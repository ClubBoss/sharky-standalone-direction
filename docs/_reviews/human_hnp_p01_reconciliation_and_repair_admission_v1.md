# Real Human HNP P01 Reconciliation + Human-Triggered Repair Admission v1

Status: `P01_ACTIONABLE_STOP_RECONCILED`.
Freshness date: 2026-08-17.
Baseline: `3416b9720e0bcfb4925b1e96d394860efb7620d9` (`origin/main` re-resolved before reconciliation).

This is the first real Human HNP evidence reconciliation. It records one
participant session, stops the current Human campaign on actionable P1 findings,
and admits exactly one bounded product repair family. It does not claim the
five-participant HNP cohort is complete and does not promote `HUMAN_PROOF`.

## Authority transition

Before P01:

- `CURRENT_STAGE = READY_FOR_REAL_HUMAN_HNP_SESSION`
- `EXACT_NEXT_ACTION = EXECUTE_CANONICAL_REAL_HUMAN_HNP_SESSION_V1`
- `REAL_HUMAN_HNP = NOT_EXECUTED`
- `HUMAN_PROOF = FALSE`

After P01 reconciliation:

- `CURRENT_STAGE = HUMAN_TRIGGERED_REPAIR_ACTIVE`
- `REAL_HUMAN_HNP = P01_EXECUTED_ACTIONABLE_STOP`
- `HNP_P01_VERDICT = HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS`
- `ACTIVE_REPAIR_FAMILY = NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`
- `PRODUCT_IMPLEMENTATION_DISPOSITION = BOUNDED_HUMAN_TRIGGERED_REPAIR_ADMITTED`
- `HNP_HARNESS = CLOSED_UNCHANGED`
- `HUMAN_PROOF = FALSE`
- `EXACT_NEXT_ACTION = IMPLEMENT_NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`

`HNP_P01_VERDICT` is a participant/session stop verdict under the canonical HNP
protocol. It is not a claim that the full five-participant HNP cohort has been
completed. The cohort cannot be called passed while this blocker is open.

## Evidence boundary

Primary Human evidence is the owner-supplied P01 transcript/video observation
record. The following evidence is preserved verbatim where quoted:

- `"Шрифт немного маленький, и читается сложно, но в целом ок."`
- `"если честно, экран очень загруженный."`
- five tutorial advances in approximately 10 seconds, approximately 1-2 seconds
  per screen;
- correct-answer feedback advanced in less than 1 second;
- `"Тут нет никакого окошка, что нужно сделать..."`
- `"Допустим, выбрала. И всё, дальше я идти не могу."`

Separate supporting deterministic observer evidence records informative
learning-table element collisions. That collision evidence corroborates scene
legibility risk but is not converted into Human comprehension evidence.

No screenshot, telemetry, AI review, deterministic observer run, or harness
result is promoted to Human proof.

## P01 finding ledger

| ID | Classification | Evidence | Severity | Confidence | Learning/product impact | Disposition |
| --- | --- | --- | --- | --- | --- | --- |
| `HNP-P01-F01` | `NOVICE_READABILITY_FRICTION` | `"Шрифт немного маленький, и читается сложно, но в целом ок."` | `P2` | `HIGH` | Reading effort is elevated in the active learning scene, but the participant did not describe this alone as a route blocker. | Repair inside the admitted learning-scene family. |
| `HNP-P01-F02` | `LEARNING_SCENE_SCANABILITY_OVERLOAD` | `"если честно, экран очень загруженный."` | `P2` | `HIGH` | Competing visual/instructional information weakens hierarchy and makes the next required action harder to parse. | Repair scene hierarchy/composition only. |
| `HNP-P01-F03` | `TUTORIAL_CONTENT_SKIM_SIGNAL` | Five tutorial advances in approximately 10 seconds; approximately 1-2 seconds per screen. | `P2` | `HIGH` | Strong corroborating signal that tutorial steps can be mechanically advanced before their teaching point becomes salient. It is not, by itself, proof of non-learning. | Improve instructional hierarchy and continuation sequencing; do not add arbitrary dwell timers. |
| `HNP-P01-F04` | `FEEDBACK_SALIENCE_INSUFFICIENT` | Correct-answer feedback advanced in less than 1 second. | `P2` | `HIGH` | The feedback/learning payoff can be passed before the learner has a clear visual reason to process it. | Strengthen feedback hierarchy and explicit continuation semantics; no forced reading-time lock. |
| `HNP-P01-F05` | `REQUIRED_ACTION_AFFORDANCE_UNCLEAR` | `"Тут нет никакого окошка, что нужно сделать..."` | `P1` | `HIGH` | A novice cannot independently identify the required interaction. This violates the HNP decision-comprehension / reachable-interaction criterion. | Immediate Human campaign stop; repair required. |
| `HNP-P01-F06` | `POST_CHOICE_CONTINUATION_BLOCKER` | `"Допустим, выбрала. И всё, дальше я идти не могу."` | `P1` | `HIGH` | The novice perceives a dead end after making a choice and cannot independently continue. This violates the HNP exit/continuation criterion. | Immediate Human campaign stop; repair required. |
| `HNP-P01-F07` | `INFORMATIVE_TABLE_ELEMENT_COLLISION` | Deterministic observer evidence of informative table-element collisions in the relevant learning scene. | `P2` | `HIGH` | Important table context competes spatially or overlaps, degrading table legibility and amplifying the P01 scanability/affordance failure. | Repair only the relevant learning-table composition/allocation seam. |

