#!/bin/bash

pveum user token remove zabbixAPI@pve zabbix
pveum user token add zabbixAPI@pve zabbix --privsep 0 > /tmp/token.temp
var1=`cat /tmp/token.temp | grep tokenid | awk '{print $4}'`
var2=`cat /tmp/token.temp | grep value | tail -n1 | awk '{print $4}'`
#APITOKEN=`echo -n $var1"="$var2`
#echo "$APITOKEN" > /etc/zabbix/zabbix_agentd.d/token.txt
echo -n $var1"="$var2 > /etc/zabbix/zabbix_agentd.d/token.txt
rm -f /tmp/token.temp
