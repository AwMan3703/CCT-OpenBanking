
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
    *amount* = [amount transferred],
    *completed* = [true/false, wether the transaction was completed]
    *details* = "[additional transaction details]",
    *date* = "[gg/mm/yyyy transaction date]",
    *time* = "[hh:mm:ss transaction time]",
    *epoch* = [epoch date of transaction]
}

###### TRANSACTION ID REQUEST DATA STRUCTURE (Request)
{
    "[id request message]"
}

###### TRANSACTION ID REQUEST DATA STRUCTURE (Response)
{
    *content* = [generated id table (see TRANSACTION ID DATA STRUCTURE)],
    *successful* = [true/false wether the ID was generated successfully]
}

###### TRANSACTION ID DATA STRUCTURE
{
    *content* = "[the id itself]",
    *expiry* = [utc epoch date of expiry],
}

###### ACCOUNT DATA STRUCTURE
{
    *id* = "[unique identifier]",
    *password* = "[password hash]",
    *holder* = {
        name = "[account holder name]",
        lastname = "[account holder last name]"
    },
    *transactionPolicies* = {
        *maxSingleTransactionAmount* = [maximum amount per transaction],
        *blacklist* = { [array of account IDs to never transfer funds to] }
    }
    *balance* = [total account balance],
    *sessions* = { [array of computer IDs the account has an open session on] }
}

###### ACCOUNT CREATION REQUEST DATA STRUCTURE (Request)
{
    *holder* = {
        name = "[account holder name]",
        lastname = "[account holder last name]"
    },
    *password* = "[plain password]"
}

###### ACCOUNT CREATION REQUEST DATA STRUCTURE (Response)
{
    *id* = "[unique identifier for the newly created account]"
<<<<<<< HEAD
    *successful* = [true/false wether the account was created successfully]
=======
>>>>>>> 06bbd3bda305bfb51f1dc662e504a2c62b491d85
}

###### ACCOUNT CLOSURE REQUEST DATA STRUCTURE (Request)
{
    *password* = "[plain password (to confirm)]"
}

###### ACCOUNT CLOSURE REQUEST DATA STRUCTURE (Response)
{
    *id* = "[unique identifier for the closed account]",
    *successful* = [true/false wether the account was closed successfully]
}
