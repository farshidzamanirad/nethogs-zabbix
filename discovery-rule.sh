#!/bin/bash
app1=$(cat /home/zabbix/output.txt | grep -i "^\/" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $(NF-2); }'  | egrep -v "usr|bin|lib|local" | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}'  | sort -u)
app2=$(cat /home/zabbix/output.txt | grep -i "^[[:alpha:]]" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $1; }' | egrep -v "Adding|Ethernet" | sort -u)
app3=$(cat /home/zabbix/output.txt | egrep -i "^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" | awk 'NF>2 { if( $NF>0 || $(NF-1)>0) print $1;}' | egrep -v "^(Couldn | No)"| grep -v "Adding" | awk -F "-" '{ print $2; }' | awk -F "/" '{ print $1}' | egrep -v "^([0-9]+\.$ | [0-9]+$ | [0-9]+\.[0-9]+\.$ | [0-9]+\.[0-9]+\.[0-9]+\.$ | [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ | [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:$)"  | sort -u)
app4=$(cat /home/zabbix/output.txt | grep -i "^\/" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | grep -i ":$" | awk -F "/" '{ print $NF; }'  | egrep -v "usr|bin|lib|local" | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}'  | sort -u)
apps=$(echo $app1 $app2 $app3 $app4)
echo "{"
echo "\"data\":["
for app in $apps
do
    echo "    {\"{#APP}\":\"$app\"},"
done
echo "]"
echo "}"
