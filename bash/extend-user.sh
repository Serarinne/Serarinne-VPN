#!/bin/bash
clear
echo -e "-----------------------------------------"
echo -e "|              Extend User              |"
echo -e "-----------------------------------------"
echo ""
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi
XRAY_PORT=127.0.0.1:10085
XRAY_TAG="user-connection"

XRAY_DATA () {
    local USER_LIST=$(xray api inbounduser --server=$XRAY_PORT --tag=$XRAY_TAG | jq '.users[].email' | awk '{ gsub("\"", "") ; print $0 }')

    USER_NAME=($(awk -F' ' '{print $0}' <<< "$USER_LIST"))

    for USER in "${USER_NAME[@]}"
    do
        local USER_DATA=$(grep -E "^# ${USER} " "/root/serarinne/xray/config.json" | cut -d '' -f 2-3)
        echo $USER_DATA | awk '{ gsub("# ", "") ; print $0 }' | awk '{ gsub(" ", "@") ; print $0 }'
    done
}

USERS_DATA=$(XRAY_DATA $1)
echo "USER@EXP ${USERS_DATA}" | tr ' ' '\n' | tr '@' ' ' | column -t
echo ""
read -rp "Username [0 for back]: " USER_NAME
if [[ $USER_NAME == 0 ]]; then
    menu
else
    read -rp "Extend until [YYYY-MM-DD]: " NEW_DATE
    sed -i "s/# $USER_NAME .*$/# $USER_NAME $NEW_DATE/g" /root/serarinne/xray/config.json
    read -p "$(echo -e "Back")"
    systemctl restart xray.service
    service cron restart
    extend-user
fi