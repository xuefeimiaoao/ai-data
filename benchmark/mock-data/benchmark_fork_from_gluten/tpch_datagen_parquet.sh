batchsize=10240
SPARK_HOME=/opt/spark
spark_sql_perf_jar=/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/mock-data/benchmark_fork_from_gluten/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
cat tpch_datagen_parquet.scala | ${SPARK_HOME}/bin/spark-shell \
  --num-executors 20 \
  --name tpch_gen_parquet \
  --executor-memory 6g \
  --executor-cores 2 \
  --master k8s://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT} \
  --driver-memory 50g \
  --deploy-mode client \
  --conf spark.executor.memoryOverhead=1g \
  --conf spark.sql.parquet.columnarReaderBatchSize=${batchsize} \
  --conf spark.sql.inMemoryColumnarStorage.batchSize=${batchsize} \
  --conf spark.sql.execution.arrow.maxRecordsPerBatch=${batchsize} \
  --conf spark.sql.broadcastTimeout=4800 \
  --conf spark.driver.maxResultSize=4g \
  --conf spark.sql.sources.useV1SourceList=avro \
  --conf spark.sql.shuffle.partitions=224 \
  --conf spark.kubernetes.driver.node.selector.benchmark-role.cloudwalk.com=true \
  --conf spark.kubernetes.executor.node.selector.spark-role.cloudwalk.com/overwhelm=true \
  --conf spark.kubernetes.container.image=apache/spark-py:v3.3.2 \
  --conf spark.kubernetes.namespace=benchmark \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.kubernetes.authenticate.executor.serviceAccountName=spark \
  --conf spark.driver.host=spark-driver-headless-service.default.svc.cluster.local \
  --conf spark.driver.port=7077 \
  --conf spark.driver.extraClassPath=${spark_sql_perf_jar} \
  --conf spark.executor.extraClassPath=${spark_sql_perf_jar}
