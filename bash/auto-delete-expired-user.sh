#!/bin/bash
clear
XRAY_CONFIG=(`cat /root/serarinne/xray/config.json | grep '^# ' | cut -d ' ' -f 2 | sort | uniq`);
SERVER_DATE=`date +"%Y-%m-%d"`
for USER_NAME in "${XRAY_CONFIG[@]}"
do
    USER_DATE=$(grep -w "^# $USER_NAME" "/root/serarinne/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    EXPIRED_DATE=$(date -d "$USER_DATE" +%s)
    CURRENT_DATE=$(date -d "$SERVER_DATE" +%s)
    USER_EXPIRED=$(((EXPIRED_DATE - CURRENT_DATE) / 86400))

    if [[ "$USER_EXPIRED" -le "0" ]]; then
        sed -i "/^# $USER_NAME $USER_DATE/,/^},{/d" /root/serarinne/xray/config.json
        systemctl restart xray.service
    fi
done