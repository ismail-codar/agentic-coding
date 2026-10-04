---
name: ce-continuous-work
description: >-
  Verilen bir uygulama planını uçtan uca, kullanıcıya HİÇ SORMADAN uygular — dal açar, moda göre planı `ce-doc-review` ile ön incelemeden geçirir, fazları sırayla `ce-work` ile koşar, moda göre inceleme ve sadeleştirme yapar, projenin tam test kapısından geçirir, ana dala merge eder (yerel ya da PR), öğrenimi yakalar, sonra dalı ve plan dosyasını siler. Her fazı ayrı bir `claude -p` alt sürecinde koşturarak ana oturum bağlamını düz tutar. Proje-bağımsızdır; test komutu, plan dizini, durum dosyaları `.claude/ce-continuous-work.json` ile ya da otomatik algılamayla çözülür. Tetik: /ce-continuous-work \<plan-yolu\> [low|middle|high].
argument-hint: "<plan-yolu> [low|middle|high]  (varsayılan: middle)"
---

# ce-continuous-work

Bir **uygulama planını** alır ve tamamlanana kadar gözetimsiz sürer. Turun
tamamı boyunca **hiçbir soru sorulmaz** — `AskUserQuestion` bu skill'in hiçbir
aşamasında kullanılmaz. Karar gerektiren her yerde ya yazılı bir kapı ya da
"en iyi LLM kararı" kuralı geçerlidir; ikisi de yoksa tur **durur ve raporlar**,
tahmin yürütmez.

Skill **proje-bağımsızdır**. Projeye özgü her şey (test komutu, plan dizini,
durum/karar dosyaları, merge yolu) tek bir yerden gelir: **Proje uyarlaması**
bölümü. Skill'in gövdesinde geçen `<test_command>`, `<plans_dir>` gibi
köşeli-parantezli adlar oradaki çözümlemenin sonucudur.

## Yetkilendirme

Kullanıcının global `CLAUDE.md`'si ve çoğu proje `CLAUDE.md`'si otomatik
inceleme (`ce-code-review`, `ce-doc-review`), otomatik commit/push ve
çok-ajanlı pahalı turları **kullanıcı istemeden başlatmayı yasaklar**. Bu
skill o kuralla çelişmez: **kullanıcı `/ce-continuous-work` yazdığı anda bu
turun tamamını açıkça istemiş olur.** Dolayısıyla bu skill'in açtığı turlarda
`ce-doc-review`, `ce-work`, `ce-simplify-code`, `ce-code-review`,
`ce-compound`, `ce-commit`, push ve ana dala merge **önceden
yetkilendirilmiştir**; tur içinde onay sorulmaz.

Muafiyet yalnız **bu skill'in açtığı turlar** içindir — elle oturumlarda
kurallar aynen durur. Proje `CLAUDE.md`'sinde yazılı muafiyet listesi tutuluyorsa
bu skill'i o listeye bir satırla ekle (örnek `README.md`'de).

Muafiyetin güvenliği "izin verildi" cümlesinden değil **kapıdan** gelir:
uygulama başlamadan plan `ce-doc-review` ön kapısından geçer ve uygulanamaz
bulunursa tur durur; `<test_command>` yeşil olmadan hiçbir commit atılmaz ve
merge yapılmaz; faz kapısı kırmızıysa sonraki faza geçilmez; alt plan
derinliği 1'dir ve yalnız blokaj çözer; `run-phase.sh` "boş-başarı"yı (süreç 0
döndü ama eser yok) başarı saymaz; plan dosyası ancak öğrenim ve artıklar
git-izlenen dosyalara girdikten sonra silinir.

## Neden alt süreç, neden `/compact` değil

`/compact` bir Claude Code **CLI yerleşiğidir** — istemci işler, model çağıramaz.
`Skill` aracı yalnız skill listesindeki girdileri çağırır; `/compact`, `/clear`,
`/help` skill değildir. Dolayısıyla "faz sonunda compact" uygulanamaz.

Asıl hedef — token verimi — daha iyi bir mekanizmayla karşılanır: **her ağır
aşama ayrı bir `claude -p` alt sürecinde koşar.** Alt süreç sıfır bağlamla
başlar; compact ise kayıplı bir özet bırakır. Ana oturum yalnız **zarfları**
(küçük JSON özetler) okur, aşamaların araç çıktısını hiç görmez. Bağlam
büyümesi faz sayısıyla değil, zarf sayısıyla orantılıdır.

Ana oturumda kalanlar: argüman ayrıştırma, kapı kararları, git işlemleri,
ilerleme raporu. Alt sürece gidenler: `ce-work`, inceleme, sadeleştirme, alt
plan üretimi.

---

## Proje uyarlaması

Faz 0'ın ilk işi bu çözümlemedir. Sonuç `state.json`'a yazılır; tur boyunca
yeniden çözülmez.

