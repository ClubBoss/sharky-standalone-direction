# Final Post-Repair Alpha Regression and Emergence Sweep v1

Date: 2026-07-09
Branch: `codex/final-post-repair-alpha-regression-sweep-v1`
Base HEAD: `7e9e783a255c2a421bea7a307519f1d5a02285c4`

## 1. Executive verdict

Terminal verdict: `post_repair_sweep_admits_human_qa_with_nonblocking_residue`

The final pre-QA repair did not introduce a P0/P1/P2 route, learning, visual,
repair, terminal, proof-fidelity, or evidence-integrity regression in the
bounded sweep cone. Fixed-build Human QA is admitted.

One P4 Human-QA-only residue remains: tablet first-use composition still uses a
very calm centered layout with large inactive surrounding space, especially on
`welcome`. The prior tablet void blocker is not reproduced as a machine
activation failure because the content block, primary CTA, and safe area remain
visible/reachable, and the focused layout guard remains green.

## 2. Repository baseline

- Current branch before work: `main`.
- Created branch: `codex/final-post-repair-alpha-regression-sweep-v1`.
- Expected local `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Expected `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Verified local HEAD: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Verified `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Ahead/behind after fetch: `0/0`.
- Tracked worktree before edits: clean.
- Untracked local-only evidence: `output/screen_review/`.
- Preflight `graphify hook-check`: passed.

No `blocked_by_repository_state_divergence` condition was found.

## 3. Prior repair closure proof

Read: `docs/_reviews/final_pre_qa_layout_and_proof_repair_v1.md`.

Accepted prior verdict:
`pre_qa_layout_and_proof_repair_complete_human_qa_ready`.

The prior repair closure records bounded repairs for:

- `FINAL-SYNTH-001`: practice repair layout void.
- `FINAL-SYNTH-002`: tablet placement/welcome first-use void.
- `FINAL-SYNTH-003`: W12 terminal proof capture byte-identical to play.

It also records that no route admission, content, repair logic, telemetry
contract, or progression behavior was intentionally changed.

## 4. Evidence-type policy

Applied policy:

- Masked/nonliteral screenshots from
  `output/screen_review/current/act0_product_100_proof/` were used only for
  geometry, viewport fill, clipping, overflow, CTA placement, safe areas,
  spacing, surface identity, and rough layout rhythm.
- Real-text lane evidence under `first_week_fast`, `day2_return_fast`, and
  `active_route_w7_w12_fast`, plus source/tests, was used for copy, no-W13,
  repair semantics, route semantics, and proof-fidelity claims.
- No copy, content quality, tone, terminology, payoff quality, repair
  personalization quality, or public-readiness claim was made from masked
  screenshots.

Unsupported claims rejected: Human QA has not been run; public release/store
readiness is not claimed; masked screenshots do not approve copy or learning
quality.

## 5. Route continuity smoke

Evidence:

- `flutter test test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/act0_product_100_proof_capture_tooling_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w10_w12_canonical_structural_closure_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/guards/world1_placement_flow_contract_test.dart test/guards/world1_app_root_startup_contract_test.dart test/guards/world1_intake_plan_flow_contract_test.dart test/guards/w1_w12_answer_position_distribution_contract_test.dart`
- Result: 66 tests passed.
- Proof matrix: 4 viewports x 13 surfaces = 52 PNG entries.

Route continuity result: pass.

Covered path:

`first open -> placement/welcome -> Home -> Learn -> lesson/detail -> decision/play -> correct feedback -> wrong feedback -> practice repair -> repair result -> summary -> Review/Profile -> return reason -> W12 terminal -> no-W13`

No route break, wrong surface, unreachable action target, false progress,
review/profile disconnection, or terminal/no-W13 contradiction was found.

## 6. Visual/activation regression check

Masked proof inspected:

- `compact_phone`: 13 surfaces.
- `tall_phone`: 13 surfaces.
- `large_phone`: 13 surfaces.
- `tablet`: 13 surfaces.

Checked surfaces:

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

Result:

- `practice_repair`: repaired fill holds across compact, tall, large, and
  tablet. The old detached table-to-dock void was not reproduced.
- `placement`: tablet content now extends into a useful support band; CTA
  remains reachable.
- `welcome`: tablet uses a wide centered content frame and reachable primary
  CTA. It remains visually calm with large surrounding inactive space, but this
  is not a machine activation blocker in the current evidence.
- `play`, `correct_feedback`, `wrong_feedback`: table/context and feedback
  regions render without observed clipping or hidden action areas.
- `summary`, `review_profile`, `completion_payoff`, `w12_terminal`: visible
  primary content and action/navigation areas remain present.

Visual regression result: no P0/P1/P2 active visual/activation regression.

## 7. Repair/recheck regression check

Evidence:

- `test/ui_v2/act0_play_shell_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_review_resolution_contract_v1_test.dart`
- `test/ui_v2/act0_fix_proof_projection_v1_test.dart`
- `test/ui_v2/act0_repair_outcome_projection_v1_test.dart`
- `test/ui_v2/act0_profile_evidence_projection_v1_test.dart`
- `output/screen_review/current/day2_return_fast/compact.practice_repair_target.png`
- `output/screen_review/current/day2_return_fast/compact.review_continuation.png`
- `output/screen_review/current/day2_return_fast/compact.profile_not_clear.png`

Result:

- Repair CTA still appears for launchable active repair rows.
- Practice repair target still opens.
- Correct repair records success and clears resolver priority.
- Failed repair keeps resolver priority.
- Matching successful repair resolves the Review item.
- Failed/unrelated/same-family-different repair does not over-resolve Review.
- Profile evidence projection still receives and groups learning evidence.

Repair/recheck regression result: pass.

## 8. W12 terminal/no-W13/proof fidelity

Manifest/source evidence:

- `output/screen_review/current/act0_product_100_proof/manifest.json`
- `tools/act0_product_100_proof_capture_v1.dart`
- `lib/campaign/campaign_pack_registry_v1.dart`
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
- `test/guards/w10_w12_canonical_structural_closure_contract_test.dart`
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart`
- `output/screen_review/current/active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png`
- `output/screen_review/current/active_route_w7_w12_fast/compact.volume_i_terminal_review_table.png`
- `output/screen_review/current/active_route_w7_w12_fast/compact.w12_payoff_completion_copy_detail.png`

