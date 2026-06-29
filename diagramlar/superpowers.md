# Superpowers Tüm Süreçler - Kapsamlı Mermaid Grafiği

```mermaid
graph TB
    subgraph "Skill Kontrol Protokolü (using-superpowers)"
        Start["Kullanıcı mesajı"] --> SkillCheck{"Skill applicable? %1 kuralı"}
        SkillCheck -->|Evet| InvokeSkill["Skill tool çağır"]
        SkillCheck -->|Hayır| Respond["Cevap ver"]
        InvokeSkill --> Announce["Skill kullanımını duyur"]
        Announce --> HasChecklist{"Checklist var mı?"}
        HasChecklist -->|Evet| CreateTodo["TodoWrite oluştur"]
        HasChecklist -->|Hayır| FollowSkill["Skill'i takip et"]
        CreateTodo --> FollowSkill
        FollowSkill --> Respond
    end

    subgraph "Brainstorming Süreci"
        B1["Proje bağlamını keşfet"] --> B2{"Görsel sorular?"}
        B2 -->|Evet| B3["Visual companion teklif et"]
        B2 -->|Hayır| B4["Açıklayıcı sorular sor"]
        B3 --> B4
        B4 --> B5["2-3 yaklaşım öner"]
        B5 --> B6["Tasarım bölümlerini sun"]
        B6 --> B7{"Kullanıcı onayı?"}
        B7 -->|Hayır| B6
        B7 -->|Evet| B8["Tasarım belgesi yaz"]
        B8 --> B9["Spec self-review"]
        B9 --> B10{"Kullanıcı incelemesi?"}
        B10 -->|Değişiklik| B8
        B10 -->|Onay| B11["writing-plans çağır"]
    end

    subgraph "Writing-Plans Süreci"
        W1["Spec'i oku"] --> W2{"Çoklu alt-sistem?"}
        W2 -->|Evet| W3["Ayrı planlar öner"]
        W2 -->|Hayır| W4["Dosya yapısını haritala"]
        W4 --> W5["Görevlere böl 2-5 dk"]
        W5 --> W6["Plan belgesi yaz"]
        W6 --> W7["Self-review"]
        W7 --> W8["Seçenek sun"]
        W8 --> W9{"Uygulama yöntemi?"}
        W9 -->|Subagent| SDD["subagent-driven-development"]
        W9 -->|Inline| EP["executing-plans"]
    end

    subgraph "Subagent-Driven Development (SDD)"
        S1["Planı oku, görevleri çıkar"] --> S2["TodoWrite oluştur"]
        S2 --> S3["Görev döngüsü başla"]
        
        subgraph "Per Task Loop"
            S3 --> S4["Implementer subagent gönder"]
            S4 --> S5{"Sorular var mı?"}
            S5 -->|Evet| S6["Cevap ver, bağlam sağla"]
            S5 -->|Hayır| S7["Uygula, test et, commit et"]
            S6 --> S4
            S7 --> S8["Spec reviewer gönder"]
            S8 --> S9{"Spec uyumlu mu?"}
            S9 -->|Hayır| S10["Implementer düzeltir"]
            S9 -->|Evet| S11["Code quality reviewer gönder"]
            S10 --> S8
            S11 --> S12{"Kalite uygun mu?"}
            S12 -->|Hayır| S13["Implementer düzeltir"]
            S12 -->|Evet| S14["Görev tamamla"]
            S13 --> S11
            S14 --> S15{"Daha fazla görev?"}
            S15 -->|Evet| S4
            S15 -->|Hayır| S16["Final code reviewer"]
        end
        
        S16 --> FDB["finishing-a-development-branch"]
    end

    subgraph "Executing-Plans (EP)"
        E1["Planı yükle ve incele"] --> E2{"Sorunlar var mı?"}
        E2 -->|Evet| E3["Partnerine bildir"]
        E2 -->|Hayır| E4["TodoWrite oluştur"]
        E4 --> E5["Görevleri sırayla uygula"]
        E5 --> E6["Her görev: adımları takip et"]
        E6 --> E7{"Tüm görevler tamamlandı?"}
        E7 -->|Hayır| E5
        E7 -->|Evet| FDB
    end

    subgraph "Code Review Süreci (İki Aşamalı)"
        CR1["Implementer tamamlandı"] --> CR2["BASE_SHA ve HEAD_SHA al"]
        CR2 --> CR3["Spec reviewer gönder"]
        CR3 --> CR4{"Spec uyumlu mu?"}
        CR4 -->|Hayır| CR5["Implementer düzeltir"]
        CR4 -->|Evet| CR6["Code quality reviewer gönder"]
        CR5 --> CR3
        CR6 --> CR7{"Kalite uygun mu?"}
        CR7 -->|Hayır| CR8["Implementer düzeltir"]
        CR7 -->|Evet| CR9["Görev tamamla"]
        CR8 --> CR6
    end

    subgraph "Finishing-a-Development-Branch"
        F1["Testleri doğrula"] --> F2{"Testler geçti mi?"}
        F2 -->|Hayır| F3["Testleri düzelt"]
        F2 -->|Evet| F4["Ortamı tespit"]
        F4 --> F5["Base branch belirle"]
        F5 --> F6["Seçenekleri sun"]
        F6 --> F7{"Seçenek"}
        F7 -->|Merge| F8["Merge işlemi"]
        F7 -->|PR| F9["PR oluştur"]
        F7 -->|Keep| F10["Branch'i tut"]
        F7 -->|Discard| F11["Branch'i sil"]
        F8 --> F12["Worktree temizle"]
        F9 --> F12
        F10 --> F12
        F11 --> F12
    end

    subgraph "Test-Driven Development (TDD)"
        T1["Başarısız test yaz"] --> T2["Testi çalıştır (FAIL)"]
        T2 --> T3["Minimal kod yaz"]
        T3 --> T4["Testi çalıştır (PASS)"]
        T4 --> T5["Commit"]
    end

    %% Ana akış bağlantıları
    SkillCheck -->|Creative work| B1
    B11 --> W1
    SDD --> FDB
    EP --> FDB
    
    %% TDD entegrasyonu
    S7 --> T1
    E6 --> T1
    
    %% Code review entegrasyonu
    S7 --> CR1
    E6 --> CR1
```

