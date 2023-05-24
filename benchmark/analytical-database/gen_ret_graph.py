#!/cloudgpfs/dataforge/ml-studio/yckj4506/venv/benchmark-venv/bin/python3
import os
import pandas as pd
import matplotlib.pyplot as plt
import glob
import numpy as np

# 读取生成的 output.parquet 文件到 DataFrame
#output_file = "/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/clickhouse-test-result-*B.csv"
# 获取要读取的所有CSV文件的列表
#csv_files = glob.glob("/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/*.csv")
#csv_files = glob.glob("/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/*/*.csv") + glob.glob("/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/*.csv")

# 从所有CSV文件中读取数据并将它们附加到一个DataFrame
#results_df = pd.concat([pd.read_csv(file) for file in csv_files])



def get_default_column_names():
    return [
        'sql','success','execution_time','error'
    ]

# 读取有列名的 CSV 文件
csv_files_with_colnames = glob.glob("/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/*.csv")

# 读取没有列名的 CSV 文件
csv_files_without_colnames = glob.glob("/cloudgpfs/dataforge/ml-studio/yckj4506/git/bigdata-dev-tools/benchmark/analytical-database/result/sparkSQL/*/*/*.csv")

# 获取默认列名
colnames = get_default_column_names()

# 从没有列名的 CSV 文件中读取数据并将它们附加到一个 DataFrame
data_without_colnames = [
    pd.read_csv(file, header=None, names=colnames).assign(file_path=file) for file in csv_files_without_colnames
]
df_without_colnames = pd.concat(data_without_colnames)

# 从有列名的 CSV 文件中读取数据
data_with_colnames = [
    pd.read_csv(file).assign(file_path=file) for file in csv_files_with_colnames
]
df_with_colnames = pd.concat(data_with_colnames)

# 构造最终的结果 DataFrame
results_df = pd.concat([df_with_colnames, df_without_colnames])


def get_scale(row):
    scales = ['0.05B', '0.06B', '0.07B', '0.08B', '0.09B', '0.1B', '0.2B', '0.3B', '0.4B', '0.5B']
    for scale in scales:
        if scale in row['sql'] or scale in row['file_path']:
            return scale
    return ''

def get_sql_type(sql: str):
    if 'height' in sql:
        return 'column_query'
    elif '17c112a7fa' in sql:
        return 'embedding_shape_type_query'
    elif 'd6bdcb3634' in sql:
        return 'embedding_classification_query'
    return ''

def get_engine_type(sql: str):
    if 'read_parquet' in sql:
        return 'duckdb'
    elif 'test_view' in sql:
        return 'sparkSQL'
    elif 'file(' in sql:
        return 'clickhouse'
    return ''

# 根据 DataFrame 中的 SQL 和 file_path 内容，添加新的 'scale', 'sql_type', 和 'engine_type' 列
results_df['scale'] = results_df.apply(get_scale, axis=1)
results_df['sql_type'] = results_df['sql'].apply(get_sql_type)
results_df['engine_type'] = results_df['sql'].apply(get_engine_type)




unique_sql_types = results_df['sql_type'].unique()

for sql_type in unique_sql_types:
    # 根据要求过滤 data
    filtered_data = results_df[(results_df['sql_type'] == sql_type)]
    # 按照 scale 列从小到大排序
    filtered_data = filtered_data.sort_values(by='scale')

    successful_results = filtered_data[(filtered_data['success'])]

    # 生成柱状图的数据，按 scale 和 engine_type 分组，计算 execution_time 的平均值
    bar_data = successful_results.groupby(['scale', 'engine_type'])['execution_time'].mean().unstack()

    # 设置图表大小
    plt.figure(figsize=(15, 5))

    # 计算柱子的位置和宽度
    n_engine_types = len(bar_data.columns)
    total_bar_width = 0.8
    bar_width = total_bar_width / n_engine_types
    x_positions = np.arange(len(bar_data.index))

    # 绘制分组柱状图和其上方的数字
    for i, (engine_type, values) in enumerate(bar_data.items()):
        plt.bar(x_positions + i * bar_width, values, width=bar_width, label=engine_type)
        for idx, value in enumerate(values):
            if np.isfinite(value):  # 检查 value 是否为有限值
                plt.text(x_positions[idx] + i * bar_width, value, f'{value:.2f}', ha='center', va='bottom', fontsize=8)

    # 设置x轴刻度位置和标签
    plt.xticks(x_positions + total_bar_width / 2, bar_data.index)

    plt.xlabel('Data Scale')
    plt.ylabel('Execution Time (seconds)')
    plt.title(f'Performance of {sql_type}')
    plt.legend()

    # 保存图像为文件
    plt.savefig(f'benchmark_results_{sql_type}.png', bbox_inches='tight')

    # 显示图像
    plt.show()
