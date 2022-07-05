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

## Validator

### Type signature
- Pass the datum data type `VestingDatum`
- Ignore the redeemer
- Pass the script context 
- Answer bool

### Runction expression**
- vesting validator takes the datum, unit and script context
- using `traceIfFalse` we define the message for `false` and call it with `signedByBeneficiary` and traceIfFails "Deadline not reached" and call it with deadlineReached 
    - you can do a lot of traceIfFalse with different validations depending on the use case
    - in this case, we are implying two
        - the beneficiary must have signed the tx
        - the deadline has to have been reached and passed
### Before we move on, a slight problem with the deadline
- The tx doesn't have a specific time, but a **range**
- This **range** of the tx needs to be **after** the deadline, middle positions don't work, all ranges must be after the deadline

### Script context
- The script context is a wrapper for two types
    
    - A `TxInfo` -> which has information about
        - tx inputs 
        - tx outputs 
        - fees paid by the tx
        - value minted by the tx
        - digests of certs included in the tx
        - withdrawals
        - valid range for the tx - uses the POSIX time range
        - signatures provided with the tx attested that they all signed the tx 
            - `txInfoSignatories :: [PubKeyHash]` -> it has the key hashes of any of the signers of the transaction
        - the datum and the hash of the datum `txInfoData :: [(DatumHash, Datum)]`
        - hash of the pending transaction (excluding witnesses)
        - tx id -> `txInfoId :: TxId`
    
    - A `ScriptPurpose` -> payment
        - Minting
        - Spending
        - Rewarding
        - Certifying



## Off-chain code