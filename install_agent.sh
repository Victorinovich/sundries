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
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian9_all.deb
         dpkg -i zabbix-release_6.0-4+debian9_all.deb
         apt update
         apt install zabbix-agent -y
         ;;
         "10")
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian10_all.deb
         dpkg -i zabbix-release_6.0-4+debian10_all.deb
         apt update
         apt install zabbix-agent -y
         ;;
         "11")
         wget http://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian11_all.deb
         dpkg -i zabbix-release_6.0-4+debian11_all.deb
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
echo "Сервер находится во внутренней сети Ilogy или это внешний сервер?"
select yn in "Internal" "External"
do
case $yn in
Internal ) 
sed -i "s/Server=127.0.0.1/Server=10.10.10.242/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=10.10.10.242:10051/" /etc/zabbix/zabbix_agentd.conf
break
;;
External ) 
sed -i "s/Server=127.0.0.1/Server=zabbix1.sys.ilogy.ru/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=zabbix1.sys.ilogy.ru:57799/" /etc/zabbix/zabbix_agentd.conf
break
;;
esac
done

echo ""
echo  "Введите имя этого хоста для Zabbix сервера - не обязательно, чтобы оно совпадало с реальным хостнеймом"
read -p "Это имя используйте при создании узла сети в Zabbix сервере: "
echo ""
sed -i "s/Hostname=Zabbix server/Hostname=${REPLY}/" /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent
systemctl enable zabbix-agent
rm -f zabbix-release*.deb*

echo ""
echo "Сервер виртуальный или реальный (дополнительно установится конфигурация для SMART и MDMADM)?"
select yn in "Virt" "Real"
do
case $yn in
Virt ) 
break
;;
Real ) 
echo "UserParameter=mdadm.status, egrep -c \"\[.*_.*\]\" /proc/mdstat" > /etc/zabbix/zabbix_agentd.conf.d/userparameters_mdadm.conf
apt install smartmontools -y
chmod u+s /usr/sbin/smartctl
echo "UserParameter=storage.discovery[*], /usr/local/bin/smartctl-storage-discovery.sh
UserParameter=storage.get[*],if [ -n \"\$1\" ]; then /usr/sbin/smartctl -i -H -A -l error -l background \$1; fi
UserParameter=smartctl.version,/usr/sbin/smartctl --version | grep -Eo \"^smartctl\s[0-9\.[:space:]\r-]+\" | sed -e 's/^smartctl.//'" > /etc/zabbix/zabbix_agentd.conf.d/userparameters_smartmontools.conf
curl -Ls https://raw.githubusercontent.com/Victorinovich/sundries/main/smartctl-storage-discovery.sh > /usr/local/bin/smartctl-storage-discovery.sh
chmod +x /usr/local/bin/smartctl-storage-discovery.sh
break
;;
esac
done
sleep 3
systemctl restart zabbix-agent
