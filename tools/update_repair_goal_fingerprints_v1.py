#!/usr/bin/env python3
"""Rewrite stale repair-goal fingerprints after a task copy edit.

Repair goals pin a hash of the task content. After editing task text, run:
    python3 tools/update_repair_goal_fingerprints_v1.py
It runs the guard test, takes the current hash it prints for every stale goal
and replaces the old hash wherever it appears in lib/ and test/ui_v2/.
Review the diff: the retry now points at the edited task content.
"""
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTRACTS = ROOT / "lib/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart"
GUARD = "test/ui_v2/act0_repair_goal_fingerprints_current_v1_test.dart"
LINE = re.compile(r"^\s+(\S+) (source|target) (\S+): now ([0-9a-f]{64})$", re.M)


def blocks(text):
    parts = text.split("Act0RepairGoalContractV1(")
    return parts[1:]


def old_hash(text, relation, kind, task):
    task_key = "targetTaskId" if kind == "target" else "sourceTaskId"
    for block in blocks(text):
        if (re.search(r"relationId:\s*['\"]%s['\"]" % re.escape(relation), block)
                and re.search(task_key + r":\s*['\"]%s['\"]" % re.escape(task), block)):
            keys = ("targetFingerprint",) if kind == "target" else (
                "sourceFingerprint", "sourceContainerFingerprint")
            for key in keys:
                m = re.search(key + r":\s*['\"]([0-9a-f]{64})['\"]", block)
                if m:
                    return m.group(1)
    return None


def main():
    run = subprocess.run(["flutter", "test", GUARD], cwd=ROOT,
                         capture_output=True, text=True)
    stale = {(m[0], m[1], m[2]): m[3] for m in LINE.findall(run.stdout)}
    if not stale:
        print("all repair-goal fingerprints are current")
        return 0
    text = CONTRACTS.read_text()
    replace = {}
    for (relation, kind, task), new in stale.items():
        old = old_hash(text, relation, kind, task)
        if old is None:
            sys.exit(f"cannot find pinned {kind} hash for {relation}")
        replace[old] = new
    files = [p for d in ("lib", "test/ui_v2") for p in (ROOT / d).rglob("*.dart")]
    for path in files:
        body = path.read_text()
        updated = body
        for old, new in replace.items():
            updated = updated.replace(old, new)
        if updated != body:
            path.write_text(updated)
            print("updated", path.relative_to(ROOT))
    for old, new in replace.items():
        print(f"{old[:12]} -> {new[:12]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
