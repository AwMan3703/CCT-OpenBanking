--[[
    OpenBanking server
    for banks exclusively! installed on bank servers
    USES:
    - account data storage
    - provides account data to merchantsc
    - transaction management / validation
]]

local configFile = "OpenBankingConfig/serverConfig.txt" -- Config path here
local defaultConfig = {} -- Default config here

------------------------------------------THIS SECTION SHOULD BE SYNCED BETWEEN ALL OPENBANKING SOFTWARE------------------------------------------
-- load config
if not fs.exists(configFile) then
    local fh = fs.open(configFile, "w")
    fh.write(textutils.serialize(defaultConfig))
end
local configHandle = fs.open(configFile, "r")
local configData = textutils.unserialize(configHandle.readAll())
configHandle.close()

-- standard data
local stdDATELOCALE = "utc"
local stdEPOCH = function () return os.epoch(stdDATELOCALE) end

-- build OpenBanking data
local OBdataPrefix = "OpenBanking:"
local OBtransactionIDrequestMessage = OBdataPrefix.."requestTransactionID"
local OBtransactionIDrequestProtocol = OBdataPrefix.."transactionIDRequest"
local OBtransactionProtocol = OBdataPrefix.."requestTransaction"
local OBhostProtocol = OBdataPrefix.."BankComms"
local OBhostnamePrefix = OBdataPrefix.."BankServer:"
local OBhostname = function (bankname) return OBhostnamePrefix..bankname end
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Server-exclusive data
--transaction IDs look like this: OpenBanking:transaction:SomeBank@18204120240210-4853
local OBtransactionID = function () return OBdataPrefix.."transaction:"..configData.bankName.."@"..os.date("%H%M%S%Y%m%d").."-"..math.random(9999) end

-------------------------------------------------------------------- UTILITY ---------------------------------------------------------------------
function table.contains(t, element, filter)
    --this is gonna be a damn nightmare to maintain but i want it to be single-line because i am acoustic
    for _, value in ipairs(t) do if (filter and filter(value)) or (value == element) then return true end end return false
end
function table.indexOf(t, element)
    for i=1,#t do if t[i]==element then return i end end return -1
end
function table.keys(t)
    local keys={} for key,_ in pairs(t) do table.insert(keys, key) end return keys
end
--------------------------------------------------------------------------------------------------------------------------------------------------

local accounts = {} --STORES ALL ACCOUNT DATA

local transactionIDs = {} --Stores generated transaction ids and info


local function generateTransactionID()
    local genid = OBtransactionID()
    if table.contains(transactionIDs, nil,
        function(v) return v.content == genid end ) then --if an identical id is already present
        return generateTransactionID() --try again until the stack overflows (🤓☝️"but its bad practice to–" yes i know shut up)
    end
    transactionIDs[genid] = { --add to transaction IDs list
        content = genid,
        expiry = stdEPOCH() + 60000 --set expiry to one minute from now (60000 milliseconds = 60 seconds)
    }
    return transactionIDs[genid]
end

local function runTransaction(from, to, amount)
    local accountfrom = accounts[from]
    local accountto = accounts[to]

    --verify that the transaction is possible:
    if (not accountfrom) and (not accountto) then --both accounts exist
        return false, "Neither of the accounts exist"
    elseif not accountfrom then
        return false, "Funding account does not exist"
    elseif not accountto then
        return false, "Recipient account does not exist" end
    if accountfrom.balance < amount then --the account has sufficient funds
        return false, "Insufficient balance" end
    if accountfrom.transactionPolicies.maxSingleTransactionAmount < amount then
        return false, "Transaction amount exceeds single transaction limit" end
    if table.contains(accountfrom.transactionPolicies.blacklist, accountto) then --the recipient is not blacklisted
        return false, "Recipient blacklisted" end

    --transfer the desired amount
    -- wip
end


local function OBhostProtocolMessageHandler(senderID, request, protocol)
end

local function OBtransactionIDrequestHandler(senderID, request, protocol)
    return generateTransactionID()
end

local function OBtransactionRequestHandler(senderID, request, protocol)
    local response = {
        id = request.id,
        from = request.from,
        to = request.to,
        origin = senderID,
        amount = 0, --transfer nothing by default
        completed = false, --deny transaction by default
        details = "",
        date = os.date("%d-%m-%Y"),
        time = os.date("%X")
    }
    -- run a couple checks
    if senderID ~= request.client then
        response.details = "Client ID is different than declared, possible third party intermission"
        return response end
    if not transactionIDs[request.id] then
        response.details = "Invalid transaction ID"
        return response end
    if stdEPOCH() > transactionIDs[request.id].expiry then
        response.details = "Transaction ID has expired"
        return response end
    if not table.contains(accounts[request.from].sessions, senderID) then
        response.details = "Client does not have an open session on funding account"
        return response end

    -- run the actual transaction
    local success, info, description = runTransaction(request.from, request.to, request.amount)
    -- remove the transaction ID (make it no longer valid + free up memory)
    table.remove(transactionIDs, table.indexOf(transactionIDs, request.id))
    response.completed = success
    response.details = info
    return response
end



-------------------------------------------------------------------------------- SERVER STUFF --------------------------------------------------------------------------------

local protocolHandlerMappings = {
    [OBhostProtocol] = OBhostProtocolMessageHandler,
    [OBtransactionIDrequestProtocol] = OBtransactionIDrequestHandler,
    [OBtransactionProtocol] = OBtransactionRequestHandler
}

local rqc = 0 --request count
local function serverLoop(i)
    local senderID, request, protocol = rednet.receive(nil, 5)
    if not senderID then
        print("Awaiting requests...") end

    rqc = rqc + 1

    print("Received request #"..rqc)

    local response = protocolHandlerMappings[protocol](senderID, request, protocol)
    rednet.send(senderID, response, protocol)

    print("Handled request #"..rqc.." and sent response")

    return i + 1
end

-- Startup script
local hostedProtocols = table.keys(protocolHandlerMappings)
for i=1,#hostedProtocols do
    rednet.host(OBhostname(configData.bankName), hostedProtocols[i]) --host all receivable protocols
end

local serverLoopCounter = 0
while true do
    local s = pcall(
        function() while true do serverLoopCounter = serverLoop(serverLoopCounter) end end
    )
    print("Restarting to avoid stack overflow crash...")
end
