#!/bin/bash

apt update
apt install sysstat -y

echo "* * * * * root DATA=$(S_TIME_FORMAT=ISO /usr/bin/iostat -yxdt -o JSON 59 1) ; echo \"$DATA\" >/tmp/iostat-cron.out
" > /etc/cron.d/iostat

curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/iostat.conf > /etc/zabbix/zabbix_agentd.d/iostat.conf
#sleep 3
systemctl restart cron
systemctl restart zabbix-agent
