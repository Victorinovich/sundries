#!/bin/bash

APITOKEN=$(cat /etc/zabbix/zabbix_agentd.d/token.txt)
URL=$1
PERIOD=$2

if [[ $PERIOD > 0 ]]
then
let "PERIOD = $(date +%s) - $PERIOD*24*3600"
fi

# проверка доступности API на случай неправильного URL и(или) токена
check_access=`curl --connect-timeout 10 -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes`
if [[ "$check_access" ]]
then

# случайное число от 1 до 1000 для генерации временного файла вывода, который в конце удаляется
rand=$(($RANDOM % 10000 + 1))
# если вдруг файл существует, то обнуляем его
echo -n > /tmp/$rand.txt

node=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes | jq -jr '.data[] | .node,"\n"' | head -n1`
pbsstorage=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"\n"' | grep "pbs-" | tr " " "\n" | sort -u`

# массив arr2 содержит все vmid с включёнными бэкапами
arr2=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"=",.enabled,"=",.vmid,"=","\n"' | grep $pbsstorage | grep -v $pbsstorage=0 | sed -r "s/(${pbsstorage}|==[^=]*=|=1=|=)//g" | sed "s/,/ /g")))
for vmid in ${arr2[*]}
do
  # массив arr3 содержит все ctime бэкапов для vmid
  arr3=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$pbsstorage/content | jq -Sjr '.data[] | .vmid," ",.ctime," ","\n"' | grep -e ^$vmid | awk '{print $2}')))
    i=0
    # считается количество бэкапов за PERIOD
    for ctime in ${arr3[*]}
    do
	if [[ $ctime > $PERIOD ]]
	then
	    let "i = $i+1"
	fi
    done
  echo $vmid $i >> /tmp/$rand.txt
done

# временный файл преобразуется в JSON и удаляется
cat /tmp/$rand.txt | sed '/^$/d' | jq -Rs 'split("\n") | map(split(" ")) | .[0:-1] | map( { "vmid":.[0], "sumbackups":.[1] } )'
rm -f /tmp/$rand.txt

else
echo "Data not received"
fi


