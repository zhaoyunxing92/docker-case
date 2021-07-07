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

