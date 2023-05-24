#!/bin/bash
mv /etc/postfix /etc/postfix.$(date "+%F--%H-%M-%S")
mkdir /etc/postfix
dpkg-reconfigure -f noninteractive postfix

echo "Введите имя для почтового поля FROM - отправителя, от которого будут отсылаться письма, допустима только латиница"
echo "Пример - PVE Server - battenfeld1 "
echo ""
echo -n ""
read name
chfn -f "$name" root

mymailname=$(cat /etc/mailname)

# Postfix on a null client
#cp /etc/postfix/main.cf /etc/postfix/main.cf.original
echo "myhostname=$mymailname
mydestination = 
relayhost =
inet_interfaces = loopback-only
recipient_canonical_maps = hash:/etc/postfix/recipient_canonical
smtp_header_checks = regexp:/etc/postfix/smtp_header_checks" > /etc/postfix/main.cf

echo "root alerts@ilogy.ru" > /etc/postfix/recipient_canonical
postmap /etc/postfix/recipient_canonical
echo "/^From: (.*)/ REPLACE From: $name <root@$mymailname>" > /etc/postfix/smtp_header_checks

systemctl restart postfix

sed -i 's/MAILADDR.*/MAILADDR root/' /etc/mdadm/mdadm.conf

echo "DEVICESCAN -m root -M test" > /etc/smartd.conf.test

#echo ""
#echo -n "Отправить тестовые письма? (y/n):  "
#read DANET
#if [[ $DANET == "y" || $DANET == "yes" ]]; then
    #echo "Test" | mail -s "Test" root
    mdadm --monitor --scan --test --oneshot
    smartd -c /etc/smartd.conf.test
    service smartd restart
    rm -f /etc/smartd.conf.test
    echo ""
    echo "Проверьте пришли ли тестовые письма от SMARTD, MDADM"
    echo ""
#fi
