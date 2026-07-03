# Motion Direction System v1

Date: 2026-07-03
Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
Preflight HEAD: `8bd8f91037640a457ea461d590b1da4a5c181067`
Mode: direction-definition only; no motion-phase implementation; no push

## 1. Verdict

`motion_direction_system_defined_with_explicit_deferrals`

The active W1-W12 product already has a real but scattered motion vocabulary
(one shared reveal primitive, several one-off `TweenAnimationBuilder` moments,
one Sharky micro-response, chip-motion during Street Replay playback, zero
navigation motion, zero milestone motion, and one accessibility seam used in
only one place). This wave inventories all of it against exact source,
defines one bounded semantic system (principles, categories, duration/easing
tokens, composition/priority rules, reduced-motion contract), classifies
every candidate surface, and selects the first implementation slice. No
motion-phase implementation was done; the two structural deferrals are named
explicitly.

## 2. Current Motion Inventory

Read directly from source (no broad scan - `rg` located every motion
primitive inside the active `lib/ui_v2/act0_shell/*.dart` owner set only).

| Surface | Owner | Current behavior | Product purpose |
| --- | --- | --- | --- |
| Navigation (tab switch) | `act0_shell_preview_screen_v1.dart` (`_tab` switch expression, `_BottomNavV1`) | Instant hard-cut rebuild; no `AnimatedSwitcher`/cross-fade | none currently |
| Panel/card reveal (general) | `act0_lesson_runner_shell_v1.dart`, `_ProofMotionRevealV1` (6 call sites) | `AnimatedScale` (0.992->1, 160ms) + `AnimatedSlide` (0.035 offset->0, 160ms) + `AnimatedOpacity` (0.92->1, 140ms), one-shot on first frame; **already checks `MediaQuery.disableAnimations` and returns `child` immediately if true** | settle-in for feedback/repair/session-summary blocks |
| Decision -> feedback | Same `_ProofMotionRevealV1`, key `act0_shell_feedback_card_motion_reveal` | as above | signal the verdict card has arrived |
| Wrong -> repair | Same `_ProofMotionRevealV1`, keys `act0_shell_repair_outcome_motion_reveal` / `act0_shell_feedback_proof_motion_reveal` | as above | signal repair evidence has arrived |
| Repair -> success | No dedicated motion; relies on the same reveal wrapper when the next feedback card renders | as above | none dedicated |
| Street Replay reveal (card) | `act0_lesson_runner_shell_v1.dart`, `_StreetReplayInlineV1` | Plain `StatelessWidget`; appears instantly with no entrance motion | none currently |
| Street Replay reveal (chip motion) | `act0_lesson_runner_shell_v1.dart`, `_BetChipPlacementV1` | `TweenAnimationBuilder`, 360/380/440ms by bet kind, only when `animateBetMotion` (i.e. `trailPlaybackEnabled`) is true | shows the historical bet actually moving during playback |
| Session Summary entry (proof hero/next-action/evidence lines) | `_ProofMotionRevealV1` (4 of its 6 call sites) | as above | settle-in for Session Summary sub-blocks |
| Session Summary progress fill | `_BlockXpProgressCardV1` | `TweenAnimationBuilder`, 1800ms, `easeOutCubic`, one-shot | fills the proof/skill progress bar |
| Proof banking (toast) | `_CompletionToastV1` | `TweenAnimationBuilder`, 1800ms, custom appear(0-18%)/hold/disappear(72-100%) math, one-shot | "Proof banked" / "Table read improved" overlay |
| Pot sweep (table, adjacent) | `_PotSweepMomentV1` | `TweenAnimationBuilder`, 1180ms, custom appear/settle/fade math | cosmetic pot-to-winner sweep on the table |
| World completion | `_WorldMilestoneCardV1` / `_WorldCompletionPayoffV1` | Plain `StatelessWidget`; appears instantly with the rest of Session Summary, no motion | none currently |
| W4->W5 band-transition milestone | `_BandTransitionPayoffV1` (wraps `_WorldMilestoneCardV1`) | Same as above - no motion despite being the single highest-emphasis payoff moment in the product | none currently |
| Sharky micro-response | `act0_sharky_presence_v1.dart`, `Act0SharkyPresenceMascotV1` | `AnimationController` (2400ms) `.forward()` only (no `.repeat()` - confirmed one-shot, not looping); mood-driven translate/rotate/scale curve | entrance "breathe" tied to mood |
| CTA press/state response | `Act0ShellTokensV1.primaryButtonStyle` (used everywhere) | Plain `ButtonStyle` (color/shape/text only); relies entirely on Flutter's built-in `FilledButton` ripple/highlight | none custom |
| Placement/Welcome question transition | `act0_placement_shell_v1.dart` (3 `AnimatedSwitcher`s) | 320/360/420ms, `easeOutCubic`/`easeInOutCubic` | cross-fade between placement questions |
| Learn path card expand/collapse | `act0_learn_path_shell_v1.dart` (`AnimatedSize`, `AnimatedContainer`) | 110-250ms, mostly `easeOutCubic`/`easeInOutCubic` | lesson-row expand/collapse |
| Reduced-motion contract | `_ProofMotionRevealV1` only | `MediaQuery.of(context).disableAnimations` checked and honored | the only place this is checked today |

