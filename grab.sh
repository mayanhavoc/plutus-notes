cardano-cli transaction build \
  --alonzo-era \
  --testnet-magic 1097911063 \
  --tx-in 8fe9e91e809019984e04ff6463e78dd8b791a5961958f162e3953f4b7144e4ad#1 \
  --tx-in-script-file ./vesting.plutus \
  --tx-in-datum-file ./unit.json  \
  --tx-in-redeemer-file ./unit.json \
  --required-signer-hash 1dcdf420c1488ba345730d41f72a846428ba814c2bd639462eaf5a07 \
  --tx-in-collateral 67557dbe63d46e252276c729ebf75afe615c9903b644a37c11f6f0ac22fa8aff#0 \
  --change-address $(cat payment2.addr) \
  --invalid-before 61248042 \
  --protocol-params-file ./protocol.json \
  --out-file tx.unsigned

cardano-cli transaction sign \
    --tx-body-file tx.unsigned \
    --signing-key-file payment2.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file tx.signed
