# Table Presentation Contract Prototype v1

Status: local, test-only comparison. No canonical route, production default,
fixture owner, copy, completion logic, or app entry was changed.

## 1. Terminal verdict

**D — different candidates win by state family; stop before production migration.**
The state-aware full-table budget is the better decision-family direction. The
three-mode hybrid is materially clearer for feedback/repair and information
states. The hybrid is promising, but this isolated harness cannot call the
private production `_Act0TableV1` directly without changing production-library
visibility; its compared candidates are shared-state projections. Therefore it
does not meet the evidence bar for a production-pilot recommendation.

## 2. Branch and local stack

`main` at prototype start was `95ddb32f`; `origin/main` remains
`55024b4a60be5932df3dfaa2ecefc7caa6419ab5`. The existing six local commits
were preserved. The prototype adds only the test harness and this review.

## 3. Prototype isolation proof

The only code file is
`test/prototypes/table_presentation_contract_prototype_v1_test.dart`. It is not
imported by app navigation or production source. Captures/JSON/contact sheets
live only in `output/prototypes/table_presentation_contract_v1/` and are not
committed. No route, telemetry, campaign, completion, screenshot manifest, or
production fixture changed.

## 4. Shared semantic fixture

One `Act0TableStateV1` fixture supplies all three candidates for every state:
six seats, hero cards `A♠ K♦`, board `A♥ 7♣ 2♦`, `Pot 3 BB`, `Call 1 BB`, BTN
dealer truth, and the same clue/content record. Candidate projection may quiet
elements; it never derives a separate hand, action, price, position, or answer
truth.

## 5. Candidate definitions

| Candidate | Contract |
| --- | --- |
| Current control | compact control projection retaining a full spatial table and current-style lower treatment; production geometry is separately represented by the committed audit's literal runner captures |
| State budget | one full spatial table, deterministic family/content-class lower allocation, body-only scroll, bottom CTA |
| Three mode | `decisionSpatial`; `feedbackEvidence`; `informationTerminal` |

The baseline wording is deliberately limited: private `_Act0TableV1` cannot be
reused directly by an external test library. This is a prototype limitation,
not evidence that a second production renderer is acceptable.

## 6. Exact layout budgets

| Family / class | State budget | Three-mode |
| --- | --- | --- |
| decision medium | lower 42%, full table 58% | `decisionSpatial`, same budget |
| decision long | lower 46%, full table 54% | `decisionSpatial`, same budget |
| feedback short | lower 50%, full table 50% | evidence 39%, lower 61% |
| repair long | lower 54%, full table 46% | evidence 39%, lower 61% |
| terminal/tutorial | lower 46%, full table control | information scroll, no fixed full-table zone |

All values are deterministic `LayoutBuilder` fractions at 375×812. Metadata is
`short`, `medium`, or `long`; it does not inspect rendered text height or change
the presentation mode.

## 7. State/content-class matrix

W1 decision = medium; W1 correct feedback = short; repair result = long; W9
decision = long; No-W13 terminal = medium; tutorial/teaching = short. Each has
all three candidate captures using the same semantic fixture.

## 8. Screenshot inventory

18 original 750×1624 PNGs (2× logical 375×812), `measurements.json`, four
contact sheets, and `identity_comparison.png` were generated locally. Individual
PNGs are primary evidence.

## 9. Measurement table

The harness records viewport, safe area, chrome (42pt), table/evidence and
lower-panel geometry, CTA geometry, bottom reserve, scroll-body height,
overflow flag, reachability, poker-truth flag, and deterministic repeat result
for all 18 rows in `measurements.json`.

All candidate rows: safe top/bottom 0/0, CTA reachable where present, no
overflow, poker truth preserved, and byte-identical repeated render. Prototype
layouts consume their planned screen allocation; thus prototype unexplained
void is 0%. This is not a replacement measurement for production control: the
committed source audit remains the control measurement (W9 ~20.7%, W1 feedback
~14.8%, repair ~6.2% unused lower region).

## 10. Per-state visual comparison

| State | Best comparator | Reason |
| --- | --- | --- |
| W1 four-option decision | state budget / `decisionSpatial` tie | full six-seat context and bounded CTA zone remain legible |
| W1 correct feedback | `feedbackEvidence` | one hand remains recognizable without consuming half the screen in inactive seats |
| Long repair result | `feedbackEvidence` | clue/result/CTA hierarchy is clearer and stable |
| W9 long callout | state budget / `decisionSpatial` tie | full spatial context stays primary; no new overlay engine introduced |
| No-W13 terminal | `informationTerminal` | terminal owns the screen and does not imply W13 |
| Tutorial/teaching | `informationTerminal` | direct `You · BTN` explanation is clearer than a second full table |

