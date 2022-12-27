#!/bin/bash

echo 'UserParameter=fstab.mount.check.status, if test "$(mount -a)"; then echo "1"; else echo "0"; fi'  > /etc/zabbix/zabbix_agentd.d/userparameters_mount_check.conf
