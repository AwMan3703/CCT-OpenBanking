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

-- build OpenBanking data
local OBdataPrefix = "OpenBanking:"
local OBtransactionIDrequestMessage = OBdataPrefix.."requestTransactionID"
local OBtransactionIDrequestProtocol = OBdataPrefix.."transactionIDRequest"
local OBtransactionProtocol = OBdataPrefix.."requestTransaction"
local OBhostProtocol = OBdataPrefix.."BankComms"
local OBhostnamePrefix = OBdataPrefix.."BankServer:"
local OBhostname = function (bankname) return OBhostnamePrefix..bankname end
--------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------- UTILITY -----------------------------------------------------------------------------------
function table.contains(table, element)
    for _, value in pairs(table) do if value == element then return true end end return false -- one liner functions go brrrrr
end
function table.keys(t)
    local keys={} for key,_ in pairs(t) do table.insert(keys, key) end return keys
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local accounts = {} --STORES ALL ACCOUNT DATA

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
        return false, "Transaction amount exceeds single transaction limit"
    end
    if table.contains(accountfrom.transactionPolicies.blacklist, accountto) then --the recipient is not blacklisted
        return false, "Recipient blacklisted" end

    --transfer the desired amount
    -- wip
end


local function OBhostProtocolMessageHandler(senderID, request, protocol)
end

local transactionIDoffset = 0 --ensure that every transaction id is unique
local function OBtransactionIDrequestHandler(senderID, request, protocol)

end

local function OBtransactionRequestHandler(senderID, request, protocol)
    local response = {
        id = request.id,
        from = request.from,
        to = request.to,
        origin = senderID,
        amount = request.amount,
        completed = false, --deny transaction by default
        details = "",
        date = os.date("%d-%m-%Y"),
        time = os.date("%X")
    }
    -- run a couple checks
    if senderID ~= request.client then
        response.details = "Client ID is different than declared, possible third party intermission"
        return response end
    if not table.contains(accounts[request.from].logins, senderID) then
        response.details = "Client is not logged into funding account"
        return response end
    

    -- run the actual transaction
    local success, info, description = runTransaction(request.from, request.to, request.amount)
    request.completed = success
    request.details = info
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
