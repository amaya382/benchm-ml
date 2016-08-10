### Hivemall(Random Forest, 100 trees, depth 20)

#### Usage

1. Preprocessing
  * Put `{train-${size}, test}.csv` into this directory
  * Execute `benchm_hivemall_preprocessing`

  and then

  * Put `data_{train-${size}, test}.csv` into your s3 bucket(`data/{train/${size}/here, test/here}`)
  * Edit path in `benchm_hivemall`

2. Execution and evaluation
  * Execute `benchm_hivemall`
