#!/bin/bash
# usage: ./submit.sh config/0.5b_config.ini
. ../../../env.sh
BENCHMARK_OUTPUT=${BENCHMARK_OUTPUT}
init_benchmark
${SPARK_SUBMIT} --name Mock-Data-Generator \
          --deploy-mode cluster \
          --class org.apache.spark.deploy.PythonRunner \
	  --conf spark.driver.memory=6g \
	  --conf spark.kubernetes.container.image=${SPARK_IMAGE} \
	  --conf spark.executor.instances=70 \
	  --conf spark.executor.cores=2 \
	  --conf spark.executor.memory=4g \
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
	  --conf spark.task.maxFailures=10 \
          ${BENCHMARK_HOME}/benchmark/mock-data/annotation/mock_annotation_data.py \
	  ${BENCHMARK_OUTPUT} ${BENCHMARK_HOME}/benchmark/mock-data/annotation/$1 
