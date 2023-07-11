from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, ArrayType, StructType
import configparser
import os
import random
import sys
import uuid

# 读取配置文件
benchmark_output = sys.argv[1]
config_file = 'config.ini' if len(sys.argv) == 2 else sys.argv[2]

config = configparser.ConfigParser()
config.read(config_file)

# 从配置文件获取输出格式和压缩选项
spark_app_name = config.get('input', 'spark_app_name')
num_records_per_partition = config.getint('input', 'num_records_per_partition')
num_partitions = config.getint('input', 'num_partitions')
file_format = config.get('output', 'format')
compression = config.get('output', 'compression')
output_path = config.get('output', 'output_file')
output_path = os.path.join(benchmark_output, output_path)
embedding_array_len = config.getint('output', 'embedding_array_len')

def generate_points():
    points = []
    for i in range(4):
        points.append({
            "x": round(46.87398 * random.uniform(0.8, 1.2), 5),
            "y": round(71.982574 * random.uniform(0.8, 1.2), 5)
        })
    return points

def generate_shape_type(wordpool, repeat_rate=0.1):
    if random.random() < repeat_rate:
        return random.choice(wordpool)
    else:
        new_word = str(uuid.uuid4()).replace('-', '')[:10]
        wordpool.append(new_word)
        return new_word

def generate_classification(wordpool, repeat_rate=1.0/10000):
    if random.random() < repeat_rate:
        return random.choice(wordpool)
    else:
        new_word = str(uuid.uuid4()).replace('-', '')[:10]
        wordpool.append(new_word)
        return new_word
    
def generate_record(_):
    wordpool = ['Quadrilateral', 'square', 'Rectangle', 'diamond', 'Pentagram']
    wordpool_class = ['人脸', '有效区域', '猫', '游乐场', '文本框']
    
    unique_id = uuid.uuid4().hex
    image_name = f"{unique_id}.jpg"
    image_path = f"/workspace/AI/datasets/raw_data/{unique_id}/{image_name}"
    relative_path = f"/{unique_id}/{image_name}"
    width = int(720 * random.uniform(0.8, 1.2))
    height = int(1028 * random.uniform(0.8, 1.2))
    bit_depth = int(24 * random.uniform(0.8, 1.2))
    size = int(160 * random.uniform(0.8, 1.2))
    format = random.choice(["JPG", "JPEG", "PNG", "cdr", "pcd", "dxf", "ufo", "eps", "ai", "raw", "WMF", "webp"])
    version = random.choice(["v1", "v2", "v3", "v4", "v5"])

    # num_objects = random.randint(1, 6)
    num_objects = random.randint(1, embedding_array_len)
    objects = [{"classification": generate_classification(wordpool_class),
                "shape": {
                    "shape_type": generate_shape_type(wordpool),
                    "points": generate_points()
                }
               } for x in range(num_objects)]

    record = (image_path, relative_path, image_name, width, height, bit_depth, size, format, version, objects)
    return record

# 创建SparkSession
spark = SparkSession.builder \
    .appName(spark_app_name) \
    .getOrCreate()

# 生成数据并创建RDD
data_rdd = spark.sparkContext.parallelize(range(num_partitions), num_partitions).flatMap(lambda _: [generate_record(None) for _ in range(num_records_per_partition)])

# 定义Schema
schema = StructType([
    StructField("image_path", StringType(), True),
    StructField("relative_path", StringType(), True),
    StructField("name", StringType(), True),
    StructField("width", IntegerType(), True),
    StructField("height", IntegerType(), True),
    StructField("bit_depth", IntegerType(), True),
    StructField("size", IntegerType(), True),
    StructField("format", StringType(), True),
    StructField("version", StringType(), True),
    StructField("objects", ArrayType(
        StructType([
            StructField("classification", StringType(), True),
            StructField("shape", StructType([
                StructField("shape_type", StringType(), True),
                StructField("points", ArrayType(StructType([
                    StructField("x", FloatType(), True),
                    StructField("y", FloatType(), True)
                ])), True)
            ]), True)
        ])
    ), True)
])

# 从RDD创建DataFrame
num_partitions_coalesced = round(num_records_per_partition * num_partitions / 50000000 * 65)
df = spark.createDataFrame(data_rdd, schema=schema).coalesce(num_partitions_coalesced)

print(output_path)
# 将数据写入指定目录
if file_format.lower() == "json":
    df.write \
        .option("compression", compression) \
        .json(output_path, mode='overwrite')
elif file_format.lower() == "parquet":
    df.write \
        .option("compression", compression) \
        .parquet(output_path, mode='overwrite')
else:
    raise ValueError(f"Unsupported file format '{file_format}'. Supported formats are 'json' and 'parquet'.")

# 停止SparkSession
spark.stop()
