#!/bin/bash
# ./...sh /data/nfs-data
storage_path=$1
subnet="10.178.2.0/24"

apt-get update
apt-get install -y nfs-kernel-server
mkdir -p ${storage_path}
chown nobody:nogroup ${storage_path}
chmod 777 ${storage_path}
echo "${storage_path}    ${subnet}(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
# 保存更改并重启NFS服务器以使其生效。
exportfs -a
systemctl restart nfs-kernel-server
