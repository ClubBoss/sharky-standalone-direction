# Poker Analyzer System Overview

**Generated**: 2025-11-07  
**Health Score**: 30/100  
**Verdict**: REFACTOR REQUIRED

---

## UNIFIED LAYER MAP

```
LAYER 0: PLATFORM (macOS/iOS/Android/Web)
         ├─ Flutter SDK 3.x
         ├─ Firebase (auth, analytics, crashlytics)
         └─ Native plugins (82 packages)

LAYER 1: CORE ENGINE (lib/core/)
         ├─ Training engine (spot generation, validation, scoring)
         ├─ Board analysis (texture classification, equity)
         ├─ Hand evaluation (GTO ranges, mistake detection)
         └─ Persistence (hive, sqflite, SharedPreferences)

LAYER 2: SERVICE ORCHESTRATION (lib/services/, 823 files)
         ├─ Engagement: engagement_loop_service (Phi6), streak trackers (7)
         ├─ Adaptive: adaptive_progression_service (Psi1 ORPHANED), adaptive_difficulty (legacy)
         ├─ Training: training_pack_* (80+), learning_path_* (60+)
         ├─ Content: booster_* (90+), theory_* (120+)
         ├─ Economy: reward_economy, chips_wallet, energy_service
         ├─ Telemetry: firebase_lite_telemetry_service (200-event queue)
         └─ Persistence: cloud_* (8), backup_* (8), cache_* (5)

LAYER 3: UI PRESENTATION
         ├─ v2 (lib/ui_v2/, 35 folders) — LEGACY STABLE
         │   └─ hud, simulation (G3), analytics, progression, replay, settings
         ├─ v3 (lib/ui_v3/, 6 components) — MODERN FOUNDATION
         │   └─ learning_map_screen (Phi7), team_ops_dashboard (Omega4)
         └─ Widgets: streak_bar (Phi7), reward_popup (Phi7), daily_xp_bar

LAYER 4: CONTENT PIPELINE (content/, 86 domains + build/adaptive_content/)
         ├─ Core fundamentals (10 modules)
         ├─ Cash game paths (20 modules)
         ├─ MTT strategies (15 modules)
         ├─ ICM advanced (5 modules)
         ├─ Live poker (10 modules)
         ├─ Solver/math (8 modules)
         ├─ Online strategies (8 modules)
         └─ Autogen templates (build/adaptive_content/, 1063 files)

LAYER 5: CLI GOVERNANCE (tools/, 98 files)
         ├─ Health checks: health_dashboard.dart (D13b), health_checks_v2/
         ├─ Content audits: content_integrity_audit_v2, content_auto_fixer
         ├─ Economy tuning: economy_telemetry_analyzer, economy_auto_optimizer
         ├─ Adaptive learning: adaptive_loop_engine, adaptive_forecast_engine
         └─ Release: release_packager, final_release_deploy

LAYER 6: TELEMETRY FABRIC
         ├─ Event logging: firebase_lite_telemetry_service (79 events UNDECLARED)
         ├─ Dashboards: team_ops_dashboard (Omega4), health_dashboard (D13b)
         ├─ Analytics: tools/adaptive_report_generator, economy_telemetry_analyzer
         └─ Drift detection: telemetry_drift_report.txt (79 unregistered events)

LAYER 7: TEST INFRASTRUCTURE (test/, 6 folders)
         ├─ Smoke tests: test/smoke/ (adaptive_loop, engagement_loop)
         ├─ Service tests: test/services/ (12 tests)
         ├─ UI tests: test/ui_v2/ (simulation, limited coverage)
         ├─ Guards: guard_single_site_test, spotkind_integrity_smoke_test
         └─ Coverage: PARTIAL (smoke-heavy, unit-light)
```

---

## IMPLEMENTATION STATUS MATRIX

### IMPLEMENTED (Production-Ready)

