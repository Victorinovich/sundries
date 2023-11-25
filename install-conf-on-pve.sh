#!/bin/bash
echo "acl:1:/:@zabbixAPI:zabbix_API_monitoring:" >> /etc/pve/user.cfg
echo ""
echo -n "Введите значение APIToken:  "
read APITOKEN
echo ""
export APITOKEN=$APITOKEN
echo "APITOKEN=$APITOKEN" >> /etc/environment
pveum role add zabbix_API_monitoring --privs "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit Sys.Audit VM.Audit VM.Backup"
pveum group add zabbixAPI -comment "group for PVE API access read"
pveum acl modify / -group zabbixAPI -role zabbix_API_monitoring
pveum user add zabbixAPI@pve 
pveum user modify zabbixAPI@pve -group zabbixAPI

#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-backup-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-running-machines-to-enable-backup.sh > /etc/zabbix/zabbix_agentd.d/check-running-machines-to-enable-backup.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-machines-to-type-backup.sh > /etc/zabbix/zabbix_agentd.d/check-machines-to-type-backup.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-localstorage-status-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-localstorage-status-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/pbs-verify-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/pbs-verify-backup-discovery.sh
#curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/userparameters_pveapi_scripts.conf > /etc/zabbix/zabbix_agentd.d/userparameters_pveapi_scripts.conf
#chmod +x /etc/zabbix/zabbix_agentd.d/*.sh
#sleep 3
#systemctl restart zabbix-agent
