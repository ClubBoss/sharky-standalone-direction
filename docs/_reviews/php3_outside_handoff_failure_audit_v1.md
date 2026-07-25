# PHP-3 Outside-Handoff Failure Audit v1

## Scope and verified evidence

This is the durable condensed record of the independent Claude read-only audit.
Its raw log (`56,015` lines), parsed JSON, and transient parser outputs remain
local-only evidence; no machine-specific path below is an authority source.

- Pinned audit baseline: `190721a5dfa86ad65b716c071fcc09371857d35f`.
- Final applicability at PR #63 / `03cc8ac8c71a072e842b159fdfffac1b8b09e0cf`:
  `STILL_APPLICABLE_NO_OVERLAP`. PR #63 changed neither the classified 39
  paths nor their direct production owners.
- Measurement command: `flutter test test/ui_v2 test/guards`.
- Measurement result at the pinned baseline: `1810` passed and `168` failed:
  `72` compile/load failure files and `96` assertion blocks, across `110`
  distinct failing files.
- PHP-3 unresolved-handoff denominator at the audit baseline: `76`; after PR
  #63's separate admitted work it is `74`. This packet does not change that
  denominator.

The historical PHP-2 evidence recorded an aggregate outside-handoff count of
40, while the pinned audit measured 39. The exact historical 40-path list was
never committed, so the one-file delta cannot be attributed to a named path.
The following 39-path inventory is the durable precise baseline; it must not
be represented as a reconstructed historical list.

## Original 39-path classification

All rows are non-blocking for PHP-3 carrier extraction. `Tier` is the
test-authority membership at audit time. Most rows were absent/unclassified;
`test/ui_v2/runner/world1_seat_quiz_feedback_copy_v1_test.dart` was the sole
Tier-B member in this 39-path set.

