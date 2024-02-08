
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

###### TRANSACTION ID DATA STRUCTURE (Request)
{}

###### TRANSACTION ID DATA STRUCTURE (Response)
{}

###### ACCOUNT DATA STRUCTURE
{
    *id* = "[unique identifier]",
    *psw* = "[password hash]",
    *holder* = {
        name = "[account holder name]",
        lastname = "[account holder last name]",
    },
    *transactionPolicies* = {
        *maxTransferAmount* = [maximum amount per transaction],
        *blacklist* = { [array of account IDs to never transfer funds to] },
        
    }
    *balance* = [total account balance],
    *logins* = { [array of computer IDs the account is logged on] }
}
