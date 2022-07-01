# Plutus On-chain code

- `BuiltinData` -> low-level data type. Cheaper and better performance (this is the level that plutarch works on).
    - The reason for this low-level data types is that they align well with Plutus Core and on-chain code gets transpiled into Plutus Core (lambda calculus bytecode that goes into the blockchain) at **compile time**.
    - Everything in the on-chain code needs to "fit" into `BuiltinData`, if it's more complex, it will eventually need to be reduced to `BuiltinData` 
        - You can wrap it **on-chain** -> expensive
        - You can wrap it **off-chain** -> arbitrary

This 👇 is the code that **validates** or not the tx i.e, if the utxos can or cannot be consumed:

```Haskell
{-# INLINABLE alwaysSucceeds #-}
alwaysSucceeds :: BuiltinData -> BuiltinData -> BuiltinData -> ()
alwaysSucceeds _ _ _ = ()

{-# INLINABLE alwaysFails #-}
alwaysFails :: BuiltinData -> BuiltinData -> BuiltinData _. ()
alwaysFails _ _ _ = error ()
```

- These are the **conditions** the transaction **must meet** in order for the utxos to be **consumed**. 


- `{-# LANGUAGE TemplateHaskell #-}` is a Haskell compiler extension, it allows you to do one thing: 
    - Plutus only uses certain parts of the libraries that it is importing. 
    - In the case of `TemplateHaskell`, Plutus uses it to **generate code at compile time**. 

    ```Haskell
    validator :: Validator
    validator = mkValidatorScript $$(PlutusTx.compile [|| goodRedeemer ||])
    ```
-                                           In order for this 👆 to be INLINABLE, you need to include the INLINABLE pragma `{-# INLINABLE goodRedeemer #-}`

## Defining the `goodRedeemer`
```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
goodRedeemer _ redeemer _ 
  | redeemer == Builtins.mkI 42         = ()
  | otherwise              = traceError "Wrong Redeemer!"

```
- This 👆 `goodRedeemer` will **succeed** if the value `42` is provided and **fail** `otherwise`. 
- The `goodRedeemer` function cares **only** about the `redeemer`.

### Why use template Haskell and `INLINABLE` pragmas? 

- To increase modularity and maintanability, i.e.,
```Haskell
  validator :: Validator
  validator = mkValidatorScript $$(PlutusTx.compile [|| goodRedeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
                                                        goodRedeemer _ redeemer _ 
                                                          | redeemer == Builtins.mkI 42         = ()
                                                          | otherwise              = traceError "Wrong Redeemer!" ||])
  ```
- 👆 This is going to be a pain to maintain.
    
```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
goodRedeemer _ redeemer _ 
  | redeemer == Builtins.mkI 42         = ()
  | otherwise              = traceError "Wrong Redeemer!
validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| goodRedeemer ||])
```
- Whereas this 👆, will allow us to update `goodRedeemer` without modifying the `validator` (it's also more readable). 

- The `Builtins.mkI` is a necessary wrapper function that turns the `Int` type into a `BuiltinData` type. The `I` is the constructor inside `BuiltinData` for **integer** values, not **floats**.
### What does the template Haskell do exactly?

- It takes the `goodRedeemer` function and generates the Plutus Core script code that goes into the blokchain. 
- In order to do that, all data types and functions **must be** `INLINABLE`, that is why plutus has its own prelude library (`PlutusTx.Prelude`), it includes the `INLINABLE` versions of the **basic functions** (not all, it is a *subset* of prelude) of prelude in Haskell. 

### `valHash`

```Haskell
valHash :: Ledger.ValidatorHash
valHash = Script.validatorHash validator

scrAddress :: Ledger.Address
scrAddress = scriptAddress validator
```

- In this case, the `Script` in the `valHash` function is calling the high-level type of `Script`, however it's name doesn't change. This will happen often as is designed to avoid rewriting too much code when making changes. This way, you can jump from a high to a low level or vice versa without changing all of the code because the functions will be calling the same **if you are using the same qualifier** (What is a qualifier? Which is the qualifier in this case? ) 


## Function evaluations

- `goodRedeemer` -> `Validator { <script> }`
- `validator`

- `scrAddress`