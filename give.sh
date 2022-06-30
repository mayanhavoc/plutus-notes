cardano-cli transaction build \
  --alonzo-era \
  $TESTNET \
  --tx-in a70fbf5e7737e2f212fd32a6bb45d5008979f874d2a50ee4904cf98a76804b8e#1 \
  --tx-in b4412ff5ac256a996cbe0bf647be55e2650d535fb8e73cc9f534a50d505dc640#1 \
  --tx-out $(cat vesting.addr)+200000000 \
  --tx-out-datum-hash-file unit.json \
  --change-address $nami \
  --out-file tx.unsigned

cardano-cli transaction sign  \
  --tx-body-file tx.unsigned  \
  --signing-key-file Adr07.skey  \
  $TESTNET  \
  --out-file tx.signed

cardano-cli transaction submit  \
  $TESTNET \
  --tx-file tx.signed
