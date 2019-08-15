# kibana


## yml文件

``` yaml
# # es+kibana 配置
version: '3'
services:
  # elasticsearch
  elasticsearch:
    image: elasticsearch:6.5.4
    container_name: elasticsearch # docker启动后的名称
    privileged: true
    # restart: always  #出现异常自动重启
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      cluster.name: elasticsearch  # es 名称
  # kibana
  kibana:
    image: kibana:6.5.4
    container_name: kibana # docker名称
    environment:
      elasticsearch.url: http://127.0.0.1:9200
      server.name: kibana
    ports:
      - 5601:5601
    depends_on:
      - elasticsearch # 依赖es
````

## 命令

* elasticsearch
 > --restart=always 可以根据个人所需添加
```shell
 docker run -d --name elk -p 9200:9200 -p 9300:9300 --restart=always elasticsearch:6.5.4
```

* kibana

```shell
docker run -d --name kb -e ELASTICSEARCH_URL=http://172.17.0.2:9200 -p 5601:5601 kibana:6.5.4
```
> 起动好了给它一点时间因为:biking_woman:立刻去访问它会说`Kibana server is not ready yet`