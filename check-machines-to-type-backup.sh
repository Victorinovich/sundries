#!/bin/bash

URL=$1
VMIDEXCLUDE=$2

# проверка доступности API на случай неправильного URL и(или) токена
check_access=`curl --connect-timeout 5 -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes`
if [[ "$check_access" ]]
then

# случайное число от 1 до 1000 для генерации временного файла вывода, который в конце удаляется
rndfile=$(($RANDOM % 10000 + 1))
# если вдруг файл существует, то обнуляем его
echo -n > /tmp/$rndfile.txt

# В массив arr1 выгружаем все типы настроенных в хранилище бэкапов, кроме stop (т.е. suspend, snapshot, ...)
arr1=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .mode,"=","\n"' | grep -v stop | sed "s/=/ /g" | sort -u)))
#echo ${arr1[@]}
# В массив arr2 выводим VMID, у которых типы бэкапов НЕ "stop"
for type in ${arr1[*]}; do
arr2=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .mode,"=",.vmid,"=","\n"' | grep $type | sed -r "s/(${type}|==[^=]*=|=1=|=)//g" | sed "s/,/ /g" ) | tr " " "\n" | sort -u))
done
# В массив arr3 выводим VMID, у которых типы бэкапов "stop"
arr3=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .mode,"=",.vmid,"=","\n"' | grep stop | sed -r "s/(stop|==[^=]*=|=1=|=)//g" | sed "s/,/ /g" ) | tr " " "\n" | sort -u))
# В массив arr4 помещаем исключённые макросом VMID (т.е. виртуалки, которые работают только в режиме snapshot, suspend вообще не используем)
arr4=($(echo $VMIDEXCLUDE | sed "s/,/ /g" | sort -u))

# для каждого VMID с бэкапами НЕ в stop-режиме проверяется присутствие этого же ID в списке VMID с бэкапами в stop-режиме 
for (( i=0; $i<=${#arr2[*]}; i=$i+1 )); do
vmid=`echo ${arr3[@]} | grep "${arr2[$i]}"`
vmidexcl=`echo ${arr4[@]} | grep "${arr2[$i]}"`
if [[ -z "$vmid" && -z "$vmidexcl" ]]; then
    echo ${arr2[$i]} >> /tmp/$rndfile.txt
fi
done

# временный файл преобразовываем в JSON и удаляем
cat /tmp/$rndfile.txt | sed '/^$/d' | jq -Rs 'split("\n") | map(split(" ")) | .[0:-1] | map( { "vmid":.[0] } )'
rm -f /tmp/$rndfile.txt

else
echo "Data not received"
fi
