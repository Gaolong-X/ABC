#!/bin/bash
NGINX_VERSION="1.12.2"
NGINX_DOWNLOAD_DIR="/tmp/nginx"
NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
NGINX_INSTALL_DIR="/usr/local/nginx-${NGINX_VERSION}"
#NGINX_CONF_DIR="${NGINX_INSTALL_DIR}/conf"
#NGINX_LOGS_DIR="${NGINX_INSTALL_DIR}/logs"


#install tool lib ,these will be uninstall in the end
#yum -y install gcc-c++ \ make \ cmake \ wget 

#install nginx lib
yum -y install pcre-devel \
	openssl-devel

#init some dir
groupadd www && useradd -g www www

if [ ! -d ${NGINX_DOWNLOAD_DIR} ]
then
    mkdir ${NGINX_DOWNLOAD_DIR}
fi

cd ${NGINX_DOWNLOAD_DIR}

if [ ! -f nginx-${NGINX_VERSION}.tar.gz ]
then
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
fi
tar -zxf nginx-${NGINX_VERSION}.tar.gz

cd nginx-${NGINX_VERSION}

#install nginx
./configure --prefix=${NGINX_INSTALL_DIR} \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make -j && make install
#clean

#${NGINX_INSTALL_DIR}/sbin/nginx -c /${NGINX_CONF_DIR}/nginx.conf