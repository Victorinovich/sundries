#!/bin/bash
pveum role add zabbix_API_monitoring --privs "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit Sys.Audit VM.Audit VM.Backup"
pveum group add zabbixAPI -comment "group for PVE API access read"
pveum acl modify / -group zabbixAPI -role zabbix_API_monitoring
pveum user add zabbixAPI@pve 
pveum user modify zabbixAPI@pve -group zabbixAPI
pveum user token add zabbixAPI@pve zabbix --privsep 0 > token.temp
var1=`cat ./token.temp | grep tokenid | awk '{print $4}'`
var2=`cat ./token.temp | grep value | tail -n1 | awk '{print $4}'`
APITOKEN=`echo -n $var1"="$var2`
export APITOKEN=$APITOKEN
echo -e "\nAPITOKEN=$APITOKEN" >> /etc/environment
rm ./token.temp
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-backup-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-running-machines-to-enable-backup.sh > /etc/zabbix/zabbix_agentd.d/check-running-machines-to-enable-backup.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-machines-to-type-backup.sh > /etc/zabbix/zabbix_agentd.d/check-machines-to-type-backup.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-localstorage-status-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-localstorage-status-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/pbs-verify-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/pbs-verify-backup-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/userparameters_pveapi_scripts.conf > /etc/zabbix/zabbix_agentd.d/userparameters_pveapi_scripts.conf
chmod +x /etc/zabbix/zabbix_agentd.d/*.sh
#sleep 3
#systemctl restart zabbix-agent
