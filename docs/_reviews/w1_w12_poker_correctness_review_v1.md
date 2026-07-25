---
status: "CLOSED"
status_source: "derived"
doc_date: "2026-07-03"
baseline: "36675160bafa"
generated_by: "docs_frontmatter_v1"
---

# W1-W12 Poker Correctness Review v1

Status: CLOSED.
Date: 2026-07-03.
Scope: admitted W1-W12 learner-facing route/source content only.

## 1. Verdict

w1_w12_poker_correctness_requires_solver_light

No P1 route-fail truth conflict was found. The route is not blocked by an
impossible board, duplicate card, missing answer key, illegal action set, W13+
leak, solver/GTO claim, or mastery claim. The correctness gate cannot honestly
advance directly to content repairs because several admitted strategic-action
families depend on omitted assumptions and should be checked in the selected
solver-light wave before copy/content repair.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Expected HEAD: `36675160bafa17c82a37ff12b793b7af841a1da5`
- Actual HEAD: `36675160bafa17c82a37ff12b793b7af841a1da5`
- `git status --short --branch`: correct branch; no tracked/staged changes; only untracked `output/**`
- `git diff --name-only`: empty
- `git diff --cached --name-only`: empty
- `graphify hook-check`: passed

No `blocked_by_dirty_scope` or `wrong_worktree_or_head` condition was found.

## 3. Authority check

No `stale_capsule_scope` conflict was found. `ACTIVE_ROUTE_CAPSULE_v1.md`
matched the prompt sequence: targeted same-signal/transfer repairs are closed
and `W1-W12 Poker Correctness Review v1` is active. Capsules were used as
context only; accepted review artifacts, live source, tests, and route-owner
runtime specs were used for truth.

## 4. Correctness inventory

Primary inventory:

- W1-W6 admitted canonical fixture tasks: 116.
- W7-W12 hidden runtime owner tasks: 24.
- W11/W12 deterministic source-packet support reps: 12.
- Street Replay/context/payoff/proof copy was checked through accepted Phase 6
  artifacts, focused guards, and screenshot lanes.

W1-W6 fixture breakdown:

| World | Count | Primary source |
| --- | ---: | --- |
| W1 | 42 | W1 coverage, starting hand, seat/card/size/checkpoint/showdown fixtures |
| W2 | 20 | canonical certification, facing-price, approved-raise fixtures |
| W3 | 12 | position and hand-bucket canonical fixtures |
| W4 | 12 | price/value and intent/action fixtures |
| W5 | 18 | texture, board-shift, and outs fixtures |
| W6 | 12 | range bucket and range width fixtures |

W7-W12 route-owner breakdown: four source-owned hidden specs per world. W11
and W12 additionally have six source-packet campaign reps each.

## 5. Core poker-truth audit

No impossible or contradictory task was found in the admitted route evidence.
Answer IDs exist in choice/action sets, feedback and repair focus fields are
present, W13+ is absent, and current W7-W12 route specs keep Practice CTA and
mapper targets blocked.

No P1/P2 issue was found for duplicate cards, impossible board count, illegal
street, future-card leakage, action already completed but still offered, or
answer key missing from options.

## 6. Concept-specific results

| Concept | Result |
| --- | --- |
| table/action reading | correct for current scope |
| position | correct for current scope, broad W3 wording remains bounded |
| starting-hand discipline | pedagogically safe simplification |
| made-hand recognition | correct and precise for current W1 showdown fixtures |
| board texture | classification safe; action prescriptions need solver-light/content repair |
| draws | W5 outs and W8 classifications are correct; strategy around draws needs solver-light where action is rewarded |
| call price | classification-only W9 is correct; no hidden pot-odds threshold is claimed |
| bet purpose | W10 route copy is safe; W4 strategic action/sizing tasks need solver-light |
| value versus bluff | target-language is correct; mutually exhaustive simplification needs bounded repair after solver-light |
| range/context thinking | correct for beginner scope, no exact range boundaries claimed |
| action sequence | no route-critical contradiction found |
| explanation/process concepts | W12 process content is safe and non-solver-authoritative |

