## 🔧 Instalasi Speed Limit VPS

Jalankan perintah di bawah ini untuk membatasi kecepatan jaringan (upload & download) pada VPS Ubuntu 20.04–24.10 dan Debian 10–12 menggunakan wondershaper:
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/wondershaper.sh)
```

Perintah Mengecek Limit menggunakan wondershaper:
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/monitor-limit.sh)
```

## ❌ Menghapus Limit

Jika kamu ingin menghapus limit yang sudah diterapkan, jalankan perintah berikut:
```bash
wondershaper clear $(ip route | grep default | awk '{print $5}' | head -n 1) && systemctl disable wondershaper
```

## SPEEDTEST
Jika mau mengecek kecepatan server
```bash
wget https://raw.githubusercontent.com/arivpnstores/v4/main/Cdy/speedtest -O /usr/bin/speedtest && chmod +x /usr/bin/speedtest && /usr/bin/speedtest
```
