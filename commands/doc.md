---
description: Kod tabanında belirtilen konuyu araştırır ve Claude'un sonraki oturumlarda hızlıca kavrayabilmesi için kategorisine uygun klasöre yapılandırılmış bir dokümantasyon dosyası oluşturur.
argument-hint: [flow:|module:|arch:|integration:|runbook:] <araştırılıp dokümante edilecek konu>
allowed-tools: Read, Grep, Glob, Bash(mkdir:*), Bash(date:*), Bash(git:*), Write
---

# Kod Dokümantasyon Komutu

Sen bu kod tabanının bir bölümünü derinlemesine inceleyip, **başka bir Claude oturumunun minimum ek araştırmayla iş yapabilmesini** sağlayacak yüksek kaliteli bir teknik dokümantasyon üreteceksin.

## Girdi

$ARGUMENTS

---

## Süreç

### 1. Kategori Tespiti

Girdinin başındaki prefix'e bakarak kategoriyi belirle:

| Prefix | Kategori | Klasör | Ne için |
|--------|----------|--------|---------|
| `flow:` | Akış | `docs/claude/flows/` | Uçtan uca bir işlem nasıl çalışır (auth login, ödeme akışı, webhook işleme) |
| `module:` | Modül | `docs/claude/modules/` | Belirli bir modül/feature'ın iç yapısı (payment servisi, notification modülü) |
| `arch:` | Mimari | `docs/claude/architecture/` | Sistem geneli, katmanlar, teknoloji seçimleri, desenler |
| `integration:` | Entegrasyon | `docs/claude/integrations/` | Üçüncü parti servislerle iletişim (Stripe, SendGrid, S3) |
| `runbook:` | Operasyon | `docs/claude/runbooks/` | "X durumunda ne yap" prosedürleri, deploy, debug kılavuzları |

**Prefix yoksa:** Girdinin içeriğine bakarak en uygun kategoriyi **sen seç**. Kararsız kaldığın durumlarda `flow` varsayılan kategoridir (en yaygın kullanım). Seçimini kullanıcıya özet bölümünde bildir.

Prefix'i çıkardıktan sonra kalan metin **araştırma konusudur**. Örnekler:
- `flow: auth login süreci` → kategori=flow, konu="auth login süreci"
- `Stripe webhook işleme` (prefix yok) → içeriğe bakarak muhtemelen kategori=flow veya integration seç

### 2. Hazırlık

Aşağıdaki komutları çalıştır (paralel):
- `date +"%d-%m-%Y_%H-%M-%S"` — dosya adı için zaman damgası
- `git rev-parse --show-toplevel 2>/dev/null || pwd` — proje kökü
- `git rev-parse --short HEAD 2>/dev/null || echo "no-git"` — mevcut commit hash
- `mkdir -p docs/claude/<kategori-klasörü>` — hedef klasörü oluştur

### 3. Araştırma

Konuyu kod tabanında sistematik olarak araştır. **Kategori araştırma odağını belirler:**

**`flow` için:**
- Giriş noktasını bul (route/controller/event handler)
- Adım adım fonksiyon çağrılarını izle
- Veri dönüşümlerini not et
- Yan etkileri (DB yazma, event emit, API çağrısı) tespit et

**`module` için:**
- Modülün dosya yapısını çıkar
- Public API'sini (export edilen fonksiyon/class'lar) listele
- İç bağımlılıkları haritala
- Diğer modüllerin bunu nasıl kullandığını bul

**`arch` için:**
- Katmanları tespit et (controller/service/repository vb.)
- Dizin yapısını ve konvansiyonları incele
- Framework/library seçimlerini not et
- Cross-cutting concern'leri bul (auth, logging, error handling)
- Config dosyalarını incele

**`integration` için:**
- Üçüncü parti client/SDK kullanımını bul
- Auth/credential yönetimini tespit et
- Request/response şekillerini çıkar
- Retry, timeout, error handling stratejilerini belirle
- Webhook endpoint'leri varsa onları da

**`runbook` için:**
- Deploy script'leri, CI/CD config'leri
- Environment değişkenleri
- Logging/monitoring noktaları
- Bilinen hata senaryoları ve çözümleri (kodda TODO/FIXME/HACK yorumlarına bak)