Manifest byte checks:

| Viewport | Play bytes | W12 terminal bytes | Byte-identical |
|---|---:|---:|---|
| `compact_phone` | 188943 | 40998 | false |
| `tall_phone` | 208109 | 41730 | false |
| `large_phone` | 225492 | 65900 | false |
| `tablet` | 290390 | 91335 | false |

The proof tool asserts terminal semantics including `Volume I terminal review`,
`future world`, and absence of `World 13` / `W13` in the generated semantic
terminal capture. Source copy routes W12 to terminal review without opening a
future world. Focused W12 tests passed.

Terminal/no-W13 result: pass.

## 9. Content smoke invariance

Evidence:

- `git diff --name-only 7e9e783a255c2a421bea7a307519f1d5a02285c4...HEAD`
  before artifact edits showed no product/content/test changes on this branch.
- Current branch changes only this review artifact.
- `test/guards/w1_w12_answer_position_distribution_contract_test.dart` passed.
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart` passed.
- `test/guards/w1_w12_poker_correctness_review_contract_test.dart` was not
  rerun because no content files changed in this sweep; the current
  answer-position/content-binding guard was sufficient and cheap.

Result:

- Task IDs: no changed source path in this sweep.
- Option order: guarded by `w1_w12_answer_position_distribution_contract_test`.
- Correct answer binding: guarded by the answer-position/content-binding cone.
- Feedback binding: guarded by W10-W12 grouped content repair and route tests.
- Repair mapping: guarded by Act0 repair intent/projection tests.
- Telemetry event identity: no telemetry files changed; repair tests keep
  existing event names such as `repair_completed` in scope.
- Copy visibility in changed surfaces: changed surfaces are from prior repair,
  now covered by proof matrix and layout guards.

Content smoke result: pass.

## 10. User-reported concern smoke

| Concern | Classification | Evidence |
|---|---|---|
| placement/welcome void | `still_nonblocking` | Tablet placement/welcome no longer reproduce the prior machine blocker; tablet welcome remains visually calm with large inactive space, Human QA should judge felt pacing. |
| practice repair void | `closed_by_recent_repair` | Masked proof and `final_pre_qa_layout_and_proof_repair_contract_test.dart` show repair fill. |
| table/learning public-readiness | `human_qa_only` | Masked screenshots support geometry only; real learner trust remains Human QA. |
| repair hidden/generic surface impression | `closed_by_recent_repair` | Practice repair target is visible in masked proof and day-2 real-text lane; repair projection tests passed. |
| summary/review/profile proof visibility | `closed_by_recent_repair` | Summary and review/profile surfaces render in all four proof viewports; Review/Profile projection tests passed. |
| completion visibility | `closed_by_recent_repair` | Completion payoff appears in all four proof viewports. |
| unexplained or mixed copy | `human_qa_only` | No new visible real-text contradiction found; copy quality remains outside masked proof. |
| W12 terminal credibility | `closed_by_recent_repair` | Terminal is byte-distinct from play, semantically terminal, and no-W13 tests passed. |

## 11. Evidence integrity

Manifest:

- Path: `output/screen_review/current/act0_product_100_proof/manifest.json`.
- `lane_type`: `preview_contract`.
- `render_kind`: `nonliteral_preview_contract`.
- Viewports: 4.
- Surfaces: 13.
- Entries: 52.
- Missing files: 0.
- Zero-byte PNG entries: 0.
- `w12_terminal` vs `play`: byte-distinct in all four viewports.

Real-text support lanes present:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/active_route_w7_w12_fast/`

