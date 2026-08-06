#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found at $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${API_BASE:?ERROR: API_BASE is not set in .env}"

echo "Running Flutter Web..."

flutter run -d chrome \
  --dart-define=API_BASE="$API_BASE" \
  --debug \
  --track-widget-creation
