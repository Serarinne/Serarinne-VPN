#!/bin/bash
clear
SERVER_UPTIME="$(uptime -p | cut -d " " -f 2-10)"
CPU_USAGE=$(printf '%-3s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
RAM_USAGE="$(free -m | awk 'NR==2 {print $3}') MB / $(free -m | awk 'NR==2 {print $2}') MB"
SERVICE_STATUS="$(systemctl is-active --quiet nginx && echo "NGINX") $(systemctl is-active --quiet xray && echo "- XRAY") $(systemctl is-active --quiet panelbot && echo "- BOT")"
TOTAL_USER=$(grep -c -E "^# $user" "/root/serarinne/xray/config.json")
TODAY_USAGE=$(vnstat -d --oneline | awk -F\; '{print $6}' | sed 's/ //')
MONTH_USAGE=$(vnstat -m --oneline | awk -F\; '{print $11}' | sed 's/ //')

clear
echo ""
echo -e "————————————————————————————————————————————————————————"
echo -e "                     Control Panel                      "
echo -e "————————————————————————————————————————————————————————"
echo -e "  Server Name  :  $(cat /root/serarinne/name)  "
echo -e "  Domain       :  $(cat /root/serarinne/domain)  "
echo -e "  IP           :  $(cat /root/serarinne/ip)  "
echo -e "  Uptime       :  $SERVER_UPTIME  "
echo -e "  CPU Usage    :  $CPU_USAGE  "
echo -e "  RAM Usage    :  $RAM_USAGE  "
echo -e "  Service      :  $SERVICE_STATUS"
echo -e "————————————————————————————————————————————————————————"
echo -e "                  Total User : ${TOTAL_USER}             "
echo -e "————————————————————————————————————————————————————————"
echo -e "  1   Add User                4   Check Login"
echo -e "  2   Delete User             5   Check User Bandwidth"
echo -e "  3   Extend User"
echo -e ""
echo -e "  6   Change Domain           8   Check System Bandwith"
echo -e "  7   Renew Certificate       9   Restart Service"
echo -e ""
echo -e "  10  Backup                  12  Update XRay Core"
echo -e "  11  Restore                 13  Reboot Server"
echo -e "————————————————————————————————————————————————————————"
echo -e "  Today's Usage        : $TODAY_USAGE "
echo -e "  This Month's Usage   : $MONTH_USAGE "
echo -e "————————————————————————————————————————————————————————"
echo ""
read -p "  Select From Options [1-13] : " options
case $options in
1) add-user;;
2) delete-user;;
3) extend-user;;
4) check-user-config;;
5) user-bandwidth;;
6) change-domain;;
7) renew-cert;;
8) system-bandwidth;;
9) restart-service;;
10) backup-server;;
11) restore-server;;
12) clear; bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata;;
13) reboot;;
*) clear; menu;;
esac