Duration values actually in use across the active surface today (from
source, deduplicated): 90, 110, 120, 130, 140, 150, 160, 180, 220, 240, 250,
260, 320, 360, 380, 420, 440, 650, 760, 900, 1180, 1800, 2400ms - 23 distinct
ad hoc values, zero shared tokens (`act0_shell_tokens_v1.dart` defines no
`Duration` or `Curve` constant today, confirmed by direct grep).

## 3. P1-P4 Ledger

| ID | Gap | Severity | Classification | Disposition |
| --- | --- | --- | --- | --- |
| MO-01 | No shared duration/easing tokens; 23 ad hoc millisecond values scattered across 6 files | P1 | contract gap | resolved by this system (Section 6) |
| MO-02 | Reduced-motion (`disableAnimations`) is honored in exactly one widget (`_ProofMotionRevealV1`) and nowhere else (chip motion, completion toast, pot sweep, XP-style progress fill, Sharky breathe, placement `AnimatedSwitcher`s) | P1 | accessibility gap | resolved by this system - reduced-motion contract mandated app-wide (Section 8); real implementation is part of the Motion phase, not this direction doc |
| MO-03 | World completion and the W4->W5 band-transition milestone - the highest-emphasis payoff moments in the product - have zero motion, while lower-stakes moments (pot sweep, chip motion) already have custom animation | P1 | hierarchy gap | `implement_next` (Section 9/10) |
| MO-04 | Navigation between tabs is an instant hard-cut with no transition at all | P2 | consistency gap | `later_in_phase_8` (Section 9) |
| MO-05 | Three different one-off `TweenAnimationBuilder`s (`_BlockXpProgressCardV1`, `_CompletionToastV1`, `_PotSweepMomentV1`) each hand-roll their own appear/settle/fade curve math instead of sharing one utility | P2 | composition-rule gap | resolved by this system (Section 7 composition rules); consolidation itself is `later_in_phase_8` |
| MO-06 | CTA press/state response relies entirely on Flutter Material defaults; no semantic "confirm" micro-response distinct from generic ripple | P3 | polish gap | `later_in_phase_8` |
| MO-07 | `_ProofMotionRevealV1` is a private, per-file class (not a shared token/component), so its settle values (160/140ms) are copy-pasted logic rather than a reusable contract | P2 | architecture gap | resolved by naming it the canonical `reveal` category primitive in this system; promoting it to a shared file is `later_in_phase_8` |
| MO-08 | Street Replay's own inline card has no entrance motion (only the chip motion inside it animates, and only during playback) | P3 | consistency gap | `later_in_phase_8` (bounded, low product EV given Street Replay is already hidden for W7-W12 and is a secondary, not primary, payoff) |

No finding above is left generic-optional: each has a named disposition and,
where deferred, an explicit reason (Section 11).

## 4. Principles

1. **Semantic** - motion communicates a specific state change (arrived,
   corrected, banked, unlocked); it never runs "because a widget mounted"
   with no state meaning.
2. **Brief** - the learning loop repeats dozens of times per session; motion
   must never feel like a tax on repetition. Bias down, not up.
3. **State-driven** - motion parameters (which category, whether it plays at
   all) come from the same structured state the copy/companion/proof
   contracts already gate on (`Act0FeedbackQualityV1`, completion summary
   flags, growth stage) - never from a widget's own guessed context.
