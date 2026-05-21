#!/usr/bin/env bash
# CityBuilder build check — runs all QM gates
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== flutter analyze ==="
flutter analyze --no-pub

echo ""
echo "=== flutter test ==="
flutter test

echo ""
echo "=== flutter build web ==="
flutter build web --release

echo ""
echo "=== docker build ==="
docker build -t citybuilder-check .

echo ""
echo "=== docker smoke test ==="
CID=$(docker run -d --rm -p 127.0.0.1:18080:8080 citybuilder-check)
sleep 5
HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:18080/ || echo "000")
docker stop "$CID" >/dev/null 2>&1 || true

if [ "$HTTP" = "200" ]; then
  echo "Docker smoke test: HTTP 200 OK"
else
  echo "Docker smoke test FAILED: HTTP $HTTP" >&2
  exit 1
fi

echo ""
echo "=== All checks passed ==="
