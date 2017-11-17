#!/bin/bash

NGX_PID="/var/run/nginx.pid"
NGX_LOG_DIR="/usr/local/nginx/logs"
TARGET_DIR="/usr/local/nginx/logs"
DATE=$(date +%Y_%m_%d)
TARGET_FILE_EXT="${DATE}.log"
ARCHIVE_FILE_EXT=".log.tar.gz"
#access log
LOGS=(
	"access.log"
	"error.log"
	"web.server.org.access.log"
	"web.server.org.error.log"
)

target_log_arr=()
for log in ${LOGS[*]}
do	
	target_log_name=${log%.log*}_${TARGET_FILE_EXT}
	target_log_arr+=(${target_log_name})
	mv ${NGX_LOG_DIR}/${log} ${TARGET_DIR}/${target_log_name}
done

kill -USR1 $(cat ${NGX_PID})

cd ${TARGET_DIR}

for log in ${target_log_arr[*]}
do
	target_log_name=${log%.log*}${ARCHIVE_FILE_EXT}
	tar -zcf ${target_log_name} ${log} --remove-files		
done

