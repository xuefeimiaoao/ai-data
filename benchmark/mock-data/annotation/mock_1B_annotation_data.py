from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, ArrayType, StructType
import random
import uuid

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
    image_path = f"/workspace/AI2/datasets/raw_data/{unique_id}/{image_name}"
    relative_path = f"/{unique_id}/{image_name}"
    width = int(720 * random.uniform(0.8, 1.2))
    height = int(1028 * random.uniform(0.8, 1.2))
    bit_depth = int(24 * random.uniform(0.8, 1.2))
    size = int(160 * random.uniform(0.8, 1.2))
    format = random.choice(["JPG", "JPEG", "PNG", "cdr", "pcd", "dxf", "ufo", "eps", "ai", "raw", "WMF", "webp"])
    version = random.choice(["v1", "v2", "v3", "v4", "v5"])

    # num_objects = random.randint(1, 6)
    num_objects = 1
    objects = [{"classification": generate_classification(wordpool_class),
                "shape": {
                    "shape_type": generate_shape_type(wordpool),
                    "points": generate_points()
                }
               } for x in range(num_objects)]

    record = (image_path, relative_path, image_name, width, height, bit_depth, size, format, version, objects)
    return record
# 貌似executor中的数据不清理，以下这个参数很快就会oom
num_records_per_partition = 125000
num_partitions = 8000

# 创建SparkSession
spark = SparkSession.builder \
    .appName("Mock Data Generator--1B annotation data") \
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
df = spark.createDataFrame(data_rdd, schema=schema)

# 将数据写入指定目录
df.write \
  .option("compression", "gzip") \
  .json("/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_1B/", mode='overwrite')

# 停止SparkSession
spark.stop()
