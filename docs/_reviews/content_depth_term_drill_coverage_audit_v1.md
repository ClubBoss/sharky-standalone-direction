# Content Depth / Term Introduction / Drill Coverage Audit v1

## Scope

Audit / PIEC only. No content expansion, product UI, copy, routes, telemetry,
Modern Table visuals, screenshot tooling, monetization, AI/chat/ML,
dashboard/XP/economy, Sharky implementation, or external visual
recommendation implementation changed.

This audit asks whether Sharky has enough learning depth, term clarity, drill
coverage, and same-signal reinforcement to support the current top-1 route:

`repair proof -> return proof -> content depth proof -> personalization proof -> monetization proof`

## Evidence used

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/top1_route_recalibration_after_day2_v1.md`
- `docs/_reviews/daily_trainer_habit_loop_learning_depth_piec_v1.md`
- `docs/_reviews/first_return_day2_proof_acceptance_v1.md`
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
- `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md`
- `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md`
- `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`
- `docs/plan/LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md`
- `docs/plan/ADAPTIVE_SPACED_REPETITION_SSOT_v1.md`
- `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md`
- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
- `content/world1_act0_*/v1/`
- `content/worlds/world*/v1/`
- `content/_meta/term_registry.jsonl`
- `content/_meta/world_sessions_manifest_v1.json`
- `content/_meta/world_drills_manifest_v1.json`
- `assets/content/*`
- `lib/ui_v2/act0_shell/*`
- content validators and scanners under `tools/`
- Act0/content/repair tests under `test/`

Commands run for evidence:

```bash
git status --short
git branch --show-current
git fetch origin
git rev-parse origin/main
git rev-parse HEAD
dart run tools/term_coverage_scanner.dart
dart run tools/unknown_uppercase_scanner.dart
```

No screenshot commands were run.

## Target user anchor

The target learner is the casual-to-serious / micro-stakes player who already
plays poker, makes mistakes, and wants to understand quickly what to fix.

This learner does not need solver-pro tooling first. They need:

1. clear table signals;
2. enough examples to stop guessing;
3. terms introduced before they become decision requirements;
4. repeated same-signal repairs;
5. credible depth beyond the free foundation before premium is implemented.

## World/module coverage table

Two layers exist and should not be confused:

1. The active Act0 app state exposes W1-W12 in
   `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
2. The external authored `content/worlds/` tree has concrete folders through
   `world10/v1`; W11-W12 are active in the app state but do not yet have
   matching `content/worlds/world11` or `content/worlds/world12` folders.

| Area | Evidence | Playable / surfaced | Theory present | Interaction present | Feedback present | Repair / recheck present | Tests / validators present | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Act0 first-week modules | `content/world1_act0_table_literacy`, `action_literacy`, `street_flow`; active shell | Yes, current first-week route | Yes, compact theory | Thin: 12 JSONL drills total across 3 modules | Not in JSONL fields; active shell supplies feedback | Yes through active Act0 repair loop | Strong Act0 tests; first-week proof lane | Strong for first value, thin as standalone content inventory |
| W0 Table Literacy content | `content/worlds/world0/v1` | Content exists, not current Learn-map world | Yes | 10 sessions / 71 drills | 71 feedback, 14 `why_v1` | Some repeat/focus variants | Many W0 references and validators | Useful support/onboarding content, but product policy says avoid World 0 map confusion |
| W1 Poker from Zero / Hand Discipline | app `world_1`; content `world1/v1` | Yes | Yes | 10 sessions / 98 drills | 27 feedback, 41 `why_v1` | Strong repair in Act0; content has repeat/focus/checkpoint IDs | Heavy W1/Act0 tests | Strong free-foundation anchor |
| W2 Position / table-reading bridge | content `world2/v1` | Yes in content/runtime tests | Yes | 17 sessions / 135 drills | 127 feedback, 127 `why_v1` | Good family-specific validators | World2 validators for texture, position, initiative, showdown, seat, board, action | Strongest deterministic content coverage |
| W3 Preflop / hand buckets | app `world_4` maps the concept; content `world3/v1` | Yes | Yes | 14 sessions but only 18 drills | 4 feedback, 7 `why_v1` | Some hand-chain/checkpoint reps | World3 routing/contracts exist | Thin drill density relative to neighboring worlds |
| W4 Bet Purpose + Price | app `world_5`; content `world4/v1` | Yes | Yes | 10 sessions / 123 drills | 80 feedback, 120 `why_v1` | Strong bet-purpose families | World4 routing/content tests | Strong, good candidate for premium boundary proof |
| W5 Board And Draws | app `world_6`; content `world5/v1` | Yes | Yes | 10 sessions / 38 drills | 30 feedback, 30 `why_v1` | Some texture chain coverage | World5 routing/runtime tests | Acceptable concept home, but thin compared with W4/W6 |
| W6 Range Thinking Lite | app `world_7`; content `world6/v1` | Yes | Yes | 10 sessions / 88 drills | 82 feedback, 82 `why_v1` | Strong range/equity/blocker intents | World6 range/action tests | Solid, but term scaffolding needs safer gating |
| W7 Stack Depth And Risk | app `world_8`; content `world7/v1` | Yes | Yes | 10 sessions / 86 drills | 82 feedback, 82 `why_v1` | Good stack-depth families | World7 gates/tests | Solid |
| W8 Tournament Pressure | app `world_9`; content `world8/v1` | Yes | Yes | 10 sessions / 86 drills | 82 feedback, 82 `why_v1` | Risk premium / bubble families | World8 gates/tests | Solid, but ICM/risk-premium terms need careful intro |
| W9 Player Adjustment | app `world_10`; content `world9/v1` | Yes | Yes | 10 sessions / 86 drills | 82 feedback, 82 `why_v1` | One-lever/exploit families | World9 gates/tests | Solid |
| W10 Track / specialization bridge | content `world10/v1`; app W10 is Player Adjustment, not specialization | Partially surfaced / deeper route | Yes | 40 drill-bearing sessions / 325 drills including tracks | 322 feedback, 322 `why_v1` | Track-specific repeat and handoff coverage | Many W10 tests/gates | Strong authored depth, but product-route naming/ownership should be clarified before premium packaging |
| W11 Real Play Transfer | app `world_11` hardcoded with runner tasks | Locked app surface exists | Yes in Dart state | App-state tasks exist | App-state feedback exists | Review-loop and transfer tasks exist | Only light W11 references found in broad preview test | Product-visible content exists, but not mirrored in `content/worlds/` |
| W12 Mindset Bridge | app `world_12` hardcoded with runner tasks | Locked app surface exists | Yes in Dart state | App-state tasks exist | App-state feedback exists | Process/reset/discipline repair framing exists | Only light W12 references found in broad preview test | Product-visible content exists, but not mirrored in `content/worlds/` |
| W13-W36 | Long-term reference docs | Docs-only | Planning only | Missing runtime/authored content | Missing | Missing | No active content proof | Missing for premium depth beyond the early bridge |

## Concept depth table

| Concept family | First safe home observed | Examples / drills observed | Repair opportunities | Recheck / same-signal opportunities | Depth verdict | Notes |
| --- | --- | ---: | --- | --- | --- | --- |
| Table anchors, BTN/SB/BB, action order | Act0 table literacy; W0/W1 | W0 has 71 drills; Act0 table module has 6 JSONL drills | Yes through Act0 repair focus | Yes through same-signal repair mapper for early tasks | Strong | Good first-session fit. Abbreviations appear in active labels but the first theory spells out Button, Small Blind, Big Blind. |
| Fold/check/call/raise legality | Act0 action literacy; W1 | Act0 action module has 3 JSONL drills; W1 has many action-choice drills | Yes, active first-week uses `actions_check_drill` | Yes, explicit same-signal mapping targets `actions_check_drill` | Strong in active route, thin in source JSONL | The visible product has strong repair proof, but source module density is small. |
| Street flow | Act0 street flow; W0/W1 | Act0 street module has 3 JSONL drills; W0 includes board/street taps | Partial | Partial | Acceptable | Enough for first-week proof, but not a deep trainer family by itself. |
| Hand discipline / bucket logic | W1/W3 app and content | W1 98 drills; W3 only 18 content drills | Yes | Yes through repair/result/session loop | Acceptable but uneven | W1 is strong; W3 external content drill density is thin. |
| Position thinking | W2 app/content and W3 support | W2 has 135 drills and several validators | Yes | Yes | Strong | The best-proven deterministic concept family. |
| Bet purpose and price | W4 content / app W5 | 123 drills, 120 `why_v1` | Yes | Likely strong via action/bet-sizing families | Strong | Most credible W5 premium-boundary foundation. |
| Board texture / draws / outs | W5/W6 content | W5 has 38 drills; W6 has related range/equity support | Yes | Some | Acceptable / thin at W5 | Needs more same-signal variations before becoming premium proof. |
| Range thinking | W6 content / app W7 | 88 drills | Yes | Some | Acceptable | Term safety is the main risk, not absence of reps. |
| Stack depth / SPR | W7 content / app W8 | 86 drills; active app copy includes SPR examples | Yes | Some | Acceptable | SPR appears in active app-state copy; glossary registry exists but inline introduction proof is weak. |
| Tournament pressure / ICM | W8 content / app W9 | 86 drills | Yes | Some | Acceptable | ICM and risk premium are registry-backed but need beginner-safe intro gates. |
| Player adjustment / exploit | W9 content / app W10 | 86 drills | Yes | Some | Acceptable | Avoids solver positioning; "exploit" has registry entry. |
| Track specialization / format transfer | W10 content | 325 drills across base and tracks | Partial | Partial | Strong authored depth, route-ownership needs cleanup | Good premium-support asset, but not yet a clear monetization-ready product package. |
| Real play transfer | App W11 | App-state tasks exist | Yes in review-loop framing | Not fully proven as content-world folder | Thin / unmirrored | Needs external content representation and tests beyond broad preview references. |
| Mindset / variance / reset | App W12 | App-state tasks exist | Yes in process/reset tasks | Not fully proven as content-world folder | Thin / unmirrored | Valuable, but should not be used as premium proof until mirrored and tested. |
| Personalized repair / same-signal loop | Act0 repair intent, rule-based decision, review/profile | Active first-week and Day 2 proof lanes | Strong | Strong for selected first-week/return states | Strong product mechanism | Content breadth behind same-signal mapping is narrower than the repair UI suggests. |

## Term-introduction risk table

Existing registry:

- `content/_meta/term_registry.jsonl` contains 22 terms, including `EQUITY`,
  `EV`, `POT_ODDS`, `SPR`, `BLOCKERS`, `ICM`, `LEAK`, `EXPLOIT`,
  `RISK_PREMIUM`, and related strategy terms.

Scanner results:

- `dart run tools/term_coverage_scanner.dart` found uncovered registry terms
  in reference theory: `SPR`, `BLOCKERS`, `EQUITY`, `EXPLOIT`, `PROBE`, `EV`.
- `dart run tools/unknown_uppercase_scanner.dart` found unknown uppercase
  tokens in reference theory: `PFA`, `DB`.

| Term / family | Where risk appears | Severity | Why it matters | Recommended fix type |
| --- | --- | --- | --- | --- |
| BTN / SB / BB | Active runtime labels and table-copy registry; Act0 table theory spells out Button, Small Blind, Big Blind | Medium | Abbreviations are central and appear early. They are mostly safe because first theory expands them, but table labels still rely on compact abbreviations. | Inline definition / first-use tooltip-style support in W1 and Welcome proof packet, not a glossary-first system |
| BB as big-blind unit | App locked-world copy such as `100 BB` / `20 BB`; runtime stack labels | Medium | `BB` means both Big Blind seat and big-blind unit; beginners can confuse these. | Inline definition when stack-depth world opens |
| Range | Practice and locked Learn route labels; W6 content | Medium | "Range" is a known poker term but not always beginner-safe. | Short "range = likely hands" definition before W6/W7 tasks |
| Pot odds / price | Legacy `assets/content/core_pot_odds`; W4/W5 purpose-price route | Low / medium | The current product increasingly uses "price" safely, but older content uses Pot Odds directly. | Prefer price first, introduce "pot odds" as the formal term after examples |
| Equity / fold equity / equity realization | Active shell W5+ app-state copy and term registry | High for W5+ | Term appears in later-world copy; definition exists but inline introduction is not proven. | Term Introduction / Glossary Safety Fix before premium packaging |
| SPR | Active app-state W8 examples and reference theory | High for W5+ | Acronym is advanced and scanner finds uncovered instances. | Inline definition and first-use gate in stack-depth world |
| Blockers | W6+ registry/reference and app copy | Medium / high | Good strategic term, but too abstract if used before card-removal examples. | Concrete card-removal example before term label |
| ICM / risk premium | W8 tournament content and registry | Medium / high | High-value tournament concept but easy to overload. | "Tournament chips are not cash chips" visible model before acronym |
| Exploit / leak / probe | W9+ content/reference | Medium | Good target-segment vocabulary, but "exploit" can sound adversarial or technical. | Keep one-lever beginner framing; define before repeated use |
| GTO / solver / optimal / MDF | Mostly guard/import/reference evidence, not active learner copy | Low now | Product constraints correctly avoid solver-first claims. | Keep guard; do not introduce in first-week/free proof |

Term verdict: **high priority but not a first-week blocker.** The first-week
route is mostly safe. The W5+ premium-depth route is not safe enough until
registry-backed terms receive deterministic first-use checks and inline
definitions.

## Drill / same-signal coverage table

| Family | Current evidence | Same-signal / repair evidence | Verdict |
| --- | --- | --- | --- |
| Act0 first-week decision | `actions_check_drill`; Welcome/W1 decision and feedback proof lanes | Explicit same-signal mapping in `act0_shell_preview_screen_v1.dart`; repair intent contract/resolver/lifecycle tests | Strong product proof |
| Table anchors / seat taps | W0/W1/W2 seat-tap content and validators | Repair focus labels and active review queue can point back to missed signal | Strong |
| Action choices | W1/W2/W4+ action-choice families | Good repair UI, but content-level same-signal catalog is not separately inventoried | Acceptable |
| Bet sizing / purpose | W4 has 40 bet-sizing drills and strong `why_v1` coverage | Repair can reuse task families, but same-signal replay count not separately proven | Strong content, acceptable repair proof |
| Board texture | W5 has 30 texture drills; W2 validators cover board texture too | Some same-family repair path exists | Acceptable but expand before premium |
| Range bucket | W6 has only 2 explicit `range_bucket_classifier_v1` drills in content count | Repair exists at product level; drill breadth is narrow | Thin |
| Stack depth / tournament pressure / exploit | W7-W9 each around 86 drills with repeated interaction shape | Product repair system can route, but same-signal family catalogs are not obvious | Acceptable, needs proof inventory |
| W10 tracks | 325 drills across base/tracks | Repetition exists; personalization/same-signal linkage to premium track content not proven | Strong authored depth, weak product packaging proof |
| W11/W12 transfer/mindset | App-state tasks exist | Product repair/history integration not proven as content-world inventory | Thin / unmirrored |

Drill verdict: **solid for W1-W4 and strong in selected W5-W10 pockets, but
same-signal coverage is proven more by the Act0 repair mechanism than by an
auditable per-concept replay inventory.** That is enough for current proof
packets, not enough for monetization.

## W1-W4 free readiness verdict

**Mostly ready for the free foundation.**

Reasons:

- W1-W4 are visible in the active Act0 route.
- First-week and Day 2 proof packets show the repair/return loop.
- W1-W4 have meaningful content and tests, especially table/position/action
  families.
- W4 bet purpose and price has strong drill and `why_v1` density.

Risks:

- The external `content/worlds/world3` drill count is thin relative to W1/W2/W4.
- Act0 first-week JSONL source modules are tiny even though active shell
  product behavior is richer.
- W1-W4 term safety is mostly good, but `BB` as both seat and unit needs care.

Verdict: **W1-W4 can support free public value after targeted term safety and
thin-slice content cleanup, but they should not be treated as final store-grade
pedagogy without human content review.**

## W5+ premium depth verdict

**Not structurally ready for monetization implementation.**

Reasons:

- The locked route says `W5+` is future paid depth.
- Authored `content/worlds/` depth exists through W10, with strong pockets in
  W6-W10 and especially W10 tracks.
- Active app state exposes W11-W12, but matching `content/worlds/world11` and
  `content/worlds/world12` folders are absent.
- W13-W36 are planning/reference only, not playable premium content.
- Several W5+ concepts depend on terms that scanners show are not fully
  introduction-safe.
- Premium value would be fragile if W5+ ships as mostly locked labels,
  hardcoded app-state tasks, and roadmap promises.

Verdict: **W5+ can be previewed as future depth, but premium should not be
implemented or sold until W5 has a release-grade foundation pack and the
W5-W12 route has mirrored content inventory, term gates, and same-signal repair
coverage.**

## Top blockers to 10/10 content depth

1. **Term introduction safety is not mechanically enforced across active and
   premium-side content.** Registry exists, but scanner output proves uncovered
   terms remain, and active app-state copy can introduce W5+ terms without a
   content-world first-use contract.
2. **Premium-side content ownership is split.** W5-W10 have authored content,
   W11-W12 are active in app state but not mirrored in `content/worlds/`, and
   W13-W36 are planning-only.
3. **Same-signal repair is product-strong but inventory-thin.** The repair loop
   is excellent for proof, but there is no simple per-concept matrix showing
   introduced -> practiced -> repaired -> rechecked counts.
4. **Some drill density is uneven.** W3 and W5 are materially thinner than W2,
   W4, W6-W10.
5. **Practice breadth can still feel like a proof lane instead of a broad
   trainer if only the first-week/Day 2 states are reviewed.** The broader
   content exists, but the active proof packet does not yet demonstrate broad
   drill selection.
6. **W5+ monetization proof is not credible yet.** W5+ must feel like real
   depth, not locked roadmap labels.

## Implementation candidates ranked

| Rank | Candidate | Why this first / later | Output shape |
| ---: | --- | --- | --- |
| 1 | Term Introduction / Glossary Safety Fix | Highest risk-to-effort ratio. It protects beginner trust and premium W5+ readiness without broad content expansion. | Add first-use term map/guard for active app-state and content theory; patch high-risk term copy only. |
| 2 | Same-Signal Drill Expansion v1 | Repair proof is the product core; it needs more auditable same-family replay coverage before broad content expansion. | Pick 3-5 high-value families: actions/check, position, bet purpose, board texture, range bucket. Add deterministic same-signal reps. |
| 3 | W5 Premium Foundation Pack | W5 is the monetization boundary and must feel like real paid-depth foundation before commerce. | Strengthen W5 board/draw/price bridge, term gates, repair replays, and proof tests. |
| 4 | W1-W4 Content Depth Completion | Free route is strong but uneven; W3 and first-week JSONL density are the main cleanup targets. | Fill thin preflop/hand-bucket examples and source-module feedback/why fields. |
| 5 | Practice Drill Breadth Expansion | Useful after same-signal expansion so Practice feels like a trainer, not only proof packet continuation. | Add visible drill-family breadth and deterministic selection proof. |
| 6 | Review / Repair Concept History | Valuable, but should follow same-signal inventory so Review does not become a dashboard. | Compact history: current focus, repaired signal, next recheck. |
| 7 | Content Factory Pipeline | Needed later for W13-W36, but premature before the specific term and W5 gaps are closed. | Inventory/count tool plus release-gate policy for concept depth. |

## Not-now list

- No commerce implementation.
- No paywall/trial/entitlement work.
- No broad W13-W36 production sprint.
- No solver/GTO positioning.
- No fake AI/adaptive claims.
- No visual redesign or Stitch/Claude recommendation implementation.
- No Modern Table work.
- No dashboard/charts/XP/economy.
- No stamina, lives, energy, or scarcity mechanics.
- No screenshot tooling changes.
- No generated output commits.

## Final recommendation

Run **Term Introduction / Glossary Safety Fix v1** first.

Rationale:

1. It is the clearest content-depth blocker with direct evidence from existing
   scanners.
2. It improves W1-W4 trust without rewriting the route.
3. It protects W5+ premium depth before commerce is even considered.
4. It creates the guardrail needed before broader same-signal or W5 expansion
   adds more terms.

After that, run **Same-Signal Drill Expansion v1** for the highest-value repair
families, then **W5 Premium Foundation Pack**.

## Exact recommended next prompt title

`Term Introduction / Glossary Safety Fix v1 - Local Only`

## Validation

Required validation for this docs-only audit:

```bash
git status --short
git diff --check
```

No Flutter tests or screenshot commands are required because this audit adds
only a review document.
