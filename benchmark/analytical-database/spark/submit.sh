#!/bin/bash
# usage: ./submit.sh 0.1b_config.ini
. ../../../env.sh

${SPARK_SUBMIT} --name Benchmark-SparkSQL \
          --deploy-mode cluster \
          --class org.apache.spark.deploy.PythonRunner \
	  --conf spark.driver.memory=6g \
	  --conf spark.kubernetes.container.image=${SPARK_IMAGE} \
	  --conf spark.executor.instances=1 \
	  --conf spark.executor.cores=20 \
	  --conf spark.executor.memory=40g \
          --conf spark.kubernetes.driver.volumes.hostPath.benchmark.options.path=${BENCHMARK_HOME} \
          --conf spark.kubernetes.driver.volumes.hostPath.benchmark.mount.path=${BENCHMARK_HOME} \
          --conf spark.kubernetes.executor.volumes.hostPath.benchmark.options.path=${BENCHMARK_HOME} \
          --conf spark.kubernetes.executor.volumes.hostPath.benchmark.mount.path=${BENCHMARK_HOME} \
          --conf spark.kubernetes.file.upload.path=${SPARK_K8S_UPLOAD_PATH} \
          --conf spark.kubernetes.driver.node.selector.${BENCHMARK_LABEL} \
	  --conf spark.kubernetes.executor.node.selector.${BENCHMARK_LABEL} \
          --conf spark.eventLog.enabled=true \
          --conf spark.eventLog.dir=${SPARK_EVENTLOG_DIR} \
	  --conf spark.history.fs.logDirectory=${SPARK_EVENTLOG_DIR} \
          ${BENCHMARK_HOME}/benchmark/analytical-database/spark/exec.py \
	  ${BENCHMARK_HOME}/benchmark/analytical-database/spark/$1
