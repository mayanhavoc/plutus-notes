# Plutus Vesting Contract

## On-chain code

- The contract is going to ignore the redeemer and use the datum. 
- The contract will work like this:
    - take eutxos (value)
    - lock it to a smart contract
        - two conditions to consider:
            - the right account requesting the funds
            - the deadline must be met

## Datum

- `data VestingDatum` uses bracket notation to pass the two values: `beneficiary :: PaymentPubKeyHash` and `deadline :: POSIXTime`
- `beneficiary :: PaymentPubKeyHash` - we need to get the hash of the public key of "somebody". this means that this "somebody" must have signed the transaction, which is where we get the pubkeyhash with their payment signing key.
- `deadline :: POSIXTime` - POSIXTime is a Unix standard that counts time in miliseconds. 
- we inject the `VestingDatum` type into the context with `PlutusTx.unstableMakeIsData`
- The vesting validator takes the datum, it ignores the redeemer, takes a script context (which we're going to use), and returns a bool. 

## Validator

- 


## Off-chain code