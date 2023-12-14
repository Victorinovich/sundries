#!/bin/bash

#apt update
#apt install jq -y
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-backup-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-running-machines-to-enable-backup.sh > /etc/zabbix/zabbix_agentd.d/check-running-machines-to-enable-backup.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-machines-to-type-backup.sh > /etc/zabbix/zabbix_agentd.d/check-machines-to-type-backup.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-localstorage-status-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-localstorage-status-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/pbs-verify-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/pbs-verify-backup-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/quantity-of-backups-discovery.sh > /etc/zabbix/zabbix_agentd.d/quantity-of-backups-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/userparameters_pveapi_scripts.conf > /etc/zabbix/zabbix_agentd.d/userparameters_pveapi_scripts.conf
#chmod +x /etc/zabbix/zabbix_agentd.d/*.sh
#echo "Timeout=30" >> /etc/zabbix/zabbix_agentd.conf

proxmox-backup-manager user generate-token pbsilogy-readonly@pbs zabbix > /tmp/token.temp
#proxmox-backup-manager user list-tokens pbsilogy-readonly@pbs

var1=`cat ./token.temp | grep tokenid | awk '{print $4}'`
var2=`cat ./token.temp | grep value | tail -n1 | awk '{print $4}'`
APITOKEN=`echo -n $var1":"$var2`
echo $APITOKEN
#sed -i '3i APITOKEN='"$APITOKEN"'' /etc/zabbix/zabbix_agentd.d/*.sh
#rm -f /tmp/token.temp
#sleep 3
#systemctl restart zabbix-agent
