#!/bin/bash
nohup kubectl -n clickhouse-operator port-forward chi-ck-server-test-01-0-0-0 9191:9000 > port_forward.log &
