---
status: "w5_w6_authored_session_contract_reconciliation_complete"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# W5-W6 Authored-Session Runtime and Validator Contract Reconciliation v1

## Verdict

`w5_w6_authored_session_contract_reconciliation_complete`

The W5/W6 authored-session source, manifest, runtime parser, stable-ID, and
broad-validator contracts now agree. Canonical Act0 ownership and route state
were not changed.

## Original Scanner Breakdown

Baseline command:

```text
dart run tools/validate_world_content_v1.dart
```

Baseline result: exit `1`, W5 `22`, W6 `31`, total `53`.

| Root cause | World | Error count | Affected files | Runtime impact | Validator impact | Intended fix layer |
| --- | --- | ---: | --- | --- | --- | --- |
| Explanation-length contract mismatch | W5 | 11 | 11 board-texture drills in `w5.s01`, `s03`, `s04`, `s05`, `s10` | Runtime dropped over-140-character `why_v1` values | Correctly rejected the same values | Exact failing `why_v1` fields |
| Missing/incomplete session admission metadata | W5 | 8 | `w5.s11/session.md` plus three outs drills | `w5.s11` was not manifest-admitted and drills lacked intent metadata | Four missing headings, one unknown role, three missing intents | W5 session source, role rule, manifests |
| Unsupported runtime kind / incomplete runtime shape | W5/W6 | 15 | Three W5 outs classifiers and 12 W6 normalized classifiers | Parser rejected all three accepted authored kinds | Reported missing `expected` objects | Parser aliases plus source-owned deterministic action shape |
| Manifest/source identity mismatch | W6 | 12 | Six `w6.s01` and six `w6.s02` normalized classifiers | Adapter item IDs differed from semantic source IDs | Filename-derived ID rule rejected semantic IDs | Indices, manifests, source-ID resolution |
| Stale validator expectation | W6 | 7 | Six `position_and_range_width` drills and 14-drill `w6.s01` | No independent runtime defect | Intent allowlist and 12-drill ceiling predated accepted source | Intent SSOT and source-backed pacing rule |
| Stale focused test expectation | W6 | 0 | Existing range-bucket focused tests | Tests expected superseded action-authored semantics | Not a scanner line | Focused tests |
| Duplicate/missing stable ID | W5/W6 | 0 | None in the accepted source | None | Negative controls remain active | No repair required |
| Other | W5/W6 | 0 | None | None | None | None |

Accounting: `11 + 8 + 15 + 12 + 7 = 53`.

## W5 Before/After Contract

Before:

- 11 learner-facing explanations exceeded the shared 140-character runtime
  contract and became null at parse time.
- `w5.s11` existed in active source indices but not both runtime manifests.
- Its session lacked the four required headings.
- Its three `outs_count_classifier_v1` files lacked `intent_v1`,
  `error_class`, deterministic runtime actions, and `expected.actionId`.

After:

- All 11 explanations fit the existing 8..140 ASCII contract while preserving
  the source cue, selected response, and anti-automatic-action warning.
- `w5.s11` is admitted in both session and drill manifests.
- The session has Objective, Scenario, Decision, and Explanation sections.
- Each outs classifier owns `basic_outs_awareness`, an existing 4/8/9 action
  set, numeric `expected.actionId`, and `basic_outs_awareness_gap`.
- `outs_count_classifier_v1` maps narrowly to the existing deterministic
  `DrillKindV1.outsCountChoice` interaction.

No explanation was too short, non-learner metadata, or assigned to the wrong
field. All 11 were learner-facing explanations that were genuinely too long
for the existing runtime contract.

## W5 `w5.s11` Admission Result

`w5.s11` remains W5-owned Basic Outs Awareness. It is now present in:

- `content/worlds/world5/v1/index.md`;
- `content/worlds/world5/v1/sessions/index.md`;
- `content/_meta/world_sessions_manifest_v1.json`;
- `content/_meta/world_drills_manifest_v1.json`.

The runtime adapter loads all three drills, and each adapter `drillId` equals
the parsed source ID. Canonical Act0 world ownership was not used as an
admission mechanism and remains unchanged.

## W6 Before/After Contract

Before:

- `range_bucket_board_fit_classifier_v1` and
  `range_width_classifier_v1` were accepted source kinds but parser-unknown.
- Semantic JSON IDs differed from legacy filename-derived index and manifest
  IDs.
- The broad validator required an unrelated generic `expected` shape, rejected
  the accepted width intent, and capped `w6.s01` below its accepted 14 reps.
- Focused tests still expected action-authored fold/call/raise range drills.

After:

- Both accepted source kinds map narrowly to existing deterministic
  `DrillKindV1.actionChoice` evaluation.
