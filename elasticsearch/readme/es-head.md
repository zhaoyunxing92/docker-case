# elasticsearch-head

[elasticsearch-head](https://github.com/mobz/elasticsearch-head)可理解为[DBeaver](https://dbeaver.io/)一个数据可视化工具，但是这个工具并没有理想中那么好用坑也是很多

### docker-compose.yml配置

> 如果你elasticsearch没有开启x-pack并且不需使用es-head创建索引，并且你比较懒，那么就可以使用docker构建，这么多限制条件就知道它有多难用了，这个不想过多解释直接拿去使用就是了

```yaml
version: '3'
 services:
    head:
      image: docker.io/mobz/elasticsearch-head:5
      container_name: es-head # docker启动后的名称
      network_mode: host # 公用主机的网络
      ports:
        - 9100:9100
```