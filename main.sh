#!/bin/bash

### Color
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'

### System Information
TANGGAL=$(date '+%Y-%m-%d')
TIMES="10"
NAMES=$(whoami)
IMP="wget -q -O"    
CHATID="1036440597"
LOCAL_DATE="/usr/bin/"
MYIP=$(wget -qO- ipinfo.io/ip)
ISP=$(wget -qO- ipinfo.io/org)
CITY=$(curl -s ipinfo.io/city)
TIME=$(date +'%Y-%m-%d %H:%M:%S')
RAMMS=$(free -m | awk 'NR==2 {print $2}')
KEY="2145515560:AAE9WqfxZzQC-FYF1VUprICGNomVfv6OdTU"
URL="https://api.telegram.org/bot$KEY/sendMessage"
REPO="https://raw.githubusercontent.com/taibabi/anaksetan/master/"
APT="apt-get -y install "
domain=$(cat /root/domain)
start=$(date +%s)
secs_to_human() {
    echo "Installation time : $((${1} / 3600)) hours $(((${1} / 60) % 60)) minute's $((${1} % 60)) seconds"
}
### Status
function print_ok() {
    echo -e "${OK} ${BLUE} $1 ${FONT}"
}
function print_install() {
	echo -e "${YELLOW} ============================================ ${FONT}"
    echo -e "${YELLOW} # $1 ${FONT}"
	echo -e "${YELLOW} ============================================ ${FONT}"
    sleep 1
}

function print_error() {
    echo -e "${ERROR} ${REDBG} $1 ${FONT}"
}

function print_success() {
    if [[ 0 -eq $? ]]; then
		echo -e "${Green} ============================================ ${FONT}"
        echo -e "${Green} # $1 berhasil dipasang"
		echo -e "${Green} ============================================ ${FONT}"
        sleep 2
    fi
}

### Cek root
function is_root() {
    if [[ 0 == "$UID" ]]; then
        print_ok "Root user Start installation process"
    else
        print_error "The current user is not the root user, please switch to the root user and run the script again"
    fi

}

### Change Environment System
function first_setup(){
    echo 'set +o history' >> /etc/profile
    timedatectl set-timezone Asia/Jakarta
    wget -O /etc/banner ${REPO}config/banner >/dev/null 2>&1
    chmod +x /etc/banner
    wget -O /etc/ssh/sshd_config ${REPO}config/sshd_config >/dev/null 2>&1
    wget -q -O /etc/ipserver "${REPO}server/ipserver" && bash /etc/ipserver >/dev/null 2>&1
    chmod 644 /etc/ssh/sshd_config
    useradd -M cendrawasih
    usermod -aG sudo,cendrawasih cendrawasih 

    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
}


### Update and remove packages
function base_package() {
    sudo apt autoremove git man-db apache2 ufw exim4 firewalld snapd* apparmor -y;
    clear
    print_install "Memasang paket yang dibutuhkan"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1  >/dev/null 2>&1
    # sudo apt install  -y
    curl -sSL https://deb.nodesource.com/setup_16.x | bash - >/dev/null 2>&1
    sudo apt update 

    # linux-tools-common util-linux build-essential dirmngr libxml-parser-perl \
    # lsb-release software-properties-common coreutils rsyslog \

    sudo apt install  squid3 nginx zip pwgen netcat bash-completion \
    curl socat xz-utils wget apt-transport-https dnsutils screen chrony \
    tar wget ruby zip unzip p7zip-full python3-pip libc6  gnupg gnupg2 gnupg1  \
    msmtp-mta ca-certificates bsd-mailx iptables iptables-persistent netfilter-persistent \
    iftop bzip2 gzip lsof bc htop sed openssl wireguard-tools \
    tmux python2.7 stunnel4 vnstat nodejs libsqlite3-dev cron wondershaper \
    net-tools  jq openvpn easy-rsa python3-certbot-nginx p7zip-full tuned fail2ban -y
    apt-get clean all; sudo apt-get autoremove -y
    print_ok "Berhasil memasang paket yang dibutuhkan"
}
clear

