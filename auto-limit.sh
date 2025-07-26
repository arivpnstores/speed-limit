#!/bin/bash

# Fungsi: Deteksi interface utama
get_interface() {
    ip route | grep default | awk '{print $5}' | head -n 1
}

# Fungsi: Deteksi total RAM dalam GB
get_ram_gb() {
awk '/MemTotal/ {printf "%.0f", ($2 / 1024 / 1024) + 0.5}' /proc/meminfo
}

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Silakan jalankan sebagai root"
    exit 1
fi

# Install wondershaper jika belum ada
if ! command -v wondershaper &> /dev/null; then
    apt --fix-broken install
    apt update -y
    apt install -y wondershaper
fi

# Ambil interface
IFACE=$(get_interface)
if [ -z "$IFACE" ]; then
    echo "❌ Tidak dapat mendeteksi interface jaringan."
    exit 1
fi

# Ambil RAM VPS dalam GB
RAM_GB=$(get_ram_gb)

# Tentukan limit berdasarkan RAM (Mbps)
if [ "$RAM_GB" -eq 1 ]; then
    DL_MBPS=200
    UL_MBPS=100
elif [ "$RAM_GB" -eq 2 ]; then
    DL_MBPS=300
    UL_MBPS=150
elif [ "$RAM_GB" -eq 4 ]; then
    DL_MBPS=500
    UL_MBPS=250
elif [ "$RAM_GB" -eq 8 ]; then
    DL_MBPS=800
    UL_MBPS=400
elif [ "$RAM_GB" -gt 8 ]; then
    DL_MBPS=1000
    UL_MBPS=500
else
    echo "⚠️ RAM tidak dikenali. Menggunakan limit default 200 Mbps / 100 Mbps"
    DL_MBPS=200
    UL_MBPS=100
fi

# Konversi ke Kbps
DL_KBPS=$((DL_MBPS * 1000))
UL_KBPS=$((UL_MBPS * 1000))

# Terapkan speed limit
wondershaper -a "$IFACE" -d "$DL_KBPS" -u "$UL_KBPS"

# Buat systemd service
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

echo "✅ Speed limit diterapkan berdasarkan RAM VPS ($RAM_GB GB)"
echo "⬇️ Download: $DL_MBPS Mbps | ⬆️ Upload: $UL_MBPS Mbps pada interface $IFACE"
