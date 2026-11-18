# Sharky — agent instructions

Read this file, then `docs/PLAN.md`. That is the whole required orientation.
Everything else under `docs/` is reference or history: open it only when a task needs a specific fact.

## Product

- Poker learning app for micro-stakes players who want to fix their mistakes fast. Flutter/Dart, iOS first, English first.
- Active app: the Act0 route — `lib/ui_v2/act0_shell/*` and its direct support code.
  Entry: `lib/main.dart` → `lib/ui_v2/app_root.dart` → `Act0ShellPreviewScreenV1`. Keep that entry.
- Most other code under `lib/` is legacy and is not reachable from `main.dart`. Do not route new work into it.
  Dormant families: `lib/ui_v2/persona`, `lib/ui_v2/ai_coach`, `lib/personalization`, `lib/ui_v3`,
  non-Act0 screens under `lib/ui_v2/screens`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
- Task catalogue: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`. Lesson runner: `act0_lesson_runner_shell_v1.dart`.
  The app screen (`act0_shell_preview_screen_v1.dart`) and the runner are split into `part` files by topic
  (`act0_shell_preview_*_v1.dart`, `act0_lesson_runner_*_v1.dart`); screen-state methods live in private extensions.

## Plan and status

- `docs/PLAN.md` is the single plan: current stage, next result, blockers, working rules.
- Work goes block by block ("Маршрут по дням" in `docs/PLAN.md`): take the first open block, one block ≈ one day ≈ one PR.
  Update the block status and the "Сейчас" table in the same PR. After changing the route, run
  `python3 tools/plan_coverage_check_v1.py` (every pre-beta Roadmap criterion must sit in a block).
  Do not create new registries, audits, review docs or handoff files.
- Roadmap 2.0 (Google Sheet) holds the text of the 165 original criteria. `docs/plan/ROADMAP_STAGE_MAP_v1.md`
  says which stage each criterion belongs to.

## How to work

- One executor finishes one stage step end to end: code, tests, self-check in the running app for visible changes.
- One final review per PR, proportional to risk. No per-part independent acceptance, exact-SHA receipts or evidence packets.
- Strict areas (always tests + review): poker correctness (rules, pot, call price, legal actions, grading),
  saving/restoring learner progress, privacy and stored data.
- Do not repeat checks whose inputs did not change.
- Continuously remove waste: a process step, test, CI job or document that costs time or money without
  guarding a real risk gets simplified or deleted when you notice it, with a one-line reason in the PR.
- Prefer free paths (web build, Personal Team signing, free CI minutes); paid services need an owner decision.
- Ask the owner only for access, or for decisions that change the product or the release.

## Code rules

- Enums are append-only; do not reorder or rename existing values.
- Keep one canonical guard site for `SpotKind`.
- Table visuals (Modern Table geometry/camera) change only inside the S4 visual stage.
- No monetization/paywall work until the plan opens it.
- Do not commit generated output: screenshots, captures, `output/`, `graphify-out/`, archives.

## Setup

- Flutter 3.35 (CI pins 3.35.0, stable), then `flutter pub get`. Linux is enough for every test; the iOS
  simulator (macOS + Xcode) is needed only for visual checks: `flutter build ios --simulator --debug`,
  then `xcrun simctl install booted build/ios/iphonesimulator/Runner.app` and
  `xcrun simctl launch booted com.example.pokerAnalyzer`. Reference device: iPhone 14 Pro, 393×852.
- Run one test file: `flutter test test/ui_v2/<file>_test.dart`. Run a Tier A shard like CI:
  `TEST_AUTHORITY_SHARD=0/3 python3 tools/test_authority/run_lane_v1.py tier-a`.
- Catalog-wide guards (Tier A): `act0_copy_error_classes_v1_test` (copy error classes),
  `act0_bet_rules_w14_v1_test` (bets and stacks), `act0_w14_no_dead_ends_v1_test` (every W1–W4 task can be
  finished), `act0_w1_long_session_v1_test` (a learner finishes W1–W4 across restarts),
  `act0_repair_goal_fingerprints_current_v1_test` (retry goals match task content).
- After editing task text: `python3 tools/update_repair_goal_fingerprints_v1.py`.
  Export the catalog to JSON for review: `flutter test tools/export_catalog_v1_test.dart --dart-define=OUT=/tmp/c.json`.

## Checks

- Before a PR: `dart format` on changed Dart files, `flutter analyze`, and the tests that cover what you changed.
- Main PR checks: Test Authority Tier A (curated product tests + `flutter analyze`), Table Truth,
  Learner Trust, Health, R5 release gate. Keep them green; do not merge on red.
- Fast local loop for W1 work: `./tools/fast_loop_world1_v1.sh`.
- Tests should check behaviour a learner could see or data they could lose. Do not add tests that assert
  wording of documents.

## Git

- Remote: `https://github.com/ClubBoss/sharky-standalone-direction.git`, base branch `main`.
- Branch per task, PR into `main`. Neighbouring roots (`Poker_Analyzer`, `Sharky`, `Sharky_main`) are archives.

## Navigation

- `graphify-out/` (if present) indexes `lib/` symbols: `graphify query "<identifier>"`, `graphify affected "<symbol>"`.
  Check `built_at_commit` against HEAD first; it does not index tests, string literals or widget keys — grep those.
- Archive docs (`docs/archive/`, `docs/_reviews/`) are history. Do not read them unless a task asks for history.
