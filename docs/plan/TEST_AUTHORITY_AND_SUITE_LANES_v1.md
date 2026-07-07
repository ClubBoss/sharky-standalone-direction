# TEST_AUTHORITY_AND_SUITE_LANES_v1

Status: PROPOSED CANONICAL TEST AUTHORITY MANIFEST. Phase 0 only; no CI partition has been implemented.

## Purpose
Define the suite lanes needed to migrate away from `lib/testing/test_shims.dart` without treating dormant, support, and active authorities as one merge-blocking suite.

## Locked Product Truth
- Act0 remains the canonical active learner route.
- W1-W6 route/content/evaluator/feedback and Wave 5 telemetry/repair semantics are unchanged.
- Modern Table and session-drill surfaces are maintained compatibility/support unless explicitly promoted by a later product wave.

## Tier Definitions

| Tier | Name | Owner | Blocking policy | Compile policy | Expiry / next action |
| --- | --- | --- | --- | --- | --- |
| A | Active Release-Critical | Act0 shell, W1-W6 active route, telemetry/repair guards | Blocks merge and release | Must compile and pass on every merge | No expiry; keep minimal and green |
| B | Maintained Compatibility/Support | ModernTable/session-drill compatibility, Audit Hub, tooling, canonical guards | Blocks checkpoint; release-blocking only when invoked by release lane | Must compile within lane after migration batch | Migrate shims mechanically, then decide promotion/retention |
| C | Historical/Quarantined | Old global-suite, quarantine, dormant tests without active owner | Does not block merge/release | May be compile-red until owner batch; must be listed | Assign owner, migrate to A/B or retire with proof |
| D | Retired | Fixture-only, obsolete tests, replaced assertions | Does not block | Excluded from executable gates after replacement proof | Delete/retire only with replacement proof path |

## Tier Assignment Summary

| Tier | Assigned directory/family rows | Phase 0 policy |
| --- | ---: | --- |
| A | 0 | Active release-critical tests remain governed by existing focused gates until Phase 1 promotes explicit lane entries. |
| B | 8 | Maintained support and compatibility families are listed for shim migration before checkpoint/release lane enforcement. |
| C | 366 | Historical or owner-uncertain families are listed explicitly; none are silently excluded from future owner review. |
| D | 1 | Retired-family status requires replacement-proof review before executable removal. |

## Directory/Family Assignment

