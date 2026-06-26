# Wave 3.5 - Premium Transition & Replay Motion System v1

## 1. Verdict

wave3_5_premium_transition_replay_motion_no_code_needed

The current screenshot packets and code seams do not show a concrete high-EV motion or transition opportunity that should be implemented in this wave. Existing proof-loop motion from Wave 2.6 remains active, and Street Replay already uses a platform bottom-sheet transition over a deterministic `Act0StreetReplayV1` contract.

## 2. TOP1 matrix row target

- Primary: premium transition / replay motion.
- Secondary: street context / how-we-got-here comprehension, Session Summary payoff, first proof loop, premium visual feel, habit loop / return reason.

## 3. Wave goal and scope

Goal: audit whether a small deterministic motion/transition improvement would make the existing proof loop or Street Replay clearer, more premium, or more memorable.

Scope stayed limited to:

- Street Replay / `How we got here`;
- proof-loop transitions;
- Review to Practice handoff;
- repair result / fix attempt payoff;
- Session Summary proof / earned moment reveal;
- compact Sharky line moments.

No product code changed because the safe motion surfaces are already covered or would require a new animation layer that the prompt explicitly scoped out.

## 4. Evidence inspected

Screenshot packets:

- `./tools/screen_review_fast_v1.sh day2_return compact` passed.
  - Contact sheet: `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - Zip: `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact` passed.
  - Contact sheet: `output/screen_review/current/first_week_fast/contact_sheet.png`
  - Zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Current motion wrappers:

- `_ProofMotionRevealV1` in `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `AnimatedScale` press affordance in `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- existing platform `showModalBottomSheet` transition for Street Replay.

Surfaces:

- Street Replay entry / sheet owner seam.
- Review handoff card and `Practice this spot` CTA.
- active repair result / table feedback surface.
- Session Summary proof payoff.
- Profile proof area where motion was intentionally not in scope.

Files:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `test/ui_v2/act0_street_replay_contract_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `test/ui_v2/act0_play_shell_v1_test.dart`

