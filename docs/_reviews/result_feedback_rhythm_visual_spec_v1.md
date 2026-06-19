# Result Feedback Rhythm Visual Spec v1

Date: 2026-06-19
Branch: `codex/result-feedback-rhythm-visual-spec-v1`
Base commit: `23de8047`
Mode: audit/spec; no implementation.

## 1. Inputs Read

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/compact_first_week_proof_packet_v1.md`
- `docs/_reviews/full_surface_10_ux_ui_coherence_gate_v1.md`
- `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`
- `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`
- `docs/_reviews/act0_rule_based_repair_result_receipt_v1.md`
- `docs/_reviews/act0_session_repair_summary_v1.md`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`

## 2. Current Proven Product Spine

The current Act0 spine is proven:

`missed signal -> visible repair reason -> repair attempt -> fixed/repeated receipt -> session repair summary`

Current implementation already has these seams inside the active Act0 feedback
path:

- immediate correct / wrong / suboptimal result state;
- selected vs preferred answer line;
- table-signal proof row;
- reason copy;
- first-value or repair receipt;
- active repair session summary;
- local deterministic repair state, with no new telemetry owner.

The remaining issue is not logic. The remaining issue is rhythm: the learner
should feel a clean sequence of "I chose -> Sharky showed the clue -> I know
what to do next" instead of reading a dense stack of equally weighted UI
fragments.

## 3. 10/10 Feedback Rhythm

The target 10/10 result rhythm is:

1. Decision submitted.
2. Immediate correctness feedback appears.
3. If wrong or suboptimal, the missed clue becomes visible without shame.
4. The reason explains the table signal, not generic correctness.
5. If repair-worthy, the next repair reason is tied to the same clue.
6. The repair attempt happens.
7. The repair receipt shows fixed or repeated.
8. The session summary closes the loop with one honest next focus.

Learner experience by result:

- Correct: "I saw the right clue. Keep this read and use it again."
- Wrong: "I missed a visible table clue. That is fixable."
- Suboptimal: "My instinct was close, but one better clue should guide me."
- Fixed repair: "This exact clue got easier."
- Repeated repair: "This clue is still fragile; one more repair hand is the
  next useful step."

The rhythm must stay emotionally light. Wrong is not a failure state; it is the
start of the repair loop.

## 4. Moment-by-Moment UI Pattern Map

| Moment | Preferred pattern | Why | Avoid |
| --- | --- | --- | --- |
| Decision submitted | Micro-moment inside the existing result card. | The app should feel fast; no transition should delay feedback. | Modal, full-screen interstitial, decorative animation. |
| Immediate correctness | Result band, not a generic pill. | Correct/wrong/suboptimal needs emotional clarity and immediate color/icon hierarchy. | Tiny verdict chip as the primary signal. |
| Missed clue reveal | Compact clue card or highlighted proof row. | The clue is Sharky's teaching object; it deserves more weight than metadata. | Punitive red error block, buried one-line label. |
| Explanation / why | Inline copy below clue card. | The why should read as coach explanation tied to the visible clue. | Long paragraph, generic encouragement, solver/GTO language. |
| Repair reason | Timeline row or compact repair card. | The learner should see why the next hand was selected without reading internals. | Standalone chip, raw reason code, "AI found" framing. |
| Repair attempt | Existing runner flow. | The repair hand is the action, not a new screen. | New route, modal workflow, dashboard detour. |
| Repair receipt | Compact receipt card. | Fixed/repeated is proof and should feel like a mini receipt. | Status tag only, fake mastery badge, large celebration. |
| Session summary | Persistent summary card or small ceremony block. | Session proof should close the loop and feed return reason. | Analytics dashboard, broad leak profile, multi-metric report. |
| Next action | Primary CTA row inside the result rhythm. | The learner should know exactly what to do next. | Competing CTAs with equal weight. |

Recommended visual order inside the existing feedback surface:

1. Result band: `Good read` / `Not quite` / `Better clue`.
2. Primary answer line: the correct or better action.
3. Table clue card: the visible signal proof.
4. Why copy: one compact explanation.
5. Repair / first-value receipt card.
6. Session summary card when present.
7. One next action.

## 5. Pills / Chips Verdict for Result Moments

Pills and chips are acceptable only as tertiary metadata in result/feedback.

Allowed:

- small secondary state labels;
- compact debug-safe task context when not competing with the clue;
- low-priority metadata such as category or route status.

Not allowed as primary feedback:

- correctness;
- missed clue;
- repair receipt;
- session proof;
- next action.

Reason:

The result moment carries the product promise. If the primary emotional beats
are small pills, the app feels like a generic training UI instead of a table
coach. Result, clue, repair receipt, and session summary need card/receipt/proof
shapes with clear hierarchy.

## 6. Copy and Tone Rules

Copy must be:

- calm;
- specific;
- table-signal grounded;
- confident but not overclaiming;
- beginner-safe;
- short enough to scan before the next hand.

Wrong-answer copy should say:

- what was missed;
- why that clue matters;
- what the next repair action is.

Correct-answer copy should say:

- what clue was read correctly;
- how to keep using that read;
- next useful action without fake mastery.

Repair receipt copy should say:

