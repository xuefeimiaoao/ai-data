# Benchmark for olap db  
## How to generate data
generate 0.05 billion of records of annotation data:   
``` shell
source env.sh  
cd ${BENCHMARK_HOME}/benchmark/mock-data/annotation  
./submit.sh config/0.05b_config_coalesce.ini
```

## How to run test

