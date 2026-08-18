# VISUAL GAUNTLET B6 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B6_SEMANTIC_MOTION_V1`.
Starting live `origin/main`: `7c0e39813fd156822b07c5eced69f2a6ce5972a4`.
Primary viewport: `402x874`.
`HUMAN_PROOF = FALSE`.

Core rule: **SEMANTIC MOTION, NOT DECORATIVE MOTION.** Motion communicates an
existing state change. It never creates or owns truth.

## 0. What B5 left behind

B5 gave the scene a deterministic idea of *what the learner is doing*: one
attention model, recession by plane, a clue anchor that belongs to the phases
talking about it. It is a good model, and B6 reuses it unchanged.

What B5 did not give it is any sense of *change*. Every value the model
produces is applied by a `StatelessWidget` that reads the current phase, so the
entire learning loop is a sequence of hard cuts.

This is measured, not asserted. Driving the canonical route at `402x874`:

| Step | Resolved phase | Room plane opacity | Animated frames |
| --- | --- | --- | --- |
| decision, settled | `decision` | `0.876` | — |
| first frame after the option tap | `wrongFeedback` | `0.5412` | `0` |
| +16ms / +33ms / +100ms / +400ms | `wrongFeedback` | `0.5412` | `0` |

`settle_frames_after_decision_tap = 0`. The room drops a third of its presence
between one frame and the next, and nothing in the scene ever tells the learner
that a transition happened. **That single-frame cut is the B6 gap.**

## 1. Architecture measurement that constrains every option

Element identity was probed across the full canonical loop
(decision -> wrongFeedback -> repair -> correctFeedback -> recheck):

| Owner | Behaviour across every hop |
| --- | --- |
| `_Act0LessonRunnerShellV1State` | **persists** (same `State` instance throughout) |
| scene subtree (`act0_scene_environment_plane` element) | **replaced on every hop** |

Consequence, and it is the decisive one: **implicit animation placed inside the
table subtree cannot work.** An `AnimatedOpacity` or `TweenAnimationBuilder`
mounted down there gets a fresh `State` at every phase change, so it has no
"from" value and would either jump anyway or fade in from nothing.

Therefore the interpolation must be **owned by the runner `State`**, which
provably survives, and passed down as already-resolved values. This is also the
architecturally correct answer: it keeps exactly one salience model and adds no
second state system.

## 2. Gap map — required classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Decision selection commitment | `B6` | no commitment beat at all; the dock is replaced in the same frame as the tap |
| 2 | Decision -> feedback abruptness | `B6` | **largest gap.** Measured single-frame cut, `0` animated frames, room opacity `0.876 -> 0.5412` |
| 3 | Verdict arrival | `B6` | the verdict is simply present on the next frame; nothing marks it as newly current |
| 4 | Causal clue arrival | `B6` | B4 bracket alpha hard-cuts `0.30 -> 1.0`; it never *arrives* |
| 5 | B5 salience interpolation | `B6 — primary mechanism` | values are correct and already deterministic; only the transition between them is missing |
| 6 | Correct-feedback transition | `B6` | same hard cut, at a lower recession target |
| 7 | Wrong-feedback transition | `B6` | same hard cut, at the strongest recession target (`0.74` room) |
| 8 | Feedback -> repair handoff | `B6` | field re-quiets and the clue re-asserts, both instantly; no handoff is perceivable |
| 9 | Repair clue reacquisition | `B6` | clue jumps to `0.85`; a settle would say "use this again" without a new marker |
| 10 | Repair -> recheck release | `B6 — RISK` | clue goes `0.85 -> 0.0` in one frame. Interpolating the *release* would animate a clue into recheck, which the acceptance bar forbids |
| 11 | Recheck context restoration | `B6` | field restores `0.52 -> 0.12` instantly; this is the natural home of "the assistance is gone" |
| 12 | Answer-leak risk during transitions | `PROTECTED — B6 must manage` | no transition may preview correctness before evaluation, and no eligible target may move |
| 13 | CTA stability | `PROTECTED` | CTA must be interaction-ready the instant it is visible; no motion may gate `onPressed` |
| 14 | Input blocking risk | `PROTECTED` | no `IgnorePointer`/`AbsorbPointer` gating, no delay inserted before the next decision |
| 15 | Reduced-motion behavior | `B6` | contract already exists (`MediaQuery.disableAnimations`); B6 must honour it with **zero animated frames** |
| 16 | 1.4x interaction | `RISK — B6 must manage` | motion must not reflow or clip at large text |
| 17 | Responsive motion stability | `RISK — B6 must manage` | must hold at compact `375x812` and large `430x932` |
| 18 | Endpoint geometry | `PROTECTED` | every settled endpoint must remain pixel-compatible with accepted B1-B5 evidence |
| 19 | Performance / jank risk | `B6` | interpolation rides the existing `Opacity` + `ColorFilter` already in the tree; no new raster pass, no blur |
| 20 | Premium restraint | `B6` | one duration, one curve, one mechanism. Restraint is the deliverable |
| 21 | Decorative-motion temptation | `NON-GOAL` | ambient loops, idle acting, dealing/chip spectacle, confetti, camera moves are all forbidden and none are adopted |