### 1. Yapılandırma dosyası (varsa otorite)

Proje kökünde `.claude/ce-continuous-work.json`:

```json
{
  "test_command": "./run-all-tests.sh",
  "plans_dir": "docs/plans",
  "state_dir": "out/continuous-work",
  "main_branch": "main",
  "merge": "local",
  "learning_files": ["PROJECT_STATE.md", "DECISIONS.md"],
  "residual_targets": {
    "decision": "docs/open-decisions/",
    "open_work": "PROJECT_STATE.md",
    "binding_decision": "DECISIONS.md",
    "fallback": "docs/follow-ups/"
  },
  "plan_headings": "auto"
}
```

Her alan opsiyoneldir; eksik alan aşağıdaki algılamayla doldurulur. Dosya hiç
yoksa tamamı algılamayla çözülür ve tur raporuna "yapılandırma: algılandı"
notu düşülür.

### 2. Otomatik algılama (yapılandırma eksikse)

| alan | algılama sırası | hiçbiri yoksa |
|---|---|---|
| `test_command` | `./run-all-tests.sh` → `Makefile` içinde `test:` hedefi (`make test`) → `package.json` `scripts.test` (`npm test` / `pnpm test` / `bun test`, lock dosyasına göre) → `pyproject.toml`/`pytest.ini`/`tests/` (`pytest` ya da `uv run pytest`) → `Cargo.toml` (`cargo test`) → `go.mod` (`go test ./...`) | **DUR** — kapısız gözetimsiz merge yasak; kullanıcıya `test_command` yazmasını söyle |
| `plans_dir` | `docs/plans/` varsa o; yoksa verilen plan yolunun dizini | plan yolunun dizini |
| `state_dir` | `out/continuous-work/` | aynı; **gitignore'lu olmalı** (bkz. aşağı) |
| `main_branch` | `git symbolic-ref refs/remotes/origin/HEAD` → `main` → `master` | **DUR** |
| `merge` | `gh` kurulu **ve** `.github/workflows/` var → `pr`; aksi halde `local` | `local` |
| `learning_files` | kökte `PROJECT_STATE.md`, `DECISIONS.md`, `STATE.md`, `ROADMAP.md` hangileri varsa | boş liste — Faz 6 yalnız `ce-compound` koşar |
| `residual_targets` | `docs/open-decisions/` varsa `decision` oraya; `learning_files` içinde `PROJECT_STATE.md`/`DECISIONS.md` varsa `open_work`/`binding_decision` oraya | hepsi `fallback`: `docs/follow-ups/<plan-slug>.md` |
| `plan_headings` | plan dosyasında hangi dil geçiyorsa (İngilizce `## Implementation Units` / `### Phase N` / `## Verification Contract` / `## Open Questions` / `## Deferred to Follow-Up Work` **ya da** Türkçe `## Uygulama Üniteleri` / `### Faz N` / `## Doğrulama Sözleşmesi` / `## Açık sorular`) | İngilizce (ce-plan varsayılanı) |

`state_dir` için ek koşul: `git check-ignore -q <state_dir>` **başarısızsa
DUR** ve `.gitignore`'a eklenmesi gerektiğini söyle. Zarflar ve günlükler
depoya girmemeli; ama bu dizinin gitignore'lu olması Faz 6.5'in **tam da
sebebidir** — oraya yazılan her şey tur bitince kaybolur sayılır.

### 3. Betik yolu

`run-phase.sh` iki yerden birinde durur; ilk bulunan kullanılır:

```
.claude/skills/ce-continuous-work/scripts/run-phase.sh    # proje kopyası
~/.claude/skills/ce-continuous-work/scripts/run-phase.sh  # global kopya
```

Aşağıda `<run-phase>` bu çözülmüş yoldur.

---

## Faz 0 — Argümanlar ve ön koşullar

`$ARGUMENTS`'tan ayrıştır:

- **plan yolu** (zorunlu) — `<plans_dir>` altında bir dosya.
- **mod** (opsiyonel) — `low` | `middle` | `high`. Belirtilmezse **`middle`**.

Plan yolu verilmemişse **dur ve söyle**; en son planı tahmin etme (yanlış planı
uçtan uca uygulamak bu turun en pahalı hatasıdır).

Planın frontmatter'ını oku ve şu üçünü doğrula:

| alan | beklenen | değilse |
|---|---|---|
| `artifact_contract` | `ce-unified-plan/v1` | eski plan — devam et, uyarıyı rapora yaz |
| `artifact_readiness` | `implementation-ready` | **DUR** — `requirements-only` ise `/ce-plan <yol>` gerektiğini söyle |
| `execution` | `code` | **DUR** — `knowledge-work` bu turun konusu değil |

