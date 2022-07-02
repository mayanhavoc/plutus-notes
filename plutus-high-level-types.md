---
ref: 02 - TypedValidator.hs
week: 1
program: Emurgo Developer Professional
date: 01/07/2022
---

# Plutus High Level Types

## On-chain Code

### Library changes**
- `imported qualified Ledger.Scripts as Scripts` 🤖 👉  `imported qualified Ledger.Typed.Scripts as Scripts`


### INLINABLE function changes**
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
- No longer uses `BuiltinData` (we are using **high-level** types), so **proper types** need to be defined
    - the **redeemer**, i.e., `Integer` and 
    - the `ScriptContext`
    - returns `()` for the datum (we don't want to consider the type of unit) -> *unit is the representation of something that is itself ("the empty tuple, is just an empty tuple").*
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
```

### data Typed

```
data Typed
instance. Scripts.ValidatorTypes Typed where
    type instance DatumType Typed    = ()
    type instance RedeemerType Type  = Integer
```
- `data Typed` -> create instances of validator types
    - Typed **unit** instance -> `type instance DatumType Typed    = ()`
    - Typed **integer** instance -> `type instance RedeemerType Type  = Integer`

- 👆 This is required in order to 
    - use `()` as a **datum** type -> `type instance DatumType Typed    = ()` 
    - `Integer` as a **redeemer** type -> `type instance RedeemerType Type  = Integer`

- The `ScriptContext` represents information about the whole transaction
    - You can take **time** information from the tx moment of execution (Plutus has tools to work in POSIX time, which is why it's not necessary to use slot no.s)

- The redeemer now considers the output of the transaction (it is using **high level** types), which is a `Bool` -> valid/not valid

### Typed Validator
```Haskell
typedValidator :: Scripts.TypedValidator Typed
```
- The validator is of type `Scripts.TypedValidator` and as a parameter, the `Typed` data type we just defined:
```Haskell
data Typed
instance. Scripts.ValidatorTypes Typed where
    type instance DatumType Typed    = ()
    type instance RedeemerType Type  = Integer
```
- `Typed` data type **implies** 
    - the `DatumType` and 
    - the `RedeemerType`

- We are 💉 (injecting) 
    - the Datum's and Redeemer's types
    - `Scripts.mkTypedValidator` which exposes the compiler extension `@Typed` which allows the (💉)injection of types
```Haskell
typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
```

- splice two things in 
    - the compile of the on-chain redeemer `$$(PlutusTx.compile [|| goodRedeemer ||])`
    - the wrapper for the compiler (because it is a high level type, it needs to be wrapped/mapped to low level types)
        - using the `wrap` auxiliary function
        - `$$(PlutusTx.compile [|| wrap ||])`
     - this happens with the help of an auxiliary function
        - `wrap = Scripts.wrapValidator @() @Integer`

```Haskell
{-# INLINABLE goodRedeemer #-}
goodRedeemer :: () -> Integer -> ScriptContext -> Bool
goodRedeemer _ redeemer _ = traceIfFalse "Wrong Redeemer" (redeemer == 42)

data Typed
instance. Scripts.ValidatorTypes Typed where
    type instance DatumType Typed    = ()
    type instance RedeemerType Type  = Integer

typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed
  $$(PlutusTx.compile [|| goodRedeemer ||])
  $$(PlutusTx.compile [|| wrap ||])
where
  wrap = Scripts.wrapValidator @() @Integer
```
- aux function 👆              👆 inject datum `@()` and redeemer `@Integer` data types 

### Typed Validator Script

```Haskell
validator :: Validator
validator = mkValidatorScript typedValidator
```
- The `mkValidatorScript` takes a `Typed` validator (`typedValidator`) as **input**

### Typed Hash Validator
```Haskell
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash typedValidator
```
- The `valHash` also takes a `Typed` validator (`typedValidator`) as **input**

and now the `scrAddress` function can take the `validator` we have defined:
- This validator (`validator = mkValidatorScript typedValidator`) evaluates to `validator {<script>}` **but**
    - it includes extra data: `$$(PlutusTx.compile [|| wrap ||])` (which is very expensive) 🚨 <- ??


## Off-chain Code

