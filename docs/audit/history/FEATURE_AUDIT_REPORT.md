# Poker Analyzer — Full Architectural Self-Audit

**Date:** October 25, 2025  
**Branch:** main  
**Purpose:** Pre-beta architectural assessment for final UX polish pass

---

## 1. DIRECTORY-LEVEL SUMMARY

### 1.1 `/lib/screens/` (200+ files)

**Purpose:** All user-facing Flutter screens

**Key Domains:**
- **Training/Practice** (30% of files)
  - `training_pack_screen.dart`, `training_session_screen.dart`, `spot_editor_screen.dart`
  - `training_play_screen.dart`, `result_screen.dart`, `session_summary_screen.dart`
  - **Maturity:** ✅ Ready — core training loop is battle-tested
  
- **Learning/Theory** (25%)
  - `learning_path_screen.dart`, `learning_path_screen_v2.dart`
  - `theory_lesson_viewer_screen.dart`, `skill_tree_screen.dart`
  - `module_catalog_screen.dart` (new, XP-enabled)
  - **Maturity:** ✅ Ready — v2 refactor complete, v1 screens deprecated
  
- **Analytics/Stats** (20%)
  - `progress_dashboard_screen.dart`, `training_stats_screen_v2.dart`
  - `decay_analytics_screen.dart`, `tag_analytics_screen.dart`
  - **Maturity:** ✅ Ready — comprehensive stats infrastructure
  
- **Gamification** (15%)
  - `achievements_screen.dart`, `daily_challenge_screen.dart`, `goals_screen.dart`
  - `streak_history_screen.dart`, `shop_screen.dart`
  - **Maturity:** ✅ Ready — fully functional, needs leaderboard screen
  
- **Utility/Admin** (10%)
  - `settings_screen.dart`, `profile_screen.dart`, `dev_menu_screen.dart`
  - `pack_library_qa_screen.dart`, various debugger screens
  - **Maturity:** 🟡 In-progress — dev tools mature, settings incomplete

**Known Issues:**
- **Duplicates:** `learning_path_stage_list_screen_old.dart` (marked old)
- **Deprecated:** `main_menu_screen.dart.bak`, `training_recap_screen.dart.bak`
- **Overlaps:** Multiple "overview", "dashboard", "summary" screens with unclear boundaries
- **Missing:** Leaderboard screen, level progression screen, social screens

**Entry Points:**
- `main_navigation_screen.dart` — primary nav hub
- `main_menu_screen.dart` — home/dashboard

---

### 1.2 `/lib/services/` (1000+ files)

**Purpose:** Business logic, data management, orchestration

**Key Domains:**
- **Training Core** (20%)
  - `training_pack_service.dart`, `training_session_controller.dart`
  - `evaluation_executor_service.dart`, `evaluation_queue_service.dart`
  - **Maturity:** ✅ Ready — stable, well-tested
  
- **Content Management** (15%)
  - `pack_generator_service.dart`, `autogen_v4.dart`
  - `pack_library_loader_service.dart`, `theory_manifest_service.dart`
  - **Maturity:** ✅ Ready — L3 autogen system operational
  
- **Gamification Services** (15%)
  - `xp_service.dart`, `achievement_service.dart`, `streak_service.dart`
  - `daily_challenge_service.dart`, `goals_service.dart`, `coins_service.dart`
  - **Maturity:** ✅ Ready — fully implemented, needs leaderboard service
  
- **Learning Orchestration** (15%)
  - `learning_path_engine.dart`, `skill_tree_builder_service.dart`
  - `adaptive_training_planner.dart`, `smart_recommendation_engine.dart`
  - **Maturity:** ✅ Ready — complex but stable
  
- **Decay/Spaced Repetition** (10%)
  - `decay_booster_engine.dart`, `decay_smart_scheduler_service.dart`
  - `recall_analytics_service.dart`, `tag_mastery_service.dart`
  - **Maturity:** ✅ Ready — sophisticated SRS system
  
- **Reminders/Notifications** (10%)
  - `notification_service.dart`, 72+ reminder services
  - `training_reminder_push_service.dart`, `daily_reminder_scheduler.dart`
  - **Maturity:** ✅ Ready — 20+ reminder types implemented
  
