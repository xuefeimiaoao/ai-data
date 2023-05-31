#!/bin/bash
# 以下没有删除docker的配置文件，如/etc/docker等
# 适用于ubuntu系统，但是思路相似
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
systemctl stop docker
systemctl disable docker
systemctl status docker
apt-get purge docker-ce docker-ce-cli containerd.io

# 没有docker命令了，怎么删除这些容器?
#   列出所有与containerd-shim相关的进程。containerd-shim是Docker容器的一个组成部分。
# ps -aux | grep containerd-shim|grep -v grep| awk '{print "kill -9 " $2}'|sh

cat /proc/mounts | grep /data/cloudwalk/docker | awk '{print  "umount " $2}'|sh
docker_root_dir=`docker info|grep 'Docker Root Dir'|awk -F ':' '{print $2}'`
rm -rf $docker_root_dir
