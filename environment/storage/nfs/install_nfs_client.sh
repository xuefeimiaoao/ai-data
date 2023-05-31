#!/bin/bash
# usage: ./....sh 10.178.2.28 /nfs-share /nfs-data
server_ip=$1
mount_path=$2
storage_path=$3

apt-get update
apt-get install -y nfs-common
mkdir -p ${mount_path}
echo "mount -t nfs ${server_ip}:${storage_path} ${mount_path}"
mount -t nfs ${server_ip}:${storage_path} ${mount_path}
