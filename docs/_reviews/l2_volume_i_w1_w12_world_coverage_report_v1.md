# L2 Volume I W1-W12 World Coverage Report v1

## 1. Verdict

`l2_volume_i_blocked_by_route_content_truth`

Volume I W1-W12 is auditable in one report, but it is not launch-coverage
ready.

The strongest blocker is route/content truth drift:

- W1 maps cleanly enough to be the first launch-coverage candidate, but only
  one non-runtime W1 L1 migrated sample is validator-backed.
- W2-W6 have active campaign-route ownership and real authored content, but
  their route-facing titles and source-world content jobs do not align cleanly.
- W7-W10 have substantial authored/internal content and guards, but they remain
  locked/not learner-playable in the active route and also show route/title
  drift.
- W11-W12 have source/proof packets, but they remain authored-but-not-routed
  with no active campaign route.

This report does not move product scores by itself. It reduces planning risk
and selects the next safe implementation/control-plane step:

`W2-W6 Route/Content Normalization`.

## 2. Source Truth

Focused files inspected and why:

- `AGENTS.md`: active repo boundary, Act0 route truth, no archive/donor roots,
  and docs-only validation constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  Act0 shell as canonical learner-facing runtime.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch target,
  W13-W36 deferral, and forbidden launch claims.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: score ledger, active
  repair queue, W1-W12 quality bar, and next-wave candidates.
- `docs/_reviews/volume_i_launch_scope_rebaseline_v1.md`: accepted launch-scope
  rebaseline and W1-W12/W13-W36 boundary.
- `docs/_reviews/wave6_3_content_factory_mvp_l1_migrated_sample_v1.md`:
  accepted L1 migrated W1 sample and still-open L2/factory/normalization gates.
- `docs/_reviews/wave6_2_content_validation_rules_v1.md`: L0 validator status
  and deferred L2/L3/L4 rules.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: required schema fields, route
  gate values, source-truth values, and coverage rules.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0-L4 validation ladder
  and coverage-threshold rules.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  W1-W6 content volume, same-signal evidence, schema-field absence, and
  W2-W6 route/title drift.
- `docs/_reviews/wave5_2_w7_w12_route_truth_reconciliation_v1.md`: W7-W12
  route-truth conflict classification and W11-W12 authored-but-not-routed
  posture.
- `docs/_reviews/wave5_2_w7_w10_current_campaign_status_alignment_v1.md`:
  accepted W7-W10 locked-not-learner-playable follow-up.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`: active Act0 world cards,
  route-facing titles, lock state, and selectable state.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`: learner-visible Volume
  I copy saying W1-W6 available, W7-W10 locked preview, and W11-W12 planned.
- `lib/services/progress_service.dart`: W1-W6 campaign progression owner and
  W7-W10 terminal clamp after W6.
- `lib/campaign/campaign_pack_registry_v1.dart`: W1-W10 campaign/follow-up pack
  registry presence, treated as route-support evidence only where route gates
  allow it.
- `content/worlds/world1/v1` through `content/worlds/world12/v1`: current
  source-world titles, session counts, file counts, and authored/proof content
  inventory.
- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
  and `test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`:
  the only schema-shaped validator-backed examples found.
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`: direct guard
  proving W7-W10 are locked in the active learner route.
- `test/guards/w11_route_backed_proof_contract_test.dart` and
  `test/guards/w12_route_backed_proof_contract_test.dart`: W11/W12 source proof
  without learner visibility or campaign registration.
- Focused `test/guards/worldN_campaign_routing_contract_test.dart`,
  `test/tools/worldN_*`, and `test/ui_v2/session_drill_player_worldN_*` files:
  route/content guard evidence by world family.

No archive docs, donor roots, screenshots, or generated `output/` artifacts
were inspected.

## 3. Active Launch Scope

- Perfect W1-W12 Volume I Premium Product is the launch target.
- W13-W36 are post-launch / live expansion / advanced roadmap.
- W13-W36 are not pre-launch blockers.
- W13-W36 must not be claimed as launch-available in store, onboarding,
  paywall, marketing, or learner route copy.
- Quick public/store beta remains paused unless explicitly reactivated.

## 4. Route Truth Summary

Current route truth:

- W1: learner-playable/current Act0 entry and campaign route.
- W2-W6: available through current campaign progression, but Act0 world cards
  are locked preview cards; Learn copy states W1-W6 available.
- W7-W10: `locked_not_learner_playable`; registry/internal content can remain,
  but learner progression clamps back to the W6 terminal follow-up gate.
- W11-W12: `authored_but_not_routed`; source/proof packets exist, but no active
  campaign route or prior-world handoff is enabled.
- W13-W36: out of scope and not a launch dependency.

Route/content title drift:

- W1 route title and content job align.
- W2 route title is Hand Discipline; content world job is broad table-reading
  bridge.
- W3 route title is Position Thinking; content world job is Preflop Framework.
- W4 route title is Preflop Framework; content world job is Bet Purpose and
  Price.
- W5 route title is Bet Purpose And Price; content world job is Board
  Awareness.
- W6 route title is Board And Draws; content world job is Range Thinking.
- W7 route title is Range Thinking Lite; content world job is Stack Depth.
- W8 route title is Stack Depth And Risk; content world job is Tournament /
  intuitive ICM.
- W9 route title is Tournament Pressure; content world job is Exploit Thinking.
- W10 route title is Player Adjustment; content world job is specialization /
  track handoff.
- W11 and W12 source titles align with Act0 titles, but neither is routed.

## 5. W1-W12 World Coverage Matrix

| World | Launch-facing title / expected job | Route status | Content source status | Schema/validator status | Same-signal coverage status | Transfer coverage status | Repair path status | Test/guard evidence | Correctness / QA risk | Primary blocker | Next safe action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | Poker from Zero / first table literacy and simple action discipline | learner-playable/current | Strong W1 source: 10 sessions, 132 source files, 98 drill files; Act0 packs plus W1 spine | Content is schema legacy; one W1 L0 fixture and one L1 migrated sample are validator-backed | Strong but mostly inferred from filenames/intents; L1 sample covers one starting-hand discipline rep | Present but mostly inferred; one L0 fixture has transfer field | Runtime/feedback repair exists; one L1 sample has repair_focus_id | Large W1 guard set plus L0/L1 validator fixture tests | Needs human novice QA and poker review for public premium claims | blocked_by_schema | Migrate/report W1 coverage through L2/L3 after W2-W6 route truth is normalized |
| W2 | Hand Discipline | active campaign-owned, Act0 locked card | Real source: 14 sessions, 190 files, 135 drill files; content job is table-reading bridge | Schema legacy; no content-world schema fields found; no L1 sample | Partial/inferred; Wave 5.3 found several thin or bridge families | Bridge transfer exists but fieldless | Feedback/review patterns exist; no source-owned repair_focus_id | W2 route, board, seat, initiative, outs, and rendered tests | Human QA needed; table-reading breadth risks overclaiming Hand Discipline | route_content_drift | Normalize W2 route title/content owner/status before authoring or factory work |
| W3 | Position Thinking | active campaign-owned, Act0 locked card | Real source: 14 sessions, 64 files, 18 drill files; content job is Preflop Framework | Schema legacy; no content-world schema fields found; no L1 sample | Strong/inferred preflop chain arc | Transfer exists in chain form, not fielded | Feedback exists; no source-owned repair_focus_id | W3 route, hand-chain validator, and rendered slice tests | Poker correctness and human QA needed before premium claims | route_content_drift | Normalize W3 route title/content owner/status before coverage claims |
| W4 | Preflop Framework | active campaign-owned, Act0 locked card | Real source: 10 sessions, 157 files, 123 drill files; content job is Bet Purpose and Price | Schema legacy; no content-world schema fields found; no L1 sample | Strong/inferred purpose-price coverage | Present through action/size surfaces, not schema-fielded | Feedback exists; no source-owned repair_focus_id | W4 route guard and intent normalization tests | Sizing/purpose advice needs review before public 10/10 claims | route_content_drift | Normalize W4/W5 title/content boundary before migration |
| W5 | Bet Purpose And Price | active campaign-owned, Act0 locked card | Real source: 10 sessions, 75 files, 41 drill files; content job is Board Awareness | Schema legacy; no content-world schema fields found; no L1 sample | Strong/inferred board texture coverage | Present through texture-to-action and street-shift surfaces, not fielded | Feedback/recap exists; no source-owned repair_focus_id | W5 route guard, early runtime truth, and same-signal test evidence | Board/draw correctness and human QA needed | route_content_drift | Normalize W5 route/content identity before factory migration |
| W6 | Board And Draws | active campaign terminal, Act0 locked card | Real source: 10 sessions, 127 files, 92 drill files; content job is Range Thinking | Schema legacy; no content-world schema fields found; no L1 sample | Strong/inferred range/action aggregate; direct range bucket coverage usable but fragile | Present through range/board transitions, not fielded | Feedback exists; no source-owned repair_focus_id | W6 route guard, range bucket runtime truth, and surface tests | Range advice needs poker review and human QA | route_content_drift | Normalize W6 route/content identity and preserve W6 terminal gate |
| W7 | Range Thinking Lite | locked_not_learner_playable | Internal authored source: 10 sessions, 121 files, 86 drill files; content job is Stack Depth | Schema legacy; no content-world schema fields found; no L1 sample | Likely present from source volume/tests, but not route-claimable | Not claimable while locked and fieldless | Internal feedback likely exists; no source-owned repair_focus_id | W7 route guard now expects W6 terminal gate; W7 content/tool tests exist | Advanced stack-depth correctness and human QA required | locked_requires_admission | Keep locked; later W7-W12 admission/content lock after W2-W6 normalization |
| W8 | Stack Depth And Risk | locked_not_learner_playable | Internal authored source: 10 sessions, 121 files, 86 drill files; content job is Tournament / ICM | Schema legacy; no content-world schema fields found; no L1 sample | Likely present from source volume/tests, but not route-claimable | Not claimable while locked and fieldless | Internal feedback likely exists; no source-owned repair_focus_id | W8 route guard now expects W6 terminal gate; W8 surface/tool tests exist | Tournament/ICM correctness and human QA required | locked_requires_admission | Keep locked; resolve title/content sequence before admission |
| W9 | Tournament Pressure | locked_not_learner_playable | Internal authored source: 10 sessions, 121 files, 86 drill files; content job is Exploit Thinking | Schema legacy; no content-world schema fields found; no L1 sample | Likely present from source volume/tests, but not route-claimable | Not claimable while locked and fieldless | Internal feedback likely exists; no source-owned repair_focus_id | W9 route guard now expects W6 terminal gate; W9 surface/tool tests exist | Exploit advice correctness and human QA required | locked_requires_admission | Keep locked; resolve route/content status before admission |
| W10 | Player Adjustment | locked_not_learner_playable | Internal authored source: 10 sessions, 455 files, 325 drill files; content job is specialization / track handoff | Schema legacy; no content-world schema fields found; no L1 sample | Likely present from source volume/tests, but not route-claimable | Not claimable while locked and fieldless | Internal feedback likely exists; no source-owned repair_focus_id | W10 route guard now expects W6 terminal gate; W10 track/tool tests exist | Track advice correctness, W10 terminal semantics, and human QA required | locked_requires_admission | Keep locked; decide W10 terminal/track handoff only after W7-W9 admission |
| W11 | Real Play Transfer | authored_but_not_routed | One source session/proof packet: 7 files, no drill files | Source/proof fixtures exist but not Content Schema Foundation L1 sample | Insufficient for launch coverage; source proof only | Insufficient for launch coverage; source proof only | Source process/review proof exists, not route-owned repair | W11 route-backed proof and admission/runtime guards prove no learner visibility | Real-play/process claims need human QA and correctness review | authored_but_not_routed | Keep authored but non-routed; admit only after W7-W10 truth and W10 handoff |
| W12 | Mindset Bridge | authored_but_not_routed | One source session/proof packet: 7 files, no drill files | Source/proof fixtures exist but not Content Schema Foundation L1 sample | Insufficient for launch coverage; source proof only | Insufficient for launch coverage; source proof only | Source process proof exists, not route-owned repair | W12 route-backed proof and admission guards prove no learner visibility | Mindset/process claims need human QA and no false Volume I/W13 gateway | authored_but_not_routed | Keep authored but non-routed; admit only after W11 route truth and W12 boundary contract |

Primary status per world:

- W1: `launch_coverage_candidate`
- W2: `route_content_drift`
- W3: `route_content_drift`
- W4: `route_content_drift`
- W5: `route_content_drift`
- W6: `route_content_drift`
- W7: `locked_requires_admission`
- W8: `locked_requires_admission`
- W9: `locked_requires_admission`
- W10: `locked_requires_admission`
- W11: `authored_but_not_routed`
- W12: `authored_but_not_routed`

Secondary flags by band:

- W1: `has_active_route`, `has_authored_content`, `has_schema_fields` only in
  fixtures, `has_l1_migrated_sample`, `has_same_signal_evidence`,
  `has_transfer_evidence`, `has_repair_path`, `has_route_guard`,
  `has_content_validator`, `needs_human_qa`, `needs_poker_review`.
- W2-W6: `has_active_route`, `has_authored_content`,
  `has_same_signal_evidence`, `has_transfer_evidence`, `has_repair_path`,
  `has_route_guard`, `needs_route_content_normalization`,
  `needs_factory_migration`, `needs_human_qa`, `needs_poker_review`.
- W7-W10: `has_locked_preview`, `has_authored_content`,
  `has_same_signal_evidence` as internal/inferred only, `has_route_guard`,
  `has_correctness_risk`, `needs_route_content_normalization`,
  `needs_factory_migration`, `needs_human_qa`, `needs_poker_review`.
- W11-W12: `has_locked_preview`, `has_authored_content`,
  `has_route_guard`, `needs_factory_migration`, `needs_human_qa`,
  `needs_poker_review`.

## 6. Schema and Validator Readiness

Current schema state:

- Active `content/worlds/world1` through `content/worlds/world12` files do not
  contain the canonical Content Schema Foundation fields searched in this wave:
  `concept_family_id`, `repair_focus_id`, `same_signal_group_id`,
  `transfer_surface_id`, `validation_status`, `source_truth_status`, or
  `route_gate_status`.
- The only schema-shaped examples found are the Wave 6.2 L0 W1 fixture and the
  Wave 6.3 L1 migrated W1 fixture.
- The L1 sample proves migration/validation mechanics for one W1 task, not
  world coverage.

Deferred validation levels that still block launch-grade claims:

- L2 world coverage reporting by concept family, same-signal group, transfer
  surface, repair focus, route gate, and validation status.
- L3 route admission gate that blocks route opening when route/content status,
  preview status, coverage evidence, or validator evidence is missing.
- L4 poker correctness gate for W7+ and any advanced/ambiguous advice.

Factory import/export can proceed only as a tiny controlled proof, but this
report recommends route/content normalization first because W2-W10 title/source
drift would make migration outputs ambiguous.

## 7. Same-Signal / Transfer / Repair Coverage

Coverage evidence exists, but it is not yet schema-owned:

- W1-W6: prior Wave 5.3 evidence found real same-signal and transfer patterns,
  especially W1, W3-W6. The evidence is inferred from filenames, intents,
  chains, feedback, and tests rather than canonical schema fields.
- W2: broad table-reading bridge has useful source material but too much
  conceptual breadth to carry the route-facing Hand Discipline claim cleanly.
- W7-W10: source volume and focused tests suggest internal coverage, but locked
  route state and title/content drift prevent launch claims.
- W11-W12: one source/proof session each is not enough for same-signal,
  transfer, or repair-ready coverage claims.

Repair-path state:

- Runtime/feedback repair patterns exist in earlier worlds.
- Source-owned `repair_focus_id` is absent from active content files.
- One W1 L1 migrated sample contains `repair_focus_id`, proving the field can
  exist, not that the world is repair-coverage-ready.

## 8. Correctness and QA Risks

Human novice QA remains a hard future gate before external beta, public launch,
monetization scale, or learning-effect claims.

Poker correctness risk by band:

- W1-W4: lower relative risk, but still needs human novice QA and claim review
  before premium/public claims.
- W5-W6: board/draw/range concepts need poker review before 10/10 Volume I
  claims.
- W7-W10: stack depth, tournament/ICM, exploit, and track-specialization advice
  need a correctness protocol before public claims.
- W11-W12: real-play transfer and mindset/process claims need human QA and must
  not imply W13 availability or full Volume I completion until routed.

## 9. Highest-Risk Volume I Blockers

| Rank | Blocker | Affected worlds | Affected scores | Severity | Required next action | Why it blocks 10/10 Volume I |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | W2-W6 route/content title drift | W2-W6 | W1-W12 readiness, content depth, learning effect | Critical | W2-W6 Route/Content Normalization | Active route can claim one world job while source content teaches another. |
| 2 | Missing source-owned schema fields in active content | W1-W12 | Content depth, architecture, learning effect | Critical | Migration/factory gate after route normalization | Coverage, repair, transfer, and route status are inferred rather than owned. |
| 3 | W7-W10 locked admission state plus route/content drift | W7-W10 | W1-W12 readiness, content depth, correctness | Critical future gate | W7-W12 Admission/Content Lock | Substantial content exists but cannot be counted as launch-playable. |
| 4 | No L2/L3 validators for world coverage and route admission | W1-W12 | Architecture, content depth, launch readiness | High | L2/L3 validator/report design after normalization | Nothing executable can yet certify coverage-ready or route-ready status. |
| 5 | Tiny factory import/export missing | W1-W12 | Architecture scalability, content depth | High | Tiny Content Factory Import/Export MVP | Schema work has one L1 sample but no repeatable production path. |
| 6 | W1 only has one L1 migrated sample | W1 | Architecture, content depth | High | Expand migration proof only after normalization decision | One sample cannot carry W1 world-level coverage claims. |
| 7 | W11-W12 authored but not routed | W11-W12 | W1-W12 readiness, progression/payoff | High | Later W11/W12 admission after W7-W10 lock | Source proof exists, but there is no learner route or handoff. |
| 8 | Correctness review absent for W5-W12 claims | W5-W12 | Trust, moat, launch readiness | High | Human/poker correctness protocol | Premium claims cannot rely on unreviewed advanced advice. |
| 9 | Human novice QA unavailable | W1-W12 | Learning effect, store/brand, launch readiness | Critical future gate | Human QA Protocol | No external learner proof exists for comprehension and payoff. |
| 10 | Telemetry/session learning transfer still incomplete | W1-W12 | Learning effect, telemetry, monetization | Medium | Later deterministic session/transfer measurement wave | The app cannot yet prove durable learning across sessions. |

## 10. Active Repair Queue Update

Closed:

- W7-W10 route leak.
- W1-W6 content-depth audit classification.
- Content Schema Foundation.
- L0 Content Validation Rules.
- L1 Migrated Sample Pilot.
- L2 W1-W12 coverage report classification.

Active:

- W2-W6 Route/Content Normalization.

Must-not-skip:

- Do not author or migrate broad content before route/content truth is
  normalized.
- Do not count same-signal, transfer, or repair coverage from filenames alone.
- Do not open W7-W12 from registry/content presence.
- Do not claim W13-W36 at launch.
- Do not make premium/public learning claims before correctness review and
  human novice QA.

Deferred:

- Tiny Content Factory Import/Export MVP until route/content target names are
  stable enough to migrate safely.
- W7-W12 Admission/Content Lock until W2-W6 normalization gives the Volume I
  title/owner pattern.
- New W1-W6 content authoring.
- W7-W12 opening.
- W13-W36 content production.
- Monetization/store/public beta.

Blockers:

- W2-W10 title/source drift.
- Active content lacks schema-owned coverage fields.
- L2/L3 validators are not implemented.
- W7-W10 locked route gate.
- W11-W12 non-routed source proof only.
- Human novice QA and poker correctness review absent.

## 11. Score Delta Proposal

No product-score movement is recommended.

- W1-W12 Volume I Premium Product Readiness: unchanged at `5.3/10`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0/10`.
- Overall Top-1 Readiness: unchanged at `5.1/10`.
- Architecture scalability: unchanged at `7.3/10`.
- Content depth: unchanged at `4.5/10`.
- Learning effect: unchanged at `6.0/10`.
- Monetization readiness: unchanged at `2.0/10`.