| Directory/family | Tier | Owner | Blocking policy | Compile policy | Expiry/next action | Replacement proof for Tier D |
| --- | --- | --- | --- | --- | --- | --- |
| test/accuracy_utils_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/action_entry_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/actions_subtitle_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/appinio_swiper_layout_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/architecture | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/audit_hub_v1 | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_booster_pruner_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_decay_spot_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_mistake_tagger_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_replay_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_replay_invariants_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_start_training_prompt_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_theory_review_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_theory_rewriter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/auto_theory_stage_seeder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/autogen_stats_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/bet_sizer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/board_filtering_params_builder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/board_similarity_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/board_street_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/board_textures_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_cluster_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_injection_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_mistake_backlink_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_pack_cluster_exporter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_similarity_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_smart_selector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_thematic_tagger_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_theory_pack_linker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_theory_usage_audit_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/booster_variation_injector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/canonical | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/canonical_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/cash_l3_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ci_canary_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ci_report_soft_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/clipboard_detection_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/content | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/content_audit_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/content_manifest_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/content_schema_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/contracts | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/controllers | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/converter_validation_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/core | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/coverage_summary_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/csv_io_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_consistency_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_next_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_overlay_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_status_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_status_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/curriculum_structure_doc_link_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/date_utils_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/duplicate_spot_detection_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/duplicates_only_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/dynamic_spot_generation_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_ab_exposure_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_adaptive_closed_loop_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_adaptive_plan_injection_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_adaptive_training_planner_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_concurrency_locking_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_idempotent_retry_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_path_hardening_rollback_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_theory_injection_path_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/e2e_theory_injection_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/engine | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/engine_v2 | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ev | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ev_icm_history_chart_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ev_icm_trend_chart_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ev_summary_bucketize_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/evaluation_executor_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/flutter_test_config.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/full_board_generator_multi_street_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/full_board_generator_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/full_board_generator_texture_tags_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/full_board_generator_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/game_mode_profile_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/generate_from_preset_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/generate_research_prompts_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/graph_path_template_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/graph_path_template_parser_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/graph_path_template_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/graph_template_exporter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/guard_single_site_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/guards | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/hand_history_parsing_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/headless | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/helpers | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/history_csv_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/home_hero_surface_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/home_modules_header_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/home_modules_list_container_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/home_modules_tiles_surface_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_bb_packs_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_bubble_packs_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_l4_bb_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_l4_bubble_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_l4_ladder_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_l4_mix_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_l4_sb_pack_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_ladder_packs_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_mix_packs_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_push_ev_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_sb_packs_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/icm_weight_distributor_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/import_dup_hint_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/injection_block_assembler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/inline_theory_node_linker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/interpolation_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/intro_theory_pack_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/jam_dedup_key_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/jsonl_importer_roundtrip_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/jsonl_loader_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/jsonl_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/keyframe_timeline_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/kpi_fields_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/kpi_gate_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l2_autogen_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l2_metrics_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l2_packs_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l2_smoke_gen_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_autogen_distribution_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_cli_runner_weights_parse_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_cli_weights_conflict_warning_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_cli_weights_invalid_json_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_cli_weights_no_conflict_warning_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_demo_sampler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_ev_model_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_evaluator_rules_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_evaluator_weights_config_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_feasibility_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_jsonl_decode_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_jsonl_export_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_metrics_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_packrun_cli_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_packrun_explain_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_packrun_presetcounts_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_texture_keys_contract_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l3_weights_presets_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/l4_icm_sb_jam_vs_fold_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ladder_outcome_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_engine_v1_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_heatmap_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_auto_expander_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_auto_pack_assigner_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_auto_seeder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_config_loader_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_controller_gating_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_engine_core_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_graph_orchestrator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_library_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_library_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_orchestrator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_pack_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_progress_service_fallback_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_promoter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_registry_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_stage_seeder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_stage_template_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_stage_unlock_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_stage_unlock_engine_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_template_builder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_template_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_unlock_engine_path_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_path_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/learning_track_progress_model_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/lesson_search_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/level_tag_auto_assigner_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/line_graph_builder_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/line_graph_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_actions_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_badges_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_barrel_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_content_coverage_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_context_format_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_context_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_defaults_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_event_adapter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_ids_consistency_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_integration_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_messages_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_mode_persistence_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_mode_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_module_utils_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_no_flutter_imports_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_progress_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_runtime_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_telemetry_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/live_validators_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/manual_legacy_pack_validation_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_auto_injector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_booster_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_library_builder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_pack_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_pack_importer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_path_injector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mini_lesson_scheduler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/missing_only_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/missing_pack_resolver_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mistake_categorization_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mistake_cluster_analytics_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mistake_tag_classifier_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mistake_tag_cluster_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mistakes_only_quick_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/models | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_audit_doc_contract_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_audit_hub_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_audit_note_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_audit_pack_hint_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_pr_snippet_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/modern_table_screenshot_contract_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mvp_pack_library_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/mvs_player_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/navigation | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/new_only_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_augmentation_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_completion_stats_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_library_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_library_generator_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_run_controller_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_run_session_state_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_search_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_search_index_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_similarity_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_unlocking_rules_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/pack_yaml_config_parser_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/packs_manifest_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/path_suggestion_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/payments | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/personalization | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase1_summarize_logs_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase2_summarize_logs_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase3_summarize_logs_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase4_emit_sample_logs_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase4_precommit_all_flag_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase4_regression_docs_contract_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase4_regression_inset_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/phase4_regression_validate_logs_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/plugin_loader_io_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/presenters | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/profile | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/proof | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/push_fold_btn_cash_library_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/push_fold_helpers_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/quarantine | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/range_library_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/recall_cooldown_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/remedial_analyzer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/remedial_generation_controller_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/remedial_pack_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/report_csv_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/result_summary_json_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/review_path_recommender_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/rich_id_labels_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/room_hand_history_importer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/saved_hand_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/screens | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/select_duplicates_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/services | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/session_analysis_screen_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/session_flow_timer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/session_start_timing_guard_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/skill_tag_coverage_tracker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/skill_targeting_recommender_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/skill_tree_motivational_hint_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_mini_booster_planner_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_mistake_review_strategy_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_path_compiler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_path_seed_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_path_ux_hints_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smart_recap_auto_injector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/smoke | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_factory_level2_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_importer_json_modes_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_importer_jsonl_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_importer_parse_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_importer_roundtrip_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_importer_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_line_graph_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_maps_coverage_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_auto_replay_invariants_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_autoreplay_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_core_call_vs_price_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_icm_ssot_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_jamfold_helper_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_should_auto_replay_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_specs_ssot_consistency_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spot_validation_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spotkind_enum_discipline_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spotkind_integrity_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/spotkind_naming_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ssot_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/stack_range_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/staged_path_promoter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/starter_learning_path_builder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/stubs | D | see evidence owner map | per tier definition | per tier definition | none | required before deletion |
| test/tag_retention_tracker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/telemetry_builder_smoke_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/telemetry_builder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/telemetry_mode_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/temp_cleanup_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/template_ev_cache_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/test_stubs.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/test_utils | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_booster_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_booster_injector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_booster_pack_linker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_injection_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_lesson_auto_linker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_lesson_node_fallback_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_lesson_reachability_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_lesson_review_queue_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_lesson_trail_tracker_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_auto_indexer_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_auto_tagger_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_completion_estimator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_generator_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_library_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_review_status_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_sampler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_pack_seeder_level2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_smart_entry_point_selector_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_snippet_coverage_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_stage_auto_seeder_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/theory_validation_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/title_utils_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/tools | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_history_widgets_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_asset_loader_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_fingerprint_generator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_generator_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_library_theme_filter_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_ranking_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_sampler_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_spot_serialization_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_spot_yaml_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_expander_full_board_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_metadata_validator_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_set_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_v2_from_json_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_pack_template_v2_to_yaml_string_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_progress_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_progress_timeline_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_result_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/training_spot_expander_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui_v2 | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui_v2_smoke_test.dart | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui_v2_visual_haptics_test.dart | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui_v2_visual_motion_test.dart | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/ui_v2_visual_tokens_test.dart | B | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/undo_history | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/unit | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/unit_id_utils_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/utils | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/weakness_cluster_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/weakness_cluster_engine_v2_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/weakness_log_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/weakness_review_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/weakness_tag_resolver_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/widget_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/widgets | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_duplicate_detector_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_lesson_track_loader_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_pack_auto_tag_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_pack_auto_tagger_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_pack_importer_service_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |
| test/yaml_pack_rating_engine_test.dart | C | see evidence owner map | per tier definition | per tier definition | Phase 1 owner review | - |