## Süreç Açıklamaları

### 1. Skill Kontrol Protokolü
`using-superpowers` skill'i, "1% kuralı" olarak bilinen zorunlu bir protokol uygular. Eğer bir skill'in geçme ihtimali %1 bile olsa, ajan mutlaka o skill'i çağırmalıdır. [1](#2-0) 

### 2. Brainstorming Süreci
Fikirleri tasarıma dönüştürür. Hard-gate mekanizması ile tasarım onayı olmadan hiçbir implementation skill'ine geçiş yapmaz. [2](#2-1)  Tasarım belgesi `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` konumuna kaydedilir. [3](#2-2) 

### 3. Writing-Plans Süreci
Onaylanmış tasarımı uygulama planına dönüştürür. Her görev 2-5 dakikalık adımlara bölünür ve tam dosya yolları, tam kod, doğrulama adımları içerir. [4](#2-3)  Plan belgesi `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` konumuna kaydedilir. [5](#2-4) 

### 4. Subagent-Driven Development
Her görev için taze bir alt-ajan gönderir ve iki aşamalı inceleme yapar (spec compliance, sonra code quality). Sürekli yürütme ilkesi ile görevler arasında durulmaz. [6](#2-5) 

### 5. Executing-Plans
Subagent desteği olmayan platformlar için toplu uygulama yöntemi. Görevleri sırayla uygular ve doğrulamaları çalıştırır. [7](#2-6) 

### 6. Code Review Süreci
İki aşamalı inceleme: önce spec compliance, sonra code quality. BASE_SHA/HEAD_SHA protokolü ile inceleme kapsamı belirlenir. [8](#2-7) 

### 7. Finishing-a-Development-Branch
Tüm görevler tamamlandıktan sonra testleri doğrular, seçenekleri sunar (merge/PR/keep/discard) ve worktree'i temizler. [9](#2-8) 

### 8. Test-Driven Development
RED-GREEN-REFACTOR döngüsü: önce başarısız test yaz, başarısız olduğunu gör, minimal kod yaz, geçtiğini gör, commit yap. [10](#2-9) 

## Notes

- **Temel İş Akışı:** 7 zorunlu skill'den oluşur: brainstorming, using-git-worktrees, writing-plans, subagent-driven-development/executing-plans, test-driven-development, requesting-code-review, finishing-a-development-branch. [11](#2-10) 
- **Platform Uyarlama:** Skill'ler Claude Code araç isimleriyle yazılır ancak diğer platformlar için bir eşleştirme katmanı vardır (Copilot CLI, Codex, Gemini CLI). [12](#2-11) 
- **Model Seçimi:** Subagent-driven development'da görev karmaşıklığına göre model seçilir (mekanik → ucuz model, entegrasyon → standart model, mimari → yetenekli model). [13](#2-12) 

Wiki pages you might want to explore:
- [Glossary (obra/superpowers)](/wiki/obra/superpowers#11)
- [Code Review Process (obra/superpowers)](/wiki/obra/superpowers#6.8)

### Citations

**File:** skills/using-superpowers/SKILL.md (L10-16)
```markdown
<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>
```

**File:** skills/using-superpowers/SKILL.md (L38-40)
```markdown
## Platform Adaptation

Skills use Claude Code tool names. Non-CC platforms: see `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.
```

**File:** skills/brainstorming/SKILL.md (L12-14)
```markdown
<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>
```

**File:** skills/brainstorming/SKILL.md (L111-111)
```markdown
- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
```

**File:** skills/writing-plans/SKILL.md (L18-18)
```markdown
**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
```

**File:** skills/writing-plans/SKILL.md (L63-104)
```markdown
## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````
```

**File:** skills/subagent-driven-development/SKILL.md (L14-14)
```markdown
**Continuous execution:** Do not pause to check in with your human partner between tasks. Execute all tasks from the plan without stopping. The only reasons to stop are: BLOCKED status you cannot resolve, ambiguity that genuinely prevents progress, or all tasks complete. "Should I continue?" prompts and progress summaries waste their time — they asked you to execute the plan, so execute it.
```

**File:** skills/subagent-driven-development/SKILL.md (L89-103)
```markdown
## Model Selection

Use the least powerful model that can handle each role to conserve cost and increase speed.

**Mechanical implementation tasks** (isolated functions, clear specs, 1-2 files): use a fast, cheap model. Most implementation tasks are mechanical when the plan is well-specified.

**Integration and judgment tasks** (multi-file coordination, pattern matching, debugging): use a standard model.

**Architecture, design, and review tasks**: use the most capable available model.

**Task complexity signals:**
- Touches 1-2 files with a complete spec → cheap model
- Touches multiple files with integration concerns → standard model
- Requires design judgment or broad codebase understanding → most capable model

```

**File:** skills/executing-plans/SKILL.md (L16-38)
```markdown
## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

```

**File:** skills/requesting-code-review/SKILL.md (L26-30)
```markdown
**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```
```

**File:** skills/finishing-a-development-branch/SKILL.md (L18-38)
```markdown
### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.
```

**File:** README.md (L163-177)
```markdown
1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.
```