Çalışma ağacı kirliyse **dur** — commit'lenmemiş değişikliğin üstüne gözetimsiz
tur açmak, kimin neyi yazdığını ayırt edilemez hale getirir.

### Mod merdiveni

| mod | `ce-simplify-code` | kod incelemesi | plan ön incelemesi |
|---|---|---|---|
| `low` | yok | yok | **yok — Faz 2.5 atlanır** |
| `middle` *(varsayılan)* | yok | `ce-code-review` — **low kademe** | **low kademe** |
| `high` | var, incelemeden **önce** | `ce-code-review depth:full` | **high kademe** |

Merdiven iki kolu birden ayarlar: kod incelemesinin derinliğini **ve** Faz
2.5'teki plan ön incelemesinin kademesini. Kademe tanımları Faz 2.5'tedir.

`low` modun bedeli yazılı olsun: planı hiçbir kapı denetlemeden fazlar
doğrudan plana karşı koşar. Çelişkili ya da uygulanamaz bir plan turda ancak
`ce-work` bir blokaj bildirdiğinde (Faz 3b), faz kapısı kırmızı verdiğinde
(3e) ya da Faz 4'te görünür — hiçbiri "plan yanlış" demez, yalnız "iş
yürümedi" der. Planın kendisinden şüphe varsa `low` mod yanlış seçimdir.

### `middle` için kod incelemesinin low kademesi

`ce-code-review`'un `low`/`middle`/`high` diye bir argümanı **yoktur**; kabul
ettiği derinlik token'ları yalnız `depth:auto` (varsayılan) ve `depth:full`.
"Low" burada — plan ön incelemesindeki gibi — **bu skill'in tanımladığı
kademedir** ve promptta açıkça yazılır:

- **Token geçirilmez** (`depth:auto` zaten varsayılan). `depth:full`
  yasaktır — hafif yolu kapatır, bu kademenin tam tersi.
- **Kadro yalnız `correctness-reviewer` + `project-standards-reviewer`.**
  `testing-reviewer`, `maintainability-reviewer`, `agent-native-reviewer` ve
  `learnings-researcher` bu kademede koşmaz.
