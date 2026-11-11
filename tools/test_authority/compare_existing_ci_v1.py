#!/usr/bin/env python3
"""Read-only, fail-closed comparison of already captured CI/Test Authority receipts.

No GitHub API, test execution, merger, gate or scorecard writes. This tool does
not determine whether an original Sharky DoD is independently accepted.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import tempfile
from pathlib import Path

SCHEMA = "SHARKY_EXISTING_CI_SNAPSHOT_V1"
OUTPUT_SCHEMA = "SHARKY_EXISTING_CI_DIFF_V1"
SHA = re.compile(r"^[0-9a-f]{40}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
ROLES = {"pr_head", "synthetic_merge", "merged_main"}
TERMINAL = {"success", "failure", "cancelled", "skipped", "timed_out", "action_required", "neutral", "stale"}
BAD = {"fail", "error", "timeout", "cancelled"}
GOOD = {"pass"}


def _sha(value: object) -> bool:
    return isinstance(value, str) and bool(SHA.fullmatch(value))


def _require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def validate(snapshot: dict) -> None:
    _require(isinstance(snapshot, dict) and snapshot.get("schema") == SCHEMA, "invalid schema")
    _require(snapshot.get("repo") == "ClubBoss/sharky-standalone-direction", "wrong repository")
    s = snapshot.get("source")
    _require(isinstance(s, dict), "missing source")
    _require(s.get("role") in ROLES and _sha(s.get("sha")), "invalid source role/SHA")
    _require(s.get("tree") is None or _sha(s.get("tree")), "invalid source tree")
    gates = snapshot.get("gates")
    _require(isinstance(gates, list), "missing gates")
    seen = set()
    for gate in gates:
        _require(isinstance(gate, dict) and isinstance(gate.get("key"), str) and gate["key"], "invalid gate")
        _require(gate["key"] not in seen, "duplicate gate")
        seen.add(gate["key"])
        attempts = gate.get("attempts")
        _require(isinstance(attempts, list), "missing attempts")
        ids = set()
        for a in attempts:
            _require(isinstance(a, dict), "invalid attempt")
            ident = (a.get("run_id"), a.get("run_attempt"))
            _require(type(ident[0]) is int and ident[0] > 0 and type(ident[1]) is int and ident[1] > 0, "invalid run identity")
            _require(ident not in ids, "duplicate attempt")
            ids.add(ident)
            _require(a.get("status") in {"queued", "waiting", "requested", "pending", "in_progress", "completed"}, "invalid run status")
            _require(a.get("conclusion") in TERMINAL | {None}, "invalid conclusion")
            _require(a.get("status") == "completed" or a.get("conclusion") is None, "premature conclusion")
            _require(a.get("status") != "completed" or a.get("conclusion") is not None, "missing terminal conclusion")
            _require(a.get("source_sha") is None or _sha(a.get("source_sha")), "invalid attempt SHA")
            _require(a.get("checkout_sha") is None or _sha(a.get("checkout_sha")), "invalid checkout SHA")
            _require(a.get("checkout_tree") is None or _sha(a.get("checkout_tree")), "invalid checkout tree")
            report = a.get("test_authority")
            if report is not None:
                _require(isinstance(report, dict) and isinstance(report.get("results"), list), "invalid Test Authority report")
        chosen = gate.get("selected")
        _require(chosen is None or (isinstance(chosen, list) and len(chosen) == 2
                                     and tuple(chosen) in ids), "selected attempt must exist")


def _gate_map(snapshot: dict) -> dict:
    return {g["key"]: g for g in snapshot["gates"]}


def _chosen(gate: dict | None) -> dict | None:
    if not gate or not gate.get("selected"):
        return None
    return next(a for a in gate["attempts"] if (a["run_id"], a["run_attempt"]) == tuple(gate["selected"]))


def _runs(gate: dict | None) -> list[dict]:
    # Always preserve history, including failures, retries, skips and cancelled attempts.
    return [{k: a.get(k) for k in ("run_id", "run_attempt", "status", "conclusion", "url", "source_sha", "checkout_sha", "checkout_tree", "captured_utc")}
            for a in (gate or {}).get("attempts", [])]


def _result_index(report: dict) -> tuple[dict, str | None]:
    if report.get("smoke") is not False or report.get("complete") is not True:
        return {}, "Test Authority inventory incomplete or smoke-only"
    results = report["results"]
    indexed = {}
    for case in results:
        if not isinstance(case, dict):
            return {}, "malformed case"
        name, cmd, status = case.get("name"), case.get("cmd"), case.get("status")
        if not isinstance(name, str) or not name or not isinstance(cmd, list) or not cmd or any(not isinstance(part, str) for part in cmd):
            return {}, "missing exact command identity"
        if status not in BAD | GOOD | {"skip"}:
            return {}, "unknown test result"
        # JSON array identity avoids delimiter ambiguity; command name+argv is exact.
        key = json.dumps([name, cmd], separators=(",", ":"), ensure_ascii=True)
        if key in indexed:
            return {}, "duplicate case/command identity"
        indexed[key] = status
    if not indexed:
        return {}, "no cases captured"
    return indexed, None


def _compare_gate(base: dict | None, candidate: dict | None, sb: dict, sc: dict) -> dict:
    b, c = _chosen(base), _chosen(candidate)
    output = {
        "base_attempts": _runs(base), "candidate_attempts": _runs(candidate),
        "base_selected": list(base["selected"]) if b else None,
        "candidate_selected": list(candidate["selected"]) if c else None,
        "status": "UNVERIFIED", "reasons": [],
        "new_failures": [], "persistent_failures": [], "resolved_failures": [],
        "skipped": [], "missing_evidence": [],
    }
    if not b or not c:
        output["reasons"].append("selected attempt missing on one side")
        return output
    output["base_conclusion"] = b["conclusion"]
    output["candidate_conclusion"] = c["conclusion"]
    for label, a in (("base", b), ("candidate", c)):
        source = sb if label == "base" else sc
        if a["conclusion"] == "skipped":
            output["skipped"].append(label)
        if a["status"] != "completed":
            output["missing_evidence"].append(label + ": run not terminal")
        if a.get("source_sha") != source["sha"]:
            output["missing_evidence"].append(label + ": unverified selected source SHA")
        if not _sha(a.get("checkout_sha")) or not _sha(a.get("checkout_tree")):
            output["missing_evidence"].append(label + ": exact checkout SHA/TREE missing")
        elif a["checkout_sha"] != source["sha"]:
            output["missing_evidence"].append(label + ": checkout commit differs from selected source")
        if not _sha(source.get("tree")):
            output["missing_evidence"].append(label + ": source TREE not independently known")
        elif _sha(a.get("checkout_tree")) and a["checkout_tree"] != source["tree"]:
            output["missing_evidence"].append(label + ": checkout TREE differs from selected source")
        if not a.get("url"):
            output["missing_evidence"].append(label + ": original run URL missing")
    if output["skipped"]:
        output["reasons"].append("a skipped gate is not a successful gate")
        return output
    if output["missing_evidence"]:
        output["reasons"].append("source/checkout/run evidence incomplete")
        return output
    b_meta = [b.get(k) for k in ("workflow_sha", "environment", "sdk", "test_manifest_sha", "commands_sha")]
    c_meta = [c.get(k) for k in ("workflow_sha", "environment", "sdk", "test_manifest_sha", "commands_sha")]
    if any(not isinstance(x, str) or not x.strip() for x in b_meta+c_meta) or b_meta != c_meta or \
       any(not bool(SHA256.fullmatch(x)) for x in b_meta[1:] + c_meta[1:]) or \
       any(not bool(SHA.fullmatch(x)) for x in (b_meta[0], c_meta[0])):
        output["reasons"].append("workflow/test version/commands/environment not proved identical")
        return output
    if b.get("log_complete") is not True or c.get("log_complete") is not True:
        output["reasons"].append("log or event inventory incomplete")
        return output
    br, cr = b.get("test_authority"), c.get("test_authority")
    if br is None or cr is None:
        output["reasons"].append("no machine-readable Test Authority per-command results")
        return output
    if br.get("lane") != cr.get("lane") or br.get("blocking") != cr.get("blocking"):
        output["reasons"].append("different Test Authority lane or blocking policy")
        return output
    bi, problem_b = _result_index(br)
    ci, problem_c = _result_index(cr)
    if problem_b or problem_c or set(bi) != set(ci):
        output["reasons"].append(problem_b or problem_c or "different Test Authority command inventory")
        return output
    for key in sorted(bi):
        b_status, c_status = bi[key], ci[key]
        entry = {"command_id_sha256": hashlib.sha256(key.encode("utf-8")).hexdigest(),
                 "base": b_status, "candidate": c_status}
        if b_status in GOOD and c_status in BAD:
            output["new_failures"].append(entry)
        elif b_status in BAD and c_status in BAD:
            output["persistent_failures"].append(entry)
        elif b_status in BAD and c_status in GOOD:
            output["resolved_failures"].append(entry)
        elif b_status == "skip" or c_status == "skip":
            output["skipped"].append(entry)
    output["status"] = "COMPARABLE_COMMAND_RECEIPTS"
    output["reasons"].append("command-level status only; identical failure cause NOT independently proven")
    return output


def compare(base: dict, candidate: dict) -> dict:
    validate(base)
    validate(candidate)
    _require(base["repo"] == candidate["repo"], "repository mismatch")
    bg, cg = _gate_map(base), _gate_map(candidate)
    checks = {key: _compare_gate(bg.get(key), cg.get(key), base["source"], candidate["source"])
              for key in sorted(set(bg) | set(cg))}
    return {"schema": OUTPUT_SCHEMA,
            "baseline": base["source"], "candidate": candidate["source"],
            "comparison": checks,
            "authority": "DIAGNOSTIC_ONLY",
            "merge_permitted": False, "scorecard_write_permitted": False,
            "acceptance_inferred": False}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--out-root", required=True, type=Path)
    args = parser.parse_args()
    result = compare(json.loads(args.base.read_text()), json.loads(args.candidate.read_text()))
    args.out_root.mkdir(parents=True, exist_ok=True)
    dest = Path(tempfile.mkdtemp(prefix="ci-diff-", dir=args.out_root))
    (dest / "comparison.json").write_text(json.dumps(result, ensure_ascii=True, sort_keys=True, indent=2) + "\n")
    print("COMPARISON_PATH=" + str(dest / "comparison.json"))
    for gate, difference in result["comparison"].items():
        print("GATE=" + gate + " STATUS=" + difference["status"]
              + " NEW=" + str(len(difference["new_failures"]))
              + " PERSISTENT=" + str(len(difference["persistent_failures"]))
              + " RESOLVED=" + str(len(difference["resolved_failures"]))
              + " SKIP=" + str(len(difference["skipped"])))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
