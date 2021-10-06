# Kubernetes-namespace

> [namespaces](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/namespaces/)主要用来隔离资源,不隔离网络。避免使用前缀 `kube-` 创建名字空间，因为它是为 Kubernetes 系统名字空间保留的

Kubernetes 会默认创建四个初始化命名空间

- `default`： 没有指明使用其它名字空间的对象所使用的默认名字空间
- `kube-system`： Kubernetes 系统创建对象所使用的名字空间
- `kube-public` ：这个名字空间是自动创建的，所有用户（包括未经过身份验证的用户）都可以读取它。 这个名字空间主要用于集群使用，以防某些资源在整个集群中应该是可见和可读的。 这个名字空间的公共方面只是一种约定，而不是要求。
- `kube-node-lease`： 此名字空间用于与各个节点相关的租期（Lease）对象； 此对象的设计使得集群规模很大时节点心跳检测性能得到提升

## 查看命名空间

> kubernetes会为每个命名空间设置一个不可变更的 [标签](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/labels/) `kubernetes.io/metadata.name`，可以通过`kubectl get namespaces --show-labels`查看

```shell
[vagrant@k8s-master]$ kubectl get namespaces --show-labels
NAME                   STATUS   AGE     LABELS
default                Active   7h31m   kubernetes.io/metadata.name=default
kube-node-lease        Active   7h31m   kubernetes.io/metadata.name=kube-node-lease
kube-public            Active   7h31m   kubernetes.io/metadata.name=kube-public
kube-system            Active   7h31m   kubernetes.io/metadata.name=kube-system
kubernetes-dashboard   Active   6h51m   kubernetes.io/metadata.name=kubernetes-dashboard
```

## 创建命名空间

> 以下通过yaml和命令别创建nginx

### yaml

```yaml
apiVersion: v1
kind: Namespace # 指定类型为namespace
metadata:
  name: nginx
```

### 命令

```shell
[vagrant@k8s-master]$ kubectl create ns nginx
namespace/nginx created
```

## 删除命名空间

```shell
[vagrant@k8s-master]$ kubectl delete ns nginx
namespace "nginx" deleted
```