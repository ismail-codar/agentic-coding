---
name: project-history-curator
description: >-
  Curate and simplify long-running software project history without losing important
  context. Use when a repository has accumulated many plan, progress, prompt,
  specification, decision, note, TODO, handoff, or history files and the user wants
  to consolidate current state, archive completed work, preserve architectural
  decisions, repair documentation references, or reduce context for Claude Code,
  Codex, ChatGPT, or other coding agents. Never deletes files: completed or obsolete
  material is moved into a root `_archive/` folder that is excluded from VS Code
  search, and all summarization, organization, and archival work is reversible.
---

# Project History Curator

## Platform Compatibility

Use this skill through the shared Agent Skills `SKILL.md` format. Do not depend on platform-specific metadata for core behavior.

- In Claude Code, support project installation under `.claude/skills/project-history-curator/` and user installation under `~/.claude/skills/project-history-curator/`.
- In Claude.ai, support ZIP upload as a custom Skill.
- In ChatGPT, allow `agents/openai.yaml` to provide interface metadata without changing the workflow.
- Treat `SKILL.md` and referenced files as the portable source of truth across platforms.
- Do not require an `agents/claude.yaml` file; Claude discovers skills from `SKILL.md`.

Simplify repository context while preserving decisions, unfinished work, and traceability. Prefer a small active context plus a searchable-on-demand archive over destructive cleanup.

## Language

Detect the dominant language of project documentation.

- Write generated project documents in that language.
- Preserve established terminology and file naming conventions where practical.
- If documentation is predominantly Turkish, produce Turkish headings and summaries.
- Keep code identifiers, paths, commands, and technical product names unchanged.
- If the repository is multilingual, follow the language used by the nearest related documents.

## Safety Model

This skill never permanently deletes a file. Not with approval, not on request within this skill. If the user wants something deleted for good, tell them to do it manually after the curation run; it is outside this skill's scope.

Every reduction of active context is a move into `_archive/`. Moves are reversible with `git mv` or a plain move back.

Perform these reversible actions without additional approval:

- Inspect and classify documentation.
- Create or update current-state and decision summaries.
- Create plan summaries.
- Move clearly completed, obsolete, superseded, or duplicate material into `_archive/`.
- Repair Markdown links and documentation references affected by moves.
- Write or update the archive manifest (`_archive/ARCHIVE.md`).
- Configure the repository so `_archive/` is hidden from VS Code search.

Do not treat Git history as the only backup. A repository may be shallow, squashed, exported, or not tracked. That is one more reason to move rather than delete.

When status is uncertain, retain the file in place and mark it for manual review.

## Repository Discovery

Inspect the repository before changing files. Look for:

- `plans/`, `.plans/`, `docs/`, `notes/`, `history/`, `.claude/`, `.codex/`, an existing `_archive/`
- `CLAUDE.md`, `AGENTS.md`, `PROJECT_STATE.md`, `DECISIONS.md`, ADR files, and README files
- Files named or containing concepts such as prompt, spec, implementation, progress, plan, todo, notes, decision, handoff, changelog, summary, archive, completed, cancelled, superseded
- References from active documentation to candidate files
- Code and configuration that reveal the current architecture and implemented state
- `.vscode/settings.json` and any existing `search.exclude` configuration

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

Items in classes 2, 3, 4, and 7 are archive candidates. Items in classes 1, 5, and 8 stay where they are. Class 6 stays in place when it is referenced by active documents; otherwise it is archived with a summary.

## Choose the Target Structure

Prefer the repository's existing conventions for the active side, including wherever and however the user keeps plans. When no suitable convention exists, suggest (do not impose) a layout such as:

```text
PROJECT_STATE.md
DECISIONS.md
<plans location>/          # e.g. docs/plans/ for ce-plan, or the user's own
docs/
  history/
_archive/
  ARCHIVE.md
  <plans location>/
    <plan-name>.md            # single-file plan, archived as-is
    <plan-name>.SUMMARY.md
    <plan-name>/              # or a multi-file plan folder
      SUMMARY.md
      ...original files...
  docs/
  notes/
  ...
```

Rules for `_archive/`:

- It lives at the repository root and is always named `_archive`. The leading underscore keeps it sorted first and makes it easy to exclude.
- Mirror the original relative path under `_archive/` so `plans/2024-login/` becomes `_archive/plans/2024-login/`. Preserve file names.
- If the repository already has an archive location such as `plans/archive/` or `docs/archive/`, do not create a parallel one. Either keep using the existing location or, if the user agrees, move it under `_archive/` in one step and repair references.
- `_archive/` is committed to Git. Do not add it to `.gitignore`.

Do not force the active-side layout when an equivalent structure already exists, such as ADR directories, RFC folders, or a documented planning system.

