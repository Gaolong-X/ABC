#!/bin/bash

MYSQL_USER='root'
MYSQL_PASSWD='123456'
MYSQL_DATABASE='sakila'
BACKUP_FILE_NAME="`date +'%Y%m%d%H%M%S'`.sql"
BACKUP_DIR='/data/backup/mysqldb'
LOG_DIR='/data/backup/log/mysqldb'
LOG_NAME="backup_`date +'%Y%m%d'`.log"
EMAIL='1025264711@qq.com'
STARTTIME=$(date +%s%N)

function log(){
	if [ -d "${LOG_DIR}" ]
	then
		echo -e "$1" >> "${LOG_DIR}/${LOG_NAME}"
	else
		echo 'error, not found the log directory'
	fi
}

function email(){
	local msg=$2
	local statusHTML=''
	local exetime=$3
	case $1 in
		'SUCCESS')
			statusHTML='<span class="success">SUCCESS</span>'
		;;
		'ERROR')
			statusHTML='<span class="error">ERROR</span>'
		;;
	esac
	local title='MySQL备份通知'
	mutt -s "${title}" -e 'set content_type="text/html"' ${EMAIL} << EOF
	<html>
 		<head></head>
 		<title>${title}</title> 
 		<style type="text/css">
    	table{width:90%; border-collapse:collapse; margin:0 0 10px;}
    	table td.title{font-size:14px;font-weight:bold;padding:5px 10px;  border:1px solid #C1D9F3; background:#C1D9F3;}
    	table td.key{width:120px; font-size:14px;text-align:center; background:#EFF5FB; border:1px solid #C1D9F3;}
    	table td.val{border:1px solid #C1D9F3; font-family:verdana; padding:5px 15px; line-height:20px; font-size:14px;}
    	.success{color: limegreen}
    	.error{color: red}
 		</style>
 	<body>
    	<div> 
     	<table cellpadding="0" cellspacing="0" border="0">
      	<tbody>
       	<tr><td colspan="2" class="title">${title}</td></tr>
       	<tr>
        	<td class="key">运行结果</td> 
        	<td class="val">${statusHTML}</td>
       	</tr>
		<tr>
			<td class="key">运行时长</td>
			<td class="val">${exetime} sec</td>
		</tr>
		<tr>
			<td class="key">日志内容</td> 
			<td class="val">${msg}</td>
        </tr>
      	</tbody>
     	</table> 
    	</div>
 	</body>
</html>
EOF
}

function mark(){
	local flag=$1
	local msg=$2
	local logmsg="time:`date +'%Y-%m-%d %H:%M:%S'` $$ [$flag] $2"
	
	#set log
	if test "${EMAIL}"
	then
		if test "${emailmsg}"
		then
			emailmsg="${emailmsg}<br/>${logmsg}"
		else
			emailmsg="${logmsg}"
		fi
	fi

	if [ "${flag}" == 'SUCCESS' ] || [ "${flag}" == 'ERROR' ]
	then
		#计算运行时长
		local curtime=$(date +%s%N)
		#local timediff=`expr ${curtime} - ${STARTTIME}`				
		local exetime=$(printf "%.5f" `echo "scale=5;(${curtime}-${STARTTIME})/1000000000" | bc`)
		#写入日志
		#logmsg="${logmsg} Exec:${exetime}"
		log "${logmsg} Exec:${exetime}"
		if test "${EMAIL}"
		then
			email "${flag}" "${emailmsg} Exec:${exetime}" "${exetime}"
		fi
	else
		log "${logmsg}"
	fi
}

#init
if [ ! -d "${LOG_DIR}" ]
then
	mkdir -p "${LOG_DIR}"
	if [ ! $? -eq 0 ]
	then
		mark 'ERROR' 'Create log directory fail.'
		exit 1
	fi
fi

mark 'NOTE' 'Start Run.'

if [ ! -d "${BACKUP_DIR}" ]
then
	mkdir -p "${BACKUP_DIR}"
	if [ ! $? -eq 0 ]
 	then
		mark 'ERROR' 'Create backup directory.'
 		exit 1;
 	fi
fi

mark 'NOTE' 'backup...'

mysqldump -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -R "${MYSQL_DATABASE}" > "${BACKUP_DIR}/${BACKUP_FILE_NAME}"

if [ $? -eq 0 ]
then
	mark 'SUCCESS' 'Backup completed.'
else
	mark 'ERROR' 'Backup fail,mysqldump execute error.'
fi

exit $?

