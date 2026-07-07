# Test Authority Migration Phase 0 Evidence Freeze v1

Status: EVIDENCE FREEZE. Branch source: canonical `main` plus donor machine log. No product behavior migration is implemented here.

## Git Inputs

- Base main HEAD: `c2987f9db0073dfbe8bbcf46d395615dc9e3655b`
- Donor branch HEAD: `60e4e02e0e0d9340869e1ba5282407cf4224d7b6`

## A. Shim Consumer Totals

- Shim importing files: `921`
- Shim import lines: `922`
- Classification counts: `{'unused_import': 610, 'mixed_consumer': 296, 'shadow_type_consumer': 13, 'genuine_fake_only_consumer': 2}`

### Per-Symbol Matrix

| Symbol | Canonical equivalent | Importer count | Direct-use count | Mixed-use count | Genuine fake or shadow | Migration action |
| --- | --- | --- | --- | --- | --- | --- |
| ShareOptions | lib/share/share_options.dart or product-specific sharing facade (missing exact canonical owner) | 921 | 3 | 0 | shadow | replace shim import with canonical import |
| GameType | lib/models/game_type.dart | 921 | 45 | 41 | shadow | replace shim import with canonical import |
| TrainingType | lib/core/training/engine/training_type_engine.dart | 921 | 139 | 130 | shadow | replace shim import with canonical import |
| TrainingPackLevel | lib/models/v2/pack_ux_metadata.dart | 921 | 4 | 3 | shadow | replace shim import with canonical import |
| HeroPosition | lib/models/v2/hero_position.dart | 921 | 59 | 54 | shadow | replace shim import with canonical import |
| HeroPositionLabel | lib/models/v2/hero_position.dart / lib/utils/hero_position_ext.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| TrainingPackTemplateV2 | lib/models/v2/training_pack_template_v2.dart | 921 | 71 | 69 | shadow | replace shim import with canonical import |
| MixedDrillStat | lib/models/mixed_drill_stat.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| TagGoalProgress | lib/models/tag_goal_progress.dart | 921 | 2 | 2 | shadow | replace shim import with canonical import |
| HandData | lib/models/v2/hand_data.dart | 921 | 103 | 99 | shadow | replace shim import with canonical import |
| parseYamlToMap | canonical YAML parser helper, not shim-owned (missing exact owner) | 921 | 1 | 0 | genuine_fake | localize fake/test helper or move to named test utility |
| isAutoReplayKind | lib/ui/session_player/spot_specs.dart | 921 | 5 | 5 | shadow | replace shim import with canonical import |
| ShimLastModifiedDir | dart:io Directory extension test helper | 921 | 0 | 0 | genuine_fake | localize fake/test helper or move to named test utility |
| ShimLastModifiedFile | dart:io File extension test helper | 921 | 0 | 0 | genuine_fake | localize fake/test helper or move to named test utility |
| setLastModified | dart:io File/Directory setLastModified extension helper | 921 | 1 | 0 | genuine_fake | localize fake/test helper or move to named test utility |
| MixedDrillHistoryService | lib/services/mixed_drill_history_service.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| TrainingSessionService | lib/services/training_session_service.dart | 921 | 66 | 63 | shadow | replace shim import with canonical import |
| TrainingPackService | lib/services/training_pack_service.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| RecentTrainingPackSection | lib/widgets/v2/recent_training_pack_section.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| FilterSummaryBar | lib/widgets/filter_summary_bar.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| AppColors | lib/theme/app_colors.dart | 921 | 0 | 0 | shadow | replace shim import with canonical import |
| MiniLessonLibraryService | lib/services/mini_lesson_library_service.dart | 921 | 66 | 66 | shadow | replace shim import with canonical import |
| PackLibraryService | lib/services/pack_library_service.dart | 921 | 13 | 13 | shadow | replace shim import with canonical import |
| RecallSuccessLoggerService | lib/services/recall_success_logger_service.dart | 921 | 7 | 7 | shadow | replace shim import with canonical import |
| SmartTheoryRecapDismissalMemory | lib/services/smart_theory_recap_dismissal_memory.dart | 921 | 4 | 4 | shadow | replace shim import with canonical import |
| AppLocalizations | lib/l10n/app_localizations.dart or lib/flutter_gen/gen_l10n/app_localizations.dart | 921 | 2 | 2 | shadow | replace shim import with canonical import |
| _ignore | local dead-code suppression helper, no production equivalent | 921 | 0 | 0 | genuine_fake | localize fake/test helper or move to named test utility |

### 921-File Consumer Classification

