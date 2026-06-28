# W1 Full Coverage Certification Plan v1

Status: ACCEPTED certification-plan artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_full_coverage_certification_plan_ready`

W1 is the only current Volume I world with canonical learner-playable route
status and real source-derived L2/L3 coverage proof. It is not yet release-grade
certified. The current proof covers one schema-shaped same-signal group, not
full World 1.

The next implementation wave should be `W1 Concept Family Migration Batch 1`,
targeting `starting_hand_discipline` as the second schema-backed W1 concept
family.

## 2. Source truth

Inspected docs and why:

- `AGENTS.md`: active repo, route, readiness, and testing instructions.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: top-1 strategy boundary.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon
  execution ledger and current next wave.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1-W12 readiness scores,
  W1 score, and anti-theater scoring rules.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: task schema and required
  coverage fields.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0/L1/L2/L3 validation
  expectations.
- `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`: existing skill-family placement
  language for W1 and adjacent families.
- `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`: existing W1 node-family placement.
- `docs/_reviews/w1_w6_migration_coverage_consolidation_v1.md`: accepted prior
  consolidation verdict and next-step rationale.
- `docs/_reviews/w1_world_coverage_expansion_pilot_v1.md`: real W1 pilot proof.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md`: validator coverage
  and route-admission proof model.

Inspected fixtures/tests and why:

- `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`: current
  W1 schema-shaped coverage proof, same-signal group, transfer surfaces, and
  repair focus.

Inspected W1 source/content and why:

- `content/worlds/world1/v1/world.md`: W1 source contract and goals.
- `content/worlds/world1/v1/atoms.md`: W1 content atom vocabulary.
- `content/worlds/world1/v1/sessions/index.md`: W1 session map.
- `content/worlds/world1/v1/sessions/w1.s01/session.md` through
  `content/worlds/world1/v1/sessions/w1.s10/session.md`: session-level concept
  intent and source structure.
- All JSON source tasks under
  `content/worlds/world1/v1/sessions/w1.s01/` through
  `content/worlds/world1/v1/sessions/w1.s10/`: scripted inventory of task kind,
  source intent, error class, and per-session distribution.

## 3. Current W1 readiness state

Current score: `6.9/10`.

Current proven coverage:

- One real W1 factory coverage pilot with six source-derived tasks.
- Concept family: `position_action_order`.
- Same signal: `w1.position_action_order.first_in_or_facing_pressure`.
- Transfer surfaces:
  - `first_in_action_order_v1`
  - `facing_open_pressure_v1`
  - `multiway_pressure_v1`
- Repair focus: `position_before_action`.
- Route admission: `learner_playable_route_ready` for the pilot fixture.

Current L2/L3 status:

- W1 has coverage-countable L2/L3 proof for one pilot group.
- The proof is source-derived and validator-backed.
- The proof does not certify all W1 concept families.

Current blockers:

- Broad W1 source is not fully schema migrated.
- Only one concept family has schema-shaped same-signal proof.
- Most W1 concept families do not yet have validator-owned transfer surfaces.
- Most W1 concept families do not yet have `repair_focus_id` coverage.
- Poker correctness review is not complete.
- Human novice QA is not complete.
- Release claim safety is limited to a W1 foundation pilot, not full W1 mastery.

## 4. W1 concept family inventory

Scripted W1 source inventory found:

- `50` `action_choice` tasks.
- `20` `seat_tap` tasks.
- `10` `hand_chain_v1` roots.
- `10` `board_tap` tasks.
- `4` `bet_sizing_choice_v1` tasks.
- `4` `hole_cards_tap` tasks.

| Concept family | Source locations | Existing drill/task count | Schema-shaped proof | Same-signal status | Transfer status | `repair_focus_id` status | Correctness risk | Human QA need | Release claim safety |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `position_action_order` | W1 pilot fixture; W1 action-choice source in `w1.s02` and `w1.s03`; broader W1 action-choice source | 6 validator-backed pilot tasks; broader source includes many action-choice tasks | Yes | Ready for one same-signal group | Ready for three transfer surfaces | Ready: `position_before_action` | Medium; action advice still needs review before broad claims | Yes | Safe only as pilot coverage proof |
| Proposed `starting_hand_discipline` | `world.md`; W1 sessions with `hand_discipline_fold`, dominated-ace, weak-start, and trash-hand action choices | 68 source-intent references to `hand_discipline_fold` across task kinds; 50 action-choice tasks total | No | Missing | Missing | Missing | Medium-high; beginner preflop advice must be correctness-reviewed | Yes | Not safe as a full W1 claim yet |
| Proposed `seat_role_orientation` | W1 seat-tap tasks; Act0 seat-quiz trio language; sessions with BTN/SB/BB recognition | 20 seat-tap tasks; 10 `seat_role_confusion`; 10 `seat_id_confusion` | No | Missing | Missing | Missing | Low-medium; mostly table semantics, but copy and role order still need review | Yes | Safe as existing orientation surface, not certified coverage |
| Proposed `card_board_orientation` | W1 board-tap and hole-card tasks | 10 board-tap tasks; 4 hole-card tasks | No | Missing | Missing | Missing | Low-medium; basic literacy, but novice confusion must be tested | Yes | Safe only as literacy support |
| Proposed `bet_size_vocabulary_preview` | `w1.s01` betting cluster | 4 bet-sizing-choice tasks | No | Missing | Missing | Missing | High for claims; W1 should not imply bet-sizing mastery | Yes | Preview-only; fuller bet-purpose claim belongs later |
| Proposed `world1_checkpoint_synthesis` | One `hand_chain_v1` root in each W1 session | 10 chain roots | No | Missing | Missing | Missing | Medium; synthesis can mask weak component coverage | Yes | Safe as review/checkpoint support, not standalone certification |

