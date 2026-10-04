#!/usr/bin/env bash
# ce-continuous-work — tek bir aşamayı ayrı bir `claude -p` alt sürecinde koşar.
#
# NEDEN ALT SÜREÇ: Ana oturum bağlamı, uygulama aşamalarının araç çıktısını
# taşımasın diye. `/compact` bir CLI yerleşiğidir, model onu çağıramaz; ayrıca
# compact kayıplı bir özet bırakır. Ayrı süreç SIFIR bağlamla başlar — bu,
# compact'in yapabileceğinden kesin olarak daha iyidir.
#
# İZİN KİPİ: Varsayılan olarak HİÇBİR şey geçirilmez — alt süreç projenin
# `.claude/settings*.json` içindeki `defaultMode` değerini devralır. Bu
# bilinçlidir: betik projenin izin kararını geri almaz. Gözetimsiz turda daha
# geniş izin gerekirse çağıran açıkça seçer:
#
#   CLAUDE_PERM_MODE=acceptEdits ./run-phase.sh ...
#
# KAYITSIZ AŞAMA TUZAĞI: Gözetimsiz süreçte `claude -p` 0 dönse bile aşama
# zarfı yazmamış olabilir. Bu yüzden tek başına çıkış koduna güvenilmez: aşama bir ESER
# (zarf dosyası) üretmek zorundadır — üretmezse çıkış 0 olsa bile başarısız
# sayılır.
#
# EKSİK ZARF "HİÇBİR ŞEY YAPMADI" DEMEK DEĞİLDİR. Bu ayrım skill'in ilk
# geliştirildiği projede ÖLÇÜLDÜ: inceleme aşaması zarfsız bitti ama çalışma
# ağacını ciddi biçimde değiştirmişti (bir kaynak dosya ~100 satır büyüdü).
# Eksik zarfın iki ayrı sebebi vardır ve turun tepkisi ikisinde de aynı
# (DUR) ama teşhisi FARKLIDIR:
#
#   (a) aşama gerçekten hiçbir şey yapmadı — sessiz araç reddi, anında hata;
#   (b) aşama işi yaptı ama KAYDINI bırakmadı — turunu erken bitirdi
#       (ör. "arka plan görevini bekleyeceğim" deyip çıktı), zarfı yazmayı
#       atladı, ya da yanlış yola yazdı.
#
# (b) daha tehlikelidir: ağaçta ne uygulandığı, doğrulanıp doğrulanmadığı ve
# hangi bulguların açık kaldığı BİLİNMEYEN değişiklikler durur. Çağıran bu
# ikisini çıkış koduyla ayıramaz, ağacı ölçerek ayırır — bu yüzden betik
# çıkış 3 yolunda aşamanın ağacı değiştirip değiştirmediğini raporlar.
#
# AYRICA: durdurulan bir aşamanın `claude -p` çocuğu HAYATTA KALABİLİR ve
# yazmaya devam eder (aynı turda ölçüldü). Bir aşamayı iptal eden çağıran,
# ağacın gerçekten durduğunu ÖLÇMEDEN (diff/mtime kararlılığı) bir sonraki
# aşamayı başlatmamalıdır.
#
# Kullanım:
#   run-phase.sh <asama-adi> <prompt-dosyasi> <zarf-dosyasi> [model]
#
# ZARF KURTARMA: Kayıtsız aşama ÖLÇÜLDÜ ve nadir değil — bir turda 5 aşamanın
# 3'ü (iki uygulama ünitesi ve bir inceleme) işi
# bitirip zarfı yazmadan öldü. Her seferinde ağaçtaki iş SAĞLAMDI; pahalı olan
# kaydın elle yeniden kurulmasıydı (diff okuma + testleri yeniden koşma).
# Prompt'a "zarfı unutma" yazmak ZAYIF bir önlemdir: alt sürecin uyumuna bağlı
# ve üç turda da tutmadı.
#
# Yapısal önlem: aşama SABİT bir `--session-id` ile koşar; zarf eksikse betik
# AYNI oturumu `--resume` ile geri çağırıp YALNIZ zarfı yazdırır. İş zaten
# yapılmıştır ve bağlam o oturumdadır — kurtarma çağrısı kısa ve ucuzdur.
# Kurtarma da başarısız olursa davranış eskisi gibidir (çıkış 3 + teşhis).
#
# Kurtarılan zarfa `_envelope_recovered: true` düşülür: kaydın ikinci turda
# geldiği GÖRÜNÜR kalmalı, çünkü kurtarma anı alt sürecin kendi ölçümlerini
# hatırlamasına dayanır ve birincil kayıt kadar güvenilir değildir.
# `CE_ENVELOPE_RECOVERY=0` ile kapatılabilir.
#
# Çıkış kodları:
#   0  aşama koştu ve zarf dosyası üretildi (kurtarma ile de olabilir)
#   1  kullanım hatası
#   2  `claude -p` sıfırdan farklı döndü
#   3  süreç 0 döndü, zarf üretilmedi ve KURTARMA da başarısız oldu
#      (aşama iş yapmış olabilir; betik ağacın değişip değişmediğini yazar)

