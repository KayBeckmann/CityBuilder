#!/usr/bin/env bash
# QM-Baseline — führe vor jedem Merge/Tag aus
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> flutter analyze"
flutter analyze

echo "==> dart format"
dart format --set-exit-if-changed .

echo "==> flutter test"
flutter test

echo "==> flutter build web"
flutter build web --no-wasm-dry-run

echo ""
echo "✓ Alle QM-Checks bestanden."
