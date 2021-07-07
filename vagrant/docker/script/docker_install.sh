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
    # mkdir
    sudo mkdir -p /etc/systemd/system/docker.service.d
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