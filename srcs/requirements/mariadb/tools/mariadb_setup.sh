# srcs/requirements/mariadb/tools/mariadb_setup.sh
#!/bin/bash
if [[ ! -d "/var/lib/mysql/mysql" ]]; then
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm


    chown -R mysql:mysql /var/lib/mysql


    mysqld --user=mysql --bootstrap --verbose --skip-name-resolve --skip-networking=0
<<EOF
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;

EOF
fi

exec "$@"