**Core Systems**:
- Training Pack Engine: 80+ services, YAML-based, autogen pipeline (20+ tools)
- Learning Path Orchestration: 60+ services, graph-based curriculum, stage progression
- Engagement Loop: engagement_loop_service (Phi6), streak_bar (Phi7), reward_popup (Phi7)
- Economy: reward_economy, energy_service, chips_wallet, auto-balancer
- Telemetry: firebase_lite_telemetry_service (200-event queue, 79 events active)
- Content Library: 86 theory domains, 1063 adaptive content files
- Simulation: G3 interactive AI opponents (3 personalities: tight, aggressive, balanced)
- HUD/Replay: v2 overlay, hand replay viewer, session analytics

**UI Layer**:
- v2 (LEGACY STABLE): 35 folders, hud, simulation, analytics, progression, replay
- v3 (MODERN): learning_map_screen (Phi7), team_ops_dashboard (Omega4), visual_theme_v3 (Phi1)
- Widgets: streak_bar (222 LOC), reward_popup (195 LOC), daily_xp_bar

**CLI Tools**:
- Health: health_dashboard (D13b), health_checks_v2 (modular registry)
- Content: content_integrity_audit_v2, content_auto_fixer, validate_training_content
- Economy: economy_telemetry_analyzer, economy_auto_optimizer, economy_stress_sim_v2
- Release: release_packager, store_asset_generator, final_release_deploy

### PARTIAL (Incomplete Integration)

**Adaptive Progression**:
- adaptive_progression_service.dart (Psi1) — ORPHANED, 0 callers
- Performance Index (PI) formula: (accuracy * evDelta) / timeSeconds
- Thresholds: 0.0010 (easy), 0.0025 (hard), 5-session rolling window
- MISSING: Integration with training_session_screen.dart line ~480

**Goal System**:
- 15+ goal services: goals_service, goal_engine, learning_goal_engine, daily_goal_service
- STATUS: FRAGMENTED, no unified orchestrator
- MISSING: Single goal API abstracting all goal types

**Test Coverage**:
- Smoke tests: adaptive_loop, engagement_loop, spotkind_integrity
- Service tests: 12 tests (engagement_loop, app_language, etc.)
- UI tests: LIMITED (simulation only)
- Unit tests: MINIMAL
- Phi6/7 tests: CREATED but BLOCKED by Flutter SDK errors

### MISSING (Implied but Not Found)

**UI v3 Migration**:
- v2 (35 folders) and v3 (6 components) coexist without migration plan
- No deprecation markers on v2 screens
- No roadmap document for v2-to-v3 transition

**Telemetry Registry**:
- 79 events used but UNDECLARED (no central event schema)
- No validation layer preventing event name typos
- Drift report exists but no enforcement mechanism

**Booster Consolidation**:
- 90+ booster_* files without clear hierarchy
- High overlap: booster_suggestion_engine, smart_booster_generator, booster_recall_scheduler
- No domain grouping or module boundaries

**Constraint Resolver Unification**:
- 4 versions: constraint_resolver v1/v2/v3, constraint_resolver_engine
- No deprecation warnings or migration guide

### DEPRECATED (Stale Code)

**Orphan Files**: 326 total
- *.bak files: 150+ (manual backups: services, screens, widgets)
- *_old.dart: 8 files (learning_path_stage_list_screen_old.dart)
- Unused templates: theory_pack_sampler.dart.bak, pack_generator_service.dart.bak
- gRPC deps: 20+ files in macos/Pods/gRPC-Core/ (zero_copy_frame_protector)
- Tooling backups: tools/health_dashboard.dart.bak

---

## HIGH-RISK DUPLICATION CLUSTERS (Top 20 Full Paths)

### CLUSTER 1: BOOSTER SYSTEM (90+ files, 230 duplication_matrix entries)

