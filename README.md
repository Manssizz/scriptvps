<h1 align="center">
  <a href="https://github.com/manssizz/scriptvps"><img src="https://github.com/Manssizz/scriptvps/raw/master/assets/logo.png" alt="LOGO"></a>
</h1>

### PERHATIAN
- Terima kasih untuk tidak menjual maupun mengenkripsi skrip ini. Saya mendapatkan secara gratis, jadi saya ataupun kalian harus berbagi secara gratis.
- Script ini **tidak direkomendasikan untuk bermain game**.
- Status servis terkadang miss informasi. Dimana pada status dead tetapi jika dilihat by servis statusnya sudah aktif. Jadi bisa diabaikan
- Jika mendapatkan error pada status servis dalam jangka panjang, bisa restart servis yang dead.

### INSTALL SCRIPT
<pre><code>apt install -y wget screen && wget -q https://raw.githubusercontent.com/taibabi/anaksetan/master/main.sh && chmod +x main.sh && screen -S install ./main.sh</code></pre>

Akses kembali 20 menit setelah proses instalasi. **Akses kembali via ssh menggunakan port 39**

### TESTED ON OS 
- UBUNTU 20.04.05

### FITUR TAMBAHAN
- Tambah Swap 1GiB
- Pemasangan yang dinamis
- Tuning profile pada server
- Xray Core by [@dharak36](https://github.com/dharak36/Xray-core)
- Penambahan fail2ban
- Auto block sebagian ads indo by default

### PORT INFO
```
- TROJAN WS 443
- TROJAN GRPC 443
- SHADOWSOCKS WS 443
- SHADOWSOCKS GRPC 443
- VLESS WS 443
- VLESS GRPC 443
- VLESS NONTLS 80
- VMESS WS 443
- VMESS GRPC 443
- VMESS NONTLS 80
- SSH WS / TLS 443 [BETA]
- SSH NON TLS 8880 [BETA]
- OVPN SSL/TCP 1194 [BETA]
- SLOWDNS 5300 [BETA]
```

### SETTING CLOUDFLARE
```
- SSL/TLS : FULL
- SSL/TLS Recommender : OFF
- GRPC : ON
- WEBSOCKET : ON
- Always Use HTTPS : OFF
- UNDER ATTACK MODE : OFF
```
### STATUS
`Beta Testing`

### Lisensi
Repository ini dilindungi oleh lisensi [MIT](https://mit-license.org/)

### Credits
- [Dharak36](https://github.com/dharak36/Xray-core)
- [Tiarap](https://github.com/pengelana/blocklist)