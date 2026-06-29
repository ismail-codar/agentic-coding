Aşağıdaki karşılaştırma iki şeyi ayırarak okunmalı: **Superpowers** daha çok “ajanı disipline eden yazılım geliştirme metodolojisi + skill framework”; **Compound Engineering** ise “AI-native mühendislik felsefesi + takım/ürün döngüsü + plugin” gibi konumlanıyor.

## Kısa hüküm

**Superpowers**, ajanların “koda atlamasını” engelleyip onları spec → plan → worktree → TDD → review → finish gibi katı, doğrulanabilir adımlara sokmak için daha preskriptif ve mühendislik hijyenine odaklı. README’si bunu “coding agents için composable skills ve başlangıç talimatları üzerine kurulu eksiksiz bir yazılım geliştirme metodolojisi” diye tanımlıyor. ([GitHub][1])

**Compound Engineering**, daha geniş bir üretim sistemi felsefesi: her iş biriminin sonraki işleri kolaylaştırması, yani öğrenmenin kod, doküman, skill, agent, test ve süreçlere geri beslenmesi. Ana döngüsü **Plan → Work → Review → Compound → Repeat**; fark yaratan adımın “Compound” olduğunu özellikle vurguluyor. ([every.to][2])

## Temel fark

| Boyut              | Superpowers                                                                                 | Compound Engineering                                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Ana amaç           | Coding agent’ı disiplinli SDLC akışına sokmak                                               | AI ile mühendisliği zamanla hızlanan bir sistem haline getirmek                                                      |
| Çekirdek fikir     | Skills otomatik tetiklenir; ajan ilgili workflow’u uygulamak zorundadır                     | Her işten öğrenme çıkar, sistem hafızasına/dokümantasyona/skill’e dönüşür                                            |
| İş akışı           | Brainstorming → worktree → writing plans → subagent/executing plans → TDD → review → finish | Plan → Work → Review → Compound → Repeat                                                                             |
| Kalite yaklaşımı   | TDD, kök neden analizi, worktree izolasyonu, iki aşamalı review, “evidence over claims”     | Plan/review ağırlıklı çalışma, çoklu reviewer ajanları, PR/CI/browser testleri, öğrenme yakalama                     |
| İnsan rolü         | Spec onayı, plan onayı, checkpoint’ler, merge/PR kararı                                     | Fikir, plan kalitesi, PR review, sistemin öğrenmesini yönetme                                                        |
| Otomasyon seviyesi | Görevleri küçük parçalara bölüp subagent’larla yürütür; TDD’yi zorlar                       | `/lfg` gibi komutlarla planlama, çalışma, review, browser tests, PR, CI izleme ve düzeltme akışına kadar genişletir  |
| Takım/ürün boyutu  | Daha çok kod kalitesi ve agentic development pratiği                                        | Ürün stratejisi, kullanıcı feedback’i, pulse report, duyuru metni, UX polish gibi daha ürün-merkezli alanlara uzanır |

## Superpowers’ın karakteri

Superpowers’ın güçlü tarafı **disiplin**. README’de ajan bir şey inşa edeceğini anladığında hemen kod yazmak yerine kullanıcının ne istediğini netleştirmeye çalıştığı, sonra okunabilir parçalarda spec sunduğu, onaydan sonra “junior engineer’ın bile takip edebileceği” ayrıntıda uygulama planı hazırladığı anlatılıyor. Planlama TDD, YAGNI ve DRY ilkelerini özellikle vurguluyor. ([GitHub][1])

Workflow oldukça net: brainstorming, git worktree ile izole çalışma alanı, küçük görevli implementation plan, subagent-driven development veya plan execution, red-green-refactor TDD, code review ve branch finishing. Ayrıca “agent checks for relevant skills before any task” ve “mandatory workflows, not suggestions” deniyor; yani bu sistem öneri seti değil, davranış kısıtlayıcı bir çerçeve. ([GitHub][1])

Felsefesi de çok net: test-first, sistematik yaklaşım, karmaşıklık azaltma ve “iddia değil kanıt” üzerinden doğrulama. ([GitHub][1]) Bu yüzden Superpowers’ı ben daha çok **AI coding için emniyet kemeri ve mühendislik standardı** olarak görüyorum.

## Compound Engineering’in karakteri

Compound Engineering daha iddialı bir üst-felsefe kuruyor: Her feature karmaşıklık eklemek yerine sistemi yeni bir şey öğrenmiş hale getirmeli. Yazıya göre bug fix’ler gelecekteki bug kategorilerini yok etmeli; kalıplar araçlara dönüşmeli; sistem zamanla daha anlaşılır, değiştirilebilir ve güvenilir olmalı. ([every.to][2])

