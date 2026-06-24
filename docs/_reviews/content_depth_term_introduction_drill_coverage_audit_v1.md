# Content Depth / Term Introduction / Drill Coverage Audit v1

## 1. Verdict

`audit_ready_with_prioritized_gaps`

The active W1-W10 source inventory is substantial and the existing six-term
scanner passes. It does not prove all learner-visible terminology is safely
introduced. The highest bounded gap is unscanned `ICM` introduction in W8;
the next gap is proof of adequate variation for lower-count W3 and W5 drills.

## 2. Source inventory

Inspected active shelves:

| Range | Current route status | Inspected sources | Inventory signal |
| --- | --- | --- | --- |
| W1-W6 | accepted first-value / route-backed scope | `world.md`, session/notes trees, drill JSON trees | W1 10 sessions/98 drills; W2 17 sessions including 3 crucibles/135 drills; W3 14 sessions/18 drills; W4 10/123; W5 10/41; W6 10/92. |
| W7-W10 | campaign-routed | same active shelf families | W7 10/86; W8 10/86; W9 10/86; W10 40 session files across core and track roots/325 drills. |
| W11-W12 | `planned_foundation` | status and curriculum documents only | Not audited as playable content. |
| W13+ | frontier-only | status and curriculum documents only | Out of scope. |

Proof and policy sources used:

- `docs/_reviews/w1_w6_first_week_content_trust_pass_v1.md`
- `docs/_reviews/world_7_12_route_truth_audit_v1.md`
- `docs/_reviews/36_world_curriculum_coverage_sequence_audit_v1.md`
- `docs/_reviews/volume_i_surface_copy_tiny_slice_v1.md`
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.4.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

Validators/scanners:

- `dart run tools/term_coverage_scanner.dart` passed against 1,581 active
  learner-session files. It owns only `EQUITY`, `PROBE`, `BLOCKERS`, `SPR`,
  `EV`, and `EXPLOIT`; it deliberately excludes `PFA` and `DB`.
- No validator was found that establishes first-safe-use for the broader term
  list in this audit. Scanner pass is therefore not broad glossary proof.

## 3. Term introduction audit

`Verified` below means the scoped sources or owned scanner show an explicit
plain-language introduction. `Unproven` means it was absent from the inspected
session/notes prose or is only implied by world goals/drill data; it does not
mean the term is absent from every runtime surface.

