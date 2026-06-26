# Wave 3.15 - W2-W4 Launch Quality Packet v1

## 1. Verdict

wave3_15_w2_w4_launch_quality_packet_ready

## 2. Target 10/10 block

W2-W4 Launch Quality / Foundation Depth.

## 3. Current gap

W1 was strongest; W2-W4 quality needed proof to avoid a quality cliff before public packaging.

## 4. W2/W3/W4 quality packet

### W2 / World 2: Hand Discipline

- Visible status: locked immediate-next world in the base Act0 sample; route label and selected-world panel are present.
- Current learner-facing job: teach that not every hand deserves chips through buckets, weak-hand awareness, dominated-hand discipline, fold discipline, and simple continue/fold choices.
- Evidence path:
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Quality verdict: launch-quality evidence passes. W2 has a real hand-discipline spine, enough decision reps before W3, non-punitive suboptimal literacy, no-chart framing, a position bridge, and a real-table discipline transfer rep.
- Blockers found: no W2 P0/P1 content-quality blocker found.
- Fixes made: none.
- Remaining accepted gaps: dedicated W2 screenshot capture is not currently exposed by `screen_review_fast_v1.sh`; this is not a product-content blocker, but a future capture-tooling improvement before public reviewer packets would reduce manual review friction.

### W3 / World 3: Position Thinking

- Visible status: locked later-world preview in the base Act0 sample; route title exists and is covered by route-order tests.
- Current learner-facing job: teach seat order, early/late comfort, BTN advantage, same-hand-different-seat reasoning, and the bridge into frame-first preflop.
- Evidence path:
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Quality verdict: launch-quality evidence passes. W3 has a real position-thinking spine, enough decision reps before W4, a real-table transfer read, suboptimal literacy, and a clear bridge into W4.
- Blockers found: no W3 P0/P1 content-quality blocker found.
- Fixes made: none.
- Remaining accepted gaps: dedicated W3 screenshot capture is not currently exposed by the fast screenshot lane.

### W4 / World 4: Preflop Framework

- Visible status: locked later-world preview in the base Act0 sample; route title exists and is covered by route-order tests.
- Current learner-facing job: teach first-in open, facing open, open/call/fold logic, frame before action, and a simple preflop checkpoint without charts.
- Evidence path:
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Quality verdict: launch-quality evidence passes. W4 has a real preflop-framework spine, enough decision reps before W5, a real-table frame transfer rep, suboptimal literacy, checkpoint bridge copy, and a stable purpose-price transfer ID inside the checkpoint owner.
- Blockers found: no W4 P0/P1 content-quality blocker found.
- Fixes made: none.
- Remaining accepted gaps: dedicated W4 screenshot capture is not currently exposed by the fast screenshot lane.

## 5. Mistake Family Taxonomy

W1-W4 only:

| Family ID | Learner-safe name | Current source / mapping note |
| --- | --- | --- |
| `table_basics` | Table basics | W1 table, seat, pot, blind, action-order, card, street, and showdown literacy. Maps through stable `worldId`, `lessonId`, `taskId`, and `Act0TaskFamilyV1` where available. |
| `action_read` | Action read | W1 no-bet/facing-action repair focus; currently appears through `missedSignalId`, `skillAtomId`, `repairFocusKey`, and active repair queue IDs. |
| `hand_discipline` | Hand discipline | W2 bucket, weak hand, dominated-hand, fold discipline, and continue/fold content. Current mapping is source-owned by W2 lesson/task IDs and task family. |
| `position_awareness` | Position awareness | W3 seat-order, early/late, BTN, players-behind, and same-hand-different-seat content. Current mapping is source-owned by W3 lesson/task IDs and task family. |
| `preflop_framework` | Preflop framework | W4 first-in, facing-open, open/call/fold, and frame-before-action content. Current mapping is source-owned by W4 lesson/task IDs and task family. |
| `repair_followthrough` | Repair followthrough | Cross-W1-W4 repair loop family for active repair intent, Practice queue launch target, repair outcome, and local proof close. Current mapping uses `sourceTaskId`, `repairTaskId`, `targetTaskId`, `repairFocusKey`, and outcome state. |

No W5-W36 taxonomy was introduced.

## 6. Canonical Telemetry Event Names

Canonical Wave 3.15 names:

| Canonical event | Current mapping / gap |
| --- | --- |
| `session_start` | Present in `TelemetryEvents.sessionStart` and older services. Act0 local truth map currently uses more granular local names such as `lesson_started` and `task_shown`; no code alignment was attempted. |
| `decision_made` | Conceptually maps to Act0 `user_choice` / selected answer handling. Current code has local choice/result seams, not this exact public canonical name. |
| `repair_attempted` | Current repair outcome state uses `repair_attempted_v1`; canonical public event name is documented here without changing code. |
| `fix_landed` | Current last-session proof result uses `fix_landed`; canonical event name documented here. |
| `session_complete` | Older app-wide code uses session completion names; Act0 route currently has local completion state and world-completion seams. |
| `day2_return` | Current Day 2 screenshot/capture lane and return-state owner exist; no telemetry event was added. |
| `world_complete` | Canonical TOP1 name; existing Act0 telemetry truth map references `world_completed`. Code alignment is deferred to a telemetry architecture wave. |
| `upgrade_viewed` | Canonical future commerce/readiness event name only. No paywall, upgrade, price, trial, purchase, or restore flow was added. |

