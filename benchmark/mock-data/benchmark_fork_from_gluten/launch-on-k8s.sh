#!/bin/bash
kubectl -n benchmark get job|grep gen-tpch-parquet|awk '{print "kubectl -n benchmark delete job " $1}'|sh
kubectl -n benchmark get po|grep gen-tpch-parquet|awk '{print "kubectl -n benchmark delete po " $1}'|sh
kubectl -n benchmark get po|grep tpch-gen-parquet|awk '{print "kubectl -n benchmark delete po " $1}'|sh
kubectl -n benchmark delete svc spark-driver-headless-service
kubectl -n benchmark apply -f service.yaml
kubectl -n benchmark create -f tpch_datagen_parquet.yaml

