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
3. 启动 Nginx（和Nginx Proxy Manager启动一个就可以）
```
cd ../nginx && docker-compose up -d  #使用nginx
```
4. 启动 Nginx Proxy Manager 
```
cd ../npm && docker-compose up -d   #使用npm
```
#### npm配置

对于每个静态站点（如 UnityDocumentation、ace 等），在 NPM 界面中创建静态主机

默认初始账号密码
* 用户名：admin@example.com
* 密码：changeme
* 使用Nginx Proxy Manager时，不需要使用Nginx，直接代替nginx。
* 访问 http://your-server-ip:81
* 添加 Proxy Host → 选择 Static Files 类型
  - 配置示例：
  - Domain Names: unity.la998.com
  - Path: /opt/static_sites/UnityDocumentation
  - 其他保持默认

