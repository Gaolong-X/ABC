#!/bin/bash

MYSQL_USER='root'
MYSQL_PASSWD='123456'
BACKUP_FILE_NAME="`date +'%Y%m%d%H%M%S'`.sql"
BACKUP_DIR='/data/backup/mysqldb'
BACKUP_DATABASE='b2b2c'
BACKUP_LOG_DIR='/data/backup/log/mysqldb'
BACKUP_LOG_NAME="backup_`date +'%Y%m%d'`.log"
#BACKUP_LOG_FILE="${BACKUP_LOG_DIR}/${BACKUP_LOG_NAME}"
CURRENT_PID=$$
EMAIL='1025264711@qq.com'

function log(){
	echo "time:`date +'%Y-%m-%d %H:%M:%S'` ${CURRENT_PID} $1" >> \
	"${BACKUP_LOG_DIR}/${BACKUP_LOG_NAME}"
}

function email(){
	local msg=$2
	local statusHTML=''
	case $1 in
		SUCCESS)
			statusHTML='<span class="success">SUCCESS</span>'
		;;
		ERROR)
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
    	<div id="mailContentContainer"> 
     	<table cellpadding="0" cellspacing="0" border="0">
      	<tbody>
       	<tr><td colspan="2" class="title">${title}</td></tr>
       	<tr>
        	<td class="key"><span>状态</span></td> 
        	<td class="val">${statusHTML}</td>
       	</tr>
		<tr>
			<td class="key"><span>日志内容</span></td> 
			<td class="val">${msg}</td>
        </tr>
      	</tbody>
     	</table> 
    	</div>
 	</body>
</html>
EOF
}

#init
if [ ! -d "${BACKUP_LOG_DIR}" ]
then
	mkdir -p "${BACKUP_LOG_DIR}"
	if [ ! $? -eq 0 ]
	then
		email 'ERROR' 'Error, Create log directory'
		exit 1
	fi
fi

logmsg='[NOTE] Start working'
emailmsg="${logmsg}"
log ${logmsg}

if [ ! -d "${BACKUP_DIR}" ]
then
	mkdir -p "${BACKUP_DIR}"
	if [ ! $? -eq 0 ]
 	then
		logmsg='[ERROR] Create backup directory'
		emailmsg="${emailmsg}<br/>${logmsg}"
 		log ${logmsg}
		email 'ERROR' ${emailmsg}
 		exit 1;
 	fi
fi

logmsg='[NOTE] Start backup...'
emailmsg="${emailmsg}<br/>${logmsg}"
log ${logmsg}

result=`mysqldump -u"${MYSQL_USER}" -p"${MYSQL_PASSWD}" -R "${BACKUP_DATABASE}" > "${BACKUP_DIR}/${BACKUP_FILE_NAME}"`

if [ $? -eq 0 ]
then	
	log '[SUCCESS] Backup completed'
else
	log '[ERROR] Backup fail, command execution failed!'
fi

exit $?

