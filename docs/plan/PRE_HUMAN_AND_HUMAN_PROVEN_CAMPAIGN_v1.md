# Pre-Human And Human-Proven Product Campaign v1

Status: **ACTIVE CAMPAIGN STATE DOCUMENT (planning; no implementation performed)**

Date: 2026-07-25
Campaign baseline: `52034abb6f614b907b2d9277eeca5e1f642b92f9` (`main` == `origin/main`, tracked worktree clean)
Authoring agent: Claude Code (planning + targeted verification only)
Human Novice Proof: **NOT PERFORMED**

Headline result of this planning pass: the Final Deep Independent Audit's
blocking family (**F-16**) is closed and independently re-verified at head
(62/62), **but the first full run of `test/ui_v2` + `test/guards` at head reports
1810 passed / 239 failed** — 128 compile failures and 111 assertion failures
across 53 files, none of which any automatic lane executes. Ten of those sit on
canonical or canonical-adjacent Act0 surfaces. Two new findings are recorded:
**F-17**, an assertion-evidence pool (**not** 111 product defects), and
**F-18**, one reproduced compact teaching-copy absence whose **causation is
unproven**. Pre-Human Node 5 is therefore decomposed into five sub-packets and
the first executable window is **PHP-0 triage only**.

Authority position: this document sits **beneath**
`docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` and
`docs/plan/MASTER_PLAN_v3.0.md`, and **above** individual packet reviews for
campaign sequencing only. It does not create a competing SSOT, does not
authorize visual redesign, does not reopen Modern Table, and does not move the
Human QA gate earlier.

Claim boundary: every verdict below rests either on an admitted authority
artifact named in §1 or on a targeted verification executed at
`52034abb` and recorded in §2. Screenshots and AI review are not Human Novice
evidence. No rubric dimension whose evidence is Human-bound is given a numeric
score.

---

## 1. Pass 1 — authority and evidence map

### 1.1 Documents read in Pass 1

| Document | Role | What it controlled here |
| --- | --- | --- |
| `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` | execution capsule (freshest head section) | node sequence, frozen surfaces, owner decisions, forbidden scope |
| `docs/_reviews/final_deep_independent_audit_current_head_v1.md` | blocking independent audit at `4563ce2d` | F-01…F-16, disposition vocabulary, Node 5 packet, Waves 3.10–3.15 matrix |
| `docs/_reviews/f16_canonical_contract_adjudication_v1.md` | F-16 closure ledger at `1e99912e` | per-item adjudication of the 12 blocking failures |
| `docs/_reviews/node4_visual_ledger_reconciliation_v1.md` | visual/UX disposition ledger (36 records) | visual P0/P1/P2 state, GR/CODEX-HARD/PREHQA/DCA/ALI rows |
| `docs/plan/MASTER_PLAN_v3.0.md` (targeted: `1–60`, `120–200`, `560–700`) | active execution SSOT | route order, device policy, excellence-wave order, forbidden scope, freshness corrections |
| `docs/_reviews/w1_w6_post_repair_canonical_rescore_v1.md` | W1–W6 source re-score | per-world provisional scores, Wave-4 admission decisions, stale-test disposition |
| `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md` (targeted) | learning debt ledger | W1W6-DLR-001…006 current state and severity counts |
| `docs/_reviews/w1_w12_known_deferred_debt_burn_and_closure_v1.md` (targeted) | known-debt burn ledger | KD-W2…KD-W6, KD-X rows and their dispositions |
| `docs/_reviews/human_novice_proof_protocol_v1.md` | Human protocol | Horizon B session design, evidence classes, verdict vocabulary |
| `docs/_reviews/sharky_three_register_system_lock_v3.md`, `docs/_reviews/sharky_10_10_master_backlog_and_direction_plan_v1.md` | Sharky direction + merged visual deconstruction | Sharky owner decision state, merged 6.8–7.8 visual score, six named visual gaps |
| `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`, `docs/plan/PRODUCT_SURFACE_READINESS_v1.md`, `docs/current/READINESS.md` | readiness authorities | Act0-route vs whole-product readiness separation; the second is REFERENCE only |
| `docs/deferred_backlog.md` | deferred SSOT | 13 deferred entries and their gates |

### 1.2 Provisional remaining capability map (Pass 1 result, before verification)

1. Canonical guard-lane truth (no lane runs `test/ui_v2` / `test/guards` in full).
2. Legacy test-corpus ownership disposition (F-15).
3. Premium motion & ceremony completion (F-01/F-02, Wave 3.10 remainder).
4. Sharky integration completeness proof (owner-named mandatory pre-Human block).
5. Screen-role / visual-hierarchy emphasis proof (W1W6-DLR-003).
6. Evidence-lane completeness (F-13 W2 capture lane, milestone-state capture).
7. Pre-Human admission publication.

Pass 2 subsequently added two items this map did not contain — the assertion
layer of the two canonical test directories (F-17) and one reproduced compact
teaching-copy absence whose causation is unproven (F-18) — which is why the executable
sequence in §4 opens with PHP-0 rather than with any Pass-1 item.

### 1.3 Classification summary (Pass 1)

- **Closed with current evidence:** Node 4's 24 FIXED rows, its 4 DISPROVED rows, N4-R01, Waves 3.11–3.15, W1W6-DLR-001/002/004, KD-W2…KD-W6, telemetry/privacy Subwave 4, content census (291/466).
- **Deferred inside pre-Human:** F-01, F-02, F-13, F-14, GR-11/14/16, Sharky evidence-capture gaps, milestone capture anomaly.
- **Open at Pass 1:** F-15 (legacy corpus), F-16 (12 canonical failures — *status contested by the newer adjudication ledger*), guard-lane gate absence, DLR-003 proof.
- **Human-bound:** felt comprehension, felt credibility, Human protocol scope, durable learning effect.
- **Outside pre-Human:** tablet, dormant preflop list, future content architecture, RU rollout, sizing curriculum, the 13 `deferred_backlog.md` entries, whole-product non-Act0 readiness.

### 1.4 Top-three macro comparison

| Macro option | Content | Why not / why yes |
| --- | --- | --- |
| **A. Guard-lane truth first, then ceremony, then admission** (SELECTED) | restore the ability of any lane to detect a regression, then close the two owner-mandated families (motion/ceremony, Sharky), then admit | The audit's own root cause is "a guard that no lane runs is a guard that cannot fail." Every later closure claim is worth less until this is fixed. Also the cheapest ordering: motion guards added in PHP-5 are only meaningful once a lane runs them. |
| B. Ceremony/Sharky first (owner-named blocks first), guard lane last | close the two owner-mandated families immediately, repair test truth afterwards | Rejected: it re-creates the exact failure mode the audit found — landing owner-mandatory work behind gates that structurally cannot detect its regression. F-01 itself was landed and then silently removed under precisely this ordering. |
| C. Straight to Human Novice Proof (protocol is already prepared) | run Horizon B now; treat machine debt as post-Human repair input | Rejected and forbidden: the capsule's Human QA Boundary states Human QA may not be moved earlier to compensate for unresolved product proof; a Human session run over a route with an unguarded canonical contract surface wastes the single most expensive evidence source. |

### 1.5 Unresolved ownership / evidence questions carried into Pass 2

| # | Question | Why it materially changes the campaign |
| --- | --- | --- |
| Q1 | Does F-16 actually hold closed at `52034abb`, or is the blocking family still red? | Decides whether the campaign opens with a repair packet or an admission packet; changes packet order and PR count. |
| Q2 | How many test files carry dead `lib/` imports at head, and does the audit's "125" still hold? | Sizes PHP-2/PHP-3, their PR ceiling and salvage boundary. |
| Q3 | Is the Wave 3.10 Street Replay reveal (F-01) still absent at head? | Decides whether PHP-5 exists at all. |
| Q4 | Is the proof-hero motion reveal still unguarded (F-02)? | Decides PHP-5's guard scope. |
| Q5 | Does any *automatic* lane run `test/ui_v2` / `test/guards` in full at head? | Decides whether PHP-4 exists and whether it can land green. |
| Q6 | Is the W6 promise/checkpoint/bridge debt (rescore Wave-4 admission) still open? | Decides whether a content packet must enter the campaign. |
| Q7 | Did the F-16 closure weaken any assertion to make a lane green? | Decides whether an independent non-weakening review packet is required. |
| Q8 | What does the full `test/ui_v2` + `test/guards` run actually report at head, separated into compile failures and assertion failures? | Decides the true size of the guard-lane debt and whether any *canonical* contract other than F-16 is red. |

---

## 2. Pass 2 — targeted verification at `52034abb`

Only the seven Pass-1 questions were investigated. No broad source sweep was
performed, and no capability already strongly proven closed (content census,
telemetry/privacy, canonical route ownership, Node 4 visual closure, frozen
surfaces) was re-inspected.

| # | Verification executed | Result | Campaign consequence |
| --- | --- | --- | --- |
| Q1 | `flutter test` over all 8 F-16 files (`act0_instruction_content_policy_v1`, `act0_wave1_canonical_correctness_trust_v1`, `act0_w4_w5_band_transition_milestone_v1`, `act0_repair_outcome_consumer_v1`, `act0_w9_w10_internal_world_source_template_batch_v1`, `act0_sharky_improvement_observation_v1`, `session_result_world1_onboarding_payoff`, `act0_visual_ux_known_p1_copy_contract`) | **PASS — 62/62, "All tests passed!"** including "one repair yields at most one acknowledgement" and "known P1 Visual UX copy stays bounded and unambiguous" | **F-16 is CLOSED_FIXED and now independently verified at head.** The audit's blocking family no longer blocks. Campaign opens at guard-lane truth, not at F-16 repair. |
| Q2 | `grep -rl` over the 9 removed `lib/` paths, restricted to `test/**/*_test.dart` | **145 files** at head (audit reported 125 on `4563ce2d`; the audit counted compile-failing files from a broad run, this counts importers of the 9 named paths — both figures are real, measured differently) | PHP-2 is sized against 145 files, not 125. Batching is mandatory; single-window closure is not credible. |
| Q3 | `grep -rn "act0_shell_street_replay_step" lib/` | only `act0_lesson_runner_shell_v1.dart:15151` → `Key('act0_shell_street_replay_step_$index')`, **no motion wrapper** | **F-01 confirmed still open at head.** PHP-5 exists. |
| Q4 | `grep -rlo` for `act0_shell_session_summary_proof_hero_motion_reveal` across `lib/` and `test/` | present in `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`; the only `test/` hit is `test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart`, which is **not** a `_test.dart` file and is executed by no lane | **F-02 confirmed still open at head.** PHP-5 must add real guards, not repoint an inert backlog file. |
| Q5 | `grep "flutter test"` across `.github/workflows/*`; header inspection of `unit-tests-nightly.yml` and `full-tests-manual.yml`; lane inspection of `tools/fast_loop_world1_v1.sh` / `release_gate_world1.sh` | required `ci.yaml` runs `test/l2_*`, `test/l3_*`, `packs_manifest_test.dart`, validators, `analyze` only. The two workflows that do run `flutter test --coverage` (whole suite) are **`workflow_dispatch`-only** — they never fire automatically. Tools lanes are path-regex selected. | **Q5 answered: no automatic lane runs these directories.** PHP-4 exists and is justified; because 145 files cannot compile, PHP-4 cannot land green before PHP-2/PHP-3, which fixes the campaign order. |
| Q6 | `docs/_reviews/w1_w12_known_deferred_debt_burn_and_closure_v1.md` rows KD-W2…KD-W6 + source read of `_rangeThinkingFoundationLessons` at `act0_shell_state_v1.dart:5512` | W6 now owns **five** lessons (`_rangeThinkingLiteLessons[0..4]`, i.e. including `range_combo_counts` and `range_thinking_checkpoint`); guarded by `test/guards/w1_w12_known_deferred_debt_burn_contract_test.dart` | **KD-W6 / rescore Wave-4 admission is CLOSED_FIXED.** No content packet enters the campaign. |
| Q7 | Read of the F-16 adjudication ledger against topology-map §7 (contract verdict required, no assertion relaxation) | 7 of 12 items closed as `STALE_TEST` with test-side edits. The ledger argues non-weakening for #12 (adds one forbidden-copy assertion) and documents the shared-segmenter isolation for #1/#2, but **no independent reviewer has re-derived the other five `STALE_TEST` verdicts.** | A bounded independent non-weakening review is required. It becomes **PHP-1**, and it is cheap (read-only + focused re-assertion). |
| **Q8** | `flutter test test/ui_v2 test/guards` executed in full at `52034abb` (13 min 21 s, single run) | **1810 passed / 239 failed.** Decomposed: **128 files fail to load (compile)** and **111 assertion-level test failures across 53 distinct files.** The audit's `4563ce2d` figure was 1797/250 with the failures attributed as "238 compile errors + 12 canonical assertion failures" — **that attribution does not survive re-measurement.** Compile failures are file-scoped (128), and assertion failures are an order of magnitude more numerous than the 12 the audit isolated. Most of the 53 files are legacy-owner families (`session_drill_player_*`, `modern_table_*`, `map_*`, `world1_*` map/runner guards, `today_plan_*`, `universal_intake_*`), but **at least 10 sit on canonical or canonical-adjacent Act0 surfaces** — see §2.3. | **Materially reshapes the campaign.** A triage packet (**PHP-0**) is inserted ahead of everything, because bulk-archiving the legacy corpus (PHP-2) before adjudicating these red guards could delete the only evidence of a real regression. The `PRE_HUMAN_READY` definition gains a zero-canonical-assertion-failure condition. |

