#!/bin/bash
#echo "[INFO] Start Clickhouse Benchmark"
#cd /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/clickhouse
#./pipeline.sh
#echo "[INFO] Start SparkSQL Benchmark"
#cd /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/spark
#./pipeline.sh
echo "[INFO] Start DuckDB Benchmark"
cd /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/duckdb
kubectl -n benchmark create -f ./exec-on-k8s.yaml
