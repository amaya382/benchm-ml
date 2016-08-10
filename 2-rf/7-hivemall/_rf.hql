-- train
DROP TABLE model_rf_${size};
CREATE EXTERNAL TABLE model_rf_${size}(
  model_id string,
  model_type int,
  pred_model string,
  var_importance array<double>,
  oob_errors int,
  oob_tests int
) STORED AS ORC
LOCATION '${dir}/model/rf/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE model_rf_${size}
  SELECT train_randomforest_classifier(features, label, "-trees 84 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size}
UNION ALL
  SELECT train_randomforest_classifier(features, label, "-trees 84 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size}
UNION ALL
  SELECT train_randomforest_classifier(features, label, "-trees 83 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size}
UNION ALL
  SELECT train_randomforest_classifier(features, label, "-trees 83 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size}
UNION ALL
  SELECT train_randomforest_classifier(features, label, "-trees 83 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size}
UNION ALL
  SELECT train_randomforest_classifier(features, label, "-trees 83 -vars 3 -attrs C,C,C,Q,C,C,C,Q")
  FROM train_${size};

-- test
DROP TABLE prediction_rf_${size};
CREATE TABLE prediction_rf_${size}(
  rowId int,
  label int,
  prob double,
  probs array<double>
) STORED AS ORC
LOCATION '${dir}/prediction/rf/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE prediction_rf_${size}
SELECT
  rowId,
  p.label,
  p.probability,
  p.probabilities
FROM (
  SELECT
    rowId,
    rf_ensemble(p) AS p
  FROM (
    SELECT
      u.rowId,
      tree_predict(t.model_id, t.model_type, t.pred_model, u.features, true) AS p
    FROM (
      SELECT model_id, model_type, pred_model
      FROM model_rf_${size}
      DISTRIBUTE BY RAND(1)
    ) t LEFT JOIN test_${size} u
  ) v
  GROUP BY rowId
) w;

-- eval
DROP TABLE result_rf_${size};
CREATE EXTERNAL TABLE result_rf_${size}(
  actual double,
  prob double
)ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '${dir}/result/rf/${size}/';
INSERT OVERWRITE TABLE result_rf_${size}
SELECT
  t.label,
  p.probs[1]
FROM
  test_${size} t LEFT JOIN prediction_rf_${size} p
    ON t.rowId = p.rowId;
