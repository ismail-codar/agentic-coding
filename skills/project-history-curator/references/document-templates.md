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

## Source Files
- `prompt.md`
- `spec.md`
- `implementation.md`
- `progress.md`
```

## Deletion Candidate Report

```md
# Deletion Candidates

No file in this list may be deleted without explicit user approval.

| Path | Classification | Reason | Preserved In | Reference Check | Risk |
|---|---|---|---|---|---|
| `path` | Duplicate | Explanation | `SUMMARY.md` | No references found | Low |
```
