#!/bin/bash

echo 'UserParameter=fstab.mount.check.status, if test "$(findmnt -x 2>&1 | grep -E "no errors|0 errors")"; then echo "0"; else echo "1"; fi'  > /etc/zabbix/zabbix_agentd.d/userparameters_mount_check.conf
