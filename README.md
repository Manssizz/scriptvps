## STATUS
`Versi Alpha` \
MASIH DALAM PENGEMBANGAN

## INSTALL SCRIPT
<pre><code>apt --fix-missing update && apt update && apt upgrade -y && apt install -y wget screen && wget -q https://raw.githubusercontent.com/manssizz/scriptvps/master/main.sh && chmod +x main.sh && screen -S install ./main.sh</code></pre>

Akses kembali 15 setelah proses instalasi.

## TESTED ON OS 
- UBUNTU 20.04

## FITUR TAMBAHAN
- Auto block sebagian ads indo by default (jadi ga perlu tambahan adblock)
- Tambah Swap 512MiB

## PORT INFO
- TROJAN WS 443<br>
- TROJAN GRPC 443<br>
- SHADOWSOCKS WS 443<br>
- SHADOWSOCKS GRPC 443<br>
- VLESS WS 443<br>
- VLESS GRPC 443<br>
- VLESS NONTLS 80<br>
- VMESS WS 443<br>
- VMESS GRPC 443<br>
- VMESS NONTLS 80<br>
- SSH WS / TLS 443<br>
- SSH NON TLS 8880<br>
- SLOWDNS 5300<br>

## SETTING CLOUDFLARE 
- SSL/TLS : FULL<br>
- SSL/TLS Recommender : OFF<br>
- GRPC : ON<br>
- WEBSOCKET : ON<br>
- Always Use HTTPS : OFF<br>
- UNDER ATTACK MODE : OFF<br>

## BUG
- Hapus user secara manual

## NOT WORKING FOR VPS SIMILAR 
- IDCLOUDHOST