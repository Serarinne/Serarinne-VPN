#!/bin/bash
clear
SERVER_DOMAIN=$(cat /root/serarinne/domain)
SERVER_NAME=$(cat /root/serarinne/name)
SERVER_IP=$(cat /root/serarinne/ip)

echo -e "-----------------------------------------"
echo -e "|                Add User               |"
echo -e "-----------------------------------------"
until [[ $USER_NAME =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
    read -rp "Username : " -e USER_NAME
    CLIENT_EXISTS=$(grep -w $USER_NAME /root/serarinne/xray/config.json | wc -l)
    
    if [[ ${CLIENT_EXISTS} == '1' ]]; then
        clear
        echo ""
        echo "Username already used"
        echo ""
        read -n 1 -s -r -p "Back"
        menu
    fi
done

ACTIVE_PERIOD=30
USER_ID=$(cat /proc/sys/kernel/random/uuid)
USER_DATE=`date -d "$ACTIVE_PERIOD days" +"%Y-%m-%d"`
sed -i '/#USER-ACCOUNT$/a\# '"$USER_NAME $USER_DATE"'\
,{"password": "'""$USER_ID""'","level": '"0"',"email": "'""$USER_NAME""'"}' /root/serarinne/xray/config.json

ACCOUNT_URL="trojan://${USER_ID}@${SERVER_DOMAIN}:80?type=ws&host=${SERVER_DOMAIN}&headerType=none&path=%252Ftrojan&security=none#${SERVER_NAME} ${USER_NAME} ${USER_DATE}"
systemctl restart xray.service
service cron restart

clear
echo -e ""
echo -e "Remarks           : ${USER_NAME}"
echo -e "Domain            : ${SERVER_DOMAIN}"
echo -e "IP/Host           : ${SERVER_IP}"
echo -e "Port TLS          : 443"
echo -e "Port None TLS     : 80"
echo -e "ID                : ${USER_ID}"
echo -e "AlterId           : 0"
echo -e "Security          : Auto"
echo -e "Network           : WS"
echo -e "Path              : /trojan"
echo -e "═══════════════════"
echo -e "URL               : ${ACCOUNT_URL}"
echo -e "═══════════════════"
echo -e "Expired Date      : ${USER_DATE}"
echo -e "═══════════════════"
echo -e ""
read -p "$(echo -e "Back")"
menu