**Her kategoride geçerli:**
- Her bulguda `dosya_yolu:satır_no` formatında referans not al
- Testleri tara (davranışı netleştirir)
- Config/env değişkenleri
- Kenar durumları ve hata yönetimi

### 4. Dosya Adı

Format: `dd-MM-yyyy_HH-mm-ss - kısa-açıklama.md`

- Tarih kısmını `date` çıktısından al
- "kısa-açıklama": konuyu 3-6 kelimeyle özetleyen, türkçe karakter ve özel karakter içermeyen, kebab-case bir metin (örnek: `auth-login-akisi`, `odeme-webhook-islemi`)
- Hedef yol: `docs/claude/<kategori-klasörü>/<dosya_adi>.md`

### 5. Dokümantasyon Şablonu

**Tüm kategorilerde ortak olan bölümler** (Hızlı Referans başlığı, alt kısım) birebir kullanılır. **Ortada yer alan içerik bölümleri kategoriye göre değişir.**

#### 5a. Ortak Üst Kısım (Tüm Kategoriler)

```markdown
---
kategori: <flow | module | arch | integration | runbook>
konu: <konunun tek cümlelik özeti>
olusturulma: <dd-MM-yyyy HH:mm:ss>
commit: <git short hash>
ilgili_dosyalar:
  - <path/to/file1.ext>
  - <path/to/file2.ext>
anahtar_kelimeler: [kelime1, kelime2, kelime3]
---

# <Konu Başlığı>

## 🎯 Hızlı Referans (Quick Reference)

> **Bu bölüm bilinçli olarak kısa tutulmuştur. Bir Claude oturumu sadece bu bölümü okuyarak basit değişiklikler yapabilmelidir.**

[Kategoriye göre içerik — aşağıda]
```

#### 5b. Kategoriye Özel İçerik Bölümleri

**🔄 `flow` kategorisi için:**

```markdown
## 🎯 Hızlı Referans

- **Ne yapar:** <1-2 cümle>
- **Tetikleyici:** <ne başlatıyor — HTTP request, event, cron, user action>
- **Giriş noktası:** `<dosya:satır>` — `<fonksiyon adı>`
- **Son çıktı / yan etki:** <DB'ye ne yazılır, hangi event atılır, ne döndürülür>
- **Tek cümlelik akış:** A → B → C → D

## 📐 Mimari Konum

<Bu akış mimaride hangi katmanlarda geçiyor? 1-2 paragraf.>

## 🔄 Veri Akışı (Adım Adım)

1. **<Adım adı>** — `<dosya:satır>`
   - Ne olur: <açıklama>
   - Girdi: <tip/şekil>
   - Çıktı: <tip/şekil>

2. **<Adım adı>** — `<dosya:satır>`
   - ...

## 🗂️ Kritik Dosyalar

| Dosya | Sorumluluk | Dikkat |
|-------|-----------|--------|
| `<path>` | <ne yapar> | <gotcha> |

## 🧩 Tipler ve Veri Yapıları

<İmzalar ve alan açıklamaları>

## ⚠️ Kenar Durumları

- **<Durum>:** <ne olur, nasıl handle ediliyor> — `<dosya:satır>`

## 🔧 Tipik Değişiklik Senaryoları

- **Yeni bir <X> eklemek için:** `<dosya:satır>`'e ... ekle
- **<Y> davranışını değiştirmek için:** `<dosya:satır>`'i düzenle
```

**📦 `module` kategorisi için:**

```markdown
## 🎯 Hızlı Referans

- **Modülün sorumluluğu:** <1-2 cümle>
- **Konum:** `<modül kök klasörü>`
- **Public API (en kritik 3-5 export):**
  - `<fonksiyon/class>` — `<dosya:satır>` — <ne yapar>
- **Bağımlı olduğu modüller:** <liste>
- **Bunu kullanan modüller:** <liste>

## 🗂️ Dosya Yapısı

\`\`\`
module-root/
├── <dosya> — <sorumluluk>
├── <dosya> — <sorumluluk>
\`\`\`

## 🔌 Public API (Detaylı)

<Her önemli export için>
### `<export adı>` — `<dosya:satır>`
- **İmza:** `<signature>`
- **Ne yapar:** <açıklama>
- **Kullanım örneği:** <kısa örnek>

## 🧩 İç Yapı

<Modülün içsel organizasyonu. Alt katmanlar, helper'lar, state yönetimi.>

## 🧩 Tipler ve Veri Yapıları

## ⚠️ Kenar Durumları ve Gotcha'lar

## 🔧 Tipik Değişiklik Senaryoları

- **Modüle yeni bir <X> eklemek için:** ...
- **Public API'ye yeni bir endpoint/fonksiyon eklemek için:** ...
```

