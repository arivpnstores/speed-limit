#!/bin/bash

# =========================
# CONFIG
# =========================
IFACE="eth0"                       # ganti sesuai interface VPS
LIMIT=1024                          # limit harian 1TB = 1024 GiB
NORMAL_SPEED=100000000              # 100Gbps -> kbps
LIMIT_SPEED=50000000                # 50Gbps -> kbps
LOG_FILE="/var/log/bw_limit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# =========================
# GET TRAFFIC USAGE
# =========================
# ambil RX+TX hari ini dari vnstat (dalam GiB)
USAGE=$(vnstat --oneline b | awk -F\; '{print $9+$10}')

# =========================
# CHECK AND APPLY LIMIT
# =========================
if (( $(echo "$USAGE > $LIMIT" | bc -l) )); then
    # over limit
    wondershaper -c $IFACE
    wondershaper $IFACE $LIMIT_SPEED $LIMIT_SPEED
    echo "$DATE: Over limit! Penggunaan hari ini $USAGE GiB > 1TB. Speed diturunkan ke 50Gbps" >> $LOG_FILE
else
    # masih aman
    wondershaper -c $IFACE
    wondershaper $IFACE $NORMAL_SPEED $NORMAL_SPEED
    echo "$DATE: Penggunaan hari ini $USAGE GiB, speed normal 100Gbps" >> $LOG_FILE
fi
