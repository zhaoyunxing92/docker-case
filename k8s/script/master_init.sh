#!/bin/bash
# author:zhaoyunxing

# init master
if [ ! -d ".kube" ]; then
echo "======== master start kubeadm init ==========="
sudo yum install -y kubelet kubeadm kubectl ipvsadm
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo kubeadm init \
    --apiserver-advertise-address=192.168.56.200 \
    --image-repository registry.aliyuncs.com/google_containers \
    --pod-network-cidr=10.244.0.0/16

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

source /etc/profile
# 部署flannel网络
kubectl apply -f /vagrant/config/kube-flannel.yml
# # 文件授权
# sudo sh -c "echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile"
# sudo chmod 666 /etc/kubernetes/admin.conf
# 设置自动补全
# echo "source <(kubectl completion bash)" >> ~/.bashrc
sudo sh -c "echo -e 'source <(kubectl completion bash)' >> .bashrc" # 在您的 bash shell 中永久的添加自动补全
fi