### 2.1 Canonical and canonical-adjacent red guards at head (Q8 detail)

Ownership is **not** adjudicated here — that is PHP-0's DoD. What is established
is that each of these is red at head and executed by no automatic lane.

| Test | Failing assertion | Why it matters |
| --- | --- | --- |
| `test/ui_v2/compact_decision_integrity_repair_v1_test.dart` | "short table-read instruction composes its teaching copy with Continue without moving the table" — `find.textContaining('Same scan, different spot.')` found **0** widgets, with the no-scroll-view assertion still in force | Act0-canonical compact learning rail. The copy is authored at `act0_shell_state_v1.dart:10740` and is **not in the widget tree at all**. See F-18: this is on the exact seam PR #51 changed. |
| `test/guards/phone_first_premium_polish_v4_contract_test.dart` | "Home and Learn keep one hero while secondary modules stay quiet"; "Summary, feedback, and actions own purposeful premium moments" | This is the **W1W6-DLR-003 emphasis-competition claim with a red guard.** DLR-003 moves from "unconfirmed, needs visual evidence" to "evidenced by a failing contract." |
| `test/ui_v2/ui_v2_accessibility_touch_contract_test.dart` | file-level failure | The accessibility touch contract is **red**, which directly contradicts treating accessibility as a passing dimension. |
| `test/ui_v2/sharky_visual_consistency_foundation_v1_test.dart` | "correct feedback Sharky mascot uses the rounded-square family, not a circle" | Sharky visual identity contract red on a feedback surface. |
| `test/ui_v2/wave4_5_motion_evidence_repair_feel_v1_test.dart` | "repair surfaces share one calm repair proof system" | Motion/ceremony contract red on the repair surface — adjacent to F-01/F-02. |
| `test/guards/w10_to_w11_transition_policy_contract_test.dart` | "W10 to W11 transition policy enables handoff without W12 or W13 unlock" | Terminal/progression policy guard red. Note the audit separately re-confirmed no `world_13` token in state, so this is a policy-contract question, not a proven W13 leak. |
| `test/guards/targeted_content_repairs_contract_test.dart` | W11/W10 route copy overcertainty; W5 texture observational-not-deterministic | Content-claim-safety guards red. |
| `test/guards/early_world_feedback_quality_family_contract_test.dart` | canonical corrective feedback across world2/world1/world3/world6 families; shared-seam fail surfacing | Feedback-quality family guards red (families named here are the legacy session-drill families, so ownership adjudication is essential before any product claim). |
| `test/guards/phase_7_closure_audit_contract_test.dart` | "capsules advance to Phase 8 without opening forbidden scopes" | A *documentation/scope* guard reading the capsules; likely stale after this campaign's capsule edits, but must be adjudicated, not assumed. |
| `test/ui_v2/session_summary_gold_containment_v1_test.dart`, `test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart`, `test/guards/showable_spine_handoff_coherence_contract_test.dart`, `test/guards/canonical_surface_reachability_contract_test.dart` | various | Named because their titles claim canonical or premium-identity scope; ownership unadjudicated. |

### 2.2 Broad reads deliberately avoided

- `graphify-out/GRAPH_REPORT.md` and the generated wiki (navigation only; nothing in the campaign turns on graph topology).
- The 92-file Act0 owner set and `act0_lesson_runner_shell_v1.dart` in full (~15k lines): only two exact line anchors were read.
- 460 `_test.dart` files in `test/ui_v2` + `test/guards`: file-level classification only, no per-file reading.
- The remaining ~55 `docs/plan/*.md` and ~250 `docs/_reviews/*.md` artifacts not named in §1.1.
- The 59 `output/` evidence trees (two directory listings and one `.result` file only).
- Content corpus and census re-derivation: **not repeated** — independently reproduced by the audit at `4563ce2d` and unchanged by PR #50–#52 in any assessed row (fingerprint `1318f99a…` unchanged, re-adjudicated in the F-16 ledger).
- Modern Table sources and visuals: untouched by design (permanent Maintenance Mode; no exact-head regression evidence exists to justify reopening).

### 2.3 Estimated quota saved

Pass 1 consumed roughly **180 KB of admitted authority text** plus eight
targeted verifications (seven cheap; one 13-minute full-lane run whose token
cost was ~1 KB of extracted summary out of a 2.6 MB log). A conventional "read the review corpus, then sweep the
source" approach for the same question set would have consumed the Master Plan
in full (81 KB), `GRAPH_REPORT.md`, the ~300 planning/review artifacts, and the
Act0 owner set — conservatively **8–12×** the input volume, with the same seven
decisions. Targeted verification also replaced an estimated three to five
speculative packets (an F-16 repair packet, a content packet for W6, a
Sharky-removal recovery packet, and a "restore 125 imports" packet) with two
real ones — while the one deliberately expensive check (the full lane) found the
two findings no document-only pass could have found. **Estimated saving: ~85% of
input tokens and ~4 packet-sized execution windows**, with the residual budget
spent exactly where prior evidence was structurally blind.

---

## 3. Current state summary — what is machine-proven, what is missing

### 3.1 Machine-proven at `52034abb`

