#!/bin/bash

# Fungsi: Deteksi interface utama
get_interface() {
    ip route | grep default | awk '{print $5}' | head -n 1
}

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Silakan jalankan sebagai root"
    exit 1
fi

# Install wondershaper 
    apt --fix-broken install
    apt update -y
    apt install -y wondershaper

# Ambil interface
IFACE=$(get_interface)
if [ -z "$IFACE" ]; then
    echo "Tidak dapat mendeteksi interface jaringan."
    exit 1
fi

# Input limit dalam Mbps
read -p "Masukkan limit download (Mbps): " DL_MBPS
read -p "Masukkan limit upload (Mbps): " UL_MBPS

# Konversi ke Kbps
DL_KBPS=$((DL_MBPS * 1000))
UL_KBPS=$((UL_MBPS * 1000))

# Terapkan speed limit
wondershaper -a "$IFACE" -d "$DL_KBPS" -u "$UL_KBPS"

# Simpan service systemd
cat > /etc/systemd/system/wondershaper.service << EOF
[Unit]
Description=Limit bandwidth using wondershaper
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/wondershaper -a $IFACE -d $DL_KBPS -u $UL_KBPS
ExecStop=/sbin/wondershaper clear $IFACE
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Aktifkan service
systemctl daemon-reload
systemctl enable wondershaper
systemctl start wondershaper

echo "Speed limit berhasil diterapkan pada interface $IFACE"
echo "Download: $DL_MBPS Mbps | Upload: $UL_MBPS Mbps"