The active W7-W12 lane guard passed and confirms final-audit eligibility for
that real-text evidence lane.

## 12. P0-P4 finding ledger

| ID | Severity | Route/surface | Viewport | Evidence type | Evidence path | Learner/product consequence | Introduced by recent repair | Minimum repair | Validation |
|---|---|---|---|---|---|---|---|---|---|
| POST-REPAIR-SWEEP-001 | P4 | first-use `welcome` tablet composition | tablet | masked_layout_proof | `output/screen_review/current/act0_product_100_proof/tablet.welcome.png` | Human QA should judge whether the large calm area around the centered content feels too empty or too slow; no machine route/CTA/safe-area failure observed. | Not clearly introduced; it is residual composition after the prior tablet repair. | None before fixed-build Human QA unless human testers flag felt activation drag. | `final_pre_qa_layout_and_proof_repair_contract_test.dart` passed; masked proof inspected. |

Counts:

- P0: 0.
- P1: 0.
- P2: 0.
- P3: 0.
- P4: 1.

## 13. Remaining nonblocking residue

- Tablet first-use composition should be watched in Human QA for felt pacing
  and premium quality.
- Human QA still owns claims about comprehension, motivation, trust, payoff
  strength, copy clarity, and public readiness.
- Local `output/screen_review/` evidence remains untracked and local-only.

## 14. Human-QA admission decision

Decision: admit fixed-build Human QA with nonblocking residue.

Reason:

- No active P0/P1/P2 regression remains in the bounded sweep cone.
- No P3 repair was found that clearly improves QA validity enough to justify
  another pre-QA repair wave.
- The only ledger item is P4 and explicitly belongs to Human QA judgment.

## 15. Exact next stage

Next exact action:

`ALPHA-HUMAN-QA-CANDIDATE-v1`

Use:

- Current branch artifact after merge/acceptance.
- Local proof manifest and PNGs under
  `output/screen_review/current/act0_product_100_proof/`.
- Real-text support lanes under `output/screen_review/current/first_week_fast/`,
  `day2_return_fast/`, and `active_route_w7_w12_fast/`.

Do not freeze the build from this artifact alone; Human QA has not been run.

## 16. Explicit non-claims

This artifact does not claim:

- Human QA was performed.
- Public/store release readiness is complete.
- Copy, tone, or learning quality is approved from masked screenshots.
- Premium trust is proven.
- W13+ was activated.
- Routes, progression, telemetry, repair mappings, content, or tests changed in
  this sweep.
- Modern Table was redesigned or reopened.
- A broad W1-W12 content audit was performed.

## 17. Validation

Commands run:

```bash
git fetch origin main --prune
git rev-parse HEAD origin/main main
git rev-list --left-right --count HEAD...origin/main
git status --porcelain=v1 --untracked-files=no
graphify hook-check
graphify query "Final post-repair alpha regression sweep Act0 route W12 terminal practice repair placement welcome proof manifest tests"
python3 -m json.tool output/screen_review/current/act0_product_100_proof/manifest.json
python3 - <<'PY'
# manifest count, zero-byte, missing-file, and terminal/play byte comparison check
PY
flutter test test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart test/guards/act0_product_100_proof_capture_tooling_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart test/guards/w10_w12_canonical_structural_closure_contract_test.dart test/guards/w10_w12_grouped_content_repair_contract_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/guards/world1_placement_flow_contract_test.dart test/guards/world1_app_root_startup_contract_test.dart test/guards/world1_intake_plan_flow_contract_test.dart test/guards/w1_w12_answer_position_distribution_contract_test.dart
flutter test test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/ui_v2/act0_review_resolution_contract_v1_test.dart test/ui_v2/act0_profile_evidence_projection_v1_test.dart test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_repair_outcome_projection_v1_test.dart
flutter analyze
```

Results:

- Product proof manifest check: passed; 52 non-empty PNG entries, no missing
  files, all terminal images byte-distinct from play.
- W12 terminal/no-W13 focused tests: passed in the 66-test batch.
- Practice repair focused tests: passed in the 66-test batch.
- Placement/welcome focused tests: passed in the 66-test batch.
- Home/Learn route smoke tests: passed in the 66-test batch.
- Repair/recheck smoke tests: passed across the 66-test and 58-test batches.
- Current answer-position/content-binding guard: passed in the 66-test batch.
- Active W7-W12 real-text/proof-lane guard: passed in the 58-test batch.
- `flutter analyze`: no issues found.
- `graphify hook-check`: passed.

Pending after this file is written:

- `git diff --check`.
- `git diff --cached --check`.
- Commit and push branch.

## 18. Token Efficiency Report

- exact_usage: unavailable.
- selected model: Codex, medium effort as requested by the mission.
- why sufficient: the sweep required deterministic repo preflight, focused
  Flutter guards, source/test reconciliation, manifest checks, and visual proof
  inspection; no unresolved learning/product contradiction required escalation.
- escalation status: Claude Sonnet 5 not commissioned.
- estimated tokens: unavailable.
- files opened: mission attachment, required review artifacts, proof manifest,
  focused source/test search results, screenshot montages, selected screenshots.
- full files read: `final_pre_qa_layout_and_proof_repair_v1.md`,
  `alpha_journey_certification_enablement_and_surface_proof_v1.md`, and the
  available opening portion of
  `final_w1_w12_holistic_product_learning_visual_synthesis_v1.md`.
- targeted searches: terminal/no-W13, proof tooling, repair/recheck, Review,
  Profile, answer-position/content binding, layout guard seams.
- broad searches: one overly broad targeted `rg` command returned excessive
  output and was not repeated.
- Graphify queries: one query plus `graphify hook-check`.
- commands: repo preflight, manifest parser/byte comparison, montage helper,
  two focused Flutter test batches, `flutter analyze`.
- tests: 124 focused tests passed.
- screenshots inspected: 52 masked proof screenshots via four viewport
  montages, plus direct tablet welcome inspection and existing real-text lane
  path checks.
- largest token sinks: broad `rg` output and required review-artifact reading.
- repeated investigation: none beyond the second focused test batch requested
  by the mission scope.
- avoidable cost: narrower initial `rg` patterns would have reduced output.
- whether another discovery pass is required: no machine discovery pass is
  required before fixed-build Human QA; Human QA remains required for felt
  product quality.
