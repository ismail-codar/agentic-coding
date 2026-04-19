## Görev: Planı Uygula

Verilen klasördeki `implementation.md` dosyasını oku ve uygula.

### Adımlar:

1. `$ARGUMENTS/implementation.md` dosyasını oku
2. `$ARGUMENTS/spec.md` dosyasını oku (bağlam için)

3. `$ARGUMENTS/progress.md` dosyasını kontrol et:
   - Dosya **yoksa**: tüm adımları baştan uygula
   - Dosya **varsa**: `[x]` işaretli adımları atla, ilk `[ ]` adımından itibaren devam et
   - `⚠️ revize edildi` işaretli adımları yeniden uygula (önceki uygulama geçersiz)

4. Uygulamaya başlamadan önce kullanıcıya şunu söyle:
   - Kaç adım var, hangisinden başlanıyor
   - Örnek: `"Toplam 6 adım. 3. adımdan devam ediliyor."`

5. Her adımı tamamladıktan sonra:
   - Kısa durum raporu ver
   - `$ARGUMENTS/progress.md` dosyasını güncelle:
     - Tamamlanan adımı `[x]` olarak işaretle
     - Henüz yapılmayanlar `[ ]` olarak kalsın

6. Tüm adımlar bitince özet sun ve `progress.md`'yi tamamlandı olarak kapat:
   ```
   ## Durum: TAMAMLANDI
   Tarih: <tarih saat>
   ```

### progress.md Formatı:

```
## Progress
Son güncelleme: <tarih saat>

- [x] Adım 1: <açıklama> (tamamlandı)
- [x] Adım 2: <açıklama> (tamamlandı)
- [ ] Adım 3: <açıklama>
- [ ] Adım 4: <açıklama>
```

### Önemli:
- Hiçbir `[ ]` adımı atlamadan uygula
- `[x]` adımları tekrar çalıştırma, zaman kaybı ve yan etki riski var
- `⚠️ revize edildi` adımları önce mevcut durumu temizle, sonra yeniden uygula
- Emin olmadığın bir şey varsa sormadan devam etme
- `implementation.md`'de belirtilmeyen değişiklik yapma
- Kod içi comment'ler Türkçe olmalı