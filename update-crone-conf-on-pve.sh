#!/bin/bash

rm -f  /etc/zabbix/zabbix_agentd.d/*.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-backup-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-running-machines-to-enable-backup.sh > /etc/zabbix/zabbix_agentd.d/check-running-machines-to-enable-backup.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/check-machines-to-type-backup.sh > /etc/zabbix/zabbix_agentd.d/check-machines-to-type-backup.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/proxmox-localstorage-status-discovery.sh > /etc/zabbix/zabbix_agentd.d/proxmox-localstorage-status-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/pbs-verify-backup-discovery.sh > /etc/zabbix/zabbix_agentd.d/pbs-verify-backup-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/quantity-of-backups-discovery.sh > /etc/zabbix/zabbix_agentd.d/quantity-of-backups-discovery.sh
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/userparameters_pveapi_scripts.conf > /etc/zabbix/zabbix_agentd.d/userparameters_pveapi_scripts.conf
chmod +x /etc/zabbix/zabbix_agentd.d/*.sh
systemctl restart zabbix-agent
