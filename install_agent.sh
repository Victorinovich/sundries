#!/bin/bash

apt purge zabbix-agent zabbix-release -y

DISTR=`lsb_release -i  | awk '{print $3}'`
RELEASE=`lsb_release -r  | awk '{print $2}'`

if [[ $DISTR == "Debian" ]]
then

case "$RELEASE" in

"9")
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian9_all.deb
dpkg -i zabbix-release_6.0-1+debian9_all.deb
apt update
apt install zabbix-agent -y
;;

"10")
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian10_all.deb
dpkg -i zabbix-release_6.0-1+debian10_all.deb
apt update
apt install zabbix-agent -y
;;

"11")
wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb
dpkg -i zabbix-release_6.0-1+debian11_all.deb
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

sed -i "s/Server=127.0.0.1/Server=zabbix1.sys.ilogy.ru/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=zabbix1.sys.ilogy.ru:57799/" /etc/zabbix/zabbix_agentd.conf

echo ""
echo ""
echo  "Введите имя этого хоста для Zabbix сервера - не обязательно, чтобы оно совпадало с реальным хостнеймом"
read -p "Это имя используйте при создании узла сети в Zabbix сервере: "
echo ""
echo ""
sed -i "s/Hostname=Zabbix server/Hostname=${REPLY}/" /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent
systemctl enable zabbix-agent