No new telemetry owner, network telemetry, vendor wiring, or telemetry refactor was created.

## 7. Practice Session Concept ID Seam

Current seam is sufficient for future same-signal variations at the ID level, but not yet a generator.

- Current ID sources:
  - `Act0LessonTaskV1.worldId`, `lessonId`, `taskId`, and `resolvedTaskFamily`.
  - Active repair intent fields: `missedSignalId`, `skillAtomId`, `reasonCode`, source/target task IDs.
  - Practice repair queue projection fields: `sourceKey`, `skillTag`, `context`, `repairFocusKey`, `launchTarget`, and `launchRequest`.
  - Repair outcome projection fields: `repairFocusKey`, source/repair/target IDs, and outcome state.
  - Last-session return state: `last_session_repair_focus_id`, `last_session_proof_result`, `last_session_world_id`.
- Enough for future same-signal variations: yes, for source-owned repair focus and task-family routing.
- Deferred: no practice generator, no broader concept graph, no durable all-world taxonomy, and no W5-W36 expansion.

## 8. Implementation summary

This was a validation packet. No product code changes were necessary.

Exact changes made:

- Created this Wave 3.15 review artifact.
- Captured current W2/W3/W4 content-state evidence through focused Act0 tests.
- Documented W1-W4 taxonomy, telemetry-name mapping/gaps, and Practice concept-ID seam.

Why no broader content expansion occurred:

- Existing W2-W4 content tests prove non-placeholder spines, enough decision reps, transfer tasks, suboptimal literacy, and beginner-safe boundaries.
- Adding new content or capture tooling would exceed this evidence-first wave without a concrete P0/P1 blocker.

## 9. Learner-visible change

No direct UI copy or route behavior changed. The learner/reviewer-facing movement is evidence: W2-W4 are now documented as credible Foundation depth instead of assumed future quality.

## 10. Evidence

Focused W2 tests:

- `World 2 has a real hand-discipline spine`
- `World 2 content covers hand discipline without strategy jumps`
- `World 2 has enough true decision reps before World 3`
- `World 2 includes suboptimal literacy as non-punitive growth`
- `World 2 keeps beginner-safe no-chart framing`
- `World 2 checkpoint explicitly bridges to position thinking`
- `World 2 includes a real-table discipline transfer rep`

Focused W3 tests:

- `World 3 has a real position-thinking spine`
- `World 3 content covers position thinking without strategy jumps`
- `World 3 has enough true decision reps before World 4`
- `World 3 includes a real-table transfer read`
- `World 3 includes suboptimal literacy as non-punitive growth`
- `World 3 checkpoint bridges to frame-first preflop`

Focused W4 tests:

- `World 4 has a real preflop framework spine`
- `World 4 content covers preflop framework without charts`
- `World 4 has enough true decision reps before World 5`
- `World 4 includes a real-table frame transfer rep`
- `World 4 includes suboptimal literacy as non-punitive growth`
- `World 4 checkpoint bridges to bet-purpose thinking`
- `W4 price checkpoint adds live purpose-price transfer with stable id`
- `W4 live purpose-price transfer stays inside the checkpoint owner seam`

Screenshot/evidence packet paths:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`

Current tooling limitation:

- `./tools/screen_review_fast_v1.sh` supports `core`, `runner`, `first_week`, `day2_return`, `profile_evidence`, and `full_scroll`.
- It does not currently expose dedicated `world_2`, `world_3`, or `world_4` capture groups.
- This is classified as an accepted capture-lane gap, not a P1 product-quality blocker, because focused content-state tests directly prove W2-W4 launch depth.

Baseline note:

- Broad `--name "World 2"` and `--name "World 3"` filters also pull unrelated RU-localization tests that remain red in this file. Exact W2/W3 launch-quality tests passed.

## 11. Anti-theater proof

This packet does not claim all 36 worlds are ready. It proves only W2-W4 Foundation depth using current route state, content tests, and local evidence packets. It does not add marketing copy, public packaging, store claims, premium pressure, or artificial runtime readiness.

## 12. Context Efficiency Protocol

Followed.

- No broad repo read.
- Owner seams were found by graphify/query and targeted string search.
- Generated outputs were produced but not read as source authority.
- Historical/archive docs were not reopened.
- The work stayed in current SSOT snippets, active Act0 state/tests, screenshot tooling, telemetry truth map, and this review artifact.

## 13. Not built

- No W5-W36 implementation.
- No broad content expansion.
- No Store/Public packaging.
- No paywall/trial/purchase/restore.
- No AI/chat/GTO/solver.
- No Modern Table changes.
- No route rewrite.
- No telemetry refactor.
- No practice generator.

## 14. Expected TOP1 movement

Expected movement is positive for foundation depth confidence, public-v1 readiness evidence, W2-W4 quality-cliff risk reduction, and external reviewer confidence.

## 15. Actual observed movement

The matrix row moved from assumption to evidence. W2-W4 have focused tests proving route titles, content jobs, enough decision reps, non-punitive suboptimal options, transfer tasks, and beginner-safe boundaries. The remaining measurable gap is dedicated W2-W4 screenshot capture, which should be considered for later reviewer-packet tooling but did not block this quality packet.

## 16. Next route validity

Recommended next route:

1. Refresh `day2_return`, `first_week`, and `full_scroll` packets.
2. Run a fresh TOP1 challenger pass.
3. Move to Wave 4.0 Store/Public Readiness Packet only if the excellence band remains strong enough.
