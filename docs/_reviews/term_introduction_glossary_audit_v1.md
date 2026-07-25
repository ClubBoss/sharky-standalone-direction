---
status: "term_introduction_glossary_ready_with_optional_gaps"
status_source: "derived"
baseline: "739bdbb6"
generated_by: "docs_frontmatter_v1"
---

# Term Introduction / Glossary Audit v1

## 1. Verdict

`term_introduction_glossary_ready_with_optional_gaps`

The admitted W1-W12 learner route is safe to advance to
`Same-Signal / Transfer Coverage Audit v1`. Current active-route terminology is
introduced, contextualized, or self-explanatory enough for route continuation.
No broad glossary system, new screen, new route, W13+ work, localization work,
or poker-correctness certification is required by this gate.

This audit does not claim every term is Human-QA-proven, poker-correct, or
launch-ready. It only closes the first-use/glossary gate for current route
ordering.

## 2. Preflight

| Check | Result |
| --- | --- |
| Worktree | `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1` |
| Branch | `codex/apply-owner-patch-sequence-a-b-c-d-v1` |
| Starting HEAD | `739bdbb6` |
| `git status --short --branch` | correct branch; no tracked or staged changes; only untracked `output/**` |
| `git rev-parse HEAD` | `739bdbb6d50578c9d398c5540df3c9eeda963ecb` |
| `git diff --name-only` | empty |
| `git diff --cached --name-only` | empty |
| `graphify hook-check` | passed |

No `blocked_by_dirty_scope` or `wrong_worktree_or_head` condition was found.

## 3. Capsule/authority check

No `stale_capsule_scope` conflict was found. `ACTIVE_ROUTE_CAPSULE_v1.md`
matched the prompt: Phase 7 - Content & Correctness is active,
`W1-W12 Content Depth Gate v1` is closed, and
`Term Introduction / Glossary Audit v1` is active. `LEARNING_REPAIR_CAPSULE_v1`
preserves the content-depth optional gaps and the claim-safety boundary.

Read and used:

