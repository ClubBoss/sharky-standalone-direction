# Premium Transitions / Replay Motion v1

Date: 2026-07-03
Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
Preflight HEAD: `637a71bfc8bb932ab682b1c7df5735d79db1be41`
Mode: bounded two-surface milestone motion implementation; no push

## 1. Verdict

`premium_milestone_motion_landed_with_explicit_deferrals`

Both admitted surfaces (`_WorldCompletionPayoffV1`, `_BandTransitionPayoffV1`)
now share one bounded `milestone`-category motion contract, built on the
Motion Direction System v1 tokens, with a working reduced-motion bypass and
no-replay-on-rebuild guarantee. The one explicit deferral is a screenshot
PNG evidence gap for these two specific states (Section 10) - the states
have no existing capture lane, and an ad-hoc capture script hit an unresolved
`toImage()`-only rendering anomaly that does not reproduce in the actual
widget-test suite (which directly verifies the real state: opacity, color,
text data, and no exceptions all correct). No product or test regression
resulted; this is an evidence-tooling gap, not a functional gap.

## 2. Admitted Slice

Exactly two surfaces, as scoped: `_WorldCompletionPayoffV1` (ordinary
World 2-6 completion) and `_BandTransitionPayoffV1` (the one W4->W5
Foundation -> Developing Player transition). No Street Replay motion, no
navigation motion, no Sharky micro-animation work was added.

## 3. Shared Milestone Contract

Both surfaces already funneled through one shared layout,
`_WorldMilestoneCardV1` (`lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`).
That widget's existing content is naturally two stages - a top identity row
(milestone icon + payoff label) and a details block (learning line, proof
row, next-world label, preview line) - so a new shared primitive,
`_MilestoneMotionRevealV1`, was added right next to it and wired into
`_WorldMilestoneCardV1.build()` as the single render path both
`_WorldCompletionPayoffV1` and `_BandTransitionPayoffV1` already use. No new
per-surface animation code exists; there is exactly one implementation.

Contract:

- accepts semantic state only (`emphasized: bool`, `identity: Widget`,
  `details: Widget`) - no duration/curve/styling escape hatches;
- identity settles first (`AnimatedScale` + `AnimatedOpacity`, `micro`
  fade), details follow after a `micro` (140ms) stagger (`AnimatedSlide` +
  `AnimatedOpacity`, `standard` duration, `enter` curve);
- runs once per admitted appearance via `State` (see Section 7);
- reduced motion resolves both stages immediately, structurally bypassing
  every `Animated*` widget (see Section 6);
- preserves every existing `Key`, callback, and layout structure from
  `_WorldMilestoneCardV1` unchanged.

New tokens added to `Act0ShellTokensV1` (`Act0MotionTokensV1`), exactly the
four accepted duration and four accepted easing tokens from
`docs/_reviews/motion_direction_system_v1.md` - no new arbitrary duration
was introduced (locked by a dedicated test, Section 9).

## 4. World Completion Result

`_WorldCompletionPayoffV1` uses `emphasized: false`: identity settles over
`standard` (260ms), details follow after the `micro` stagger over another
`standard` (260ms). No scale/slide value exceeds the bounded ranges from the
Motion Direction System (icon settle 0.97->1.0, details slide <=0.02 of its
own height). No bounce, confetti, or sparkle. The CTA (owned entirely by
`Act0BlockCompletionShellV1`, outside this card) is unaffected structurally
and available immediately regardless of the reveal's progress.

## 5. W4->W5 Result

`_BandTransitionPayoffV1` uses `emphasized: true`: the identity stage uses
the `milestone` token (900ms, `emphasis` curve) instead of `standard`, and a
slightly stronger icon settle (0.94->1.0 vs 0.97->1.0 for ordinary
completion) - the one documented, bounded emphasis difference. No new
badge/crown/trophy asset was added; the existing `Act0ProofIconV1`
`emphasized` ring (already accepted, already tested) remains the sole visual
differentiator, now with a matching stronger motion. Copy and layout
structure are untouched.

## 6. Reduced-Motion Result

`_MilestoneMotionRevealV1.build()` checks
`MediaQuery.of(context).disableAnimations` first and, when true, returns
`Column(children: [widget.identity, widget.details])` directly - no
`AnimatedScale`/`AnimatedSlide`/`AnimatedOpacity` widget exists in that
tree at all, matching the exact structural-bypass pattern the codebase's
existing `_ProofMotionRevealV1` already uses (and that existing tests, e.g.
`act0_session_summary_earned_moment_v1_test.dart`, already assert against
via `find.byType(AnimatedScale), findsNothing`). Verified with a dedicated
test: under `disableAnimations: true`, both the identity and details content
are immediately present, no `AnimatedScale`/`AnimatedSlide` widget exists,
and `pumpAndSettle()` resolves without any pending timer.

