一、
服务器安装docker、docker-compose
二、
目录结构和nginx域名映射
.
├── UnityDocumentation  #unity.la998.com
├── ace    #ace.la998.com
├── adminlte #adminlte.la998.com
├── color_admin_v3.0 #coloradmin.la998.com
├── la998 #www.la998.com/la998.com
├── laraveldocs #laraveldocs.la998.com
├── layim-v3.7.8 #layim.la998.com
├── layuiAdmin.pro-v1.1.0 #layuiadmin.la998.com
└── wordpress #blog.la998.com

blog.la998.com 为wordpress需要mysql和php支持，其他均为纯html静态页项目。
路径为：
luchanglong@luchanglongdeMacBook-Air html % pwd
/Users/luchanglong/workspace/html

请通过docker-compose部署以上应用。
mysql、nginx、wordpress需要独立的docker-compose文件。
因为mysql、nginx还需要给其他应用提供服务。

1.首先创建共享网络（所有服务需要连接同一网络）：
docker network create web_network
2.目录结构建议如下：
myserver/
├── mysql/
│   ├── docker-compose.ymlø
│   └── data/          # MySQL 数据持久化目录
├── nginx/
│   ├── docker-compose.yml
│   ├── conf.d/
│   │   ├── static.conf
│   │   └── wordpress.conf
│   └── ssl/           # 如果需要 HTTPS 可放置证书
└── wordpress/
    ├── docker-compose.yml
    └── wp-content/    # WordPress 数据持久化目录

启动顺序：
1. 启动 MySQL
cd mysql && docker-compose up -d
2. 启动 WordPress
cd ../wordpress && docker-compose up -d
3. 启动 Nginx
cd ../nginx && docker-compose up -d
