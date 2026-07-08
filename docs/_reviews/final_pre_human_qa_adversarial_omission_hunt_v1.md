# Final Pre-Human-QA Adversarial Omission Hunt v1

Date: 2026-07-09
Branch: `codex/final-pre-human-qa-adversarial-omission-hunt-v1`
Base HEAD: `7e9e783a255c2a421bea7a307519f1d5a02285c4`

## 1. Executive verdict

Terminal verdict: `omission_hunt_requires_screenshot_pipeline_repair_before_final_sweep`.

This omission hunt found one new pre-Human-QA blocker class: the current
screenshot/evidence system is not sufficient for the next final full 10/10
pre-Human-QA visual/product/copy/learning-readiness sweep. The product-100
lane is valid masked layout evidence, but not copy/product-readiness evidence.
The available real-text lanes are compact-only, locally generated from an
older commit, and do not provide a current all-surface/all-viewport proof map.

No additional mechanically proven route, content, answer-validity, transition,
or Human-QA-protocol blocker was found beyond the accepted ledgers.

## 2. Repository/evidence baseline

- Repository: `/Users/elmarsalimzade/Sharky_1.0`
- Remote: `https://github.com/ClubBoss/sharky-standalone-direction.git`
- Current branch: `codex/final-pre-human-qa-adversarial-omission-hunt-v1`
- Local `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`
- `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`
- Ahead/behind: `0/0`
- Tracked worktree before artifact: clean
- Expected local-only evidence: `output/screen_review/`, left untracked

The four primary prompt paths for pre-Human QA full-depth, hard-consistency,
parallel challenger, and final post-repair regression artifacts were not
present at their exact filenames. Per the prompt, current equivalents were
located through the context router and support artifacts. This missing-name
condition is not classified as product debt.

## 3. Known ledger summary

| ID / family | Current disposition | Evidence |
| --- | --- | --- |
| `ALPHA-JOURNEY-001` multi-viewport proof harness failure | repaired | `alpha_journey_certification_enablement_and_surface_proof_v1.md` |
| `ALPHA-JOURNEY-002` stale validation authority | repaired | `alpha_journey_certification_enablement_and_surface_proof_v1.md` |
| `FINAL-SYNTH-001` practice-repair layout void | repaired | `final_pre_qa_layout_and_proof_repair_v1.md` |
| `FINAL-SYNTH-002` tablet placement/welcome void | repaired | `final_pre_qa_layout_and_proof_repair_v1.md` |
| `FINAL-SYNTH-003` W12 terminal proof byte-identical to play | repaired | `final_pre_qa_layout_and_proof_repair_v1.md` |
| `FINAL-SYNTH-004` stale active-route capsule residue | known/excluded | `final_w1_w12_holistic_product_learning_visual_synthesis_v1.md` |
| `FINAL-W1W12-001` answer-position dominance | repaired | `final_w1_w12_answer_position_repair_and_machine_closure_v1.md` |
| `KD-W6-promise-checkpoint-bridge` | repaired | `w1_w12_known_deferred_debt_burn_and_closure_v1.md` |
| `KD-X-stale-test-expectation` | repaired | `w1_w12_known_deferred_debt_burn_and_closure_v1.md` |
| `W10W12-DCA-004` concept echo | repaired | `w10_w12_grouped_content_repair_and_closure_v1.md` |
| `W10W12-DCA-007` condition-contrast feedback | prioritized rows repaired; broader nuance deferred | `w10_w12_grouped_content_repair_and_closure_v1.md` |
| `W10W12-DCA-008` duplicate scored prompts | repaired | `w10_w12_grouped_content_repair_and_closure_v1.md` |
| Human QA W1-W6/W1-W12 scope mismatch | known protocol-scope item | `HUMAN_QA_CAPSULE_v1.md`, prompt accepted-state list |

Known findings count: 13.

## 4. Evidence-type policy enforcement

Masked screenshots may prove only layout, geometry, safe area, surface
presence, CTA reachability, and coarse visual hierarchy. They cannot prove
copy, content clarity, tone, feedback quality, payoff quality, repair
personalization, premium feel, public readiness, or learning depth.

Copy/content/learning/tone/payoff claims require real-text screenshots or
source/test evidence. Route, task, answer, feedback, repair, telemetry, and
no-W13 claims require source/tests.