- fixed: the clue was caught this time;
- repeated: the same clue is still fragile;
- exact replay: this spot was handled or missed again, without transfer claims.

Forbidden:

- fake mastery;
- win-rate or guaranteed-improvement claims;
- "AI", "adaptive", "GTO", "solver", or black-box language;
- punitive language;
- premium, paywall, trial, purchase, restore, unlock language.

## 7. Visual Hierarchy Rules

Primary hierarchy:

1. Result.
2. Table clue.
3. Next action.

Secondary hierarchy:

- answer comparison;
- reason copy;
- Sharky reaction line;
- repair reason.

Tertiary hierarchy:

- metadata;
- context labels;
- status labels;
- XP / streak / reward details.

Rules:

- Do not give pills, tags, XP, context labels, and clue proof equal weight.
- The missed clue must be visually easier to find than the metadata.
- The receipt must look like proof, not like another status label.
- The result card should read top-to-bottom as a sentence:
  "Not quite -> nobody had bet yet -> repair this clue next."
- A learner should understand the screen in under five seconds.

## 8. Motion / Ceremony Policy

Motion is allowed later only if it reinforces repair proof.

Allowed later:

- subtle fixed-receipt confirmation;
- calm repeated-clue nudge;
- summary completion beat;
- gentle transition from clue card to repair receipt;
- short table-signal highlight if it helps connect the card to the table.

Not allowed:

- decorative motion for beauty;
- confetti for normal correctness;
- shame animation for wrong answers;
- modal overload;
- screenshot-led visual churn;
- Modern Table micro-polish detached from feedback proof.

## 9. What Was Intentionally Not Changed

- No product implementation.
- No visual redesign implementation.
- No route changes.
- No Modern Table polish.
- No table geometry changes.
- No dashboard.
- No commerce, public paywall, pricing, purchase, restore, trial, or Premium
  Hub work.
- No AI, ML, adaptive, coach/chat, GTO, solver, optimal-frequency, win-rate, or
  guaranteed-improvement claims.
- No telemetry owner or network telemetry changes.
- No content expansion.
- No generated screenshots or proof outputs.
- No workflow changes.
- No `external_competitors/` changes.
- No Runout assets, binaries, screenshots, docs, or extracted materials.

## 10. Recommended First Implementation Wave

Recommended next wave:

`Act0 Result Feedback Rhythm Surface v1`

Why this is first:

- It is the highest-EV surface because every repair-proof beat passes through
  the existing feedback card.
- It can reuse the current `Act0FeedbackShellV1` seam without adding a route.
- It can improve rhythm by changing hierarchy and composition around already
  proven data: result, signal proof, reason, receipt, and summary.
- It can include repair receipt visual rhythm as part of one coherent result
  pass, without starting a separate dashboard or summary product.

Do not start with standalone `Act0 Repair Receipt Visual Rhythm v1` because the
receipt only works emotionally when the surrounding result/clue/why hierarchy is
clear.

Do not start with `Act0 Session Summary Ceremony v1` because the summary should
inherit the result rhythm first.

## 11. Acceptance Gates for Implementation

For `Act0 Result Feedback Rhythm Surface v1`, acceptance requires:

- correct, wrong, and suboptimal feedback each have a clear primary result
  band or equivalent high-clarity result moment;
- wrong/suboptimal feedback makes the missed or better table clue visibly
  primary without punitive language;
- repair result receipt appears as a compact receipt/proof card, not just a
  status label;
- session repair summary appears as a distinct summary/proof block when present;
- first-value receipt remains visible and distinct from repair receipt;
- non-repair feedback remains unchanged in meaning;
- exact replay still avoids same-signal transfer claims;
- correct answers do not create repair copy or open repair state;
- no raw internal repair payloads are exposed;
- no route, Modern Table, table geometry, commerce, telemetry owner, dashboard,
  AI/adaptive/GTO/solver, generated output, workflow, or localization expansion
  is introduced.

Tests needed:

- extend `test/ui_v2/act0_repair_intent_resolver_v1_test.dart` or add a focused
  Act0 feedback rhythm test proving visible ordering/keys for result, clue,
  repair receipt, and session summary;
- keep `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart` green;
- keep `test/ui_v2/act0_telemetry_sink_v1_test.dart` green if shell state is
  touched;
- keep broad `test/ui_v2/act0_shell_preview_screen_v1_test.dart` green if
  feedback layout keys or preview contracts change.

Verification for implementation wave:

- `dart format` on touched Dart files;
- `flutter analyze`;
- targeted feedback/repair tests;
- `git diff --check`;
- `./tools/fast_loop_world1_v1.sh`;
- `./tools/release_gate_world1.sh` if Act0 shell runtime files are touched.

## 12. Verification / Checks

Run for this docs/spec PR:

- `git diff --check`
  - passed
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`

No product tests are required because no runtime code or tests changed.
No release gate is required unless repo policy or PR checks require it.

## 13. Final Verdict

Spec admitted.

The next implementation should upgrade the existing Act0 feedback card rhythm,
not create a new route, dashboard, or visual redesign arc. The first visual pass
should make the result, clue, receipt, and session summary read as one calm
learning sentence.
