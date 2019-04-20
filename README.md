# docker-case
这个项目主要是为了快速拉起基于docker的服务，在使用中如果有问题可以提交[issuse](https://github.com/zhaoyunxing92/docker-case/issues) 有没有涉及到的欢迎添加进来，（本人的系统是deepin各位在使用中如果遇到系统问题也欢迎提交issuse）

## 进展

* [x] [es+kibana](./elasticsearch/readme.md) 由于es依赖kibana就在一起弄了
* [x] [redis](./redis/readme.md)
* [x] [mysql](./mysql/readme.md)
* [x] [jenkins](./jenkins/readme.md)
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
  sudo service docker restart
  # 普通用户执行还是提示权限不够，则修改/var/run/docker.sock权限 
  sudo chmod a+rw /var/run/docker.sock
  ```

