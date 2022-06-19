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
fi

if ! type docker-compose >/dev/null 2>&1; then
  echo "======== start install docker-compose ==========="
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi