#!/bin/bash
# Mysql Single Server setup
# Amazon Linux 2 AMI
# user_data already launched as root (no need sudo -s}

# Add yum repo
:''
yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
yum -y repolist enabled | grep "mysql.*-community.*"
# Install the EPEL repository
amazon-linux-extras install epel -y
# Install mysql
yum -y install mysql-community-server
# Configure mysql
echo "bind_address = *" >> /etc/my.cnf
systemctl enable --now mysqld
TMP_PASS=$(grep 'temporary password' /var/log/mysqld.log |  cut -d " " -f 13)
mysql --connect-expired-password -uroot -p$TMP_PASS -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_root_pass}';"
mysql -uroot -p${new_root_pass} -e "CREATE USER '${client_username}'@'${client_cidr}' IDENTIFIED BY '${client_password}';"
mysql -uroot -p${new_root_pass} -e "GRANT ALL PRIVILEGES ON * . * TO '${client_username}'@'${client_cidr}';"
mysql -uroot -p${new_root_pass} -e "CREATE USER '${private_net_client_username}'@'${private_net_client_cidr}' IDENTIFIED BY '${private_net_client_password}';"
mysql -uroot -p${new_root_pass} -e "GRANT ALL PRIVILEGES ON * . * TO '${private_net_client_username}'@'${private_net_client_cidr}';"
# Init dataset
yum -y install git
git clone https://github.com/datacharmer/test_db.git
mysql -uroot -p${new_root_pass} -t < employees.sql