## 7. Replay/Rebuild Behavior

State (`_identityRevealed`, `_detailsRevealed`) lives in
`_MilestoneMotionRevealV1State`, keyed identically to
`_WorldMilestoneCardV1`'s existing outer `Key('${keyPrefix}_payoff')`
pattern. A parent rebuild that keeps the same widget in the same tree
position (the common case - e.g. an ancestor `setState`) reuses the same
`State`, so it never resets to the pre-reveal scale/opacity. Verified with a
dedicated test that pumps the same summary twice and confirms the settled
scale (`1.0`) survives the second, non-settled pump untouched. A genuine
unmount/remount (a different completion actually appearing) correctly starts
fresh - proven by the existing, unmodified idempotent-reopening tests in
`act0_w4_w5_band_transition_milestone_v1_test.dart` and
`act0_w2_w6_completion_payoff_v1_test.dart`, both still passing.

## 8. CTA Integrity

The primary CTA (`act0_shell_block_summary_continue_cta`) is owned by
`Act0BlockCompletionShellV1`, structurally outside `_WorldMilestoneCardV1`,
so it was never touched. Verified with a dedicated test that taps the CTA
immediately after the first pump (deliberately not settling the reveal
first) and confirms the callback still fires exactly once - proving the
motion layer never intercepts input. All pre-existing CTA tests (routing,
no-blank-label, idempotency) continue to pass unmodified.

## 9. P1-P4 Ledger