This artifact applies that boundary strictly. The new finding below is an
evidence-system finding, not a claim that the underlying product surfaces are
defective.

## 5. Omission search method

1. Read the current router and the accepted pre-QA layout/proof, answer-position,
   journey, alpha-certification, known-debt, Human QA, and screenshot-tooling
   artifacts.
2. Built the known-finding table above.
3. Parsed current local screenshot manifests and evidence indexes.
4. Searched only the active screenshot tooling, proof guards, Act0 capture
   surfaces, and targeted guard families for omitted evidence/tooling,
   transition, source-validity, and Human QA protocol gaps.
5. Rejected candidates already covered by the ledgers or unsupported by the
   evidence-type policy.

## 6. Screenshot / visual evidence pipeline readiness

Current masked layout lane:

- Manifest: `output/screen_review/current/act0_product_100_proof/manifest.json`
- `render_kind`: `nonliteral_preview_contract`
- `lane_type`: `preview_contract`
- Viewports: `compact_phone`, `tall_phone`, `large_phone`, `tablet`
- Surfaces: 13
- Entries: 52
- Non-empty PNGs: all entries have bytes greater than zero
- W12 terminal/play byte comparison: `all_terminal_images_differ_from_play: true`

This lane is adequate for layout-contract proof. It is not adequate for
copy/product/learning-readiness review.

Current real-text lanes observed locally:

- `first_week_fast`: compact only, `render_kind: flutter_widget_test_real_text`
- `day2_return_fast`: compact only, `render_kind: flutter_widget_test_real_text`
- `active_route_w7_w12_fast`: compact only, `render_kind: flutter_widget_test_real_text`
- Native/core real-text packet exists only as
  `output/screen_review/current/core/screen_review_core.zip`; no extracted
  current `manifest.json` exists at `output/screen_review/current/core/`.

Freshness problem:

- The real-text indexes for `first_week_fast`, `day2_return_fast`, and
  `active_route_w7_w12_fast` record
  `git_commit=738a783040093ede744e350ff9e656bb8d5a9d54`.
- Current HEAD is
  `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Each real-text index records `git_status=dirty`.

Viewport problem:

- Real-text evidence is compact-only.
- No current tall-phone, large-phone, or tablet real-text evidence was found
  for the high-risk copy/product surfaces.

Surface-coverage problem:

- Current real-text coverage includes placement, welcome beats, decision,
  feedback, repair, summary, review/profile return, W7-W12 copy-detail/table,
  W12 payoff, and terminal/no-W13 compact surfaces.
- Current real-text Home, Learn, and lesson-detail evidence is not present as
  extracted current files; the older core packet is zipped and dated before
  the current build chain.

Semantic identity problem:

- The masked product-100 lane now has 13 unique SHA-256 hashes per viewport,
  so no other exact byte-identical masked surface recurrence was found.
- The real-text `first_week_fast` packet has an exact duplicate hash for
  `compact.repair_focus.png` and `compact.session_repair.png`.
- Source maps those labels to two distinct controlled states,
  `repairFocus` and `sessionRepair`, but both states currently call the same
  wrong-outcome repair proof debug path. This may be acceptable product reuse,
  but the evidence system does not distinguish intentional same-state reuse
  from mislabeled surface proof.

Manifest-authority problem:

- The masked manifest records `lane_type` and `render_kind`, but entries have
  only `viewport`, `surface`, `path`, and `bytes`.
- The real-text manifests record packet-level `render_kind`, `allowed_use`,
  `visual_audit_validity`, and `capture_source_policy`.
- Neither lane provides a per-entry field set for `is_real_text`,
  `surface_identity`, `semantic_assertions`, `allowed_claims`, `viewport`, and
  route/source state sufficient to prevent future audit overclaiming.

Final readiness decision: the screenshot/evidence pipeline must be repaired
before the final full pre-Human-QA visual/product sweep.

## 7. Other evidence/tooling omissions

No additional standalone tooling blocker was found outside the screenshot
pipeline class. Existing guards for active W7-W12 real-text tooling check that
the active route lane uses active Act0 owners, blocks the archive runner,
uses active-surface metadata, repairs Ahem-text overlays, and marks the lane
as final-audit eligible. Those are useful but not enough to prove current
multi-viewport real-text readiness.

## 8. Visual/activation omissions

No new mechanically proven visual/activation defect was found beyond the
accepted and repaired placement/welcome/practice-repair findings.

The current 4-viewport product-100 lane can still support layout outlier
checks, and its manifest passed the expected 52-entry non-empty parser check.
Because that lane is masked, it cannot support final copy, tone, public trust,
premium feel, or learning-readiness review.

## 9. Product journey/transition omissions

No new transition-identity blocker was found. The accepted ledgers and focused
evidence cover:

- placement -> welcome -> first decision
- Home/Learn -> lesson detail
- decision -> feedback
- feedback -> repair
- repair -> recheck
- session summary -> Review/Profile
- W12 -> terminal/no-W13

The only transition-related gap in this pass is evidence freshness/claim
authority for a final visual/product sweep, not missing source/test transition
protection.

## 10. Content/learning omissions

No additional content/learning omission was found from targeted search. The
known DCA families are already captured:

- DCA-004 concept echo repaired.
- DCA-007 condition-contrast improved on prioritized rows, with broader nuance
  already deferred as low-EV/Human-QA-dependent residue.
- DCA-008 duplicate scored prompts repaired.
- Answer-position dominance repaired across W1-W6 and W8-W9; W10-W12
  distribution invariant preserved.

No broad W1-W12 content audit was run or required by this mission.

## 11. Test/tooling/maintenance omissions

The guard files referenced by the accepted artifacts still exist:

- `test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart`
- `test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`
- `test/guards/w1_w12_answer_position_distribution_contract_test.dart`
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart`
- `test/guards/w7_w9_grouped_content_repair_contract_test.dart`
- `test/guards/w1_w12_known_deferred_debt_burn_contract_test.dart`
- `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`

