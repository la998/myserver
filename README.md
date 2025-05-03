一、
服务器安装docker、docker-compose
二、
文件目录结构和nginx域名映射
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

blog.la998.com 为wordpress的访问需要mysql和php支持，其他均为纯html静态页项目。
所有文件夹均放在路径下：
/Users/luchanglong/workspace/html


1.首先创建共享网络（所有服务需要连接同一网络）：
docker network create web_network
2.服务目录结构建议如下：

.
├── README.md
├── mysql
│   ├── conf
│   │   └── mysql.conf
│   ├── docker-compose.yml
│   └── init
│       ├── 01-permissions.sql
│       └── 02-wordpress.sql
├── nginx
│   ├── conf.d
│   │   ├── static.conf
│   │   └── wordpress.conf
│   ├── docker-compose.yml
│   └── ssl
│       ├── 8083681_www.la998.com.key
│       ├── 8083681_www.la998.com.pem
│       ├── 8083726_www.luchanglong.com.cn.key
│       └── 8083726_www.luchanglong.com.cn.pem
└── wordpress
    └── docker-compose.yml

启动顺序：
1. 启动 MySQL
cd mysql && docker-compose up -d
2. 启动 WordPress
cd ../wordpress && docker-compose up -d
3. 启动 Nginx
cd ../nginx && docker-compose up -d
