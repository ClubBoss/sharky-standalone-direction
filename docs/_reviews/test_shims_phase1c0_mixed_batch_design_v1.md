---
status: "EVIDENCE FREEZE. This artifact designs Phase 1C implementation batches only; it does not modify tests, production code, "
status_source: "derived"
baseline: "79104b41c78d"
generated_by: "docs_frontmatter_v1"
---

# Test Shims Phase 1C0 Mixed Batch Design v1

Status: EVIDENCE FREEZE. This artifact designs Phase 1C implementation batches only; it does not modify tests, production code, tooling, CI, content, routes, or `lib/testing/test_shims.dart`.

## Git Inputs

- Base branch: `main`
- Base HEAD: `79104b41c78dc80ca4ae30aaaa42acab85434d64`
- Branch: `codex/test-shims-phase1c0-mixed-batch-design-v1`

## Locked Current State

- Remaining shim importer files: `296`
- Remaining importer identity: frozen `mixed_consumer` set from Phase 0 after Phase 1A/1B removals.
- Direct-shadow consumers: `0`
- Unused importers: `0`
- Genuine-fake-only consumers: `0`

## A. Exact Per-Symbol Consumer Matrix

| Symbol | Consumer files | Exclusive consumers | Overlap consumers | Canonical equivalent | API divergence |
| --- | ---: | ---: | ---: | --- | --- |
| `ShareOptions` | 2 | 0 | 2 | `No confirmed canonical owner; likely product-specific share facade under share/export flow` | `semantic_owner_review_required` |
| `GameType` | 43 | 4 | 39 | `lib/models/game_type.dart` | `drop_in_import_only` |
| `TrainingType` | 131 | 31 | 100 | `lib/core/training/engine/training_type_engine.dart` | `minor_constructor_or_enum_adaptation` |
| `TrainingPackLevel` | 3 | 0 | 3 | `lib/models/v2/pack_ux_metadata.dart` | `minor_constructor_or_enum_adaptation` |
| `HeroPosition` | 54 | 7 | 47 | `lib/models/v2/hero_position.dart` | `drop_in_import_only` |
| `HeroPositionLabel` | 0 | 0 | 0 | `lib/models/v2/hero_position.dart / lib/utils/hero_position_ext.dart` | `drop_in_import_only` |
| `TrainingPackTemplateV2` | 69 | 0 | 69 | `lib/models/v2/training_pack_template_v2.dart` | `minor_constructor_or_enum_adaptation` |
| `TagGoalProgress` | 2 | 0 | 2 | `lib/models/tag_goal_progress.dart` | `fixture_rewrite_required` |
| `HandData` | 100 | 16 | 84 | `lib/models/v2/hand_data.dart` | `minor_constructor_or_enum_adaptation` |
| `isAutoReplayKind` | 5 | 5 | 0 | `lib/ui/session_player/spot_specs.dart` | `minor_constructor_or_enum_adaptation` |
| `TrainingSessionService` | 66 | 32 | 34 | `lib/services/training_session_service.dart` | `semantic_owner_review_required` |
| `AppColors` | 0 | 0 | 0 | `lib/theme/app_colors.dart` | `drop_in_import_only` |
| `MiniLessonLibraryService` | 66 | 45 | 21 | `lib/services/mini_lesson_library_service.dart` | `minor_constructor_or_enum_adaptation` |
| `PackLibraryService` | 13 | 2 | 11 | `lib/services/pack_library_service.dart` | `semantic_owner_review_required` |
| `RecallSuccessLoggerService` | 7 | 7 | 0 | `lib/services/recall_success_logger_service.dart` | `minor_constructor_or_enum_adaptation` |
| `SmartTheoryRecapDismissalMemory` | 4 | 1 | 3 | `lib/services/smart_theory_recap_dismissal_memory.dart` | `minor_constructor_or_enum_adaptation` |
| `AppLocalizations` | 2 | 1 | 1 | `lib/l10n/app_localizations.dart or lib/flutter_gen/gen_l10n/app_localizations.dart` | `semantic_owner_review_required` |

### Per-Symbol Consumer Files

#### `ShareOptions`
- Count: `2`
- Exclusive: `0`
- Overlap: `2`
- Canonical equivalent: `No confirmed canonical owner; likely product-specific share facade under share/export flow`
- API divergence: `semantic_owner_review_required` - No canonical production type was confirmed; representative file `test/widgets/export_csv_button_test.dart` passes `ShareOptions? sharePositionOrigin` through export/share seams.
- Consumer files:
  - `test/services/pack_export_service_test.dart`
  - `test/widgets/export_csv_button_test.dart`

#### `GameType`
- Count: `43`
- Exclusive: `4`
- Overlap: `39`
- Canonical equivalent: `lib/models/game_type.dart`
- API divergence: `drop_in_import_only` - Canonical enum has the same `tournament` and `cash` values; representative `test/services/training_pack_search_service_test.dart` can import canonical type.
- Consumer files:
  - `test/core/training/training_pack_exporter_v2_test.dart`
  - `test/missing_pack_resolver_test.dart`
  - `test/services/auto_recovery_trigger_service_test.dart`
  - `test/services/autogen_pack_error_classifier_service_test.dart`
  - `test/services/booster_injection_orchestrator_test.dart`
  - `test/services/booster_mistake_recorder_test.dart`
  - `test/services/booster_pack_changelog_generator_test.dart`
  - `test/services/booster_pack_launcher_test.dart`
  - `test/services/booster_pack_validator_service_test.dart`
  - `test/services/booster_preview_launcher_test.dart`
  - `test/services/booster_refiner_engine_test.dart`
  - `test/services/booster_session_tracker_test.dart`
  - `test/services/booster_suggestion_engine_test.dart`
  - `test/services/decay_booster_spot_injector_test.dart`
  - `test/services/learning_path_launcher_service_test.dart`
  - `test/services/learning_path_stage_launcher_test.dart`
  - `test/services/learning_plan_cache_test.dart`
  - `test/services/lesson_step_filter_engine_test.dart`
  - `test/services/mistake_drill_launcher_service_test.dart`
  - `test/services/pack_novelty_guard_service_test.dart`
  - `test/services/scheduled_training_launcher_test.dart`
  - `test/services/scheduled_training_queue_service_test.dart`
  - `test/services/skill_gap_booster_service_test.dart`
  - `test/services/skill_loss_feed_engine_test.dart`
  - `test/services/smart_recap_booster_launcher_test.dart`
  - `test/services/smart_recap_booster_linker_test.dart`
  - `test/services/smart_theory_booster_bridge_test.dart`
  - `test/services/targeted_pack_booster_engine_test.dart`
  - `test/services/theory_booster_launcher_test.dart`
  - `test/services/theory_booster_recommender_test.dart`
  - `test/services/theory_recall_evaluator_suggestions_test.dart`
  - `test/services/track_unlock_conditions_engine_test.dart`
  - `test/services/track_visibility_filter_engine_test.dart`
  - `test/services/training_pack_library_metadata_enricher_test.dart`
  - `test/services/training_pack_search_service_test.dart`
  - `test/services/training_pack_template_set_generator_test.dart`
  - `test/services/training_session_launcher_btn_cash_lesson_test.dart`
  - `test/services/training_session_launcher_intro_lesson_test.dart`
  - `test/spot_factory_level2_engine_test.dart`
  - `test/widgets/goal_reengagement_banner_test.dart`
  - `test/widgets/review_path_card_test.dart`
  - `test/widgets/template_play_button_test.dart`
  - `test/yaml_pack_auto_tag_engine_test.dart`