Asıl ayrım “Compound” adımında: plan, work, review geleneksel mühendisliğe benziyor; dördüncü adımda çözüm, öğrenme ve reusable pattern yakalanıyor, metadata ile bulunabilir hale getiriliyor, `CLAUDE.md` veya yeni agent/skill gibi sistem parçalarına işleniyor. ([every.to][2])

Plugin tarafında da kapsam geniş. Standard feature loop şu şekilde veriliyor: `/ce-brainstorm`, `/ce-plan`, `/ce-work`, `/ce-simplify-code`, `/ce-code-review`, `/ce-compound`. Debugging için `/ce-debug`, tam otonom akış için `/lfg` var. `/lfg` planlıyor, planı yürütüyor, review bulgularını çözüyor, browser testleri çalıştırıyor, commit/push/PR açıyor, CI’ı izleyip yeşile dönene kadar tamir ediyor. ([GitHub][3])

Ayrıca skill envanteri Superpowers’a göre daha ürün/takım bağlamlı: strategy, ideation, product pulse, feedback analysis, promote, browser QA, UX polish gibi işler de var. ([GitHub][3]) Bu yüzden Compound Engineering’i **AI ile çalışan takımın işletim sistemi** gibi düşünmek daha doğru.

## Benzerlikler

İkisi de “AI’a tek satır prompt ver, gelen kodu kabul et” tarzı vibe coding’e karşı daha sistemli bir yaklaşım öneriyor. İkisi de plan-first çalışmayı, worktree/izolasyon fikrini, review aşamasını ve reusable knowledge/skill mantığını önemsiyor. İkisi de Claude Code, Codex, Cursor gibi birden fazla coding agent ortamında kullanılabilir şekilde paketlenmiş durumda; Superpowers çok sayıda harness için kurulum veriyor, Compound Engineering de Claude Code, Cursor ve Codex dahil çeşitli ortamları destekliyor. ([GitHub][1])

En kritik ortak nokta şu: **ajanı daha akıllı yapmaya çalışmıyorlar; ajanı daha iyi bir sürece sokuyorlar.**

## Ayrıştıkları felsefi nokta

Superpowers’ta vurgu:
**“Ajanın yanlış yapmasını önleyecek mühendislik ritüellerini zorunlu hale getirelim.”**

Compound Engineering’de vurgu:
**“Her işten sonra sistemi eğitelim ki bir sonraki iş daha kolay olsun.”**

Bu küçük gibi görünen fark pratikte büyük. Superpowers daha çok bug riskini, plansızlığı ve test eksikliğini azaltır. Compound Engineering ise organizasyonel hafızayı, ürün geri bildirimi döngüsünü ve agent fleet yönetimini daha merkeze alır.

## Hangisini ne zaman seçerdim?

**Tek geliştiriciysen, codebase kalitesi kritikse, test disiplini zayıfsa veya ajanların plansızca dosya değiştirmesinden şikayetçiysen:** Superpowers daha iyi başlangıç. Daha katı, daha mühendislik odaklı, daha “beni raydan çıkarma” tarzı.

**Ürün geliştiriyorsan, birden fazla feature/PR/agent akışını yönetmek istiyorsan, öğrendiklerini kurumsal hafızaya çevirmek istiyorsan:** Compound Engineering daha uygun. Özellikle strategy, product pulse, feedback analysis, polish, PR automation gibi uçtan uca ürün döngüsü parçaları değerli.

**İkisini birlikte düşünürsek:** Superpowers, Compound Engineering’in “Work” ve “Review” aşamalarını daha güvenli kılacak bir altyapı gibi konumlanabilir. Compound Engineering ise Superpowers tarzı disiplinli execution’ın üstüne “öğrenmeyi sisteme geri yazma” katmanı ekler.

## Sonuç

Benim değerlendirmem:

**Superpowers = agentic software development için sıkı süreç ve kalite standardı.**
**Compound Engineering = AI-native ürün/mühendislik organizasyonu için compounding loop.**

Başlangıç için Superpowers daha düşük riskli ve daha net. Olgunluk arttıkça Compound Engineering daha yüksek kaldıraç sağlar; çünkü sadece işi yaptırmaz, işi yapma kapasiteni de büyütmeye çalışır.

[1]: https://github.com/obra/superpowers "GitHub - obra/superpowers: An agentic skills framework & software development methodology that works. · GitHub"
[2]: https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents "Compound Engineering: How Every Codes With Agents "
[3]: https://github.com/EveryInc/compound-engineering-plugin "GitHub - EveryInc/compound-engineering-plugin: Official Compound Engineering plugin for Claude Code, Codex, Cursor, and more · GitHub"
