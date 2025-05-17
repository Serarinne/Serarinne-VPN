#!/bin/bash
clear
echo -e "-----------------------------------------"
echo -e "|            Restore Service            |"
echo -e "-----------------------------------------"
echo ""
read -rp "URL Backup: " -e FILE_URL
wget -O /root/backup.zip "$FILE_URL"
unzip /root/backup.zip
sleep 1
echo -e "Restoring...."
cp -r /root/backup/* /root >/dev/null 2>&1
rm -rf /root/backup
rm -f /root/backup.zip
echo ""
echo -e "Restarting Service..."
systemctl restart nginx.service
systemctl restart xray.service
systemctl restart cron.service
echo ""
read -p "$(echo -e "Back")"
menu