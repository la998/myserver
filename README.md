## Ubuntu24 配置服务器环境

#### 服务器安装docker、docker-compose
    略
#### 文件目录结构和nginx域名映射
```text
.
├── UnityDocumentation  #unity.la998.com
├── ace                 #ace.la998.com
├── adminlte            #adminlte.la998.com
├── color_admin_v3.0    #coloradmin.la998.com
├── la998               #www.la998.com/la998.com
├── laraveldocs         #laraveldocs.la998.com
├── layim-v3.7.8        #layim.la998.com
├── layuiAdmin.pro-v1.1.0 #layuiadmin.la998.com
└── wordpress           #blog.la998.com
```
#### 启动服务
    启动服务之前，需要修改nginx/.env和wordpress/.env中的路径为实际路径
    STATIC_HTML_PATH=/Users/luchanglong/workspace/html
 ```
 #在mac上需要设置wordperss权限
 mkdir -p wordpress 
 chmod -R 777 wordpress
 sudo chmod -R a+rwx wordpress
 ```
0. 创建网络
```
docker network create web_network
# 检查容器是否加入 web_network
docker network inspect web_network
docker network ls
docker network rm web_network
 ```
1. 启动 MySQL
```
cd mysql && docker-compose up -d
```
2. 启动 WordPress
```
cd ../wordpress && docker-compose up -d
```
3. 启动 Nginx
```
cd ../nginx && docker-compose up -d
```

#### 配置ssl证书
