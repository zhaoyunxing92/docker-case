# docker 制作过程

主要看下docker制作过程和怎么推送到hub上方便其他同学使用

## 启动

> 在`docekr`目录下直接`vagrant up`就可以了,这个脚本会自动安装docker如果没有的话。

```shell
vagrant up
```

## 进入

```shell
vagrant ssh
```

## 我对容器修改地方

### 允许ssh登录

> sudo vi /etc/ssh/sshd_config

```shell
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication yes
PermitEmptyPasswords yes
#PasswordAuthentication no
```

完事后保存下重新启动ssh服务 `sudo  service sshd restart`

## 权限问题

> 脚本里面授权了不知道为什么没有执行

```shell
# 添加用户组
sudo usermod -aG docker $USER && newgrp docker
```

## 打包

> 我这里打包到指定目录里面 [package doc](https://www.vagrantup.com/docs/cli/package) 

```shell
vagrant package --output ./pkg/docker.box
```

## 添加到本地

> `cd pkg` 执行一下命令

```shell
vagrant box add metadata.json
```

