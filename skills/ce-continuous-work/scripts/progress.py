#!/usr/bin/env python
"""ce-continuous-work — `claude -p --output-format stream-json` akışını okur.

Alt komutlar:
  activity <stream.jsonl> [n]   son n araç çağrısını tek satırlık özet olarak basar
  result   <stream.jsonl>       son `result` olayının metnini basar (yoksa çıkış 1)

Fail-soft: bozuk satırlar atlanır; akış yoksa/boşsa sessiz çıkar. Nabız
satırı bu betiğin hatası yüzünden ASLA düşmemeli — çağıran `|| true` kullanır.
"""
import json
import os
import sys


def _events(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except ValueError:
                    continue
    except OSError:
        return


def _short(text, limit=90):
    text = " ".join(str(text).split())
    return text if len(text) <= limit else text[: limit - 1] + "…"


def _describe(name, inp):
    inp = inp or {}
    path = inp.get("file_path") or inp.get("notebook_path") or inp.get("path")
    if path:
        try:
            path = os.path.relpath(path)
        except ValueError:
            pass
    if name in ("Edit", "Write", "MultiEdit", "NotebookEdit", "Read"):
        return f"{name} {path or ''}".strip()
    if name == "Bash":
        return f"Bash: {_short(inp.get('description') or inp.get('command', ''))}"
    if name in ("Grep", "Glob"):
        return f"{name} {_short(inp.get('pattern', ''), 60)}"
    if name == "Skill":
        return f"Skill {inp.get('skill', '')} {_short(inp.get('args', ''), 50)}".strip()
    if name in ("Agent", "Task"):
        return f"{name}: {_short(inp.get('description', ''), 60)}"
    if name == "TodoWrite":
        todos = inp.get("todos") or []
        active = [t.get("activeForm") or t.get("content") for t in todos
                  if t.get("status") == "in_progress"]
        return f"Todo: {_short(active[0], 70)}" if active else "TodoWrite"
    return name


def activity(path, n):
    calls = []
    for ev in _events(path):
        if ev.get("type") != "assistant":
            continue
        for block in (ev.get("message") or {}).get("content") or []:
            if isinstance(block, dict) and block.get("type") == "tool_use":
                calls.append(_describe(block.get("name", "?"), block.get("input")))
    for line in calls[-n:]:
        print(line)
    print(f"#toplam_arac_cagrisi={len(calls)}")


def result(path):
    text = None
    for ev in _events(path):
        if ev.get("type") == "result":
            text = ev.get("result")
    if text is None:
        return 1
    sys.stdout.write(str(text))
    if not str(text).endswith("\n"):
        sys.stdout.write("\n")
    return 0


def main(argv):
    if len(argv) < 3 or argv[1] not in ("activity", "result"):
        print(__doc__, file=sys.stderr)
        return 2
    if argv[1] == "activity":
        activity(argv[2], int(argv[3]) if len(argv) > 3 else 5)
        return 0
    return result(argv[2])


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except AttributeError:
        pass
    sys.exit(main(sys.argv))
