#!/bin/bash

systemctl stop zabbix-agent
apt purge zabbix-agent zabbix-release -y
rm -rf /etc/zabbix
DISTR=`lsb_release -i  | awk '{print $3}'`
RELEASE=`lsb_release -r  | awk '{print $2}' | cut -f '1' -d.`
   if [[ $DISTR == "Debian" ]]
   then
         case "$RELEASE" in
         "9")
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-3+debian9_all.deb
         dpkg -i zabbix-release_6.0-3+debian9_all.deb
         apt update
         apt install zabbix-agent -y
         ;;
         "10")
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-3+debian10_all.deb
         dpkg -i zabbix-release_6.0-3+debian10_all.deb
         apt update
         apt install zabbix-agent -y
         ;;
         "11")
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-3+debian11_all.deb
         dpkg -i zabbix-release_6.0-3+debian11_all.deb
         apt update
         apt install zabbix-agent -y
         ;;
         *) 
         echo "Дистрибутив не поддерживается"
         exit
         ;;
         esac
   else
     echo "Дистрибутив не поддерживается"
     exit
   fi

echo ""
echo ""
echo  "Введите имя этого хоста для Zabbix-агента - должно быть уникальным и не обязательно,"
echo  "чтобы оно совпадало с реальным именем хоста."
echo  "Оно будет использовано при"
read -p "создании узла в сервере Zabbix: "
echo ""
sed -i "s/Hostname=Zabbix server/Hostname=${REPLY}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=192.168.25.148/" /etc/zabbix/zabbix_agentd.conf
rm -f zabbix*.deb

echo "UserParameter=mdadm.status, egrep -c \"\[.*_.*\]\" /proc/mdstat" > /etc/zabbix/zabbix_agentd.d/userparameters_mdadm.conf
apt install smartmontools -y
chmod u+s /usr/sbin/smartctl
echo "UserParameter=storage.discovery[*], /usr/local/bin/smartctl-storage-discovery.sh
UserParameter=storage.get[*],if [ -n \"\$1\" ]; then /usr/sbin/smartctl -i -H -A -l error -l background \$1; fi
UserParameter=smartctl.version,/usr/sbin/smartctl --version | grep -Eo \"^smartctl\s[0-9\.[:space:]\r-]+\" | sed -e 's/^smartctl.//'" > /etc/zabbix/zabbix_agentd.d/userparameters_smartmontools.conf
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/smartctl-storage-discovery.sh > /usr/local/bin/smartctl-storage-discovery.sh
chmod +x /usr/local/bin/smartctl-storage-discovery.sh
systemctl restart zabbix-agent
