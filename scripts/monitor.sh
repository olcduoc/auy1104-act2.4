#!/usr/bin/env bash
# Uso: ./monitor.sh <LB_URL>
# Hace curl cada 0.5s, marca con verde/rojo, cuenta el downtime total

URL="$1"
[ -z "$URL" ] && { echo "Uso: $0 <http://lb-url>"; exit 1; }

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
FAILS=0
TOTAL=0
START=$(date +%s)

echo "Monitoreando $URL (Ctrl+C para terminar)"
echo "Cada error suma 0.5s al downtime acumulado"
echo "---"

while true; do
  TOTAL=$((TOTAL+1))
  TS=$(date +%H:%M:%S)
  if BODY=$(curl -fsS --max-time 1 "$URL" 2>/dev/null); then
    VER=$(echo "$BODY" | grep -oE '<h1>[^<]+</h1>' | head -1)
    printf "${GREEN}[%s] OK ${NC} %s\n" "$TS" "$VER"
  else
    FAILS=$((FAILS+1))
    printf "${RED}[%s] FAIL${NC}\n" "$TS"
  fi
  sleep 0.5
done

trap 'END=$(date +%s); echo; echo "Duración total: $((END-START))s | Requests: $TOTAL | Fallos: $FAILS | Downtime estimado: $(awk "BEGIN{print $FAILS*0.5}")s"; exit 0' INT TERM