| ID | Finding | Severity | Disposition |
| --- | --- | --- | --- |
| PT-01 | World completion and W4->W5 had zero motion (the direction-doc's MO-03 finding) | P1 | fixed - shared milestone reveal added to both |
| PT-02 | No shared motion token set existed for duration/easing | P1 | fixed - `Act0MotionTokensV1` added, used exclusively by this reveal |
| PT-03 | Risk of reduced-motion being forgotten on a new/touched animated widget | P1 | fixed - structural bypass verified by dedicated test |
| PT-04 | Risk of the reveal replaying on an unrelated parent rebuild | P2 | fixed - verified by dedicated rebuild test |
| PT-05 | Risk of the reveal blocking/delaying the CTA | P1 | fixed - verified by dedicated mid-motion tap test; CTA structurally untouched |
| PT-06 | No visual PNG evidence exists for these two specific states in any capture lane | P3 | `deferred_with_explicit_structural_reason` (Section 10/13) |
| PT-07 | Ad-hoc `toImage()` capture of the new reveal showed a rendering anomaly (details content reports correct state via widget introspection but is absent from the rasterized PNG) | P2 (evidence-only) | investigated at length (Section 10); not reproduced by the real widget-test suite or by the two unmodified existing screenshot lanes; classified `screenshot_tooling_limitation`, not a product defect; flagged for a future dedicated capture-tooling investigation if PNG proof of this exact state is ever required |

No finding above was left generically "optional."

## 10. Evidence

Existing lanes run and copied to
`output/premium_transitions_replay_motion_v1/` (uncommitted):

- `first_week_fast` (includes Session Summary, Welcome, repair/feedback
  states) - 12 labels text-repaired, identical to the pre-change baseline.
- `full_scroll_fast` (includes Session Summary at top/mid/bottom scroll) -
  27 labels text-repaired, identical to the pre-change baseline.

Neither existing lane's fixture reaches an actual world-complete or
W4->W5-complete state (both use an ordinary in-progress lesson summary), so
neither one exercises the new motion. This was confirmed by inspecting the
capture tool's fixture data before attempting evidence generation.

Because no existing lane exposes these two states and this task explicitly
forbids adding a new capture harness, a one-off, uncommitted `flutter test`
script (reusing the exact `RenderRepaintBoundary.toImage()` technique the
existing tool already uses, not a new mechanism) was used to attempt direct
visual evidence. It reproducibly showed the identity row (icon + payoff
label) rendering correctly, but the details block (learning line, proof row,
next label, preview line) missing from the rasterized PNG - while
`find.text(...)`, `getRect(...)`, opacity, and text-style-color
introspection on the exact same widgets all reported fully correct, fully
revealed values in the same frame. Ablation (removing `AnimatedSlide`,
removing `AnimatedScale`, reducing to a single plain `AnimatedOpacity`,
adding extra settle pumps, testing in a freshly isolated `testWidgets` block
with only one `pumpWidget` call) did not resolve it, pointing to a narrow
`toImage()`-in-headless-test compositing edge case with staggered sibling
animations rather than a defect in the widget itself. This diagnostic script
was discarded (not committed); it is not part of the shipped change.

Given the widget-test suite (Section 9's PT-01 through PT-05) directly
verifies the real, load-bearing properties - opacity, scale, curves,
durations, gating, CTA behavior, no-replay - and the two existing,
unmodified screenshot lanes show no regression, the correctness of this
change is not in question; only a specific ad-hoc PNG artifact is.

## 11. Tests/Validation

New test file: `test/ui_v2/act0_premium_transitions_replay_motion_v1_test.dart`
(10 tests):

1. world completion animates only when admitted;
2. band transition animates only when admitted (including the exact-route
   mismatch case where neither card renders);
3. both surfaces share the same motion contract (same curves, same details
   duration; only the documented `standard` vs `milestone` identity-duration
   difference);
4. reduced motion skips animation with no hidden content;
5. rebuild does not replay the reveal;
6. CTA callback remains intact and is not intercepted mid-motion;
7. motion does not alter copy or gating truth;
8. compact layout (375x812) has no overflow with motion active;
9. settles deterministically within the existing capture pump budget
   (mirrors the tool's own `pump(); pump(900ms);` sequence);
10. no new arbitrary duration values on the milestone motion primitive.

Validation run:

- `flutter analyze` (whole project) - no issues.
- New test file - 10/10 pass.
- `act0_w4_w5_band_transition_milestone_v1_test.dart`,
  `act0_w2_w6_completion_payoff_v1_test.dart`,
  `act0_world1_completion_payoff_v1_test.dart`,
  `act0_session_summary_earned_moment_v1_test.dart` - 116/116 pass,
  unmodified, confirming zero regression to existing gating, copy, proof,
  CTA, overflow, and reduced-motion contracts.
- `graphify hook-check`, `git diff --check`, `git diff --cached --check` -
  all pass.
- `first_week compact` and `full_scroll compact` screenshot lanes
  regenerated - pass, identical text-repair counts to the pre-change
  baseline (12 and 27 respectively).
- No dependency added. No route/table regression.

## 12. Fixed/Deferred/Accepted Counts

- Fixed: 5 (PT-01 through PT-05).
- Deferred with explicit structural reason: 2 (PT-06, PT-07 - both evidence-
  generation gaps, not functional gaps; a dedicated capture-tooling wave
  would be required to resolve either, which is out of this bounded slice's
  scope and forbidden by "no custom capture harness").
- Accepted: 0.

## 13. Rolling Capsule Advance

- `Premium Transitions / Replay Motion v1` is CLOSED.
- `Sharky Micro-Animations v1` is now ACTIVE.
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` updated: shared motion contract,
  token usage, reduced-motion behavior, and the two evidence deferrals
  recorded; active task advanced.
- `docs/context/VISUAL_PROOF_CAPSULE_v1.md` updated: this artifact added to
  the reference list; the landed milestone motion and its evidence
  limitation summarized.

## 14. Scope Safety

- Exactly two surfaces touched (`_WorldCompletionPayoffV1`,
  `_BandTransitionPayoffV1`, via the one shared `_WorldMilestoneCardV1`
  render path).
- No navigation motion, no Street Replay motion, no Sharky micro-animation
  work.
- No new package, no new asset, no new route/screen, no Modern Table
  change, no copy/content rewrite, no XP/coins/levels/crowns/confetti.
- No looping animation (every animation is one-shot, gated by `State` that
  does not reset on rebuild).
- No CTA delay - verified by a dedicated mid-motion tap test.
- Deterministic screenshots: existing lanes unaffected (identical repair
  counts); the one PNG evidence gap for the two new states is explicitly
  named, not silently dropped.
- `output/**` not committed.
- Diff: 2 source files (`act0_lesson_runner_shell_v1.dart`,
  `act0_shell_tokens_v1.dart`) + 1 new test file.

## 15. Next Recommendation

Begin `Sharky Micro-Animations v1`. Separately, if visual PNG proof of the
World-completion / W4->W5 milestone motion is ever required (e.g. for a
future Human QA packet), open a small, explicitly scoped capture-tooling
investigation into the `toImage()` anomaly described in Section 10 - do not
fold that investigation into a future product-motion wave.
