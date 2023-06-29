#!/bin/bash

echo "#!/bin/bash

# Не забываем проверить (отредактировать) переменные, особенно INTERFACE

INTERFACE=ens18
SUBNET_OVPN=10.8.0.0/24
SUBNET_LOCAL=10.10.10.0/24
GATEWAY=10.10.10.1/32
PORT_OVPN=54541

# Обработка идёт сверху вниз
# Сначала зачищаем все цепочки и правила
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
# Запрещаем всё
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
# Разрешаем SSH к серверу, трафик на локальном интерфейсе и пинг
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# Пока непонятно, нужна ли эта строка, оставил на всякий случай, но без неё всё работает
#iptables -A INPUT -i tun+ -j ACCEPT

# Разрешаем клиентские подключения к OpenVPN серверу
iptables -A INPUT -i $INTERFACE -p udp --dport $PORT_OVPN -j ACCEPT
# Разрешаем входить только ответам на исходящие запросы
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#########################################################################################################################################
# Если комментируем 4 строки из следующего блока, то расскоментируем эти две
#iptables -I FORWARD 1 -i $INTERFACE -o tun0 -j ACCEPT
#iptables -I FORWARD 1 -i tun0 -o $INTERFACE -j ACCEPT

# Разрешаем доступ подсети OpenVPN к локальной подсети самого сервера, но запрещаем доступ к шлюзу по-умолчанию (в обе стороны)
# перекрываем таким образом доступ к интернету через VPN-сеть
# Можно закомментировать все 4 строки, если развёртываем VPN сервер специально для выхода в интернет
iptables -A FORWARD -s $SUBNET_OVPN -d $SUBNET_LOCAL -j ACCEPT
iptables -A FORWARD -s $SUBNET_OVPN -d $GATEWAY -j DROP
iptables -A FORWARD -s $SUBNET_LOCAL -d $SUBNET_OVPN -j ACCEPT
iptables -A FORWARD -s $GATEWAY -d $SUBNET_OVPN -j DROP
#########################################################################################################################################

# Запрещаем трафик между клиентами OpenVPN
iptables -A FORWARD -i tun+ -o tun+ -j DROP
# Выпускаем любой исходящий трафик наружу
iptables -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
# Делаем NAT-маскарадинг для подсети OpenVPN
iptables -t nat -A POSTROUTING -s $SUBNET_OVPN -o $INTERFACE -j MASQUERADE
" > /etc/iptables/iptables-config.sh

chmod +x /etc/iptables/iptables-config.sh

echo "pre-up /etc/iptables/iptables-rules.sh" >> /etc/network/interfaces


systemctl restart postfix

sed -i 's/MAILADDR.*/MAILADDR root/' /etc/mdadm/mdadm.conf

mdadm --monitor --scan --test --oneshot
echo "DEVICESCAN -m root -M test" > /etc/smartd.conf.test
smartd -c /etc/smartd.conf.test
service smartd restart
rm -f /etc/smartd.conf.test
echo ""
echo "Проверьте пришли ли тестовые письма от SMARTD, MDADM"
echo ""
