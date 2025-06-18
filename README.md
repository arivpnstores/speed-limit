## 🔧 Instalasi Speed Limit VPS

Jalankan perintah di bawah ini untuk membatasi kecepatan jaringan (upload & download) pada VPS Ubuntu 20.04–24.10 dan Debian 10–12 menggunakan `wondershaper`:

```bash
bash <(curl -s https://raw.githubusercontent.com/arivpnstores/speed-limit/main/wondershaper.sh)


```bash
wondershaper clear $(ip route | grep default | awk '{print $5}' | head -n 1) && systemctl disable wondershaper
