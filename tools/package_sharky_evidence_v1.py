#!/usr/bin/env python3
"""Package existing Phone Lab browser proof as SHARKY_EVIDENCE_V1."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

SCHEMA = "SHARKY_EVIDENCE_V1"
VALIDATION_SCHEMA = "SHARKY_EVIDENCE_VALIDATION_V1"
SOURCE_SCHEMA = "sharky_phone_lab_browser_proof_v1"
SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--proof-dir", required=True)
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--candidate-sha", required=True)
    parser.add_argument("--base-sha", required=True)
    parser.add_argument("--pr-number", default="")
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--tooling-sha", required=True)
    parser.add_argument("--evidence-kind", default="phone_lab_browser")
    return parser.parse_args()


def require_sha(name: str, value: str) -> str:
    value = value.strip().lower()
    if not SHA_RE.fullmatch(value):
        raise ValueError(
            f"{name} must be a full 40-character lowercase commit SHA: {value!r}"
        )
    return value


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_dump(path: Path, payload: object) -> None:
    path.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def file_entry(root: Path, path: Path, kind: str) -> dict[str, object]:
    return {
        "kind": kind,
        "path": path.relative_to(root).as_posix(),
        "sha256": sha256_file(path),
        "size_bytes": path.stat().st_size,
    }


def source_hashes_match(proof_dir: Path, proof: dict[str, object]) -> bool:
    expected: list[tuple[str, str]] = []
    profiles = proof.get("profiles") or {}
    for profile in profiles.values():
        if profile.get("screenshot") and profile.get("screenshot_sha256"):
            expected.append((profile["screenshot"], profile["screenshot_sha256"]))

    overflow = proof.get("console_overflow_signals") or {}
    for signal in overflow.values():
        if signal.get("screenshot") and signal.get("screenshot_sha256"):
            expected.append((signal["screenshot"], signal["screenshot_sha256"]))

    interaction = proof.get("interaction_details") or {}
    for name, key in (
        ("compact-live-before.png", "before_sha256"),
        ("compact-live-after.png", "after_sha256"),
        ("compact-live-stable.png", "stable_sha256"),
    ):
        if interaction.get(key):
            expected.append((name, interaction[key]))

    if not expected:
        return False
    for name, digest in expected:
        path = proof_dir / name
        if not path.is_file() or sha256_file(path) != digest:
            return False
    return True


def main() -> int:
    args = parse_args()
    proof_dir = Path(args.proof_dir)
    out_dir = Path(args.out_dir)
    candidate_sha = require_sha("candidate_sha", args.candidate_sha)
    base_sha = require_sha("base_sha", args.base_sha)
    tooling_sha = require_sha("tooling_sha", args.tooling_sha)
    run_id = int(args.run_id)
    pr_number = int(args.pr_number) if str(args.pr_number).strip() else None

    proof_json_path = proof_dir / "browser-proof.json"
    proof_md_path = proof_dir / "browser-proof.md"
    if not proof_json_path.is_file():
        raise FileNotFoundError(f"Missing Phone Lab browser proof: {proof_json_path}")

    proof = json.loads(proof_json_path.read_text(encoding="utf-8"))
    root = out_dir / f"sharky-evidence-{candidate_sha}"
    if root.exists():
        shutil.rmtree(root)
    screenshots_dir = root / "screenshots"
    checks_dir = root / "checks"
    screenshots_dir.mkdir(parents=True)
    checks_dir.mkdir(parents=True)

    copied_screenshots: list[Path] = []
    for source in sorted(proof_dir.glob("*.png")):
        destination = screenshots_dir / source.name
        shutil.copy2(source, destination)
        copied_screenshots.append(destination)
    if not copied_screenshots:
        raise FileNotFoundError(f"No PNG evidence found in {proof_dir}")

    copied_proof_json = checks_dir / "browser-proof.json"
    shutil.copy2(proof_json_path, copied_proof_json)
    copied_proof_md = None
    if proof_md_path.is_file():
        copied_proof_md = checks_dir / "browser-proof.md"
        shutil.copy2(proof_md_path, copied_proof_md)

    profiles = proof.get("profiles") or {}
    compact = profiles.get("compact") or {}
    tall = profiles.get("tall") or {}
    checks = {
        "source_schema": proof.get("schema") == SOURCE_SCHEMA,
        "candidate_sha_matches_proof": proof.get("target_sha") == candidate_sha,
        "source_hashes_match": source_hashes_match(proof_dir, proof),
        "exact_sha_identity": proof.get("exact_sha_identity") == "PASS",
        "compact_375x812": compact.get("measured_inner") == [375, 812]
        and compact.get("product_sha") == candidate_sha,
        "tall_402x874": tall.get("measured_inner") == [402, 874]
        and tall.get("product_sha") == candidate_sha,
        "fit_mode": proof.get("fit_mode") == "PASS",
        "interaction": proof.get("interaction") == "PASS",
        "web_native_truth_boundary": True,
    }
    status = "PASS" if all(checks.values()) else "FAIL"
    validation = {
        "schema": VALIDATION_SCHEMA,
        "status": status,
        "checks": checks,
    }
    validation_path = checks_dir / "validation_summary.json"
    json_dump(validation_path, validation)

    artifact_name = f"sharky-evidence-{candidate_sha}"
    workflow_run_url = f"https://github.com/{args.repository}/actions/runs/{run_id}"
    report_path = root / "report.md"
    report_lines = [
        "# SHARKY_EVIDENCE_V1 report",
        "",
        f"- Repository: `{args.repository}`",
        f"- Candidate SHA: `{candidate_sha}`",
        f"- Base SHA: `{base_sha}`",
        f"- PR number: `{pr_number if pr_number is not None else 'N/A'}`",
        f"- Workflow run ID: `{run_id}`",
        f"- Artifact name: `{artifact_name}`",
        f"- Evidence kind: `{args.evidence_kind}`",
        "- Capture authority: `web_qa`",
        "- Native acceptance claimed: `false`",
        f"- Validation: `{status}`",
        f"- Workflow run: {workflow_run_url}",
    ]
    if proof.get("base_url"):
        report_lines.append(f"- Exact-SHA QA mirror: {proof['base_url']}")
    report_lines.extend(
        [
            "",
            "This package transports browser QA evidence only. It does not claim native iOS Simulator/device acceptance.",
            "",
        ]
    )
    report_path.write_text("\n".join(report_lines), encoding="utf-8")

    payload_files: list[dict[str, object]] = []
    for path in copied_screenshots:
        payload_files.append(file_entry(root, path, "screenshot"))
    payload_files.append(file_entry(root, copied_proof_json, "source_check"))
    if copied_proof_md is not None:
        payload_files.append(file_entry(root, copied_proof_md, "source_check"))
    payload_files.append(file_entry(root, validation_path, "validation"))
    payload_files.append(file_entry(root, report_path, "report"))
    payload_files.sort(key=lambda item: str(item["path"]))

    capture_profiles = []
    for name, expected in (("compact", [375, 812]), ("tall", [402, 874])):
        profile = profiles.get(name) or {}
        capture_profiles.append(
            {
                "name": name,
                "width": expected[0],
                "height": expected[1],
                "measured_inner": profile.get("measured_inner"),
                "product_sha": profile.get("product_sha"),
                "screenshot": (
                    f"screenshots/{profile['screenshot']}"
                    if profile.get("screenshot")
                    else None
                ),
            }
        )

    manifest = {
        "schema": SCHEMA,
        "repository": args.repository,
        "candidate_sha": candidate_sha,
        "base_sha": base_sha,
        "pr_number": pr_number,
        "workflow": {
            "run_id": run_id,
            "run_url": workflow_run_url,
            "tooling_sha": tooling_sha,
        },
        "artifact_name": artifact_name,
        "evidence_kind": args.evidence_kind,
        "capture_profiles": capture_profiles,
        "capture_authority": "web_qa",
        "native_acceptance_claimed": False,
        "preview_url": proof.get("base_url"),
        "files": payload_files,
        "validation": {
            "status": status,
            "summary_path": "checks/validation_summary.json",
        },
    }
    manifest_path = root / "manifest.json"
    json_dump(manifest_path, manifest)

    parsed_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if parsed_manifest.get("schema") != SCHEMA:
        raise RuntimeError("Generated manifest failed schema self-check")

    print(f"SHARKY_EVIDENCE_V1_ROOT={root}")
    print(f"SHARKY_EVIDENCE_V1_STATUS={status}")
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"SHARKY_EVIDENCE_V1_ERROR={exc}", file=sys.stderr)
        raise
