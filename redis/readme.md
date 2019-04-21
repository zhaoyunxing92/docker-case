# redis
> redis.conf路径注意下
## yml文件

``` yaml
version: '3'
services:
  # redis
  redis:
    image: redis:5.0.4
    container_name: redis
    privileged: true  # 授权
    ports:
      - 6379:6379
    volumes:
      - /data/redis/data:/data
      - ./redis.conf:/etc/redis/redis.conf # 把当前的redis.conf挂载到容器中
    command: redis-server /etc/redis/redis.conf
````

## 命令

* redis
 > --restart=always 可以根据个人所需添加
```shell
 docker run -d --name redis -p 6379:6379 --privileged=true -v /data/redis/data:/data -v redis.conf:/etc/redis/redis.conf redis:5.0.4 redis-server /etc/redis/redis.conf
```
