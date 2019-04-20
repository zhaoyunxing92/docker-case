# redis

## yml文件

``` yaml
version: '3'
services:
  # redis
  redis:
    image: redis:4.0.8
    container_name: redis # docker启动后的名称
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      cluster.name: elasticsearch  # es 名称
````

## 命令

* elasticsearch
 > --restart=always 可以根据个人所需添加
```shell
 docker run -d --name elk -p 9200:9200 -p 9300:9300 --restart=always elasticsearch:6.5.4
```