- **Koşullu personalar etkinleşmez** (`security-`, `performance-`,
  `api-contract-`, `reliability-`, `data-migration-`, `adversarial-`) ve
  **çapraz-model karşıt geçişi koşmaz** — turun en pahalı kalemi odur ve
  kullanıcının global kuralı gereği zaten opt-in'dir (`cross-model pass: not
  run (opt-in)` notu düşülür).
- Kadro kısıtı skill'in kendi kadro kararının **üstündedir**: tam kadro seçse
  bile bu kademede kadro ikiliye indirilir.

Bırakılan personaların bedeli ölçülü: `ce-code-review` zaten yalnız
testing/maintainability'den gelen zayıf P2/P3 bulgularını `testing_gaps` /
`residual_risks`'e **düşürüyor** — yani bu iki persona low kademede en az
uygulanabilir bulguyu üreten kanattır. Gerçek test güvencesi bu incelemeden
değil Faz 4'ün `<test_command>` kapısından gelir. Derin kadro isteyen tur
`high` moda geçer.

Kip yine **varsayılan (etkileşimli) kiptir**, `mode:agent` değil:

- **Varsayılan kip düzeltmeleri kendi uygular.** `mode:agent` rapor-sadece'dir
  ve uygulamayı çağırana bırakır — burada gereksiz dolayım.
- **Varsayılan kip soru sormaz**: skill'in kendi kuralı "No blocking prompts.
  Never use `AskUserQuestion`". Gözetimsiz tur için güvenlidir.

Bulgular **en iyi LLM kararı ile** uygulanır. Otomatik uygulanamayan artık
bulgular tur raporuna yazılır, sessizce düşürülmez.

---

## Faz 1 — Dal

Turun kendi dalını **`ce-work`'ten önce** aç. `ce-work` dal açmayı kendi
üstlenir ama bunu **sorarak** yapar ("Continue on X, or create a new branch?");
zaten bir özellik dalındaysa soru sormaz. Dalı önden açmak o soruyu ortadan
kaldırır.

```
git checkout <main_branch> && git pull origin <main_branch>
git checkout -b <tip>/<plan-slug>
```

`<tip>` plandan (`type: fix|feat|refactor`), `<plan-slug>` dosya adının
açıklayıcı kısmından gelir. Dal adı zaten varsa sonuna `-2`, `-3` ekle.

Projede worktree deseni olsa bile (`ce-worktree` skill'i) bu skill **düz dal**
kullanır: tur ana dala merge edip dalı silecek, worktree'nin yalıtımı burada
kazanç değil ek temizlik yükü olur.

---

## Faz 2 — Tur durumu

`<state_dir>/<plan-slug>/` altında çalış:

- `state.json` — plan yolu, mod, çözülmüş proje uyarlaması, dal adı, faz
  listesi, her fazın durumu
- `<asama>.envelope.json` — her aşamanın zarfı
- `<asama>.out` — alt sürecin tam günlüğü (**silinme**; kayıtsız aşamanın
  teşhisi ancak metin dururken yapılabilir — zarf yokken aşamanın ne yaptığını
  söyleyen tek kayıt budur)

Durum dosyasını her aşamadan sonra güncelle. Tur yarıda kesilirse aynı
argümanla yeniden çağrıldığında `state.json`'dan devam edilebilmeli.

---

## Faz 2.5 — Plan ön incelemesi (`ce-doc-review`)

**`low` modda bu faz tamamen atlanır** — hiç `ce-doc-review` koşmaz, zarf
üretilmez, `state.json`'a `plan-inceleme: atlandi (mod=low)` yazılır ve
doğrudan Faz 3'e geçilir. Bedeli mod merdiveninde yazılıdır.

`middle` ve `high` modda uygulama başlamadan önce plan **bir kez** incelenir.
Turun geri kalanı planı otorite kabul eder — çelişkili ya da uygulanamaz bir
plan, fazlar boyunca sessizce yanlış kod üretir ve bedeli ancak Faz 4 kapısında
ya da hiç görülmez.

Alt süreçte koş:

```
<run-phase> plan-inceleme <prompt-dosyasi> <zarf-dosyasi>
```

Prompt şunu içerir: `ce-doc-review` skill'ini **`mode:headless <plan-yolu>`**
ile çağır, moda karşılık gelen kademe kısıtıyla koş, sonucu `<zarf-dosyasi>`na
JSON olarak yaz.

`ce-doc-review`'un `low`/`middle`/`high` diye bir argümanı **yoktur** — kabul
ettiği tek bayrak `mode:headless`. Kademeler bu skill'in tanımıdır ve promptta
açıkça yazılır. **`mode:headless` her iki kademede de zorunludur**: gözetimsiz
turda etkileşimli kip yönlendirme sorusu sorar, bu skill hiçbir aşamada
`AskUserQuestion` kullanmaz.

### Low kademe — `middle` mod

- **Kadro yalnız her-zaman-açık ikili**: `coherence-reviewer` ve
  `feasibility-reviewer`. Koşullu personalar (`product-lens`, `design-lens`,
  `security-lens`, `scope-guardian`, `adversarial`) bu kademede etkinleşmez.
- **Aranan şey uygulanabilirliktir**, ürün kararının yeniden açılması değil:
  ünitelerin birbiriyle çelişip çelişmediği, faz sırasının mümkün olup olmadığı,
  doğrulama sözleşmesinin ölçülebilir olup olmadığı, atıf verilen yolların var
  olup olmadığı.

Kadronun dar tutulması bilinçli: plan zaten `ce-plan`'den geçmiş ve Faz 0
`implementation-ready` doğrulaması yapmıştır. `adversarial` bu noktada
premise'i yeniden açar — uygulamaya başlamadan önce turu tartışmaya sokar,
`middle`'ın aradığı kapı değerini üretmez.

### High kademe — `high` mod

- **Kadro kısıtı yok.** Her-zaman-açık ikiliye ek olarak `ce-doc-review`'un
  kendi koşullu seçimi serbest bırakılır: belgede sinyali olan
  `product-lens`, `design-lens`, `security-lens`, `scope-guardian` ve
  `adversarial` personaları etkinleşir.
- **Persona listesi zorlanmaz, sinyale bırakılır.** Sinyali olmayan personayı
  elle açmak (arka uç planına `design-lens`) bulgu değil gürültü üretir;
  `high`'ın kazancı kadroyu şişirmekten değil, `middle`'ın kapattığı premise ve
  kapsam kanadını **açmaktan** gelir.
- **Aranan şey uygulanabilirliğe ek olarak premise ve kapsamdır**: planın
  dayandığı varsayım tutuyor mu, seçilen yön alternatiflerine karşı savunulur
  mu, üniteler ürün sözleşmesinin dışına taşıyor mu.

### Bulgulara ne olur

| sınıf | davranış |
|---|---|
| `safe_auto` | `ce-doc-review` zaten uygulamıştır — plan dosyası dalda değişmiş olarak kalır |
| planı **uygulanamaz** kılan bulgu | **DUR** — çelişen üniteler, imkânsız faz sırası, ölçülemez doğrulama sözleşmesi, var olmayan yola atıf |
| kalan `gated_auto` / `manual` / FYI | en iyi LLM kararı ile uygula ya da tur raporuna yaz — sessizce düşürme |

Durma ölçütü `high` kademede de **aynı listedir ve genişlemez**: premise'e,
alternatiflere ya da kapsama dair bulgular — `adversarial` ve `scope-guardian`
tam da bunları üretir — planı uygulanamaz **kılmaz**. Bunlar en iyi LLM kararı
ile uygulanır ya da tur raporuna yazılır. Aksi halde `high` mod, derinleşmenin
bedelini "her tartışmalı planda tur durdu" olarak öderdi; `high`'ın amacı turu
zorlaştırmak değil planı düzelterek başlatmaktır.

Uygulanamazlık bulgusunda tur durur ve `/ce-plan <plan-yolu>` ile planın
düzeltilmesi gerektiğini raporlar. Planın niyetini gözetimsiz yeniden yazmak
bu turun üstlendiği bir risk değildir — Faz 3b'nin alt plan sınırı da aynı
gerekçeyle vardır.

İncelemenin plan üzerinde bıraktığı değişiklikler dalda durur ve Faz 5'in
commit'ine girer. Plan dosyası Faz 7'de nasılsa silinecektir; kazanç dosyanın
kendisi değil, **fazların düzeltilmiş plana karşı koşmasıdır**.

`state.json`'a incelemenin durumu ve bulgu sayıları yazılır.

---

## Faz 3 — Faz döngüsü

Plandan fazları çıkar: `<plan_headings>`'e göre `## Implementation Units` /
`## Uygulama Üniteleri` altındaki `### Phase N — ...` / `### Faz N — ...`
başlıkları. Faz başlığı yoksa **tüm plan tek faz** sayılır.

