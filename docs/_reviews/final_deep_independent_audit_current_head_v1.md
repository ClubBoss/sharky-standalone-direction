---
status: "FINAL_DEEP_INDEPENDENT_AUDIT_BLOCKED"
status_source: "derived"
doc_date: "2026-07-25"
baseline: "4563ce2d2091"
generated_by: "docs_frontmatter_v1"
---

# Final Deep Independent Audit — Current Head v1

Status: **FINAL_DEEP_INDEPENDENT_AUDIT_BLOCKED**

Blocker family: **12 reproduced Act0-canonical contract failures at exact head**, on
surfaces currently recorded as CLOSED, invisible to every gate in use. See §13.
No implementation was performed; a bounded repair packet is specified in §14.

Date: 2026-07-25
Audit baseline: `4563ce2d2091ec3dc92734b616b90b87f016b16d` (`main` == `origin/main`)
Executing agent: Claude Code (independent; not the implementing campaign agent)
Human Novice Proof: **NOT PERFORMED**
Computer Use: **OFF** — no admission-critical ambiguity survived deterministic evidence.

This audit is read-only with respect to product source. No `lib/`, test, content,
asset, workflow, dependency, telemetry-schema, Modern Table, Sharky, or motion
implementation was changed.

## 1. Scope and independence

This report is produced from zero on exact current HEAD. It does not inherit the
verdicts of `docs/_reviews/final_deep_independent_audit_v1.md`, which is
historical, LOCAL-ONLY/UNPUBLISHED, and predates the Alpha, Review, feedback, CI,
and Node 4 closures. That document is used only as a historical finding source.

Deterministic evidence, source inspection, and git history are the basis for every
verdict below. Screenshots and AI review are not Human Novice evidence.

## 2. Exact baseline verification

| Check | Result |
| --- | --- |
| `main` == `origin/main` == `4563ce2d` | PASS |
| Tracked worktree clean | PASS |
| User-owned untracked evidence preserved | PASS — no untracked path removed or modified |
| PRs #45–#49 merged | PASS (#45 `fix(ci)`, #46 `test(review)`, #47 `docs(context)`, #48 `test`, #49 merge) |
| Required CI on `4563ce2d` | PASS — Theory Integrity, validate, Theory Manifest baseline, pure-dart-smoke, Content CI all `success` |
| CI exception classification | `L2 Tests (conditional)` = `skipped`. Conditional-by-design job, not a required-check failure. |

Audit branch: `claude/final-deep-independent-audit-current-head-v1`.

## 3. Authority reconciliation

### 3.1 Authority table

| File | Authority level | Status | Applicable baseline | Claims controlled | Superseded / correction |
| --- | --- | --- | --- | --- | --- |
| `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` | 1 — primary hierarchy | ACTIVE | current head | SSOT routing; canonical vs legacy runtime families; Act0 shell is canonical learner truth | none |
| `docs/plan/MASTER_PLAN_v3.0.md` | 2 — active execution SSOT | ACTIVE, with two stale paragraphs | mixed (`Last updated: 2026-05-14`) | route order, Waves 3.10–3.15, device policy, forbidden scope | Conflict A and Conflict D below |
| `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` | 3 — execution capsule | ACTIVE (2026-07-25 head section) | `00073f13` → current head | Node 4 closure, frozen surfaces, Alpha/PR #41/#44/#46 status | none; its head section is the freshest active statement |
| `AGENTS.md` | 5 — workflow protocol | ACTIVE | current head | evidence, route, test policy | none |
| `docs/PROJECT_RULES_VFINAL.md` | 4 — cited workflow authority | **DOES NOT EXIST** | n/a | none | Conflict C below |
| `docs/_reviews/node4_visual_ledger_reconciliation_v1.md` | 6 — closure ledger | ACTIVE | `00073f13` | 36-item visual disposition | Conflict B — disposition terminology corrected below |
| `docs/plan/CONCEPT_ERROR_REPAIR_INTEGRITY_V1.md` | 6 — closure ledger | ACTIVE | re-verified at head | 291/466 census, 20 concept-error ids | none; independently reproduced |
| `docs/_reviews/wave3_1{0..5}_*.md` | 6 — closure ledger | ACTIVE | 2026-06-27 | Waves 3.10–3.15 delivery | supersedes Master Plan's "deferred" wording (Conflict D) |
| `docs/_reviews/final_deep_independent_audit_v1.md` | 7 — historical audit | HISTORICAL | older product baseline | none current | superseded in full by this report |

### 3.2 Conflict A — Master Plan selects FINAL DEEP INDEPENDENT AUDIT while newer sections describe the completed AI Personalization / Alpha route

**Correct interpretation: both are true in sequence; there is no live contradiction.**

`MASTER_PLAN_v3.0.md:164–177` is a single baseline-pinned bullet. It is explicitly
scoped to `PRODUCT_SOURCE_BASELINE 40babdeb…` and the immutable tag
`act0-final-deterministic-candidate-v1`, neither of which is current head. Within
that bullet the plan both selects FINAL DEEP INDEPENDENT AUDIT as "the next Top-1"
and forbids *the then-active convergence wave* from beginning it — those two
sentences describe two different actors, not a contradiction.

