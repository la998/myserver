#### 服务器启动服务
```
KC_ENV=pro docker-compose --env-file .env.pro down
KC_ENV=pro docker-compose --env-file .env.pro up -d
```
```
# 重启流程：
# 优雅停止服务（保留 volume 数据）
KC_ENV=pro docker-compose --env-file .env.pro down
# 强制清理旧容器残留（可选，解决端口冲突）
docker container prune -f
docker network prune -f
# 启动
KC_ENV=pro docker-compose --env-file .env.pro up -d
# 验证服务状态
docker-compose logs -f --tail=100 keycloak | grep -i 'started in'
```
#### 本地启动服务
```
KC_ENV=dev docker-compose --env-file .env.dev down
KC_ENV=dev docker-compose --env-file .env.dev up -d
```
* 访问地址：http://localhost:8080



#### 访问管理控制台

* http://localhost:8080/admin
* 使用 admin/admin 登录。默认admin/change_me
* https://keycloak.la998.com/admin   必须通过HTTPS访问
* 生产环境访问：https://keycloak.la998.com
* 管理控制台登录：使用 .env 中定义的 KEYCLOAK_ADMIN 和 KEYCLOAK_ADMIN_PASSWORD。
* 健康检查：通过 docker ps 查看容器状态，或调用 http://keycloak.la998.com/health/ready 验证
* 获取配置地址 https://keycloak.la998.com/realms/master/.well-known/openid-configuration

#### 验证配置
```
# 清理旧容器并重新部署
docker-compose down -v
docker-compose up -d

# 查看日志确认 Keycloak 启动正常
docker logs keycloak

# 检查 KC_ENV 变量传递是否正确
KC_ENV=dev docker-compose --env-file .env.dev config

# 确保 web_network 已正确创建
docker network inspect web_network

#检查 keycloak_mysql_data 卷是否存在
docker volume inspect mykeycloak_keycloak_mysql_data

# 监控实际内存使用
watch -n 1 "docker stats --no-stream | grep -E 'keycloak|mysql'"

#进入容器检查时间
docker exec -it keycloak_mysql date

# 终极清理方案
# 清理所有Docker残留
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
docker volume prune -f
docker network prune -f

# 重新克隆仓库并部署
git clone your-repo-url 
cd your-repo
KC_ENV=dev docker-compose --env-file .env.dev up -d

#查看所有容器（包括暂停的容器）
docker ps -a
#过滤仅显示暂停的容器
docker ps -a --filter "status=paused"
#恢复暂停的容器
docker unpause my-nginx
# 恢复所有暂停的容器
docker ps -aq --filter "status=paused" | xargs docker unpause
# 停止并删除所有暂停的容器
docker ps -aq --filter "status=paused" | xargs docker stop | xargs docker rm

```

#### nginx proxy manage(npm) Advanced 配置
```
# 强制传递真实协议和客户端信息
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-Port $server_port;
proxy_set_header X-Real-IP $remote_addr;

# WebSocket 支持
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";

# 性能优化（增大超时时间）
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;


# 安全头（防止点击劫持、MIME 嗅探等）
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Content-Type-Options "nosniff";
add_header X-Frame-Options "SAMEORIGIN";
add_header Referrer-Policy "strict-origin";
```