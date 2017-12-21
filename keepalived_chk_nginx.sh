#!/bin/bash
ngx_ps_num=`ps -C nginx --no-header | wc -l`
if [ ${ngx_ps_num} -eq 0 ]
then
    /etc/init.d/keepalived stop
fi