
#### Config structure

###### CLIENT CONFIG DATA STRUCTURE
{
    bankName = "[name of the bank hosting this server]"
}

###### SERVER CONFIG DATA STRUCTURE
{
    bankName = "[name of the bank hosting this server]"
}


#### Data structure

###### TRANSACTION DATA STRUCTURE (Request)
{
    *id* = "[transaction id]",
    *from* = "[account id of sender]",
    *to* = "[account id of recipient]",
    *client* = [id of the computer that requested the transaction],
    *amount* = [amount transferred]
}

###### TRANSACTION DATA STRUCTURE (Response)
{
    *id* = "[transaction id]",
    *from* = "[account id of sender]",
    *to* = "[account id of recipient]",
    *origin* = [id of the computer that requested the transaction],
    *amount* = [amount transferred],
    *completed* = [true/false, wether the transaction was completed]
    *details* = "[additional transaction details]",
    *date* = "[gg/mm/yyyy transaction date]",
    *time* = "[hh:mm:ss transaction time]"
}

###### TRANSACTION ID REQUEST DATA STRUCTURE (Request)
{
    "[id request message]"
}

###### TRANSACTION ID REQUEST DATA STRUCTURE (Response)
{
    [generated id table (see TRANSACTION ID DATA STRUCTURE)]
}

###### TRANSACTION ID DATA STRUCTURE
{
    *content* = "[the id itself]",
    *expiry* = [utc epoch date of expiry],
}

###### ACCOUNT DATA STRUCTURE
{
    *id* = "[unique identifier]",
    *psw* = "[password hash]",
    *holder* = {
        name = "[account holder name]",
        lastname = "[account holder last name]",
    },
    *transactionPolicies* = {
        *maxSingleTransactionAmount* = [maximum amount per transaction],
        *blacklist* = { [array of account IDs to never transfer funds to] },
        *allowRemote* = [true/false wether to allow]
    }
    *balance* = [total account balance],
    *sessions* = { [array of computer IDs the account has an open session on] }
}
