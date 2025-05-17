#!/bin/bash
clear
echo -e "-----------------------------------------"
echo -e "|               User Login              |"
echo -e "-----------------------------------------"
echo ""
XRAY_PORT=127.0.0.1:10085
XRAY_TAG="user-connection"

XRAY_DATA () {
    local USER_LIST=$(xray api inbounduser --server=$XRAY_PORT --tag=$XRAY_TAG | jq '.users[].email' | awk '{ gsub("\"", "") ; print $0 }')

    USER_NAME=($(awk -F' ' '{print $0}' <<< "$USER_LIST"))

    for USER in "${USER_NAME[@]}"
    do
        local USER_IP=$(xray api statsonlineiplist --server=127.0.0.1:10085 --email="${USER}" 2>/dev/null | jq '.ips' | awk '{ gsub("\"", "") ; print $0 }' | sed 's/[^a-zA-Z0-9.:]//g' | tr '\n' ' ')

        if [[ $USER_IP == *":"* ]]; then
            TOTAL_IP=$(echo "$USER_IP" | grep -o ':' | wc -l)
            ONLINE_STATUS="Online-${TOTAL_IP}"
        else
            ONLINE_STATUS="Offline-0"
        fi

        echo -e "${USER}-${ONLINE_STATUS}"
    done
}

LOGIN_DATA=$(XRAY_DATA $1)
echo "USER-STATUS-TOTAL ${LOGIN_DATA}" | tr ' ' '\n' | tr '-' ' ' | column -t
echo ""
read -p "$(echo -e "Back")"
menu