### Severity reconciliation

The active repair admission is driven by `HNP-P01-F05` and `HNP-P01-F06`.
Under the canonical protocol, a P0/P1 route failure is a stop condition and a
real reproducible Human/product blocker maps to
`HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS`.

`HNP-P01-F01` through `F04` and `F07` are not independently used to expand
scope. They are supporting findings inside the same novice-comprehension /
learning-scene-legibility failure family.

## Root-cause family

Admit one bounded family only:

`NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`

Target outcomes:

1. required interaction affordance is obvious without observer rescue;
2. the learning scene has one dominant instructional/action hierarchy;
3. selection deterministically leads to visible, understandable feedback and a
   reachable explicit continuation path;
4. feedback has enough structural salience to communicate the teaching point
   before the continuation control becomes the dominant target;
5. informative table elements remain legible and non-colliding in the HNP
   learning scene;
6. learner-facing type and spacing are readable at supported phone/text-scale
   fixtures without opening a broad visual redesign.

This family is structural product repair triggered by Human evidence. It is not
cosmetic polish.

## Canonical owner cone

Primary production owner:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

Relevant existing seams include:

- `Act0LessonRunnerShellV1`
- `_buildIntegratedLearningSceneV1`
- `_buildIntegratedLearningSceneWithAllocationV1`
- `_buildIntegratedLowerSurfaceV1`
- `_LearningRailV1`
- `Act0FeedbackShellV1`
- `_RunnerTableStageV1`
- existing composition/allocation logic used by the integrated learning scene

Codex may touch tightly coupled existing helpers/tests only when required to
close this owner cone. It must not use this admission to refactor unrelated
Act0 architecture.

## Codex implementation mission

Mission: `NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`

Repository: `ClubBoss/sharky-standalone-direction`

Required starting rule:

- re-resolve live `origin/main` before work;
- expected admission baseline is
  `3416b9720e0bcfb4925b1e96d394860efb7620d9`;
- if live main changed, reconcile the delta against this P01 authority before
  mutating product code;
- read `AGENTS.md`, this reconciliation artifact,
  `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`, and only directly relevant HNP
  sections of `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`;
- do not reopen the HNP harness.

### Objective

Implement the smallest coherent structural repair that makes the canonical
Act0 learning scene understandable and operable by a novice without observer
rescue, while preserving learning semantics, route truth, telemetry contracts,
and the accepted product visual foundation.

### Required repair behaviors

1. **Explicit task/action affordance**
   - In the affected decision/table state, the learner can identify what must be
     done and where to interact from the visible scene.
   - Do not rely on the observer, hidden gesture knowledge, or a below-fold CTA
     whose existence is not discoverable.

2. **Deterministic post-choice progression**
   - A valid learner choice must lead to an unmistakable feedback state.
   - The next deliberate action must be visible/reachable and must not leave the
     learner in a perceived dead end.
   - Preserve the existing evaluation, repair/recheck, route, and telemetry
     semantics.

3. **Scene scanability**
   - Reduce competing emphasis in the active learning scene so the instructional
     focal point, table context, choice area, and continuation hierarchy are
     visually unambiguous.
   - Prefer layout, grouping, spacing, information hierarchy, and existing design
     tokens over decorative restyling.

4. **Feedback salience**
   - Correct and wrong feedback must clearly expose the result/teaching point and
     the deliberate continuation action.
   - Do not add arbitrary time locks, countdowns, disabled-until-timeout logic,
     or artificial mandatory reading duration.

5. **Table legibility**
   - Remove informative learning-table element collisions in the relevant HNP
     viewport states through bounded allocation/anchor/layout repair.
   - Do not redesign Modern Table and do not generalize this into a new table-art
     system.

