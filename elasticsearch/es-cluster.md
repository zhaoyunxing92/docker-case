 ## elasticsearch 集群搭建

### yml
```yml
# 集群配置
version: '3'
services:
  es1:
    image: elasticsearch:6.5.4
    container_name: es1 # docker启动后的名称
    network_mode: host # 公用主机的网络
    volumes:
      - /data/es/es1/data:/usr/share/elasticsearch/data
      - /data/es/es1/logs:/usr/share/elasticsearch/logs
      - ./config/es1/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  es2:
    image: elasticsearch:6.5.4
    container_name: es2 # docker启动后的名称
    network_mode: host
    volumes:
      - /data/es/es2/data:/usr/share/elasticsearch/data
      - /data/es/es2/logs:/usr/share/elasticsearch/logs
      - ./config/es2/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  es3:
    image: elasticsearch:6.5.4
    container_name: es3 # docker启动后的名称
    network_mode: host
    volumes:
      - /data/es/es3/data:/usr/share/elasticsearch/data
      - /data/es/es3/logs:/usr/share/elasticsearch/logs
      - ./config/es3/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
```
> 注意`network_mode: host`配置必须,不然三个集群网络不通

### elasticsearch.yml配置

#### master elasticsearch.yml配置

```yml
cluster.name: elasticsearch  # 集群必须一样
node.name: node-data-1 # 节点名称必须不一样
node.master: true
node.data: true
http.port: 9201
transport.tcp.port: 9301
#network.bind_host: 0.0.0.0
network.host: 0.0.0.0
# network.publish_host: 172.26.104.209 # 网络模式设置的是host就可以不用设置这个ip了
# 设置集群自动发现服务id集合
discovery.zen.ping.unicast.hosts: ["127.0.0.1:9301","127.0.0.1:9302","127.0.0.1:9303"]
discovery.zen.minimum_master_nodes: 1
```

#### slave elasticsearch.yml配置

```yml
cluster.name: elasticsearch  # 集群必须一样
node.name: node-data-2 # 节点名称必须不一样
node.master: false
node.data: true
http.port: 9201
transport.tcp.port: 9301
#network.bind_host: 0.0.0.0
network.host: 0.0.0.0
# network.publish_host: 172.26.104.209 # 网络模式设置的是host就可以不用设置这个ip了
# 设置集群自动发现服务id集合
discovery.zen.ping.unicast.hosts: ["127.0.0.1:9301","127.0.0.1:9302","127.0.0.1:9303"]
discovery.zen.minimum_master_nodes: 1
```
> 主要区别是 `node.master: false`

### 运行
```shell
# -f 指定yml文件运行
docker-compose -f es-cluster.yml up -d
```

### 注意点
 
 * 如果是一台机器做集群那么需要设置`network_mode: host`这样docker就不会虚拟出ip了

 * 挂载的目录需要有权限`sudo chown R 1000:1000 /data/es/`
