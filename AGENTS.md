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

## Plan and status

- `docs/PLAN.md` is the single plan: current stage, next result, blockers, working rules.
- Update the stage status in `docs/PLAN.md` in the same PR that moves it. Do not create new registries,
  audits, review docs or handoff files.
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

## Checks

- Before a PR: `flutter analyze` and the tests that cover what you changed.
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
