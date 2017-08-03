#!/bin/bash

NGINX_PID="/var/run/nginx.pid"

#access log
ACCESS_LOG="/data/logs/nginx/access.log"

#archive target dir
TARGET_DIR="/data/logs/nginx"

#archive name
TARGET_FILE_NAME="${TARGET_DIR}/access_$(date -d "yesterday" +%Y_%m_%d).log"

ARCHIVE_FILE_NAME="${TARGET_DIR}/access_$(date -d "yesterday" +%Y_%m_%d).log.tar.gz"

mv ${ACCESS_LOG} ${TARGET_FILE_NAME}

kill -USR1 $(cat ${NGINX_PID})

tar -zcf ${TARGET_FILE_NAME} ${ARCHIVE_FILE_NAME} --remove-files
