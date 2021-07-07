# k8s前期准备工作

## 软件准备

* [vagrant 2.2.16](https://www.vagrantup.com/downloads) 跨平台虚拟化工具
* [virtualbox](https://www.virtualbox.org/wiki/Downloads) 开源免费的虚拟机

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
> 下面的镜像应该去除"k8s.gcr.io/"的前缀，版本换成上面获取到的版本
```shell
images=(
    k8s.gcr.io/kube-apiserver:v1.21.2
    k8s.gcr.io/kube-controller-manager:v1.21.2
    k8s.gcr.io/kube-scheduler:v1.21.2
    k8s.gcr.io/kube-proxy:v1.21.2
    k8s.gcr.io/pause:3.4.1
    k8s.gcr.io/etcd:3.4.13-0
    k8s.gcr.io/coredns/coredns:v1.8.0
)

for imageName in ${images[@]} ; do
    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
```

### master开始安装

```shell
kubeadm init \
    --apiserver-advertise-address=192.168.56.100 \
    --image-repository registry.aliyuncs.com/google_containers \
    --kubernetes-version v1.21.1 \
    --pod-network-cidr=10.244.0.0/16
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