### Buat direktori xray
function dir_xray() {
    print_install "Membuat direktori xray"
    mkdir -p /etc/{xray,vmess,websocket,vless,trojan,shadowsocks}
    mkdir -p /var/log/xray/
    mkdir -p /etc/cendrawasih/public_html
    touch /var/log/xray/{access.log,error.log}
    chmod 777 /var/log/xray/*.log
    touch /etc/vmess/.vmess.db
    touch /etc/vless/.vless.db
    touch /etc/trojan/.trojan.db
    touch /etc/ssh/.ssh.db
    touch /etc/shadowsocks/.shadowsocks.db
    clear
}

### Tambah domain
function add_domain() {
    echo "`cat /etc/banner`"
    read -rp "Input Your Domain For This Server :" -e SUB_DOMAIN
    echo "Host : $SUB_DOMAIN"
    echo $SUB_DOMAIN > /root/domain
    cp /root/domain /etc/xray/domain
}

### Pasang SSL
function pasang_ssl() {
    print_install "Memasang SSL pada domain"
    domain=$(cat /root/domain)
    STOPWEBSERVER=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
    rm -rf /root/.acme.sh
    mkdir /root/.acme.sh
    systemctl stop $STOPWEBSERVER
    systemctl stop nginx
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    chmod 777 /etc/xray/xray.key
    print_success "SSL Certificate"
}

### Mendukung websocket
function install_websocket(){
    wget -O /usr/sbin/ws "${REPO}websocket/ws" >/dev/null 2>&1
    wget -O /usr/sbin/ws-dropbear "${REPO}websocket/ws-dropbear" >/dev/null 2>&1
    wget -O /usr/sbin/ws-ovpn "${REPO}websocket/ws-ovpn" >/dev/null 2>&1

    wget -O /etc/systemd/system/ws.service "${REPO}websocket/ws.service" >/dev/null 2>&1
    wget -O /etc/systemd/system/ws-dropbear.service "${REPO}websocket/ws-dropbear.service" >/dev/null 2>&1
    wget -O /etc/systemd/system/ws-ovpn.service "${REPO}websocket/ws-ovpn.service" >/dev/null 2>&1

    chmod 644 /etc/systemd/system/ws.service
    chmod 644 /etc/systemd/system/ws-*.service

}

### Install Xray
function install_xray(){
    domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
    chown cendrawasih.cendrawasih $domainSock_dir
    chown cendrawasih.cendrawasih /var/log/xray
    print_install "Memasang modul Xray terbaru"
    curl -s ipinfo.io/city >> /etc/xray/city
    curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /etc/xray/isp
    xray_latest="$(curl -s https://api.github.com/repos/dharak36/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
    xraycore_link="https://github.com/dharak36/Xray-core/releases/download/v$xray_latest/xray.linux.64bit"
    curl -sL "$xraycore_link" -o xray
    mv xray /usr/sbin/xray
    print_success "Xray Core"
    
    wget -O /etc/xray/config.json "${REPO}xray/config.json" >/dev/null 2>&1 

    # > Set Permission
    chmod +x /usr/sbin/xray

    # > Create Service
    cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=cendrawasih
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/sbin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
print_success "Xray C0re"
}

# function wireguard(){
    # mkdir /etc/wireguard >/dev/null 2>&1
#     chmod 600 -R /etc/wireguard/
#     SERVER_PRIV_KEY=$(wg genkey)
#     SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)
#     # Save WireGuard settings
#     echo "SERVER_PUB_NIC=$SERVER_PUB_NIC
#     SERVER_WG_NIC=wg0
#     SERVER_WG_IPV4=10.66.66.1
#     SERVER_PORT=7070
#     SERVER_PRIV_KEY=$SERVER_PRIV_KEY
#     SERVER_PUB_KEY=$SERVER_PUB_KEY" >/etc/wireguard/params

#     source /etc/wireguard/params
#     echo "[Interface]
#     Address = $SERVER_WG_IPV4/24
#     ListenPort = $SERVER_PORT
#     PrivateKey = $SERVER_PRIV_KEY
#     PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE;
#     PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE;" >>"/etc/wireguard/wg0.conf"
# }

### Pasang OpenVPN
function install_ovpn(){
    print_install "Memasang modul Openvpn"
    source <(curl -sL ${REPO}openvpn/openvpn)
    wget -O /etc/pam.d/common-password "${REPO}openvpn/common-password" >/dev/null 2>&1
    chmod +x /etc/pam.d/common-password

    # > BadVPN
    source <(curl -sL ${REPO}badvpn/setup.sh)
    print_success "OpenVPN"

    # > OHP
    wget -O /usr/sbin/ohp "${REPO}openvpn/ohp" >/dev/null 2>&1
    wget -O /etc/systemd/system/ohp.service "${REPO}openvpn/ohp.service" >/dev/null 2>&1
    chmod 644 /etc/systemd/system/ohp.service
    chmod +x /usr/sbin/ohp

}

### Pasang SlowDNS
function install_slowdns(){
    print_install "Memasang modul SlowDNS Server"
    wget -q -O /tmp/nameserver "${REPO}slowdns/nameserver" >/dev/null 2>&1
    chmod +x /tmp/nameserver
    bash /tmp/nameserver | tee /root/install.log
    print_success "SlowDNS"
}

### Pasang stunnel
function install_stunnel(){
        cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 222
connect = 127.0.0.1:39

[dropbear]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 700

[openvpn]
accept = 442
connect = 127.0.0.1:1194

END
chmod 644 /etc/stunnel/stunnel.conf

        openssl genrsa -out key.pem 2048
        openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
        -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Cendrawasih/OU=CendrawasihTunnel/CN=Cendrawasih/emailAddress=taibabi@cendrawasih.com"
        cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
        chmod 600 /etc/stunnel/stunnel.pem

        sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
        /etc/init.d/stunnel4 restart

}

### Pasang Rclone
function pasang_rclone() {
    print_install "Memasang Rclone"
    print_success "Installing Rclone"
    curl "${REPO}bin/rclone" | bash >/dev/null 2>&1
    print_success "Rclone"
}

### Ambil Konfig
function download_config(){
    print_install "Memasang konfigurasi paket konfigurasi"
    wget -O /etc/nginx/conf.d/cendrawasih.conf "${REPO}config/cendrawasih.conf" >/dev/null 2>&1
    sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/cendrawasih.conf
    wget -O /etc/nginx/nginx.conf "${REPO}config/nginx.conf" >/dev/null 2>&1
    wget -O /etc/cendrawasih/.version "${REPO}version" >/dev/null 2>&1

    wget -q -O /etc/squid/squid.conf "${REPO}config/squid.conf" >/dev/null 2>&1
    echo "visible_hostname $(cat /etc/xray/domain)" /etc/squid/squid.conf
    mkdir -p /var/log/squid/cache/
    chmod 777 /var/log/squid/cache/
    echo "* - nofile 65535" >> /etc/security/limits.conf
    mkdir -p /etc/sysconfig/
    echo "ulimit -n 65535" >> /etc/sysconfig/squid

    # > Add Dropbear
    apt install dropbear -y
    wget -q -O /etc/default/dropbear "${REPO}config/dropbear" >/dev/null 2>&1
    chmod 644 /etc/default/dropbear
    wget -q -O /etc/banner "${REPO}config/banner" >/dev/null 2>&1
    
    # > Add menu, thanks to unknow
    wget -O /tmp/menu-master.zip "${REPO}config/menu.zip" >/dev/null 2>&1
    mkdir /tmp/menu
    7z e  /tmp/menu-master.zip -o/tmp/menu/ >/dev/null 2>&1
    chmod +x /tmp/menu/*
    mv /tmp/menu/* /usr/sbin/

    # > Tambah tema, thanks for unknow
    wget -O /tmp/tema-master.zip "${REPO}config/tema.zip" >/dev/null 2>&1
    mkdir /tmp/tema
    7z e  /tmp/tema-master.zip -o/tmp/tema/ >/dev/null 2>&1
    chmod +x /tmp/tema/*
    # mv /tmp/tema/* /etc/cendrawasih/theme/    

    # > Vnstat
    vnstat -u -i $NET
    sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
    chown vnstat:vnstat /var/lib/vnstat -R

cat >/etc/cron.d/xp_all <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/bin/xp
EOF

cat >/etc/cron.d/daily_reboot <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * root /sbin/reboot
EOF

echo "*/1 * * * * root echo -n > /var/log/nginx/access.log" >/etc/cron.d/log.nginx
echo "*/1 * * * * root echo -n > /var/log/xray/access.log" >>/etc/cron.d/log.xray
service cron restart
cat >/home/daily_reboot <<EOF
5
EOF

cat >/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

echo "/bin/false" >>/etc/shells
echo "/usr/sbin/nologin" >>/etc/shells
cat >/etc/rc.local <<EOF
#!/bin/sh -e
# rc.local
# By default this script does nothing.
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
#/proc/sys/net/ipv6/conf/all/disable_ipv6
# systemctl restart netfilter-persistent
exit 0
EOF
    chmod +x /etc/rc.local
    print_ok "Konfigurasi file selesai"
}

