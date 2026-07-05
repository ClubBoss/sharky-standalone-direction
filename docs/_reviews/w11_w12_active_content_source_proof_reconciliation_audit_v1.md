# W11-W12 Active Content Source-Proof Reconciliation Audit v1

## 1. Verdict

`w11_w12_metadata_only_source_proof_wave_recommended`

W11 and W12 are not missing content. Both have live Act0 lesson owners, live
Act0 task IDs, admitted campaign-pack registrations, and deterministic source
packets under the active content roots. The remaining defect is narrower:
validator-visible source proof is split across Act0 runtime task IDs and
source-packet rep IDs without a normalized metadata bridge.

## 2. Scope and authority

Scoped sources inspected:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`
- `docs/_reviews/volume1_content_depth_term_drill_coverage_audit_v1.md`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `content/worlds/world11/v1/**`
- `content/worlds/world12/v1/**`
- focused W11/W12 route, proof, source, fixture, policy, transfer, and lock
  tests
- directly referenced W11/W12 campaign projection, route-proof, and admission
  policy files
- active validators that count or resolve content roots

Master Plan route authority keeps W11 as Real Play Transfer / Capstone and W12
as Mindset Bridge. The active content index treats `content/worlds/world*/v1/`
as active authored content roots, not historical archive.

## 3. Current W11 runtime ownership

Live Act0 card: `world_11`, title `Real Play Transfer`, locked and
non-selectable, bound to `_realPlayTransferLessons`
(`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6154`).

Live owner: `_realPlayTransferLessons`.

Lesson IDs:

- `session_plan_basics`
- `table_trigger_reads`
- `post_session_review_loop`
- `real_play_transfer_checkpoint`

Act0 task IDs proven: 21. They include session-plan, trigger-read,
post-session review, and checkpoint tasks from `w11_session_plan_intro` through
`w11_checkpoint_review`.

## 4. Current W12 runtime ownership

Live Act0 card: `world_12`, title `Mindset Bridge`, locked and non-selectable,
bound to `_mindsetBridgeLessons`
(`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6168`).

Live owner: `_mindsetBridgeLessons`.

Lesson IDs:

- `decision_over_outcome`
- `tilt_reset_protocol`
- `confidence_and_discipline`
- `mindset_bridge_checkpoint`

Act0 task IDs proven: 20. They include decision-quality, tilt-reset,
confidence-discipline, and checkpoint tasks from
`w12_decision_quality_intro` through `w12_checkpoint_review`.

## 5. Stable-ID inventory

| World | Live owner | File root role | Stable IDs proven | Validator-visible | Gap |
| --- | --- | --- | --- | --- | --- |
| W11 | `_realPlayTransferLessons` | Active authored source root with one deterministic source packet and one campaign fixture. | 4 Act0 lesson IDs, 21 Act0 task IDs, 6 packet rep IDs, 4 admitted `world11_` campaign pack IDs. | Partly. Focused W11 guards prove packet reps and route proof; normal drill-json validators do not count W11. | No normalized bridge from Act0 task IDs to source-packet rep IDs / content-root proof metadata. |
| W12 | `_mindsetBridgeLessons` | Active authored source root with one deterministic source packet and one campaign fixture. | 4 Act0 lesson IDs, 20 Act0 task IDs, 6 packet rep IDs, 4 admitted `world12_` campaign pack IDs. | Partly. Focused W12 guards prove packet reps and route proof; normal drill-json validators do not count W12. | No normalized bridge from Act0 task IDs to source-packet rep IDs / content-root proof metadata. |

File-root packet IDs:

- W11: `w11.s01.r01` through `w11.s01.r06`
- W12: `w12.s01.r01` through `w12.s01.r06`

Act0 runtime task IDs and packet rep IDs are both stable, but they are not the
same ID family. Treating one family as a silent substitute for the other is the
source-proof risk.

## 6. Theory / practice / transfer / review matrix

| World | Theory tasks | Practice / drill tasks | Transfer tasks | Review / prove-it tasks | Source packet reps |
| --- | ---: | ---: | ---: | ---: | ---: |
| W11 | 4 | 12 | 5 | 4 | 6 |
| W12 | 4 | 12 | 7 | 4 | 6 |

This is sufficient to reject a "content missing" diagnosis. The source-proof
issue is traceability and validator visibility, not absence of learner work.

## 7. Repair coverage

W11 repair coverage exists as process repair, not as a dedicated
`fixMistakes` task family: `post_session_review_loop`,
`w11_review_define_fix`, review-line checkpoint work, source packet
`repair_cue` fields, and six campaign fixture `repair_cue` entries.

W12 repair coverage exists as decision-process repair: tilt reset, after-own-
mistake reset, process review, discipline under pressure, checkpoint loop work,
source packet `repair_cue` fields, and six campaign fixture `repair_cue`
entries.

The audit should not demand new learner prompts or duplicate drill content.
The missing piece is metadata that proves how existing runtime tasks and
source-packet reps satisfy repair, transfer, review, and route-proof claims.

## 8. File-root role assessment

W11 and W12 roots are active authored source roots. They are not empty shells
in the current repo state:

- each root contains `index.md`, `world.md`, `sessions/index.md`, `session.md`,
  `notes.md`, one deterministic source packet, and one campaign fixture JSON
- neither root contains `sessions/**/drills/*.json`
- each packet declares that it is authored content and creates no route by
  itself

Current role: source-owned packet and fixture proof that coexists with active
route admission. It is not the same shape as the W0-W9 drill-json content
tree.

## 9. Validator behavior

Focused W11/W12 guards prove:

- W11 and W12 active source drafts exist
- each deterministic packet has six complete reps
- each campaign fixture preserves packet fields
- projection adapters preserve source fields without creating runtime route
  registration
- route-backed proof descriptors are learner-visible and retain handoff flags
- W13 campaign packs remain absent

General validator behavior remains mismatched:

- `tools/validate_world_content_v1.dart` scans `_kWorldIds = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]`
  and expects normal `sessions/**/drills/index.md` plus
  `sessions/**/drills/d.<id>.json` structure.
- W11/W12 contain zero `sessions/**/drills/*.json` files.
- `content_schema_foundation_validator_v1.dart` can validate normalized task
  fixtures with `migration_source`, `route_gate_status`, and
  `source_truth_status`, but W11/W12 do not yet have a normalized task metadata
  fixture that bridges Act0 task IDs to packet reps.

Result: focused route/source tests see W11/W12; broad drill-root validators can
ignore or undercount them.

## 10. Source-of-truth risk

Highest risk option: creating new W11/W12 drill JSON by copying packet prompts,
answers, feedback, board context, or learner copy. That would create a second
learner-content source and invite drift.

Lower risk option: add metadata-only source proof that references existing
owners, lesson IDs, Act0 task IDs, packet rep IDs, packet paths, campaign
fixture paths, route-proof IDs, and coverage tags. This preserves the existing
runtime and authored packet sources while making the proof validator-readable.

## 11. Options considered

1. No action. Rejected because broad validators and future audits can still
   undercount W11/W12.
2. Runtime source-contract repair. Rejected for this finding because live
   runtime owners and route proof already exist.
3. Duplicate W11/W12 prompts into drill JSON. Rejected because it creates a
   second source of truth.
4. Validator-only change. Rejected as insufficient unless W11/W12 first expose
   normalized metadata that validators can consume.
5. Metadata-only source-proof bridge. Recommended.

## 12. Recommended bounded repair wave

Run a W11/W12 metadata-only source-proof wave.

The wave should add validator-readable metadata that maps, for each world:

- canonical world ID and displayed world title
- live Act0 owner symbol
- live Act0 lesson IDs
- live Act0 task IDs
- deterministic packet path and packet rep IDs
- campaign fixture path
- route-proof ID
- coverage tags for theory, practice, transfer, review, and repair cue
- explicit statement that packet/fixture content is referenced, not copied

If a validator update is needed, keep it narrow: teach the relevant validator
or guard to accept this metadata bridge as source proof for W11/W12 without
requiring duplicate `drills/*.json` files.

## 13. Files likely involved

Likely metadata additions or edits:

- `content/worlds/world11/v1/`
- `content/worlds/world12/v1/`

Likely narrow validation additions if admitted:

- a W11/W12 metadata reachability guard
- a source-proof validator fixture or targeted validator update

No runtime, test-meta, Master Plan, W13+, content expansion, mascot, Modern
Table, screenshot, telemetry, monetization, localization, or route-lock file is
part of this audit.

## 14. Tests required

Required for the future repair wave:

- W11 metadata lists exactly the current live Act0 lesson IDs and task IDs.
- W12 metadata lists exactly the current live Act0 lesson IDs and task IDs.
- W11 metadata lists exactly `w11.s01.r01` through `w11.s01.r06`.
- W12 metadata lists exactly `w12.s01.r01` through `w12.s01.r06`.
- Metadata references existing packet and fixture paths without copying learner
  prompts, answers, feedback, or board/state copy.
- Validator-visible counts include W11/W12 source proof through metadata.
- Existing route/proof/policy guards remain green.
- W13+ remains absent, locked, and non-selectable.

## 15. Explicit non-goals

- No runtime code change in this audit.
- No W11/W12 content authoring in this audit.
- No new learner prompts, answers, feedback, board contexts, or stable IDs.
- No duplicate drill JSON generated from packet copy.
- No Act0 lock, route, or W13+ change.
- No W4-W7, mascot, Modern Table, screenshot, telemetry, monetization, or
  localization work.
- No Master Plan edit.
- No meta-test creation.
- No push.

## 16. Validation

Audit validation performed by scoped read-only inspection:

- W11 live owner and task inventory inspected in
  `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- W12 live owner and task inventory inspected in
  `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- W11/W12 active roots inspected under `content/worlds/world11/v1/**` and
  `content/worlds/world12/v1/**`.
- Focused W11/W12 source, fixture, projection, route-proof, admission, transfer,
  and W13-lock tests inspected.
- Active validators inspected for normal drill-json counting and normalized
  task-fixture behavior.

Command validation is recorded in the final response for this audit commit.

## 17. Final route recommendation

Do not implement a runtime source-contract repair and do not duplicate W11/W12
learner content. The next owner action should be a bounded metadata-only
source-proof bridge for W11/W12, with a narrow validator/guard update only if
needed to make the bridge countable. Preserve current Act0 owners, current
source packets, current route-proof descriptors, current lock state, and W13+
closure.
