# Original Three-Agent Audit Crosswalk v1

Status: ACTIVE source-truth reconciliation. Published baseline reviewed:
`cf0b4c8b4abd9ac9a0265b58f0f8aa6b5185e4fa`.

## Method and safety result

This is a direct crosswalk, not a synthesis replacement. The complete original
packages were inspected at `output/product_audit/current/`:
`antigravity_visual_ux_v1` (15; frozen candidate `11715b50`),
`claude_learning_content_v1` (16; frozen candidate `11715b50`), and
`codex_source_truth_feasibility_v1` (10; frozen candidate `11715b50`).
Their originating working heads were respectively `11715b50`, `b4068fa4`, and
`b4068fa4`. `main`, `HEAD`, and `origin/main` were all the baseline above;
tracked and staged diffs were empty. Existing untracked `output/`, `tmp/`,
contract, and local-test evidence was observed and left untouched.

Disposition is factual; scope is separate. “Current source verification” means
the canonical `AppRoot -> _EntryGate -> Act0ShellPreviewScreenV1` route and its
actual owners were examined at the published baseline. A Human claim is never
silently converted to a closure; an opportunity is never counted as a defect.

## Exact 41-row inventory

| ID | Original classification / exact claim | Original evidence / audited head | Current owner and reproduction | Later evidence / scope | Factual disposition | Exact current evidence; uncertainty; repair family |
| --- | --- | --- | --- | --- | --- | --- |
| AG-VUX-F01 | CONFIRMED_P0: no first-60-second micro-aha | Journey audit; `11715b50` | Home/first W1 owner; not mechanically falsifiable | Human QA required | CURRENT_SOURCE_VERIFICATION_REQUIRED | No deterministic retention metric proves or disproves felt aha; `HUMAN_QA_REQUIRED`; first-session comprehension/payoff family if observed. |
| AG-VUX-F02 | CONFIRMED_P1: table-motion alpha residue | Visual audit; `11715b50` | Act0 motion/render owners; no active regression | Motion is deferred | CLOSED_INTENTIONAL | Later milestone-motion work exists, but feedback transition polish is a `FUTURE_CAPABILITY`, not a current route defect. |
| AG-VUX-F03 | HUMAN hypothesis: compact feedback text not scannable | Visual audit; `11715b50` | Runner/lower surface | Human QA required | CLOSED_VERIFIED_PASS | `2e86b4c` fixed reachable bounded scroll/1.4x mechanics; comprehension remains `HUMAN_QA_REQUIRED`. |
| AG-VUX-F04 | CONFIRMED_P2: Sharky tone static across worlds | Copy/visual audit; `11715b50` | Act0 copy owners | Future mascot/copy capability | CLOSED_INTENTIONAL | Source has no tier-register system; this is `FUTURE_CAPABILITY`, not a freeze-blocking functional defect. |
| AG-VUX-F05 | STRATEGIC: pattern-level Review coaching | Review audit; `11715b50` | Review/evidence projections | AI Personalization later | CLOSED_INTENTIONAL | Current Review is item/family based; `FUTURE_CAPABILITY` under AI Personalization. |
| AG-VUX-F06 | CONFIRMED_P2: abrupt session closure | Journey audit; `11715b50` | Session payoff owner | Later payoff integration | CLOSED_FIXED | Learning Run payoff is landed; source/tests distinguish mastered/recovered/insufficient evidence and explicit Learn-to-Home close. |
| AG-VUX-F07 | Competitive gap: no street replay context | Journey audit; `11715b50` | Multi-street content/runner | Not in Act0 release scope | CLOSED_INTENTIONAL | `OUTSIDE_CURRENT_RELEASE_SCOPE`; no false claim that the current single-spot route supplies it. |
| AG-VUX-F08 | CONFIRMED_P3: Profile clutter risk | Profile audit; `11715b50` | Profile shell | Human/polish observation | CLOSED_VERIFIED_PASS | Current source has bounded proof/fixes presentation; felt clutter remains `HUMAN_QA_REQUIRED`, not a source defect. |
| AG-VUX-F09 | HUMAN hypothesis: paywall/trial trust | Entry audit; `11715b50` | Monetization boundary | No paywall on canonical Act0 route | CLOSED_VERIFIED_PASS | Current route contains no premium-trial prompt before repair; future commerce remains `HUMAN_QA_REQUIRED`. |
| AG-VUX-F10 | CONFIRMED_P3: localization hardcoding | Copy audit; `11715b50` | Act0 strings | Post-Human maintenance | CLOSED_INTENTIONAL | English-first source remains; `POST_HUMAN_TECHNICAL_RISK`, not a current English-route defect. |
| AG-VUX-F11 | STRATEGIC: W1 completion graduation payoff | Journey audit; `11715b50` | World payoff owner | Later world-completion work | CLOSED_FIXED | Completion/milestone payoff owner and guards exist; no remaining missing-functional-payoff reproduction. |
| AG-VUX-F12 | CONFIRMED_P4: mixed achievement visual language | Visual audit; `11715b50` | Presentation assets | Art-system capability | CLOSED_INTENTIONAL | `FUTURE_CAPABILITY`; does not demonstrate a functional canonical-route fault. |
| AG-VUX-F13 | CONFIRMED_P3: Welcome feels like World 0 | Map/onboarding audit; `11715b50` | Entry/Welcome owners | Later route/placement closure | CLOSED_FIXED | Current cold-start Act0 Home and placement-forward contracts separate Welcome/onboarding from world progression. |
| AG-VUX-F14 | Competitive gap: premium value preview subtle | Commercial audit; `11715b50` | Monetization route | Not release scope | CLOSED_INTENTIONAL | `FUTURE_CAPABILITY`; no paid-depth contract is admitted by this freeze. |
| AG-VUX-F15 | STRATEGIC: personalized Day-2 return reason | Retention audit; `11715b50` | Return/personalization owner | AI Personalization later | CLOSED_INTENTIONAL | `FUTURE_CAPABILITY`; no false Day-2 claim is made by the current shell. |
| CL-LRN-F01 | CONFIRMED_P1: no time-based spaced repetition | Evidence record has no timestamp; `11715b50` | Evidence/retention projections | Retention capability | CLOSED_FIXED | Schema 17 persists injected UTC event time and review kind; the canonical state machine schedules 24h, 72h, and 7d checks through the existing Review route. Legacy evidence remains untimestamped and claim-safe. See `DURABLE_RETENTION_TRANSFER_CONTRACT_v1.md`. |
| CL-LRN-F02 | CONFIRMED_P1: W7 one-lesson depth cliff | `_visibleCardRangeContinuationLessons`; `11715b50` | `act0_shell_state_v1`; reproducible | Current route content | PRODUCT_DEBT_CONFIRMED | Current list contains only `_w7VisibleCardComboDensityLesson`; generated task specs do not make multiple learner-visible lessons. `CURRENT_RELEASE_SCOPE`; `W7 authored lesson-depth`. |
| CL-LRN-F03 | CONFIRMED_P2: generic error taxonomy | Six atoms/table-read; `11715b50` | `act0_concept_error_contract_v1.dart`; 291-task/466-option census | AI personalization dependency | CLOSED_FIXED | Canonical decision evidence now uses 20 source-owned misconception ids across all 466 incorrect options; zero options lack repair intent. Legacy generic string values remain readable without schema change. Full inventory: `CONCEPT_ERROR_REPAIR_INTEGRITY_V1.md`. |
| CL-LRN-F04 | CONFIRMED_P2: W7 authoring metadata leaks | W7 spec projection; `11715b50` | W7 spec runner; reproducible | Current route content | CLOSED_FIXED | Learner-facing title, hint, feedback title, theory title, and focus labels now use intentional beginner copy. `learningPurpose` and `conceptFamilyId` remain internal authored metadata and the deterministic learner-surface guard rejects the leaked family id. |
| CL-LRN-F05 | CONFIRMED_P2: repair mapping minority coverage | mapping switch; `11715b50` | Complete 34-row registry and repair resolver | Current route loop | CLOSED_FIXED | All 34 prior gaps are explicit: 20 alternate same-signal targets and 14 guarded intentional exact replays, with zero unresolved or unrecorded fallbacks. `blinds_review` now asks and marks UTG as the first preflop actor; its exact replay is launchable. Different-target coverage remains 277/291 (95.2%). |
| CL-LRN-F06 | CONFIRMED_P2: binary decisions inflate mastery | complete 121-row adjudication; `6eb79805` | `DECISION_DISCRIMINATION_V1.md`; assessed-row guard | Current route curriculum | CLOSED_INTENTIONAL | Every canonical two-option assessment is individually adjudicated. All 121 are source-proven inherently binary at their route point; no third misconception is both already introduced and compatible with the task/repair contract. Census remains 121/291 two, 165/291 three, 5/291 four; checkpoints 12/37 and repair targets 8/16; correct positions 112/115/62/2, longest run 3. No filler option or fingerprint change is admitted. Next Top-1: W7 Depth Authority (F02). |
| CL-LRN-F07 | CONFIRMED_P2: late worlds favor recall | W9-W12 samples; `11715b50` | W9-W12 route tasks; reproducible | Content-depth decision | CLOSED_FALSE_POSITIVE | The canonical W9-W12 census finds 58 assessed rows: 29 table-action decisions and 29 table-clue/range inferences; all require visible table state and none classify as terminology-only recall. This does not prove broad curriculum quality, but it falsifies the asserted recall dominance. |
| CL-LRN-F08 | CONFIRMED_P3: immutable first-vs-latest transfer | transfer bucket; `11715b50` | Transfer measurement | Learning-claim integrity | CLOSED_FIXED | Recent timestamped evidence now requires 24h separation plus task/session diversity and yields insufficient, recovered-not-durable, improving, stable, regressing, or mixed. Equal-time ordering is deterministic. |
| CL-LRN-F09 | CONFIRMED_P3: inverted/negative prompts | W4 examples; `11715b50` | Content state owner; reproducible | Current curriculum | CLOSED_FIXED | `w4_value_missed` now asks directly which action collects value from worse hands. It preserves the two-option decision, task id, correct option position, and repair identity while making `bet_half` the poker-correct positive answer. |
| CL-LRN-F10 | CONFIRMED_P3: W1 trivial/UI-referential items | hero badge question; `11715b50` | `_meetTableRunner`; reproducible | First-session learning | CLOSED_FIXED | First-table assessments now require preflop-order reading and learner-identity-versus-seat-role inference; they no longer ask learners merely to repeat the visible You/Hero badge. Task ids and option positions remain compatible. |
| CL-LRN-F11 | CONFIRMED_P3: one correct clears repeat-miss family | repair memory; `11715b50` | Retention/due selection | Retention/selection | CLOSED_FIXED | One recovery schedules a future due recheck; repeated misses remain preserved through recovery and lapse. Due selection is earliest-due, severity, concept, then task, and launches the existing Review/runner route. |
| CL-LRN-F12 | CONFIRMED_P4: naming/alias hazards | alias runner names; `11715b50` | State authoring names | Maintenance risk | CLOSED_INTENTIONAL | Not learner-visible by itself; `POST_HUMAN_TECHNICAL_RISK` with owner-aligned extraction/renaming only when touching content. |
| CL-LRN-F13 | HUMAN hypothesis: W8-W9 jargon ramp | static content; `11715b50` | W8-W9 content | Human evidence | CURRENT_SOURCE_VERIFICATION_REQUIRED | Source confirms terms but not novice tolerance, latency, or quitting; preserve as `HUMAN_QA_REQUIRED`. |
| CL-LRN-F14 | HUMAN hypothesis: recap feels filler | static content; `11715b50` | Recap runners | Human evidence | CURRENT_SOURCE_VERIFICATION_REQUIRED | Source confirms recap reuse but not learner perception; preserve as `HUMAN_QA_REQUIRED`. |
| CL-LRN-F15 | CONTENT opportunity: interleaved W2/W3 drills | audit recommendation | Curriculum plan | Opportunity | CLOSED_INTENTIONAL | `STRATEGIC_OPPORTUNITY`, not a present defect. |
| CL-LRN-F16 | STRATEGIC: pour all content into evidence skeleton | audit recommendation | Curriculum/evidence owners | Opportunity | CLOSED_INTENTIONAL | `STRATEGIC_OPPORTUNITY`; F03/F05 are concrete prerequisite debt, not proof that the opportunity is implemented. |
| CX-ST-F01 | CONFIRMED_P2: Quick Table overflow | failing 430x932 test; `11715b50` | Lower surface | `fe57219e`, `2e86b4c` | CLOSED_FIXED | Active selected test inclusion and bounded scroll/geometry contract remove the reproduced overflow. |
| CX-ST-F02 | TECHNICAL_RISK: no HNP live sink | AppRoot did not compose sink | Telemetry composition | `2507b1b2`, `fefb7c36` | CLOSED_FIXED | `Act0HnpTelemetrySinkV1` with opt-in JSONL evidence exists; live owner proof is recorded. |
| CX-ST-F03 | TECHNICAL_RISK: telemetry SSOT/cardinality divergence | source/map mismatch | Telemetry owner | `eef22eb8`, `fefb7c36` | CLOSED_FIXED | Canonical trace and repair-start cardinality closure reconcile active HNP telemetry; no active counterexample found. |
| CX-ST-F04 | TECHNICAL_RISK: persistence stronger than discovered tests | legacy non-test file | Persistence owner | `f3ab667c`, `8147990c` | CLOSED_FIXED | Active discovered round-trip authority is promoted and protects schema-16 restore/write behavior. |
| CX-ST-F05 | TECHNICAL_RISK: active route test omitted | selected gate excluded alpha journey | Test manifest | selected-tests update | CLOSED_FIXED | `tools/_world1_selected_tests_v1.sh` includes `alpha_journey_progression_truth_v1_test.dart`; prior overflow cannot hide behind the gate. |
| CX-ST-F06 | TECHNICAL_RISK: W8-W12 route/fixture authority | hidden owners used by capture | State/capture owners | `8147990c` | CLOSED_FIXED | Current capture metadata distinguishes active route from fixture/capture and source proof labels authority; no fixture-only claim is retained. |
| CX-ST-F07 | TECHNICAL_RISK: huge owner concentration | line counts | Preview/state/runner | Engineering risk | CLOSED_INTENTIONAL | `POST_HUMAN_TECHNICAL_RISK`; no safe broad refactor is justified in this freeze. |
| CX-ST-F08 | HUMAN hypothesis: no full-shell accessibility proof | runner-focused coverage | Shell semantics | Human QA | CURRENT_SOURCE_VERIFICATION_REQUIRED | Runner 1.4x/tap-target coverage is not a VoiceOver full-shell journey; preserve as `HUMAN_QA_REQUIRED`. |
| CX-ST-F09 | TECHNICAL_RISK: release identity/observability deferred | package IDs/release config | Release owners | Store release later | CLOSED_INTENTIONAL | `OUTSIDE_CURRENT_RELEASE_SCOPE`; not an Act0 freeze defect, but visible technical risk. |
| CX-ST-F10 | TECHNICAL_RISK: split startup readiness | Entry/preference owners | Entry gate/bootstrap | Current cold-start tests | CLOSED_VERIFIED_PASS | Current canonical cold-start contracts prevent intake/placement flash; compatibility preference complexity remains `POST_HUMAN_TECHNICAL_RISK`. |

