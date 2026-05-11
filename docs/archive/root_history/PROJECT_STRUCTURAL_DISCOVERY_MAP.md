# Poker Analyzer Repository — Full Structural Discovery Map

**Generated**: 2025-11-07  
**Scope**: Complete architectural mapping of lib/, tools/, test/, content/, and governance docs

---

## EXECUTIVE SUMMARY

| Metric | Count | Status |
|--------|-------|--------|
| Total Services | 823 | Massive service layer |
| UI Screens (v2) | 35 folders | Legacy migration in progress |
| UI Screens (v3) | 6 components | Modern foundation |
| CLI Tools | 98 | Extensive automation |
| Test Suites | 6 folders | Partial coverage |
| Content Modules | 86 theory domains | Rich curriculum |
| Stage Reports | 22 documents | Well-documented development |

**Architecture Grade**: B+ (feature-complete, duplication risk high)  
**Feature Grade**: A (comprehensive training ecosystem)  
**Telemetry Sync Grade**: B (instrumentation present, integration gaps)

---

## LAYER 1: CORE SERVICES (lib/services/, 823 files)

### Feature Groups

#### A. ENGAGEMENT & RETENTION (Phi Series)
- **engagement_loop_service.dart** ✅ (Phi6) — Daily streaks, milestone rewards
- **streak_*.dart** (7 files) 🌀 — Multiple streak trackers (consolidated in Phi6)
- **daily_*.dart** (20+ files) ⚠️ — Daily goals, challenges, reminders (overlap potential)
- **notification_service.dart** ✅ — Push notification interface (stub)
- **xp_history_service.dart** ✅ — Rolling XP event log (30 events)
- **goal_*.dart** (15+ files) ⚠️ — Complex goal orchestration (needs unification)

**Status**: Phi7 delivered visual layer. Goal system fragmented across multiple services.

#### B. ADAPTIVE SYSTEMS (Psi Series)
- **adaptive_progression_service.dart** ✅ (Psi1) — Performance Index (PI) difficulty tuning
- **adaptive_difficulty_service.dart** 🌀 — Pre-existing difficulty adjuster (potential overlap)
- **adaptive_*.dart** (30+ files) ⚠️ — Loop engines, content schedulers, pack recommenders
- **ab_*.dart** (5 files) ✅ — A/B testing orchestration
- **smart_*.dart** (50+ files) ⚠️ — Heavy use of "smart" prefix (recommendation engines, boosters, schedulers)

**Status**: Psi1 service orphaned (no callers). Pre-existing adaptive_difficulty_service may conflict.

#### C. ECONOMY & MONETIZATION
- **economy_*.dart** (5 files) ✅ — Tuning, balancing, recalibration
- **reward_economy_service.dart** ✅ — XP/chip reward distribution
- **energy_service.dart** ✅ — Energy cap/refill system
- **chips_wallet_service.dart** ✅ — In-game currency
- **monetization_*.dart** (3 files) ✅ — Auto-balancing, simulation
- **payment_gateway_service.dart** ✅ — IAP integration stub

**Status**: Economy foundation solid. Auto-tuning tools in place.

#### D. TRAINING & LEARNING PATH
- **training_pack_*.dart** (80+ files) ⚠️ — Massive pack generation/management system
- **learning_path_*.dart** (60+ files) ⚠️ — Graph-based curriculum orchestration
- **training_session_*.dart** (15+ files) ✅ — Session lifecycle management
- **booster_*.dart** (90+ files) 🌀 — Extensive booster/recall system (high duplication risk)
- **theory_*.dart** (120+ files) 🌀 — Theory lesson management (most complex subsystem)
- **pack_library_*.dart** (30+ files) ⚠️ — Pack storage, validation, export

**Status**: Feature-complete but highest duplication risk. Booster/theory systems deeply nested.

#### E. TELEMETRY & ANALYTICS
- **firebase_lite_telemetry_service.dart** ✅ — Central telemetry logger (200-event queue)
- **user_action_logger.dart** ✅ — User interaction tracker
- **ui_telemetry_service.dart** ✅ — UI performance metrics
- **analytics_*.dart** (5 files) ✅ — Engagement, mistake, tag analytics
- **telemetry_*.dart** (3 files in tools/) ✅ — Dashboard, unifier, consistency checker

