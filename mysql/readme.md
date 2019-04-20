# mysql

## yml文件

``` yaml
version: '3'
services:
  # mysql
  mysql:
    image: mysql:5.7
    container_name: mysql # docker启动后的名称
    ports:
      - 3306:3306
    environment:
      cluster.name: elasticsearch  # es 名称
````

## 命令

* elasticsearch
 > --restart=always 可以根据个人所需添加
```shell
 docker run -d --name elk -p 9200:9200 -p 9300:9300 --restart=always elasticsearch:6.5.4
```