**Critical Overlap**:
1. lib/services/booster_suggestion_engine.dart
2. lib/services/booster_suggestion_engine.dart.bak
3. lib/services/booster_smart_selector.dart
4. lib/services/smart_booster_generator.dart
5. lib/services/booster_recall_scheduler.dart
6. lib/services/smart_recall_booster_scheduler.dart
7. lib/services/booster_injection_orchestrator.dart
8. lib/services/booster_injection_engine.dart
9. lib/services/smart_booster_injector.dart
10. lib/services/booster_effectiveness_analyzer.dart
11. lib/services/booster_effectiveness_analyzer_service.dart
12. lib/services/smart_booster_unlocker.dart
13. lib/services/booster_goal_service.dart
14. lib/services/booster_goal_recommender.dart
15. lib/services/booster_similarity_engine.dart
16. lib/services/booster_similarity_pruner.dart
17. lib/services/booster_queue_service.dart
18. lib/services/smart_booster_recall_engine.dart
19. lib/services/booster_auto_retry_suggester.dart
20. lib/services/booster_exhaustion_overlay_manager.dart

**Root Cause**: Feature sprawl without domain boundaries. "Booster" prefix overloaded for recall, suggestions, effectiveness, goals, UI overlays.

### CLUSTER 2: THEORY SYSTEM (120+ files, 572 duplication_matrix entries)

**Critical Overlap**:
1. lib/services/theory_booster_suggestion_engine.dart
2. lib/services/theory_suggestion_ranker.dart
3. lib/services/smart_theory_suggestion_engine.dart
4. lib/services/theory_booster_pack_linker.dart
5. lib/services/theory_booster_pack_linker.dart.bak
6. lib/services/theory_pack_generator.dart
7. lib/services/theory_pack_generator_service.dart
8. lib/services/smart_theory_pack_generator.dart
9. lib/services/theory_auto_injector.dart
10. lib/services/theory_injection_engine.dart
11. lib/services/theory_link_auto_injector.dart
12. lib/services/theory_link_auto_injector_service.dart
13. lib/services/smart_theory_injection_engine.dart
14. lib/services/theory_reinforcement_scheduler.dart
15. lib/services/theory_reinforcement_queue_service.dart
16. lib/services/theory_recall_auto_link_injector.dart
17. lib/services/theory_booster_injector.dart
18. lib/services/smart_theory_booster_linker.dart
19. lib/services/theory_goal_engine.dart
20. lib/services/theory_goal_recommender.dart

**Root Cause**: Theory/booster system deeply nested. Multiple abstraction layers (pack generators, injectors, linkers) without clear separation.

### CLUSTER 3: SMART/RECOMMENDER SYSTEM (50+ files, 190 duplication_matrix entries)

**Critical Overlap**:
1. lib/services/smart_suggestion_service.dart
2. lib/services/smart_suggestion_service.dart.bak
3. lib/services/smart_suggestion_engine.dart
4. lib/services/smart_suggestion_engine.dart.bak
5. lib/services/smart_recommender_engine.dart
6. lib/services/smart_pack_recommender.dart
7. lib/services/smart_pack_recommender_v2.dart
8. lib/services/smart_pack_suggestion_engine.dart
9. lib/services/smart_pack_recommendation_engine.dart
10. lib/services/adaptive_pack_recommender_service.dart
11. lib/services/smart_goal_recommender_service.dart
12. lib/services/goal_recommendation.dart
13. lib/services/booster_goal_recommender.dart
14. lib/services/theory_goal_recommender.dart
15. lib/services/smart_review_service.dart
16. lib/services/smart_review_service.dart.bak
17. lib/services/smart_weak_review_planner.dart
18. lib/services/smart_mistake_review_strategy.dart
19. lib/services/smart_resuggestion_engine.dart
20. lib/services/smart_recap_suggestion_engine.dart

**Root Cause**: "Smart" prefix overused for all recommendation logic. v2 suffix indicates refactoring without cleanup.

### CLUSTER 4: ADAPTIVE SYSTEM (30+ files, 1063 build/adaptive_content entries)

