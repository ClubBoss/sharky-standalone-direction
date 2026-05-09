# Personalization Surface Inventory

Scope: Read-only inventory of existing personalization mechanisms in the repo.
This document lists only what exists in code today and does not propose changes.

Legend for mechanism type:
[A] Rule-based
[B] Parameter-based
[C] Static but conditional

## Active in-app personalization surfaces

### Home: Next Action Hint (personalized routing hint)
Files: `lib/ui_v2/home/personalization_next_action_hint.dart`, `lib/personalization/personalization_next_action_router_v1.dart`
Trigger condition: Home screen builds the hint widget and loads the latest report and focus label.
Personalized output: Recommended next action label and CTA routing to phase1/phase2/phase3.
Signals used: `release/_reports/personalization_next_action.jsonl`, SharedPreferences key `lesson_focus_label_v1`, last accepted action keys.
User impact: Shows or hides the hint; routes user to a phase based on report or focus label.
Type: [A]

### Lesson Focus Bridge (leak detection and focus label)
Files: `lib/ui_v2/components/lesson_overlay_helpers.dart`, `lib/ui_v2/components/lesson_ai_personalization_v1.dart`
Trigger condition: Wrong answers during lesson steps; leak tracker threshold met.
Personalized output: Pattern/summary/nudge lines based on dominant leak key; focus label stored for next action hint.
Signals used: Per-step `errorClass`, correctness history, SharedPreferences key `lesson_focus_label_v1`.
User impact: Adjusts hint text and stores a focus label for future routing hint.
Type: [A]

### Learning Path Tag Skill Map (learning signal persistence)
Files: `lib/services/learning_path_personalization_service.dart`
Trigger condition: Session completion updates the tag skill map.
Personalized output: Tag skill values per user.
Signals used: SessionLog correct/mistake counts, pack tags and categories.
User impact: Enables downstream personalization (stage unlocks, XP multipliers).
Type: [B]

### Smart Stage Unlocks (reinforcement unlocks)
Files: `lib/services/smart_stage_unlock_service.dart`, `lib/screens/learning_path_screen_v2.dart`
Trigger condition: Learning path screen loads and evaluates weak tags.
Personalized output: Additional stage IDs unlocked ahead of default gate.
Signals used: Tag skill map from LearningPathPersonalizationService, stage tags, gatekeeper status.
User impact: Extra stages become available for weak tags within nearby sections.
Type: [A]

### XP Reward Personalization (tag-based XP multiplier)
Files: `lib/services/training_session_service.dart`
Trigger condition: Training session completion.
Personalized output: XP multiplier and per-tag XP based on skill map.
Signals used: Tag skill map from LearningPathPersonalizationService, template tags.
User impact: XP payout scales by weakest tags.
Type: [B]

### Adaptive Training Recommendations (pack list and adaptive pack)
Files: `lib/services/adaptive_training_service.dart`, `lib/screens/training_home_screen.dart`, `lib/screens/training_session_summary_screen.dart`, `lib/widgets/saved_hand_viewer_dialog.dart`
Trigger condition: Service refresh on data changes; home screen carousel load.
Personalized output: Recommended pack list and optional adaptive pack generation.
Signals used: XP level, progress forecast, saved hands, history records, mistakes, pack stats.
User impact: Recommended carousel content and adaptive pack suggestions.
Type: [A]

### Weak Spot Recommendation (position/type focus)
Files: `lib/services/weak_spot_recommendation_service.dart`, `lib/widgets/suggestion_card_weak_spots.dart`, `lib/screens/training_home_screen.dart`
Trigger condition: Progress updates or suggestion card load.
Personalized output: Weak position recommendation, weak training type, and generated weak-spot pack.
Signals used: Player progress accuracy/EV/ICM, hand history, training stats, recent history.
User impact: Suggests a focused training type or pack.
Type: [A]

