#!/cloudgpfs/dataforge/ml-studio/yckj4506/venv/benchmark-venv/bin/python3
from clickhouse_driver import Client
from datetime import datetime
import configparser
import os
import pandas as pd
import sys
import time

# 读取配置文件
config_file = 'config.ini' if len(sys.argv) == 1 else sys.argv[1]
config = configparser.ConfigParser()
config.read(config_file)

host = config.get('input', 'host')
port = config.getint('input', 'port')
username = config.get('input', 'username')
password = config.get('input', 'password')

if password == "":
    client = Client(host=host, port=port, user=username)
else:
    client = Client(host=host, port=port, user=username, password=password)
# DESCRIBE TABLE file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.5B/part-00000-f5676374-9e11-4acd-86cf-94dc430e8b7e-c000.snappy.parquet', Parquet)
# SELECT * FROM file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet', Parquet) limit 1

# DESCRIBE TABLE file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/part-00000-124e2cc1-7c89-4137-9178-443139071717-c000.snappy.parquet', Parquet)
# SELECT * FROM file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet', Parquet) limit 1

###########################################################
### 一亿标注数据集测试,外部数据查询
###########################################################
# 查询height
# SELECT count(1) FROM file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet', Parquet) where height = 1170
# ┌─count()─┐
# │  244157 │
# └─────────┘
# 1 row in set. Elapsed: 0.822 sec. Processed 100.00 million rows, 500.00 MB (121.65 million rows/s., 608.23 MB/s.)

# 查询shape_type
# SELECT count(1) FROM file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet', Parquet) where arrayExists(x -> x = '17c112a7fa', objects.2.1);
# 1 row in set. Elapsed: 9.894 sec. Processed 100.00 million rows, 9.59 GB (10.11 million rows/s., 969.11 MB/s.)
# ┌─count()─┐
# │       1 │
# └─────────┘

# 查询classification
# SELECT count(1) FROM file('/cloudgpfs/dataforge/ml-studio/yckj4506/data/dataset/mock/annotation_0.1B/*.parquet', Parquet) where arrayExists(x -> x = 'd6bdcb3634', objects.1);
# 1 row in set. Elapsed: 1.316 sec. Processed 100.00 million rows, 9.59 GB (76.00 million rows/s., 7.29 GB/s.)
# ┌─count()─┐
# │       1 │
# └─────────┘

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
        result = client.execute(query)
        # 首先将每个元素转换为字符串，然后使用逗号 ',' 分隔它们
        formatted_rows = [", ".join(str(x) for x in row) for row in result]
        # 使用换行符 '\n' 分隔每行，并将它们连接为一个长字符串
        one_row = str(";;".join(formatted_rows))
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