## 7. Draw result

W5 outs tasks are correct for standard clean beginner counts:

- flush draw: 9 outs;
- open-ended straight draw: 8 outs;
- gutshot: 4 outs.

W8 route tasks correctly distinguish draw from made hand, flush/open-ended/gutshot-style improvement, and no-clear-draw comparison. No classification repair is required.

Action-bearing W5 texture/draw-adjacent tasks are more fragile: several reward
raise/call/fold from texture/board-shift prose without enough explicit hand,
range, stack, sizing, and opponent assumptions. These are not immediate
classification errors, but they need solver-light or content narrowing before a
public correctness claim.

## 8. Range result

W6 and W7 do not treat range as one exact hand. W6 explicitly says a range is
the set of hands an opponent could have, and W7 visible-card tasks correctly
say exposed ranks reduce matching-rank combinations without proving an exact
hand. Broad W3/W6 simplifications are acceptable for the current route but must
not be promoted as exact range boundaries or mastery.

## 9. Call-price result

W9 is route-safe. It teaches cheap/expensive/lower-price classification and
explicitly avoids claiming the call will win or that the next card/result is
known. It does not introduce pot-odds math, stack requirements, or hidden equity
thresholds. No solver-light candidate is required for W9 unless a future wave
turns price classification into an action recommendation.

## 10. Value/bluff result

W10 route-owner specs are beginner-safe: value is tied to worse hands calling,
bluff-purpose is tied to stronger hands folding, and thin-value caution says
worse calls are unclear. The transfer prompt is over-broad because it asks for
the first bet-purpose question as value-or-fold-pressure while protection,
denial, semi-bluff, merge, and check remain outside the current route. This is
a bounded content-repair item, not a P1.

W4 has higher risk: several admitted action/sizing tasks reward half-pot,
pot, or raise from sparse prose. Those require solver-light assumptions before
copy or answer repair.

## 11. Board-texture result

W11 hidden route-owner board-texture tasks are correct classification/process
content: dry means fewer obvious connections, connected ranks create more
straight paths, suited cards add flush pressure, and coordinated texture asks
for more caution with one pair. No W11 hidden-owner repair is required.

W5 board texture and board-shift fixture tasks sometimes cross from
classification into strategy: dry/paired/wet/connected texture is used to
reward raise/call/fold. Those tasks need solver-light or content narrowing.

## 12. Process/explanation result

W12 route-owner and source-packet process content is safe. It separates process
from result, rejects outcome bias, preserves current-signal reasoning, and
does not imply a checklist guarantees perfect play. No P1/P2 process blocker
was found.

## 13. Answer/explanation consistency

Structural consistency passed: answer keys exist, expected choices are in
options, W7-W12 wrong-choice feedback covers wrong options, repair focus fields
are present, and proof/completion copy does not overstate mastery.

Strategic consistency is weaker in W4/W5/W11 source-packet action spots:
answers can be pedagogically plausible while explanations omit assumptions that
would justify the action in real poker. These are ledgered below.

## 14. Universal-claim audit

Unsafe solver/GTO/mastery claims were not found in admitted route content.
Universal or forceful words did appear, but most are scoped:

- safe: `best five`, `cannot also be in a private hand`, `not one exact hand`;
- acceptable shorthand: `should`, `usually`, `often` in beginner heuristics;
- repair watch: `best first action`, `profitably`, `pot is right`, and
  `should lead to a raise` in strategic-action contexts.

No universal claim is a P1, but several are P3/P4 bounded repair candidates.

## 15. World-level matrix

