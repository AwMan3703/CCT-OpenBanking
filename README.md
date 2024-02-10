# CCT OpenBanking
### Banking system for the CC:Tweaked mod
Can be forked to create software for a specific bank, customizing bank name, policies and whatever else you can think of. All scripts define a config file to quickly tweak settings (“OpenBankingConfig/<script name>Config.txt”, formatted as done by `textutils.serialize()`)

#### Providing 3 separate scripts:
- CLIENT
  - Installed on customers’ devices
  - Used to pay (to `merchant`s) or transfer money (to other `client`s)
- SERVER
  - Installed on bank's server
  - Manages accounts and transactions
- MERCHANT
  - Used as a paypoint, to receive payments from `client`s
