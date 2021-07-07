#!/bin/bash
# author:zhaoyunxing
# init master
sudo kubeadm init \
    --apiserver-advertise-address=192.168.56.100 \
    --image-repository registry.aliyuncs.com/google_containers \
    --pod-network-cidr=10.244.0.0/16