`MASTER_PLAN_v3.0.md:134–138` (same section, later owner decision) selects
**AI Personalization Layer v1** with a fixed five-step sequence. At current head all
five steps are closed: deterministic personalization, Learning Effect / Training
Flow, minimal live E2E Alpha, bounded learning-loop telemetry closure, and Alpha
admission evidence (`ACTIVE_ROUTE_CAPSULE_v1.md:97` — Alpha Learning Loop v1
ADMITTED at `13dbb973`).

Resolution: the AI Personalization stage that deferred the audit has now completed,
so the Final Deep Independent Audit gate is legitimately due at current head. **This
mission is that gate.** No Master Plan rewrite is required to legalize it, and no
historical evidence is deleted. A bounded freshness note is the only correction
published.

### 3.3 Conflict B — Node 4 `DEFERRED_OUTSIDE_PRE_HUMAN` is a mixed bucket

Confirmed. The Node 4 ledger applies one disposition to seven rows that are not the
same kind of thing. The truthful split is published in §11 below. The material
correction is that **motion / Sharky / ceremony work is not outside pre-Human** — the
standing owner decision names required Sharky production integration and required
motion/touch/ceremony as mandatory pre-Human blocks.

### 3.4 Conflict C — a cited workflow authority does not exist

`docs/PROJECT_RULES_VFINAL.md` is cited as an active workflow authority by the Node 4
ledger's authority index (row: "`docs/PROJECT_RULES_VFINAL.md` and `AGENTS.md` …
active"). The file does not exist at current head and **has never existed in git
history** (`git log --all --diff-filter=D` returns nothing; it is not tracked).

This is a documentation-integrity defect, not a product defect. `AGENTS.md` is a real
and active workflow authority and carries that role alone. Recorded as **F-03 (P3)**.

### 3.5 Conflict D — Master Plan says Waves 3.10–3.15 are deferred; all six landed

`MASTER_PLAN_v3.0.md:587–588` heads the list "Previously planned excellence order
(deferred until after Alpha learning-loop admission)" and `:636–638` states "Premium
Motion Moments v1 is deferred until Alpha learning-loop admission."

All six waves landed on **2026-06-27**, sixteen days *before* Alpha admission
(2026-07-13), with implementation verified present in production source at head
(§9). The Master Plan wording is stale, not wrong-in-intent: capability truth
outranks wave naming. Corrected by bounded freshness note; the wave list itself is
preserved as historical route evidence.

### 3.6 Owner decision preservation

