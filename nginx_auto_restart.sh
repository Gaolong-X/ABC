#!/bin/bash
ngx=/usr/local/nginx/sbin/nginx
ngx_conf=/usr/local/nginx/conf/nginx.conf
ngx_ps_num=`ps -C nginx --no-header | wc -l`
if [ ${ngx_ps_num} -eq 0 ]
then
    ${ngx} -c ${ngx_conf}
fi