| File | Classification | Shadow symbols used | Fake/helper symbols used | Mixed canonical imports |
| --- | --- | --- | --- | --- |
| test/accuracy_utils_test.dart | unused_import | - | - | - |
| test/action_entry_test.dart | unused_import | - | - | - |
| test/actions_subtitle_smoke_test.dart | unused_import | - | - | - |
| test/architecture/converter_discovery_plugin_test.dart | unused_import | - | - | - |
| test/architecture/converter_pipeline_test.dart | unused_import | - | - | - |
| test/architecture/converter_registry_test.dart | unused_import | - | - | - |
| test/architecture/evaluation_queue_service_test.dart | unused_import | - | - | - |
| test/architecture/new_converters_test.dart | unused_import | - | - | - |
| test/architecture/plugin_manager_test.dart | unused_import | - | - | - |
| test/architecture/service_registry_test.dart | unused_import | - | - | - |
| test/auto_booster_pruner_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/auto_decay_spot_generator_test.dart | unused_import | - | - | - |
| test/auto_replay_guard_test.dart | unused_import | - | - | - |
| test/auto_replay_invariants_test.dart | mixed_consumer | isAutoReplayKind | - | isAutoReplayKind |
| test/auto_start_training_prompt_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/auto_theory_review_engine_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | MiniLessonLibraryService |
| test/auto_theory_rewriter_test.dart | unused_import | - | - | - |
| test/auto_theory_stage_seeder_test.dart | unused_import | - | - | - |
| test/autogen_stats_test.dart | unused_import | - | - | - |
| test/bet_sizer_test.dart | unused_import | - | - | - |
| test/board_filtering_params_builder_test.dart | unused_import | - | - | - |
| test/board_similarity_engine_test.dart | unused_import | - | - | - |
| test/board_street_generator_test.dart | unused_import | - | - | - |
| test/board_textures_test.dart | unused_import | - | - | - |
| test/booster_cluster_engine_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/booster_injection_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/booster_mistake_backlink_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/booster_pack_cluster_exporter_test.dart | unused_import | - | - | - |
| test/booster_similarity_engine_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/booster_smart_selector_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/booster_thematic_tagger_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/booster_theory_pack_linker_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/booster_theory_usage_audit_service_test.dart | unused_import | - | - | - |
| test/booster_variation_injector_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/canonical_guard_test.dart | unused_import | - | - | - |
| test/cash_l3_pack_test.dart | unused_import | - | - | - |
| test/ci_canary_test.dart | unused_import | - | - | - |
| test/ci_report_soft_test.dart | unused_import | - | - | - |
| test/clipboard_detection_test.dart | unused_import | - | - | - |
| test/content_audit_smoke_test.dart | unused_import | - | - | - |
| test/content_manifest_test.dart | unused_import | - | - | - |
| test/content_schema_test.dart | unused_import | - | - | - |
| test/controllers/pack_run_controller_test.dart | unused_import | - | - | - |
| test/controllers/poker_analyzer_controller_test.dart | unused_import | - | - | - |
| test/converter_validation_test.dart | unused_import | - | - | - |
| test/core/models/spot_seed/legacy_seed_adapter_test.dart | unused_import | - | - | - |
| test/core/models/spot_seed/spot_seed_codec_test.dart | unused_import | - | - | - |
| test/core/models/spot_seed/spot_seed_validator_test.dart | unused_import | - | - | - |
| test/core/texture_filter_engine_test.dart | unused_import | - | - | - |
| test/core/training/training_pack_exporter_v2_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/coverage_summary_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/csv_io_test.dart | unused_import | - | - | - |
| test/curriculum_consistency_test.dart | unused_import | - | - | - |
| test/curriculum_next_test.dart | unused_import | - | - | - |
| test/curriculum_overlay_guard_test.dart | unused_import | - | - | - |
| test/curriculum_status_guard_test.dart | unused_import | - | - | - |
| test/curriculum_status_test.dart | unused_import | - | - | - |
| test/curriculum_structure_doc_link_test.dart | unused_import | - | - | - |
| test/date_utils_test.dart | unused_import | - | - | - |
| test/duplicate_spot_detection_test.dart | mixed_consumer | HandData | - | HandData |
| test/duplicates_only_filter_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/dynamic_spot_generation_test.dart | unused_import | - | - | - |
| test/e2e_ab_exposure_test.dart | unused_import | - | - | - |
| test/e2e_adaptive_closed_loop_test.dart | unused_import | - | - | - |
| test/e2e_adaptive_plan_injection_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/e2e_adaptive_training_planner_v2_test.dart | unused_import | - | - | - |
| test/e2e_concurrency_locking_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/e2e_idempotent_retry_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/e2e_path_hardening_rollback_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/e2e_theory_injection_path_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/e2e_theory_injection_smoke_test.dart | unused_import | - | - | - |
| test/ev/_cli_help_smoke_test.dart | unused_import | - | - | - |
| test/ev/l3_autogen_v4_smoke_test.dart | unused_import | - | - | - |
| test/ev_icm_history_chart_test.dart | unused_import | - | - | - |
| test/ev_icm_trend_chart_test.dart | unused_import | - | - | - |
| test/ev_summary_bucketize_test.dart | unused_import | - | - | - |
| test/evaluation_executor_service_test.dart | mixed_consumer | HandData | - | HandData |
| test/full_board_generator_multi_street_test.dart | unused_import | - | - | - |
| test/full_board_generator_service_test.dart | unused_import | - | - | - |
| test/full_board_generator_texture_tags_test.dart | unused_import | - | - | - |
| test/full_board_generator_v2_test.dart | unused_import | - | - | - |
| test/game_mode_profile_engine_test.dart | unused_import | - | - | - |
| test/generate_from_preset_test.dart | unused_import | - | - | - |
| test/generate_research_prompts_test.dart | unused_import | - | - | - |
| test/graph_path_template_generator_test.dart | unused_import | - | - | - |
| test/graph_path_template_parser_test.dart | unused_import | - | - | - |
| test/graph_path_template_validator_test.dart | unused_import | - | - | - |
| test/graph_template_exporter_test.dart | unused_import | - | - | - |
| test/hand_history_parsing_test.dart | unused_import | - | - | - |
| test/headless/training_pack_multi_output_deterministic_test.dart | unused_import | - | - | - |
| test/helpers/action_utils_test.dart | unused_import | - | - | - |
| test/history_csv_test.dart | unused_import | - | - | - |
| test/icm_bb_packs_smoke_test.dart | unused_import | - | - | - |
| test/icm_bubble_packs_smoke_test.dart | unused_import | - | - | - |
| test/icm_l4_bb_pack_test.dart | unused_import | - | - | - |
| test/icm_l4_bubble_pack_test.dart | unused_import | - | - | - |
| test/icm_l4_ladder_pack_test.dart | unused_import | - | - | - |
| test/icm_l4_mix_pack_test.dart | unused_import | - | - | - |
| test/icm_l4_sb_pack_test.dart | unused_import | - | - | - |
| test/icm_ladder_packs_smoke_test.dart | unused_import | - | - | - |
| test/icm_mix_packs_smoke_test.dart | unused_import | - | - | - |
| test/icm_push_ev_service_test.dart | unused_import | - | - | - |
| test/icm_sb_packs_smoke_test.dart | unused_import | - | - | - |
| test/icm_weight_distributor_test.dart | unused_import | - | - | - |
| test/import_dup_hint_test.dart | mixed_consumer | HandData | - | HandData |
| test/injection_block_assembler_test.dart | unused_import | - | - | - |
| test/inline_theory_node_linker_test.dart | unused_import | - | - | - |
| test/intro_theory_pack_generator_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/jam_dedup_key_test.dart | unused_import | - | - | - |
| test/jsonl_importer_roundtrip_test.dart | unused_import | - | - | - |
| test/jsonl_loader_test.dart | unused_import | - | - | - |
| test/jsonl_validator_test.dart | unused_import | - | - | - |
| test/kpi_fields_test.dart | unused_import | - | - | - |
| test/kpi_gate_test.dart | unused_import | - | - | - |
| test/l2_autogen_smoke_test.dart | unused_import | - | - | - |
| test/l2_metrics_smoke_test.dart | unused_import | - | - | - |
| test/l2_packs_validator_test.dart | unused_import | - | - | - |
| test/l2_smoke_gen_test.dart | unused_import | - | - | - |
| test/l3_autogen_distribution_test.dart | unused_import | - | - | - |
| test/l3_cli_weights_conflict_warning_test.dart | unused_import | - | - | - |
| test/l3_cli_weights_invalid_json_test.dart | unused_import | - | - | - |
| test/l3_cli_weights_no_conflict_warning_test.dart | unused_import | - | - | - |
| test/l3_demo_sampler_test.dart | unused_import | - | - | - |
| test/l3_ev_model_test.dart | unused_import | - | - | - |
| test/l3_evaluator_rules_test.dart | unused_import | - | - | - |
| test/l3_evaluator_weights_config_test.dart | unused_import | - | - | - |
| test/l3_feasibility_test.dart | unused_import | - | - | - |
| test/l3_jsonl_decode_test.dart | unused_import | - | - | - |
| test/l3_jsonl_export_test.dart | unused_import | - | - | - |
| test/l3_metrics_smoke_test.dart | unused_import | - | - | - |
| test/l3_packrun_cli_test.dart | unused_import | - | - | - |
| test/l3_packrun_explain_smoke_test.dart | unused_import | - | - | - |
| test/l3_packrun_presetcounts_test.dart | unused_import | - | - | - |
| test/l3_texture_keys_contract_test.dart | unused_import | - | - | - |
| test/l3_weights_presets_test.dart | unused_import | - | - | - |
| test/l4_icm_sb_jam_vs_fold_test.dart | mixed_consumer | isAutoReplayKind | - | isAutoReplayKind |
| test/ladder_outcome_smoke_test.dart | unused_import | - | - | - |
| test/learning_heatmap_service_test.dart | unused_import | - | - | - |
| test/learning_path_auto_expander_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/learning_path_auto_pack_assigner_test.dart | unused_import | - | - | - |
| test/learning_path_auto_seeder_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/learning_path_config_loader_test.dart | unused_import | - | - | - |
| test/learning_path_controller_gating_test.dart | unused_import | - | - | - |
| test/learning_path_engine_core_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/learning_path_graph_orchestrator_test.dart | unused_import | - | - | - |
| test/learning_path_library_generator_test.dart | unused_import | - | - | - |
| test/learning_path_library_validator_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/learning_path_orchestrator_test.dart | unused_import | - | - | - |
| test/learning_path_pack_validator_test.dart | unused_import | - | - | - |
| test/learning_path_progress_service_fallback_test.dart | unused_import | - | - | - |
| test/learning_path_promoter_test.dart | unused_import | - | - | - |
| test/learning_path_registry_service_test.dart | unused_import | - | - | - |
| test/learning_path_stage_seeder_test.dart | unused_import | - | - | - |
| test/learning_path_stage_template_generator_test.dart | unused_import | - | - | - |
| test/learning_path_stage_unlock_engine_test.dart | unused_import | - | - | - |
| test/learning_path_stage_unlock_engine_v2_test.dart | unused_import | - | - | - |
| test/learning_path_template_builder_test.dart | unused_import | - | - | - |
| test/learning_path_template_validator_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/learning_path_unlock_engine_path_test.dart | unused_import | - | - | - |
| test/learning_path_validator_test.dart | shadow_type_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | - |
| test/learning_track_progress_model_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/lesson_search_engine_test.dart | unused_import | - | - | - |
| test/level_tag_auto_assigner_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/line_graph_builder_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/line_graph_engine_test.dart | unused_import | - | - | - |
| test/live_actions_test.dart | unused_import | - | - | - |
| test/live_badges_test.dart | unused_import | - | - | - |
| test/live_barrel_test.dart | unused_import | - | - | - |
| test/live_content_coverage_test.dart | unused_import | - | - | - |
| test/live_context_format_test.dart | unused_import | - | - | - |
| test/live_context_test.dart | unused_import | - | - | - |
| test/live_defaults_test.dart | unused_import | - | - | - |
| test/live_event_adapter_test.dart | unused_import | - | - | - |
| test/live_ids_consistency_test.dart | unused_import | - | - | - |
| test/live_integration_test.dart | unused_import | - | - | - |
| test/live_messages_test.dart | unused_import | - | - | - |
| test/live_mode_persistence_test.dart | unused_import | - | - | - |
| test/live_mode_test.dart | unused_import | - | - | - |
| test/live_module_utils_test.dart | unused_import | - | - | - |
| test/live_no_flutter_imports_test.dart | unused_import | - | - | - |
| test/live_progress_test.dart | unused_import | - | - | - |
| test/live_runtime_test.dart | unused_import | - | - | - |
| test/live_smoke_test.dart | unused_import | - | - | - |
| test/live_telemetry_test.dart | unused_import | - | - | - |
| test/live_validators_test.dart | unused_import | - | - | - |
| test/manual_legacy_pack_validation_test.dart | unused_import | - | - | - |
| test/mini_lesson_auto_injector_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/mini_lesson_booster_engine_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/mini_lesson_library_builder_test.dart | unused_import | - | - | - |
| test/mini_lesson_pack_generator_test.dart | unused_import | - | - | - |
| test/mini_lesson_pack_importer_test.dart | unused_import | - | - | - |
| test/mini_lesson_path_injector_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/mini_lesson_scheduler_test.dart | unused_import | - | - | - |
| test/missing_only_filter_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/missing_pack_resolver_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/mistake_categorization_engine_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/mistake_cluster_analytics_service_test.dart | unused_import | - | - | - |
| test/mistake_tag_classifier_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/mistake_tag_cluster_service_test.dart | unused_import | - | - | - |
| test/mistakes_only_quick_filter_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/models/autogen_status_serialization_test.dart | unused_import | - | - | - |
| test/models/generate_missing_spots_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/models/learning_branch_node_test.dart | unused_import | - | - | - |
| test/models/learning_path_substage_test.dart | unused_import | - | - | - |
| test/models/learning_track_section_model_test.dart | unused_import | - | - | - |
| test/models/skill_tree_node_model_test.dart | unused_import | - | - | - |
| test/models/template_generate_spots_test.dart | unused_import | - | - | - |
| test/models/training_pack_template_v2_hand_group_tags_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/mvp_pack_library_test.dart | unused_import | - | - | - |
| test/new_only_filter_test.dart | unused_import | - | - | - |
| test/pack_augmentation_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/pack_completion_stats_service_test.dart | unused_import | - | - | - |
| test/pack_library_generator_test.dart | unused_import | - | - | - |
| test/pack_run_controller_test.dart | unused_import | - | - | - |
| test/pack_run_session_state_test.dart | unused_import | - | - | - |
| test/pack_search_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/pack_search_index_service_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/pack_similarity_engine_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2 |
| test/pack_unlocking_rules_engine_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2 |
| test/pack_yaml_config_parser_test.dart | unused_import | - | - | - |
| test/packs_manifest_test.dart | unused_import | - | - | - |
| test/path_suggestion_engine_test.dart | unused_import | - | - | - |
| test/plugin_loader_io_test.dart | unused_import | - | - | - |
| test/presenters/completed_session_history_presenter_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/push_fold_btn_cash_library_test.dart | unused_import | - | - | - |
| test/push_fold_helpers_test.dart | unused_import | - | - | - |
| test/quarantine/ev_end_to_end_golden_test.dart | unused_import | - | - | - |
| test/quarantine/ev_enrich_jam_fold_cli_test.dart | unused_import | - | - | - |
| test/quarantine/ev_rank_jam_fold_cli_help_test.dart | unused_import | - | - | - |
| test/quarantine/ev_rank_jam_fold_cli_test.dart | unused_import | - | - | - |
| test/quarantine/ev_report_jam_fold_cli_test.dart | unused_import | - | - | - |
| test/quarantine/ev_summary_jam_fold_cli_test.dart | unused_import | - | - | - |
| test/quarantine/jam_fold_evaluator_test.dart | unused_import | - | - | - |
| test/range_library_service_test.dart | unused_import | - | - | - |
| test/recall_cooldown_test.dart | unused_import | - | - | - |
| test/remedial_analyzer_test.dart | mixed_consumer | HandData | - | HandData |
| test/remedial_generation_controller_test.dart | unused_import | - | - | - |
| test/remedial_pack_generator_test.dart | unused_import | - | - | - |
| test/report_csv_test.dart | unused_import | - | - | - |
| test/result_summary_json_test.dart | unused_import | - | - | - |
| test/review_path_recommender_test.dart | unused_import | - | - | - |
| test/rich_id_labels_test.dart | unused_import | - | - | - |
| test/room_hand_history_importer_test.dart | unused_import | - | - | - |
| test/saved_hand_service_test.dart | unused_import | - | - | - |
| test/screens/main_menu_screen_test.dart | unused_import | - | - | - |
| test/select_duplicates_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/ab_orchestrator_service_test.dart | unused_import | - | - | - |
| test/services/adaptive_learning_flow_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/services/adaptive_next_step_engine_test.dart | unused_import | - | - | - |
| test/services/adaptive_outcome_tracker_test.dart | unused_import | - | - | - |
| test/services/adaptive_pack_inbox_notifier_test.dart | mixed_consumer | TrainingSessionService, TrainingType | - | TrainingType, TrainingSessionService |
| test/services/adaptive_plan_executor_budget_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/adaptive_plan_executor_idempotency_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/adaptive_scheduler_service_test.dart | unused_import | - | - | - |
| test/services/adaptive_spot_scheduler_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/adaptive_theory_scheduler_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/services/adaptive_training_path_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/adaptive_training_planner_test.dart | unused_import | - | - | - |
| test/services/assessment_pack_synthesizer_test.dart | unused_import | - | - | - |
| test/services/auto_advance_pack_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/auto_format_selector_test.dart | unused_import | - | - | - |
| test/services/auto_recovery_trigger_service_test.dart | mixed_consumer | GameType, PackLibraryService, TagGoalProgress, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, TagGoalProgress, PackLibraryService |
| test/services/auto_skill_gap_clusterer_test.dart | unused_import | - | - | - |
| test/services/auto_spot_theory_injector_service_test.dart | mixed_consumer | HandData, MiniLessonLibraryService | - | HandData, MiniLessonLibraryService |
| test/services/auto_theory_booster_launcher_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/auto_theory_review_engine_recommendation_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/autogen_error_stats_logger_test.dart | unused_import | - | - | - |
| test/services/autogen_library_publisher_service_test.dart | unused_import | - | - | - |
| test/services/autogen_metrics_history_service_test.dart | unused_import | - | - | - |
| test/services/autogen_pack_error_classifier_service_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/autogen_real_time_stats_refresher_service_test.dart | unused_import | - | - | - |
| test/services/autogen_run_history_logger_service_test.dart | unused_import | - | - | - |
| test/services/autogen_status_dashboard_seed_issue_test.dart | unused_import | - | - | - |
| test/services/autogen_status_dashboard_service_stream_test.dart | unused_import | - | - | - |
| test/services/autogen_status_dashboard_service_test.dart | unused_import | - | - | - |
| test/services/bandit_weight_learner_test.dart | unused_import | - | - | - |
| test/services/banner_queue_service_test.dart | unused_import | - | - | - |
| test/services/board_cluster_constraint_engine_test.dart | unused_import | - | - | - |
| test/services/board_filtering_service_v2_test.dart | unused_import | - | - | - |
| test/services/board_filtering_tag_library_service_test.dart | unused_import | - | - | - |
| test/services/board_texture_classifier_service_test.dart | unused_import | - | - | - |
| test/services/board_texture_classifier_test.dart | unused_import | - | - | - |
| test/services/board_texture_filter_service_test.dart | unused_import | - | - | - |
| test/services/board_texture_preset_library_test.dart | unused_import | - | - | - |
| test/services/booster_adaptation_tuner_test.dart | unused_import | - | - | - |
| test/services/booster_completion_tracker_test.dart | unused_import | - | - | - |
| test/services/booster_cooldown_blocker_service_test.dart | unused_import | - | - | - |
| test/services/booster_cooldown_scheduler_test.dart | unused_import | - | - | - |
| test/services/booster_effectiveness_analyzer_test.dart | unused_import | - | - | - |
| test/services/booster_exclusion_analytics_dashboard_service_test.dart | unused_import | - | - | - |
| test/services/booster_fatigue_guard_test.dart | unused_import | - | - | - |
| test/services/booster_goal_recommender_test.dart | unused_import | - | - | - |
| test/services/booster_inbox_delivery_service_test.dart | unused_import | - | - | - |
| test/services/booster_injection_orchestrator_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, TrainingSessionService |
| test/services/booster_lesson_status_service_test.dart | unused_import | - | - | - |
| test/services/booster_mistake_recorder_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/booster_pack_auto_fix_engine_test.dart | unused_import | - | - | - |
| test/services/booster_pack_changelog_generator_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/booster_pack_launcher_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingSessionService, PackLibraryService |
| test/services/booster_pack_validator_service_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/services/booster_path_history_service_test.dart | unused_import | - | - | - |
| test/services/booster_preview_launcher_test.dart | mixed_consumer | GameType, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingSessionService |
| test/services/booster_queue_pressure_monitor_test.dart | unused_import | - | - | - |
| test/services/booster_recall_scheduler_test.dart | unused_import | - | - | - |
| test/services/booster_refiner_engine_test.dart | mixed_consumer | GameType, HandData, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, HandData |
| test/services/booster_session_tracker_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/booster_slot_allocator_decide_test.dart | unused_import | - | - | - |
| test/services/booster_slot_allocator_test.dart | unused_import | - | - | - |
| test/services/booster_stats_tracker_service_test.dart | unused_import | - | - | - |
| test/services/booster_suggestion_engine_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/booster_theory_injector_test.dart | mixed_consumer | HandData, TrainingSessionService | - | HandData |
| test/services/built_in_pack_bootstrap_service_test.dart | unused_import | - | - | - |
| test/services/cloud_sync_local_test.dart | unused_import | - | - | - |
| test/services/cloud_sync_service_test.dart | unused_import | - | - | - |
| test/services/cluster_review_booster_builder_test.dart | unused_import | - | - | - |
| test/services/completed_session_summary_service_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2 |
| test/services/completed_training_pack_registry_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/services/constraint_resolver_engine_generation_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/constraint_resolver_engine_test.dart | unused_import | - | - | - |
| test/services/constraint_resolver_engine_v2_test.dart | unused_import | - | - | - |
| test/services/constraint_resolver_v3_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/services/daily_streak_tracker_service_test.dart | unused_import | - | - | - |
| test/services/decay_analytics_exporter_service_test.dart | unused_import | - | - | - |
| test/services/decay_badge_banner_controller_test.dart | unused_import | - | - | - |
| test/services/decay_booster_injector_scheduler_test.dart | unused_import | - | - | - |
| test/services/decay_booster_reminder_engine_test.dart | unused_import | - | - | - |
| test/services/decay_booster_reminder_orchestrator_test.dart | unused_import | - | - | - |
| test/services/decay_booster_reminder_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/decay_booster_spot_injector_test.dart | mixed_consumer | GameType, MiniLessonLibraryService, TrainingType | - | TrainingType, MiniLessonLibraryService |
| test/services/decay_booster_training_launcher_test.dart | unused_import | - | - | - |
| test/services/decay_forecast_alert_service_test.dart | unused_import | - | - | - |
| test/services/decay_forecast_engine_test.dart | unused_import | - | - | - |
| test/services/decay_heatmap_model_generator_test.dart | unused_import | - | - | - |
| test/services/decay_hotspot_stats_aggregator_service_test.dart | unused_import | - | - | - |
| test/services/decay_recall_mastery_integrator_test.dart | unused_import | - | - | - |
| test/services/decay_recall_tuner_engine_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/decay_review_frequency_advisor_service_test.dart | unused_import | - | - | - |
| test/services/decay_smart_scheduler_service_test.dart | unused_import | - | - | - |
| test/services/decay_streak_badge_notifier_test.dart | unused_import | - | - | - |
| test/services/decay_streak_tracker_service_test.dart | unused_import | - | - | - |
| test/services/decay_tag_retention_tracker_service_test.dart | unused_import | - | - | - |
| test/services/deduplication_policy_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/services/diff_snapshot_service_test.dart | unused_import | - | - | - |
| test/services/dynamic_board_tagger_service_test.dart | unused_import | - | - | - |
| test/services/dynamic_track_builder_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/services/effective_theory_injector_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/file_write_lock_service_test.dart | unused_import | - | - | - |
| test/services/generated_pack_history_service_test.dart | unused_import | - | - | - |
| test/services/goal_completion_engine_test.dart | unused_import | - | - | - |
| test/services/goal_inbox_delivery_controller_test.dart | unused_import | - | - | - |
| test/services/goal_progress_persistence_service_test.dart | unused_import | - | - | - |
| test/services/goal_reengagement_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/goal_reminder_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/goal_slot_allocator_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/goal_smart_suggestion_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/goal_streak_tracker_service_test.dart | unused_import | - | - | - |
| test/services/goal_suggestion_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/goal_to_training_launcher_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/hand_group_tag_library_service_test.dart | unused_import | - | - | - |
| test/services/icm_push_ev_service_test.dart | unused_import | - | - | - |
| test/services/icm_scenario_library_injector_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2 | - | TrainingPackTemplateV2, HandData |
| test/services/inbox_booster_delivery_controller_test.dart | unused_import | - | - | - |
| test/services/inbox_booster_tracker_service_test.dart | unused_import | - | - | - |
| test/services/inbox_booster_tuner_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/inbox_delivery_rule_simulator_service_test.dart | unused_import | - | - | - |
| test/services/inline_pack_theory_clusterer_test.dart | unused_import | - | - | - |
| test/services/inline_theory_link_auto_injector_test.dart | shadow_type_consumer | HandData | - | - |
| test/services/inline_theory_linker_cache_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/inline_theory_linker_pack_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/services/inline_theory_linker_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/interleave_sr_prefs_test.dart | unused_import | - | - | - |
| test/services/learning_goal_engine_test.dart | unused_import | - | - | - |
| test/services/learning_path_advisor_test.dart | unused_import | - | - | - |
| test/services/learning_path_booster_engine_test.dart | mixed_consumer | TrainingSessionService, TrainingType | - | TrainingType, TrainingSessionService |
| test/services/learning_path_completion_engine_test.dart | unused_import | - | - | - |
| test/services/learning_path_composer_test.dart | unused_import | - | - | - |
| test/services/learning_path_entry_group_builder_test.dart | mixed_consumer | PackLibraryService, TrainingType | - | TrainingType, PackLibraryService |
| test/services/learning_path_gatekeeper_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/learning_path_launcher_service_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingSessionService, PackLibraryService |
| test/services/learning_path_node_renderer_service_test.dart | unused_import | - | - | - |
| test/services/learning_path_player_progress_service_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/learning_path_progress_engine_v2_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_service_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_service_v2_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_tracker_service_substage_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_tracker_service_test.dart | unused_import | - | - | - |
| test/services/learning_path_progress_tracker_tag_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/services/learning_path_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/learning_path_renderer_test.dart | unused_import | - | - | - |
| test/services/learning_path_stage_completion_engine_test.dart | unused_import | - | - | - |
| test/services/learning_path_stage_launcher_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingType | - | GameType, TrainingType, PackLibraryService |
| test/services/learning_path_stage_ui_status_engine_test.dart | unused_import | - | - | - |
| test/services/learning_path_stats_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/learning_path_store_test.dart | unused_import | - | - | - |
| test/services/learning_path_summary_cache_v2_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/learning_path_telemetry_test.dart | unused_import | - | - | - |
| test/services/learning_path_unlock_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/learning_plan_cache_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/learning_stage_level_test.dart | unused_import | - | - | - |
| test/services/learning_track_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/learning_track_recommendation_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/lesson_completion_milestone_toast_service_test.dart | unused_import | - | - | - |
| test/services/lesson_goal_engine_test.dart | unused_import | - | - | - |
| test/services/lesson_goal_streak_engine_test.dart | unused_import | - | - | - |
| test/services/lesson_loader_service_test.dart | unused_import | - | - | - |
| test/services/lesson_path_progress_service_test.dart | unused_import | - | - | - |
| test/services/lesson_progress_service_test.dart | unused_import | - | - | - |
| test/services/lesson_progress_tracker_service_test.dart | unused_import | - | - | - |
| test/services/lesson_step_filter_engine_test.dart | mixed_consumer | GameType | - | GameType |
| test/services/lesson_streak_engine_test.dart | unused_import | - | - | - |
| test/services/lesson_streak_tracker_service_test.dart | unused_import | - | - | - |
| test/services/lesson_track_unlock_engine_test.dart | unused_import | - | - | - |
| test/services/level2_pack_template_seeder_test.dart | unused_import | - | - | - |
| test/services/mastery_export_service_test.dart | unused_import | - | - | - |
| test/services/mastery_persistence_service_test.dart | unused_import | - | - | - |
| test/services/mastery_sync_service_test.dart | unused_import | - | - | - |
| test/services/mini_lesson_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/mistake_booster_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/mistake_drill_launcher_service_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingType | - | GameType, TrainingType, HeroPosition, HandData |
| test/services/mistake_driven_drill_pack_generator_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/mistake_history_query_service_test.dart | unused_import | - | - | - |
| test/services/mistake_replay_pack_generator_history_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/mistake_replay_pack_generator_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/services/mistake_tag_history_service_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/mistake_telemetry_store_test.dart | unused_import | - | - | - |
| test/services/next_step_advisor_service_test.dart | shadow_type_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | - |
| test/services/next_up_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/node_recommendation_service_test.dart | unused_import | - | - | - |
| test/services/nudge_fatigue_detector_service_test.dart | unused_import | - | - | - |
| test/services/offline_evaluator_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/open_3bet_spot_template_generator_service_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/services/open_limped_spot_template_generator_service_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/services/overlay_decay_booster_orchestrator_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/pack_export_service_test.dart | mixed_consumer | HeroPosition, ShareOptions | - | HeroPosition |
| test/services/pack_filter_service_theme_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/pack_fingerprint_comparer_service_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/pack_fingerprint_comparer_test.dart | unused_import | - | - | - |
| test/services/pack_format_selection_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/pack_generation_metrics_tracker_service_test.dart | unused_import | - | - | - |
| test/services/pack_generator_service_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/services/pack_generator_service_topn_test.dart | unused_import | - | - | - |
| test/services/pack_import_service_test.dart | shadow_type_consumer | HeroPosition | - | - |
| test/services/pack_library_auto_curator_service_test.dart | unused_import | - | - | - |
| test/services/pack_library_generator_service_test.dart | unused_import | - | - | - |
| test/services/pack_library_round_trip_validator_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/pack_library_service_test.dart | mixed_consumer | PackLibraryService | - | PackLibraryService |
| test/services/pack_novelty_guard_service_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/pack_quality_gatekeeper_service_test.dart | unused_import | - | - | - |
| test/services/pack_quality_inspector_service_test.dart | unused_import | - | - | - |
| test/services/pack_quality_score_calculator_service_test.dart | unused_import | - | - | - |
| test/services/pack_recall_stats_service_test.dart | unused_import | - | - | - |
| test/services/pack_review_stats_exporter_test.dart | unused_import | - | - | - |
| test/services/pack_suggestion_analytics_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/path_idempotency_guard_test.dart | unused_import | - | - | - |
| test/services/path_injection_engine_e2e_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/path_injection_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/pinned_block_resume_strategy_test.dart | unused_import | - | - | - |
| test/services/pinned_block_tracker_service_test.dart | unused_import | - | - | - |
| test/services/pinned_interaction_logger_service_test.dart | unused_import | - | - | - |
| test/services/pinned_learning_service_block_test.dart | unused_import | - | - | - |
| test/services/plan_signature_builder_test.dart | unused_import | - | - | - |
| test/services/postflop_jam_decision_template_generator_service_test.dart | unused_import | - | - | - |
| test/services/postflop_jam_decision_theory_linker_test.dart | mixed_consumer | HandData, MiniLessonLibraryService, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData, MiniLessonLibraryService |
| test/services/postflop_template_seeder_test.dart | unused_import | - | - | - |
| test/services/push_fold_ev_service_test.dart | unused_import | - | - | - |
| test/services/recall_boost_interaction_logger_test.dart | unused_import | - | - | - |
| test/services/recall_tag_decay_summary_service_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/recap_auto_repeat_scheduler_test.dart | unused_import | - | - | - |
| test/services/recap_banner_injector_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/recap_completion_tracker_test.dart | unused_import | - | - | - |
| test/services/recap_fatigue_evaluator_test.dart | unused_import | - | - | - |
| test/services/recap_opportunity_detector_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/recap_tag_analytics_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/recap_to_drill_launcher_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | TrainingType, TrainingPackTemplateV2, TrainingSessionService |
| test/services/recent_packs_service_test.dart | unused_import | - | - | - |
| test/services/review_streak_evaluator_service_test.dart | unused_import | - | - | - |
| test/services/reward_card_renderer_service_test.dart | unused_import | - | - | - |
| test/services/scheduled_training_launcher_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, PackLibraryService |
| test/services/scheduled_training_queue_service_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, PackLibraryService |
| test/services/skill_decay_tag_filter_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/skill_gap_booster_service_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, PackLibraryService |
| test/services/skill_gap_detector_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/skill_loss_detector_test.dart | unused_import | - | - | - |
| test/services/skill_loss_feed_engine_test.dart | mixed_consumer | GameType, PackLibraryService, TagGoalProgress, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, TagGoalProgress, PackLibraryService |
| test/services/skill_map_booster_recommender_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/skill_recovery_pack_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/skill_tag_coverage_guard_service_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2 |
| test/services/skill_tag_coverage_tracker_service_test.dart | unused_import | - | - | - |
| test/services/skill_tag_coverage_tracker_test.dart | unused_import | - | - | - |
| test/services/skill_tag_decay_tracker_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/skill_tag_session_coverage_tracker_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_auto_linker_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_auto_linker_test.dart | unused_import | - | - | - |
| test/services/skill_tree_block_node_positioner_test.dart | unused_import | - | - | - |
| test/services/skill_tree_builder_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_celebration_trigger_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_completion_banner_composer_test.dart | unused_import | - | - | - |
| test/services/skill_tree_dependency_link_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_final_node_completion_detector_test.dart | unused_import | - | - | - |
| test/services/skill_tree_grid_block_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_learning_map_layout_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_lesson_gating_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_level_gate_evaluator_test.dart | unused_import | - | - | - |
| test/services/skill_tree_node_celebration_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_node_completion_state_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_node_detail_unlock_hint_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_node_lock_reason_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_node_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/skill_tree_path_connector_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_path_progress_estimator_test.dart | unused_import | - | - | - |
| test/services/skill_tree_path_progress_overview_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_progress_analytics_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_badge_evaluator_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_block_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_completion_evaluator_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_gate_evaluator_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_list_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_state_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_stage_unlock_overlay_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_track_node_stage_marker_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_track_progress_service_test.dart | unused_import | - | - | - |
| test/services/skill_tree_track_state_evaluator_test.dart | unused_import | - | - | - |
| test/services/skill_tree_track_summary_builder_test.dart | unused_import | - | - | - |
| test/services/skill_tree_training_pack_resolver_test.dart | unused_import | - | - | - |
| test/services/skill_tree_unlock_evaluator_test.dart | unused_import | - | - | - |
| test/services/smart_booster_diversity_scheduler_service_test.dart | unused_import | - | - | - |
| test/services/smart_booster_dropoff_detector_test.dart | unused_import | - | - | - |
| test/services/smart_booster_exclusion_tracker_service_test.dart | unused_import | - | - | - |
| test/services/smart_booster_inbox_limiter_service_test.dart | unused_import | - | - | - |
| test/services/smart_booster_recall_engine_test.dart | unused_import | - | - | - |
| test/services/smart_booster_summary_engine_test.dart | unused_import | - | - | - |
| test/services/smart_booster_unlocker_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/services/smart_decay_goal_generator_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/smart_decay_inbox_booster_service_test.dart | unused_import | - | - | - |
| test/services/smart_goal_aggregator_service_test.dart | unused_import | - | - | - |
| test/services/smart_goal_reminder_engine_test.dart | unused_import | - | - | - |
| test/services/smart_goal_tracking_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/smart_inbox_feedback_logger_service_test.dart | unused_import | - | - | - |
| test/services/smart_inbox_heuristic_tuning_service_test.dart | unused_import | - | - | - |
| test/services/smart_inbox_item_deduplication_service_test.dart | unused_import | - | - | - |
| test/services/smart_inbox_priority_scorer_service_test.dart | unused_import | - | - | - |
| test/services/smart_pinned_block_booster_provider_test.dart | unused_import | - | - | - |
| test/services/smart_pinned_block_inbox_provider_test.dart | unused_import | - | - | - |
| test/services/smart_recall_booster_scheduler_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/smart_recap_banner_controller_test.dart | mixed_consumer | SmartTheoryRecapDismissalMemory, TrainingSessionService | - | TrainingSessionService, SmartTheoryRecapDismissalMemory |
| test/services/smart_recap_banner_reinjection_service_test.dart | mixed_consumer | MiniLessonLibraryService, SmartTheoryRecapDismissalMemory, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService, SmartTheoryRecapDismissalMemory |
| test/services/smart_recap_booster_launcher_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, TrainingSessionService |
| test/services/smart_recap_booster_linker_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/smart_recap_event_logger_test.dart | unused_import | - | - | - |
| test/services/smart_recap_injection_planner_test.dart | unused_import | - | - | - |
| test/services/smart_recap_scheduler_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/services/smart_recap_suggestion_engine_stream_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/smart_recap_suggestion_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/smart_resuggestion_engine_test.dart | mixed_consumer | TrainingSessionService, TrainingType | - | TrainingType, TrainingSessionService |
| test/services/smart_skill_gap_booster_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/smart_theory_booster_bridge_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/smart_theory_booster_linker_test.dart | unused_import | - | - | - |
| test/services/smart_theory_injection_engine_test.dart | mixed_consumer | HandData, MiniLessonLibraryService | - | HandData, MiniLessonLibraryService |
| test/services/smart_theory_recap_dismissal_memory_test.dart | mixed_consumer | SmartTheoryRecapDismissalMemory | - | SmartTheoryRecapDismissalMemory |
| test/services/smart_theory_recap_engine_test.dart | unused_import | - | - | - |
| test/services/smart_theory_recap_score_weighting_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/smart_theory_suggestion_engine_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/spaced_review_service_test.dart | unused_import | - | - | - |
| test/services/spot_seed_filter_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/sr_queue_builder_test.dart | unused_import | - | - | - |
| test/services/stage_completion_celebration_service_test.dart | unused_import | - | - | - |
| test/services/starter_pack_telemetry_test.dart | unused_import | - | - | - |
| test/services/streak_progress_service_test.dart | unused_import | - | - | - |
| test/services/streak_reminder_scheduler_service_test.dart | unused_import | - | - | - |
| test/services/streak_tracker_service_test.dart | unused_import | - | - | - |
| test/services/suggested_training_packs_history_service_test.dart | unused_import | - | - | - |
| test/services/suggested_weak_tag_pack_service_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/suggestion_cooldown_manager_test.dart | unused_import | - | - | - |
| test/services/tag_balancer_engine_test.dart | unused_import | - | - | - |
| test/services/tag_coverage_service_test.dart | unused_import | - | - | - |
| test/services/tag_decay_forecast_service_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/tag_insight_reminder_engine_test.dart | unused_import | - | - | - |
| test/services/tag_mastery_history_service_test.dart | unused_import | - | - | - |
| test/services/tag_mastery_importer_test.dart | unused_import | - | - | - |
| test/services/tag_mastery_trend_service_test.dart | unused_import | - | - | - |
| test/services/tag_mastery_updater_test.dart | unused_import | - | - | - |
| test/services/tag_weakness_detector_service_test.dart | unused_import | - | - | - |
| test/services/targeted_pack_booster_engine_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/theory_and_booster_flow_composer_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/theory_auto_injection_logger_service_test.dart | unused_import | - | - | - |
| test/services/theory_auto_injector_test.dart | unused_import | - | - | - |
| test/services/theory_auto_recall_injector_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_block_review_streak_evaluator_test.dart | unused_import | - | - | - |
| test/services/theory_boost_trigger_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_booster_candidate_picker_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_booster_effectiveness_service_test.dart | unused_import | - | - | - |
| test/services/theory_booster_goal_completion_handler_test.dart | unused_import | - | - | - |
| test/services/theory_booster_injection_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_booster_launcher_test.dart | mixed_consumer | GameType, TrainingPackLevel, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingPackLevel, TrainingPackTemplateV2, TrainingSessionService |
| test/services/theory_booster_recall_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_booster_recommender_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/theory_booster_reinjection_policy_test.dart | unused_import | - | - | - |
| test/services/theory_booster_suggestion_service_test.dart | mixed_consumer | HandData, MiniLessonLibraryService | - | HandData, MiniLessonLibraryService |
| test/services/theory_booster_training_launcher_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_cluster_progress_service_test.dart | unused_import | - | - | - |
| test/services/theory_cluster_summary_service_test.dart | unused_import | - | - | - |
| test/services/theory_completion_event_dispatcher_test.dart | unused_import | - | - | - |
| test/services/theory_content_service_test.dart | unused_import | - | - | - |
| test/services/theory_engagement_analytics_service_test.dart | unused_import | - | - | - |
| test/services/theory_gap_detector_test.dart | unused_import | - | - | - |
| test/services/theory_goal_completion_notifier_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/services/theory_goal_engine_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/services/theory_goal_recommender_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/theory_graph_navigation_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_inbox_banner_controller_test.dart | unused_import | - | - | - |
| test/services/theory_injector_from_template_set_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/theory_integrity_sweeper_test.dart | unused_import | - | - | - |
| test/services/theory_lesson_cluster_auto_tagger_test.dart | unused_import | - | - | - |
| test/services/theory_lesson_cluster_linker_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_completion_logger_test.dart | unused_import | - | - | - |
| test/services/theory_lesson_effectiveness_analyzer_service_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/theory_lesson_graph_exporter_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_graph_navigator_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_meta_tag_extractor_service_test.dart | unused_import | - | - | - |
| test/services/theory_lesson_navigator_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/theory_lesson_resume_engine_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_tag_clusterer_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_tag_heatmap_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_lesson_unlock_notification_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_library_index_test.dart | unused_import | - | - | - |
| test/services/theory_link_auto_injector_ablation_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/services/theory_link_auto_injector_decay_weight_test.dart | unused_import | - | - | - |
| test/services/theory_link_auto_injector_service_test.dart | mixed_consumer | HandData, MiniLessonLibraryService | - | HandData, MiniLessonLibraryService |
| test/services/theory_link_auto_injector_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/services/theory_link_config_service_test.dart | unused_import | - | - | - |
| test/services/theory_link_policy_engine_test.dart | unused_import | - | - | - |
| test/services/theory_manifest_service_test.dart | unused_import | - | - | - |
| test/services/theory_milestone_unlocker_test.dart | unused_import | - | - | - |
| test/services/theory_mini_lesson_content_template_service_test.dart | unused_import | - | - | - |
| test/services/theory_mini_lesson_factory_service_test.dart | unused_import | - | - | - |
| test/services/theory_mini_lesson_linker_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingType | - | TrainingType, MiniLessonLibraryService |
| test/services/theory_mini_lesson_navigator_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_mini_map_renderer_test.dart | unused_import | - | - | - |
| test/services/theory_novelty_registry_test.dart | unused_import | - | - | - |
| test/services/theory_onboarding_path_recommender_test.dart | unused_import | - | - | - |
| test/services/theory_pack_exporter_service_test.dart | unused_import | - | - | - |
| test/services/theory_pack_importer_service_test.dart | unused_import | - | - | - |
| test/services/theory_path_preview_builder_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_recall_auto_link_injector_test.dart | unused_import | - | - | - |
| test/services/theory_recall_efficiency_evaluator_service_test.dart | mixed_consumer | RecallSuccessLoggerService | - | RecallSuccessLoggerService |
| test/services/theory_recall_evaluator_suggestions_test.dart | mixed_consumer | GameType, MiniLessonLibraryService, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingPackTemplateV2, MiniLessonLibraryService |
| test/services/theory_recall_evaluator_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/theory_recall_failure_hotspot_detector_service_test.dart | unused_import | - | - | - |
| test/services/theory_recall_impact_tracker_test.dart | unused_import | - | - | - |
| test/services/theory_recall_inbox_reinjection_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_recap_analytics_reporter_test.dart | unused_import | - | - | - |
| test/services/theory_recap_analytics_summarizer_test.dart | unused_import | - | - | - |
| test/services/theory_recap_prompt_orchestrator_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_recap_suppression_engine_reason_test.dart | unused_import | - | - | - |
| test/services/theory_recap_suppression_engine_test.dart | unused_import | - | - | - |
| test/services/theory_recap_trigger_logger_test.dart | unused_import | - | - | - |
| test/services/theory_reinforcement_banner_controller_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_reinforcement_log_service_test.dart | unused_import | - | - | - |
| test/services/theory_reinforcement_queue_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_reinforcement_scheduler_test.dart | unused_import | - | - | - |
| test/services/theory_session_service_test.dart | unused_import | - | - | - |
| test/services/theory_stage_completion_watcher_test.dart | unused_import | - | - | - |
| test/services/theory_stage_progress_tracker_test.dart | unused_import | - | - | - |
| test/services/theory_streak_service_test.dart | unused_import | - | - | - |
| test/services/theory_suggestion_engagement_tracker_service_test.dart | unused_import | - | - | - |
| test/services/theory_suggestion_ranker_test.dart | unused_import | - | - | - |
| test/services/theory_tag_decay_tracker_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_tag_summary_service_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_weakness_repeater_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/services/theory_yaml_canonicalizer_test.dart | unused_import | - | - | - |
| test/services/theory_yaml_safe_reader_test.dart | unused_import | - | - | - |
| test/services/theory_yaml_safe_writer_test.dart | unused_import | - | - | - |
| test/services/track_completion_celebration_service_test.dart | unused_import | - | - | - |
| test/services/track_completion_reward_service_test.dart | unused_import | - | - | - |
| test/services/track_lock_evaluator_test.dart | unused_import | - | - | - |
| test/services/track_milestone_unlocker_service_test.dart | unused_import | - | - | - |
| test/services/track_play_recorder_test.dart | unused_import | - | - | - |
| test/services/track_reward_preview_service_test.dart | unused_import | - | - | - |
| test/services/track_reward_unlocker_service_test.dart | unused_import | - | - | - |
| test/services/track_unlock_conditions_engine_test.dart | mixed_consumer | GameType | - | GameType |
| test/services/track_unlock_reason_service_test.dart | unused_import | - | - | - |
| test/services/track_visibility_filter_engine_test.dart | mixed_consumer | GameType | - | GameType |
| test/services/training_pack_audit_log_service_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/training_pack_auto_enricher_batch_service_test.dart | unused_import | - | - | - |
| test/services/training_pack_auto_generator_multi_output_test.dart | unused_import | - | - | - |
| test/services/training_pack_auto_generator_texture_filter_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/training_pack_generator_engine_v2_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_index_service_test.dart | unused_import | - | - | - |
| test/services/training_pack_library_auto_qa_service_test.dart | unused_import | - | - | - |
| test/services/training_pack_library_differ_test.dart | unused_import | - | - | - |
| test/services/training_pack_library_exporter_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/training_pack_library_generator_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_library_importer_test.dart | unused_import | - | - | - |
| test/services/training_pack_library_metadata_enricher_test.dart | mixed_consumer | GameType, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2 |
| test/services/training_pack_library_search_service_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/training_pack_library_search_suggestions_service_test.dart | unused_import | - | - | - |
| test/services/training_pack_metadata_enricher_service_test.dart | mixed_consumer | HandData | - | HandData |
| test/services/training_pack_performance_tracker_service_test.dart | unused_import | - | - | - |
| test/services/training_pack_search_index_builder_test.dart | mixed_consumer | TrainingPackLevel, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackLevel, TrainingPackTemplateV2 |
| test/services/training_pack_search_service_test.dart | mixed_consumer | GameType, TrainingPackLevel, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, TrainingPackLevel, TrainingPackTemplateV2 |
| test/services/training_pack_stats_service_v2_test.dart | unused_import | - | - | - |
| test/services/training_pack_template_compiler_test.dart | unused_import | - | - | - |
| test/services/training_pack_template_expander_line_patterns_test.dart | unused_import | - | - | - |
| test/services/training_pack_template_expander_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_template_instance_expander_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_template_multi_set_expander_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_template_set_expander_service_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/services/training_pack_template_set_expander_test.dart | unused_import | - | - | - |
| test/services/training_pack_template_set_generator_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/services/training_path_breadcrumb_service_test.dart | unused_import | - | - | - |
| test/services/training_path_node_definition_service_test.dart | unused_import | - | - | - |
| test/services/training_path_progress_service_test.dart | unused_import | - | - | - |
| test/services/training_path_progress_service_v2_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/training_path_progress_tracker_service_test.dart | unused_import | - | - | - |
| test/services/training_path_unlock_service_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/training_progress_substage_test.dart | unused_import | - | - | - |
| test/services/training_progress_tracker_service_test.dart | unused_import | - | - | - |
| test/services/training_run_ab_comparator_service_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/services/training_session_completion_stats_service_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/services/training_session_context_service_source_test.dart | unused_import | - | - | - |
| test/services/training_session_context_service_test.dart | unused_import | - | - | - |
| test/services/training_session_fingerprint_logger_service_test.dart | unused_import | - | - | - |
| test/services/training_session_fingerprint_recorder_test.dart | unused_import | - | - | - |
| test/services/training_session_fingerprint_timeline_service_test.dart | unused_import | - | - | - |
| test/services/training_session_launcher_btn_cash_lesson_test.dart | mixed_consumer | GameType, TrainingType | - | GameType, TrainingType |
| test/services/training_session_launcher_intro_lesson_test.dart | mixed_consumer | GameType, TrainingType | - | GameType, TrainingType |
| test/services/training_session_recommender_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/training_session_service_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | TrainingType, TrainingPackTemplateV2, TrainingSessionService |
| test/services/training_spot_generator_service_test.dart | unused_import | - | - | - |
| test/services/transition_lock_service_test.dart | unused_import | - | - | - |
| test/services/unique_pack_replay_blocker_service_test.dart | mixed_consumer | TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2 |
| test/services/unlock_condition_evaluator_test.dart | unused_import | - | - | - |
| test/services/user_error_rate_service_test.dart | unused_import | - | - | - |
| test/services/user_skill_model_service_test.dart | unused_import | - | - | - |
| test/services/weak_tag_booster_generator_service_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/services/weak_theory_zone_highlighter_test.dart | unused_import | - | - | - |
| test/services/weekly_planner_booster_engine_test.dart | mixed_consumer | PackLibraryService | - | PackLibraryService |
| test/services/weekly_planner_booster_feed_test.dart | mixed_consumer | PackLibraryService, TrainingType | - | TrainingType, PackLibraryService |
| test/services/xp_level_engine_test.dart | unused_import | - | - | - |
| test/services/xp_reward_engine_test.dart | unused_import | - | - | - |
| test/session_analysis_screen_test.dart | mixed_consumer | HandData, HeroPosition, TrainingSessionService | - | HeroPosition, HandData, TrainingSessionService |
| test/session_flow_timer_test.dart | unused_import | - | - | - |
| test/skill_tag_coverage_tracker_test.dart | unused_import | - | - | - |
| test/skill_targeting_recommender_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/skill_tree_motivational_hint_engine_test.dart | unused_import | - | - | - |
| test/smart_mini_booster_planner_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/smart_mistake_review_strategy_test.dart | mixed_consumer | HandData | - | HandData |
| test/smart_path_compiler_test.dart | unused_import | - | - | - |
| test/smart_path_seed_generator_test.dart | unused_import | - | - | - |
| test/smart_path_ux_hints_service_test.dart | unused_import | - | - | - |
| test/smart_recap_auto_injector_test.dart | mixed_consumer | SmartTheoryRecapDismissalMemory, TrainingSessionService | - | TrainingSessionService, SmartTheoryRecapDismissalMemory |
| test/smoke/smoke_test.dart | unused_import | - | - | - |
| test/smoke/tags_dedup_smoke_test.dart | unused_import | - | - | - |
| test/smoke/training_pack_v2_roundtrip_test.dart | shadow_type_consumer | TrainingPackLevel, TrainingType | - | - |
| test/smoke/utils_math_smoke_test.dart | unused_import | - | - | - |
| test/smoke/weekly_summary_card_smoke_test.dart | unused_import | - | - | - |
| test/smoke/win_overlays_smoke_test.dart | unused_import | - | - | - |
| test/smoke/yaml_spot_parser_smoke_test.dart | genuine_fake_only_consumer | - | parseYamlToMap | - |
| test/spot_factory_level2_engine_test.dart | mixed_consumer | GameType | - | GameType |
| test/spot_importer_json_modes_test.dart | unused_import | - | - | - |
| test/spot_importer_jsonl_test.dart | unused_import | - | - | - |
| test/spot_importer_parse_smoke_test.dart | unused_import | - | - | - |
| test/spot_importer_roundtrip_test.dart | unused_import | - | - | - |
| test/spot_importer_test.dart | unused_import | - | - | - |
| test/spot_line_graph_engine_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/spot_maps_coverage_test.dart | unused_import | - | - | - |
| test/spot_specs_auto_replay_invariants_test.dart | mixed_consumer | isAutoReplayKind | - | isAutoReplayKind |
| test/spot_specs_autoreplay_ssot_test.dart | unused_import | - | - | - |
| test/spot_specs_core_call_vs_price_test.dart | unused_import | - | - | - |
| test/spot_specs_icm_ssot_test.dart | unused_import | - | - | - |
| test/spot_specs_jamfold_helper_test.dart | unused_import | - | - | - |
| test/spot_specs_should_auto_replay_test.dart | mixed_consumer | isAutoReplayKind | - | isAutoReplayKind |
| test/spot_specs_ssot_consistency_test.dart | mixed_consumer | isAutoReplayKind | - | isAutoReplayKind |
| test/spot_validation_test.dart | unused_import | - | - | - |
| test/spotkind_enum_discipline_test.dart | unused_import | - | - | - |
| test/spotkind_naming_validator_test.dart | unused_import | - | - | - |
| test/ssot_smoke_test.dart | unused_import | - | - | - |
| test/stack_range_filter_test.dart | unused_import | - | - | - |
| test/staged_path_promoter_test.dart | unused_import | - | - | - |
| test/starter_learning_path_builder_test.dart | unused_import | - | - | - |
| test/tag_retention_tracker_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/telemetry_builder_smoke_test.dart | unused_import | - | - | - |
| test/telemetry_builder_test.dart | unused_import | - | - | - |
| test/telemetry_mode_test.dart | unused_import | - | - | - |
| test/temp_cleanup_test.dart | genuine_fake_only_consumer | - | setLastModified | - |
| test/theory/theory_integrity_actions_test.dart | unused_import | - | - | - |
| test/theory_booster_generator_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/theory_booster_injector_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/theory_booster_pack_linker_test.dart | unused_import | - | - | - |
| test/theory_injection_engine_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/theory_lesson_auto_linker_test.dart | unused_import | - | - | - |
| test/theory_lesson_node_fallback_test.dart | unused_import | - | - | - |
| test/theory_lesson_reachability_validator_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/theory_lesson_review_queue_test.dart | mixed_consumer | MiniLessonLibraryService, TrainingSessionService | - | TrainingSessionService, MiniLessonLibraryService |
| test/theory_lesson_trail_tracker_test.dart | unused_import | - | - | - |
| test/theory_pack_auto_indexer_service_test.dart | unused_import | - | - | - |
| test/theory_pack_auto_tagger_test.dart | unused_import | - | - | - |
| test/theory_pack_completion_estimator_test.dart | unused_import | - | - | - |
| test/theory_pack_generator_service_test.dart | unused_import | - | - | - |
| test/theory_pack_generator_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/theory_pack_library_service_test.dart | unused_import | - | - | - |
| test/theory_pack_review_status_engine_test.dart | unused_import | - | - | - |
| test/theory_pack_sampler_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/theory_pack_seeder_level2_test.dart | unused_import | - | - | - |
| test/theory_smart_entry_point_selector_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/theory_snippet_coverage_test.dart | unused_import | - | - | - |
| test/theory_stage_auto_seeder_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/theory_validation_engine_test.dart | unused_import | - | - | - |
| test/title_utils_test.dart | unused_import | - | - | - |
| test/tools/batch_generate_test.dart | unused_import | - | - | - |
| test/tools/compile_path_test.dart | unused_import | - | - | - |
| test/tools/migrate_output_variants_test.dart | unused_import | - | - | - |
| test/tools/plugin_scaffold_test.dart | unused_import | - | - | - |
| test/tools/schema_check_unit_test.dart | unused_import | - | - | - |
| test/training_history_widgets_test.dart | unused_import | - | - | - |
| test/training_pack_asset_loader_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/training_pack_fingerprint_generator_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/training_pack_generator_v2_test.dart | mixed_consumer | HandData, HeroPosition | - | HeroPosition, HandData |
| test/training_pack_library_theme_filter_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/training_pack_ranking_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/training_pack_sampler_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/training_pack_spot_serialization_test.dart | mixed_consumer | HandData | - | HandData |
| test/training_pack_spot_yaml_test.dart | mixed_consumer | HandData | - | HandData |
| test/training_pack_template_expander_full_board_test.dart | unused_import | - | - | - |
| test/training_pack_template_metadata_validator_test.dart | mixed_consumer | HandData, TrainingType | - | TrainingType, HandData |
| test/training_pack_template_service_test.dart | mixed_consumer | AppLocalizations | - | AppLocalizations |
| test/training_pack_template_set_test.dart | unused_import | - | - | - |
| test/training_pack_template_v2_from_json_test.dart | unused_import | - | - | - |
| test/training_pack_template_v2_to_yaml_string_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/training_progress_service_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/training_progress_timeline_service_test.dart | unused_import | - | - | - |
| test/training_result_test.dart | unused_import | - | - | - |
| test/training_spot_expander_test.dart | mixed_consumer | HandData, HeroPosition, TrainingType | - | TrainingType, HeroPosition, HandData |
| test/ui/session_player/mvs_session_player_flop_jam_vs_bet_test.dart | unused_import | - | - | - |
| test/ui/session_player/mvs_session_player_river_jam_vs_bet_test.dart | unused_import | - | - | - |
| test/ui/session_player/mvs_session_player_turn_jam_vs_raise_test.dart | unused_import | - | - | - |
| test/undo_history/diff_engine_test.dart | unused_import | - | - | - |
| test/unit_id_utils_test.dart | unused_import | - | - | - |
| test/utils/stack_range_filter_test.dart | unused_import | - | - | - |
| test/utils/theory_cluster_id_hasher_test.dart | unused_import | - | - | - |
| test/utils/theory_lesson_cluster_serializer_test.dart | unused_import | - | - | - |
| test/weakness_cluster_engine_test.dart | unused_import | - | - | - |
| test/weakness_cluster_engine_v2_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/weakness_log_test.dart | unused_import | - | - | - |
| test/weakness_review_engine_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/weakness_tag_resolver_test.dart | unused_import | - | - | - |
| test/widgets/board_tag_preview_renderer_test.dart | unused_import | - | - | - |
| test/widgets/booster_feedback_widget_test.dart | unused_import | - | - | - |
| test/widgets/booster_progress_chart_widget_test.dart | unused_import | - | - | - |
| test/widgets/clipboard_detector_template_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/completed_session_detail_screen_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/completed_session_history_screen_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/decay_heatmap_ui_surface_test.dart | unused_import | - | - | - |
| test/widgets/decay_streak_progress_bar_widget_test.dart | unused_import | - | - | - |
| test/widgets/endless_stop_button_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData, TrainingSessionService |
| test/widgets/ev_summary_card_test.dart | unused_import | - | - | - |
| test/widgets/eval_all_spots_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2 | - | TrainingPackTemplateV2, HandData |
| test/widgets/eval_result_view_test.dart | unused_import | - | - | - |
| test/widgets/export_csv_button_test.dart | mixed_consumer | HeroPosition, ShareOptions | - | HeroPosition |
| test/widgets/generated_pack_history_test.dart | unused_import | - | - | - |
| test/widgets/generated_pack_play_test.dart | mixed_consumer | TrainingSessionService | - | TrainingSessionService |
| test/widgets/goal_reengagement_banner_test.dart | mixed_consumer | GameType, HandData, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | GameType, TrainingType, TrainingPackTemplateV2, TrainingSessionService |
| test/widgets/handed_badge_test.dart | shadow_type_consumer | HeroPosition | - | - |
| test/widgets/icm_badge_finaltable_test.dart | unused_import | - | - | - |
| test/widgets/import_csv_button_test.dart | shadow_type_consumer | HeroPosition | - | - |
| test/widgets/inline_theory_badge_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/widgets/inline_theory_link_chip_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/widgets/inline_theory_linker_widget_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/widgets/inline_theory_recall_card_test.dart | unused_import | - | - | - |
| test/widgets/inline_theory_recall_smoke_test.dart | unused_import | - | - | - |
| test/widgets/learning_path_progress_summary_widget_test.dart | unused_import | - | - | - |
| test/widgets/learning_path_progress_widget_test.dart | unused_import | - | - | - |
| test/widgets/lesson_streak_badge_tooltip_widget_test.dart | unused_import | - | - | - |
| test/widgets/lesson_streak_summary_card_test.dart | unused_import | - | - | - |
| test/widgets/make_mistake_pack_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/mistake_inline_theory_prompt_test.dart | unused_import | - | - | - |
| test/widgets/mistake_only_filter_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/mixed_drill_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingSessionService | - | TrainingPackTemplateV2, HandData, TrainingSessionService |
| test/widgets/pack_card_almost_unlocked_badge_test.dart | shadow_type_consumer | TrainingType | - | - |
| test/widgets/pack_card_goal_label_test.dart | shadow_type_consumer | TrainingType | - | - |
| test/widgets/pack_card_level_badge_test.dart | shadow_type_consumer | TrainingType | - | - |
| test/widgets/pack_card_lock_test.dart | shadow_type_consumer | TrainingType | - | - |
| test/widgets/player_zone_widget_test.dart | unused_import | - | - | - |
| test/widgets/poker_table_view_test.dart | unused_import | - | - | - |
| test/widgets/position_label_test.dart | unused_import | - | - | - |
| test/widgets/preset_range_buttons_test.dart | unused_import | - | - | - |
| test/widgets/range_matrix_picker_test.dart | unused_import | - | - | - |
| test/widgets/resume_button_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/review_path_card_test.dart | mixed_consumer | GameType, PackLibraryService, TrainingType | - | GameType, TrainingType, PackLibraryService |
| test/widgets/reward_gallery_screen_test.dart | shadow_type_consumer | ShareOptions | - | - |
| test/widgets/room_hand_history_import_screen_test.dart | unused_import | - | - | - |
| test/widgets/skill_tag_coverage_dashboard_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_node_detail_hint_widget_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_stage_badge_icon_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_stage_badge_legend_widget_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_stage_header_badge_widget_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_stage_header_builder_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_track_header_builder_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_track_launcher_test.dart | unused_import | - | - | - |
| test/widgets/skill_tree_track_list_screen_test.dart | unused_import | - | - | - |
| test/widgets/smart_goal_progress_bar_test.dart | unused_import | - | - | - |
| test/widgets/stage_progress_bar_test.dart | unused_import | - | - | - |
| test/widgets/template_play_button_test.dart | mixed_consumer | GameType, HeroPosition, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, TrainingSessionService |
| test/widgets/theory_cluster_pack_heatmap_widget_test.dart | unused_import | - | - | - |
| test/widgets/theory_lesson_context_overlay_test.dart | mixed_consumer | MiniLessonLibraryService | - | MiniLessonLibraryService |
| test/widgets/theory_lesson_tag_sidebar_test.dart | unused_import | - | - | - |
| test/widgets/training_pack_ev_badge_test.dart | mixed_consumer | HeroPosition | - | HeroPosition |
| test/widgets/training_pack_history_list_widget_test.dart | mixed_consumer | HandData, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | TrainingType, TrainingPackTemplateV2, HandData |
| test/widgets/training_pack_icm_badge_test.dart | unused_import | - | - | - |
| test/widgets/training_play_screen_retest_after_theory_test.dart | unused_import | - | - | - |
| test/widgets/training_session_summary_screen_test.dart | mixed_consumer | AppLocalizations, HandData, HeroPosition, TrainingPackTemplateV2, TrainingSessionService, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData, TrainingSessionService, AppLocalizations |
| test/widgets/user_goal_reengagement_banner_test.dart | unused_import | - | - | - |
| test/widgets/view_manager_dialog_test.dart | unused_import | - | - | - |
| test/yaml_duplicate_detector_service_test.dart | shadow_type_consumer | TrainingType | - | - |
| test/yaml_lesson_track_loader_test.dart | unused_import | - | - | - |
| test/yaml_pack_auto_tag_engine_test.dart | mixed_consumer | GameType, HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | GameType, TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |
| test/yaml_pack_auto_tagger_test.dart | mixed_consumer | TrainingType | - | TrainingType |
| test/yaml_pack_importer_service_test.dart | unused_import | - | - | - |
| test/yaml_pack_rating_engine_test.dart | mixed_consumer | HandData, HeroPosition, TrainingPackTemplateV2, TrainingType | - | TrainingType, HeroPosition, TrainingPackTemplateV2, HandData |

