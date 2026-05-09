# Changelog

## FOUNDATION – CLOSED (2025-11-07)
- Phase 1 Learning Effect: implemented and frozen under STOP rule; see `docs/phase1_learning_effect_stop_point.md`.
- Phase 2 Value/Aha: implemented and frozen under STOP rule; see `docs/phase2_value_aha_stop_point.md`.
- Phase 3 Engagement/Return Loop: implemented and frozen under STOP rule; see `docs/phase3_engagement_return_stop_point.md`.
- Foundation artifacts (Phase 1–3 runners, logging contracts, specs) must not be modified unless CI fails, a Tier-2 regression reopens the scope, or SSOT drift requires alignment (see `docs/phases_index.md`).

## [Unreleased]

### Stage 30B — Codebase Audit (Safe Mode) (2025-11-02)
- Create tools/codebase_audit.dart for safe, read-only codebase analysis.
- Implement --readonly mode (default): analysis only, no modifications to any files.
- Implement --preview mode: prints list of potential issues without taking action.
- Disable --apply mode: manual approval required for any file deletions (safety-first approach).
- Scan lib/** and tools/** for temporary files (*.bak, *.old, *_copy.dart patterns).
- Detect orphaned generated files (.g.dart, .freezed.dart without source files).
- Identify potential duplicate files based on naming patterns.
- Exclude critical paths from audit: lib/models, lib/services, lib/ui_v2, content/**, test/**, health_dashboard.dart.
- Integrate audit into Health Dashboard with _checkCodebaseAuditStatus() function.
- ASCII output line: "Codebase Audit: PASS (readonly ✓ • N issues)".
- JSON block: codebase_audit_status with issues count, readonly flag, and pass status.
- Zero files deleted by design; all detected issues require manual review and approval.
- Tool provides diagnostic information only; human judgment required for cleanup decisions.
- Foundation for future maintenance: clear visibility into codebase health without risk.

### Stage 30A — UI Design Handoff Layer Integration (2025-11-02)
- Create lib/ui_v2/theme/ directory structure for centralized design tokens.
- Add design_tokens.md: comprehensive ASCII-only design handoff guide for designers.
- Create ui_v2_brand_theme.dart: re-exports BrandTheme with documentation on spacing, radius, elevation.
- Create ui_v2_colors.dart: complete color palette reference with hex codes and usage examples.
- Create ui_v2_typography.dart: typography token reference with font sizes, weights, and Material theme mapping.
- Document all tokens: colors (primary/surfaces/text/semantic), spacing (8/16/24px), typography (h1/h3/body/label/caption).
- BrandTheme already integrated in buildThemeV2() via ThemeExtension pattern.
- Design tokens ready for external designers or future rebranding without touching business logic.
- Health Dashboard prints "UI Design Tokens: PASS (ready)" and includes design_tokens_status JSON block.
- Foundation for design system handoff: clear token hierarchy and usage guidelines.

### Stage 29A — UI Integration of Economy Layer (2025-11-02)
- Add energy (⚡) and chips (💰) indicators to ui_v2_progress_map_screen.dart AppBar.
- FutureBuilder widgets fetch real-time energy and chips balance from EnergyService and ChipsWalletService.
- Visual feedback: yellow/grey energy indicator based on availability, amber chips display.
- Integrate energy check in training_pack_play_screen.dart: call EnergyService.useEnergy() before session start.
- Show red Snackbar when energy insufficient; auto-return to previous screen if no energy.
- Create lib/screens/dev_menu/economy_section.dart: Economy Debug section for testing.
- Add "Refill Energy" and "Add 1000 Chips" buttons to Dev Menu for developer testing.
- Real-time status display with success/failure toast notifications.
- Economy layer now fully visible in UI V2 with clear feedback and dev tools.

### Stage 28 — Energy & Economy Foundation (2025-11-02)
- Create lib/services/energy_service.dart: manage player energy for training sessions.
- Implement max 5 energy with auto-refill (1 per 30 minutes); premium users get infinite energy bypass.
- Energy consumed before training starts; useEnergy() returns false when insufficient.
- Create lib/services/chips_wallet_service.dart: soft currency wallet with 100k demo limit.
- Methods: getBalance(), addChips(), spendChips(), hasChips() for reward/purchase flows.
- Create lib/services/adaptive_premium_triggers.dart: smart engagement rewards based on behavior.
- Three trigger rules: momentum≥0.9 → 24h trial, fatigue≥80 → +2 energy, streak≥5 → 5 chips.
- Cooldown system: 1 hour between trigger evaluations to prevent spam.
- Trial system: premium_trial_expiry stored in SharedPreferences, auto-expires after duration.
- Integrate into Health Dashboard: three new JSON blocks (energy_status, chips_status, adaptive_triggers_status).
- ASCII output: "Energy System: PASS (5 / 5 ⚡)", "Chips Wallet: PASS (balance = 0)", "Adaptive Triggers: PASS (no active trial)".

### Stage 27 — UI V2 Polish & Beta Demo Preparation (2025-11-02)
- Create lib/ui_v2/ui_v2_progress_map_screen.dart: Progress Map showing training packs in adaptive grid.
- Display packs with premium/completed/current badges; adaptive column count by screen width.
- Create lib/ui_v2/ui_v2_premium_hub.dart: Premium Hub with status display and upgrade button.
- Integrate both screens into Dev Menu via ui_v2_section.dart for easy access.
- Add "UI V2 Demo: PASS (render OK)" line to Health Dashboard.
- Health Dashboard checks for ui_metrics.json or file presence to verify UI V2 render status.
- Premium packs locked behind premium check with upgrade prompt snackbar.
- Navigation flow: Progress Map → Training Pack Play or Premium Hub.

### Stage 24 — Premium Tier & Monetization Layer (2025-11-02)
- Create PremiumService for managing premium subscription status with SharedPreferences persistence.
- Add enablePremium() and disablePremium() methods for toggling premium mode (manual for now).
- Add isPremiumActive() to check current premium status across app sessions.
- Add getPremiumStatus() for health dashboard integration returning active flag and pass status.
- Extend LeaderboardService with getPremiumLeaderboard() method filtering top premium players.
- Premium leaderboard uses mock data (top 3 players considered premium for demonstration).
- Health Dashboard prints "Premium Mode: ON/OFF (pass ✓)" and includes premium_status JSON block.
- Premium flag persists between app restarts via SharedPreferences (key: premium_is_active).
- Foundation for monetization without requiring payment SDK integration yet (IAP/Stripe deferred to Stage 25).
- Premium status affects leaderboard visibility and prepares for premium-only content features.
- Dev Menu can toggle premium mode for testing (UI implementation in future stage).
- Clear separation: premium service handles state, payment verification comes later.
- ASCII-only output; ≤3 files changed; no new required dependencies; analyzer and tests remain green.

### Stage 23 — Social & Leaderboards Layer (2025-11-02)
- Extend LeaderboardService with Stage 23 competitive ranking features.
- Add getLeaderboardStatus() method for health dashboard integration.
- Add submitProfileScore() for submitting player rankings (profileId, nickname, XP, level, achievements).
- Add getTopEntries(limit) to fetch top N leaderboard entries.
- Support local leaderboard with mock data (10 top players with ranks, nicknames, XP, levels).
- Implement ranking algorithm: XP (primary) → Achievement count (tiebreaker) → Profile age (final tiebreaker).
- Health Dashboard prints "Leaderboards: PASS (top N, synced✗/cached✓)" and includes leaderboard_status JSON block.
- Leaderboard UI shows current user highlighted in rankings with rank badge.
- Prepare for optional Firebase/Firestore integration (leaderboards/global collection).
- Mock data provides immediate competitive context without backend dependency.
- ASCII-only output; no new required dependencies; analyzer and tests remain green.

### Stage 22 — User Profiles & Identity Layer (2025-11-02)
- Extend UserProfileService with multi-profile support for shared device usage.
- Add CRUD operations for user profiles: create, delete, switch between profiles.
- Each profile maintains separate identity with unique ID, nickname (ASCII-safe), and timestamps.
- Implement active profile tracking: getAllProfiles(), getActiveProfile(), setActiveProfile().
- Profile isolation: each user's XP, achievements, and adaptive history stored separately.
- Add profile count and status methods for health dashboard integration.
- Health Dashboard prints "User Profiles: PASS (n profiles, active: <name>)" and includes user_profiles_status JSON block.
- Support quick profile switching without app restart; cached profile updates immediately.
- Backward compatible: existing single-user profiles continue to work seamlessly.
- Profile nicknames are ASCII-safe (non-ASCII characters filtered out automatically).
- No new required dependencies; builds on existing SharedPreferences infrastructure.

### Stage 21 — Persistence & Cross-Device Sync (2025-11-02)
- Introduce PlayerSyncService for persistent storage of player progress across sessions and devices.
- Store player XP, achievements, and adaptive history (momentum, fatigue, adjustment factors) using SharedPreferences for local caching.
- Support optional Firebase/Firestore integration for cloud sync (graceful fallback if not configured).
- Implement non-blocking sync: always write to local immediately, attempt cloud sync in background.
- Track local and remote sync status independently; local-only mode fully functional.
- Add tools/player_sync_cli.dart CLI utility for manual sync, data export/import, and debugging.
- Health Dashboard prints "Player Sync: PASS (local✓ / remote✗)" and includes player_sync_status JSON block.
- Export/import functionality for backup and cross-device transfer via JSON files.
- No changes to existing adaptive runtime logic; purely additive persistence layer.
- No new required dependencies (Firebase optional); ASCII-only output; analyzer and tests remain green.

### Stage 20A — Adaptive Content Feedback Loop (2025-11-02)
- Introduce tools/adaptive_content_feedback.dart to create "self-learning" content system.
- Reads adaptive_learning_summary.json (performanceFactor) and adaptive_behavior_summary.json (adjustmentFactor).
- Applies deterministic corrections to difficulty_score and xp_reward in content JSONL files.
- Corrections bounded to ±25%: high performance increases difficulty, low performance decreases it; adjustmentFactor scales XP.
- Writes modified content to build/adaptive_content_feedback/ (never modifies originals).
- Generates adaptive_content_feedback_report.json with Δdifficulty, ΔXP, count, and correction factors.
- Health Dashboard prints "Adaptive Content Feedback: PASS (Δdifficulty ±X%, ΔXP ±Y%)" and includes adaptive_content_feedback JSON block.
- Completes adaptive feedback loop: telemetry → analytics → runtime application → content adjustment → improved training data.
- No new dependencies; ASCII-only; analyzer and tests remain green.

### Stage 19D — Adaptive Planner Heuristics Upgrade (2025-11-02)
- Add three dynamic planner modes (Light, Balanced, Accelerated) to learning_path_planner_engine.dart based on fatigue and momentum thresholds:
  - Light mode (fatigue >= 80%): reduce stage count by 30% to prevent overload.
  - Accelerated mode (momentum >= 0.9): increase max stages to 10 for high-momentum players.
  - Balanced mode (neutral zone): maintain default 7 stages.
- Log adaptive_planner_mode telemetry event with mode, maxCount, baseline, delta, momentum, and fatigue on mode changes.
- Health Dashboard prints "Adaptive Planner Mode: PASS (mode, ±X% stages)" and includes adaptive_planner_mode JSON block.
- Tools-only changes to health_dashboard.dart; runtime changes to planner use deterministic thresholds and existing JSON artifacts.
- No new dependencies; ASCII-only; analyzer and tests remain green.

### Stage 19C — Runtime Adaptive Application Integration (2025-11-02)
- Implement AdaptiveRuntimeService to apply adjustmentFactor from behavior tuning to spot metadata at pack load time.
- Scale difficulty_score and xp_reward using adjustmentFactor; clamp difficulty [1..5] and ensure xp >= 1.
- Set meta flags adaptiveApplied and adaptive_adjustment on each spot; log runtime_adaptive_applied telemetry with deltas.
- Integrate learning momentum and fatigue into LearningPathPlannerEngine with adaptive maxCount (3–10 stages based on thresholds).
- Health Dashboard prints "Runtime Adaptive Application: PASS (Δdifficulty +X%, ΔXP +Y%)" and includes runtime_adaptive JSON block.
- Analyzer: PASS (0 issues); Flutter tests: PASS (92/92); CI gates: 4/4 PASS; no new dependencies; ASCII-only.

### Stage 19A — Adaptive Learning Core (Behavioral Feedback Engine) (2025-11-02)
- Introduce tools/adaptive_learning_core.dart to unify XP, Drift, and Difficulty feedback with real telemetry signals.
- Reads telemetry/*.jsonl, ui_metrics.json, and adaptive_loop_report.json; computes deterministic performanceFactor, learningMomentum, and fatiguePenalty.
- Exports adaptive_learning_summary.json for CI/Dev inspection.
- Health Dashboard prints "Adaptive Learning Core: PASS (momentum X.Y, fatigue Z%)" and includes the adaptive_learning_core JSON block.
- No runtime changes; tools-only, ASCII-only, deterministic logic. Analyzer/tests/CI gates remain green.

### Stage 19B — Adaptive Behavior Tuning (2025-11-02)
- Add tools/adaptive_behavior_tuner.dart to derive behaviorBias and adjustmentFactor from telemetry.
- Inputs: telemetry/*.jsonl and adaptive_learning_summary.json; detects mistake, hint_used, and quick_correct signals.
- Deterministic formula: adjustment = clamp(1 + bias × 0.25, 0.75, 1.25).
- Writes adaptive_behavior_summary.json and surfaces a compact block in the Health Dashboard.
- Health Dashboard prints "Adaptive Behavior Tuning: PASS (bias +X%, adjust Y%)" and includes adaptive_behavior_tuning JSON.
### Stage 18C — Content XP Integration & Difficulty Curves (2025-11-02)
- Require xp_reward for all JSONL spot lines; validator enforces presence (> 0) and aggregates coverage.
- Autofix: deterministically fills missing xp_reward (range 50–150) based on stable id-derived seed; ASCII-only, no randomness.
- Introduce difficulty_score derived from xp via formula: difficulty = clamp(log(xp_reward/50), 1..5), rounded to 2 decimals.
- Validator enforces difficulty_score in [1..5] and correlation with the formula; reports difficulty balance stats.
- Health Dashboard: adds "Content XP Coverage" section and "XP Difficulty Balance" line; JSON now includes xp_coverage and xp_difficulty blocks.
- Ran autofix across repository content; revalidated to PASS (299/299) with 100% XP coverage (1819/1819).


### Stage 18B — Player Progress Loop (2025-01-15)
- Add XpProgressService for tracking player XP, level, and achievements.
- XP auto-levels every 1000 XP with telemetry events (player_xp_gain, achievement_unlocked).
- Add Player Progress section to Dev Menu showing XP/Level in real-time.
- Health dashboard now includes playerProgress section in JSON output.
- Integrate with existing telemetry infrastructure for progress tracking.

### Stage 18A — UI V2 Production Default (2025-01-15)
- UI V2 is now the production default (useUiV2 = true).
- Apply Theme V2 globally via buildThemeV2() in main.dart.
- Dev Menu toggle renamed to "Disable UI V2 (Legacy Mode)" for clarity.
- Legacy mode remains available via SharedPreferences override.
- Remove stray test line from README and clarify screenshot alt text.
- Warn when `--weights` and `--weightsPreset` flags are used together and add precommit sanity hook.
- Add DecayHeatmapUISurface widget for visualizing memory decay.
- Remind to resume stale user goals via GoalReengagementBanner on main menu.
- Add DecayHeatmapScreen to review tag decay as a heatmap.
- Fix training resume dialog to load packs before showing confirmation.
- Remove unused spot storage field from app state.
- Add "Select All" toggle in the My Packs selection toolbar.
- Export Markdown summary from pack template preview.
- Add Import Starter Packs button to Template Library.
- Suggest next built-in pack from the same category when one is completed.
- Add hand analysis history with EV/ICM stats and filters.
- Track XP goal streaks via new GoalStreakTrackerService.
- Introduce XPLevelEngine for computing user level progression.
- Add TheoryPackPreviewScreen for theory-only training packs.
- Track consecutive days of theory reinforcement via TheoryStreakService.
- Expose recordToday method on TheoryStreakService and update MiniLessonScreen.
- Introduce TheoryBoosterSuggestionEngine for recommending lessons when recap tags underperform.
- Add TheoryReinforcementBannerController for soft theory reminders after recap failures.
- Persist full decay reinforcement history and expose TagDecayForecastService for spaced repetition analytics.
- Add DecayForecastEngine to predict future decay levels by tag.
- Introduce DecayForecastAlertService for upcoming critical decay warnings.
- Add DecayDashboardScreen to visualize memory health.
- Track days without critical decay via DecayStreakTrackerService.
- Show humanized goal labels on pack cards for quick tactical focus.

- Celebrate decay streak milestones with DecayMilestoneCelebrationService.
- Display theory cluster completion summary in TheoryPackPreviewScreen.

- Add river probe jam decision training pack template for facing jams over river probes.

- Stage 15A: Introduce runtime UI v2 toggle (Dev Menu) and gated navigation to new result screen; Health Dashboard reports UI v2 state.

- Stage 16B: Wire NavigationTelemetryObserver (behind UI v2 flag), add navigation metrics export (overall and per-route), and display "UI Navigation" in Health Dashboard.

- Stage 16C: Visual Consistency & Brand Pass for UI v2
	- Add brand tokens (primaryBrand, accentSuccess, accentWarning, neutralBg) and new typography (label 14sp, caption 12sp).
	- Create theme_v2 with ThemeExtension (BrandTheme) providing spacing, radius, elevation, and brandName; central ThemeData builder.
	- Refactor v2 components to use Theme.of(context) + BrandTheme spacing; unify radius (12px) and elevation (1–2dp); footer button pill style with primaryBrand.
	- Brand assets stub with logo/mascot paths; AppBar now shows brand icon + name.
	- Health Dashboard: add UI Consistency scan and line in output.

- Stage 17: UX QA & Release Candidate Prep
	- Add golden tests for UI v2 (test_v2/ui_v2_golden_test.dart) capturing 3 viewport sizes + isolated components.
	- Create UX QA scanner (tools/ux_qa_checklist.dart) detecting hardcoded strings, TODO markers, and missing context.mounted checks.
	- Integrate UX QA report into Health Dashboard (UX QA: PASS/FAIL line).
	- Add RC_METADATA.md with v2.0.0-RC1 changelog summary, validation status, and golden test references.

```
