#!/cloudgpfs/dataforge/ml-studio/yckj4506/venv/benchmark-venv/bin/python3
from datetime import datetime
import configparser
import duckdb
import os
import pandas as pd
import sys
import time

################################################
### 测试一亿标注数据集,直接读取外部文件
###打开profileing: PRAGMA enable_profiling;
################################################

# SELECT * FROM read_parquet('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet') where height = 1170 
# ┌─────────────────────────────────────┐
# │┌───────────────────────────────────┐│
# ││         Total Time: 8.46s         ││
# │└───────────────────────────────────┘│
# └─────────────────────────────────────┘

# SELECT count(1) FROM read_parquet('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet') where height = 1170 ;
# ┌─────────────────────────────────────┐
# │┌───────────────────────────────────┐│
# ││         Total Time: 0.170s        ││
# │└───────────────────────────────────┘│
# └─────────────────────────────────────┘

# 查询shape_type
# SELECT COUNT(*)
# FROM
#   (SELECT unnest(objects) as obj
#    FROM read_parquet('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet')) subquery
# WHERE obj.shape.shape_type = '17c112a7fa';
# ┌─────────────────────────────────────┐
# │┌───────────────────────────────────┐│
# ││         Total Time: 30.70s        ││
# │└───────────────────────────────────┘│
# └─────────────────────────────────────┘

# 查询classification
# SELECT *
# FROM
#     (SELECT unnest(objects) as obj
#      FROM read_parquet('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet')) subquery
# WHERE obj.classification = 'd6bdcb3634';
# ┌─────────────────────────────────────┐
# │┌───────────────────────────────────┐│
# ││         Total Time: 28.45s        ││
# │└───────────────────────────────────┘│
# └─────────────────────────────────────┘


# 读取配置文件
config_file = 'config.ini' if len(sys.argv) == 1 else sys.argv[1]
config = configparser.ConfigParser()
config.read(config_file)

file_format = config.get('input', 'format')
input_path = config.get('input', 'input_path')
sql_file_path = config.get('input', 'sql_file_path')
output_file = config.get('output', 'output_file_path')

current_time = datetime.now().strftime('%Y_%m_%d_%H')
output_file = output_file.format(current_time)

dir_path = os.path.dirname(output_file)
# 如果目录不存在，则创建目录
if not os.path.exists(dir_path):
    os.makedirs(dir_path)

# 读取文件并根据分号分割 SQL 查询
with open(sql_file_path, 'r') as file:
    file_content = file.read()
    test_sql_lines = file_content.replace('\n', ' ').split(';')

def execute_sql(query):
    print(f"[DEBUG] Start to test sql: {query}")
    start_time = time.perf_counter()
    if file_format.lower() == "parquet":
        one_row = duckdb.sql(query).fetchall()
    else:
        raise ValueError(f"Unsupported file format '{file_format}'. Supported format is 'parquet'...")

    execution_time = time.perf_counter() - start_time
    print(f"[DEBUG] execution_time of sql [{query}] is {execution_time}")
    return one_row, execution_time

# 创建一个用于存储结果及统计信息的 DataFrame
results_df = pd.DataFrame(columns=['sql', 'success', 'execution_time', 'error'])

input_sub_path = input_path.rstrip('/') + "/*." + file_format
print(f"[DEBUG] Files to read: [{input_sub_path}]")

for test_sql in test_sql_lines:
    test_sql = test_sql.strip()
    test_sql = test_sql.format(input_sub_path)
    if not test_sql:
        continue

    try:
        result, exec_time = execute_sql(test_sql)
        results_df = results_df.append({
            'sql': test_sql,
            'success': True,
            'execution_time': exec_time,
            'error': None
        }, ignore_index=True)
    except Exception as e:
        results_df = results_df.append({
            'sql': test_sql,
            'success': False,
            'execution_time': None,
            'error': str(e)
        }, ignore_index=True)


print(f"[DEBUG] Start to write results to {output_file}")
# 将结果写入 Parquet 格式的文件
#results_df.to_parquet(output_file)
results_df.to_csv(output_file, index=False)
