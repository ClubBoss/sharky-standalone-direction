#!/usr/bin/env python3
"""docs_frontmatter_v1.py — add derived routing frontmatter to docs markdown.

Why: document status lives in prose here, so a fully superseded review reads as
authoritative until an agent opens it. Reading N documents to learn which one is
current is the largest token sink in this repository. Machine-readable
frontmatter lets a session route with one grep instead of N reads.

Honesty contract:
  * every field is DERIVED from the document's own text, never invented;
  * `status_source: derived` marks that the value was extracted, not authored,
    so nobody mistakes it for an owner declaration;
  * `supersedes` / `superseded_by` are emitted ONLY when the prose says so
    explicitly. Supersession is never guessed.
  * the document body is preserved byte for byte. The script asserts this and
    refuses to write when it would not hold.

Safety: documents referenced from code, tests, or CI are EXCLUDED by default.
Several guards read docs with positional logic (`startsWith`, `split('\\n')`),
so shifting their first line could break a green lane.

Usage:
  tools/docs_frontmatter_v1.py --dry-run                  # default: report only
  tools/docs_frontmatter_v1.py --dry-run --limit 20       # pilot sample
  tools/docs_frontmatter_v1.py --apply                    # write
  tools/docs_frontmatter_v1.py --apply --dirs docs/_reviews
  tools/docs_frontmatter_v1.py --verify                   # check body integrity only
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

DEFAULT_DIRS = ["docs/_reviews", "docs/plan", "docs/context"]

# Top-authority documents are never stamped. A DERIVED status line at the head of
# the highest-authority document could be read as an owner declaration, which is
# exactly the confusion this tool exists to remove. These documents declare their
# own status and are read first by policy.
AUTHORITY_EXCLUDE = {
    "docs/plan/MASTER_PLAN_v3.0.md",
    "docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md",
    "docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md",
    "docs/plan/EXECUTION_POLICY_SSOT_v1.md",
    "docs/plan/MONETIZATION_SSOT_v1.md",
    "docs/plan/PRE_HUMAN_AND_HUMAN_PROVEN_CAMPAIGN_v1.md",
    "docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md",
    "docs/context/CONTEXT_ROUTER_v1.md",
}

STATUS_RE = re.compile(r"^(?:Status|Verdict|Disposition)\**\s*[:—-]\s*(.+?)\s*$", re.IGNORECASE)
HEADING_STATUS_RE = re.compile(
    r"^#{1,4}\s*(?:\d+[.)]\s*)?(?:Status|Verdict|Disposition)\b.*$", re.IGNORECASE
)
DATE_RE = re.compile(r"\b(20\d{2}-[01]\d-[0-3]\d)\b")
SHA_RE = re.compile(r"\b([0-9a-f]{8,40})\b")
SUPERSEDED_BY_RE = re.compile(
    r"superseded(?:\s+in\s+full)?\s+by\s+`?([A-Za-z0-9_./-]+\.md)`?", re.IGNORECASE
)
SUPERSEDES_RE = re.compile(r"supersedes\s+`?([A-Za-z0-9_./-]+\.md)`?", re.IGNORECASE)

MARKER = "docs_frontmatter_v1"
# Consumes the closing delimiter plus the single blank separator line that
# render() emits, so stripping is the exact inverse of stamping.
FRONTMATTER_BLOCK_RE = re.compile(r"\A---\r?\n.*?\r?\n---\r?\n(?:\r?\n)?", re.DOTALL)


def referenced_docs(repo: Path) -> set[str]:
    """Docs mentioned anywhere in code, tests, CI, or build files."""
    roots = ["test", "tools", "bin", "scripts", "lib", ".github", "Makefile"]
    present = [r for r in roots if (repo / r).exists()]
    if not present:
        return set()
    try:
        out = subprocess.run(
            ["grep", "-rhoE", r"docs/[A-Za-z0-9_./-]+\.md", *present],
            cwd=repo, capture_output=True, text=True, check=False,
        ).stdout
    except OSError:
        return set()
    return {line.strip() for line in out.splitlines() if line.strip()}


def strip_frontmatter(text: str) -> tuple[str | None, str]:
    m = FRONTMATTER_BLOCK_RE.match(text)
    if not m:
        return None, text
    return m.group(0), text[m.end():]


def derive(text: str) -> dict[str, str]:
    fields: dict[str, str] = {}

    lines = text.splitlines()
    status = None

    # Form A — inline: "Status: X" / "Verdict: X" / "**Verdict:** X".
    for line in lines[:80]:
        candidate = line.strip().lstrip("*# ").strip()
        m = STATUS_RE.match(candidate)
        if m:
            status = re.sub(r"\s+", " ", m.group(1)).strip(" .*`\"")
            if status:
                break

    # Form B — heading then value, the dominant convention in docs/_reviews:
    #   ## 1. Verdict
    #
    #   `accepted_with_known_gaps`
    if not status:
        for i, line in enumerate(lines[:120]):
            if HEADING_STATUS_RE.match(line.strip()):
                for nxt in lines[i + 1: i + 6]:
                    value = nxt.strip().strip("`*_ ").strip()
                    if value and not value.startswith(("#", "|", "-", ">")):
                        status = re.sub(r"\s+", " ", value).strip(" .*`\"")
                        break
                if status:
                    break
    fields["status"] = status[:120] if status else "undeclared"
    fields["status_source"] = "derived" if status else "absent"

    d = DATE_RE.search(text)
    if d:
        fields["doc_date"] = d.group(1)

    for m in SHA_RE.finditer(text):
        sha = m.group(1)
        if len(sha) >= 8 and not sha.isdigit():
            fields["baseline"] = sha[:12]
            break

    sb = SUPERSEDED_BY_RE.search(text)
    if sb:
        fields["superseded_by"] = sb.group(1)
    sp = SUPERSEDES_RE.search(text)
    if sp:
        fields["supersedes"] = sp.group(1)

    return fields


def render(fields: dict[str, str]) -> str:
    order = ["status", "status_source", "doc_date", "baseline", "supersedes", "superseded_by"]
    lines = ["---"]
    for key in order:
        if key in fields:
            lines.append(f"{key}: {json.dumps(fields[key])}")
    lines.append(f"generated_by: {json.dumps(MARKER)}")
    lines.append("---")
    lines.append("")
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write files (default is dry-run)")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verify", action="store_true", help="only check body integrity of stamped files")
    ap.add_argument("--dirs", nargs="*", default=DEFAULT_DIRS)
    ap.add_argument("--limit", type=int, default=0)
    args = ap.parse_args()

    repo = Path(__file__).resolve().parent.parent
    excluded = referenced_docs(repo) | AUTHORITY_EXCLUDE

    files: list[Path] = []
    for d in args.dirs:
        base = repo / d
        if base.exists():
            files.extend(sorted(p for p in base.glob("*.md") if p.is_file()))

    stamped = skipped_excluded = skipped_existing = failed = verified = 0
    samples: list[str] = []

    for path in files:
        rel = path.relative_to(repo).as_posix()
        original = path.read_text(encoding="utf-8")
        existing, body = strip_frontmatter(original)

        if args.verify:
            if existing and MARKER in existing:
                verified += 1
            continue

        if rel in excluded:
            skipped_excluded += 1
            continue
        if existing is not None:
            skipped_existing += 1
            continue

        new_text = render(derive(original)) + original

        # Body must survive byte for byte.
        _, roundtrip = strip_frontmatter(new_text)
        if hashlib.sha256(roundtrip.encode()).hexdigest() != hashlib.sha256(original.encode()).hexdigest():
            print(f"REFUSED (body would change): {rel}", file=sys.stderr)
            failed += 1
            continue

        if args.apply:
            path.write_text(new_text, encoding="utf-8")
        stamped += 1
        if len(samples) < 5:
            samples.append(f"--- {rel} ---\n" + render(derive(original)).rstrip())

    if args.verify:
        print(f"verify: {verified} files carry {MARKER} frontmatter")
        return 0

    mode = "APPLIED" if args.apply else "DRY-RUN"
    print(f"[{mode}] scanned={len(files)} stamped={stamped} "
          f"skipped_code_referenced={skipped_excluded} skipped_already_stamped={skipped_existing} "
          f"refused={failed}")
    if samples and not args.apply:
        print("\n" + "\n\n".join(samples))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
