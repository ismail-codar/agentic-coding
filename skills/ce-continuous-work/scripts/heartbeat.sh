# ce-continuous-work — nabız (ilerleme bildirimi) kütüphanesi. `source` edilir.
#
# NEDEN: Aşamalar `claude -p` alt sürecinde, ana oturum da onları arka planda
# koşar; kullanıcı 30-60 dk boyunca ekranda HİÇBİR şey görmez (ölçüldü,
# 2026-10-04: faz1-work 25+ dk sessiz). Nabız her CE_HEARTBEAT_SECS saniyede
# (varsayılan 600 = 10 dk) "ne yapılıyor + hangi dosyalara dokunuldu" bloğunu
# ilerleme günlüğüne ve stderr'e yazar. Ana oturum günlüğü `Monitor` ile
# izleyip satırları kullanıcıya aktarır (SKILL.md → "İlerleme bildirimi").
#
# Ortam:
#   CE_HEARTBEAT_SECS   aralık, saniye (varsayılan 600; 0 = kapalı)
#   CE_PROGRESS_LOG     ilerleme günlüğü (çağıran varsayılanı verir)
#
# Kullanım:
#   source heartbeat.sh
#   ce_progress "<satır>"                         # günlüğe + stderr'e tek satır
#   ce_heartbeat_start <etiket> [stream-dosyası]  # arka plan nabzı başlat
#   ce_heartbeat_stop                             # durdur (idempotent)

_ce_hb_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ce_hb_pid=""

ce_progress() {
  local line="[ce-cw $(date +%H:%M:%S)] $*"
  echo "$line" >&2
  [ -n "${CE_PROGRESS_LOG:-}" ] && echo "$line" >>"$CE_PROGRESS_LOG" 2>/dev/null
  return 0
}

_ce_python() {
  if command -v python >/dev/null 2>&1; then echo python
  elif command -v python3 >/dev/null 2>&1; then echo python3
  fi
}

# Aşama başından beri dokunulan dosyalar: taban porcelain'de olmayan satırlar
# + mtime'ı başlangıçtan yeni olan kirli yollar. Git yoksa sessiz.
_ce_touched_files() {
  local start="$1" base="$2"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  # Satır başına süreç açmak Windows'ta saniyeler sürüyor (ölçüldü: 5 dosya
  # ~7 s) — taban farkı tek awk, mtime tek stat çağrısıyla hesaplanır.
  local cur; cur="$(git status --porcelain -uall 2>/dev/null)"
  [ -n "$cur" ] || return 0
  local old_paths new_lines recent
  new_lines="$(printf '%s\n' "$cur" | awk -v base="$base" \
    'BEGIN{while((getline l < base)>0) b[l]=1} !($0 in b)')"
  old_paths="$(printf '%s\n' "$cur" | awk -v base="$base" \
    'BEGIN{while((getline l < base)>0) b[l]=1} ($0 in b){p=substr($0,4); sub(/.* -> /,"",p); gsub(/"/,"",p); print p}')"
  recent=""
  if [ -n "$old_paths" ]; then
    recent="$(printf '%s\n' "$old_paths" | tr '\n' '\0' \
      | xargs -0 stat -c '%Y %n' 2>/dev/null | awk -v s="$start" '$1>=s{sub(/^[0-9]+ /,""); print}')"
  fi
  printf '%s\n' "$cur" | awk -v nl="$new_lines" -v rc="$recent" '
    BEGIN{n=split(nl,a,"\n"); for(i=1;i<=n;i++) if(a[i]!="") keep[a[i]]=1
          m=split(rc,r,"\n"); for(i=1;i<=m;i++) if(r[i]!="") rp[r[i]]=1}
    { p=substr($0,4); sub(/.* -> /,"",p); gsub(/"/,"",p)
      if(($0 in keep) || (p in rp)) print }'
}

_ce_heartbeat_block() {
  local label="$1" stream="$2" start="$3" base="$4"
  local el=$(( $(date +%s) - start ))
  ce_progress "NABIZ '$label' — $((el / 60)) dk $((el % 60)) sn geçti"
  local py; py="$(_ce_python)"
  if [ -n "$stream" ] && [ -s "$stream" ] && [ -n "$py" ]; then
    local act total
    act="$("$py" "$_ce_hb_dir/progress.py" activity "$stream" 5 2>/dev/null || true)"
    total="$(printf '%s\n' "$act" | sed -n 's/^#toplam_arac_cagrisi=//p')"
    ce_progress "  araç çağrısı: ${total:-?} — son işler:"
    printf '%s\n' "$act" | grep -v '^#toplam_arac_cagrisi=' | while IFS= read -r a; do
      [ -n "$a" ] && ce_progress "    - $a"
    done
  fi
  local touched n
  touched="$(_ce_touched_files "$start" "$base")"
  n="$(printf '%s' "$touched" | grep -c . || true)"
  ce_progress "  dokunulan dosyalar (aşama başından beri): ${n:-0}"
  [ -n "$touched" ] && ce_progress "$(printf '%s\n' "$touched" | head -15 | sed 's/^/    /')"
  [ "${n:-0}" -gt 15 ] 2>/dev/null && ce_progress "    … +$((n - 15)) dosya daha"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local stat; stat="$(git diff --shortstat 2>/dev/null)"
    [ -n "$stat" ] && ce_progress "  ağaç farkı:${stat}"
  fi
}

ce_heartbeat_start() {
  local label="$1" stream="${2:-}"
  local secs="${CE_HEARTBEAT_SECS:-600}"
  [ "$secs" -gt 0 ] 2>/dev/null || return 0
  local start; start="$(date +%s)"
  local base; base="$(mktemp 2>/dev/null || echo "${TMPDIR:-/tmp}/ce-hb-$$")"
  git status --porcelain -uall >"$base" 2>/dev/null || : >"$base"
  (
    trap 'rm -f "$base"; exit 0' TERM INT
    next=$(( start + secs ))
    while :; do
      sleep 5
      if [ "$(date +%s)" -ge "$next" ]; then
        _ce_heartbeat_block "$label" "$stream" "$start" "$base" || true
        next=$(( next + secs ))
      fi
    done
  ) &
  _ce_hb_pid=$!
}

ce_heartbeat_stop() {
  if [ -n "$_ce_hb_pid" ]; then
    kill "$_ce_hb_pid" 2>/dev/null || true
    wait "$_ce_hb_pid" 2>/dev/null || true
    _ce_hb_pid=""
  fi
}
