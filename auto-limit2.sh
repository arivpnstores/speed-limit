#!/bin/bash

IFACE=$(ip route | awk '/default/ {print $5; exit}')
HOUR=$(date +%H)

# Hapus limit lama
wondershaper clear "$IFACE" 2>/dev/null

# Jika jam 18:00 - 20:59, limit 500 Mbps
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 21 ]; then
    wondershaper -a "$IFACE" -d 500000 -u 500000
fi
