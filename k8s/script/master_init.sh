#!/bin/bash
# author:zhaoyunxing

# init master
# sudo kubeadm init \
#     --apiserver-advertise-address=192.168.56.100 \
#     --image-repository registry.aliyuncs.com/google_containers \
#     --pod-network-cidr=10.244.0.0/16

# hosts设置
sudo sh -c "echo -e '
192.168.56.100 k8s-master
192.168.56.101 k8s-node1
192.168.56.102 k8s-node2' >> /etc/hosts"

# sudo sh -c "echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile"
# source /etc/profile
# # 文件授权
# sudo chmod 666 /etc/kubernetes/admin.conf