# Runner Action-Dock Allocation Audit / Spec v1

Terminal verdict: `runner_action_dock_allocation_audit_confirms_wrong_feedback_and_repair_focus_share_fixed_lower_slot_dead_space_while_session_summary_is_a_separate_scaffold_scroll_safe_area_wave`

## Audit boundary

- Branch / audit HEAD: `claude/hub-surface-coherence-audit-plan-v1` / `1bec2dff`.
- Fresh compact evidence used: C2's real-text `first_week_fast` captures for
  wrong feedback, repair focus, repair result, session repair, and session
  summary. No new capture was needed because source ownership resolves the
  ambiguity.
- Source inspected: `act0_lesson_runner_shell_v1.dart` (runner root, viewport
  envelope, stage, dock, feedback shell, completion shell) and its direct host
  `act0_shell_preview_screen_v1.dart` (Scaffold bottom navigation / completion
  insertion). C2 design spec and implementation gate were consulted.
- This is an audit/spec only. No source, test, route, telemetry, motion,
  tablet, asset, or output change is admitted.

## State ownership map

| State | Stage / allocation owner | Lower content owner | Meaningful distinction |
| --- | --- | --- | --- |
| Wrong feedback | `Act0LessonRunnerShellV1`; fixed envelope when compact pressure applies | `_RunnerActionDockV1` -> `Act0FeedbackShellV1` | Same feedback card as other review outcomes; runner alone applies table opacity `0.68` for non-rapid wrong feedback. |
| Repair focus | Same runner and fixed `repairFill` envelope | Same `_RunnerActionDockV1` -> `Act0FeedbackShellV1` | `repairReasonLine` selects focus content/tone and CTA, but does not select table dimming. |
| Repair result | Same runner/dock/card path when it is a review result | `Act0FeedbackShellV1` receipt/proof branch | More intrinsic content makes the reserved lower slot read coherently in current evidence; regression control only. |
| Correct feedback | Same runner/dock/card path when compact fixed envelope applies | `Act0FeedbackShellV1` correct branch | No table dimming; must retain current compact CTA reachability and copy. |
| Decision | Runner root's stage plus action prompt / answer-list dock | `_RunnerActionDockV1` -> `_ActionPromptPanelV1` / `_ActionPanelV1` | Fixed answer-list envelope is designed for selectable actions, not feedback-card fill. |
| Session summary | `Act0ShellPreviewScreenV1` inserts `Act0BlockCompletionShellV1` in the Scaffold body | Completion shell owns a `SingleChildScrollView`; Scaffold owns `_BottomNavV1` | It does not use the runner action dock or its fixed lower slot. |
| W12 payoff | Completion-shell payoff branch, when present | `Act0BlockCompletionShellV1` scroll body | Same completion owner as session summary, not a reason to alter runner allocation. |

Session repair remains excluded: the C2 capture duplicates repair focus and does
not establish a distinct current runtime state.

## Constraint chain and root-cause assessment

1. The runner resolves a viewport envelope. For compact answer-list pressure or
   `repairFill`, `_resolveRunnerTaskCycleViewportEnvelopeV1` reserves a fixed
   lower slot. Repair fill targets 320--420 px and can consume up to 46% of the
   available runner height; the normal compact envelope reserves 365--405 px.
2. The runner root splits the available height into a bounded upper table/stage
   `SizedBox` and a lower `SizedBox` containing `_RunnerActionDockV1`. The
   table's maximum height is derived from the remaining upper slot.
3. In a fixed slot, the dock wraps its body in a vertical
   `SingleChildScrollView`, protects its safe bottom for review, and top-aligns
   the protected content. `Act0FeedbackShellV1` itself is intrinsic-height
   (`Column(mainAxisSize: min)`) and has no contract to occupy spare slot height.
   A short wrong or repair-focus card therefore ends above the fixed slot's
   lower edge: the visible lower dead band is reserved geometry, not a local
   card-spacing defect.
4. Wrong feedback and repair focus consequently share the allocation defect.
   Repair focus has a repair reason/tone/CTA but reaches the same feedback-card
   and dock path.