**🏛️ `arch` kategorisi için:**

```markdown
## 🎯 Hızlı Referans

- **Sistem tipi:** <monolith | modular monolith | microservices | serverless | ...>
- **Ana teknolojiler:** <dil, framework, DB, cache, queue>
- **Temel desen:** <MVC | Clean Architecture | Hexagonal | Event-Driven | ...>
- **Katman sayısı ve isimleri:** <controller → service → repository gibi>
- **Deploy hedefi:** <AWS/Vercel/Docker/bare metal>

## 📐 Katmanlar ve Sorumluluklar

| Katman | Konum | Sorumluluk | Örnek dosya |
|--------|-------|-----------|-------------|
| <isim> | `<path>` | <ne yapar> | `<dosya:satır>` |

## 🗂️ Dizin Yapısı ve Konvansiyonlar

\`\`\`
<proje kökünün üst seviye yapısı, yorumlarla>
\`\`\`

## 🔌 Cross-Cutting Concerns

<Auth, logging, error handling, validation, i18n gibi her yerde geçen konular. Nerede tanımlanmış, nasıl kullanılıyor?>

- **<concern>:** `<dosya:satır>` — <nasıl uygulanıyor>

## 🧰 Teknoloji Stack'i ve Seçim Gerekçeleri

<Her önemli teknoloji için: ne için kullanılıyor, alternatifi neden seçilmedi (kodda veya README'de ipucu varsa).>

## 🔄 Tipik Request Yaşam Döngüsü

<Bir HTTP request (veya event) geldiğinde hangi katmanlardan nasıl geçer? Üst düzey akış.>

## ⚠️ Mimari Kısıtlar ve Gotcha'lar

<"Şunu burada yapmayın", "bu katman şuna doğrudan erişemez" gibi.>

## 🔧 Tipik Değişiklik Senaryoları

- **Yeni bir endpoint eklemek için:** <hangi katmanlardan başla>
- **Yeni bir background job eklemek için:** ...
- **DB şemasında değişiklik için:** <migration süreci>
```

**🔗 `integration` kategorisi için:**

```markdown
## 🎯 Hızlı Referans

- **Servis:** <servis adı — Stripe, SendGrid, vs.>
- **Ne için kullanılıyor:** <1-2 cümle>
- **Client/SDK konumu:** `<dosya:satır>`
- **Auth yöntemi:** <API key | OAuth | JWT | ...>
- **Credential kaynağı:** <env değişkenleri — liste>
- **Giriş noktaları (bizim kodumuzdan dışarı çıkan yerler):**
  - `<dosya:satır>` — <hangi işlem>

## 🔐 Kimlik Doğrulama ve Credential Yönetimi

<Credential'lar nereden okunuyor, nasıl saklanıyor, rotate süreci var mı?>

## 📡 Kullanılan Endpoint'ler / SDK Metodları

| Endpoint / Metod | Ne için | Nerede çağrılıyor |
|------------------|---------|-------------------|
| `<POST /charges>` veya `<stripe.charges.create>` | <amaç> | `<dosya:satır>` |

## 📥 Gelen Çağrılar (Webhooks)

<Varsa: bu servis bize hangi webhook'ları gönderiyor, nerede karşılanıyor.>

- **<event tipi>** — endpoint: `<path>` — handler: `<dosya:satır>`
- Webhook signature doğrulama: `<dosya:satır>`

## 🧩 Veri Eşlemeleri

<Kendi domain modelimizle üçüncü parti model arasındaki map'ler. Örneğin bizim `User.id` ↔ Stripe `customer_id`.>

## 🔄 Retry, Timeout, Rate Limit Stratejileri

<Hatalar nasıl karşılanıyor, retry var mı, kaç kere, exponential backoff mu?>

## ⚠️ Bilinen Sorunlar ve Gotcha'lar

- <örn. "Stripe test modunda bu davranış farklıdır", "webhook idempotency key şurada tutuluyor">

## 🔧 Tipik Değişiklik Senaryoları

- **Yeni bir endpoint'i çağırmak için:** ...
- **Yeni bir webhook event'i handle etmek için:** ...
- **Credential rotate etmek için:** ...
```

