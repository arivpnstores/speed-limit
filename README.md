## 🔧 Instalasi Speed Limit VPS

Jalankan perintah di bawah ini untuk membatasi kecepatan jaringan (upload & download) pada VPS Ubuntu 20.04–24.10 dan Debian 10–12 menggunakan wondershaper:
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/wondershaper.sh)
```
Jalankan perintah di bawah ini untuk membatasi kecepatan jaringan (upload & download) pada VPS Ubuntu 20.04–24.10 dan Debian 10–12 menggunakan wondershaper sesuai ram vps :
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/auto-limit.sh)
```
Jalankan perintah di bawah ini untuk membatasi kecepatan jaringan (upload & download) pada Jam 18:00–20:59 → limit 500 Mbps. :
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/auto-limit2.sh)
```
Perintah Mengecek Limit menggunakan wondershaper:
```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/monitor-limit.sh)
```

## ❌ Menghapus Limit

Jika kamu ingin menghapus limit yang sudah diterapkan, jalankan perintah berikut:
```bash
systemctl stop wondershaper && systemctl disable wondershaper && for i in $(ls /sys/class/net); do wondershaper clear $i 2>/dev/null && echo "✅ Cleared $i"; done
```

## SPEEDTEST
Jika mau mengecek kecepatan server
```bash
wget https://raw.githubusercontent.com/arivpnstores/v4/main/Cdy/speedtest -O /usr/bin/speedtest && chmod +x /usr/bin/speedtest && /usr/bin/speedtest
```
