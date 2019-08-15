# jenkins

## yml文件

``` yaml
version: '3'
services:
  # jenkins
  jenkins:
    image: jenkins/jenkins:latest
    container_name: jenkins
    ports:
      - 8080:8080
      - 50000:50000
````

## 命令

 > --restart=always 可以根据个人所需添加
```shell
docker run -p 8080:8080 -p 50000:50000 --name jenkins -d jenkins/jenkins:latest
```

## 可能遇到的问题

  * 修改文件夹的归属者和组(必须)
  ```shell
  sudo chown -R 1000:1000 jenkins/
  ```
  * maven配置不成功
  ```shell
  sudo chown -R jenkins:jenkins maven目录
  ```
  * 进入容器看密码
  ```shell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
  ```