**🛠️ `runbook` kategorisi için:**

```markdown
## 🎯 Hızlı Referans

- **Konu:** <ne için runbook — deploy, incident response, maintenance>
- **Ne zaman kullanılır:** <tetikleyici durum>
- **Tahmini süre:** <dakika/saat>
- **Gereken yetkiler:** <admin access, DB access, vs.>
- **Risk seviyesi:** <düşük | orta | yüksek>

## 📋 Ön Koşullar

- [ ] <gerekli şey 1>
- [ ] <gerekli şey 2>

## 🚶 Adım Adım Prosedür

1. **<Adım>** 
   - Komut/Aksiyon: `<komut>` veya <yapılacak iş>
   - Beklenen çıktı: <ne görmeliyiz>
   - Başarısızsa: <fallback>

2. **<Adım>**
   - ...

## 🔍 Doğrulama

<İşlem sonrası her şeyin yolunda olduğunu nasıl kontrol ederiz?>

- <kontrol 1>: `<komut veya URL>`
- <kontrol 2>: ...

## ⏮️ Rollback / Geri Alma

<Yanlış giderse nasıl geri alınır?>

## ⚠️ Bilinen Hatalar ve Çözümleri

| Hata / Belirti | Olası Sebep | Çözüm |
|---------------|-------------|-------|
| <mesaj> | <sebep> | <ne yap> |

## 📂 İlgili Dosya ve Config'ler

- `<dosya:satır>` — <rol>
```

#### 5c. Ortak Alt Kısım (Tüm Kategoriler)

```markdown
## 🔌 Bağımlılıklar

**İç bağımlılıklar:**
- `<modül/dosya>` — <neden kullanılıyor>

**Dış bağımlılıklar (paketler):**
- `<paket adı>` — <ne için>

**Ortam değişkenleri (env):**
- `VAR_ADI` — <ne için, zorunlu mu?>

## 🧪 Testler

<Varsa test dosyalarının konumu ve ne kapsadığı. Yoksa "Bu alan için test bulunmamaktadır" yaz.>

- `<test dosyası>` — <kapsadığı senaryolar>

## 📝 Notlar

<Varsayımlar, bilinen limitasyonlar, TODO'lar, refactor adayları, tarihsel context. Opsiyonel.>

---

*Bu doküman `/doc` komutu ile otomatik üretilmiştir. Kategori: `<kategori>`. Kod değiştiğinde güncellenmelidir.*
```

### 6. Yazım Kalitesi Kuralları

- **Spesifik ol, genel olma.** "Auth işlemleri yapar" yerine "JWT doğrular, `req.user` set eder, 401 döner"
- **Dosya referansı olmadan iddia yapma.** Her teknik detay `dosya:satır` ile desteklenmeli
- **Kodun kopyasını çıkarma.** Uzun kod blokları yerine satır referansları ver
- **Boş bölümleri atla veya "Bu alanda veri yok" yaz** — şablonu boş placeholder'larla doldurma
- **Türkçe yaz** — kullanıcının dili Türkçe
- **Emoji'leri başlıklarda koru** — görsel tarama hızı için

### 7. Dosyayı Yaz

Dosyayı `docs/claude/<kategori-klasörü>/<dosya_adi>.md` yoluna Write tool ile kaydet.

### 8. Özet Sun

Yanıt olarak kullanıcıya şunu göster:
- 🏷️ **Seçilen kategori** ve (prefix verilmediyse) neden bu kategoriyi seçtiğin
- ✅ Oluşturulan dosyanın tam yolu
- 📊 Araştırmada incelenen dosya sayısı
- 🎯 Dokümantasyonun "Hızlı Referans" bölümünün içeriği
- 💡 Sonraki oturumlarda bu dosyayı `@docs/claude/<kategori>/<dosya>.md` ile context'e ekleyebileceğini hatırlat