- Each source file owns an exact accepted action vocabulary and matching
  `expected.actionId`; existing `expected_action`, bucket/width value, and
  semantic feedback remain intact.
- Unknown kinds still throw `FormatException`.
- Focused tests assert bucket/width classification rather than superseded
  action selection.

No broad enum, parser, runner, or schema family was added.

## Stable-ID Reconciliation

The semantic JSON IDs are the stable IDs. Legacy filenames remain stable source
metadata, as required by the accepted W6 source reviews.

- W6 drill indices now list semantic IDs.
- W6 manifest entries use those semantic IDs while retaining legacy file paths.
- The manifest exporter and broad validator first preserve an existing
  same-name source path, then resolve by authored JSON ID only when no derived
  path exists.
- Missing indexed IDs and duplicate authored IDs remain deterministic errors.
- The runtime adapter resolves semantic IDs through the manifest fallback and
  returns `drillId == spec.id` for all 12 normalized W6 drills.

## Validator Changes

- Added exact validation for `outs_count_classifier_v1`,
  `range_bucket_board_fit_classifier_v1`, and `range_width_classifier_v1`.
- Added accepted W5 `basic_outs_awareness` and W6
  `position_and_range_width` intents.
- Added the accepted W5 `s11` practice role and W6 `s01` 14-rep ceiling.
- Added source-ID resolution for indexed semantic IDs with deterministic
  duplicate/missing-source failures.
- Kept all global explanation thresholds and unrelated-world rules unchanged.
- Added no exclusion, ignore rule, world-wide bypass, or automatic success.

## Runtime Changes

`DrillSpecV1` recognizes exactly three additional authored kind strings:

- `outs_count_classifier_v1` -> `outsCountChoice`;
- `range_bucket_board_fit_classifier_v1` -> `actionChoice`;
- `range_width_classifier_v1` -> `actionChoice`.

The existing evaluator, available-action parsing, expected-action parsing, and
manifest fallback provide deterministic behavior. No canonical Act0 code or
archived runner code changed.

## Canonical Act0 Byte Identity

`lib/ui_v2/act0_shell/act0_shell_state_v1.dart` SHA-256 before and after:

```text
38be8da73534cc142d6147cfbb771f816bdfaaa6511e30d770c1f170451428ae
```

The W4-W7 owner decomposition test, W4-W6 title guard, W7-W12 lock guard, and
W13 closure assertion all pass.

## Negative Controls

- Unknown `unknown_classifier_v1` still throws `FormatException`.
- A missing manifest drill ID resolves to null instead of an adjacent source.
- Indexed IDs with no authored JSON source remain validator/export errors.
- Duplicate authored IDs remain validator/export errors.
- Existing `why_v1` placeholder, feedback-label, answer-leak, and action-cue
  fences pass unchanged.

## Learner-Facing Content Changes

Only the 11 failing W5 `why_v1` fields changed. Each was shortened without
changing its board cue or response and retains an explicit warning that texture
does not automatically determine the action. `w5.s11` received structural
headings and runtime metadata, not new teaching scope. W6 learner-facing copy
did not change.

## Files Changed

- Active content/manifests: 31 files, limited to the two metadata manifests,
  the exact W5 failures, and W6 `s01`/`s02` normalized source/indices.
- Runtime: `lib/services/drill_contract_v1.dart`.
- Tools: broad validator, intent SSOT, and drill-manifest exporter.
- Tests: one new focused contract test and three corrected W6 focused tests.
- Documentation: this review artifact.

No Act0 shell, route, W11/W12, W13+, visual, mascot, Modern Table, screenshot,
telemetry, monetization, localization, archive, or dependency file changed.

## Explicit Non-Goals

- No canonical Act0 ownership or title change.
- No W4-W7 decomposition change.
- No new curriculum family or broad content expansion.
- No global explanation threshold reduction.
- No legacy filename rename.
- No archive runner repair.
- No generated fixture output committed.
- No push.

## Validation

Passing evidence:

- broad scanner: exit `0`, W5 errors `0`, W6 errors `0`;
- targeted red-to-green reconciliation set: 8 tests passed;
- focused W5/W6 source, factory, evaluator, and contract set: relevant tests
  passed;
- representative unaffected validators plus Act0/lock guards: 26 tests passed;
- `flutter analyze`: no issues;
- canonical Act0 SHA-256: byte-identical;
- final `git diff --check` and `graphify hook-check`: recorded at commit
  closeout.

Exploratory broader batches also reproduced unrelated pre-existing failures in
old W4 copy expectations, legacy manifest readiness, stale archived-screen
imports, old W5 exact-count assumptions, campaign UI copy/actionability, and a
historical Phase 7 capsule assertion. None of those files was changed or used
to weaken this wave's acceptance checks.
