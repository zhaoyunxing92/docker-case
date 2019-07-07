# elasticsearch入门到放弃之elasticsearch-head

[elasticsearch-head](https://github.com/mobz/elasticsearch-head)可理解为跟[DBeaver](https://dbeaver.io/)一样是一个数据可视化工具，但是这个工具并没有理想中那么好用坑也是很多，我已经在我的github上fork了一份修改后的版本：https://github.com/zhaoyunxing92/elasticsearch-head

### 系列文章

 * [elasticsearch入门之docker搭建](https://www.jianshu.com/p/ba7caa5bed53)

 * [elasticsearch开启xpack安全认证](https://www.jianshu.com/p/3b01817996c8)


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

### chrome插件方式

直接说我的问题吧，我是按照[elasticsearch-head](https://github.com/mobz/elasticsearch-head)官方在地址栏后面添加`http://localhost:9100/?auth_user=elastic&auth_password=changeme`结果一直提示我`401(授权未通过)`，百度了半天都说这样就可以了(事实证明那些人根本没有开启过x-pack)，我本来是想在官网上提交一个[issues](https://github.com/mobz/elasticsearch-head/issues)的但是发现这个项目两年前就很少有人再修改了，没办法我只能硬着头皮[fork](https://github.com/zhaoyunxing92/elasticsearch-head)一份自己修改了。通过chrome抓包我发现访问头的`authorization`字段未按照理想的`basic auth`加密，下面就直接贴出我修改的地方代码吧

#### app.js修改地方
```javascript
// 打开 _site/app.js文件 跳转到3787行
_reconnect_handler: function() {
			var base_uri = this.el.find(".uiClusterConnect-uri").val();
			var url;
			if(base_uri.indexOf("?")!==-1){
				url=base_uri.substring(0,base_uri.indexOf("?")-1)
			}else{
				url=base_uri;
			}
			var argstr=base_uri.substring(base_uri.indexOf("?")+1,base_uri.length-1)
			// 在地址栏获取auth_user=elastic&auth_password=changeme格式的参数
			let args = argstr.split("&").reduce(function(r, p) {
					r[decodeURIComponent(p.split("=")[0])] = decodeURIComponent(p.split("=")[1]); return r;
				}, {});
		
			$("body").empty().append(new app.App("body", 
			{ id: "es",
			 base_uri: url,
			 auth_user : args["auth_user"]||"", 
			 auth_password : args["auth_password"]||""
			 }));
		}
```

#### 懒人模式

如果你嫌修改代码太麻烦我也做好了chrome插件：https://github.com/zhaoyunxing92/elasticsearch-head/blob/master/crx/es-head.crx 下载到本地，如果你会chrome插件开发你也可以自己编译一份使用`_site`目录编译就可以了，`manifest.json`文件我都写好了(我的chrome账户已经忘记了不然我会上传到google商店)

##### 安装流程

 在chrome地址栏输入：chrome://extensions 点开开发者模式

![chrome-extension](https://gitee.com/sunny9/resource/raw/master/img/chrome-extensions.png)

 * 下载模式安装

 本地创建一个`head`文件夹，把下载好的`es-head.crx`解压到`head`文件加里面，然后在chrome里选择`加载已解压的扩展程序`，完事后chrome右边就会多出一个搜索的icon

 * 自己编译模式

  ```shell
  # clone 代码
   git clone https://github.com/zhaoyunxing92/elasticsearch-head

  ```
  在chrome里面选择`打包扩展程序`

![chrome-extension-select](https://gitee.com/sunny9/resource/raw/master/img/chrome-extensions-1.png)

  完事后会在`_site`平级目录下多出一个`_site.crx`文件，拖到chrome里面就完成了

#### 两种方式运行方式

* 如果你是源码方式运行或者直接在浏览器打开`_site`目录的`index.html`文件那么你需要：`http://localhost:9100/?auth_user=elastic&auth_password=es密码`

* 如果你是插件先在浏览器访问`http://localhost:9100`根据提示完成账号密码输入，完事后再进入插件刷新就可以了

#### 最终效果图

> 如果你的es开启了x-pack那么输入框换成：http://localhost:9100/?auth_user=elastic&auth_password=es密码

![es-head](https://gitee.com/sunny9/resource/raw/master/img/es-head.png)