4. **Interruptible** - a new state change always wins immediately; motion
   never blocks or queues behind an in-flight animation from a stale state.
5. **Deterministic** - identical input state always produces the identical
   motion, every time, with no random jitter or seed-dependent variation.
6. **Hierarchy-preserving** - a payoff moment gets more emphasis than a
   routine one; a routine reveal never out-animates a milestone, and a
   milestone never animates so hard it hides the CTA beneath it.
7. **Accessible** - every animated surface must have a defined reduced-motion
   fallback (Section 8); "we forgot to check `disableAnimations`" is not an
   acceptable state for a new surface.
8. **Never delays the next decision materially** - no entrance motion may
   gate `onPressed`/tap targets behind its own duration; the CTA must be
   interaction-ready the instant it is visible, matching MO-06's constraint
   that motion competes with nothing the learner needs next.

## 5. Motion Categories

| Category | Meaning | Existing example |
| --- | --- | --- |
| `navigation` | moving between tabs/screens | none today (MO-04) |
| `reveal` | a card/panel/line entering after a state change | `_ProofMotionRevealV1` |
| `state_transition` | one state visually becoming another (decision -> feedback, question -> question) | Placement `AnimatedSwitcher` |
| `repair_correction` | acknowledging a miss and showing the fix | `_ProofMotionRevealV1` (repair keys) |
| `confirmation_proof` | a small proof/receipt landing (banked, saved) | `_CompletionToastV1` |
| `milestone` | a world/band-level payoff, rarer and higher-stakes than `confirmation_proof` | none today (MO-03) |
| `sharky_micro_response` | the companion's own reaction to a moment | `Act0SharkyPresenceMascotV1` |

Every animated widget must declare which one category it belongs to. A
widget that seems to need two categories at once is a sign the moment should
be split or re-prioritized (Section 7 priority rules), not a reason to invent
a ninth category.

## 6. Duration and Easing Tokens

Bounded set, replacing the 23 ad hoc values in Section 2. Chosen from the
values already in production use (median of the existing cluster at each
tier), so migrating existing widgets is a value swap, not a redesign:

| Duration token | Value | Replaces (examples from Section 2) | Used by categories |
| --- | --- | --- | --- |
| `micro` | 140ms | 130, 140, 150, 160ms (`_ProofMotionRevealV1`, seat/scale micro-motions) | `reveal`, `state_transition` (small), `sharky_micro_response` |
| `standard` | 260ms | 220, 240, 250, 260, 320ms (card reveals, placement transitions) | `navigation`, `state_transition`, `repair_correction` |
| `emphasis` | 420ms | 360, 380, 420, 440ms (chip motion, larger reveals) | `confirmation_proof`, chip/table-adjacent motion |
| `milestone` | 900ms | midpoint of the existing 760-1180ms proof/toast cluster, deliberately short of the existing 1800ms outliers | `milestone` only |

`1800ms` (currently used by `_BlockXpProgressCardV1` and `_CompletionToastV1`)
and `2400ms` (Sharky breathe) are intentionally **not** promoted to tokens:
both exceed the "brief" principle for a moment that repeats every session and
are flagged for shortening toward `milestone` (900ms) when those two widgets
are next touched, not retrofitted here without visual re-verification.

