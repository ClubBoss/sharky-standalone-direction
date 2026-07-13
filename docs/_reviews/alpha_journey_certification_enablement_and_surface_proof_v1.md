# Alpha Journey Certification Enablement and Layout Evidence v1

Date: 2026-07-08
Branch: `codex/alpha-journey-certification-enablement-v1`
Original main baseline: `738a783040093ede744e350ff9e656bb8d5a9d54`
Integrated audit main: `dcde6a256e7dc498e1b2f8d412308aab3b140a4d`

## 1. Objective

Repair the accepted alpha journey layout-evidence tooling blocker, reconcile stale validation authority, and rerun the multi-viewport Act0 layout matrix. This artifact records machine geometry evidence only; it does not provide real-text product proof or Alpha admission evidence.

Terminal verdict: `alpha_blocks_d_e_machine_closure_accepted_with_nonblocking_residue`

## 2. Integrated prior audit proof

The prior audit branch `codex/full-w1-w12-product-journey-simulation-v1` was verified at `dcde6a256e7dc498e1b2f8d412308aab3b140a4d`. Its only changed file was:

- `docs/_reviews/full_w1_w12_product_journey_simulation_and_surface_reconciliation_v1.md`

It was fast-forward merged into `main` and pushed. Local `main` and `origin/main` then matched at `dcde6a256e7dc498e1b2f8d412308aab3b140a4d` with ahead/behind `0/0`.

## 3. Capture-harness root cause

The accepted failure reproduced before the repair:

- Command: `dart run tools/act0_product_100_proof_capture_v1.dart`
- Root size: `Size(375.0, 812.0)`
- Derived tap: `Offset(187.5, 835.0)`
- Failing surface: compact `learn_detail`
- Failure: `Learn detail panel did not open`

Root cause: the generated Flutter test used widget-center tapping after `ensureVisible` without verifying the target was inside the root. The Learn card remained below the compact root after the scroll attempt, so the tap missed. The tool also used a tracked `output/device_audit` path and only covered three viewport classes.

## 4. Harness repair

Changed file:

- `tools/act0_product_100_proof_capture_v1.dart`

Repair:

- Moved generated output to local-only `output/screen_review/current/act0_product_100_proof`.
- Added the `tall_phone` viewport.
- Replaced coordinate/index bottom-nav taps with visible text/action finders.
- Added `tapVisibleTargetV1`, which checks target existence, calls `ensureVisible`, verifies the center is inside the logical root, then taps.
- Added actionable errors for missing targets and out-of-viewport centers.
- Expanded the surface matrix to 13 certification route families.
- Preserved production behavior; no product code was changed.

## 5. Validation-authority reconciliation

Changed tests:

- `test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`
- `test/guards/world1_placement_flow_contract_test.dart`
- `test/guards/world1_app_root_startup_contract_test.dart`
- `test/guards/world1_intake_plan_flow_contract_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_world1_completion_payoff_v1_test.dart`
- `test/guards/w7_w12_first_use_jargon_contract_test.dart`
- `test/guards/w7_w12_table_context_readiness_audit_contract_test.dart`
- `test/ui_v2/act0_w11_w12_internal_world_source_template_batch_v1_test.dart`

No stale test file was deleted. Superseded assertions were replaced with current positive authority.

## 6. Old/new guard authority matrix

| Old assertion | New authority |
|---|---|
| First-open route must show `intake_runner`. | First-open route starts in active `act0_shell_placement_screen` and excludes `intake_runner`. |
| Home cold start must show `act0_shell_home_daily_goal_card`. | Home cold start shows `act0_shell_home_daily_plan_card` and `act0_shell_home_mission_sharky_line`. |
| Successful Practice repair keeps the open repair intent. | Successful matching repair records the outcome and clears the open intent. |
| World 8 lacks completion payoff. | W2-W12 ordinary completion payoff includes World 8; W13 remains excluded. |
| W10 is old bet-purpose/W4/W9 bridge copy. | W10 is Player Adjustment: player tendency, one lever, guardrail, measured exploit. |
| W11 is old board-texture/danger route copy. | W11 is Real Play Transfer: session plan, trigger, review, one review output. |
| W12 is old review-clue route copy. | W12 is Mindset Bridge: process, reset, discipline, terminal review, no future-world unlock. |
| W7-W12 specs are all Practice-locked. | W7-W9 remain locked; W10-W12 are Practice-admitted with empty mapper-lock reason. |
| W11/W12 old hidden IDs and no Practice mapping. | Current W11/W12 hidden IDs, canonical concept families, Practice-admitted mapping. |

## 7. Multi-viewport scenario matrix

Output root: `output/screen_review/current/act0_product_100_proof`

Viewports:

- `compact_phone`: `375x812`
- `tall_phone`: `390x844`
- `large_phone`: `430x932`
- `tablet`: `834x1194`

Surfaces:

- `placement`
- `welcome`
- `home`
- `learn`
- `learn_detail`
- `play`
- `correct_feedback`
- `wrong_feedback`
- `practice_repair`
- `completion_payoff`
- `summary`
- `review_profile`
- `w12_terminal`

