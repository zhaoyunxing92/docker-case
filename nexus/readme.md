# nexus

## yml文件

``` yaml
version: '3'
services:
  # redis
  redis:
    image: sonatype/nexus3:latest
    container_name: nexus3
    privileged: true  # 授权
    ports:
      - 8081:8081
    volumes:
      - /data/nexus-data:/nexus-data  
````

## 命令

 > --restart=always 可以根据个人所需添加
```shell
 docker run --name nexus -d -p 8081:8081 sonatype/nexus3:latest
```

## 权限问题

使用docker-compose拉起nexus时,`/nexus-data`目录挂载出来的话存在权限问题

```shell
sudo chown -R 200 /data/nexus-data
```