| Easing token | Curve | Semantic use |
| --- | --- | --- |
| `enter` | `Curves.easeOutCubic` | anything appearing (matches the dominant existing curve - already used in ~90% of Section 2's inventory) |
| `exit` | `Curves.easeIn` | anything leaving/fading out |
| `settle` | `Curves.easeInOutCubic` | a value/position resolving to its final state (progress fills, slides) |
| `emphasis` | `Curves.easeOut` | the accented portion of a milestone/confirmation composite (e.g. the "pop" beat) |

No widget may declare a bespoke `Duration(milliseconds: <n>)` or raw `Curves.*`
outside these four-plus-four tokens once the Motion phase implements them.

## 7. Composition Rules

- **Fade** for anything changing meaning in place (verdict text, proof
  lines) - never slide text that's simply updating its own content.
- **Slide** only paired with fade (never alone) for cards that are newly
  arriving into a fixed slot (`reveal`, `state_transition`) - offset must
  stay small (<=0.05 of the card's own height, matching the existing
  `_ProofMotionRevealV1` values) so it reads as a settle, not a slam.
- **Scale** reserved for `milestone` and `confirmation_proof` only, and
  always subtle (<=6% of natural size, matching the existing pot-pulse and
  reveal-scale values) - scale is the strongest hierarchy signal available
  and must stay scarce to keep meaning it.
- **Crossfade** (`AnimatedSwitcher`) for `navigation` and any
  question-to-question `state_transition` where both the old and new content
  occupy the same slot.
- **Remain static** for: dense list rows, repeated small chips/badges,
  anything already inside a scrolling list (motion inside a scroll gesture
  reads as jank, not polish), and any surface explicitly marked
  `static_by_design` in Section 9.

## 8. Priority Rules

Motion must never:

- obscure a card or an actionable CTA at any point during its own playback;
- animate more than one `milestone`/`confirmation_proof` moment at the same
  time (if two would coincide - e.g. a world completion and a banked-proof
  toast - the `milestone` plays and the lesser moment is suppressed or
  deferred to right after, never layered);
- replay on rebuild (`didUpdateWidget` must gate on a real state-identity
  change, the same discipline the phrase/companion/growth resolvers already
  use - never on `setState`/parent rebuild alone);
- imply proof that was not actually earned (a `milestone` or
  `confirmation_proof` animation may only run when its gating boolean from
  the structured proof/completion state is true - the same "proof before
  points" rule already governing copy applies to motion);
- compete with feedback (a `repair_correction` or verdict reveal must finish
  its meaningful portion before a `sharky_micro_response` for the same event
  starts, so the two never visually argue for attention at once);
- block CTA readiness (Principle 8 - restated here as a hard rule, not just
  a principle, because it is the one most likely to be silently violated by
  a future "just wrap it in a delay" patch).

## 9. Reduced-Motion Contract

- Deterministic fallback: **immediate transition, zero animated frames** for
  every category except `reveal`, which may use the existing minimal-fade
  pattern already proven in `_ProofMotionRevealV1` (jump straight to the
  settled state, no scale/slide at all, matching what that widget already
  does when `disableAnimations` is true).
- No information is ever conveyed only by motion - every reveal/milestone/
  proof moment's meaning must already be present in the static end-state
  (copy, icon, color), so skipping the animation loses zero information.
  This is already true of every inventoried widget in Section 2.
- No new architecture: the existing seam is
  `MediaQuery.of(context).disableAnimations`, already correctly used in
  `_ProofMotionRevealV1`. The contract for the Motion phase is to require
  this same check on every new/touched animated widget - not to invent a
  second mechanism (a custom settings flag, a new provider, etc.).

## 10. Surface Priority Matrix

| Candidate | Classification | Reason |
| --- | --- | --- |
| Decision -> feedback | `later_in_phase_8` | Already has working motion (`_ProofMotionRevealV1`); needs token migration, not new direction work |
| Wrong -> repair | `later_in_phase_8` | Same as above |
| Repair -> success | `static_by_design` | No dedicated moment exists separate from the next feedback card's own reveal; inventing one would add a category collision (Priority Rule: never compete with feedback) for negligible EV |
| Street Replay reveal | `defer_with_reason` | Secondary/optional surface, already hidden for W7-W12; bounded EV vs. the milestone gap (Section 11) |
| Session Summary entry | `later_in_phase_8` | Partially covered by `_ProofMotionRevealV1`; remaining pieces (`_BlockXpProgressCardV1`, `_CompletionToastV1`) need duration retuning, not new direction |
| Proof banking | `later_in_phase_8` | Working today (`_CompletionToastV1`); needs duration retuning toward the `milestone` token |
| World completion | `implement_next` | MO-03: zero motion today on the product's core payoff moment |
| W4->W5 milestone | `implement_next` | MO-03: same gap, at the single highest-emphasis moment in the whole app |
| Sharky state response | `later_in_phase_8` | Already working, one-shot, mood-driven; only needs duration-token alignment |
| Navigation consistency | `later_in_phase_8` | Real gap (MO-04) but lower learning-EV than the milestone gap; a plain `navigation`/`standard` crossfade is enough and does not require new direction work beyond what Section 6/7 already specify |

## 11. First Implementation Slice

**`Premium Transitions / Replay Motion v1`** is scoped to exactly the two
highest-EV, closely-related `implement_next` surfaces:

1. **World completion** (`_WorldCompletionPayoffV1` / `_WorldMilestoneCardV1`)
2. **W4->W5 band-transition milestone** (`_BandTransitionPayoffV1`)

Both share one component (`_WorldMilestoneCardV1`) and one motion contract:
a single `milestone`-category reveal (900ms, `enter`/`emphasis` composite,
scale <=6%, fade+slight settle - reusing the exact shape already proven by
`_ProofMotionRevealV1` and `_PotSweepMomentV1`, just retuned to the
`milestone` token), gated on the same `hasWorldCompletionPayoff` /
`hasBandTransitionPayoff` booleans that already gate the copy, so it can
never play without real completion proof (Priority Rules). This is exactly
one shared motion contract applied to two already-structurally-related
wrappers - not scattered per-widget patches.

Explicitly out of the first slice: navigation, Sharky, Street Replay, CTA
press - all `later_in_phase_8` or `defer_with_reason` per Section 10.

## 12. Explicit Deferrals

- **Street Replay reveal (`defer_with_reason`)** - Street Replay is an
  intentionally hidden, secondary, learning-purpose-prose surface for
  W7-W12 (per `docs/context/VISUAL_PROOF_CAPSULE_v1.md`), not a primary
  payoff. Giving its inline card its own entrance motion is real but low-EV
  next to the milestone gap, and doing it now would mean touching a third
  unrelated surface in the first slice, violating the "maximum 2 closely
  related surfaces" constraint. Owner: a later Phase 8 wave, once the
  milestone slice's shared contract exists to reuse.
- **Navigation crossfade (`defer_with_reason`, folded into
  `later_in_phase_8`)** - real (MO-04), but implementing it now would add an
  unrelated third surface to the first slice for lower learning/product EV
  than the milestone gap. The direction is fully specified (Section 7:
  crossfade via `AnimatedSwitcher`, `standard` duration, `enter`/`exit`
  tokens) so no further direction-defining work is needed before a future
  wave implements it.

Neither deferral is a static-layout defect being pushed off - the previous
wave (`docs/_reviews/product_surface_visual_evidence_repair_v1.md`) already
closed all actionable static-layout gaps in this surface set.

## 13. Deterministic-Test Impact

No test or golden-screenshot behavior changes in this wave (docs-only). For
the future implementation wave: the reduced-motion contract (Section 8) means
every deterministic screenshot lane can continue running with
`disableAnimations` effectively true (as `flutter test` widget tests already
default to, absent an explicit animation pump), so the existing four
screenshot lanes and their guard tests remain valid without modification once
motion is implemented - this was a design goal of Section 9, not an
afterthought.

## 14. Rolling Capsule Advance

- This checkpoint (`Motion Direction System v1`) is CLOSED.
- Active task advances to `Premium Transitions / Replay Motion v1` (first
  implementation slice, Section 11) - not the full Motion phase.
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` updated: current active task set
  to `Premium Transitions / Replay Motion v1`; this artifact recorded as the
  verified active route artifact.
- `docs/context/VISUAL_PROOF_CAPSULE_v1.md` updated: this artifact added to
  the reference list; motion categories/tokens/contract summarized as the
  now-accepted direction.

## 15. Scope Safety

- No source code changed in this wave - direction/documentation only.
- No dependency added.
- No new route/screen.
- No looping ambient animation proposed (Sharky's existing motion is
  confirmed one-shot; the system explicitly keeps it that way).
- No XP/coins/levels/economy language introduced (duration-token naming
  deliberately avoided "XP" despite the existing `_BlockXpProgressCardV1`
  class name, which is legacy naming for an already-accepted proof-progress
  bar, not a new claim).
- No Modern Table redesign - `_PotSweepMomentV1`/`_BetChipPlacementV1` are
  inventoried as existing table-adjacent motion, not touched or redesigned.
- No static-layout fix reopened (all closed by the prior wave).
- No screenshot-tooling change.
- `output/**` remains untracked; nothing was generated for this docs-only
  wave.

## 16. Next Recommendation

Begin `Premium Transitions / Replay Motion v1`: implement the single
`milestone`-category motion contract (Section 11) on
`_WorldCompletionPayoffV1` and `_BandTransitionPayoffV1` only, using the
`milestone` duration token (900ms) and `enter`/`emphasis` easing tokens
defined in Section 6, with the Section 9 reduced-motion fallback wired in
from the start.
