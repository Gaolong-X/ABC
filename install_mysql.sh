#!/bin/bash
MYSQL_VERSION="5.6.32"
MYSQL_PKG_NAME="mysql-${MYSQL_VERSION}"
MYSQL_DOWNLOAD_URL="http://cdn.mysql.com//Downloads/MySQL-5.6/${MYSQL_PKG_NAME}.tar.gz" #替换下载链接
DOWNLOAD_TMP_DIR="/usr/local/src"
MYSQL_INSTALL_DIR="/usr/local/${MYSQL_PKG_NAME}"
MYSQL_DATA_DIR="/data/mysqldb"
#MYSQL_TMP_PATH="${DOWNLOAD_TMP_DIR}/${MYSQL_PKG_NAME}.tar.gz"
MYSQL_DEFAULT_PASSWORD="123456"

groupadd mysql && useradd -r -g mysql mysql

yum -y install gcc-c++ ncurses-devel cmake

if [ ! -d ${DOWNLOAD_TMP_DIR} ]
then
	mkdir ${DOWNLOAD_TMP_DIR}
fi
cd ${DOWNLOAD_TMP_DIR}
#download mysql source package
if [ ! -f "${MYSQL_PKG_NAME}.tar.gz" ]
then
	wget ${MYSQL_DOWNLOAD_URL}
fi 
tar -zxvf "./${MYSQL_PKG_NAME}.tar.gz"
#creat data dir
if [ ! -d ${MYSQL_DATA_DIR} ]
then
	mkdir -p ${MYSQL_DATA_DIR}
fi
chown -R mysql:mysql ${MYSQL_DATA_DIR}
#compile and install
cd ${MYSQL_PKG_NAME}
cmake \
	-DCMAKE_INSTALL_PREFIX=${MYSQL_INSTALL_DIR} \
	-DMYSQL_UNIX_ADDR=${MYSQL_INSTALL_DIR}/mysql.sock \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DMYSQL_DATADIR=${MYSQL_DATA_DIR} \
	-DMYSQL_TCP_PORT=3306 \
	-DENABLE_DOWNLOADS=1

make && make install

cd ${MYSQL_INSTALL_DIR}
chown -R mysql:mysql .

scripts/mysql_install_db --user=mysql --datadir=${MYSQL_DATA_DIR} --innodb_undo_tablespaces=16

cp ${MYSQL_INSTALL_DIR}/support-files/mysql.server /etc/init.d/mysqld

cp -f ${MYSQL_INSTALL_DIR}/support-files/my-default.cnf /etc/my.cnf
#set environment
echo -e "PATH=${MYSQL_INSTALL_DIR}/bin:${MYSQL_INSTALL_DIR}/lib:\$PATH\nexport PATH" >> /etc/profile
source /etc/profile

#service mysqld start

mysqladmin -u root password "${MYSQL_DEFAULT_PASSWORD}"

#chkconfig --level 35 mysqld on




