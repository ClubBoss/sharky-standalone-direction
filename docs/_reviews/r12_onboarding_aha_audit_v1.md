# R12 Onboarding + Aha Audit v1

## Summary of shipped scope (R12)
- Intro overlays priority and persisted keys were unified:
  - `global_training_intro_seen_v1`
  - `world1_intro_seen_v1`
  - `world2_handoff_seen_v1`
  - `world2_intro_seen_v1`
  - `cash_track_intro_seen_v1`, `tournament_track_intro_seen_v1`, `mixed_track_intro_seen_v1`
- Priority order is deterministic:
  - global intro -> world1 intro -> world2 handoff -> world2 intro -> track intro
- Map-first entry surfaces were tightened for release-visible flow:
  - Drills tab hidden outside debug
  - Levels/modules entry hidden outside debug
  - map CTA remains dominant (`today_plan_start_cta` / `world_campaign_next_pack_cta`)
- First 5-minute flow was tightened:
  - current focused node tap starts runner immediately (no intermediate module menu for current node)
- Result screen was simplified to a single primary CTA path:
  - primary CTA: `session_result_next_module_cta`
  - visible close action: `session_result_close_x_cta`
  - leave confirm dialog keys:
    - `session_result_leave_confirm_dialog`
    - `session_result_leave_stay_cta`
    - `session_result_leave_confirm_cta`
  - details accordion keys:
    - `session_result_table_context_toggle_v1`
    - `session_result_table_context_panel_v1`

## First 5 minutes manual smoke checklist (R12)
1. Cold boot lands on map/home with one dominant training CTA.
2. Tapping `START NOW` opens a playable runner state directly.
3. Current highlighted node can be tapped to start immediately (no extra chooser).
4. No release-visible alternate launchers (modules/drills shortcuts) compete with map start.
5. One-time intro copy appears in deterministic priority and does not stack.
6. Overlays are non-blocking and do not introduce continue-gate friction.
7. World1 -> World2 handoff hint appears once and then stays suppressed.
8. Session result shows one dominant primary CTA and clear short status/why.
9. Close `[X]` opens leave confirmation; Stay returns to result; Leave returns to map.
10. Continue routing remains deterministic through world progression and track routing.

## Paywall conflict scan (audit-only)
Risk 1: Premium/trial previews can preempt the first-run flow and hide the dominant start path.
- Must verify before R13 RC cut: today-plan premium preview does not create dead-end loops and preserves one clear primary action.

Risk 2: Monetization prompts on result/map can compete with the single-CTA completion loop.
- Must verify before R13 RC cut: result screen primary continue remains dominant and premium prompts stay secondary.

Risk 3: Entitlement transitions can diverge map routing between free and paid users.
- Must verify before R13 RC cut: same deterministic no-dead-end route exists for both entitlement states.

## R12 conclusion
- R12 objective is met: onboarding and early-loop clarity improved with map-first, deterministic, low-friction UX.