Her faz için sırayla:

### 3a. Uygulama — alt süreçte

Prompt dosyası yaz, sonra:

```
<run-phase> faz<N>-work <prompt-dosyasi> <zarf-dosyasi>
```

Prompt şunu içerir: `ce-work` skill'ini **`mode:return-to-caller <plan-yolu>`**
ile çağır, yalnız bu fazın ünitelerini uygula, sonucu `<zarf-dosyasi>`na JSON
olarak yaz.

`mode:return-to-caller` kritiktir: `ce-work` uygular ve yerel doğrular, ama
kendi ship kuyruğunu (commit/push/PR) **koşmaz** — o kuyruk bu turun kendi
kapısına tabidir.

Zarftan oku: `status`, değişen dosyalar, tamamlanan U-ID'ler, doğrulama
sonuçları, `blocker` listesi, `behavior_change` ve varsa `verification_evidence`.

`run-phase.sh` sıfırdan farklı dönerse **dur**: çıkış 2 = süreç hatası,
çıkış 3 = **kayıtsız aşama** (süreç 0 döndü, zarf yazılmadı ve kurtarma da
tutmadı). Hiçbirini başarı sayma.

### Zarf kurtarma — çıkış 3'ten ÖNCE denenir

Kayıtsız aşama nadir değil: skill'in ilk geliştirildiği projede bir turda
**5 aşamanın 3'ü** işi bitirip zarfı yazmadan öldü. Her seferinde ağaçtaki iş
sağlamdı; pahalı olan kaydın elle yeniden kurulmasıydı (diff okuma + ölçümleri
yeniden koşma). Prompt'a "zarfı unutma" yazmak **zayıf** bir önlemdir — alt
sürecin uyumuna bağlıdır ve üç turda da tutmadı.

Bu yüzden `run-phase.sh` aşamayı sabit bir `--session-id` ile koşar ve zarf
eksikse **aynı oturumu `--resume` ile geri çağırıp yalnız zarfı yazdırır**. İş
zaten yapılmıştır, bağlam o oturumdadır; kurtarma çağrısı kısa ve ucuzdur.
Aşamanın özgün promptu (şema dahil) kurtarma promptuna gömülür, yani şemayı
hatırlamaya gerek kalmaz.

Kurtarılan zarfta `"_envelope_recovered": true` durur. **Bu bayrağı gördüğünde
kritik sayıları zarfa değil ağaca sor** — kurtarma anı alt sürecin kendi
ölçümlerini hatırlamasına dayanır ve birincil kayıt kadar güvenilir değildir.
Kurtarma promptu uydurmayı açıkça yasaklar: gerçekten iş yapılmadıysa alt
süreç zarfı yazmayı reddeder (ölçüldü — yapay bir denemede doğru şekilde
reddetti).

`CE_ENVELOPE_RECOVERY=0` ile kapatılabilir.

**Çıkış 3 "aşama hiçbir şey yapmadı" DEMEK DEĞİLDİR.** Ölçüldü: bir inceleme
aşaması zarfsız bitti ama bir kaynak dosyayı yüz satıra yakın büyütmüştü —
iş yapılmış, yalnız **kaydı bırakılmamıştı**. İki sebep vardır ve teşhisleri
farklıdır:

- **ağaç değişmedi** → aşama gerçekten hiçbir şey yapmadı (sessiz araç reddi);
- **ağaç değişti** → aşama iş yaptı ama kaydını bırakmadı: ne uygulandığı,
  doğrulanıp doğrulanmadığı, hangi bulguların açık kaldığı **bilinmiyor**.

`run-phase.sh` bu ayrımı çıkış 3 yolunda kendisi ölçüp stderr'e yazar; git
deposu değilse "ölçülemedi" der — bunu asla "değişmedi" diye okuma. Ölçüm
**gitignore'lu yolları görmez** (`<state_dir>` dahil), yani yalnız oraya yazan
bir aşama "değişmedi" okunur; kesin teşhis için `<asama>.out` günlüğü her
zaman okunmalıdır. İkinci durumda tur yine **durur**, ama rapor "aşama boş
döndü" değil "ağaçta kaydı olmayan değişiklikler var" demelidir; fark,
kullanıcının bir sonraki hamlesini belirler.

**Bir aşamayı iptal ettiysen ağacın durduğunu ÖLÇ.** `TaskStop` kabuğu
öldürür, `claude -p` çocuğunu öldürmeyebilir — ölçüldü: durdurulan inceleme,
bir sonraki inceleme koşarken aynı dosyalara yazmaya devam etti. Bir sonraki
aşamayı başlatmadan önce `git diff --stat`in (ya da mtime'ların) bir aralık
boyunca sabit kaldığını doğrula.

### 3b. Blokaj → alt plan (derinlik 1, yalnız blokaj çözme)

Zarfta blokaj varsa — planın öngörmediği bir önkoşul ya da bağımlılık — **bir**
alt plan üret: ayrı bir alt süreçte `ce-plan` çağır, çıktı yine
`<plans_dir>` altına.

`ce-plan`, `AskUserQuestion` (ya da sohbette numaralı seçenek) ile soru
sorabilen bir skill'dir — çıktı biçimi, kapsam belirsizliği, yaklaşım
irtifası, planlama soruları, teslim menüsü gibi birden çok noktada. Alt süreç
`claude -p` ile açıldığı için yanıtlayacak kimse yoktur; soru oradan gelirse
tur takılır ya da sessizce yanlış dala düşer. Bu yüzden alt plan promptu şunu
**açıkça** yazmak zorundadır: her seçim noktasında `ce-plan`'ın kendi
**tavsiye ettiği/varsayılan** seçenek otomatik uygulanır, soru sorulmaz;
tavsiye yoksa en iyi LLM kararı ile karar verilir ve alınan karar üretilen alt
planda açık bir `## Assumptions` / karar notu olarak kaydedilir — sessizce
geçilmez.

Sınırlar kesindir:

- **Derinlik 1.** Alt planın alt planı **olamaz.** İkinci düzey blokajda tur
  durur ve raporlar.
- **Yalnız blokaj çözme.** Kapsam genişletme yasak. "Bunu da yapalım"
  cinsinden bulgular ana planın `Deferred to Follow-Up Work` bölümüne yazılır,
  uygulanmaz.
- Alt plan uygulandıktan sonra kesilen faza dönülür.

Sınırsız alt plan üretimi turu kendi kendini besleyen bir döngüye çevirir ve
token verimi hedefinin tam tersini yapar — bu yüzden sınır tartışmaya açık
değildir.

### 3c. Sadeleştirme — yalnız `high`

`ce-simplify-code`'u alt süreçte, **incelemeden önce** çağır ki inceleme
sadeleşmiş kodu görsün. Fark yalnız dokümansa ya da ~10 satırdan küçükse atla.

### 3d. İnceleme — `middle` ve `high`

Mod merdivenine göre `ce-code-review`'u alt süreçte çağır:

- **`middle`** — token'sız çağır, promptta mod merdivenindeki **low kademe**
  kısıtını (ikili kadro, koşullu persona yok, çapraz-model geçiş yok) aynen
  yaz.
- **`high`** — `depth:full`, kadro kısıtı yok. Çapraz-model geçişi yine
  **opt-in'dir**; kullanıcı açıkça istemediyse koşmaz.

Bulguları en iyi LLM kararı ile uygula. `low` modda bu adım tamamen atlanır.

**Uygulanmayan artık bulgu bir ESER üretmek zorundadır** (bkz. Faz 6.5). Zarfa
yazmak yetmez: zarflar `<state_dir>` altındadır ve orası **gitignore'ludur** —
tur bitince artık bulgu yalnız terminal geçmişinde kalır ve oturumla birlikte
kaybolur.

### 3e. Faz kapısı

Planın o faz için tanımladığı doğrulama varsa (`## Verification Contract` /
`## Doğrulama Sözleşmesi`, faz içi ölçüm üniteleri) koş. Kapı kırmızıysa
**tur durur** — bir sonraki faza geçmez. Kırmızı kapıyı "sonra düzeltiriz"
diye geçmek, planın faz sırasını anlamsız kılar.

Faz bitti: `state.json`'ı güncelle, kısa bir ilerleme satırı bas, sonraki faza
geç. Alt süreç bittiği için o fazın araç çıktısı ana bağlama hiç girmedi —
compact'in yapacağı şey burada zaten yapılmış oldu.

---

## Faz 4 — Tam test kapısı

Tüm fazlar bittikten sonra, **commit'ten önce**:

```
<test_command>
```

Hızlı/kısmi test seti bunun yerine geçmez. Kırmızıysa tur durur ve raporlar —
kırmızı testle merge eden bir tur, tasarruf ettiği süreyi kaçırdığı
regresyonla geri öder.

`merge: local` projelerde (CI yok ya da `gh` yok) `<test_command>` turun
**tek** gerçek kapısıdır. `merge: pr` projelerde CI ikinci kapıdır ama
birincisinin yerine geçmez: CI'yı bekleyip kırmızı görmek, yerelde yeşil
görmekten daha pahalıdır.

---

## Faz 5 — Commit, push, merge

Kapı yeşilse:

1. `ce-commit` ile commit — değeri anlatan mesaj, projenin diliyle.
2. `git push origin <dal>`
3. Merge, `<merge>` değerine göre:

**`local`**:

```
git checkout <main_branch> && git merge <dal> && git push origin <main_branch>
```

**`pr`**:

```
gh pr create --base <main_branch> --fill
gh pr checks --watch --fail-fast
gh pr merge --merge --delete-branch
```

CI kırmızıysa **dur ve raporla** — PR açık kalır, dal silinmez. Depo
merge-queue ya da zorunlu onay istiyorsa `gh pr merge` reddedilir; bu da bir
durma koşuludur ve rapor PR URL'sini verir.

Merge çakışırsa **dur ve raporla** — gözetimsiz çakışma çözümü, turun bilerek
üstlenmediği bir risktir.

---

## Faz 6 — Öğrenimi yakala (plan silinmeden ÖNCE)

Bu faz atlanamaz. Plan dosyası birazdan silinecek; öğrenim yakalanmazsa planla
birlikte buharlaşır ve tur "otomatik ama öğrenmeyen" bir döngüye düşer.

1. **`ce-compound mode:headless`** — turdan çıkan öğrenimi projenin öğrenim
   deposuna (`ce-compound` varsayılanı `docs/solutions/`) yazar.
   `mode:headless` bloklayan soru sormaz, tam koşum yapar.
2. **`<learning_files>`** — her biri için: biten yetenek, yeni ölçüm, kapanan
   açık iş, varsa bağlayıcı mimari karar. Dosyanın kendi biçimine uy; yoksa
   dokunma. Liste boşsa bu adım atlanır ve rapora yazılır.

Her tur için karar uydurma: bağlayıcı karar yoksa karar dosyasına dokunma.

---

## Faz 6.5 — Artık kapanışı (plan silinmeden ÖNCE, ZORUNLU)

Faz 6 **öğrenimi** yakalar (bu nasıl çalışılır); bu faz **artığı** yakalar
(bu ne yapılmadı). İkisi farklı şeydir ve ikincisi ölçülerek kaybedildi: bir
turda kod incelemesinin dört artık bulgusu — biri canlı, sessiz bir kayıptı —
yalnız zarflarda ve tur raporunda duruyordu; plan silindiğinde ve oturum
kapandığında hepsi kaybolacaktı. Kullanıcı fark ettiği için kurtarıldı.

**Kök neden yapısaldır, unutkanlık değil:** `<state_dir>` gitignore'ludur, plan
dosyası Faz 7'de silinir, ve "tur raporu" terminal geçmişidir. Üç kalıcı
olmayan yere yazıp dördüncü bir yere yazmamak, kaybı kesinleştirir.

### Ne toplanır

Bu turun **bütün** zarflarını tara ve şu alanları çıkar:

| zarf | alan |
|---|---|
| `plan-inceleme*.envelope.json` | `open_findings`, `blocking_findings` |
| `faz*-work.envelope.json` | `blocker`, `units_skipped` |
| `faz*-review.envelope.json` | `residual` |

Ayrıca plan dosyasının `## Open Questions` / `## Açık sorular` ve
`## Deferred to Follow-Up Work` bölümleri — plan siliniyor, onlar da
siliniyor.

### Nereye yazılır

Her kalem **git-izlenen** bir dosyaya gider. Adres kalemin türüne göre
`<residual_targets>`'tan gelir:

- **karar bekleyen soru** (bir yön seçilmeli) → `decision` hedefi. Hedef bir
  dizinse o dizinde yeni kayıt + dizinin indeks/`README.md` tablosu varsa satır
  (indeks doğrulayan bir test varsa onsuz kırmızı düşer).
- **ölçülmüş ama düzeltilmemiş kusur** (yön belli, iş yapılmadı) →
  `open_work` hedefi.
- **bu turun bağlayıcı kararı** → `binding_decision` hedefi.
- hedefi yapılandırılmamış tür → `fallback`: `docs/follow-ups/<plan-slug>.md`
  (yoksa oluştur; başlık, tarih, plan slug'ı, kalem listesi).
- **gerçekten değersiz** → düşürülebilir, ama **gerekçesiyle** tur raporuna
  yazılır. Sessiz düşüş yasak.

Bir kalemi taşırken **ölçümünü de taşı**: hangi girdi, hangi çıktı, hangi
tarih/model. Ölçümsüz bir artık kaydı bir sonraki turu aynı ölçümü yeniden
yapmaya zorlar.

### Kapı

Faz 7 **ancak** her artık kalemin git-izlenen bir dosyada karşılığı varsa
koşar. Karşılığı olmayan kalem varsa tur **durur** ve raporlar — plan
dosyası silinmez, çünkü silinirse kalem de gider.

`git status` ile doğrula: bu fazın yazdığı dosyalar `<state_dir>` altında
**olmamalıdır**.

Faz 6 ve 6.5'in yazdıkları ayrı bir commit olur ve ana dala push'lanır
(`merge: pr` ise doğrudan ana dala küçük bir "docs" commit'i kabul edilmiyorsa
ikinci bir PR açılır ve aynı kapıdan geçer).

---

## Faz 7 — Temizlik

Faz 6 **ve Faz 6.5** tamamlandıysa:

```
git branch -d <dal>
git push origin --delete <dal>     # `merge: pr --delete-branch` zaten sildiyse atla
git rm <plans_dir>/<plan-dosyasi>  # varsa üretilen alt planlar da
```

Silmeyi de commit'le ve push'la. Sonra tek ekranlık **tur raporu** bas: çözülen
proje uyarlaması (yapılandırma mı algılama mı), plan ön incelemesinin
bulguları, uygulanan üniteler, üretilen alt planlar, kod inceleme bulguları
(uygulanan / artık), test sonucu, merge SHA'sı ya da PR URL'si, yakalanan
öğrenimler, artıkların yazıldığı dosyalar.

---

## Durma koşulları

Tur şu durumlarda **durur, tahmin yürütmez**:

| durum | sebep |
|---|---|
| `test_command` çözülemedi | kapısız gözetimsiz merge yasak |
| `<state_dir>` gitignore'lu değil | zarflar/günlükler depoya sızar |
| plan `requirements-only` ya da `execution: knowledge-work` | yanlış eser tipi |
| çalışma ağacı kirli | kimin ne yazdığı ayırt edilemez |
| plan ön incelemesi planı **uygulanamaz** buldu (`middle`/`high`) | fazlar yanlış plana karşı koşar |
| `run-phase.sh` çıkış 3 (kayıtsız aşama, **kurtarma da tutmadı**) | aşamanın kaydı yok: ya hiçbir şey yapmadı ya da yaptığı iş **bilinmiyor** — ikisi de merge edilemez |
| ikinci düzey blokaj | derinlik 1 sınırı |
| faz kapısı kırmızı | plan sırası anlamsızlaşır |
| `<test_command>` kırmızı | birincil merge kapısı |
| CI kırmızı ya da `gh pr merge` reddedildi (`merge: pr`) | PR açık kalır, insan devralır |
| merge çakışması | gözetimsiz çözüm üstlenilmedi |
| plan tamamlandı ama **ilerleme yok** | merge etmeye değer bir şey yok — dal ve plan korunur |
| artık bulgunun git-izlenen karşılığı yok (Faz 6.5) | plan silinirse kalem de gider — `<state_dir>` gitignore'lu |

Her durmada: `state.json` güncel bırakılır, ne yapıldığı ve nerede kalındığı
tek ekranda raporlanır, ilgili günlük dosyalarının yolu verilir.

## Yapılmayacaklar

- `AskUserQuestion` — hiçbir aşamada, hiçbir modda.
- `/compact`, `/clear` çağırma girişimi — bunlar skill değil, çağrılamaz.
- Kırmızı kapıyı geçme, testi zayıflatma, assertion'ı mock'lama.
- Kapsam genişletme; plan dışı "bu arada şunu da düzelttim" değişiklikleri.
- Öğrenim yakalanmadan plan silme.
- **Artık bulguyu yalnız zarfa ya da tur raporuna yazma** — ikisi de kalıcı
  değildir (`<state_dir>` gitignore'lu, rapor terminal geçmişi). Faz 6.5
  zorunludur.
- Çapraz-model (codex vb.) geçişini kullanıcı istemeden koşturma.
- İstenmemiş refactor.