| Term(s) | First scoped evidence / explanation | Assessment | Later glossary support | Severity |
| --- | --- | --- | --- | --- |
| SB, BB, BTN, CO, UTG | Seat codes occur in authored table/drill data; no first explanatory prose was proven in W1-W10 session/notes search. Architecture assigns basic seat literacy to Starter/W0. | Unproven in this scope; do not infer a safe first use from code labels. | Yes, compact tap definition once a glossary seam is owned. | P2 proof gap |
| IP/OOP | W5 uses full `in position` / `out of position`; W1-W10 prose search did not prove an abbreviation expansion. | Full phrase is safer; abbreviation ownership is unproven. | Yes. | P2 |
| open, call, raise, fold | Repeated W1/W3 table-action and preflop framing; W3 s01 explicitly groups the actions, but no formal first definition was audited. | Repetition is strong; first-definition proof is incomplete. | Optional. | P2 |
| limp | No scoped learner-session/notes occurrence found. | No active term-introduction need until learner-facing use is admitted. | Deferred. | Deferred |
| pot | W4 gives concrete half-pot/one-third-pot/pot examples; basic pot literacy is architecturally Starter/W0. | Practical use is present; first definition is unproven in W1-W10. | Yes. | P2 |
| bet size / price | W4 s01 and later sessions tie preset sizes to purpose and the offered price in plain language. | Beginner-safe practical introduction; not formula-heavy. | Optional. | No action |
| pot odds | Appears as a later/deferred layer and in W2 `pot-odds-lite` notes; no owned explicit first definition was proven. | A term-before-definition risk if that note/source becomes learner-visible. | Yes. | P1 |
| outs | W5 owns simple improvement counting, but an explicit first learner-session definition was not proven by the scoped prose search. | World ownership is clear; first-use proof is incomplete. | Yes. | P1 |
| equity | Scanner-owned at W1 s05: `your chance to win the pot if all cards fall.` | Verified and beginner-safe. | Optional. | No action |
| draw | W5 s01 introduces draw/improvement cues and repeats them through turn/river work. | Repeated, concrete board-state use. | Optional. | No action |
| dry board / wet board | W5 s02/s03 introduce dry and wetter texture through connectedness and improvement pressure. | Repeated and beginner-safe. | Optional. | No action |
| paired board | W5 world contract owns it, but no explicit first session/notes explanation was proven. | Ownership without first-use proof. | Yes. | P2 |
| range | W6 s01-s03 moves from buckets to wide/narrow ranges in plain language. | Clear scaffold before precision. | Yes, later. | No action |
| combo / combination | W4 scanner-owned blockers definition says cards remove opponent combinations; no `combo` first-use/definition was proven. | Do not introduce shorthand `combo` without a compact definition. | Yes. | P2 |
| SPR | Scanner-owned at W7 s02: `stack-to-pot ratio` compares stack left with pot. | Verified and beginner-safe. | Optional. | No action |
| M-ratio | No scoped learner-session/notes occurrence found. | No active introduction needed. | Deferred. | Deferred |
| ICM | W8 s01 uses `ICM pressure buckets`; no scanner-owned expansion or explicit acronym definition was found. | High-impact unexplained abbreviation in a campaign-routed world. | Yes, but inline definition is first priority. | P1 |
| variance | No scoped active learner-session/notes occurrence found; planned W12 owns the broader concept. | Not a current-route term claim. | Deferred. | Deferred |
| EV | Scanner-owned at W8 s02: average result of repeating a decision many times. | Verified and beginner-safe. | Optional. | No action |
| tilt | No scoped active learner-session/notes occurrence found; planned W12 owns broader mindset work. | Not a current-route term claim. | Deferred. | Deferred |

## 4. Drill density audit

Raw drill counts are an inventory signal, not proof that every drill reaches
the learner or that its examples are pedagogically distinct.

| World(s) | Depth signal | Variation / repair finding | Audit assessment |
| --- | --- | --- | --- |
| W1-W2 | 98 and 135 drills, repeated seat/action/table reads, chained checkpoints. | Strong raw variation; first-use role/action vocabulary still needs separate proof. | Sufficient inventory signal, not full first-use proof. |
| W3 | 14 sessions but 18 JSON drills, including 14 chain drills. | Good framework repetition in session prose, but low discrete-drill count versus adjacent worlds makes varied-decision proof weak. | P1 drill-density proof gap. |
| W4 | 123 drills across 10 sessions. | Purpose/price has repeated preset and checkpoint reinforcement. | Strong raw inventory signal. |
| W5 | 41 drills across 10 sessions. | Texture/draw work repeats across dry, wet, turn, river, IP/OOP, and capstone sessions, but raw examples are materially thinner than W4/W6. | P1 drill-density proof gap. |
| W6 | 92 drills and synthesis checkpoints. | Range buckets, width, advantage, compression, and river shape recur; abstraction remains the safety concern. | Adequate inventory, P2 terminology watch. |
| W7-W9 | 86 drills each with synthesis/checkpoint patterns. | Strong raw inventory signal; definitions for advanced terms must precede repeated use. | W8 ICM is P1; otherwise density proof later. |
| W10 | 325 drills across core plus cash/tournament/mixed tracks. | Deep inventory but its tracks do not prove a completed specialization program. | Do not convert count into commercial/specialization claim. |

## 5. Concept depth audit

| Concept | Current evidence | Depth conclusion |
| --- | --- | --- |
| Made-hand recognition / hand buckets | W1-W3 repeat stable action and preflop bucket work. | Present; first-definition evidence is thinner than repetition evidence. |
| Hand combinations / combos | Combination language appears through blockers, not a learner-owned combo lesson. | Keep shorthand deferred; no active combo-mastery claim. |
| Board texture, draws, outs | W5 has dry/wet, street-shift, draw-completion, and capstone patterns. | Texture/draw depth is credible; outs and paired-board first definitions need proof. |
| Bet purpose / price | W4 makes size purpose and practical price central. | Strong practical depth; no formula/pot-odds mastery claim. |
| Range buckets | W6 moves from bucket/width to board-relative range shape. | Good conceptual staircase, but avoid solver-like language and add later glossary support. |
| Stack depth / SPR | W7 has depth buckets and scanner-owned SPR definition. | Adequate bounded introduction. |
| Tournament pressure | W8 has ICM/risk/bubble source families. | Content is dense, but `ICM` needs a first-use expansion. |
| Player adjustment | W9 has exploit families and scanner-owned `EXPLOIT` definition. | Adequate bounded introduction. |
| Variance / decision quality | Current route sources do not prove a learner-facing lane; W12 remains planned. | Do not claim current coverage. |

