#!/bin/bash

pveum user token remove zabbixAPI@pve zabbix
pveum user token add zabbixAPI@pve zabbix --privsep 0 > token.temp
var1=`cat ./token.temp | grep tokenid | awk '{print $4}'`
var2=`cat ./token.temp | grep value | tail -n1 | awk '{print $4}'`
APITOKEN=`echo -n $var1"="$var2`
sed -i 's/^APITOKEN=.*/APITOKEN='"$APITOKEN"'/' /etc/zabbix/zabbix_agentd.d/*.sh
rm ./token.temp
