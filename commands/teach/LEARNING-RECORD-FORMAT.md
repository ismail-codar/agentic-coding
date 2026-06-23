# Öğrenme Kaydı Formatı

Öğrenme kayıtları `./learning-records/` dizininde yer alır ve sıralı numaralandırma kullanır: `0001-slug.md`, `0002-slug.md` vb. Dizini ihtiyaç anında oluştur — yalnızca ilk kayıt yazıldığında.

Bunlar öğretimin ADR'lerine (mimari karar kayıtlarına) denktir: aşikâr olmayan dersleri, kilit içgörüleri ve belirtilen ön bilgileri yakalar; bunlar gelecekteki seansları yönlendirir. En yakın gelişim alanını (zone of proximal development) hesaplamak için kullanılır.

## Şablon

```md
# {Öğrenilen veya tespit edilen şeyin kısa başlığı}

{1-3 cümle: ne öğrenildi (veya hangi ön bilgi tespit edildi) ve bunun gelecekteki seanslar için neden önemli olduğu.}
```

Formatın tamamı budur. Bir öğrenme kaydı tek bir paragraftan ibaret olabilir. Değer, bölümleri doldurmakta değil; bu şeyin artık bilindiğini ve bunun bundan sonra ne öğretileceğini neden değiştirdiğini kaydetmektedir.

## İsteğe bağlı bölümler

Bunları yalnızca gerçek bir değer kattıklarında ekle. Çoğu kayıt bunlara ihtiyaç duymaz.

- **Status** frontmatter'ı (`active | superseded by LR-NNNN`) — daha önceki bir anlayışın yanlış çıkıp yenisiyle değiştirildiği durumlarda yararlıdır.
- **Evidence (Kanıt)** — kullanıcının anlayışını nasıl gösterdiği (yanıtlanan bir soru, tamamlanan bir alıştırma, anılan önceki deneyim). İddianın ileride yeniden ele alınma ihtimali varsa yararlıdır.
- **Implications (Çıkarımlar)** — bunun gelecekteki seanslar için neyi açtığı veya neyi devre dışı bıraktığı. Aşikâr olmadığında kaydetmeye değer.

## Numaralandırma

`./learning-records/` dizinini tara, en yüksek mevcut numarayı bul ve bir artır.

## Ne zaman öğrenme kaydı yazılmalı

Aşağıdakilerden herhangi biri doğru olduğunda bir tane yaz:

1. **Kullanıcı, önemsiz olmayan bir şeyi gerçekten anladığını gösterdi** — yalnızca konuya maruz kalmak değil, kavramı doğru kullanabildiğine dair kanıt. Bu, bundan sonra ne öğretileceğine dair yeni bir taban belirler.
2. **Kullanıcı ön bilgisini açıkladı** — "X'i zaten biliyorum." Bunu kaydet ki gelecekteki seanslar onu yeniden öğretmesin. Ayrıca iddia edilen _derinliği_ de kaydet.
3. **Bir yanlış anlama düzeltildi** — kullanıcı daha önce yanlış bir şeye inanıyordu ve artık nedenini görüyor. Bunlar yüksek değerlidir: ilgili konularda gelecekteki takılma noktalarını önceden haber verir.
4. **Misyon, öğrenmenin sonucunda değişti** — kullanıcı, sandığından farklı bir şeyi önemsediğini keşfetti. [[MISSION.md]] dosyasına çapraz bağlantı ver ve onu güncelle.

### Neler nitelik taşımaz

- Yalnızca üzerinden geçilmiş materyal. Üzerinden geçmek öğrenmek değildir. Kanıt için bekle.
- [[GLOSSARY.md]] içinde bir terim tanımı olarak zaten kısaca yakalanmış olan her şey. Tekrar etme.
- Seans seans etkinlik günlükleri. Öğrenme kayıtları bir günlük değildir — karar düzeyinde içgörülerdir.

## Yerini alma (Supersession)

Sonraki bir kayıt öncekiyle çeliştiğinde (kullanıcının anlayışı derinleşti veya düzeldi), eski kaydı silmek yerine `Status: superseded by LR-NNNN` olarak işaretle. Anlayışın nasıl evrildiğinin tarihçesi, kendi başına yararlı bir sinyaldir.
