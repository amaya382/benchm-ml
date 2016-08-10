-- amplify for iteration(TABLE ver.)
--DROP TABLE train_${size}_${niters};
--CREATE EXTERNAL TABLE train_${size}_${niters}(
--  rowId int,
--  features array<int>,
--  label int
--) STORED AS SEQUENCEFILE
--LOCATION '${dir}/train/${size}_${niters}/';
--INSERT OVERWRITE TABLE train_${size}_${niters}
--SELECT *
--FROM (
--  SELECT amplify(${niters}, *) AS (rowId, features, label)
--  FROM train_${size}
--) t
--CLUSTER BY RAND(1);

-- amplify for iteration(VIEW ver.)
--CREATE OR REPLACE VIEW view_train_${size}
--AS SELECT *
--FROM (
--  SELECT amplify(${niters}, *) AS (rowId, features, label)
--  FROM train_${size}
--) t
--CLUSTER BY RAND(1);

-- train
DROP TABLE model_logress_${size};
CREATE EXTERNAL TABLE model_logress_${size}(
  feature int,
  weight double
) STORED AS ORC
LOCATION '${dir}/model/logress/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE model_logress_${size}
SELECT
  CAST(t.feature AS int),
  AVG(t.weight)
FROM (
  SELECT logress(add_bias(features), label, "-t 1000000 -eta0 0.125")
  FROM train_${size}
--  FROM train_${size}_${niters}
--  FROM view_train_${size}
) t
GROUP BY feature;

-- explode
DROP TABLE test_exploded_${size};
CREATE EXTERNAL TABLE test_exploded_${size}(
  rowId int,
  label int,
  feature double,
  value double
) STORED AS ORC
LOCATION '${dir}/exploded/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE test_exploded_${size}
SELECT
  rowId,
  label,
  extract_feature(feature) AS feature,
  extract_weight(feature) AS value
FROM
  test_${size} LATERAL VIEW explode(add_bias(features)) t AS feature;

-- test
DROP TABLE prediction_logress_${size};
CREATE EXTERNAL TABLE prediction_logress_${size}(
  rowId int,
  prob double
) STORED AS ORC
LOCATION '${dir}/prediction/logress/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE prediction_logress_${size}
SELECT
  t.rowId,
  sigmoid(SUM(m.weight * t.value))
FROM
  test_exploded_${size} t LEFT JOIN model_logress_${size} m
    ON t.feature = m.feature
GROUP BY t.rowId;

-- eval
DROP TABLE result_logress_${size};
CREATE EXTERNAL TABLE result_logress_${size}(
  actual double,
  prob double
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '${dir}/result/logress/${size}/';
INSERT OVERWRITE TABLE result_logress_${size}
SELECT
  label,
  prob
FROM
  test_${size} t LEFT JOIN prediction_logress_${size} p
    ON t.rowId = p.rowId;
