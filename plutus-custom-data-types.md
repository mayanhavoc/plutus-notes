# Plutus Custom Data Types

## On-chain code

### Custom data type

- Very important difference between high-level typed PlutusTx but basic types on Haskell vs advanced data types on Haskell is the use of
    - `PlutusTx.unstableMakeIsData ''MyWonderfullRedeemer` -> writes at compile time an instance of the data type (there is a `stableMakeIsData`, we are using this because this was has been used in examples so there are resources available).
        - This notation `''MyWonderfullRedeemer` gets (💉) injected by one of Haskell's compiler extensions (i.e., `{-# LANGUAGE <Compiler-extension-name> #-}`
- `newtype MyWonderfullRedeemer = MWR Integer`
- The difference is that this `Integer` alone (as in the `TypedValidator` contract) is a basic Haskell data type that already exists in the Prelude, it's already INLINABLE, **but** `MyWonderfullRedeemer` is **not**.

### Custom data type Redeemer

- 👇 **Typed Redeemer**
```Haskell
{-# INLINABLE typedRedeemer #-} 
typedRedeemer :: () -> Integer -> ScriptContext -> Bool   
typedRedeemer _ redeemer _ = traceIfFalse "wrong redeemer" (redeemer == 42)
```

- 👇 **Custom** Typed Redeemer
```Haskell
{-# INLINABLE customTypedRedeemer #-} 
customTypedRedeemer :: () -> MyWonderfullRedeemer -> ScriptContext -> Bool   
customTypedRedeemer _ (MWR redeemer) _ = traceIfFalse "wrong redeemer" (redeemer == 42)
```
- The redeemer type `Integer` is now `MyWonderfullRedeemer`, (i.e, `newtype MyWonderfullRedeemer = MWR Integer`)
- In order to **pattern match** the **data constructor**, - aka - - - - - - - - - - - - - - - - - - 👆
    - `redeemer` in (`typedRedeemer _ redeemer _ = traceIfFalse "wrong redeemer" (redeemer == 42)`) 
        - is now `customTypedRedeemer _ (MWR redeemer) _ = traceIfFalse "wrong redeemer" (redeemer == 42)`
            - *notice the `(MWR)`*
        - basically, we are defining a wrapper `MyWonderfullRedeemer` which 
            - contains an `Integer` value, (`MWR Integer`) 
                - which can extracted through **pattern matching** *(see couple lines before)*   


- **Custom** `data Typed`

- Typed
```Haskell
data Typed                                            
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()                
    type instance RedeemerType Typed = Integer 
```

**Custom** Typed
```
data Typed                                            
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed = ()                
    type instance RedeemerType Typed = MyWonderfullRedeemer 
```
- All that changes is we need to change `Integer` to the new type `MyWonderfullRedeemer`

### What is `PlutusTx.unstableMakeIsData` doing?
- Plutus has a prelude library because in it, all data types (i.e., `head`, `tail`, etc.) are `INLINABLE`. They need to be in order to be inserted into the template Haskell that later gets compiled into Plutus Core, etc., etc.
    - However, here we are using our own **custom** data type with arbitrary logic. 
        - This data type is not included in the Plutus Prelude library **and is not** `INLINABLE`
    - That's where `PlutusTx.unstableMakeIsData` (there's also `PlutusTx.stableMakeIsData`), it allows us to make our own **custom data types** `INLINABLE`  

### Custom Typed Validator

- Typed Validator
```Haskell
typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed      
    $$(PlutusTx.compile [|| typedRedeemer ||]) 
    $$(PlutusTx.compile [|| wrap ||])                
  where
    wrap = Scripts.wrapValidator @() @Integer  
```

- **Custom** Typed Validator
```Haskell
typedValidator :: Scripts.TypedValidator Typed
typedValidator = Scripts.mkTypedValidator @Typed      -- Tell the compiler that you are using Types
    $$(PlutusTx.compile [|| typedRedeemer ||]) 
    $$(PlutusTx.compile [|| wrap ||])                -- Provide the translation into high level typed to low level typed
  where
    wrap = Scripts.wrapValidator @() @MyWonderfullRedeemer 
```
- Again, the only change is the substitution of the `Integer` data type for the `MyWonderfullRedeemer` data type