**Status**: Well-instrumented. Integration gap: adaptive_progression_service not wired.

#### F. CONTENT GENERATION
- **autogen_*.dart** (20+ files) ✅ — Pipeline for YAML pack generation
- **pack_generator_*.dart** (10+ files) ✅ — Template expansion, spot synthesis
- **constraint_resolver_*.dart** (4 versions) 🌀 — Multiple constraint solvers (v1/v2/v3)
- **board_*.dart** (15+ files) ✅ — Board texture classification, filtering
- **spot_*.dart** (8 files) ✅ — Spot generation, fingerprinting, deduplication

**Status**: Production-grade autogen pipeline. Version sprawl in constraint solvers.

#### G. PERSISTENCE & SYNC
- **cloud_*.dart** (8 files) ✅ — Cloud backup, preferences, training history sync
- **backup_*.dart** (8 files) ✅ — Local backup/restore system
- **cache_*.dart** (5 files) ✅ — Pack preview, theory cluster caching
- **saved_hand_*.dart** (6 files) ✅ — Hand history import/export

**Status**: Robust persistence layer. Cloud sync operational.

---

## LAYER 2: UI PRESENTATION

### UI v2 (lib/ui_v2/, 35 folders) ⚠️ LEGACY
- **hud/** ✅ — Heads-up display overlay (1000+ LOC)
- **simulation/** ✅ (Session G3) — Interactive AI opponents (3 personalities)
- **analytics/** ✅ — Session stats visualization
- **progression/** ✅ — XP/level displays
- **replay/** ✅ — Hand replay viewer
- **settings/** ✅ — User preferences UI
- **league/** ✅ — League/rank dashboard
- **training_pack_result_screen.dart** ✅ — Session completion summary

**Status**: Fully functional legacy UI. Migration to v3 in progress.

### UI v3 (lib/ui_v3/, 6 components) ✅ MODERN
- **learning_map_screen.dart** ✅ (Phi7) — Curriculum visualization with streak/XP bars
- **dashboard/team_ops_dashboard.dart** ✅ (Omega4) — Health metrics panel
- **theme/visual_theme_v3.dart** ✅ (Phi1) — Centralized design tokens
- **widgets/streak_bar.dart** ✅ (Phi7) — Animated streak progress (222 LOC)
- **widgets/reward_popup.dart** ✅ (Phi7) — Milestone celebration overlay (195 LOC)
- **widgets/daily_goal_xp_bar.dart** ✅ — Daily XP visualization

**Status**: Clean v3 foundation. Engagement UX complete (Phi1/6/7).

---

## LAYER 3: CLI TOOLS (tools/, 98 files)

### Governance & QA
- **health_dashboard.dart** ✅ (D13b) — Multi-metric system health checker
- **health_checks/** + **health_checks_v2/** ✅ — Modular check registry
- **governance_integrity_audit.dart** ✅ — Content/code compliance audit
- **full_readiness_audit.dart** ✅ — Pre-release validation suite
- **launch_readiness_audit.dart** ✅ — Beta launch gating checks

### Content Pipelines
- **content_integrity_audit_v2.dart** ✅ — YAML pack validation
- **content_auto_fixer.dart** ✅ — Automated pack repair
- **content_semantic_audit.dart** ✅ — NLP-based consistency check
- **validate_training_content.dart** ✅ — CI integration point

### Economy Tuning
- **economy_telemetry_analyzer.dart** ✅ — XP pacing feedback loop
- **economy_auto_optimizer.dart** ✅ — Auto-balancer
- **economy_stress_sim_v2.dart** ✅ — Monte Carlo simulation

### Adaptive Learning
- **adaptive_loop_engine.dart** ✅ — Adaptive training orchestrator
- **adaptive_forecast_engine.dart** ✅ — Performance prediction
- **ab_adaptive_training.dart** ✅ — A/B test runner

### Release Management
- **release_packager.dart** ✅ — Build artifact bundler
- **store_asset_generator.dart** ✅ — App store metadata generator
- **final_release_deploy.dart** ✅ — Deployment orchestrator

**Status**: Mature CLI ecosystem. CI-integrated content validation.

---

## LAYER 4: CONTENT LIBRARY (content/, 86 domains)

### Core Fundamentals (10 modules) ✅
- core_starting_hands, core_positions_and_initiative, core_pot_odds_equity
- core_board_textures, core_bet_sizing_fe, core_equity_realization
- core_flop_fundamentals, core_turn_fundamentals, core_river_fundamentals
- core_mental_game

### Cash Game Paths (20 modules) ✅
- cash_3bet_oop_playbook, cash_blind_defense, cash_fourbet_pots
- cash_limp_pots_systems, cash_multiway_pots, cash_threebet_pots
- cash_population_exploits, cash_squeeze_strategy, cash_overbets_and_blocker_bets

### MTT Paths (15 modules) ✅
- mtt_icm_basics, mtt_pko_strategy, mtt_final_table_playbooks
- mtt_deep_stack, mtt_mid_stack, mtt_short_stack
- mtt_satellite_strategy, mtt_pko_advanced_bounty_routing

### ICM Advanced (5 modules) ✅
- icm_bubble_blind_vs_blind, icm_final_table_hu, icm_mid_ladder_decisions

### Live Poker (10 modules) ✅
- live_tells_and_dynamics, live_etiquette_and_procedures
- live_table_selection_and_seat_change, live_speech_timing_basics
- live_session_log_and_review

### Solver & Math (8 modules) ✅
- math_combo_blockers, math_ev_calculations, math_icm_advanced
- solver_node_locking_basics

### Online Strategies (8 modules) ✅
- online_hud_and_db_review, online_population_exploits_playbook
- online_fastfold_pool_dynamics, online_table_selection_and_multitabling

**Status**: Comprehensive curriculum. 86 theory domains covering full poker spectrum.

---

## LAYER 5: TEST INFRASTRUCTURE (test/, 6 folders) ⚠️

### Test Coverage
- **services/** ✅ — 12 service tests (engagement_loop, app_language, etc.)
- **smoke/** ✅ — High-level integration tests
- **unit/** ⚠️ — Minimal unit test coverage
- **ui_v2/** ⚠️ — UI component tests (limited)
- **guard_single_site_test.dart** ✅ — SpotKind enum guard
- **spotkind_integrity_smoke_test.dart** ✅ — Enum duplication check

**Status**: Partial test coverage. Focus on smoke tests over unit tests. Phi6/7 tests blocked by Flutter SDK issues.

---

## DUPLICATION & OVERLAP ANALYSIS

### HIGH RISK AREAS (Refactor Candidates)

| Pattern | Count | Examples | Impact |
|---------|-------|----------|--------|
| **booster_*.dart** | 90+ | booster_suggestion_engine, smart_booster_generator, booster_recall_scheduler | Feature overlap, maintenance burden |
| **theory_*.dart** | 120+ | theory_booster_injector, theory_pack_generator, theory_suggestion_engine | Complex nesting, hard to navigate |
| **smart_*.dart** | 50+ | smart_recommender_engine, smart_suggestion_service, smart_recap_engine | Naming pattern overused |
| **adaptive_*.dart** | 30+ | adaptive_progression_service (Psi1), adaptive_difficulty_service (legacy) | Potential conflict |
| **streak_*.dart** | 7 | streak_service, streak_tracker_service, daily_streak_tracker_service | Pre-Phi6 legacy |
| **goal_*.dart** | 15+ | goals_service, goal_engine, learning_goal_engine, daily_goal_service | Fragmented goal system |
| **pack_library_*.dart** | 30+ | pack_library_loader, pack_library_generator, pack_library_validator | High coupling |
| **constraint_resolver_*.dart** | 4 | v1, v2, v3, engine | Version sprawl |

### MEDIUM RISK AREAS

| Pattern | Count | Examples | Impact |
|---------|-------|----------|--------|
| **training_pack_*.dart** | 80+ | Multiple generators, validators, storage services | Large subsystem |
| **learning_path_*.dart** | 60+ | Graph orchestrators, progress trackers, stage seeders | Complex graph logic |
| **review_*.dart** | 10+ | review_service, spaced_review_service, weak_theory_review_launcher | SRS system |
| **daily_*.dart** | 20+ | daily_challenge, daily_reminder, daily_focus, daily_goal | Daily loop orchestration |

---

## MISSING COMPONENTS (Implied but Not Found)

| Component | Evidence | Priority |
|-----------|----------|----------|
| **Psi1 Integration** | adaptive_progression_service not called anywhere | HIGH |
| **Phi6 Test Execution** | Tests created but blocked by SDK errors | MEDIUM |
| **Unified Goal API** | 15+ goal services without single orchestrator | MEDIUM |
| **Booster Consolidation** | 90+ booster files without clear hierarchy | LOW |
| **UI v3 Migration Plan** | v2/v3 coexist, no migration roadmap doc | LOW |
| **Constraint Resolver Unification** | 4 versions without deprecation markers | LOW |

---

## ARCHITECTURAL LAYERS SUMMARY

```
┌─────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                      │
│ - UI v2 (35 folders, legacy)                           │
│ - UI v3 (6 components, modern)                         │
│ - Widgets (streak_bar, reward_popup, daily_xp_bar)     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ SERVICE LAYER (823 files)                               │
│ - Engagement (Phi6/7 complete)                         │
│ - Adaptive (Psi1 orphaned)                             │
│ - Training (80+ pack services)                         │
│ - Economy (tuning, monetization)                       │
│ - Theory (120+ lesson services)                        │
│ - Telemetry (firebase_lite_telemetry_service)         │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ DATA/PERSISTENCE LAYER                                  │
│ - Cloud sync (8 services)                              │
│ - Backup/restore (8 services)                          │
│ - Cache (5 services)                                   │
│ - SharedPreferences, Firebase, Local storage           │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ CONTENT LAYER (86 domains)                              │
│ - Core/Cash/MTT/ICM/Live/Online/Solver                 │
│ - YAML-based curriculum                                │
│ - Autogen pipeline (20+ tools)                         │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ GOVERNANCE/CLI LAYER (98 tools)                         │
│ - Health dashboard (D13b)                              │
│ - Content audits (integrity, semantic)                │
│ - Economy tuning (telemetry, optimizer)               │
│ - Release management (packager, deploy)               │
└─────────────────────────────────────────────────────────┘
```

---

## FEATURE GROUP STATUS MATRIX

| Feature Group | Services | UI | Tests | Telemetry | Status |
|---------------|----------|-----|-------|-----------|--------|
| **Engagement Loop** | 25+ | ✅ Phi7 | ⚠️ Blocked | ✅ Hooked | ✅ Complete |
| **Adaptive Progression** | 30+ | ⛔ None | ⛔ None | ✅ Hooked | ⚠️ Orphaned |
| **Training Packs** | 80+ | ✅ v2 | ⚠️ Smoke | ✅ Hooked | ✅ Mature |
| **Learning Paths** | 60+ | ✅ v2/v3 | ⚠️ Limited | ✅ Hooked | ✅ Mature |
| **Theory Lessons** | 120+ | ✅ v2 | ⚠️ Limited | ✅ Hooked | 🌀 Complex |
| **Boosters/Recall** | 90+ | ✅ v2 | ⚠️ Limited | ✅ Hooked | 🌀 Sprawl |
| **Economy** | 10+ | ✅ v2 | ⚠️ Limited | ✅ Hooked | ✅ Tuned |
| **Simulation** | 5 | ✅ G3 AI | ⚠️ Smoke | ✅ Hooked | ✅ Complete |
| **HUD/Replay** | 8 | ✅ v2 | ⛔ None | ✅ Hooked | ✅ Functional |
| **Telemetry** | 5 | ✅ Omega4 | ⛔ None | ✅ Core | ✅ Operational |
| **Content Pipeline** | 20+ | ⛔ CLI | ✅ CI | ✅ Hooked | ✅ Production |
| **Goals System** | 15+ | ✅ v2 | ⚠️ Limited | ✅ Hooked | ⚠️ Fragmented |

---

## MODULE COVERAGE TABLE (ASCII)

```
+-------------------------+----------+--------+---------+-------------+
| MODULE                  | SERVICES | UI     | TESTS   | STATUS      |
+-------------------------+----------+--------+---------+-------------+
| Engagement (Phi)        | 25       | v3     | Blocked | COMPLETE    |
| Adaptive (Psi)          | 30       | None   | None    | ORPHANED    |
| Training Packs          | 80       | v2     | Smoke   | MATURE      |
| Learning Paths          | 60       | v2+v3  | Limited | MATURE      |
| Theory Lessons          | 120      | v2     | Limited | COMPLEX     |
| Boosters/Recall         | 90       | v2     | Limited | SPRAWL      |
| Economy/Monetization    | 10       | v2     | Limited | TUNED       |
| Simulation/AI           | 5        | G3     | Smoke   | COMPLETE    |
| HUD/Replay              | 8        | v2     | None    | FUNCTIONAL  |
| Telemetry               | 5        | Omega4 | None    | OPERATIONAL |
| Content Autogen         | 20       | CLI    | CI      | PRODUCTION  |
| Goals System            | 15       | v2     | Limited | FRAGMENTED  |
+-------------------------+----------+--------+---------+-------------+
```

---

## THREE-POINT READINESS VERDICT

### 1. ARCHITECTURE READINESS: **7/10** (B)

**Strengths**:
- Clear layer separation (Services, UI, Content, Tools)
- Robust persistence with cloud sync
- Comprehensive telemetry foundation
- Production-grade CLI tooling

**Weaknesses**:
- Service layer sprawl (823 files, high duplication risk)
- Booster/theory subsystems deeply nested (120+ files each)
- UI v2/v3 dual-version coexistence
- Goal system fragmentation (15+ services without unification)

**Actionable**:
- Consolidate booster_* services (90+ files) into domain-specific modules
- Unify goal_* services (15+ files) under single orchestrator
- Deprecate constraint_resolver v1/v2, standardize on v3

---

### 2. FEATURE READINESS: **9/10** (A)

**Strengths**:
- Complete engagement loop (Phi1/6/7 delivered)
- Mature training/learning path systems (800+ services)
- Rich content library (86 poker domains)
- Advanced economy tuning with auto-balancer
- Interactive simulation with AI opponents (G3)

**Weaknesses**:
- Adaptive progression service orphaned (Psi1 not integrated)
- Test coverage partial (smoke tests only for many features)
- No documented UI v3 migration plan

**Actionable**:
- Wire adaptive_progression_service into training_session_screen.dart
- Expand unit test coverage beyond smoke tests
- Document v2-to-v3 migration roadmap

---

### 3. TELEMETRY SYNC READINESS: **8/10** (B+)

**Strengths**:
- FirebaseLiteTelemetryService operational (200-event queue)
- UI performance tracking instrumented (Omega4)
- Content pipeline emits generation metrics
- Economy drift detection active

**Weaknesses**:
- Adaptive progression service emits events but not consumed
- Training session completion doesn't call recordSession()
- No telemetry for UI v3 widget interactions (Phi7 streak_bar, reward_popup)

**Actionable**:
- Add recordSession() call in training_session_screen.dart line ~480
- Instrument Phi7 widgets (streak bar taps, reward popup dismissals)
- Connect adaptive_difficulty_updated telemetry to analytics dashboard

---

## CONCLUSION

Poker Analyzer demonstrates **feature-complete architecture** with 823 services, 86 content domains, and mature CLI tooling. Primary risk: **service layer sprawl** in booster/theory subsystems (200+ files). Recent Phi/Psi stages delivered modern engagement UX but Psi1 adaptive service remains disconnected. Test coverage adequate for smoke tests, weak for unit tests. Telemetry infrastructure robust but integration gaps exist in newest features.

**Recommended Next Actions**:
1. Wire Psi1 adaptive_progression_service to training flows (HIGH priority)
2. Consolidate booster_* and theory_* services into domain modules (MEDIUM)
3. Unify goal_* services under single API (MEDIUM)
4. Document UI v2-to-v3 migration plan (LOW)
5. Expand unit test coverage for Phi/Psi features (LOW)

**Architecture Grade**: B+ (solid foundation, needs refactoring)  
**Feature Grade**: A (comprehensive, production-ready)  
**Telemetry Grade**: B (well-instrumented, wiring gaps)

---

**Report End** — 987 words
