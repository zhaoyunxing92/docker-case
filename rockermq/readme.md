# [rockermq](https://github.com/apache/rocketmq/)

Apache RocketMQ™是一个开源的分布式消息传递和流数据平台

## 参考文档

* [https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console) 客户端可视化工具

* [https://github.com/foxiswho/docker-rocketmq](https://github.com/foxiswho/docker-rocketmq) 

## rockermq基本概念

* name server：可以看做是一个简化版的ZK,它主要用于管理 Broker 集群信息（提供心跳检查，检查是否有 Broker 下线） 和 Topic 路由信息（用于客户端查询）

* broker server: 存储消息，提供消息的存储、推送、查询，集群部署可保证高性能、高可用。Broker 一主可以对应多从，主从之间会同步数据，同步方式分同步和异步，保存数据到磁盘文件也分为同步刷盘和异步刷盘。Broker 维护了 Topic 订阅信息，方便客户端做负载。


## 工作流程

* 首先启动 NameServer，等待 Broker来连接，并提供各种查询服务。

* 接着启动 BrokerServer，每隔 30s 定时向所有的 NameServer 发送心跳包，信息包括自己的状态和存储的 Topic 信息。

* NameServer 收到 Broker 心跳包后，更新相关信息，且会每隔 10s 检查上次 Broker 发送心跳的时间，若超过 120s 就判定 Broker 下线，并移除此 Broker 所有信息。

* 启动 Producer，先随机和 NameServer 建立长连接，发送消息前先需要创建 Topic，可以通过控制台也可以选择发送时自动创建，从 NameServer 获取这个主题可以发往的所有 Broker 的地址，轮询队列并和 Broker 建立长连接，然后发送数据。

* Broker 收到数据进行存储，并构建消费队列和索引文件。

* Consumer 跟 Producer 类似，启动后先随机和 NameServer 建立长连接，获取订阅信息，然后根据这心信息从 Broker 获取消息进行消费。

## yml文件

``` yaml
version: '3'
services:
 # rocket mq name server
  rmqnamesrv:
    image: foxiswho/rocketmq:server
    container_name: rocket-server
    network_mode: host
    environment:
      JAVA_OPT_EXT: "-server -Xms64m -Xmx64m -Xmn64m"
    ports:
      - 9876:9876
    volumes:
      - /data/rocket/server/logs:/opt/logs
      - /data/rocket/server/store:/opt/rmqstore

  # rocket mq broker
  rmqbroker:
    image: foxiswho/rocketmq:broker
    container_name: rocket-broker
    network_mode: host
    ports:
      - 10909:10909
      - 10911:10911
    volumes:
      - /data/rocket/broker/logs:/opt/logs
      - /data/rocket/broker/store:/opt/rmqstore
      - ./broker.conf:/etc/rocketmq/broker.conf
    environment:
      - NAMESRV_ADDR=localhost:9876
      - JAVA_OPTS:=-Duser.home=/opt
      - JAVA_OPT_EXT=-server -Xms64m -Xmx64m -Xmn64m
    command: mqbroker -c /etc/rocketmq/broker.conf
    depends_on:
      - rmqnamesrv
  # rocket console
  rmqconsole:
    image: styletang/rocketmq-console-ng
    container_name: rocket-console
    network_mode: host
    ports:
      - 8180:8180
    environment:
      - JAVA_OPTS=-Drocketmq.config.namesrvAddr=localhost:9876 -Dserver.port=8180 -Drocketmq.config.isVIPChannel=false
      - JAVA_OPT_EXT=-Xms128m -Xmx128m -Xmn128m
    depends_on:
      - rmqnamesrv
````

## 注意事项

* [rocketmq-console](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console) 官方的配置docker启动参数为`-Drocketmq.namesrv.addr=127.0.0.1:9876`我配置不成功最后改为`-Drocketmq.config.namesrvAddr=localhost:9876` 才成功

* [rocketmq-console](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console) 端口默认是`8080`注意不要冲突了可以通过`-Dserver.port=8180`进行修改