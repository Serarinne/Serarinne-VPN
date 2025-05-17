#!/bin/bash
clear
SERVER_DOMAIN=$(cat /root/serarinne/domain)

echo -e "-----------------------------------------"
echo -e "|           Renew Certificate           |"
echo -e "-----------------------------------------"
echo ""
echo -e "Renewing certificate...." 
sleep 0.5
systemctl stop nginx
sleep 1
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $SERVER_DOMAIN --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $SERVER_DOMAIN --fullchainpath /root/serarinne/cert/certificate.crt --keypath /root/serarinne/cert/private.key --ecc
sleep 1
systemctl restart nginx
echo "Certificate has been updated"
echo ""
read -p "$(echo -e "Back")"
menu