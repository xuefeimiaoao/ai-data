#!/bin/bash
# lighter-submit is an encapsulation of spark-submit, and acts as spark-submit
# usage: ./submit.sh config/0.5b_config.ini
lighter-submit --name Benchmark-Gluten \
          --deploy-mode cluster \
          --class org.apache.spark.deploy.PythonRunner \
	  --conf spark.driver.memory=6g \
	  --conf spark.kubernetes.container.image=crazytempo/spark-py-gluten:v3.2.2-0.5.0-dev \
	  --conf spark.cleaner.referenceTracking.cleanCheckpoints=false \
	  --conf spark.plugins=io.glutenproject.GlutenPlugin \
	  --conf spark.gluten.sql.columnar.backend.lib=velox \
          --conf spark.memory.offHeap.enabled=true \
          --conf spark.memory.offHeap.size=20g \
          --conf spark.gluten.loadLibFromJar=true \
          --conf spark.shuffle.manager=org.apache.spark.shuffle.sort.ColumnarShuffleManager \
	  --conf spark.kubernetes.executor.node.selector.spark-role.cloudwalk.com/overwhelm=true \
	  --conf spark.executor.instances=1 \
	  --conf spark.executor.cores=20 \
	  --conf spark.executor.memory=40g \
          --conf spark.kubernetes.driver.volumes.hostPath.dataforge.options.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.driver.volumes.hostPath.dataforge.mount.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.executor.volumes.hostPath.dataforge.options.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.executor.volumes.hostPath.dataforge.mount.path=/cloudgpfs/dataforge/ml-studio \
	  --conf spark.kubernetes.driver.volumes.hostPath.var.options.path=/cloudgpfs/dataforge/spark/var \
	  --conf spark.kubernetes.driver.volumes.hostPath.var.mount.path=/var/data \
	  --conf spark.kubernetes.executor.volumes.hostPath.var.options.path=/cloudgpfs/dataforge/spark/var \
          --conf spark.kubernetes.executor.volumes.hostPath.var.mount.path=/var/data \
          --conf spark.kubernetes.file.upload.path=/spark/tmp/upload \
          --conf spark.kubernetes.driver.node.selector.spark-role.cloudwalk.com/executor=true \
          --conf spark.kubernetes.executor.node.selector.spark-role.cloudwalk.com/executor=true \
          --conf spark.eventLog.enabled=true \
          --conf spark.eventLog.dir=/spark/eventLog \
          --conf spark.history.fs.logDirectory=/spark/eventLog \
          /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/gluten/exec.py \
	  /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/gluten/$1

          #--conf spark.archives=/cloudgpfs/dataforge/ml-studio/yckj4506/venv/conda-numpy-env.tar.gz#environment \
          #--conf spark.pyspark.python=./environment/bin/python \