5. Table dimming is a separate semantic presentation rule: the runner checks
   `isReview && quality == wrong && !rapidReviewMode`. It neither changes slot
   allocation nor recognizes repair focus. This explains repair focus's more
   dominant table without proving that all repair focus should inherit a wrong
   feedback visual treatment.
6. Session summary is outside the runner. `Act0BlockCompletionShellV1` owns a
   scroll view with bottom padding of `bottomNavHeight + gapXl`; the preview
   host's Scaffold independently owns the fixed `_BottomNavV1`. The compact
   capture's continuation below navigation is therefore a completion-scroll /
   host-safe-area or capture-position question, not an action-dock constraint.
   Its existing bottom padding makes a missing-padding conclusion unsafe; the
   next wave must reproduce and inspect scroll extent/initial position before
   changing it.

## Options

| Option | Expected EV / likely files | Regression risk | Tests and evidence | Stop condition |
| --- | --- | --- | --- | --- |
| A. Shared wrong + repair-focus allocation only | **Highest.** Establish a feedback-dock compact-fill/anchor contract in `act0_lesson_runner_shell_v1.dart`; add focused runner/widget guards. | CTA can move below reach, long content can overflow, table may become oversized, correct/result can change accidentally. | Compact literal wrong, repair focus, correct, repair result, decision; small/long copy fixtures and fixed-slot geometry assertions. | Any fix needs new data, changes decision geometry, or fails long-content reachability. |
| B. Session-summary scroll/safe-area micro-wave only | Medium, but conditional on fresh reproduction; `act0_lesson_runner_shell_v1.dart` completion shell and possibly direct preview host. | Double bottom inset, broken scroll start, payoff/W12 regression, CTA hidden after scroll. | Fresh compact session-summary and W12 payoff captures, scroll-to-end proof, completion widget tests. | Fresh capture cannot reproduce or source shows capture wrapper, not runtime clipping. |
| C. Combined runner/action-dock plus completion contract | Potentially broad polish but low confidence. Likely both files plus distinct test families. | Conflates unrelated owners, increases navigation/safe-area blast radius, obscures rollback. | All Option A and B evidence/tests, including W12 payoff. | Ownership remains separate (confirmed) or either evidence gate is absent. |
| D. Defer implementation | Avoids regressions; debt remains visible. No product files. | Repeated compact dead-space/hierarchy defect. | Re-capture only when ownership or evidence changes. | Chosen only if Option A's prototype cannot preserve controls. |

## Recommended next implementation wave

Choose **Option A only**: a bounded compact feedback lower-slot allocation wave
for wrong feedback and repair focus.

- Exact scope: make the fixed review/repair dock allocate/anchor short feedback
  content intentionally while preserving CTA safe-bottom clearance; decide
  repair-focus table hierarchy as an explicit semantic subdecision rather than
  coupling it to geometry.
- Non-scope: session summary, session repair, correct-copy redesign, repair
  result redesign, decision prompt design, W12 payoff, routes, telemetry,
  Sharky, motion, tablet, W13+.
- Likely files: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` and a
  narrowly scoped runner/feedback guard test. Add a direct preview-host test
  only if a changed contract reaches it (not expected).
- Required proof: focused existing/new widget tests for wrong, repair focus,
  correct feedback, repair result, decision, long/short compact content;
  literal compact captures of those controls; `flutter analyze`, diff checks,
  and `graphify hook-check`.
- Executor: Codex / GPT-5.6 Terra / Medium. Escalate only if an attempted
  bounded contract exposes competing safe-area ownership.

## Debt ledger / return queue

- `TERM-010` no-W13 chip copy fit: independent micro-wave.
- Session repair: evidence gap; capture a distinct state before admitting work.
- Session summary: Option B after fresh compact reproduction and scroll proof.
- Sharky final gate: externally paused; no assets here.
- Motion/touch: later, after static compact hierarchy closure.
- Runner allocation: return immediately if Option A cannot keep correct,
  repair-result, decision, long-content, and CTA-safe-area controls stable.

## Non-claims

This audit makes no 10/10, public-readiness, Human-QA-readiness, or tablet
quality claim. Human QA has not started.