## B. Donor Failure/Error Matrix

- Failing testDone rows: `145` (`39` failures, `106` errors).

| Result | File | Test | Compile/runtime | Likely shim-caused | Authority | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| failure | test/personalization/learning_continuation_v1_test.dart | early-arc session continuation uses route headline instead of local focus | runtime/assertion | no | support | Expected: 'What changes now: Read visible table truth' \|   Actual: 'What changes now: Build Hand Discipline from position, price, and approved pressure cues' |
| error | test/smoke/simulation_engine_v2_smoke_test.dart | SimulationEngine v2 smoke action labels show BB amounts for raises | runtime/error | no | support | Test failed. See exception logs above. \| The test description was: action labels show BB amounts for raises |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/smoke/training_pack_v2_roundtrip_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/smoke/training_pack_v2_roundtrip_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/smoke/training_pack_v2_roundtrip_test.dart: test/ |
| failure | test/learning_path_controller_gating_test.dart | completion threshold is inclusive | runtime/assertion | no | support | Expected: <true> \|   Actual: <false> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_metadata_validator_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_metadata_validator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_metadata_validato |
| failure | test/ssot_smoke_test.dart | SSOT smoke jam-vs-* kinds map to [jam, fold] | runtime/assertion | no | support | Expected: empty \|   Actual: [ |
| failure | test/ssot_smoke_test.dart | SSOT smoke actionsMap covers every SpotKind with non-empty actions | runtime/assertion | no | support | Expected: empty \|   Actual: [ |
| error | test/ui_v2_smoke_test.dart | UiV2ProgressMapScreenV2 renders without errors | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: UiV2ProgressMapScreenV2 renders without errors |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/live_context_format_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/live_context_format_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/live_context_format_test.dart: test/live_context_format_test.d |
| error | test/ui/session_player/mvs_session_player_river_jam_vs_bet_test.dart | renders River Jam vs Bet spot | runtime/error | no | support | Test failed. See exception logs above. \| The test description was: renders River Jam vs Bet spot |
| error | test/ui/session_player/mvs_session_player_flop_jam_vs_bet_test.dart | renders Flop Jam vs Bet spot | runtime/error | no | support | Test failed. See exception logs above. \| The test description was: renders Flop Jam vs Bet spot |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/ui/simulation_table_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/ui/simulation_table_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/ui/simulation_table_smoke_test.dart: lib/ui_v2/simulatio |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_booster_pack_linker_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_booster_pack_linker_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_booster_pack_linker_test.dart: test/theory_boost |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/spot_specs_ssot_consistency_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/spot_specs_ssot_consistency_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/spot_specs_ssot_consistency_test.dart: test/spot_specs |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/e2e_adaptive_plan_injection_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/e2e_adaptive_plan_injection_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/e2e_adaptive_plan_injection_test.dart: test/e2e_adapti |
| failure | test/curriculum_structure_doc_link_test.dart | CURRICULUM_STRUCTURE.md links to RICH_TRACK_SCHEMA | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| error | test/remedial_generation_controller_test.dart | dedupe logic respects age and accuracy improvement | runtime/error | no | support | Binding has not yet been initialized. \| The "instance" getter on the ServicesBinding binding mixin is only available once that binding has been initialized. |
| error | test/remedial_generation_controller_test.dart | returned uri contains all params | runtime/error | no | support | Binding has not yet been initialized. \| The "instance" getter on the ServicesBinding binding mixin is only available once that binding has been initialized. |
| error | test/auto_theory_stage_seeder_test.dart | exportYamlFile writes file and injects stages | runtime/error | no | support | UnimplementedError |
| error | test/auto_theory_stage_seeder_test.dart | generateYamlForMissingTheoryStages returns yaml | runtime/error | no | support | UnimplementedError |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/curriculum_overlay_guard_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/curriculum_overlay_guard_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/curriculum_overlay_guard_test.dart: test/curriculum_overl |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/auto_start_training_prompt_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/auto_start_training_prompt_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/auto_start_training_prompt_test.dart: test/auto_start_t |
| error | test/quarantine/ev_rank_jam_fold_cli_help_test.dart | --help prints usage | runtime/error | no | legacy | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error | test/quarantine/ev_rank_jam_fold_cli_help_test.dart | -h prints usage | runtime/error | no | legacy | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error | test/quarantine/ev_rank_jam_fold_cli_help_test.dart | --help works with extra args | runtime/error | no | legacy | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/quarantine/jam_fold_evaluator_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/quarantine/jam_fold_evaluator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/quarantine/jam_fold_evaluator_test.dart: test/quaran |
| error | test/quarantine/ev_rank_jam_fold_cli_test.dart | ev_rank_jam_fold_deltas CLI prints usage with --help | runtime/error | no | legacy | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error | test/quarantine/ev_rank_jam_fold_cli_test.dart | ev_rank_jam_fold_deltas CLI fails gracefully on invalid flag | runtime/error | no | legacy | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_enrich_jam_fold_cli_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_enrich_jam_fold_cli_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_enrich_jam_fold_cli_test.dart: tes |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_end_to_end_golden_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_end_to_end_golden_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/quarantine/ev_end_to_end_golden_test.dart: test/qu |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/undo_history/diff_engine_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/undo_history/diff_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/undo_history/diff_engine_test.dart: test/undo_history/dif |
| failure | test/temp_cleanup_test.dart | cleanupOldTempDirs removes only old directories | runtime/assertion | no | support | Expected: false \|   Actual: <true> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/mini_lesson_path_injector_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/mini_lesson_path_injector_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/mini_lesson_path_injector_test.dart: test/mini_lesson_pa |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_pack_generator_service_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_generator_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_generator_service_test.dart: test/theory |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/mistake_tag_cluster_service_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/mistake_tag_cluster_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/mistake_tag_cluster_service_test.dart: test/mistake_ta |
| error | test/tools/core_parity_proof_v1_test.dart | core parity modules are present and have non-trivial drill counts | compile | no | support | PathNotFoundException: Cannot open file, path = '/Users/elmarsalimzade/Sharky_1.0/content/core_positions_and_initiative/v1/manifest.json' (OS Error: No such file or directory, errno = 2) |
| failure | test/tools/feedback_quality_scaleout_world10_tournament_generic_template_wave_test.dart | world10 tournament generic-template wave stays poker-reasoned in tournament.s01-tournament.s06 | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| failure | test/tools/w5_w6_authored_session_contract_reconciliation_v1_test.dart | accepted source IDs match manifest IDs while paths stay resolvable | runtime/assertion | no | support | Expected: non-empty \|   Actual: [] |
| failure | test/tools/w5_w6_authored_session_contract_reconciliation_v1_test.dart | broad scanner reports no W5 or W6 contract errors | runtime/assertion | no | support | Expected: <0> \|   Actual: <1> |
| failure | test/tools/table_projection_acceptance_audit_v1_test.dart | current repo world10 audit is clean after canonical table migration batch | runtime/assertion | no | support | Expected: <0> \|   Actual: <120> |
| failure | test/tools/canonical_early_path_correctness_audit_v1_test.dart | canonical early-path correctness audit v1 stays clean | runtime/assertion | no | support | Expected: <0> \|   Actual: <1> |
| failure | test/tools/feedback_quality_scaleout_world10_cash_generic_template_wave_test.dart | world10 cash generic-template wave stays poker-reasoned in cash.s01-cash.s05 | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| failure | test/tools/operational_review_packet_v1_test.dart | operational review packet is deterministic for a fixed timestamp | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| failure | test/tools/feedback_quality_scaleout_world6_generic_template_wave_test.dart | scale-out generic-template corrective feedback stays poker-reasoned | runtime/assertion | no | support | Expected: contains 'missed bucket' \|   Actual: 'Incorrect. This is missed because the board did not connect with the hand as a made pair or clear draw.' |
| failure | test/tools/world3_preflop_hand_chain_validator_convergence_test.dart | validator no longer reports World 3 content-path failures | runtime/assertion | no | support | Expected: false \|   Actual: <true> |
| failure | test/tools/world6_range_intro_wave_test.dart | w6.s01 range intro family teaches bucket and anchor value instead of generic or shallow feedback | runtime/assertion | no | support | Expected: contains 'build a bigger pot cleanly' \|   Actual: 'Correct. Calling fits because position and a medium range edge support controlled realization more than a bigger pot.' |
| failure | test/tools/project_readiness_epics_ssot_v1_test.dart | project readiness epics ssot keeps required structure and enum values | runtime/assertion | no | support | Expected: a value greater than <-1> \|   Actual: <-1> |
| failure | test/tools/world7_generic_anchor_wave_guard_test.dart | world7 generic-anchor family stays learner-facing in w7.s03 and w7.s05-w7.s08 | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/tools/batch_generate_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/tools/batch_generate_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/tools/batch_generate_test.dart: test/tools/batch_generate_tes |
| error | test/tools/compile_path_test.dart | compile path cli | compile | yes | support | PathNotFoundException: Deletion failed, path = 'compiled' (OS Error: No such file or directory, errno = 2) |
| failure | test/tools/plugin_scaffold_test.dart | plugin scaffold | runtime/assertion | no | support | Expected: <0> \|   Actual: <254> |
| failure | test/tools/world0_dealer_button_index_copy_convergence_test.dart | validator no longer reports World 0 dealer-position jargon failures | runtime/assertion | no | support | Expected: <0> \|   Actual: <1> |
| failure | test/tools/runner_unification_readiness_audit_v1_test.dart | accepted runner surface stays free of unknown health and special-cased launch drift | runtime/assertion | no | support | Expected: empty \|   Actual: WhereIterable<RunnerUnificationReadinessRowV1>:[ |
| failure | test/tools/runner_unification_readiness_audit_v1_test.dart | W2-W10 campaign cohorts now report canonical runner readiness | runtime/assertion | no | support | Expected: an object with length of <36> \|   Actual: [ |
| failure | test/tools/release_readiness_snapshot_v1_test.dart | release readiness snapshot is deterministic | runtime/assertion | no | support | Expected: { \|             'version': 'v1', |
| failure | test/tools/stage1a_wave2_feedback_transfer_contract_test.dart | selected W1 action-choice family no longer uses bare Correct. | runtime/assertion | no | support | Expected: an object with length of <27> \|   Actual: [ |
| failure | test/tools/feedback_quality_scaleout_world9_generic_template_wave_test.dart | world9 generic-template wave stays poker-reasoned in w9.s01-w9.s09 | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| failure | test/tools/canonical_trust_inspector_v1_test.dart | canonical trust inspector v1 stays clean on accepted learner trust seams | runtime/assertion | no | support | Expected: empty \|   Actual: [ |
| failure | test/tools/w1_w6_prerequisite_chain_repair_batch_v1_test.dart | pins repaired beginner prerequisite definitions across W1-W6 | runtime/assertion | no | support | Expected: contains 'Protection means betting so drawing hands pay more to continue' \|   Actual: '{\n' |
| error | test/tools/content_quality_validator_v1_test.dart | passes on current beginner repo content smoke | compile | no | support | PathNotFoundException: Directory listing failed, path = '/Users/elmarsalimzade/Sharky_1.0/content/intro_game_flow/v1/' (OS Error: No such file or directory, errno = 2) |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/weakness_cluster_engine_v2_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/weakness_cluster_engine_v2_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/weakness_cluster_engine_v2_test.dart: test/weakness_clu |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/smart_path_ux_hints_service_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/smart_path_ux_hints_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/smart_path_ux_hints_service_test.dart: test/smart_path |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/dynamic_spot_generation_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/dynamic_spot_generation_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/dynamic_spot_generation_test.dart: test/dynamic_spot_gener |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_smart_selector_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_smart_selector_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_smart_selector_test.dart: test/booster_smart_select |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_pack_completion_estimator_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_completion_estimator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_completion_estimator_test.dart: test/ |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/import_dup_hint_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/import_dup_hint_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/import_dup_hint_test.dart: test/import_dup_hint_test.dart:73:63: E |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_progress_timeline_service_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_progress_timeline_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_progress_timeline_service_test.dart: t |
| failure | test/spot_specs_icm_ssot_test.dart | L4 ICM jam vs fold SSOT Enum tail stays L4 ICM SB | runtime/assertion | no | support | Expected: SpotKind:<SpotKind.l4_icm_sb_jam_vs_fold> \|   Actual: SpotKind:<SpotKind.l1_core_call_vs_price> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/pack_augmentation_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/pack_augmentation_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/pack_augmentation_engine_test.dart: test/pack_augmentatio |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_booster_injector_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_booster_injector_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_booster_injector_test.dart: test/theory_booster_inj |
| failure | test/core/texture_filter_engine_test.dart | twoTone detection | runtime/assertion | no | support | Expected: ['AhAd7s'] \|   Actual: [] |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/core/training/training_pack_exporter_v2_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/core/training/training_pack_exporter_v2_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/core/training/training_pack_exporter_v2_te |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_validator_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_validator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_validato |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_codec_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_codec_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/spot_seed_codec_test.d |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/legacy_seed_adapter_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/legacy_seed_adapter_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/core/models/spot_seed/legacy_seed_adapte |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_pack_library_theme_filter_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_pack_library_theme_filter_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_pack_library_theme_filter_test.dart: t |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/weakness_review_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/weakness_review_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/weakness_review_engine_test.dart: test/weakness_review_engi |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_stage_auto_seeder_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_stage_auto_seeder_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_stage_auto_seeder_test.dart: test/theory_stage_aut |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_pack_sampler_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_sampler_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_pack_sampler_test.dart: test/theory_pack_sampler_test.d |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/live_runtime_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/live_runtime_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/live_runtime_test.dart: test/live_runtime_test.dart:34:39: Error: Exp |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/telemetry_builder_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/telemetry_builder_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/telemetry_builder_test.dart: test/telemetry_builder_test.dart:8: |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_cli_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_cli_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_cli_test.dart: test/l3_packrun_cli_test.dart:10:43: Erro |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/board_street_generator_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/board_street_generator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/board_street_generator_test.dart: test/board_street_generat |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/auto_theory_rewriter_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/auto_theory_rewriter_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/auto_theory_rewriter_test.dart: test/auto_theory_rewriter_tes |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_thematic_tagger_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_thematic_tagger_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_thematic_tagger_test.dart: test/booster_thematic_t |
| error | test/curriculum_consistency_test.dart | status matches SSOT and loaders exist | compile | yes | support | PathNotFoundException: Cannot open file, path = 'curriculum_status.json' (OS Error: No such file or directory, errno = 2) |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/ev_summary_bucketize_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/ev_summary_bucketize_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/ev_summary_bucketize_test.dart: test/ev_summary_bucketize_tes |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/smart_mistake_review_strategy_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/smart_mistake_review_strategy_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/smart_mistake_review_strategy_test.dart: test/smart_ |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/learning_path_template_builder_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/learning_path_template_builder_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/learning_path_template_builder_test.dart: test/lear |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/learning_path_engine_core_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/learning_path_engine_core_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/learning_path_engine_core_test.dart: test/learning_path_ |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/icm_bb_packs_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/icm_bb_packs_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/icm_bb_packs_smoke_test.dart: test/icm_bb_packs_smoke_test.dart |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/icm_bubble_packs_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/icm_bubble_packs_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/icm_bubble_packs_smoke_test.dart: test/icm_bubble_packs_smo |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_pack_generator_v2_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_pack_generator_v2_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_pack_generator_v2_test.dart: test/training_pac |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/icm_mix_packs_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/icm_mix_packs_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/icm_mix_packs_smoke_test.dart: test/icm_mix_packs_smoke_test.d |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/learning_path_promoter_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/learning_path_promoter_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/learning_path_promoter_test.dart: test/learning_path_promot |
| failure | test/spot_importer_json_modes_test.dart | JSONL invalid lines report row-scoped errors and cap at 5 | runtime/assertion | no | support | Expected: <1> \|   Actual: <0> |
| failure | test/phase4_regression_inset_guard_test.dart | phase4 inset guard exits cleanly | runtime/assertion | no | support | Expected: <0> \|   Actual: <1> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/mistakes_only_quick_filter_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/mistakes_only_quick_filter_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/mistakes_only_quick_filter_test.dart: test/mistakes_onl |
| failure | test/content_manifest_test.dart | manifest loading | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_similarity_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_similarity_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_similarity_engine_test.dart: test/booster_simila |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_review_queue_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_review_queue_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_review_queue_test.dart: test/theory_lesso |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/pack_unlocking_rules_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/pack_unlocking_rules_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/pack_unlocking_rules_engine_test.dart: test/pack_unloc |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/missing_pack_resolver_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/missing_pack_resolver_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/missing_pack_resolver_test.dart: test/missing_pack_resolver_ |
| failure | test/booster_pack_cluster_exporter_test.dart | export clusters copies packs | runtime/assertion | no | support | Expected: <1> \|   Actual: <0> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/learning_path_auto_seeder_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/learning_path_auto_seeder_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/learning_path_auto_seeder_test.dart: test/learning_path_ |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_service_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_pack_template_service_test.dart: Error: Co |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/live_content_coverage_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/live_content_coverage_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/live_content_coverage_test.dart: test/live_content_coverage_ |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_cluster_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_cluster_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_cluster_engine_test.dart: test/booster_cluster_engi |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_injection_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_injection_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_injection_engine_test.dart: test/booster_injectio |
| failure | test/contracts/store_package_v1_contract_test.dart | store package owner stays bounded, metadata-linked, and non-governing | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| failure | test/contracts/operational_review_packet_truth_v1_contract_test.dart | operational review packet truth stays bounded, runner-backed, and non-governing | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_theory_usage_audit_service_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_theory_usage_audit_service_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_theory_usage_audit_service_test.dart: t |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/booster_mistake_backlink_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/booster_mistake_backlink_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/booster_mistake_backlink_engine_test.dart: test/bo |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/unit_id_utils_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/unit_id_utils_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/unit_id_utils_test.dart: test/unit_id_utils_test.dart:7:26: Error: T |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_explain_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_explain_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/l3_packrun_explain_smoke_test.dart: test/l3_packrun_expla |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/remedial_pack_generator_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/remedial_pack_generator_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/remedial_pack_generator_test.dart: test/remedial_pack_gene |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/ev/l3_autogen_v4_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/ev/l3_autogen_v4_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/ev/l3_autogen_v4_smoke_test.dart: test/ev/l3_autogen_v4_smo |
| error | test/ev/_cli_help_smoke_test.dart | cli --help prints usage ev_rank_jam_fold_deltas.dart | runtime/error | no | support | TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_trail_tracker_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_trail_tracker_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/theory_lesson_trail_tracker_test.dart: test/theory_les |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/yaml_pack_rating_engine_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/yaml_pack_rating_engine_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/yaml_pack_rating_engine_test.dart: test/yaml_pack_rating_e |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/live_smoke_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/live_smoke_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/live_smoke_test.dart: test/live_smoke_test.dart:28:43: Error: The opera |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/learning_path_stage_seeder_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/learning_path_stage_seeder_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/learning_path_stage_seeder_test.dart: test/learning_pat |
| failure | test/csv_io_test.dart | writeCsv writes BOM and CRLF on Windows | runtime/assertion | no | support | Expected: true \|   Actual: <false> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/l3_evaluator_weights_config_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/l3_evaluator_weights_config_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/l3_evaluator_weights_config_test.dart: test/l3_evaluat |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/duplicate_spot_detection_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/duplicate_spot_detection_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/duplicate_spot_detection_test.dart: test/duplicate_spot_d |
| failure | test/theory/theory_integrity_actions_test.dart | action tags resolve to theory ids with overview fallback | runtime/assertion | no | support | Expected: a value greater than or equal to <0.95> \|   Actual: <0.45> |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/e2e_theory_injection_path_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/e2e_theory_injection_path_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/e2e_theory_injection_path_test.dart: test/e2e_theory_inj |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/smart_path_compiler_test.dart | compile | no | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/smart_path_compiler_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/smart_path_compiler_test.dart: test/smart_path_compiler_test.d |
| error |  | loading /Users/elmarsalimzade/Sharky_1.0/test/training_pack_asset_loader_test.dart | compile | yes | support | Failed to load "/Users/elmarsalimzade/Sharky_1.0/test/training_pack_asset_loader_test.dart": \| Compilation failed for testPath=/Users/elmarsalimzade/Sharky_1.0/test/training_pack_asset_loader_test.dart: test/training_pac |
| error | test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart | sizing confirmation resolves its preset option before emitting a completed-decision contract | runtime/error | no | active | Test failed. See exception logs above. \| The test description was: sizing confirmation resolves its preset option before emitting a completed-decision contract |
| error | test/ui_v2/modern_table_blind_level_entry_test.dart | canonical table renders authored blind ownership, blind amounts, and minimal ante indicator | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: canonical table renders authored blind ownership, blind amounts, and minimal ante indicator |
| error | test/ui_v2/modern_table_blind_level_entry_test.dart | canonical table keeps marker-derived blind posting grammar | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: canonical table keeps marker-derived blind posting grammar |
| error | test/ui_v2/session_drill_player_world3_front_slice_contract_test.dart | w3.s03 mixed checkpoint completes as a three-step preflop framework chain | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: w3.s03 mixed checkpoint completes as a three-step preflop framework chain |
| error | test/ui_v2/session_drill_player_board_texture_contract_test.dart | board_texture_classifier_v1 action bar and expected/acceptable/fail outcomes are deterministic | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: board_texture_classifier_v1 action bar and expected/acceptable/fail outcomes are deterministic |
| error | test/ui_v2/session_drill_player_board_texture_contract_test.dart | repaired World 5 sessions surface embedded table state without PREFLOP fallback | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: repaired World 5 sessions surface embedded table state without PREFLOP fallback |
| error | test/ui_v2/progress_map_route_v1_test.dart | progress map route preserves review queue auto-open flag | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: progress map route preserves review queue auto-open flag |
| error | test/ui_v2/session_drill_player_position_thinking_contract_test.dart | position_thinking_choice_v1 keeps actor choice deterministic | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: position_thinking_choice_v1 keeps actor choice deterministic |
| error | test/ui_v2/session_drill_player_position_thinking_contract_test.dart | w2.s02 exposes position bridge intro through supplements | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: w2.s02 exposes position bridge intro through supplements |
| error | test/ui_v2/session_drill_player_world2_outs_review_rendered_acceptance_test.dart | w2.s05 direct canonical path surfaces review recap above the completion surface after the chain completes | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: w2.s05 direct canonical path surfaces review recap above the completion surface after the chain completes |
| error | test/ui_v2/universal_intake_plan_personalization_contract_test.dart | today plan applies the same progression-quality fit as session result | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: today plan applies the same progression-quality fit as session result |
| error | test/ui_v2/drill_runner_host_contract_alignment_test.dart | drill runner consumes explicit authored factual family through the canonical runtime path | compile | no | compat | PathNotFoundException: Cannot open file, path = 'content/core_board_textures/v1/drills.jsonl' (OS Error: No such file or directory, errno = 2) |
| failure | test/ui_v2/today_plan_routing_reason_contract_test.dart | followup b0 and b2 map to deterministic adaptive focus reasons | runtime/assertion | no | compat | Expected: 'Why: To-call accuracy needs reinforcement.' \|   Actual: 'Why: World 4 trained Bet Purpose / Price by connecting intent, price, and action before the click. World 5 now trains Board Awareness through dry, wet,  |
| failure | test/ui_v2/today_plan_routing_reason_contract_test.dart | absent routing target falls back safely and deterministically | runtime/assertion | no | compat | Expected: 'Why: No next campaign pack is available yet.' \|   Actual: 'Why: No next progression step is available yet.' |
| error | test/ui_v2/session_drill_player_world2_source_projection_contract_test.dart | surfaced World 2 sessions project source hero cards into the embedded table scene | runtime/error | no | compat | Test failed. See exception logs above. \| The test description was: surfaced World 2 sessions project source hero cards into the embedded table scene |
| error | test/ui_v2/session_drill_player_world2_source_projection_contract_test.dart | surfaced World 2 sessions project truthful seat role and seat state semantics into the embedded table scene | runtime/error | no | compat | - |

## C. World 2 Donor Diff Classification

Classification: `compatibility-surface regression` with active-adjacent risk. The donor fix touches live non-Act0 session-drill/ModernTable compatibility surface and optional defaults loading. It does not change Act0 route truth, content identity, or evaluator semantics. Do not port in Phase 0.

Compared donor diff paths:
```
M	lib/services/drill_runtime_adapter_v1.dart
A	lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart
A	lib/ui_v2/screens/modern_table_screen_v1.dart
A	lib/ui_v2/screens/session_drill_player_v1_screen.dart
```


## D. Dev-Hub Ownership Evidence

Classification: `debug-only active support`. The owner is the canonical dev access hub route reachable from debug module launcher tooling; it is not canonical Act0 route authority.

```
test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart:55:        moduleLauncher.contains('canonicalDevAccessHubRouteV1()'),
test/guards/canonical_dev_access_hub_contract_test.dart:50:    final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
test/guards/canonical_dev_access_hub_contract_test.dart:56:      find.byKey(const Key('canonical_dev_hub_step_target_input_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:60:      find.byKey(const Key('canonical_dev_hub_step_target_input_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:66:      'canonical_dev_hub_launch_${kWorld1CanonicalModuleOrder.first}_v1',
test/guards/canonical_dev_access_hub_contract_test.dart:92:      final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
test/guards/canonical_dev_access_hub_contract_test.dart:98:        const Key('canonical_dev_hub_world_summary_1_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:107:        const Key('canonical_dev_hub_world_gap_summary_1_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:118:        find.byKey(Key('canonical_dev_hub_status_${firstPackId}_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:125:              find.byKey(Key('canonical_dev_hub_mode_${firstPackId}_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:133:              find.byKey(Key('canonical_dev_hub_host_${firstPackId}_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:141:              find.byKey(Key('canonical_dev_hub_gap_${firstPackId}_v1')),
test/guards/canonical_dev_access_hub_contract_test.dart:150:              'canonical_dev_hub_status_${kWorld1CanonicalModuleOrder[1]}_v1',
test/guards/canonical_dev_access_hub_contract_test.dart:184:    expect(find.text('Canonical Dev Hub'), findsOneWidget);
test/guards/canonical_dev_access_hub_contract_test.dart:187:        Key('canonical_dev_hub_launch_${kWorld1CanonicalModuleOrder.first}_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:235:      final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
test/guards/canonical_dev_access_hub_contract_test.dart:241:        const Key('canonical_dev_hub_launch_w2.s01_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:251:        const Key('canonical_dev_hub_launch_w2.s02_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:261:        const Key('canonical_dev_hub_launch_w3.s11_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:271:        const Key('canonical_dev_hub_launch_w3.s12_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:281:        const Key('canonical_dev_hub_launch_w3.s13_v1'),
test/guards/canonical_dev_access_hub_contract_test.dart:291:        const Key('canonical_dev_hub_launch_w3.s14_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:321:class _CanonicalDevAccessHubScreenV1 extends StatefulWidget {
lib/ui_v2/screens/module_launcher_screen.dart:322:  const _CanonicalDevAccessHubScreenV1();
lib/ui_v2/screens/module_launcher_screen.dart:325:  State<_CanonicalDevAccessHubScreenV1> createState() =>
lib/ui_v2/screens/module_launcher_screen.dart:326:      _CanonicalDevAccessHubScreenV1State();
lib/ui_v2/screens/module_launcher_screen.dart:329:class _CanonicalDevAccessHubScreenV1State
lib/ui_v2/screens/module_launcher_screen.dart:330:    extends State<_CanonicalDevAccessHubScreenV1> {
lib/ui_v2/screens/module_launcher_screen.dart:429:      key: Key('canonical_dev_hub_status_${entry.packId}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:455:        key: Key('canonical_dev_hub_launch_${entry.packId}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:510:                          key: Key('canonical_dev_hub_host_${entry.packId}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:524:                          key: Key('canonical_dev_hub_mode_${entry.packId}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:537:                      key: Key('canonical_dev_hub_gap_${entry.packId}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:566:            key: const Key('canonical_dev_hub_step_target_label_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:584:              key: const Key('canonical_dev_hub_step_target_input_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:612:            key: const Key('canonical_dev_hub_host_truth_label_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:629:            key: const Key('canonical_dev_hub_host_truth_body_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:670:              key: const Key('canonical_dev_hub_reset_progress_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:692:        title: const Text('Canonical Dev Hub'),
lib/ui_v2/screens/module_launcher_screen.dart:706:              key: Key('canonical_dev_hub_world_${worldEntry.world}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:716:                'canonical_dev_hub_world_summary_${worldEntry.world}_v1',
lib/ui_v2/screens/module_launcher_screen.dart:726:              key: Key('canonical_dev_hub_world_shape_${worldEntry.world}_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:736:                'canonical_dev_hub_world_gap_summary_${worldEntry.world}_v1',
lib/ui_v2/screens/module_launcher_screen.dart:757:Route<void> canonicalDevAccessHubRouteV1() {
lib/ui_v2/screens/module_launcher_screen.dart:759:    builder: (_) => const _CanonicalDevAccessHubScreenV1(),
lib/ui_v2/screens/module_launcher_screen.dart:957:                      key: const Key('canonical_dev_hub_entry_tile_v1'),
lib/ui_v2/screens/module_launcher_screen.dart:958:                      title: 'Canonical Dev Hub',
lib/ui_v2/screens/module_launcher_screen.dart:964:                      ).push(canonicalDevAccessHubRouteV1()),
```


## E. Current Gate Evidence

Direct gate/CI hits:
```
.github/workflows/l3-contract.yml:108:      # Flutter smoke отдельно через flutter test
.github/workflows/l3-contract.yml:113:            flutter test test/smoke/win_overlays_smoke_test.dart -r expanded
tools/checkpoint_world1_v1_capture.sh:20:        echo "Usage: ./tools/checkpoint_world1_v1_capture.sh [--repeat N]"
tools/checkpoint_world1_v1_capture.sh:28:      echo "Usage: ./tools/checkpoint_world1_v1_capture.sh [--repeat N]"
tools/checkpoint_world1_v1_capture.sh:48:  local cmd="CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint"
tools/checkpoint_world1_v1_capture.sh:53:  CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint >"$log_path" 2>&1
.github/workflows/full-tests-manual.yml:31:      - run: flutter test --coverage --concurrency=6
tools/health_checks/ui_perf_checks.dart:104:      ['-lc', 'FAST_MODE=1 flutter test test/ui_v2_smoke_test.dart'],
tools/health_dashboard_flutter.dart:2:// Isolates expensive Flutter SDK operations (flutter test, flutter analyze)
tools/health_dashboard_flutter.dart:100:/// Run flutter test
tools/health_dashboard_flutter.dart:102:  stdout.writeln('[Flutter] Running flutter test...');
.github/workflows/unit-tests-nightly.yml:37:      - run: flutter test --coverage --concurrency=6
.github/workflows/ci.yaml:94:            flutter test -r expanded test/l2_*
.github/workflows/ci.yaml:139:            flutter test -r expanded test/packs_manifest_test.dart
.github/workflows/ci.yaml:147:            flutter test -r expanded test/l3_demo_*
.github/workflows/ci.yaml:207:            flutter test -r expanded test/l3_*
tools/act0_real_text_surface_capture_v1.dart:345:      stderr.writeln('screen_review_fast_v1: flutter test timed out.');
tools/release_gate_world10.sh:34:flutter test -r expanded "${WORLD10_SELECTED_TESTS_V1[@]}"
tools/release_gate_world10.sh:38:  flutter test -r expanded
tools/run_gates_changed_v1.sh:139:    run_cmd "flutter test test/tools/content_quality_validator_v1_test.dart"
tools/run_gates_changed_v1.sh:143:    run_cmd "flutter test test/tools/content_quality_validator_v1_test.dart"
tools/run_gates_changed_v1.sh:151:    run_cmd "./tools/fast_loop_world1_v1.sh"
tools/checkpoint_world1_contracts_v1.sh:20:  echo "checkpoint_world1_contracts_v1: run file=${test_file}"
tools/checkpoint_world1_contracts_v1.sh:21:  if ! flutter test "$test_file"; then
tools/checkpoint_world1_contracts_v1.sh:22:    echo "checkpoint_world1_contracts_v1: FAIL file=${test_file}"
tools/checkpoint_world1_contracts_v1.sh:27:echo "checkpoint_world1_contracts_v1: OK tests=${#WORLD1_CONTRACT_TESTS_V1[@]}"
tools/demo_world2.sh:24:FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests
tools/run_release_gate_r5_v1.sh:23:      echo "  --quick   Skip targeted flutter test step"
tools/run_release_gate_r5_v1.sh:59:run_step "fast loop" ./tools/fast_loop_world1_v1.sh
tools/run_release_gate_r5_v1.sh:76:  run_step "critical contract tests" flutter test "${critical_tests[@]}"
tools/release_gate_world3.sh:34:flutter test -r expanded "${WORLD3_SELECTED_TESTS_V1[@]}"
tools/release_gate_world3.sh:38:  flutter test -r expanded
tools/demo_world10.sh:24:FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests
tools/TOOLS_INDEX.md:5:- `tools/checkpoint_world1_v1.sh` — checkpoint gate for World 1 policy loop
tools/TOOLS_INDEX.md:6:- `tools/fast_loop_world1_v1.sh` — fast local validation loop for World 1
tools/TOOLS_INDEX.md:8:- `tools/release_gate_world1.sh` — release gate for World 1
tools/demo_world3.sh:24:FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests
tools/release_gate_world2.sh:34:flutter test -r expanded "${WORLD2_SELECTED_TESTS_V1[@]}"
tools/release_gate_world2.sh:38:  flutter test -r expanded
tools/release_gate_world1.sh:52:./tools/fast_loop_world1_v1.sh --force-tests --all-selected-guards
tools/release_gate_world1.sh:71:  echo "[gate] checkpoint full-suite -> flutter test -r expanded"
tools/release_gate_world1.sh:72:  flutter test -r expanded
tools/lint_tools_v1.sh:16:  tools/fast_loop_world1_v1.sh
tools/lint_tools_v1.sh:20:  tools/release_gate_world1.sh
tools/lint_tools_v1.sh:23:  tools/checkpoint_world1_v1.sh
tools/lint_tools_v1.sh:24:  tools/checkpoint_world1_contracts_v1.sh
tools/lint_tools_v1.sh:25:  tools/checkpoint_world1_v1_capture.sh
tools/lint_tools_v1.sh:43:test -x tools/release_gate_world1.sh
tools/lint_tools_v1.sh:44:echo "  - ok: tools/release_gate_world1.sh"
tools/lint_tools_v1.sh:49:test -x tools/checkpoint_world1_v1.sh
tools/lint_tools_v1.sh:50:echo "  - ok: tools/checkpoint_world1_v1.sh"
tools/lint_tools_v1.sh:51:test -x tools/checkpoint_world1_contracts_v1.sh
tools/lint_tools_v1.sh:52:echo "  - ok: tools/checkpoint_world1_contracts_v1.sh"
tools/lint_tools_v1.sh:53:test -x tools/checkpoint_world1_v1_capture.sh
tools/lint_tools_v1.sh:54:echo "  - ok: tools/checkpoint_world1_v1_capture.sh"
tools/README.md:14:- `./tools/fast_loop_world1_v1.sh`
tools/README.md:15:- `./tools/release_gate_world1.sh`
tools/release_preflight_world1.sh:24:  echo "  ./tools/release_gate_world1.sh"
tools/release_preflight_world1.sh:36:echo "[preflight] Next: ./tools/release_gate_world1.sh"
tools/speed_profile_world1_v1.sh:36:printf 'force-no-cache-key' > .dart_tool/fast_loop_world1_v1.cache
tools/speed_profile_world1_v1.sh:37:run_timed no_cache_s ./tools/fast_loop_world1_v1.sh --force-tests
tools/speed_profile_world1_v1.sh:40:run_timed cached_s ./tools/fast_loop_world1_v1.sh --force-tests
tools/speed_profile_world1_v1.sh:44:  run_timed full_s flutter test -r expanded
tools/health_dashboard.dart:500:        // Retry with flutter test
tools/health_dashboard.dart:519:      // Final fallback: try flutter test once.
tools/health_dashboard.dart:2666:      ['-lc', 'FAST_MODE=1 flutter test test/ui_v2_smoke_test.dart'],
tools/act0_motion_evidence_capture_v1.dart:61:        'act0_motion_evidence_capture_v1: flutter test timed out.',
tools/release_readiness_snapshot_v1.dart:110:    '${root.path}${Platform.pathSeparator}tools${Platform.pathSeparator}release_gate_world1.sh',
tools/fast_loop_runner_compact_v1.sh:40:  flutter test "$TEST_FILE" --plain-name "$name"
tools/_fast_loop_cache_v1.sh:3:FAST_LOOP_CACHE_FILE_V1=".dart_tool/fast_loop_world1_v1.cache"
tools/fast_loop_world1_v1.sh:94:      echo "Usage: ./tools/fast_loop_world1_v1.sh [--full] [--checkpoint] [--no-analyze] [--no-tests] [--force] [--force-tests] [--force-world1-contracts] [--all-selected-guards] [--print-plan]"
tools/fast_loop_world1_v1.sh:143:  run_reason="tier-2 full suite requested"
tools/fast_loop_world1_v1.sh:266:  flutter test -r expanded "${selected_tests[@]}"
tools/fast_loop_world1_v1.sh:270:  flutter test -r expanded
tools/fast_loop_world1_v1.sh:274:  bash tools/checkpoint_world1_contracts_v1.sh
tools/demo_world1.sh:28:FAST_LOOP_SELECTED_TESTS_V1="$demo_tests_env" ./tools/fast_loop_world1_v1.sh --no-analyze --force-tests
tools/demo_world1.sh:54:- Re-run ./tools/release_gate_world1.sh
tools/demo_world1.sh:55:- Re-run flutter test test/guards/world_campaign_routing_matrix_contract_test.dart
tools/demo_world1.sh:56:- Re-run flutter test test/guards/world1_readiness_smoke_contract_test.dart
tools/demo_world1.sh:95:  flutter test test/guards/world_campaign_routing_matrix_contract_test.dart
tools/demo_world1.sh:96:  flutter test test/guards/world1_campaign_telemetry_contract_test.dart
tools/run_table_first_tiers.sh:7:  echo "  tier 1 => targeted flutter tests (includes SSOT guard)"
tools/run_table_first_tiers.sh:65:    echo "Tier 1: running targeted flutter tests"
tools/run_table_first_tiers.sh:82:      run_cmd "flutter test ${path}"
tools/run_table_first_tiers.sh:91:        run_cmd_tier2 "flutter test --update-goldens test/ui_state_golden_test.dart"
tools/run_table_first_tiers.sh:102:      "flutter test"
tools/checkpoint_world1_v1.sh:17:  ./tools/checkpoint_world1_v1_capture.sh "$@"
tools/checkpoint_world1_v1.sh:19:  CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint "$@"
```

### tools/fast_loop_world1_v1.sh
```sh
#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"

source "$ROOT/tools/_world1_selected_tests_v1.sh"
source "$ROOT/tools/_fast_loop_cache_v1.sh"
source "$ROOT/tools/_fast_loop_test_tiers_v1.sh"
source "$ROOT/tools/_test_policy_v1.sh"

readonly -a WORLD1_CONTRACTS_HIGH_RISK_PATHS_V1=(
  "lib/ui_v2/"
  "lib/services/today_router_v1.dart"
  "lib/campaign/"
)
readonly WORLD1_CONTRACTS_HIGH_RISK_REGEX_V1='^(lib/ui_v2/|lib/services/today_router_v1\.dart|lib/campaign/)'
readonly WORLD1_SURFACE_PATH_REGEX_V1='^(lib/ui_v2/act0_shell/act0_play_shell_v1\.dart|test/ui_v2/act0_play_shell_v1_test\.dart)$'
readonly WORLD1_EN_COPY_GUARD_REGEX_V1='^(lib/ui_v2/act0_shell/(act0_play_shell_v1|act0_profile_shell_v1|act0_review_shell_v1|act0_shell_preview_screen_v1)\.dart|test/ui_v2/act0_en_alpha_residue_guard_test\.dart)$'
readonly WORLD1_RU_COPY_GUARD_REGEX_V1='^(lib/ui_v2/act0_shell/(l10n/act0_copy_ru_v1|act0_shell_preview_screen_v1|act0_profile_shell_v1|act0_welcome_shell_v1|act0_review_shell_v1|act0_play_shell_v1|act0_home_shell_v1|act0_learn_path_shell_v1|act0_lesson_runner_shell_v1|act0_placement_shell_v1)\.dart|test/ui_v2/act0_ru_surface_no_unapproved_latin_test\.dart)$'
readonly WORLD1_FEEDBACK_GUARD_REGEX_V1='^(lib/ui_v2/act0_shell/act0_shell_state_v1\.dart|test/ui_v2/act0_shell_state_v1_feedback_test\.dart)$'
readonly WORLD1_CAMPAIGN_GUARD_REGEX_V1='^(lib/campaign/|assets/packs/|content/|test/guards/campaign_pack_registry_invariants_test\.dart|test/guards/campaign_followup_pack_registry_invariants_test\.dart)'

should_run_world1_contracts_checkpoint_v1() {
  local changed_files="$1"
  [[ -n "$changed_files" ]] && echo "$changed_files" | rg -q "$WORLD1_CONTRACTS_HIGH_RISK_REGEX_V1"
}

selected_tests=("${WORLD1_SELECTED_TESTS_STATE_V1[@]}")
if [[ -n "${FAST_LOOP_SELECTED_TESTS_V1:-}" ]]; then
  selected_tests=()
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      selected_tests+=("$line")
    fi
  done <<< "$FAST_LOOP_SELECTED_TESTS_V1"
fi

run_analyze=true
run_tests=true
run_full=false
force=false
force_tests=false
force_world1_contracts=false
print_plan=false
run_content_validation=false
include_all_selected_guards=false
run_reason="default tier-0 selected guard list"
tier_label="Tier0"
policy_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --full)
      run_full=true
      policy_args+=("$1")
      ;;
    --checkpoint)
      run_full=true
      policy_args+=("$1")
      ;;
    --no-analyze)
      run_analyze=false
      ;;
    --no-tests)
      run_tests=false
      run_full=false
      ;;
    --force)
      force=true
      ;;
    --force-tests)
      force_tests=true
      ;;
    --force-world1-contracts)
      force_world1_contracts=true
      ;;
    --all-selected-guards)
      include_all_selected_guards=true
      ;;
    --print-plan)
      print_plan=true
      ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: ./tools/fast_loop_world1_v1.sh [--full] [--checkpoint] [--no-analyze] [--no-tests] [--force] [--force-tests] [--force-world1-contracts] [--all-selected-guards] [--print-plan]"
      exit 2
      ;;
  esac
  shift
done

if [[ ${#policy_args[@]} -gt 0 ]]; then
  test_policy_should_run_full_suite_v1 "${policy_args[@]}"
else
  test_policy_should_run_full_suite_v1
fi
test_policy_require_full_suite_enabled_v1

if [[ "${FAST_LOOP_ALREADY_RAN:-0}" == "1" && "$force" == "false" ]]; then
  echo "Plan:"
  echo "- lint_tools: skipped (nested invocation guard)"
  echo "- dart_analyze: skipped (nested invocation guard)"
  echo "- selected_world1_tests: skipped (nested invocation guard)"
  echo "- full_flutter_test: skipped (nested invocation guard)"
  echo "- Tier: skipped"
  echo "- Reason: NOOP: FAST_LOOP_ALREADY_RAN=1"
  exit 0
fi
export FAST_LOOP_ALREADY_RAN=1

cache_key="$(fast_loop_compute_cache_key_v1 "$ROOT")"
cache_hit=false
if fast_loop_cache_matches_v1 "$cache_key"; then
  cache_hit=true
fi

analyze_status="enabled"
if [[ "$run_analyze" == "true" && "$cache_hit" == "true" && "$force" == "false" ]]; then
  run_analyze=false
  analyze_status="skipped (cache hit; use --force to override)"
elif [[ "$run_analyze" == "false" ]]; then
  analyze_status="skipped (--no-analyze)"
fi

tests_status="enabled"
if [[ "$run_tests" == "false" ]]; then
  tests_status="skipped (--no-tests)"
fi

content_validation_status="disabled"

if [[ "$run_tests" == "true" && "$run_full" == "true" ]]; then
  tests_status="skipped (covered by --full)"
  run_reason="tier-2 full suite requested"
  tier_label="Tier2"
elif [[ "$run_tests" == "true" && "$run_full" == "false" && "$force_tests" == "false" ]]; then
  changed_files="$(fast_loop_collect_changed_files_v1 "$ROOT")"
  if [[ -n "$changed_files" ]] && echo "$changed_files" | rg -q '^content/'; then
    run_content_validation=true
    content_validation_status="enabled"
  else
    content_validation_status="skipped (content unchanged)"
  fi
  if [[ -z "$changed_files" ]]; then
    run_tests=false
    tests_status="skipped (no changed files)"
    run_reason="NOOP: no relevant changes"
  elif ! echo "$changed_files" | rg -q '^(lib/|test/|pubspec\.yaml|pubspec\.lock)'; then
    run_tests=false
    tests_status="skipped (changes outside lib/test/pubspec)"
    run_reason="NOOP: no relevant changes"
  else
    if echo "$changed_files" | rg -q "$WORLD1_SURFACE_PATH_REGEX_V1"; then
      fast_loop_append_unique_tests_v1 selected_tests "${WORLD1_SELECTED_TESTS_SURFACE_V1[@]}"
    fi
    if echo "$changed_files" | rg -q "$WORLD1_EN_COPY_GUARD_REGEX_V1"; then
      fast_loop_append_unique_tests_v1 selected_tests "${WORLD1_SELECTED_TESTS_COPY_GUARDS_V1[0]}"
    fi
    if echo "$changed_files" | rg -q "$WORLD1_RU_COPY_GUARD_REGEX_V1"; then
      fast_loop_append_unique_tests_v1 selected_tests "${WORLD1_SELECTED_TESTS_COPY_GUARDS_V1[1]}"
    fi
    if echo "$changed_files
```

### tools/release_gate_world1.sh
```sh
#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"
source "$ROOT/tools/_test_policy_v1.sh"

test_policy_should_run_full_suite_v1 "$@"
test_policy_require_full_suite_enabled_v1

collect_changed_dart_files_v1() {
  {
    git diff --name-only HEAD
    git ls-files --others --exclude-standard
  } | sort -u | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    [[ "$path" == *.dart ]] || continue
    [[ -f "$path" ]] || continue
    case "$path" in
      lib/*|test/*|bin/*|tool/*|tools/*) ;;
      *) continue ;;
    esac
    echo "$path"
  done
}

echo "[gate] Policy: full-suite $([[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]] && echo "ON" || echo "OFF") ($TEST_POLICY_REASON_V1)"
echo "[gate] 1/5 git diff hygiene"
git diff --check

mapfile -t changed_dart_files < <(collect_changed_dart_files_v1)
if [[ ${#changed_dart_files[@]} -gt 0 ]]; then
  echo "[gate] 2/5 dart format (changed Dart files)"
  dart format --set-exit-if-changed "${changed_dart_files[@]}"
else
  echo "[gate] 2/5 dart format -> skip (no changed Dart files)"
fi

echo "[gate] pre-clean unit test assets"
rm -rf build/unit_test_assets || true
mkdir -p build || true

echo "[gate] 3/5 fast loop (tier checks)"
./tools/fast_loop_world1_v1.sh --force-tests --all-selected-guards

changed_files="$(git diff --name-only HEAD)"

if echo "$changed_files" | rg -q '^content/'; then
  echo "[gate] 4/5 content changed -> validate training content"
  dart run tools/validate_training_content.dart --staged-only
else
  echo "[gate] 4/5 content unchanged -> skip validation"
fi

if echo "$changed_files" | rg -q '^(l10n\.yaml|lib/l10n/.*\.arb)$'; then
  echo "[gate] 5/5 l10n changed -> flutter gen-l10n"
  flutter gen-l10n
else
  echo "[gate] 5/5 l10n unchanged -> skip gen-l10n"
fi

if [[ "$TEST_POLICY_FULL_SUITE_V1" == "1" ]]; then
  echo "[gate] checkpoint full-suite -> flutter test -r expanded"
  flutter test -r expanded
fi

echo "[gate] World1 release gate passed."
```

### tools/checkpoint_world1_v1.sh
```sh
#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"

echo "[checkpoint] CHECKPOINT MODE: lint -> analyze -> tier tests -> full-suite"
if [[ "${CAPTURE:-0}" == "1" ]]; then
  ./tools/checkpoint_world1_v1_capture.sh "$@"
else
  CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint "$@"
fi
```

### tools/_test_policy_v1.sh
```sh
#!/usr/bin/env bash

TEST_POLICY_FULL_SUITE_V1=0
TEST_POLICY_REASON_V1="default"
TEST_POLICY_WANTS_FULL_SUITE_V1=0

test_policy_should_run_full_suite_v1() {
  local arg

  TEST_POLICY_FULL_SUITE_V1=0
  TEST_POLICY_REASON_V1="default: full-suite OFF"
  TEST_POLICY_WANTS_FULL_SUITE_V1=0

  if [[ "${CHECKPOINT:-0}" == "1" ]]; then
    TEST_POLICY_FULL_SUITE_V1=1
    TEST_POLICY_REASON_V1="env CHECKPOINT=1"
  else
    for arg in "$@"; do
      if [[ "$arg" == "--full" || "$arg" == "--checkpoint" ]]; then
        TEST_POLICY_WANTS_FULL_SUITE_V1=1
      fi
      if [[ "$arg" == "--checkpoint" ]]; then
        TEST_POLICY_FULL_SUITE_V1=1
        TEST_POLICY_REASON_V1="explicit flag: $arg"
      fi
    done
  fi

  if [[ "$TEST_POLICY_FULL_SUITE_V1" == "0" ]]; then
    local head_subject
    head_subject="$(git log -1 --pretty=%s 2>/dev/null || true)"
    if [[ "$head_subject" == *"[checkpoint]"* ]]; then
      TEST_POLICY_FULL_SUITE_V1=1
      TEST_POLICY_REASON_V1="HEAD subject contains [checkpoint]"
    fi
  fi
}

test_policy_require_full_suite_enabled_v1() {
  if [[ "$TEST_POLICY_WANTS_FULL_SUITE_V1" == "1" && "$TEST_POLICY_FULL_SUITE_V1" != "1" ]]; then
    echo "ERROR: full-suite is policy-locked and currently OFF ($TEST_POLICY_REASON_V1)." >&2
    echo "Use CHECKPOINT=1 or --checkpoint or [checkpoint] in commit subject." >&2
    return 2
  fi
}
```


## F. Test Directory Tier Counts

| Directory/family | Tier A files | Tier B files | Tier C files | Tier D files |
| --- | --- | --- | --- | --- |
| test/accuracy_utils_test.dart | 0 | 0 | 1 | 0 |
| test/action_entry_test.dart | 0 | 0 | 1 | 0 |
| test/actions_subtitle_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/appinio_swiper_layout_test.dart | 0 | 0 | 1 | 0 |
| test/architecture | 0 | 0 | 7 | 0 |
| test/audit_hub_v1 | 0 | 1 | 0 | 0 |
| test/auto_booster_pruner_test.dart | 0 | 0 | 1 | 0 |
| test/auto_decay_spot_generator_test.dart | 0 | 0 | 1 | 0 |
| test/auto_mistake_tagger_engine_test.dart | 0 | 0 | 1 | 0 |
| test/auto_replay_guard_test.dart | 0 | 0 | 1 | 0 |
| test/auto_replay_invariants_test.dart | 0 | 0 | 1 | 0 |
| test/auto_start_training_prompt_test.dart | 0 | 0 | 1 | 0 |
| test/auto_theory_review_engine_test.dart | 0 | 0 | 1 | 0 |
| test/auto_theory_rewriter_test.dart | 0 | 0 | 1 | 0 |
| test/auto_theory_stage_seeder_test.dart | 0 | 0 | 1 | 0 |
| test/autogen_stats_test.dart | 0 | 0 | 1 | 0 |
| test/bet_sizer_test.dart | 0 | 0 | 1 | 0 |
| test/board_filtering_params_builder_test.dart | 0 | 0 | 1 | 0 |
| test/board_similarity_engine_test.dart | 0 | 0 | 1 | 0 |
| test/board_street_generator_test.dart | 0 | 0 | 1 | 0 |
| test/board_textures_test.dart | 0 | 0 | 1 | 0 |
| test/booster_cluster_engine_test.dart | 0 | 0 | 1 | 0 |
| test/booster_injection_engine_test.dart | 0 | 0 | 1 | 0 |
| test/booster_mistake_backlink_engine_test.dart | 0 | 0 | 1 | 0 |
| test/booster_pack_cluster_exporter_test.dart | 0 | 0 | 1 | 0 |
| test/booster_similarity_engine_test.dart | 0 | 0 | 1 | 0 |
| test/booster_smart_selector_test.dart | 0 | 0 | 1 | 0 |
| test/booster_thematic_tagger_test.dart | 0 | 0 | 1 | 0 |
| test/booster_theory_pack_linker_test.dart | 0 | 0 | 1 | 0 |
| test/booster_theory_usage_audit_service_test.dart | 0 | 0 | 1 | 0 |
| test/booster_variation_injector_test.dart | 0 | 0 | 1 | 0 |
| test/canonical | 0 | 0 | 4 | 0 |
| test/canonical_guard_test.dart | 0 | 0 | 1 | 0 |
| test/cash_l3_pack_test.dart | 0 | 0 | 1 | 0 |
| test/ci_canary_test.dart | 0 | 0 | 1 | 0 |
| test/ci_report_soft_test.dart | 0 | 0 | 1 | 0 |
| test/clipboard_detection_test.dart | 0 | 0 | 1 | 0 |
| test/content | 0 | 0 | 2 | 0 |
| test/content_audit_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/content_manifest_test.dart | 0 | 0 | 1 | 0 |
| test/content_schema_test.dart | 0 | 0 | 1 | 0 |
| test/contracts | 0 | 0 | 25 | 0 |
| test/controllers | 0 | 0 | 2 | 0 |
| test/converter_validation_test.dart | 0 | 0 | 1 | 0 |
| test/core | 0 | 0 | 5 | 0 |
| test/coverage_summary_test.dart | 0 | 0 | 1 | 0 |
| test/csv_io_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_consistency_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_next_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_overlay_guard_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_status_guard_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_status_test.dart | 0 | 0 | 1 | 0 |
| test/curriculum_structure_doc_link_test.dart | 0 | 0 | 1 | 0 |
| test/date_utils_test.dart | 0 | 0 | 1 | 0 |
| test/duplicate_spot_detection_test.dart | 0 | 0 | 1 | 0 |
| test/duplicates_only_filter_test.dart | 0 | 0 | 1 | 0 |
| test/dynamic_spot_generation_test.dart | 0 | 0 | 1 | 0 |
| test/e2e | 0 | 0 | 1 | 0 |
| test/e2e_ab_exposure_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_adaptive_closed_loop_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_adaptive_plan_injection_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_adaptive_training_planner_v2_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_concurrency_locking_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_idempotent_retry_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_path_hardening_rollback_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_theory_injection_path_test.dart | 0 | 0 | 1 | 0 |
| test/e2e_theory_injection_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/engine | 0 | 0 | 4 | 0 |
| test/engine_v2 | 0 | 0 | 10 | 0 |
| test/ev | 0 | 0 | 2 | 0 |
| test/ev_icm_history_chart_test.dart | 0 | 0 | 1 | 0 |
| test/ev_icm_trend_chart_test.dart | 0 | 0 | 1 | 0 |
| test/ev_summary_bucketize_test.dart | 0 | 0 | 1 | 0 |
| test/evaluation_executor_service_test.dart | 0 | 0 | 1 | 0 |
| test/flutter_test_config.dart | 0 | 0 | 1 | 0 |
| test/full_board_generator_multi_street_test.dart | 0 | 0 | 1 | 0 |
| test/full_board_generator_service_test.dart | 0 | 0 | 1 | 0 |
| test/full_board_generator_texture_tags_test.dart | 0 | 0 | 1 | 0 |
| test/full_board_generator_v2_test.dart | 0 | 0 | 1 | 0 |
| test/game_mode_profile_engine_test.dart | 0 | 0 | 1 | 0 |
| test/generate_from_preset_test.dart | 0 | 0 | 1 | 0 |
| test/generate_research_prompts_test.dart | 0 | 0 | 1 | 0 |
| test/graph_path_template_generator_test.dart | 0 | 0 | 1 | 0 |
| test/graph_path_template_parser_test.dart | 0 | 0 | 1 | 0 |
| test/graph_path_template_validator_test.dart | 0 | 0 | 1 | 0 |
| test/graph_template_exporter_test.dart | 0 | 0 | 1 | 0 |
| test/guard_single_site_test.dart | 0 | 0 | 1 | 0 |
| test/guards | 0 | 224 | 0 | 0 |
| test/hand_history_parsing_test.dart | 0 | 0 | 1 | 0 |
| test/headless | 0 | 0 | 1 | 0 |
| test/helpers | 0 | 0 | 2 | 0 |
| test/history_csv_test.dart | 0 | 0 | 1 | 0 |
| test/home_hero_surface_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/home_modules_header_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/home_modules_list_container_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/home_modules_tiles_surface_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/icm_bb_packs_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/icm_bubble_packs_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/icm_l4_bb_pack_test.dart | 0 | 0 | 1 | 0 |
| test/icm_l4_bubble_pack_test.dart | 0 | 0 | 1 | 0 |
| test/icm_l4_ladder_pack_test.dart | 0 | 0 | 1 | 0 |
| test/icm_l4_mix_pack_test.dart | 0 | 0 | 1 | 0 |
| test/icm_l4_sb_pack_test.dart | 0 | 0 | 1 | 0 |
| test/icm_ladder_packs_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/icm_mix_packs_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/icm_push_ev_service_test.dart | 0 | 0 | 1 | 0 |
| test/icm_sb_packs_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/icm_weight_distributor_test.dart | 0 | 0 | 1 | 0 |
| test/import_dup_hint_test.dart | 0 | 0 | 1 | 0 |
| test/injection_block_assembler_test.dart | 0 | 0 | 1 | 0 |
| test/inline_theory_node_linker_test.dart | 0 | 0 | 1 | 0 |
| test/interpolation_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/intro_theory_pack_generator_test.dart | 0 | 0 | 1 | 0 |
| test/jam_dedup_key_test.dart | 0 | 0 | 1 | 0 |
| test/jsonl_importer_roundtrip_test.dart | 0 | 0 | 1 | 0 |
| test/jsonl_loader_test.dart | 0 | 0 | 1 | 0 |
| test/jsonl_validator_test.dart | 0 | 0 | 1 | 0 |
| test/keyframe_timeline_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/kpi_fields_test.dart | 0 | 0 | 1 | 0 |
| test/kpi_gate_test.dart | 0 | 0 | 1 | 0 |
| test/l2_autogen_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/l2_metrics_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/l2_packs_validator_test.dart | 0 | 0 | 1 | 0 |
| test/l2_smoke_gen_test.dart | 0 | 0 | 1 | 0 |
| test/l3_autogen_distribution_test.dart | 0 | 0 | 1 | 0 |
| test/l3_cli_runner_weights_parse_test.dart | 0 | 0 | 1 | 0 |
| test/l3_cli_weights_conflict_warning_test.dart | 0 | 0 | 1 | 0 |
| test/l3_cli_weights_invalid_json_test.dart | 0 | 0 | 1 | 0 |
| test/l3_cli_weights_no_conflict_warning_test.dart | 0 | 0 | 1 | 0 |
| test/l3_demo_sampler_test.dart | 0 | 0 | 1 | 0 |
| test/l3_ev_model_test.dart | 0 | 0 | 1 | 0 |
| test/l3_evaluator_rules_test.dart | 0 | 0 | 1 | 0 |
| test/l3_evaluator_weights_config_test.dart | 0 | 0 | 1 | 0 |
| test/l3_feasibility_test.dart | 0 | 0 | 1 | 0 |
| test/l3_jsonl_decode_test.dart | 0 | 0 | 1 | 0 |
| test/l3_jsonl_export_test.dart | 0 | 0 | 1 | 0 |
| test/l3_metrics_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/l3_packrun_cli_test.dart | 0 | 0 | 1 | 0 |
| test/l3_packrun_explain_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/l3_packrun_presetcounts_test.dart | 0 | 0 | 1 | 0 |
| test/l3_texture_keys_contract_test.dart | 0 | 0 | 1 | 0 |
| test/l3_weights_presets_test.dart | 0 | 0 | 1 | 0 |
| test/l4_icm_sb_jam_vs_fold_test.dart | 0 | 0 | 1 | 0 |
| test/ladder_outcome_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/learning_engine_v1_test.dart | 0 | 0 | 1 | 0 |
| test/learning_heatmap_service_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_auto_expander_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_auto_pack_assigner_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_auto_seeder_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_config_loader_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_controller_gating_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_engine_core_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_graph_orchestrator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_library_generator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_library_validator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_orchestrator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_pack_validator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_progress_service_fallback_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_promoter_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_registry_service_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_stage_seeder_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_stage_template_generator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_stage_unlock_engine_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_stage_unlock_engine_v2_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_template_builder_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_template_validator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_unlock_engine_path_test.dart | 0 | 0 | 1 | 0 |
| test/learning_path_validator_test.dart | 0 | 0 | 1 | 0 |
| test/learning_track_progress_model_test.dart | 0 | 0 | 1 | 0 |
| test/lesson_search_engine_test.dart | 0 | 0 | 1 | 0 |
| test/level_tag_auto_assigner_test.dart | 0 | 0 | 1 | 0 |
| test/line_graph_builder_service_test.dart | 0 | 0 | 1 | 0 |
| test/line_graph_engine_test.dart | 0 | 0 | 1 | 0 |
| test/live_actions_test.dart | 0 | 0 | 1 | 0 |
| test/live_badges_test.dart | 0 | 0 | 1 | 0 |
| test/live_barrel_test.dart | 0 | 0 | 1 | 0 |
| test/live_content_coverage_test.dart | 0 | 0 | 1 | 0 |
| test/live_context_format_test.dart | 0 | 0 | 1 | 0 |
| test/live_context_test.dart | 0 | 0 | 1 | 0 |
| test/live_defaults_test.dart | 0 | 0 | 1 | 0 |
| test/live_event_adapter_test.dart | 0 | 0 | 1 | 0 |
| test/live_ids_consistency_test.dart | 0 | 0 | 1 | 0 |
| test/live_integration_test.dart | 0 | 0 | 1 | 0 |
| test/live_messages_test.dart | 0 | 0 | 1 | 0 |
| test/live_mode_persistence_test.dart | 0 | 0 | 1 | 0 |
| test/live_mode_test.dart | 0 | 0 | 1 | 0 |
| test/live_module_utils_test.dart | 0 | 0 | 1 | 0 |
| test/live_no_flutter_imports_test.dart | 0 | 0 | 1 | 0 |
| test/live_progress_test.dart | 0 | 0 | 1 | 0 |
| test/live_runtime_test.dart | 0 | 0 | 1 | 0 |
| test/live_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/live_telemetry_test.dart | 0 | 0 | 1 | 0 |
| test/live_validators_test.dart | 0 | 0 | 1 | 0 |
| test/manual_legacy_pack_validation_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_auto_injector_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_booster_engine_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_library_builder_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_pack_generator_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_pack_importer_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_path_injector_test.dart | 0 | 0 | 1 | 0 |
| test/mini_lesson_scheduler_test.dart | 0 | 0 | 1 | 0 |
| test/missing_only_filter_test.dart | 0 | 0 | 1 | 0 |
| test/missing_pack_resolver_test.dart | 0 | 0 | 1 | 0 |
| test/mistake_categorization_engine_test.dart | 0 | 0 | 1 | 0 |
| test/mistake_cluster_analytics_service_test.dart | 0 | 0 | 1 | 0 |
| test/mistake_tag_classifier_test.dart | 0 | 0 | 1 | 0 |
| test/mistake_tag_cluster_service_test.dart | 0 | 0 | 1 | 0 |
| test/mistakes_only_quick_filter_test.dart | 0 | 0 | 1 | 0 |
| test/models | 0 | 0 | 8 | 0 |
| test/modern_table_audit_doc_contract_test.dart | 0 | 0 | 1 | 0 |
| test/modern_table_audit_hub_test.dart | 0 | 0 | 1 | 0 |
| test/modern_table_audit_note_test.dart | 0 | 0 | 1 | 0 |
| test/modern_table_audit_pack_hint_test.dart | 0 | 0 | 1 | 0 |
| test/modern_table_pr_snippet_test.dart | 0 | 0 | 1 | 0 |
| test/modern_table_screenshot_contract_test.dart | 0 | 0 | 1 | 0 |
| test/mvp_pack_library_test.dart | 0 | 0 | 1 | 0 |
| test/mvs_player_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/navigation | 0 | 0 | 1 | 0 |
| test/new_only_filter_test.dart | 0 | 0 | 1 | 0 |
| test/pack_augmentation_engine_test.dart | 0 | 0 | 1 | 0 |
| test/pack_completion_stats_service_test.dart | 0 | 0 | 1 | 0 |
| test/pack_library_generator_test.dart | 0 | 0 | 1 | 0 |
| test/pack_library_generator_v2_test.dart | 0 | 0 | 1 | 0 |
| test/pack_run_controller_test.dart | 0 | 0 | 1 | 0 |
| test/pack_run_session_state_test.dart | 0 | 0 | 1 | 0 |
| test/pack_search_engine_test.dart | 0 | 0 | 1 | 0 |
| test/pack_search_index_service_test.dart | 0 | 0 | 1 | 0 |
| test/pack_similarity_engine_test.dart | 0 | 0 | 1 | 0 |
| test/pack_unlocking_rules_engine_test.dart | 0 | 0 | 1 | 0 |
| test/pack_yaml_config_parser_test.dart | 0 | 0 | 1 | 0 |
| test/packs_manifest_test.dart | 0 | 0 | 1 | 0 |
| test/path_suggestion_engine_test.dart | 0 | 0 | 1 | 0 |
| test/payments | 0 | 0 | 1 | 0 |
| test/personalization | 0 | 0 | 25 | 0 |
| test/phase1_summarize_logs_test.dart | 0 | 0 | 1 | 0 |
| test/phase2_summarize_logs_test.dart | 0 | 0 | 1 | 0 |
| test/phase3_summarize_logs_test.dart | 0 | 0 | 1 | 0 |
| test/phase4_emit_sample_logs_test.dart | 0 | 0 | 1 | 0 |
| test/phase4_precommit_all_flag_test.dart | 0 | 0 | 1 | 0 |
| test/phase4_regression_docs_contract_test.dart | 0 | 0 | 1 | 0 |
| test/phase4_regression_inset_guard_test.dart | 0 | 0 | 1 | 0 |
| test/phase4_regression_validate_logs_test.dart | 0 | 0 | 1 | 0 |
| test/plugin_loader_io_test.dart | 0 | 0 | 1 | 0 |
| test/presenters | 0 | 0 | 1 | 0 |
| test/profile | 0 | 0 | 1 | 0 |
| test/proof | 0 | 0 | 1 | 0 |
| test/push_fold_btn_cash_library_test.dart | 0 | 0 | 1 | 0 |
| test/push_fold_helpers_test.dart | 0 | 0 | 1 | 0 |
| test/quarantine | 0 | 0 | 7 | 0 |
| test/range_library_service_test.dart | 0 | 0 | 1 | 0 |
| test/recall_cooldown_test.dart | 0 | 0 | 1 | 0 |
| test/remedial_analyzer_test.dart | 0 | 0 | 1 | 0 |
| test/remedial_generation_controller_test.dart | 0 | 0 | 1 | 0 |
| test/remedial_pack_generator_test.dart | 0 | 0 | 1 | 0 |
| test/report_csv_test.dart | 0 | 0 | 1 | 0 |
| test/result_summary_json_test.dart | 0 | 0 | 1 | 0 |
| test/review_path_recommender_test.dart | 0 | 0 | 1 | 0 |
| test/rich_id_labels_test.dart | 0 | 0 | 1 | 0 |
| test/room_hand_history_importer_test.dart | 0 | 0 | 1 | 0 |
| test/saved_hand_service_test.dart | 0 | 0 | 1 | 0 |
| test/screens | 0 | 0 | 2 | 0 |
| test/select_duplicates_test.dart | 0 | 0 | 1 | 0 |
| test/services | 0 | 0 | 562 | 0 |
| test/session_analysis_screen_test.dart | 0 | 0 | 1 | 0 |
| test/session_flow_timer_test.dart | 0 | 0 | 1 | 0 |
| test/session_start_timing_guard_test.dart | 0 | 0 | 1 | 0 |
| test/skill_tag_coverage_tracker_test.dart | 0 | 0 | 1 | 0 |
| test/skill_targeting_recommender_test.dart | 0 | 0 | 1 | 0 |
| test/skill_tree_motivational_hint_engine_test.dart | 0 | 0 | 1 | 0 |
| test/smart_mini_booster_planner_test.dart | 0 | 0 | 1 | 0 |
| test/smart_mistake_review_strategy_test.dart | 0 | 0 | 1 | 0 |
| test/smart_path_compiler_test.dart | 0 | 0 | 1 | 0 |
| test/smart_path_seed_generator_test.dart | 0 | 0 | 1 | 0 |
| test/smart_path_ux_hints_service_test.dart | 0 | 0 | 1 | 0 |
| test/smart_recap_auto_injector_test.dart | 0 | 0 | 1 | 0 |
| test/smoke | 0 | 0 | 22 | 0 |
| test/spot_factory_level2_engine_test.dart | 0 | 0 | 1 | 0 |
| test/spot_importer_json_modes_test.dart | 0 | 0 | 1 | 0 |
| test/spot_importer_jsonl_test.dart | 0 | 0 | 1 | 0 |
| test/spot_importer_parse_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/spot_importer_roundtrip_test.dart | 0 | 0 | 1 | 0 |
| test/spot_importer_test.dart | 0 | 0 | 1 | 0 |
| test/spot_line_graph_engine_test.dart | 0 | 0 | 1 | 0 |
| test/spot_maps_coverage_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_auto_replay_invariants_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_autoreplay_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_core_call_vs_price_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_icm_ssot_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_jamfold_helper_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_should_auto_replay_test.dart | 0 | 0 | 1 | 0 |
| test/spot_specs_ssot_consistency_test.dart | 0 | 0 | 1 | 0 |
| test/spot_validation_test.dart | 0 | 0 | 1 | 0 |
| test/spotkind_enum_discipline_test.dart | 0 | 0 | 1 | 0 |
| test/spotkind_integrity_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/spotkind_naming_validator_test.dart | 0 | 0 | 1 | 0 |
| test/ssot_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/stack_range_filter_test.dart | 0 | 0 | 1 | 0 |
| test/staged_path_promoter_test.dart | 0 | 0 | 1 | 0 |
| test/starter_learning_path_builder_test.dart | 0 | 0 | 1 | 0 |
| test/stubs | 0 | 0 | 0 | 4 |
| test/tag_retention_tracker_test.dart | 0 | 0 | 1 | 0 |
| test/telemetry_builder_smoke_test.dart | 0 | 0 | 1 | 0 |
| test/telemetry_builder_test.dart | 0 | 0 | 1 | 0 |
| test/telemetry_mode_test.dart | 0 | 0 | 1 | 0 |
| test/temp_cleanup_test.dart | 0 | 0 | 1 | 0 |
| test/template_ev_cache_test.dart | 0 | 0 | 1 | 0 |
| test/test_stubs.dart | 0 | 0 | 1 | 0 |
| test/test_utils | 0 | 0 | 1 | 0 |
| test/theory | 0 | 0 | 1 | 0 |
| test/theory_booster_generator_test.dart | 0 | 0 | 1 | 0 |
| test/theory_booster_injector_test.dart | 0 | 0 | 1 | 0 |
| test/theory_booster_pack_linker_test.dart | 0 | 0 | 1 | 0 |
| test/theory_injection_engine_test.dart | 0 | 0 | 1 | 0 |
| test/theory_lesson_auto_linker_test.dart | 0 | 0 | 1 | 0 |
| test/theory_lesson_node_fallback_test.dart | 0 | 0 | 1 | 0 |
| test/theory_lesson_reachability_validator_test.dart | 0 | 0 | 1 | 0 |
| test/theory_lesson_review_queue_test.dart | 0 | 0 | 1 | 0 |
| test/theory_lesson_trail_tracker_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_auto_indexer_service_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_auto_tagger_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_completion_estimator_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_generator_service_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_generator_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_library_service_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_review_status_engine_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_sampler_test.dart | 0 | 0 | 1 | 0 |
| test/theory_pack_seeder_level2_test.dart | 0 | 0 | 1 | 0 |
| test/theory_smart_entry_point_selector_test.dart | 0 | 0 | 1 | 0 |
| test/theory_snippet_coverage_test.dart | 0 | 0 | 1 | 0 |
| test/theory_stage_auto_seeder_test.dart | 0 | 0 | 1 | 0 |
| test/theory_validation_engine_test.dart | 0 | 0 | 1 | 0 |
| test/title_utils_test.dart | 0 | 0 | 1 | 0 |
| test/tools | 0 | 165 | 0 | 0 |
| test/training_history_widgets_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_asset_loader_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_fingerprint_generator_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_generator_v2_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_library_theme_filter_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_ranking_engine_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_sampler_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_spot_serialization_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_spot_yaml_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_expander_full_board_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_metadata_validator_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_service_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_set_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_v2_from_json_test.dart | 0 | 0 | 1 | 0 |
| test/training_pack_template_v2_to_yaml_string_test.dart | 0 | 0 | 1 | 0 |
| test/training_progress_service_test.dart | 0 | 0 | 1 | 0 |
| test/training_progress_timeline_service_test.dart | 0 | 0 | 1 | 0 |
| test/training_result_test.dart | 0 | 0 | 1 | 0 |
| test/training_spot_expander_test.dart | 0 | 0 | 1 | 0 |
| test/ui | 0 | 0 | 8 | 0 |
| test/ui_v2 | 73 | 185 | 0 | 0 |
| test/ui_v2_smoke_test.dart | 0 | 1 | 0 | 0 |
| test/ui_v2_visual_haptics_test.dart | 0 | 1 | 0 | 0 |
| test/ui_v2_visual_motion_test.dart | 0 | 1 | 0 | 0 |
| test/ui_v2_visual_tokens_test.dart | 0 | 1 | 0 | 0 |
| test/undo_history | 0 | 0 | 1 | 0 |
| test/unit | 0 | 0 | 2 | 0 |
| test/unit_id_utils_test.dart | 0 | 0 | 1 | 0 |
| test/utils | 0 | 0 | 3 | 0 |
| test/weakness_cluster_engine_test.dart | 0 | 0 | 1 | 0 |
| test/weakness_cluster_engine_v2_test.dart | 0 | 0 | 1 | 0 |
| test/weakness_log_test.dart | 0 | 0 | 1 | 0 |
| test/weakness_review_engine_test.dart | 0 | 0 | 1 | 0 |
| test/weakness_tag_resolver_test.dart | 0 | 0 | 1 | 0 |
| test/widget_test.dart | 0 | 0 | 1 | 0 |
| test/widgets | 0 | 0 | 67 | 0 |
| test/yaml_duplicate_detector_service_test.dart | 0 | 0 | 1 | 0 |
| test/yaml_lesson_track_loader_test.dart | 0 | 0 | 1 | 0 |
| test/yaml_pack_auto_tag_engine_test.dart | 0 | 0 | 1 | 0 |
| test/yaml_pack_auto_tagger_test.dart | 0 | 0 | 1 | 0 |
| test/yaml_pack_importer_service_test.dart | 0 | 0 | 1 | 0 |
| test/yaml_pack_rating_engine_test.dart | 0 | 0 | 1 | 0 |

## G. Phase 1 Batch Evidence

| Order | Symbol/group | Direct files | Canonical import | Validation | Rollback boundary | Fable suitability |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ShareOptions | 3 | lib/share/share_options.dart or product-specific sharing facade (missing exact canonical owner) | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 2 | GameType | 45 | lib/models/game_type.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 3 | TrainingType | 139 | lib/core/training/engine/training_type_engine.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 4 | TrainingPackLevel | 4 | lib/models/v2/pack_ux_metadata.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 5 | HeroPosition | 59 | lib/models/v2/hero_position.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 6 | HeroPositionLabel | 0 | lib/models/v2/hero_position.dart / lib/utils/hero_position_ext.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 7 | TrainingPackTemplateV2 | 71 | lib/models/v2/training_pack_template_v2.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 8 | MixedDrillStat | 0 | lib/models/mixed_drill_stat.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 9 | TagGoalProgress | 2 | lib/models/tag_goal_progress.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 10 | HandData | 103 | lib/models/v2/hand_data.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 11 | isAutoReplayKind | 5 | lib/ui/session_player/spot_specs.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 12 | MixedDrillHistoryService | 0 | lib/services/mixed_drill_history_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 13 | TrainingSessionService | 66 | lib/services/training_session_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 14 | TrainingPackService | 0 | lib/services/training_pack_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 15 | RecentTrainingPackSection | 0 | lib/widgets/v2/recent_training_pack_section.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 16 | FilterSummaryBar | 0 | lib/widgets/filter_summary_bar.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 17 | AppColors | 0 | lib/theme/app_colors.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 18 | MiniLessonLibraryService | 66 | lib/services/mini_lesson_library_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 19 | PackLibraryService | 13 | lib/services/pack_library_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes |
| 20 | RecallSuccessLoggerService | 7 | lib/services/recall_success_logger_service.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 21 | SmartTheoryRecapDismissalMemory | 4 | lib/services/smart_theory_recap_dismissal_memory.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |
| 22 | AppLocalizations | 2 | lib/l10n/app_localizations.dart or lib/flutter_gen/gen_l10n/app_localizations.dart | Focused importer rewrite; run affected tests plus Tier A gates | revert batch commit | yes-small |