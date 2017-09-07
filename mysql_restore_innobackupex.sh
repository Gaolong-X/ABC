#!/bin/bash

backup_file=$1
USER='mysql'
GROUP='mysql'
MY_CNF='/etc/my.cnf'
DATADIR='/www/data/mysqldb'

if [ -z "${backup_file}" ]; then
	echo 'input backup file path'
	exit 1
fi

if [ ! -e "${backup_file}" ]; then
	echo 'backup file not exist'
	exit 1
fi

if [ ! -d "${DATADIR}" ]; then
	echo 'the datadir is not exist'
	exit 1
fi

echo 'start recovery...'

recovery_dir="`dirname ${backup_file}`/recovery_`basename ${backup_file} .tar.gz`"

echo "create recovery dir ${recovery_dir}"

if [ -d ${recovery_dir} ] ; then
    echo "the recovery dir exist and create new folder"
    rm -rf "${recovery_dir}/*"
else
    echo "create recovery dir ${recovery_dir}"
    mkdir "${recovery_dir}"
fi

echo "copy the data file form backup dir to recovery dir..."

tar -zxvf ${backup_file} -C ${recovery_dir}

echo "innobackupex --apply-log ${recovery_dir}"
innobackupex --apply-log ${recovery_dir}

echo 'service mysqld stop'
service mysqld stop

if [ $? -ne 0 ]; then
	echo 'stop mysqld service failed'
	exit $?
fi

datadir_backup="`dirname ${DATADIR}`/`basename ${DATADIR}`_backup"
echo "rename datadir ${DATADIR} -> ${datadir_backup}"
mv ${DATADIR} ${datadir_backup}

echo 'create new datadir and copy recoveey file to datadir'
mkdir "${DATADIR}"

innobackupex --defaults-file=${MY_CNF} --copy-back ${recovery_dir}

if [ $? -ne 0 ]; then
	echo 'innobackupex copy-back field'
	exit
fi

chown -R ${USER}:${GROUP} ${DATADIR}

echo 'service mysqld start'
service mysqld start

echo 'completed'