Reason: this report improves truth clarity and next-step selection. It does
not add content, migrate content, open routes, implement validators, or produce
learner-visible proof.

## 12. Next-Step Recommendation

Recommended actual next wave:

`W2-W6 Route/Content Normalization`.

Why:

- The report finds route/content truth is too unstable for safe factory work.
- W2-W6 are already in the active campaign-owned band, so their drift affects
  the launch target earlier than W7-W12.
- Normalizing W2-W6 creates the pattern needed for later W7-W12 admission and
  safer factory migration.

What the next wave should not do:

- no new content authoring;
- no broad content migration;
- no W7-W12 opening;
- no W13-W36 launch dependency;
- no UI, monetization, telemetry, server analytics, or screenshots.

## 13. Wave DoD Status

- [x] W1-W12 classified.
- [x] Route truth summarized.
- [x] Schema/validator readiness summarized.
- [x] Same-signal/transfer/repair summarized.
- [x] Blockers ranked.
- [x] Next wave selected.
- [x] No content authored.
- [x] No runtime route changed.
- [x] No W7-W12 opened.
- [x] No W13-W36 launch dependency introduced.

## 14. Evidence DoD Status

Commands and results:

- `git status --short --branch`
  - Pre-edit result: branch `codex/volume-i-launch-scope-rebaseline-v1` with
    pre-existing untracked `output/` folders.