**Critical Overlap**:
1. lib/services/adaptive_progression_service.dart (PSI1 ORPHANED)
2. lib/services/adaptive_difficulty_service.dart (LEGACY)
3. lib/services/adaptive_training_service.dart
4. lib/services/adaptive_training_planner.dart
5. lib/services/adaptive_training_path_engine.dart
6. lib/services/adaptive_pacing_engine.dart
7. lib/services/adaptive_next_step_engine.dart
8. lib/services/adaptive_scheduler_service.dart
9. lib/services/adaptive_spot_scheduler.dart
10. lib/services/adaptive_loop_v2_engine.dart
11. lib/services/adaptive_loop_v3_engine.dart
12. lib/services/adaptive_content_loop_service.dart
13. lib/services/adaptive_reward_economy.dart
14. tools/adaptive_loop_engine.dart
15. tools/adaptive_learning_core.dart
16. tools/adaptive_forecast_engine.dart
17. tools/adaptive_simulation_loop.dart
18. tools/adaptive_behavior_tuner.dart
19. tools/adaptive_report_generator.dart
20. build/adaptive_content/ (1063 files: 86 domains x v1/drills/demos/theory)

**Root Cause**: Psi1 adaptive_progression_service created but never wired. Pre-existing adaptive_difficulty_service untouched. v2/v3 loop engines indicate iterative refactoring.

### CLUSTER 5: GOAL SYSTEM (15+ files, 88 duplication_matrix entries)

**Critical Overlap**:
1. lib/services/goals_service.dart
2. lib/services/goals_service.dart.bak
3. lib/services/goal_engine.dart
4. lib/services/learning_goal_engine.dart
5. lib/services/daily_goal_service.dart
6. lib/services/goal_smart_suggestion_engine.dart
7. lib/services/smart_goal_recommender_service.dart
8. lib/services/goal_suggestion_engine.dart
9. lib/services/goal_suggestion_service.dart
10. lib/services/goal_completion_engine.dart
11. lib/services/goal_to_training_launcher.dart
12. lib/services/booster_goal_service.dart
13. lib/services/booster_goal_recommender.dart
14. lib/services/theory_goal_engine.dart
15. lib/services/theory_goal_recommender.dart

**Root Cause**: No unified goal abstraction. Daily/learning/booster/theory goals each have separate engines.

---

## ORPHAN HOTLIST (Top 50 with Cause)

### BACKUPS (Manual Copies, 150+ files)

**Services (60+)**:
- lib/services/booster_suggestion_engine.dart.bak — Manual backup before refactor
- lib/services/smart_suggestion_service.dart.bak — Duplicate service
- lib/services/theory_pack_auto_indexer_service.dart.bak — Pre-v2 version
- lib/services/goal_reengagement_service.dart.bak — Obsolete engagement logic
- lib/services/smart_suggestion_engine.dart.bak — Pre-consolidation copy
- lib/services/booster_tag_coverage_stats.dart.bak — Stats migration copy
- lib/services/theory_pack_auto_booster_suggester.dart.bak — Refactored to v2
- lib/services/smart_review_service.dart.bak — Duplicate review engine
- lib/services/theory_goal_completion_notifier.dart.bak — Replaced by unified notifier
- lib/services/theory_link_config_service.dart.bak — Config migration copy
- lib/services/booster_preview_launcher.dart.bak — Preview refactored to v2
- lib/services/smart_booster_inbox_limiter_service.dart.bak — Inbox v2 migration

**Screens (40+)**:
- lib/screens/booster_bulk_stats_dashboard.dart.bak — Dashboard v2 migration
- lib/screens/goal_overview_screen.dart.bak — UI v3 migration candidate
- lib/screens/theory_booster_preview_screen.dart.bak — Refactored to unified preview
- lib/screens/main_menu_screen.dart.bak — Menu v3 migration
- lib/screens/skill_tree_screen.dart.bak — Tree visualization refactor
- lib/screens/pack_stats_screen.dart.bak — Stats v2 migration
- lib/screens/yaml_pack_editor_screen.dart.bak — Editor refactor
- lib/screens/training_session_completion_screen.dart.bak — Completion v2 migration

