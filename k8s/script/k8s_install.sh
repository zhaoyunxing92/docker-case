#!/bin/bash
# author:zhaoyunxing
# hosts设置
sudo sh -c "echo -e '
192.168.56.100 k8s-master
192.168.56.101 k8s-node1
192.168.56.102 k8s-node2' >> /etc/hosts"