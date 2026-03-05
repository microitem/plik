#!/bin/bash
# Po docker pull rootgg/plik:latest spustite tento skript
# Aktualizuje hashe v branding/index.html podľa novej verzie Plik

set -e
COMPOSE_FILE="${1:-docker-compose.yml}"
CONTAINER="plik-dev"

echo "Zistujem nove asset hashe z kontajnera..."

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Startujem kontajner..."
  docker compose -f "$COMPOSE_FILE" up -d
  sleep 10
fi

JS_FILE=$(docker exec "$CONTAINER" ls /home/plik/webapp/dist/assets/ | grep '^index-.*\.js$' | head -1)
CSS_FILE=$(docker exec "$CONTAINER" ls /home/plik/webapp/dist/assets/ | grep '^index-.*\.css$' | head -1)

echo "  JS:  $JS_FILE"
echo "  CSS: $CSS_FILE"

sed -i "s|src=\"/assets/index-[^\"]*\.js\"|src=\"/assets/${JS_FILE}\"|g" branding/index.html
sed -i "s|href=\"/assets/index-[^\"]*\.css\"|href=\"/assets/${CSS_FILE}\"|g" branding/index.html

echo "branding/index.html aktualizovany"
grep -E 'index-.*\.(js|css)' branding/index.html