## Duplicate groups and reconciliation corrections

`DG-RETENTION` = CL-LRN-F01/F08/F11; `DG-W7-CONTENT` = F02/F04;
`DG-LEARNING-DISCRIMINATION` = F06/F07/F09/F10; `DG-REPAIR-COVERAGE` = F03/F05;
`DG-HUMAN` = AG-VUX-F01/F03/F08/F09, CL-LRN-F13/F14, CX-ST-F08; and
`DG-TECHNICAL-RISK` = CL-LRN-F12, CX-ST-F07/F09/F10. Each retains its row.

The prior KDZ and Closure Packet do not contain these original package IDs and
therefore incorrectly represent their 41 claims as reconciled. They also merge
learning-content claims into generic content/proof closure and declare zero
current product debt without source verification of F01-F11. The prior closures
for compact layout, live HNP sink, telemetry cardinality, persistence discovery,
selected-test inclusion, W8-W12 authority labeling, placement/Welcome
separation, and session payoff are supported. Its blanket candidate-freeze and
``current-release active product defects: 0`` claim is not supported.

## Freeze decision and next work

Corrected Claude row-inventory counts are **9 confirmed product debts, 2
quantitative censuses, 2 Human requirements, and 3 future/risk/opportunity
rows**. The old `8 / 2 / 2 / 4` aggregate was a count typo. These are
factual-disposition counts, not mutually exclusive scope classes.

