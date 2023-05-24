#!/bin/bash
# reference: https://github.com/Altinity/clickhouse-operator/blob/master/docs/quick_start.md
helm repo add clickhouse-operator https://docs.altinity.com/clickhouse-operator/
helm install clickhouse-operator -n clickhouse-operator clickhouse-operator/altinity-clickhouse-operator 
kubectl apply -n test-clickhouse-operator -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/docs/chi-examples/01-simple-layout-01-1shard-1repl.yaml
