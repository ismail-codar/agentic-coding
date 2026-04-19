## Görev: Mevcut Planı Güncelle

Verilen klasördeki planı kullanıcının isteğine göre **minimal** değişiklikle revize et.

### Adımlar:

1. `$ARGUMENTS` argümanını parse et:
   - Format: `plans/<klasor> <değişiklik isteği>`
   - Eğer sadece klasör verilmişse kullanıcıdan değişiklik isteğini sor

2. Mevcut dosyaları oku:
   - `plans/<klasor>/prompt.md`
   - `plans/<klasor>/spec.md`
   - `plans/<klasor>/implementation.md`

3. Değişikliğin kapsamını belirle:
   - Sadece `implementation.md` mi etkiliyor? (ör: adım sırası, ek bir dosya)
   - `spec.md`'yi de etkiliyor mu? (ör: yeni gereksinim, kapsam değişikliği)
   - Her ikisini de baştan mı değiştiriyor? (ör: tamamen farklı yaklaşım)

   Kapsama göre yalnızca etkilenen dosyaları güncelle.

4. Yalnızca etkilenen dosyaları güncelle:
   - Değişmeyen hiçbir maddeye dokunma
   - Ekleme/çıkarma/güncelleme yapılan satırları minimal tut

5. `progress.md` dosyasını kontrol et ve güncelle:
   - Dosya **yoksa**: bir şey yapma
   - Dosya **varsa**:
     - `[x]` işaretli adımları gözden geçir
     - Değişiklikten **etkilenmeyen** tamamlanmış adımlara dokunma
     - Değişiklikten **etkilenen** `[x]` adımları şu şekilde güncelle:
       ```
       - ⚠️ revize edildi | Adım N: <açıklama> → <ne değişti, bir satırda>
       ```
     - Yeni eklenen adımları `[ ] (yeni)` olarak ekle:
       ```
       - [ ] (yeni) Adım N: <açıklama>
       ```
     - Kaldırılan adımları `~~` ile üstünü çiz ve `(kaldırıldı)` ekle:
       ```
       - ~~[x] Adım N: <açıklama>~~ (kaldırıldı)
       ```

6. `prompt.md` dosyasına revizyon ekle:
   ```
   ---
   ## Revizyon - <tarih saat>
   <değişiklik isteği>
   ```

7. Kullanıcıya çıktı ver:
   - Hangi dosyaların değiştiğini belirt
   - Neyin eklenip neyin çıkarıldığını kısaca özetle
   - `progress.md` güncellendiyse kaç adımın etkilendiğini söyle
   - Şu mesajı yaz:
     `Plan güncellendi. Hazır olduğunda /plan:implement plans/<klasor> komutunu çalıştır.`

### Önemli:
- **Değişiklik ne kadar küçükse, o kadar az dosyaya dokun**
- Kullanıcı yeni istek vermemişse tahmin yürütme, sor
- Revizyon geçmişini `prompt.md`'de koru
- `progress.md` güncellenirken tamamlanmış ama etkilenmeyen adımlar kesinlikle korunur