set -euo pipefail

stage_name="${1:-}"
prompt_file="${2:-}"
envelope_file="${3:-}"
model="${4:-}"

if [ -z "$stage_name" ] || [ -z "$prompt_file" ] || [ -z "$envelope_file" ]; then
  echo "kullanım: run-phase.sh <asama-adi> <prompt-dosyasi> <zarf-dosyasi> [model]" >&2
  exit 1
fi

if [ ! -f "$prompt_file" ]; then
  echo "run-phase.sh: prompt dosyası yok: $prompt_file" >&2
  exit 1
fi

claude_bin="${CLAUDE_BIN:-claude}"
# Boş = projenin defaultMode'unu devral. Çağıran bilinçli olarak geçersiz kılar.
perm="${CLAUDE_PERM_MODE:-}"

log_dir="$(dirname "$envelope_file")"
mkdir -p "$log_dir"
log_file="$log_dir/${stage_name}.out"

# Bayat zarf, yeni koşumun eksik zarfını maskeler — önce sil.
rm -f "$envelope_file"

# Ağacın aşama ÖNCESİ parmak izi. Yalnız çıkış 3 yolunda kullanılır: eksik
# zarfın "hiçbir şey yapmadı" mı yoksa "kaydını bırakmadı" mı olduğunu
# çıkış kodu söyleyemez, bu söyler. Git yoksa/burası depo değilse boş kalır
# ve teşhis satırı "ölçülemedi" der (sessizce "değişmedi" DEMEZ).
tree_before=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tree_before="$(git status --porcelain 2>/dev/null)"
fi

prompt="$(cat "$prompt_file")"

echo "[ce-continuous-work] aşama '$stage_name' başlıyor (izin kipi: ${perm:-proje varsayılanı})" >&2
start_time=$(date +%s)

# Sabit oturum kimliği: zarf eksik kalırsa AYNI oturuma dönebilmek için şart.
# `--continue` yerine açık kimlik kullanılır — gözetimsiz turda aynı dizinde
# başka bir `claude -p` koşmuş olabilir ve "en son oturum" yanlış aşamayı
# yakalayabilir.
session_id="${CE_SESSION_ID:-}"
if [ -z "$session_id" ]; then
  if command -v uuidgen >/dev/null 2>&1; then
    session_id="$(uuidgen | tr 'A-Z' 'a-z' | tr -d '\r\n')"
  elif [ -r /proc/sys/kernel/random/uuid ]; then
    session_id="$(cat /proc/sys/kernel/random/uuid)"
  else
    session_id="$(python -c 'import uuid;print(uuid.uuid4())' 2>/dev/null || true)"
  fi
fi

cmd=("$claude_bin" -p)
[ -n "$model" ] && cmd+=(--model "$model")
[ -n "$perm" ] && cmd+=(--permission-mode "$perm")
[ -n "$session_id" ] && cmd+=(--session-id "$session_id")

set +e
"${cmd[@]}" "$prompt" >"$log_file" 2>&1
exit_code=$?
set -e

duration=$(( $(date +%s) - start_time ))

if [ "$exit_code" -ne 0 ]; then
  echo "[ce-continuous-work] aşama '$stage_name' HATA: claude -p çıkış $exit_code (${duration}s)" >&2
  echo "  günlük: $log_file" >&2
  exit 2
fi

# Eser denetimi — kayıtsız aşamayı burada yakalıyoruz.
# ÖNCE KURTARMA: iş bitmiş, yalnız kaydı eksikse aynı oturumdan istenir.
if [ ! -s "$envelope_file" ] \
   && [ "${CE_ENVELOPE_RECOVERY:-1}" != "0" ] \
   && [ -n "$session_id" ]; then
  echo "[ce-continuous-work] aşama '$stage_name' zarfsız bitti — oturum geri çağrılıyor" >&2
  recovery_log="$log_dir/${stage_name}.recovery.out"
  recovery_prompt="$(cat <<EOF
