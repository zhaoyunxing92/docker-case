

# k8s前期准备工作

## 软件准备

* [vagrant 2.2.16](https://www.vagrantup.com/downloads) 跨平台虚拟化工具
* [virtualbox](https://www.virtualbox.org/wiki/Downloads) 开源免费的虚拟机
* k8s version v1.21.2

## 配置过程

### 设置cgroup

> docker 默认cgroup是`driver`,k8s推荐使用`systemd` 所以：sudo vi /etc/docker/daemon.json

```json
{
  "exec-opts":["native.cgroupdriver=systemd"],
  "registry-mirrors":["https://75lag9v5.mirror.aliyuncs.com"]
}
```

### 修改images为阿里云
> 查看需要的版本
```shell
kubeadm config images list
```
### master开始安装

> 使用阿里云镜像镜像加速，`coredns:v1.8.0`由于tag问题导致不能下载所以先下载`coredns:v1.8.0`

#### 查看需要安装软件列表

```shell
kubeadm config images list
```
>  这里主要看下`coredns`版本

```yaml
k8s.gcr.io/kube-apiserver:v1.21.2
k8s.gcr.io/kube-controller-manager:v1.21.2
k8s.gcr.io/kube-scheduler:v1.21.2
k8s.gcr.io/kube-proxy:v1.21.2
k8s.gcr.io/pause:3.4.1
k8s.gcr.io/etcd:3.4.13-0
k8s.gcr.io/coredns/coredns:v1.8.0
```

#### 下载coredns:1.8.0

```shell
docker pull registry.aliyuncs.com/google_containers/coredns:1.8.0
```

#### 替换tag

```shell
docker tag registry.aliyuncs.com/google_containers/coredns:1.8.0 registry.aliyuncs.com/google_containers/coredns:v1.8.0
```

#### kubeadm init

```shell
sudo kubeadm init \
    --apiserver-advertise-address=192.168.56.100 \
    --image-repository registry.aliyuncs.com/google_containers \
    --kubernetes-version v1.21.2 \
    --pod-network-cidr=10.24.0.0/16
```

### 初始化kube

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chmod 666 /etc/kubernetes/admin.conf
sudo sh -c "echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile"
source /etc/profile
```

#### kubeadm token 重新设置

```shell
kubeadm token create --print-join-command
```

## 可能遇到的问题

* 执行`vagrant up` 遇到一下异常

> 异常信息

```shel
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterfaceWrap, interface IHostNetworkInterface
VBoxManage: error: Context: "RTEXITCODE handleCreate(HandlerArg *)" at line 71 of file VBoxManageHostonly.cpp
```

> 解决方案 https://www.cnblogs.com/xkfeng/p/8639696.html

```shell
sudo spctl --master-disable
```

