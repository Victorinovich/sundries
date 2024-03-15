#!/bin/bash

URL=$1

check_access=`curl --connect-timeout 10 -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes`
if [[ "$check_access" ]]
then

rand=$(($RANDOM % 1000 + 1))
echo -n > /tmp/$rand.txt
node=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes | jq -jr '.data[] | .node,"\n"' | head -n1`
string_stor=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"\n"' | grep -v "pbs-"`
arr1=($(echo $string_stor | tr " " "\n" | sort -u))
  for storage in ${arr1[*]}
  do
  summ_last_backups=0
  summ_first_backups=0
  string_vmid=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"=",.enabled,"=",.vmid,"=","\n"' | grep $storage | grep -v $storage=0 | sed -r "s/(${storage}|==[^=]*=|=1=|=)//g" | sed "s/,/ /g" `
  storage_avail=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/status | jq -jr '.data | .avail,"\n"'`
  arr2=($(echo $string_vmid))
     for vmid in ${arr2[*]}
     do
     size_last_backup=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/content | jq -Sjr '.data[] | .vmid," ",.volid," ",.size," ","'$storage'","\n"' | grep -e ^$vmid | tail -n1 | awk '{print $3}'`
     summ_last_backups=$((summ_last_backups+$size_last_backup))
     size_first_backup=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/content | jq -Sjr '.data[] | .vmid," ",.volid," ",.size," ","'$storage'","\n"' | grep -e ^$vmid | head -n1 | awk '{print $3}'`
     summ_first_backups=$((summ_first_backups+$size_first_backup)) 
     done
  echo $storage $storage_avail $summ_last_backups $summ_first_backups >> /tmp/$rand.txt
  done
cat /tmp/$rand.txt | sed '/^$/d' | jq -Rs 'split("\n") | map(split(" ")) | .[0:-1] | map( { "storage":.[0], "freespace":.[1], "sumlastbackups":.[2], "sumfirstbackups":.[3] } )'
rm -f /tmp/$rand.txt

else
echo "Data not received"
fi


