#!/bin/bash
#fix
dpkg-statoverride --list | grep Debian-exim
dpkg-statoverride --remove /path/yangsalah
sed -i '/Debian-exim/d' /var/lib/dpkg/statoverride
dpkg --configure -a
apt-get install -f

# Fungsi: Deteksi interface utama
get_interface() {
    ip route | grep default | awk '{print $5}' | head -n 1
}

# Fungsi: Deteksi total RAM dalam GB (dibulatkan)
get_ram_gb() {
    awk '/MemTotal/ {printf "%.0f", int(($2 + 1048575) / 1048576)}' /proc/meminfo
}

# Fungsi: Deteksi jumlah CPU core
get_cpu_core() {
    nproc
}

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Silakan jalankan sebagai root"
    exit 1
fi

# Install wondershaper 
    apt --fix-broken install -y
    apt update -y
    apt install -y wondershaper

# Ambil interface, RAM, dan CPU core
IFACE=$(get_interface)
RAM_GB=$(get_ram_gb)
CPU_CORE=$(get_cpu_core)

if [ -z "$IFACE" ]; then
    echo "❌ Tidak dapat mendeteksi interface jaringan."
    exit 1
fi

# Tentukan limit berdasarkan kombinasi RAM & CPU
case "${CPU_CORE}_${RAM_GB}" in
    1_1)
        DL_MBPS=300; UL_MBPS=300 ;;   # pas buat user sedikit, stabil
    1_2)
        DL_MBPS=500; UL_MBPS=500 ;;   # cocok buat tunneling personal
    2_2)
        DL_MBPS=700; UL_MBPS=700 ;;   # 5-10 user masih aman
    2_4)
        DL_MBPS=900; UL_MBPS=900 ;;   # ramean, masih wuss
    4_8|*_8)
        DL_MBPS=1200; UL_MBPS=1200 ;; # server gede, bisa pull max
    *)
        echo "⚠️ Kombinasi RAM/CPU tidak dikenali. Gunakan default aman 200/200 Mbps"
        DL_MBPS=200; UL_MBPS=200 ;;
esac

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

echo "✅ Speed limit diterapkan berdasarkan RAM ${RAM_GB}GB & CPU ${CPU_CORE} core"
echo "⬇️ Download: $DL_MBPS Mbps | ⬆️ Upload: $UL_MBPS Mbps pada interface $IFACE"
