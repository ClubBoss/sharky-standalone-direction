# Act0 Surface Coherence Map v1

## 1. Date / Branch / Base Commit

- Date: 2026-06-20
- Branch: `codex/act0-surface-coherence-map-v1`
- Base commit: `744dfe32`

## 2. Mode

Local-only audit/spec wave.

No implementation, UI redesign, route change, Modern Table change, telemetry change, commerce change, screenshot work, workflow work, GitHub action, push, or PR is admitted in this wave.

## 3. Current Proven Spine

The current Act0 spine is:

`missed signal -> visible reason -> repair attempt -> receipt -> summary -> Home next action`

Current proven ownership:

- Result/feedback owns the immediate missed clue and visible reason moment.
- Repair attempts own the deterministic retry path.
- Repair result receipts own the fixed/repeated proof moment.
- Session summary owns the session-end ceremony.
- Home owns the next-best-action handoff after proof.

This spine should stay narrow. Other surfaces can reference the spine, but they should not duplicate every proof moment.

## 4. Surface Role Map

### A. Home

10/10 job: choose the next best action.

Current state:

- Home already has a repair-aware next action through `Act0HomeShellV1.nextUsefulHandReasonLine`.
- Home can route the learner to Learn, Practice, or Review from the active Act0 shell.
- Home has enough state to explain why the next useful hand is selected without exposing raw repair-intent payloads.

Rules:

- Home decides where the learner should go next.
- Home should show one dominant next action plus a compact reason.
- Home must not become a dashboard, analytics page, generic streak board, or duplicated session ceremony.

Future direction:

- Route to Learn, Practice, or Review based on learner state.
- Prefer repair-aware handoff when an open repair or fragile clue exists.
- Keep all secondary status below the primary action.

### B. Learn

10/10 job: structured route and progress clarity.

Current state:

- Learn is owned by `Act0LearnPathShellV1`.
- It answers where the learner is, which concept is active, and what comes next in the route.
- It can receive focused route context from the Act0 shell.

Rules:

- Learn teaches the route.
- Learn should clarify concept progression, not become a generic content library.
- Learn connects to repair proof through route context, not by showing repair receipts or personal error logs.

Future direction:

- Make the current concept and next concept easier to scan.
- Add only light bridges from route progress to the current focus when needed.
- Avoid duplicating Home's next-action ownership.

### C. Practice / Play

10/10 job: fast reps and repair reinforcement.

Current state:

- Practice is owned by `Act0PlayShellV1` when the Play tab is showing the practice hub.
- The shell can pass recommended group title, subtitle, reason, outcome, and mastery labels.
- Existing practice groups include daily, weak spots, continue, placement, and topic packs.

Rules:

- Practice reinforces the hand Sharky wants the learner to train.
- Practice should use repair or fragile-clue state when Home routes there.
- Practice must not duplicate Learn's route map or Review's personal repair-coach role.

Future direction:

- Make a repair or fragile clue the primary Practice entry when one exists.
- Keep generic daily practice clean when no repair state exists.
- Use deterministic reason copy, not AI/adaptive claims.

### D. Review

10/10 job: personal repair coach.

Current state:

- Review is owned by `Act0ReviewShellV1`.
- It already has pending mistakes, recovered mistakes, dominant pattern language, and repair/replay actions.
- It is closest to a personal repair board.

Rules:

- Review repairs patterns and clue families.
- Review should explain what clue keeps showing up and which repair comes next.
- Review must not become a raw error log, analytics dashboard, or broad coaching chat.

Future direction:

- Later, promote repeated clue families when there is enough evidence.
- Keep recovered proof lightweight and human-readable.
- Do not move Home's next-action decision into Review.

### E. You / Profile

10/10 job: progress identity and confidence mirror.

Current state:

- Profile is owned by `Act0ProfileShellV1`.
- It reflects placement, confidence, streak, recent gains, and replay/welcome actions.

Rules:

- You/Profile reflects who the learner is becoming.
- It should show improvement and current focus without exposing raw state payloads.
- It must not become a data warehouse, retention dashboard, or analytics console.

Future direction:

- Later, show repaired clues, current focus, and confidence as identity-level progress.
- Keep the surface quieter than Review.
- Avoid making Profile a second Home.

### F. Result / Receipt / Summary

10/10 job: proof moments.

Current state:

- Result feedback owns the immediate table-clue explanation.
- Repair result receipts own the fixed/repeated proof.
- Session summary owns the session-end ceremony.

Rules:

- Proof moments live where the learner just acted.
- Session ceremony stays session-end only.
- Home can reference the next focus, but should not duplicate the full receipt or session summary.

Future direction:

- Keep result feedback, repair receipt, and session summary distinct.
- Use Home/Practice/Review to route from proof, not to replay the full ceremony.

## 5. Cross-Surface Routing Rules

- Home decides.
- Learn teaches.
- Practice reinforces.
- Review repairs patterns.
- You/Profile reflects growth.
- Result/Receipt/Summary proves progress.

Only Home should own the top-level next action. Other surfaces can present local actions that match their role.

## 6. Anti-Patterns

- Duplicate next-action cards across Home, Practice, Review, Learn, and Profile.
- Pill/chip soup that makes every label compete for attention.
- Dashboard before proof.
- Generic motivation that does not connect to a table clue, action, or repaired hand.
- AI, adaptive, ML, solver, GTO, optimal, win-rate, or guaranteed-improvement language.
- Premature premium, paywall, trial, purchase, restore, or commerce language.
- Raw analytics tables or exposed internal payloads.
- Moving Act0 ownership away from the current shell route.

## 7. Recommended Next Implementation Wave

Recommended wave: `Practice Repair-Reinforcement Entry v1`.

Why this is highest EV and lowest risk:

- Home now has a deterministic next-best-action handoff.
- Practice is the natural place to turn that handoff into fast reinforcement.
- The existing Play hub already accepts a recommended group, title, subtitle, reason, outcome, and mastery labels.
- This wave can strengthen the proof loop without creating a Review dashboard or adding Profile/Learn complexity.
- It keeps the learner in the core loop: one missed clue, one useful hand, one reason, one repair rep.

Deferred candidates:

- `Review Repair-Coach Entry v1`: valuable, but higher risk of becoming an error log or pattern dashboard before Practice reinforcement is crisp.
- `Learn Route Clarity v1`: useful after the route/repair boundary is clearer.
- `You Progress Mirror v1`: valuable later, but it should reflect proven repaired clues rather than create a new progress system first.

## 8. Acceptance Gates For Practice Repair-Reinforcement Entry v1

Allowed files and surfaces:

- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` only if needed to pass existing deterministic recommendation state into Practice.
- Focused tests in `test/ui_v2/act0_shell_preview_screen_v1_test.dart` and/or existing repair-intent resolver tests.
- One focused review artifact for the implementation wave.

Visible requirements:

- When a repair or fragile clue exists, Practice shows it as the primary reinforcement entry.
- The Practice entry explains why this rep is useful through deterministic reason copy.
- The action launches the existing repair or practice path.
- When no repair state exists, existing generic Practice behavior remains intact.

Must not change:

- Routes.
- Modern Table visuals or geometry.
- Home's top-level next-action ownership.
- Review, Learn, or Profile behavior unless a tiny shell handoff is required and explicitly justified.
- Telemetry implementation or payload shape.
- Monetization, premium, trial, paywall, purchase, restore, or entitlement behavior.
- Screenshots, Playwright, workflows, localization, content packs, or generated outputs.

Tests:

- Repair state prioritizes the Practice repair-reinforcement entry.
- No-repair state preserves existing daily/generic Practice behavior.
- Failed repair state still routes to reinforcement.
- Successful repair clearing restores fallback Practice behavior.
- No Session proof text leaks into Practice.
- No forbidden AI/ML/solver/GTO/commerce language appears in touched payloads or copy.
- Existing Act0 repair-intent and broad preview tests remain green.

Verification:

- `dart format` on touched Dart files if implementation touches Dart.
- `flutter analyze`.
- Targeted tests for the touched Practice/repair surface.
- `./tools/fast_loop_world1_v1.sh`.
- `./tools/release_gate_world1.sh` before PR.
- No GitHub action until local summary approval.

## 9. Design-Language Note

Pills and chips are not the final answer by default.

Use compact labels only when they reduce scanning cost. Primary action, repair proof, and progress receipt should prefer blocks, cards, receipts, or clear rows with one dominant idea. A later design-research pass can decide final visual language; this map only protects role ownership and surface coherence.

## 10. Screenshot Policy

Screenshots are not required for this spec-only wave.

Screenshots are required when an implementation wave changes visible Practice, Review, You/Profile, Learn, major Home, result, receipt, or session-summary surfaces. Screenshot work remains out of scope for this local-only spec wave.

## 11. What Intentionally Did Not Change

- No product code changed.
- No UI, copy, route, Modern Table, telemetry, commerce, workflow, screenshot, generated output, or test changed.
- No GitHub action was taken.
- No push or PR was created.
- No external or competitive research folder was touched.

## 12. Verification

- `git diff --check`: passed
- `./tools/fast_loop_world1_v1.sh`: passed, `FAST LOOP PASS`