#### `TrainingType`
- Count: `131`
- Exclusive: `31`
- Overlap: `100`
- Canonical equivalent: `lib/core/training/engine/training_type_engine.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Shim values `generic/gto` do not exist canonically and canonical uses `pushFold/postflop/...`; representative `test/services/training_pack_search_service_test.dart` already uses canonical `TrainingType.postflop` while importing shim.
- Consumer files:
  - `test/booster_injection_engine_test.dart`
  - `test/booster_mistake_backlink_engine_test.dart`
  - `test/booster_smart_selector_test.dart`
  - `test/booster_thematic_tagger_test.dart`
  - `test/booster_theory_pack_linker_test.dart`
  - `test/booster_variation_injector_test.dart`
  - `test/core/training/training_pack_exporter_v2_test.dart`
  - `test/coverage_summary_test.dart`
  - `test/duplicates_only_filter_test.dart`
  - `test/e2e_adaptive_plan_injection_test.dart`
  - `test/e2e_concurrency_locking_test.dart`
  - `test/e2e_idempotent_retry_test.dart`
  - `test/e2e_path_hardening_rollback_test.dart`
  - `test/e2e_theory_injection_path_test.dart`
  - `test/intro_theory_pack_generator_test.dart`
  - `test/learning_path_auto_seeder_test.dart`
  - `test/learning_path_library_validator_test.dart`
  - `test/learning_path_template_validator_test.dart`
  - `test/level_tag_auto_assigner_test.dart`
  - `test/missing_only_filter_test.dart`
  - `test/missing_pack_resolver_test.dart`
  - `test/mistakes_only_quick_filter_test.dart`
  - `test/models/training_pack_template_v2_hand_group_tags_test.dart`
  - `test/pack_augmentation_engine_test.dart`
  - `test/pack_search_engine_test.dart`
  - `test/pack_search_index_service_test.dart`
  - `test/pack_similarity_engine_test.dart`
  - `test/pack_unlocking_rules_engine_test.dart`
  - `test/presenters/completed_session_history_presenter_test.dart`
  - `test/select_duplicates_test.dart`
  - `test/services/adaptive_learning_flow_engine_test.dart`
  - `test/services/adaptive_pack_inbox_notifier_test.dart`
  - `test/services/adaptive_plan_executor_budget_test.dart`
  - `test/services/adaptive_plan_executor_idempotency_test.dart`
  - `test/services/adaptive_training_path_engine_test.dart`
  - `test/services/auto_advance_pack_engine_test.dart`
  - `test/services/auto_recovery_trigger_service_test.dart`
  - `test/services/autogen_pack_error_classifier_service_test.dart`
  - `test/services/booster_injection_orchestrator_test.dart`
  - `test/services/booster_mistake_recorder_test.dart`
  - `test/services/booster_pack_changelog_generator_test.dart`
  - `test/services/booster_pack_launcher_test.dart`
  - `test/services/booster_pack_validator_service_test.dart`
  - `test/services/booster_preview_launcher_test.dart`
  - `test/services/booster_refiner_engine_test.dart`
  - `test/services/booster_session_tracker_test.dart`
  - `test/services/booster_suggestion_engine_test.dart`
  - `test/services/completed_session_summary_service_test.dart`
  - `test/services/completed_training_pack_registry_test.dart`
  - `test/services/decay_booster_spot_injector_test.dart`
  - `test/services/deduplication_policy_engine_test.dart`
  - `test/services/dynamic_track_builder_test.dart`
  - `test/services/inline_theory_linker_pack_test.dart`
  - `test/services/learning_path_booster_engine_test.dart`
  - `test/services/learning_path_entry_group_builder_test.dart`
  - `test/services/learning_path_launcher_service_test.dart`
  - `test/services/learning_path_progress_tracker_tag_test.dart`
  - `test/services/learning_path_stage_launcher_test.dart`
  - `test/services/learning_plan_cache_test.dart`
  - `test/services/learning_track_engine_test.dart`
  - `test/services/mistake_drill_launcher_service_test.dart`
  - `test/services/mistake_replay_pack_generator_test.dart`
  - `test/services/pack_filter_service_theme_test.dart`
  - `test/services/pack_novelty_guard_service_test.dart`
  - `test/services/path_injection_engine_e2e_test.dart`
  - `test/services/path_injection_engine_test.dart`
  - `test/services/postflop_jam_decision_theory_linker_test.dart`
  - `test/services/recap_to_drill_launcher_test.dart`
  - `test/services/scheduled_training_launcher_test.dart`
  - `test/services/scheduled_training_queue_service_test.dart`
  - `test/services/skill_gap_booster_service_test.dart`
  - `test/services/skill_loss_feed_engine_test.dart`
  - `test/services/skill_recovery_pack_engine_test.dart`
  - `test/services/skill_tag_coverage_guard_service_test.dart`
  - `test/services/smart_recap_booster_launcher_test.dart`
  - `test/services/smart_recap_booster_linker_test.dart`
  - `test/services/smart_resuggestion_engine_test.dart`
  - `test/services/smart_theory_booster_bridge_test.dart`
  - `test/services/suggested_weak_tag_pack_service_test.dart`
  - `test/services/targeted_pack_booster_engine_test.dart`
  - `test/services/theory_booster_launcher_test.dart`
  - `test/services/theory_booster_recommender_test.dart`
  - `test/services/theory_link_auto_injector_ablation_test.dart`
  - `test/services/theory_link_auto_injector_test.dart`
  - `test/services/theory_mini_lesson_linker_test.dart`
  - `test/services/theory_recall_evaluator_suggestions_test.dart`
  - `test/services/training_pack_library_metadata_enricher_test.dart`
  - `test/services/training_pack_library_search_service_test.dart`
  - `test/services/training_pack_search_index_builder_test.dart`
  - `test/services/training_pack_search_service_test.dart`
  - `test/services/training_pack_template_set_generator_test.dart`
  - `test/services/training_path_unlock_service_test.dart`
  - `test/services/training_session_completion_stats_service_test.dart`
  - `test/services/training_session_launcher_btn_cash_lesson_test.dart`
  - `test/services/training_session_launcher_intro_lesson_test.dart`
  - `test/services/training_session_recommender_test.dart`
  - `test/services/training_session_service_test.dart`
  - `test/services/unique_pack_replay_blocker_service_test.dart`
  - `test/services/weak_tag_booster_generator_service_test.dart`
  - `test/services/weekly_planner_booster_feed_test.dart`
  - `test/skill_targeting_recommender_test.dart`
  - `test/theory_booster_generator_test.dart`
  - `test/theory_injection_engine_test.dart`
  - `test/theory_pack_generator_test.dart`
  - `test/theory_pack_sampler_test.dart`
  - `test/theory_stage_auto_seeder_test.dart`
  - `test/training_pack_fingerprint_generator_test.dart`
  - `test/training_pack_library_theme_filter_test.dart`
  - `test/training_pack_ranking_engine_test.dart`
  - `test/training_pack_sampler_test.dart`
  - `test/training_pack_template_metadata_validator_test.dart`
  - `test/training_pack_template_v2_to_yaml_string_test.dart`
  - `test/training_progress_service_test.dart`
  - `test/training_spot_expander_test.dart`
  - `test/weakness_cluster_engine_v2_test.dart`
  - `test/weakness_review_engine_test.dart`
  - `test/widgets/clipboard_detector_template_test.dart`
  - `test/widgets/completed_session_detail_screen_test.dart`
  - `test/widgets/completed_session_history_screen_test.dart`
  - `test/widgets/endless_stop_button_test.dart`
  - `test/widgets/goal_reengagement_banner_test.dart`
  - `test/widgets/make_mistake_pack_test.dart`
  - `test/widgets/mistake_only_filter_test.dart`
  - `test/widgets/resume_button_test.dart`
  - `test/widgets/review_path_card_test.dart`
  - `test/widgets/template_play_button_test.dart`
  - `test/widgets/training_pack_history_list_widget_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`
  - `test/yaml_pack_auto_tag_engine_test.dart`
  - `test/yaml_pack_auto_tagger_test.dart`
  - `test/yaml_pack_rating_engine_test.dart`

#### `TrainingPackLevel`
- Count: `3`
- Exclusive: `0`
- Overlap: `3`
- Canonical equivalent: `lib/models/v2/pack_ux_metadata.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Shim values `l1/l2/l3` differ from canonical `beginner/intermediate/advanced`; representative `test/services/training_pack_search_service_test.dart` uses `TrainingPackLevel.beginner` and needs canonical import plus value audit.
- Consumer files:
  - `test/services/theory_booster_launcher_test.dart`
  - `test/services/training_pack_search_index_builder_test.dart`
  - `test/services/training_pack_search_service_test.dart`

#### `HeroPosition`
- Count: `54`
- Exclusive: `7`
- Overlap: `47`
- Canonical equivalent: `lib/models/v2/hero_position.dart`
- API divergence: `drop_in_import_only` - Canonical enum contains all active shim values plus `unknown`; representative `test/widgets/export_csv_button_test.dart` uses `HeroPosition.sb`.
- Consumer files:
  - `test/booster_cluster_engine_test.dart`
  - `test/booster_similarity_engine_test.dart`
  - `test/booster_smart_selector_test.dart`
  - `test/booster_thematic_tagger_test.dart`
  - `test/booster_variation_injector_test.dart`
  - `test/coverage_summary_test.dart`
  - `test/duplicates_only_filter_test.dart`
  - `test/line_graph_builder_service_test.dart`
  - `test/mistake_categorization_engine_test.dart`
  - `test/mistake_tag_classifier_test.dart`
  - `test/models/generate_missing_spots_test.dart`
  - `test/pack_augmentation_engine_test.dart`
  - `test/select_duplicates_test.dart`
  - `test/services/adaptive_learning_flow_engine_test.dart`
  - `test/services/adaptive_training_path_engine_test.dart`
  - `test/services/booster_mistake_recorder_test.dart`
  - `test/services/booster_pack_changelog_generator_test.dart`
  - `test/services/booster_pack_validator_service_test.dart`
  - `test/services/constraint_resolver_engine_generation_test.dart`
  - `test/services/constraint_resolver_v3_test.dart`
  - `test/services/deduplication_policy_engine_test.dart`
  - `test/services/dynamic_track_builder_test.dart`
  - `test/services/learning_plan_cache_test.dart`
  - `test/services/mistake_drill_launcher_service_test.dart`
  - `test/services/mistake_replay_pack_generator_history_test.dart`
  - `test/services/offline_evaluator_service_test.dart`
  - `test/services/open_3bet_spot_template_generator_service_test.dart`
  - `test/services/open_limped_spot_template_generator_service_test.dart`
  - `test/services/pack_export_service_test.dart`
  - `test/services/pack_generator_service_test.dart`
  - `test/services/pack_library_round_trip_validator_service_test.dart`
  - `test/services/spot_seed_filter_service_test.dart`
  - `test/services/theory_injector_from_template_set_service_test.dart`
  - `test/services/training_pack_generator_engine_v2_test.dart`
  - `test/services/training_pack_library_generator_test.dart`
  - `test/services/training_pack_template_expander_service_test.dart`
  - `test/services/training_pack_template_instance_expander_service_test.dart`
  - `test/services/training_pack_template_multi_set_expander_service_test.dart`
  - `test/services/training_pack_template_set_expander_service_test.dart`
  - `test/services/training_pack_template_set_generator_test.dart`
  - `test/session_analysis_screen_test.dart`
  - `test/spot_line_graph_engine_test.dart`
  - `test/training_pack_asset_loader_test.dart`
  - `test/training_pack_generator_v2_test.dart`
  - `test/training_pack_ranking_engine_test.dart`
  - `test/training_pack_sampler_test.dart`
  - `test/training_spot_expander_test.dart`
  - `test/weakness_cluster_engine_v2_test.dart`
  - `test/widgets/export_csv_button_test.dart`
  - `test/widgets/template_play_button_test.dart`
  - `test/widgets/training_pack_ev_badge_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`
  - `test/yaml_pack_auto_tag_engine_test.dart`
  - `test/yaml_pack_rating_engine_test.dart`

