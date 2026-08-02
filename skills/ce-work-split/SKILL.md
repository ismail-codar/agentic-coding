---
name: ce-work-split
description: Üçe bölünmüş bir planın (`.md` + `.contract.md` + `.units.md`) tek fazını /ce-work ile çalıştırır. Verilen faz etiketini planın "Fazlar" tablosundan çözer, yalnız contract + o fazın ünitelerini yükletir ve sadece o fazı uygulatır. Faz etiketi verilmezse planı önce üçe böler, üniteleri bağımlılık DAG'ına göre fazlara ayırır ve onaydan sonra Faz 1'i başlatır. Uzun /ce-work talimatını elle yazmaya alternatif kısayol.
argument-hint: "<plan .md yolu> [<Faz N>]   (faz verilmezse: böl + fazla + Faz 1'i başlat)"
---

# ce-work-split

Bölünmüş planı **faz faz** yürütmek için ince sarmalayıcı. Kullanıcının uzun
`/ce-work ... — Bu split plan. contract.md'yi yükle; units.md'den Faz X ...`
talimatını yazmasına gerek kalmadan, faz etiketinden üniteleri çözüp `ce-work`'e
devreder.

İki mod var:

- **Faz etiketi verildi** → doğrudan o fazı çözüp devret (adım 1-2-6-7-8).
- **Faz etiketi verilmedi** → plan zaten tek oturumluksa uyar ve çık (adım 3);
  değilse gerekiyorsa üçe böl (adım 4), üniteleri bağımlılık DAG'ına göre fazla
  ve tabloyu plana yaz (adım 5), tabloyu göster, onay al, Faz 1'i devret
  (adım 6-7-8).

## Kullanım

```text
/ce-work-split <plan .md yolu> [<Faz etiketi>]
```

Örnekler:

```text
/ce-work-split docs/plans/2026-07-31-003-feat-seed-roundtrip-source-coverage-plan.md Faz 1
/ce-work-split docs/plans/2026-07-31-003-feat-seed-roundtrip-source-coverage-plan.md
```

## Adımlar

### 1. Argümanları ayrıştır

- İlk token = plan **index** dosyası yolu (`<plan>.md`). Zorunlu; yoksa dur ve
  kullanımı göster.
- Kalan token(ler) = faz etiketi (`Faz 1`, `faz1`, `1`, `Phase 1` — hepsi
  kabul; normalize et: sondaki sayı faz numarasıdır). **Opsiyonel.**
- Faz etiketi yerine `böl` / `force` tokenı verilebilir: faz etiketi verilmemiş
  sayılır ama adım 3'ün tek-faz eşiği atlanır (küçük planı yine de böler).
- Verilen yol `.md` ile bitmiyorsa (örn. yanlışlıkla `.contract.md`/`.units.md`
  verilmişse) `.md` index'e düzelt. Dosya yoksa dur.

### 2. Parça yollarını türet ve doğrula

`<plan>.md` → `<plan>.contract.md` ve `<plan>.units.md` (yalnız `.md` sonekini
değiştir). Üçünün de var olup olmadığını kontrol et.

- Üçü de varsa → bölünmüş plan. Adım 4'ü atla.
- `.contract.md` veya `.units.md` eksikse:
  - **faz etiketi verildiyse** → bu bölünmüş plan değil: kullanıcıya bildir,
    düz `/ce-work <plan>` öner, dur.
  - **faz etiketi verilmediyse** → adım 3'e geç.

### 3. Tek faz yeterliyse uyar ve çık (yalnız faz etiketi verilmemişken)

Bölme ve fazlama **maliyetlidir** (plan dosyalarını yeniden yazar, çoklu oturum
gerektirir). Küçük planlarda bu maliyet kazandırdığı token'dan fazladır. Ölç:

- **satır sayısı** — plan parçalarının toplamı (`wc -l`),
- **ünite sayısı** — `### U<n>.` başlıkları.

**Eşik:** satır < 1000 **ve** ünite ≤ 3 ise plan tek oturumda yürütülebilir.
Bu durumda hiçbir şey yapma — bölme yok, fazlama yok, `ce-work` çağrısı yok.
Şunu bas ve dur:

```text
Plan tek fazda yürütülebilir (<N> satır, <M> ünite; eşik: 1000 satır / 3 ünite).
Bölme ve fazlama token kazandırmaz. Doğrudan çalıştır:

  /ce-work <plan>.md

Yine de bölmek istersen zorla:
  /ce-work-split <plan>.md böl
```

Eşiğin iki koşulu da **ve** ile bağlıdır: 400 satırlık 6 üniteli bir plan da,
1500 satırlık 2 üniteli bir plan da bölünmeye değer. Eşik aşılıyorsa adım 4'e
geç.

### 4. Otomatik bölme (yalnız faz etiketi verilmemişken)

