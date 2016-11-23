#!/bin/bash

REDIS_VERSION="3.2.5"
REDIS_PORT="6375"
#REDIS_PID="/var/run/redis_${REDIS_PORT}.pid"
REDIS_PID="/usr/local/redis/redis_${REDIS_PORT}.pid"
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
	wget "http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"
fi
#tar
tar -zxvf "redis-${REDIS_VERSION}.tar.gz" && cd "redis-${REDIS_VERSION}"
#bulid
make
#cp
if [ ! -d "${INSTALL_DIR}" ]
then
    mkdir -p "${INSTALL_DIR}"
fi

#cp to install dir
cp  ./src/mkreleasehdr.sh \
	./src/redis-benchmark \
	./src/redis-check-aof \
	./src/redis-check-rdb \
	./src/redis-cli \
	./src/redis-sentinel \
	./src/redis-server \
	./src/redis-trib.rb \
	"${INSTALL_DIR}"
#set redis conf
cp ./redis.conf ./redis.conf.default

sed -i -e "s%^pidfile /var/run/redis_6379.pid%pidfile ${REDIS_PID}%" \
	-e "s%^port 6379%port ${REDIS_PORT}%" \
	./redis.conf

cp ./redis.conf "${INSTALL_DIR}"

# set redis_init_script
# this is use to service command
cp ./utils/redis_init_script ./

sed -i -e "s%^REDISPORT=6379%REDISPORT=${REDIS_PORT}%" \
	-e '/^EXEC=/'d \
	-e '/^CLIEXEC=/'d \
	-e '/^PIDFILE=/'d \
	-e '/^CONF=/'d \
	-e "/^REDISPORT/a\CONF=\"${INSTALL_DIR}/redis.conf\"" \
	-e "/^REDISPORT/a\PIDFILE=${REDIS_PID}" \
	-e "/^REDISPORT/a\CLIEXEC=${INSTALL_DIR}/redis-cli" \
	-e "/^REDISPORT/a\EXEC=${INSTALL_DIR}/redis-server" \
	./redis_init_script

cp ./redis_init_script /etc/init.d/redisd
#start service

