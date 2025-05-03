-- 设置root本地访问
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';

-- 创建root远程用户（如果不存在）
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Mrluchanglong@163.com';

-- 授权
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;