6. **Readability**
   - Correct the directly evidenced learner-facing readability friction using the
     smallest supported typography/line-length/spacing adjustments inside the
     learning-scene owner cone.
   - Preserve existing design-system contracts unless a local contract is proven
     causal to the HNP failure.

### Explicit non-scope

Do not:

- modify or reopen the HNP harness/protocol to make the result pass;
- claim screenshots, AI review, CI, or telemetry as Human proof;
- start premium room/table/avatar/Blender/3D/photorealistic art production;
- redesign Modern Table;
- add new curriculum, lessons, poker concepts, or content expansion;
- add arbitrary dwell timers or forced-reading locks;
- change route architecture, telemetry architecture, persistence, or
  personalization systems unless a directly touched existing contract requires
  a minimal compatibility fix;
- add new dependencies;
- open mascot, motion, monetization, store, dashboard, ML/remote-AI, or unrelated
  visual-polish work;
- perform broad refactors, speculative guards, tests-for-tests, or unrelated
  cleanup.

## Definition of Done

All conditions are required:

1. `HNP-P01-F05` is structurally closed: a novice-facing required action is
   explicit, discoverable, and reachable in the canonical affected scene without
   observer rescue.
2. `HNP-P01-F06` is structurally closed: after a valid choice, feedback appears
   deterministically and an explicit reachable continuation path exists; no
   affected branch presents a dead end.
3. `HNP-P01-F02/F03/F04` are closed as one hierarchy/salience repair: tutorial,
   decision, and feedback states present one clear dominant next-purpose/action
   hierarchy. No time-based reading lock is introduced.
4. `HNP-P01-F01` is closed within bounded scope: learner-facing text in the
   affected learning scene is readable without introducing overflow or clipping
   in supported fixtures.
5. `HNP-P01-F07` is closed: informative table elements do not collide in the
   canonical HNP learning-scene viewport fixtures.
6. Compact/nominal/tall/large phone fixtures and the repository's existing
   enlarged-text fixture for this scene remain overflow-free, safe-area-safe,
   and interaction-reachable.
7. Existing Action evaluation, personalized wrong-feedback, same-signal repair,
   recheck, payoff/next-step, and telemetry event semantics remain unchanged
   unless a minimal compatibility adjustment is strictly required by the local
   composition repair and is explicitly documented.
8. No new dependency, asset family, route, curriculum item, premium-art surface,
   Modern Table redesign, or HNP harness machinery is introduced.
9. `dart format` is clean for touched Dart files; `flutter analyze` passes;
   targeted owner-cone tests pass; `./tools/fast_loop_world1_v1.sh` passes; and
   the repository's normal pre-PR gate is run according to live `AGENTS.md`.
10. Deterministic screenshot/layout evidence may be used to prove regression
    closure but is labeled implementation evidence only, never Human proof.
11. The repair PR reports the exact files changed, maps each product diff back to
    `HNP-P01-F01..F07`, and identifies any finding not fully closed instead of
    widening scope.
12. `HUMAN_PROOF` remains `FALSE` after implementation and CI. Human validation
    resumes only after the repair is green and integrated.

## Human re-entry rule

Do not resume the cohort on the broken candidate. After the bounded repair is
integrated and deterministic regression evidence is green, re-resolve the new
candidate and resume the canonical protocol with a fresh eligible novice.

P01 remains valid failure evidence and is not retroactively converted into a
pass by implementation evidence. A repeat by the already-exposed P01 may be
useful as non-fresh regression feedback, but it must not substitute for the
fresh-participant Human gate.

## Protected deferred scope

`HNP_HARNESS = CLOSED_UNCHANGED`.

`VISUAL_NORTH_STAR_ART_PRODUCTION = DEFERRED_POST_HNP_REPAIR_AND_HUMAN_REENTRY`.

Premium room art, avatar/character production, Blender, layered 2.5D expansion,
photorealism, new lighting/shader work, broad Modern Table redesign, and generic
visual polish remain deferred. P01 admits only the structural learning-scene
repair required by the evidence above.

`CURRENT_STAGE = HUMAN_TRIGGERED_REPAIR_ACTIVE`
`EXACT_NEXT_ACTION = IMPLEMENT_NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`
`HNP_P01_VERDICT = HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS`
`ACTIVE_REPAIR_FAMILY = NOVICE_COMPREHENSION_AND_LEARNING_SCENE_LEGIBILITY_V1`
`HUMAN_PROOF = FALSE`
