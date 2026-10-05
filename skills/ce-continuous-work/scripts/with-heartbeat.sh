#!/usr/bin/env bash
# ce-continuous-work — uzun bir komutu (ör. Faz 4 `<test_command>`) nabızla koşar.
#
# Kullanım:
#   CE_PROGRESS_LOG=<state_dir>/<slug>/progress.log \
#     with-heartbeat.sh <etiket> -- <komut> [arg...]
#
# Komutun çıkış kodunu aynen döndürür; çıktısı değişmeden stdout/stderr'e akar.
# Nabız bloğu (süre + dokunulan dosyalar) CE_HEARTBEAT_SECS aralıkla ilerleme
# günlüğüne düşer; başlangıç ve bitiş satırları her zaman yazılır.

set -uo pipefail

label="${1:-}"
[ "${2:-}" = "--" ] && shift 2 || { echo "kullanım: with-heartbeat.sh <etiket> -- <komut>..." >&2; exit 1; }
[ -n "$label" ] && [ "$#" -gt 0 ] || { echo "kullanım: with-heartbeat.sh <etiket> -- <komut>..." >&2; exit 1; }

# shellcheck source=heartbeat.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/heartbeat.sh"

ce_progress "BAŞLADI '$label': $*"
start=$(date +%s)
ce_heartbeat_start "$label"
"$@"
code=$?
ce_heartbeat_stop
el=$(( $(date +%s) - start ))
ce_progress "BİTTİ '$label': çıkış $code ($((el / 60)) dk $((el % 60)) sn)"
exit "$code"
