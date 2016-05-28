#!/bin/bash
app1=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^\/" | grep -iv "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $(NF-2); }' | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}'  | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|local|lib)" | sort -u)
app2=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^[[:alpha:]]" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $1; }' | egrep -v "Adding|Ethernet" | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|local|lib)" | awk -F ":" '{ print $1 }' | sort -u)
app3=$(cat /home/zabbix/zabbix_agent/output.txt | egrep -wi "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]+)" | awk 'NF>2 { if( $NF>0 || $(NF-1)>0) print $1;}' | egrep -v "^(Couldn | No)"| grep -v "Adding" | awk -F "-" '{ print $2; }' | awk -F "/" '{ print $1}' | egrep -iw "^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]{2,5})$" | sort -u)
app4=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^\/" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | grep -i ":$" | awk -F "/" '{ print $NF; }' | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}' | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|local|lib)" | sort -u)
#apps=$(echo $app1 $app2 $app4 $app3 | egrep -vwi "^[[:alpha:]]+[0-9]+\.[0-9]+")
l=$(echo $app1 $app2 $app4)
o=$(lsof  | awk '{ print $1}' | grep -v COMMAND | sort -u)
for q in $l; do
    for w in $o; do
        if [[ $q == $w ]];then
            array+=" $q "
        fi
    done
done
apps=$(echo $array $app3 | egrep -vwi "^[[:alpha:]]+[0-9]+\.[0-9]+")
#sum=0
#for h in apps; do
#    summ=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "$1" | grep -v "^Couldn*" | grep -v "^No*" | awk 'NF>2 { if($$(NF-1)>0) sum+=$$(NF-1);} END { print sum; }')
#    sum+=$summ
#done
#echo $sum
echo "{"
echo "\"data\":["
for app in $apps
do
f="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]{2,5}"
if [[ "$app" =~ $f ]];then
  z=`echo $app | awk -F ":" '{ print $2 }'`
  appservice=`sudo netstat -4tupln | awk -v i="\:${z}$" '{ if($4 ~ i) print $NF }'  2>/dev/null | awk -F "/" '{ print $2 }' | sort -u`
else
  appservice=$app
fi
if [[ -n $appservice ]];then
    echo "    {\"{#APP}\":\"$app\",\"{#APPSERVICE}\":\"$appservice($z)\"},"
else
    echo "    {\"{#APP}\":\"$app\",\"{#APPSERVICE}\":\"NotRecognized($z)\"},"
fi
done
echo "]"
echo "}"

