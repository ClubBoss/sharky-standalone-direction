# Claude UX/UI v2 Wave 1 Safe-Now Cleanup Plan

## 1. Verdict

safe_now_cleanup_wave1_plan_ready

Wave 1 should stay split into small PRs. The remaining safe-now work is presentation cleanup, not a route, progression, content, monetization, or data-model wave.

## 2. Source audit reference

Accepted input:

- Claude Design UX/UI v2 Audit.
- Overall UX score: 7.0.
- First-week score: 7.0.
- Beginner-friendly score: 7.5.
- Learning-effect score: 7.0.
- Premium-ready score: 6.0.

Main safe-now issues from the accepted audit:

1. Profile decorative scroll / repeated mood-copy.
2. Mascot inconsistency / flat fallback circle.
3. Feedback density and reward hierarchy.
4. Session Summary headline/tone.
5. Home next-action duplication / XP prominence.

## 3. Wave 1 goal

Make the current first-week and return-loop surfaces feel clearer, calmer, and more premium without changing Sharky's learning engine or inventing new learner evidence.

Wave 1 should:

- reduce decorative UI repetition;
- clarify primary action ownership;
- improve coach identity consistency;
- tighten feedback and summary hierarchy;
- preserve all route/progression/telemetry/content truth.

## 4. Already completed slice

### PR1 Profile Compression / Evidence-Safe Cleanup v1

Status: completed and pushed.

Evidence:

- Full-Scroll Screen Evidence v1 is on `origin/main`.
- Profile Compression / Evidence-Safe Cleanup v1 is on `origin/main`.
- Profile compact full-scroll max extent dropped to the compressed evidence state recorded in `output/screen_review/current/full_scroll_fast/full_scroll_meta.json`.

Completed intent:

- Identity / Level moved near the top.
- Current focus remains actionable.
- Repeated Recent progress / rhythm mood-copy collapsed.
- Settings/account access preserved.
- No new Profile evidence claims were added.

## 5. Remaining PR sequence

1. PR2 Mascot Consistency / Coach Identity v1.
2. PR3 Feedback + Session Summary Tone/Density v1.
3. PR4 Home De-dupe / Reward Hierarchy v1.

Do not merge these into one large cleanup PR.

## 6. Per-PR scope

### PR2 Mascot Consistency / Coach Identity v1

Likely touched files/surfaces:

- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- Profile/Welcome/feedback mascot call sites only if they already use the shared presence widget.
- Focused tests in `test/ui_v2/act0_shell_preview_screen_v1_test.dart` or an existing Sharky presence test.

Allowed changes:

- Replace flat/fallback mascot treatments with the existing canonical Sharky presence where already safe.
- Normalize size, tone, and placement of the existing coach identity.
- Keep coach presence supportive and non-claiming.

Forbidden changes:

- No new mascot asset pipeline.
- No new emotion/persona system.
- No AI/chat/coach expansion.
- No layout redesign outside mascot wrapper/call sites.
- No route, progression, telemetry, content, glossary, Modern Table, premium, or generated output changes.

Tests/proof required:

- Focused mascot/presence tests if present or touched.
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

Expected commit message:

`feat: normalize Sharky coach presence`

Product risk:

Low-medium. Risk is visual inconsistency or accidental broad persona expansion.

### PR3 Feedback + Session Summary Tone/Density v1

Likely touched files/surfaces:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- Session Summary owner in the Act0 shell if separate.
- Focused feedback/session-summary tests.

Allowed changes:

- Tighten feedback hierarchy and reduce dense stacked copy.
- Keep amber/coaching tone for wrong answers.
- Make Session Summary headline/tone clearer and calmer.
- Preserve already-owned facts and existing repair/session evidence.
- Keep one primary CTA per card.

Forbidden changes:

- No new repair result state.
- No durable evidence claim changes.
- No Session Summary data model expansion.
- No new Profile, Review, Practice, or Home behavior.
- No telemetry schema change.
- No AI/leak/mastery/GTO/solver language.
- No route/progression/content/glossary/Modern Table changes.

Tests/proof required:

- Focused feedback rhythm tests.
- Focused Session Summary tests/capture contract tests.
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact` if Session Summary scroll proof changes.
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

Expected commit message:

`feat: tighten feedback and session summary tone`

Product risk:

Medium. Risk is accidentally weakening factual repair evidence or creating fake completion/reward claims.

### PR4 Home De-dupe / Reward Hierarchy v1

Likely touched files/surfaces:

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- Focused Home/first-week tests.

Allowed changes:

- Ensure Home hero owns the primary next action.
- Convert below-hero rows into neutral session shape/status.
- Reduce XP/reward prominence where it competes with the next action.
- Preserve truthful current lesson/world/repair state.

Forbidden changes:

- No new Home data model.
- No Practice recommendation expansion.
- No Review history or fake backlog.
- No route/progression/telemetry/content/glossary changes.
- No premium/paywall.
- No dashboard/XP economy expansion.
- No Modern Table changes.

Tests/proof required:

- Focused Home shell tests.
- First-week packet:
  `./tools/screen_review_fast_v1.sh first_week compact`
- Core packet:
  `./tools/screen_review_fast_v1.sh core compact`
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

Expected commit message:

`feat: simplify home next-action hierarchy`

Product risk:

Low-medium. Risk is hiding a real repair/lesson priority or making Home too passive.

## 7. Explicit non-goals

- No Modern Table redesign.
- No route/progression changes.
- No W11/W12/W13 activation.
- No Profile evidence claims beyond admitted data.
- No Review history UI.
- No Practice recommendation expansion.
- No onboarding implementation.
- No premium/paywall.
- No broad redesign.
- No generated output commits.
- No repo-wide formatter.
- No AI/chat/persona expansion.
- No dashboard/charts/XP economy expansion.

## 8. Validation plan

Every PR must run:

```bash
graphify hook-check
flutter analyze
git diff --check
git status --short
```

Each PR must also run the smallest focused widget/contract tests for touched surfaces.

Run formatting only on touched Dart/test files:

```bash
dart format --set-exit-if-changed <touched Dart/test files>
```

Do not run repo-wide formatter.

## 9. Screenshot/evidence plan

Use deterministic fast evidence only. Do not commit generated output.

Default packets by PR:

- PR2: `first_week compact` and `day2_return compact`.
- PR3: `first_week compact`, `day2_return compact`, and `full_scroll compact` if Session Summary scroll proof changes.
- PR4: `first_week compact` and `core compact`.

Generated output paths remain local-only under:

- `output/screen_review/current/`
- `output/claude_review/`

## 10. Stop conditions

Stop and report if a proposed PR requires any of the following:

- Modern Table changes.
- route/progression mutation.
- telemetry schema change.
- content/glossary change.
- new learner evidence claims.
- Profile/Review history modeling.
- Practice recommendation expansion.
- W11/W12/W13 activation.
- premium/paywall work.
- AI/chat/persona expansion.
- new screenshot tooling.
- generated output staging.
- broad redesign beyond the named surface.

## 11. Recommended next prompt

Next prompt:

`Mascot Consistency / Coach Identity v1 — Local Only`

Recommended scope:

- Inspect current Sharky presence ownership and mascot call sites.
- Normalize only existing coach identity presentation.
- Do not introduce new persona/AI behavior, new assets, or route changes.
- Validate with focused tests plus `first_week compact` and `day2_return compact` screenshot packets.
