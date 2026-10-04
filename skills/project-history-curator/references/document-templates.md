# Document Templates

Translate headings into the repository's dominant documentation language.

## Current State

```md
# Project State

## Project Purpose

## Current Architecture

## Main Modules and Responsibilities

## Major Completed Work

## Active Work

## Known Issues and Technical Debt

## Constraints and Assumptions to Preserve

## Next Steps
```

Keep this document concise and current. Link to detailed plans instead of embedding their full history.

## Decision Entry

```md
## YYYY-MM-DD — Decision title

**Decision:**

**Rationale:**

**Alternatives:**

**Affected areas:**

**Status:** Current | Changed | Retired

**Sources:**
- `path/to/source.md`
```

Use `Date unknown` when the date cannot be established reliably.

## Archived Plan Summary

```md
# Plan Summary

## Status
Completed | Cancelled | Superseded

## Purpose

## Outcomes

## Important Decisions

## Affected Areas

## Open Items

## Archive Reason

## Original Location
`<original plan path>`

## Source Files
- List the archived plan files as they exist; do not assume a fixed set.
```

## Archive Manifest

Lives at `_archive/ARCHIVE.md`. Append a row for every move; never delete rows.

```md
# Archive Manifest

Nothing in `_archive/` is deleted by the curator. Move an entry back with `git mv` if it is needed again.

| Archived | Original Path | Archive Path | Classification | Reason | Preserved In | Reference Check |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | `docs/plans/old-plan.md` | `_archive/docs/plans/old-plan.md` | Completed | Explanation | `PROJECT_STATE.md`, `SUMMARY.md` | 2 links updated |
```

## VS Code Search Exclusion

Merge into the target repository's `.vscode/settings.json`. Keep every existing key.

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
