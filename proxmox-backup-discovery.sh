#!/bin/bash

URL=$1

# проверка доступности API на случай неправильного URL и(или) токена
check_access=`curl --connect-timeout 10 -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes`
if [[ "$check_access" ]]
then
# случайное число от 1 до 1000 для генерации временного файла вывода, который в конце удаляется
rand=$(($RANDOM % 10000 + 1))
# если вдруг файл существует, то обнуляем его
echo -n > /tmp/$rand.txt
node=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes | jq -jr '.data[] | .node,"\n"' | head -n1`
# в переменную ниже выводим список всех хранилищ из расписания бэкапов
string_stor=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"\n"'`
# список хранилищ фильтруем на дубликаты, отсеиваем их, всё это заносим в массив arr1
arr1=($(echo $string_stor | tr " " "\n" | sort -u))
 for storage in ${arr1[*]}
 do
  # вводим свою переменную для обозначения типа хранилища - необходимо для триггеров в Zabbix
  type=$(echo $storage | grep -e "pbs-")
  if [[ "$type" ]]
  then
    type=PBS
  else
    type=LOCAL
  fi
  # в переменную последовательно через пробел попадают ID виртуалок, где бэкапы не отключены, которые затем передаются в массив arr2
  string_vmid=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"=",.enabled,"=",.vmid,"=","\n"' | grep $storage | grep -v $storage=0 | sed -r "s/(${storage}|==[^=]*=|=1=|=)//g" | sed "s/,/ /g" `
  arr2=($(echo $string_vmid))
   for vmid in ${arr2[*]}
   do
   # переменная ниже содержит через пробел id виртуальной машины, id бэкапа, время его создания, имя хранилище и его тип - PBS или LOCAL
   tempout=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/content | jq -Sjr '.data[] | .vmid," ",.volid," ",.ctime," ","'$storage'"," ","'$type'","\n"' | grep -e ^$vmid | tail -n1`
   # проверяем переменную на пустоту, такое может быть, если в расписании бэкап задан, а в хранилище его нет
     if [[ "$tempout" ]]
      then
       # если вывод не пуст, то строка "vmid volid ctime storage type" выгружается во временный файл для последующего преобразовния в JSON (для Zabbix JSONPath)
       echo $tempout >> /tmp/$rand.txt
      else
       # если вывод пустой, то в качестве volid и ctime ставятся "none", чтобы в Zabbix можно было определённо сконструировать триггер на отсутствие этого бэкапа в хранилище
       echo "$vmid none none $storage $type" >> /tmp/$rand.txt
      fi
   done
 done
# временный файл преобразуется в JSON и удаляется
cat /tmp/$rand.txt | sed '/^$/d' | jq -Rs 'split("\n") | map(split(" ")) | .[0:-1] | map( { "vmid":.[0], "volid":.[1], "ctime":.[2], "storage":.[3], "type":.[4] } )'
rm -f /tmp/$rand.txt

else
echo "Data not received"
fi



