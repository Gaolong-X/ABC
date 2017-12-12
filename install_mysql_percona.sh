#!/bin/bash
MYSQL_PKG_NAME="percona-server-5.7.19-17"
MYSQL_DOWNLOAD_URL="https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-5.7.19-17/source/tarball/${MYSQL_PKG_NAME}.tar.gz"
DOWNLOAD_TMP_DIR="/usr/local/src"
MYSQL_INSTALL_DIR="/usr/local/mysql"
MYSQL_DATA_DIR="/data/mysqldb"
#must download boost 
BOOST_DOWNLOAD_URL="https://nchc.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz"
BOOST_INSTALL_PATH="/usr/local/boost"

groupadd mysql && useradd -r -g mysql mysql

yum -y install gcc-c++ ncurses-devel cmake bison libaio-devel readline-devel zlib-devel

if [ ! -d ${DOWNLOAD_TMP_DIR} ]
then
	mkdir ${DOWNLOAD_TMP_DIR}
fi
cd ${DOWNLOAD_TMP_DIR}
#download boost
if [ ! -f "./boost.tar.gz" ]
then
	wget ${BOOST_DOWNLOAD_URL} -O "boost.tar.gz"
fi 
tar -zxvf "./boost.tar.gz"
cp -R "./boost_1_59_0" ${BOOST_INSTALL_PATH}
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
	-DWITH_BOOST=${BOOST_INSTALL_PATH} \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	#-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DMYSQL_DATADIR=${MYSQL_DATA_DIR} \
	-DMYSQL_TCP_PORT=3306 \
	-DENABLE_DOWNLOADS=1 \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_CONFIG=mysql_release \
	-DFEATURE_SET=community \
	-DWITH_EMBEDDED_SERVER=OFF

make && make install

cd ${MYSQL_INSTALL_DIR}
chown -R mysql:mysql .

./bin/mysqld --initialize-insecure \
	--user=mysql \
	--basedir=${MYSQL_INSTALL_DIR} \
	--datadir=${MYSQL_DATA_DIR} \
	--innodb_data_file_path=ibdata1:1024M:autoextend \
	--innodb_undo_tablespaces=16

cp ${MYSQL_INSTALL_DIR}/support-files/mysql.server /etc/init.d/mysqld

echo -e "PATH=${MYSQL_INSTALL_DIR}/bin:${MYSQL_INSTALL_DIR}/lib:\$PATH\nexport PATH" >> /etc/profile
source /etc/profile

echo 'completed.'
#SET PASSWORD=PASSWORD('123456');
