from datetime import datetime
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, ArrayType, StructType, BooleanType
import configparser
import random
import sys
import time
import uuid

# 读取配置文件
config_file = 'config.ini' if len(sys.argv) == 1 else sys.argv[1]
config = configparser.ConfigParser()
config.read(config_file)

file_format = config.get('input', 'format')
input_path = config.get('input', 'input_path')
sql_file_path = config.get('input', 'sql_file_path')
view_name = config.get('input', 'view_name')
output_file = config.get('output', 'output_file_path')

current_time = datetime.now().strftime('%Y_%m_%d_%H')
output_file = output_file.format(current_time)

# 创建SparkSession
spark = SparkSession.builder \
    .appName("Benchmark SparkSQL-Gluten") \
    .getOrCreate()

test_df = spark.read.parquet(f"{input_path}/*.parquet")
# 创建临时表
test_df.createOrReplaceTempView(view_name)

# 读取文件并根据分号分割 SQL 查询
with open(sql_file_path, 'r') as file:
    file_content = file.read()
    test_sql_lines = file_content.replace('\n', ' ').split(';')

def execute_sql(query):
    start_time = time.perf_counter()
    if file_format.lower() == "parquet":
        one_row = spark.sql(query).collect()
    else:
        raise ValueError(f"Unsupported file format '{file_format}'. Supported format is 'parquet'...")

    execution_time = time.perf_counter() - start_time
    return one_row, execution_time

# 定义一个用于存储结果及统计信息的 schema
results_schema = StructType([
    StructField("sql", StringType(), True),
    StructField("success", BooleanType(), True),
    StructField("execution_time", FloatType(), True),
    StructField("error", StringType(), True)
])

# 创建一个空的 Spark DataFrame
results_df = spark.createDataFrame(spark.sparkContext.emptyRDD(), schema=results_schema)

for test_sql in test_sql_lines:
    test_sql = test_sql.strip()
    test_sql = test_sql.format(view_name)
    if not test_sql:
        continue

    try:
        result, exec_time = execute_sql(test_sql)
        new_row = spark.createDataFrame([(test_sql, True, exec_time, None)], schema=results_schema)
        results_df = results_df.union(new_row)
    except Exception as e:
        new_row = spark.createDataFrame([(test_sql, False, None, str(e))], schema=results_schema)
        results_df = results_df.union(new_row)

# 将结果保存为 csv 格式的文件
results_df.coalesce(1).write.mode("overwrite").csv(output_file)