| World | Items | Correct/precise | Safe simplification | Overgeneralized | Ambiguous | Solver-light | Direct repair | Blocker | Highest |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| W1 | 42 | 24 | 16 | 2 | 0 | 0 | 0 | 0 | P4 |
| W2 | 20 | 6 | 12 | 2 | 0 | 2 | 0 | 0 | P3 |
| W3 | 12 | 3 | 7 | 2 | 0 | 1 | 1 | 0 | P3 |
| W4 | 12 | 0 | 3 | 5 | 4 | 8 | 4 | 0 | P2 |
| W5 | 18 | 6 | 2 | 7 | 3 | 8 | 10 | 0 | P2 |
| W6 | 12 | 4 | 7 | 1 | 0 | 0 | 0 | 0 | P4 |
| W7 | 4 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| W8 | 4 | 3 | 1 | 0 | 0 | 0 | 0 | 0 | P4 |
| W9 | 4 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | none |
| W10 | 4 | 2 | 1 | 1 | 0 | 1 | 1 | 0 | P3 |
| W11 | 10 | 4 | 1 | 2 | 3 | 4 | 2 | 0 | P2 |
| W12 | 10 | 8 | 2 | 0 | 0 | 0 | 0 | 0 | P4 |

Strongest concept: W9 price classification.
Weakest concept: W5 texture-to-action strategy.

## 16. Full P1-P4 gap ledger

| ID | Sev | World/task | Issue type | Poker / learning / trust impact | Minimum repair | Solver dependency | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PC-001 | P2 | W5 texture and board-shift action fixtures: `w5.s01.classify_texture_intro_*`, `w5.s03.classify_wet_protection_connected_call`, `w5.s04.classify_turn_shift_*`, `w5.s05.classify_river_closure_*`, `w5.s10.classify_texture_synthesis_dry_raise` | ambiguous strategic action from texture | Texture alone rarely determines raise/call/fold; learners may over-trust board label as action rule | add visible hand/action/price assumptions or narrow to texture classification before action reward | yes for retained action keys | send_to_solver_light |
| PC-002 | P2 | W11 source reps `w11.s01.r02`, `r04`, `r05`, `r06` | strategic continue/fold under-specified | Continue/fold depends on stack, ranges, exact sizing, and tendency strength; learner may treat one-focus heuristic as exact | solver-light assumptions or source-owner narrowing of "best" to "one-focus beginner" | yes | send_to_solver_light |
| PC-003 | P3 | W4 price/value sizing tasks `w4.s01.choose_half_pot_value`, `w4.s03.choose_half_pot_value_checkpoint`, `w4.s04.choose_half_pot_value_stability`, `w4.s07.choose_half_pot_value_followthrough`, `w4.s07.choose_pot_value_pressure_finish` | sizing precision | Half-pot/pot may be plausible, but exact sizing depends on ranges and board | solver-light selected sizing check or copy narrowing | yes | send_to_solver_light |
| PC-004 | P3 | W4 intent/action tasks `choose_raise_protection`, `choose_raise_bluff`, `choose_raise_denial`, `choose_raise_repeat` | action-purpose overgeneralization | Raise purpose is plausible but ranges/fold equity/sizing are omitted | add assumptions or soften action-specific language | yes | send_to_solver_light |
| PC-005 | P3 | W10 `bet_purpose_transfer_check` | over-broad purpose taxonomy | Value-or-fold-pressure omits protection/denial/check/semi-bluff/merge | reword to "among the beginner purposes taught here" | no | fix_in_targeted_content_repairs |
| PC-006 | P3 | W3 `w3.s08.preflop_continue_fold_discipline.step1.canonical_pr2_v1` | "best first action" overclaim | Call may not be universally best facing an open without positions/sizing/hand | narrow copy to "in this source frame" | maybe | fix_in_targeted_content_repairs |
| PC-007 | P4 | W6 range-width family | broad simplification | Wider/narrower claims are beginner-safe but not exact range construction | retain as scoped beginner language | no | intentional_acceptance |
| PC-008 | P4 | W8 `gutshot_vs_open_ended_comparison_lite` | simplified draw-path count | "Usually" handles exceptions; no false count is taught | retain; avoid outs-threshold expansion here | no | intentional_acceptance |
| PC-009 | P4 | W1/W3/W5 universal words `should`, `often`, `usually` in heuristic feedback | shorthand overclaim risk | Learners may overread heuristics if detached from task context | copy trim in targeted repairs where touching same families | no | fix_in_targeted_content_repairs |
| PC-010 | P4 | W9 price tasks | possible "better price" misunderstanding | Could be read as "good call", but copy explicitly says price not result | keep current classification-only framing | no | intentional_acceptance |
| PC-011 | P4 | W11/W12 corpus parity | source-packet-first shape | Correctness sample is narrower than broad corpus parity | keep as source-truth follow-up, not correctness blocker | no | defer_with_explicit_reason |

