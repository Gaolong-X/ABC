#!/bin/bash
#echo "Hello World"

MYSQL_VERSION="5.6.32"
MYSQL_PKG_NAME="mysql-${MYSQL_VERSION}"
MYSQL_DOWNLOAD_URL="http://cdn.mysql.com//Downloads/MySQL-5.6/${MYSQL_PKG_NAME}.tar.gz"
DOWNLOAD_TMP_DIR="/tmp/install_mysql"
MYSQL_INSTALL_DIR="/usr/local/${MYSQL_PKG_NAME}"
MYSQL_DATA_DIR="/data/mysqldb"
#MYSQL_TMP_PATH="${DOWNLOAD_TMP_DIR}/${MYSQL_PKG_NAME}.tar.gz"

groupadd mysql
useradd -r -g mysql mysql

yes | yum install gcc-c++ ncurses-devel cmake

mkdir -p ${MYSQL_DATA_DIR}
chown -R mysql:mysql ${MYSQL_DATA_DIR}

mkdir ${DOWNLOAD_TMP_DIR}
cd ${DOWNLOAD_TMP_DIR}
#wget ${MYSQL_DOWNLOAD_URL}
cp /tmp/${MYSQL_PKG_NAME}.tar.gz ${DOWNLOAD_TMP_DIR}

MYSQL_TMP_DIR="${DOWNLOAD_TMP_DIR}/${MYSQL_PKG_NAME}.tar.gz"
if [ ! -e ${MYSQL_TMP_PATH} ]
then
	echo "Error:not fund ${MYSQL_PKG_NAME}.tar.gz file"
	exit 0
fi

cd ${DOWNLOAD_TMP_DIR}
tar -zxvf "./${MYSQL_PKG_NAME}.tar.gz"

if [ ! -d ${MYSQL_PKG_NAME} ]
then
	echo "Error:${MYSQL_PKG_NAME} decompression failed"
	exit 0
fi

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

echo "#MySQL environment variable"
echo "${MYSQL_INSTALL_DIR}/bin:${MYSQL_INSTALL_DIR}/lib:\$PATH\nexport PATH" >> /etc/profile

source /etc/profile

service mysqld start

mysqladmin -u root password '123456'

chkconfig --level 35 mysqld on




