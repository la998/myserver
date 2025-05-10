# env.pro
# Keycloak
KC_COMMAND=start                     # 强制生产模式启动命令
KC_DB=mysql
KC_DB_URL=jdbc:mysql://keycloak_mysql:3306/keycloak?
  useSSL=false&
  allowPublicKeyRetrieval=true&
  connectionTimeout=45000&          # 连接超时 45s
  socketTimeout=60000&              # Socket 超时 60s
  maxPoolSize=35&                   # 连接池上限
  minIdle=10&                       # 最小空闲连接
  idleTimeout=240000&               # 空闲超时 4 分钟
  validationQuery=SELECT 1&         # 连接保活
  testOnBorrow=true
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=Mrluchanglong@163.com
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KC_HOSTNAME=keycloak.la998.com
KC_HTTP_ENABLED=false                # 生产环境禁用 HTTP
KC_HTTPS_ENABLED=true                # 启用 HTTPS（需配置证书）
KC_PROXY=edge                        # 代理模式（与反向代理配合）
PROXY_ADDRESS_FORWARDING=true
KC_HOSTNAME_STRICT=true
KC_HOSTNAME_STRICT_HTTPS=true

# MySQL
MYSQL_DATABASE=keycloak
MYSQL_USER=keycloak
MYSQL_PASSWORD=Mrluchanglong@163.com
MYSQL_ROOT_PASSWORD=Mrluchanglong@163.com

# Java
JAVA_OPTS=-Xmx768m -Xms512m -XX:MaxRAM=1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=150 -XX:InitiatingHeapOccupancyPercent=35 -XX:ParallelGCThreads=4 -XX:ConcGCThreads=2 -Djava.net.preferIPv4Stack=true

# 生产环境优化配置
KC_HEALTH_ENABLED=true               # 启用健康检查
KC_METRICS_ENABLED=true              # 启用监控指标
KC_CACHE_STACK=kubernetes            # 生产建议使用分布式缓存（如 redis）
KC_TRANSACTION_XA_ENABLED=true       # 启用 XA 事务