#### `HeroPositionLabel`
- Count: `0`
- Exclusive: `0`
- Overlap: `0`
- Canonical equivalent: `lib/models/v2/hero_position.dart / lib/utils/hero_position_ext.dart`
- API divergence: `drop_in_import_only` - Canonical extension already provides `.label`; zero remaining direct symbol references.
- Consumer files:
  - None

#### `TrainingPackTemplateV2`
- Count: `69`
- Exclusive: `0`
- Overlap: `69`
- Canonical equivalent: `lib/models/v2/training_pack_template_v2.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Canonical constructor requires `id`, `name`, and `trainingType`; most mixed files already prefix canonical `v2.TrainingPackTemplateV2`; representative `test/services/training_pack_search_index_builder_test.dart` needs import cleanup only if constructors are already canonical.
- Consumer files:
  - `test/booster_thematic_tagger_test.dart`
  - `test/booster_variation_injector_test.dart`
  - `test/core/training/training_pack_exporter_v2_test.dart`
  - `test/coverage_summary_test.dart`
  - `test/duplicates_only_filter_test.dart`
  - `test/missing_only_filter_test.dart`
  - `test/missing_pack_resolver_test.dart`
  - `test/mistakes_only_quick_filter_test.dart`
  - `test/pack_similarity_engine_test.dart`
  - `test/pack_unlocking_rules_engine_test.dart`
  - `test/select_duplicates_test.dart`
  - `test/services/adaptive_training_path_engine_test.dart`
  - `test/services/auto_recovery_trigger_service_test.dart`
  - `test/services/autogen_pack_error_classifier_service_test.dart`
  - `test/services/booster_injection_orchestrator_test.dart`
  - `test/services/booster_mistake_recorder_test.dart`
  - `test/services/booster_pack_changelog_generator_test.dart`
  - `test/services/booster_refiner_engine_test.dart`
  - `test/services/booster_session_tracker_test.dart`
  - `test/services/booster_suggestion_engine_test.dart`
  - `test/services/completed_session_summary_service_test.dart`
  - `test/services/icm_scenario_library_injector_test.dart`
  - `test/services/inline_theory_linker_pack_test.dart`
  - `test/services/learning_path_progress_tracker_tag_test.dart`
  - `test/services/learning_plan_cache_test.dart`
  - `test/services/mistake_replay_pack_generator_test.dart`
  - `test/services/pack_novelty_guard_service_test.dart`
  - `test/services/postflop_jam_decision_theory_linker_test.dart`
  - `test/services/recap_to_drill_launcher_test.dart`
  - `test/services/scheduled_training_launcher_test.dart`
  - `test/services/scheduled_training_queue_service_test.dart`
  - `test/services/skill_gap_booster_service_test.dart`
  - `test/services/skill_loss_feed_engine_test.dart`
  - `test/services/skill_tag_coverage_guard_service_test.dart`
  - `test/services/smart_recap_booster_launcher_test.dart`
  - `test/services/smart_recap_booster_linker_test.dart`
  - `test/services/smart_theory_booster_bridge_test.dart`
  - `test/services/targeted_pack_booster_engine_test.dart`
  - `test/services/theory_booster_launcher_test.dart`
  - `test/services/theory_booster_recommender_test.dart`
  - `test/services/theory_recall_evaluator_suggestions_test.dart`
  - `test/services/training_pack_library_metadata_enricher_test.dart`
  - `test/services/training_pack_search_index_builder_test.dart`
  - `test/services/training_pack_search_service_test.dart`
  - `test/services/training_pack_template_set_generator_test.dart`
  - `test/services/training_session_service_test.dart`
  - `test/services/unique_pack_replay_blocker_service_test.dart`
  - `test/skill_targeting_recommender_test.dart`
  - `test/theory_booster_generator_test.dart`
  - `test/theory_injection_engine_test.dart`
  - `test/training_pack_fingerprint_generator_test.dart`
  - `test/training_pack_ranking_engine_test.dart`
  - `test/training_progress_service_test.dart`
  - `test/weakness_cluster_engine_v2_test.dart`
  - `test/widgets/clipboard_detector_template_test.dart`
  - `test/widgets/completed_session_detail_screen_test.dart`
  - `test/widgets/completed_session_history_screen_test.dart`
  - `test/widgets/endless_stop_button_test.dart`
  - `test/widgets/eval_all_spots_test.dart`
  - `test/widgets/goal_reengagement_banner_test.dart`
  - `test/widgets/make_mistake_pack_test.dart`
  - `test/widgets/mistake_only_filter_test.dart`
  - `test/widgets/mixed_drill_test.dart`
  - `test/widgets/resume_button_test.dart`
  - `test/widgets/template_play_button_test.dart`
  - `test/widgets/training_pack_history_list_widget_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`
  - `test/yaml_pack_auto_tag_engine_test.dart`
  - `test/yaml_pack_rating_engine_test.dart`

#### `TagGoalProgress`
- Count: `2`
- Exclusive: `0`
- Overlap: `2`
- Canonical equivalent: `lib/models/tag_goal_progress.dart`
- API divergence: `fixture_rewrite_required` - Shim positional constructor differs from canonical required named fields `trainings/xp/streak/lastTrainingDate`; representative `test/services/auto_recovery_trigger_service_test.dart` returns a fake progress object.
- Consumer files:
  - `test/services/auto_recovery_trigger_service_test.dart`
  - `test/services/skill_loss_feed_engine_test.dart`

#### `HandData`
- Count: `100`
- Exclusive: `16`
- Overlap: `84`
- Canonical equivalent: `lib/models/v2/hand_data.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Shim exposes `id` and `street`; canonical uses poker-state fields like `heroCards`, `position`, `board`, and `actions`; representative model-heavy files already use `v2models.HandData()` but require import disambiguation.
- Consumer files:
  - `test/booster_cluster_engine_test.dart`
  - `test/booster_similarity_engine_test.dart`
  - `test/booster_smart_selector_test.dart`
  - `test/booster_thematic_tagger_test.dart`
  - `test/booster_theory_pack_linker_test.dart`
  - `test/booster_variation_injector_test.dart`
  - `test/coverage_summary_test.dart`
  - `test/duplicate_spot_detection_test.dart`
  - `test/duplicates_only_filter_test.dart`
  - `test/e2e_theory_injection_path_test.dart`
  - `test/evaluation_executor_service_test.dart`
  - `test/import_dup_hint_test.dart`
  - `test/intro_theory_pack_generator_test.dart`
  - `test/line_graph_builder_service_test.dart`
  - `test/missing_only_filter_test.dart`
  - `test/mistake_categorization_engine_test.dart`
  - `test/mistake_tag_classifier_test.dart`
  - `test/mistakes_only_quick_filter_test.dart`
  - `test/pack_augmentation_engine_test.dart`
  - `test/presenters/completed_session_history_presenter_test.dart`
  - `test/remedial_analyzer_test.dart`
  - `test/select_duplicates_test.dart`
  - `test/services/adaptive_learning_flow_engine_test.dart`
  - `test/services/adaptive_spot_scheduler_test.dart`
  - `test/services/adaptive_training_path_engine_test.dart`
  - `test/services/auto_spot_theory_injector_service_test.dart`
  - `test/services/booster_mistake_recorder_test.dart`
  - `test/services/booster_pack_changelog_generator_test.dart`
  - `test/services/booster_pack_validator_service_test.dart`
  - `test/services/booster_refiner_engine_test.dart`
  - `test/services/booster_theory_injector_test.dart`
  - `test/services/completed_training_pack_registry_test.dart`
  - `test/services/constraint_resolver_engine_generation_test.dart`
  - `test/services/deduplication_policy_engine_test.dart`
  - `test/services/dynamic_track_builder_test.dart`
  - `test/services/icm_scenario_library_injector_test.dart`
  - `test/services/inline_theory_linker_pack_test.dart`
  - `test/services/learning_path_progress_tracker_tag_test.dart`
  - `test/services/learning_plan_cache_test.dart`
  - `test/services/mistake_drill_launcher_service_test.dart`
  - `test/services/mistake_driven_drill_pack_generator_test.dart`
  - `test/services/mistake_replay_pack_generator_history_test.dart`
  - `test/services/mistake_replay_pack_generator_test.dart`
  - `test/services/mistake_tag_history_service_test.dart`
  - `test/services/offline_evaluator_service_test.dart`
  - `test/services/pack_fingerprint_comparer_service_test.dart`
  - `test/services/pack_library_round_trip_validator_service_test.dart`
  - `test/services/postflop_jam_decision_theory_linker_test.dart`
  - `test/services/smart_theory_injection_engine_test.dart`
  - `test/services/spot_seed_filter_service_test.dart`
  - `test/services/theory_booster_suggestion_service_test.dart`
  - `test/services/theory_injector_from_template_set_service_test.dart`
  - `test/services/theory_link_auto_injector_ablation_test.dart`
  - `test/services/theory_link_auto_injector_service_test.dart`
  - `test/services/theory_link_auto_injector_test.dart`
  - `test/services/theory_recall_evaluator_test.dart`
  - `test/services/training_pack_audit_log_service_test.dart`
  - `test/services/training_pack_auto_generator_texture_filter_test.dart`
  - `test/services/training_pack_generator_engine_v2_test.dart`
  - `test/services/training_pack_library_exporter_test.dart`
  - `test/services/training_pack_library_generator_test.dart`
  - `test/services/training_pack_metadata_enricher_service_test.dart`
  - `test/services/training_pack_template_expander_service_test.dart`
  - `test/services/training_pack_template_instance_expander_service_test.dart`
  - `test/services/training_pack_template_multi_set_expander_service_test.dart`
  - `test/services/training_pack_template_set_expander_service_test.dart`
  - `test/services/training_pack_template_set_generator_test.dart`
  - `test/services/training_session_completion_stats_service_test.dart`
  - `test/session_analysis_screen_test.dart`
  - `test/skill_targeting_recommender_test.dart`
  - `test/smart_mistake_review_strategy_test.dart`
  - `test/spot_line_graph_engine_test.dart`
  - `test/theory_booster_generator_test.dart`
  - `test/theory_injection_engine_test.dart`
  - `test/theory_pack_sampler_test.dart`
  - `test/theory_stage_auto_seeder_test.dart`
  - `test/training_pack_fingerprint_generator_test.dart`
  - `test/training_pack_generator_v2_test.dart`
  - `test/training_pack_ranking_engine_test.dart`
  - `test/training_pack_sampler_test.dart`
  - `test/training_pack_spot_serialization_test.dart`
  - `test/training_pack_spot_yaml_test.dart`
  - `test/training_pack_template_metadata_validator_test.dart`
  - `test/training_progress_service_test.dart`
  - `test/training_spot_expander_test.dart`
  - `test/weakness_cluster_engine_v2_test.dart`
  - `test/widgets/clipboard_detector_template_test.dart`
  - `test/widgets/completed_session_detail_screen_test.dart`
  - `test/widgets/completed_session_history_screen_test.dart`
  - `test/widgets/endless_stop_button_test.dart`
  - `test/widgets/eval_all_spots_test.dart`
  - `test/widgets/goal_reengagement_banner_test.dart`
  - `test/widgets/make_mistake_pack_test.dart`
  - `test/widgets/mistake_only_filter_test.dart`
  - `test/widgets/mixed_drill_test.dart`
  - `test/widgets/resume_button_test.dart`
  - `test/widgets/training_pack_history_list_widget_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`
  - `test/yaml_pack_auto_tag_engine_test.dart`
  - `test/yaml_pack_rating_engine_test.dart`

