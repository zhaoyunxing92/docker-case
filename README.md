# docker-case
这个项目主要是为了快速拉起基于docker的服务，在使用中如果有问题可以提交`issuse` 有没有涉及到的欢迎添加进来

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