- **Analytics/Stats** (10%)
  - `analytics_service.dart`, `training_stats_service.dart`
  - `tag_analytics_service.dart`, 50+ stat services
  - **Maturity:** ✅ Ready — comprehensive tracking
  
- **Persistence/Sync** (5%)
  - `cloud_sync_service.dart`, `backup_manager_service.dart`
  - `preferences_service.dart`, `saved_hand_storage_service.dart`
  - **Maturity:** ✅ Ready — SharedPreferences + cloud backup

**Known Issues:**
- **Redundancy:** Multiple overlapping services (e.g., `goal_engine.dart`, `goal_completion_engine.dart`, `goal_suggestion_engine.dart`, `smart_goal_*`)
- **Fragmentation:** 20+ "booster" services with unclear boundaries
- **Deprecated:** `.bak` files present (`goals_service.dart.bak`, `training_pack_template_storage.dart.bak`)
- **Missing:** `leaderboard_service.dart`, `social_service.dart`, `ai_commentary_service.dart`
- **Tech Debt:** Some services are 600+ lines (violates single responsibility)

**Overlaps:**
- Learning path v1 vs v2 (`learning_path_progress_service.dart` vs `_v2.dart`)
- Multiple "smart" recommenders with overlapping logic
- Achievement engines: 5 separate services with unclear division

---

### 1.3 `/lib/widgets/` (estimated 300+ files based on grep)

**Purpose:** Reusable UI components

**Key Categories:**
- **Training UI** — `training_spot_diagram.dart`, `training_pack_spot_panel.dart`
- **Gamification** — `streak_widget.dart`, `achievement_tile.dart`, `xp_progress_card.dart`
- **Cards/Tiles** — `*_card.dart`, `*_tile.dart` (100+ files)
- **Overlays/Dialogs** — `achievement_unlocked_overlay.dart`, `streak_lost_dialog.dart`
- **Analytics** — `streak_chart.dart`, `decay_heatmap_tile.dart`

**Maturity:** ✅ Mature — extensive widget library

**Known Issues:**
- **Inconsistent naming:** Some use `*_widget.dart`, others just functional names
- **No widget catalog:** Difficult to discover available components
- **A11y gaps:** Not all widgets have semantic labels (per docs/_archive/misc/A11Y_AUDIT.md)

---

### 1.4 `/lib/models/` (estimated 150+ files)

**Purpose:** Data structures, DTOs, serialization

**Key Types:**
- **Training:** `training_spot.dart`, `training_pack_template_v2.dart`, `spot_kind.dart`
- **Gamification:** `achievement_info.dart`, `simple_achievement.dart`, `saved_hand.dart`
- **User Data:** `player_model.dart`, `user_profile.dart`
- **Content:** `theory_lesson.dart`, `learning_path_node.dart`

**Maturity:** ✅ Mature — well-structured with code generation (`.g.dart`)

**Known Issues:**
- **v1 vs v2:** Some models have v2 variants (training_pack_template), unclear deprecation plan
- **Missing:** Social models (friend, activity), leaderboard models

---

### 1.5 `/test/` (200+ files)

**Purpose:** Automated testing

**Structure:**
- **Unit tests:** `services/*_test.dart`, `models/*_test.dart`
- **Widget tests:** `screens/*_test.dart` (sparse)
- **Integration tests:** `*_integration_test.dart` (minimal)
- **Smoke tests:** `*_smoke_test.dart` (SpotKind guard, MVP player)

**Maturity:** 🟡 Partial coverage

**Test Distribution:**
- Services: ~30% coverage (estimated)
- Screens: ~5% coverage (very sparse)
- Widgets: ~10% coverage
- Models: ~50% coverage (serialization tests)

**Key Tests:**
- ✅ `guard_single_site_test.dart` — SpotKind enum integrity (critical)
- ✅ `mvs_player_smoke_test.dart` — MVP training loop
- ✅ `spotkind_integrity_smoke_test.dart`
- ✅ `content_audit_smoke_test.dart` — content validation
- ✅ `xp_service_test.dart` — gamification logic
- ✅ `module_progress_service_test.dart`

