--[[
    OpenBanking client
    client software, installed on customers devices
    USES:
    - pay
    - send money (non commercial)
    - receive money (non commercial)
]]

local configFile = "OpenBankingConfig/clientConfig.txt" -- Config path here
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

local OBserverID = rednet.lookup(OBhostProtocol, OBhostname(configData.bankName))

local function rednet_comm(recipient, message, protocol) -- sends {message} to {recipient} under protocol {protocol} via the rednet API, then awaits a response and returns it
    peripheral.find("modem", rednet.open) --open all modems
    rednet.send(recipient, message, protocol)
    local responder, response, protocol = rednet.receive(protocol)
    return responder, response, protocol
end

local function requestTransactionId()
    local _, response, _ = rednet_comm(OBserverID, {OBtransactionIDrequestMessage}, OBtransactionIDrequestProtocol)
    if not response.successful then return nil end --if no valid ID could be generated, return nil
    return response.content.content, response.content.expiry
end

local function requestTransaction(id_from, id_to, amount) -- send {amount} money to {id}
    local request = {
        id = requestTransactionId(),
        from = id_from,
        to = id_to,
        amount = amount
    }
    local _, response, _ = rednet_comm(OBserverID, request, OBtransactionProtocol)
    local summary = "Transaction "..(response.completed and "completed" or "denied").." on "..response.date.." at "..response.time.." ("..response.details..") - transaction id: "..response.id
    return summary, response.completed, response.details
end
