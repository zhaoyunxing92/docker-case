# elasticsearch入门到放弃之docker搭建

[集群版本](./readme/es-cluster.md)

> 基于docker构建的代码地址:<https://github.com/zhaoyunxing92/docker-case/tree/develop/elasticsearch> 可以直接使用,我下面也是按照这个写的这个文档

## 单机版

### docker-compose.yml

```yaml
version: '3'
services:
  # elasticsearch
  elasticsearch:
    image: elasticsearch:6.5.4
    container_name: elasticsearch # docker启动后的名称
    privileged: true
    # restart: always  #出现异常自动重启
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      cluster.name: elasticsearch  # es 名称
```

> 可以指定config文件运行,在下面集群里面我会写出来

### docker运行

```shell
# --restart=always 可以根据个人所需添加
docker run -d --name elk -p 9200:9200 -p 9300:9300 --restart=always elasticsearch:6.5.4
```

### docker-compose运行

```shell
docker-compose -f docker-compose.yml up -d
```

到这里单机版就很简单的结束了,我一起搭建`skywalking`的时候也就单机版运行结束了

## 集群版

> 这个是花费我时间最长的,主要是我对docker的网络架构一知半解导致的

### es-cluster.yml配置

```yaml
# 集群配置 伪集群
version: '3'
services:
  es1:
    image: elasticsearch:6.5.4
    container_name: es1 # docker启动后的名称
    network_mode: host # 公用主机的网络
    environment:
       #cluster.name: "elasticsearch"  # es 名称config配置了这里就不用重复了
       ES_JAVA_OPTS: "-Xms512m -Xmx512m"  # 自定内存
    volumes:
      - /data/es/es1/data:/usr/share/elasticsearch/data
      - /data/es/es1/logs:/usr/share/elasticsearch/logs
      - ./config/es1/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  es2:
    image: elasticsearch:6.5.4
    container_name: es2 # docker启动后的名称
    network_mode: host
    environment:
       #cluster.name: "elasticsearch"  # es 名称config配置了这里就不用重复了
       ES_JAVA_OPTS: "-Xms512m -Xmx512m"  # 自定内存
    volumes:
      - /data/es/es2/data:/usr/share/elasticsearch/data
      - /data/es/es2/logs:/usr/share/elasticsearch/logs
      - ./config/es2/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  es3:
    image: elasticsearch:6.5.4
    container_name: es3 # docker启动后的名称
    network_mode: host
    environment:
       #cluster.name: "elasticsearch"  # es 名称config配置了这里就不用重复了
       ES_JAVA_OPTS: "-Xms512m -Xmx512m"  # 自定内存
    volumes:
      - /data/es/es3/data:/usr/share/elasticsearch/data
      - /data/es/es3/logs:/usr/share/elasticsearch/logs
      - ./config/es3/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
```

* `network_mode: host` 这个很重要表示这三组都使用宿主机的网络,感兴趣的可以了解下docker的网络模式
* `container_name: es3` docker启动后的名称
* `volumes`下面配置都是目录挂载,,值得注意的是你要关注下他们的权限,挂载的data目录`必须是空的`不然集群也会不成功
* `ES_JAVA_OPTS` 指定jvm运行内存

### master elasticsearch.yml配置

```
cluster.name: elastic  # 集群必须一样
node.name: node-data-1 # 节点名称必须不一样
node.master: true  # 表示主节点
node.data: true
http.port: 9201
transport.tcp.port: 9301
#network.bind_host: 0.0.0.0
network.host: 0.0.0.0
# 设置集群自动发现服务id集合
discovery.zen.ping.unicast.hosts: ["127.0.0.1:9301","127.0.0.1:9302","127.0.0.1:9303"]
discovery.zen.minimum_master_nodes: 1

# heald 插件使用
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
# 开启密码认证 xpack
xpack.security.enabled: true
```

* `cluster.name` 集群的名称必须一致
* `node.name` 节点名称必须不一样
* `node.master` 是否主节点
* `http.port` http端口  这两个端口也是坑的地方,后面在跟springboot整合的时候我再说
* `transport.tcp.port` tcp端口
* `discovery.zen.ping.unicast.hosts` 集群的ip数据同步是通过`tcp`端口进行的

###  slave elasticsearch.yml配置

> slave跟master的配置基本一致主要是`node.master: false`其他都一样,这里就不写了,你可以去看我[github](https://github.com/zhaoyunxing92/docker-case/tree/develop/elasticsearch)上的配置(elasticsearch/config/es/elasticsearch.yml)

### docker-compose启动

```shell
# -f 指定yml文件运行
docker-compose -f cluster/docker-compose.yml up -d
```
### 验证

```shell
# --user elastic:123456 是我设置的密码
➜  notes git:(master) ✗ curl --user elastic:123456 'http://127.0.0.1:9201/_cat/nodes'
172.26.104.209 43 81 5 0.17 0.59 0.53 di  - node-data-3
172.26.104.209 30 81 5 0.17 0.59 0.53 mdi * node-data-1
172.26.104.209 55 81 5 0.17 0.59 0.53 di  - node-data-2
```

到这里集群版的也算是完成了

## 可能遇到的问题

* 挂载容器内部目录到物理机上出现 `[0.001s][error][logging] Error opening log file 'logs/gc.log': Permission denied`

     这个是权限问题

     ```shell
     # 给目录775权限
     sudo chmod -R 775 /data/es/
     # 修改文件归属者
     sudo chown -R 1000:1000 /data/es/
     ```

* java.lang.RuntimeException: can not run elasticsearch as root

  > es禁止root用户直接运行,切换用户就可以了,不过用docker好像没有出现

* max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

     > jvm 内存不够需要修改系统jvm内存

     ```shell
      vim /etc/sysctl.conf
      # 追加配置
      vm.max_map_count=655300
     ```
     修改完后执行: `sudo sysctl -p`可以执行:`more /proc/sys/vm/max_map_count`验证下是否修改成功

* failed to read [id:1, file:/usr/share/elasticsearch/data/nodes/0/_state/node-1.st]

    挂载的宿主目录文件加不是空导致,清空即可

* java.lang.OutOfMemoryError: Java heap space (oom和gc等这里问题我电脑无法还原就弄这个oom说明问题吧)

    jvm内存设置的小了修改 `ES_JAVA_OPTS`参数即可

* docker启动了但是不能正常访问或者只能本地访问,另外在用网段的电脑不能访问

    这个主要是docker网络模式的问题`network_mode: host`设置上就可以了,你也可以通过`docker inspect 容器id` 查看docker帮我们绑定的ip