No obvious compile/analyze blocker was found from targeted source/test search.
No full Flutter suite was run because this is a docs-only omission hunt and no
source contradiction required broad validation.

## 12. Human QA protocol omissions

The known Human QA scope issue remains already covered: `HUMAN_QA_CAPSULE_v1.md`
still describes W1-W6-specific learner-outcome scope while the current
accepted state is W1-W12 pre-Human QA. The prompt already listed this as a
known repair/verification ledger item, so it is not a new omission.

No additional Human QA protocol precondition was found beyond:

- do not execute fake/synthetic QA;
- do not claim launch, 9.0, durable learning, or public readiness before Human
  QA;
- do not send Human QA unsupported claims that the screenshot/evidence system
  cannot prove.

## 13. New findings ledger

| ID | Severity | Classification | Route/screen/world/task | Evidence type | Evidence path/source | Exact measured data | Learner/product consequence | Why missed | Changes repair wave? | Minimum repair or verification | Likely owner | Validation method |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `OMISSION-HUNT-001` | P2 | `fix_before_human_qa` | Screenshot/evidence pipeline for final pre-Human-QA sweep; all Act0 high-risk surfaces | Manifest/source/local-output verification | `act0_product_100_proof/manifest.json`, `first_week_fast/manifest.json`, `day2_return_fast/manifest.json`, `active_route_w7_w12_fast/manifest.json`, `screen_review_index.json`, `tools/act0_product_100_proof_capture_v1.dart`, `tools/act0_real_text_surface_capture_v1.dart` | Masked lane: 4 viewports x 13 surfaces x 52 entries, `render_kind=nonliteral_preview_contract`; real-text lanes: compact only; real-text indexes at `738a783...` while current HEAD is `7e9e783...`; all real-text indexes `git_status=dirty`; `repair_focus` and `session_repair` compact PNGs byte-identical | A final 10/10 visual/product/copy/learning-readiness sweep would be forced either to overclaim from masked screenshots or to judge current product copy from stale compact-only evidence | Prior ledgers focused on specific proof bugs and layout repair; they did not reclassify the entire evidence system against the stricter final-sweep claim standard in this v2 prompt | Yes. Add Screenshot / Evidence Pipeline Repair v2 before final full visual/product sweep | Keep masked lane as layout-contract only; add/extend current real-text product-proof lane; include high-risk surfaces; prefer all four viewports or publish an explicit unsupported-claims map; ensure live decision/table capture; add per-lane/per-entry allowed claims, semantic assertions, route/source state, and current-HEAD freshness checks; guard duplicate surface hashes except explicit allowlist | screenshot tooling / evidence pipeline owner | Rerun capture on current HEAD; parser checks for freshness, fields, dimensions, surface coverage, duplicate-hash policy, and allowed-claims separation; focused guards for play/live decision and semantic terminal/no-W13 |

