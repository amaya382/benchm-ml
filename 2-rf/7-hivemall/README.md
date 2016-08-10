### Hivemall(Random Forest, 500 trees, 3 vars)

#### Usage

1. Preprocessing
  * Put `{train-${size}, test}.csv` into this directory
  * Execute `benchm_hivemall_preprocessing`

  and then

  * Put `data_{train-${size}, test}.csv` into your s3 bucket(`data/{train/${size}/here, test/here}`)
  * Edit path in `benchm_hivemall`

2. Execution and evaluation
  * Execute `benchm_hivemall`


#### Results

##### Environment
  * EC2: m3.xlarge \* 3 + c3.2xlarge \* 3
  * Hadoop: Amazon 2.7.2
  * Tez: 0.8.4
  * Hive: 2.1.0
  * Hivemall: 0.4.2-RC2

##### Time[sec] / AUC

|size|0.01M|0.1M|1M|10M|
|:--:|:--:|:--:|:--:|:--:|
|**Time[sec] / AUC**|12.52 / 68.275|43.06 / 70.793|<3600 /|/|
