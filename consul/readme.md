# consul

[consul](https://www.consul.io/docs/intro)跟nacos一样一种服务网格解决方案，提供具有服务发现，配置和分段功能的全功能控制平面

---
一下使用`1.9.5`版本作为单个服务

## yml文件

``` yaml
version: '3.1'
services:
  nacos:
    image: consul:1.9.5
    container_name: consul
    ports:
      - 8500:8500
    command: agent -server -bootstrap -ui -client 0.0.0.0
````

## 命令

### docker
> --restart=always 可以根据个人所需添加

```shell
 docker run -d --name=consul -p 8500:8500 consul:1.9.5 agent -server -bootstrap -ui -client 0.0.0.0
```
### compose

```shell
docker compose -f single.yml up -d
```