## 5. W1 certification gap matrix

| Concept family | Current evidence | Missing evidence | Minimum tasks needed | Validator requirement | QA requirement | Correctness requirement | Priority | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `position_action_order` | 6-task schema pilot; same-signal, transfer, repair fields pass | Broader session coverage and human QA | 4-6 more tasks only after second family is started | Existing L2/L3 must stay green | Novice observes action-order decisions without prompt confusion | Review fold/call/raise reasons in migrated tasks | P1 | Preserve as baseline while adding next family |
| `starting_hand_discipline` | Strong source volume; core W1 learning promise | Schema tasks, same-signal group, transfer surfaces, repair focus, correctness review | 5-8 source-derived migrated tasks | L0/L1 plus L2/L3 coverage-countable group | Novice can explain release/continue reason in plain language | Poker review for dominated, trash, first-in, and facing-pressure advice | P0 | `W1 Concept Family Migration Batch 1` |
| `seat_role_orientation` | 20 source tasks and strong live surface | Schema group, transfer framing, repair focus | 4-6 tasks if certified separately | L2/L3 must count without overstating decision coverage | Novice can identify BTN/SB/BB quickly | Table-role semantics review | P2 | Migrate after one more decision-family proof |
| `card_board_orientation` | Board and hole-card source tasks exist | Schema group, repair taxonomy, transfer framing | 4-6 tasks | L2/L3 can count only as literacy coverage | Novice can distinguish board/hole cards under time pressure | Basic poker terminology review | P3 | Keep as later literacy batch |
| `bet_size_vocabulary_preview` | 4 `w1.s01` bet-size tasks | Claim boundary, transfer limit, repair focus | 4-6 tasks only if kept preview-scoped | Validator must mark preview/bridge status or route to W4 | Novice does not infer sizing mastery | Sizing/purpose correctness review | P3 | Do not promote during W1 certification PR1 |
| `world1_checkpoint_synthesis` | 10 chain roots, one per session | Component coverage proof before synthesis claim | 3-5 schema checkpoint records after component families exist | Validator should require component-family references | Novice can connect checkpoint back to learned family | Review any combined-action rationale | P4 | Defer until multiple families pass |

## 6. W1 readiness ladder

### W1 7.0

Bar:

- Current W1 pilot remains green.
- The certification plan exists and identifies concept-family gaps.
- At least one next implementation slice is selected.

Status after this wave: eligible for planning clarity only. No automatic score
movement is proposed because no executable coverage evidence changed.

### W1 8.0

Bar:

- Multiple schema-backed W1 concept families pass L0/L1 and L2/L3.
- At least two concept families have same-signal groups.
- Each counted family has transfer surfaces and `repair_focus_id`.
- No bridge/preview family is counted as full W1 mastery.
- Route and claim safety remain locked to W1 only.

Minimum path:

- Keep `position_action_order` green.
- Add `starting_hand_discipline` as a second validator-backed family.
- Add at least one more low-risk W1 literacy or decision family if the second
  family exposes thin transfer coverage.

### W1 9.0

Bar:

- W1 has broad source-to-schema migration across the certified family set.
- Human novice QA protocol has run for the W1 route or its certified sample.
- Poker correctness review has passed for action advice and any bet-size copy.
- Repair behavior is observable for the claimed families.
- Progression/payoff proof is connected to certified concept-family progress.

No 9.0 without human QA and correctness proof.

### W1 10.0

Bar:

- Complete W1 coverage map is schema-owned and validator-backed.
- Same-signal, transfer, repair, feedback, progression, payoff, correctness,
  QA, and claim-safety evidence are all present.
- The product can safely claim full W1 foundation certification without hiding
  preview-only or bridge-limited gaps.