## Current Gate Architecture

| Command | Current membership | Blocks merge | Blocks release | Invokes global suite | Required change |
| --- | --- | --- | --- | --- | --- |
| ./tools/fast_loop_world1_v1.sh | World1/Act0 fast policy loop via selected tier scripts | Yes for active lane | No by itself | No | Recast as Tier A fast gate |
| ./tools/release_gate_world1.sh | Release gate wrapper around active World1 policy checks | Yes when release path invoked | Yes | No | Keep Tier A/B release-selected only |
| ./tools/checkpoint_world1_v1.sh | Checkpoint batch for broader World1 contracts | No for ordinary merge | Checkpoint only | No | Map to Tier B checkpoint lane |
| flutter test / full suite | All discoverable tests mixed together | No until partitioned | No until partitioned | Yes | Replace with lane umbrella plus non-blocking historical report |
| GitHub workflows | Mixed analyze/unit/content/manual full-test workflows | Depends workflow | Depends workflow | Manual/nightly can invoke broad tests | Update only after Phase 1 evidence batches |

## Phase 1 Ordered Migration Batches

| Order | Symbol/group | File count | Expected canonical import | Validation after batch | Rollback boundary | Fable suitable |
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

## Phase 2 Lane Plan
- Add lane manifest parser and umbrella command after Phase 1 symbols are migrated.
- Commands: `test_tier_a_active`, `test_tier_b_compat_support`, `test_tier_c_historical_report`, and `test_all_lanes_report`.
- Merge semantics: Tier A blocks merge; Tier B blocks checkpoint; Tier C reports only; Tier D excluded after replacement proof.
- Release semantics: Tier A plus selected Tier B release support blocks release.
- Reporting: emit JSONL per lane with file counts, pass/fail/error counts, and owner labels.


## Evidence Pointer
See `docs/_reviews/test_authority_migration_phase0_evidence_freeze_v1.md` for the exact 921-file classifier, per-symbol counts, donor failure/error matrix, World 2 classification, and dev-hub evidence.
