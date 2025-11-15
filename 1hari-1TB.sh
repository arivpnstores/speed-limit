#!/bin/bash

IFACE=$(ip route | awk '/default/ {print $5; exit}')
LIMIT=1024
NORMAL_SPEED="10gbit"
LIMIT_SPEED="5gbit"
LOG_FILE="/var/log/bw_limit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOUR=$(date '+%H')

apply_tc() {
    local SPEED=$1
    tc qdisc del dev $IFACE root 2>/dev/null
    tc qdisc add dev $IFACE root tbf rate $SPEED burst 100mb latency 50ms
}

if [[ "$HOUR" == "00" ]]; then
    apply_tc $NORMAL_SPEED
    MESSAGE="$DATE: Reset speed ke normal $NORMAL_SPEED (tengah malam)"
    echo -e "$MESSAGE" | tee -a $LOG_FILE
    exit 0
fi

# Ambil trafik hari ini dari vnStat
USAGE=$(vnstat -i $IFACE -d | awk '/today/ {print $2+$3}')

if (( $(echo "$USAGE > $LIMIT" | bc -l) )); then
    apply_tc $LIMIT_SPEED
    MESSAGE="$DATE: Over limit! Penggunaan hari ini ${USAGE}GiB > 1TB. Speed turun ke $LIMIT_SPEED"
else
    apply_tc $NORMAL_SPEED
    MESSAGE="$DATE: Penggunaan hari ini ${USAGE}GiB, speed normal $NORMAL_SPEED"
fi

echo -e "$MESSAGE" | tee -a $LOG_FILE
