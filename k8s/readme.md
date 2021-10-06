

# k8s前期准备工作

我这里主要使用[docker-case](https://github.com/zhaoyunxing92/docker-case/tree/develop/k8s)构建本地k8s(v1.21.2)集群的

## 软件准备

* [vagrant 2.2.16](https://www.vagrantup.com/downloads) 跨平台虚拟化工具
* [virtualbox](https://www.virtualbox.org/wiki/Downloads) 开源免费的虚拟机
* k8s version v1.21.2

##  vagrant环境说明

* 需要使用`root`用户进去开始安装，不然会遇到很多问题

|  节点  |          连接方式          | 密码    |
| :----: | :------------------------: | ------- |
| master | ssh root@127.0.0.1 -p 2200 | vagrant |
| node1  | ssh root@127.0.0.1 -p 2201 | vagrant |
| node2  | ssh root@127.0.0.1 -p 2202 | vagrant |

## 配置过程

### 先创建三个虚拟机

> 进入目录执行下面命令就可以了`docker-case/k8s`

```shell
vagrant up
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
kubeadm init \
 --apiserver-advertise-address=192.168.56.200 \
 --image-repository registry.aliyuncs.com/google_containers \
 --kubernetes-version v1.21.2 \
 --pod-network-cidr=10.244.0.0/16
```

### 初始化kube

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sh -c "echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile"
source /etc/profile
```

### 安装网络插件flannle

> 由于我们上面使用的ip(192.168.56.200)不在eth0网卡上需要修改网卡可以通过`ip add`查看网卡

##### 1. 先下载

> 可以直接用[kube-flannel.yml](./config/kube-flannel.yml)

```shell
curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > kube-flannel.yml
```

##### 2.开始编辑`vi kube-flannel.yml`

```yam
    181       containers:
    182       - name: kube-flannel
    183         image: quay.io/coreos/flannel:v0.14.0
    184         command:
    185         - /opt/bin/flanneld
    186         args:
    187         - --ip-masq
    188         - --kube-subnet-mgr
    189         - --iface=eth1 # 这个地方指定网卡
```

##### 3.apply flannel

```shell
[root@k8s-master ~]# kubectl apply -f kube-flannel.yml
Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
```

##### 4.验证结果

> 先获取pods然后查看一个pod的日志即可

```shell
[root@k8s-master ~]# kubectl get pods --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-59d64cd4d4-2d46n             1/1     Running   0          19m
kube-system   coredns-59d64cd4d4-jvbvs             1/1     Running   0          19m
kube-system   etcd-k8s-master                      1/1     Running   0          20m
kube-system   kube-apiserver-k8s-master            1/1     Running   0          20m
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          15m
kube-system   kube-flannel-ds-hvsmm                1/1     Running   0          95s
kube-system   kube-flannel-ds-lhdpp                1/1     Running   0          95s
kube-system   kube-flannel-ds-nbxl4                1/1     Running   0          95s
kube-system   kube-proxy-6gj8p                     1/1     Running   0          18m
kube-system   kube-proxy-jf8v6                     1/1     Running   0          18m
kube-system   kube-proxy-srx5t                     1/1     Running   0          19m
kube-system   kube-scheduler-k8s-master            1/1     Running   0          15m
```

> 由日志可以看到`Using interface with name eth1 and address 192.168.56.200`

```shell
[root@k8s-master ~]# kubectl logs -n kube-system kube-flannel-ds-nbxl4
I0709 08:28:28.858390       1 main.go:533] Using interface with name eth1 and address 192.168.56.200
I0709 08:28:28.859608       1 main.go:550] Defaulting external address to interface address (192.168.56.200)
W0709 08:28:29.040955       1 client_config.go:608] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
```

### 使用ipvs负载均衡

> [啥是ipvs](https://www.jianshu.com/p/7cff00e253f4) 可以看看

#### 修改配置
> 执行`kubectl edit  configmap -n kube-system  kube-proxy`

```yaml
     28     iptables:
     29       masqueradeAll: false
     30       masqueradeBit: null
     31       minSyncPeriod: 0s
     32       syncPeriod: 0s
     33     ipvs:
     34       excludeCIDRs: null
     35       minSyncPeriod: 0s
     36       scheduler: ""
     37       strictARP: false
     38       syncPeriod: 0s
     39       tcpFinTimeout: 0s
     40       tcpTimeout: 0s
     41       udpTimeout: 0s
     42     kind: KubeProxyConfiguration
     43     metricsBindAddress: ""
     44     mode: "ipvs" # 这里指定用ipvs
     45     nodePortAddresses: null
     46     oomScoreAdj: null
```

#### 杀死所有的 `kube-proxy` pod

```shell
[root@k8s-master ~]# kubectl get pod -n kube-system |grep kube-proxy
kube-proxy-6gj8p                     1/1     Running   0          149m
kube-proxy-jf8v6                     1/1     Running   0          150m
kube-proxy-srx5t                     1/1     Running   0          150m
[root@k8s-master ~]# kubectl delete  pod -n kube-system kube-proxy-6gj8p kube-proxy-jf8v6 kube-proxy-srx5t
pod "kube-proxy-6gj8p" deleted
pod "kube-proxy-jf8v6" deleted
pod "kube-proxy-srx5t" deleted
```

#### 验证结果

> Using ipvs Proxier.

```shell
[root@k8s-master ~]# kubectl get pod -n kube-system |grep kube-proxy
kube-proxy-4fvxf                     1/1     Running   0          2m41s
kube-proxy-j79lj                     1/1     Running   0          2m32s
kube-proxy-l4vjz                     1/1     Running   0          2m41s
[root@k8s-master ~]# kubectl logs -n kube-system kube-proxy-4fvxf
Error from server (NotFound): the server could not find the requested resource ( pods/log kube-proxy-4fvxf)
[root@k8s-master ~]# kubectl logs -n kube-system kube-proxy-j79lj
I0709 10:43:06.511908       1 node.go:172] Successfully retrieved node IP: 10.0.2.15
I0709 10:43:06.511989       1 server_others.go:140] Detected node IP 10.0.2.15
I0709 10:43:06.551606       1 server_others.go:206] kube-proxy running in dual-stack mode, IPv4-primary
I0709 10:43:06.551773       1 server_others.go:274] Using ipvs Proxier.
I0709 10:43:06.551794       1 server_others.go:276] creating dualStackProxier for ipvs.
W0709 10:43:06.551816       1 server_others.go:512] detect-local-mode set to ClusterCIDR, but no IPv6 cluster CIDR defined, , defaulting to no-op detect-local for IPv6
```

### kubeadm token 重新设置

> 这一步**不是必须**，如果上面join忘记了可以重新生成

```shell
kubeadm token create --print-join-command
```

### Kubectl 自动补全

```shell
source <(kubectl completion bash) # 在 bash 中设置当前 shell 的自动补全，要先安装 bash-completion 包。
echo "source <(kubectl completion bash)" >> ~/.bashrc # 在您的 bash shell 中永久的添加自动补全
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

* `vi /etc/kubernetes/manifests/kube-scheduler.yaml` 注释端口

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

* `vi /etc/kubernetes/manifests/kube-controller-manager.yaml` 同样注释端口

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

### kubeadm join的时候提示没有关闭bridge-nf-call-iptables 

```shell
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
```

#### 解决

```shell
sudo sh -c " echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
```

### node无法加入master节点

> 之前我使用的ip是`192.168.56.100`跟VirualBox的DHCP服务冲突了选择端口的时候需要注意下ip选择范围

![image-20210709163923103](/Users/docker/code/github/docker-case/images/image-20210709163923103.png)

