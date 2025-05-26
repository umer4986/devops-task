#!/bin/bash
# Update and install MySQL server
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server jq awscli

# Start MySQL service
systemctl start mysql
systemctl enable mysql

# Fetch DB password from AWS SSM Parameter Store
DB_PASSWORD=$(aws ssm get-parameter --name "/your/env/mysql-password" --with-decryption --query "Parameter.Value" --output text --region YOUR_REGION)

# Secure MySQL installation and setup DB, user
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS crud_app;

CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON crud_app.* TO 'appuser'@'%';

FLUSH PRIVILEGES;
EOF

# Configure MySQL to allow remote access (bind-address)
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL to apply changes
systemctl restart mysql