Confirmed preserved in active authority. `ACTIVE_ROUTE_CAPSULE_v1.md:56` ("Human
Novice Proof remains downstream"), `:488–492` (Human QA Boundary: "Human QA is the
final external evidence gate… cannot be simulated or claimed internally"), and the
Node 4 ledger's closing paragraph (§5: "Mandatory later items before Human Proof
remain the separately governed Human protocol/live evidence and any future legally
admitted Sharky/motion work"). No active authority contradicts the owner decision.

## 4. Historical audit disposition

`docs/_reviews/final_deep_independent_audit_v1.md` — **SUPERSEDED_HISTORICAL**. Used
as a finding source only. No verdict in it is carried forward unexamined; every
current verdict in §10 rests on exact-head evidence.

## 5. Canonical route audit

Traced production ownership at head. Canonical learner truth is the Act0 shell route
(`lib/ui_v2/act0_shell/*`, 92 owner files), per topology map §2a.

| Route stage | Production owner | Result |
| --- | --- | --- |
| App launch → entry gate | `lib/ui_v2/app_root.dart` | OWNED |
| Placement / Welcome | `act0_placement_shell_v1.dart`, `act0_welcome_shell_v1.dart` | OWNED |
| Home / Learn | `act0_home_shell_v1.dart`, `act0_learn_path_shell_v1.dart`, `act0_shell_preview_screen_v1.dart` | OWNED |
| Lesson → theory → decision → feedback | `act0_lesson_runner_shell_v1.dart` | OWNED |
| Repair | `act0_repair_intent_contract_v1.dart`, `act0_rule_based_repair_personalization_v1.dart` | OWNED |
| Original-source recheck | `act0_repair_intent_lifecycle` family; recheck returns to the original source task | OWNED |
| Recovered / failed result | `act0_repair_outcome_projection_v1.dart` | OWNED |
| Payoff / Review | `act0_learning_run_payoff_v1.dart` (sole run-level lifecycle), `act0_review_shell_v1.dart` | OWNED |
| Next authored step | `act0_personalized_return_reason_v1.dart` → Home | OWNED |
| Explicit safe exit | Learn→Home navigation closes the learning run exactly once | OWNED |

**Debug/support route exclusion — PASS.** `parseAct0ControlledDemoHarnessEntryV1` and
`parseAct0NativeCaptureHarnessEntryV1` are reachable only through
`app_root.dart:601–606`, which is hard-gated:

```dart
final debugHarnessEntry = kReleaseMode ? null : parseAct0ControlledDemoHarnessEntryV1(...)
```

The gate is actively guarded by `test/ui_v2/act0_release_dev_menu_boundary_v1_test.dart`.
No debug, dormant, legacy, archived, or screenshot-only substitute route contributes
to any product claim in this report.

**Fresh vs unlocked truth — PRESERVED.** The route remains deliberately split into
`alpha_fresh_install_first_lesson_v1` (fresh learner lands at First Table Guide,
`0/9`, Action locked) and `alpha_action_repair_recovery_unlocked_v2` (requires
persisted production-equivalent completion of the first four W1 lessons). No
evidence at head reopens the disproved "fresh install reaches Action" claim.

## 6. Learning and content census — independently re-run at head

Re-executed, not inherited: `test/guards/learning_content_integrity_census_v1_test.dart`,
`concept_error_repair_integrity_v1_test.dart`,
`w1_w12_answer_position_distribution_contract_test.dart` — **6/6 PASS**.

| Measure | Head value | Verdict |
| --- | --- | --- |
| Assessed tasks | 291 | CONFIRMED |
| Incorrect options | 466 | CONFIRMED |
| Option distribution | 2-option 121, 3-option 165, 4-option 5 | CONFIRMED |
| Zero/one-option rows | **absent** — census emits no `0` or `1` bucket | CONFIRMED |
| Arithmetic closure | 121+165+5 = 291; (121·1)+(165·2)+(5·3) = 466 | CONFIRMED independently |
| Concept-error mapping | 20 source-owned ids, zero unclassified incorrect options | CONFIRMED |
| Same-signal repair coverage | 277/291 different-signal | CONFIRMED |
| Intentional exact replays | 14, explicit allowlist | CONFIRMED |
| Answer-order bias guard | authored stable order; not runtime-shuffled; correct positions 112/115/62/2 | CONFIRMED |
| Shortcut distractor guard | grouped-content guards pass | CONFIRMED |
| Feedback source identity | source-owned; recheck returns to original source task | CONFIRMED |
| W11/W12 transfer + terminal | 16-state active-route packet; W11 transfer identity and W12 terminal visible | CONFIRMED (Node 4 evidence, not re-captured) |
| W13 non-admission | no `world_13` / `W13` token in `act0_shell_state_v1.dart` | CONFIRMED |
| Late-world authenticity | 29 TABLE_ACTION_DECISION + 29 TABLE_CLUE_OR_RANGE_INFERENCE; terminology-only = 0 | CONFIRMED |

No future-content ambition is converted into a current product defect. The canonical
W1–W12 route meets its current contract.

## 7. Personalization / telemetry / privacy

| Requirement | Result | Evidence |
| --- | --- | --- |
| Deterministic rule-based only | PASS | `act0_rule_based_repair_personalization_v1.dart`, `act0_*_personalization_v1.dart` family |
| No ML | PASS | zero `tensorflow`/`tflite`/`onnx` reference anywhere in `lib/ui_v2/act0_shell/` |
| No remote AI | PASS | zero `openai`/`anthropic`/`http.post`/`dio`/`WebSocket` reference in the Act0 owner set |
| Network isolation | PASS | `sentry_flutter`, `http`, `firebase_*` exist as repo-wide deps but have **no Act0 consumer** |
| No hidden task-specific special case | PASS | personalization ids are generic families (position, price, starting-hand) |
| One source outcome / one repair lifecycle / one original-source recheck | PASS | repair-intent lifecycle + resolver + outcome suites |
| One recovered payoff where earned; none for failed recheck | PASS | PR #41/#44 contract preserved; `act0_learning_run_payoff_v1.dart` sole run-level lifecycle |
| Truthful Review routing | PASS | PR #46 restored deterministic repair-lifecycle coverage via the bottom-nav Practice control |
| Time-to-decision authority | PASS | bounded decision-time bucket only |
| Exactly-once completion/exit | PASS | Home tab closes the learning run once |
| No raw/private evidence projection | PASS | Telemetry Subwave 4 removed raw board-card IDs and learner-facing table-signal labels; not reintroduced |
| No hidden persistence/schema expansion | PASS | progress schema remains 16; repair-intent, learning-evidence, Review-history, resolution-receipt schemas unchanged |
| Local-only sink | PASS | `act0_telemetry_sink_v1.dart` imports only `dart:convert`, `dart:async`, `foundation`, and a local file store |

No later commit invalidated the accepted PR #41 / Subwave 4 telemetry evidence.

## 8. Visual / accessibility / frozen surfaces

Node 4 current-head evidence was treated as input, not unquestioned truth, and
re-tested where a source claim was checkable.

- Baseline/manifest freshness: Node 4 regenerated on `00073f13`; the Act0 runtime
  owner diff from PR #44 through `00073f13` is empty, and PR #49 is docs-only, so
  Node 4 visual evidence **remains valid for `4563ce2d`**. Verified, not assumed.
- Compact / standard / tall-large phone coverage, enlarged Dynamic Type, safe areas,
  CTA reachability, no destructive clipping, feedback/recheck hierarchy,
  Review/Practice/Session Summary lifecycle, W11/W12 terminal presentation,
  reduced-motion contract: **no open P0/P1/P2 reproduced at head**.
- Tablet remains deferred and non-blocking per Master Plan device policy.

**Frozen-surface result: intact.** Modern Table remains in permanent Maintenance
Mode; no exact-head regression was reproduced against it, and no aesthetic or
material-polish change was made or proposed. PR #44 feedback/recovery,
Review/Practice lifecycle, and Session Summary are unreopened.

**No Claude Design pass was performed or fabricated.** Node 4 had none; this audit
adds none. Felt-premium concerns are classified separately from mechanical defects
and never promoted above P3 without product impact.

## 9. Waves 3.10–3.15 current-state matrix

All six landed `2026-06-27`, before Alpha admission (`2026-07-13`). Implementation
presence was verified in production source at head, not read from the review docs.

| Wave | Intended user-visible effect | Backcast row | Merged implementation | Deterministic evidence at head | Status | Remaining DoD | Pre-Human mandatory |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 3.10 Premium Motion Moments | Proof-loop feels causal: choice → feedback → repair proof → session proof → replay | A — Premium Proof-Loop Motion | `d0c4b9fe` | 3 of 4 moments present in `act0_lesson_runner_shell_v1.dart`; **Street Replay reveal absent** | **PARTIALLY_LANDED** | restore the 4th moment; add active guards for moments 2–4 | **YES** |
| 3.11 Personalized Return Reason | Day-2 Home states something unwritable before the last session | B | `736ab694` | `act0_personalized_return_reason_v1.dart` + `act0_last_session_return_reason_v1.dart`, consumed by Home, preview screen, Review | **CLOSED_PROVEN** | none | no |
| 3.12 World 1 Completion Payoff | W1 completion reads as the first Core Shark Path milestone and previews W2 | C | `421589e3` | `hasWorldOneCompletionPayoff` gate present in `act0_lesson_runner_shell_v1.dart` | **CLOSED_PROVEN** | none | no |
| 3.13 Sharky Growth / Companion Tone | Foundation Sharky is warm and simple; future register structurally protected, no AI/chat | D | `f7357e77` | `Act0SharkyCoachTierV1{foundation,developing}` + `Act0SharkyGrowthStageV1` in `act0_sharky_coach_phrase_contract_v1.dart`; band selector present | **CLOSED_PROVEN** | none | no |
| 3.14 Competitive Wedge Pass | Method reads as one connected loop: clue → decision → why → targeted rep → proof | Competitive Method Wedge | `09ea9377` | exact new copy live at `act0_repair_intent_copy_guard_v1.dart:45` and `:132`; guarded by `act0_repair_intent_copy_guard_v1_test.dart` | **CLOSED_PROVEN** | none | no |
| 3.15 W2–W4 Launch Quality Packet | No quality cliff after W1 across W2–W4 | W2-W4 Launch Quality | `753f625d` | docs/content quality packet; W2–W4 content census clean at head | **CLOSED_PROVEN** | accepted gap: no dedicated W2 capture lane in `screen_review_fast_v1.sh` (tooling, P3) | no |

Five of six are closed and proven at head. One is partially landed. No wave is
reimplemented merely because its numbered PR was never created.

## 10. Finding ledger — exact head `4563ce2d`

| ID | Source | Canonical owner | Reproducibility | Sev | Learner impact | Evidence | Repair owner | Dependency | Pre-Human status | Verdict |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- | --- |
| **F-01** | this audit | Act0 lesson runner shell (motion) | deterministic, 100% | **P3** | One of four claimed premium proof-loop motion moments is missing; Street Replay steps appear without the reveal the other three proof moments use. Cosmetic/ceremony only — no mechanical, accessibility, or learning defect. | `d0c4b9fe` added `key: Key('act0_shell_street_replay_step_motion_$i')`; `git show 21b4abd0` shows that exact line **deleted** by `21b4abd0` ("feat: add street replay context", 2026-07-03). At head `lib/` contains `act0_shell_street_replay_step_$index` (`act0_lesson_runner_shell_v1.dart:15142`) with **no** motion wrapper. Zero active `_test.dart` references the motion key. | Claude Code | none | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** — required motion/ceremony is an explicit owner-named pre-Human block | **OPEN_REPRODUCED** |
| **F-02** | this audit | Act0 test-guard ownership | deterministic | **P3** | None direct. Guard-coverage gap: `act0_shell_session_summary_proof_hero_motion_reveal` exists in production with zero active `_test.dart` guard, the same exposure class that let F-01 regress undetected. | key present at `act0_lesson_runner_shell_v1.dart`; `grep -rl` across active `_test.dart` files returns 0 | Claude Code | F-01 | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** | **OPEN_REPRODUCED** |
| **F-03** | this audit | docs owner | deterministic | **P3** | None. Documentation integrity: `docs/PROJECT_RULES_VFINAL.md` is cited as an active workflow authority by the Node 4 ledger but does not exist and never has. | `ls` fails; `git log --all --diff-filter=D -- 'docs/PROJECT_RULES*'` empty; not in `git ls-files` | docs owner | none | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** (corrected in this PR) | **OPEN_REPRODUCED** |
| **F-04** | this audit | Master Plan owner | deterministic | **P3** | None. Master Plan describes Waves 3.10–3.15 as deferred pending Alpha admission; all six landed 16 days before it. | `MASTER_PLAN_v3.0.md:587,636–638` vs `git log` dates `2026-06-27` and implementation presence at head | docs owner | none | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** (corrected in this PR) | **OPEN_REPRODUCED** |
| **F-05** | this audit | Node 4 ledger owner | deterministic | **P3** | None. `DEFERRED_OUTSIDE_PRE_HUMAN` conflates four distinct dispositions; motion/Sharky rows are wrongly placed outside pre-Human. | Node 4 ledger §4, 7 rows | docs owner | none | corrected in §11 | **OPEN_REPRODUCED** |
| F-06 | Node 4 N4-R01 | test owner | n/a | P2 | stale compact visual fixture | closed by PR #48 | — | — | closed | **CLOSED_PROVEN** |
| F-07 | Node 4 (24 rows) | various | n/a | P0–P3 | content, compact reachability, route copy, proof tooling | Node 4 §4; re-validated by head census and route inspection | — | — | closed | **CLOSED_PROVEN** |
| F-08 | Node 4 (4 rows) | various | not reproducible | P1–P3 | blank CTA, summary/nav collision, sparse presentation, stale W11 filename | capture-interpretation artifacts, not product state | — | — | closed | **DISPROVED** |
| F-09 | this audit | responsive owner | deterministic | P3 | tablet welcome underfill | Master Plan device policy: tablet deferred, non-blocking | — | — | unsupported device class | **OUTSIDE_PRE_HUMAN** |
| F-10 | Node 4 | Human-proof owner | n/a | P2 | felt credibility, felt comprehension, Human protocol scope | requires live human observation | Human protocol | Human gate | Human-bound | **HUMAN_BOUND_EVIDENCE** |
| F-11 | Node 4 | curriculum owner | n/a | P2–P3 | transfer ratio, context variety, W11/W12 transfer depth, terminology drift | future content architecture | curriculum | future content | not a current-route defect | **OUTSIDE_PRE_HUMAN** |
| F-12 | Node 4 ALI-NATIVE-SHARED-001 | dormant owner | n/a | P3 | dormant preflop list, no canonical Act0 consumer | noncanonical | — | — | noncanonical | **OUTSIDE_PRE_HUMAN** |
| F-13 | Wave 3.15 | evidence tooling | deterministic | P3 | no dedicated W2 capture lane in `screen_review_fast_v1.sh` | Wave 3.15 accepted gap; reviewer-friction only | tooling owner | none | tooling | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** |
| F-14 | ACTIVE_ROUTE_CAPSULE | test owner | deterministic | P4→P3 | Same-Session test title mentions Review although continuation advances to the next authored W2 hand | pre-recorded wording debt | test owner | none | future test maintenance | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** |
| **F-15** | this audit | legacy/archive boundary owner (**non-canonical**) | deterministic, 100% | **P2 (non-canonical)** | No direct learner impact and no canonical Act0 contract affected. The correct disposition for most of this corpus is `ARCHIVED_NONCANONICAL`, not revival; see §14 Part 2. | **125 test files** in `test/ui_v2` + `test/guards` import **9 `lib/` paths that no longer exist**, so they fail to compile. All 9 are legacy/archived (`ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart`, `.../canonical_terminal_session_drill_surfaced_runner_v1.dart`, `.../world1_modern_table_adapter_v1.dart`, `.../shared_embedded_table_visual_family_v1.dart`, `ui_v2/screens/modern_table_screen_v1.dart`, `.../session_drill_player_v1_screen.dart`, `.../world1_foundations_microtask_runner_screen.dart`, `ui_v2/legacy/ui_v2_session_result_screen.dart`, `ui_v2/map/ui_v2_progress_map_screen_v2.dart`). **Zero are Act0-canonical.** The symbols moved to `lib/archive/legacy_runners/` without updating importers. Broad run: `flutter test test/ui_v2 test/guards` → **1797 passed / 250 failed**. | Claude Code | none | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** | **OPEN_REPRODUCED** |

### F-15 — why previous evidence missed it

Every green lane is a **selected-subset** lane, and none executes these directories
in full:

- required CI (`.github/workflows/ci.yaml`) runs `flutter test test/l2_*`,
  `test/packs_manifest_test.dart`, content validators, and `analyze` — never
  `test/ui_v2` or `test/guards` broadly;
- `fast_loop_world1_v1.sh` and `release_gate_world1.sh` run a policy-selected file
  set (Node 4's own record: "11 selected files, 49 tests");
- `flutter analyze` passes because it analyzes `lib/`, and the broken imports are
  in test files that the selected lanes never load.

So 125 non-compiling test files remain invisible to every gate currently in use.
This is the same class of blind spot as F-01/F-02: **a guard that no lane runs is a
guard that cannot fail.** It is a larger, precisely quantified instance of the
"missing legacy route-import test" debt that `ACTIVE_ROUTE_CAPSULE_v1.md` records as
"unrelated debt" — the real figure is 125 files, not one.

### Counts by verdict

| Verdict | Count |
| --- | ---: |
| CLOSED_PROVEN | 2 families (25 inherited rows) |
| OPEN_REPRODUCED | 6 |
| DISPROVED | 1 family (4 rows) |
| HUMAN_BOUND_EVIDENCE | 1 |
| DEFERRED_TO_LATER_PRE_HUMAN_NODE | 5 |
| OUTSIDE_PRE_HUMAN | 3 |

### Counts by severity — open findings only

| Severity | Canonical Act0 | Non-canonical | IDs |
| --- | ---: | ---: | --- |
| P0 | 0 | 0 | — |
| P1 | **1** | 0 | **F-16 #12** — known P1 Visual UX copy contract |
| P2 | **1** | **1** | **F-16** (remaining 11 canonical failures) / F-15 (legacy test-import decay) |
| P3 | 5 | 0 | F-01, F-02, F-03, F-04, F-05 |

**Stated plainly:** the audit does **not** clear the "no open canonical P0/P1/P2"
bar. F-16 is an open canonical family of 12 reproduced contract failures. F-15 is an
open non-canonical P2. This is the basis for the BLOCKED verdict in §13.

**Severity language — precise claim boundary.** What is established, and what is not:

- **Established:** all 12 failures are reproduced deterministically at exact head,
  each re-confirmed in isolation. Their *test assertions* carry P1/P2 contract
  significance — one is an explicitly named P1 copy contract, the rest sit on
  learning-loop and copy contracts recorded as CLOSED.
- **Not established:** that all 12 are already-proven user-visible product
  regressions. **Product severity is provisional** until item-by-item source
  adjudication determines, per item, whether production regressed or the test
  asserts a retired contract.
- **Why this still blocks:** an active canonical contract cannot remain red. The
  audit blocks because canonical contract authority is currently untruthful — the
  red state is unexplained — not because 12 learner-visible regressions are proven.

The severities in the table above are therefore *contract-significance* severities.
They may resolve downward for any item adjudicated `STALE_TEST`.

Every P0/P1/P2 claim required direct current-head evidence. No preference-level
premium polish is promoted above P3.

### Disproved during this audit

A key-coverage sweep initially suggested that ~206 previously guarded
`act0_shell_*` keys had disappeared from production, including the Sharky mascot
family (`..._mascot_happy`, `..._mascot_repair`, `..._presence_mascot_celebrate`).
**DISPROVED.** Those keys are runtime-interpolated from literal prefixes that are
present in `lib/` (`act0_shell_sharky_presence_mascot_`,
`act0_shell_sharky_mascot_motion_`). Sharky is broadly integrated in production
across placement, Home, lesson runner, Review, and Profile. Only F-01 survived as a
genuine removal, and it is confirmed by direct diff evidence rather than by the
heuristic. The raw key-count metric is a proxy and is not reported as a defect count.

## 11. Node 4 disposition terminology correction

The Node 4 ledger's single `DEFERRED_OUTSIDE_PRE_HUMAN` bucket (7 rows) is split
truthfully. This corrects terminology only; no Node 4 mechanical closure is reopened
and the ledger's "no remaining open Act0 visual P0/P1/P2" result stands.

| Node 4 row | Old disposition | Corrected disposition | Basis |
| --- | --- | --- | --- |
| ALI-NATIVE-SHARED-001 | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | dormant, no canonical Act0 consumer |
| W10W12-DCA-005, -006 | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | future content architecture |
| W10W12-DCA-010 (felt credibility) | DEFERRED_OUTSIDE_PRE_HUMAN | **HUMAN_BOUND_EVIDENCE** | requires live human observation |
| W10W12-DCA-009 | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | future copy maintenance, P3 |
| CODEX-HARD-001, PREHQA-001 | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | unsupported device class per Master Plan tablet policy |
| CODEX-HARD-004, PREHQA-010 | DEFERRED_OUTSIDE_PRE_HUMAN | **HUMAN_BOUND_EVIDENCE** | Human protocol scope |
| CODEX-HARD-009 (felt comprehension) | DEFERRED_OUTSIDE_PRE_HUMAN | **HUMAN_BOUND_EVIDENCE** | requires human observation |
| CODEX-HARD-010 (W11/W12 transfer depth) | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | future content |
| PREHQA-009, -011 (capsule/plan wording) | DEFERRED_OUTSIDE_PRE_HUMAN | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** | partially closed by this audit (F-03/F-04) |
| PREHQA-012 (corpus size) | DEFERRED_OUTSIDE_PRE_HUMAN | **OUTSIDE_PRE_HUMAN** | tooling, non-product |
| **GR-11, GR-14, GR-16** (future visual/motion/Sharky) | DEFERRED_OUTSIDE_PRE_HUMAN | **DEFERRED_TO_LATER_PRE_HUMAN_NODE** | **material correction** — the owner decision names required Sharky production integration and required motion/touch/ceremony as mandatory pre-Human blocks; this family is inside pre-Human, deferred to a later node |

## 12. Validation record — all executed on this audit branch at `4563ce2d`

| Check | Result |
| --- | --- |
| `flutter analyze` | **PASS** — No issues found (14.3s) |
| `./tools/fast_loop_world1_v1.sh` | **PASS** — TOOLS LINT PASS, analyze clean, FAST LOOP PASS |
| Content/option census guard | **PASS** — 291/466, 121/165/5 |
| Concept-error + repair integrity guard | **PASS** — taxonomy exact/unique/route-complete; 34 fallbacks dispositioned |
| Answer-position distribution guard | **PASS** — authored order, not runtime-shuffled; fingerprint freshness distinguishes source vs generator drift |
| `test/ui_v2` + `test/guards` broad suite | **FAIL — 1797 passed / 250 failed** (reproduced twice). 238 are compile errors in the 125 legacy-import files of F-15; **12 are genuine Act0-canonical assertion failures (F-16)**, each re-confirmed in isolation. |
| F-16 isolation re-run (4 files) | **FAIL — 40 passed / 6 failed**, confirming the canonical failures are not suite pollution |
| `git diff --check` | **PASS** |
| `graphify hook-check` | **PASS** |
| Required GitHub checks on `4563ce2d` | **PASS** — 5 success, 1 conditional skip |
| Computer Use | **NOT ENABLED** — no surviving admission-critical ambiguity |

## 13. Audit verdict

**FINAL_DEEP_INDEPENDENT_AUDIT_BLOCKED**

Much of the product is genuinely healthy: the canonical route, content census,
telemetry/privacy, and frozen surfaces all held under independent re-verification
(§5–§8). But the audit cannot return PASSED, because PASSED requires "no false
closure claim" and that condition fails at head.

### F-16 — reproduced blocker family

**12 Act0-canonical contract failures at `4563ce2d`**, each reproduced in isolation
(not suite pollution), each on a surface currently recorded as CLOSED:

| # | Test | Failing contract |
| ---: | --- | --- |
| 1–2 | `test/ui_v2/act0_instruction_content_policy_v1_test.dart` | EN **and** RU authored instruction blocks exceed the compact contract — e.g. `ru first_table_guide_route_roles`, `ru continue_or_let_go_medium_open`, `ru apply_btn_open`, `ru w4_value_intro` each "contains 3 sentences; expected at most 2" |
| 3 | `test/ui_v2/act0_wave1_canonical_correctness_trust_v1_test.dart` | W4–W6 canonical runners display adjacent stale subtitles |
| 4–5 | `test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart` | no-proof completion fallback; `act0_proof_icon_v1_reinforced` **absent** from `act0_shell_band_transition_completion_payoff` |
| 6 | `test/ui_v2/act0_repair_outcome_consumer_v1_test.dart` | expected `'You missed this clue before. On a later hand, you caught it.'`; production emits generic `'1 completed repair now has later supporting evidence'` |
| 7–9 | `test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart` | W10 hidden learning arc; evidence writing; unknown-choice rejection |
| 10 | `test/ui_v2/act0_sharky_improvement_observation_v1_test.dart` | "one repair yields at most one acknowledgement" — acknowledgement idempotency |
| 11 | `test/ui_v2/session_result_world1_onboarding_payoff_test.dart` | early W1 result surface falls back to generic campaign framing |
| 12 | `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart` | known **P1** Visual UX copy no longer bounded/unambiguous |

**Canonical owner:** Act0 shell — specifically the Sharky improvement/repair-receipt
seam (`act0_sharky_improvement_observation_v1.dart`,
`act0_repair_outcome_consumer_v1.dart`), the band-transition milestone payoff, the
authored instruction-copy policy (EN + RU), and the W10 internal source template.

**Severity:** at least one is an explicit **P1** copy contract (#12); the Sharky
acknowledgement idempotency (#10) and the repair-receipt copy (#6) sit directly on
the learning-loop proof surfaces that Phase 5 "Sharky Saw You Improve" and the
PR #41/#44 family record as CLOSED / NATIVE PROVEN.

**Why previous evidence missed it — the same blind spot as F-01/F-02/F-15.** Every
gate in use is a selected-subset lane: required CI runs `test/l2_*` + validators +
`analyze`; `fast_loop_world1_v1.sh` and `release_gate_world1.sh` run a
policy-selected file set (Node 4's own record: "11 selected files, 49 tests"). No
lane executes `test/ui_v2` or `test/guards` in full, so these 12 failures — and the
125 non-compiling files of F-15 — have been invisible to every closure claim made on
top of them. `flutter analyze` cannot see them because it analyzes `lib/`, and the
failures are assertion-level, not static.

This is why the audit blocks rather than passes: several surfaces were certified
CLOSED on evidence that structurally could not have detected these failures.

### What did hold

- no hidden route-owner contradiction — canonical ownership traced end to end, debug
  routes release-gated and actively guarded (§5);
- content census independently reproduced at head — 291/466, 121/165/5 (§6);
- telemetry/privacy valid — no ML, no remote AI, no network consumer in Act0,
  schemas unchanged (§7);
- frozen surfaces intact; Modern Table untouched (§8);
- Node 4's *visual* mechanical closure remains valid, terminology corrected (§11).

None of the 12 failures reopens Modern Table or contradicts the telemetry/privacy
result.

## 14. Bounded repair packet (no implementation performed)

**Pre-Human Node 5 — Canonical Guard-Lane Truth Restoration.**

The audit is blocked, so the next node is the repair packet below, not the
previously indicated motion work. Three bounded parts, in order. **No implementation
was performed by this audit.**

**Part 1 — adjudicate and repair the 12 canonical failures (F-16).** For each of the
12, decide explicitly whether the *test* asserts a stale contract or the *production
source* regressed, and record that verdict per item. Do not delete or relax an
assertion to make a lane green — per topology map §7 that requires an explicit
contract verdict. Highest priority: #12 (P1 copy contract), #10 (Sharky
acknowledgement idempotency), #6 (repair-receipt copy), #4–5 (band-transition proof
icon), because these sit on surfaces recorded as CLOSED.

**Part 2 — dispose of the F-15 legacy corpus by ownership, not by compilation.**

Explicitly **not** the instruction: "restore or repoint all 125 legacy imports."
Making a broad directory command green is not a goal, and green compilation is not
evidence of contract ownership.

Instead:

- classify the affected corpus by **current ownership**;
- migrate or repair **only** tests proven to own a current canonical contract that
  has no active canonical replacement;
- archived/noncanonical tests must **not** be revived merely to satisfy a broad
  directory command — the correct disposition for most of this corpus is
  `ARCHIVED_NONCANONICAL`;
- **no dormant runner, archived Modern Table owner, or legacy progression system may
  become active authority through this repair.** Reviving a legacy guard would
  promote an archived runtime to canonical evidence, which is the opposite of the
  intended outcome.

Where a unique current contract is found inside an archived-owner test, extract it
into an owner-aligned focused test against the current production owner, and drop
the archived-runner dependency rather than repointing to it.

**Part 3 — close the blind spot that caused all of this (F-01, F-02, F-16).** Add a
gate that actually compiles and runs `test/ui_v2` and `test/guards` in full, so
"selected lane green" can no longer be mistaken for "canonical contracts hold". Then
restore the Wave 3.10 Street Replay reveal (F-01) and add active guards for
proof-loop motion moments 2–4 (F-02).

Constraint for all parts: no new asset, no new dependency, no table motion, no
replay playback renderer, no Modern Table change, no telemetry schema change.

After this node closes, the next unfinished pre-Human capability is **Premium Motion
& Ceremony Completion**, whose remaining scope is F-01/F-02 (folded into Part 3
above). Human Novice Proof remains downstream and is not authorized.

### Superseded PASS reasoning (retained for traceability)

The following was this audit's reasoning before the broad-suite run; it is retained
so the correction is auditable rather than silently replaced.

Basis for the previously indicated next capability:

1. The owner decision names required motion/touch/ceremony and required Sharky
   production integration as mandatory pre-Human blocks.
2. F-01 is the only reproduced product-surface gap at head: a Wave 3.10 proof-loop
   motion moment that landed and was then silently removed.
3. F-02 shows the guard gap that allowed it, so the repair must include regression
   guards, not just restoration.
4. Every other pre-Human family is either closed and proven, Human-bound, or
   genuinely outside pre-Human (§10, §11).

F-01, F-02, and F-15 share one root cause — **a guard that no lane runs is a guard
that cannot fail** — so Node 5 has two bounded parts:

**Part A — restore the missing ceremony (canonical, owner-mandated pre-Human).**
Restore the Street Replay reveal using the existing shared local proof-reveal wrapper
and existing `Act0MotionTokensV1` tokens; add active `_test.dart` guards for
proof-loop motion moments 2–4; preserve the reduced-motion structural bypass. No new
asset, no new dependency, no table motion, no replay playback renderer, no Modern
Table change.

**Part B — restore guard-lane integrity (non-canonical, P2).** Repoint the 125
legacy-import test files at `lib/archive/legacy_runners/…`, or explicitly
decommission the ones whose contracts are genuinely retired — per topology map §7,
that decision requires an explicit contract verdict and must not be made to silence
a red lane. Then add a gate that actually compiles `test/ui_v2` and `test/guards` so
this class cannot recur. Part B changes no product source.

Part A is mandatory before Human Proof. Part B is strongly recommended before Human
Proof because it is what currently prevents any lane from detecting a Part-A-style
regression, but it is a test/tooling repair, not a learner-facing block.

Human Novice Proof remains downstream and is not authorized by this audit.
