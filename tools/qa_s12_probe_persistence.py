#!/usr/bin/env python3
"""Read-only S11 iOS preferences-domain discovery; synthetic hosted device only.

Avoid assuming that UserDefaults has flushed to one specific bundle plist.
A passing gate still requires the *actual* saved source-owned decision record.
No record is created or modified by this script.
"""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--container", required=True)
parser.add_argument("--output", required=True)
parser.add_argument("--extracted-plist", required=True)
args = parser.parse_args()
container = Path(args.container)
key = "flutter.act0_shell_progress_v1"
candidates = []
for path in sorted((container / "Library" / "Preferences").glob("*.plist")):
    try:
        content = path.read_bytes()
        plist = plistlib.loads(content)
        matches = [k for k in plist if k == key or k == "act0_shell_progress_v1"]
        candidates.append({
            "name": path.name,
            "bytes": len(content),
            "sha256": hashlib.sha256(content).hexdigest(),
            "contains_target": bool(matches),
            "relevant_pref_keys": matches,
        })
        if matches:
            progress = plist[matches[0]]
            if not isinstance(progress, str):
                raise RuntimeError("ACTUAL_PERSISTED_PROGRESS_NOT_STRING")
            decoded = json.loads(progress)
            if not isinstance(decoded, dict):
                raise RuntimeError("ACTUAL_PERSISTED_PROGRESS_NOT_OBJECT")
            # Keep the actual unmodified source plist for independent verifier.
            if Path(args.extracted_plist).exists():
                raise RuntimeError("MULTIPLE_PERSISTED_PROGRESS_DOMAINS")
            Path(args.extracted_plist).write_bytes(content)
            candidates[-1]["evidence_record_count"] = len(
                decoded.get("learningEvidenceHistory", {}).get("records", [])
                if isinstance(decoded.get("learningEvidenceHistory"), dict)
                else decoded.get("learningEvidenceHistory", [])
            )
            candidates[-1]["earned_xp"] = decoded.get("earnedXp")
    except (ValueError, plistlib.InvalidFileException, OSError, TypeError) as exc:
        candidates.append({"name": path.name, "error_type": type(exc).__name__})
Path(args.output).write_text(json.dumps({
    "evidence_class": "READ_ONLY_NATIVE_APP_USERDEFAULTS_DISCOVERY",
    "searched": str(container / "Library" / "Preferences"),
    "candidates": candidates,
    "found_target": Path(args.extracted_plist).exists()
}, indent=2))
print("S11_ACTUAL_USERDEFAULTS_FOUND", Path(args.extracted_plist).exists(),
      "domains_scanned", len(candidates))
