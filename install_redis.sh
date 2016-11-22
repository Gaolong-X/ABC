#!/bin/bash

REDIS_VERSION="3.2.5"
DOWNLOAD_URL="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"
INSTALL_TMP_DIR="/tmp/install_redis"
INSTALL_DIR="/usr/local/redis"

if [ ! -d "${INSTALL_TMP_DIR}" ]
then
	mkdir -p "${INSTALL_TMP_DIR}"
fi

cd "${INSTALL_TMP_DIR}"

#download
if [ ! -f "redis-${REDIS_VERSION}.tar.gz" ]
then
	wget http://download.redis.io/releases/redis-3.2.5.tar.gz
fi
#tar
tar -zxvf "redis-${REDIS_VERSION}.tar.gz" && cd "redis-${REDIS_VERSION}"
#bulid
make 
#cp
if [ ! -d "${INSTALL_DIR}" ]
then
    mkdir -p ${INSTALL_DIR}
fi

cp  './src/mkreleasehdr.sh' \
	'./src/redis-benchmark' \
	'./src/redis-check-aof' \
	'./src/redis-check-rdb' \
	'./src/redis-cli' \
	'./src/redis-sentinel' \
	'./src/redis-server' \
	'./src/redis-trib.rb' \
	"${INSTALL_DIR}"

#cp './redis.conf' "${INSTALL_DIR}"
	

#start service