After Blinds Action-Order Truth Repair, the factual Claude disposition is
**5 current product debts** (F01/F02/F06/F08/F11), **5 CLOSED_FIXED**
(F03/F04/F09/F10), **1 CLOSED_FALSE_POSITIVE** (F07), **2 Human
requirements** (F13/F14), and **3 future/risk/opportunity**. The mutually
exclusive scope classes remain: **6 current-release product-debt rows**
(F01/F02/F05/F06/F08/F11), **2 Human-only rows** (F13/F14), **1
post-Human technical-risk row** (F12), **2 strategic-opportunity rows**
(F15/F16), and **5 closed current-source rows** (F03/F04/F07/F09/F10). Human
uncertainty is not counted as factual source closure.

Current confirmed product debt from this learning group is CL-LRN-F02 only.
F01/F08/F11 are closed by Durable Retention & Transfer v1; F02 remains open
because no authority supplies a minimum W7 lesson count, and no lesson count is
invented here.

### Learning-content inventory notes

- **Negative frames:** the canonical assessed-question scan found no remaining
  `not`, `except`, `wrong`, `misses`, or `least` reverse-selection question.
  The learner-visible “fix mistakes after a miss” route-role question is a
  necessary navigation fact, not an inverted poker assessment. Retained
  “before” phrasing is temporal sequencing, not negative framing.
