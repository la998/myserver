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

#### 从nginx迁移到npm
1. 静态站点迁移（以 UnityDocumentation 为例）
* 访问管理界面：http://服务器IP:81
* 创建静态站点：
   - Domain Names：unity.la998.com, unity.la998.test
   - Scheme：Static Files
   - Path：/opt/static_sites/UnityDocumentation
* SSL 配置：
   - 点击 SSL 标签
   - 选择已有证书 或 申请 Let's Encrypt 证书
   - 强制 HTTPS 勾选 Force SSL

#### WordPress 代理配置
1. 创建代理规则：
  - Domain Names：blog.la998.com, www.luchanglong.com.cn, luchanglong.com.cn
  - Scheme：http
  - Forward Hostname/IP：wordpress（容器名称） 
  - Forward Port：80

2. 高级代理配置：
```
# 在 "Advanced" 标签页添加：
proxy_buffer_size 128k;
proxy_buffers 4 256k;
proxy_busy_buffers_size 256k;
```
3. SSL 配置：
  - 上传现有证书或申请新证书
  - 证书路径对应容器内：
```
/etc/nginx/ssl/8083681_www.la998.com.pem → /data/ssl/certificate_xxx.pem
/etc/nginx/ssl/8083681_www.la998.com.key → /data/ssl/certificate_xxx.key
```
4. 路径重写需求
* 若某个站点需要特殊重写规则（如 Laravel）：
```
# 在 "Advanced" 标签页添加：
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```
5. 自定义错误页面
* 在 Custom Locations 中添加：
```
error_page 404 /custom_404.html;
location = /custom_404.html {
    root /opt/static_sites/errors;
    internal;
}
```
6. 性能优化建议
* 在 Dashboard → Settings 中开启 Brotli 压缩 
* 对静态站点启用缓存：
```
nginx
location ~* \.(jpg|css|js)$ {
expires 30d;
add_header Cache-Control "public";
}
```