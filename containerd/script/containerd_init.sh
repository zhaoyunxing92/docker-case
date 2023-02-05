#!/bin/bash
# author:zhaoyunxing
# 执行安装containerd步骤
if ! type containerd >/dev/null 2>&1; then
    echo "========start install containerd ==========="
    # 设置repo
    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # 安装containerd
    sudo yum -y update && sudo yum install -y containerd.io
    # 修改配置
    sudo mkdir -vp /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml

    sudo sed -i "s#k8s.gcr.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
    sudo sed -i "s#registry.k8s.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
    sudo sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
    sudo sed -i '/registry.mirrors/a\ \ \ \ \ \ \ \ \[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]'  /etc/containerd/config.toml
    sudo sed -i '/registry.mirrors."docker.io"/a\ \ \ \ \ \ \ \ \  \endpoint=["https://75lag9v5.mirror.aliyuncs.com"]'  /etc/containerd/config.toml

    # 重新加载配置
    sudo systemctl daemon-reload
    sudo systemctl enable containerd
    # 重启containerd
    sudo systemctl restart containerd
    # 授权
    sudo chmod 666 /run/containerd/containerd.sock

    # hosts设置
    sudo sh -c "echo -e '
192.168.56.100 master
192.168.56.101 node1
192.168.56.102 node2' >> /etc/hosts"
fi

# install k8s
if ! type kubelet >/dev/null 2>&1; then
echo "======== start install k8s ====== ====="

# 设置阿里云源
sudo bash -c 'cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF'

# 允许 iptables 检查桥接流量
sudo bash -c 'cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF' 
sudo modprobe overlay && \
sudo modprobe br_netfilter && \
sudo bash -c 'cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0

vm.swappiness=0
vm.overcommit_memory=1 # 不检查物理内存是否够用
vm.panic_on_oom=0  # 开启oom
EOF' && \
sudo sysctl --system

# 永久关闭swap
sudo sed -i 's/.*swap.*/#&/' /etc/fstab
# 关闭swap
sudo setenforce 0
sudo bash -c "echo -e 'vm.swappiness=0' >> /etc/sysctl.conf" && \
sudo swapoff -a && sed -i 's/^SELINUX=.*/selinux=disabled' /etc/selunux/config
sudo sysctl -p

# 时区
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-local-rtc 0

sudo systemctl restart rsyslog
sudo systemctl restart crond

# 设置crictl配置
sudo bash -c 'cat << EOF > /etc/crictl.yaml
runtime-endpoint: /run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
pull-image-on-create: false
disable-pull-on-run: false
EOF'

fi