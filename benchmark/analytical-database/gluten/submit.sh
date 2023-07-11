#!/bin/bash
# usage: ./submit.sh config/0.5b_config.ini
. ../../../env.sh 
${SPARK_SUBMIT} --name Benchmark-Gluten \
          --deploy-mode cluster \
          --class org.apache.spark.deploy.PythonRunner \
	  --conf spark.driver.memory=4g \
	  --conf spark.kubernetes.container.image=crazytempo/spark-py-gluten:v3.3.1-0.5.0 \
	  --conf spark.plugins=io.glutenproject.GlutenPlugin \
	  --conf spark.gluten.sql.columnar.backend.lib=velox \
          --conf spark.memory.offHeap.enabled=true \
          --conf spark.memory.offHeap.size=20g \
          --conf spark.gluten.loadLibFromJar=true \
	  --conf spark.gluten.sql.columnar.forceShuffledHashJoin=true \
          --conf spark.shuffle.manager=org.apache.spark.shuffle.sort.ColumnarShuffleManager \
	  --conf spark.executor.instances=1 \
	  --conf spark.executor.cores=20 \
	  --conf spark.executor.memory=20g \
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
          ${BENCHMARK_HOME}/benchmark/analytical-database/gluten/exec.py \
	  ${BENCHMARK_HOME}/benchmark/analytical-database/gluten/$1