Manifest result: 4 viewports, 13 surfaces, 52 non-empty PNG entries.

## 8. Compact findings

Compact phone evidence completed for all 13 surfaces. The original Learn-detail blocker is closed on compact: the repaired harness opens the detail panel deterministically through the visible lesson-card finder. No compact geometry, safe-area, or physical-CTA blocker was observed. Copy, readability, and product-quality conclusions require real-text evidence.

## 9. Tall-phone findings

Tall-phone evidence completed for all 13 surfaces. No blank surface, offscreen primary CTA, hidden feedback, or unsafe-area blocker was observed. Text density remains a Human QA/readability-residue item, not a machine blocker.

## 10. Large-phone findings

Large-phone evidence completed for all 13 surfaces. Home, Learn, feedback, repair, payoff, profile, and W12 terminal surfaces remained reachable. No active visual activation blocker was observed.

## 11. Tablet findings

Tablet evidence completed for all 13 surfaces. Wider layouts render as full-root captures with reachable bottom navigation and visible action areas. Some dense informational surfaces still warrant Human QA review, but no machine-blocking clipping or CTA loss was observed.

## 12. Safe-area/readability/CTA matrix

| Check | Result |
|---|---|
| Safe area | Passed in machine visual review across all four viewports. |
| Viewport fill | Passed; no blank or unmounted root captures. |
| Clipping/overflow | No P0-P2 clipping observed in the layout-masked matrix. |
| CTA reachability | Passed; primary CTAs and bottom navigation are visible/reachable. |
| Feedback visibility | Correct and wrong feedback surfaces rendered across all viewports. |
| Continue/action reachability | Passed in captured feedback, payoff, and terminal surfaces. |
| One clear next action | Not evaluated by masked evidence; requires real-text and Human QA review. |
| Text readability | Not evaluated by masked evidence; requires real-text review. |
| Duplicate progress/status | No machine-blocking duplication observed. |
| Table/context readability | Layout presence only in this matrix; readable text requires real-text review. |
| Navigation continuity | Passed through generated harness and focused Home/Learn/Practice tests. |

## 13. Journey continuity proof

The repaired matrix covers first-open placement, welcome, Home, Learn, Learn detail, Practice/play, feedback, repair, completion, summary, review/profile, and W12 terminal surfaces. Focused route tests also passed for Home/Learn, Practice, repair queue, review, profile, W10-W12 route identity, and W12 no-W13 terminal policy.

## 14. Repair/recheck visual proof

The layout-masked matrix includes repair and feedback layout states for all four viewports. It proves state/layout presence only; repair wording and learner comprehension require real-text evidence. The repair validation cone passed with 164 tests, including lifecycle, queue resolution, review resolution, repair outcome projection/consumer, fix proof, and W7-W12 same-signal repair mapping.

## 15. Completion/Review/Profile proof

Completion, session summary, review/profile, proof projection, achievement seed, and premium transition tests passed in the focused completion/profile batch. World 8 now uses the ordinary W2-W12 completion payoff; W13 remains blocked from ordinary payoff.

## 16. W12 terminal/no-W13 proof

W12 terminal/no-W13 proof passed through:

- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
- `test/guards/w10_w12_canonical_structural_closure_contract_test.dart`
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart`
- product-proof `w12_terminal` screenshots across compact, tall, large, and tablet.

No W13 activation was introduced.

## 17. Screenshot evidence index

Local-only generated evidence:

- `output/screen_review/current/act0_product_100_proof/manifest.json`
- `output/screen_review/current/act0_product_100_proof/contact_sheet.png`
- `output/screen_review/current/act0_product_100_proof/<viewport>.<surface>.png`

Counts:

- 52 surface PNGs
- 1 manifest
- 1 contact sheet

Existing prior local evidence under `output/screen_review/current/first_week_fast`, `day2_return_fast`, and `active_route_w7_w12_fast` was preserved.

## 18. Product/visual finding ledger

| Class | Count | Notes |
|---|---:|---|
| P0 active product defects | 0 | None observed. |
| P1 active product defects | 0 | None observed. |
| P2 active product defects | 0 | None observed. |
| P3 active product defects | 0 | None observed. |
| P4 active product defects | 0 | None observed. |
| Evidence-tooling blockers | 0 open | Original capture blocker is closed. |
| Validation-authority blockers | 0 open | Known stale guards reconciled. |
| Nonblocking surface observations | 1 family | Dense text/felt clarity remains Human QA residue. |

## 19. Human-QA-only residue

Machine closure does not answer:

- Whether placement feels too long.
- Whether W10-W12 concepts feel learned rather than merely visible.
- Whether repair copy feels personal enough.
- Whether payoff moments feel emotionally strong.
- Whether tablet density feels premium.
- Whether public launch trust is sufficient for real alpha users.

These are Human QA inputs, not machine blockers found in this mission.

## 20. Alpha Block D status

Alpha Block D status: closed at machine-evidence level.

Reason:

- End-to-end Act0 journey surfaces completed across focused tests and screenshot proof.
- Validation authority is current for the known stale guard families.
- No active journey regression remains in the focused validation set.
- Remaining issues are Human-QA-only or nonblocking residue.

## 21. Alpha Block E status

Alpha Block E status: admitted and closed at machine-evidence level with nonblocking residue.

Reason:

- Compact, tall, large, and tablet evidence completed.
- No clipping, overflow, inaccessible CTA, hidden feedback, unsafe-area, or serious readability blocker was observed in the machine proof matrix.
- Modern Table was not redesigned or reopened.
- Remaining surface concerns are Human QA/nonblocking polish.

## 22. Repair-wave decision

No product repair wave is recommended from this mission.

No visual repair wave is recommended from this mission.

The exact next stage is real-text evidence closure, then Human QA / alpha candidate review using complete local evidence and focused green validation.

## 23. Exact next stage

Recommended next stage:

`ALPHA-HUMAN-QA-CANDIDATE-v1`

Inputs:

- Current `main` after this branch is integrated.
- Closure artifact in this file.
- Local layout-masked contact sheet and PNG evidence under the current `act0_layout_masked_proof` lane; this lane cannot authorize Alpha admission.
- Existing first-week, day-2, and active-route local evidence under `output/screen_review/current/`.

## 24. Explicit non-claims

This artifact does not claim:

- Human QA was performed.
- Public release/store readiness is complete.
- Monetization or entitlement states were tested.
- W13+ was activated.
- Learning content was rewritten.
- Canonical route/progression behavior was changed.
- Telemetry was changed.
- Modern Table was redesigned.
- Aesthetic polish was performed.
- Generated screenshots should be committed.

## 25. Validation

Preflight and integration:

- `git fetch origin --prune`: passed.
- `graphify hook-check`: passed before integration.
- Audit branch local/remote: `dcde6a256e7dc498e1b2f8d412308aab3b140a4d`.
- Audit branch diff: exactly `docs/_reviews/full_w1_w12_product_journey_simulation_and_surface_reconciliation_v1.md`.
- Prior audit branch fast-forward merged to `main` and pushed.
- Integrated `main` / `origin/main`: `dcde6a256e7dc498e1b2f8d412308aab3b140a4d`, ahead/behind `0/0`.

Red/reproduction:

- `dart run tools/act0_product_100_proof_capture_v1.dart`: reproduced `Offset(187.5, 835.0)` outside `Size(375.0, 812.0)` and `Learn detail panel did not open`.
- `flutter test test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`: failed before repair, passed after repair.
- Known stale validation groups failed before reconciliation and passed after reconciliation.

Post-repair validation already passed:

- `dart run tools/act0_product_100_proof_capture_v1.dart`: passed twice.
- Manifest validation: 4 viewports, 13 surfaces, 52 entries, 52 non-empty.
- `flutter test test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`: 4 passed.
- Reconciled stale validation group: 52 passed.
- Home/Learn/Practice/feedback group: 50 passed.
- Repair lifecycle cone: 164 passed.
- Completion/Profile/W10-W12/terminal group: 341 passed.

Final validation before staging:

- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `graphify hook-check`: passed.
- `git diff --cached --check`: run after staging.

## 26. Token Efficiency Report

- exact_usage: unavailable
- selected model: Codex GPT-5 coding agent
- why sufficient: Flutter test/tooling repair, deterministic screenshot generation, and branch integration were within normal Codex coding capability.
- escalation status: no Claude commissioned; no model escalation used.
- estimated total tokens: unavailable in runtime; likely inside the requested medium-effort band.
- files opened: attachment, prior audit artifact, capture tool, screen-review shell, named stale tests, current positive guards, W11/W12 owner/harness files, Act0 shell debug-surface snippets.
- full files read: mission prompt, selected skill files, `tools/act0_product_100_proof_capture_v1.dart`, `tools/screen_review_fast_v1.sh`, prior audit artifact.
- targeted searches: product-proof tool, stale keys, W10-W12 IDs, debug harness surfaces, Home/placement keys.
- broad searches: none over curriculum/content/archive.
- Graphify queries: `graphify hook-check`; no broad graph report read.
- commands: git preflight/integration, capture reproduction, capture reruns, focused Flutter tests, manifest checks, contact sheet generation.
- tests: focused tooling, placement/startup, Home/Learn, repair lifecycle, payoff/profile/review, W10-W12, W12 terminal/no-W13.
- screenshots generated/inspected: 52 product-proof PNGs plus contact sheet; prior local packets preserved.
- largest token sinks: test output and W10-W12 guard reconciliation.
- repeated investigation: one rerun of capture for determinism; one focused stale-group rerun after final wording patch.
- avoidable cost: stale W11/W12 batch had extra old assumptions beyond the first ID failure.
- another discovery pass required: no for machine closure; yes for Human QA.
- certification blockers closed per estimated 10k tokens: two blocker families closed, evidence tooling and validation authority.