- `AGENTS.md`
- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`
- `docs/_reviews/w1_w12_content_depth_gate_v1.md`
- `docs/_reviews/phase_6_closure_audit_v1.md`
- `docs/_reviews/w7_w12_table_context_readiness_audit_v1.md`
- `docs/_reviews/sharky_phrase_tier_contract_v1.md`
- `docs/_reviews/foundation_developing_phrase_sets_v1.md`
- `docs/_reviews/sharky_saw_you_improve_v1.md`
- existing glossary/term artifacts and tests
- live active learner content and W7-W12 route owner copy

## 4. Term inventory

Inventory source: active `content/worlds` learner files, W7-W12 route owner
specs, campaign-pack copy, Street Replay labels, Review/Profile/Session Summary
visible copy, existing term contract, scanner output, and screenshot lanes.

| Term family | First visible/use evidence | Definition/support | Verdict |
| --- | --- | --- | --- |
| SB / BB / BTN / CO | seat metadata plus full-name seat copy in early content and visible table labels | full names appear in content; route visuals use compact seat labels as table labels | `defined_in_context` |
| UTG | later content metadata and W4/W6 learner copy | not foundational; used only in later positional comparison | `needs_lightweight_definition` optional |
| Button / Small Blind / Big Blind / Cutoff | W0/W1 content and route copy | full words are present before or with required seat tasks | `introduced_before_use` |
| fold / check / call / raise | W1 first route and action module | plain action words; W1 starts with them explicitly | `self_explanatory` |
| flop / turn / river | W0/W1 street flow and table copy | repeated street labels and table context | `introduced_before_use` |
| range | early source mentions, W6/W7 route context | W6 range and W7 visible-card route contextualize possible hands | `defined_in_context` |
| texture / board texture | W2/W5/W11 board context | used with dry/connected/suited board examples | `defined_in_context` |
| draw / flush draw / straight draw / open-ended / gutshot / one-gap | W2/W5/W8 draw content and W8 route | `OUTS` scanner definition plus draw examples; one-gap is explained as narrower | `defined_in_context` |
| outs | W2 s06 | scanner-owned definition: cards that can improve your hand | `introduced_before_use` |
| price / call price / pot odds | W4/W9 route copy | price is plain; W9 explains call price versus pot reward; pot odds copy says price compared with pot | `defined_in_context` |
| value / bluff / bet purpose | W4/W10 route copy | W10 distinguishes worse-hands-call and stronger-hands-fold targets | `defined_in_context` |
| made hand / pair / two pair / trips / set / overcard | W1-W7 content | concrete hand-ranking and table examples; some nuance belongs to correctness review | `defined_in_context` |
| equity / EV / SPR / ICM / exploit / probe / blockers / combo / paired | term contract and scanner | exact first-use definition and order checked by `term_coverage_scanner` | `introduced_before_use` |
| repair / proof / fix / missed cue | Review/Profile/Session Summary | product terms are plain and tied to visible states; no internal IDs shown | `defined_in_context` |
| source ids / route ids / concept-family ids | source/test metadata only | not rendered in screenshot lanes | `not_learner_visible` |

## 5. First-use ordering

First-use ordering result: `route_safe_with_optional_gaps`.

- Scanner-owned priority terms pass exact first-use order:
  `EQUITY`, `PROBE`, `BLOCKERS`, `OUTS`, `OOP`, `PAIRED`, `SPR`, `ICM`, `EV`,
  `EXPLOIT`, and `COMBO`.
- `PFA` and `DB` remain reference-only and are excluded from active learner
  content.
- Abbreviated table labels (`SB`, `BB`, `BTN`, `CO`) appear as compact seat
  labels or source metadata. The active visible table relies on standard poker
  seat labels, while early content uses full names for blind/button concepts.
- W8 draw terms are contextualized by W2/W5 draw/outs content and W8 route
  copy. `one-gap` is explained as narrower than open-ended.
- W10 value/bluff language is separated by target language: worse hands call
  versus stronger hands fold.

Optional first-use gaps do not block route continuation:

- seat-code scanner ownership is still too broad and would catch source
  metadata, so `SB` / `BB` / `BTN` / `CO` should stay audit-watch rather than
  scanner-owned until a current UI owner admits compact label definitions;
- `UTG` appears later and could use a future lightweight definition if that
  route becomes prominent;
- `No-bet-yet clue` is understandable rendered copy, but should remain watched
  because it is compact product terminology.

## 6. Foundation/Developing vocabulary

Foundation copy remains plain enough for the current route:

- W1 starts with action words and table reads.
- Foundation Sharky phrases name one concrete clue or local proof.
- Review/Profile product copy uses `repair`, `proof`, and `miss` as plain
  learner-facing words, not hidden concept-family labels.

Developing copy becomes denser after W4-W5:

- W5/W8 can use draw/outs language after earlier exposure.
- W6/W7 can use range language after W6 source support.
- W9/W10 can use price/purpose/value/bluff language after W4/W9 bridge support.
- W11/W12 can combine texture, draw, call price, bet purpose, and process terms
  because those are prior concepts in the route.

The W4->W5 boundary is supported. No Foundation screen requires unexplained
Developing-only terminology to choose correctly.

## 7. Surface consistency

| Surface | Result |
| --- | --- |
| Theory/session source | first-use definitions exist for scanner-owned terms; no broad glossary UI needed |
| Task prompts/options | mostly plain; high-risk W7-W12 prompts are guarded by route-copy tests |
| Feedback/explanations | no exact internal concept ids found in visible screenshot lanes |
| Repair/Review | `repair`, `miss`, `proof`, and `clue` are consistently product-facing |
| Session Summary | phrase contract keeps evidence-backed Sharky copy bounded |
| Profile | `Progress proof` and `proof, not points` are consistent with proof capsule truth |
| Street Replay | uses `How we got here` and source-owned action rows; no shorthand route ids |
| Sharky phrases | Foundation/Developing resolver prevents unsupported mastery/AI/solver language |

No comprehension-risk inconsistency requires immediate repair.

## 8. Glossary ownership

Existing lightweight owners are sufficient:

- `content/_meta/term_introduction_contract_v1.json` owns exact first-use
  definition paths for priority terms.
- `tools/term_coverage_scanner.dart` enforces order and definition presence.
- `content/_meta/term_registry.jsonl` remains a reference registry, not a
  learner-visible glossary product.
- Route copy and lesson-local definitions are the right current repair path.

Conclusion: do not build a full searchable glossary screen. Do not add tappable
definition UI. Future fixes should prefer first-use expansion or lesson-local
definition, then scanner ownership when recurrence and source order justify it.

## 9. High-risk world matrix

| World | New/risky terms | Audit result | Blockers |
| --- | --- | --- | --- |
| W1 | actions, streets, equity, seat labels | action words and table clues are plain; equity is scanner-owned | 0 |
| W2 | OOP, paired, outs, draw, texture, value/bluff seeds | scanner and examples cover the critical terms | 0 |
| W3 | position, multiway, preflop map | optional clarity risk for lower-density W3, no blocker | 0 |
| W4 | price, purpose, probe, blockers | scanner and normalized route source support first use | 0 |
| W5 | draw, outs, board awareness | supported by W2/W5 content; optional watch for draw density | 0 |
| W6 | range, combo, blockers | combo/blockers scanner-owned; range is contextual | 0 |
| W7 | visible-card range narrowing, trips | route copy says visible cards narrow possible hands, not exact proof | 0 |
| W8 | flush/open-ended/one-gap/gutshot, future-card improvement | route copy contextualizes terms; one-gap optional watch | 0 |
| W9 | call price, pot reward, pot odds | route copy defines price against pot reward | 0 |
| W10 | value/bluff, worse hands, stronger hands | beginner target language is present; correctness nuance deferred | 0 |
| W11 | dry/connected/suited texture, danger, path | source-owned and table-context ready; no broad glossary need | 0 |
| W12 | review, missed cue, process, payoff | cumulative review language fits prior route; no W13+ claim | 0 |

## 10. Feedback terminology

Wrong-answer feedback does not create a route blocker:

- scanner-owned terms are not introduced only after failure;
- W7-W12 route owner feedback uses the same vocabulary as prompt/context;
- W10 avoids unsupported `thin value` / `fold pressure` first-use reliance in
  the active route packs;
- Sharky phrase copy stays evidence-bounded and does not jump ahead of the
  lesson tier;
- later-improvement copy describes a clue caught later without exposing
  concept-family ids.

Some content-world track files outside the active route still contain
source-style anchor labels such as `flop_left`; those were classified as
source/drill metadata or non-active deep content, not visible route blockers for
this audit.

## 11. Internal-language leaks

No active screenshot lane showed snake_case, route ids, concept-family ids,
source task ids, telemetry keys, or template tokens.

Classification:

- `world*_spine_*`, `conceptFamilyId`, `repairFocusId`, `skillAtomId`,
  `sourceTaskId`, and `errorType`: source/test metadata, not learner visible.
- JSON fields such as `hero_seat_v1`, `flop_left`, `intent_v1`, and
  `error_class`: source/drill metadata or non-rendered labels in this route
  audit.
- `No-bet-yet clue`: actual learner-facing copy, but plain enough and not
  snake_case; optional copy-watch only.

No `term_introduction_glossary_blocked_by_internal_term_leak` condition exists.

## 12. Definition quality

Current definitions are compact, local, and route-appropriate:

- `EQUITY`, `EV`, `SPR`, and `ICM` avoid formulas and solver-heavy language.
- `OUTS`, `PAIRED`, and `COMBO` are one-sentence, current-task definitions.
- `PROBE`, `BLOCKERS`, and `EXPLOIT` are accurate enough for current route
  understanding without trying to teach full strategy theory.
- W7-W12 route copy defines by use: visible cards narrow possible hands, draws
  improve on future cards, price is weighed against pot reward, value/bluff
  targets worse/stronger hands, texture changes danger, and review connects
  missed cues.

Correctness-sensitive nuances remain for the later poker-correctness review,
especially W10 value/bluff and W11 texture danger. They do not block
terminology readiness.

## 13. Route impact

Route classification: `route_safe_with_optional_gaps`.

Route impact:

- close `Term Introduction / Glossary Audit v1`;
- keep Phase 7 active;
- activate `Same-Signal / Transfer Coverage Audit v1`;
- preserve W1-W12-only boundary;
- keep Practice mapping, W13+, glossary UI, poker-correctness certification,
  and solver-light checks deferred.

## 14. Required repairs

No immediate tiny repair is required.

Deferred optional recommendations:

| Term/area | Repair type | Minimum future repair | Dependency |
| --- | --- | --- | --- |
| SB / BB / BTN / CO labels | `lesson_local_helper` | compact seat-label explainer if a current UI owner admits it | UI owner / first-use owner |
| UTG | `first_use_expansion` | define `Under the gun` before any required decision using the abbreviation | exact active route need |
| one-gap draw | `inline_definition` | keep current narrower-than-open-ended wording or add one sentence if Human QA flags it | Human QA / copy pass |
| No-bet-yet clue | `terminology_standardization` | leave as product copy unless learner testing finds it opaque | Human QA |
| W10 value/bluff nuance | `defer_to_correctness_review` | review target wording, not glossary | poker-correctness review |

No generic glossary entry is recommended without recurrence plus a clear
definition-owner benefit.

## 15. Evidence result

Evidence result: `term_introduction_route_safe_with_optional_gaps`.

Local-only evidence was saved under:

- `output/term_introduction_glossary_audit_v1/term_occurrences.tsv`
- `output/term_introduction_glossary_audit_v1/term_coverage_scanner.txt`
- `output/term_introduction_glossary_audit_v1/unknown_uppercase_scanner.txt`
- `output/term_introduction_glossary_audit_v1/core_compact/`
- `output/term_introduction_glossary_audit_v1/first_week_compact/`
- `output/term_introduction_glossary_audit_v1/active_route_w7_w12_compact/`
- `output/term_introduction_glossary_audit_v1/full_scroll_compact/`

`output/**` remains local-only and must not be committed.

## 16. Tests/validation

Validation used during this audit:

- `graphify hook-check`: passed in preflight.
- `dart run tools/term_coverage_scanner.dart`: passed.
- `dart run tools/unknown_uppercase_scanner.dart`: only reference-only `PFA`
  and `DB` reported.
- `flutter test test/tools/term_introduction_glossary_safety_v1_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart --reporter expanded`: passed.
- `flutter test test/ui_v2/act0_street_replay_contract_v1_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart --reporter expanded`: passed.
- `./tools/screen_review_fast_v1.sh core compact`: passed.
- `./tools/screen_review_fast_v1.sh first_week compact`: passed.
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`: passed.
- `./tools/screen_review_fast_v1.sh full_scroll compact`: passed.

Final repository validation is recorded in the implementation response.

## 17. Rolling Capsule Advance

Advance route state:

- `Term Introduction / Glossary Audit v1` -> CLOSED
- `Same-Signal / Transfer Coverage Audit v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/term_introduction_glossary_audit_v1.md`

## 18. Scope safety

No broad glossary implementation, new route, new screen, new dependency, W13+
work, localization architecture, Modern Table redesign, full-app copy rewrite,
solver terminology expansion, poker-correctness certification, or speculative
definition system was introduced.

## 19. Known limitations

- This is not Human QA.
- This is not a full poker-correctness review.
- It does not certify every source content file as launch-ready.
- It does not admit tappable terms or a searchable glossary.
- It does not solve optional seat-label helper ownership.
- Deep W10 track content may still contain source-style anchor labels outside
  the active route surface and should not be treated as current rendered UI.

## 20. Next recommendation

`Same-Signal / Transfer Coverage Audit v1`
