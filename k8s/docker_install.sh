#!/bin/bash
# author:zhaoyunxing
# 安装并启动docker
if ! type docker > /dev/null 2>&1; then
    echo '++++++ install docker start ++++++'
    # 安装工具
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    # 设置源
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # 安装docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    # 启动docker
    sudo systemctl start docker
    # 开机启动
    sudo systemctl enable docker
    # 设置数据源
    sudo sh -c "echo -e '{\n  \"registry-mirrors\":[\"https://75lag9v5.mirror.aliyuncs.com\"]\n}' > /etc/docker/daemon.json"
    # 加载配置
    sudo systemctl daemon-reload
    # 重启docker
    sudo systemctl restart docker
    # 添加用户组
    sudo usermod -aG docker $USER && newgrp docker
fi

# 时间同步
sudo systemctl start chronyd
sudo systemctl enable chronyd

# hosts设置
sudo sh -c "echo -e '
192.168.56.100 k8s-master
192.168.56.101 k8s-node1
192.168.56.102 k8s-node2' > /etc/hosts"

# 关闭iptables、firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo systemctl stop iptables
sudo systemctl disable iptables

# 禁止selinux
sudo sh -c "echo -e '
SELINUX=disabled
SELINUXTYPE=targeted' > /etc/selinux/config"

# 禁止swap分区
sudo swapoff -a
sudo sed -i '/swap/s/^/#/g' /etc/fstab