Route / prior-wave artifacts:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/public_premium_top1_v1_endgame_lock_v1.md`
- `docs/_reviews/wave3_4_achievement_visual_language_icons_v1.md`
- `docs/_reviews/wave3_3_runner_text_zone_feedback_clarity_final_pass_v1.md`
- `docs/_reviews/wave3_2_first_week_commercial_proof_gap_lock_v1.md`
- `docs/_reviews/wave3_1_street_replay_how_we_got_here_v1.md`
- `docs/_reviews/wave3_0_review_pattern_coaching_lite_v1.md`
- `docs/_reviews/wave2_9_earned_rewards_achievement_hooks_v1.md`
- `docs/_reviews/wave2_8_sharky_soul_compact_coach_layer_v1.md`
- `docs/_reviews/wave2_6_premium_motion_interaction_feel_v1.md`

## 5. Motion/replay audit

### Street Replay / How we got here

- Observed state: `How we got here` opens a bottom sheet through `showModalBottomSheet`; the sheet renders structured street rows, source-owned decision context, source-owned key clue, and a `You are here` marker.
- Issue/opportunity/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

The bottom-sheet transition already provides a deterministic entry motion. Adding row stagger or animated reveal would not improve the static screenshot proof and would risk timing surface area without a concrete readability blocker.

### Animated replay readiness over Act0StreetReplayV1

- Observed state: `Act0StreetReplayV1` and `Act0StreetReplayStepV1` are ordered, deterministic, source-gated, and animation-ready.
- Issue/opportunity/no issue: deferred opportunity.
- Severity: P2 by route, not a current blocker.
- Decision: deferred.

Building a full replay renderer would require a new animation layer or playback state. That is explicitly out of scope for this wave.

### Practice launch / Review to Practice handoff

- Observed state: Review continuation shows the active repair card and a clear `Practice this spot` CTA. Practice active repair row already has press-scale motion from Wave 2.6.
- Issue/opportunity/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

CTA behavior and visibility are already clear in the Day 2 packet. No new route transition or CTA animation is justified.

### Repair result / Fix landed

- Observed state: repair result and proof feedback surfaces already use proof-owned reveal motion through `_ProofMotionRevealV1`.
- Issue/opportunity/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

The existing reveal supports payoff without introducing repair resolution, cleared/fixed-forever language, or confetti.

### Session Summary / Proof banked / earned moment

- Observed state: Session Summary proof hero and next-step card already use `_ProofMotionRevealV1`; earned proof is visually distinct and readable in the first-week packet.
- Issue/opportunity/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

Adding another reveal would duplicate Wave 2.6 and risk making the close noisier.

### Sharky line moments

- Observed state: compact Sharky presence exists where proof moments need emotional support; `Act0SharkyPresenceBubbleV1` already has its own restrained presence treatment.
- Issue/opportunity/no issue: no issue.
- Severity: not an issue.
- Decision: no action.

Mascot animation is explicitly out of scope unless trivial and non-noisy. No concrete gap was found.

## 6. Implementation summary if code changed

No product code changed.

No Dart files, tests, routes, progression state, telemetry, model contracts, assets, localization files, or screenshot tooling were modified.

## 7. Motion changes if any

None.

- Surface touched: none.
- Motion wrapper used: none added.
- Why it improves comprehension/payoff: no new motion was needed.
- Why deterministic: existing deterministic motion remains unchanged.
- Why not broad animation: no animation system, replay renderer, playback controls, or route transition system was added.

## 8. Street Replay preservation proof

Street Replay remains owned by `Act0StreetReplayV1` and `Act0StreetReplayStepV1`.

Preserved boundaries:

- no duplicate replay model;
- no full animated replay;
- no cards/chips/action cinematic playback;
- no playback controls;
- no scrubber;
- no replay state machine;
- `How we got here` remains source-gated by table street/action-trail evidence;
- `You are here` remains derived from `Act0StreetReplayStepV1.isCurrentStreet`.

Existing tests preserve:

- replay entry appears when source-owned street trail evidence exists;
- replay entry stays hidden without street trail evidence;
- sheet includes `Street by street` and `You are here`;
- hand-history/tracker/GTO/solver copy is absent;
- playback toggle is absent.

## 9. Screenshot determinism proof

No new rendering or timing behavior was introduced.

The required screenshot packets passed after audit:

- `day2_return compact`;
- `first_week compact`.

Because there was no implementation, no post-change rerun was needed beyond the already-required audit packets.

## 10. Primary decision UI proof

The primary decision UI remains unchanged.

Observed in the first-week packet:

- answer controls remain visible and dominant on decision screens;
- `How we got here` stays a compact contextual entry point, not a competing primary action;
- critical table, prompt, feedback, and CTA text remains visible.

No motion wrapper was added that could hide answer buttons or delay critical copy.

## 11. Claim-safety proof

No visible copy was introduced.

Existing inspected surfaces avoid:

- AI;
- GTO;
- solver;
- mastery;
- permanent leak fix;
- fixed forever;
- cleared;
- resolved;
- recovered;
- all-time analytics;
- rating;
- radar;
- Level / Lv proof;
- rank;
- premium/paywall value;
- guaranteed improvement;
- win-rate improvement;
- complete hand-history tracking;
- unsupported player tendency reads.

## 12. Boundary proof

This wave did not add:

- Modern Table visual redesign;
- full animated replay;
- playback controls or scrubber;
- cards/chips/action cinematic playback;
- route, progression, model, or telemetry changes;
- reward, Profile, value, localization, or store work;
- new dependencies;
- durable storage;
- queue resolution;
- Review clearing;
- broad motion system;
- global navigation transition redesign.

## 13. Tests and validation run

No focused Flutter tests were required because no product code changed.

Docs-only validation run:

- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 14. Screenshot proof run and result

Required audit-first screenshot proof passed:

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

No post-implementation screenshot rerun was required because there was no implementation.

## 15. Generated/untracked artifact status

Generated screenshot and Claude review outputs remain local-only and untracked:

- `output/screen_review/`
- `output/claude_review/`

They must not be committed.

## 16. Anti-theater proof

User-visible thing changed: nothing, by design.

Why no-code was correct:

- Wave 2.6 already added deterministic proof-owned reveal and CTA press motion.
- Wave 3.1 already made Street Replay structured, source-gated, and bottom-sheet based.
- Current packets show readable proof-loop and handoff surfaces.
- The only obvious extra motion candidate, Street Replay row stagger, would be decorative without a concrete comprehension blocker and would not be meaningfully proven by compact screenshot packets.

Final target requirement moved by this wave:

- Premium transition / replay motion is now audited against current screenshots and code seams, and no safe implementation gap remains for this bounded wave.

Evidence:

- current Day 2 and first-week packets;
- owner seam inspection;
- Wave 2.6 motion artifact;
- Wave 3.1 Street Replay artifact and focused tests.

Explicitly not built:

- full replay animation;
- row stagger/reveal;
- playback controls;
- route transition system;
- table animation;
- confetti/casino effects;
- new motion dependency.

This is not fake progress because the prompt explicitly required no-code closure when no concrete safe high-EV motion opportunity was found.

## 17. Expected TOP1 matrix movement

- Premium transition / replay motion: audit confidence increases; no implementation lift needed.
- Street context / how-we-got-here comprehension: preserved; existing source-gated bottom sheet remains the correct v1 surface.
- Session Summary payoff: preserved through existing Wave 2.6 reveal wrappers.
- First proof loop: preserved; no extra timing risk introduced.
- Premium visual feel: current motion is acceptable for this route stage; larger motion should not be added without a concrete blocker.
- Habit loop / return reason: unchanged in behavior, but route confidence improves because motion debt was audited and scoped.

## 18. Caveats

- This was not a video-based motion QA pass; the required packet system produces static screenshot proof.
- Street Replay sheet is tested through widget tests and source inspection rather than an always-open compact screenshot.
- If future external review identifies a specific P1 motion comprehension issue, it should be fixed as one bounded follow-up using the existing `Act0StreetReplayV1` contract.

## 19. Next recommendation

Proceed to Wave 3.6 - Profile Identity & Progress Proof v1.

No bounded P1 fix is needed before Wave 3.6.
