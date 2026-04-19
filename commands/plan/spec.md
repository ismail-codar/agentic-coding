## Görev: Plan Oluştur

Kullanıcının isteğine göre bir plan klasörü oluştur ve aşağıdaki dosyaları hazırla.

### 1) Klasör oluştur
Şu formatta bir klasör oluştur:

`plans/DD.MM.YYYY HH_MM_SS - kisa-aciklama`

Tarih için:
```bash
date '+%d.%m.%Y %H_%M_%S'
````

`kisa-aciklama`:

* Promptu 2-3 kelimeyle özetle
* Promptun diline uygun yaz
* Küçük harf kullan
* Boşluk yerine `-` kullan

Örnek:

* `plans/04.01.2025 14_23_45 - kullanici-giris-formu`
* `plans/04.01.2025 14_23_45 - api-rate-limiting`

### 2) prompt.md oluştur

Dosya: `plans/<klasor>/prompt.md`

İçerik:

* Kullanıcının promptunu aynen yaz

### 3) spec.md oluştur

Dosya: `plans/<klasor>/spec.md`

İçerik:

* **Amaç**
* **Kapsam**
* **Gereksinimler**
* **Kısıtlamalar**
* **Başarı kriterleri**

Kısa, net ve uygulanabilir yaz.

### 4) implementation.md oluştur

Dosya: `plans/<klasor>/implementation.md`

İçerik:

1. Adım adım uygulama planı
2. Her adım için:

   * yapılacak iş
   * ilgili dosya/modül
   * tahmini efor
3. Bağımlılıklar ve sıralama
4. Dikkat edilmesi gereken noktalar

### 5) Kullanıcıya çıktı ver

Oluşturulan klasör yolunu paylaş ve şu mesajı yaz:

`Plan hazır. İstersen plans/<klasor>/ içindeki dosyaları düzenleyebilirsin. Hazır olduğunda /plan:implement plans/<klasor> komutunu çalıştır.`

Konu: $ARGUMENTS