#!/bin/bash

#apt update
#echo "postfix postfix/mailname string $HOSTNAME.local" | debconf-set-selections
#echo "postfix postfix/main_mailer_type string 'Satellite system'" | debconf-set-selections
#apt install postfix mailutils -y
#dpkg-reconfigure postfix
echo "Введите имя для почтового поля FROM - отправителя, от которого будут отсылаться письма, допустима только латиница"
echo "Пример - PVE Server - battenfeld1 "
echo ""
echo -n "  "
read name
chfn -f "$name" root

# Postfix on a null client
cp /etc/postfix/main.cf /etc/postfix/main.cf.original
echo "myhostname=$(cat /etc/mailname)
mydestination = 
relayhost =
inet_interfaces = loopback-only
" > /etc/postfix/main.cf

systemctl reload postfix

sed -i 's/MAILADDR.*/MAILADDR root/' /etc/mdadm/mdadm.conf

echo ""
echo -n "Отправить тестовое письмо? (y/n):  "
read DANET
if [[ $DANET == "y" || $DANET == "yes" ]]; then
	echo ""
	echo -n "Введите e-mail:  "
	read ADDRESS
	echo ""
	echo "Test" | mail -s "Test" $ADDRESS
	echo ""
	echo "Письмо отправлено на $ADDRESS"
	echo ""
fi
