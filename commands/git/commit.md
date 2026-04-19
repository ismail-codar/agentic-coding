---
description: Git değişikliklerini analiz ederek Türkçe conventional commit mesajı oluşturur ve commit atar
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

# Türkçe Commit Mesajı Oluşturucu

**ÖNEMLİ:** Onay isteme, soru sorma, stash kullanma. Tüm adımları kesintisiz olarak doğrudan uygula.

Aşağıdaki adımları sırayla ve otomatik olarak takip et:

## 1. Tüm Değişiklikleri Stage'e Al

Tüm değişiklikleri (yeni dosyalar, değişiklikler, silmeler) stage'e ekle ve durumu kontrol et:

```
git add -A
git status
```

## 2. Stage'deki Değişiklikleri İncele

```
git diff --staged
```

## 3. Türkçe Commit Mesajı Oluştur ve Doğrudan Commit Et

Değişiklikleri analiz ederek **Conventional Commits** formatında Türkçe bir mesaj oluştur ve **hemen commit et**.

### Format:
```
<tip>(<kapsam>): <kısa açıklama>

<opsiyonel gövde>
```

### Commit tipleri:
| Tip | Ne zaman kullanılır |
|-----|---------------------|
| `feat` | Yeni özellik eklendi |
| `fix` | Hata düzeltildi |
| `docs` | Sadece dokümantasyon değişikliği |
| `style` | Kod formatı değişikliği (mantık değişmedi) |
| `refactor` | Kod yeniden düzenlendi (ne fix ne feat) |
| `test` | Test eklendi veya güncellendi |
| `chore` | Build, bağımlılık veya config değişikliği |
| `perf` | Performans iyileştirmesi |
| `ci` | CI/CD pipeline değişikliği |
| `revert` | Önceki commit geri alındı |

### Kurallar:
- Başlık satırı **50 karakteri geçmemeli**
- Fiil **geçmiş zaman** ile başlamalı (eklendi, düzeltildi, güncellendi, kaldırıldı...)
- Nokta ile **bitme**
- Kapsam varsa parantez içinde belirt (örn: `feat(auth):`, `fix(api):`)
- Birden fazla değişiklik varsa gövdede madde madde açıkla

### Örnekler:
```
feat(auth): Google ile giriş özelliği eklendi
fix(api): Null pointer hatası düzeltildi
docs: README kurulum adımları güncellendi
```

## 4. Commit Et

Mesajı oluştur ve **doğrudan** commit et:

```bash
git commit -m "<başlık>" -m "<gövde>"
```

Commit tamamlandıktan sonra sonucu raporla.
