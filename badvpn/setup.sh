#!/bin/bash
REPO="https://raw.githubusercontent.com/taibabi/anaksetan/master/"
wget -O /usr/sbin/badvpn "${REPO}badvpn/badvpn" >/dev/null 2>&1
chmod +x /usr/sbin/badvpn > /dev/null 2>&1
wget -q -O /etc/systemd/system/badvpn1.service "${REPO}badvpn/badvpn1.service" >/dev/null 2>&1
wget -q -O /etc/systemd/system/badvpn2.service "${REPO}badvpn/badvpn2.service" >/dev/null 2>&1
wget -q -O /etc/systemd/system/badvpn3.service "${REPO}badvpn/badvpn3.service" >/dev/null 2>&1

systemctl enable --now badvpn1 > /dev/null 2>&1
systemctl enable --now badvpn2 > /dev/null 2>&1
systemctl enable --now badvpn3 > /dev/null 2>&1
