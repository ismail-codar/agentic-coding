# Project History Curator

A portable Agent Skill for safely consolidating long-running software project history.

## Compatibility

This package uses the shared `SKILL.md` Agent Skills format and is compatible with:

- ChatGPT Skills
- Claude.ai custom Skills
- Claude Code project or user Skills
- Other agents that support the open Agent Skills format

The file `agents/openai.yaml` contains ChatGPT-specific display metadata only. Claude does not require an `agents/claude.yaml` file; Claude discovers the skill from `SKILL.md`.

## Install in Claude Code

Project-scoped installation:

```text
<repository>/.claude/skills/project-history-curator/
```

Copy the complete `project-history-curator` folder into that location. Keep `SKILL.md` and the `references/` directory together.

User-scoped installation:

```text
~/.claude/skills/project-history-curator/
```

Claude Code discovers the skill automatically from its `name` and `description` metadata.

## Install in Claude.ai

Upload the ZIP as a custom Skill. The archive contains one skill folder with `SKILL.md` at its root.

## Example requests

- "Bu projedeki eski planları özetle ve tamamlananları güvenli şekilde arşivle."
- "Consolidate this repository's project history and preserve important decisions."
- "Review deletion candidates, but do not permanently delete anything without my approval."
