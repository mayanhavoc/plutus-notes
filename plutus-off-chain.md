# Plutus Off-chain

```Haskell
type GiftSchema = 
            Endpoint "give" Integer
        .\/ Endpoint "grab" Integer
```
- Notice that, unlike `alwaysSucceeds`, `goodRedeemer` **does** have a redeemer with type `Int`, so we must its type in the `GiftSchema`.