- Any learner-facing claim is narrower than or equal to evidence.

No 10.0 without complete W1 coverage, QA, correctness, claim safety, and
payoff/progression proof.

## 7. Minimum next implementation slice

Chosen next implementation wave:

`W1 Concept Family Migration Batch 1`

Target concept family:

`starting_hand_discipline`

Minimum slice:

- Migrate 5-8 existing W1 source-derived tasks into schema/factory fixtures.
- Use one same-signal group around weak, dominated, or clearly playable starting
  hand discipline.
- Include at least two transfer surfaces, preferably:
  - `clean_first_in_start_v1`
  - `facing_open_continue_or_release_v1`
  - `oop_weak_start_release_v1`
- Include a repair focus such as `release_weak_or_dominated_start`.
- Run existing foundation and L2/L3 validators.
- Add no new authored content unless the implementation wave explicitly admits
  a tiny source-normalization correction.

Why this wave:

- It moves W1 toward the 8.0 bar by adding a second schema-backed concept
  family.
- It attacks the highest-value W1 claim risk: beginner starting-hand discipline.
- It keeps work validator-led before broad migration or authoring.

## 8. Volume I ledger impact

No W1 score movement is proposed.

Reason: this wave creates a certification plan and evidence budget. It does not
add executable schema coverage, correctness proof, human QA, or route behavior.

Ledger next action should move from `W1 Full Coverage Certification Plan` to
`W1 Concept Family Migration Batch 1`.

## 9. Route impact

- No route changes.
- No learner-facing title changes.
- W1 remains the only canonical route-ready world with real source-derived
  L2/L3 coverage proof.
- W2-W6 remain bridge_or_legacy limited.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain post-launch/live expansion/deferred roadmap.

## 10. Active repair queue update

Closed:

- W7-W10 route leak.
- W1-W6 content-depth audit classification.
- Content Schema Foundation.
- L0 Content Validation Rules.
- L1 Migrated Sample Pilot.
- Volume I Launch Scope Rebaseline.
- L2 World Coverage Report for W1-W12.
- W2-W6 Route/Content Normalization.
- Tiny Content Factory Import/Export MVP.
- L2/L3 Content Validator Expansion.
- W1 World Coverage Expansion Pilot.
- W1-W6 Schema Migration Pilot.
- W2-W6 Bridge Coverage Expansion.
- W1-W6 Migration Coverage Consolidation.
- W1 Full Coverage Certification Plan.

Active:

- W1 Concept Family Migration Batch 1.

Must-not-skip:

- Preserve the W1 `position_action_order` positive control.
- Add one validator-backed migrated W1 concept family before broad W1 migration.
- Keep L2/L3 admission checks green.
- Add transfer surfaces and `repair_focus_id` for every counted family.
- Run correctness review before broad W1 premium/public claims.
- Run Human QA Protocol before external beta or learning-effect claims.

Deferred:

- Broad W1 migration.
- New W1 content authoring.
- W2-W6 canonical realignment.
- W7-W12 admission/opening.
- W13-W36 launch dependency.
- Monetization/store/public beta.

Blockers:

- Second W1 schema-backed concept family is not implemented.
- Human novice QA is not executed.
- Poker correctness review is not executed.
- W1 payoff/progression proof is not certification-linked.

## 11. Score delta proposal

| Score area | Current | Proposed after this wave | Reason |
| --- | ---: | ---: | --- |
| W1 readiness | 6.9 | 6.9 | Planning only; no new executable evidence |
| W1-W12 readiness | 5.9 | 5.9 | Route/content evidence unchanged |
| Architecture scalability | 8.1 | 8.1 | No tooling/schema capability added |
| Content depth | 4.8 | 4.8 | No new coverage tasks added |
| Overall top-1 readiness | 5.7 | 5.7 | Decision risk reduced, product evidence unchanged |

## 12. Evidence DoD status

Required checks for this docs-only wave:

- `graphify hook-check`
- `git diff --check`
- direct ASCII check
- direct trailing-whitespace/CRLF check

No screenshots are required or allowed.

No `dart format`, Flutter tests, or validator commands are required because this
wave changes no tooling, product code, fixture, schema, or validator behavior.

## 13. Anti-theater check

What risk moved:

- The W1 certification target is now decomposed into concept families,
  evidence gaps, score bars, and one exact next implementation wave.

What did not move:

- W1 coverage proof did not expand.
- W1 score did not increase.
- W2-W6 did not become canonical launch coverage.
- W7-W12 did not open.
- Human QA and poker correctness did not execute.

Is this docs-only or code-backed:

- Docs-only.

Does this select a safer next implementation step:

- Yes. The next wave is not broad migration or authoring. It is one
  validator-backed W1 concept-family migration batch with same-signal,
  transfer, repair, and correctness boundaries.