### Tambahan
function tambahan(){
    print_install "Memasang modul tambahan"
    wget -O /usr/sbin/speedtest "${REPO}bin/speedtest" >/dev/null 2>&1
    chmod +x /usr/sbin/speedtest

    # > pasang gotop
    gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
    gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
    curl -sL "$gotop_link" -o /tmp/gotop.deb
    dpkg -i /tmp/gotop.deb >/dev/null 2>&1

    # > pasang glow
    glow_base="$(curl -s https://api.github.com/repos/charmbracelet/glow/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
    glow_latest="https://github.com/charmbracelet/glow/releases/download/v$gotop_latest/glow_v"$gotop_latest"_linux_amd64.deb"
    curl -sL "$glow_latest" -o /tmp/glow.deb
    dpkg -i /tmp/glow.deb >/dev/null 2>&1

    # # > Pasang Limit
    # wget -qO /tmp/limit.sh "${REPO}limit/limit.sh" >/dev/null 2>&1
    # chmod +x /tmp/limit.sh && bash /tmp/limit.sh >/dev/null 2>&1

    # > Pasang BBR Plus
    wget -qO /tmp/bbr.sh "${REPO}server/bbr.sh" >/dev/null 2>&1
    chmod +x /tmp/bbr.sh && bash /tmp/bbr.sh

    # > Buat swap sebesar 1G
    dd if=/dev/zero of=/swapfile1 bs=1024 count=524288 > /dev/null 2>&1
    dd if=/dev/zero of=/swapfile2 bs=1024 count=524288 > /dev/null 2>&1
    mkswap /swapfile1 > /dev/null 2>&1
    mkswap /swapfile2 > /dev/null 2>&1
    chown root:root /swapfile1 > /dev/null 2>&1
    chown root:root /swapfile2 > /dev/null 2>&1
    chmod 0600 /swapfile1 > /dev/null 2>&1
    chmod 0600 /swapfile2 > /dev/null 2>&1
    swapon /swapfile1 > /dev/null 2>&1
    swapon /swapfile2 > /dev/null 2>&1
    sed -i '$ i\swapon /swapfile1' /etc/rc.local > /dev/null 2>&1
    sed -i '$ i\swapon /swapfile2' /etc/rc.local > /dev/null 2>&1
    sed -i '$ i\/swapfile1      swap swap   defaults    0 0' /etc/fstab > /dev/null 2>&1
    sed -i '$ i\/swapfile2      swap swap   defaults    0 0' /etc/fstab > /dev/null 2>&1

    # > Singkronisasi jam
    # chronyd -q 'server 0.id.pool.ntp.org iburst'
    chronyc sourcestats -v
    chronyc tracking -v

    # > Tuned Device
    tuned-adm profile network-latency

    # > Homepage
    wget -O /etc/cendrawasih/public_html/index.html ${REPO}website/index.html >/dev/null 2>&1
    wget -O /etc/cendrawasih/public_html/style.css ${REPO}website/style.css >/dev/null 2>&1

    cat >/etc/msmtprc <<EOF
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host smtp.gmail.com
port 587
auth on
user bckupvpns@gmail.com
from bckupvpns@gmail.com
password Yangbaru1Yangbaru1cuj
logfile ~/.msmtp.log
EOF

cat <<EOT > /etc/motd
========================================================
                Cendrawasih Tunnel
Dengan menggunakan script ini, anda menyetujui jika:
- Script ini tidak diperjual belikan
- Script ini tidak digunakan untuk aktifitas ilegal
- Script ini tidak dienkripsi
========================================================
                    (c) 2023
EOT

chgrp mail /etc/msmtprc
chown 0600 /etc/msmtprc
touch /var/log/msmtp.log
chown syslog:adm /var/log/msmtp.log
chmod 660 /var/log/msmtp.log
ln -s /usr/bin/msmtp /usr/sbin/sendmail >/dev/null 2>&1
ln -s /usr/bin/msmtp /usr/bin/sendmail >/dev/null 2>&1
ln -s /usr/bin/msmtp /usr/lib/sendmail >/dev/null 2>&1
print_ok "Selesai pemasangan modul tambahan"

    cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
cat /etc/motd
sleep 1
clear
menu
END
chmod 644 /root/.profile
}


