#!/bin/bash
clear
export SERVER_IP=$(wget -qO- ipv4.icanhazip.com)

echo -e "-----------------------------------------"
echo -e "|             Change Domain             |"
echo -e "-----------------------------------------"
echo ""
read -rp "New Domain: " SERVER_DOMAIN
rm -f /root/serarinne/ip
rm -f /root/serarinne/domain
echo $SERVER_DOMAIN > /root/serarinne/domain
echo $SERVER_IP > /root/serarinne/ip
clear
sleep 1
systemctl stop nginx
sleep 1
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $SERVER_DOMAIN --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $SERVER_DOMAIN --fullchainpath /root/serarinne/cert/certificate.crt --keypath /root/serarinne/cert/private.key --ecc
sleep 1
systemctl restart nginx
clear
menu