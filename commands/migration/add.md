---
allowed-tools: Bash(git diff:*), Bash(git status:*)
description: Git diff'inden migration adını çıkarır ve dotnet ef migrations add komutunu üretir
---

# EF Core Migration Ekle

## Mevcut git durumu:
!`git status`

## Staged değişiklikler:
!`git diff --cached -- . ':(exclude)bin' ':(exclude)obj'`

## Unstaged değişiklikler:
!`git diff -- . ':(exclude)bin' ':(exclude)obj'`

---

Yukarıdaki diff'i analiz et ve şu kurallara göre bir migration adı çıkar:

**Adlandırma kuralları:**
- PascalCase, tek kelime olarak yaz
- 3–8 kelime birleştir
- Bir eylemle başla: `Add`, `Create`, `Rename`, `Remove`, `Alter`, `Update`, `Drop`
- Etkilenen ana tablo veya entity'i belirt
- Değişiklikler karışıksa baskın şema değişikliğini özetle

**Kaçın:** `UpdateModels`, `Changes`, `Fixes`, `Migration1`

**Çıktıyı bu formatta ver, başka hiçbir şey ekleme:**

```
add-migration "<InferredMigrationName>"

dotnet ef migrations add "<InferredMigrationName>" --project Data --startup-project WebApi
```