Tek dosyalık planı `docs/standards/split-plan-format.md` düzenine göre üçe böl.
**Bölme taşımadır, yeniden yazma değil**: bölümler kelimesi kelimesine taşınır;
metin özetlenmez, kısaltılmaz, yeniden ifade edilmez. Tek eklenen şey
frontmatter, başlık ve çapraz-referans işaretçileridir.

Önce planı TAM oku, sonra bölümleri dağıt:

| Parça | İçerik |
|---|---|
| `<plan>.md` (index — yerinde kalır) | Summary, Problem Frame, Goals / Non-Goals, High-Level Technical Design, Scope Boundaries, Risks, Open Questions, Sources & Research, Deferred / Open Questions + **faz haritası** |
| `<plan>.contract.md` (sözleşme — her ünite oturumunda yüklenir) | Requirements (Rn), Key Technical Decisions (KTD-n), artefakt/şema sözleşmeleri, signal model, Verification Contract, Definition of Done |
| `<plan>.units.md` (üniteler) | `## Implementation Units` gövdeleri + **Fazlar** tablosu + **DAG** |

Frontmatter (her iki yeni parçaya; `part` değeri `contract` / `units`):

```yaml
---
artifact_contract: ce-unified-plan/v1
part: units
parent_plan: docs/plans/<plan>.md
type: <index'teki type>
title: "<index'teki title> — UYGULAMA ÜNİTELERİ"
created: <index'teki created>
---
```

Bölmeden sonra:

- Index'ten taşınan bölümlerin yerine tek satırlık işaretçi bırak (örn.
  `> Requirements ve KTD sözleşme katmanındadır: <plan>.contract.md`).
- `units.md` başına yükleme notu koy: "Bir fazı uygularken yalnız o fazın
  ünitelerini + `<plan>.contract.md`'yi yükle."
- Bölme kayıpsızlığını doğrula: orijinal `##` başlıklarının hepsi üç parçadan
  birinde olmalı. Kayıp varsa dur ve bildir.

### 5. Fazları türet ve plana yaz (Fazlar tablosu yoksa)

`units.md`'de zaten bir **"Fazlar"** tablosu (veya eski konvansiyonda "oturum
grupları" tablosu) varsa bu adımı atla — mevcut tablo otoritedir.

Yoksa türet:

**5a. Üniteleri ve bağımlılıkları çıkar.** Her `### U<n>.` ünitesi için:

- **Bağımlılık alanı** — şu etiketlerden hangisi varsa: `**Dependencies.**`,
  `**Bağımlılıklar:**`, `**Bağımlılık:**`, `Depends on:`. `—`, `yok`, `none`
  → bağımlılık yok.
- **Dosya kümesi** — `**Files.**` listesindeki yollar (faz içi paralellik
  kararı için).
- **Paket** — dosya yollarının ortak kök dizini.

**5b. Açık sıra beyanı bağlayıcıdır.** Plan gövdesinde "Yürütme sırası: U1 → U2
→ U4 → U3 → ..." gibi bir sıra cümlesi varsa, o sıra **türetilen DAG'ı ezer**:
beyandaki her ardışık çift için bir kenar ekle. Böyle bir beyan genelde bir
gerekçeyle konur (örn. kalibrasyon, mühürlemeden önce koşmalı); türetim onu
bozamaz. Gerekçe cümlesini faz tablosunun altına not olarak taşı.

**5c. Katmanla.** Kahn topolojik katmanlaması: katman 0 = bağımlılığı olmayan
üniteler; katman *n* = tüm bağımlılıkları ≤ *n-1* katmanlarda olan üniteler.
Her katman bir fazdır. Döngü bulunursa dur ve döngüdeki üniteleri bildir.

**5d. Faz içi paralellik.** Aynı fazdaki üniteler:

