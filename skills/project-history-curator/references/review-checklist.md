# Final Review Checklist

## Evidence

- Every archived plan has clear evidence of completion, cancellation, or supersession.
- Old age alone was not used as evidence.
- Uncertain status is labeled rather than guessed.

## Information Preservation

- Current state includes active work and immediate next steps.
- Important decisions retain rationale and sources.
- Open items were not buried in archives.
- Archived plans have concise summaries.

## Safety

- No file was deleted; `git status` shows only renames, additions, and modifications.
- Every moved item has a row in `_archive/ARCHIVE.md` stating where its information was preserved.
- References to moved files were searched and repaired where possible.
- Git history was not assumed to be the sole backup.

## Archive Hygiene

- Archived items live under the root `_archive/` with their original relative path.
- `.vscode/settings.json` excludes `_archive` from search; other settings are untouched.
- `_archive/` is not in `.gitignore` and not in `files.exclude`.
- Agent instruction files say `_archive/` is read only on explicit request.

## Scope

- No product behavior changed.
- No unrelated refactor or dependency update occurred.
- Agent instruction files remain concise.
- The resulting active context is materially smaller and clearer.