- `git switch -c codex/l2-volume-i-w1-w12-coverage-report-v1`
  - Result: branch created.
- Focused `rg` over authority docs, route/content owners, content-world fields,
  and W1-W12 test owners.
  - Result: found the active route/status owners and confirmed no active
    content-world schema field hits.
- `find content/worlds/worldN/v1 ...`
  - Result: produced W1-W12 source file/session/drill inventory used in the
    matrix.
- `graphify query "Volume I W1-W12 route status locked_not_learner_playable authored_but_not_routed content schema validation"`
  - Result: completed and pointed to Act0 Learn route shell plus adjacent route
    nodes; used as navigation only.
- `graphify hook-check`
  - Passed with no output.
- `git diff --check`
  - Passed with no output.
- Direct ASCII check on changed markdown files.
  - Passed. `LC_ALL=C grep -n '[^ -~]' ...` returned no matches.
- Direct trailing-whitespace and CRLF check on changed markdown files.
  - Passed with no output.

Dart, Flutter, and screenshots were not run because this wave changed only a
report artifact.

## 15. Anti-Theater Check

What risk moved?

- Planning risk moved. W1-W12 now have a single Volume I matrix separating
  route status, content source status, schema/validator status, coverage
  evidence, and launch blockers.
- Next-step risk moved. The report selects W2-W6 route/content normalization
  before factory/import work because migration targets are still ambiguous.

What did not move?

- No learner-visible product value moved.
- No content depth moved.
- No route admission moved.
- No validator level moved.
- No human QA, correctness review, monetization, or telemetry proof moved.

Is this docs-only/report-only, code-backed, test-backed, or learner-visible?

- Docs-only/report-only. It is not code-backed, test-backed, or learner-visible
  beyond existing evidence it cites.

Does this enable a safer next implementation wave?

- Yes. It prevents authoring/factory work from hardening the wrong W2-W6 world
  titles and content-owner mapping.
