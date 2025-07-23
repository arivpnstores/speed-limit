#!/bin/bash

# Interface yang digunakan
IFACE="eth0"

echo -e "🔍 Memeriksa bandwidth limiter di interface \e[1m$IFACE\e[0m..."

# Ambil output tc
TC_OUTPUT=$(tc qdisc show dev "$IFACE")

# Cek apakah menggunakan tbf (Token Bucket Filter)
if echo "$TC_OUTPUT" | grep -q "tbf"; then
    echo -e "✅ Bandwidth limiter \e[32mAKTIF\e[0m"

    # Ambil rate limit
    RATE=$(echo "$TC_OUTPUT" | grep -oP 'rate \K[^\s]+')
    BURST=$(echo "$TC_OUTPUT" | grep -oP 'burst \K[^\s]+')
    LATENCY=$(echo "$TC_OUTPUT" | grep -oP 'lat \K[^\s]+')

    echo "📊 Detail:"
    echo "   ➤ Rate    : $RATE"
    echo "   ➤ Burst   : $BURST"
    echo "   ➤ Latency : $LATENCY"
else
    echo -e "❌ Bandwidth limiter \e[31mTIDAK aktif\e[0m (pfifo_fast default digunakan)"
fi
