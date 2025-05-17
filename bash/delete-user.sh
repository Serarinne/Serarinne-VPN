#!/bin/bash
clear
TOTAL_USER=$(grep -c -E "^# " "/root/serarinne/xray/config.json")
if [[ ${TOTAL_USER} == '0' ]]; then
	echo ""
	echo "No user"
	echo ""
	exit 1
fi

echo -e "-----------------------------------------"
echo -e "|              Delete User              |"
echo -e "-----------------------------------------"
echo ""
echo "     No  User    Expired"
grep -E "^# " "/root/serarinne/xray/config.json" | cut -d ' ' -f 2-3 | nl -s '. '
until [[ ${USER_NUMBER} -ge 1 && ${USER_NUMBER} -le ${TOTAL_USER} ]]; do
	if [[ ${USER_NUMBER} == '1' ]]; then
		read -rp "User number [1]: " USER_NUMBER
	else
		read -rp "User number [1-${TOTAL_USER}]: " USER_NUMBER
	fi
done

USER_NAME=$(grep -E "^# " "/root/serarinne/xray/config.json" | cut -d ' ' -f 2 | sed -n "${USER_NUMBER}"p)
USER_DATE=$(grep -E "^# " "/root/serarinne/xray/config.json" | cut -d ' ' -f 3 | sed -n "${USER_NUMBER}"p)
sed -i "/^# $USER_NAME $USER_DATE/,/^,{/d" /root/serarinne/xray/config.json
systemctl restart xray.service
clear
echo -e ""
echo "$USER_NAME has been deleted"
echo ""
read -p "$(echo -e "Back")"
menu