

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

#### 删除旧的

```shell
docker rmi registry.aliyuncs.com/google_containers/coredns:1.8.0
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
sudo sh -c "echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile"
source /etc/profile
```

### 安装网络插件flannle



#### kubeadm token 重新设置

```shell
kubeadm token create --print-join-command
```



## 可能遇到的问题

###  scheduler和controller-manager端口起不来

```shell
[root@k8s-master ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused
etcd-0               Healthy     {"health":"true"}
```

#### 解决

> 主要问题是`--port=0`导致，注释掉就可以

* `vim /etc/kubernetes/manifests/kube-scheduler.yaml` 注释端口

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --authentication-kubeconfig=/etc/kubernetes/scheduler.conf
    - --authorization-kubeconfig=/etc/kubernetes/scheduler.conf
    - --bind-address=127.0.0.1
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --leader-elect=true
#    - --port=0  # 注释端口
    image: registry.aliyuncs.com/google_containers/kube-scheduler:v1.21.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10259
        scheme: HTTPS
.....
```

* `vim /etc/kubernetes/manifests/kube-controller-manager.yaml` 同样注释端口

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-controller-manager
    tier: control-plane
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --allocate-node-cidrs=true
    - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --bind-address=127.0.0.1
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cluster-cidr=10.24.0.0/16
    - --cluster-name=kubernetes
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --controllers=*,bootstrapsigner,tokencleaner
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --leader-elect=true
#    - --port=0
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --root-ca-file=/etc/kubernetes/pki/ca.crt
    - --service-account-private-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --use-service-account-credentials=true
    image: registry.aliyuncs.com/google_containers/kube-controller-manager:v1.21.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10257
        scheme: HTTPS
.....
```

* 重新启动

```she
systemctl restart kubelet.service
```



### kubeadm join的时候提示没有关闭iptables

```shell
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
```

#### 解决

```shell
sudo sh -c " echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
```

