# First 5 Minutes Flow (Golden Hour) - SSOT

## 1) Entry points (screens, states, preconditions)
- App cold start or resume lands on `main_navigation_screen.dart` or `main_menu_screen.dart`.
- Training entry originates from existing training list surfaces:
  - `training_pack_screen.dart` or `training_pack_template_list_screen.dart`.
  - `module_catalog_screen.dart` (when used as the pack list).
- Preconditions:
  - Training pack index is available (pack list renders without error).
  - Navigation stack is clean (no blocking modal or author preview state).

## 2) Deterministic sequence to first success moment
1. Entry screen shows the primary training entry affordance (pack list or training hub).
2. User selects a training pack/template from the list.
3. `TrainingSessionLauncher` starts a session and navigates to `training_session_screen.dart`.
4. The first training spot renders and accepts a user action (training play loop).
5. User completes the pack-defined session loop (spot sequence ends).
6. `training_session_completion_screen.dart` is displayed.

## 3) Success definition (signals only)
Success is reached when ALL of the following occur:
- `TrainingSessionEndReasonV1.completed` is signaled.
- `training_session_completion_screen.dart` is shown to the user.
- Telemetry event `session_end` is emitted.

## 4) Allowed vs disallowed actions in this window
Allowed actions:
- Navigate from entry screen to pack list and select a pack.
- Start a training session and submit actions for spots.
- Use in-session navigation that already exists (next/prev where exposed).
- Complete the session and land on the completion screen.
- Exit the session via the provided exit confirmation.

Disallowed actions (outside the First 5 Minutes flow):
- Opening theory/lesson screens (`theory_lesson_viewer_screen.dart`).
- Entering learning path or skill tree flows (`learning_path_screen_v2.dart`, `skill_tree_screen.dart`).
- Opening analytics/stats screens (`progress_dashboard_screen.dart`, `training_stats_screen_v2.dart`).
- Entering gamification screens (`achievements_screen.dart`, `daily_challenge_screen.dart`, `goals_screen.dart`, `streak_history_screen.dart`, `shop_screen.dart`).
- Editing packs or spots (`spot_editor_screen.dart`).
- Using dev/admin utilities (`dev_menu_screen.dart`).

## 5) Abort / exit paths and handling
- From `training_session_screen.dart`:
  - System back or in-app exit triggers the exit confirmation.
  - On confirm, session ends with `TrainingSessionEndReasonV1.aborted` and `session_abort` is emitted.
  - Navigation returns to the previous screen on the stack (pack list or entry screen).
- From `training_session_completion_screen.dart`:
  - Retry: starts a new session for the same pack.
  - Choose other pack: navigates to `training_pack_template_list_screen.dart`.
  - Home: pops to the root of the navigation stack.

## 6) Telemetry emitted (names only)
- `session_start` (on session launch).
- `session_end` (on successful completion).
- `session_abort` (on confirmed exit).

## 7) Explicit non-goals
- No new content, pedagogy, or lesson structure.
- No new UI or navigation surfaces.
- No new telemetry events or schema changes.
- No changes to training pack composition or evaluation rules.
- No gamification, monetization, or social features.
