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

# В массив arr0 выгружаем все ноды
arr0=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes | jq -jr '.data[] | .node,"\n"')))
for node in ${arr0[*]}
do
# В массив arr1 выгружаем все VMID и их статусы - включена или выключена (число текст через пробел)
arr1=(${arr1[@]} $(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/qemu | jq -Sjr '.data[] | .vmid," ",.status,"\n"' | sort -u)))
done
#echo ${arr1[@]}

# В массив arr2 выводим VMID, у которых бэкапы включены
arr2=($(echo $(curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .enabled,"=",.vmid,"=","\n"' | sed -r "s/(${storage}|==[^=]*=|=1=|=)//g" | sed "s/,/ /g") | tr " " "\n" | sort -u))

# В массив arr3 помещаем исключённые макросом VMID (т.е. виртуалки, которые работают, но для которых не нужен обязательный бэкап)
arr3=($(echo $VMIDEXCLUDE | sed "s/,/ /g" | sort -u))

# прогоняем и фильтруем список всех VMID (чётные элементы массива 0, 2, 4, 6, ...) из массива arr1 
for (( i=0; $i<=${#arr1[*]}; i=$i+2 )); do
# грепаем список ID виртуалок с включёнными бэкапами на предмет попадания туда VM из общего списка arr1 
vmid=`echo ${arr2[@]} | grep "${arr1[$i]}"`
# грепаем список ID исключённых виртуалок на предмет попадания туда VM из общего списка arr1 
vmidexcl=`echo ${arr3[@]} | grep "${arr1[$i]}"`
# выводим во временный файл только VMID - (которые в статусе "running") И (бэкапы у которых ещё не включены) И (которые не добавлены в исключения)
 if [[ ${arr1[$i+1]} == "running" && -z "$vmid" && -z "$vmidexcl" ]]; then
   echo ${arr1[$i]} >> /tmp/$rndfile.txt
 fi
done

# временный файл преобразовываем в JSON и удаляем
cat /tmp/$rndfile.txt | jq -Rs 'split("\n") | map(split(" ")) | .[0:-1] | map( { "vmid":.[0] } )'
rm -f /tmp/$rndfile.txt

else
echo "Data not received"
fi