| Path | Failure | Classification | Direct owner | Tier | PHP-3 blocker | Next action |
| --- | --- | --- | --- | --- | --- | --- |
| `test/guards/app_lifecycle_resume_nonblank_v1_test.dart` | assertion | ACTIVE_NONBLOCKING | app root / secondary map-resume smoke | absent | no | preserve |
| `test/guards/board_texture_dry_subset_policy_pilot_v1_test.dart` | assertion | ARCHIVED_NONCANONICAL | retired pilot | absent | no | future deletion only |
| `test/guards/campaign_spine_structure_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | historical campaign-pack owner | absent | no | preserve |
| `test/guards/canonical_launcher_phase_cutover_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy launcher owner | absent | no | preserve |
| `test/guards/canonical_terminal_world1_runtime_config_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy runner owner | absent | no | preserve; do not conflate with `_v1` carrier |
| `test/guards/early_world_arc_progression_rhythm_wave_test.dart` | assertion | QUARANTINED_WITH_OWNER | dormant owner | absent | no | preserve |
| `test/guards/exact_board_texture_subset_pilot_v1_test.dart` | assertion | ARCHIVED_NONCANONICAL | retired pilot | absent | no | future deletion only |
| `test/guards/exact_initiative_subset_pilot_v1_test.dart` | assertion | ARCHIVED_NONCANONICAL | retired pilot | absent | no | future deletion only |
| `test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart` | assertion | ACTIVE_NONBLOCKING | current preview owner | absent | no | preserve |
| `test/guards/initiative_pressure_subset_policy_pilot_v1_test.dart` | assertion | ARCHIVED_NONCANONICAL | retired pilot | absent | no | future deletion only |
| `test/guards/map_black_screen_regression_v1_test.dart` | assertion | QUARANTINED_WITH_OWNER | map owner | absent | no | preserve |
| `test/guards/next_module_visibility_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy result/map owner | absent | no | preserve |
| `test/guards/onboarding_legacy_completion_boot_parity_contract_test.dart` | assertion | ACTIVE_NONBLOCKING | app-root boot owner | absent | no | preserve |
| `test/guards/phone_first_near10_visual_lift_v3_contract_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active Act0 visual owner | absent | no | preserve for later visual packet |
| `test/guards/phone_first_premium_polish_v4_contract_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active Act0 visual owner | absent | no | preserve DLR-003 evidence |
| `test/guards/session_result_non_spine_entry_routing_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy result owner | absent | no | preserve |
| `test/guards/table_first_practice_shell_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy shell owner | absent | no | preserve |
| `test/guards/targeted_content_repairs_contract_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active content-claim owner | absent | no | preserve intact |
| `test/guards/w10_to_w11_transition_policy_contract_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active progression owner | absent | no | preserve intact |
| `test/guards/world1_campaign_completion_unlock_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy map owner | absent | no | preserve |
| `test/guards/world1_foundations_microtask_contract_test.dart` | assertion | ARCHIVED_NONCANONICAL | archived | absent | no | future deletion only |
| `test/guards/world1_plan_result_compact_height_no_overflow_contract_test.dart` | assertion | ACTIVE_NONBLOCKING | compact Act0 owner | absent | no | preserve |
| `test/guards/world1_result_whats_next_block_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy result owner | absent | no | preserve |
| `test/guards/world1_viral_proof_contract_test.dart` | assertion | ARCHIVED_NONCANONICAL | archived | absent | no | future deletion only |
| `test/guards/world2_bridge_pacing_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | campaign-pack owner | absent | no | preserve |
| `test/guards/world2_campaign_routing_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy owner | absent | no | preserve |
| `test/guards/world3_campaign_routing_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy owner | absent | no | preserve |
| `test/ui_v2/drill_runner_host_contract_alignment_test.dart` | assertion | QUARANTINED_WITH_OWNER | legacy host owner | absent | no | preserve |
| `test/ui_v2/modern_table_entry_test.dart` | assertion | ARCHIVED_NONCANONICAL | archived Modern Table | absent | no | preserve frozen boundary |
| `test/ui_v2/runner/world1_seat_quiz_feedback_copy_v1_test.dart` | compile/load | ARCHIVED_NONCANONICAL | orphaned copy source; archive-only runtime consumer | Tier B | no | retired in PHP-3C |
| `test/ui_v2/session_summary_gold_containment_v1_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | Session Summary / Sharky containment | absent | no | preserve |
| `test/ui_v2/sharky_visual_consistency_foundation_v1_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active Sharky owner | absent | no | preserve for PHP-6 |
| `test/ui_v2/theory_screen_narrow_build_test.dart` | assertion | ACTIVE_NONBLOCKING | stronger Act0 theory guards | absent | no | preserve |
| `test/ui_v2/today_plan_premium_access_text_safety_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | dormant intake owner | absent | no | preserve |
| `test/ui_v2/universal_intake_plan_personalization_contract_test.dart` | assertion | QUARANTINED_WITH_OWNER | dormant owner | absent | no | preserve |
| `test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | feedback/session-summary owner | absent | no | preserve |
| `test/ui_v2/wave4_5_motion_evidence_repair_feel_v1_test.dart` | assertion | UNRESOLVED_UNIQUE_CONTRACT | active motion owner | absent | no | preserve for PHP-5 |
| `test/guards/world1_branch_unlock_contract_test.dart` | compile/load | QUARANTINED_WITH_OWNER | shared legacy-map harness | absent | no | retired: all assertions were Progress Map-only |
| `test/guards/world1_checkpoint_locked_contract_test.dart` | compile/load | QUARANTINED_WITH_OWNER | shared legacy-map harness | absent | no | retired: all assertions were Progress Map-only |

Classification totals at the pinned audit baseline: CURRENT_CANONICAL_REQUIRED
0; CURRENT_CANONICAL_STALE_ASSERTION 0; ACTIVE_NONBLOCKING 5;
ARCHIVED_NONCANONICAL 8; QUARANTINED_WITH_OWNER 18;
UNRESOLVED_UNIQUE_CONTRACT 8. The terminal audit verdict is
`OUTSIDE_HANDOFF_AUDIT_CLOSED_CLASSIFIED`.

## PHP-3C disposition

The harness import census found eight exact direct consumers. Six are protected
members of the 74 unresolved PHP-3 carrier denominator and are intentionally
unchanged: `world1_campaign_bust_backer`, `app_root_map_first_tap_safety`,
`world1_bankroll_buyin_idempotency`, `world1_foundations_entry_from_map`,
`world1_spine_resume_continuity`, and `world1_spaced_review_plan_priority`.
Their unresolved contracts were not extracted, retired, or reclassified.

The harness now contains only current AppRoot/Today Plan/SessionResult seed and
pump helpers. Its removed Progress Map and removed World1-runner helpers are
retired legacy-only remainder; no archive runtime import or source-string
substitute was introduced. The two outside-handoff map-only guards are retired.

The seat-quiz copy test is retired as
`ARCHIVED_NONCANONICAL_TEST_RETIRED`: runtime import search found no live
non-archive consumer; the only production importer is
`lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart`.
The production copy source remains unchanged and is recorded as orphaned,
deferred code debt. Its remaining guard/tool references do not establish a
live learner route.

Outside-handoff accounting: starting classified set 39; repaired/retired 3;
still red but classified 36; current-canonical blockers 0; unclassified
outside-handoff residual 0. This accounting is separate from PHP-3's unchanged
admitted/unresolved/nine-path equation: `3 / 74 / 74`, unexplained `0`.

## Context-cost record

Budget selected / changed: standard / no. Authority files read: state, router,
supplied packet, independent audit, direct harness consumers, source owner,
Tier manifests and validator. Outcome: candidate prepared; no carrier,
production, workflow, PHP-4, visual, Motion, Sharky, native, or Human work.