- dosya kümeleri kesişmiyorsa → `U1‖U2` (paralel subagent'a dağıtılabilir),
- kesişiyorsa → `seri: U1 → U2` (ünite numarası sırası),
- tek üniteyse → `tekil`.

**5e. Token bütçesi.** Bir faz 4'ten fazla ünite ya da kabaca 800 satırdan uzun
ünite gövdesi içeriyorsa, o katmanı ünite numarası sırasına göre `Faz 2a` /
`Faz 2b` olarak böl (aralarındaki sıra bağlayıcı değildir, yalnız oturum
bölmesidir) ve bunu tablo altında belirt.

**5f. Yaz.** `units.md`'ye `## Implementation Units`'ten **önce** şu bölümü
ekle:

````markdown
## Fazlar

Üniteler bağımlılık DAG'ının topolojik katmanlarına göre fazlara ayrılır. Aynı
fazdaki bağımsız üniteler paralel çalıştırılabilir; fazlar arası sıra
bağlayıcıdır. Oturum başına `<plan>.contract.md` + yalnız o fazın üniteleri
yüklenir.

| Faz | Üniteler | Paket(ler) | Girdi bağımlılığı | Faz içi paralellik |
|---|---|---|---|---|
| **Faz 1 — <kısa ad>** | U1, U2 | `<paket>` | yok | U1‖U2 (dosya kesişimi yok) |
| ... | | | | |

> Türetim kaynağı: ünitelerin bildirdiği bağımlılıklar<, ve "Yürütme sırası"
> beyanı>. <Beyanın gerekçesi.>

### DAG

```text
U1 ──┬── U3 ── U5
U2 ──┘
```
````

Faz adı, o fazın ünitelerinin `**Goal.**` satırlarından türetilen 2-4 kelimelik
bir özet olsun (örn. "Saf çekirdek", "Kapı ve rapor").

Aynı tabloyu index `<plan>.md` içine de **faz haritası** olarak ekle (tek
kaynak korunur: index'te yalnız `| Faz | Üniteler | Girdi bağımlılığı |`
sütunları + `units.md`'ye işaretçi).

### 6. Fazı üniteye çöz

`<plan>.units.md` içindeki **"Fazlar"** tablosunu oku (adım 5 yeni yazdıysa
onu). Hedef faz:

- Faz etiketi verildiyse → o faz. Tabloda yoksa: mevcut faz etiketlerini
  listele ve dur.
- Verilmediyse → **Faz 1** (tablodaki ilk satır).

O fazın **ünite listesini** (U-ID'ler) ve faz-içi sıra/paralellik notunu çıkar.
Eski konvansiyonlu planlarda "Fazlar" yerine "oturum grupları" tablosu varsa,
grup etiketini (A–F) faz gibi kabul et.

**Onay (yalnız faz etiketi verilmemişken).** Türetilen faz tablosunu kullanıcıya
bas ve devam onayı iste: "Bu bölüm doğruysa Faz 1'i `/ce-work` ile başlatıyorum."
Kullanıcı fazlamayı düzeltirse tabloyu `units.md`'de güncelle, sonra devret.
Faz etiketi açıkça verilmişse onay isteme — doğrudan devret.

### 7. ce-work'e devret

`ce-work` skill'ini (Skill aracı; namespace gerekiyorsa
`compound-engineering:ce-work`) şu input ile çağır — köşeli parantezleri gerçek
değerlerle doldur:

```text
<plan>.md — Bu üçe bölünmüş (split) bir plandır. Sözleşme katmanı
<plan>.contract.md dosyasını TAM yükle. <plan>.units.md dosyasından YALNIZ
<Faz etiketi> ünitelerini (<U-ID listesi>) yükle; diğer üniteleri okuma. Bu
oturumda YALNIZCA bu fazı uygula. Faz-içi sıra/paralellik: <not>. Fazlar arası
bağımlılık sırası bağlayıcıdır; bu fazın girdi-bağımlısı önceki fazlar
tamamlandı varsay. Proje CLAUDE.md gereği kod incelemesi (`ce-code-review`) ve
token/ajan maliyeti yüksek çok-ajanlı / toplu-ajan adımlarını OTOMATİK başlatma
— o adımlara gelince önce kullanıcıya sor. Commit/push yalnız kullanıcı
isterse.
```

Bundan sonra `ce-work`'ün akışı devralır (branch kurulumu, task listesi, faz
ünitelerinin uygulanması, doğrulama). Bu skill yalnız girdi hazırlar; kendi
başına kod yazmaz veya commit atmaz.

### 8. Faz bitince /clear hatırlat

`ce-work` bu fazı tamamlayıp döndüğünde, kullanıcıya bir sonraki faza taze
context ile girmesi için şu hatırlatmayı bas (sonraki faz varsa):

```text
Faz <X> tamamlandı. Bir sonraki faza (Faz <X+1>) geçmeden önce context'i
/clear ile temizle, sonra: /ce-work-split <plan>.md Faz <X+1>
```

`/clear`'ı **skill çalıştıramaz** — o istemci tarafı bir komuttur ve context'i
(skill talimatı dahil) siler. Temizleme fazlar arası kullanıcı eylemidir; skill
yalnız hatırlatır. Son fazdan sonra hatırlatma basma.

## Notlar

- Faz haritası ve bağımlılıklar plandaki "Fazlar" tablosunun otoritesidir;
  buraya faz içeriği gömme (drift olur) — her çağrıda tablodan taze oku.
  Otomatik türetim (adım 5) yalnız tablo **yokken** çalışır; var olan tabloyu
  asla yeniden türetmez.
- Bölme ve fazlama plan dosyalarını değiştirir. Kod değiştirmez, commit atmaz —
  git'e yazma kararı kullanıcınındır.
- Bir sonraki fazı çalıştırmadan önce oturum context'ini `/clear` ile sıfırla:
  her faz taze context ile token-verimlidir. Örnek uçtan uca komut listesi:
  `docs/solutions/workflow-issues/faz-faz-ce-work-plan-yurutme.md`.
- Farklı pakette olup erken tamamlanabilen üniteler (örn. bağımsız audit
  ünitesi) tablodaki nota göre kendi fazından ayrı da koşulabilir; varsayılan
  olarak tabloya uy.
