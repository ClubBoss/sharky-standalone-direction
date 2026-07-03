# Solver-Light Selected Checks v1

Status: CLOSED.
Date: 2026-07-03.
Scope: five selected borderline W1-W12 poker-correctness spots only.

## 1. Verdict

solver_light_selected_checks_complete_with_repairs_required

No selected spot proves a material route blocker or requires a full solver
integration. The shared result is narrower: several tasks are pedagogically
plausible but present action, sizing, or purpose as more determinate than the
source-owned assumptions support. The next wave should repair copy/context and
some answer framing before any stronger poker-correctness claim.

## 2. Preflight

- Worktree:
  `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Expected HEAD: `61687fd94468a89d8d07f155dd88271bbdfa48a3`
- Actual HEAD: `61687fd94468a89d8d07f155dd88271bbdfa48a3`
- `git status --short --branch`: correct branch; no tracked/staged changes;
  only untracked `output/**`
- `git diff --name-only`: empty
- `git diff --cached --name-only`: empty
- `graphify hook-check`: passed

No `blocked_by_dirty_scope` or `wrong_worktree_or_head` condition was found.

## 3. Authority check

No `stale_capsule_scope` conflict was found. `ACTIVE_ROUTE_CAPSULE_v1.md`
showed `Solver-Light Selected Checks v1` as active and `Targeted Content
Repairs v1` as pending. This pass used capsules as route context only; accepted
review artifact `w1_w12_poker_correctness_review_v1.md`, live fixture/source
JSON, W10 runtime owner specs, W11 source packet, and focused tests owned the
selected-check truth.

## 4. Selected candidate inventory

| ID | Source scope | Current route purpose |
| --- | --- | --- |
| SL-001 | W5 action-bearing texture and board-shift tasks in PC-001 | Teach board texture/shift awareness before action |
| SL-002 | W4 value sizing tasks in PC-003 | Teach price selection for value purpose |
| SL-003 | W4 raise-purpose tasks in PC-004 | Teach purpose-before-action recognition |
| SL-004 | W11 `w11.s01.r02`, `r04`, `r05`, `r06` | Teach one-focus continue/fold transfer |
| SL-005 | W10 `bet_purpose_transfer_check` | Teach value-versus-pressure purpose recognition |

## 5. Assumption completeness

| ID | Explicit assumptions | Missing assumptions | Completeness |
| --- | --- | --- | --- |
| SL-001 | texture label, partial board-shift/draw language, action options, expected action, feedback | exact board cards in most tasks, hero hole cards, positions, stack, pot, facing action, bet size, villain range | incomplete for unique action advice |
| SL-002 | value objective, expected size, acceptable alternate in source JSON | hero hand, board, street, pot, stack, villain range, betting sequence | incomplete for unique sizing advice |
| SL-003 | stated purpose such as protection, bluff, denial; expected raise | current hand, board, facing action, sizing, stack, fold equity/range details | incomplete for unique raise advice, sufficient for purpose-recognition drill |
| SL-004 | position, board class, hand/draw class, opponent tendency, approximate bet size, continue/fold options | exact stack, exact pot, exact ranges, exact hand combos | sufficient for one-focus beginner continue/fold, not exact EV |
| SL-005 | W10 taught value and pressure definitions, choices, feedback | protection/denial/semi-bluff/check categories outside W10 scope | sufficient if scoped to taught beginner purposes |

## 6. SL-001 result

Disposition: `context_assumption_repair`.
Confidence: `low_due_to_missing_assumptions`.
Severity: P2.

The current W5 answer keys are not proven false, but texture alone does not
legitimately determine raise/call/fold. Several prompts say "choose the best
action" from dry/wet/paired/connected labels while omitting hero hand, prior
action, price, stack, and opponent range. Multiple actions are defensible in
real poker under different omitted assumptions.

Minimum repair: convert these reps to texture/shift classification or add a
tiny visible scenario frame before retaining action keys. Remove "should lead
to a raise", "best action", and any wet/dry wording that implies an automatic
action rule.

## 7. SL-002 result

Disposition: `copy_precision_repair`.
Confidence: `moderate`.
Severity: P3.

Half pot is a reasonable beginner value size in sparse teaching content, and
the source already accepts `one_third_pot` for the half-pot family. The current
copy overstates precision when it presents half pot or pot as uniquely "right"
without board, hand, range, stack, and street context. The pot-size finish task
is the sharpest case because "biggest immediate price" needs a stronger source
frame than the current prompt provides.

Minimum repair: keep half pot as one practical beginner value size where
needed, preserve accepted alternates, and rewrite pot/half-pot feedback to say
"in this simplified rep" or add the missing assumptions.

## 8. SL-003 result

Disposition: `copy_precision_repair`.
Confidence: `moderate`.
Severity: P3.

The W4 raise-purpose tasks are coherent as action-recognition drills once the
purpose is already supplied: protection, bluff pressure, and denial commonly
map to betting or raising. They are not complete strategy spots. Without
facing action, board, exact hand, stack, sizing, and fold-equity/range details,
the tasks should not imply that raising is uniquely correct poker strategy.

Minimum repair: narrow prompts and feedback to "given this taught purpose,
raise is the intended action in this simplified rep." Keep value/bluff/denial
as beginner purpose labels, not exhaustive strategic categories.

## 9. SL-004 result

Disposition: `copy_precision_repair`.
Confidence: `moderate`.
Severity: P3.

The W11 source reps are directionally defensible for one-focus beginner
transfer. R02 continue is supported by position, an open-ended draw, and a
quarter-pot lead. R05 fold is supported by ace-high, no strong draw, a tight
player, and a check-raise on a coordinated board. R04 and R06 are plausible
continues because price, position/tendency, and showdown/backdoor context are
visible, but exact EV is not proven without ranges/stacks.

Minimum repair: no answer-key change. Keep "one-focus decision" framing and
soften feedback that sounds exact, especially "gives up value" or "too tight",
to "in this simplified one-focus rep."

## 10. SL-005 result

Disposition: `copy_precision_repair`.
Confidence: `high`.
Severity: P3.

The W10 taxonomy is logically coherent inside the taught route: value asks
whether worse hands call, and pressure/bluff asks whether stronger hands fold.
The issue is scope, not correctness. The transfer check omits protection,
denial, semi-bluff, merge, and check, so the prompt should not read like the
universal first question for every bet.

Minimum repair: reword to "among the beginner purposes taught here, first ask
whether the bet mainly wants worse calls or stronger folds."

## 11. Cross-spot consistency

Shared risks:

- texture used as action prescription;
- unique-answer framing where multiple actions are valid;
- value/bluff binary oversimplification;
- missing price/stack/range assumptions;
- explanation stronger than source evidence;
- one beginner heuristic presented as universal poker truth.

Shared repair rule: preserve beginner-friendly drills, but make the visible
task ask only what the source-owned assumptions can support.

## 12. PC ledger resolution

| PC | Resolution |
| --- | --- |
| PC-001 | `repair_required`: SL-001 confirms context-assumption repair for W5 texture-to-action |
| PC-002 | `repair_required`: SL-004 resolves no answer-key repair, but copy precision repair remains |
| PC-003 | `repair_required`: SL-002 confirms W4 sizing copy/context repair |
| PC-004 | `repair_required`: SL-003 confirms W4 raise-purpose copy/context repair |
| PC-005 | `repair_required`: SL-005 confirms W10 taxonomy scope repair |
| PC-006 | `repair_required`: W3 best-first-action wording still needs bounded copy repair |
| PC-007 | `safe_simplification`: W6 range-width simplification remains accepted |
| PC-008 | `safe_simplification`: W8 draw comparison remains accepted |
| PC-009 | `repair_required`: heuristic universal wording should be trimmed in touched families |
| PC-010 | `safe_simplification`: W9 price classification remains safe |
| PC-011 | `explicit_defer`: W11/W12 broad corpus parity remains source-truth follow-up |

No PC item remains unnamed or undisposed.

## 13. Final P1-P4 repair ledger

| ID | Sev | World/task | Exact defect | Minimum repair | Owner file | Required tests | Screenshots | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SLCR-001 | P2 | W5 PC-001 texture-to-action tasks | action keys outrun assumptions | classify texture only or add source frame before action | W5 canonical fixture/source JSON | content schema guard plus selected-check contract | likely if learner copy changes | repair_required |
| SLCR-002 | P3 | W4 PC-003 sizing tasks | half-pot/pot presented as too uniquely right | scope as simplified beginner size; preserve alternates | W4 price fixture/source JSON | content schema guard plus sizing contract | likely if copy changes | copy_precision_repair |
| SLCR-003 | P3 | W4 PC-004 raise-purpose tasks | raise treated as strategy result rather than purpose-recognition answer | narrow to "given this purpose in this simplified rep" | W4 intent fixture/source JSON | intent/action guard | likely if copy changes | copy_precision_repair |
| SLCR-004 | P3 | W11 PC-002 source reps | one-focus feedback can sound exact-EV | keep keys, soften exactness for r04/r06 style wording | W11 source packet/campaign fixture | W11 campaign/source contract | possible if visible copy changes | copy_precision_repair |
| SLCR-005 | P3 | W10 PC-005 transfer check | value/pressure question reads universal | add "among the beginner purposes taught here" | W10 hidden owner spec | W10 route contract | yes if visible copy changes | copy_precision_repair |
| SLCR-006 | P3 | W3 PC-006 preflop continue/fold step | "best first action" overclaim | scope to source frame or taught simplified rep | W3 canonical fixture/source JSON | content schema guard | likely if copy changes | copy_precision_repair |
| SLCR-007 | P4 | PC-009 heuristic wording in touched W1/W3/W5 families | forceful should/often wording can overgeneralize | trim only where next repair touches same copy | touched fixture/source JSON | focused content guard | only if visible copy changes | copy_precision_repair |
| SLCR-008 | P4 | PC-011 W11/W12 corpus parity | broad parity is not source-owned yet | defer until source-truth pass, not correctness repair | W11/W12 source packets and corpus | source-contract tests | no | explicit_defer |

Explicit safe simplifications: PC-007, PC-008, and PC-010 require no repair in
the next wave.

## 14. Route safety

route_safe_until_repair

No selected task proves materially false poker logic severe enough to fail the
route closed immediately. The route can remain open until consolidated
`Targeted Content Repairs v1` lands because the defects are bounded copy,
context, and action-key framing issues, not impossible boards, illegal actions,
missing answers, W13 leakage, or fake solver claims.

## 15. Tests/validation

Planned validation for this wave:

- focused selected-check guard:
  `test/guards/solver_light_selected_checks_contract_test.dart`
- existing poker correctness guard:
  `test/guards/w1_w12_poker_correctness_review_contract_test.dart`
- W1-W12 schema/route guard batch
- repair/proof mapper tests
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- capsule route grep
- `git status --short --branch`

Final command output is recorded in the implementation response.

## 16. Evidence result

Evidence result: `solver_light_route_safe_until_repair`.

Source and tests were sufficient. No new screenshot ambiguity was identified,
so no screenshot lane was required for this adjudication. Existing local output
packets remain uncommitted.

## 17. Rolling Capsule Advance

Advance route state:

- `Solver-Light Selected Checks v1` -> CLOSED
- `Targeted Content Repairs v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/solver_light_selected_checks_v1.md`

Carry forward repair ledger IDs `SLCR-001` through `SLCR-008`.

## 18. Scope safety

No production content repair, runtime feature, route/screen, Practice mapper,
Modern Table change, package, W13+ expansion, full solver layer, or fake solver
authority was introduced.

## 19. Known limitations

This is not a full GTO certification and does not compute exact equilibrium
frequencies. It does not resolve W11/W12 broad corpus parity, Human QA, launch
readiness, public learning-effect claims, or future paid-depth scope.

## 20. Next recommendation

Targeted Content Repairs v1
