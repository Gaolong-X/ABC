#!/bin/bash
PHP_VERSION="7.3.12"
PHP_DOWNLOAD_DIR="/tmp/php"
PHP_INSTALL_DIR="/usr/local/php-${PHP_VERSION}"
PHP_DOWNLOAD_URL="http://cn2.php.net/distributions/php-${PHP_VERSION}.tar.gz"

#install php lib
#rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
yum install -y gcc-c++ \
    openssl-devel \
    libxml2-devel \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libzip-devel \

#init some dir
groupadd www && useradd -g www www
#create tmp dir
if [ ! -d ${PHP_DOWNLOAD_DIR} ]
then
    mkdir ${PHP_DOWNLOAD_DIR}
fi

cd ${PHP_DOWNLOAD_DIR}

if [ ! -f php-${PHP_VERSION}.tar.gz ]
then
     curl -O ${PHP_DOWNLOAD_URL}
fi

 tar -zxvf php-${PHP_VERSION}.tar.gz

# cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h

cd php-${PHP_VERSION} && \
    ./configure --prefix=${PHP_INSTALL_DIR} \
    --with-config-file-path=${PHP_INSTALL_DIR}/etc \
    --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    #--with-mcrypt \
    #--with-mysqli \
    --with-pdo-mysql \
    --with-pdo-sqlite \
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
    --enable-ctype \
    #--enable-gd-native-ttf \
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
    make -j && make install



#config
cp php.ini-development php.ini-production ${PHP_INSTALL_DIR}/etc
cd ${PHP_INSTALL_DIR} && \
cp etc/php.ini-production etc/php.ini && \
cp etc/php-fpm.conf.default etc/php-fpm.conf && \
cp etc/php-fpm.d/www.conf.default etc/php-fpm.d/www.conf

#set php-fpm
cp sapi/fpm/init.d.php-fpm.in /etc/init.d/php-fpm
sed -i -e "s%^@prefix@%${PHP_INSTALL_DIR}%" \
    -e 's%^@exec_prefix@%${prefix}/bin%' \
	-e 's%^@sbindir@%${prefix}/sbin%' \
	-e 's%^@sysconfdir@%${prefix}/etc%' \
	-e 's%^@localstatedir@%${prefix}/var%' /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
#/etc/init.d/php-fpm status
