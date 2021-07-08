#!/bin/bash
# author:zhaoyunxing
# 设置cgroup
sudo sh -c "echo -e '{\n \"exec-opts\":[\"native.cgroupdriver=systemd\"],\n \"registry-mirrors\":[\"https://75lag9v5.mirror.aliyuncs.com\"]\n}' > /etc/docker/daemon.json"
# 加载配置
sudo systemctl daemon-reload
# 重启docker
sudo systemctl restart docker

# 时间同步
sudo systemctl start chronyd
sudo systemctl enable chronyd

# 关闭iptables、firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo systemctl stop iptables
sudo systemctl disable iptables

# 禁止selinux
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

# 禁止swap分区
sudo swapoff -a
sudo sed -i '/swap/s/^/#/g' /etc/fstab

# 设置源
sudo sh -c "echo -e '[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg' > /etc/yum.repos.d/kubernetes.repo"


sudo sh -c " echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"

# 安装ipvs
sudo yum install ipset ipvsadm -y
# 安装k8s kubeadm会安装 kubelet、kubectl
sudo yum install -y kubeadm kubectl kubelet
# 开机启动
sudo systemctl enable kubelet