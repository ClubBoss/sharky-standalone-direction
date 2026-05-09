#!/usr/bin/env python3
import json
import pathlib
import re
import subprocess
import sys
from typing import Dict, List, Optional, Set, Tuple

ROOT = pathlib.Path(".")
CONTENT = ROOT / "content"
ALLOWDIR = ROOT / "tooling" / "allowlists"

# Allow importing sibling tools without making tools/ a package
if str((ROOT / "tools").resolve()) not in sys.path:
    sys.path.append(str((ROOT / "tools").resolve()))
try:
    import jsonl_guard  # type: ignore
except Exception:
    jsonl_guard = None  # Fallback: still run, but parsing errors will be surfaced below

def is_ascii(s: str) -> bool:
    try:
        s.encode("ascii")
        return True
    except:
        return False

def collect_targets(drills_path: pathlib.Path):
    out = []
    for idx, ln in enumerate(drills_path.read_text(encoding="utf-8").splitlines(), start=1):
        ln = ln.strip()
        if not ln:
            continue
        try:
            obj = json.loads(ln)
        except json.JSONDecodeError as e:
            col = getattr(e, "colno", 1) or 1
            # Mirror guard message style
            caret = " " * (col - 1) + "^"
            msg = f"BAD {drills_path}:{idx}:{col} -> {e.msg}\n{ln}\n{caret}"
            print(msg)
            sys.exit(1)
        t = obj.get("target","")
        if t:
            out.append(t)
    return sorted({tuple(x) if isinstance(x, list) else x for x in out}, key=str)

def _drill_paths(
    staged_modules: Optional[Dict[str, Set[Optional[str]]]] = None,
) -> List[pathlib.Path]:
    candidates = sorted(CONTENT.glob("*/v1/drills.jsonl"))
    result = []
    for path in candidates:
        module, version = _module_and_version(path)
        if _should_include(module, version, staged_modules):
            result.append(path)
    return result

def _module_and_version(path: pathlib.Path) -> Tuple[str, str]:
    relative = path.relative_to(CONTENT)
    part = relative.parts
    return part[0], part[1].lower()

def _should_include(
    module: str,
    version: str,
    staged_modules: Optional[Dict[str, Set[Optional[str]]]],
) -> bool:
    if staged_modules is None:
        return True
    versions = staged_modules.get(module)
    if not versions:
        return False
    if None in versions:
        return True
    return version in versions

def sync(
    mode: str,
    staged_modules: Optional[Dict[str, Set[Optional[str]]]] = None,
) -> int:
    errors = []
    if staged_modules is not None and not staged_modules:
        return 0
    # Validate drills with the JSONL guard first (auto-fix by default)
    drill_paths = _drill_paths(staged_modules)
    drill_files: List[str] = [str(p) for p in drill_paths]
    if jsonl_guard is not None and drill_files:
        rc = jsonl_guard.validate_paths(drill_files, fix=True)
        if rc != 0:
            return rc
    for drills in drill_paths:
        module = drills.parts[1]  # content/<module>/v1/...
        targets = collect_targets(drills)
        if not targets:
            # Some training bundles use narrative/value-style drills and do not
            # expose tokenized "target" fields. These modules should not block
            # commits via allowlist synchronization.
            continue
        ALLOWDIR.mkdir(parents=True, exist_ok=True)
        allow = ALLOWDIR / f"target_tokens_allowlist_{module}.txt"
        want = "\n".join(str(x) for x in targets) + "\n"
        have = allow.read_text(encoding="utf-8") if allow.exists() else ""
        if not is_ascii(want):
            errors.append(f"[non-ascii] {allow}")
        if mode == "--check":
            if want != have:
                errors.append(f"[outdated] {allow} (run tools/allowlists_sync.py --write)")
        else:
            allow.write_text(want, encoding="utf-8")
    if mode == "--check" and errors:
        print("\n".join(errors))
        return 1
    return 0

def _parse_args(args: List[str]) -> Tuple[str, bool]:
    mode = "--check"
    staged_only = False
    for arg in args:
        if arg == "--staged-only":
            staged_only = True
        elif arg in ("--check", "--write"):
            mode = arg
        else:
            print("usage: tools/allowlists_sync.py [--check|--write] [--staged-only]")
            sys.exit(2)
    return mode, staged_only


def _collect_staged_module_versions() -> Dict[str, Set[Optional[str]]]:
    result = subprocess.run(
        [
            "git",
            "diff",
            "--cached",
            "--name-only",
            "--diff-filter=ACDMRT",
            "--",
            "content/**",
            "tooling/allowlists/**",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(f"git diff failed ({result.returncode})\n")
        sys.exit(result.returncode)

    modules: Dict[str, Set[Optional[str]]] = {}
    allowlist_prefix = "tooling/allowlists/target_tokens_allowlist_"
    allowlist_suffix = ".txt"
    for raw in result.stdout.splitlines():
        trimmed = raw.strip()
        if not trimmed:
            continue
        if trimmed.startswith("content/"):
            segments = trimmed.split("/")
            if len(segments) < 3:
                continue
            module, version = segments[1], segments[2].lower()
            if not re.fullmatch(r"v\d+", version, flags=re.IGNORECASE):
                continue
            modules.setdefault(module, set()).add(version)
        elif trimmed.startswith(allowlist_prefix) and trimmed.endswith(
            allowlist_suffix
        ):
            module = trimmed[len(allowlist_prefix) : -len(allowlist_suffix)]
            if module:
                modules.setdefault(module, set()).add(None)
    return modules


if __name__ == "__main__":
    mode, staged_only = _parse_args(sys.argv[1:])
    staged_modules = (
        _collect_staged_module_versions() if staged_only else None
    )
    sys.exit(sync(mode, staged_modules))
