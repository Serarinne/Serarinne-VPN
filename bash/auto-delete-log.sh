#!/bin/bash
clear
VAR_LOG=(`find /var/log/ -name '*.log'`);
for log in "${VAR_LOG[@]}"
do
echo > $log
done
VPN_LOG=(`find /var/log/ -name '*.err'`);
for log in "${VPN_LOG[@]}"
do
echo > $log
done
echo > /var/log/syslog
echo > /var/log/btmp
echo > /var/log/messages
echo > /var/log/debug