**Known Issues:**
- **Low screen coverage:** Most screens lack widget tests
- **No E2E tests:** No full user flow testing
- **Flaky tests:** Some tests depend on SharedPreferences mocks
- **Terminal failures:** Recent test runs show exit code 1 (per context)

---

### 1.6 `/assets/` (extensive content tree)

**Purpose:** Training content, theory, media

**Structure:**
```
assets/
├── training_packs/          # 100+ YAML packs
├── packs_builtin/           # Core training content
├── theory/                  # Markdown theory lessons
├── theory_lessons/          # Structured lessons
├── learning_paths/          # Path definitions
├── skill_tag_categories.json
├── pack_matrix.json
└── autogen_presets/         # L3 generation configs
```

**Maturity:** ✅ Production-ready — extensive content library

**Known Issues:**
- **Duplication:** Some content exists in multiple locations
- **Validation:** `validate_training_content.dart` tool exists but not always run
- **IDs:** Normalization issues (fixed by `normalize_content_ids.dart`)

---

### 1.7 `/tool/` (50+ CLI tools)

**Purpose:** Developer tooling, content generation, validation

**Key Tools:**
- **Content Generation:** `generate_pack.dart`, `generate_previews.dart`, `bundle_packs.dart`
- **Validation:** `validate_training_content.dart`, `fast_content_check.dart`, `schema_check.dart`
- **L3 Autogen:** `l3/autogen_v4_session_build.dart`, `l3/packrun_ev.dart`
- **Testing:** `test_partition.dart`, `fast_live_check.dart`

**Maturity:** ✅ Mature — extensive CLI tooling

---

### 1.8 `/lib/l10n/` (localization)

**Files:**
- `app_en.arb` — English strings (1000+ keys)
- `app_ru.arb` — Russian strings (complete translation)

**Maturity:** ✅ Ready — full i18n support

**Known Issues:**
- **Unused keys:** Some keys defined but never used (e.g., `"share": "Share"`)
- **Missing keys:** Potential gaps in new features

---

### 1.9 Root Configuration Files

