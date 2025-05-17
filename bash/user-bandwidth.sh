#!/bin/bash
clear
echo -e "-----------------------------------------"
echo -e "|          User Bandwidth Usage         |"
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
        local USER_UPLINK=$(xray api stats --server=$XRAY_PORT -name "user>>>${USER}>>>traffic>>>uplink" 2>/dev/null | jq '.stat.value')
        local USER_DOWNLINK=$(xray api stats --server=$XRAY_PORT -name "user>>>${USER}>>>traffic>>>downlink" 2>/dev/null | jq '.stat.value')

        if [[ $USER_UPLINK < 1 ]]; then
            local UPLOAD_USAGE=0
        else
            local UPLOAD_USAGE=${USER_UPLINK}
        fi

        if [[ $USER_DOWNLINK < 1 ]]; then
            local DOWNLOAD_USAGE=0
        else
            local DOWNLOAD_USAGE=${USER_DOWNLINK}
        fi

        echo $USER $UPLOAD_USAGE $DOWNLOAD_USAGE | numfmt --field=2 --suffix=B --to=iec | numfmt --field=3 --suffix=B --to=iec | awk '{ gsub(" ", "@") ; print $0 }'
    done
}

USERS_DATA=$(XRAY_DATA $1)
echo "USER@UPLOAD@DOWNLOAD ${USERS_DATA}" | tr ' ' '\n' | tr '@' ' ' | column -t
echo ""
read -p "$(echo -e "Back")"
menu