- **W1 UI-referential items:** the original direct You/Hero-label assessments
  are replaced. The remaining W1 badge/marker language teaches table identity
  or BTN as a table object; it is not scored as the answer-equivalent learner
  identity claim. The two scored first-table identity tasks now require action
  order and player-versus-position inference.
- **W7 depth:** W7 has one learner-visible lesson containing four authored
  assessed rows plus recap/review. The Master Plan admits its spine and task
  concepts but specifies no minimum lesson count or structural threshold;
  `W7_DEPTH_BLOCKED_BY_CONTENT_AUTHORITY` is therefore preserved.

### Next Top-1 selection

1. **Decision Discrimination — CLOSED_INTENTIONAL.** All 121 binary rows are
   source-proven two-state at their route point; no filler option was admitted.
2. **Durable Retention & Transfer — CLOSED_FIXED.** F01/F08/F11 now have a
   deterministic UTC, persistence, selection, Review, transfer, and claim-safe
   architecture.
3. **W7 Depth Authority — selected next.** F02 still lacks an authoritative
   outcome-based minimum-depth contract; no arbitrary lesson count is inferred.

Project-level freeze is **not allowed**. No Final Deep Independent Audit, Human
Novice Proof, or AI Personalization work starts from this record. The selected
next Top-1 is **W7 Depth Authority (CL-LRN-F02)**, which must establish an
outcome-based content-depth authority before any authored W7 expansion.

### Copyable next goal

> GOAL: W7 DEPTH AUTHORITY V1. Starting from the published Durable Retention &
> Transfer contract and CL-LRN-F02, establish an outcome-based minimum-depth
> authority for the learner-visible W7 route before changing authored content.
> Reconcile Master Plan intent, current W7 route/task truth, W6->W7 and W7->W8
> seams, prerequisite knowledge, transfer/repair coverage, and novice cognitive
> load. Define measurable admission criteria for concept progression, varied
> table evidence, misconception discrimination, repair/recheck, spaced transfer,
> payoff, and route pacing; do not infer an arbitrary lesson count. Implement
> only the smallest bounded W7 packet the new authority admits, if any, while
> preserving W1-W6/W8-W12 content, task identities unless explicitly
> adjudicated, schema 17, telemetry names/cardinality, Review, payoffs, route
> locks, and all unrelated evidence. Do not begin Human QA, Final Deep Audit, AI
> Personalization, visual redesign, monetization, or W8+ expansion. Publish only
> after focused content/correctness, repair, fingerprint, selected-route, fast,
> release, analyzer, Graphify, diff, and repository-hygiene gates pass.