### Explicitly NOT B6

| Gap | Class |
| --- | --- |
| Feedback attention flow, proximity docking, moving feedback, action-dock redesign | `DEFERRED_TO_B7` |
| Table oval identity refinement | `DEFERRED_TO_B7` |
| Character/environment polish, cohesion parity | `DEFERRED B7` |
| Sharky in the lesson scene, mascot motion | `NON-GOAL` |

## 3. Binding pre-existing authority

`docs/_reviews/motion_direction_system_v1.md` already governs motion in this
product, and it is **more restrictive** than the B6 packet's allowed list. B6
obeys the stricter document:

- durations come only from `Act0MotionTokensV1` (`micro` 140, `standard` 260,
  `emphasis` 420, `milestone` 900); no bespoke `Duration`;
- easings come only from `enter` / `exit` / `settle` / `emphasis`;
- **scale is reserved for `milestone` and `confirmation_proof` only.** The B6
  packet permits "restrained scale / settle"; the repo's own motion authority
  does not permit scale for a `state_transition`, so **B6 adopts no scale**;
- motion must not replay on a parent rebuild;
- reduced motion is an immediate transition with zero animated frames;
- motion must never block CTA readiness.

Category for every B6 transition: `state_transition`.

## 4. Largest class-level B6 gap

**The scene knows what state it is in, and never shows the learner that the
state changed.**

Four different meanings currently arrive as the same silent cut:

| Moment | What the learner should perceive |
| --- | --- |
| decision | `I committed a choice.` |
| feedback | `The state changed; here is why.` |
| repair | `Here is the same relevant context to use.` |
| recheck | `The assistance is gone; recognise it yourself.` |

## 5. Approach chosen

One mechanism, not four. The B5 attention values become interpolatable, and the
runner `State` — the one owner that survives every hop — drives a single
`standard`/`settle` interpolation between the outgoing and incoming values.

That single mechanism expresses all four meanings, because B5 already encoded
them as numbers:

- field quiets on feedback -> "the state changed";
- clue rises -> "here is why", and on repair "use this again";
- field restores on recheck -> "normal context is back".

Adopted asymmetry, deliberately: **the clue releases instantly when entering
`recheck`, and never interpolates on the way out.** Item 10 is a real conflict —
a fade-out is still a clue animating into a recognition attempt, and the
acceptance bar names that as insufficient. Answer fairness wins over transition
symmetry. The restoration of the field carries the "assistance withdrawn"
meaning instead, with zero leak risk.

## 6. Protected foundation

Unchanged by B6: spatial scene, table/environment materials, player embodiment,
object-attached HUD, the B5 salience values themselves, and
`Act0ActionSequenceStageV1` learning-loop phase ownership. No poker truth, no
evaluation, no learning state, no repair/recheck progression, no telemetry
semantics, no route change, no layout change.
