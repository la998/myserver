-- init/0-init-keycloak.sql
-- 开发环境专用：允许root远程访问
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';

CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 通用配置
CREATE DATABASE IF NOT EXISTS keycloak CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'keycloak'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';
ALTER USER 'keycloak'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';
GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'%';

FLUSH PRIVILEGES;