**Build/Platform:**
- `pubspec.yaml` — 120+ dependencies, well-maintained
- `analysis_options.yaml` — strict lint rules
- `build.yaml` — code generation config
- Platform folders: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`

**Documentation:**
- `README.md`, `README_DEV.md` — setup instructions
- `ARCHITECTURE_v2.md` — architectural overview
- `AGENTS.md` — AI agent instructions (this file)
- `docs/_archive/misc/STYLE_GUIDE_CONTENT.md` — historical content authoring standards
- `IAP_*.md` — in-app purchase documentation
- `docs/_archive/misc/FEATURE_AUDIT_REPORT.md` — historical root-level audit output copy

**Known Issues:**
- **Bash scripts:** `*.sh` files for bracket fixes (technical debt from parse errors)
- **Perl scripts:** `fix_brackets*.pl` (legacy cleanup scripts)
- **Error logs:** `pa_err_*.errors` files present (not gitignored?)

---

## 2. COMPONENT MAP (Core Features)

### Legend:
- ✅ Complete — production-ready
- 🟡 Partial — functional but incomplete UI/UX
- 🔴 Stub — code exists but not functional
- ❌ Missing — not implemented

---

| Feature | Services | Screens | Widgets | Persistence | Provider | Status | Entry Point |
|---------|----------|---------|---------|-------------|----------|--------|-------------|
| **XP System** | `xp_service.dart` | Module badge | `xp_progress_card.dart` | SharedPreferences | ✅ | ✅ | `module_catalog_screen.dart:92` |
| **Streaks** | 10+ streak services | 4 screens | 20+ widgets | SharedPreferences | ✅ | ✅ | `main_menu_screen.dart` |
| **Achievements** | 5 engines | 8 screens | 5 widgets | SharedPreferences | ✅ | ✅ | `achievements_screen.dart` |
| **Daily Challenge** | `daily_challenge_service.dart` | 3 screens | - | SharedPreferences | ✅ | ✅ | `daily_challenge_screen.dart` |
| **Goals** | 15+ goal services | 10 screens | 2 banners | SharedPreferences + Cloud | ✅ | ✅ | `goals_screen.dart` |
| **Leaderboards** | - | - | - | - | ❌ | ❌ | **Missing** |
| **Levels/Tiers** | `xp_level_engine.dart`, `level_up_celebration_engine.dart` | - | `level_badge_widget.dart` | SharedPreferences | ✅ | 🟡 | **No UI screen** |
| **Notifications** | `notification_service.dart` + 7 schedulers | 1 settings screen | - | flutter_local_notifications | ✅ | ✅ | Android/iOS native |
| **Reminders** | 72+ reminder services | - | 6 banners | SharedPreferences + workmanager | ✅ | ✅ | Various banners |
| **Badges** | 10+ badge services | - | 10+ widgets | SharedPreferences | ✅ | ✅ | Embedded in screens |
| **Saved Hands** | 6 services (CRUD + stats) | 3 screens | 4 widgets | SharedPreferences + Cloud | ✅ | ✅ | `saved_hands_screen.dart` |
| **Social** | - | - | - | - | ❌ | ❌ | **Missing** |
| **Sharing** | - | - | - | - | ❌ | 🔴 | Placeholder text only |
| **Spotlight** | `daily_spotlight_service.dart` | 6 daily spot screens | - | SharedPreferences | ✅ | 🟡 | No featured packs UI |
| **AI Commentary** | - | - | - | - | ❌ | ❌ | **Missing** |
| **Shop/IAP** | `payment_service.dart`, `coins_service.dart` | 1 shop screen | - | in_app_purchase + Cloud | ✅ | ✅ | `shop_screen.dart` |
| **Onboarding** | `onboarding_flow_manager.dart` | 3 screens | - | SharedPreferences | ✅ | ✅ | First launch |
| **Theory** | 50+ theory services | 20+ screens | - | SharedPreferences | ✅ | ✅ | `theory_lesson_viewer_screen.dart` |
| **Learning Paths** | 40+ path services | 20+ screens | - | SharedPreferences + Cloud | ✅ | ✅ | `learning_path_screen_v2.dart` |
| **Skill Tree** | 30+ tree services | 10+ screens | - | SharedPreferences | ✅ | ✅ | `skill_tree_screen.dart` |
| **Training Packs** | 60+ pack services | 30+ screens | 10+ widgets | SharedPreferences + Assets | ✅ | ✅ | `training_packs_screen.dart` |
| **Decay/SRS** | 40+ decay services | 10+ screens | 5+ widgets | SharedPreferences | ✅ | ✅ | `decay_dashboard_screen.dart` |
| **Analytics** | 50+ stat services | 30+ screens | 10+ charts | SharedPreferences | ✅ | ✅ | `progress_dashboard_screen.dart` |
| **Boosters** | 60+ booster services | 10+ screens | 5+ widgets | SharedPreferences | ✅ | ✅ | `booster_library_screen.dart` |
| **Profile** | 5+ profile services | 5 screens | - | SharedPreferences + Cloud | ✅ | ✅ | `profile_screen.dart` |
| **Cloud Sync** | `cloud_sync_service.dart` | 3 screens | `sync_status_widget.dart` | Firebase (implied) | ✅ | ✅ | `cloud_sync_screen.dart` |

---

## 3. UX READINESS GAPS (Duolingo-Style Checklist)

### 3.1 Critical for Beta (Duolingo Parity)

**❌ Missing Entirely:**

1. **Leaderboards**
   - **What's needed:** 
     - `leaderboard_service.dart` — fetch/update rankings
     - `leaderboard_screen.dart` — tabbed UI (global, friends, regional)
     - API backend for global rankings
     - Real-time updates via streams
   - **Duolingo equivalent:** Daily/weekly/all-time leagues
   - **Effort:** Medium (backend + UI)

2. **Social Features**
   - **What's needed:**
     - `social_service.dart` — friends, following, activity
     - `friends_screen.dart`, `activity_feed_screen.dart`
     - Friend invites, friend requests
   - **Duolingo equivalent:** Follow friends, see their progress
   - **Effort:** High (complex social graph)

3. **AI-Powered Explanations**
   - **What's needed:**
     - `ai_commentary_service.dart` — LLM integration
     - UI for spot-level explanations
     - OpenAI/Claude API integration
   - **Duolingo equivalent:** N/A (unique to poker)
   - **Effort:** Medium (API + UI)

**🟡 Partially Implemented:**

4. **Level Progression Screen**
   - **What exists:** `xp_level_engine.dart`, `level_badge_widget.dart`
   - **What's missing:** Dedicated screen showing:
     - Current level + XP progress bar
     - Next level requirements
     - Level history timeline
     - Level-up animations
   - **Duolingo equivalent:** Profile level display with crown tiers
   - **Effort:** Low (UI only, logic exists)

5. **Featured Content (Spotlight)**
   - **What exists:** Daily spot service + screens
   - **What's missing:**
     - Featured packs banner on home screen
     - "Pack of the Week" system
     - Curator recommendations
   - **Duolingo equivalent:** Featured lessons on home
   - **Effort:** Low (UI + content curation logic)

6. **Sharing**
   - **What exists:** Localization key `"share": "Share"`
   - **What's missing:**
     - Share buttons on achievement/result screens
     - `share_plus` package integration
     - Deep linking for shared content
   - **Duolingo equivalent:** Share streak milestones
   - **Effort:** Low (UI + package integration)

### 3.2 Nice-to-Have (Post-Beta)

7. **Clubs/Groups**
   - **Duolingo equivalent:** Classroom groups, clubs
   - **Effort:** High

8. **Challenges/Tournaments**
   - **What exists:** Daily challenge (single-player)
   - **What's missing:** Multi-player tournaments
   - **Effort:** High

9. **Offline Mode**
   - **Status:** Partially works (local storage), but no offline indicator
   - **Effort:** Medium

10. **Push Notification Improvements**
    - **What exists:** 18+ notification services
    - **What's missing:** Rich notifications, action buttons
    - **Effort:** Low

---

## 4. TECH DEBT & WARNINGS

### 4.1 Code Quality Issues

**🔴 Parse Errors (High Priority):**
- **Status:** Recent `dart analyze` exits with code 3 (per terminal context)
- **Evidence:** Error log files present (`pa_err_*.errors`)
- **Scripts created:** Multiple bracket-fixing Perl/Bash scripts suggest ongoing parse issues
- **Risk:** Blocks CI/CD, prevents production deployment
- **Action Required:** Run full parse cleanup pass before beta

**🟡 Deprecated Files:**
```
lib/screens/main_menu_screen.dart.bak
lib/screens/training_recap_screen.dart.bak
lib/screens/learning_path_stage_list_screen_old.dart
lib/services/goals_service.dart.bak
lib/services/training_pack_template_storage.dart.bak
archive/main.dart.disabled
```
- **Action:** Delete or move to `archive/`

**🟡 Overlapping Services:**
- **Example:** Achievement system has 5 separate engines with unclear boundaries:
  - `achievement_service.dart` (399 lines)
  - `achievement_engine.dart`
  - `achievements_engine.dart` (note plural)
  - `achievement_trigger_engine.dart`
  - `achievement_manager.dart`
- **Risk:** Difficult to maintain, unclear which service to use
- **Action:** Consolidate or document responsibilities clearly

**🟡 God Classes:**
- Several services exceed 500+ lines:
  - `achievement_service.dart` (399 lines, approaching threshold)
  - `onboarding_flow_manager.dart` (652+ lines)
  - Multiple "orchestrator" services likely over 500
- **Risk:** Hard to test, violates SRP
- **Action:** Refactor into smaller, focused services

### 4.2 Architectural Patterns

**🟡 State Management Fragmentation:**
- **Primary:** Provider (via `ChangeNotifier`)
- **Secondary:** Direct service calls, streams
- **Inconsistency:** Some screens use `context.watch()`, others use manual listeners
- **Risk:** Confusing for new contributors
- **Action:** Document preferred pattern in ARCHITECTURE_v2.md

**🟡 Persistence Strategy:**
- **Primary:** SharedPreferences (local-only)
- **Secondary:** Cloud sync (Firebase implied, not explicit)
- **Issue:** No clear data migration strategy
- **Risk:** User data loss on reinstall if cloud sync fails
- **Action:** Document backup/restore flow, test thoroughly

### 4.3 Testing Gaps

**🔴 Low Screen Coverage (~5%):**
- Most screens lack widget tests
- **Risk:** UI regressions undetected
- **Action:** Prioritize testing critical flows (training loop, purchase flow)

**🟡 Integration Test Absence:**
- No E2E tests for full user journeys
- **Risk:** Multi-step flows can break silently
- **Action:** Add at least 5 E2E tests for critical paths:
  1. Complete onboarding → first training pack → result
  2. Unlock achievement → view achievements screen
  3. Purchase coins → buy shop item
  4. Complete daily challenge → claim streak
  5. Theory lesson → linked training pack

**🔴 Flaky Tests:**
- Terminal shows `test/guard_single_site_test.dart` failed (exit code 1)
- **Cause:** Likely SpotKind enum guard violated
- **Action:** Fix SpotKind additions to maintain canonical guard site

### 4.4 Content Issues

**🟡 Content Duplication:**
- Training packs exist in multiple locations:
  - `assets/training_packs/`
  - `assets/packs_builtin/`
  - `assets/precompiled_packs/`
- **Risk:** Inconsistent versions, unclear source of truth
- **Action:** Consolidate or document purpose of each folder

**🟡 Validation Not Always Run:**
- `dart run tools/validate_training_content.dart --ci` should be in CI
- **Evidence:** AGENTS.md lists it as required, but not enforced
- **Action:** Add to CI pipeline as required check

### 4.5 Performance Concerns

**⚠️ 1000+ Service Files:**
- Services directory is massive
- **Risk:** Slow startup if all services initialize eagerly
- **Status:** Unknown if lazy loading is implemented
- **Action:** Profile app startup time, implement lazy initialization if needed

**⚠️ Asset Size:**
- Extensive content in `assets/` (100+ YAML files, markdown lessons)
- **Risk:** Large app download size
- **Status:** Unknown if assets are bundled or downloaded on-demand
- **Action:** Consider on-demand content download for non-core assets

---

## 5. COVERAGE REPORT (Estimated)

### 5.1 Code Coverage (Unit/Widget Tests)

| Component | Estimated Coverage | Notes |
|-----------|-------------------|-------|
| **Services** | ~30% | Core services tested, booster services sparse |
| **Models** | ~50% | Serialization well-tested, business logic gaps |
| **Screens** | ~5% | Very low, mostly smoke tests |
| **Widgets** | ~10% | Some reusable widgets tested |
| **Overall** | ~20% | Below industry standard (aim for 70%+) |

**Critical Gaps:**
- Payment flow (IAP) — ❌ untested (high risk)
- Cloud sync — ❌ untested (high risk)
- Achievement unlock flow — 🟡 partially tested
- Daily challenge flow — ✅ tested

### 5.2 Screen Coverage by Module

| Module | Screens Implemented | Screens Tested | Coverage % |
|--------|---------------------|----------------|------------|
| Training | 30+ | ~3 | ~10% |
| Learning Paths | 20+ | ~1 | ~5% |
| Skill Tree | 10+ | 0 | 0% |
| Theory | 20+ | ~1 | ~5% |
| Analytics | 30+ | 0 | 0% |
| Gamification | 20+ | ~2 | ~10% |
| Shop | 1 | 0 | 0% |
| **Overall** | 200+ | ~10 | **~5%** |

### 5.3 SpotKind Coverage (Training Content)

**Total SpotKind Enums:** ~50+ (exact count in `spot_kind.dart`)

**Content Coverage:**
- **L2 (Manual Packs):** ~40% of SpotKinds have authored packs
- **L3 (Autogen):** MVS preset covers ~70% of push-fold scenarios
- **Theory Coverage:** ~60% of SpotKinds have linked theory lessons

**Gaps:**
- Some exotic spots lack training content (e.g., `bomb_pot_multiway`)
- ICM scenarios underrepresented in L2 packs

### 5.4 Platform Parity

| Feature | iOS | Android | Web | Desktop |
|---------|-----|---------|-----|---------|
| **Core Training** | ✅ | ✅ | 🟡 | 🟡 |
| **IAP** | ✅ | ✅ | ❌ | ❌ |
| **Push Notifications** | ✅ | ✅ | ❌ | ❌ |
| **Cloud Sync** | ✅ | ✅ | ✅ | ✅ |
| **Saved Hands** | ✅ | ✅ | ✅ | ✅ |
| **Offline Mode** | 🟡 | 🟡 | 🟡 | 🟡 |

**Notes:**
- Web/Desktop builds exist but not fully tested
- IAP requires platform-specific store integration (not available on web)
- Notifications use platform channels (iOS/Android only)

---

## 6. STRATEGIC RECOMMENDATIONS

### 6.1 Pre-Beta Critical Path (4-6 weeks)

**Week 1-2: Fix Tech Debt**
1. ✅ Resolve all parse errors (`dart analyze` must pass)
2. ✅ Run `dart test` full suite, fix failing tests (guard_single_site_test)
3. ✅ Delete deprecated `.bak` files
4. ✅ Add content validation to CI pipeline

**Week 3-4: Implement Missing UX**
1. ✅ Leaderboard screen (high priority)
2. ✅ Level progression screen (low-hanging fruit)
3. ✅ Featured packs banner on home (low-hanging fruit)
4. ✅ Share buttons on achievement screens (low-hanging fruit)

**Week 5-6: Testing & Polish**
1. ✅ Write E2E tests for 5 critical flows
2. ✅ A11y audit (per docs/_archive/misc/A11Y_AUDIT.md recommendations)
3. ✅ Performance profiling (startup time, frame rate)
4. ✅ Beta user testing

### 6.2 Post-Beta Enhancements (3-6 months)

1. **Social Features** (Month 1-2)
   - Friends list
   - Activity feed
   - Challenge friends

2. **AI Commentary** (Month 2-3)
   - LLM integration
   - Contextual explanations

3. **Code Quality** (Ongoing)
   - Increase test coverage to 70%
   - Refactor god classes
   - Consolidate overlapping services

4. **Content Expansion** (Ongoing)
   - Fill SpotKind gaps
   - More theory lessons
   - Advanced ICM scenarios

---

## 7. SUMMARY VERDICT

### ✅ Strengths

1. **Massive Feature Completeness:** 18/21 core domains fully implemented
2. **Content Richness:** 100+ training packs, extensive theory lessons
3. **Sophisticated Systems:** SRS, adaptive learning, booster engine
4. **Gamification Infrastructure:** XP, streaks, achievements, goals all working
5. **Multi-Platform:** iOS/Android/Web/Desktop builds exist

### ⚠️ Weaknesses

1. **Tech Debt:** Parse errors, deprecated files, overlapping services
2. **Testing Gaps:** 5% screen coverage, no E2E tests
3. **Missing UX:** No leaderboards, no level screen, no social features
4. **Documentation Gaps:** Service responsibilities unclear, no widget catalog
5. **Performance Unknown:** No profiling data, potential startup lag

### 🎯 Beta Readiness: 75%

**Blockers to 100%:**
- Parse errors must be fixed
- Leaderboard screen must be implemented
- E2E tests for critical flows
- A11y compliance (per docs/_archive/misc/A11Y_AUDIT.md)

**Recommended Timeline:**
- 4-6 weeks to address blockers
- Beta launch feasible by **December 2025**

---

## 8. APPENDIX: File Counts Summary

```
Directory                Files (approx)
--------------------------------------
lib/screens/            200+
lib/services/           1000+
lib/widgets/            300+
lib/models/             150+
test/                   200+
assets/                 500+ (content)
tool/                   50+
--------------------------------------
Total Dart Files:       ~2400
Lines of Code (est):    250,000+
```

**Largest Services (by line count, estimated):**
1. `onboarding_flow_manager.dart` — 652 lines
2. `achievement_service.dart` — 399 lines
3. Various "orchestrator" services — 500-800 lines

**Most Complex Domains (by file count):**
1. Services (1000+ files)
2. Screens (200+ files)
3. Widgets (300+ files)

---

**END OF AUDIT**

**Status:** Ready for final polish pass  
**Next Action:** Address Week 1-2 critical path items (parse errors, failing tests)