- Canonical route ownership traced end to end; debug/harness routes release-gated and actively guarded.
- Content census: 291 assessed tasks / 466 incorrect options / distribution 121-165-5, zero-and-one-option rows absent, 20 concept-error ids, 277/291 different-signal repair coverage, 14 allowlisted exact replays.
- Telemetry/privacy: deterministic rule-based only, no ML, no remote AI, no Act0 network consumer, no raw board-card or table-signal projection, schemas unchanged, local-only sink.
- Visual/UX: no open Act0 visual P0/P1/P2; compact/standard/tall-large phone coverage, enlarged Dynamic Type, CTA reachability, feedback/recheck hierarchy, Review/Practice/Session-Summary lifecycle, W11/W12 terminal presentation.
- Frozen surfaces intact: Modern Table, PR #44 feedback/recovery family, Review/Practice lifecycle, Session Summary.
- **F-16 (the audit's blocking family): closed and independently re-verified — 62/62 at head.**
- Waves 3.11–3.15 `CLOSED_PROVEN`; W6 promise/checkpoint/bridge closed and guarded.

Two caveats attach to this list. First, every visual/accessibility statement in
it rests on **selected-lane** evidence, and §2.1 shows that the accessibility
touch contract, the Sharky visual-identity contract, and the Home/Learn hero
contract are red in the *unselected* set. Second, "no open visual P0/P1/P2" was
established by Node 4 against the same selected lanes. Neither statement is
withdrawn — both were true against the evidence used — but both are now
**bounded by PHP-0's adjudication**, and this campaign does not repeat them as
unqualified closure.

### 3.2 Human evidence still missing (nothing below can be machine-closed)

- Whether a real novice comprehends the product in seconds, unaided.
- Whether wrong-answer feedback reads as a *named missed clue* rather than "wrong".
- Whether the repair → original-source recheck → recovered payoff loop is felt as repair rather than repetition.
- Whether the product reads as premium in the first 30 seconds.
- Whether motion/ceremony reads as earned rather than decorative.
- Whether any learning effect survives the session (learning-effect validation).
- Real-device accessibility behavior (screen reader, real Dynamic Type, real touch targets).

### 3.3 Machine-open at head (the whole of Horizon A)

| Item | Verified evidence | Packet |
| --- | --- | --- |
| **111 assertion-level test failures across 53 files**, ≥10 on canonical or canonical-adjacent Act0 surfaces (compact instruction rail, accessibility touch, Sharky visual identity, repair-feel motion, Home/Learn hero emphasis, W10→W11 policy, content claim safety) | Q8, §2.1 | **PHP-0** |
| Compact teaching-copy absence reproduced at head, **causation and owner unproven** | Q8 + PR #51/#52 diff scope | **PHP-0** |
| No automatic lane compiles/runs `test/ui_v2` or `test/guards` | Q5 | PHP-4 |
| 145 `_test.dart` files import removed `lib/` paths | Q2 | PHP-2, PHP-3 |
| Wave 3.10 Street Replay reveal absent | Q3 | PHP-5 |
| Proof-loop motion moments 2–4 unguarded | Q4 | PHP-5 |
| Five `STALE_TEST` verdicts not independently re-derived | Q7 | PHP-1 |
| Learn/Home primary-CTA emphasis unproven (W1W6-DLR-003) | Pass 1 (ledger) | PHP-7 |
| Sharky state/growth reachability not proven as one contract | Pass 1 (owner decision OD-03) | PHP-6 |
| No W2 capture lane; milestone-state capture anomaly | Pass 1 (F-13, MOT-03) | PHP-8 |

---

## 4. Horizon A — machine-proven pre-Human closure

Terminal state: **`PRE_HUMAN_READY`**

Definition of `PRE_HUMAN_READY` (all must hold simultaneously at one exact head):

1. no open canonical Act0 P0/P1/P2 finding in the §7 appendix;
2. every owner-mandatory pre-Human visual, motion, Sharky, accessibility, screen-role, and terminal-state finding is `CLOSED_PROVEN`, `CLOSED_FIXED`, `DISPROVED`, or explicitly `BLOCKED_OWNER_DECISION` with the decision named;
3. an automatic lane compiles and runs `test/ui_v2` and `test/guards` in full, with an empty quarantine ledger;
4. **zero assertion failures remain on any test adjudicated as owning a current canonical Act0 contract** — every one of the 111 assertion failures measured in Q8 carries an explicit ownership verdict, and every canonical-owned one is green;
5. every rubric dimension in §6 that is not Human-bound has an evidence-backed score and a named guard;
6. the campaign state document records the exact head, the exact validation set, and the Human evidence still missing.

### 4.1 Stage hierarchy and packet sequence

**Pre-Human Node 5 — Canonical Contract and Test Authority Restoration** remains
the umbrella capability named by the active route authorities. PHP-0 through
PHP-4 are its **operational sub-packets, not a competing peer phase**. The
historical Master Plan sequence is not rewritten; exact-head remeasurement
decomposed Node 5's execution without changing its product purpose and without
reopening any previously closed capability.

```
Pre-Human Node 5 — Canonical Contract and Test Authority Restoration  (umbrella)
├── PHP-0  Canonical-Adjacent Red-Guard Triage
├── PHP-1  Confirmed Canonical Guard Repair
├── PHP-2  Legacy Corpus Ownership Disposition
├── PHP-3  Canonical Test Classification and Manifest
└── PHP-4  Canonical Full-Lane CI Authority

Remaining Horizon A capabilities (outside Node 5, ordered after it)
├── PHP-5  Premium Motion & Ceremony Completion
├── PHP-6  Sharky Production Integration & Completeness Proof
├── PHP-7  Screen-Role & Visual-Hierarchy Emphasis Proof
├── PHP-8  Evidence & Accessibility Lane Completeness
└── PHP-9  PRE_HUMAN_READY Admission
```

| Packet | Stage | Name | Owner families (≤2) | PR range | Quota ceiling | Order rationale |
| --- | --- | --- | --- | --- | --- | --- |
| **PHP-0** | Node 5 | Canonical-Adjacent Red-Guard Triage | test authority; Act0 instruction/compact owner | 1 (2 only if a proven repair cannot share the PR) | medium | **Must run first.** PHP-2 disposes of the legacy corpus; running it before ownership adjudication could archive away the only evidence of a current canonical contract. PHP-0 also carries F-18, whose causation is unproven and must be settled before anything is built on it. |
| **PHP-1** | Node 5 | Confirmed Canonical Guard Repair | test authority; named canonical Act0 owners | 1–2 | small–medium | Repairs only what PHP-0 *proved* canonical, and re-derives the seven F-16 `STALE_TEST` verdicts. Cannot be scoped before PHP-0's terminal classification. |
| **PHP-2** | Node 5 | Legacy Corpus Ownership Disposition | test authority; archive boundary | 1–2 | large (mechanical, batched) | Unblocks PHP-4. Must follow PHP-0's contract preservation. |
| **PHP-3** | Node 5 | Canonical Test Classification and Manifest | test authority; canonical Act0 owners | 1 (may be a no-op) | small–medium | Publishes the canonical test manifest PHP-4 gates on; extracts any unique contract found inside an archived-owner file. |
| **PHP-4** | Node 5 | Canonical Full-Lane CI Authority | CI/workflow | 1–2 | small–medium | Can only land green after PHP-2/PHP-3. Closes the root cause. |
| **PHP-5** | — | Premium Motion & Ceremony Completion | Act0 lesson-runner motion | 1 | small | Owner-mandated pre-Human block. Sequenced after PHP-4 so its new guards run in a lane that actually executes. |
| **PHP-6** | — | Sharky Production Integration & Completeness Proof | Sharky presence/state seam | 1–2 | small–medium | Owner-mandated pre-Human block. Direction is supplied (§5 OD-03b); scope is integration, not exploration. |
| **PHP-7** | — | Screen-Role & Visual-Hierarchy Emphasis Proof | Act0 Learn/Home shell | 1–2 | small | Last open P2-class learner-facing proof; may close as a nonissue. |
| **PHP-8** | — | Evidence & Accessibility Lane Completeness | evidence tooling | 1–2 | small–medium | Reviewer-friction and Human-session prerequisites. |
| **PHP-9** | — | `PRE_HUMAN_READY` Admission | campaign docs | 0–1 | small | Publication only. Should ride with the last capability PR where safe. |

### 4.1.1 PR compression rule

**16 PRs is a hard emergency ceiling, not a delivery target.** Compression is
mandatory, and it is bounded by ownership:

- **Eliminate** any packet that triage proves unnecessary — PHP-3 becomes a no-op if PHP-3's carrier list is empty; PHP-7 may close on its first proof; PHP-1 shrinks to a verdict table if PHP-0 finds no canonical regression.
- **Merge** only tightly coupled owner work.
- **Do not create standalone docs-closure PRs** when the artifact can safely accompany the capability PR that earned it.
- **Never split** one coherent owner fix merely to satisfy a packet template.
- **Never combine** unrelated owners to reduce PR count. A lower PR number bought with mixed ownership is a worse outcome than a higher one.

| Scope | Target PR range | Hard ceiling |
| --- | --- | ---: |
| Node 5 (PHP-0…PHP-4) | **~4–7** | 9 |
| Complete machine pre-Human horizon (PHP-0…PHP-9) | **~8–12** | **16** |

The full 16 is reachable only when exact evidence forces the maximum split —
for example if PHP-0 proves several distinct canonical owners regressed, or if
PHP-3 finds many carrier contracts in different owner families.

### 4.1.2 First autonomous window

The first executable window is **PHP-0 only.**

It may include one bounded product or test repair **in the same PR** only when
all of the following hold:

1. F-18 or another finding is **causally proven** by PHP-0's own evidence;
2. exactly one current owner family is involved;
3. no new architecture or product meaning is introduced;
4. the repair fits inside PHP-0's quota;
5. exact-head focused tests and required CI are green.

PHP-0 must **stop at a campaign gateway**. PHP-1 and PHP-2 are **not
pre-authorized** and may not begin before PHP-0 publishes its terminal
classification.

After PHP-0, a later window may carry up to **two merged PRs** when the next
owners are already known, no independent gateway intervenes, exact-head CI is
green, and the campaign state file explicitly authorizes the next packet. After
a gateway, the campaign state may explicitly authorize a bounded multi-PR wave.
PHP-3 Wave 1 is the current exception, capped at three sequential extraction
PRs with one PR open at a time; this exception does not automatically apply to
future packets.

### 4.2 Packet definitions

#### PHP-0 — Canonical-Adjacent Red-Guard Triage  *(Node 5)*

- **Findings addressed:** F-17 classification (all 53 files), F-18 causation, the ownership half of W1W6-DLR-003, A11Y-01 red contracts, SHK-VIS-01, MOT-04.
- **Executable DoD — part 1, F-17 classification.** Every one of the **53** assertion-failing files receives **exactly one** classification:

  | Label | Meaning |
  | --- | --- |
  | `CURRENT_CANONICAL_REQUIRED` | owns a current canonical Act0 contract; must be green |
  | `CURRENT_CANONICAL_STALE_ASSERTION` | canonical surface, but the assertion encodes a retired expectation |
  | `ACTIVE_NONBLOCKING` | current owner, real but non-blocking scope |
  | `ARCHIVED_NONCANONICAL` | archived/dormant owner; disposition belongs to PHP-2 |
  | `QUARANTINED_WITH_OWNER` | cannot be settled in this window; named owner recorded |
  | `UNRESOLVED_UNIQUE_CONTRACT` | may carry a unique current contract that exists nowhere else |

  Severity is **never** inferred from assertion count. **No file may be archived, deleted, or repointed in this packet** — PHP-0's job is to *preserve* every potentially current unique contract, not to dispose of anything.

- **Executable DoD — part 2, F-18 causation.** In this exact order:
  1. reproduce at `52034abb`;
  2. test at `4563ce2d`;
  3. test the smallest relevant commit interval around PR #51;
  4. record exactly one terminal verdict: `PRODUCTION_REGRESSION`, `STALE_TEST`, `FIXTURE_OR_ROUTE_MISMATCH`, or `RETIRED_CONTRACT`;
  5. identify the exact owner **before** any repair.

  **A production repair is authorized only after causation and ownership are proven.** Until then F-18 stays `OPEN_REPRODUCED` / `CAUSATION_UNPROVEN` and must not be described as a PR #51 regression.

- **Required evidence:** the 53-row classification table (one label each); the F-18 four-step evidence trail with all commit/outcome pairs and the terminal verdict; the eight F-16 files still green; `flutter analyze`; `git diff --check`; explicit statements that no assertion was relaxed, no file was archived or repointed, and no legacy owner was revived.
- **Salvage boundary:** the classification table is publishable row by row; the F-18 evidence trail stands alone and is the single highest-value output.
- **PR shape:** **1 PR.** A second is admitted only when a causally proven repair genuinely cannot share it.
- **Terminal gateway:** PHP-0 stops on publication. It does not authorize PHP-1 or PHP-2.
- **Fit test:** two coupled families (test authority; Act0 instruction/compact owner — coupled because F-18 lives at their seam); DoD needs no owner decision; one window; 53 files is bounded because the unit of work is one label per file, not one repair per file.
- **Explicitly out of scope:** the 128 compile failures, any archiving, any new accessibility or visual assertion, and any repair whose causation is unproven.

#### PHP-1 — Confirmed Canonical Guard Repair  *(Node 5)*

- **Findings closed:** the `CURRENT_CANONICAL_REQUIRED` and `CURRENT_CANONICAL_STALE_ASSERTION` subsets PHP-0 proved, plus the F-16 verification debt (Q7).
- **Precondition:** PHP-0's terminal classification is published. This packet **cannot be scoped in advance** — its size is exactly what PHP-0 proved canonical.
- **Executable DoD:**
  1. For every `CURRENT_CANONICAL_REQUIRED` file, repair the **production owner** so the contract is green. Do not relax an assertion to make a lane green.
  2. For every `CURRENT_CANONICAL_STALE_ASSERTION` file, correct the assertion to the current contract and record the retiring commit plus the current replacement contract — per topology-map §7 this requires an explicit contract verdict, never a deletion of convenience.
  3. Re-derive the seven F-16 `STALE_TEST` verdicts (#4, #5, #6, #7–9, #11, #12) independently, publishing `NON_WEAKENING` or `WEAKENED` per item; restore any weakened assertion against the current production owner.
- **Required evidence:** per-item repair/verdict table; every touched contract green; all eight F-16 files green; `flutter analyze`; explicit no-relaxation statement.
- **Salvage boundary:** each repair and each F-16 verdict is independently publishable.
- **Fit test:** two coupled families; no owner decision (topology map §7 supplies the rule); 1–2 PRs. **If PHP-0 proves more than two distinct canonical owner families regressed, this packet must be split by owner family before publication.**

#### PHP-2 — Legacy Corpus Ownership Disposition  *(Node 5)*

- **Findings closed:** F-15, plus the `ARCHIVED_NONCANONICAL` subset of F-17.
- **Precondition:** PHP-0 published, and every `UNRESOLVED_UNIQUE_CONTRACT` and `CURRENT_CANONICAL_*` file is excluded from disposition here.
- **Executable DoD:** for the **145** dead-import `_test.dart` files plus the `ARCHIVED_NONCANONICAL` files PHP-0 hands over, dispose by **ownership, not by compilation**. Remove or relocate under the archive boundary. Making a broad directory command green is not a goal, and green compilation is not evidence of contract ownership. **No dormant runner, archived Modern Table owner, or legacy progression system may become active authority through this packet** — repointing an import at `lib/archive/legacy_runners/` to make a file compile is explicitly forbidden as a closure method.
- **Required evidence:** one ledger line per file; before/after dead-import count (`grep -rl` over the 9 removed paths restricted to `_test.dart`); proof that no `lib/archive/` path gained a new active test importer; `flutter analyze`; pre-existing selected lanes still green.
- **Batching:** ≤50 files per PR, each batch independently green.
- **Salvage boundary:** a completed batch is independently valuable; unprocessed ledger rows carry forward verbatim.
- **Fit test:** two coupled families (test authority, archive boundary); no owner decision; 1–2 PRs; mechanical.

#### PHP-3 — Canonical Test Classification and Manifest  *(Node 5)*

##### Execution update — 2026-07-26: PHP-3 Wave 1 authorization reconciliation

The original one-PR estimate assumed the unique-contract set might be small or
empty. Published PHP-2/PHP-3 evidence instead establishes 77 original handoffs,
3 admitted carriers, 74 unresolved carriers, and multiple distinct owner
families. The original estimate is therefore no longer operationally valid.

PHP-3 Autonomous Layered Closure Campaign — Wave 1 is explicitly authorized
for up to three sequential extraction PRs, with only one PR open at a time.
Each PR must reconcile to the latest admitted `origin/main`, use
owner-homogeneous families, satisfy required exact-head CI before merge, and
target at least eight carrier admissions for a normal later-family PR. The
Wave-1 no-weakening and circuit-breaker rules remain mandatory.

This evidence-driven batching correction does not authorize PHP-4, alter the
product roadmap, reopen Modern Table, permit visual, Motion, Sharky, native, or
Human scope, or allow mixed-owner batches merely to reduce PR count.

- **Findings closed:** the `UNRESOLVED_UNIQUE_CONTRACT` subset of F-17; F-15 remainder.
- **Executable DoD:**
  1. For each `UNRESOLVED_UNIQUE_CONTRACT` file, determine whether it carries a current contract that exists nowhere else. If it does, extract that contract into an owner-aligned focused test against the **current production owner** and drop the archived-owner dependency — do not repoint to the archive. If it does not, reclassify it to `ARCHIVED_NONCANONICAL` with the duplicate active guard named.
  2. Publish the **canonical test manifest**: the explicit set of test paths that constitute canonical contract authority, which PHP-4's lane gates on.
- **Required evidence:** per-file mapping (file → contract → new test or named duplicate → current owner); the manifest; each new test green; dead-import count **0**; no new `lib/archive/` importer.
- **Salvage boundary:** one extracted contract per commit; the manifest is publishable independently.
- **Fit test:** two coupled families; 1 PR; **may close as a no-op** (`NO_UNIQUE_CONTRACT_FOUND`) if PHP-0/PHP-2 leave the set empty. If more than ~10 files carry unique contracts across different owner families, split by owner family first.

#### PHP-4 — Canonical Full-Lane CI Authority  *(Node 5)*

- **Findings closed:** the root cause behind F-01, F-02, F-15, F-16, F-17, F-18.
- **Precondition:** PHP-3's canonical test manifest is published, and PHP-2 has disposed of the archived corpus. A full-lane gate cannot land green before both.
- **Executable DoD:** add one automatic lane that (a) compiles and (b) runs `test/ui_v2` and `test/guards` in full on every PR touching `lib/**` or `test/**`, gating on PHP-3's canonical test manifest, with a machine-readable quarantine ledger that must be **empty** at packet close. The lane must fail on a compile error, not skip it. `workflow_dispatch`-only workflows do not satisfy this DoD — `unit-tests-nightly.yml` and `full-tests-manual.yml` already run the whole suite and are exactly why this gap survived: neither ever fires automatically. Measured baseline for runtime budgeting: the full local run is **13 min 21 s** for 2049 tests.
- **Required evidence:** workflow diff; one green run on a real PR; one deliberately induced failure proving the lane fails red (an intentionally broken import and an intentionally failing assertion, both reverted in the same PR); recorded wall-clock runtime; quarantine ledger empty.
- **Salvage boundary:** the compile-integrity half can land before the full-assertion half; both halves are separately meaningful.
- **Fit test:** one owner family; 1–2 PRs; no owner decision; runtime cost is the only real risk and is measured in the DoD.

#### PHP-5 — Premium Motion & Ceremony Completion

- **Findings closed:** F-01, F-02, W3.10 remainder, GR-11/GR-14 motion half.
- **Executable DoD:** restore the Street Replay reveal using the existing shared local proof-reveal wrapper and existing `Act0MotionTokensV1` duration/easing tokens; re-establish `Key('act0_shell_street_replay_step_motion_$i')`; add active `_test.dart` guards for proof-loop motion moments 2, 3, and 4 (including `act0_shell_session_summary_proof_hero_motion_reveal`); preserve the structural reduced-motion bypass; prove state does not replay on rebuild and the CTA is tap-safe mid-motion.
- **Required evidence:** widget tests for all four moments; reduced-motion bypass test; `MediaQuery.disableAnimations` contract preserved; the PHP-4 lane green; explicit statement that no new asset, dependency, table motion, replay playback renderer, Modern Table change, or telemetry change was introduced.
- **Salvage boundary:** guards for moments 2–4 are landable independently of the F-01 restoration and are the higher-durability half.
- **Fit test:** one owner family; one PR; no owner decision (the motion system, tokens, and reduced-motion contract are all already admitted).

#### PHP-6 — Sharky Production Integration & Completeness Proof

- **Findings closed:** GR-16 integration half, SHK-STATE-01, SHK-EVID-01, SHK-ANIM-01 (integration-ready portion), VIS-DEC-03 (integration-ready portion).
- **Owner-decision position:** the visual direction is **supplied** — refined C, `SHARKY_VISUAL_LOCK_V1` (§5 OD-03b). No direction exploration is reactivated. What remains is production integration, not selection.
- **Executable DoD:**
  1. Prove as one contract that every admitted Sharky state and both growth stages (`Act0SharkyCoachTierV1{foundation,developing}`, `Act0SharkyGrowthStageV1`) are reachable on the canonical route and guarded, and that the presence/mascot key families resolve at runtime rather than only as literal prefixes.
  2. Prove same-character continuity across Product/Progress registers and small-size identity at the 16 dp mark and 34 dp valence sizes.
  3. Prove reduced-motion behavior for every Sharky presence surface.
  4. Close the recorded deterministic-capture gaps for Developing, improve, and milestone.
  5. Complete fallback migration **only** for rows whose approved production-ready asset exists; rows requiring absent art are recorded `EXTERNAL_ASSET_INPUT_REQUIRED` and are not faked with placeholder art.
- **Required evidence:** state-reachability matrix (state → route point → key → guard); continuity and small-size identity assertions; reduced-motion assertions; three new deterministic captures; explicit per-row statement of which rows were integration-complete and which remain `EXTERNAL_ASSET_INPUT_REQUIRED`.
- **Constraint:** no new art is generated in this packet, no mascot concept is created, no direction is re-litigated, and no Modern Table change is made.
- **Salvage boundary:** the reachability matrix is valuable without the captures; each capture and each proof is independent.
- **Fit test:** one owner family; 1–2 PRs; needs no owner decision because the direction is already supplied and asset-absent rows are explicitly deferred rather than guessed.

#### PHP-7 — Screen-Role & Visual-Hierarchy Emphasis Proof

- **Findings closed:** W1W6-DLR-003; screen-role differentiation rubric dimension.
- **Precondition:** PHP-0 has adjudicated `phone_first_premium_polish_v4_contract_test` ("Home and Learn keep one hero while secondary modules stay quiet"), which is **red at head** and is the same claim as DLR-003. If PHP-0 finds it `CANONICAL_ACT0_CONTRACT` + `PRODUCTION_REGRESSION`, the repair lands in PHP-0 and this packet becomes the proof-and-role-distinctness half only.
- **Executable DoD:** add one compact-portrait (360×640) proof that the Learn/Home mission-card CTA is the single highest-emphasis element against competing `Now` / `Current lesson` / `Current step` / progress labels. **Do not redesign.** If the proof fails, the only admitted repair is copy, order, or emphasis adjustment inside the existing Act0 Learn/Home shell files — no layout rebuild. Additionally assert that Home, Learn, Review, Practice, Profile, and Session Summary each present a distinct primary role element (screen-role differentiation), reusing existing role/coherence guards.
- **Required evidence:** the compact-portrait assertion; if repaired, before/after emphasis evidence; the six-surface role-distinctness assertion; frozen-surface statement.
- **Salvage boundary:** the proof is publishable even when it fails — a failing proof converts DLR-003 from unconfirmed to confirmed with a bounded repair, which is itself progress.
- **Fit test:** one owner family; two PRs (proof, then conditional bounded repair); no owner decision.

#### PHP-8 — Evidence & Accessibility Lane Completeness

- **Findings closed:** F-13, F-14, MOT-03, accessibility rubric machine delta.
- **Precondition:** PHP-0 has adjudicated `ui_v2_accessibility_touch_contract_test`, which is **red at head**. A named accessibility lane that is red on arrival is worse than no lane, so the contract must be green (or explicitly reclassified as legacy-owned) before it is promoted into a gate.
- **Executable DoD:** add the missing W2 capture lane to `screen_review_fast_v1.sh`; correct the F-14 Same-Session test title/comment wording; add one accessibility sweep lane that runs the existing a11y/touch/text-scale/semantics contracts as a named set (`ui_v2_accessibility_touch_contract`, `world1_a11y_semantics_contract`, `session_result_text_scale_contract`, compact-height and enlarged-text contracts) so accessibility has a single named gate rather than scattered files; record the milestone-state capture anomaly (`RenderRepaintBoundary.toImage()`) as a bounded tooling investigation with a reproduction, or close it if it no longer reproduces.
- **Required evidence:** W2 capture packet generated on the exact head; the a11y lane green with its file list recorded; the corrected test title; the anomaly reproduction or its disproof.
- **Salvage boundary:** all four items are independent; any subset is publishable.
- **Fit test:** one owner family (evidence tooling); two PRs; no owner decision. Note: this packet adds **no** new accessibility *assertion* — inventing new a11y contracts belongs to a future packet, not here.

#### PHP-9 — `PRE_HUMAN_READY` Admission

- **Findings closed:** none; publication only.
- **Executable DoD:** at one exact head, re-run the full validation set (PHP-4 lane, F-16 files, content/concept-error/answer-position guards, `flutter analyze`, tools lanes, `git diff --check`, `graphify hook-check`), refresh §6 rubric machine scores, refresh the §7 appendix verdicts, and record the exact head plus the Human evidence still missing. Emit `PRE_HUMAN_READY` **only** if all five §4 conditions hold; otherwise emit `PRE_HUMAN_BLOCKED` with the exact blocking IDs.
- **Required evidence:** validation table with exact results; updated appendix; updated rubric; explicit "Human Novice Proof NOT PERFORMED" statement.
- **Salvage boundary:** documentation only; no partial state is harmful.
- **Fit test:** one owner family; one PR; no source change.

### 4.3 Packet fit-test results

| Packet | ≤2 owner families | DoD free of owner decision | One window | No review gateway mid-implementation | Max PRs | Quota ceiling credible | Salvage boundary clear |
| --- | --- | --- | --- | --- | ---: | --- | --- |
| PHP-0 | ✅ 2 | ✅ | ✅ (~10 files) | ✅ | 2 | ✅ | ✅ per verdict; bisect standalone |
| PHP-1 | ✅ 1 | ✅ | ✅ | ✅ | 1 | ✅ | ✅ per item |
| PHP-2 | ✅ 2 | ✅ | ✅ batched | ✅ | 2 | ✅ | ✅ per batch |
| PHP-3 | ✅ 2 | ✅ | ✅ (conditional on PHP-2 output; split rule stated) | ✅ | 2 | ✅ | ✅ per carrier |
| PHP-4 | ✅ 1 | ✅ | ✅ | ✅ | 2 | ✅ runtime measured | ✅ two halves |
| PHP-5 | ✅ 1 | ✅ | ✅ | ✅ | 1 | ✅ | ✅ guards vs restore |
| PHP-6 | ✅ 1 | ✅ (art excluded) | ✅ | ✅ | 1 | ✅ | ✅ matrix vs captures |
| PHP-7 | ✅ 1 | ✅ | ✅ | ✅ | 2 | ✅ | ✅ proof standalone |
| PHP-8 | ✅ 1 | ✅ | ✅ | ✅ | 2 | ✅ | ✅ four items |
| PHP-9 | ✅ 1 | ✅ | ✅ | ✅ | 1 | ✅ | ✅ docs only |

Splits performed to pass the fit test:

- The audit's Node 5 was published as one packet with three parts. Part 2 alone is 145 files, and Part 3 cannot land green until Part 2 finishes. **Split into PHP-2, PHP-3, PHP-4.**
- The audit's superseded "Part A" bundled motion restoration with Sharky work under one ceremony heading. Motion tokens and the Sharky presence seam are different owners, and the Sharky art half is owner-blocked. **Split into PHP-5 and PHP-6.**
- F-16 verification was not a packet at all in the audit. It is now **PHP-1**, and it deliberately does not carry F-15 work despite sharing the test-authority owner, because 145-file classification would not fit the same window.
- The 111 assertion failures found by Q8 were unknown to every prior authority. They are **not** admitted as one packet: PHP-0 takes only the canonical-adjacent ~10 (bounded, decision-carrying), and the ~43 legacy-owner files flow into PHP-2's classification, where they belong by ownership. Bundling all 53 into one packet would fail the fit test on window size and would mix unrelated owner families.

No packet in this campaign uses one audit finding as justification for combining
unrelated systems. F-01, F-02, F-15, and F-16 share a root cause, but they are
four packets, not one.

---

## 5. Owner decisions in force (constraint table)

| ID | Decision | Source | Campaign effect |
| --- | --- | --- | --- |
| OD-01 | Human QA is the final external evidence gate; it cannot be simulated, claimed internally, or moved earlier to compensate for unresolved product proof | `ACTIVE_ROUTE_CAPSULE_v1.md` Human QA Boundary | Horizon B is planned, never executed by this campaign |
| OD-02 | Modern Table is in permanent Maintenance Mode | Master Plan; capsule | No table aesthetic/material item may be reopened without exact current regression evidence |
| OD-03 | Required Sharky integration **and** required motion/ceremony are mandatory pre-Human blocks | capsule `:38–42`; audit §11 | GR-11/14/16 are `DEFERRED_TO_LATER_PRE_HUMAN_PACKET`, **not** outside pre-Human; PHP-5 and PHP-6 are mandatory |
| **OD-03b** | **Sharky visual direction is SUPPLIED — `SHARKY_VISUAL_LOCK_V1` = refined C.** Canonical neutral base: compact premium pet-like shark companion; deep navy body; warm cream underside; restrained teal dorsal and tail tips; exactly three slightly irregular teal gill marks on character-left only; small soft asymmetric front crest / messy tuft; warm observant eyes; restrained asymmetric closed-mouth smile; no legs or feet; no humanoid anatomy; subtle aquatic suspension; compact collected silhouette. | owner decision, 2026-07-25 (supersedes the prior "blocked pending controlled board verdict" position) | **Supersedes `BLOCKED_OWNER_DECISION` for direction.** The Warm Compact / Balanced / Premium Iconic three-direction board, the serious-premium shark boards, the Route B/C/Hybrid selection, and any new mascot concept generation are **closed and must not be reactivated.** Remaining Sharky rows are reclassified in §7.5 as either `OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING` or `EXTERNAL_ASSET_INPUT_REQUIRED`. The direction decision does **not** block campaign planning. |
| **OD-03c** | Required Sharky **production integration**, same-character continuity, small-size identity, fallback migration, reduced-motion behavior, and deterministic evidence remain **mandatory before Human Novice Proof** | owner decision, 2026-07-25 | PHP-6 is mandatory in Horizon A; it is integration work, not exploration |
| **OD-03d** | **Unresolved contradiction to report, not to resolve unilaterally.** The supplied refined C specifies a "small soft asymmetric front crest / messy tuft". The existing owner-approved `sharky_canonical_character_package_v1_1` (`assets/design/sharky_character_v1/sharky_character_package_manifest_v1.json`, approval date 2026-07-13) names its rank-1 authority `sharky_canonical_3q_front_authority_v1_1` as the **"no-crest sole authority for canonical visual identity"**, and marks a visible crest in its side/back references as "a deprecated reconstruction inconsistency [that] never overrides the no-crest canonical 3/4 front". | this campaign's targeted verification of the asset manifest | **One owner confirmation is required** before any crest-bearing asset is produced or admitted: either refined C supersedes package v1.1 (which then needs a versioned replacement package per its own `replacementPolicy`), or the no-crest authority stands and the refined C crest clause is withdrawn. Recorded as **SHK-CREST-01** in §7.5. This does **not** block PHP-0…PHP-5, PHP-7, PHP-8, or campaign planning; it bounds only crest-dependent asset production inside PHP-6. |
| OD-04 | Tablet is deferred and non-blocking; phone acceptance is compact/tall/large | Master Plan device policy | Tablet findings are `OUTSIDE_PRE_HUMAN` |
| OD-05 | No monetization, paywall, or IAP work in the current wave | CLAUDE.md; Master Plan forbidden scope | No packet touches commerce |
| OD-06 | Deterministic, rule-based personalization only — no ML, no remote AI | Master Plan | Personalization rubric ceiling is bounded by design, not a defect |
| OD-07 | Store/Public Readiness stays delayed until excellence proof | Master Plan | Horizon B ends at a readiness *candidate*, not a store packet |
| OD-08 | W13–W36 expansion, RU rollout, hand import, dashboards, XP/economy are forbidden scope | capsule Current Forbidden Scope | Related findings are `OUTSIDE_PRE_HUMAN` |

---

## 6. 10/10 product rubric

Scoring rules:

- A numeric score requires named current evidence. Anything whose evidence is a real human observation is **`UNKNOWN`** and is never rendered as a high score.
- Where a dimension has both a machine half and a Human half, the machine half is scored and the Human half is stated as `UNKNOWN`; the dimension's terminal criterion requires both.
- Confidence is about the *evidence*, not the product: `HIGH` = independently reproduced at head; `MEDIUM` = admitted artifact plus at least one current check; `LOW` = single artifact, not re-derived.

| # | Dimension | Current score | Confidence | Remaining delta | Machine-closure packet | Human evidence required | Terminal acceptance criterion |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | Immediate comprehension | **UNKNOWN** (machine sub-result: entry route, primary CTA, and progress state are structurally present and reachable) | MEDIUM on the machine half | the entire felt half; PHP-7 removes the last machine ambiguity (CTA emphasis) | PHP-7 | HNP Profile A: participant identifies and begins the primary learning action with **no** directional or explicit assistance | ≥1 clean Profile A participant orients and starts unaided, and PHP-7's emphasis proof is green |
| 2 | Interaction reachability | **7 / 10** (was 9 on selected-lane evidence; lowered because the compact instruction rail is red at head — §2.1 F-18 — and the accessibility touch contract is red) | MEDIUM-HIGH | F-18 adjudication; real-device touch behavior unobserved | **PHP-0**, then PHP-8 | HNP: `REACHABLE_AND_DISCOVERABLE` classification on feedback/recommendation | no `PARTIALLY_OBSCURED`/`CTA_UNREACHABLE` at any observed checkpoint; compact/tall/large + enlarged-text contracts green **in the full lane** |
| 3 | Teaching clarity | **7 / 10** machine (teach-before-assess proven; leakage removed in W1/W2/W4/W5; 291-row census clean — but authored teaching copy is **missing from the compact widget tree** at head, and two content claim-safety guards are red) | MEDIUM | F-18; `targeted_content_repairs_contract_test`; template-phrasing residue (W1W6-DLR-005); felt clarity | **PHP-0** | HNP: participant restates the decision in their own words | participant states the task in own words at ≥2 checkpoints without coaching, and no teaching copy is absent on any supported viewport |
| 4 | Decision-feedback specificity | **9 / 10** | HIGH (F-16 #6 receipt copy verified at head) | felt causality | closed | HNP: participant names the missed clue, not merely "wrong" | participant names a clue at ≥1 naturally exposed wrong answer |
| 5 | Repair-loop value | **9 / 10** machine (one source outcome, one repair lifecycle, one original-source recheck, 277/291 different-signal coverage) | HIGH | felt repair value; durable value | closed | HNP: participant understands the repair, returns to source recheck, answers unaided | one clean repair→recheck observation with no supplied answer |
| 6 | Personalized relevance | **8 / 10** (three deterministic families: position, price, starting hand; personalized return reason live) | MEDIUM-HIGH | felt relevance; breadth is bounded by OD-06 by design | closed | HNP: participant explains what the suggested next step is for | participant describes the next step's purpose in own words |
| 7 | Learning payoff | **8 / 10** machine (learning-run payoff is the sole run-level lifecycle; recovered payoff only where earned; W1/W2–W6/band-transition/world-completion payoffs present) | MEDIUM-HIGH | **the entire durable half** | closed | Learning-effect validation (Horizon B, HB-5): a corrected point survives to a later comparable spot | participant articulates a learned/corrected point **and** a later comparable decision improves without coaching |
| 8 | Progression clarity | **8 / 10** (fresh route `0/9` truth preserved; unlock contract explicit; W6→W7 bridge closed and guarded) | MEDIUM-HIGH | felt sense of "where am I / what's next" | closed | HNP: participant explains the next step and the exit | participant states current position and next action at session end |
| 9 | Screen-role differentiation | **6 / 10** | MEDIUM-HIGH — upgraded from LOW: DLR-003's emphasis claim now has a **red guard** at head (`phone_first_premium_polish_v4_contract_test`: "Home and Learn keep one hero while secondary modules stay quiet") | the claim is no longer unconfirmed; it needs an ownership verdict and, if canonical, a bounded repair | **PHP-0**, then **PHP-7** | HNP: participant does not confuse Home/Learn/Review/Practice roles | red guard green or reclassified as legacy-owned, PHP-7 proof green, **and** no observed role confusion |
| 10 | Visual hierarchy & premium cohesion | **UNKNOWN** for felt premium; machine sub-result **7 / 10** (no open visual P0/P1/P2; layout contract clean at 4 viewports) | MEDIUM on the machine half; the merged 6.8–7.8 review band is **static-evidence judgment, not a machine score** | felt premium is the single largest UNKNOWN in the rubric | none admitted (visual redesign is not authorized) | HNP + a real Claude Design pass: does it read premium in 30 seconds | no serious unresolved premium-perception defect from a real observation; the merged review band is superseded by observed evidence |
| 11 | Purposeful motion & ceremony | **5 / 10** | HIGH (F-01/F-02 reproduced by direct grep; `wave4_5_motion_evidence_repair_feel_v1_test` "repair surfaces share one calm repair proof system" red at head) | one of four proof-loop moments missing; three of four unguarded; one repair-feel contract red | **PHP-0** (red guard), **PHP-5** | HNP: does the proof moment read as earned rather than decorative | four of four moments present and guarded, repair-feel contract green or reclassified, reduced-motion bypass proven, and no observed "decorative motion" complaint |
| 12 | Sharky product/emotional integration | **6 / 10** machine (broadly integrated across placement, Home, lesson runner, Review, Profile; six states + two growth stages contracted; acknowledgement idempotency verified at head — but `sharky_visual_consistency_foundation_v1_test` "correct feedback Sharky mascot uses the rounded-square family, not a circle" is **red**) | MEDIUM-HIGH | one red visual-identity contract; state-reachability not proven as one contract; three capture gaps; **art/animation direction owner-blocked** | **PHP-0** (red guard), **PHP-6** (machine half) | HNP: is Sharky supportive rather than noise, especially at repair | red guard resolved, reachability matrix green, **and** no observed "mascot feels like noise / feels wrong at repair" finding; art direction remains a separate owner decision |
| 13 | Compact-device behavior | **7 / 10** (was 9 on selected-lane evidence) | MEDIUM-HIGH | the compact instruction-rail contract is **red at head** (F-18): authored teaching copy is absent from the widget tree while the no-scroll assertion still holds; a compact-height overflow guard is also red | **PHP-0** | HNP on a real device/simulator at default and enlarged text | no compact-specific functional finding in a clean session, and every compact contract green in the full lane |
| 14 | Accessibility | **5 / 10** | HIGH | `ui_v2_accessibility_touch_contract_test` is **red at head**, and `world1_plan_result_compact_height_no_overflow_contract_test` is red. Contracts are also scattered with **no single named gate**, there is no screen-reader traversal, and no real Dynamic Type sweep. A dimension cannot be scored above the state of its own failing contract. | **PHP-0** (red contracts), then **PHP-8** (named lane) | HNP with a screen reader and system-level large text | red a11y contracts green or explicitly reclassified as legacy-owned, named a11y lane green **in the full lane**, and one screen-reader traversal with no blocking finding |
| 15 | Telemetry completeness | **9 / 10** | HIGH (Subwave 4 verified; no reintroduction found by the audit) | none machine-side; HNP JSONL agreement with observer notes unproven | closed | HNP: physical JSONL parses, and route/task/choice/error/timing/repair/recheck/payoff/exit agree with observer notes | zero unexplained observer-vs-telemetry disagreement; no identity/raw-signal field present |
| 16 | Deterministic integrity | **6 / 10** | HIGH on the measurements; the *cause* is explicitly unestablished | F-16 is green (62/62) and the assessed-row fingerprint `1318f99a…` is unchanged. But one canonical-adjacent contract is red at the seam F-16 edited (F-18, **causation unproven**), and five `STALE_TEST` verdicts remain independently un-re-derived. The score is lowered because contract truth is currently unsettled — **not** because a regression is attributed. | **PHP-0**, **PHP-1** | none | F-18 carries a terminal verdict with a named owner, and is repaired only if proven `PRODUCTION_REGRESSION`; PHP-1 publishes `NON_WEAKENING` for all seven items (or restores the weakened assertion) |
| 17 | Regression resistance | **3 / 10** | HIGH (Q2/Q5/Q8 measured at head) | **128 files fail to compile; 111 assertion failures across 53 files; no automatic lane runs the two canonical test directories at all.** The two workflows that would catch this are `workflow_dispatch`-only. A guard that no lane runs cannot fail — and the F-18 evidence shows this has already let a fresh regression through. | **PHP-0, PHP-2, PHP-3, PHP-4** | none | dead-import count 0, zero canonical-owned assertion failures, quarantine ledger empty, and one proven red-on-failure run of the full automatic lane |
| 18 | End-to-end product completion | **UNKNOWN** overall; machine sub-result **7 / 10** (W1–W12 route complete: placement → welcome → Home → Learn → theory → decision → feedback → repair → recheck → recovered → payoff → Review → Session Summary → W12 terminal, no W13 admission; lowered from 8 because a W10→W11 transition-policy guard is red at head) | MEDIUM on the machine half | `w10_to_w11_transition_policy_contract_test` red; one uninterrupted human traversal has never been observed | **PHP-0**, then PHP-9 consolidates | HNP Profile A + Profile B, both parts, without a functional blocker | one clean end-to-end human session with a single truthful terminal exit and no P0/P1 route failure |

Scores marked "was N on selected-lane evidence" were lowered by this campaign's
full-lane measurement (§2, Q8). Nothing was lowered on judgment — each
reduction names a specific contract that is red at exact head. Equally, none of
these reductions asserts a proven learner-visible regression: ownership is
adjudicated in PHP-0, and several may resolve upward as legacy-owned or stale.

Aggregate reading (stated honestly): **machine-side the product is strong on
route, content census, telemetry, and repair mechanics; weak on regression
resistance; incomplete on motion/ceremony; carrying one reproduced compact
teaching-copy absence of unproven cause; and entirely unproven on every felt
dimension.**
No aggregate 10/10 number is asserted here, because four dimensions (1, 10, 18,
and the durable half of 7) are `UNKNOWN` and cannot be machine-closed. Reporting
an aggregate now would necessarily convert `UNKNOWN` into a score, which this
rubric forbids.

---

## 7. Appendix — full defect coverage

Verdict vocabulary: `CLOSED_PROVEN` · `CLOSED_FIXED` · `DISPROVED` ·
`OPEN_CANONICAL` · `DEFERRED_TO_LATER_PRE_HUMAN_PACKET` ·
`HUMAN_BOUND_EVIDENCE` · `OUTSIDE_PRE_HUMAN` · `BLOCKED_OWNER_DECISION`.

Three additional statuses are used where the plain vocabulary would misstate the
situation:

- `OPEN_REPRODUCED · CAUSATION_UNPROVEN` — reproduced at exact head, cause and owner not yet established (F-18 only).
- `OPEN_ASSERTION_EVIDENCE_POOL` — a measured pool of failing assertions whose per-file ownership and severity are not yet assigned (F-17 only). **Never read as a defect count.**
- `OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING` / `EXTERNAL_ASSET_INPUT_REQUIRED` — the owner decision exists; what remains is integration, or an absent production-ready asset (Sharky rows, per OD-03b).

`CLOSED_PROVEN` = closed and re-verified at a current head. `CLOSED_FIXED` = a
named fix landed and its guard passes, without independent re-derivation of the
original claim. Where a row groups alias IDs, every alias is listed and is
counted once.

### 7.1 Final Deep Independent Audit findings

| ID | Source artifact | Affected surface | Owner | Orig. sev | Current evidence | Verdict | Packet | Executable DoD | Required evidence | Reason if not implemented |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- | --- |
| **F-01** | audit §10, §13 | Act0 lesson runner — Street Replay proof-loop motion | Act0 motion owner | P3 | **Verified open at `52034abb`:** only `Key('act0_shell_street_replay_step_$index')` exists at `act0_lesson_runner_shell_v1.dart:15151`; no motion wrapper. Added by `d0c4b9fe`, deleted by `21b4abd0`. | **OPEN_CANONICAL** | **PHP-5** | restore the reveal via the existing shared proof-reveal wrapper + `Act0MotionTokensV1`; re-establish the motion key | widget test for moment 4; reduced-motion bypass; no-replay-on-rebuild; CTA tap-safe mid-motion | — |
| **F-02** | audit §10 | Session Summary proof-hero motion reveal + moments 2–4 | Act0 motion owner | P3 | **Verified open:** `act0_shell_session_summary_proof_hero_motion_reveal` present in `lib/`; the only `test/` reference is `act0_shell_preview_screen_v1_legacy_backlog.dart`, not a `_test.dart` and executed by no lane | **OPEN_CANONICAL** | **PHP-5** | add active `_test.dart` guards for moments 2, 3, 4 | three passing guards, executed by the PHP-4 lane | — |
| **F-03** | audit §3.4 | docs authority index | docs owner | P3 | Node 4 ledger row now states `AGENTS.md` is the sole active workflow authority and records the correction | **CLOSED_FIXED** | — | — | Node 4 §2 corrected row | — |
| **F-04** | audit §3.5 | Master Plan wave freshness | docs owner | P3 | Freshness corrections present in `MASTER_PLAN_v3.0.md` (post-`:174` note and the Current-Route-To-100 correction) marking Waves 3.10–3.15 landed and rule 4 stale | **CLOSED_FIXED** | — | — | Master Plan freshness notes | — |
| **F-05** | audit §3.3, §11 | Node 4 disposition vocabulary | docs owner | P3 | Split published in audit §11 and back-annotated into the Node 4 ledger §4 | **CLOSED_FIXED** | — | — | audit §11 table; Node 4 correction block | — |
| F-06 (= N4-R01) | Node 4 discovery | compact visual proof fixture | test owner | P2 | PR #48 `00073f13` aligned the fixture with the production enlarged-text scroll contract | **CLOSED_PROVEN** | — | — | PR #48 | — |
| F-07 | Node 4 (24 rows) | content, compact reachability, route copy, proof tooling | various | P0–P3 | Node 4 §4 plus the audit's independent head census and route inspection | **CLOSED_PROVEN** | — | — | audit §6 | — |
| F-08 | Node 4 (4 rows) | blank CTA, summary/nav collision, sparse presentation, stale W11 filename | various | P1–P3 | capture-interpretation artifacts; not reproducible in product state | **DISPROVED** | — | — | audit §10 | — |
| F-09 | Node 4 (CODEX-HARD-001/PREHQA-001) | tablet Welcome underfill | responsive owner | P1 orig. | Master Plan device policy: tablet deferred, non-blocking | **OUTSIDE_PRE_HUMAN** | — | — | — | OD-04: unsupported device class in the current wave |
| F-10 | Node 4 | felt credibility, felt comprehension, Human protocol scope | Human-proof owner | P2 | requires live human observation | **HUMAN_BOUND_EVIDENCE** | HB-1/HB-2 | — | HNP session record | OD-01: cannot be machine-closed or simulated |
| F-11 | Node 4 | transfer ratio, context variety, W11/W12 transfer depth, terminology drift | curriculum owner | P2–P3 | future content architecture; not a current-route defect | **OUTSIDE_PRE_HUMAN** | — | — | — | future content architecture; W13–W36 and depth expansion are forbidden scope |
| F-12 (= ALI-NATIVE-SHARED-001) | Node 4 | dormant preflop list | dormant owner | P3 | no canonical Act0 consumer | **OUTSIDE_PRE_HUMAN** | — | — | — | non-canonical; reviving it would promote a dormant owner |
| F-13 | Wave 3.15 accepted gap | no dedicated W2 capture lane in `screen_review_fast_v1.sh` | evidence tooling | P3 | reviewer-friction only | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-8** | add the W2 capture lane | W2 packet generated at exact head | — |
| F-14 | capsule P4 wording debt | Same-Session test title/comment names Review although continuation advances to the next authored W2 hand | test owner | P4→P3 | pre-recorded wording debt | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-8** | correct the title/comment | corrected test, still green | — |
| **F-15** | audit §10, §14 Part 2 | `test/ui_v2` + `test/guards` legacy import corpus (non-canonical) | test authority / archive boundary | P2 (non-canonical) | **Verified open and larger at head: 145 `_test.dart` files** import the 9 removed `lib/` paths (audit reported 125 compile-failing files at `4563ce2d`; different measurement, both real). `lib/archive/legacy_runners/` exists; the 9 original paths do not. | **OPEN_CANONICAL** (open, non-canonical ownership) | **PHP-2**, **PHP-3** | classify by ownership; dispose of archived/duplicate files; extract carrier contracts against current owners | 145-row ledger; dead-import count → 0; no new `lib/archive/` test importer | — |
| **F-16** (12 items + #2b) | audit §13; `f16_canonical_contract_adjudication_v1.md` | Act0 instruction copy (EN+RU), W4–W6 subtitles, band-transition proof icon, repair-receipt copy, W9/W10 source template, Sharky acknowledgement idempotency, W1 result surface, **P1 Visual UX copy contract** | Act0 shell (5 seams) | P1–P2 | **Verified CLOSED at `52034abb`: 62/62 pass across all 8 files**, including "one repair yields at most one acknowledgement" and "known P1 Visual UX copy stays bounded and unambiguous". 5 items were `PRODUCTION_REGRESSION` (repaired in source), 7 `STALE_TEST` (contract-corrected). | **CLOSED_FIXED** | **PHP-1** for the residual verification debt | independently re-derive the seven `STALE_TEST` verdicts; restore any weakened assertion | per-item non-weakening table; 8 files green | — |
| **F-17** (new; this campaign) | Q8 full-lane run at `52034abb` | `test/ui_v2` + `test/guards` assertion layer — 53 files, of which ≥10 claim canonical, premium-identity, accessibility, Sharky, motion, content-safety, or terminal scope (enumerated in §2.1) | test authority (classification); named canonical owners (repair) | **evidence pool — severity not yet assignable** | **`flutter test test/ui_v2 test/guards` at head: 1810 passed / 239 failed = 128 compile failures + 111 assertion failures across 53 files.** No prior authority recorded this: the audit attributed its 250 failures as "238 compile errors + 12 canonical", which does not survive re-measurement. Every one is invisible to every automatic lane (Q5). **This is an assertion-evidence pool, NOT 111 product defects.** Severity is never inferred from assertion count; most files are legacy-owner families. | **OPEN_ASSERTION_EVIDENCE_POOL** | **PHP-0** (classify all 53), then **PHP-1** (canonical repair), **PHP-2** (archived disposition), **PHP-3** (unique-contract extraction) | every one of the 53 files receives exactly one of `CURRENT_CANONICAL_REQUIRED`, `CURRENT_CANONICAL_STALE_ASSERTION`, `ACTIVE_NONBLOCKING`, `ARCHIVED_NONCANONICAL`, `QUARANTINED_WITH_OWNER`, `UNRESOLVED_UNIQUE_CONTRACT`. **No archiving or repointing until PHP-0 has preserved every potentially current unique contract.** | 53-row classification table; per-label counts; no file archived, deleted, or repointed in PHP-0 | — |
| **F-18** (new; this campaign) | Q8 + PR #51/#52 diff scope | Act0 compact learning/instruction rail — `test/ui_v2/compact_decision_integrity_repair_v1_test.dart:461`, "short table-read instruction composes its teaching copy with Continue without moving the table" | **owner not yet established** — candidate seam is the instruction-policy owner (`act0_instruction_content_policy_v1.dart`) | **P2 contract-significance; product severity provisional** | **Reproduced at head:** `find.textContaining('Same scan, different spot.')` returns **0 widgets** while the no-scroll-view assertion still holds. The copy is authored at `act0_shell_state_v1.dart:10740`. The segmenter (`_groupCompactLearningRailSentencesV1`) flushes rather than truncates, so absence points at bounded-height rendering of a larger segment set rather than at truncation. `act0_instruction_content_policy_v1.dart` is in the PR #51/#52 diff and this contract sits on that seam — **but the test was not executed at `4563ce2d`, so this is a co-location, not a cause.** | **OPEN_REPRODUCED · CAUSATION_UNPROVEN** | **PHP-0** | five ordered steps: (1) reproduce at `52034abb`; (2) test at `4563ce2d`; (3) test the smallest relevant commit interval around PR #51; (4) record one terminal verdict from `PRODUCTION_REGRESSION` / `STALE_TEST` / `FIXTURE_OR_ROUTE_MISMATCH` / `RETIRED_CONTRACT`; (5) identify the exact owner. **Production repair authorized only after causation and ownership are proven.** | all commit/outcome pairs; terminal verdict; named owner; F-16's eight files still green | Not repaired in this pass because causation is unproven — repairing a co-located seam without proof would be a guess, and editing the test instead would destroy the evidence. |

### 7.2 Node 4 visual/UX ledger — 36 canonical records, dispositions corrected per audit §11

| IDs | Affected surface | Owner | Orig. sev | Current evidence | Verdict | Packet | DoD / reason |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| ALI-W1-001, ALI-W2-001, ALI-SHARED-002 | assessed content correctness | curriculum | P1–P3 | current content guards; head census 291/466 | **CLOSED_PROVEN** | — | closed content |
| ALI-SHARED-003 | fourth compact choice reachability | runner shell / compact geometry | P1 | compact geometry tests | **CLOSED_PROVEN** | — | closed; will additionally be covered by the PHP-8 named a11y lane |
| ALI-NATIVE-SHARED-001 | dormant preflop list | dormant owner | P3 | no canonical consumer | **OUTSIDE_PRE_HUMAN** | — | reviving a dormant owner is forbidden |
| W10W12-DCA-001, -002, -003 | answer order, shortcut distractors | curriculum | P0–P1 | fingerprint + distribution + grouped-content guards, re-run at head | **CLOSED_PROVEN** | — | closed content |
| W10W12-DCA-004, -008 | concept echoes, duplicate prompts | curriculum | P2–P3 | grouped closure + source guards | **CLOSED_PROVEN** | — | closed content |
| W10W12-DCA-007 | change-condition feedback | feedback owner | P2 | grouped repair closure + feedback guard | **CLOSED_PROVEN** | — | mechanical half closed; felt residue is Human-bound (see F-10) |
| W10W12-DCA-005, -006 | transfer ratio, context variety | curriculum | P2–P3 | future content architecture | **OUTSIDE_PRE_HUMAN** | — | future content; not a current-route defect |
| W10W12-DCA-009 | literal terminology drift | copy owner | P3 | intentional nonblocking residue | **OUTSIDE_PRE_HUMAN** | — | future copy maintenance |
| W10W12-DCA-010 | felt credibility | Human-proof owner | P3 | requires live observation | **HUMAN_BOUND_EVIDENCE** | HB-1 | OD-01 |
| CODEX-HARD-001, PREHQA-001 | tablet Welcome underfill | responsive | P1 orig. | Master Plan tablet policy | **OUTSIDE_PRE_HUMAN** | — | OD-04 |
| CODEX-HARD-002, PREHQA-002 | Practice-repair density/void | runner shell | P2 | current layout + real-text route proof | **CLOSED_PROVEN** | — | closed compact owner |
| CODEX-HARD-003, PREHQA-003 | `play` capture fidelity | evidence tooling | P3 | product-100 capture contract | **CLOSED_PROVEN** | — | closed proof tooling |
| CODEX-HARD-004, PREHQA-010 | Human protocol scope | Human-proof owner | P2 | protocol boundary | **HUMAN_BOUND_EVIDENCE** | HB-1 | OD-01 |
| CODEX-HARD-005; PREHQA-006, -007, -008 | assessment provenance gaps | curriculum | P2–P3 | DCA grouped closure + current guards; aliases are not separate defects | **CLOSED_PROVEN** | — | closed content |
| CODEX-HARD-006, OMISSION-HUNT-001 | viewport/evidence freshness boundary | evidence tooling | P3 | regenerated current-head manifests | **CLOSED_PROVEN** | — | closed proof tooling |
| CODEX-HARD-007, -008 | no-W13 admission; placement void | route owner | P3 | active-route proof + layout contract; audit re-confirmed no `world_13`/`W13` token in `act0_shell_state_v1.dart` | **CLOSED_PROVEN** | — | **terminal-state finding: closed** |
| CODEX-HARD-009 | felt comprehension | Human-proof owner | P3 | requires live observation | **HUMAN_BOUND_EVIDENCE** | HB-1 | OD-01 |
| CODEX-HARD-010 | W11/W12 transfer depth | curriculum | P3 | future content | **OUTSIDE_PRE_HUMAN** | — | future content architecture |
| CODEX-HARD-011, PREHQA-004 | stale W11 `danger_texture` filename | evidence tooling | P3 | current rendered W11 identity is correct; filename is capture residue | **DISPROVED** | — | — |
| PREHQA-005 | purported resolver test failure | test owner | P3 | does not reproduce | **DISPROVED** | — | — |
| PREHQA-009, -011 | stale capsule / plan wording | docs owner | P3 | closed by F-03/F-04 corrections | **CLOSED_FIXED** | — | — |
| PREHQA-012 | corpus-size concern | tooling | P3 | tooling, non-product | **OUTSIDE_PRE_HUMAN** | — | broad test/plan refactor is not admitted |
| GR-01, GR-02, GR-04, GR-05 | raw IDs; clue/category/lock copy | route/copy owner | P1–P2 | current route/copy closure | **CLOSED_PROVEN** | — | closed route copy |
| GR-03, GR-08 | blank CTA; summary/nav collision | evidence tooling | P1–P2 orig. | capture interpretation, not product state | **DISPROVED** | — | — |
| GR-06, GR-07 | Welcome and Review sparse presentation | route owner | P2 | intentional state presentation; no mechanical contradiction | **DISPROVED** | — | felt-premium residue is Human-bound (dimension 10) |
| GR-09, GR-10, GR-12, GR-17 | later nonreproducible visual allegations | named owners | P2–P3 | current route captures + closure evidence | **DISPROVED** | — | — |
| **GR-11** | future visual/premium-perception work | visual owner | P3 | no fresh regression; inside pre-Human per OD-03 | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-5** (motion half), **PHP-7** (hierarchy half) | corrected from Node 4's `DEFERRED_OUTSIDE_PRE_HUMAN` by audit §11 |
| **GR-14** | future motion/ceremony work | motion owner | P3 | F-01/F-02 are its reproduced remainder | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-5** | OD-03 makes motion/ceremony mandatory pre-Human |
| **GR-16** | future Sharky work | Sharky owner | P3 | integration proven broad; state-reachability unproven; **art direction now supplied** (refined C) | **OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING** | **PHP-6** | OD-03/OD-03c mandate integration before Human Proof; OD-03b supplies the direction, so nothing here is blocked on selection |
| N4-R01 | stale compact visual regression fixture | test owner | P2 | PR #48 | **CLOSED_PROVEN** | — | — |

### 7.3 Waves 3.10–3.15

| ID | Surface | Owner | Sev | Current evidence at head | Verdict | Packet | DoD / reason |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| W3.10 Premium Motion Moments | proof-loop motion | Act0 motion | P3 | 3 of 4 moments present; Street Replay reveal absent (= F-01); moments 2–4 unguarded (= F-02) | **OPEN_CANONICAL** (`PARTIALLY_LANDED`) | **PHP-5** | restore moment 4 + guard 2–4 |
| W3.11 Personalized Return Reason | Home / preview / Review | Act0 route | — | `act0_personalized_return_reason_v1.dart` + `act0_last_session_return_reason_v1.dart` consumed by three surfaces | **CLOSED_PROVEN** | — | — |
| W3.12 World 1 Completion Payoff | lesson runner | Act0 route | — | `hasWorldOneCompletionPayoff` gate present | **CLOSED_PROVEN** | — | — |
| W3.13 Sharky Growth / Companion Tone | Sharky phrase contract | Sharky owner | — | `Act0SharkyCoachTierV1{foundation,developing}` + `Act0SharkyGrowthStageV1`; band selector present | **CLOSED_PROVEN** | — | reachability proof still added by PHP-6 |
| W3.14 Competitive Wedge Pass | repair-intent copy | copy owner | — | live copy at `act0_repair_intent_copy_guard_v1.dart:45`, `:132`, guarded | **CLOSED_PROVEN** | — | — |
| W3.15 W2–W4 Launch Quality | content quality packet | curriculum | — | W2–W4 census clean at head; accepted gap = F-13 | **CLOSED_PROVEN** (with F-13 deferred) | **PHP-8** for F-13 | — |

### 7.4 W1–W6 learning closure ledger and known-debt burn

| ID | Surface | Owner | Sev | Current evidence | Verdict | Packet | DoD / reason |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| W1W6-DLR-001 | W1 showdown/hand-ranking prerequisite | content | P1 withdrawn | premise absent on the canonical route (`MISSCOPED_NO_CANONICAL_ASSESSMENT`) | **DISPROVED** | — | — |
| W1W6-DLR-002 | W6 session-drill repair continuity | non-canonical session-drill owner | P1 withdrawn | canonical W6 uses task-centric repair (`MISSCOPED_NONCANONICAL_SESSION_DRILL_OWNER`) | **DISPROVED** | — | — |
| **W1W6-DLR-003** | Learn/Home primary-CTA emphasis, compact portrait | Act0 Learn/Home shell | P2 | **Upgraded by this campaign from "needs visual evidence" to evidenced:** `test/guards/phone_first_premium_polish_v4_contract_test.dart` — "Home and Learn keep one hero while secondary modules stay quiet" — is **red at head**, alongside "Summary, feedback, and actions own purposeful premium moments". One structural primary CTA is still confirmed present in `act0_learn_path_shell_v1.dart`. | **OPEN_CANONICAL** | **PHP-0** (ownership + repair), **PHP-7** (proof + role distinctness) | ownership verdict for the red guard; if canonical, bounded copy/order/emphasis repair; then the 360×640 dominance proof |
| W1W6-DLR-004 | repair-continuity breadth | canonical Act0 mapper | P2 | superseded by Wave 3 canonical same-world coverage via `act0FirstValueSameSignalRepMappingV1`; head census confirms 277/291 | **CLOSED_FIXED** | — | any future breadth work targets the canonical mapper, never the session-drill seam |
| W1W6-DLR-005 | prompt/option template residue | content copy / assessment policy | P2 | leakage removed for W1/W2/W4/W5 by Wave 2 CAP-005; deferred template phrasing remains | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | none admitted | Not implemented because the admitted DoD is a representative scan-and-patch wave, and no current evidence promotes the residue to a confirmed assessment-validity defect. Rubric dimension 3 carries the delta. |
| W1W6-DLR-006 | `concept_family_id` schema field | content schema | P3 | audit-repeatability debt; not learner-facing | **OUTSIDE_PRE_HUMAN** | — | tooling debt; admit only when a wave already has validator access open |
| KD-W2-weak-ace-depth | W2 depth | curriculum | P3 | `already_closed`; low new EV | **CLOSED_FIXED** | — | — |
| KD-W3-table-format (6-max/full-ring framing) | W3 framing | curriculum | P3 | `obsolete`; canonical copy names exactly six seats and does not overclaim | **DISPROVED** | — | `DEFERRED_BOUNDED_LEARNER_TRUST_CANDIDATE` copy note remains optional, not a defect |
| KD-W4-purpose-size | W4 sizing transfer | curriculum | P3 | `already_closed` via `w4_checkpoint_table_purpose_price` | **CLOSED_FIXED** | — | rescore listed it `HUMAN_QA_FIRST`; the checkpoint closes the machine half |
| KD-W5-texture-action | W5 classification→action | curriculum | P3 | `already_closed` via two transfer tasks | **CLOSED_FIXED** | — | as above |
| **KD-W6-promise-checkpoint-bridge** | W6 promise/payoff + W6→W7 bridge | Act0 shell state | P2 (was `admit_now`, high EV) | **Verified at head:** `_rangeThinkingFoundationLessons` now holds `_rangeThinkingLiteLessons[0..4]` (five lessons incl. `range_combo_counts`, `range_thinking_checkpoint`); guarded by `test/guards/w1_w12_known_deferred_debt_burn_contract_test.dart` | **CLOSED_FIXED** | — | closes the rescore's only `ADMIT_WAVE4` items — no content packet enters this campaign |
| KD-X-terminology-order, KD-X-checkpoint-template | W7–W12 copy/templates | curriculum | P3 | `already_closed` by W7–W9 and W10–W12 guards | **CLOSED_FIXED** | — | — |
| KD-X-stale-test-expectation | cross-world guard drift | test authority | P3 | `admit_now` → guard landed | **CLOSED_FIXED** | — | — |
| W1-load / W1 pacing (70 tasks) | W1 pacing | curriculum | P3 | `HUMAN_QA_FIRST` — do not cut content before QA confirms a pacing problem | **HUMAN_BOUND_EVIDENCE** | HB-1/HB-3 | OD-01; observing pacing is the only valid evidence |
| TST-01 | `act0_completed_decision_callback_contract_v1_test` sizing case used `world_5` for a `world_4`-owned lesson | test owner | P3 | rescore recorded `STALE_TEST_EXPECTATION_PENDING_BOUNDED_TEST_ONLY_FIX` | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-2** (verify during classification; fix if still red) | one-word test-argument fix if the PHP-4 lane reports it red |

### 7.5 Visual, motion, Sharky and accessibility review artifacts

| ID | Source artifact | Surface | Owner | Sev | Current evidence | Verdict | Packet | DoD / reason |
| --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| VIS-DEC-01 | merged 10/10 deconstructions (`sharky_10_10_master_backlog…`) | table signal weakness | Modern Table (frozen) | judgment | 6.8–7.8 merged static-evidence band; no exact-head mechanical regression | **OUTSIDE_PRE_HUMAN** | — | OD-02 permanent Maintenance Mode; reopening requires exact current regression evidence, which does not exist |
| VIS-DEC-02 | same | table/feedback split | Act0 learning surface | judgment | closed by Learning Surface Composition Stability v1 (`2e86b4c`) — one unified canonical scene across theory/decision/feedback/repair/recheck | **CLOSED_FIXED** | — | — |
| VIS-DEC-03 | same | under-produced Sharky | Sharky owner | judgment | direction is now supplied (refined C / `SHARKY_VISUAL_LOCK_V1`); the runtime family in `assets/images/mascot/` predates it, and the approved character package is explicitly non-runtime | **OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING** for every integration-ready surface; the art-production remainder is **EXTERNAL_ASSET_INPUT_REQUIRED** | **PHP-6** | integrate against the supplied lock; record asset-absent rows explicitly rather than substituting placeholder art. No exploration is reactivated. |
| VIS-DEC-04 | same | state sameness across screens | Act0 shells | judgment | screen-role differentiation unproven as one contract | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-7** | six-surface role-distinctness assertion |
| VIS-DEC-05 | same | weak proof/payoff ceremony | Act0 motion | judgment | F-01/F-02 are its reproduced mechanical remainder | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-5** | four-of-four moments guarded |
| VIS-DEC-06 | same | unproven motion/touch feel | motion + Human | judgment | machine contracts exist; feel is unobserved | **HUMAN_BOUND_EVIDENCE** | HB-1 | OD-01 |
| MOT-01 | `motion_direction_system_v1.md` | navigation crossfade | motion owner | P3 | explicit deferral, not open scope | **OUTSIDE_PRE_HUMAN** | — | admitted motion scope is bounded; a future task must name it |
| MOT-02 | same | Street Replay **entrance** motion | motion owner | P3 | explicit deferral; distinct from the F-01 **reveal** | **OUTSIDE_PRE_HUMAN** | — | not to be conflated with F-01 during PHP-5 |
| MOT-03 | `premium_transitions_replay_motion_v1` closure | no screenshot lane reaches world-complete/W4-complete; `RenderRepaintBoundary.toImage()` anomaly | evidence tooling | P3 | evidence-only gap; motion itself is widget-test verified | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-8** | reproduce the anomaly or close it as non-reproducing |
| SHK-STATE-01 | `sharky_companion_states_v1`, `sharky_visual_growth_evolution_v1` | six states + two growth stages reachability | Sharky owner | P3 | contracted and present; not proven reachable as one matrix | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-6** | state→route→key→guard matrix |
| SHK-VIS-01 | Q8 full-lane run | `sharky_visual_consistency_foundation_v1_test` — "correct feedback Sharky mascot uses the rounded-square family, not a circle" | Sharky visual owner | P2 contract-significance | **red at head**, invisible to every lane | **OPEN_CANONICAL** | **PHP-0** | ownership verdict; if canonical, repair the mascot container family at the feedback surface — no new art, no direction change (OD-03b) |
| MOT-04 | Q8 full-lane run | `wave4_5_motion_evidence_repair_feel_v1_test` — "repair surfaces share one calm repair proof system" | Act0 motion owner | P2 contract-significance | **red at head** | **OPEN_CANONICAL** | **PHP-0** (adjudicate), **PHP-5** (repair if canonical) | ownership verdict, then repair within the admitted motion-token system |
| SHK-EVID-01 | `sharky_character_growth_evidence_pack_v1` | capture gaps: Developing, improve, milestone | Sharky owner | P3 | bounded recorded gaps | **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** | **PHP-6** | three deterministic captures |
| SHK-ASSET-01 | `sharky_asset_truth_v1`, mascot feasibility audit | legacy `poker_shark_*.svg` still used in Welcome and as PNG load-error fallback | Sharky owner | P3 | live production use confirmed. **Verified this pass:** the owner-approved `sharky_canonical_character_package_v1_1` contains 4 files, **all `runtimeEligibility: false`** with `runtimeBundle: false`, and references no runtime mascot PNG. So no production-ready approved on-identity fallback asset exists yet. | **EXTERNAL_ASSET_INPUT_REQUIRED** | **PHP-6** (records the gap; does not fake it) | Direction is no longer the blocker — the exact production-ready asset is genuinely absent. Migration proceeds once one runtime-eligible on-identity fallback asset is supplied under the package `replacementPolicy`. |
| **SHK-CREST-01** (new; this campaign) | supplied OD-03b vs `sharky_character_package_manifest_v1.json` | canonical base identity — crest vs no-crest | Sharky owner | P3 | Refined C specifies a "small soft asymmetric front crest / messy tuft". The approved package's rank-1 authority is the **"no-crest sole authority for canonical visual identity"**, and its side/back references call a visible crest "a deprecated reconstruction inconsistency". | **BLOCKED_OWNER_DECISION** (one confirmation, narrowly scoped) | — | Needs one owner sentence: refined C supersedes package v1.1 (requiring a versioned replacement package), or the no-crest authority stands and the crest clause is withdrawn. **Does not block campaign planning or any packet except crest-dependent asset production inside PHP-6.** No exploration is reopened by this row. |
| SHK-HOME-01 | `sharky_visual_growth_evolution_v1` | Home companion-state migration (ad hoc ownership retained) | Sharky owner | P3 | explicitly deferred; "do not activate in this route" | **OUTSIDE_PRE_HUMAN** | — | route-scoped deferral by the closing artifact |
| SHK-ANIM-01 | Phase 8 sequence item 6 | Sharky Micro-Animations v1 | Sharky owner | — | the controlled-visual-verdict precondition is **discharged** by the supplied refined C lock; the remaining preconditions (fallback parity, renderer apparent-scale/anchor normalization, reduced-motion proof) are machine-provable against the existing runtime asset family | **OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING** | **PHP-6** | animate on existing approved runtime assets with reduced-motion bypass; no new art, no direction re-litigation |
| A11Y-01 | `ui_v2_accessibility_touch_contract`, `world1_a11y_semantics_contract`, `session_result_text_scale_contract`, compact-height + enlarged-text contracts | accessibility contract set has no single named gate **and two of its contracts are red** | evidence tooling (lane); named owner (repair) | P3 → **P2** | **Corrected by Q8:** `ui_v2_accessibility_touch_contract_test` and `world1_plan_result_compact_height_no_overflow_contract_test` are **red at head**. The earlier "contracts exist and pass" statement was true only of the selected lanes. | **OPEN_CANONICAL** (red contracts) + **DEFERRED_TO_LATER_PRE_HUMAN_PACKET** (named lane) | **PHP-0** (red contracts), then **PHP-8** + **PHP-4** (lane) | adjudicate and fix/reclassify the two red contracts **before** promoting the set into a named gate; a gate that is red on arrival is worse than no gate |
| A11Y-02 | rubric dimension 14 | screen-reader traversal; real system Dynamic Type | Human-proof owner | P2 potential | never observed | **HUMAN_BOUND_EVIDENCE** | HB-1 | OD-01; a simulator contract is not a screen-reader traversal |
| TERM-01 | audit §6; CODEX-HARD-007 | W12 terminal state; no W13 admission | route owner | P3 | 16-state active-route packet; no `world_13`/`W13` token in `act0_shell_state_v1.dart` | **CLOSED_PROVEN** | — | **terminal-state family closed** |
| TERM-02 | capsule; audit §5, §7 | exactly-once learning-run terminal exit | Act0 payoff owner | P2 | Home tab closes the run exactly once; `act0_learning_run_payoff_v1.dart` is the sole run-level lifecycle | **CLOSED_PROVEN** | — | — |

### 7.6 Readiness authorities and standing deferrals

| ID | Source | Item | Verdict | Reason |
| --- | --- | --- | --- | --- |
| RDY-01 | `FULL_PRODUCT_READINESS_LEDGER_v1.md` | app-wide unit-based readiness ~mid-50s vs Act0 route ~93 | **OUTSIDE_PRE_HUMAN** | the gap is non-Act0 departments (commercial, store, RU, analytics); this campaign is Act0 pre-Human only and must not present Act0 strength as whole-product readiness |
| RDY-02 | `PRODUCT_SURFACE_READINESS_v1.md` | older pre-Act0 surface-quality model | **OUTSIDE_PRE_HUMAN** | marked `REFERENCE`; explicitly "do not use first when choosing current product waves" |
| SIZ-01 | Master Plan sizing-control hold | preset-first sizing surface; W5 `presetsOnly` first slice | **OUTSIDE_PRE_HUMAN** | belongs to a later implementation-spec wave; `ModernTableScreenV1` slider is not the approved final owner |
| L10N-01 | `l10n_untranslated_report.txt`; Wave 3.9 boundary | RU untranslated residue | **OUTSIDE_PRE_HUMAN** | English-first boundary; RU rollout is forbidden scope. (The RU *instruction compact contract* was in scope and is closed — F-16 #2.) |
| DEF-01…DEF-13 | `docs/deferred_backlog.md` | Bet Sizing Input + Drill Integration; Completion Filters enhancements; Coach Layer v1 + table visual borrow; Import Preview/File Picker; Intro Game Flow cross-module progression; Module Progress Tracking enhancements; Path Visual Upgrade; Phase 2 Value/Aha polish; Phase 4 regression suite expansion; Player Zone chip-count overlay; RC packaging manifest aggregation; Visual Icon SSOT; Web plugin loader download | **OUTSIDE_PRE_HUMAN** (all 13) | every entry names an unmet gate, and each owner is either a legacy/dormant screen (`lib/ui_v2/screens/`, `lib/widgets/player_zone/`, `lib/plugins/`), a post-launch scope, or a release-packaging concern. None is on the canonical Act0 learner route, so none is an owner-mandatory pre-Human item. |

### 7.7 Coverage assertion

- Every finding named in the Node 4 reconciliation (36 canonical records), the Final Deep Independent Audit (F-01…F-16, including all 12 F-16 sub-items), the two findings this campaign discovered (F-17, F-18), Waves 3.10–3.15 (6), the W1–W6 closure ledger (DLR-001…006), the known-debt burn ledger (KD rows), the visual/Sharky/motion review artifacts, the accessibility contract set, the terminal-state family, the readiness authorities, and the 13 standing deferred entries appears above with exactly one verdict.
- **Open items by status:** `OPEN_CANONICAL` **6** — F-01, F-02, F-15, W1W6-DLR-003, SHK-VIS-01, MOT-04, plus the A11Y-01 red-contract half. `OPEN_REPRODUCED · CAUSATION_UNPROVEN` **1** — F-18. `OPEN_ASSERTION_EVIDENCE_POOL` **1** — F-17. Every one is mapped to a packet (PHP-0 ×6, PHP-1, PHP-2, PHP-3, PHP-5 ×2, PHP-7).
- **Open P0: 0. Open P1: 0 proven.** The known P1 (F-16 #12, the Visual UX copy contract) is closed and verified at head. F-18 carries *potential* P1 learner impact (teaching copy absent on the compact rail) and is deliberately recorded as P2 contract-significance with provisional product severity until PHP-0 establishes causation and ownership — the same claim discipline the Final Deep Independent Audit applied to F-16.
- **Severity language:** every "P2 contract-significance" label above means the failing assertion carries P2 contract weight, not that a learner-visible P2 defect is proven. Product severity resolves in PHP-0.
- **F-17 is not 111 product defects.** It is a measured pool of 111 failing assertions across 53 files whose per-file ownership is unassigned. Its per-label counts become knowable only after PHP-0; until then no defect count may be derived from it.
- **Sharky owner-decision rows: reclassified.** The four previously identical `BLOCKED_OWNER_DECISION` rows (VIS-DEC-03, SHK-ASSET-01, SHK-ANIM-01, GR-16) are now `OWNER_DECISION_SUPPLIED — PRODUCTION_INTEGRATION_PENDING` (VIS-DEC-03 integration half, SHK-ANIM-01, GR-16) and `EXTERNAL_ASSET_INPUT_REQUIRED` (SHK-ASSET-01, VIS-DEC-03 art-production remainder), per OD-03b. **`BLOCKED_OWNER_DECISION`: 1** — SHK-CREST-01, a single narrowly scoped crest/no-crest confirmation that blocks no packet other than crest-dependent asset production inside PHP-6. No Sharky direction exploration is reactivated by any row.
- **No owner-mandatory pre-Human visual, motion, Sharky, accessibility, screen-role, or terminal-state finding is unmapped.**
- **No closed Modern Table or material-detail item is reopened.** VIS-DEC-01 is the only table-adjacent judgment item and is held `OUTSIDE_PRE_HUMAN` precisely because no exact current evidence proves a regression.

---

## 8. Horizon B — human-proven product closure (planned, not executed)

**This horizon is planned only. No part of it is authorized by this document,
and no packet below may begin until `PRE_HUMAN_READY` is published by PHP-9.**

Terminal state: **`HUMAN_PROVEN_10_OF_10_CANDIDATE`**

| Packet | Name | Precondition | Output | Explicit non-claims |
| --- | --- | --- | --- | --- |
| **HB-1** | Human Novice Proof execution | `PRE_HUMAN_READY` at an exact frozen head; a real eligible participant; consent obtained | Profile A orientation record + Profile B learning-loop record, assistance ledger, physical JSONL, evidence manifest with SHA-256 | one participant's taste is not a defect; an initial poker mistake is not a failure |
| **HB-2** | Evidence classification | HB-1 executed | every observation classified as novice misunderstanding / intentional learning error / unclear instruction / interaction blocker / telemetry mismatch / cosmetic preference, each with severity, confidence, reproducibility, and smallest repair boundary | classification is not repair authorization |
| **HB-3** | Bounded high-EV repair wave | HB-2 published | repairs only for reproducible P0–P2 findings with a named smallest boundary; no redesign; each repair guarded by the PHP-4 lane | not a licence to reopen frozen surfaces or start a visual wave |
| **HB-4** | Targeted Human recheck | HB-3 landed | re-observation of only the repaired checkpoints, with the same protocol and assistance rules | a recheck cannot upgrade an unobserved dimension |
| **HB-5** | Learning-effect validation | HB-4 clean | evidence that a corrected point survives to a later comparable decision without coaching | telemetry alone cannot establish a felt or durable learning effect |
| **HB-6** | Final exact-head product-readiness admission | HB-1…HB-5 complete | `HUMAN_PROVEN_10_OF_10_CANDIDATE` or an explicit non-admission with blocking IDs | not an absolute or permanent claim |

### 8.1 `HUMAN_PROVEN_10_OF_10_CANDIDATE` — exact meaning

The terminal state means all six of the following, and nothing more:

1. 10/10 **against the declared §6 rubric and the evidence available at that exact head** — a bounded, dated judgment;
2. **not** an absolute or permanent claim, and not a store-readiness, commercial-readiness, or durable-mastery claim;
3. no unresolved canonical P0, P1, or P2 in the §7 appendix;
4. every owner-mandatory P3 either fixed or disproved;
5. every Human-bound rubric dimension (1, 2's real-device half, 3's felt half, 4, 5's felt half, 7's durable half, 10, 12's felt half, 13's real-device half, 14, 15's agreement half, 18) **directly observed**, not inferred;
6. no serious unresolved novice comprehension or learning-payoff defect.

Any later commit invalidates the exact-head basis and requires re-admission.

### 8.2 The three states this document keeps separate

| State | What it asserts | Current value |
| --- | --- | --- |
| **Current machine-proven state** | what deterministic evidence establishes at `52034abb` | route, content census, telemetry/privacy, and repair mechanics hold; **F-16 closed and independently verified (62/62)**; **but the full lane reports 128 compile failures and 111 assertion failures**, including one reproduced compact teaching-copy absence of unproven cause (F-18) and red accessibility, Sharky-visual, repair-motion, and Home/Learn-hero contracts; 9 open canonical items; regression resistance is the weakest dimension at 3/10 |
| **Human evidence still missing** | what only a real session can establish | §3.2 — comprehension, felt causality, felt repair value, premium perception, ceremony perception, durable learning effect, real-device accessibility |
| **Final 10/10-candidate state** | the §8.1 six-part conjunction at one exact head | **NOT REACHED, and not reachable inside Horizon A** |

Reporting rule: no summary of this campaign may present machine-proven state as
product readiness, present an aggregate rubric score while any dimension is
`UNKNOWN`, or describe `PRE_HUMAN_READY` as a 10/10 claim.

---

## 9. What this document does not do

- It does not authorize any implementation. **PHP-0 is the next legal packet**, it is the *only* authorized window, and PHP-1/PHP-2 are not pre-authorized.
- It does not select art direction beyond recording the supplied `SHARKY_VISUAL_LOCK_V1`, does not generate mascot art, and does not reopen the closed three-direction exploration.
- It does not attribute F-18 to any commit.
- It does not perform, schedule, or claim Human Novice Proof.
- It does not reopen Modern Table, the PR #44 feedback/recovery family, Review/Practice lifecycle, or Session Summary.
- It does not activate Sharky micro-animations, produce any asset, or resolve SHK-CREST-01.
- It does not widen scope into W13–W36, RU rollout, monetization, dashboards, sizing curriculum, or the 13 standing deferred entries.
- It does not supersede `MASTER_PLAN_v3.0.md`; where this document and the Master Plan conflict, the Master Plan and the topology map win and the conflict must be reported.

### 9.1 Conflict report (required by the authority rules)

Two active authorities name **"Pre-Human Node 5 — Canonical Guard-Lane Truth
Restoration"** as the next legal capability:
`docs/context/ACTIVE_ROUTE_CAPSULE_v1.md:44–48` and the 2026-07-25 freshness
correction in `docs/plan/MASTER_PLAN_v3.0.md`. Both were written when F-16 was
red and when the guard-lane debt was believed to be 125 compile failures plus 12
canonical assertion failures.

At `52034abb` the exact evidence differs: F-16 is closed and verified, and the
real debt is 128 compile failures plus **111** assertion failures across 53
files, plus one reproduced compact teaching-copy absence whose causation is not
yet established. This
campaign therefore splits Node 5 into PHP-0 through PHP-4 and opens with PHP-0.

**Resolved by owner decision, 2026-07-25.** Node 5 **remains the umbrella
capability**, renamed to its current purpose — *Pre-Human Node 5 — Canonical
Contract and Test Authority Restoration* — and PHP-0 through PHP-4 are admitted
as its **operational sub-packets, not a competing peer phase** (§4.1).

How the wording conflict is discharged:

1. **this campaign overlay** — §4.1 publishes the nesting;
2. **the campaign state file** — `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` records the umbrella stage and the active sub-packet;
3. **one minimal freshness note** in `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`, stating only that exact-head remeasurement decomposed Node 5 **without changing its product purpose and without reopening any previously closed capability**.

`docs/plan/MASTER_PLAN_v3.0.md` is **not modified** by this mission, and the
historical Master Plan sequence is not rewritten.
