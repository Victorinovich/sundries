#!/bin/bash

echo ""
echo "Выберите свой дистрибутив"
select distr in  "Debian_9" "Ubuntu_20.04" "Lubuntu_16.04"
do
case $distr in
Debian_9 ) 
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix/zabbix-agent_6.0.7-1+debian9_amd64.deb
apt install ./zabbix-agent_6.0.7-1+debian9_amd64.deb
break
;;
Lubuntu_16.04 ) 
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix/zabbix-agent_6.0.7-1+ubuntu16.04_amd64.deb
apt install ./zabbix-agent_6.0.7-1+ubuntu16.04_amd64.deb
break
;;
Ubuntu_20.04 )
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix/zabbix-agent_6.0.7-1+ubuntu20.04_amd64.deb
apt install ./zabbix-agent_6.0.7-1+ubuntu20.04_amd64.deb
break
;;
esac
done

echo ""
echo ""
echo  "Введите имя этого хоста для Zabbix-агента - должно быть уникальным и не обязательно,"
echo  "чтобы оно совпадало с реальным именем хоста."
echo  "Оно будет использовано при"
read -p "создании узла в сервере Zabbix: "
echo ""
sed -i "s/Hostname=Zabbix server/Hostname=${REPLY}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=192.168.25.148/" /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent
rm -f zabbix-agent*.deb*
