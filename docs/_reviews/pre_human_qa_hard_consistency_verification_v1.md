# Pre-Human-QA Hard Consistency Verification v1

Date: 2026-07-09
Branch: `codex/pre-human-qa-hard-consistency-verification-v1`
Base HEAD: `7e9e783a255c2a421bea7a307519f1d5a02285c4`

## 1. Executive verdict.

Terminal verdict:
`hard_consistency_verification_ready_for_repair_planning`

The current evidence is sufficient to start a bounded pre-Human-QA repair and
verification planning wave. Another broad source/depth audit is not required
before planning the next wave, but fixed-build Human QA should not start from
the current artifact chain.

This pass reconciles the prior Codex sweep against the stricter Claude/Qulo
challenger. The stricter interpretation wins where the issue is
machine-verifiable, first-use, repair-surface, proof-tooling, or conflicts with
a prior closure claim.

Net decision:

- Do not run Human QA yet.
- Do not run a new broad W1-W12 content audit first.
- Run one bounded repair/verification wave covering tablet `welcome`,
  `practice_repair` density, `play` proof fidelity, Human QA protocol scope,
  real-text coverage, and targeted assessment-validity evidence.

## 2. Repository/evidence baseline.

Preflight:

- Mission expected `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Mission expected `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- Found initial checkout on `claude/parallel-final-pre-qa-human-readiness-challenger-v1`.
- Switched to `main` without modifying that branch.
- Created this branch from expected `main`.
- Current branch: `codex/pre-human-qa-hard-consistency-verification-v1`.
- Current branch base: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4`.
- `HEAD...origin/main`: `0/0` before edits.
- Tracked worktree before edits: clean.
- Local-only evidence: untracked `output/screen_review/`.
- `graphify hook-check`: passed.

Primary evidence read or inspected:

- `docs/_reviews/final_pre_qa_layout_and_proof_repair_v1.md`
- `claude/parallel-final-pre-qa-human-readiness-challenger-v1:docs/_reviews/parallel_final_pre_qa_human_readiness_challenger_v1.md`
- `origin/codex/final-post-repair-alpha-regression-sweep-v1:docs/_reviews/final_post_repair_alpha_regression_and_emergence_sweep_v1.md`
- `docs/_reviews/final_w1_w12_holistic_product_learning_visual_synthesis_v1.md`
- `docs/_reviews/alpha_journey_certification_enablement_and_surface_proof_v1.md`
- `docs/_reviews/full_w1_w12_product_journey_simulation_and_surface_reconciliation_v1.md`
- `docs/_reviews/final_w1_w12_answer_position_repair_and_machine_closure_v1.md`
- `docs/_reviews/w1_w12_known_deferred_debt_burn_and_closure_v1.md`
- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/context/VISUAL_PROOF_CAPSULE_v1.md`
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`
- `docs/plan/PRODUCT_SURFACE_READINESS_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`

Current proof inspected:

- `output/screen_review/current/act0_product_100_proof/manifest.json`
- `output/screen_review/current/act0_product_100_proof/*.png`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/active_route_w7_w12_fast/`

Manifest stats:

- Viewports: 4 (`compact_phone`, `tall_phone`, `large_phone`, `tablet`).
- Surfaces: 13.
- PNG entries: 52.
- Missing files: 0.
- Zero-byte PNGs: 0.
- Same-viewport MD5 duplicates: 0.

## 3. Evidence-type policy enforcement.

Applied policy:

- Masked/nonliteral proof images were used only for layout, geometry, density,
  safe-area, clipping, CTA placement, surface identity, and proof-tooling
  fidelity.
- Copy, tone, learning quality, payoff quality, repair personalization,
  terminology, and public/premium trust claims were not accepted from masked
  screenshots.
- Route, W13 boundary, task identity, answer binding, feedback binding, repair
  mapping, and telemetry claims were accepted only from source/tests.
- Real-text lanes were used for copy-sensitive sampling, but their current
  coverage is compact-only.

Unsupported or downgraded claims:

- Masked `welcome` cannot prove copy quality.
- Masked `practice_repair` cannot prove repair personalization quality.
- Masked `play` cannot prove live decision copy.
- Existing real-text compact decision evidence proves live-app compact
  decision rendering, but not tall/large/tablet decision layout.
- Existing machine evidence does not prove Human QA, public readiness, 9.0,
  10/10, premium trust, durable learning effect, or beginner mastery.

## 4. Codex-vs-Claude/Qulo conflict reconciliation.

Prior Codex sweep verdict:
`post_repair_sweep_admits_human_qa_with_nonblocking_residue`.

Claude/Qulo challenger verdict:
`parallel_challenger_recommends_one_bounded_pre_qa_repair`.

Reconciled verdict:
Claude/Qulo is directionally correct. The current build should not be admitted
to fixed-build Human QA yet.

Conflicts resolved:

- Tablet `welcome`: Codex classified the issue as P4 Human-QA-only. Direct
  byte-ratio and image inspection show it is machine-verifiable, first-use, and
  previously claimed closed. Reclassified as `fix_before_human_qa`.
- `practice_repair`: Codex accepted the repair guards as enough. Direct
  inspection confirms the old dock gap is closed, but density remains
  mechanically weaker than sibling feedback surfaces. Reclassified as a
  secondary `fix_before_human_qa` item if bundled with welcome.
- `play` proof: Codex treated `play` as decision/play layout evidence. Source
  and images show the masked `play` surface captures the Practice hub, not the
  live decision/table moment. Reclassified as `fix_before_human_qa`
  evidence-tooling debt.
- W12 terminal/no-W13: both branches agree it is closed. Rejected as an active
  concern with current source, tests, and byte evidence.
- Human QA capsule: Claude/Qulo identified stale protocol scope. Current source
  confirms the capsule still scopes Human QA to W1-W6 and forbids W7-W12 opening
  as part of W1-W6 QA. Reclassified as `fix_before_human_qa` docs/protocol
  authority debt.

## 5. Tablet welcome closure verification.

Current byte sizes and compact-to-tablet growth:

| Surface | Compact bytes | Tablet bytes | Ratio |
|---|---:|---:|---:|
| `welcome` | 175631 | 206039 | 1.173 |
| `placement` | 354281 | 838150 | 2.366 |
| `home` | 186316 | 292226 | 1.568 |
| `correct_feedback` | 409678 | 831369 | 2.029 |
| `wrong_feedback` | 391005 | 794682 | 2.032 |
| `practice_repair` | 278969 | 700774 | 2.512 |
| `summary` | 54453 | 87939 | 1.615 |
| `review_profile` | 248754 | 353716 | 1.422 |

Direct evidence:

- `output/screen_review/current/act0_product_100_proof/tablet.welcome.png`
- `output/screen_review/current/act0_product_100_proof/compact_phone.welcome.png`
- `output/screen_review/current/act0_product_100_proof/manifest.json`

Verdict:

- The repair did add a real tablet two-column row composition.
- The closure claim does not hold to the owner quality bar.
- Tablet `welcome` remains the lowest-growth outlier in the proof matrix.
- The first-use path now has an inconsistent pair: tablet `placement` closes
  its void convincingly, while immediately following tablet `welcome` remains
  visibly underfilled.

Classification:
`fix_before_human_qa`.

## 6. Practice repair density verification.

Evidence:

- `output/screen_review/current/act0_product_100_proof/compact_phone.practice_repair.png`
- `output/screen_review/current/act0_product_100_proof/tall_phone.practice_repair.png`
- `output/screen_review/current/act0_product_100_proof/large_phone.practice_repair.png`
- `output/screen_review/current/act0_product_100_proof/tablet.practice_repair.png`
- Sibling comparison:
  `tablet.correct_feedback.png`, `tablet.wrong_feedback.png`.
- Guard reference:
  `test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart`.

Verdict:

- The original table-to-dock detached void is closed.
- The accepted repair guard is meaningful for its stated geometry contract:
  it checks repair envelope key, tablet table height, table-to-dock gap, and
  dock position.
- The guard is too narrow to prove sibling-level repair-surface density.
- `practice_repair` still reads thinner than correct/wrong feedback,
  especially on tablet, because the lower content region remains sparse
  compared with sibling feedback panels.

Classification:
`fix_before_human_qa` as a secondary bundled repair with tablet `welcome`.

## 7. Play proof fidelity verification.

Evidence:

- `output/screen_review/current/act0_product_100_proof/tablet.play.png`
- `output/screen_review/current/act0_product_100_proof/tablet.home.png`
- `output/screen_review/current/act0_product_100_proof/tablet.correct_feedback.png`
- `output/screen_review/current/act0_product_100_proof/tablet.practice_repair.png`
- `tools/act0_product_100_proof_capture_v1.dart`

Byte comparison:

| Viewport | Play bytes | Home bytes | Play/Home ratio | Correct feedback bytes | Practice repair bytes |
|---|---:|---:|---:|---:|---:|
| `compact_phone` | 188943 | 186316 | 1.014 | 409678 | 278969 |
| `tall_phone` | 208109 | 203846 | 1.021 | 443784 | 301744 |
| `large_phone` | 225492 | 234623 | 0.961 | 517193 | 331984 |
| `tablet` | 290390 | 292226 | 0.994 | 831369 | 700774 |

Source inspection:

- `play` capture opens the Practice tab with `debugSurface: null`.
- `correct_feedback`, `wrong_feedback`, `practice_repair`, and
  `w12_terminal` pin explicit `Act0ControlledDemoCaptureSurfaceV1` states.

Verdict:

- The masked `play` matrix surface captures the Practice landing/hub, not a
  live decision/table state.
- Existing compact real-text `first_week_fast/compact.decision.png` supports
  live-app correctness for the compact decision moment.
- Existing evidence does not support multi-viewport decision/play layout proof.

Classification:
`fix_before_human_qa` for proof tooling.

## 8. W12 terminal/no-W13 verification.

Evidence:

- Manifest terminal/play byte comparison.
- `tools/act0_product_100_proof_capture_v1.dart`.
- `lib/campaign/campaign_pack_registry_v1.dart`.
- `lib/services/progress_service.dart`.
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`.
- `test/guards/w10_w12_canonical_structural_closure_contract_test.dart`.
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart`.
- Real-text lane:
  `output/screen_review/current/active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png`.

Byte comparison:

| Viewport | Play bytes | W12 terminal bytes | Byte-identical |
|---|---:|---:|---|
| `compact_phone` | 188943 | 40998 | false |
| `tall_phone` | 208109 | 41730 | false |
| `large_phone` | 225492 | 65900 | false |
| `tablet` | 290390 | 91335 | false |

Source/test facts:

- W12 completion routes to `volume_i_terminal_review_v1`.
- W13 campaign IDs remain absent.
- Terminal copy says no future world is open and later worlds remain blocked.

Verdict:
closed.

Classification:
`reject_with_evidence` for any current W12 terminal/no-W13 active regression
claim.

## 9. Human QA capsule/protocol authority.

Evidence:

- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- Current mission scope: W1-W12 pre-Human-QA candidate.

Finding:

`HUMAN_QA_CAPSULE_v1.md` remains active but scopes the purpose to the W1-W6
learner outcome chain and forbids W7-W12 opening as part of W1-W6 Human QA.
That conflicts with the current W1-W12 fixed-build QA candidate premise.

Verdict:
stale protocol authority for this mission's intended QA stage.

Classification:
`fix_before_human_qa`.

## 10. Content/learning evidence sufficiency.

Evidence supporting sufficiency:

- The holistic synthesis reconciles the current journey and real-text W7-W12
  evidence without finding a new P0/P1 learning contradiction.
- Known-debt burn classifies W7-W12 terminology, checkpoint-template,
  option-order, and distractor-quality findings as already closed by accepted
  guards.
- Learning repair capsule records W1-W12 content depth, term introduction,
  same-signal/transfer, poker correctness, and targeted repair closures with
  explicit remaining optional/future items.
- Active real-text W7-W12 lane is final-audit-eligible and current for
  post-idealization copy.

Evidence limits:

- Zero-knowledge beginner path W1-W12 has not been validated by Human QA.
- W11 transfer strength still has carried-forward context-diversity residue.
- W12 guided-to-transfer ratio remains future-stage/content-depth judgment.
- W12 mindset credibility is supported by sampled real-text/source evidence
  but not proven as learner-internalized skill.
- Durable learning effect and "no shallow recognition counted as competence"
  cannot be fully established without either targeted source audit expansion
  or Human QA.

Verdict:
No broad deep content source audit is required before repair planning, but a
targeted verification checklist remains necessary before Human QA.

Classification:
`verify_before_human_qa`.

## 11. Assessment validity evidence sufficiency.

Evidence supporting sufficiency:

- `final_w1_w12_answer_position_repair_and_machine_closure_v1.md` proves the
  accepted answer-position blocker is closed across 291 assessed rows.
- `test/guards/w1_w12_answer_position_distribution_contract_test.dart` covers
  global distribution, longest runs, content/evaluator fingerprint, no runtime
  shuffle, W13 absence, and terminal pack presence.
- `test/guards/w10_w12_grouped_content_repair_contract_test.dart` covers
  W10-W12 authored option order, shortcut-copy fragments, duplicate prompt
  differentiation, forbidden distractor fragments, same-signal repair mapping,
  payoff, and terminal invariants.
- `test/guards/w1_w12_poker_correctness_review_contract_test.dart` covers
  selected answer/explanation integrity.

Remaining sufficiency gaps:

- The current evidence is strongest for answer-position and W10-W12 targeted
  shortcut repairs.
- It is weaker as an all-world proof for absurd distractors, duplicate prompts,
  guided examples reused as independent proof, and correct/acceptable/incorrect
  distinction across all W1-W12 assessed rows.
- These are mechanically verifiable and should be checked before Human QA
  rather than discovered by novice testers.

Verdict:
assessment validity is not blocked, but not fully arbitration-complete.

Classification:
`verify_before_human_qa`.

## 12. Real-text/copy evidence sufficiency.

Current real-text surfaces:

- `first_week_fast`: 13 compact surfaces.
- `day2_return_fast`: 5 compact surfaces.
- `active_route_w7_w12_fast`: 16 compact surfaces.

Coverage against required key surfaces:

| Key surface | Current real-text coverage |
|---|---|
| placement | yes, compact |
| welcome | yes, compact decision/feedback/handoff |
| decision/play | yes, compact decision |
| correct feedback | yes, compact |
| wrong feedback | yes, compact |
| practice repair | partial, compact repair focus/session repair/day2 target |
| session summary | yes, compact |
| review/profile | yes, compact review handoff/profile return/profile proof |
| W11 transfer | yes, compact active W11 copy detail |
| W12 payoff | yes, compact active W12 payoff copy detail |
| W12 terminal | yes, compact terminal/no-W13 copy detail |

Gaps:

- Real-text evidence is compact-only.
- Current tablet `welcome` finding is layout-only, but any copy-sensitive
  tablet concern cannot be judged from masked proof.
- Multi-viewport real-text decision/play proof is absent.
- `play` masked proof currently does not represent the live decision surface.

Verdict:
enough real-text evidence exists for targeted repair planning, but not enough
for fixed-build Human QA admission.

Classification:
`verify_before_human_qa`.

## 13. Test/tooling/refactor authority.

Current stale/confidence-affecting items:

- `play` capture step is semantically misleading in the 52-PNG matrix.
- `HUMAN_QA_CAPSULE_v1.md` is stale for W1-W12 protocol scope.
- `active_route_w7_w12_fast` still has an internal W11 filename using
  `danger_texture` while on-screen/source identity is W11 Real Play Transfer.
- Current tablet `welcome` layout guard allowed the low-growth outlier to pass.
- Practice repair geometry guard does not enforce sibling-density parity.

Required cleanup type:

- Small, targeted proof/layout/protocol cleanup only.
- No broad refactor.
- No product route/content/telemetry changes unless required by a bounded
  admitted repair wave.

Classification:
mixed `fix_before_human_qa` and `future_stage` as recorded below.

## 14. Fix-before-Human-QA ledger.

### CODEX-HARD-001

- Severity: P1.
- Classification: `fix_before_human_qa`.
- Route/screen/world/task: first-use `welcome`, tablet viewport.
- Evidence type: masked layout proof, runtime manifest.
- Evidence path/source:
  `output/screen_review/current/act0_product_100_proof/tablet.welcome.png`,
  `output/screen_review/current/act0_product_100_proof/manifest.json`.
- Exact measured data:
  `welcome` compact 175631 bytes, tablet 206039 bytes, ratio 1.173; sibling
  ratios: `placement` 2.366, `home` 1.568, `correct_feedback` 2.029,
  `wrong_feedback` 2.032, `practice_repair` 2.512.
- Learner/product consequence:
  first-use tablet path still reads underfilled after a preceding sibling
  screen proves tablet fill can be achieved.
- Introduced by recent repair:
  not introduced, but left unresolved by a repair that claimed closure.
- Prior artifact claimed closed:
  yes, `final_pre_qa_layout_and_proof_repair_v1.md`.
- Minimum repair or verification:
  make tablet `welcome` vertically fill and grow proportionally in line with
  sibling surfaces; add a focused guard or manifest-derived check.
- Likely owner:
  Act0 placement/welcome layout owner.
- Validation method:
  rerun product proof capture, inspect tablet welcome, compare ratio against
  sibling band, run focused layout guard and diff checks.
- Conflict:
  conflicts with prior Codex sweep; agrees with Claude/Qulo challenger.

### CODEX-HARD-002

- Severity: P3.
- Classification: `fix_before_human_qa`.
- Route/screen/world/task: `practice_repair`, all viewports, most visible on
  tablet.
- Evidence type: masked layout proof.
- Evidence path/source:
  `output/screen_review/current/act0_product_100_proof/tablet.practice_repair.png`,
  `tablet.correct_feedback.png`, `tablet.wrong_feedback.png`.
- Exact measured data:
  `practice_repair` compact 278969 bytes, tablet 700774 bytes, ratio 2.512;
  repair table/dock geometry is present, but visual density remains below
  sibling feedback panels by direct inspection.
- Learner/product consequence:
  repair launch can still feel thinner than the feedback moment that sends the
  learner there.
- Introduced by recent repair:
  no; residual after partial repair.
- Prior artifact claimed closed:
  partially, for table-to-dock geometry; not for density parity.
- Minimum repair or verification:
  add lower-panel/support content or density constraint so repair visually
  approaches correct/wrong feedback density.
- Likely owner:
  Act0 lesson runner repair-fill layout owner.
- Validation method:
  rerun product proof capture, inspect all viewports, add or update focused
  density guard if implemented.
- Conflict:
  prior Codex treated as closed; Claude/Qulo classified as secondary residual.

### CODEX-HARD-003

- Severity: P3.
- Classification: `fix_before_human_qa`.
- Route/screen/world/task: `play` proof surface in
  `act0_product_100_proof`.
- Evidence type: masked layout proof, source.
- Evidence path/source:
  `output/screen_review/current/act0_product_100_proof/tablet.play.png`,
  `tools/act0_product_100_proof_capture_v1.dart`.
- Exact measured data:
  tablet `play` 290390 bytes vs `home` 292226 bytes, ratio 0.994; tablet
  `correct_feedback` 831369 and `practice_repair` 700774.
- Learner/product consequence:
  the 52-PNG matrix cannot currently prove multi-viewport decision/play layout.
- Introduced by recent repair:
  no; pre-existing proof-tooling gap left after terminal proof repair.
- Prior artifact claimed closed:
  no direct closure; prior Codex sweep over-read `play` proof as decision/table
  evidence.
- Minimum repair or verification:
  pin an explicit live decision/table debug surface for `play`, then add
  semantic/distinctness proof.
- Likely owner:
  Act0 product proof capture tooling.
- Validation method:
  source guard plus rerun proof capture and byte/hash comparison against home
  and table-bearing surfaces.
- Conflict:
  conflicts with prior Codex sweep; agrees with Claude/Qulo challenger.

### CODEX-HARD-004

- Severity: P2.
- Classification: `fix_before_human_qa`.
- Route/screen/world/task: Human QA protocol authority.
- Evidence type: source/docs.
- Evidence path/source:
  `docs/context/HUMAN_QA_CAPSULE_v1.md`.
- Exact measured data:
  capsule states Human QA should test W1-W6 and forbids W7-W12 opening as
  part of W1-W6 Human QA; current mission evaluates W1-W12 fixed-build QA.
- Learner/product consequence:
  QA protocol could be scoped to the wrong route boundary.
- Introduced by recent repair:
  no; stale capsule.
- Prior artifact claimed closed:
  no; stale-capsule residue was repeatedly excluded.
- Minimum repair or verification:
  update or supersede Human QA capsule/protocol to explicitly govern W1-W12
  fixed-build QA while preserving no fake QA/no launch claims.
- Likely owner:
  docs/context QA protocol owner.
- Validation method:
  docs diff check, graphify hook-check, explicit route-scope references.
- Conflict:
  prior Codex treated as nonblocking/excluded; Claude/Qulo flagged.

## 15. Verify-before-Human-QA ledger.

### CODEX-HARD-005

- Severity: P2.
- Classification: `verify_before_human_qa`.
- Route/screen/world/task: W1-W12 assessment validity.
- Evidence type: source/tests/review artifacts.
- Evidence path/source:
  `test/guards/w1_w12_answer_position_distribution_contract_test.dart`,
  `test/guards/w10_w12_grouped_content_repair_contract_test.dart`,
  `docs/_reviews/final_w1_w12_answer_position_repair_and_machine_closure_v1.md`,
  `docs/_reviews/w1_w12_known_deferred_debt_burn_and_closure_v1.md`.
- Exact measured data:
  291 assessed rows covered by answer-position guard; W10-W12 distribution
  `{0: 14, 1: 14, 2: 14}`; W10-W12 forbidden distractor fragments guarded.
- Learner/product consequence:
  Human QA should not be used to discover mechanically detectable shortcut
  assessment residue.
- Introduced by recent repair:
  no.
- Prior artifact claimed closed:
  partially; answer-position and selected W10-W12 shortcut repairs are closed,
  but all-world validity dimensions are not exhaustively re-proven here.
- Minimum repair or verification:
  targeted assessment-validity verification checklist for absurd distractors,
  duplicate prompts, guided-example reuse, and correct/acceptable/incorrect
  distinction across W1-W12.
- Likely owner:
  content/assessment guard owner.
- Validation method:
  focused guard or script, no full suite unless shared owner breaks.
- Conflict:
  refines both prior Codex and Claude/Qulo; does not require a broad audit
  before repair planning.

### CODEX-HARD-006

- Severity: P3.
- Classification: `verify_before_human_qa`.
- Route/screen/world/task: real-text/copy evidence coverage.
- Evidence type: real-text screenshots, manifests.
- Evidence path/source:
  `output/screen_review/current/first_week_fast/manifest.json`,
  `output/screen_review/current/day2_return_fast/manifest.json`,
  `output/screen_review/current/active_route_w7_w12_fast/manifest.json`.
- Exact measured data:
  compact real-text lanes cover 13 + 5 + 16 surfaces; no tall/large/tablet
  real-text coverage.
- Learner/product consequence:
  copy-sensitive claims across non-compact viewports remain unsupported.
- Introduced by recent repair:
  no.
- Prior artifact claimed closed:
  no; prior reports explicitly used real-text lanes as supplementary evidence.
- Minimum repair or verification:
  either produce targeted real-text evidence for changed/high-risk surfaces or
  explicitly limit Human QA packet claims to compact real-text plus masked
  geometry for other viewports.
- Likely owner:
  screen-review evidence owner.
- Validation method:
  manifest/index check and path-level evidence map.
- Conflict:
  narrows prior Codex admission; partly agrees with Claude/Qulo evidence
  boundary.

## 16. Reject-with-evidence ledger.

### CODEX-HARD-007

- Severity: P4.
- Classification: `reject_with_evidence`.
- Route/screen/world/task: W12 terminal/no-W13.
- Evidence type: runtime manifest, source, tests, real-text screenshot.
- Evidence path/source:
  manifest terminal/play comparison; `campaign_pack_registry_v1.dart`;
  `progress_service.dart`; W12 route guards; active-route terminal real-text
  screenshot.
- Exact measured data:
  terminal/play byte-identical is false on all four viewports.
- Learner/product consequence:
  no current terminal/no-W13 regression found.
- Introduced by recent repair:
  no; repair closed prior proof-fidelity defect.
- Prior artifact claimed closed:
  yes, and current evidence supports closure.
- Minimum repair or verification:
  none before Human QA beyond preserving existing guards.
- Likely owner:
  W12 route/proof owner.
- Validation method:
  existing W12 route/no-W13 guards.
- Conflict:
  agrees with both prior Codex and Claude/Qulo.

### CODEX-HARD-008

- Severity: P4.
- Classification: `reject_with_evidence`.
- Route/screen/world/task: tablet `placement` void.
- Evidence type: masked layout proof, manifest.
- Evidence path/source:
  `tablet.placement.png`, manifest byte table.
- Exact measured data:
  `placement` compact 354281 bytes, tablet 838150 bytes, ratio 2.366.
- Learner/product consequence:
  prior placement void is closed.
- Introduced by recent repair:
  repaired by recent repair.
- Prior artifact claimed closed:
  yes, and current evidence supports closure.
- Minimum repair or verification:
  none.
- Likely owner:
  Act0 placement layout.
- Validation method:
  preserve focused layout guard.
- Conflict:
  agrees with Claude/Qulo; no conflict with Codex.

## 17. Human-QA-only ledger.

### CODEX-HARD-009

- Severity: P4.
- Classification: `human_qa_only`.
- Route/screen/world/task: felt comprehension and perceived learning effect.
- Evidence type: source and screenshot evidence boundary.
- Evidence path/source:
  Human QA capsule, synthesis non-claims, current proof manifests.
- Exact measured data:
  none; this requires real participants.
- Learner/product consequence:
  only novice behavior can prove whether the route feels learned rather than
  merely visible.
- Introduced by recent repair:
  no.
- Prior artifact claimed closed:
  no.
- Minimum repair or verification:
  real Human QA only after fix/verify ledgers are closed.
- Likely owner:
  Human QA protocol owner.
- Validation method:
  admitted Human QA protocol with real participant evidence.
- Conflict:
  no conflict; all artifacts keep this as non-claimed.

## 18. Future-stage ledger.

### CODEX-HARD-010

- Severity: P4.
- Classification: `future_stage`.
- Route/screen/world/task: W11/W12 transfer depth and broader durable learning
  proof.
- Evidence type: review artifacts/source.
- Evidence path/source:
  W10-W12 adversarial audit, holistic synthesis, learning repair capsule.
- Exact measured data:
  W12 guided/transfer ratio and W11 context-diversity residue remain carried
  forward in prior artifacts.
- Learner/product consequence:
  affects future excellence and content-depth expansion, not current bounded
  proof-tooling repair planning.
- Introduced by recent repair:
  no.
- Prior artifact claimed closed:
  no; repeatedly carried as residue/future-stage.
- Minimum repair or verification:
  future content-depth/learning-effect wave if Human QA or source evidence
  promotes it.
- Likely owner:
  content/learning-depth owner.
- Validation method:
  future scoped content audit or Human QA evidence.
- Conflict:
  no direct conflict.

### CODEX-HARD-011

- Severity: P4.
- Classification: `future_stage`.
- Route/screen/world/task: stale internal W11 capture filename
  `w11_danger_texture`.
- Evidence type: local evidence filename plus on-screen/source identity.
- Evidence path/source:
  `output/screen_review/current/active_route_w7_w12_fast/compact.w11_danger_texture_task_copy_detail.png`;
  active metadata identifies task as W11 route evidence.
- Exact measured data:
  filename stale; copy/source identity current.
- Learner/product consequence:
  none; evidence-tooling naming residue only.
- Introduced by recent repair:
  no.
- Prior artifact claimed closed:
  no.
- Minimum repair or verification:
  rename when next touching active W7-W12 capture tooling.
- Likely owner:
  active route screen-review tooling owner.
- Validation method:
  package/index check.
- Conflict:
  agrees with Claude/Qulo as nonblocking naming debt.

## 19. Recommended repair/verification waves.

Recommended next wave:
`Pre-Human-QA Evidence/First-Use Repair Wave v1`.

Scope:

1. Fix tablet `welcome` vertical fill and add/strengthen the guard.
2. If touching the same layout owner, tighten `practice_repair` lower-panel
   density and add a density/ratio assertion.
3. Fix the `play` proof capture to pin an explicit live decision/table debug
   surface and add proof-fidelity guard coverage.
4. Update or supersede `HUMAN_QA_CAPSULE_v1.md` for W1-W12 fixed-build QA.
5. Produce a targeted real-text evidence map or new small lane for changed
   high-risk surfaces.
6. Run targeted assessment-validity verification for all-world shortcut
   classes not fully covered by the current answer-position guard.

Forbidden in that wave unless separately admitted:

- Broad W1-W12 rewrite.
- Modern Table redesign.
- W13+ activation.
- Route/progression changes unrelated to proof.
- Telemetry schema changes.
- Public readiness or 10/10 claims.

## 20. Whether another deep audit is required.

Another broad source/depth audit is not required before repair planning.

Reason:

- The blocker set is already concrete and bounded.
- The major contradictions are proof/layout/protocol/evidence-boundary issues,
  not unresolved source truth that demands a new full audit.
- Assessment/content gaps can be handled by targeted verification scripts or
  guards before Human QA.

Deep audit trigger:

- Run a deeper content source audit only if targeted assessment verification
  finds concrete all-world shortcut leakage beyond existing W10-W12 repaired
  rows, or if Human QA later exposes a repeated prerequisite/confusion cluster.

## 21. Exact Codex implementation checklist if repairs are ready.

1. Branch from latest `origin/main`.
2. Preserve local `output/screen_review/` as unstaged evidence.
3. Patch only Act0 `welcome` tablet layout owner and its focused guard.
4. Optionally patch `practice_repair` density if it shares the same safe owner.
5. Patch only proof tooling for `play` capture fidelity.
6. Patch only Human QA docs/protocol authority if admitted in the same wave.
7. Run product proof capture once.
8. Verify:
   - manifest has 52 non-empty PNGs;
   - tablet `welcome` ratio is no longer a low outlier;
   - `play` is not byte/structure-near-identical to `home`;
   - `w12_terminal` remains byte-distinct from `play`;
   - `practice_repair` density improves if touched.
9. Run focused layout/proof tooling guards.
10. Run targeted W12/no-W13 guards if proof tooling touches terminal code.
11. Run targeted assessment-validity verification if content confidence is part
    of the wave.
12. Run `flutter analyze` only if Dart code changes.
13. Run `git diff --check`, `git diff --cached --check`, and
    `graphify hook-check`.
14. Commit only admitted files.
15. Push branch; do not merge to main by default.

## 22. Explicit non-claims.

This artifact does not claim:

- Human QA was run.
- Human QA is admitted on the current build.
- Public launch/store readiness.
- 9.0, 10/10, top-1, premium trust, durable learning effect, or beginner
  mastery.
- W13+ activation.
- Modern Table redesign need.
- Current W12 terminal/no-W13 regression.
- Current live-app decision/play runtime defect.
- Broad W1-W12 content correctness failure.
- Any product code, tests, content, routes, telemetry, tooling, or screenshots
  were changed.

## 23. Validation.

Commands run:

```bash
git fetch origin main codex/final-post-repair-alpha-regression-sweep-v1 --prune
git rev-parse HEAD main origin/main
git rev-list --left-right --count HEAD...origin/main
git status --porcelain=v1 --untracked-files=no
graphify hook-check
graphify query "pre Human QA hard consistency Act0 proof tablet welcome practice repair play capture W12 terminal Human QA capsule"
python3 -m json.tool output/screen_review/current/act0_product_100_proof/manifest.json
python3 - <<'PY'
# manifest, byte-size, MD5, duplicate, play/home, and terminal/play checks
PY
```

Validation results:

- Repository baseline: expected `main` and `origin/main` verified.
- Parallel Claude/Qulo branch: not modified.
- Product proof manifest parser: passed; 52 entries, 0 missing, 0 zero-byte.
- Byte/hash comparisons: completed for `welcome`, `placement`, `home`, `play`,
  `correct_feedback`, `wrong_feedback`, `practice_repair`, `summary`,
  `review_profile`, and `w12_terminal`.
- Same-viewport duplicate MD5 scan: no duplicates.
- W12 terminal/play comparison: byte-distinct on all four viewports.
- Capture-tool source inspection: completed; `play` uses `debugSurface: null`.
- Full Flutter suite: not run; not required by mission and no code was changed.

Pending after artifact write:

- `git diff --check`
- `git diff --cached --check`
- final `graphify hook-check`
- commit and push

## 24. Token Efficiency Report.

- exact_usage: unavailable.
- selected model: Codex, high effort per mission.
- why sufficient: the work required deterministic source, runtime manifest,
  screenshot, and evidence-boundary arbitration; no external model escalation
  was needed.
- escalation status: no Claude commissioned by Codex; existing Claude/Qulo
  branch artifact was read via `git show`.
- estimated tokens: unavailable.
- files opened: mission attachment, context router/capsules, required review
  artifacts, proof manifest, real-text manifests, capture tool source, focused
  tests/guards, selected screenshots.
- full files read: mission attachment; `HUMAN_QA_CAPSULE_v1.md`; key sections
  of required artifacts and owner files were read by targeted ranges/search.
- targeted searches: welcome, practice repair, play capture, W12/no-W13,
  assessment validity, real-text coverage, Human QA scope.
- broad searches: one artifact-wide grep across selected docs/tests for
  evidence-sufficiency terms.
- Graphify queries: one query plus `graphify hook-check`.
- commands: git preflight/switch/fetch, graphify, manifest parser, byte/hash
  scripts, source/test searches, image inspection.
- tests: none run; mission validation did not require tests unless source
  contradiction appeared.
- screenshots inspected: tablet `welcome`, tablet `play`, tablet
  `practice_repair`, tablet `correct_feedback`, tablet `wrong_feedback`, plus
  manifest-backed all-surface byte/hash checks.
- largest token sinks: primary artifact reads and selected evidence searches.
- repeated investigation: none after baseline branch correction.
- avoidable cost: the first skill path read used a stale plugin path and had to
  be retried through discovery.
- whether another discovery pass is required: no broad discovery pass before
  repair planning; targeted verification is required before Human QA.