## 6. Beginner-safety risks

- Unexplained abbreviations are the highest content-trust risk: `ICM` is
  active in W8 without a scanner-owned first explanation; seat codes and
  `IP`/`OOP` have incomplete scoped proof.
- W4 keeps price practical, but `pot odds` needs an owned definition before a
  learner-facing use rather than being inferred from `price`.
- W6 range work intentionally avoids exact math, but its width/advantage/
  polarization vocabulary requires progressive disclosure, not a glossary dump.
- W3 and W5 have enough authored sessions to be plausible paths but lack a
  measurement proving varied learner-visible decision reps before progression.
- W10 track count must not be read as evidence of a live specialization or
  commercial pathway.

## 7. Missing proof ledger

| Priority | World(s) / concept | Problem type | Evidence | Smallest future action |
| --- | --- | --- | --- | --- |
| P1 | W8 / ICM | term-before-definition | W8 s01 uses `ICM pressure buckets`; existing scanner does not own ICM. | Add one inline first-use definition and scanner ownership in a Term Introduction Tiny Fix. |
| P1 | W2-W5 / pot odds, outs | weak explanation / term-before-definition | `pot-odds-lite` appears in W2 notes; W5 owns outs but scoped first explicit definition was not proven. | Verify learner-visible source order, then add only missing first-use definitions. |
| P1 | W3, W5 | low drill density | 18 and 41 raw drills respectively versus 10-17 sessions and higher neighboring inventories. | Create a Drill Density Proof Plan with per-atom unique-decision and variation counts. |
| P2 | W1-W6 / seat codes, IP/OOP, pot | glossary candidate / weak explanation | Current scoped prose did not establish first definitions; architecture assigns core table literacy to Starter/W0. | Write a compact glossary/tappable-definition contract after first-use ownership is reconciled. |
| P2 | W5 / paired board; W4-W6 / combo | glossary candidate | World ownership exists, first session/notes explanation was not proven. | Include in the later glossary inventory; do not add broad copy now. |
| P2 | W6 / range vocabulary | copy density / sequence jump | Width, advantage, compression, and polarization appear in a short progression. | Audit one-atom-per-session visible text before changing content. |
| Deferred | M-ratio, variance, tilt | not in current active source scope | No scoped W1-W10 learner-session occurrence found; variance/tilt are planned W12 territory. | No action until a current route owner is admitted. |
| Deferred | W11+ | planned content | No active shelves/route proof. | Do not audit or represent as playable. |

## 8. Recommended bounded corrections

1. `future term-introduction pass`: own `ICM` with one plain-English first-use
   definition; verify whether `outs` and `pot odds` are learner-visible before
   adding anything.
2. `future validator rule`: extend term ownership only after the precise
   learner-visible introduction paths are agreed; do not make a broad glossary
   scanner from inferred words.
3. `future drill-density pass`: measure unique decision contexts and
   same-signal variations for W3 and W5 before authoring more drills.
4. `future glossary/tappable definition pass`: queue seat codes, IP/OOP, pot,
   paired board, and combo after first-use ownership is reconciled.
5. `no action`: keep M-ratio, variance, and tilt deferred; retain W11+ as
   planned/frontier-only.

## 9. Next recommended wave

`Term Introduction Tiny Fix v1`

The specific, high-impact, narrow evidence gap is W8's learner-visible `ICM`
abbreviation without an owned first-use expansion. This can be fixed without
rewriting content, adding drills, changing the learner route, or reopening the
first-week polish lane. The W3/W5 density question should follow as a separate
proof plan rather than receiving speculative new content.