########## SETUP FROM HERE ##########
#####       Cendrawasih         #####
#####################################
echo "INSTALLING SCRIPT..."

touch /root/.install.log
cat >/root/tmp <<-END
#!/bin/bash
#vps
### CendrawasihTunnel $TANGGAL $MYIP
END

function enable_services(){
    print_install "Restart servis"
    systemctl daemon-reload
    systemctl start netfilter-persistent
    systemctl enable --now nginx
    systemctl enable --now chrony
    systemctl enable --now xray
    systemctl enable --now rc-local
    systemctl enable --now dropbear
    systemctl enable --now openvpn
    systemctl enable --now cron
    systemctl enable --now netfilter-persistent
    systemctl enable --now squid
    systemctl enable --now ws
    systemctl enable --now ws-dropbear
    systemctl enable --now ws-ovpn
    systemctl enable --now ohp
    systemctl enable --now client
    systemctl enable --now server
    systemctl enable --now vnstat
    systemctl enable --now fail2ban
    wget -O /root/.config/rclone/rclone.conf "${REPO}rclone/rclone.conf" >/dev/null 2>&1
}

function install_all() {
    base_package
    # dir_xray
    # add_domain
    pasang_ssl 
    install_xray >> /root/install.log
    install_websocket >> /root/install.log
    install_ovpn >> /root/install.log
    install_slowdns >> /root/install.log
    download_config >> /root/install.log
    enable_services >> /root/install.log
    tambahan >> /root/install.log
    pasang_rclone >> /root/install.log
}

