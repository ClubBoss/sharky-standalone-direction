#!/usr/bin/env python3
"""Build the local-only Wave 2 feedback/repair/proof evidence pack."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASE_BUILDER = ROOT / "tools" / "build_real_text_visual_pack_wave1b_table_signal_refinement_v1.py"
OUTPUT_ROOT = (
    ROOT
    / "output"
    / "design_review"
    / "real_text_visual_pack_wave2_feedback_repair_proof_v1"
)
ARTIFACT = ROOT / "docs" / "_reviews" / "wave2_feedback_repair_proof_system_v1.md"
TABLET_HANDLING = "tablet_deferred_phone_first"
CONTACT_SHEET_NAMES = (
    "compact_visible_contact_sheet.png",
    "compact_full_scroll_contact_sheet.png",
)


def main() -> None:
    module = _load_base_builder()
    module.OUTPUT_ROOT = OUTPUT_ROOT
    module.main()
    _rewrite_manifest()
    _rewrite_coverage()
    _write_wave2_prompt()


def _load_base_builder():
    spec = importlib.util.spec_from_file_location("wave1b_visual_pack_builder", BASE_BUILDER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load base builder: {BASE_BUILDER}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def _rewrite_manifest() -> None:
    manifest_path = OUTPUT_ROOT / "manifest.json"
    if not manifest_path.exists():
        raise RuntimeError(f"Manifest missing after pack build: {manifest_path}")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest["schema"] = "real_text_visual_pack_wave2_feedback_repair_proof_v1"
    manifest["review_artifact"] = str(ARTIFACT.relative_to(ROOT))
    manifest["tablet_handling"] = TABLET_HANDLING
    manifest["primary_phone_screens"] = [
        "07_correct_feedback",
        "08_wrong_feedback",
        "09_repair_focus",
        "10_targeted_recheck",
        "11_session_summary",
        "12_practice_default",
        "13_review_empty",
        "14_review_active",
        "16_day2_return_home",
    ]
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def _rewrite_coverage() -> None:
    coverage_path = OUTPUT_ROOT / "coverage.md"
    if not coverage_path.exists():
        raise RuntimeError(f"Coverage missing after pack build: {coverage_path}")
    coverage = coverage_path.read_text(encoding="utf-8")
    coverage = coverage.replace(
        "# Wave 1B Table Signal Refinement Visual Pack Coverage",
        "# Wave 2 Feedback Repair Proof Visual Pack Coverage",
        1,
    )
    coverage = coverage.replace(
        "- Tablet target: clipping, overflow, CTA access, and layout smoke only",
        "- Tablet target: smoke only for clipping, overflow, CTA access, and broken layout",
        1,
    )
    coverage_path.write_text(coverage, encoding="utf-8")


def _write_wave2_prompt() -> None:
    stale_prompt = OUTPUT_ROOT / "wave1b_table_signal_refinement_rereview_prompt.md"
    if stale_prompt.exists():
        stale_prompt.unlink()

    text = """# Wave 2 Feedback Repair Proof Re-review Prompt

Review the 19-screen real-text evidence pack for Wave 2: Feedback / Repair /
Proof System Evolution. Compact phone portrait is the quality target. Tablet is
smoke evidence for clipping, overflow, inaccessible actions, and broken layout
only.

Evaluate whether feedback now reads as stateful and instructive without adding
friction; whether repair is framed as a useful current rep, not a punitive or
locked inventory state; whether proof/result language feels earned and compact;
and whether Review and Practice preserve continuity from the learner's current
clue.

Primary attention: screens 07-14 and 16. Use the individual images for detailed
judgment and the contact sheets for cross-screen consistency. Respect every
limitation recorded in `coverage.md` and `manifest.json`. Do not infer route
correctness, telemetry, Human QA, learner outcomes, public readiness, launch
readiness, or 10/10 proof from static screenshots.

Return:
1. screen-by-screen findings;
2. cross-screen feedback/repair/proof system findings;
3. compact findings first, then tablet blocker regressions only;
4. prioritized remaining issues with screenshot paths;
5. explicit accepted screens;
6. questions that require Human QA rather than visual evidence.

Wave implementation artifact:
`docs/_reviews/wave2_feedback_repair_proof_system_v1.md`
"""
    (OUTPUT_ROOT / "wave2_feedback_repair_proof_rereview_prompt.md").write_text(
        text, encoding="utf-8"
    )


if __name__ == "__main__":
    main()
