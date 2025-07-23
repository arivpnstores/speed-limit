#!/bin/bash

iface="eth0"

echo "🔍 Memeriksa limit bandwidth di semua interface..."

tc qdisc show | while read -r line; do
  echo "$line" | grep -E "tbf|htb|fq_codel|fq" > /dev/null
  if [[ $? -eq 0 ]]; then
    iface_name=$(echo "$line" | grep -oP 'dev \K\S+')
    echo "✅ Limit aktif di interface: $iface_name"
    echo "   ↳ Detail: $line"
  fi
done