No unnamed optional correctness gaps remain from this audit.

## 17. Solver-light candidates

Selected candidates:

| Candidate | Exact tasks | Solver-light question | Required assumptions |
| --- | --- | --- | --- |
| SL-001 W5 texture-to-action | all W5 action-bearing texture/shift tasks in PC-001 | Are the rewarded raise/call/fold actions defensible, or should these become classification-only/softened tasks? | positions, stack depth, pot, bet size, action sequence, hero hand, opponent range, board, prior street |
| SL-002 W4 value sizing | W4 sizing tasks in PC-003 | Are half-pot and pot labels strategically defensible for the stated value contexts? | hero hand strength, board, villain range, stack, pot, bet size menu, street |
| SL-003 W4 raise-purpose | W4 raise tasks in PC-004 | Are protection/bluff/denial raises defensible under beginner-visible assumptions? | fold equity, draw composition, opponent range, stack, sizing, street/action |
| SL-004 W11 one-focus continue/fold | `w11.s01.r02`, `r04`, `r05`, `r06` | Are continue/fold answers robust enough for admitted source-packet route, or should source wording narrow the claim? | exact stack, bet sizes, hero hands, villain tendencies/ranges, position, board, action sequence |
| SL-005 W10 purpose transfer | `bet_purpose_transfer_check` | Is the simplified first question adequate if explicitly scoped to taught beginner purposes? | no full solver tree; lightweight expert/solver sanity on purpose taxonomy |

Simple factual/classification items such as W5 outs, W8 draw recognition, W9
price classification, W11 hidden texture classification, and W12 process review
are not selected for solver-light.

## 18. Route impact

route_requires_solver_light_before_repair

No immediate fail-closed route safety repair is required. The next gate should
be `Solver-Light Selected Checks v1`, carrying the exact candidate IDs above.
After solver-light resolves which action keys/copy should change, run one
consolidated `Targeted Content Repairs v1` wave.

## 19. Tiny repairs made, if any

None. This was audit-first. No learner-facing content, answer key, route, or
runtime copy was changed.

Focused guard added:

- `test/guards/w1_w12_poker_correctness_review_contract_test.dart`

## 20. Evidence result

Evidence result: `poker_correctness_route_requires_solver_light_before_repair`.

Screenshot lanes were used for learner-visible copy/context checks and saved
local-only under:

- `output/w1_w12_poker_correctness_review_v1/core_fast/`
- `output/w1_w12_poker_correctness_review_v1/first_week_fast/`
- `output/w1_w12_poker_correctness_review_v1/active_route_w7_w12_fast/`
- `output/w1_w12_poker_correctness_review_v1/full_scroll_fast/`

`output/**` remains uncommitted.

## 21. Tests/validation

Final validation is recorded in the implementation response. Required focused
coverage includes the new correctness-review guard, content schema tests,
route/admission guards, repair mapper tests, Street Replay/context tests,
screenshot lanes, analyzer, graphify hook-check, diff checks, capsule route
checks, and git status.

## 22. Rolling Capsule Advance

Advance route state:

- `W1-W12 Poker Correctness Review v1` -> CLOSED
- `Solver-Light Selected Checks v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/w1_w12_poker_correctness_review_v1.md`

Carry forward solver-light candidates: `SL-001`, `SL-002`, `SL-003`,
`SL-004`, `SL-005`.

## 23. Scope safety

No W13+, new route, screen, UI redesign, Modern Table change, Practice mapper
change, solver integration, dependency, localization work, monetization,
content rewrite, or broad curriculum expansion was introduced.

## 24. Known limitations

This audit does not run a solver and does not certify borderline strategic
actions. It does not perform Human QA, launch readiness, public learning-effect
validation, broad W11/W12 corpus parity, or full GTO review.

## 25. Next recommendation

Solver-Light Selected Checks v1
