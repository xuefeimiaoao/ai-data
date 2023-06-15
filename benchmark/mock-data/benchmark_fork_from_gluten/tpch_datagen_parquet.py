from pyspark.sql import SparkSession

scale_factor = "100"
num_partitions = 200

output_format = "parquet"
root_dir = "/PATH/TO/TPCH_PARQUET_PATH"
dbgen_dir = "/PATH/TO/TPCH_DBGEN"

spark = SparkSession.builder \
            .appName("TPC-H Data Generation") \
            .config("spark.jars", "/path/to/TPCHTables.jar") \
            .getOrCreate()

 jvm = spark._jvm
 tables = jvm.com.databricks.spark.sql.perf.tpch.TPCHTables(
     spark._jwrapped,
     dbgen_dir,
     scale_factor,
     False, # useDoubleForDecimal
     False  # useStringForDate
 )

tables.genData(
    root_dir,
    output_format,
    True, # overwrite
    False, # partitionTables
    False, # clusterByPartitionColumns
    False, # filterOutNullPartitionValues
    "", # tableFilter
    num_partitions)
