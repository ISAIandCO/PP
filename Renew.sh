#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./Renew.sh [smartproxy_json_path]
# Environment:
#   DOWNLOADS_DIR - directory to search for SmartProxy backups (default: ~/Загрузки)
#   EDITOR        - editor for manual review (default: nano)
#   AUTO_YES=1    - skip interactive editor
#   NO_PUSH=1     - do not run git push

DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Загрузки}"
INPUT_JSON="${1:-}"
EDITOR_CMD="${EDITOR:-nano}"
AUTO_YES="${AUTO_YES:-0}"
NO_PUSH="${NO_PUSH:-0}"

b64_decode() {
  if base64 -d /dev/null >/dev/null 2>&1; then
    base64 -d "$1"
  elif base64 -D /dev/null >/dev/null 2>&1; then
    base64 -D "$1"
  else
    echo "Ошибка: не удалось определить режим декодирования base64" >&2
    exit 1
  fi
}

b64_encode_file() {
  if base64 -w 0 /dev/null >/dev/null 2>&1; then
    base64 -w 0 "$1"
  else
    base64 < "$1" | tr -d '\n'
  fi
}

find_latest_backup() {
  local latest=""

  if [[ ! -d "$DOWNLOADS_DIR" ]]; then
    echo ""
    return 0
  fi

  # shellcheck disable=SC2012
  latest="$(ls -1t "$DOWNLOADS_DIR"/SmartProxy*.json 2>/dev/null | head -n 1 || true)"
  echo "$latest"
}

if [[ -z "$INPUT_JSON" ]]; then
  INPUT_JSON="$(find_latest_backup)"
fi

if [[ -z "$INPUT_JSON" || ! -f "$INPUT_JSON" ]]; then
  echo "Ошибка: не найден SmartProxy JSON. Передайте путь первым аргументом или проверьте DOWNLOADS_DIR=$DOWNLOADS_DIR" >&2
  exit 1
fi

if [[ ! -f PR_b64.rls ]]; then
  echo "Ошибка: отсутствует файл PR_b64.rls" >&2
  exit 1
fi

tmp1="$(mktemp PR_pt_temp1.XXXXXX.rls)"
tmp2="$(mktemp PR_pt_temp2.XXXXXX.rls)"
trap 'rm -f "$tmp1" "$tmp2"' EXIT

b64_decode PR_b64.rls > "$tmp1"

# Извлечение hostName без зависимости от grep -P
sed -n 's/.*"hostName":"\([^"]*\)".*/\1/p' "$INPUT_JSON" >> "$tmp1"

awk '!seen[$0]++' "$tmp1" > "$tmp2"

if [[ "$AUTO_YES" != "1" ]]; then
  "$EDITOR_CMD" "$tmp2"
fi

b64_encode_file "$tmp2" > PR_b64.rls

git add -A -f
if ! git diff --cached --quiet; then
  git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
  if [[ "$NO_PUSH" != "1" ]]; then
    current_branch="$(git rev-parse --abbrev-ref HEAD)"
    git push origin "$current_branch"
  else
    echo "NO_PUSH=1: push пропущен"
  fi
else
  echo "Нет изменений для коммита"
fi
