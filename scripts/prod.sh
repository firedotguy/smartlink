#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
WEB_ROOT="/var/www/flutter"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${API_KEY:?ERROR: API_KEY is not set in .env}"
: "${API_BASE:?ERROR: API_BASE is not set in .env}"

echo "Building Flutter Web with dart-defines (values hidden)…"

flutter build web --release \
  --dart-define=API_KEY="$API_KEY" \
  --dart-define=API_BASE="$API_BASE" \
  --wasm

rm -rf "$WEB_ROOT"/*
sudo cp -a build/web/. "$WEB_ROOT"/

echo "Done. Deployed to $WEB_ROOT"
