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
    sudo yum -y update && sudo yum install -y docker-ce
    # 启动docker
    sudo systemctl start docker
    # 授权
    sudo chmod 666 /var/run/docker.sock
    # 当前用户添加到docker用户组，更新用户组
    sudo usermod -aG docker $USER && newgrp docker
    # 设置docker开机启动
    sudo systemctl enable docker
    # 设置国内镜像可以使用阿里云
    sudo sh -c "echo -e '{\n  \"registry-mirrors\":[\"https://75lag9v5.mirror.aliyuncs.com\"],\n  \"exec-opts\":[\"native.cgroupdriver=systemd\"],\n  \"log-opts\":{\"max-size\":\"50m\"}\n}' > /etc/docker/daemon.json"
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
EOF' && \
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

# 开启ipvs
# sudo bash -c "cat > /etc/sysconfig/modules/ipvs.modules <<EOF
# #!/bin/bash
# modprobe -- ip_vs
# modprobe -- ip_vs_rr
# modprobe -- ip_vs_wrr
# modprobe -- ip_vs_sh
# modprobe -- nf_conntrack_ipv4
# EOF"

# sudo chmod 755 /etc/sysconfig/modules/ipvs.modules && \
# bash /etc/sysconfig/modules/ipvs.modules && \
# lsmod |grep -e ip_vs -e nf_conntrack_ipv4
fi