# docker-case
这个项目主要是为了快速拉起基于docker的服务，在使用中如果有问题可以提交[issuse](https://github.com/zhaoyunxing92/docker-case/issues) 有没有涉及到的欢迎添加进来，（本人的系统是deepin各位在使用中如果遇到系统问题也欢迎提交issuse）

## 代码地址

码云：https://gitee.com/zhaoyunxing92/docker-case

github：https://github.com/zhaoyunxing92/docker-case

## 重要提示

windows用户请自觉放弃！自觉放弃！放弃！，不要折腾了，当然你会vagrant还是可以看看的

## 进展

* [x] [elasticsearch](./elasticsearch/readme.md)

  - [x] [x-pack](./elasticsearch/readme/es-xpack.md) xpack安全认证
  - [x] [es-cluster](./elasticsearch/readme/es-cluster.md) es集群配置
  - [x] [es-kibana](./elasticsearch/readme/es-kibana.md)
  - [x] [es-head](./elasticsearch/readme/es-head.md)  es数据可视化工具
  - [x] [es-in-java](https://github.com/zhaoyunxing92/spring-boot-learn-box/tree/master/spring-boot-elasticsearch/elasticsearch-in-java) 在java中使用es
  - [x] [es-in-spring boot](https://github.com/zhaoyunxing92/spring-boot-learn-box/tree/master/spring-boot-elasticsearch/spring-boot-data-elasticsearch) spring boot跟elasticsearch整合
  - [x] [spring-data-elasticsearch实践](https://github.com/zhaoyunxing92/spring-boot-learn-box/blob/master/spring-boot-elasticsearch/spring-boot-data-elasticsearch/spring-data-es-practice.md)

* [x] [redis](./redis/readme.md)

* [x] [mysql](./mysql/readme.md)

* [x] [jenkins](./jenkins/readme.md) 自动发布代码

* [x] [nexus](./nexus/readme.md)  maven、node、docker等镜像私服

* [x] [rabbitmq](./rabbitmq/readme.md) RabbitMQ是采用Erlang语言编写的实现高级消息队列协议（AMQP）的消息中间件
  
  - [x] [rabbitmq入门到放弃之rabbitmq exchange](https://www.jianshu.com/p/bdccfeb3d71e) 基本概念梳理以及使用

* [x] [nacos](./nacos/readme.md) nacos是一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台

* [x] [rockermq](./rockermq/readme.md) rockermq是一个开源的分布式消息传递和流数据平台

* [x] [skywalking](./skywalking/readme.md) 它是一款优秀的国产 APM 工具，包括了分布式追踪、性能指标分析、应用和服务依赖分析等。

## vagrant 快速构建docker环境

看完这个三篇文章就可以获取一个安装好docker的虚拟机环境，如果你先麻烦可以直接到[centos-docker](https://app.vagrantup.com/zhaoyunxing/boxes/centos-docker)下载我制作好的box

* [vagrant入门之基本操作](https://www.jianshu.com/p/b3da273689ae)

* [vagrant入门之VagrantFile](https://www.jianshu.com/p/7db398ea9f2a)

* [vagrant入门之制作docker镜像](https://www.jianshu.com/p/224dc1e3abd6)

## docker-compose安装

> [官网安装](https://docs.docker.com/compose/install/)  各种系统安装很详细了,下面是按照官网搬书
>
> [github](https://github.com/docker/compose)  可以找新版本的安装

* 下载

  ```shell
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  ```

* 授权

  ```shell
  sudo chmod +x /usr/local/bin/docker-compose
  ```

* 检查

  ```shell
  $ docker-compose -v
  docker-compose version 1.24.0, build 0aa59064
  ```

## docker-compose简单命令汇总

> 跟docker 命令差不多，只不过是要使用`docker-compose.yml`控制
>
> [docker](https://docs.docker.com/engine/reference/run/) 更多的使用看官网不赘述了太多了

* 启动

  ```shell
  sunny@g50 es $ docker-compose start
  Starting elasticsearch ... done
  Starting kibana        ... don
  ```

* 停止

  ```shell
  sunny@g50 es $ docker-compose stop
  Stopping kibana        ... done
  Stopping elasticsearch ... done
  ```

* 拉起

  ```shell
  # -d 表示后台运行，更多参数含义去官网理解
  sunny@g50 es $ docker-compose up -d
  Creating network "es_esnet" with the default driver
  Creating elasticsearch ... done
  Creating kibana        ... done
  ```

* 移除

  ```shell
  sunny@g50 es $ docker-compose down
  Stopping kibana        ... done
  Stopping elasticsearch ... done
  Removing kibana        ... done
  Removing elasticsearch ... done
  Removing network es_esnet
  ```
## docker安装  

docker 要求系统的内核版本高于 3.10 ，通过` uname -r` 命令查看你当前的内核版本

* 移除残渣

  ```shell
  $ sudo apt-get remove docker docker-engine docker.io
  ```

* 下载

  > [windows](https://docs.docker.com/v17.09/docker-for-windows/install/) 严格安装流程是可以成功的

  ```shell
  yum -y install docker-io
  # 或者
  sudo wget -qO- http://get.docker.com | sh
  ```

* 启动

  ```shell
  service docker start
  # 开机自动启动
  systemctl enable docker.service
  ```

* 查看日志
  
  ```shell
  docker logs -f xxx # 容器名称
  ```
* 进入容器
  
  ```shell
  docker exec -it xxx /bin/bash # xxx 替换为容器名称
  ```
* 删除容器
  
   ```shell
  docker rm xxx # xxx 替换为容器名称
    # 如果容器在启动但是需要删除
  docker rm -f xxx
   ```

* 加速

  > docker 拉去images会十分缓慢可以修改 /etc/docker/daemon.json文件没有创建，可以换阿里的，下面使用的是网易的

  ```json
  {
    "registry-mirrors": ["http://hub-mirror.c.163.com"]
  }
  ```

  修改完成后重启

  ```shell
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```

* 用户授权

  ```shell
  sudo groupadd docker # 创建docker组 默认会创建
  sudo usermod -aG docker $USER  # 当前用户添加到docker组
  # 更新docker组
  newgrp docker
  sudo service docker restart
  # 普通用户执行还是提示权限不够，则修改/var/run/docker.sock权限 
  sudo chmod a+rw /var/run/docker.sock
  ```