New findings count: 1.

## 14. Already-covered findings table

| Candidate | Classification | Evidence |
| --- | --- | --- |
| Practice repair density/layout void | `already_covered_by_existing_ledger` | repaired in `final_pre_qa_layout_and_proof_repair_v1.md` |
| Tablet placement/welcome layout void | `already_covered_by_existing_ledger` | repaired in `final_pre_qa_layout_and_proof_repair_v1.md` |
| W12 terminal byte-identical to play | `already_covered_by_existing_ledger` | repaired and byte-guarded in `final_pre_qa_layout_and_proof_repair_v1.md` |
| W10-W12 DCA-004 concept echo | `already_covered_by_existing_ledger` | repaired in grouped content closure |
| W10-W12 DCA-007 condition contrast | `already_covered_by_existing_ledger` | prioritized repair plus known residue classification |
| W10-W12 DCA-008 duplicate scored prompts | `already_covered_by_existing_ledger` | repaired in grouped content closure |
| Answer-position dominance | `already_covered_by_existing_ledger` | repaired in final W1-W12 machine closure |
| W6 promise/checkpoint bridge | `already_covered_by_existing_ledger` | repaired in known-debt burn |
| Stale active route capsule | `already_covered_by_existing_ledger` | recorded as `FINAL-SYNTH-004`, excluded by later mission scope |
| Human QA W1-W6/W1-W12 scope mismatch | `already_covered_by_existing_ledger` | present in prompt accepted-state list |

Already-covered count: 10.

## 15. Reject-with-evidence table

| Candidate | Classification | Evidence |
| --- | --- | --- |
| Missing exact primary filenames mean repository divergence | `reject_with_evidence` | prompt allowed locating equivalents through the context router |
| Current masked W12 terminal still captures play | `reject_with_evidence` | current product-100 manifest reports terminal/play byte comparisons all false |
| Other masked product-100 surfaces are byte-identical duplicates | `reject_with_evidence` | SHA-256 counts are 13 unique images per viewport |
| Prior isolated resolver lifecycle failure still blocks this pass | `reject_with_evidence` | later layout/proof artifact records affected repair/play guards passing |
| A new broad W1-W12 content audit is required now | `reject_with_evidence` | prompt states another broad audit is not currently required; targeted search found no new concrete contradiction |

Reject-with-evidence count: 5.

## 16. Human-QA-only/future-stage table

| Candidate | Classification | Evidence |
| --- | --- | --- |
| Felt pacing of placement/welcome | `human_qa_only` | Human QA capsule owns novice pacing; no new machine defect found |
| Felt repair personalization strength | `human_qa_only` | source/tests prove repair mechanics; perceived personalization needs real users |
| Emotional payoff and premium trust | `human_qa_only` | screenshot/source evidence cannot certify launch trust |
| Full W12+ transfer-depth expansion | `future_stage` | known-debt burn classifies broader transfer depth as future architecture |
| Modern Table/store asset sweep | `future_stage` | outside active Act0 pre-Human-QA omission scope |

Human-QA-only count: 3.
Future-stage count: 2.

## 17. Updated repair wave impact

The repair wave changes. Add one prerequisite before the final full
pre-Human-QA visual/product sweep:

`Screenshot / Evidence Pipeline Repair v2`

This should be a tooling/evidence wave, not product content or route repair.
The final sweep should not start until the evidence system can clearly
separate masked layout proof, real-text product proof, and source/test truth.

## 18. Screenshot pipeline repair prerequisite decision

Screenshot / Evidence Pipeline Repair v2 is required before the final full
pre-Human-QA visual/product/copy/learning-readiness sweep.

Minimum repair:

1. Keep the product-100 masked lane as `layout_contract` only.
2. Add or extend a current `real_text_product_proof` lane.
3. Ensure play/decision captures a live decision/table surface.
4. Ensure high-risk surfaces have readable full-resolution real-text evidence:
   placement, welcome, decision/play, correct feedback, wrong feedback,
   practice repair, completion payoff, summary, review/profile, and W12
   terminal/no-W13.
5. Prefer all four viewports for real-text evidence.
6. If all four viewports are not feasible in one wave, publish a strict
   coverage map and mark unsupported claims explicitly.
7. Make the manifest distinguish masked layout proof, real-text product proof,
   and source/test truth.
8. Include allowed claims per lane and preferably per entry.
9. Add guardrails preventing masked screenshots from being cited for copy,
   content, product-readiness, premium, or learning-depth claims.
10. Add freshness checks that fail when real-text evidence `git_commit` differs
    from the build under audit.
11. Add duplicate-surface hash checks, with an explicit allowlist only when two
    labels intentionally prove the same state.

## 19. Whether current repair planning can start

Repair planning can start, but it must include `OMISSION-HUNT-001` as a
pre-final-sweep blocker. Product/content repair planning should not rely on
masked screenshots for copy or product-readiness claims.

## 20. Whether another audit is required

No additional broad omission audit is required now. After the screenshot
pipeline repair lands, run the final full pre-Human-QA visual/product sweep
using the repaired evidence lanes.

## 21. Exact next action

Implement `Screenshot / Evidence Pipeline Repair v2` as a bounded tooling and
evidence-lane wave. Then rerun the final full pre-Human-QA visual/product
sweep on current HEAD with explicit claim boundaries.

## 22. Explicit non-claims

- No Human QA was executed.
- No product code, tests, content, routes, telemetry, or screenshot tooling
  were changed by this artifact.
- No launch, public-readiness, 9.0, 10/10, durable learning-effect, mastery,
  or Human-QA approval claim is made.
- Masked screenshots are not treated as copy/content/tone/payoff evidence.
- The new finding is not a claim that the current product surfaces are broken;
  it is a claim that the current evidence system cannot support the final
  full-sweep standard.

## 23. Validation

Validation results:

- `git diff --check`: passed.
- Manifest parser for current proof evidence: passed.
  - Product-100 manifest is `nonliteral_preview_contract`.
  - Product-100 manifest has 4 viewports, 13 surfaces, 52 entries, all
    non-empty.
  - Product-100 terminal/play byte comparison reports all terminal images
    differ from play.
  - Real-text `first_week_fast`, `day2_return_fast`, and
    `active_route_w7_w12_fast` manifests parse as compact
    `flutter_widget_test_real_text` packets with non-empty entries.
- Screenshot evidence index / manifest coverage check: completed.
  - Real-text indexes for `first_week_fast`, `day2_return_fast`, and
    `active_route_w7_w12_fast` all report
    `git_commit=738a783040093ede744e350ff9e656bb8d5a9d54`,
    `matches_current=false`, and `git_status=dirty`.
  - Masked manifest coverage reports `masked_surface_count=13` and
    `masked_entry_count=52`.
- `graphify hook-check`: passed.
- `git diff --cached --check`: passed after staging this single artifact.

## 24. Token Efficiency Report

- exact_usage: unavailable
- selected model: GPT-5 Codex coding agent
- why sufficient: the mission required source/runtime/test/proof verification
  and adversarial gap classification, not product repair
- escalation status: no Claude or external reviewer commissioned
- files opened: mission attachment, context router, Human QA capsule, visual
  and worktree capsules, accepted review artifacts, screenshot manifests,
  targeted screenshot tooling/guard sections, and local evidence indexes
- broad searches: avoided except one targeted screenshot-tooling search whose
  output was treated as orientation
- targeted searches: render kind, real-text, manifest fields, W12 terminal,
  DCA IDs, answer-position, Human QA protocol, screenshot surface labels
- graphify: one query attempted; it did not provide useful screenshot context;
  `graphify hook-check` remains required validation
- tests: no Flutter full suite; no product/test changes were made
- generated evidence: none created; existing `output/screen_review/` was read
  only as local evidence and left untracked
- largest token sinks: accepted ledger reconciliation and screenshot tooling
  source/manifest inspection
- whether another omission audit is required: no