### Recommendation Feed Cards (dashboard recommendations)
Files: `lib/services/recommendation_feed_engine.dart`, `lib/services/smart_pack_recommender.dart`, `lib/screens/learning_dashboard_screen.dart`
Trigger condition: Learning dashboard loads.
Personalized output: FeedRecommendationCard list (title, subtitle, CTA, packId).
Signals used: Training attempts, pack stats, training path, decay/weakness logic.
User impact: Shows personalized recommendations in dashboard feed.
Type: [A]

### Adaptive Pack Recommendations (next pack card and inbox)
Files: `lib/services/adaptive_pack_recommender_service.dart`, `lib/widgets/recommended_next_pack_card.dart`, `lib/services/adaptive_pack_inbox_notifier.dart`
Trigger condition: Card load or app resume for inbox notifier.
Personalized output: Top adaptive pack recommendation; inbox suggestion when score threshold met.
Signals used: Tag decay forecast, tag mastery, mistake tag history, pack stats, cooldown state.
User impact: Shows recommended next pack card or inbox item.
Type: [A]

### Adaptive Learning Flow Plan and Session Recommendation Banner
Files: `lib/services/adaptive_learning_flow_engine.dart`, `lib/services/training_session_recommender.dart`, `lib/widgets/training_recommender_banner.dart`, `lib/services/track_launch_orchestrator.dart`
Trigger condition: Banner load or track launch requests.
Personalized output: Recommended track or mistake replay pack selection.
Signals used: Session logs, tag mastery, weakness clusters, adaptive schedule, track play history.
User impact: Shows recommended next training action and launches it.
Type: [A]

### Learning Track Recommendations (Next Up widget)
Files: `lib/services/learning_track_recommendation_engine.dart`, `lib/widgets/next_up_widget.dart`
Trigger condition: Next Up widget load.
Personalized output: Recommended lesson tracks and reasons.
Signals used: Track mastery, completion metadata.
User impact: Suggested tracks with start CTA.
Type: [A]

### Learning Track Next Pack (track engine)
Files: `lib/services/learning_track_engine.dart`, `lib/screens/learning_dashboard_screen.dart`
Trigger condition: Learning dashboard load.
Personalized output: Next pack within unlocked track (nextUpPack).
Signals used: Pack accuracy stats, unlocked packs.
User impact: Suggested next pack in dashboard summary.
Type: [A]

### Node Recommendations (training path detail)
Files: `lib/services/node_recommendation_service.dart`, `lib/screens/training_path_node_detail_screen.dart`, `lib/widgets/node_recommendation_section_widget.dart`
Trigger condition: Training path node detail screen load.
Personalized output: Recommended prerequisite or sibling nodes.
Signals used: Node progress (completed/unlocked), prerequisites.
User impact: Shows suggested nodes to complete next.
Type: [A]

### Theory Booster Recommendation
Files: `lib/services/theory_booster_recommender.dart`, `lib/widgets/booster_recommendation_banner.dart`
Trigger condition: Booster banner created after a theory lesson.
Personalized output: Recommended booster pack and reason tag.
Signals used: Lesson tags, recent mistake tag history.
User impact: Suggests a booster pack to reinforce weak tags.
Type: [A]

### Personal Recommendation Tasks (tasks and pack list)
Files: `lib/services/personal_recommendation_service.dart`
Trigger condition: Updates on achievements, adaptive packs, weak spots, style forecast, progress forecast.
Personalized output: Task list and pack list.
Signals used: Achievements, adaptive recommendations, weak spot recommendation, player style forecast, progress forecast.
User impact: Provides personalized task list and pack ordering (via provider).
Type: [A]

### Adaptive Difficulty (AI opponent tuning)
Files: `lib/services/adaptive_difficulty_service.dart`, `lib/ui_v2/simulation/simulation_engine.dart`
Trigger condition: Simulation round start.
Personalized output: AI tuning multipliers for aggression/bluff/fold.
Signals used: Telemetry summaries from `tools/_reports/*` (generated locally; may be absent in repo, e.g. via `tools/telemetry_unifier.dart`) or `release/public_beta_v2/unified_telemetry_summary.json`, cached history.
User impact: Adjusts AI behavior difficulty.
Type: [B]

