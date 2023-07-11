# Path of this script
export BENCHMARK_HOME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

# Possible fileSystem type: 
#   local: such as nfs
#   hdfs: not support for now
export FILE_SYSTEM_TYPE=local

# Path of spark-submit.sh
#   lighter-submit is an encapsulation of spark-submit, and acts as spark-submit
export SPARK_SUBMIT=lighter-submit

export BENCHMARK_OUTPUT="${BENCHMARK_HOME}/runtime/data"

# Spark Configuration
# node.selector of kubernetes
export BENCHMARK_LABEL="spark-role.cloudwalk.com/executor=true"
export SPARK_EVENTLOG_DIR="${BENCHMARK_HOME}/runtime/spark/eventLog"
export SPARK_IMAGE="artifact.cloudwalk.work/rd_docker_release/apache/spark-py:v3.3.2"
export SPARK_K8S_UPLOAD_PATH="${BENCHMARK_HOME}/runtime/spark/upload"

mkdir_if_exists() {
  local dir_to_create=$1	
  if [ -f ${dir_to_create} ]; then
	  echo "[INFO] ${dir_to_create} already exists."	  
  else
	  mkdir -p ${dir_to_create}
	  echo "[INFO] Create directory: ${dir_to_create}."
	  chmod 777 -R ${dir_to_create}
  fi	  	  
}	

init_benchmark() {
  mkdir_if_exists $BENCHMARK_OUTPUT
  mkdir_if_exists $SPARK_EVENTLOG_DIR 

  # this is unnecessary
  # mkdir_if_exists $SPARK_K8S_UPLOAD_PATH
}	
