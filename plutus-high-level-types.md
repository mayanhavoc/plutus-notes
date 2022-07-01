---
ref: 02 - TypedValidator.hs
week: 1
program: Emurgo Developer Professional
date: 01/07/2022
---

# Plutus High Level Types

**Library changes**
- `imported qualified Ledger.Scripts as Scripts` 🤖 👉  `imported qualified Ledger.Typed.Scripts as Scripts`


**INLINABLE function changes**
```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: BuiltinData -> BuiltinData -> BuitinData -> ()
goodRedeemer _ redeemer _
  | redeemer == Builtins.mkI 42       = ()
  | otherwise                         = traceError "Wrong Redeemer!"
```
🤖 👇 
```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: () -> Integer -> ScriptContext -> Bool
goodRedeemer _ redeemer _ = traceIfFalse "Wrong Redeemer" (redeemer == 42)
```
- Uses proper types for 
    - the **redeemer**, i.e., `Integer` and 
    - the `ScriptContext`
- Returns `()` for the datum 
- The **output** in this case is not `()`, it's `Bool`, **yes** or **no**.
- Takes a **redeemer** and 
    - The boolean function `traceIfFalse` will pass the **error** message (i.e, `"Wrong Redeemer"`) against the **validation** `(redeemer == 42)`
    - Because the types *align* (How exactly?), **it no longer needs the `BuiltinData` auxiliary wrapper function**

### The thing with the Typed version...

The high level types (`Integer`, `ScriptContext`, `Bool`) need to be wrapped into low level types, and that requires more boilerplate:

```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: () -> Integer -> ScriptContext -> Bool
goodRedeemer _ redeemer _ = traceIfFalse "Wrong Redeemer" (redeemer == 42)

data Typed
instance. Scripts.ValidatorTypes Typed where
    type instance DatumType Typed    = ()
    type instance RedeemerType Type  = Integer
```
- `data Typed` -> create instances of validator types
    - Typed **unit** instance -> `type instance DatumType Typed    = ()`
    - Typed **integer** instance -> `type instance RedeemerType Type  = Integer`