#### `isAutoReplayKind`
- Count: `5`
- Exclusive: `5`
- Overlap: `0`
- Canonical equivalent: `lib/ui/session_player/spot_specs.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Shim accepts `Object?`; canonical requires `SpotKind`; representative auto-replay tests must pass or type variables as `SpotKind`.
- Consumer files:
  - `test/auto_replay_invariants_test.dart`
  - `test/l4_icm_sb_jam_vs_fold_test.dart`
  - `test/spot_specs_auto_replay_invariants_test.dart`
  - `test/spot_specs_should_auto_replay_test.dart`
  - `test/spot_specs_ssot_consistency_test.dart`

#### `TrainingSessionService`
- Count: `66`
- Exclusive: `32`
- Overlap: `34`
- Canonical equivalent: `lib/services/training_session_service.dart`
- API divergence: `semantic_owner_review_required` - Canonical class is a ChangeNotifier with runtime state; representative `test/widgets/training_session_summary_screen_test.dart` subclasses it and may need owner-safe fake strategy.
- Consumer files:
  - `test/auto_booster_pruner_test.dart`
  - `test/auto_start_training_prompt_test.dart`
  - `test/auto_theory_review_engine_test.dart`
  - `test/learning_path_auto_expander_test.dart`
  - `test/learning_path_engine_core_test.dart`
  - `test/learning_track_progress_model_test.dart`
  - `test/mini_lesson_auto_injector_test.dart`
  - `test/mini_lesson_booster_engine_test.dart`
  - `test/mini_lesson_path_injector_test.dart`
  - `test/services/adaptive_pack_inbox_notifier_test.dart`
  - `test/services/adaptive_theory_scheduler_test.dart`
  - `test/services/auto_theory_booster_launcher_test.dart`
  - `test/services/auto_theory_review_engine_recommendation_test.dart`
  - `test/services/booster_injection_orchestrator_test.dart`
  - `test/services/booster_pack_launcher_test.dart`
  - `test/services/booster_preview_launcher_test.dart`
  - `test/services/booster_theory_injector_test.dart`
  - `test/services/goal_reengagement_service_test.dart`
  - `test/services/goal_reminder_engine_test.dart`
  - `test/services/goal_suggestion_service_test.dart`
  - `test/services/learning_path_booster_engine_test.dart`
  - `test/services/learning_path_gatekeeper_service_test.dart`
  - `test/services/learning_path_launcher_service_test.dart`
  - `test/services/learning_path_progress_engine_test.dart`
  - `test/services/learning_path_stats_service_test.dart`
  - `test/services/learning_path_summary_cache_v2_test.dart`
  - `test/services/learning_path_unlock_engine_test.dart`
  - `test/services/learning_track_recommendation_engine_test.dart`
  - `test/services/next_up_engine_test.dart`
  - `test/services/pack_format_selection_service_test.dart`
  - `test/services/pack_suggestion_analytics_engine_test.dart`
  - `test/services/recap_banner_injector_test.dart`
  - `test/services/recap_opportunity_detector_test.dart`
  - `test/services/recap_tag_analytics_service_test.dart`
  - `test/services/recap_to_drill_launcher_test.dart`
  - `test/services/skill_map_booster_recommender_test.dart`
  - `test/services/skill_tag_decay_tracker_test.dart`
  - `test/services/smart_booster_unlocker_test.dart`
  - `test/services/smart_goal_tracking_service_test.dart`
  - `test/services/smart_recap_banner_controller_test.dart`
  - `test/services/smart_recap_banner_reinjection_service_test.dart`
  - `test/services/smart_recap_booster_launcher_test.dart`
  - `test/services/smart_recap_scheduler_test.dart`
  - `test/services/smart_resuggestion_engine_test.dart`
  - `test/services/smart_theory_suggestion_engine_test.dart`
  - `test/services/theory_and_booster_flow_composer_test.dart`
  - `test/services/theory_booster_launcher_test.dart`
  - `test/services/theory_goal_completion_notifier_test.dart`
  - `test/services/theory_goal_engine_test.dart`
  - `test/services/theory_goal_recommender_test.dart`
  - `test/services/training_path_progress_service_v2_test.dart`
  - `test/services/training_run_ab_comparator_service_test.dart`
  - `test/services/training_session_service_test.dart`
  - `test/session_analysis_screen_test.dart`
  - `test/smart_mini_booster_planner_test.dart`
  - `test/smart_recap_auto_injector_test.dart`
  - `test/tag_retention_tracker_test.dart`
  - `test/theory_booster_injector_test.dart`
  - `test/theory_lesson_review_queue_test.dart`
  - `test/widgets/endless_stop_button_test.dart`
  - `test/widgets/generated_pack_play_test.dart`
  - `test/widgets/goal_reengagement_banner_test.dart`
  - `test/widgets/mixed_drill_test.dart`
  - `test/widgets/template_play_button_test.dart`
  - `test/widgets/training_pack_history_list_widget_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`

#### `AppColors`
- Count: `0`
- Exclusive: `0`
- Overlap: `0`
- Canonical equivalent: `lib/theme/app_colors.dart`
- API divergence: `drop_in_import_only` - Zero remaining direct symbol references after Phase 1B; no batch work needed unless newly discovered.
- Consumer files:
  - None

#### `MiniLessonLibraryService`
- Count: `66`
- Exclusive: `45`
- Overlap: `21`
- Canonical equivalent: `lib/services/mini_lesson_library_service.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Shim is abstract with synchronous fake methods; canonical is singleton-style concrete service with async methods for several calls; representative `test/services/weekly_planner_booster_feed_test.dart` needs fake adaptation.
- Consumer files:
  - `test/auto_theory_review_engine_test.dart`
  - `test/learning_path_auto_expander_test.dart`
  - `test/mini_lesson_auto_injector_test.dart`
  - `test/mini_lesson_booster_engine_test.dart`
  - `test/mini_lesson_path_injector_test.dart`
  - `test/services/adaptive_theory_scheduler_test.dart`
  - `test/services/auto_spot_theory_injector_service_test.dart`
  - `test/services/decay_booster_reminder_service_test.dart`
  - `test/services/decay_booster_spot_injector_test.dart`
  - `test/services/effective_theory_injector_service_test.dart`
  - `test/services/goal_slot_allocator_test.dart`
  - `test/services/goal_smart_suggestion_engine_test.dart`
  - `test/services/goal_to_training_launcher_test.dart`
  - `test/services/inbox_booster_tuner_service_test.dart`
  - `test/services/inline_theory_linker_cache_test.dart`
  - `test/services/inline_theory_linker_test.dart`
  - `test/services/overlay_decay_booster_orchestrator_test.dart`
  - `test/services/postflop_jam_decision_theory_linker_test.dart`
  - `test/services/skill_decay_tag_filter_test.dart`
  - `test/services/skill_gap_detector_service_test.dart`
  - `test/services/smart_booster_unlocker_test.dart`
  - `test/services/smart_recap_banner_reinjection_service_test.dart`
  - `test/services/smart_recap_scheduler_test.dart`
  - `test/services/smart_recap_suggestion_engine_stream_test.dart`
  - `test/services/smart_recap_suggestion_engine_test.dart`
  - `test/services/smart_skill_gap_booster_engine_test.dart`
  - `test/services/smart_theory_injection_engine_test.dart`
  - `test/services/smart_theory_recap_score_weighting_test.dart`
  - `test/services/theory_auto_recall_injector_test.dart`
  - `test/services/theory_boost_trigger_service_test.dart`
  - `test/services/theory_booster_candidate_picker_test.dart`
  - `test/services/theory_booster_injection_service_test.dart`
  - `test/services/theory_booster_recall_engine_test.dart`
  - `test/services/theory_booster_suggestion_service_test.dart`
  - `test/services/theory_booster_training_launcher_test.dart`
  - `test/services/theory_goal_completion_notifier_test.dart`
  - `test/services/theory_goal_engine_test.dart`
  - `test/services/theory_graph_navigation_engine_test.dart`
  - `test/services/theory_lesson_cluster_linker_service_test.dart`
  - `test/services/theory_lesson_graph_exporter_test.dart`
  - `test/services/theory_lesson_graph_navigator_service_test.dart`
  - `test/services/theory_lesson_navigator_service_test.dart`
  - `test/services/theory_lesson_resume_engine_test.dart`
  - `test/services/theory_lesson_tag_clusterer_test.dart`
  - `test/services/theory_lesson_tag_heatmap_service_test.dart`
  - `test/services/theory_lesson_unlock_notification_service_test.dart`
  - `test/services/theory_link_auto_injector_service_test.dart`
  - `test/services/theory_mini_lesson_linker_test.dart`
  - `test/services/theory_mini_lesson_navigator_test.dart`
  - `test/services/theory_path_preview_builder_test.dart`
  - `test/services/theory_recall_evaluator_suggestions_test.dart`
  - `test/services/theory_recall_inbox_reinjection_service_test.dart`
  - `test/services/theory_recap_prompt_orchestrator_test.dart`
  - `test/services/theory_reinforcement_banner_controller_test.dart`
  - `test/services/theory_reinforcement_queue_service_test.dart`
  - `test/services/theory_tag_decay_tracker_test.dart`
  - `test/services/theory_tag_summary_service_test.dart`
  - `test/services/theory_weakness_repeater_test.dart`
  - `test/smart_mini_booster_planner_test.dart`
  - `test/theory_lesson_reachability_validator_test.dart`
  - `test/theory_lesson_review_queue_test.dart`
  - `test/theory_smart_entry_point_selector_test.dart`
  - `test/widgets/inline_theory_badge_test.dart`
  - `test/widgets/inline_theory_link_chip_test.dart`
  - `test/widgets/inline_theory_linker_widget_test.dart`
  - `test/widgets/theory_lesson_context_overlay_test.dart`

