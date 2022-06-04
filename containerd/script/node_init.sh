#!/bin/bash
# author:zhaoyunxing
# init node

if ! type kubelet >/dev/null 2>&1; then
sudo yum install -y kubelet kubeadm
sudo systemctl enable kubelet && sudo systemctl start kubelet
fi