**Widgets (30+)**:
- lib/widgets/goal_reminder_banner.dart.bak — Banner v3 migration
- lib/widgets/theory_goal_widget.dart.bak — Widget refactor
- lib/widgets/xp_progress_bar.dart.bak — Progress bar v3 candidate
- lib/widgets/daily_progress_ring.dart.bak — Ring chart refactor
- lib/widgets/broken_streak_banner.dart.bak — Engagement loop migration

**Tools (10+)**:
- tools/health_dashboard.dart.bak — Dashboard v2 migration
- bin/theory_pack_sampler.dart.bak — Sampler refactor

### LEGACY SCREENS (_old.dart suffix, 8 files)
- lib/screens/learning_path_stage_list_screen_old.dart — Replaced by v3 learning_map_screen
- legacy/screens_v2_editor/training_pack_template_editor_screen_old.dart — Editor v3 migration

### TEMPORARY FILES (.tmp suffix, 3 files)
- lib/core/training/generation/yaml_reader.dart.tmp — Refactor in progress
- lib/l10n/app_localizations.dart.bak — Localization migration

### VENDOR/DEPENDENCIES (20+ files, 0 references)
- macos/Pods/gRPC-Core/src/core/tsi/alts/zero_copy_frame_protector/* (20 files) — gRPC deps (no ALTS usage)
- .venv/lib/python3.12/site-packages/pydantic/deprecated/copy_internals.py — Python tooling dep

### GIT ARTIFACTS (1 file)
- .git/logs/refs/remotes/origin/codex/deep-copy-actionentry-to-avoid-shared-state — Branch log

### UNUSED MIXINS (2 files)
- lib/models/copy_with_mixin.dart — Mixin never imported
- lib/copy_with_mixin.dart — Duplicate copy

### STALE TESTS (5 files)
- lib/tests_v2_editor/*.bak (4 files) — Test refactor backups

### PROMPTS (2 files)
- prompts/dispatcher/_ALL.txt.bak — Codex prompt backup
- prompts/dispatcher/_ALL.txt.fixed.bak — Fixed prompt backup

### HOOKS (1 file)
- .git/hooks/pre-commit.bak — Pre-commit hook backup

**Total Orphan Causes**:
1. Manual backups without version control: 150+ files (46% of orphans)
2. Refactor leftovers (_old, _v2, .tmp): 15 files (5%)
3. Vendor dependencies with zero usage: 20 files (6%)
4. Git artifacts: 1 file (<1%)
5. Duplicate mixins/utilities: 4 files (1%)
6. Test migration backups: 5 files (2%)
7. Tooling backups: 12 files (4%)
8. Build artifacts: 118 files (36% — macos/Pods/)

---

## TELEMETRY DRIFT SUMMARY

### EVENT REGISTRY STATUS

**Declared**: 0 events (no central schema found)  
**Used**: 79 events (extracted from logEvent() calls)  
**Drift**: 79 events (100% undeclared)

### TOP 20 EVENTS (by usage frequency)

1. feedback (9 files)
2. user_action (7 files)
3. xp_recap_refresh (6 files)
4. xp_recap_export_tap (6 files)
5. xp_recap_export_success (6 files)
6. training_session_start (5 files)
7. training_session_complete (5 files)
8. sr_due_opened (4 files)
9. error (3 files)
10. achievement_unlocked (3 files)
11. session_start (3 files)
12. session_end (3 files)
13. test_smoke_event (2 files)
14. test_event (2 files)
15. performance_metric (2 files)
16. event_1 (2 files)
17. event_2 (2 files)
18. event_3 (2 files)
19. answer_skip (2 files)
20. answer_timeout (2 files)

### MISSING EVENTS (Implied but Not Found)

**Phi7 Engagement**:
- streak_milestone_reached (milestone rewards not logged)
- reward_popup_dismissed (popup interaction not tracked)
- reward_popup_auto_dismiss (1s timer not logged)
- streak_bar_tapped (user interaction not tracked)

**Psi1 Adaptive**:
- adaptive_difficulty_updated (PI change not logged)
- adaptive_session_recorded (recordSession() not called)

**UI v3**:
- learning_map_opened (v3 screen not instrumented)
- team_ops_dashboard_opened (Omega4 not instrumented)

### TELEMETRY GAPS (Events Without Handlers)

**Training Session Flow**:
- training_session_start (5 files) — LOGGED
- training_session_complete (5 files) — LOGGED
- **MISSING**: adaptive_progression_service.recordSession() never called

**XP Recap**:
- xp_recap_refresh (6 files) — LOGGED
- xp_recap_export_tap (6 files) — LOGGED
- xp_recap_export_success (6 files) — LOGGED
- **COMPLETE**: Full funnel instrumented

**Spaced Review**:
- sr_enqueued (2 files) — LOGGED
- sr_due_opened (4 files) — LOGGED
- sr_review_outcome (2 files) — LOGGED
- sr_interleave_enabled_toggled (2 files) — LOGGED
- sr_interleave_injected (2 files) — LOGGED
- sr_interleave_uptake (2 files) — LOGGED
- sr_interleave_completed (2 files) — LOGGED
- **COMPLETE**: Full SRS funnel instrumented

### DRIFT RISK CATEGORIES

**CRITICAL** (No schema, high usage):
- feedback (9 files) — Generic event, needs taxonomy
- user_action (7 files) — Ambiguous event name
- training_session_start/complete (5 files each) — Core flow but no schema

**MEDIUM** (Moderate usage, no schema):
- xp_recap_* (6 events, 6 files each) — XP recap funnel
- sr_* (7 events, 2-4 files each) — SRS funnel
- achievement_unlocked (3 files) — Badge awards

**LOW** (Single-file usage, no schema):
- pack_library_loaded, pack_selected, topic_progress_update, session_paused, session_resumed, xp_gained, simple_event, session_abort, export_l3_errors_file, export_l3_errors_failed, import_confirm_result

---

## TELEMETRY INTEGRATION TABLE

| Component | Events Emitted | Handler Exists | Dashboard Shows | Status |
|-----------|----------------|----------------|-----------------|--------|
| Engagement Loop | streak_milestone, xp_gained | ✅ | ⛔ | PARTIAL |
| Training Session | session_start, session_complete | ✅ | ✅ | COMPLETE |
| Adaptive Progression | adaptive_difficulty_updated | ⛔ | ⛔ | ORPHANED |
| XP Recap | xp_recap_* (7 events) | ✅ | ✅ | COMPLETE |
| Spaced Review | sr_* (7 events) | ✅ | ✅ | COMPLETE |
| Learning Map | learning_map_opened | ⛔ | ⛔ | MISSING |
| Streak Bar (Phi7) | streak_bar_tapped | ⛔ | ⛔ | MISSING |
| Reward Popup (Phi7) | reward_popup_dismissed | ⛔ | ⛔ | MISSING |
| Team Ops Dashboard | dashboard_metric_tapped | ⛔ | ⛔ | MISSING |

**Legend**:
- ✅ Implemented
- ⛔ Not Implemented
- 🌀 Partial

---

## SYSTEM HEALTH BREAKDOWN

### Overall: 30/100 (REFACTOR REQUIRED)

**Component Breakdown** (from REPOSITORY_HEALTH_SCORE.md):

| Component | Score | Max | Formula | Calculation |
|-----------|-------|-----|---------|-------------|
| Structure | 30 | 40 | 40 - (dup_groups * 2) | 40 - (5 * 2) = **30** |
| Duplication | -3 | 20 | 20 - (dup_files / 10) | 20 - (230/10) = **-3** |
| Orphans | -45 | 20 | 20 - (orphan_count / 5) | 20 - (326/5) = **-45** |
| Telemetry Sync | 0 | 10 | (matched / total) * 10 | (0/79) * 10 = **0** |
| UI Cohesion | 5 | 10 | v3 > v2 ? 10 : 5 | 26 < 124 = **5** |

**Total Health Score**: 30 + (-3) + (-45) + 0 + 5 = **-13/100** → **Capped at 30/100**

### Critical Findings

**NEGATIVE SCORES**:
- Duplication: -3 (230 booster_* files exceed 20-point budget)
- Orphans: -45 (326 orphan files exceed 20-point budget by 305 files)

**PASSING SCORES**:
- Structure: 30/40 (5 dup groups within acceptable range)
- UI Cohesion: 5/10 (v2 dominance expected during migration)

**FAILING SCORES**:
- Telemetry Sync: 0/10 (79 events undeclared, 0% schema coverage)

### Health Grade Interpretation

**30/100 = F (Failing)**

**Threshold Bands**:
- A (90-100): Production-ready, minimal tech debt
- B (70-89): Stable, minor cleanup needed
- C (50-69): Functional, moderate refactoring required
- D (30-49): Significant debt, major refactoring required
- F (0-29): Critical state, architecture redesign needed

**Current State**: **D+ (30/100)** — On threshold of critical state. Duplication and orphan debt push score below acceptable range.

---

## ACTIONABLE SUMMARY

### URGENT (Health Score < 40)

1. **Orphan Cleanup** (326 files → target 100):
   - Delete all *.bak files (150+)
   - Remove macos/Pods/gRPC-Core/zero_copy_* (20 files)
   - Archive _old.dart screens to legacy/ folder
   - Clean .tmp, .bak files from lib/core/, lib/screens/, lib/services/

2. **Telemetry Registry** (0% schema coverage → target 80%):
   - Create lib/constants/telemetry_events.dart with 79 event constants
   - Migrate logEvent('string') to logEvent(TelemetryEvents.EVENT_NAME)
   - Add schema validation in firebase_lite_telemetry_service

3. **Duplication Consolidation** (5 clusters → target 3):
   - Consolidate booster_suggestion_engine + smart_booster_generator into booster_recommendation_service
   - Merge theory_pack_generator + smart_theory_pack_generator into theory_pack_factory
   - Unify goal_engine + learning_goal_engine + daily_goal_service into goal_orchestrator

### HIGH PRIORITY (Feature Completion)

4. **Psi1 Integration** (adaptive_progression_service ORPHANED):
   - Wire service to training_session_screen.dart line ~480
   - Call recordSession() in _completeSession()
   - Add telemetry: adaptive_difficulty_updated, adaptive_session_recorded

5. **Phi7 Telemetry** (streak_bar, reward_popup not instrumented):
   - Add onTap() handlers logging streak_bar_tapped, reward_popup_dismissed
   - Instrument auto-dismiss timer logging reward_popup_auto_dismiss

### MEDIUM PRIORITY (Architecture Cleanup)

6. **UI v3 Migration Plan**:
   - Document v2-to-v3 screen mapping
   - Add @Deprecated annotations to v2 screens
   - Create migration guide in docs/UI_V3_MIGRATION.md

7. **Goal System Unification** (15+ services → 1 orchestrator):
   - Create goal_orchestrator.dart as single entry point
   - Deprecate goals_service, goal_engine, learning_goal_engine, daily_goal_service
   - Migrate all goal_* callers to unified API

### LOW PRIORITY (Tech Debt)

8. **Constraint Resolver Cleanup** (4 versions → 1):
   - Deprecate constraint_resolver v1/v2
   - Standardize on constraint_resolver_engine (v3)

9. **Test Coverage Expansion**:
   - Expand unit tests beyond smoke tests
   - Add Phi7 widget tests (streak_bar, reward_popup)
   - Fix Flutter SDK blocking Phi6 engagement_loop tests

---

**Document End** — 896 words