#### `PackLibraryService`
- Count: `13`
- Exclusive: `2`
- Overlap: `11`
- Canonical equivalent: `lib/services/pack_library_service.dart`
- API divergence: `semantic_owner_review_required` - Shim was generic/abstract-like while canonical is concrete singleton-style; representative `test/services/auto_recovery_trigger_service_test.dart` has `implements PackLibraryService` and invalid fake signatures.
- Consumer files:
  - `test/services/auto_recovery_trigger_service_test.dart`
  - `test/services/booster_pack_launcher_test.dart`
  - `test/services/learning_path_entry_group_builder_test.dart`
  - `test/services/learning_path_launcher_service_test.dart`
  - `test/services/learning_path_stage_launcher_test.dart`
  - `test/services/pack_library_service_test.dart`
  - `test/services/scheduled_training_launcher_test.dart`
  - `test/services/scheduled_training_queue_service_test.dart`
  - `test/services/skill_gap_booster_service_test.dart`
  - `test/services/skill_loss_feed_engine_test.dart`
  - `test/services/weekly_planner_booster_engine_test.dart`
  - `test/services/weekly_planner_booster_feed_test.dart`
  - `test/widgets/review_path_card_test.dart`

#### `RecallSuccessLoggerService`
- Count: `7`
- Exclusive: `7`
- Overlap: `0`
- Canonical equivalent: `lib/services/recall_success_logger_service.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Canonical constructor is private with `instance`; representative recall tests that instantiate the shim need a local fake or canonical instance strategy.
- Consumer files:
  - `test/services/decay_recall_tuner_engine_test.dart`
  - `test/services/recall_tag_decay_summary_service_test.dart`
  - `test/services/smart_decay_goal_generator_test.dart`
  - `test/services/smart_recall_booster_scheduler_test.dart`
  - `test/services/tag_decay_forecast_service_test.dart`
  - `test/services/theory_lesson_effectiveness_analyzer_service_test.dart`
  - `test/services/theory_recall_efficiency_evaluator_service_test.dart`

#### `SmartTheoryRecapDismissalMemory`
- Count: `4`
- Exclusive: `1`
- Overlap: `3`
- Canonical equivalent: `lib/services/smart_theory_recap_dismissal_memory.dart`
- API divergence: `minor_constructor_or_enum_adaptation` - Canonical constructor is private with `instance`; representative recap tests need instance/local fake strategy.
- Consumer files:
  - `test/services/smart_recap_banner_controller_test.dart`
  - `test/services/smart_recap_banner_reinjection_service_test.dart`
  - `test/services/smart_theory_recap_dismissal_memory_test.dart`
  - `test/smart_recap_auto_injector_test.dart`

#### `AppLocalizations`
- Count: `2`
- Exclusive: `1`
- Overlap: `1`
- Canonical equivalent: `lib/l10n/app_localizations.dart or lib/flutter_gen/gen_l10n/app_localizations.dart`
- API divergence: `semantic_owner_review_required` - Shim exposes only `of/ok/cancel`; canonical localization uses generated delegates/supported locales and nullable `of`; representative `test/training_pack_template_service_test.dart` uses generated localization strings.
- Consumer files:
  - `test/training_pack_template_service_test.dart`
  - `test/widgets/training_session_summary_screen_test.dart`

## B. Overlap Graph

| Symbols per file | File count |
| ---: | ---: |
| 1 | 151 |
| 2 | 66 |
| 3 | 44 |
| 4 | 24 |
| 5 | 10 |
| 6 | 1 |

### Highest-Overlap Symbol Clusters

| Rank | Symbol cluster | File count |
| ---: | --- | ---: |
| 1 | `MiniLessonLibraryService` | 45 |
| 2 | `TrainingSessionService` | 32 |
| 3 | `TrainingType` | 31 |
| 4 | `HeroPosition, HandData` | 19 |
| 5 | `HandData` | 16 |
| 6 | `TrainingType, TrainingPackTemplateV2, HandData` | 16 |
| 7 | `TrainingSessionService, MiniLessonLibraryService` | 12 |
| 8 | `TrainingType, HandData` | 11 |
| 9 | `GameType, TrainingType, TrainingPackTemplateV2` | 11 |
| 10 | `TrainingType, HeroPosition, TrainingPackTemplateV2, HandData` | 9 |
| 11 | `TrainingType, HeroPosition, HandData` | 7 |
| 12 | `HeroPosition` | 7 |
| 13 | `RecallSuccessLoggerService` | 7 |
| 14 | `isAutoReplayKind` | 5 |
| 15 | `TrainingType, TrainingPackTemplateV2` | 5 |
| 16 | `GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData` | 5 |
| 17 | `GameType` | 4 |
| 18 | `HandData, MiniLessonLibraryService` | 4 |
| 19 | `TrainingType, TrainingSessionService` | 3 |
| 20 | `GameType, TrainingType, TrainingPackTemplateV2, PackLibraryService` | 3 |

### Greedy Importer-Reduction Order

| Order | Symbol | Newly unlocked files if migrated now |
| ---: | --- | ---: |
| 1 | `TrainingType` | 131 |
| 2 | `MiniLessonLibraryService` | 62 |
| 3 | `HandData` | 40 |
| 4 | `TrainingSessionService` | 34 |
| 5 | `HeroPosition` | 9 |
| 6 | `RecallSuccessLoggerService` | 7 |
| 7 | `isAutoReplayKind` | 5 |
| 8 | `GameType` | 4 |
| 9 | `PackLibraryService` | 2 |
| 10 | `SmartTheoryRecapDismissalMemory` | 1 |
| 11 | `AppLocalizations` | 1 |

## C. API Divergence Classes

### `drop_in_import_only`
- `GameType`: Canonical enum has the same `tournament` and `cash` values; representative `test/services/training_pack_search_service_test.dart` can import canonical type.
- `HeroPosition`: Canonical enum contains all active shim values plus `unknown`; representative `test/widgets/export_csv_button_test.dart` uses `HeroPosition.sb`.
- `HeroPositionLabel`: Canonical extension already provides `.label`; zero remaining direct symbol references.
- `AppColors`: Zero remaining direct symbol references after Phase 1B; no batch work needed unless newly discovered.

### `minor_constructor_or_enum_adaptation`
- `TrainingType`: Shim values `generic/gto` do not exist canonically and canonical uses `pushFold/postflop/...`; representative `test/services/training_pack_search_service_test.dart` already uses canonical `TrainingType.postflop` while importing shim.
- `TrainingPackLevel`: Shim values `l1/l2/l3` differ from canonical `beginner/intermediate/advanced`; representative `test/services/training_pack_search_service_test.dart` uses `TrainingPackLevel.beginner` and needs canonical import plus value audit.
- `TrainingPackTemplateV2`: Canonical constructor requires `id`, `name`, and `trainingType`; most mixed files already prefix canonical `v2.TrainingPackTemplateV2`; representative `test/services/training_pack_search_index_builder_test.dart` needs import cleanup only if constructors are already canonical.
- `HandData`: Shim exposes `id` and `street`; canonical uses poker-state fields like `heroCards`, `position`, `board`, and `actions`; representative model-heavy files already use `v2models.HandData()` but require import disambiguation.
- `isAutoReplayKind`: Shim accepts `Object?`; canonical requires `SpotKind`; representative auto-replay tests must pass or type variables as `SpotKind`.
- `MiniLessonLibraryService`: Shim is abstract with synchronous fake methods; canonical is singleton-style concrete service with async methods for several calls; representative `test/services/weekly_planner_booster_feed_test.dart` needs fake adaptation.
- `RecallSuccessLoggerService`: Canonical constructor is private with `instance`; representative recall tests that instantiate the shim need a local fake or canonical instance strategy.
- `SmartTheoryRecapDismissalMemory`: Canonical constructor is private with `instance`; representative recap tests need instance/local fake strategy.

### `fixture_rewrite_required`
- `TagGoalProgress`: Shim positional constructor differs from canonical required named fields `trainings/xp/streak/lastTrainingDate`; representative `test/services/auto_recovery_trigger_service_test.dart` returns a fake progress object.

### `semantic_owner_review_required`
- `ShareOptions`: No canonical production type was confirmed; representative file `test/widgets/export_csv_button_test.dart` passes `ShareOptions? sharePositionOrigin` through export/share seams.
- `TrainingSessionService`: Canonical class is a ChangeNotifier with runtime state; representative `test/widgets/training_session_summary_screen_test.dart` subclasses it and may need owner-safe fake strategy.
- `PackLibraryService`: Shim was generic/abstract-like while canonical is concrete singleton-style; representative `test/services/auto_recovery_trigger_service_test.dart` has `implements PackLibraryService` and invalid fake signatures.
- `AppLocalizations`: Shim exposes only `of/ok/cancel`; canonical localization uses generated delegates/supported locales and nullable `of`; representative `test/training_pack_template_service_test.dart` uses generated localization strings.

### `no_canonical_equivalent`
- None

### `uncertain_stop`
- None

## D. Cheapest Batch Candidates

| Batch | Symbols | File count | Expected importer reduction | Risk | Recommended model | Effort |
| --- | --- | ---: | ---: | --- | --- | --- |
| 1. Core enum/model/template cleanup | `GameType`, `TrainingType`, `HeroPosition`, `HeroPositionLabel`, `TrainingPackTemplateV2`, `HandData`, `isAutoReplayKind` | 176 | 176 | Medium: constructor/enum import adaptation, no owner-sensitive files | Fable | Low |
| 2. Service/local fake cleanup | `TrainingSessionService`, `MiniLessonLibraryService`, `PackLibraryService`, `RecallSuccessLoggerService`, `SmartTheoryRecapDismissalMemory` | 101 | 101 | Medium: fake/service import adaptation, residual inheritance/implements excluded | Fable | Medium |
| 3. Owner-review residuals | `ShareOptions`, `AppLocalizations`, `TrainingPackLevel`, `TagGoalProgress`, service fake inheritance/implements conflicts | 19 | 19 | High: product-truth or compatibility-owner decision needed | Codex | Low |

### Batch File Lists
#### Batch 1 Core enum/model/template cleanup
- `test/auto_replay_invariants_test.dart`
- `test/booster_cluster_engine_test.dart`
- `test/booster_injection_engine_test.dart`
- `test/booster_mistake_backlink_engine_test.dart`
- `test/booster_similarity_engine_test.dart`
- `test/booster_smart_selector_test.dart`
- `test/booster_thematic_tagger_test.dart`
- `test/booster_theory_pack_linker_test.dart`
- `test/booster_variation_injector_test.dart`
- `test/core/training/training_pack_exporter_v2_test.dart`
- `test/coverage_summary_test.dart`
- `test/duplicate_spot_detection_test.dart`
- `test/duplicates_only_filter_test.dart`
- `test/e2e_adaptive_plan_injection_test.dart`
- `test/e2e_concurrency_locking_test.dart`
- `test/e2e_idempotent_retry_test.dart`
- `test/e2e_path_hardening_rollback_test.dart`
- `test/e2e_theory_injection_path_test.dart`
- `test/evaluation_executor_service_test.dart`
- `test/import_dup_hint_test.dart`
- `test/intro_theory_pack_generator_test.dart`
- `test/l4_icm_sb_jam_vs_fold_test.dart`
- `test/learning_path_auto_seeder_test.dart`
- `test/learning_path_library_validator_test.dart`
- `test/learning_path_template_validator_test.dart`
- `test/level_tag_auto_assigner_test.dart`
- `test/line_graph_builder_service_test.dart`
- `test/missing_only_filter_test.dart`
- `test/missing_pack_resolver_test.dart`
- `test/mistake_categorization_engine_test.dart`
- `test/mistake_tag_classifier_test.dart`
- `test/mistakes_only_quick_filter_test.dart`
- `test/models/generate_missing_spots_test.dart`
- `test/models/training_pack_template_v2_hand_group_tags_test.dart`
- `test/pack_augmentation_engine_test.dart`
- `test/pack_search_engine_test.dart`
- `test/pack_search_index_service_test.dart`
- `test/pack_similarity_engine_test.dart`
- `test/pack_unlocking_rules_engine_test.dart`
- `test/presenters/completed_session_history_presenter_test.dart`
- `test/remedial_analyzer_test.dart`
- `test/select_duplicates_test.dart`
- `test/services/adaptive_learning_flow_engine_test.dart`
- `test/services/adaptive_pack_inbox_notifier_test.dart`
- `test/services/adaptive_plan_executor_budget_test.dart`
- `test/services/adaptive_plan_executor_idempotency_test.dart`
- `test/services/adaptive_spot_scheduler_test.dart`
- `test/services/adaptive_training_path_engine_test.dart`
- `test/services/auto_advance_pack_engine_test.dart`
- `test/services/auto_spot_theory_injector_service_test.dart`
- `test/services/autogen_pack_error_classifier_service_test.dart`
- `test/services/booster_injection_orchestrator_test.dart`
- `test/services/booster_mistake_recorder_test.dart`
- `test/services/booster_pack_changelog_generator_test.dart`
- `test/services/booster_pack_validator_service_test.dart`
- `test/services/booster_preview_launcher_test.dart`
- `test/services/booster_refiner_engine_test.dart`
- `test/services/booster_session_tracker_test.dart`
- `test/services/booster_suggestion_engine_test.dart`
- `test/services/booster_theory_injector_test.dart`
- `test/services/completed_session_summary_service_test.dart`
- `test/services/completed_training_pack_registry_test.dart`
- `test/services/constraint_resolver_engine_generation_test.dart`
- `test/services/constraint_resolver_v3_test.dart`
- `test/services/decay_booster_spot_injector_test.dart`
- `test/services/deduplication_policy_engine_test.dart`
- `test/services/dynamic_track_builder_test.dart`
- `test/services/icm_scenario_library_injector_test.dart`
- `test/services/inline_theory_linker_pack_test.dart`
- `test/services/learning_path_booster_engine_test.dart`
- `test/services/learning_path_progress_tracker_tag_test.dart`
- `test/services/learning_plan_cache_test.dart`
- `test/services/learning_track_engine_test.dart`
- `test/services/lesson_step_filter_engine_test.dart`
- `test/services/mistake_drill_launcher_service_test.dart`
- `test/services/mistake_driven_drill_pack_generator_test.dart`
- `test/services/mistake_replay_pack_generator_history_test.dart`
- `test/services/mistake_replay_pack_generator_test.dart`
- `test/services/mistake_tag_history_service_test.dart`
- `test/services/offline_evaluator_service_test.dart`
- `test/services/open_3bet_spot_template_generator_service_test.dart`
- `test/services/open_limped_spot_template_generator_service_test.dart`
- `test/services/pack_filter_service_theme_test.dart`
- `test/services/pack_fingerprint_comparer_service_test.dart`
- `test/services/pack_generator_service_test.dart`
- `test/services/pack_library_round_trip_validator_service_test.dart`
- `test/services/pack_novelty_guard_service_test.dart`
- `test/services/path_injection_engine_e2e_test.dart`
- `test/services/path_injection_engine_test.dart`
- `test/services/postflop_jam_decision_theory_linker_test.dart`
- `test/services/recap_to_drill_launcher_test.dart`
- `test/services/skill_recovery_pack_engine_test.dart`
- `test/services/skill_tag_coverage_guard_service_test.dart`
- `test/services/smart_recap_booster_launcher_test.dart`
- `test/services/smart_recap_booster_linker_test.dart`
- `test/services/smart_resuggestion_engine_test.dart`
- `test/services/smart_theory_booster_bridge_test.dart`
- `test/services/smart_theory_injection_engine_test.dart`
- `test/services/spot_seed_filter_service_test.dart`
- `test/services/suggested_weak_tag_pack_service_test.dart`
- `test/services/targeted_pack_booster_engine_test.dart`
- `test/services/theory_booster_recommender_test.dart`
- `test/services/theory_booster_suggestion_service_test.dart`
- `test/services/theory_injector_from_template_set_service_test.dart`
- `test/services/theory_link_auto_injector_ablation_test.dart`
- `test/services/theory_link_auto_injector_service_test.dart`
- `test/services/theory_link_auto_injector_test.dart`
- `test/services/theory_mini_lesson_linker_test.dart`
- `test/services/theory_recall_evaluator_suggestions_test.dart`
- `test/services/theory_recall_evaluator_test.dart`
- `test/services/track_unlock_conditions_engine_test.dart`
- `test/services/track_visibility_filter_engine_test.dart`
- `test/services/training_pack_audit_log_service_test.dart`
- `test/services/training_pack_auto_generator_texture_filter_test.dart`
- `test/services/training_pack_generator_engine_v2_test.dart`
- `test/services/training_pack_library_exporter_test.dart`
- `test/services/training_pack_library_generator_test.dart`
- `test/services/training_pack_library_metadata_enricher_test.dart`
- `test/services/training_pack_library_search_service_test.dart`
- `test/services/training_pack_metadata_enricher_service_test.dart`
- `test/services/training_pack_template_expander_service_test.dart`
- `test/services/training_pack_template_instance_expander_service_test.dart`
- `test/services/training_pack_template_multi_set_expander_service_test.dart`
- `test/services/training_pack_template_set_expander_service_test.dart`
- `test/services/training_pack_template_set_generator_test.dart`
- `test/services/training_path_unlock_service_test.dart`
- `test/services/training_session_completion_stats_service_test.dart`
- `test/services/training_session_launcher_btn_cash_lesson_test.dart`
- `test/services/training_session_launcher_intro_lesson_test.dart`
- `test/services/training_session_recommender_test.dart`
- `test/services/training_session_service_test.dart`
- `test/services/unique_pack_replay_blocker_service_test.dart`
- `test/services/weak_tag_booster_generator_service_test.dart`
- `test/session_analysis_screen_test.dart`
- `test/skill_targeting_recommender_test.dart`
- `test/smart_mistake_review_strategy_test.dart`
- `test/spot_factory_level2_engine_test.dart`
- `test/spot_line_graph_engine_test.dart`
- `test/spot_specs_auto_replay_invariants_test.dart`
- `test/spot_specs_should_auto_replay_test.dart`
- `test/spot_specs_ssot_consistency_test.dart`
- `test/theory_booster_generator_test.dart`
- `test/theory_injection_engine_test.dart`
- `test/theory_pack_generator_test.dart`
- `test/theory_pack_sampler_test.dart`
- `test/theory_stage_auto_seeder_test.dart`
- `test/training_pack_asset_loader_test.dart`
- `test/training_pack_fingerprint_generator_test.dart`
- `test/training_pack_generator_v2_test.dart`
- `test/training_pack_library_theme_filter_test.dart`
- `test/training_pack_ranking_engine_test.dart`
- `test/training_pack_sampler_test.dart`
- `test/training_pack_spot_serialization_test.dart`
- `test/training_pack_spot_yaml_test.dart`
- `test/training_pack_template_metadata_validator_test.dart`
- `test/training_pack_template_v2_to_yaml_string_test.dart`
- `test/training_progress_service_test.dart`
- `test/training_spot_expander_test.dart`
- `test/weakness_cluster_engine_v2_test.dart`
- `test/weakness_review_engine_test.dart`
- `test/widgets/clipboard_detector_template_test.dart`
- `test/widgets/completed_session_detail_screen_test.dart`
- `test/widgets/completed_session_history_screen_test.dart`
- `test/widgets/endless_stop_button_test.dart`
- `test/widgets/eval_all_spots_test.dart`
- `test/widgets/goal_reengagement_banner_test.dart`
- `test/widgets/make_mistake_pack_test.dart`
- `test/widgets/mistake_only_filter_test.dart`
- `test/widgets/mixed_drill_test.dart`
- `test/widgets/resume_button_test.dart`
- `test/widgets/template_play_button_test.dart`
- `test/widgets/training_pack_ev_badge_test.dart`
- `test/widgets/training_pack_history_list_widget_test.dart`
- `test/yaml_pack_auto_tag_engine_test.dart`
- `test/yaml_pack_auto_tagger_test.dart`
- `test/yaml_pack_rating_engine_test.dart`

#### Batch 2 Service/local fake cleanup
- `test/auto_booster_pruner_test.dart`
- `test/auto_start_training_prompt_test.dart`
- `test/auto_theory_review_engine_test.dart`
- `test/learning_path_auto_expander_test.dart`
- `test/learning_path_engine_core_test.dart`
- `test/learning_track_progress_model_test.dart`
- `test/mini_lesson_auto_injector_test.dart`
- `test/mini_lesson_booster_engine_test.dart`
- `test/mini_lesson_path_injector_test.dart`
- `test/services/adaptive_theory_scheduler_test.dart`
- `test/services/auto_theory_booster_launcher_test.dart`
- `test/services/auto_theory_review_engine_recommendation_test.dart`
- `test/services/decay_booster_reminder_service_test.dart`
- `test/services/decay_recall_tuner_engine_test.dart`
- `test/services/effective_theory_injector_service_test.dart`
- `test/services/goal_reengagement_service_test.dart`
- `test/services/goal_reminder_engine_test.dart`
- `test/services/goal_slot_allocator_test.dart`
- `test/services/goal_smart_suggestion_engine_test.dart`
- `test/services/goal_suggestion_service_test.dart`
- `test/services/goal_to_training_launcher_test.dart`
- `test/services/inbox_booster_tuner_service_test.dart`
- `test/services/inline_theory_linker_cache_test.dart`
- `test/services/inline_theory_linker_test.dart`
- `test/services/learning_path_gatekeeper_service_test.dart`
- `test/services/learning_path_progress_engine_test.dart`
- `test/services/learning_path_stats_service_test.dart`
- `test/services/learning_path_summary_cache_v2_test.dart`
- `test/services/learning_path_unlock_engine_test.dart`
- `test/services/learning_track_recommendation_engine_test.dart`
- `test/services/next_up_engine_test.dart`
- `test/services/overlay_decay_booster_orchestrator_test.dart`
- `test/services/pack_format_selection_service_test.dart`
- `test/services/pack_library_service_test.dart`
- `test/services/pack_suggestion_analytics_engine_test.dart`
- `test/services/recall_tag_decay_summary_service_test.dart`
- `test/services/recap_banner_injector_test.dart`
- `test/services/recap_opportunity_detector_test.dart`
- `test/services/recap_tag_analytics_service_test.dart`
- `test/services/skill_decay_tag_filter_test.dart`
- `test/services/skill_gap_detector_service_test.dart`
- `test/services/skill_map_booster_recommender_test.dart`
- `test/services/skill_tag_decay_tracker_test.dart`
- `test/services/smart_booster_unlocker_test.dart`
- `test/services/smart_decay_goal_generator_test.dart`
- `test/services/smart_goal_tracking_service_test.dart`
- `test/services/smart_recall_booster_scheduler_test.dart`
- `test/services/smart_recap_banner_controller_test.dart`
- `test/services/smart_recap_banner_reinjection_service_test.dart`
- `test/services/smart_recap_scheduler_test.dart`
- `test/services/smart_recap_suggestion_engine_stream_test.dart`
- `test/services/smart_recap_suggestion_engine_test.dart`
- `test/services/smart_skill_gap_booster_engine_test.dart`
- `test/services/smart_theory_recap_dismissal_memory_test.dart`
- `test/services/smart_theory_recap_score_weighting_test.dart`
- `test/services/smart_theory_suggestion_engine_test.dart`
- `test/services/tag_decay_forecast_service_test.dart`
- `test/services/theory_and_booster_flow_composer_test.dart`
- `test/services/theory_auto_recall_injector_test.dart`
- `test/services/theory_boost_trigger_service_test.dart`
- `test/services/theory_booster_candidate_picker_test.dart`
- `test/services/theory_booster_injection_service_test.dart`
- `test/services/theory_booster_recall_engine_test.dart`
- `test/services/theory_booster_training_launcher_test.dart`
- `test/services/theory_goal_completion_notifier_test.dart`
- `test/services/theory_goal_engine_test.dart`
- `test/services/theory_goal_recommender_test.dart`
- `test/services/theory_graph_navigation_engine_test.dart`
- `test/services/theory_lesson_cluster_linker_service_test.dart`
- `test/services/theory_lesson_effectiveness_analyzer_service_test.dart`
- `test/services/theory_lesson_graph_exporter_test.dart`
- `test/services/theory_lesson_graph_navigator_service_test.dart`
- `test/services/theory_lesson_navigator_service_test.dart`
- `test/services/theory_lesson_resume_engine_test.dart`
- `test/services/theory_lesson_tag_clusterer_test.dart`
- `test/services/theory_lesson_tag_heatmap_service_test.dart`
- `test/services/theory_lesson_unlock_notification_service_test.dart`
- `test/services/theory_mini_lesson_navigator_test.dart`
- `test/services/theory_path_preview_builder_test.dart`
- `test/services/theory_recall_efficiency_evaluator_service_test.dart`
- `test/services/theory_recall_inbox_reinjection_service_test.dart`
- `test/services/theory_recap_prompt_orchestrator_test.dart`
- `test/services/theory_reinforcement_banner_controller_test.dart`
- `test/services/theory_reinforcement_queue_service_test.dart`
- `test/services/theory_tag_decay_tracker_test.dart`
- `test/services/theory_tag_summary_service_test.dart`
- `test/services/theory_weakness_repeater_test.dart`
- `test/services/training_path_progress_service_v2_test.dart`
- `test/services/training_run_ab_comparator_service_test.dart`
- `test/smart_mini_booster_planner_test.dart`
- `test/smart_recap_auto_injector_test.dart`
- `test/tag_retention_tracker_test.dart`
- `test/theory_booster_injector_test.dart`
- `test/theory_lesson_reachability_validator_test.dart`
- `test/theory_lesson_review_queue_test.dart`
- `test/theory_smart_entry_point_selector_test.dart`
- `test/widgets/generated_pack_play_test.dart`
- `test/widgets/inline_theory_badge_test.dart`
- `test/widgets/inline_theory_link_chip_test.dart`
- `test/widgets/inline_theory_linker_widget_test.dart`
- `test/widgets/theory_lesson_context_overlay_test.dart`

#### Batch 3 Owner-review residuals
- `test/services/auto_recovery_trigger_service_test.dart`
- `test/services/booster_pack_launcher_test.dart`
- `test/services/learning_path_entry_group_builder_test.dart`
- `test/services/learning_path_launcher_service_test.dart`
- `test/services/learning_path_stage_launcher_test.dart`
- `test/services/pack_export_service_test.dart`
- `test/services/scheduled_training_launcher_test.dart`
- `test/services/scheduled_training_queue_service_test.dart`
- `test/services/skill_gap_booster_service_test.dart`
- `test/services/skill_loss_feed_engine_test.dart`
- `test/services/theory_booster_launcher_test.dart`
- `test/services/training_pack_search_index_builder_test.dart`
- `test/services/training_pack_search_service_test.dart`
- `test/services/weekly_planner_booster_engine_test.dart`
- `test/services/weekly_planner_booster_feed_test.dart`
- `test/training_pack_template_service_test.dart`
- `test/widgets/export_csv_button_test.dart`
- `test/widgets/review_path_card_test.dart`
- `test/widgets/training_session_summary_screen_test.dart`

## E. Suggested Ordering

1. Batch 1 first: it has the largest importer reduction (`176`) and reuses one canonical import strategy across enum/model/template files.
2. Batch 2 second: it removes the remaining low/medium-risk service-only importers (`101`) after model overlap has been cleared.
3. Batch 3 last: it is intentionally small (`19`) and isolates product-truth, localization, level/progress schema, and fake inheritance decisions for Codex review.

## F. Shim-Deletion Forecast

| Symbol | Delete after batch | Reason |
| --- | --- | --- |
| `ShareOptions` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `GameType` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `TrainingType` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `TrainingPackLevel` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `HeroPosition` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `HeroPositionLabel` | Already deletable after confirming no reflective/import side effect | Remaining consumers must be zero before deleting this shim symbol. |
| `TrainingPackTemplateV2` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `TagGoalProgress` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `HandData` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `isAutoReplayKind` | Batch 1 | Remaining consumers must be zero before deleting this shim symbol. |
| `TrainingSessionService` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `AppColors` | Already deletable after confirming no reflective/import side effect | Remaining consumers must be zero before deleting this shim symbol. |
| `MiniLessonLibraryService` | Batch 2 | Remaining consumers must be zero before deleting this shim symbol. |
| `PackLibraryService` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |
| `RecallSuccessLoggerService` | Batch 2 | Remaining consumers must be zero before deleting this shim symbol. |
| `SmartTheoryRecapDismissalMemory` | Batch 2 | Remaining consumers must be zero before deleting this shim symbol. |
| `AppLocalizations` | Batch 3 | Remaining consumers must be zero before deleting this shim symbol. |

## G. Residual Conflict Ledger

These files should not be assigned to mechanical Fable work because they require product-truth judgment, stale assertion triage, owner clarification, or compatibility-route decisions.

| File | Symbols | Reason |
| --- | --- | --- |
| `test/services/auto_recovery_trigger_service_test.dart` | `GameType`, `TrainingType`, `TrainingPackTemplateV2`, `TagGoalProgress`, `PackLibraryService` | progress fixture schema rewrite; PackLibraryService fake implementation |
| `test/services/booster_pack_launcher_test.dart` | `GameType`, `TrainingType`, `TrainingSessionService`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/learning_path_entry_group_builder_test.dart` | `TrainingType`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/learning_path_launcher_service_test.dart` | `GameType`, `TrainingType`, `TrainingSessionService`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/learning_path_stage_launcher_test.dart` | `GameType`, `TrainingType`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/pack_export_service_test.dart` | `ShareOptions`, `HeroPosition` | share/export owner decision |
| `test/services/scheduled_training_launcher_test.dart` | `GameType`, `TrainingType`, `TrainingPackTemplateV2`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/scheduled_training_queue_service_test.dart` | `GameType`, `TrainingType`, `TrainingPackTemplateV2`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/skill_gap_booster_service_test.dart` | `GameType`, `TrainingType`, `TrainingPackTemplateV2`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/skill_loss_feed_engine_test.dart` | `GameType`, `TrainingType`, `TrainingPackTemplateV2`, `TagGoalProgress`, `PackLibraryService` | progress fixture schema rewrite; PackLibraryService fake implementation |
| `test/services/theory_booster_launcher_test.dart` | `GameType`, `TrainingType`, `TrainingPackLevel`, `TrainingPackTemplateV2`, `TrainingSessionService` | level enum value mapping |
| `test/services/training_pack_search_index_builder_test.dart` | `TrainingType`, `TrainingPackLevel`, `TrainingPackTemplateV2` | level enum value mapping |
| `test/services/training_pack_search_service_test.dart` | `GameType`, `TrainingType`, `TrainingPackLevel`, `TrainingPackTemplateV2` | level enum value mapping |
| `test/services/weekly_planner_booster_engine_test.dart` | `PackLibraryService` | PackLibraryService fake implementation |
| `test/services/weekly_planner_booster_feed_test.dart` | `TrainingType`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/training_pack_template_service_test.dart` | `AppLocalizations` | generated localization/delegate authority |
| `test/widgets/export_csv_button_test.dart` | `ShareOptions`, `HeroPosition` | share/export owner decision |
| `test/widgets/review_path_card_test.dart` | `GameType`, `TrainingType`, `PackLibraryService` | PackLibraryService fake implementation |
| `test/widgets/training_session_summary_screen_test.dart` | `TrainingType`, `HeroPosition`, `TrainingPackTemplateV2`, `HandData`, `TrainingSessionService`, `AppLocalizations` | generated localization/delegate authority; TrainingSessionService fake inheritance |

## Coverage Validation

- Batch 1 files: `176`
- Batch 2 files: `101`
- Residual owner-review files: `19`
- Union coverage: `296` of `296`
- Duplicate files across groups: `0`
- Missing files: `0`

## Final Recommended Implementation Sequence

1. Fable Low: Batch 1 core enum/model/template cleanup. Use canonical imports and only local constructor/enum argument adaptations necessary to preserve existing assertions.
2. Fable Medium: Batch 2 service/local fake cleanup. Use local test fakes where canonical services are singleton/private-constructor or async-shifted.
3. Codex Low: Batch 3 owner-review residuals. Decide share/export authority, localization authority, level/progress fixture mapping, and service fake inheritance/implements replacements before deleting the remaining shim symbols.
