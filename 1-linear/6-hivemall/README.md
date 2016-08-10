### Hivemall(Logistic Regression)

#### Usage

1. Preprocessing
  * Put `{train-${size}, test}.csv` into this directory
  * Execute `benchm_hivemall_preprocessing`

  and then

  * Put `data_{train-${size}, test}.csv` into your s3 bucket(`data/{train/${size}/here, test/here}`)
  * Edit path in `benchm_hivemall`

2. Execution and evaluation
  * Execute `benchm_hivemall`
    * If you need iterative execution, edit `_logress.hql` and execute as `benchm_hivemall ${niters}`


#### Results

##### Environment
  * EC2: m3.xlarge \* 3 + c3.2xlarge \* 3
  * Hive: 2.1.0
  * Tez: 0.8.4

##### Time[sec] / AUC

|#iters\size|0.01M|0.1M|1M|10M|
|:--:|:--:|:--:|:--:|:--:|
|**1**|16.53 / 54.283|18.56 / 62.928|22.84 / 66.618|31.12 / 69.547|
|**10**|/|/|/|101.65 / 69.610|
|**100**|16.23 / 59.077|20.84 / 67.536|101.57 / 69.318|398.87 / 69.652|
