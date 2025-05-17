#!/bin/bash
timedatectl set-timezone Asia/Jakarta
export SERVER_SCRIPT="https://raw.githubusercontent.com/Serarinne/Serarinne-VPN/main"
export SERVER_IP=$(wget -qO- ipv4.icanhazip.com)

clear
echo -e "-----------------------------------------"
echo -e "|             Setup Server              |"
echo -e "-----------------------------------------"
echo -e ""
read -rp "Server Name   : " SERVER_NAME
read -rp "Server Domain : " SERVER_DOMAIN
mkdir /root/serarinne
echo "" > /root/serarinne/name
echo "" > /root/serarinne/domain
echo "" >> /root/serarinne/ip
echo $SERVER_NAME > /root/serarinne/name
echo $SERVER_DOMAIN > /root/serarinne/domain
echo $SERVER_IP >> /root/serarinne/ip

clear
echo -e "-----------------------------------------"
echo -e "|           Instalasi Package           |"
echo -e "-----------------------------------------"
apt remove --purge ufw firewalld exim4 -y
apt install git curl wget nano lsof fail2ban netfilter-persistent bzip2 gzip coreutils rsyslog iftop htop zip unzip net-tools sed screen gnupg gnupg1 gnupg2 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch libsqlite3-dev socat python3 xz-utils dnsutils lsb-release cron bash-completion ntpdate chrony pwgen openssl netcat-traditional vnstat bsdmainutils -y

ntpdate pool.ntp.org
timedatectl set-ntp true
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
date

apt install nginx -y
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mkdir /root/serarinne/log
wget -O /etc/nginx/nginx.conf "${SERVER_SCRIPT}/nginx/nginx.conf"
wget -O /etc/nginx/conf.d/xray.conf "${SERVER_SCRIPT}/nginx/xray.conf"

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

mkdir /root/serarinne/cert
wget -O -  https://get.acme.sh | sh -s email=admin@seras.my.id
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d ${SERVER_DOMAIN} --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d ${SERVER_DOMAIN} --fullchainpath /root/serarinne/cert/certificate.crt --keypath /root/serarinne/cert/private.key --ecc

mkdir /root/serarinne/xray
wget -O /root/serarinne/xray/config.json "${SERVER_SCRIPT}/xray/config.json"

find "/etc/systemd/system/xray.service" -type f -exec sed -i "s/\/usr\/local\/etc\/xray\/config.json/\/root\/serarinne\/xray\/config.json/g" {} \;
find "/etc/systemd/system/xray.service" -type f -exec sed -i "s/nobody/root/g" {} \;
find "/etc/systemd/system/xray@.service" -type f -exec sed -i "s/\/usr\/local\/etc\/xray\/%i.json/\/root\/serarinne\/xray\/%i.json/g" {} \;
find "/etc/systemd/system/xray@.service" -type f -exec sed -i "s/nobody/root/g" {} \;
find "/etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf" -type f -exec sed -i "s/\/usr\/local\/etc\/xray\/config.json/\/root\/serarinne\/xray\/config.json/g" {} \;
find "/etc/systemd/system/xray@.service.d/10-donot_touch_single_conf.conf" -type f -exec sed -i "s/\/usr\/local\/etc\/xray\/%i.json/\/root\/serarinne\/xray\/%i.json/g" {} \;

systemctl daemon-reload
systemctl restart xray.service
systemctl restart xray@.service
systemctl restart nginx
systemctl restart vnstat

clear
echo -e "-----------------------------------------"
echo -e "|            Instalasi Addon            |"
echo -e "-----------------------------------------"
wget -O /usr/bin/add-user "${SERVER_SCRIPT}/bash/add-user.sh" && chmod +x /usr/bin/add-user
wget -O /usr/bin/auto-delete-expired-user "${SERVER_SCRIPT}/bash/auto-delete-expired-user.sh" && chmod +x /usr/bin/auto-delete-expired-user
wget -O /usr/bin/auto-delete-log "${SERVER_SCRIPT}/bash/auto-delete-log.sh" && chmod +x /usr/bin/auto-delete-log
wget -O /usr/bin/backup-server "${SERVER_SCRIPT}/bash/backup-server.sh" && chmod +x /usr/bin/backup-server
wget -O /usr/bin/change-domain "${SERVER_SCRIPT}/bash/change-domain.sh" && chmod +x /usr/bin/change-domain
wget -O /usr/bin/delete-user "${SERVER_SCRIPT}/bash/delete-user.sh" && chmod +x /usr/bin/delete-user
wget -O /usr/bin/extend-user "${SERVER_SCRIPT}/bash/extend-user.sh" && chmod +x /usr/bin/extend-user
wget -O /usr/bin/renew-cert "${SERVER_SCRIPT}/bash/renew-cert.sh" && chmod +x /usr/bin/renew-cert
wget -O /usr/bin/restart-service "${SERVER_SCRIPT}/bash/restart-service.sh" && chmod +x /usr/bin/restart-service
wget -O /usr/bin/restore-server "${SERVER_SCRIPT}/bash/restore-server.sh" && chmod +x /usr/bin/restore-server
wget -O /usr/bin/system-bandwidth "${SERVER_SCRIPT}/bash/system-bandwidth.sh" && chmod +x /usr/bin/system-bandwidth
wget -O /usr/bin/user-bandwidth "${SERVER_SCRIPT}/bash/user-bandwidth.sh" && chmod +x /usr/bin/user-bandwidth
wget -O /usr/bin/menu "${SERVER_SCRIPT}/bash/menu.sh" && chmod +x /usr/bin/menu

echo "0 2 * * * root auto-delete-expired-user" >> /etc/crontab
echo "0 3 * * * root backup-server" >> /etc/crontab
echo "0 */2 * * * root auto-delete-log" >> /etc/crontab

apt autoclean -y
echo "menu" >> /root/.profile
rm /root/install.sh
reboot