## Hide `_archive/` from VS Code Search

The archive must not pollute workspace search, Quick Open, or agent file discovery. Configure this in the target repository as part of every run that creates or uses `_archive/`.

Create or update `.vscode/settings.json` so it contains at least:

```json
{
  "search.exclude": {
    "**/_archive": true,
    "**/_archive/**": true
  },
  "files.watcherExclude": {
    "**/_archive/**": true
  }
}
```

Rules:

- Merge into an existing `.vscode/settings.json`. Never overwrite other keys. Preserve existing entries under `search.exclude` and `files.watcherExclude`.
- Do not add `_archive` to `files.exclude`. The folder should stay visible in the Explorer so people can open it deliberately; it only disappears from search.
- If `.vscode/` is listed in `.gitignore`, tell the user that the exclusion will be local-only and offer to keep it anyway.
- If the repository already uses `search.useIgnoreFiles` with a custom ignore file, add `_archive/` there as well.
- For Claude Code and similar agents, mention `_archive/` in `CLAUDE.md` or `AGENTS.md` as "read only when explicitly asked" so agents do not load it by default.

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

Archive plans only when evidence clearly shows they are completed, cancelled, or superseded. Move the plan (a single file or a whole folder) into `_archive/` under its original relative path and name to avoid broken references and loss of chronology.

For every archived plan, create or update a concise `SUMMARY.md` using `references/document-templates.md`. For a single-file plan, place it next to the archived file as `<plan-name>.SUMMARY.md`. Summarize outcomes rather than copying the entire history.

Preserve unresolved items by moving them into an active plan, current-state document, issue tracker reference, or the archived plan's open-items section.

Do not assume or impose a plan format. Plans may be single files (for example `ce-plan` output under `docs/plans/`), multi-file folders, or any other structure the user prefers; archive whatever files make up the plan unchanged.

## Archive Manifest

Maintain `_archive/ARCHIVE.md` using the template in `references/document-templates.md`. For every archived item record:

- Original path
- Archive path
- Classification
- Reason
- Where current information is preserved
- Reference check result
- Date archived

Append to the manifest on every run. Never rewrite history already in it; correct an entry by adding a note.

## Handle Instructions for Coding Agents

If `CLAUDE.md` or `AGENTS.md` exists, add only concise operational guidance needed for future sessions:

- Read the current-state document before work.
- Check active plans before implementation.
- Do not repeat completed plans.
- Record material architecture decisions.
- Update current state after significant work.
- Summarize completed plans and move them to `_archive/`.
- Do not read `_archive/` unless explicitly asked.
- Avoid unrelated refactoring.

Do not duplicate large project histories into agent instruction files. Keep them compact because they may be loaded every session.

If both `CLAUDE.md` and `AGENTS.md` exist, preserve both and resolve direct contradictions minimally. Do not move either into the archive merely to standardize naming.

## Repair References

After moving files:

- Search Markdown links, relative paths, and plain-text references.
- Update references that can be resolved confidently to the new `_archive/` path.
- Check agent instructions, README files, indexes, and active plans.
- Avoid editing source code unless a documentation path used by code is actually affected.

## Archive Gate

Before moving an item into `_archive/`, verify all conditions:

1. The item is completed, cancelled, superseded, or truly duplicated.
2. Current information is preserved in the current-state document.
3. Important decisions are preserved in the decision log.
4. A plan summary preserves necessary historical context.
5. No active document or code path depends on the item, or the dependency has been repaired.
6. Archiving will not hide the only evidence for an unresolved issue.

If any condition fails, leave the item in place and list it under manual review.

## Validation

Before reporting completion, verify:

- Active plans represent unfinished work.
- Archived plans are not needed for current execution.
- Current-state claims match the repository.
- Decisions are meaningful and traceable.
- Important unresolved work remains visible.
- Moved files have no known broken documentation references.
- `_archive/ARCHIVE.md` lists every move made in this run.
- `.vscode/settings.json` excludes `_archive` from search and no unrelated setting was changed.
- Code behavior and dependencies were not changed.
- No file was deleted. Confirm with `git status` that there are only renames, additions, and modifications.
- The new structure is simpler than the old one.

Use `references/review-checklist.md` for the final review.

## Final Report

Report:

- Created files
- Updated files
- Moved files, as `old path -> new path`
- Archived plans
- Active plans retained
- VS Code search exclusion status
- Important decisions preserved
- Uncertain items requiring manual review
- Recommended ongoing workflow

State explicitly that no files were deleted.

## Scope Boundaries

Do not implement product features, upgrade dependencies, rewrite application architecture, or perform broad refactoring as part of this skill.

Do not delete files. Do not empty `_archive/`. Do not add `_archive/` to `.gitignore`.

Make minimal documentation and organization changes necessary to reduce active context safely.
