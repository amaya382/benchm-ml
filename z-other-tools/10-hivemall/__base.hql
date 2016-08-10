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