### Adaptive Progression (difficulty delta recommendation)
Files: `lib/services/adaptive_progression_service.dart`, `lib/screens/training_session_screen.dart`, `lib/ui_v2/simulation/simulation_table_screen.dart`
Trigger condition: Session summary calculation.
Personalized output: Difficulty delta recommendation and feedback signal.
Signals used: Session accuracy, EV delta, time spent.
User impact: Emits adaptive difficulty feedback and telemetry; used by UI surfaces that observe feedback notifier.
Type: [B]

### Adaptive Table Tuning (visual intensity)
Files: `lib/ui_v2/table_visualization_prototype.dart`, `lib/ui_v2/hud/ui_v2_hud_overlay.dart`
Trigger condition: HUD/table visualization loads.
Personalized output: Difficulty multiplier and repetition rate used for visual intensity and messaging.
Signals used: `adaptive_learning_summary.json` fields `difficultyMultiplier` and `topicRepetitionRate`.
User impact: Adjusts table visualization intensity and contextual HUD messages.
Type: [B]

### Emotion Adaptive Tone
Files: `lib/services/emotion_adaptive_engine.dart`, `lib/ui_v2/hud/ui_v2_hud_overlay.dart`, `lib/ui_v2/league/ui_v2_league_dashboard_screen.dart`, `lib/ui_v2/ui_v2_feedback_panel.dart`, `lib/ui_v2/ui_v2_session_analytics_screen.dart`
Trigger condition: Gameplay events or UI rendering requests tone.
Personalized output: Adaptive tone selection and reaction phrasing.
Signals used: Recorded events (momentum), optional sentiment/consistency inputs, `ux_feedback_metrics.json` cache.
User impact: Changes tone labels and feedback phrasing in UI surfaces.
Type: [A]

## Personalization mechanisms present but not wired in app flow (no call sites found in repo scan)

### Report-driven bundles and profile synthesis
Files:
- `lib/services/personalization_kernel_service.dart`
- `lib/services/persona_engine_service.dart`
- `lib/services/personalization_readiness_bridge_service.dart`
- `lib/services/player_profile_spec_service.dart`
Trigger condition: No in-repo call sites found; intended to read report files and build bundles.
Personalized output: Bundle JSON structures (visual adjustments, learning adjustments, persona tone, profile spec).
Signals used: `release/_reports/*.json` bundles listed in each service.
User impact: None observed in app code (services are not referenced).
Type: [B]

### Adaptive persona/context plumbing (placeholders)
Files:
- `lib/services/personalization_context.dart`
- `lib/services/personalization_hub.dart`
- `lib/services/persona_behavior_router.dart`
- `lib/services/difficulty_assist_router.dart`
- `lib/services/ai_adaptive_signal_pack.dart`
Trigger condition: No in-repo call sites found for hub/router/signal pack classes.
Personalized output: Context-derived placeholders (tone, difficulty hints, micro modifiers).
Signals used: PersonalizationContext values (decision speed, accuracy trend, error burst, style tag).
User impact: None observed in app code (placeholders return defaults or not referenced).
Type: [C]

### Adaptive pacing and content loop services (unreferenced)
Files:
- `lib/services/adaptive_pacing_engine.dart`
- `lib/services/adaptive_content_loop_service.dart`
- `lib/services/adaptive_drill_expansion_service.dart`
- `lib/services/adaptive_ab_loop_engine.dart`
Trigger condition: No in-repo call sites found.
Personalized output: Pace factors, adaptive module lists, or content expansion actions.
Signals used: Report files and/or cached telemetry as described in each service.
User impact: None observed in app code.
Type: [B]

## Notes
- This inventory is based on in-repo static inspection; no runtime behavior was changed.
- If a surface appears in UI but is gated by feature flags or missing report files, the code still constitutes an existing personalization mechanism.
