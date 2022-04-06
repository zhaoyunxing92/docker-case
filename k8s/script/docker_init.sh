#!/bin/bash
# author:zhaoyunxing
# 执行安装docker步骤
if ! type docker >/dev/null 2>&1; then
    echo "========start install docker==========="
    # 安装更新驱动包
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    # 设置repo
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # 安装docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    # 启动docker
    sudo systemctl start docker
    # 当前用户添加到docker用户组，更新用户组
    sudo usermod -aG docker $USER &&  newgrp docker
    # 设置docker开机启动
    sudo systemctl enable docker
    # 设置国内镜像可以使用阿里云
    sudo sh -c "echo -e '{\n  \"registry-mirrors\":[\"https://75lag9v5.mirror.aliyuncs.com\"],\n  \"exec-opts\":[\"native.cgroupdriver=systemd\"]\n}' > /etc/docker/daemon.json"
    # 重新加载配置
    sudo systemctl daemon-reload
    # 重启docker
    sudo systemctl restart docker
    # hosts设置
    sudo sh -c "echo -e '
    192.168.56.200 master
    192.168.56.201 node1
    192.168.56.202 node2' >> /etc/hosts"
fi

# install k8s
if ! type kubeadm >/dev/null 2>&1; then
echo "======== start install kubeadm ==========="

sudo bash -c 'cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF' && \
sudo setenforce 0 && \
sudo yum install -y kubelet kubeadm kubectl && \
sudo systemctl enable kubelet && sudo systemctl start kubelet && \
# 永久关闭swap
sudo sed -i 's/.*swap.*/#&/' /etc/fstab

# 允许 iptables 检查桥接流量
sudo bash -c 'cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF' && \
sudo bash -c 'cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF' && \
sudo sysctl --system

# 关闭swap
sudo bash -c "echo -e '
vm.swappiness=0' >> /etc/sysctl.conf" && \
sudo sysctl -p && \
sudo swapoff -a && swapon -a
fi