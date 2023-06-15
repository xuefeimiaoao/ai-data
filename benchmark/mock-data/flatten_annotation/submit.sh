#!/bin/bash
# lighter-submit is an encapsulation of spark-submit, and acts as spark-submit
# usage: ./submit.sh config/0.5b_config.ini
lighter-submit --name Mock-Data-Generator \
          --deploy-mode cluster \
          --class org.apache.spark.deploy.PythonRunner \
	  --conf spark.driver.memory=6g \
	  --conf spark.kubernetes.container.image=artifact.cloudwalk.work/rd_docker_release/apache/spark-py:v3.3.2 \
	  --conf spark.executor.instances=70 \
	  --conf spark.executor.cores=2 \
	  --conf spark.executor.memory=4g \
          --conf spark.kubernetes.driver.volumes.hostPath.dataforge.options.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.driver.volumes.hostPath.dataforge.mount.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.executor.volumes.hostPath.dataforge.options.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.executor.volumes.hostPath.dataforge.mount.path=/cloudgpfs/dataforge/ml-studio \
          --conf spark.kubernetes.file.upload.path=/spark/tmp/upload \
          --conf spark.kubernetes.driver.node.selector.spark-role.cloudwalk.com/executor=true \
          --conf spark.kubernetes.executor.node.selector.spark-role.cloudwalk.com/executor=true \
          --conf spark.eventLog.enabled=true \
          --conf spark.eventLog.dir=/spark/eventLog \
          --conf spark.history.fs.logDirectory=/spark/eventLog \
	  --conf spark.task.maxFailures=20 \
          /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/mock-data/annotation/mock_annotation_data.py \
	  /cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/mock-data/annotation/$1

          #--conf spark.archives=/cloudgpfs/dataforge/ml-studio/yckj4506/venv/conda-numpy-env.tar.gz#environment \
          #--conf spark.pyspark.python=./environment/bin/python \
	  #--conf spark.kubernetes.executor.node.selector.spark-role.cloudwalk.com/overwhelm=true \
