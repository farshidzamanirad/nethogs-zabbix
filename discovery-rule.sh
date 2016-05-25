#!/bin/bash
app1=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^\/" | grep -vi "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $(NF-2); }' | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}'  | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|lib|local)" | sort -u)
app2=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^[[:alpha:]]" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | awk -F "/" '{ print $1; }' | egrep -v "Adding|Ethernet" | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|lib|local)" | awk -F ":" '{ print $1 }' | sort -u)
app3=$(cat /home/zabbix/zabbix_agent/output.txt | egrep -i "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]+)" | awk 'NF>2 { if( $NF>0 || $(NF-1)>0) print $1;}' | egrep -v "^(Couldn | No)"| grep -v "Adding" | awk -F "-" '{ print $2; }' | awk -F "/" '{ print $1}' | egrep -iw "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]{2,5})" | sort -u)
app4=$(cat /home/zabbix/zabbix_agent/output.txt | grep -i "^\/" | grep -v "^Couldn" | grep -v "^No" | awk 'NF>2 { if($NF>0 || $(NF-1)>0) print $1; }' | grep -i ":$" | awk -F "/" '{ print $NF; }' | grep -i "^[[:alpha:]]" | awk -F ":" '{ print $1}' | egrep -vi "(input|standard|Binary|matches|to|connection|usr|bin|local|lib)" | sort -u)
apps=$(echo $app1 $app2 $app3 $app4 | egrep -vi "^[[:alpha:]]+[0-9]+\.[0-9]+")
echo "{"
echo "\"data\":["
for app in $apps
do
f="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]{2,5}"
if [[ "$app" =~ $f ]];then
  z=`echo $app | awk -F ":" '{ print $2 }'`
  appservice=`sudo netstat -4tupln | awk -v i="\:${z}$" '{ if($4 ~ i) print $NF }' 2>/dev/null | awk -F "/" '{ print $2 }' | sort -u`
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
