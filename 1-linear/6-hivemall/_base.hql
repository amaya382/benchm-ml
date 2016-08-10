-- set
SET dfs.replication=6;
SET mapreduce.map.speculative=false;
SET mapreduce.reduce.speculative=false;
SET mapred.reduce.tasks=6;

-- preparing hivemall
ADD JAR hivemall-core-0.4.2-rc.2-with-dependencies.jar;
SOURCE define-all.hive;

-- create DB
CREATE DATABASE IF NOT EXISTS benchm;
USE benchm;

-- create table
DROP TABLE data_train_${size};
CREATE EXTERNAL TABLE data_train_${size}(
  rowId int,
  Month string,
  DayofMonth string,
  DayOfWeek string,
  DepTime int,
  UniqueCarrier string,
  Origin string,
  Dest string,
  Distance int,
  dep_delayed_15min string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '${dir}/data/train/${size}'
TBLPROPERTIES('skip.header.line.count' = '1');

DROP TABLE data_test;
CREATE EXTERNAL TABLE data_test(
  rowId int,
  Month string,
  DayofMonth string,
  DayOfWeek string,
  DepTime int,
  UniqueCarrier string,
  Origin string,
  Dest string,
  Distance int,
  dep_delayed_15min string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '${dir}/data/test'
TBLPROPERTIES('skip.header.line.count' = '1');

-- feature -- train
DROP TABLE train_${size};
CREATE EXTERNAL TABLE train_${size}(
  rowId int,
  features array<int>,
  label int
) STORED AS SEQUENCEFILE
LOCATION '${dir}/train/${size}/';
INSERT OVERWRITE TABLE train_${size}
SELECT
  rowId,
  array(Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance),
  label
FROM(
  SELECT
    quantify(true, rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance,
        IF(dep_delayed_15min = 'Y', 1, 0))
      AS (rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance, label)
  FROM(
    SELECT * FROM data_train_${size} ORDER BY rowId ASC
  ) t
) u;

-- feature -- test
DROP TABLE test_${size};
CREATE EXTERNAL TABLE test_${size}(
  rowId int,
  features array<int>,
  label int
) STORED AS ORC
LOCATION '${dir}/test/${size}/'
TBLPROPERTIES ("orc.compress" = "SNAPPY");
INSERT OVERWRITE TABLE test_${size}
SELECT
  rowId,
  array(Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance),
  label
FROM (
  SELECT
    quantify(output_row, rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance,
        IF(dep_delayed_15min = 'Y', 1, 0))
      AS (rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance, label)
  FROM (
    SELECT *
    FROM (
        SELECT 1 AS train_first, false AS output_row, rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance, dep_delayed_15min
        FROM data_train_${size}
      UNION ALL
        SELECT 2 AS train_first, true AS output_row, rowId, Month, DayofMonth, DayOfWeek, DepTime, UniqueCarrier, Origin, Dest, Distance, dep_delayed_15min
        FROM data_test
    ) t
    ORDER BY train_first ASC, rowId ASC
  ) u
) v;

