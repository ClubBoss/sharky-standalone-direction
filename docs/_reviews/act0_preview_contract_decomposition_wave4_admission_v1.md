---
status: "act0_preview_decomposed_wave4_admission_lane_restored"
status_source: "derived"
baseline: "5d3f77880cc8"
generated_by: "docs_frontmatter_v1"
---

# Act0 Preview Contract Decomposition + Wave 4 Admission v1

Status: `act0_preview_decomposed_wave4_admission_lane_restored`

Branch: `codex/act0-preview-decomposition-world-identity-lock-v1`

Base HEAD: `5d3f77880cc8d55c8252bf2882fd9fd16242b17c`

## Initial Evidence

Reused JSON Tier0 failure log:

`/.dart_tool/codex_tier0_root_cause_wave4/tier0_7files_after.jsonl`

Initial selected Tier0 result:

`602 success / 128 error`

All 128 errors were concentrated in:

`test/ui_v2/act0_shell_preview_screen_v1_test.dart`

Compact extraction:

`/.dart_tool/codex_act0_preview_decomposition/act0_preview_errors.tsv`

Grouped matrix:

`/.dart_tool/codex_act0_preview_decomposition/act0_preview_error_families.tsv`

## Grouped Failure Matrix

| Contract family | Failure count | Test-name pattern | Owner | Active/legacy/uncertain |
| --- | ---: | --- | --- | --- |
| Review shell / repair loop | 33 | Debug capture first-wrong feedback; review entry active repair; wrong first-value receipt | Act0 review shell + repair resolver/consumer | active but not Wave 4 admission |
| RU localization | 25 | Learn/runner/shell Russian localization expectations | Act0 RU copy bundle + RU residue guard | active but outside Wave 4 admission unless focused guard red |
| Learn shell / runner lesson flow | 16 | selected lesson panel; hidden options; locked levels | Act0 learn path shell + lesson runner | active but split owner coverage required |
| World identity / curriculum mapping | 16 | W5/W7/source lookup and stale preflop/postflop examples | canonical truth map + Act0 state/source owners | active |
| Home shell / retention-progress | 13 | daily checklist; weekly focus; prove/keep-sharp/recheck jobs | Act0 home shell + repair/retention projections | active but not Wave 4 admission |
| Legacy-only runner expectations | 8 | family-aware prompt copy; locked detail; theory recall affordance | legacy preview backlog artifact | legacy/non-authoritative until decomposed |
| Feedback/debug flows | 6 | debug capture; first-value receipt; table signal labels | Act0 feedback shell + debug capture harness | mixed debug/active; debug capture retired from admission |
| Widget structure/layout | 6 | Pro Max compactness; dock geometry; compact headroom | Act0 widget layout owners | active visual/layout, not Wave 4 admission |
| Shell chrome / placement / profile | 5 | placement signal; profile dedupe; play launch | Act0 shell tabs + placement/profile/play owners | active shell, not Wave 4 admission |

Total: 128.

## Decomposition

The old preview test file was 33,273 lines and mixed unrelated contracts:

- debug capture harness expectations;
- RU localization;
- Home retention/progress;
- Learn path;
- Review/repair loop;
- layout geometry;
- placement/profile/play shell;
- source-owned curriculum lookup expectations.

It has been moved to:

`test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart`

That file is no longer a `_test.dart` file and is marked as provenance-only.
It must not be returned to the admission lane unless a specific contract family
is decomposed into an owner-aligned focused test.

The canonical preview test path now contains the narrow active core:

`test/ui_v2/act0_shell_preview_screen_v1_test.dart`

Current core coverage:

- canonical path root remains `Act0ShellPreviewScreenV1`;
- Act0 sample state exposes canonical W1-W12 runtime identity;
- preview shell renders Home and opens Learn through the bottom nav.

Existing focused tests remain the authority for their own families:

- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_en_alpha_residue_guard_test.dart`
- `test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart`
- `test/guards/campaign_pack_registry_invariants_test.dart`
- `test/guards/campaign_followup_pack_registry_invariants_test.dart`
- `test/ui_v2/act0_shell_state_v1_feedback_test.dart`
- `test/guards/canonical_truth_map_v1_contract_test.dart`

## Repaired / Retired

Repaired:

- canonical W1-W12 runtime identity is explicit and guarded;
- W4-W6 retired active-plan labels were removed from active launch/calibration docs;
- W12 terminal pack ownership is explicit;
- selected Tier0 no longer depends on the legacy 33k-line mixed preview backlog.

Retired from Wave 4 admission:

- debug capture exact-copy expectations;
- broad pixel-density/layout expectations;
- broad repair/review loop assertions;
- broad RU localization expectations already covered by focused RU guards;
- stale source lookups embedded in the mixed preview file.

This does not mark all legacy assertions false. It marks the mixed file
non-authoritative for Wave 4 admission until each valid contract is split into
its direct owner lane.

## Current Admission Verdict

`canonical_world_identity_locked_act0_preview_green_wave4_admitted`

Meaning:

- Wave 4 has not started.
- The admission lane is trustworthy again.
- Any future repair/review/localization/layout work should enter through a
  focused owner-specific test, not by restoring the mixed preview backlog.
