#!/bin/bash

INTERFACE="eth0"
QDISC_OUTPUT=$(tc qdisc show dev $INTERFACE)

echo "🔍 Memeriksa bandwidth limiter di interface $INTERFACE..."

if echo "$QDISC_OUTPUT" | grep -q "tbf"; then
    RATE=$(echo "$QDISC_OUTPUT" | grep -oP "rate \K\S+")
    BURST=$(echo "$QDISC_OUTPUT" | grep -oP "burst \K\S+")
    LATENCY=$(echo "$QDISC_OUTPUT" | grep -oP "lat \K\S+")

    echo "✅ Bandwidth limiter AKTIF:"
    echo "Rate    : $RATE"
    echo "Burst   : $BURST"
    echo "Latency : $LATENCY"
else
    echo "❌ Bandwidth limiter TIDAK aktif (pfifo_fast default digunakan)"
fi
