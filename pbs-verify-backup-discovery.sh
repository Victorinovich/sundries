#!/bin/bash

APITOKEN=$(cat /etc/zabbix/zabbix_agentd.d/token.txt)
URL=$1
NUMOFBACKUPS=$2

check_access=`curl --connect-timeout 10 -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes`
if [[ "$check_access" && "$NUMOFBACKUPS" =~ ^[0-9]+$ ]]
then

node=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes | jq -jr '.data[] | .node,"\n"' | head -n1`
storage=`curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/cluster/backup | jq -jr '.data[] | .storage,"\n"' | grep -m1 "pbs-"`

  if [[ $NUMOFBACKUPS == 0 ]]
  then 
  curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/content/ | jq -S '[.data[] | select(.verification)] | sort_by(.ctime)'
  else
  curl -s -k -H "Authorization: PVEAPIToken=$APITOKEN" $URL/api2/json/nodes/$node/storage/$storage/content/ | jq -S '[.data[] | select(.verification)] | sort_by(.ctime) | .[length-'$NUMOFBACKUPS':length+1]'
  fi

else
echo "Data not received"
fi





