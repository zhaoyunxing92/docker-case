# mongo

## yml文件

``` yaml
version: '3'
services:
  # mongo
  mongo:
    image: mongo:latest
    container_name: mongo # docker启动后的名称
    ports:
      - 27017:27017
````
