#!/bin/bash

apt update
apt install sysstat -y

curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/crontab > /etc/cron.d/iostat

curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/iostat.conf > /etc/zabbix/zabbix_agentd.d/iostat.conf
#sleep 3
systemctl restart cron
systemctl restart zabbix-agent
