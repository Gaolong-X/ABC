#!/bin/bash

INSTALL_DIR='/usr/local/jdk8u111'
INSTALL_FIEL_NAME='jdk'
INSTALL_TMP_DIR='/tmp/install_jdk'
DOWNLOAD_URL='http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz'



wget -O "${INSTALL_FIEL_NAME}" "${DOWNLOAD_URL}"

tar -zxvf ${INSTALL_FIEL_NAME}

mv -R "${INSTALL_FIEL_NAME}/*" "{$INSTALL_DIR}"

#set evirment
echo -e '#java environment\n'
echo -e "export JAVA_HOME={$INSTALL_DIR}\n"
echo -e "export PATH=$JAVA_HOME/bin:$PATH\n"
echo -e "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"

source /etc/profile

