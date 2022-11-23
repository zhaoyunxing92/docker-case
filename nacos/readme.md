# nacos

[nacos](https://nacos.io/zh-cn/shi)是一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台

## yml文件

``` yaml
version: '3.1'
services:
  nacos:
    image: nacos/nacos-server:latest
    container_name: nacos
    ports:
      - 8848:8848
    environment:
      - MODE=standalone #启动模式是独立模式
    volumes:
      - ./custom.properties:/home/nacos/init.d/custom.properties
````

## 命令

 > --restart=always 可以根据个人所需添加
```shell
 docker run --name nacos -e MODE=standalone -d -p 8848:8848 nacos/nacos-server:latest 
```
