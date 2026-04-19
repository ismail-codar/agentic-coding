# /doc Custom Command — Kurulum ve Kullanım (Kategorili Versiyon)

## 📦 Kurulum

`doc.md` dosyasını aşağıdaki konumlardan birine koy:

### Proje bazlı (takımla paylaşılır, git'e commit edilir — önerilen)
```
<proje-kok>/.claude/commands/doc.md
```

### Kullanıcı bazlı (tüm projelerinde kullanılır)
```
~/.claude/commands/doc.md
```

### Hızlı kurulum komutu
```bash
# Proje bazlı için:
mkdir -p .claude/commands
mv doc.md .claude/commands/doc.md

# Kullanıcı bazlı için:
mkdir -p ~/.claude/commands
mv doc.md ~/.claude/commands/doc.md
```

## 🗂️ Oluşturulan Klasör Yapısı

Komut çalıştıkça aşağıdaki yapı otomatik oluşur:

```
docs/claude/
├── flows/          → Uçtan uca akışlar (en yaygın kullanım)
├── modules/        → Modül/feature iç yapıları
├── architecture/   → Sistem geneli, mimari kararlar
├── integrations/   → Üçüncü parti servisler
└── runbooks/       → Operasyonel prosedürler
```

## 🚀 Kullanım

### Prefix ile (önerilen — net ve açık)

```
/doc flow: kullanıcı kayıt süreci ve email doğrulama
/doc module: payment servisi iç yapısı
/doc arch: genel sistem mimarisi ve katmanlar
/doc integration: Stripe ödeme entegrasyonu
/doc runbook: prod deploy süreci
```

### Prefix olmadan (Claude kategoriyi tahmin eder)

```
/doc auth login akışı
/doc Redis cache invalidation
/doc JWT token yapısı
```

Claude içeriğe bakar ve uygun kategoriye yerleştirir. Seçtiği kategoriyi yanıtta bildirir, yanlışsa yeniden `flow:` gibi bir prefix'le çalıştırabilirsin.

## 🏷️ Kategori Rehberi

| Prefix | Ne zaman kullan | Örnek konular |
|--------|-----------------|---------------|
| `flow:` | Bir işlemin uçtan uca nasıl çalıştığını anlatmak | login akışı, ödeme süreci, webhook işleme, kullanıcı kaydı |
| `module:` | Bir modülün/feature'ın iç yapısını belgelemek | auth modülü, notification servisi, cache katmanı |
| `arch:` | Sistem geneli hakkında konuşmak | katman yapısı, teknoloji seçimleri, kod organizasyonu |
| `integration:` | Dış bir servisle olan ilişkiyi belgelemek | Stripe, SendGrid, AWS S3, Twilio, OpenAI API |
| `runbook:` | "X olursa ne yap" prosedürleri | deploy, incident response, DB migration, rollback |

## 🔄 Sonraki Oturumlarda Kullanım

Üretilen dokümanı yeni bir Claude Code oturumunda context'e eklemek için:

```
@docs/claude/flows/19-04-2026_14-30-22 - auth-login-akisi.md

Bu akışa 2FA desteği ekleyelim
```

Birden fazla dokümanı birden ekleyebilirsin:

```
@docs/claude/flows/... - login.md
@docs/claude/modules/... - auth-modulu.md

Login akışında password reset adımını da entegre edelim
```

## 💡 Kullanım Önerileri

**Hangi kategori hangi sıklıkta oluşur?**

Tipik bir projede dağılım genelde şöyle olur:
- `flows/` — en çok (her feature için 1-2 tane)
- `modules/` — orta (modül sayısı kadar)
- `integrations/` — üçüncü parti servis sayısı kadar
- `arch/` — 1-3 tane (sistem değişene kadar stabil)
- `runbooks/` — operasyonel olgunluğa göre

**Parçalama stratejisi**

Karmaşık konuları tek dokümana tıkmak yerine bölün:
- ❌ `/doc flow: auth sistemi` (çok geniş)
- ✅ `/doc flow: auth login` + `/doc flow: auth logout` + `/doc flow: password reset` + `/doc module: auth modülü`

Her doküman odaklı olduğunda Claude sadece gerekeni context'e alır — token tasarrufu.

**Güncel tutma**

Kod değişince ilgili doküman outdated olur. İki yaklaşım:
1. Yeni `/doc` çalıştır, eski dosyayı sil (yeni tarih damgası zaten ayırt eder)
2. Eski dosyayı `_eski_DD-MM-YYYY` suffix'i ile arşivle

Front-matter'daki `commit` hash'i hangi commit'te üretildiğini söyler — doküman gerçekten eski mi anlamak için yardımcı olur.

**Index dosyası (opsiyonel)**

Dokümanlar çoğaldıkça `docs/claude/INDEX.md` dosyası ekle:
```markdown
# Dokümantasyon İndeksi

## Flows
- [Auth Login](flows/...) — kullanıcı login süreci
- [Payment](flows/...) — ödeme akışı

## Modules
- [Auth Module](modules/...) — kimlik doğrulama modülü
```

İleride `/doc-index` gibi ayrı bir komutla otomatikleştirilebilir.

## 📐 Tasarım Kararları (Neden Böyle?)

- **`docs/claude/` prefix'i:** Normal `docs/` klasörü kullanıcı/müşteri dokümantasyonu içindir. `docs/claude/` klasörü açıkça "bu Claude için üretilmiş iç doküman" anlamına gelir — karışıklık olmaz.
- **Kategoriye özel şablonlar:** Bir `flow` ile bir `integration` dokümanı farklı şeyleri vurgulamalı. Tek şablon zorlaması bölümleri boş bırakmaya yol açar.
- **Prefix opsiyonel:** Net istiyorsan prefix ver, üşeniyorsan bırak Claude karar versin. Her iki kullanım desteklenir.
- **`HH-mm-ss` (`:` değil):** Windows dosya sistemi `:` karakterini kabul etmez.
- **Front-matter `kategori` alanı:** Dosyaları kategoriye göre grep/filtre yapabilirsin (`grep -r "kategori: flow" docs/claude/`).
- **`allowed-tools` kısıtlaması:** Komut sadece okuma, arama, klasör oluşturma ve yazma yapabilir — kod değiştirme/silme yetkisi yok.

## 🎯 Eski Versiyondan Farkları

Tek klasörlü versiyona göre:
- ✅ Kategorili klasör yapısı (`docs/claude/flows/`, `modules/` vs.)
- ✅ Her kategoriye özel dokümantasyon şablonu (içerik farklı şeyleri vurguluyor)
- ✅ Prefix tabanlı routing + otomatik kategori tahmini
- ✅ Cross-cutting concerns, tipik request yaşam döngüsü gibi mimari-spesifik bölümler
- ✅ Webhook, retry stratejisi gibi entegrasyon-spesifik bölümler
- ✅ Rollback, ön koşullar gibi runbook-spesifik bölümler