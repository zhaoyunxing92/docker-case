# rabbitmq

RabbitMQ是采用Erlang语言编写的实现高级消息队列协议（AMQP）的消息中间件

## 参考文档

* [rabbitmq.conf](https://www.rabbitmq.com/configure.html) 主要写了不同系统怎么找到`rabbitmq.conf`文件以及每个版本应该怎么编写配置文件
* [dockerhub](https://hub.docker.com/_/rabbitmq) rabbitmq的镜像，主要找出带管理界面的rabbitmq
* [rabbitmq.conf.example](https://github.com/zhaoyunxing92/rabbitmq-server/blob/master/docs/rabbitmq.conf.example) 官方的一个配置案例
* [advanced.config.example](https://github.com/rabbitmq/rabbitmq-server/blob/master/docs/advanced.config.example) 解决无法通过`rabbitmq.conf`设置的配置可以通过这个配置文件

## AMQP

AMQP(Advanced Message Queuing Protocol 高级消息队列协议)是一个进程间传递`异步消息`的`网络协议`

### AMQP模型

![AMQPM模型](https://gitee.com/zhaoyunxing92/resource/raw/master/amqp/amqp.png)

### 专业术语解释

* `Server`：简单来说就是消息队列服务器实体也可以说是`broker`
* `Exchange`：消息交换机，指定消息按照什么规则，路由到哪个队列
* `Queue`：消息队列载体，每个消息都会被投入到一个或多个队列
* `Binding`：绑定，它的作用是把exchange和queue按照路由规则绑定起来
* `Routing Key`：路由关键字，exchange根据这个关键字进行消息投递
* `Virtual host`：虚拟主机，一个broker里可以开设多个virtual host，作用不同用户的权限逻辑分离。一个vritual host里有多个exchange和queue，但同一个virtual host不能有相同的exchange和queue。
* `Product`：消息生产者
* `Consumer`：消息消费者
* `Channel`：消息通道，在客户端的每个链接里，可以建立多个channel，每个channel代表一个会话任务
* `Message`：生产者和消费者之间传递的数据，由properties和body组成，properties对消息进行修饰，比如消息的优先级、延迟等高级特性，body就是消息体内容

## 安装

我的电脑是deepin的(debian)所以对应的目录在`/etc/rabbitmq/`

### rabbitmq.conf

```shell
## {loopback_users, ["guest">>]},
# 禁止远程访问的用户
loopback_users = none
## 
loopback_users.guest = true
# default_vhost = /
default_user = guest  # 账户密码
default_pass = 123456
```
### docker-compose.yml

```yml
version: '3'
services:
  # rabbitmq
  rabbit:
    image: rabbitmq:management # 选择带web界面的版本
    container_name: rabbit
    privileged: true  # 授权
    ports:
      - 15672:15672
      - 5672:5672
    volumes:
      - ./config/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf # 把当前的rabbitmq.conf挂载到容器中
    hostname: master #指定主机名称很重要后面集群使用 
```

### 访问

浏览器访问`http://localhost:15672`输入账户密码：`guest/123456`

## 可能遇到的问题

* `User can only log in via localhost`
 
  按照官方的说法禁止使用guest/guest权限通过除localhost外的访问
  
  ```shell
   # 开启都可以远程登录，可以数组限制指定用户
   loopback_users = none
  ```