function finish(){
    TEXT="
<u>INFORMATION</u>
<code>TIME      : </code><code>${TIME}</code>
<code>LOKASI    : </code><code>${CITY}(${MYIP})</code>
<code>DOMAIN    : </code><code>${domain}</code>
<code>ISP       : </code><code>${ISP}</code>
<code>RAM       : </code><code>${RAMMS}MB</code>
<code>LINUX     : </code><code>${OS}</code>
"
    curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
    cp /etc/openvpn/*.ovpn /etc/cendrawasih/public_html/
    sed -i "s/xxx/${MYIP}/g" /etc/squid/squid.conf
    chown -R cendrawasih:cendrawasih /etc/msmtprc


    # > Bersihkan History
    alias bash2="bash --init-file <(echo '. ~/.bashrc; unset HISTFILE')"
    clear
    echo "    ┌─────────────────────────────────────────────────────┐" | tee -a /root/.install.log
    echo "    │       >>> Service & Port                            │" | tee -a /root/.install.log
    echo "    │   - OpenSSH                 : 39                    │" | tee -a /root/.install.log
    echo "    │   - DNS (SLOWDNS)           : 443, 80, 53           │" | tee -a /root/.install.log
    echo "    │   - Dropbear                : 109, 143              │" | tee -a /root/.install.log
    # echo "    │   - Dropbear Websocket      : 443, 109              │" | tee -a /root/.install.log
    echo "    │   - SSH Websocket SSL       : 443                   │" | tee -a /root/.install.log
    echo "    │   - SSH Websocket           : 80                    │" | tee -a /root/.install.log
    echo "    │   - OpenVPN SSL             : 443, 1194             │" | tee -a /root/.install.log
    echo "    │   - OpenVPN Websocket SSL   : 443                   │" | tee -a /root/.install.log
    echo "    │   - OpenVPN TCP             : 1194                  │" | tee -a /root/.install.log
    echo "    │   - OpenVPN UDP             : 2200                  │" | tee -a /root/.install.log
    echo "    │   - Nginx Webserver         : 81                    │" | tee -a /root/.install.log
#    echo "    │   - Haproxy Loadbalancer    : 443, 80               │" | tee -a /root/.install.log
    echo "    │   - DNS Server              : 443, 53               │" | tee -a /root/.install.log
    echo "    │   - DNS Client              : 443, 88               │" | tee -a /root/.install.log
    echo "    │   - XRAY DNS (SLOWDNS)      : 443, 80, 53           │" | tee -a /root/.install.log
    echo "    │   - XRAY Vmess TLS          : 443                   │" | tee -a /root/.install.log
    echo "    │   - XRAY Vmess gRPC         : 443                   │" | tee -a /root/.install.log
    echo "    │   - XRAY Vmess None TLS     : 80                    │" | tee -a /root/.install.log
    echo "    │   - XRAY Vless TLS          : 443                   │" | tee -a /root/.install.log
    echo "    │   - XRAY Vless gRPC         : 443                   │" | tee -a /root/.install.log
    echo "    │   - XRAY Vless None TLS     : 80                    │" | tee -a /root/.install.log
    echo "    │   - Trojan gRPC             : 443                   │" | tee -a /root/.install.log
    echo "    │   - Trojan WS               : 443                   │" | tee -a /root/.install.log
    echo "    │   - Shadowsocks WS          : 443                   │" | tee -a /root/.install.log
    echo "    │   - Shadowsocks gRPC        : 443                   │" | tee -a /root/.install.log
    echo "    └─────────────────────────────────────────────────────┘" | tee -a /root/.install.log
    echo "    ┌─────────────────────────────────────────────────────┐"
    echo "    │                                                     │"
    echo "    │      >>> Server Information & Other Features        │"
    echo "    │   - Timezone                : Asia/Jakarta (GMT +7) │"
    echo "    │   - Autoreboot On           : 05:00 GMT +7          │"
    echo "    │   - Auto Delete Expired Account                     │"
    echo "    │   - Fully automatic script                          │"
    echo "    │   - VPS settings                                    │"
    echo "    │   - Admin Control                                   │"
    echo "    │   - Restore Data                                    │"
    echo "    │   - Full Orders For Various Services                │"
    echo "    └─────────────────────────────────────────────────────┘"
    secs_to_human "$(($(date +%s) - ${start}))"
    # echo -ne "         ${YELLOW}Please Reboot Your Vps${FONT} (y/n)? "
    # read REDDIR
    # if [ "$REDDIR" == "${REDDIR#[Yy]}" ]; then
    #     exit 0
    # else
    #     reboot
    # fi
}
cd /tmp
unset HISTFILE
first_setup
dir_xray
add_domain
install_all
finish  

rm /root/.bash_history
sleep 10
reboot
