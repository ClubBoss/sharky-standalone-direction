# Wave 3.10 - Premium Motion Moments v1

## 1. Verdict

wave3_10_premium_motion_moments_ready

## 2. Target 10/10 block: Premium Proof-Loop Motion

Target block A from the Wave 3.9.2 TOP1 backcast matrix: Premium Proof-Loop Motion.

The intended movement is for the learner to feel cause/effect across the proof loop:
choice -> feedback -> repair proof -> session proof -> street replay context.

## 3. Current gap

Before this slice, key proof moments were mostly static text/state changes. Some proof blocks already had subtle reveal motion, but the main feedback card, Session Summary proof hero, and Street Replay step list did not expose a clear, testable proof-loop motion moment.

## 4. Implemented moments

| Target moment | State | Result |
| --- | --- | --- |
| Decision -> Feedback | implemented | `Act0FeedbackShellV1` now wraps the mounted feedback card in the existing local proof reveal wrapper with `act0_shell_feedback_card_motion_reveal`. |
| Fix Landed / Repair Success | implemented | Existing repair outcome proof reveal remains the owned receipt/proof moment and now settles with the shared scale/slide/opacity reveal. |
| Session Summary Proof Hero | implemented | Block completion proof hero now has an explicit `act0_shell_session_summary_proof_hero_motion_reveal` wrapper while preserving the existing payoff key. |
| Street Replay Reveal | implemented | Street Replay rows now reveal through the same subtle local wrapper keyed per structured step, e.g. `act0_shell_street_replay_step_motion_0`. |

No target moment was blocked. No table motion or replay playback renderer was added.

## 5. Learner-visible change

The visible change is subtle motion on meaningful proof events only:

- feedback card settles in when the learner receives the result;
- repair proof/receipt settles in when a fix attempt is shown;
- Session Summary proof hero settles in at session close;
- Street Replay rows settle in when the structured replay sheet opens.

The content remains visible, readable, and non-dependent on animation.

## 6. Replay Source Boundary

The Street Replay motion layer consumes the existing `_StreetReplayStepRowV1` rows built from `Act0StreetReplayStepV1` instances inside `_StreetReplaySheetV1`.

This preserves the source boundary:

- motion/presentation consumes structured replay steps;
- there is no authored-content-only assumption;
- there is no hand-import parser implementation;
- future hand-import-derived replay steps can drive the same presentation if they produce the same structured objects;
- no table geometry, table cards, seats, chips, action buttons, route state, or gameplay state changed.

## 7. Evidence

Code evidence:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - feedback card reveal key: `act0_shell_feedback_card_motion_reveal`;
  - repair outcome reveal key: `act0_shell_repair_outcome_motion_reveal`;
  - Session Summary proof hero reveal key: `act0_shell_session_summary_proof_hero_motion_reveal`;
  - Street Replay step reveal keys: `act0_shell_street_replay_step_motion_$i`.

Test evidence:

- focused feedback test asserts feedback-card motion, repair proof motion, `AnimatedSlide`, `AnimatedOpacity`, and `AnimatedScale`;
- focused block summary test asserts the Session Summary proof hero motion key;
- focused street replay test asserts a structured replay step motion key inside the opened sheet.

Screenshot proof:

- `./tools/screen_review_fast_v1.sh first_week compact` passed and regenerated `output/screen_review/current/first_week_fast/`;
- `./tools/screen_review_fast_v1.sh day2_return compact` passed and regenerated `output/screen_review/current/day2_return_fast/`;
- `./tools/screen_review_fast_v1.sh full_scroll compact` passed and regenerated `output/screen_review/current/full_scroll_fast/`.

Device recording / frame sequence:

- no repo-owned frame-sequence, GIF, video, or screen-recording helper was found under `tools/`;
- the best available local proof for this wave is widget motion-key coverage plus deterministic screenshot packets;
- generated screenshot artifacts remain local-only and untracked.

## 8. Anti-theater proof

The motion is tied only to proof-loop state that already exists:

- result feedback card;
- repair proof/receipt;
- Session Summary proof hero;
- structured Street Replay step rows.

No decorative particles, confetti, Lottie, broad animation system, global motion framework, fake delay, new reward ceremony, or hidden state transition was added. Reduce-motion users get the child content directly through `MediaQuery.disableAnimations`.

## 9. Not built list

Not built:

- no new dependencies;
- no broad motion system;
- no Lottie, particles, or confetti;
- no Modern Table visual change;
- no table geometry, seats, chips, cards, action buttons, or table animation;
- no route, localization, monetization, content, gameplay, progression, or telemetry change;
- no AI, chat, fake mastery, GTO, solver, or hand-import claim;
- no hand-import parser;
- no playback controls, scrubber, replay renderer, or replay state machine.

## 10. Expected TOP1 movement

Expected movement: modest but real. This raises premium feel on the current proof loop without opening a broad animation/replay system or changing route truth.

## 11. Actual observed movement

Observed movement is test-proven at widget level and screenshot-packet-safe at surface level. It is not fully measurable as video/frame proof because the repo has no existing recording/frame-sequence tool for this packet type.

## 12. Next wave validity

Proceed to Wave 3.11 unless review of the latest packets identifies a concrete accepted blocker. The next wave should keep using the TOP1 backcast matrix and avoid broad motion expansion unless a specific proof-loop moment is selected.

## Validation

Passed:

- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart --name "repair outcome proof renders compact local proof only"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Street replay opens structured how-we-got-here sheet without hiding decisions"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Block summary exposes mastery and suggested next action"`
- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `flutter analyze`
- `graphify hook-check`
- `dart format --set-exit-if-changed` on touched Dart/test files
- `git diff --check`
- `git diff --cached --check`

Final local status before staging:

- source/test/review files changed for this wave;
- generated `output/claude_review/` and `output/screen_review/` directories remain untracked and local-only.
