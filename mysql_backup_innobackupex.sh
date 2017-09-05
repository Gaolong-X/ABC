#!/bin/bash
USER='root'
PASSWORD='123456'
HOST='127.0.0.1'
BACKUP_DIR='~/xtrabackup'
MY_FILE='/etc/my.cnf'
BACKUP_NAME="full_`date +'%Y-%m-%d_%H-%M-%S'`.tar.gz"
#echo ${BACKUP_NAME}
#innobackupex --help
innobackupex --defaults-file=${MY_FILE} --stream=tar --host=${HOST} --user=${USER} --password=${PASSWORD} ${BACKUP_DIR} | gzip > ${BACKUP_DIR}/${BACKUP_NAME}
