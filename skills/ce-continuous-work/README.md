# ce-continuous-work

Bir `ce-plan` planını gözetimsiz, uçtan uca uygulayan skill. Ayrıntı:
`SKILL.md`. Bu dosya yalnız **kurulum**u anlatır.

## Kurulum

### Global (her projede)

```bash
cp -r skills/ce-continuous-work ~/.claude/skills/ce-continuous-work
```

Skill `~/.claude/skills/` altından yüklenir; `run-phase.sh` yolunu kendisi
çözer (önce proje kopyası, sonra global kopya).

### Proje bazlı (global kopyayı gölgeler)

```bash
cp -r skills/ce-continuous-work <proje>/.claude/skills/ce-continuous-work
```

## Proje uyarlaması

Zorunlu değil; eksik alanlar algılanır (`SKILL.md` → "Proje uyarlaması").
Algılama tutmayan ya da varsayılanı beğenmeyen proje `.claude/ce-continuous-work.json`
yazar — örnek: `SKILL.md` → "Yapılandırma dosyası".

İki ön koşul **algılanamazsa tur durur**:

- `test_command` — tam test komutu. `make test`,
  `package.json` `scripts.test`, `pytest`, `cargo test`, `go test ./...`
  denenir; hiçbiri yoksa yazılmalı.
- `state_dir` (varsayılan `out/continuous-work/`) **gitignore'lu** olmalı.

## Proje CLAUDE.md'ye muafiyet satırı

Proje `CLAUDE.md`'si otomatik inceleme/commit/push'u yasaklıyor ve yazılı
muafiyet listesi tutuyorsa şu satırı ekle:

```markdown
- `/ce-continuous-work <plan> [low|middle|high]` — kullanıcı tetikler; tur
  içinde `ce-doc-review`/`ce-work`/`ce-code-review`/`ce-compound`/`ce-commit`,
  push ve ana dala merge önceden yetkilidir, `AskUserQuestion` çağrılmaz.
```

## Çevre değişkenleri (`run-phase.sh`)

| değişken | etki |
|---|---|
| `CLAUDE_BIN` | `claude` yerine kullanılacak ikili |
| `CLAUDE_PERM_MODE` | alt sürece `--permission-mode` (boş = proje varsayılanı) |
| `CE_SESSION_ID` | sabit oturum kimliği (boşsa üretilir) |
| `CE_ENVELOPE_RECOVERY=0` | zarf kurtarma (`--resume`) geçişini kapat |
| `CE_HEARTBEAT_SECS` | nabız aralığı, saniye (varsayılan 600; `0` = kapalı) |
| `CE_PROGRESS_LOG` | ilerleme günlüğü (varsayılan `<zarf-dizini>/progress.log`) |
| `CE_STREAM=0` | `stream-json` yerine düz metin koşum (nabızda "son işler" olmaz) |

`with-heartbeat.sh <etiket> -- <komut>` aynı nabzı ana oturumdaki uzun
komutlara (test kapısı) uygular. Konsola taşıma `Monitor` ile yapılır —
`SKILL.md` → "İlerleme bildirimi".
