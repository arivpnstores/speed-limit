#!/bin/bash

# =========================
# CONFIG
# =========================
IFACE="eth0"                       # ganti sesuai interface VPS
LIMIT=1024                          # limit harian 1TB = 1024 GiB
NORMAL_SPEED="100gbit"              # speed normal 100Gbps
LIMIT_SPEED="70gbit"                # speed saat over limit
LOG_FILE="/var/log/bw_limit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOUR=$(date '+%H')

# =========================
# FUNCTION: APPLY LIMIT USING TC
# =========================
apply_tc() {
    local SPEED=$1
    tc qdisc del dev $IFACE root 2>/dev/null
    tc qdisc add dev $IFACE root tbf rate $SPEED burst 100mb latency 50ms
}

# =========================
# RESET SPEED TENGAH MALAM
# =========================
if [[ "$HOUR" == "00" ]]; then
    apply_tc $NORMAL_SPEED
    MESSAGE="$DATE: Reset speed ke normal 100Gbps (tengah malam)"
    echo -e "$MESSAGE"
    echo "$MESSAGE" >> $LOG_FILE
    exit 0
fi

# =========================
# GET TRAFFIC USAGE
# =========================
USAGE=$(vnstat --oneline b | awk -F\; '{print $9+$10}')

# =========================
# CHECK AND APPLY LIMIT
# =========================
if (( $(echo "$USAGE > $LIMIT" | bc -l) )); then
    apply_tc $LIMIT_SPEED
    MESSAGE="$DATE: Over limit! Penggunaan hari ini $USAGE GiB > 1TB. Speed diturunkan ke $LIMIT_SPEED"
else
    apply_tc $NORMAL_SPEED
    MESSAGE="$DATE: Penggunaan hari ini $USAGE GiB, speed normal $NORMAL_SPEED"
fi

# =========================
# OUTPUT & LOG
# =========================
echo -e "$MESSAGE"
echo "$MESSAGE" >> $LOG_FILE
