# elasticsearch

## 开启xpack安全认证

### 启动服务

```shell
docker-compose -f es-cluster.yml up -d
```

### 开启tral license

> 不想使用curl或者有`postman` 的可以导入[es.postman.json](./postman/es.postman.json)文件,并且设置下`url`变量就可以使用

```sell
curl -H "Content-Type:application/json" -XPOST  http://127.0.0.1:9200/_xpack/license/start_trial?acknowledge=true
```

控制台成功日志

```log
[2019-07-01T11:26:33,611][INFO ][o.e.l.LicenseService     ] [node-data-1] license [8c9e65ae-a727-4fa3-ab05-f690cf882a87] mode [trial] - valid
```

### 进入容器设置密码

```shell
# docker 进入容器
docker exec -it es1 /bin/bash

# 修改密码
[root@g50 elasticsearch]# bin/elasticsearch-setup-passwords interactive
```
> elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user 等密码一起修改的

### 修改elasticsearch.yml配置

> `xpack.security.enabled: true`可以先开启

```yml
xpack.security.enabled: true
```

### docker重启服务

```shell
docker-compose -f es-cluster.yml restart
```