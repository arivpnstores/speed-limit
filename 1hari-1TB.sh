#!/bin/bash

# =========================
# AUTO DETECT INTERFACE
# =========================
IFACE=$(ip route | awk '/default/ {print $5; exit}')

if [[ -z "$IFACE" ]]; then
    echo "❌ Tidak bisa mendeteksi interface jaringan."
    exit 1
fi

# =========================
# CONFIG
# =========================
LIMIT=1024                      # 1TB = 1024 GiB
NORMAL_SPEED="10gbit"
LIMIT_SPEED="5gbit"
LOG_FILE="/var/log/bw_limit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOUR=$(date '+%H')

# =========================
# FUNCTION: APPLY TC
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
    MESSAGE="$DATE: Reset speed ke normal $NORMAL_SPEED (tengah malam)"
    echo -e "$MESSAGE" | tee -a $LOG_FILE
    exit 0
fi

# =========================
# HITUNG TRAFIK HARI INI
# =========================
# Pastikan sudah install vnstat dan jq
USAGE=$(vnstat -i $IFACE --oneline --json | jq '.traffic.today.rx + .traffic.today.tx')
USAGE_GIB=$(echo "$USAGE / 1024 / 1024 / 1024" | bc -l)

# =========================
# CEK DAN APPLY LIMIT
# =========================
if (( $(echo "$USAGE_GIB > $LIMIT" | bc -l) )); then
    apply_tc $LIMIT_SPEED
    MESSAGE="$DATE: Over limit! Penggunaan hari ini ${USAGE_GIB}GiB > 1TB. Speed turun ke $LIMIT_SPEED"
else
    apply_tc $NORMAL_SPEED
    MESSAGE="$DATE: Penggunaan hari ini ${USAGE_GIB}GiB, speed normal $NORMAL_SPEED"
fi

# =========================
# OUTPUT & LOG
# =========================
echo -e "$MESSAGE" | tee -a $LOG_FILE
