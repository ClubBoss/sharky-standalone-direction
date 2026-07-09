# W11/W12 Late-Route Table Signal Differentiation v1

Terminal verdict: `w11_w12_late_route_table_signal_differentiation_v1_complete`

## Scope and source truth

- Baseline HEAD: `62d23f2fe716a23b6d8d20ed8610ca7ed9259bf1`.
- Working branch: `claude/hub-surface-coherence-audit-plan-v1`.
- Active owner surface: `Act0LessonRunnerShellV1`.
- The runner now receives the live `selectedWorld.worldNumber` from the
  canonical Act0 preview shell. It does not infer route state from task copy,
  change task data, or alter route/progression behavior.
- The existing real-text W7-W12 capture wrapper now passes its already-known
  capture world number to the same runner field. This fixes the evidence seam
  for world-aware runner presentation; it does not create a capture lane.

## Before and after

| Surface | Before | After |
| --- | --- | --- |
| W1-W10 | Shared table presentation. | Unchanged: no late-route signal resolves. |
| W11 | Generic in-felt callout, visually close to early-route screens. | Gold-accented `W11 - Transfer` callout: `Name the cue. Choose one action.` |
| W12 | Generic in-felt callout despite process/tilt-reset lesson context. | Gold-accented `W12 - Reset` callout: `Drop last hand. Read spot.` |
| W12 terminal completion | Already has the accepted Volume I terminal payoff. | Unchanged. |
| W13+ | No active route. | No signal resolves for W13+; no route is exposed. |

The W11 cue connects the existing table signal to one deliberate action. The
W12 cue reinforces process discipline without implying mastery, future-world
access, or that the player must be on tilt. Both use the existing callout slot
instead of adding another table layer, avoiding collision with seats and the
central pot/status hierarchy.

## Files changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - Adds the narrowly gated W11/W12 signal resolver.
  - Threads `worldNumber` into the runner and applies the signal only to the
    existing table callout slot.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
  - Supplies `selectedWorld.worldNumber` to the active runner.
- `tools/act0_real_text_surface_capture_v1.dart`
  - Supplies the already-selected capture world to the active runner so the
    existing W7-W12 visual-evidence lane reflects the live presentation.
- `test/ui_v2/act0_w11_w12_late_route_table_signal_differentiation_v1_test.dart`
  - Proves W1-W10 and W13+ resolve no late-route treatment; W11/W12 resolve
    only their claim-safe cue/action copy.

## Validation and evidence

- `flutter test test/ui_v2/act0_w11_w12_late_route_table_signal_differentiation_v1_test.dart` - 4/4 passed.
- `flutter analyze` - passed.
- `git diff --check` - passed.
- `graphify hook-check` - passed.
- Compact W1 baseline: `output/screen_review/current/runner_fast/contact_sheet.png`.
- Compact W7-W12 route comparison:
  `output/screen_review/current/active_route_w7_w12_fast/contact_sheet.png`.
- Direct compact captures reviewed:
  - `compact.w11_danger_texture_task_table.png`
  - `compact.w12_first_review_task_table.png`
- Evidence ZIP:
  `output/screen_review/current/active_route_w7_w12_fast/screen_review_active_route_w7_w12_fast.zip`.

The W7-W12 lane is larger than the three touched comparison states, but it is
the smallest existing active-route lane that reaches both W11 and W12. No
tablet or full-pack capture was run. Evidence stays local and uncommitted.

## Repair v1

The first committed presentation placed the new W11/W12 signal in a separate
in-felt callout slot. Compact evidence showed that this competed with the
existing status lane: W12 covered `Emotional spike`, while W11 crowded the
`Decision spot` / street row. The direction was valid; the layout was not.

Repair v1 removes the extra late-route overlay. The existing center status
lane now renders one gold, compact signal instead:

- W11: `W11 - Transfer` beside the street status.
- W12: `W12 - Reset` beside the street status.

This uses the table's established signal hierarchy, preserves board, pot,
seats, and street, and gives the table more breathing room by not stacking a
second status surface above it. W1-W10 retain the original blue table-signal
chip; W13+ still receives no signal. W12 terminal completion is unchanged.

Repair validation:

- Focused late-route resolver test - 4/4 passed.
- `flutter analyze` - passed.
- `git diff --check` - passed.
- `graphify hook-check` - passed.
- Raw compact W11/W12 table captures were visually reviewed after the repair.

The existing post-capture text-repair script can erase portions of this W12
state after capture. Raw real-text capture is intact and is the accepted
evidence for this repair; the raw pack was packaged directly without that
post-processing step. Push is held pending this separate repair commit.

## Explicit non-scope

- Poker correctness, task content, route IDs, progression, telemetry, and
  W13+ admission.
- W12 terminal payoff behavior.
- Hub, Profile, Practice, Review, Sharky, motion, tablet, Human QA, and
  public-readiness work.
- A broader table layout or table-signal redesign.

## Debt ledger / return queue

| Finding | Severity | Owner layer | Intended timing |
| --- | --- | --- | --- |
| W11/W12 now have distinct semantic table identity, but the full table hierarchy is still shared. | P2 | Table escalation / advanced route visual evolution | Return after the next objective design-direction pass. |
| Compact runner still has unused lower viewport space after the decision card. A broad envelope reallocation was not safe in this repair and must be addressed as a focused runner-layout wave. | P2 | Runner viewport allocation | Before final table/interaction 10/10 pass. |
| The fast screenshot text-repair post-process can damage the W12 compact table after a valid raw capture. Raw real-text evidence is valid; repair the post-process before a final 10/10 visual gate. | P2 tooling | Evidence pipeline | Before final 10/10 visual gate. |
| Profile stat-tile execution / MB-024. | P2 | Profile proof identity | Later proof-value pass. |
| Shared hub card grammar / MB-015. | P2/P3 | Visual system | Final consistency pass. |
| Practice/Review minor sparseness and dead space. | P3 | Hub polish | Final static polish. |
| Sharky placeholder and motion/touch depth. | P1 before public/Human QA | Mascot and interaction design | Dedicated later waves. |

No 10/10, public-readiness, Human-QA-readiness, mastery, or future-world claim
is made by this wave.
