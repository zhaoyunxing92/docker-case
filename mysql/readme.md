# mysql

## yml文件

``` yaml
version: '3'
services:
  # mysql
  mysql:
    image: mysql:5.7
    container_name: mysql
    privileged: true  # 授权
    ports:
      - 3308:3306
    environment:
      MYSQL_ROOT_PASSWORD: '147' # root用户密码
      MYSQL_USER: 'sunny' #创建用户
      MYSQL_PWD: '123456' # 密码
    volumes:
      - /data/mysql/data:/var/lib/mysql
      - ./mysql.cnf:/etc/my.cnf # 把当前的mysql.conf挂载到容器中
     # - './init.sql:/docker-entrypoint-initdb.d' # 初始化sql
````

## 命令

* mysql
 > --restart=always 可以根据个人所需添加
```shell
 docker run --name mysql -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 -d mysql:5.7
```
## 可能遇到的问题
* 进入容器
```shell
docker exec -it mysql bash
```
#### plugin 'caching_sha2_password' cannot be loaded

使用的plugin不一样，需要使用`mysql_native_password`而上面的是`caching_sha2_password`

使用如下命令修改：

```sql
mysql> ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'sunny';
```

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password' PASSWORD EXPIRE NEVER; #修改加密规则 
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password'; #更新一下用户的密码 
FLUSH PRIVILEGES; #刷新权限
```