---
name: project-history-curator
description: >-
  Curate and simplify long-running software project history without losing important
  context. Use when a repository has accumulated many plan, progress, prompt,
  specification, decision, note, TODO, handoff, or history files and the user wants
  to consolidate current state, archive completed work, preserve architectural
  decisions, repair documentation references, or reduce context for Claude Code,
  Codex, ChatGPT, or other coding agents. Apply a hybrid safety model by performing
  reversible summarization, organization, and archival work automatically while
  requiring explicit user approval before permanent deletion.
---

# Project History Curator

## Platform Compatibility

Use this skill through the shared Agent Skills `SKILL.md` format. Do not depend on platform-specific metadata for core behavior.

- In Claude Code, support project installation under `.claude/skills/project-history-curator/` and user installation under `~/.claude/skills/project-history-curator/`.
- In Claude.ai, support ZIP upload as a custom Skill.
- In ChatGPT, allow `agents/openai.yaml` to provide interface metadata without changing the workflow.
- Treat `SKILL.md` and referenced files as the portable source of truth across platforms.
- Do not require an `agents/claude.yaml` file; Claude discovers skills from `SKILL.md`.

Simplify repository context while preserving decisions, unfinished work, and traceability. Prefer a small active context plus searchable archives over destructive cleanup.

## Language

Detect the dominant language of project documentation.

- Write generated project documents in that language.
- Preserve established terminology and file naming conventions where practical.
- If documentation is predominantly Turkish, produce Turkish headings and summaries.
- Keep code identifiers, paths, commands, and technical product names unchanged.
- If the repository is multilingual, follow the language used by the nearest related documents.

## Safety Model

Use a hybrid workflow.

Perform these reversible actions without additional approval:

- Inspect and classify documentation.
- Create or update current-state and decision summaries.
- Create plan summaries.
- Move clearly completed or obsolete plans into an archive.
- Repair Markdown links and documentation references affected by moves.
- Produce a deletion-candidate report.

Never permanently delete a file without explicit user approval in the current conversation.

Do not treat Git history as the only backup. A repository may be shallow, squashed, exported, or not tracked.

When status is uncertain, retain the file and mark it for manual review.

## Repository Discovery

Inspect the repository before changing files. Look for:

- `plans/`, `.plans/`, `docs/`, `notes/`, `history/`, `.claude/`, `.codex/`
- `CLAUDE.md`, `AGENTS.md`, `PROJECT_STATE.md`, `DECISIONS.md`, ADR files, and README files
- Files named or containing concepts such as prompt, spec, implementation, progress, plan, todo, notes, decision, handoff, changelog, summary, archive, completed, cancelled, superseded
- References from active documentation to candidate files
- Code and configuration that reveal the current architecture and implemented state

Respect repository-local instructions before making changes. Do not weaken or overwrite project-specific rules.

## Classify Evidence

Classify each relevant item as one of:

1. Active and incomplete
2. Completed
3. Cancelled
4. Superseded or obsolete
5. Current decision or constraint
6. Historical but valuable
7. Duplicate or low-value detail
8. Uncertain; manual review required

Base classifications on evidence such as checked progress items, implementation state, code presence, timestamps, explicit status text, references, and later superseding plans. Do not infer completion from age alone.

Record uncertainty explicitly. Never invent dates, decisions, completion status, or rationale.

## Choose the Target Structure

Prefer the repository's existing conventions. When no suitable convention exists, use:

```text
PROJECT_STATE.md
DECISIONS.md
plans/
  active/
  archive/
docs/
  history/
```

Do not force this layout when an equivalent structure already exists, such as ADR directories, RFC folders, or a documented planning system.

## Build the Current-State Document

Create or update `PROJECT_STATE.md`, or the repository's equivalent, using the template in `references/document-templates.md`.

Include only currently useful information:

- Project purpose
- Current architecture
- Main modules and responsibilities
- Major completed capabilities
- Active work
- Known issues and technical debt
- Constraints and assumptions that must be preserved
- Immediate next steps

Verify claims against current code and configuration when practical. Mark inferred statements as inferred. Do not copy old discussions verbatim.

## Consolidate Decisions

Create or update `DECISIONS.md`, an ADR index, or the repository's equivalent.

For each meaningful decision, preserve:

- Decision
- Rationale
- Important alternatives, when documented
- Affected areas
- Current status
- Source references

Merge duplicates carefully. Mark changed or retired decisions rather than silently removing them. Use `Date unknown` or its project-language equivalent when no reliable date exists.

## Curate Plans

Keep genuinely active work in the active plan location.

Archive plans only when evidence clearly shows they are completed, cancelled, or superseded. Preserve existing names where possible to avoid broken references and loss of chronology.

For every archived plan folder, create or update a concise `SUMMARY.md` using `references/document-templates.md`. Summarize outcomes rather than copying the entire history.

Preserve unresolved items by moving them into an active plan, current-state document, issue tracker reference, or the archived plan's open-items section.

When the repository uses the plan-driven structure with `prompt.md`, `spec.md`, `implementation.md`, and `progress.md`, preserve those files in the archive unless deletion is later approved.

## Handle Instructions for Coding Agents

If `CLAUDE.md` or `AGENTS.md` exists, add only concise operational guidance needed for future sessions:

- Read the current-state document before work.
- Check active plans before implementation.
- Do not repeat completed plans.
- Record material architecture decisions.
- Update current state after significant work.
- Summarize and archive completed plans.
- Read detailed archives only when needed.
- Avoid unrelated refactoring.

Do not duplicate large project histories into agent instruction files. Keep them compact because they may be loaded every session.

If both `CLAUDE.md` and `AGENTS.md` exist, preserve both and resolve direct contradictions minimally. Do not delete either merely to standardize naming.

## Repair References

After moving files:

- Search Markdown links, relative paths, and plain-text references.
- Update references that can be resolved confidently.
- Check agent instructions, README files, indexes, and active plans.
- Avoid editing source code unless a documentation path used by code is actually affected.

## Permanent Deletion Gate

Before proposing deletion, verify all conditions:

1. The item is completed, obsolete, or truly duplicated.
2. Current information is preserved in the current-state document.
3. Important decisions are preserved in the decision log.
4. A plan summary preserves necessary historical context.
5. No active document or code path depends on the item.
6. Deletion will not remove the only evidence for an unresolved issue.

Then create a deletion-candidate list containing:

- Path
- Classification
- Reason
- Information preserved elsewhere
- Reference check result
- Risk level

Ask for explicit approval before deleting any listed file. Approval for one set of paths does not imply approval for new paths discovered later.

If approval is not available, leave the candidates untouched.

## Validation

Before reporting completion, verify:

- Active plans represent unfinished work.
- Archived plans are not needed for current execution.
- Current-state claims match the repository.
- Decisions are meaningful and traceable.
- Important unresolved work remains visible.
- Moved files have no known broken documentation references.
- Code behavior and dependencies were not changed.
- No permanent deletion occurred without approval.
- The new structure is simpler than the old one.

Use `references/review-checklist.md` for the final review.

## Final Report

Report:

- Created files
- Updated files
- Moved files
- Archived plans
- Active plans retained
- Deletion candidates awaiting approval
- Permanently deleted files, only when approved
- Important decisions preserved
- Uncertain items requiring manual review
- Recommended ongoing workflow

State explicitly when no files were deleted.

## Scope Boundaries

Do not implement product features, upgrade dependencies, rewrite application architecture, or perform broad refactoring as part of this skill.

Make minimal documentation and organization changes necessary to reduce active context safely.