Bu oturumda az önce '$stage_name' aşamasını koştun ama SONUÇ ZARFINI yazmadın.

TEK GÖREV: zarfı şimdi yaz. Başka hiçbir iş yapma — kod değiştirme, test
koşma, doğrulama yapma. Yalnız BU OTURUMDA GERÇEKTEN yaptıklarını ve
ölçtüklerini kaydet.

Zarfı şu dosyaya SADECE JSON olarak yaz (başka metin yok):
$envelope_file

Bir alanı gerçekten ölçmediysen UYDURMA: bilinmiyorsa null ver ya da "notlar"
alanında ölçülmediğini yaz. Testleri yeniden koşma; koşmadığın bir doğrulamayı
"geçti" diye yazma. Zarfa ayrıca şu alanı ekle:

  "_envelope_recovered": true

Bu oturumda gerçekten iş yapmadıysan zarfı yazma — bunun yerine neden
yazmadığını tek cümleyle söyle. (Uydurulmuş bir kayıt, kayıt olmamasından
kötüdür.)

--- AŞAMANIN ÖZGÜN PROMPTU (şema burada; hatırlamana gerek yok) ---
$prompt
EOF
)"
  rcmd=("$claude_bin" -p --resume "$session_id")
  [ -n "$model" ] && rcmd+=(--model "$model")
  [ -n "$perm" ] && rcmd+=(--permission-mode "$perm")
  set +e
  "${rcmd[@]}" "$recovery_prompt" >"$recovery_log" 2>&1
  recovery_code=$?
  set -e
  if [ -s "$envelope_file" ]; then
    echo "[ce-continuous-work] zarf KURTARILDI → $envelope_file" >&2
    echo "  kurtarma günlüğü: $recovery_log" >&2
    echo "  NOT: zarf ikinci turda yazıldı (_envelope_recovered); alanları" >&2
    echo "  aşamanın kendi hatırladığına dayanır — kritik sayıları ağaçtan doğrula." >&2
    echo "[ce-continuous-work] aşama '$stage_name' tamam (${duration}s, kurtarma ile)" >&2
    exit 0
  fi
  echo "  kurtarma BAŞARISIZ (çıkış $recovery_code): $recovery_log" >&2
fi

if [ ! -s "$envelope_file" ]; then
  echo "[ce-continuous-work] aşama '$stage_name' KAYITSIZ: süreç 0 döndü ama zarf yazılmadı" >&2
  echo "  beklenen zarf: $envelope_file" >&2
  echo "  günlük: $log_file" >&2

  # Teşhis: aşama iş yaptı mı? Çıkış kodu bunu söyleyemez.
  if [ -z "$tree_before" ] && ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "  ağaç: ÖLÇÜLEMEDİ (git deposu değil) — 'değişmedi' sayma, elle bak" >&2
  elif [ "$(git status --porcelain 2>/dev/null)" != "$tree_before" ]; then
    echo "  ağaç: DEĞİŞTİ — aşama iş yaptı ama KAYDINI bırakmadı." >&2
    echo "  ne uygulandığı, doğrulanıp doğrulanmadığı ve hangi bulguların açık" >&2
    echo "  kaldığı BİLİNMİYOR: farkı elle oku, günlüğü incele, gerekirse aşamayı" >&2
    echo "  zarf kısıtı açıkça yazılmış bir promptla tekrar koş." >&2
  else
    echo "  ağaç: DEĞİŞMEDİ — aşama gerçekten hiçbir şey yapmadı" >&2
    echo "  olası sebep: bir araç çağrısı reddedildi ve aşama sessizce çıktı" >&2
    echo "  NOT: bu ölçüm gitignore'lu yolları GÖRMEZ (tur/state dizini dahil);" >&2
    echo "  aşama yalnız oraya yazdıysa burası yine 'DEĞİŞMEDİ' okur — günlüğe bak" >&2
  fi

  # Uyarı: ağaç 'değişmedi' okunsa bile aşamanın `claude -p` çocuğu hayatta
  # kalıp SONRA yazmaya başlayabilir. Bir sonraki aşamayı başlatmadan önce
  # ağacın durduğunu ölç.
  exit 3
fi

echo "[ce-continuous-work] aşama '$stage_name' tamam (${duration}s) → $envelope_file" >&2
exit 0