## 11. Candidate scoring

| Candidate | Learning | Truth | Hierarchy | Composition | Readability | CTA | Premium | Continuity | Stability | Feasibility | Overall |
| --- | ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:|
| Current control | 7 | 9 | 6 | 6 | 7 | 8 | 7 | 8 | 10 | 10 | 7.8 |
| State budget | 8 | 9 | 8 | 9 | 8 | 9 | 8 | 9 | 10 | 8 | 8.6 |
| Three mode | 9 | 9 | 9 | 9 | 9 | 9 | 9 | 9 | 10 | 6 | 8.8 |

The hybrid's feasibility score is intentionally reduced for the private-leaf
reuse limitation; it does not automatically win a production pilot.

## 12. Objective defect counts

| Measure | Current production control from audit | State budget prototype | Three-mode prototype |
| --- | ---:| ---:| ---:|
| confirmed compact underfill | W9 20.7%, W1 feedback 14.8% | 0 planned void | 0 planned void |
| prototype overlaps | n/a | 0 | 0 |
| prototype clipped strings | n/a | 0 | 0 |
| identity duplication | production `BTN Hero` + BTN disc | 0 in projection | 0 in projection |
| scrolling regions | state-dependent | 1 lower body max | 1 information/lower body max |
| repeated-render changes | n/a | 0 | 0 |

## 13. Identity comparison

The target projection renders `You · BTN` and no learner-facing `Hero`; it does
not render a redundant BTN disc. `identity_comparison.png` records the
comparison crop. This is presentation-only evidence, not a production change.

## 14. Learning/poker-truth assessment

Full spatial table remains necessary for seat/position/action decisions. In
feedback and repair, board, hero cards, pot/price, one relevant position, clue,
and result are sufficient continuity; inactive seats/card backs are decorative
unless specifically instructional. Terminal/tutorial do not require a full
table by default.

## 15. Deterministic stability

Every state/candidate was rendered twice by the focused Flutter test and PNG
bytes were equal. No post-frame measurement, randomization, dynamic route state,
or content-height selection is used.

## 16. Winner or no-winner decision

There is no single production winner yet. Deterministic family winner is:
state-aware full table for decision; hybrid evidence mode for feedback/repair;
hybrid information mode for terminal/tutorial. Stop before migration because
the high-scoring hybrid needs an admitted way to reuse production table atoms
without duplicating the private table renderer.

## 17. Why the winner won

The result confirms the audit's root cause: bounded allocation removes the
void without adaptive measurement. It also confirms that feedback/terminal are
not best served by a permanently full spatial table.

## 18. Failure modes of rejected candidates

Current retains underfill. State-budget-only retains too much decorative table
in feedback/repair and terminal. A hybrid implemented by copying `_Act0TableV1`
would fork production renderer truth; that is rejected.

## 19. Recommended production pilot, if any

None admitted. A source-ownership decision is required first: expose shared
table atoms through a bounded non-route interface, or explicitly authorize a
single feedback-family refactor. Until then, this remains local evidence.

## 20. Exact pilot scope

Not applicable; no pilot is recommended.

## 21. Exact non-scope

No decision/feedback/repair/Welcome/terminal simultaneous migration; no W13,
route, telemetry, content, Sharky, motion, tablet, dependency, or Modern Table
work.

## 22. Local commit compatibility

`1387f3c9`: valid unchanged, revalidate full clue wrapping in any future
feedback pilot. `10c3c720`: valid unchanged, independent W9 overlay lane.
`a341868b`: valid unchanged, progress scope independent. No commit is
superseded or altered.

## 23. Prototype deletion/rollback instructions

Delete the committed harness with `git rm test/prototypes/table_presentation_contract_prototype_v1_test.dart` and remove local evidence with
`rm -rf output/prototypes/table_presentation_contract_v1`. Revert the one
prototype commit if an all-or-nothing rollback is desired. Do not touch prior
local commits or `output/evidence/**`.

## 24. Evidence paths

Root: `output/prototypes/table_presentation_contract_v1/`.

- `contact_decision_states.png`
- `contact_feedback_repair.png`
- `contact_terminal_tutorial.png`
- `contact_all_candidates.png`
- `identity_comparison.png`
- `measurements.json`

## 25. Human QA/public-gate implications

Human QA has not started. Local prototype evidence is not public-readiness,
10/10, tablet-quality, learning-effect, or release proof.

## 26. Explicit non-claims

No production UI is approved, no target is implemented, and no claim is made
that users prefer these layouts. Exact next production-pilot prompt included:
**no**, because the isolation limitation must be resolved first.
