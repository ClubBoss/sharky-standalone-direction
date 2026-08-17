# VISUAL GAUNTLET B5 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B5_ATTENTION_AWARE_RENDERING_V1`
Starting live `origin/main`: `2766d94fec110a5f21e776ba830917c81bc0042a`
(contains B4 integrated main via PR #192, B4 = `CLOSED_PASS`)
Branch: `feat/visual-gauntlet-b5-attention-aware-rendering-v1`
Primary viewport: `402x874`.
Produced BEFORE any production mutation, from merged B4 renders of
decision / wrong feedback / targeted repair / targeted recheck.

## 0. What B4 left behind

The scene is **state-blind**. Rendered side by side, decision, wrong feedback,
repair and recheck are pixel-comparable except for header copy and the lower
surface. Every object — room, six players, cloth, board, chips, plates, hero —
carries the same visual weight in every state, so the learner re-scans the whole
scene at every step.

One specific artefact: B4's clue bracket is **always on**. It marks the causal
anchor identically during decision and recheck as during feedback, so it
currently carries no state information and sits closer to permanent decoration
than to a pointer.

## 1. Gap map — required classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Theory focal hierarchy | `B5` | teaching copy and table compete at equal weight |
| 2 | Decision focal hierarchy | `B5` | **largest gap.** Situation and action carry identical salience to decoration |
| 3 | Eligible-target fairness | `PROTECTED` | selectable seats are equal today and **must stay equal** — B5 must not tilt them |
| 4 | Active-player salience | `B5` | active player indistinguishable from the rest at a glance |
| 5 | Irrelevant-player salience | `B5` | six players at full weight in every state |
| 6 | Environment salience | `B5` | room never recedes, even during feedback |
| 7 | Hero-card salience | `PROTECTED` | readable now; must stay readable in every state |
| 8 | Board salience | `B5` | never rises during feedback about the board |
| 9 | Bet/pot salience | `B5` | constant weight regardless of relevance |
| 10 | Feedback causal-clue salience | `B5` | bracket is present but the field around it is not quieted |
| 11 | Verdict vs table-clue balance | `PARTLY STRONG` | Wave A copy hierarchy is good; the scene does not follow it |
| 12 | Wrong-feedback hierarchy | `B5` | identical scene weighting to a correct answer |
| 13 | Repair-target reacquisition | `B5` | repair looks like a fresh decision; nothing helps re-find the target |
| 14 | Recheck answer-leak risk | `B5 — RISK` | always-on bracket persists into recheck; must not become a standing pointer |
| 15 | B4 clue compatibility | `B5` | B5 must drive the existing B4 anchor, not add a second marker |
| 16 | Far-player distraction | `B5` | far figures hold full contrast during feedback |
| 17 | Near-player distraction | `B5` | near figures are the largest non-learning objects on screen |
| 18 | Responsive hierarchy | `RISK — B5 must manage` | attenuation must hold at compact and large |
| 19 | 1.4x text interaction | `RISK — B5 must manage` | must not reduce text contrast at large text |
| 20 | Accessibility / contrast risk | `RISK — B5 must manage` | attenuation is bounded and never applied to copy, cards or actions |
| 21 | Premium restraint | `B5` | the answer is a quieter field, never "everything important glows" |

### Explicitly NOT B5

| Gap | Class |
| --- | --- |
| Semantic motion, transitions, chip flight, animated focus | `DEFERRED B6` |
| Final cohesion, parity, costume/room richness, table oval identity | `DEFERRED B7` |

Table oval residual debt stays `DEFERRED_TO_B7` and is untouched.

## 2. Largest class-level B5 gap

**The scene does not know what the learner is doing.** Items 1, 2, 4-6, 8-13 and
16-17 are one gap: there is no salience model, so no object can recede and none
can rise.

## 3. Approach chosen

New module `lib/ui_v2/act0_shell/act0_scene_salience_v1.dart`:

- `Act0SceneAttentionPhaseV1` — derived **only** from deterministic state Wave A
  already exposes: theory, decision, correct feedback, wrong feedback, repair,
  recheck.
- `Act0SceneSalienceTierV1` — `primary` / `supporting` / `ambient`.
- `Act0SceneAttentionV1` — resolves a phase to bounded recession values for the
  room plane, the player plane, and the clue anchor's emphasis.
- `Act0SceneRecedeV1` — applies bounded **desaturation plus luminance drop** to
  a subtree via a colour matrix.

Mechanism choice: **no blur.** A colour-matrix recession is deterministic,
costs no raster pass, keeps every edge sharp for accessibility, and cannot
smear poker information. Blur was not adopted because nothing in the measured
evidence showed it materially better, and the admission explicitly warns
against using it because a benchmark does.

Attenuation is applied **only** to the environment plane and the player plane.
Cards, board, pot, bets, plates, hero, teaching copy and the action dock are
never attenuated — that is what keeps the scene fair and readable.

Eligible-target fairness is preserved by construction: recession is applied per
*plane*, never per seat, so no selectable seat can be made to stand out.

## 4. Protected foundation

Unchanged: B1 planes/perspective/anchors, B2 material/room/light, B3
characters/postures/hero, B4 nameplates/puck/clue anchor; Wave A learning
hierarchy, interaction grammar, answer truth, evaluation, feedback semantics,
repair/recheck logic, continuation, telemetry, accessibility, responsive
support.

`HUMAN_PROOF = FALSE`

---

# B5_PHASE_SIGNAL_BLOCKER — RAISED, ADMITTED, RESOLVED

Raised per the completion-pass instruction. Mastermind verified it and approved
a minimal exposure of the existing learning-route stage. **Resolved below.**

## What was required

The renderer must deterministically separate targeted repair from targeted
recheck on the canonical learning route.

## Deterministic sources found, and why they do not reach this route

The product **does** own a canonical repair/recheck identity. Two fields already
exist on `Act0LessonRunnerShellV1` and are already consumed by this branch:

- `isSourceRecheckAttempt` — driven by
  `_activeSameSignalRecheckTaskId == playSelectedTask?.taskId`
- `repairContinuesToSourceRecheck` — driven by
  `_activeRepairTaskId == playSelectedTask?.taskId && (...)`

Both are assigned only from Play-tab flows:
`_startSameSignalRecheckV1` (`act0_shell_preview_screen_v1.dart:8927`, called at
`:6178`) and `_startSameSignalRepairFromFeedbackV1` (`:8844`, called at `:6313`).
Both compare against `playSelectedTask`, which is `null` unless
`_tab == Act0ShellTabV1.play`.

The canonical Wave A learning-scene sequence used by the evidence harness —
`runnerFirstWrongFeedback` -> continue -> drill -> answer -> continue -> drill —
never enters those flows, so `_activeRepairTaskId` and
`_activeSameSignalRecheckTaskId` are never set on it.

## Measured evidence

A widget test walking that exact canonical sequence, reading the scene's
published attention-phase marker:

| Step | Resolved phase |
| --- | --- |
| wrong feedback surface | `wrongFeedback` (correct) |
| after continue — targeted repair | **`decision`** |
| after answer + continue — targeted recheck | **`decision`** |

Independently, gold-pixel counts in the clue band of the rendered captures:
`decision 169`, `targeted_repair 169`, `targeted_recheck 186`,
`wrong_feedback 297`, `repair_success 447`. Repair is pixel-identical to a
normal decision.

## Why the previous heuristic was insufficient

`repairResultReceiptLine` is bound to a *task*, not to a *stage*
(`_activeRepairTaskId == playSelectedTask?.taskId ? ... : null`). On the learning
route it is null in both steps, so it cannot separate them; and where it is
non-null it stays set across subsequent steps of the same task.

## What was NOT done, deliberately

- No new learning state invented to satisfy rendering.
- No inference of phase from header copy, receipt strings or beat index.
- No degrading of the visual contract to make repair and recheck agree.

## What is in place and ready

The renderer now consumes the canonical fields directly, and the scene publishes
its resolved phase as `act0_scene_attention_phase_<name>` so separation is
provable the moment the signal reaches this route. The salience model's
repair-vs-recheck contract is locked by
`test/ui_v2/act0_scene_attention_phase_resolution_v1_test.dart`.

## Decision requested

Whether exposing the existing repair/recheck identity to the learning route —
rather than only the Play route — is admissible as view metadata.

`HUMAN_PROOF = FALSE`


---

# B5 PHASE RESOLUTION — RESOLVED

## The canonical owner

`Act0ActionSequenceStageV1` — an existing typed enum
(`theory / decision / repair / recheck / complete`) held in
`_activeActionSequenceStageV1` and transitioned by
`_advanceActionSequenceReviewV1`
(`act0_shell_preview_screen_v1.dart:12520`), which is the route seam that
actually performs wrong-feedback -> repair -> recheck on the Wave A action
learning sequence.

No parallel state machine was created. The enum already existed, already owned
the transition, and already emitted the repair/recheck telemetry.

## The exposure

One field, view-only:

```
learningLoopStage: _activeActionSequenceStageV1
```

passed to `Act0LessonRunnerShellV1` and read by the B5 resolver. It drives no
progression; progression stays owned by `_advanceActionSequenceReviewV1`.

The Play-only `isSourceRecheckAttempt` / `repairContinuesToSourceRecheck` flags
are retained as the fallback for their own path, exactly as the architecture
constraint required.

## Canonical acceptance test

`test/ui_v2/act0_scene_attention_phase_resolution_v1_test.dart` mounts
`Act0ShellPreviewScreenV1` and walks the real production sequence — wrong
feedback -> Continue -> targeted repair -> answer -> repair result -> Continue
-> targeted recheck — asserting the scene-published phase at each step:

| Step | Resolved phase |
| --- | --- |
| wrong feedback | `wrongFeedback` |
| targeted repair | `repair` |
| targeted recheck | `recheck` |

Orchestration -> runner -> renderer, passing. The model-level guards are
retained alongside it.

## Rendered proof

Gold pixels in the clue band, measured from the actual captures:

| State | Clue gold px |
| --- | --- |
| decision | 169 (floor — no bracket) |
| wrong feedback | 297 |
| **targeted repair** | **422** — asserted for reacquisition |
| **targeted recheck** | **186** — back to floor, no standing pointer |

One adjustment the renders proved necessary: repair's clue emphasis was held at
a decision-level `0.34` only while repair and recheck could not be told apart.
With the stage resolving, the intended `0.85` was restored. The accepted global
salience model was otherwise not retuned.

## Answer-leak audit

Recheck clue emphasis is `0.0`; room and player recession return to `0.12` /
`0.10`, at or below normal-decision levels, so the learner re-recognises the
full situation. Recession stays per-plane, so no seat is singled out. Cards,
board, pot, bets, actions and copy are never attenuated.

`HUMAN_PROOF = FALSE`
