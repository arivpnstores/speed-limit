#!/bin/bash

# =========================
# CONFIG
# =========================
IFACE="eth0"                       # ganti sesuai interface VPS
LIMIT=1024                          # limit harian 1TB = 1024 GiB
NORMAL_SPEED="100gbit"              # speed normal 100Gbps
LIMIT_SPEED="50gbit"                # speed saat over limit 50Gbps
LOG_FILE="/var/log/bw_limit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# =========================
# FUNCTION: APPLY LIMIT USING TC
# =========================
apply_tc() {
    local SPEED=$1

    # Hapus qdisc lama
    sudo tc qdisc del dev $IFACE root 2>/dev/null

    # Tambahkan qdisc baru
    sudo tc qdisc add dev $IFACE root tbf rate $SPEED burst 100mb latency 50ms
}

# =========================
# GET TRAFFIC USAGE
# =========================
# Pastikan vnstat sudah terinstall dan update database
# Install: sudo apt install vnstat -y
USAGE=$(vnstat --oneline b | awk -F\; '{print $9+$10}')

# =========================
# CHECK AND APPLY LIMIT
# =========================
if (( $(echo "$USAGE > $LIMIT" | bc -l) )); then
    apply_tc $LIMIT_SPEED
    echo "$DATE: Over limit! Penggunaan hari ini $USAGE GiB > 1TB. Speed diturunkan ke $LIMIT_SPEED" >> $LOG_FILE
else
    apply_tc $NORMAL_SPEED
    echo "$DATE: Penggunaan hari ini $USAGE GiB, speed normal $NORMAL_SPEED" >> $LOG_FILE
fi
