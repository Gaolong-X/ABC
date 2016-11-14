#!/bin/bash
PHP_VERSION="5.6.28"
PHP_DOWNLOAD_DIR="/tmp/php"
PHP_INSTALL_DIR="/usr/local/php-${PHP_VERSION}"

#install php lib
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum install -y gcc-c++ \
    zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools

#init some dir
groupadd www && useradd -g www www
#create tmp dir
mkdir ${PHP_DOWNLOAD_DIR}
#Make install php
cd ${PHP_DOWNLOAD_DIR} && \
    wget http://cn2.php.net/distributions/php-${PHP_VERSION}.tar.gz && \
    tar -zxvf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    ./configure --prefix=${PHP_INSTALL_DIR} \
    --with-config-file-path=${PHP_INSTALL_DIR}/etc \
    --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --disable-debug \
    --without-pear && \
    make && make install

#config
cd ${PHP_INSTALL_DIR} &&\
cp php-fpm.conf.default php-fpm.conf && \
cp php-fpm.d/www.conf.default php-fpm.d/default.conf


cd ${PHP_INSTALL_DIR}/sbin
./php-fpm
