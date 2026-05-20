import 'dart:async' show Timer, unawaited;
import 'dart:convert' show jsonEncode;
import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/world1_scenario_truth_pilot_v1.dart';
import 'package:poker_analyzer/canonical/learner_action_semantics_v1.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:meta/meta.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/campaign_spine_runner_progress_store_adapter_v1.dart';
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart'
    as scenario_fsm;
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/engine_v2/cards/deterministic_deal_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';

import 'package:poker_analyzer/engine_v2/decision/decision_bar_v1.dart';
import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:poker_analyzer/services/personalization_hint_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/return_loop_service_v1.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_advancement_dispatch_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_action_token_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_board_pot_body_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_felt_caption_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_action_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_shell_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_interaction_state_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_view_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_completion_header_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_visual_cluster_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_loop_execution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_bootstrap_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_portrait_overlay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_runner_authority_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_overlay_lane_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_shell_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_marker_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_scene_compositor_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_scene_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_instruction_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_render_branch_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_teaching_flow_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_top_panel_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_status_capsule_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/shared_embedded_table_visual_family_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_surface_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_area_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_control_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_family_extras_slots_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_local_policy_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_header_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_details_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_prompt_reveal_launcher_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_route_completion_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_reveal_sheet_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_section_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_support_outcome_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_table_adjacent_frame_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_outcome_lane_semantics_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_runtime_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_runtime_feed_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_render_model_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_seat_scene_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_support_action_composer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_support_action_runtime_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_table_scene_leaf_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_table_scene_runtime_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_table_section_composer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_table_runtime_feed_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_details_surface_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_intro_prelude_adapter_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_modern_table_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/campaign_action_pot_invariants_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/table/table_surface.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/widgets/playing_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Set<String> kWorld1MicroTaskNoPackModules = <String>{};
const String kWorld1RunnerModeFoundationsCheck = 'foundations_check';
const String kWorld1RunnerModeTablePractice = 'table_practice';
const String kWorld1RunnerModeDailyRun = 'daily_run';
const String kWorld1RunnerModeCheckpoint = 'checkpoint';
const String kWorld1RunnerModeCampaignSpine = 'campaign_spine';
const String kWorld1RunnerModeReviewQueue = 'review_queue';
const String kWorld1RunnerModeDemoHandLoopV1 = 'demo_handloop_v1';
const String kWorld1LearningEffectSliceIdV1 = 'world1_recovery_loop_v1';
const String _globalTrainingIntroSeenKeyV1 = 'global_training_intro_seen_v1';
const String _world1IntroSeenKeyV1 = 'world1_intro_seen_v1';
const String _world1ActionIntroSeenKeyV1 = 'world1_action_intro_seen_v1';
const String _world1StreetFlowIntroSeenKeyV1 =
    'world1_street_flow_intro_seen_v1';
const String _world2HandoffSeenKeyV1 = 'world2_handoff_seen_v1';
const String _world2IntroSeenKeyV1 = 'world2_intro_seen_v1';
const String _cashTrackIntroSeenKeyV1 = 'cash_track_intro_seen_v1';
const String _tournamentTrackIntroSeenKeyV1 = 'tournament_track_intro_seen_v1';
const String _mixedTrackIntroSeenKeyV1 = 'mixed_track_intro_seen_v1';
const String _checkpointReviewCueTextV1 = 'Practice your toughest spots again.';
const String _goldLearningSlicePackIdV1 = 'world1_spine_campaign_v1';
const Set<int> _goldLearningClusterStepIndexesV1 = <int>{0, 1, 2};
const Set<int> _goldLearningClusterReinforceStepIndexesV1 = <int>{0};
const Set<int> _goldLearningLiteracyStepIndexesV1 = <int>{0, 1};
const String _conceptFirstSeatPackIdV1 = 'world1_act0_table_literacy';
const String _actionLiteracyPackIdV1 = 'world1_act0_action_literacy';
const String _streetFlowPackIdV1 = 'world1_act0_street_flow';
const Set<int> _conceptFirstSeatClusterStepIndexesV1 = <int>{0, 1, 2};
const Set<int> _actionLiteracyClusterStepIndexesV1 = <int>{0, 1, 2};
const Set<int> _streetFlowClusterStepIndexesV1 = <int>{0, 1, 2};

String _world1OutcomeVerdictLineV1(bool isCorrect) {
  return isCorrect ? 'Nice choice.' : 'Try this one instead.';
}

const String kAct0SeatQuizFallbackGuidanceTitleV1 =
    'Seat drill: identify the highlighted position.';

class World1EarlyPackMomentumPreludeCopyV1 {
  const World1EarlyPackMomentumPreludeCopyV1({
    required this.setupLine,
    required this.supportLine,
  });

  final String setupLine;
  final String supportLine;
}

@visibleForTesting
World1EarlyPackMomentumPreludeCopyV1?
resolveWorld1EarlyPackMomentumPreludeCopyV1(String moduleId) {
  return switch (moduleId.trim().toLowerCase()) {
    _actionLiteracyPackIdV1 => const World1EarlyPackMomentumPreludeCopyV1(
      setupLine:
          'Next: use the seat map you just learned to choose the first action.',
      supportLine:
          'Why it matters: once Button and the blinds are clear, action order stops feeling random. Notice: start from Button, then move one seat clockwise to the next actor.',
    ),
    _streetFlowPackIdV1 => const World1EarlyPackMomentumPreludeCopyV1(
      setupLine: 'Next: keep the same seat order while the street changes.',
      supportLine:
          'Why it matters: once you know who acts next, flop, turn, and river are easier to follow. Notice: keep the same seat order, then read the new street.',
    ),
    _ => null,
  };
}

class World1FirstPackTransitionPacingContractV1 {
  const World1FirstPackTransitionPacingContractV1({
    required this.usesBlockingIntroOverlay,
    this.embeddedPreludeCardKey,
  });

  final bool usesBlockingIntroOverlay;
  final String? embeddedPreludeCardKey;
}

enum World1EmbeddedTableRouteV1 { sharedEmbedded, localLegacy }

@visibleForTesting
World1EmbeddedTableRouteV1 resolveWorld1EmbeddedTableRouteV1({
  required bool handLoopVisualMode,
  required bool seatQuizVisualMode,
  required bool isCampaignSpineSession,
  required bool isReviewQueueSession,
  required bool isTablePracticeSession,
  required bool isDailyRunSession,
  required bool showSeatQuizPrelude,
  required bool showIntroSequence,
  required bool showLegacyOverlaySurface,
  required bool showConceptPreludeCard,
  required bool showActionLiteracyPreludeCard,
  required bool showStreetFlowPreludeCard,
}) {
  if (handLoopVisualMode) {
    return World1EmbeddedTableRouteV1.sharedEmbedded;
  }
  if (!seatQuizVisualMode) {
    return World1EmbeddedTableRouteV1.localLegacy;
  }
  final usesLegacyInstructionSurface =
      showSeatQuizPrelude ||
      showIntroSequence ||
      showLegacyOverlaySurface ||
      showConceptPreludeCard ||
      showActionLiteracyPreludeCard ||
      showStreetFlowPreludeCard;
  if (usesLegacyInstructionSurface) {
    return World1EmbeddedTableRouteV1.localLegacy;
  }
  final usesCompatibleLearnerFacingMode =
      isCampaignSpineSession ||
      isReviewQueueSession ||
      isTablePracticeSession ||
      isDailyRunSession;
  return usesCompatibleLearnerFacingMode
      ? World1EmbeddedTableRouteV1.sharedEmbedded
      : World1EmbeddedTableRouteV1.localLegacy;
}

@visibleForTesting
World1FirstPackTransitionPacingContractV1?
resolveWorld1FirstPackTransitionPacingContractV1(String moduleId) {
  return switch (moduleId.trim().toLowerCase()) {
    _conceptFirstSeatPackIdV1 =>
      const World1FirstPackTransitionPacingContractV1(
        usesBlockingIntroOverlay: true,
        embeddedPreludeCardKey: 'concept_first_seat_prelude_card_v1',
      ),
    _actionLiteracyPackIdV1 => const World1FirstPackTransitionPacingContractV1(
      usesBlockingIntroOverlay: false,
      embeddedPreludeCardKey: 'action_literacy_prelude_card_v1',
    ),
    _streetFlowPackIdV1 => const World1FirstPackTransitionPacingContractV1(
      usesBlockingIntroOverlay: false,
      embeddedPreludeCardKey: 'street_flow_prelude_card_v1',
    ),
    _ => null,
  };
}

@visibleForTesting
String resolveConceptFirstSeatSetupLineV1(String? expectedSeatId) {
  switch (expectedSeatId) {
    case 'btn':
      return 'Sharky Poker starts here: Button marks the dealer seat.';
    case 'sb':
      return 'Concept: Small Blind is the first blind after Button.';
    case 'bb':
      return 'Concept: Big Blind is the second blind seat.';
    default:
      return 'Sharky Poker starts at the dealer seat.';
  }
}

const Set<String> _world1SpineParityPackIdsV1 = <String>{
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
};

String world1LearningEffectSliceMarkerV1({
  required String moduleId,
  required String mode,
}) {
  if (moduleId.startsWith('world1_') ||
      kWorld1CanonicalModuleOrder.contains(moduleId) ||
      mode == kWorld1RunnerModeFoundationsCheck ||
      mode == kWorld1RunnerModeTablePractice ||
      mode == kWorld1RunnerModeDailyRun ||
      mode == kWorld1RunnerModeCampaignSpine ||
      mode == kWorld1RunnerModeReviewQueue) {
    return kWorld1LearningEffectSliceIdV1;
  }
  return 'outside_world1_slice_v1';
}

@visibleForTesting
class World1TelemetrySampleV1 {
  const World1TelemetrySampleV1({required this.name, required this.payload});

  final String name;
  final Map<String, Object?> payload;
}

@visibleForTesting
Map<String, Object> computeWorld1LearningEffectSummaryV1({
  required String moduleId,
  required String mode,
  required List<World1TelemetrySampleV1> events,
}) {
  final inSliceEvents = events
      .where((sample) {
        final eventModuleId = (sample.payload['module_id'] ?? '').toString();
        final eventMode = (sample.payload['mode'] ?? '').toString();
        return eventModuleId == moduleId && eventMode == mode;
      })
      .toList(growable: false);

  int totalDecisions = 0;
  int correctDecisions = 0;
  final errorDist = <String, int>{};
  final correctSteps = <Object?>{};
  final timeByStep = <Object?, int>{};

  for (final event in inSliceEvents) {
    if (event.name == 'correct') {
      totalDecisions += 1;
      final isCorrect = event.payload['correct'] == true;
      if (isCorrect) {
        correctDecisions += 1;
        correctSteps.add(event.payload['step_index']);
      } else {
        final errorType = (event.payload['error_type'] ?? 'unknown')
            .toString()
            .trim()
            .toLowerCase();
        final normalizedError = errorType.isEmpty ? 'unknown' : errorType;
        if (normalizedError != 'none') {
          errorDist.update(normalizedError, (v) => v + 1, ifAbsent: () => 1);
        }
      }
    } else if (event.name == 'time_to_decision') {
      final raw = event.payload['time_to_decision_ms'];
      final decisionMs = switch (raw) {
        int value => value,
        String value => int.tryParse(value),
        _ => null,
      };
      if (decisionMs != null) {
        timeByStep[event.payload['step_index']] = decisionMs;
      }
    }
  }

  int correctDecisionTimeSamples = 0;
  int correctDecisionTimeTotalMs = 0;
  for (final step in correctSteps) {
    final decisionMs = timeByStep[step];
    if (decisionMs == null) continue;
    correctDecisionTimeSamples += 1;
    correctDecisionTimeTotalMs += decisionMs;
  }
  final avgDecisionMs = correctDecisionTimeSamples == 0
      ? null
      : (correctDecisionTimeTotalMs / correctDecisionTimeSamples).round();

  final errorKeys = errorDist.keys.toList(growable: false)..sort();
  final sortedErrorDist = <String, int>{
    for (final key in errorKeys) key: errorDist[key]!,
  };
  final accuracy = totalDecisions == 0
      ? 0
      : ((correctDecisions * 100) / totalDecisions).round();

  return <String, Object>{
    'slice_marker': world1LearningEffectSliceMarkerV1(
      moduleId: moduleId,
      mode: mode,
    ),
    'module_id': moduleId,
    'mode': mode,
    'total_decisions': totalDecisions,
    'correct_decisions': correctDecisions,
    'accuracy_percent': accuracy,
    'error_type_distribution': sortedErrorDist,
    'correct_time_to_decision_avg_ms': avgDecisionMs ?? -1,
    'correct_time_to_decision_samples': correctDecisionTimeSamples,
  };
}

enum RunnerDebugBootstrapStateV1 {
  outcomeIncorrectRange,
  demoDecisionHeroSb,
  demoDecisionHeroBb,
}

@visibleForTesting
String world1SpineOutcomeWhyLineV2({
  required int toCall,
  required ActionKindV1? selectedActionKind,
  required String errorType,
  required MicroTaskStreetV1? street,
  List<String>? allowedActions,
}) {
  final isPreflop = street == null;
  final canonicalSelectedActionKind = selectedActionKind == null
      ? null
      : canonicalizeLearnerActionKindV1(
          kind: selectedActionKind,
          isPreflop: isPreflop,
          toCall: toCall,
        );
  final normalizedAllowed = (allowedActions ?? const <String>[])
      .map(
        (value) => canonicalizeLearnerActionTokenV1(
          token: value,
          isPreflop: isPreflop,
          toCall: toCall,
        ),
      )
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final raiseAvailable = normalizedAllowed.any(
    (value) => value.contains('raise'),
  );
  final raiseToAvailable = normalizedAllowed.contains('raise_to');
  final betAvailable = normalizedAllowed.contains('bet');
  final checkAvailable = normalizedAllowed.contains('check');
  final normalizedErrorType = errorType.trim().toLowerCase();

  // v3: for range misses, prefer factual spot-specific guidance first.
  if (normalizedErrorType == 'range') {
    if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.fold) {
      return 'Why: Folding gives up your equity share.';
    }
    if (toCall > 0 &&
        canonicalSelectedActionKind == ActionKindV1.call &&
        raiseToAvailable) {
      return 'Why: This spot rewards aggression more than calling.';
    }
    if (toCall == 0 &&
        canonicalSelectedActionKind == ActionKindV1.check &&
        betAvailable) {
      return 'Why: Betting is the higher-EV play here.';
    }
    if (toCall == 0 &&
        canonicalSelectedActionKind == ActionKindV1.bet &&
        checkAvailable) {
      return 'Why: Checking misses value/protection here.';
    }
  }

  if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.bet) {
    return 'Why: There is a bet to call. You must call, fold, or raise.';
  }
  if (toCall == 0 && canonicalSelectedActionKind == ActionKindV1.fold) {
    return 'Why: Folding for free gives up equity.';
  }
  if (toCall == 0 && canonicalSelectedActionKind == ActionKindV1.call) {
    return 'Why: Nothing to call. Check is free.';
  }
  if (toCall == 0 && canonicalSelectedActionKind == ActionKindV1.raise) {
    if (isPreflop) {
      return 'Why: Preflop with nothing to call still uses check or raise.';
    }
    return 'Why: There is nothing to call. Bet is the first action.';
  }
  if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.check) {
    return 'Why: You must call, fold, or raise.';
  }
  if (toCall > 0 &&
      canonicalSelectedActionKind == ActionKindV1.raise &&
      !raiseAvailable) {
    return 'Why: This raise is not available in this spot.';
  }
  if (normalizedErrorType == 'range' &&
      canonicalSelectedActionKind == ActionKindV1.fold &&
      toCall == 0) {
    return 'Why: Folding for free gives up equity.';
  }
  return 'Why: The stronger line keeps more value or pressure in this spot.';
}

@visibleForTesting
String world1SpineOutcomeCorrectLineV1({
  required int toCall,
  required ActionKindV1? selectedActionKind,
  required MicroTaskStreetV1? street,
  List<String>? allowedActions,
}) {
  final isPreflop = street == null;
  final canonicalSelectedActionKind = selectedActionKind == null
      ? null
      : canonicalizeLearnerActionKindV1(
          kind: selectedActionKind,
          isPreflop: isPreflop,
          toCall: toCall,
        );
  if (toCall == 0 && canonicalSelectedActionKind == ActionKindV1.check) {
    return 'Correct: Check is free.';
  }
  if (toCall == 0 && canonicalSelectedActionKind == ActionKindV1.bet) {
    return 'Correct: Bet starts the action.';
  }
  if (toCall == 0 &&
      isPreflop &&
      canonicalSelectedActionKind == ActionKindV1.raise) {
    return 'Correct: Raise is the price-setting action preflop.';
  }
  if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.call) {
    return 'Correct: Call matches the bet.';
  }
  if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.fold) {
    return 'Correct: Fold ends the hand.';
  }
  if (toCall > 0 && canonicalSelectedActionKind == ActionKindV1.raise) {
    final raiseLabel = world1SpinePreferredRaiseLabelV1(allowedActions);
    if (raiseLabel == 'RAISE MIN') {
      return 'Correct: RAISE MIN applies pressure.';
    }
    if (raiseLabel == 'RAISE TO') {
      return 'Correct: RAISE TO applies pressure.';
    }
    return 'Correct: Raise increases the bet.';
  }
  return 'Correct: Spot resolved.';
}

@visibleForTesting
ActionKindV1? world1SpineExplicitExpectedActionKindV1(MicroTaskStep step) {
  final explicit = step.expectedActionKind?.trim().toLowerCase().replaceAll(
    '-',
    '_',
  );
  if (explicit == null || explicit.isEmpty) {
    return null;
  }
  switch (explicit) {
    case 'fold':
      return ActionKindV1.fold;
    case 'check':
      return ActionKindV1.check;
    case 'call':
      return ActionKindV1.call;
    case 'bet':
      return ActionKindV1.bet;
    case 'raise':
    case 'raise_to':
    case 'raise_min':
      return ActionKindV1.raise;
  }
  return null;
}

@visibleForTesting
ActionKindV1? world1SpineExpectedActionKindV1(MicroTaskStep step) {
  return world1ScenarioTruthExpectedActionKindV1(step);
}

@visibleForTesting
ActionKindV1? world1SpineMismatchExpectedActionKindV1({
  required MicroTaskStep step,
  required bool useSpineExplicitExpectedAction,
  required ActionV1? firstHeroActionOverride,
  required List<ActionV1> heroActions,
}) {
  if (useSpineExplicitExpectedAction) {
    return world1SpineExpectedActionKindV1(step);
  }
  if (firstHeroActionOverride == null && heroActions.isNotEmpty) {
    return heroActions.first.kind;
  }
  return null;
}

@visibleForTesting
String world1SpinePreferredRaiseLabelV1(List<String>? allowedActions) {
  final actions = (allowedActions ?? const <String>[])
      .map((value) => value.trim().toLowerCase().replaceAll('-', '_'))
      .where((value) => value.isNotEmpty)
      .toSet();
  final hasRaiseMin = actions.contains('raise_min');
  final hasRaiseTo = actions.contains('raise_to');
  final hasRaise = actions.contains('raise');
  if (hasRaiseMin && !hasRaiseTo && !hasRaise) {
    return 'RAISE MIN';
  }
  if (hasRaiseTo) {
    return 'RAISE TO';
  }
  if (hasRaise) {
    return 'RAISE';
  }
  return 'RAISE';
}

@visibleForTesting
String? world1SpineOutcomeExpectedLineV1(MicroTaskStep step) {
  return world1ScenarioTruthExpectedLineV1(step);
}

@visibleForTesting
bool world1SpineIsExpectedActionV1({
  required MicroTaskStep step,
  required ActionKindV1 selectedActionKind,
}) {
  final expected = world1SpineExpectedActionKindV1(step);
  if (expected == null) {
    return false;
  }
  final toCall = step.toCall ?? 0;
  final isPreflop = step.street == null;
  final canonicalSelected = canonicalizeLearnerActionKindV1(
    kind: selectedActionKind,
    isPreflop: isPreflop,
    toCall: toCall,
  );
  return expected == canonicalSelected;
}

class RunnerInstructionContentV1 {
  const RunnerInstructionContentV1({required this.title, this.subtitle = ''});

  final String title;
  final String subtitle;
}

abstract class RunnerInstructionSourceV1 {
  const RunnerInstructionSourceV1();

  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  });

  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  });

  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  });
}

final Map<String, World1MicroTaskPack> kWorld1MicroTaskPacks = kCampaignPacksV1;

@visibleForTesting
int applyWorld1FairnessShieldDeltaV1({
  required String packId,
  required bool isCorrect,
  required int rawDelta,
}) {
  if (packId == 'world1_spine_campaign_v1' && isCorrect && rawDelta < 0) {
    return 0;
  }
  return rawDelta;
}

const Map<int, List<MicroTaskStep>> kWorld1CheckpointTaskPacks =
    <int, List<MicroTaskStep>>{
      3: <MicroTaskStep>[
        MicroTaskStep(
          prompt: 'Tap Button.',
          hint: 'Button is the bottom center seat.',
          expectedSeatIds: <String>['btn'],
        ),
        MicroTaskStep(
          prompt: 'Tap Big Blind.',
          hint: 'Big Blind is the right-lower blind seat.',
          expectedSeatIds: <String>['bb'],
        ),
        MicroTaskStep(
          prompt: 'Move past the empty spots and tap Hijack.',
          hint: 'Ignore empty seats and continue to Hijack.',
          expectedSeatIds: <String>['hj'],
        ),
      ],
      6: <MicroTaskStep>[
        MicroTaskStep(
          prompt: 'Tap Cutoff.',
          hint: 'Cutoff is upper-left at this table.',
          expectedSeatIds: <String>['co'],
        ),
        MicroTaskStep(
          prompt: 'Tap Button.',
          hint: 'Button is the dealer seat at bottom center.',
          expectedSeatIds: <String>['btn'],
        ),
        MicroTaskStep(
          prompt: 'Tap Small Blind.',
          hint: 'Small Blind is left of Button.',
          expectedSeatIds: <String>['sb'],
        ),
      ],
    };

bool hasWorld1MicroTaskPack(String moduleId) {
  final override = debugHasWorld1MicroTaskPackOverride;
  if (override != null) {
    return override(moduleId);
  }
  return kWorld1MicroTaskPacks.containsKey(moduleId);
}

bool usesWorld1TablePracticeV1(String moduleId) {
  if (!kWorld1CanonicalModuleOrder.contains(moduleId)) {
    return false;
  }
  return hasWorld1MicroTaskPack(moduleId);
}

@visibleForTesting
bool Function(String moduleId)? debugHasWorld1MicroTaskPackOverride;

bool hasWorld1FoundationsCheck(String moduleId) {
  if (!kWorld1CanonicalModuleOrder.contains(moduleId)) {
    return false;
  }
  if (kWorld1MicroTaskPacks.containsKey(moduleId)) {
    return true;
  }
  return kWorld1MicroTaskNoPackModules.contains(moduleId);
}

List<MicroTaskStep> world1MicroTaskPackFor(String moduleId) {
  return kWorld1MicroTaskPacks[moduleId] ?? const <MicroTaskStep>[];
}

bool _markerCircleIntersectsRectV1(Offset center, double radius, Rect rect) {
  final nearestX = center.dx.clamp(rect.left, rect.right).toDouble();
  final nearestY = center.dy.clamp(rect.top, rect.bottom).toDouble();
  final dx = center.dx - nearestX;
  final dy = center.dy - nearestY;
  return (dx * dx + dy * dy) <= (radius * radius);
}

double _rectOverlapAreaV1(Rect a, Rect b) {
  if (!a.overlaps(b)) {
    return 0;
  }
  final intersection = Rect.fromLTRB(
    math.max(a.left, b.left),
    math.max(a.top, b.top),
    math.min(a.right, b.right),
    math.min(a.bottom, b.bottom),
  );
  return intersection.width * intersection.height;
}

Offset _resolveMarkerCenterNoOverlapV1({
  required Offset seatCenter,
  required Offset tableCenter,
  required double seatVisualRadiusPx,
  required double markerRadiusPx,
  required Rect stadiumSafeRect,
  required List<Rect> avoidRects,
}) {
  const gapPx = 5.0;
  final towardCenterFactor = _TableStadiumSpecV1.markerTowardCenterFactor;
  final minDistance = seatVisualRadiusPx + markerRadiusPx + gapPx;
  final toward = tableCenter - seatCenter;
  final towardMagnitude = toward.distance;
  final direction = towardMagnitude <= 0.001
      ? const Offset(0, -1)
      : toward / towardMagnitude;
  final safeRectInset = markerRadiusPx + 1.0;
  final insetSafeRect = stadiumSafeRect.deflate(safeRectInset);
  final effectiveSafeRect = insetSafeRect.width > 0 && insetSafeRect.height > 0
      ? insetSafeRect
      : stadiumSafeRect;

  Offset clampToSafeRect(Offset point) {
    if (effectiveSafeRect.width <= 0 || effectiveSafeRect.height <= 0) {
      return tableCenter;
    }
    final minX = math.min(effectiveSafeRect.left, effectiveSafeRect.right);
    final maxX = math.max(effectiveSafeRect.left, effectiveSafeRect.right);
    final minY = math.min(effectiveSafeRect.top, effectiveSafeRect.bottom);
    final maxY = math.max(effectiveSafeRect.top, effectiveSafeRect.bottom);
    return Offset(
      point.dx.clamp(minX, maxX).toDouble(),
      point.dy.clamp(minY, maxY).toDouble(),
    );
  }

  bool overlapsSeat(Offset center) {
    return (center - seatCenter).distance < minDistance;
  }

  bool overlapsAvoidRects(Offset center) {
    for (final rect in avoidRects) {
      if (_markerCircleIntersectsRectV1(center, markerRadiusPx + 1.0, rect)) {
        return true;
      }
    }
    return false;
  }

  final projectedDistance = towardMagnitude <= 0.001
      ? minDistance
      : math.max(towardMagnitude * towardCenterFactor, minDistance);
  var candidate = clampToSafeRect(seatCenter + (direction * projectedDistance));
  if (overlapsSeat(candidate)) {
    candidate = clampToSafeRect(seatCenter + (direction * minDistance));
  }
  if (!overlapsSeat(candidate) && !overlapsAvoidRects(candidate)) {
    return candidate;
  }

  final tangent = Offset(-direction.dy, direction.dx);
  final shiftPx = markerRadiusPx + 6.0;
  for (final sign in <double>[1, -1, 1.5, -1.5, 2, -2]) {
    final shifted = clampToSafeRect(candidate + (tangent * shiftPx * sign));
    if (!overlapsSeat(shifted) && !overlapsAvoidRects(shifted)) {
      return shifted;
    }
  }

  final outwardCandidate = clampToSafeRect(
    seatCenter + (direction * (minDistance + markerRadiusPx + 6.0)),
  );
  if (!overlapsSeat(outwardCandidate) &&
      !overlapsAvoidRects(outwardCandidate)) {
    return outwardCandidate;
  }
  final fallback = clampToSafeRect(seatCenter + (direction * minDistance));
  if (!overlapsSeat(fallback) && !overlapsAvoidRects(fallback)) {
    return fallback;
  }
  return candidate;
}

class World1FoundationsMicroTaskRunnerScreen extends StatefulWidget {
  const World1FoundationsMicroTaskRunnerScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    this.hostShellControllerV1,
    this.resolvedHostLaunchV1,
    this.startHandIndex,
    this.isDailyRun = false,
    this.isCheckpoint = false,
    this.checkpointId,
    this.isTablePracticeV1 = false,
    this.mode,
    this.debugSeatLayoutMaxPlayersV1,
    this.instructionSourceV1,
    this.hintsEnabledV1 = true,
    this.debugBootstrapStateV1,
    this.debugHandLoopFeltCaptionOverrideV1,
    this.debugForceHandLoopSurfaceV1,
  });

  final String moduleId;
  final String moduleTitle;
  final World1CanonicalHostShellControllerV1? hostShellControllerV1;
  final World1CanonicalResolvedHostLaunchV1? resolvedHostLaunchV1;
  final int? startHandIndex;
  final bool isDailyRun;
  final bool isCheckpoint;
  final int? checkpointId;
  final bool isTablePracticeV1;
  final String? mode;
  final int? debugSeatLayoutMaxPlayersV1;
  final RunnerInstructionSourceV1? instructionSourceV1;
  final bool hintsEnabledV1;
  final RunnerDebugBootstrapStateV1? debugBootstrapStateV1;
  // Test-only seam to inject a deterministic hand-loop felt caption.
  final String? debugHandLoopFeltCaptionOverrideV1;
  // Test-only seam to force hand-loop geometry surface in review mode.
  final bool? debugForceHandLoopSurfaceV1;

  @override
  State<World1FoundationsMicroTaskRunnerScreen> createState() =>
      _World1FoundationsMicroTaskRunnerScreenState();
}

class _GuidedSeatStepV1 {
  const _GuidedSeatStepV1({
    this.seatId,
    required this.prompt,
    this.subtitle,
    this.requiresSeatTap = true,
  });

  final String? seatId;
  final String prompt;
  final String? subtitle;
  final bool requiresSeatTap;
}

class _CoachStepV1 {
  const _CoachStepV1({
    required this.title,
    this.subtitle,
    this.highlightSeatId,
  });

  final String title;
  final String? subtitle;
  final String? highlightSeatId;
}

int? _seatLayoutMaxPlayersForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (normalized.contains('10max')) return 10;
  if (normalized.contains('tournament') || normalized.contains('mtt')) {
    return 9;
  }
  if (normalized.contains('cash')) return 9;
  return null;
}

@visibleForTesting
int? debugSeatLayoutRuleForPackIdV1(String packId) =>
    _seatLayoutMaxPlayersForPackIdV1(packId);

@visibleForTesting
bool debugDisableRunnerMicroAnimationsV1 = false;

@visibleForTesting
bool debugDisableRunnerSessionStartEmotionHooksV1 = false;

class _World1FoundationsMicroTaskRunnerScreenState
    extends State<World1FoundationsMicroTaskRunnerScreen> {
  static bool _firstSessionSeenInLaunchV1 = false;
  static const List<StreetV1> _streetTimelineOrder = <StreetV1>[
    StreetV1.preflop,
    StreetV1.flop,
    StreetV1.turn,
    StreetV1.river,
  ];
  static const List<String> _streetTimelineLabels = <String>[
    'PREFLOP',
    'FLOP',
    'TURN',
    'RIVER',
  ];

  VoidCallback? _settingsListener;
  int _appliedHostShellSignalGenerationV1 = -1;

  static const List<_SeatMeta> _seats = <_SeatMeta>[
    // Canonical clockwise 6-max ring from Button:
    // BTN -> SB -> BB -> UTG -> HJ -> CO
    _SeatMeta('btn', 'Button', Alignment(0, 0.88), true),
    _SeatMeta('sb', 'Small Blind', Alignment(-0.56, 0.74), true),
    _SeatMeta('bb', 'Big Blind', Alignment(-0.88, 0.34), true),
    _SeatMeta('utg', 'UTG', Alignment(-0.76, -0.2), true),
    _SeatMeta('hj', 'Hijack', Alignment(0, -0.88), true),
    _SeatMeta('co', 'Cutoff', Alignment(0.76, -0.2), true),
  ];
  static const List<_SeatMeta> _seats9MaxV1 = <_SeatMeta>[
    _SeatMeta('btn', 'Button', Alignment(0, 0.88), true),
    _SeatMeta('sb', 'Small Blind', Alignment(-0.36, 0.84), true),
    _SeatMeta('bb', 'Big Blind', Alignment(-0.68, 0.66), true),
    _SeatMeta('utg', 'UTG', Alignment(-0.90, 0.34), true),
    _SeatMeta('utg1', 'UTG+1', Alignment(-0.94, 0.00), true),
    _SeatMeta('mp', 'MP', Alignment(-0.72, -0.38), true),
    _SeatMeta('hj', 'Hijack', Alignment(0, -0.90), true),
    _SeatMeta('co', 'Cutoff', Alignment(0.72, -0.38), true),
    _SeatMeta('lj', 'Lojack', Alignment(0.94, 0.00), true),
  ];
  static const List<_SeatMeta> _seats10MaxV1 = <_SeatMeta>[
    _SeatMeta('btn', 'Button', Alignment(0, 0.90), true),
    _SeatMeta('sb', 'Small Blind', Alignment(-0.30, 0.86), true),
    _SeatMeta('bb', 'Big Blind', Alignment(-0.58, 0.74), true),
    _SeatMeta('utg', 'UTG', Alignment(-0.82, 0.52), true),
    _SeatMeta('utg1', 'UTG+1', Alignment(-0.96, 0.18), true),
    _SeatMeta('mp', 'MP', Alignment(-0.90, -0.20), true),
    _SeatMeta('mp1', 'MP+1', Alignment(-0.58, -0.66), true),
    _SeatMeta('hj', 'Hijack', Alignment(0, -0.92), true),
    _SeatMeta('co', 'Cutoff', Alignment(0.58, -0.66), true),
    _SeatMeta('lj', 'Lojack', Alignment(0.90, -0.20), true),
  ];

  static List<_SeatMeta> _seatsForMaxPlayersV1(int maxPlayers) {
    if (maxPlayers <= 0) return _seats;

    final seatCount = math.max(6, math.min(10, maxPlayers));
    final slotIds = canonicalTableSlotIdsForSeatCountV1(
      seatCount,
      heroSeatIndex: kCanonicalTableHeroTopologySlotIdV1,
    );

    // Provide a normalized list of string ids for this seat count
    // Based on the canonical full ring order, derived topologies extract from standard positions.
    final canonicalIds = _generateCanonicalStringIdsV1(seatCount);

    return canonicalIds
        .map((id) {
          String label = describeWorld1CanonicalSeatForLearnerV1(id);
          if (id == 'mp')
            label =
                'MP'; // Override canonical 'Middle Position' to prevent line-wrap overflow
          return _SeatMeta(id, label, Alignment.center, true);
        })
        .toList(growable: false);
  }

  static List<String> _generateCanonicalStringIdsV1(int seatCount) {
    switch (seatCount) {
      case 9:
        return const ['btn', 'sb', 'bb', 'utg', 'utg1', 'mp', 'hj', 'co', 'lj'];
      case 10:
        return const [
          'btn',
          'sb',
          'bb',
          'utg',
          'utg1',
          'mp',
          'mp1',
          'hj',
          'co',
          'lj',
        ];
      case 6:
      default:
        // Default MUST be a 6-max layout for ANY unknown size (including heads up) to match old fallback semantics.
        return const ['btn', 'sb', 'bb', 'utg', 'hj', 'co'];
    }
  }

  static const Map<int, _GuidedSeatStepV1>
  kGuidedSeatStepsV1 = <int, _GuidedSeatStepV1>{
    0: _GuidedSeatStepV1(
      seatId: 'btn',
      prompt: 'This is the Button (Dealer). Tap it.',
      subtitle: 'Seat labels continue clockwise from the Button.',
    ),
    1: _GuidedSeatStepV1(
      seatId: 'sb',
      prompt: 'This is the Small Blind. Tap it.',
    ),
    2: _GuidedSeatStepV1(
      seatId: 'bb',
      prompt: 'This is the Big Blind. Tap it.',
    ),
    3: _GuidedSeatStepV1(seatId: 'co', prompt: 'This is the Cutoff. Tap it.'),
    4: _GuidedSeatStepV1(seatId: 'hj', prompt: 'This is the Hijack. Tap it.'),
    5: _GuidedSeatStepV1(
      seatId: 'utg',
      prompt: 'This is Under the Gun. Tap it.',
    ),
  };
  static const List<_GuidedSeatStepV1> _introSequenceStepsV1 =
      <_GuidedSeatStepV1>[
        _GuidedSeatStepV1(
          prompt: 'Seat labels continue clockwise from Button.',
          subtitle:
              'You will choose positions next. This only shows the order.',
          requiresSeatTap: false,
        ),
      ];
  static const List<_GuidedSeatStepV1> _introSequenceStepsWorld2V1 =
      <_GuidedSeatStepV1>[
        _GuidedSeatStepV1(
          seatId: 'btn',
          prompt: 'Start from Button, then compare late seats and blinds.',
          subtitle: 'Seat order only. Not action order.',
          requiresSeatTap: false,
        ),
        _GuidedSeatStepV1(
          seatId: 'co',
          prompt: 'Cutoff is the seat before Button in seat order.',
          subtitle: 'Late seats and blinds are different seat labels.',
          requiresSeatTap: false,
        ),
      ];
  static const List<_GuidedSeatStepV1> _introSequenceStepsWorld3V1 =
      <_GuidedSeatStepV1>[
        _GuidedSeatStepV1(
          seatId: 'btn',
          prompt: 'Seat label first, then price to call.',
          subtitle: 'Seat order labels do not change pot-price math.',
          requiresSeatTap: false,
        ),
        _GuidedSeatStepV1(
          seatId: 'bb',
          prompt: 'Compare call cost to total pot before acting.',
          subtitle: 'Good price can continue more. Bad price folds more.',
          requiresSeatTap: false,
        ),
      ];

  late List<MicroTaskStep> _steps;
  late final String _mode;
  int _stepIndex = 0;
  String? _selectedSeatId;
  bool _showHint = false;
  bool get _tierHintsEnabledV1 => widget.hintsEnabledV1;
  bool get _showHintBubbleV1 => _showHint && _tierHintsEnabledV1;
  String? _feedback;
  bool _pulseSuccess = false;
  bool _pulseFailure = false;
  bool _pulseBust = false;
  double _failureShakeDx = 0;
  String? _loopRewardBanner;
  String? _successBadgeText;
  bool _showDailyCompletedBadge = false;
  bool _dailyCompletedInSession = false;
  bool _showCheckpointCompleteBadge = false;
  bool _completionInProgress = false;
  bool _sessionTerminalEventSent = false;
  String _beforeSessionPhraseTextV1 = '';
  String _afterOutcomePhraseTextV1 = '';
  bool _reviewQueueCreatedTelemetrySentV1 = false;
  bool _reviewQueueStartedTelemetrySentV1 = false;
  bool _reviewQueueCompletedTelemetrySentV1 = false;
  bool _debugBootstrapAppliedV1 = false;
  List<String> _checkpointSeedTopErrorClassesV1 = const <String>[];
  List<String> _checkpointStepErrorClassesV1 = const <String>[];
  late final String _learningEffectSliceMarkerV1;
  int _reviewQueueLaunchCountV1 = 0;
  int _spineCorrectCount = 0;
  int _spineMistakesCount = 0;
  int _spineBankroll = ProgressService.bankrollCap;
  int _spineDelta = 0;
  bool _spineContractSyntheticNegativeIssuedV1 = false;
  bool _spineContractSyntheticNegativePendingCheckV1 = false;
  int _spineSessionDelta = 0;
  int _spineRank = ProgressService.spineRankFish;
  int _spineCalibrationBand = ProgressService.spineCalibrationBandIntermediate;
  bool _spineBustEventSent = false;
  late final DateTime _sessionStartedAt;
  late DateTime _decisionStartedAt;
  int? _debugDecisionTapUsV1;
  int? _debugStateAppliedUsV1;
  int? _debugEngineStartUsV1;
  int? _debugEngineDoneUsV1;
  int? _debugPostEngineDoneUsV1;
  int? _debugBeforeShowOutcomeUsV1;
  int? _debugAfterShowOutcomeCallUsV1;
  int? _debugShowOutcomeEntryUsV1;
  int? _debugShowOutcomeBeforeSetStateUsV1;
  int? _debugShowOutcomeAfterSetStateUsV1;
  int? _debugOutcomeSetStateUsV1;
  int? _debugOutcomeFirstFrameUsV1;
  int? _debugPreShowTelemetryUsV1;
  int? _debugPreShowFeedbackFxUsV1;
  int? _debugPreShowProgressionUsV1;
  int? _debugPreShowFeedbackSetStateUsV1;
  int? _debugPreShowSeatQuizPrepUsV1;
  int? _debugHole1T0UsV1;
  int? _debugHole1T1UsV1;
  int? _debugHole2T0UsV1;
  int? _debugHole2T1UsV1;
  int? _debugHole3T0UsV1;
  int? _debugHole3T1UsV1;
  String _debugHole1LabelV1 = 'n/a';
  String _debugHole2LabelV1 = 'n/a';
  String _debugHole3LabelV1 = 'n/a';
  Timer? _successPulseTimer;
  Timer? _failurePulseTimer;
  Timer? _failureShakeTimer;
  Timer? _bustPulseTimer;
  Timer? _successBadgeTimer;
  Timer? _dailyCompletedBadgeTimer;
  Timer? _checkpointCompleteTimer;
  Timer? _loopRewardBannerTimer;
  Timer? _completionNavigateTimer;
  Timer? _resultAutoContinueTimer;
  Timer? _globalTrainingIntroPreludeTimerV1;
  Timer? _globalTrainingIntroPreludeMinVisibleTimerV1;
  Timer? _world1IntroPreludeTimerV1;
  Timer? _world1IntroPreludeMinVisibleTimerV1;
  Timer? _world1ActionIntroPreludeTimerV1;
  Timer? _world1ActionIntroPreludeMinVisibleTimerV1;
  Timer? _world1StreetFlowIntroPreludeTimerV1;
  Timer? _world1StreetFlowIntroPreludeMinVisibleTimerV1;
  Timer? _world2HandoffPreludeTimerV1;
  Timer? _world2HandoffPreludeMinVisibleTimerV1;
  Timer? _world2IntroPreludeTimerV1;
  Timer? _world2IntroPreludeMinVisibleTimerV1;
  Timer? _trackIntroPreludeTimerV1;
  Timer? _trackIntroPreludeMinVisibleTimerV1;
  Timer? _engineV2StreetReplayTimer;
  Timer? _engineV2PotPulseTimer;
  final Map<int, int> _wrongAttemptsByStep = <int, int>{};
  final Set<int> _guidedConsumedSteps = <int>{};
  late final bool _isFirstSessionInLaunch = !_firstSessionSeenInLaunchV1;
  bool _outcomeSurfaceVisible = false;
  bool _outcomeLastResultCorrect = false;
  bool _seatQuizAutoAdvancePendingV1 = false;
  bool _globalTrainingIntroPreludePendingV1 = false;
  bool _showGlobalTrainingIntroPreludeV1 = false;
  DateTime? _globalTrainingIntroPreludeShownAtV1;
  bool _world1IntroPreludePendingV1 = false;
  bool _showWorld1IntroPreludeV1 = false;
  DateTime? _world1IntroPreludeShownAtV1;
  bool _world1ActionIntroPreludePendingV1 = false;
  bool _showWorld1ActionIntroPreludeV1 = false;
  DateTime? _world1ActionIntroPreludeShownAtV1;
  bool _world1StreetFlowIntroPreludePendingV1 = false;
  bool _showWorld1StreetFlowIntroPreludeV1 = false;
  DateTime? _world1StreetFlowIntroPreludeShownAtV1;
  bool _world2HandoffPreludePendingV1 = false;
  bool _showWorld2HandoffPreludeV1 = false;
  DateTime? _world2HandoffPreludeShownAtV1;
  bool _world2IntroPreludePendingV1 = false;
  bool _showWorld2IntroPreludeV1 = false;
  DateTime? _world2IntroPreludeShownAtV1;
  bool _trackIntroPreludePendingV1 = false;
  bool _showTrackIntroPreludeV1 = false;
  DateTime? _trackIntroPreludeShownAtV1;
  String? _trackIntroKindV1;
  bool _resultContinueBusy = false;
  bool _outcomeShowRetrySecondary = false;
  bool _outcomeContinueAdvancesFlowV1 = false;
  bool _outcomeAutoContinueArmedV1 = false;
  bool _preludeDismissedV1 = false;
  bool _introDismissedV1 = false;
  int _introSequenceIndexV1 = 0;
  bool _introStepSatisfiedV1 = false;
  List<String> _outcomeLines = const <String>[];
  String _outcomePrimaryCtaLabel = 'CONTINUE';
  Future<void> Function()? _pendingContinueAction;
  World1CanonicalProgressionTargetV1 _outcomeProgressionTargetV1 =
      World1CanonicalProgressionTargetV1.none;
  final List<int> _reviewQueueStepIndices = <int>[];
  final Set<int> _reviewQueueSet = <int>{};
  final Map<String, GlobalKey> _seatRingRectKeysByDisplayIdV1 =
      <String, GlobalKey>{};
  bool _isInReviewPass = false;
  int _reviewQueueCursor = 0;
  bool _campaignHudDetailsExpanded = false;
  bool _engineV2RunBusy = false;
  bool _engineV2BackendEnabled = false;
  bool _engineV2UseLegacyBackend = false;
  bool _engineV2BackendChoiceMadeInSession = false;
  bool _showEngineV2Controls = false;
  List<String> _engineV2SummaryLines = const <String>[];
  String? _engineV2Verdict;
  String? _engineV2ErrorType;
  String? _engineV2FallbackNote;
  StreetV1? _engineV2CurrentStreet;
  StreetV1? _engineV2StepStreet;
  int _engineV2PotChips = 0;
  int _engineV2ToCallChips = 0;
  int _engineV2CurrentBetChips = 0;
  bool _engineV2PotPulse = false;
  bool _engineV2PlaybackBusy = false;
  List<String> _engineV2TurnFeedLines = const <String>[];
  final List<World1TelemetrySampleV1> _sessionTelemetrySamplesV1 =
      <World1TelemetrySampleV1>[];
  late final CampaignSpineRunnerV1 _campaignSpineRunner = CampaignSpineRunnerV1(
    store: const CampaignSpineProgressStoreAdapterV1(),
  );

  MicroTaskStep get _step => _steps[_stepIndex];
  bool get _isCheckpointSession => _mode == kWorld1RunnerModeCheckpoint;
  bool get _isTablePracticeSession => _mode == kWorld1RunnerModeTablePractice;
  bool get _isDailyRunSession => _mode == kWorld1RunnerModeDailyRun;
  bool get _isCampaignSpineSession => _mode == kWorld1RunnerModeCampaignSpine;
  bool get _isGlobalCheckpointPackV1 =>
      widget.moduleId.trim().toLowerCase() ==
      ProgressService.checkpointPackIdV1;
  bool get _isWorld1SpineCampaignEntryV1 =>
      _isCampaignSpineSession &&
      widget.moduleId.trim().toLowerCase() == 'world1_spine_campaign_v1';
  bool get _isWorld1FirstUserOnboardingTargetV1 =>
      _isCampaignSpineSession &&
      widget.moduleId.trim().toLowerCase() == _conceptFirstSeatPackIdV1;
  bool get _isWorld1ActionLiteracyContinuityTargetV1 =>
      _isCampaignSpineSession &&
      widget.moduleId.trim().toLowerCase() == _actionLiteracyPackIdV1;
  bool get _isWorld1StreetFlowContinuityTargetV1 =>
      _isCampaignSpineSession &&
      widget.moduleId.trim().toLowerCase() == _streetFlowPackIdV1;
  bool get _isWorld2SpineCampaignEntryV1 =>
      _isCampaignSpineSession &&
      widget.moduleId.trim().toLowerCase() == 'world2_spine_campaign_v1';
  bool get _isWorld10TrackFollowupPackV1 =>
      _isCampaignSpineSession &&
      _world10TrackKindForPackIdV1(widget.moduleId) != null;
  bool get _isReviewQueueSession => _mode == kWorld1RunnerModeReviewQueue;
  bool get _isDemoHandLoopSession => _mode == kWorld1RunnerModeDemoHandLoopV1;
  bool get _forceHandLoopSurfaceForTestV1 =>
      widget.debugForceHandLoopSurfaceV1 == true && _isReviewQueueSession;
  bool get _microAnimationsEnabled => !debugDisableRunnerMicroAnimationsV1;
  bool get _engineV2CheckpointEligible =>
      !kReleaseMode && AppSettingsService.instance.isCheckpointModeV1;
  bool get _showEngineV2StreetUi =>
      _isCampaignSpineSession &&
      _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop &&
      _engineV2BackendEnabled &&
      !_engineV2UseLegacyBackend &&
      _engineV2CurrentStreet != null;

  GlobalKey _seatRingRectKeyForDisplayIdV1(String displaySeatId) =>
      _seatRingRectKeysByDisplayIdV1.putIfAbsent(
        displaySeatId,
        () => GlobalKey(debugLabel: 'microtask_seat_ring_rect_$displaySeatId'),
      );

  Rect? _seatRingRectFromKeyV1(String displaySeatId) {
    final context =
        _seatRingRectKeysByDisplayIdV1[displaySeatId]?.currentContext;
    if (context == null) {
      return null;
    }
    try {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return null;
      }
      final origin = renderObject.localToGlobal(Offset.zero);
      return origin & renderObject.size;
    } on FlutterError {
      return null;
    }
  }

  bool get _isLockInBlocked =>
      _outcomeSurfaceVisible ||
      _completionInProgress ||
      _engineV2PlaybackBusy ||
      _showSeatQuizPreludeV1 ||
      _showIntroSequenceV1;
  bool get _showSeatQuizPreludeV1 => false;
  bool get _showIntroSequenceV1 => false;

  void _resetDebugDecisionLatencyV1() {
    if (!kDebugMode) return;
    _debugDecisionTapUsV1 = null;
    _debugStateAppliedUsV1 = null;
    _debugEngineStartUsV1 = null;
    _debugEngineDoneUsV1 = null;
    _debugPostEngineDoneUsV1 = null;
    _debugBeforeShowOutcomeUsV1 = null;
    _debugAfterShowOutcomeCallUsV1 = null;
    _debugShowOutcomeEntryUsV1 = null;
    _debugShowOutcomeBeforeSetStateUsV1 = null;
    _debugShowOutcomeAfterSetStateUsV1 = null;
    _debugOutcomeSetStateUsV1 = null;
    _debugOutcomeFirstFrameUsV1 = null;
    _debugPreShowTelemetryUsV1 = null;
    _debugPreShowFeedbackFxUsV1 = null;
    _debugPreShowProgressionUsV1 = null;
    _debugPreShowFeedbackSetStateUsV1 = null;
    _debugPreShowSeatQuizPrepUsV1 = null;
    _debugHole1T0UsV1 = null;
    _debugHole1T1UsV1 = null;
    _debugHole2T0UsV1 = null;
    _debugHole2T1UsV1 = null;
    _debugHole3T0UsV1 = null;
    _debugHole3T1UsV1 = null;
    _debugHole1LabelV1 = 'n/a';
    _debugHole2LabelV1 = 'n/a';
    _debugHole3LabelV1 = 'n/a';
  }

  void _markDebugDecisionTapV1() {
    if (!kDebugMode) return;
    _debugDecisionTapUsV1 = DateTime.now().toUtc().microsecondsSinceEpoch;
    _debugStateAppliedUsV1 = null;
    _debugEngineStartUsV1 = null;
    _debugEngineDoneUsV1 = null;
    _debugPostEngineDoneUsV1 = null;
    _debugBeforeShowOutcomeUsV1 = null;
    _debugAfterShowOutcomeCallUsV1 = null;
    _debugShowOutcomeEntryUsV1 = null;
    _debugShowOutcomeBeforeSetStateUsV1 = null;
    _debugShowOutcomeAfterSetStateUsV1 = null;
    _debugOutcomeSetStateUsV1 = null;
    _debugOutcomeFirstFrameUsV1 = null;
    _debugPreShowTelemetryUsV1 = null;
    _debugPreShowFeedbackFxUsV1 = null;
    _debugPreShowProgressionUsV1 = null;
    _debugPreShowFeedbackSetStateUsV1 = null;
    _debugPreShowSeatQuizPrepUsV1 = null;
    _debugHole1T0UsV1 = null;
    _debugHole1T1UsV1 = null;
    _debugHole2T0UsV1 = null;
    _debugHole2T1UsV1 = null;
    _debugHole3T0UsV1 = null;
    _debugHole3T1UsV1 = null;
    _debugHole1LabelV1 = 'n/a';
    _debugHole2LabelV1 = 'n/a';
    _debugHole3LabelV1 = 'n/a';
  }

  void _markDebugEngineStartV1() {
    if (!kDebugMode) return;
    _debugEngineStartUsV1 = DateTime.now().toUtc().microsecondsSinceEpoch;
    _debugEngineDoneUsV1 = null;
    _debugPostEngineDoneUsV1 = null;
    _debugBeforeShowOutcomeUsV1 = null;
    _debugAfterShowOutcomeCallUsV1 = null;
    _debugShowOutcomeEntryUsV1 = null;
    _debugShowOutcomeBeforeSetStateUsV1 = null;
    _debugShowOutcomeAfterSetStateUsV1 = null;
    _debugOutcomeSetStateUsV1 = null;
    _debugOutcomeFirstFrameUsV1 = null;
    _debugPreShowTelemetryUsV1 = null;
    _debugPreShowFeedbackFxUsV1 = null;
    _debugPreShowProgressionUsV1 = null;
    _debugPreShowFeedbackSetStateUsV1 = null;
    _debugPreShowSeatQuizPrepUsV1 = null;
    _debugHole1T0UsV1 = null;
    _debugHole1T1UsV1 = null;
    _debugHole2T0UsV1 = null;
    _debugHole2T1UsV1 = null;
    _debugHole3T0UsV1 = null;
    _debugHole3T1UsV1 = null;
    _debugHole1LabelV1 = 'n/a';
    _debugHole2LabelV1 = 'n/a';
    _debugHole3LabelV1 = 'n/a';
  }

  void _markDebugEngineDoneV1() {
    if (!kDebugMode) return;
    _debugEngineDoneUsV1 = DateTime.now().toUtc().microsecondsSinceEpoch;
  }

  void _markDebugPostEngineDoneV1() {
    if (!kDebugMode) return;
    _debugPostEngineDoneUsV1 = DateTime.now().toUtc().microsecondsSinceEpoch;
  }

  void _markDebugBeforeShowOutcomeV1() {
    if (!kDebugMode) return;
    _debugBeforeShowOutcomeUsV1 = DateTime.now().toUtc().microsecondsSinceEpoch;
    _debugAfterShowOutcomeCallUsV1 = null;
    _debugShowOutcomeEntryUsV1 = null;
    _debugShowOutcomeBeforeSetStateUsV1 = null;
    _debugShowOutcomeAfterSetStateUsV1 = null;
  }

  void _markDebugAfterShowOutcomeCallV1() {
    if (!kDebugMode) return;
    _debugAfterShowOutcomeCallUsV1 = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch;
  }

  void _markDebugHoleStartV1(int holeIndex, String label) {
    if (!kDebugMode) return;
    final nowUs = DateTime.now().toUtc().microsecondsSinceEpoch;
    switch (holeIndex) {
      case 1:
        _debugHole1LabelV1 = label;
        _debugHole1T0UsV1 = nowUs;
        _debugHole1T1UsV1 = null;
        return;
      case 2:
        _debugHole2LabelV1 = label;
        _debugHole2T0UsV1 = nowUs;
        _debugHole2T1UsV1 = null;
        return;
      case 3:
        _debugHole3LabelV1 = label;
        _debugHole3T0UsV1 = nowUs;
        _debugHole3T1UsV1 = null;
        return;
    }
  }

  void _markDebugHoleEndV1(int holeIndex) {
    if (!kDebugMode) return;
    final nowUs = DateTime.now().toUtc().microsecondsSinceEpoch;
    switch (holeIndex) {
      case 1:
        _debugHole1T1UsV1 = nowUs;
        return;
      case 2:
        _debugHole2T1UsV1 = nowUs;
        return;
      case 3:
        _debugHole3T1UsV1 = nowUs;
        return;
    }
  }

  void _ensureDebugEngineDoneV1() {
    if (!kDebugMode || _debugEngineDoneUsV1 != null) return;
    _markDebugEngineDoneV1();
    _markDebugPostEngineDoneV1();
  }

  void _markDebugStateAppliedV1() {
    if (!kDebugMode) return;
    final appliedUs = DateTime.now().toUtc().microsecondsSinceEpoch;
    _debugStateAppliedUsV1 = appliedUs;
    _debugOutcomeSetStateUsV1 = appliedUs;
    _debugOutcomeFirstFrameUsV1 = null;
  }

  void _scheduleDebugOutcomeFirstFrameMarkV1() {
    if (!kDebugMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_outcomeSurfaceVisible) return;
      _debugOutcomeFirstFrameUsV1 = DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch;
    });
  }

  @visibleForTesting
  String debugCoachModeNameV1() => _currentCoachModeV1().name;

  @visibleForTesting
  List<String> debugOutcomeLinesV1() =>
      List<String>.unmodifiable(_outcomeLines);

  @visibleForTesting
  void debugForceCoachIntroStateForTestV1() {
    if (!_isCampaignSpineSession) return;
    setState(() {
      _stepIndex = 0;
      _selectedSeatId = null;
      _outcomeSurfaceVisible = false;
      _completionInProgress = false;
      _preludeDismissedV1 = false;
      _introDismissedV1 = false;
    });
  }

  @visibleForTesting
  void debugForceCoachOutcomeStateForTestV1({bool isCorrect = true}) {
    setState(() {
      _outcomeSurfaceVisible = true;
      _outcomeLastResultCorrect = isCorrect;
      _completionInProgress = false;
      _feedback = null;
      _showHint = false;
      _outcomeLines = <String>[_world1OutcomeVerdictLineV1(isCorrect)];
      _outcomePrimaryCtaLabel = 'CONTINUE';
      _pendingContinueAction ??= () async {};
    });
  }

  _CoachModeV1 _currentCoachModeV1() {
    final runnerAuthorityV1 = _currentRunnerAuthorityStateV1();
    if (_showSeatQuizPreludeV1 || _showIntroSequenceV1) {
      return _CoachModeV1.intro;
    }
    if (runnerAuthorityV1.outcomeVisible) {
      return _CoachModeV1.outcome;
    }
    if (_isDemoHandLoopVisualStepV1) {
      return _CoachModeV1.demo;
    }
    if (runnerAuthorityV1.handLoopMode) {
      return runnerAuthorityV1.actionStateAvailable
          ? _CoachModeV1.action
          : _CoachModeV1.none;
    }
    final hasFeedback = _feedback != null && _feedback!.trim().isNotEmpty;
    if (_showHint || hasFeedback || _awaitingSeatInput) {
      return _CoachModeV1.action;
    }
    return _CoachModeV1.none;
  }

  _GuidedSeatStepV1? get _guidedSeatStepV1 =>
      !_isCampaignSpineSession ||
          _currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz
      ? null
      : kGuidedSeatStepsV1[_stepIndex];
  _GuidedSeatStepV1? get _introSequenceStepV1 =>
      (_showIntroSequenceV1 &&
          _introSequenceIndexV1 >= 0 &&
          _introSequenceIndexV1 < _activeIntroSequenceStepsV1.length)
      ? _activeIntroSequenceStepsV1[_introSequenceIndexV1]
      : null;
  List<_GuidedSeatStepV1> get _activeIntroSequenceStepsV1 {
    final packId = widget.moduleId.trim().toLowerCase();
    if (packId.startsWith('world2_spine_')) {
      return _introSequenceStepsWorld2V1;
    }
    if (packId.startsWith('world3_spine_')) {
      return _introSequenceStepsWorld3V1;
    }
    return _introSequenceStepsV1;
  }

  List<_CoachStepV1> get _seatQuizCoachStepsV1 => <_CoachStepV1>[
    _CoachStepV1(
      title: _seatQuizPreviewTitleV1,
      subtitle: _seatQuizPreviewSubtitleV1,
      highlightSeatId: 'btn',
    ),
    ..._activeIntroSequenceStepsV1.map(
      (step) => _CoachStepV1(
        title: step.prompt,
        subtitle: step.subtitle,
        highlightSeatId: step.seatId,
      ),
    ),
  ];
  _CoachStepV1? get _activeSeatQuizCoachStepV1 {
    final coachSteps = _seatQuizCoachStepsV1;
    if (coachSteps.isEmpty) return null;
    if (_showSeatQuizPreludeV1) {
      return coachSteps.first;
    }
    if (_showIntroSequenceV1) {
      final coachIndex = 1 + _introSequenceIndexV1;
      if (coachIndex >= 0 && coachIndex < coachSteps.length) {
        return coachSteps[coachIndex];
      }
    }
    return null;
  }

  bool get _isIntroContinueEnabledV1 {
    final introStep = _introSequenceStepV1;
    if (introStep == null) {
      return false;
    }
    if (!introStep.requiresSeatTap) {
      return true;
    }
    return _selectedSeatId == introStep.seatId || _introStepSatisfiedV1;
  }

  String get _seatQuizPreviewTitleV1 =>
      _seatQuizGuidanceForTargetV1(includeConfirmHint: false);
  String get _seatQuizPreviewSubtitleV1 => '';

  String get _seatQuizPreviewSeatListDebugV1 {
    final expected = _effectiveExpectedSeatIdsV1
        .map((seat) => seat.trim().toUpperCase())
        .where((seat) => seat.isNotEmpty)
        .toList();
    if (expected.isNotEmpty) {
      return expected.join('/');
    }
    return 'BTN/SB/BB/CO/HJ/UTG';
  }

  String _seatQuizTargetLabelV1(String seatId) {
    final normalized = seatId.trim().toLowerCase();
    return switch (normalized) {
      'btn' => 'Button (Dealer)',
      'sb' => 'Small Blind',
      'bb' => 'Big Blind',
      'co' => 'Cutoff',
      'hj' => 'Hijack',
      'utg' => 'Under the Gun',
      _ => normalized.toUpperCase(),
    };
  }

  String _seatQuizGuidanceForTargetV1({required bool includeConfirmHint}) {
    final seatOrderIds =
        _World1FoundationsMicroTaskRunnerScreenState._seatsForMaxPlayersV1(
          _effectiveSeatLayoutMaxPlayersV1,
        ).map((seat) => seat.id).toList(growable: false);
    final taskCopy = resolveWorld1CanonicalSeatQuizTaskCopyV1(
      World1CanonicalSeatQuizTaskCopyInputV1(
        targetSeatId: _seatQuizTargetSeatIdV1,
        includeConfirmHint: includeConfirmHint,
        seatOrderIds: seatOrderIds,
      ),
    );
    return taskCopy.promptText;
  }

  String? _seatQuizInstructionForTargetV1() {
    final targetSeatId = _seatQuizTargetSeatIdV1;
    if (targetSeatId == null || targetSeatId.trim().isEmpty) {
      return null;
    }
    return _seatQuizGuidanceForTargetV1(includeConfirmHint: false);
  }

  String _seatQuizIdleGuidanceLineV1() {
    return _seatQuizGuidanceForTargetV1(includeConfirmHint: true);
  }

  String get _seatQuizFallbackGuidanceTitleV1 =>
      kAct0SeatQuizFallbackGuidanceTitleV1;

  String get _displayedStepPromptV1 =>
      _guidedSeatStepV1?.prompt ?? _step.prompt;
  String? get _guidedTargetSeatIdV1 {
    final introStep = _introSequenceStepV1;
    if (introStep != null) {
      return introStep.requiresSeatTap
          ? _normalizedScenarioSeatIdV1(introStep.seatId)
          : null;
    }
    return _normalizedScenarioSeatIdV1(_guidedSeatStepV1?.seatId);
  }

  List<String> get _effectiveExpectedSeatIdsV1 {
    final guidedTarget = _guidedTargetSeatIdV1;
    if (guidedTarget != null && guidedTarget.isNotEmpty) {
      return <String>[guidedTarget];
    }
    return _step.expectedSeatIds
        .map(_normalizedScenarioSeatIdV1)
        .whereType<String>()
        .toList(growable: false);
  }

  List<String> get _normalizedStepExpectedSeatIdsV1 => _step.expectedSeatIds
      .map(_normalizedScenarioSeatIdV1)
      .whereType<String>()
      .toList(growable: false);

  String? get _seatQuizTargetSeatIdV1 {
    final stepExpected = _normalizedStepExpectedSeatIdsV1;
    if (stepExpected.isNotEmpty) {
      return stepExpected.first;
    }
    final guidedTarget = _guidedTargetSeatIdV1;
    if (guidedTarget != null && guidedTarget.isNotEmpty) {
      return guidedTarget;
    }
    final fallbackExpected = _effectiveExpectedSeatIdsV1;
    if (fallbackExpected.isNotEmpty) {
      return fallbackExpected.first;
    }
    final introCoachHighlight = _normalizedScenarioSeatIdV1(
      _activeSeatQuizCoachStepV1?.highlightSeatId,
    );
    if (introCoachHighlight != null && introCoachHighlight.isNotEmpty) {
      return introCoachHighlight;
    }
    return _normalizedScenarioSeatIdV1(_selectedSeatId);
  }

  List<String> get _seatQuizExpectedSeatIdsV1 {
    final stepExpected = _normalizedStepExpectedSeatIdsV1;
    if (stepExpected.isNotEmpty) {
      return stepExpected;
    }
    final targetSeatId = _seatQuizTargetSeatIdV1;
    if (targetSeatId != null) {
      return <String>[targetSeatId];
    }
    return const <String>[];
  }

  _CampaignRunnerMode get _currentCampaignRunnerMode =>
      _resolveCampaignRunnerModeForCurrentStep();

  static final RegExp _campaignSpinePackPattern = RegExp(
    r'^world(10|[1-9])_spine_(?:campaign_v1|followup_v1(?:_b\d+)?)$',
  );

  bool _isCampaignSpinePackId(String packId) {
    return _campaignSpinePackPattern.hasMatch(packId.trim().toLowerCase());
  }

  bool get _isWorld1SpineParityPackV1 => _world1SpineParityPackIdsV1.contains(
    widget.moduleId.trim().toLowerCase(),
  );

  int? _campaignWorldForPackId(String packId) {
    final match = _campaignSpinePackPattern.firstMatch(
      packId.trim().toLowerCase(),
    );
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  String? _world10TrackKindForPackIdV1(String packId) {
    final normalized = packId.trim().toLowerCase();
    if (normalized == 'world10_spine_followup_v1_b0') return 'cash';
    if (normalized == 'world10_spine_followup_v1_b1') return 'tournament';
    if (normalized == 'world10_spine_followup_v1_b2') return 'mixed';
    return null;
  }

  String? _trackHandoffStatusLineV1() {
    return buildProgressionHandoffContextForPackV1(widget.moduleId)?.statusLine;
  }

  Future<void> _markCalibrationCompletedForCampaignPack({
    required String packId,
    required int calibrationBand,
  }) async {
    final world = _campaignWorldForPackId(packId);
    if (world == null) return;
    switch (world) {
      case 1:
        await ProgressService.setSpineCalibrationBandV1(calibrationBand);
        await ProgressService.markSpineCalibrationCompletedV1();
        return;
      case 2:
        await ProgressService.markWorld2CalibrationCompletedV1();
        return;
      case 3:
        await ProgressService.markWorld3CalibrationCompletedV1();
        return;
      case 4:
        await ProgressService.markWorld4CalibrationCompletedV1();
        return;
      case 5:
        await ProgressService.markWorld5CalibrationCompletedV1();
        return;
      case 6:
        await ProgressService.markWorld6CalibrationCompletedV1();
        return;
      case 7:
        await ProgressService.markWorld7CalibrationCompletedV1();
        return;
      case 8:
        await ProgressService.markWorld8CalibrationCompletedV1();
        return;
      case 9:
        await ProgressService.markWorld9CalibrationCompletedV1();
        return;
      case 10:
        await ProgressService.markWorld10CalibrationCompletedV1();
        return;
    }
  }

  String get _spineContractExpectedTargetToken {
    if (!_isCampaignSpineSession) return '';
    final expected = _seatQuizExpectedSeatIdsV1.isEmpty
        ? ''
        : _seatQuizExpectedSeatIdsV1.first;
    switch (expected) {
      case 'btn':
        return 'seat_btn';
      case 'sb':
        return 'seat_sb';
      case 'bb':
        return 'seat_bb';
      case 'co':
        return 'seat_co';
      case 'hj':
        return 'seat_hj';
      case 'utg':
        return 'seat_utg';
      default:
        return 'seat_btn';
    }
  }

  bool get _spineContractRequiresContinue =>
      _seatQuizAutoAdvancePendingV1 ||
      _completionInProgress ||
      _outcomeSurfaceVisible ||
      _showSeatQuizPreludeV1 ||
      (_showIntroSequenceV1 && _isIntroContinueEnabledV1);

  void _advanceSpineContractContinueV1() {
    if (_outcomeSurfaceVisible) {
      unawaited(_onContinueResult());
      return;
    }
    if (_showSeatQuizPreludeV1) {
      setState(() {
        _preludeDismissedV1 = true;
        _introDismissedV1 = false;
        _introSequenceIndexV1 = 0;
        final introSteps = _activeIntroSequenceStepsV1;
        _introStepSatisfiedV1 = introSteps.isEmpty
            ? false
            : !introSteps[0].requiresSeatTap;
        _selectedSeatId = null;
      });
      return;
    }
    if (_showIntroSequenceV1 && _isIntroContinueEnabledV1) {
      setState(() {
        final isLast =
            _introSequenceIndexV1 >= _activeIntroSequenceStepsV1.length - 1;
        if (isLast) {
          _introDismissedV1 = true;
        } else {
          _introSequenceIndexV1 += 1;
        }
        final nextStep = isLast
            ? null
            : _activeIntroSequenceStepsV1[_introSequenceIndexV1];
        _introStepSatisfiedV1 = nextStep == null
            ? false
            : !nextStep.requiresSeatTap;
        _selectedSeatId = null;
      });
    }
  }

  void _onSpineContractTargetTap(String token) {
    if (_isCampaignSpineSession &&
        (_currentCampaignRunnerMode == _CampaignRunnerMode.handLoop ||
            _isWorld2SeatQuizBeatV1) &&
        token.startsWith('seat_')) {
      debugDisableRunnerMicroAnimationsV1 = true;
      if (!_spineContractSyntheticNegativeIssuedV1) {
        _spineContractSyntheticNegativeIssuedV1 = true;
        _spineContractSyntheticNegativePendingCheckV1 = true;
        if (mounted && _spineDelta >= 0) {
          setState(() {
            _spineDelta = -1;
          });
        }
        return;
      }
      if (_currentCampaignRunnerMode != _CampaignRunnerMode.handLoop) {
        // For seat-quiz contract paths, allow seat selection handling below.
      } else {
        if (token == 'seat_co') {
          unawaited(_runCampaignHandLoopFromLockIn());
          return;
        }
        unawaited(_runCampaignHandLoopFromLockIn());
        return;
      }
    }
    switch (token) {
      case 'seat_btn':
        _selectSeat('btn');
        return;
      case 'seat_sb':
        _selectSeat('sb');
        return;
      case 'seat_bb':
        _selectSeat('bb');
        return;
      case 'seat_co':
        _selectSeat('co');
        return;
      case 'seat_hj':
        _selectSeat('hj');
        return;
      case 'seat_utg':
        _selectSeat('utg');
        return;
      case 'continue':
        _advanceSpineContractContinueV1();
        return;
    }
  }

  Widget _buildSpineContractHarnessV1({
    required bool useRunnerCompactHeaderV1,
  }) {
    if (!_isCampaignSpineSession) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Offstage(
          offstage: true,
          child: Text(
            'i=$_stepIndex',
            key: const Key('spine_contract_hand_index'),
          ),
        ),
        Offstage(
          offstage: true,
          child: Text(
            'target=$_spineContractExpectedTargetToken',
            key: const Key('spine_contract_expected_target'),
          ),
        ),
        Offstage(
          offstage: true,
          child: Text(
            _spineContractRequiresContinue ? 'continue=1' : 'continue=0',
            key: const Key('spine_contract_requires_continue'),
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pack: ${widget.moduleId}',
                    key: const Key('spine_campaign_pack_id_value'),
                  ),
                  Text(
                    'HandIndex: $_stepIndex',
                    key: const Key('spine_campaign_hand_index_value'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (kDebugMode)
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              for (final token in const <String>[
                'seat_btn',
                'seat_sb',
                'seat_bb',
                'seat_co',
                'seat_hj',
                'seat_utg',
                'continue',
              ])
                SizedBox(
                  width: 10,
                  height: 10,
                  child: GestureDetector(
                    key: Key('spine_contract_target_$token'),
                    onTap: () => _onSpineContractTargetTap(token),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
            ],
          ),
        if (((_currentCampaignRunnerMode == _CampaignRunnerMode.handLoop)) ||
            (!_showSeatQuizPreludeV1 &&
                !_showIntroSequenceV1 &&
                !_outcomeSurfaceVisible &&
                _selectedSeatId != null))
          SizedBox(
            width: 10,
            height: 10,
            child: GestureDetector(
              key: const Key('microtask_check_cta'),
              onTap: () {
                if (_spineContractSyntheticNegativePendingCheckV1) {
                  _spineContractSyntheticNegativePendingCheckV1 = false;
                  return;
                }
                _onCheck();
              },
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.transparent),
              ),
            ),
          ),
        if (_isCampaignSpineSession)
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: Text(
                  _spineDelta > 0
                      ? '+$_spineDelta chips'
                      : (_spineDelta < 0 ? '$_spineDelta chips' : '0 chips'),
                  key: const Key('spine_bankroll_delta'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  CampaignSpineBeatPointerV1? _buildCurrentCampaignPointerForDebug() {
    if (!_isCampaignSpineSession) return null;
    final worldId = _campaignWorldForPackId(widget.moduleId);
    if (worldId == null) return null;
    return CampaignSpineBeatPointerV1(
      packId: widget.moduleId,
      worldId: worldId,
      beatIndex: _stepIndex,
      totalBeats: _steps.length,
      beat: _step,
    );
  }

  Future<void> _runEngineV2MvpFixture() async {
    if (_engineV2RunBusy) return;
    _engineV2StreetReplayTimer?.cancel();
    setState(() {
      _engineV2RunBusy = true;
      if (_engineV2BackendEnabled && !_engineV2UseLegacyBackend) {
        _engineV2CurrentStreet = StreetV1.preflop;
        _engineV2StepStreet = StreetV1.preflop;
        _engineV2PotChips = 0;
        _engineV2ToCallChips = 0;
        _engineV2CurrentBetChips = 0;
        _engineV2PotPulse = false;
        _engineV2PlaybackBusy = true;
      }
    });
    try {
      if (!_engineV2BackendEnabled) {
        if (!mounted) return;
        setState(() {
          _engineV2Verdict = 'disabled';
          _engineV2ErrorType = null;
          _engineV2SummaryLines = const <String>[
            'EngineV2 backend toggle is OFF.',
            'Enable \"Use EngineV2 backend\" to run interop scenario.',
          ];
          _engineV2CurrentStreet = null;
          _engineV2StepStreet = null;
          _engineV2PotChips = 0;
          _engineV2ToCallChips = 0;
          _engineV2CurrentBetChips = 0;
          _engineV2PotPulse = false;
          _engineV2PlaybackBusy = false;
        });
        return;
      }
      final pointer = _buildCurrentCampaignPointerForDebug();
      if (pointer == null) {
        const fallbackFollowUpPlanV1 =
            kWorld1CanonicalHandLoopFallbackFollowUpPlanV1;
        if (!mounted) return;
        setState(() {
          _engineV2Verdict = 'unavailable';
          _engineV2ErrorType = 'logic';
          _engineV2SummaryLines = const <String>[
            'EngineV2 interop requires campaign spine mode.',
          ];
          _engineV2CurrentStreet = null;
          _engineV2StepStreet = null;
          _engineV2PotChips = 0;
          _engineV2ToCallChips = 0;
          _engineV2CurrentBetChips = 0;
          _engineV2PotPulse = false;
          _engineV2PlaybackBusy = false;
        });
        return;
      }

      final replayerScenario = _campaignSpineRunner.scenarioForPointer(pointer);
      if (_engineV2UseLegacyBackend) {
        _applyLegacyBackendSummary(
          pointer: pointer,
          replayerScenario: replayerScenario,
          fallbackNote: null,
        );
        return;
      }

      final interop = const ReplayerToEngineV2AdapterV1().tryConvert(
        scenarioId: 'w1_real_${pointer.packId}_${pointer.beatIndex}',
        replayer: replayerScenario,
      );

      if (!interop.isSuccess || interop.scenario == null) {
        _applyLegacyBackendSummary(
          pointer: pointer,
          replayerScenario: replayerScenario,
          fallbackNote: kReleaseMode ? null : 'EngineV2 blocked; used Legacy',
        );
        return;
      }

      final handLoop = runWorld1CanonicalEngineV2HandLoopV1(interop.scenario!);
      final replayTrace = _asReplayTrace(handLoop);
      final outcome = _buildOutcomeFromHandLoop(
        replayTrace: replayTrace,
        handLoop: handLoop,
      );
      final executionPackageV1 =
          resolveWorld1CanonicalHandLoopExecutionPackageV1(
            World1CanonicalHandLoopExecutionPackageInputV1(
              verdict: outcome.verdict.name,
              errorType: outcome.error?.type.name,
              outcomeSummaryLines: const OutcomeAdapterV1().toSummaryLines(
                outcome,
              ),
              turnFeedLines: _buildTurnFeedLines(replayTrace),
              heroActionsApplied: handLoop.heroActionsApplied,
              entryCount: handLoop.entries.length,
              stopReasonName: handLoop.stopReason.name,
              isCorrect: outcome.verdict == DecisionVerdictV1.correct,
              reason: _engineOutcomeReason(
                outcome: outcome,
                handLoop: handLoop,
              ),
              outcomeType: outcome.error?.type.name ?? 'none',
              nextHint: _engineOutcomeHint(
                outcome: outcome,
                handLoop: handLoop,
              ),
            ),
          );
      const outcomeFollowUpPlanV1 =
          kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1;
      if (!mounted) return;
      setState(() {
        _engineV2Verdict = executionPackageV1.engineVerdict;
        _engineV2ErrorType = executionPackageV1.engineErrorType;
        _engineV2SummaryLines = executionPackageV1.engineSummaryLines;
        _engineV2FallbackNote = executionPackageV1.engineFallbackNote;
        _engineV2TurnFeedLines = executionPackageV1.engineTurnFeedLines;
      });
      _startEngineV2StreetPlayback(replayTrace);
      _showOutcomeSurfaceProfiledV1(
        isCorrect: executionPackageV1.isCorrect,
        reason: executionPackageV1.reason,
        errorType: executionPackageV1.outcomeType,
        nextHint: executionPackageV1.nextHint,
        onContinue: _completeStepFlow,
        continueAdvancesFlow: outcomeFollowUpPlanV1.continueAdvancesFlow,
        autoContinue: outcomeFollowUpPlanV1.autoContinue,
        primaryCtaLabel: outcomeFollowUpPlanV1.primaryCtaLabel,
        showRetrySecondary: outcomeFollowUpPlanV1.showRetrySecondary,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _engineV2RunBusy = false;
      });
    }
  }

  OutcomeV1 _buildOutcomeFromHandLoop({
    required ReplayTraceV1 replayTrace,
    required World1CanonicalHandLoopRunV1 handLoop,
  }) {
    final finalStateKind = replayTrace.entries.isEmpty
        ? EngineStateKindV1.setup
        : replayTrace.entries.last.result.state.kind;
    final summary = OutcomeTraceSummaryV1(
      totalSteps: replayTrace.entries.length,
      executedSteps: replayTrace.entries.length,
      finalStateKind: finalStateKind,
      stoppedAtStep: replayTrace.stoppedAtStep,
    );
    if (!handLoop.firstHeroActionMatchesExpected) {
      return OutcomeV1(
        verdict: DecisionVerdictV1.incorrect,
        error: const ErrorClassificationV1().fromRangeMismatch(
          expected:
              handLoop.firstHeroActionExpectedLabel ??
              'EXPECTED_ACTION_UNAVAILABLE',
          actual:
              handLoop.firstHeroActionActualLabel ??
              'ACTUAL_ACTION_UNAVAILABLE',
        ),
        traceSummary: summary,
      );
    }
    if (handLoop.violations.isEmpty) {
      return OutcomeV1(
        verdict: DecisionVerdictV1.correct,
        traceSummary: summary,
      );
    }
    return OutcomeV1(
      verdict: DecisionVerdictV1.incorrect,
      error: const ErrorClassificationV1().fromViolation(
        code: handLoop.violations.first.code,
        message: handLoop.violations.first.message,
      ),
      traceSummary: summary,
    );
  }

  Future<void> _presentCampaignOutcomeFromResult({
    required bool isCorrect,
    required String reason,
    required String errorType,
    required String nextHint,
    required int decisionMs,
    required World1CanonicalHandLoopFollowUpPlanV1 followUpPlanV1,
    ActionKindV1? selectedActionKind,
  }) async {
    _markDebugHoleEndV1(2);
    _markDebugHoleStartV1(3, 'present_pre_show_window');
    _ensureDebugEngineDoneV1();
    final outcomeEffectsStateV1 =
        resolveWorld1CanonicalHandLoopOutcomeEffectsStateV1(
          World1CanonicalHandLoopOutcomeEffectsInputV1(
            moduleId: widget.moduleId,
            mode: _mode,
            stepIndex: _stepIndex,
            isCorrect: isCorrect,
            errorType: errorType,
            decisionMs: decisionMs,
            previousAttemptsForStep: _wrongAttemptsByStep[_stepIndex] ?? 0,
            previousMistakesCount: _wrongAttemptsByStep.length,
            reason: reason,
          ),
        );
    final telemetryStartUs = kDebugMode
        ? DateTime.now().toUtc().microsecondsSinceEpoch
        : 0;
    _emitTelemetry('correct', outcomeEffectsStateV1.correctTelemetry);
    _emitTelemetry(
      'time_to_decision',
      outcomeEffectsStateV1.timeToDecisionTelemetry,
    );
    if (kDebugMode) {
      _debugPreShowTelemetryUsV1 =
          DateTime.now().toUtc().microsecondsSinceEpoch - telemetryStartUs;
    }

    final feedbackFxStartUs = kDebugMode
        ? DateTime.now().toUtc().microsecondsSinceEpoch
        : 0;
    if (outcomeEffectsStateV1.uiSoundEventName == 'success') {
      UiSoundV1.fire(UiSoundEventV1.success);
    } else {
      UiSoundV1.fire(UiSoundEventV1.error);
    }
    unawaited(
      AudioService.instance.playUiSfx(outcomeEffectsStateV1.uiSfxAssetName),
    );
    if (outcomeEffectsStateV1.uiHapticEventName == 'success') {
      unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
    } else {
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
    }
    if (outcomeEffectsStateV1.triggerSuccessPulse) {
      _triggerSuccessPulse();
    }
    if (outcomeEffectsStateV1.triggerFailurePulse) {
      _triggerFailurePulse();
    }
    if (outcomeEffectsStateV1.effectProfile ==
        World1CanonicalHandLoopEffectProfileV1.error) {
      _wrongAttemptsByStep[_stepIndex] =
          outcomeEffectsStateV1.nextAttemptsForStep!;
      _queueCurrentStepForReview();
      if (mounted) {
        setState(() {
          _spineMistakesCount = outcomeEffectsStateV1.nextMistakesCount!;
          _showHint = outcomeEffectsStateV1.showHint!;
        });
      }
    }
    if (kDebugMode) {
      _debugPreShowFeedbackFxUsV1 =
          DateTime.now().toUtc().microsecondsSinceEpoch - feedbackFxStartUs;
    }

    final progressionStartUs = kDebugMode
        ? DateTime.now().toUtc().microsecondsSinceEpoch
        : 0;
    if (outcomeEffectsStateV1.applyCampaignConsequence) {
      unawaited(() async {
        try {
          await _applyCampaignConsequence(
            isCorrect,
            handIndex: _stepIndex,
            mistakesCountSoFar: _wrongAttemptsByStep.length,
          );
        } catch (_) {}
      }());
    }
    if (kDebugMode) {
      _debugPreShowProgressionUsV1 =
          DateTime.now().toUtc().microsecondsSinceEpoch - progressionStartUs;
    }

    if (!mounted) return;
    final feedbackSetStateStartUs = kDebugMode
        ? DateTime.now().toUtc().microsecondsSinceEpoch
        : 0;
    setState(() {
      _feedback = outcomeEffectsStateV1.feedback;
    });
    if (kDebugMode) {
      _debugPreShowFeedbackSetStateUsV1 =
          DateTime.now().toUtc().microsecondsSinceEpoch -
          feedbackSetStateStartUs;
    }
    _showOutcomeSurfaceProfiledV1(
      isCorrect: isCorrect,
      reason: reason,
      errorType: errorType,
      nextHint: nextHint,
      selectedActionKind: selectedActionKind,
      onContinue: _completeStepFlow,
      continueAdvancesFlow: followUpPlanV1.continueAdvancesFlow,
      autoContinue: followUpPlanV1.autoContinue,
      primaryCtaLabel: followUpPlanV1.primaryCtaLabel,
      showRetrySecondary: followUpPlanV1.showRetrySecondary,
    );
    _markDebugHoleEndV1(3);
  }

  Future<void> _runCampaignHandLoopFromLockIn({
    ActionV1? heroActionOverride,
  }) async {
    if (_engineV2RunBusy || _engineV2PlaybackBusy || _outcomeSurfaceVisible) {
      return;
    }
    _markDebugEngineStartV1();
    final decisionMs = _elapsedMs(_decisionStartedAt);
    _emitTelemetry('user_choice', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
      'step_index': _stepIndex,
      'choice': heroActionOverride == null
          ? (_selectedSeatId ?? 'engine_hand_loop')
          : 'action_${heroActionOverride.kind.name}',
    });
    _engineV2StreetReplayTimer?.cancel();
    _engineV2PotPulseTimer?.cancel();
    final handLoopLaunchStateV1 = resolveWorld1CanonicalHandLoopLaunchStateV1(
      preflopStreet: StreetV1.preflop,
    );
    setState(() {
      _engineV2RunBusy = handLoopLaunchStateV1.engineRunBusy;
      _engineV2PlaybackBusy = handLoopLaunchStateV1.enginePlaybackBusy;
      _engineV2CurrentStreet =
          handLoopLaunchStateV1.engineCurrentStreet as StreetV1?;
      _engineV2StepStreet = handLoopLaunchStateV1.engineStepStreet as StreetV1?;
      _engineV2PotChips = handLoopLaunchStateV1.enginePotChips;
      _engineV2ToCallChips = handLoopLaunchStateV1.engineToCallChips;
      _engineV2CurrentBetChips = handLoopLaunchStateV1.engineCurrentBetChips;
      _engineV2PotPulse = handLoopLaunchStateV1.enginePotPulse;
      _engineV2TurnFeedLines = handLoopLaunchStateV1.engineTurnFeedLines;
    });
    try {
      final pointer = _buildCurrentCampaignPointerForDebug();
      if (pointer == null) {
        const fallbackFollowUpPlanV1 =
            kWorld1CanonicalHandLoopFallbackFollowUpPlanV1;
        if (!mounted) return;
        setState(() {
          _engineV2PlaybackBusy =
              kWorld1CanonicalHandLoopFallbackStateV1.enginePlaybackBusy;
          _engineV2CurrentStreet =
              kWorld1CanonicalHandLoopFallbackStateV1.engineCurrentStreet
                  as StreetV1?;
          _engineV2StepStreet =
              kWorld1CanonicalHandLoopFallbackStateV1.engineStepStreet
                  as StreetV1?;
          _engineV2PotChips =
              kWorld1CanonicalHandLoopFallbackStateV1.enginePotChips;
          _engineV2ToCallChips =
              kWorld1CanonicalHandLoopFallbackStateV1.engineToCallChips;
          _engineV2CurrentBetChips =
              kWorld1CanonicalHandLoopFallbackStateV1.engineCurrentBetChips;
          _engineV2PotPulse =
              kWorld1CanonicalHandLoopFallbackStateV1.enginePotPulse;
          _engineV2TurnFeedLines =
              kWorld1CanonicalHandLoopFallbackStateV1.engineTurnFeedLines;
        });
        if (fallbackFollowUpPlanV1.action ==
            World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck) {
          _runSeatQuizCheckFlow(decisionMs: decisionMs);
        }
        return;
      }

      final replayerScenario = _campaignSpineRunner.scenarioForPointer(pointer);
      final interop = const ReplayerToEngineV2AdapterV1().tryConvert(
        scenarioId: 'w1_real_${pointer.packId}_${pointer.beatIndex}',
        replayer: replayerScenario,
      );

      if (!interop.isSuccess || interop.scenario == null) {
        const interopFailureFollowUpPlanV1 =
            kWorld1CanonicalHandLoopInteropFailureFollowUpPlanV1;
        if (mounted) {
          setState(() {
            _engineV2UseLegacyBackend =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                    .engineUseLegacyBackend;
            _engineV2Verdict =
                kWorld1CanonicalHandLoopInteropFailureStateV1.engineVerdict;
            _engineV2ErrorType =
                kWorld1CanonicalHandLoopInteropFailureStateV1.engineErrorType;
            _engineV2SummaryLines =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                    .engineSummaryLines;
            _engineV2FallbackNote =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                    .engineFallbackNote;
            _engineV2CurrentStreet =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                        .engineCurrentStreet
                    as StreetV1?;
            _engineV2StepStreet =
                kWorld1CanonicalHandLoopInteropFailureStateV1.engineStepStreet
                    as StreetV1?;
            _engineV2PotChips =
                kWorld1CanonicalHandLoopInteropFailureStateV1.enginePotChips;
            _engineV2ToCallChips =
                kWorld1CanonicalHandLoopInteropFailureStateV1.engineToCallChips;
            _engineV2CurrentBetChips =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                    .engineCurrentBetChips;
            _engineV2PotPulse =
                kWorld1CanonicalHandLoopInteropFailureStateV1.enginePotPulse;
            _engineV2PlaybackBusy =
                kWorld1CanonicalHandLoopInteropFailureStateV1
                    .enginePlaybackBusy;
          });
        }
        if (interopFailureFollowUpPlanV1.action ==
            World1CanonicalHandLoopFollowUpActionV1.seatQuizCheck) {
          _runSeatQuizCheckFlow(decisionMs: decisionMs);
        }
        return;
      }

      final heroActions = interop.scenario!.steps
          .whereType<PlayerActionStepV1>()
          .where((step) => step.playerId == const PlayerIdV1('hero'))
          .map((step) => step.action)
          .toList(growable: false);
      final useSpineExplicitExpectedAction =
          heroActionOverride != null &&
          _isWorld1SpineParityPackV1 &&
          !_isDemoHandLoopVisualStepV1;
      final expectedFirstHeroActionKind =
          world1SpineMismatchExpectedActionKindV1(
            step: _step,
            useSpineExplicitExpectedAction: useSpineExplicitExpectedAction,
            firstHeroActionOverride: heroActionOverride,
            heroActions: heroActions,
          );
      final handLoop = runWorld1CanonicalEngineV2HandLoopV1(
        interop.scenario!,
        firstHeroActionOverride: heroActionOverride,
        expectedFirstHeroActionKind: expectedFirstHeroActionKind,
      );
      final replayTrace = _asReplayTrace(handLoop);
      final outcome = _buildOutcomeFromHandLoop(
        replayTrace: replayTrace,
        handLoop: handLoop,
      );
      _markDebugEngineDoneV1();
      _markDebugPostEngineDoneV1();
      _markDebugHoleStartV1(1, 'street_playback_wait');
      final executionPackageV1 =
          resolveWorld1CanonicalHandLoopExecutionPackageV1(
            World1CanonicalHandLoopExecutionPackageInputV1(
              verdict: outcome.verdict.name,
              errorType: outcome.error?.type.name,
              outcomeSummaryLines: const OutcomeAdapterV1().toSummaryLines(
                outcome,
              ),
              turnFeedLines: _buildTurnFeedLines(replayTrace),
              heroActionsApplied: handLoop.heroActionsApplied,
              entryCount: handLoop.entries.length,
              stopReasonName: handLoop.stopReason.name,
              isCorrect: outcome.verdict == DecisionVerdictV1.correct,
              reason: _engineOutcomeReason(
                outcome: outcome,
                handLoop: handLoop,
              ),
              outcomeType: _engineOutcomeType(
                outcome: outcome,
                handLoop: handLoop,
              ),
              nextHint: _engineOutcomeHint(
                outcome: outcome,
                handLoop: handLoop,
              ),
            ),
          );
      const outcomeFollowUpPlanV1 =
          kWorld1CanonicalHandLoopOutcomeFollowUpPlanV1;
      if (mounted) {
        setState(() {
          _engineV2UseLegacyBackend = false;
          _engineV2Verdict = executionPackageV1.engineVerdict;
          _engineV2ErrorType = executionPackageV1.engineErrorType;
          _engineV2SummaryLines = executionPackageV1.engineSummaryLines;
          _engineV2FallbackNote = executionPackageV1.engineFallbackNote;
          _engineV2TurnFeedLines = executionPackageV1.engineTurnFeedLines;
        });
      }
      _startEngineV2StreetPlayback(
        replayTrace,
        skipPlaybackWait: true,
        onComplete: () {
          if (!mounted) return;
          _markDebugHoleEndV1(1);
          _markDebugHoleStartV1(2, 'onComplete_to_present_start');
          if (outcomeFollowUpPlanV1.action ==
              World1CanonicalHandLoopFollowUpActionV1.presentOutcome) {
            unawaited(
              _presentCampaignOutcomeFromResult(
                isCorrect: executionPackageV1.isCorrect,
                reason: executionPackageV1.reason,
                errorType: executionPackageV1.outcomeType,
                nextHint: executionPackageV1.nextHint,
                decisionMs: decisionMs,
                followUpPlanV1: outcomeFollowUpPlanV1,
                selectedActionKind: heroActionOverride?.kind,
              ),
            );
          }
        },
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _engineV2RunBusy =
            kWorld1CanonicalHandLoopRunBusyFinishedV1.engineRunBusy;
      });
    }
  }

  bool get _isSeedGroupStep {
    final group = _step.isoGroup;
    if (group == null || group.trim().isEmpty) return false;
    if (_stepIndex == 0) return true;
    return _steps[_stepIndex - 1].isoGroup != group;
  }

  bool get _showInstructionOverlay {
    if (_currentCampaignRunnerMode == _CampaignRunnerMode.handLoop) {
      return false;
    }
    if (!_isSeedGroupStep) return false;
    return (_step.instructionText?.trim().isNotEmpty ?? false) ||
        (_step.goalText?.trim().isNotEmpty ?? false);
  }

  bool get _isGoldLearningClusterStepV1 {
    if (!_isCampaignSpineSession) return false;
    if (widget.moduleId.trim().toLowerCase() != _goldLearningSlicePackIdV1) {
      return false;
    }
    return _goldLearningClusterStepIndexesV1.contains(_stepIndex);
  }

  bool get _showGoldLearningSlicePreludeCardV1 {
    if (!_isGoldLearningClusterStepV1) return false;
    if (_outcomeSurfaceVisible ||
        _showSeatQuizPreludeV1 ||
        _showIntroSequenceV1) {
      return false;
    }
    return _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop;
  }

  bool get _isConceptFirstSeatMicroSliceV1 {
    if (!_isCampaignSpineSession) return false;
    if (widget.moduleId.trim().toLowerCase() != _conceptFirstSeatPackIdV1) {
      return false;
    }
    return _conceptFirstSeatClusterStepIndexesV1.contains(_stepIndex);
  }

  bool get _showConceptFirstSeatPreludeCardV1 {
    if (!_isConceptFirstSeatMicroSliceV1) return false;
    if (_outcomeSurfaceVisible ||
        _showSeatQuizPreludeV1 ||
        _showIntroSequenceV1) {
      return false;
    }
    return _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz;
  }

  bool get _isActionLiteracyMicroSliceV1 {
    if (!_isCampaignSpineSession) return false;
    if (widget.moduleId.trim().toLowerCase() != _actionLiteracyPackIdV1) {
      return false;
    }
    return _actionLiteracyClusterStepIndexesV1.contains(_stepIndex);
  }

  bool get _showActionLiteracyPreludeCardV1 {
    if (!_isActionLiteracyMicroSliceV1) return false;
    if (_outcomeSurfaceVisible ||
        _showSeatQuizPreludeV1 ||
        _showIntroSequenceV1) {
      return false;
    }
    return _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz;
  }

  bool get _useActionLiteracyCalmSceneLaneV1 {
    if (!_isActionLiteracyMicroSliceV1) return false;
    if (_outcomeSurfaceVisible ||
        _showSeatQuizPreludeV1 ||
        _showIntroSequenceV1) {
      return false;
    }
    return _isCampaignSpineSession &&
        _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop;
  }

  bool get _isStreetFlowMicroSliceV1 {
    if (!_isCampaignSpineSession) return false;
    if (widget.moduleId.trim().toLowerCase() != _streetFlowPackIdV1) {
      return false;
    }
    return _streetFlowClusterStepIndexesV1.contains(_stepIndex);
  }

  bool get _showStreetFlowPreludeCardV1 {
    if (!_isStreetFlowMicroSliceV1) return false;
    if (_outcomeSurfaceVisible ||
        _showSeatQuizPreludeV1 ||
        _showIntroSequenceV1) {
      return false;
    }
    return _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz;
  }

  bool get _isGoldLearningLiteracySliceStepV1 {
    return _isGoldLearningClusterStepV1 &&
        _goldLearningLiteracyStepIndexesV1.contains(_stepIndex);
  }

  String _goldLearningSliceSetupLineV1() {
    final fromStep = _step.contextText?.trim() ?? '';
    if (fromStep.isNotEmpty) {
      return _truncateForOutcome(fromStep, 86);
    }
    return 'Preflop opener in position. Read to-call before acting.';
  }

  String _goldLearningSliceFocusLineV1() {
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    final focus = truth?.requiredFocusLabelV1.trim().toLowerCase() ?? '';
    switch (focus) {
      case 'facing_bet_decision':
        return 'Notice: Facing a bet means call, fold, or raise.';
      case 'initiative_pressure':
        return 'Notice: With no bet to call, decide between check or bet.';
      case 'to_call_discipline':
        return 'Notice: To-call size decides if you continue or exit.';
      default:
        return 'Notice: Read legal actions before tapping.';
    }
  }

  String _conceptFirstSeatSetupLineV1() {
    final expectedSeatId = _seatQuizExpectedSeatIdsV1.isEmpty
        ? null
        : _seatQuizExpectedSeatIdsV1.first;
    return resolveConceptFirstSeatSetupLineV1(expectedSeatId);
  }

  String _conceptFirstSeatWhyLineV1() {
    final expectedSeatId = _seatQuizExpectedSeatIdsV1.isEmpty
        ? null
        : _seatQuizExpectedSeatIdsV1.first;
    switch (expectedSeatId) {
      case 'btn':
        return 'Why it matters: Once you find Button, the rest of the table has an order.';
      case 'sb':
        return 'Why it matters: The blinds are named seats, not random labels.';
      case 'bb':
        return 'Why it matters: Keeping the two blinds distinct prevents seat-order mistakes.';
      default:
        return 'Why it matters: This is where the table order starts.';
    }
  }

  String _conceptFirstSeatFocusLineV1() {
    final expected = _seatQuizExpectedSeatIdsV1.toList(growable: false);
    final expectedSeatId = expected.isEmpty ? null : expected.first;
    switch (expectedSeatId) {
      case 'btn':
        return 'Notice: The dealer button shows where the table order starts.';
      case 'sb':
        return 'Notice: Small Blind sits immediately left of Button.';
      case 'bb':
        return 'Notice: Big Blind sits next to Small Blind and completes the pair.';
      default:
        final seatLabel = expected.isEmpty
            ? 'the highlighted seat'
            : _seatQuizSeatDisplayV1(expected.first);
        return 'Notice: Find $seatLabel before you lock in.';
    }
  }

  String _conceptFirstSeatCompactSupportLineV1() {
    final expectedSeatId = _seatQuizExpectedSeatIdsV1.isEmpty
        ? null
        : _seatQuizExpectedSeatIdsV1.first;
    switch (expectedSeatId) {
      case 'btn':
        return 'Why it matters: The dealer button sets the table order. Notice: Find the dealer button.';
      case 'sb':
        return 'Why it matters: Blind seats have fixed names. Notice: Small Blind is left of Button.';
      case 'bb':
        return 'Why it matters: Blind order must stay clear. Notice: Big Blind is next to Small Blind.';
      default:
        return '${_conceptFirstSeatWhyLineV1()} ${_conceptFirstSeatFocusLineV1()}';
    }
  }

  String _actionLiteracySetupLineV1() {
    final momentumCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
      widget.moduleId,
    );
    switch (_stepIndex) {
      case 0:
        return momentumCopy?.setupLine ??
            'Concept: Action order follows the next seat clockwise.';
      case 1:
        return 'Concept: Button closes late position before the blinds begin.';
      case 2:
        return 'Concept: After Button, the blind pair begins.';
      default:
        return 'Concept: Action order depends on seat order.';
    }
  }

  String _actionLiteracyWhyLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Why it matters: Action labels only help if you know who acts next.';
      case 1:
        return 'Why it matters: Mixing up Cutoff and Button breaks the action chain.';
      case 2:
        return 'Why it matters: The blinds start immediately after Button in seat order.';
      default:
        return 'Why it matters: Position tells you who should act first.';
    }
  }

  String _actionLiteracyFocusLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Notice: Read one seat clockwise and lock the next actor.';
      case 1:
        return 'Notice: Button comes after Cutoff in late-position order.';
      case 2:
        return 'Notice: Small Blind is the first seat after Button.';
      default:
        return 'Notice: Find who acts next before you tap.';
    }
  }

  String _actionLiteracyCompactSupportLineV1() {
    final momentumCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
      widget.moduleId,
    );
    if (_stepIndex == 0 && momentumCopy != null) {
      return momentumCopy.supportLine;
    }
    return '${_actionLiteracyWhyLineV1()} ${_actionLiteracyFocusLineV1()}';
  }

  String _actionLiteracySceneLanePromptLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Find the next player one seat clockwise.';
      case 1:
        return 'Button comes after Cutoff.';
      case 2:
        return 'Small Blind acts right after Button.';
      default:
        return 'Find who acts next before you tap.';
    }
  }

  String _actionLiteracyMismatchWhyLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Why: Start from the current seat, then move one seat clockwise to the next player.';
      case 1:
        return 'Why: Button follows Cutoff before the blind seats begin.';
      case 2:
        return 'Why: Small Blind is the first blind seat after Button.';
      default:
        return 'Why: The next actor comes from seat order, not the brightest ring.';
    }
  }

  String _actionLiteracyMismatchFixLineV1() {
    return resolveWorld1SeatQuizMismatchFixLineV1(
      slice: World1SeatQuizFeedbackSliceV1.actionLiteracy,
      stepIndex: _stepIndex,
    );
  }

  String _actionLiteracyReinforceLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Reinforce: Find the starting seat, then move one seat clockwise.';
      case 1:
        return 'Reinforce: Late position closes with Button before action reaches the blinds.';
      case 2:
        return 'Reinforce: After Button, Small Blind starts the blind pair.';
      default:
        return 'Reinforce: Seat order tells you the next actor.';
    }
  }

  String _actionLiteracyPlacementPreviewTextV1() {
    return [
      _actionLiteracySetupLineV1(),
      _actionLiteracyCompactSupportLineV1(),
    ].join('\n');
  }

  String _streetFlowSetupLineV1() {
    final momentumCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
      widget.moduleId,
    );
    switch (_stepIndex) {
      case 0:
        return momentumCopy?.setupLine ??
            'Concept: Street changes still use the same table order.';
      case 1:
        return 'Concept: Big Blind keeps preflop orientation stable.';
      case 2:
        return 'Concept: After the blind pair, action returns to the next live seat.';
      default:
        return 'Concept: Street flow still depends on stable table order.';
    }
  }

  String _streetFlowWhyLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Why it matters: Street names are easier when the table order stays clear.';
      case 1:
        return 'Why it matters: Big Blind is the last blind reference before later streets.';
      case 2:
        return 'Why it matters: Street changes do not erase who acts next in seat order.';
      default:
        return 'Why it matters: Street flow only sticks if the seat map stays clear.';
    }
  }

  String _streetFlowFocusLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Notice: Start from Button before you think about the next street.';
      case 1:
        return 'Notice: Big Blind finishes the blind pair before the action moves on.';
      case 2:
        return 'Notice: With early seats empty here, Hijack is the next live seat to track.';
      default:
        return 'Notice: Keep the same seat order while the street changes.';
    }
  }

  String _streetFlowCompactSupportLineV1() {
    final momentumCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
      widget.moduleId,
    );
    if (_stepIndex == 0 && momentumCopy != null) {
      return momentumCopy.supportLine;
    }
    return '${_streetFlowWhyLineV1()} ${_streetFlowFocusLineV1()}';
  }

  String _streetFlowMismatchWhyLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Why: Button is the clearest place to start before the street changes.';
      case 1:
        return 'Why: Big Blind completes the blind pair and locks the preflop reference.';
      case 2:
        return 'Why: Once the blind pair is set, move to the next live seat in order.';
      default:
        return 'Why: Keep the same seat map even as the street changes.';
    }
  }

  String _streetFlowMismatchFixLineV1() {
    return resolveWorld1SeatQuizMismatchFixLineV1(
      slice: World1SeatQuizFeedbackSliceV1.streetFlow,
      stepIndex: _stepIndex,
    );
  }

  String _streetFlowReinforceLineV1() {
    switch (_stepIndex) {
      case 0:
        return 'Reinforce: Read the table first, then read the street.';
      case 1:
        return 'Reinforce: Big Blind closes the blind pair before later street flow starts.';
      case 2:
        return 'Reinforce: After the blinds, move to the next live seat in order.';
      default:
        return 'Reinforce: Street flow stays easier when the seat map stays stable.';
    }
  }

  String _streetFlowPlacementPreviewTextV1() {
    return [
      _streetFlowSetupLineV1(),
      _streetFlowCompactSupportLineV1(),
    ].join('\n');
  }

  String _conceptFirstSeatMismatchWhyLineV1() {
    final expected = _seatQuizExpectedSeatIdsV1.toList(growable: false);
    final seatLabel = expected.isEmpty
        ? 'the highlighted seat'
        : _seatQuizSeatDisplayV1(expected.first);
    if (expected.isNotEmpty && expected.first == 'sb') {
      return 'Why: $seatLabel is the first blind seat after Button.';
    }
    if (expected.isNotEmpty && expected.first == 'bb') {
      return 'Why: $seatLabel is the second blind, next to Small Blind.';
    }
    return 'Why: $seatLabel shows where the rest of the table starts.';
  }

  String _conceptFirstSeatMismatchFixLineV1() {
    return resolveWorld1SeatQuizMismatchFixLineV1(
      slice: World1SeatQuizFeedbackSliceV1.conceptFirstSeat,
      stepIndex: _stepIndex,
      expectedSeatId: _seatQuizExpectedSeatIdsV1.isEmpty
          ? null
          : _seatQuizExpectedSeatIdsV1.first,
    );
  }

  String _seatQuizMismatchFixLineV1() {
    if (_isConceptFirstSeatMicroSliceV1)
      return _conceptFirstSeatMismatchFixLineV1();
    if (_isActionLiteracyMicroSliceV1)
      return _actionLiteracyMismatchFixLineV1();
    if (_isStreetFlowMicroSliceV1) return _streetFlowMismatchFixLineV1();
    return _conceptFirstSeatMismatchFixLineV1();
  }

  String _seatQuizExpectedChosenFeedbackLineV1({
    required String expectedLabel,
    required String chosenLabel,
  }) {
    return buildWorld1SeatQuizExpectedChosenFeedbackLineV1(
      expectedLabel: expectedLabel,
      chosenLabel: chosenLabel,
      fixLine: _seatQuizMismatchFixLineV1(),
    );
  }

  String _conceptFirstSeatReinforceLineV1() {
    final expected = _seatQuizExpectedSeatIdsV1.toList(growable: false);
    final seatLabel = expected.isEmpty
        ? 'the highlighted seat'
        : _seatQuizSeatDisplayV1(expected.first);
    if (expected.isNotEmpty && expected.first == 'btn') {
      return 'Reinforce: Start from Button, then read the table clockwise.';
    }
    if (expected.isNotEmpty && expected.first == 'sb') {
      return 'Reinforce: Button, then $seatLabel, starts the blind pair.';
    }
    if (expected.isNotEmpty && expected.first == 'bb') {
      return 'Reinforce: Button, Small Blind, then $seatLabel keeps blind order clear.';
    }
    return 'Reinforce: Start from $seatLabel, then continue clockwise.';
  }

  String _conceptFirstSeatPlacementPreviewTextV1() {
    return [
      _conceptFirstSeatSetupLineV1(),
      _conceptFirstSeatCompactSupportLineV1(),
    ].join('\n');
  }

  Widget _buildConceptFirstSeatPreludeCardV1({
    bool compact = false,
    bool embedded = false,
  }) {
    return Container(
      key: const Key('concept_first_seat_prelude_card_v1'),
      width: double.infinity,
      margin: embedded
          ? EdgeInsets.zero
          : EdgeInsets.only(top: compact ? 2 : 4, bottom: compact ? 2 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: embedded ? 0 : (compact ? 6 : AppSpacing.sm),
        vertical: embedded ? 0 : (compact ? 3 : AppSpacing.xs),
      ),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(
          embedded ? 0 : SharkyTokensV1.radiusMd,
        ),
        border: embedded
            ? null
            : Border.all(color: SharkyTokensV1.semanticInfo.withOpacity(0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _conceptFirstSeatSetupLineV1(),
            key: const Key('concept_first_seat_setup_v1'),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.clip,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.0 : null,
            ),
          ),
          SizedBox(height: compact ? 2 : 6),
          Container(
            key: const Key('concept_first_seat_support_surface_v1'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 8,
              vertical: compact ? 3 : 6,
            ),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceCard.withOpacity(
                compact ? 0.46 : 0.5,
              ),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
              border: Border.all(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.22),
              ),
            ),
            child: Text(
              _conceptFirstSeatCompactSupportLineV1(),
              key: const Key('concept_first_seat_support_v1'),
              softWrap: true,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 9.85 : null,
                height: compact ? 1.18 : 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLiteracyPreludeCardV1({
    bool compact = false,
    bool embedded = false,
  }) {
    return Container(
      key: const Key('action_literacy_prelude_card_v1'),
      width: double.infinity,
      margin: embedded
          ? EdgeInsets.zero
          : EdgeInsets.only(top: compact ? 2 : 4, bottom: compact ? 2 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: embedded ? 0 : (compact ? 6 : AppSpacing.sm),
        vertical: embedded ? 0 : (compact ? 3 : AppSpacing.xs),
      ),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(
          embedded ? 0 : SharkyTokensV1.radiusMd,
        ),
        border: embedded
            ? null
            : Border.all(color: SharkyTokensV1.semanticInfo.withOpacity(0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _actionLiteracySetupLineV1(),
            key: const Key('action_literacy_setup_v1'),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.clip,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.0 : null,
            ),
          ),
          SizedBox(height: compact ? 2 : 6),
          Container(
            key: const Key('action_literacy_support_surface_v1'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 8,
              vertical: compact ? 3 : 6,
            ),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceCard.withOpacity(
                compact ? 0.46 : 0.5,
              ),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
              border: Border.all(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.22),
              ),
            ),
            child: Text(
              _actionLiteracyCompactSupportLineV1(),
              key: const Key('action_literacy_support_v1'),
              softWrap: true,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 9.85 : null,
                height: compact ? 1.18 : 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreetFlowPreludeCardV1({
    bool compact = false,
    bool embedded = false,
  }) {
    return Container(
      key: const Key('street_flow_prelude_card_v1'),
      width: double.infinity,
      margin: embedded
          ? EdgeInsets.zero
          : EdgeInsets.only(top: compact ? 2 : 4, bottom: compact ? 2 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: embedded ? 0 : (compact ? 6 : AppSpacing.sm),
        vertical: embedded ? 0 : (compact ? 3 : AppSpacing.xs),
      ),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(
          embedded ? 0 : SharkyTokensV1.radiusMd,
        ),
        border: embedded
            ? null
            : Border.all(color: SharkyTokensV1.semanticInfo.withOpacity(0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _streetFlowSetupLineV1(),
            key: const Key('street_flow_setup_v1'),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.clip,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.0 : null,
            ),
          ),
          SizedBox(height: compact ? 2 : 6),
          Container(
            key: const Key('street_flow_support_surface_v1'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 8,
              vertical: compact ? 3 : 6,
            ),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceCard.withOpacity(
                compact ? 0.46 : 0.5,
              ),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
              border: Border.all(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.22),
              ),
            ),
            child: Text(
              _streetFlowCompactSupportLineV1(),
              key: const Key('street_flow_support_v1'),
              softWrap: true,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 9.85 : null,
                height: compact ? 1.18 : 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _goldLearningLiteracyWhyLineV1() {
    if (!_isGoldLearningLiteracySliceStepV1) {
      return null;
    }
    final tradeoff = _step.tradeoffText?.trim() ?? '';
    if (tradeoff.isNotEmpty) {
      return _truncateForOutcome('Why it matters: $tradeoff', 102);
    }
    return 'Why it matters: Guessing here leaks chips over time.';
  }

  String? _goldLearningSliceReinforceLineV1() {
    if (!_isGoldLearningClusterStepV1) {
      return null;
    }
    if (!_goldLearningClusterReinforceStepIndexesV1.contains(_stepIndex)) {
      return null;
    }
    final insight = _step.insightText?.trim() ?? '';
    if (insight.isEmpty) {
      return 'Reinforce: Read to-call first, then choose action.';
    }
    return _truncateForOutcome('Reinforce: $insight', 88);
  }

  bool get _guidedSeatsActive {
    if (_guidedConsumedSteps.contains(_stepIndex)) return false;
    return _step.guidedScope == 'seats';
  }

  bool get _awaitingSeatInput =>
      _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz &&
      _selectedSeatId == null &&
      !_completionInProgress;

  BoxDecoration _consequenceCardDecoration() {
    final baseBorder = _pulseBust
        ? SharkyTokensV1.semanticLoss.withOpacity(0.86)
        : _pulseSuccess
        ? SharkyTokensV1.semanticWin.withOpacity(0.8)
        : (_pulseFailure
              ? SharkyTokensV1.semanticLoss.withOpacity(0.64)
              : SharkyTokensV1.slate600.withOpacity(0.66));
    return BoxDecoration(
      color: SharkyTokensV1.surfaceCard.withOpacity(0.66),
      borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
      border: Border.all(color: baseBorder, width: _pulseBust ? 1.8 : 1.2),
      boxShadow: [
        BoxShadow(
          color:
              (_pulseSuccess
                      ? SharkyTokensV1.semanticWin
                      : (_pulseFailure || _pulseBust
                            ? SharkyTokensV1.semanticLoss
                            : SharkyTokensV1.brandPrimary))
                  .withOpacity(0.14),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _firstSessionSeenInLaunchV1 = true;
    _settingsListener = _onSettingsChanged;
    AppSettingsService.instance.changes.addListener(_settingsListener!);
    unawaited(_loadEngineV2BackendSetting());
    _sessionStartedAt = DateTime.now().toUtc();
    _decisionStartedAt = _sessionStartedAt;
    _resetDebugDecisionLatencyV1();
    final resolvedHostLaunchV1 =
        widget.resolvedHostLaunchV1 ??
        (() {
          final entryInput = World1CanonicalHostStateEntryInputV1(
            moduleId: widget.moduleId,
            explicitMode: widget.mode,
            isCheckpoint: widget.isCheckpoint,
            isDailyRun: widget.isDailyRun,
            isTablePractice: widget.isTablePracticeV1,
            startHandIndex: widget.startHandIndex,
            isGlobalCheckpointPack: _isGlobalCheckpointPackV1,
            checkpointSteps: widget.isCheckpoint
                ? kWorld1CheckpointTaskPacks[widget.checkpointId] ??
                      const <MicroTaskStep>[]
                : const <MicroTaskStep>[],
            packSteps: widget.isCheckpoint
                ? const <MicroTaskStep>[]
                : world1MicroTaskPackFor(widget.moduleId),
            fallbackSteps: const <MicroTaskStep>[
              MicroTaskStep(
                prompt: 'Find the Button seat.',
                hint: 'Dealer button is bottom center.',
                expectedSeatIds: <String>['btn'],
              ),
              MicroTaskStep(
                prompt: 'Find the Big Blind seat.',
                hint: 'Tap the right-lower blind seat.',
                expectedSeatIds: <String>['bb'],
              ),
              MicroTaskStep(
                prompt: 'Move past the empty spots and tap Hijack.',
                hint: 'Ignore the empty seats and continue to Hijack.',
                expectedSeatIds: <String>['hj'],
              ),
            ],
            campaignSpineModeId: kWorld1RunnerModeCampaignSpine,
            reviewQueueModeId: kWorld1RunnerModeReviewQueue,
            checkpointModeId: kWorld1RunnerModeCheckpoint,
            dailyRunModeId: kWorld1RunnerModeDailyRun,
            tablePracticeModeId: kWorld1RunnerModeTablePractice,
            defaultModeId: kWorld1RunnerModeFoundationsCheck,
          );
          final entryStateV1 = resolveWorld1CanonicalHostStateEntryV1(
            entryInput,
          );
          return World1CanonicalResolvedHostLaunchV1(
            mode: entryStateV1.mode,
            learningEffectSliceMarker: world1LearningEffectSliceMarkerV1(
              moduleId: widget.moduleId,
              mode: entryStateV1.mode,
            ),
            steps: entryStateV1.steps,
            initialStepIndex: entryStateV1.initialStepIndex,
            shouldApplyCheckpointSeed: entryStateV1.shouldApplyCheckpointSeed,
            shouldBootstrapCampaignState:
                entryStateV1.shouldBootstrapCampaignState,
            shouldBootstrapIntroPreludes:
                entryStateV1.shouldBootstrapIntroPreludes,
            shouldBootstrapReviewQueue: entryStateV1.shouldBootstrapReviewQueue,
          );
        })();
    _mode = resolvedHostLaunchV1.mode;
    _learningEffectSliceMarkerV1 =
        resolvedHostLaunchV1.learningEffectSliceMarker;
    _steps = resolvedHostLaunchV1.steps;
    _stepIndex = resolvedHostLaunchV1.initialStepIndex;
    if (resolvedHostLaunchV1.shouldApplyCheckpointSeed) {
      unawaited(_applyCheckpointSeedV1());
    }
    if (resolvedHostLaunchV1.shouldBootstrapCampaignState) {
      unawaited(_bootstrapCampaignState());
    }
    if (resolvedHostLaunchV1.shouldBootstrapIntroPreludes) {
      unawaited(_bootstrapIntroPreludesV1());
    } else if (resolvedHostLaunchV1.shouldBootstrapReviewQueue) {
      unawaited(_bootstrapReviewQueueSessionV1());
    }
    _emitTelemetry('session_start', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
    });
    if (!debugDisableRunnerSessionStartEmotionHooksV1) {
      unawaited(_loadBeforeSessionPhraseV1());
      unawaited(_emitSessionStartEmotionPhraseV1());
    }
    _scheduleDebugBootstrapIfNeededV1();
    _attachHostShellControllerV1(widget.hostShellControllerV1);
  }

  MicroTaskStep _stepWithCheckpointCueV1(MicroTaskStep source) {
    return MicroTaskStep(
      prompt: source.prompt,
      hint: source.hint,
      expectedSeatIds: List<String>.from(source.expectedSeatIds),
      contextText: source.contextText,
      tradeoffText: source.tradeoffText,
      consequenceText: source.consequenceText,
      insightText: source.insightText,
      instructionText: _checkpointReviewCueTextV1,
      goalText: source.goalText,
      guidedScope: source.guidedScope,
      isoGroup: source.isoGroup,
      heroSeatId: source.heroSeatId,
      street: source.street,
      boardCards: source.boardCards == null
          ? null
          : List<String>.from(source.boardCards!),
      heroCards: source.heroCards == null
          ? null
          : List<String>.from(source.heroCards!),
      pot: source.pot,
      toCall: source.toCall,
      allowedActions: source.allowedActions == null
          ? null
          : List<String>.from(source.allowedActions!),
      expectedActionKind: source.expectedActionKind,
    );
  }

  Future<void> _applyCheckpointSeedV1() async {
    final resolved = await bootstrapWorld1CheckpointSeedV1(
      steps: _steps,
      stepIndex: _stepIndex,
      checkpointPackId: ProgressService.checkpointPackIdV1,
      checkpointCueMapper: _stepWithCheckpointCueV1,
    );
    if (!mounted || resolved == null) return;
    setState(() {
      _steps = resolved.steps;
      _checkpointSeedTopErrorClassesV1 = resolved.topErrorClasses;
      _checkpointStepErrorClassesV1 = resolved.stepErrorClasses;
      _stepIndex = resolved.stepIndex;
    });
  }

  @override
  void didUpdateWidget(
    covariant World1FoundationsMicroTaskRunnerScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hostShellControllerV1 != widget.hostShellControllerV1) {
      _detachHostShellControllerV1(oldWidget.hostShellControllerV1);
      _attachHostShellControllerV1(widget.hostShellControllerV1);
    }
  }

  void _attachHostShellControllerV1(
    World1CanonicalHostShellControllerV1? controller,
  ) {
    if (controller == null) return;
    _appliedHostShellSignalGenerationV1 = controller.value.generation;
    controller.addListener(_onCanonicalHostShellSignalChangedV1);
  }

  void _detachHostShellControllerV1(
    World1CanonicalHostShellControllerV1? controller,
  ) {
    controller?.removeListener(_onCanonicalHostShellSignalChangedV1);
  }

  void _onCanonicalHostShellSignalChangedV1() {
    final signal = widget.hostShellControllerV1?.value;
    if (signal == null ||
        signal.generation == _appliedHostShellSignalGenerationV1) {
      return;
    }
    _appliedHostShellSignalGenerationV1 = signal.generation;
    if (!_isCampaignSpineSession ||
        !_outcomeSurfaceVisible ||
        !signal.shouldResetOutcomeSurface) {
      return;
    }
    _resultAutoContinueTimer?.cancel();
    _resultAutoContinueTimer = null;
    if (!mounted) return;
    setState(() {
      _outcomeSurfaceVisible = false;
      _outcomeLines = const <String>[];
      _pendingContinueAction = null;
      _resultContinueBusy = false;
    });
  }

  void _scheduleDebugBootstrapIfNeededV1() {
    if (!kDebugMode ||
        widget.debugBootstrapStateV1 == null ||
        _debugBootstrapAppliedV1) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_applyDebugBootstrapStateV1());
    });
  }

  Future<void> _applyDebugBootstrapStateV1() async {
    if (!kDebugMode ||
        !mounted ||
        widget.debugBootstrapStateV1 == null ||
        _debugBootstrapAppliedV1) {
      return;
    }
    switch (widget.debugBootstrapStateV1!) {
      case RunnerDebugBootstrapStateV1.outcomeIncorrectRange:
        if (!_isCampaignSpineSession ||
            _currentCampaignRunnerMode != _CampaignRunnerMode.handLoop ||
            _outcomeSurfaceVisible) {
          return;
        }
        _debugBootstrapAppliedV1 = true;
        await _runCampaignHandLoopFromLockIn(
          heroActionOverride: const ActionV1(
            actorId: PlayerIdV1('hero'),
            kind: ActionKindV1.fold,
          ),
        );
        return;
      case RunnerDebugBootstrapStateV1.demoDecisionHeroSb:
        if (_mode != kWorld1RunnerModeDemoHandLoopV1 ||
            widget.moduleId != 'season1_demo_multistreet_v1' ||
            _steps.length < 2) {
          return;
        }
        _debugBootstrapAppliedV1 = true;
        if (!mounted) return;
        setState(() {
          _stepIndex = 1;
          _selectedSeatId = null;
          _showHint = true;
          _feedback = '';
          _decisionStartedAt = DateTime.now().toUtc();
          _resetDebugDecisionLatencyV1();
        });
        return;
      case RunnerDebugBootstrapStateV1.demoDecisionHeroBb:
        if (_mode != kWorld1RunnerModeDemoHandLoopV1 ||
            widget.moduleId != 'season1_demo_multistreet_v1' ||
            _steps.length < 3) {
          return;
        }
        _debugBootstrapAppliedV1 = true;
        if (!mounted) return;
        setState(() {
          _stepIndex = 2;
          _selectedSeatId = null;
          _showHint = true;
          _feedback = '';
          _decisionStartedAt = DateTime.now().toUtc();
          _resetDebugDecisionLatencyV1();
        });
        return;
    }
  }

  Future<void> _bootstrapReviewQueueSessionV1() async {
    final packId = widget.moduleId.trim().toLowerCase();
    if (packId.isEmpty) return;
    final resolved = await bootstrapWorld1ReviewQueueSessionV1(
      packId: packId,
      stepCount: _steps.length,
    );
    if (!mounted) return;
    if (resolved.shouldPop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).maybePop(false);
      });
      return;
    }
    setState(() {
      _reviewQueueSet
        ..clear()
        ..addAll(resolved.queuedStepIndices);
      _reviewQueueStepIndices
        ..clear()
        ..addAll(resolved.queuedStepIndices);
      _reviewQueueLaunchCountV1 = resolved.queuedStepIndices.length;
      _applyReviewPassCursorStateFieldsV1(
        cursor: 0,
        feedback: resolved.feedback,
      );
    });
    if (!_reviewQueueStartedTelemetrySentV1) {
      _reviewQueueStartedTelemetrySentV1 = true;
      _emitTelemetry(TelemetryEvents.reviewQueueStartedV1, <String, dynamic>{
        'packId': packId,
        'reviewed_count': resolved.queuedStepIndices.length,
        'source': 'runner',
      });
    }
  }

  Future<void> _bootstrapCampaignState() async {
    final resolved = await bootstrapWorld1CampaignStateV1(
      moduleId: widget.moduleId,
      stepIndex: _stepIndex,
      stepCount: _steps.length,
      shouldBootstrapCampaignProgress: _isCampaignSpinePackId(
        widget.moduleId.trim().toLowerCase(),
      ),
      startRun: _campaignSpineRunner.startRun,
    );
    if (!mounted) return;
    setState(() {
      _stepIndex = resolved.stepIndex;
      _spineBankroll = resolved.bankroll;
      _spineRank = resolved.rank;
      _spineCalibrationBand = resolved.calibrationBand;
    });
    _emitTelemetry(TelemetryEvents.campaignPackStart, <String, dynamic>{
      'pack_id': widget.moduleId,
      'start_hand_index': _stepIndex,
      'bankroll': _spineBankroll,
      'rank': _spineRank,
      'calibration_completed': resolved.calibrationCompleted,
    });
    _scheduleDebugBootstrapIfNeededV1();
  }

  Future<void> _bootstrapWorld2IntroPreludeV1() async {
    if (!_isWorld2SpineCampaignEntryV1) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_world2IntroSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_world2IntroSeenKeyV1, true);
    if (!mounted) return;
    setState(() {
      _world2IntroPreludePendingV1 = true;
    });
  }

  Future<void> _bootstrapWorld2HandoffPreludeV1() async {
    if (!_isWorld2SpineCampaignEntryV1) return;
    final prefs = await SharedPreferences.getInstance();
    final world2IntroSeen = prefs.getBool(_world2IntroSeenKeyV1) ?? false;
    if (world2IntroSeen) return;
    final seen = prefs.getBool(_world2HandoffSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_world2HandoffSeenKeyV1, true);
    if (!mounted) return;
    setState(() {
      _world2HandoffPreludePendingV1 = true;
    });
  }

  Future<void> _bootstrapWorld1IntroPreludeV1() async {
    if (!_isWorld1FirstUserOnboardingTargetV1) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_world1IntroSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_world1IntroSeenKeyV1, true);
    if (!mounted) return;
    setState(() {
      _world1IntroPreludePendingV1 = true;
    });
  }

  Future<void> _bootstrapWorld1ActionIntroPreludeV1() async {
    if (!_isWorld1ActionLiteracyContinuityTargetV1) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_world1ActionIntroSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_world1ActionIntroSeenKeyV1, true);
  }

  Future<void> _bootstrapWorld1StreetFlowIntroPreludeV1() async {
    if (!_isWorld1StreetFlowContinuityTargetV1) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_world1StreetFlowIntroSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_world1StreetFlowIntroSeenKeyV1, true);
  }

  Future<void> _bootstrapGlobalTrainingIntroPreludeV1() async {
    if (!_isWorld1SpineCampaignEntryV1) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_globalTrainingIntroSeenKeyV1) ?? false;
    if (seen) return;
    await prefs.setBool(_globalTrainingIntroSeenKeyV1, true);
    if (!mounted) return;
    setState(() {
      _globalTrainingIntroPreludePendingV1 = true;
    });
  }

  String? _trackIntroSeenKeyForKindV1(String? trackKind) {
    return switch (trackKind) {
      'cash' => _cashTrackIntroSeenKeyV1,
      'tournament' => _tournamentTrackIntroSeenKeyV1,
      'mixed' => _mixedTrackIntroSeenKeyV1,
      _ => null,
    };
  }

  Future<void> _bootstrapTrackIntroPreludeV1() async {
    if (!_isCampaignSpineSession) return;
    final trackKind = _world10TrackKindForPackIdV1(widget.moduleId);
    final seenKey = _trackIntroSeenKeyForKindV1(trackKind);
    if (trackKind == null || seenKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(seenKey) ?? false;
    if (seen) return;
    await prefs.setBool(seenKey, true);
    if (!mounted) return;
    setState(() {
      _trackIntroKindV1 = trackKind;
      _trackIntroPreludePendingV1 = true;
    });
  }

  Future<void> _bootstrapIntroPreludesV1() async {
    await _bootstrapGlobalTrainingIntroPreludeV1();
    await _bootstrapWorld1IntroPreludeV1();
    await _bootstrapWorld1ActionIntroPreludeV1();
    await _bootstrapWorld1StreetFlowIntroPreludeV1();
    await _bootstrapWorld2HandoffPreludeV1();
    await _bootstrapWorld2IntroPreludeV1();
    await _bootstrapTrackIntroPreludeV1();
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowHighestPriorityPreludeV1() {
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1) {
      _maybeShowGlobalTrainingIntroPreludeV1();
      return;
    }
    if (_world1IntroPreludePendingV1 || _showWorld1IntroPreludeV1) {
      _maybeShowWorld1IntroPreludeV1();
      return;
    }
    if (_world1ActionIntroPreludePendingV1 || _showWorld1ActionIntroPreludeV1) {
      _maybeShowWorld1ActionIntroPreludeV1();
      return;
    }
    if (_world1StreetFlowIntroPreludePendingV1 ||
        _showWorld1StreetFlowIntroPreludeV1) {
      _maybeShowWorld1StreetFlowIntroPreludeV1();
      return;
    }
    if (_world2HandoffPreludePendingV1 || _showWorld2HandoffPreludeV1) {
      _maybeShowWorld2HandoffPreludeV1();
      return;
    }
    if (_world2IntroPreludePendingV1 || _showWorld2IntroPreludeV1) {
      _maybeShowWorld2IntroPreludeV1();
      return;
    }
    if (_trackIntroPreludePendingV1 || _showTrackIntroPreludeV1) {
      _maybeShowTrackIntroPreludeV1();
    }
  }

  void _maybeShowGlobalTrainingIntroPreludeV1() {
    if (!_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1) {
      return;
    }
    if (_outcomeSurfaceVisible || _completionInProgress) {
      return;
    }
    _globalTrainingIntroPreludeTimerV1?.cancel();
    _globalTrainingIntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showGlobalTrainingIntroPreludeV1 = true;
      _globalTrainingIntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _globalTrainingIntroPreludeTimerV1 = Timer(
      const Duration(milliseconds: 4000),
      () {
        if (!mounted) return;
        _dismissGlobalTrainingIntroPreludeV1();
      },
    );
  }

  void _requestDismissGlobalTrainingIntroPreludeFromInteractionV1() {
    if (!_showGlobalTrainingIntroPreludeV1) {
      return;
    }
    final shownAt = _globalTrainingIntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissGlobalTrainingIntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissGlobalTrainingIntroPreludeV1();
      return;
    }
    _globalTrainingIntroPreludeMinVisibleTimerV1?.cancel();
    _globalTrainingIntroPreludeMinVisibleTimerV1 = Timer(
      minVisible - elapsed,
      () {
        if (!mounted) return;
        _dismissGlobalTrainingIntroPreludeV1();
      },
    );
  }

  void _dismissGlobalTrainingIntroPreludeV1() {
    _globalTrainingIntroPreludeTimerV1?.cancel();
    _globalTrainingIntroPreludeTimerV1 = null;
    _globalTrainingIntroPreludeMinVisibleTimerV1?.cancel();
    _globalTrainingIntroPreludeMinVisibleTimerV1 = null;
    if (!_showGlobalTrainingIntroPreludeV1 &&
        !_globalTrainingIntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showGlobalTrainingIntroPreludeV1 = false;
      _globalTrainingIntroPreludePendingV1 = false;
      _globalTrainingIntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowTrackIntroPreludeV1() {
    if (!_trackIntroPreludePendingV1 || _showTrackIntroPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1 ||
        _world1IntroPreludePendingV1 ||
        _showWorld1IntroPreludeV1 ||
        _world2HandoffPreludePendingV1 ||
        _showWorld2HandoffPreludeV1 ||
        _world2IntroPreludePendingV1 ||
        _showWorld2IntroPreludeV1) {
      return;
    }
    if (_outcomeSurfaceVisible || _completionInProgress) {
      return;
    }
    _trackIntroPreludeTimerV1?.cancel();
    _trackIntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showTrackIntroPreludeV1 = true;
      _trackIntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _trackIntroPreludeTimerV1 = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      _dismissTrackIntroPreludeV1();
    });
  }

  void _requestDismissTrackIntroPreludeFromInteractionV1() {
    if (!_showTrackIntroPreludeV1) {
      return;
    }
    final shownAt = _trackIntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissTrackIntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissTrackIntroPreludeV1();
      return;
    }
    _trackIntroPreludeMinVisibleTimerV1?.cancel();
    _trackIntroPreludeMinVisibleTimerV1 = Timer(minVisible - elapsed, () {
      if (!mounted) return;
      _dismissTrackIntroPreludeV1();
    });
  }

  void _dismissTrackIntroPreludeV1() {
    _trackIntroPreludeTimerV1?.cancel();
    _trackIntroPreludeTimerV1 = null;
    _trackIntroPreludeMinVisibleTimerV1?.cancel();
    _trackIntroPreludeMinVisibleTimerV1 = null;
    if (!_showTrackIntroPreludeV1 && !_trackIntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showTrackIntroPreludeV1 = false;
      _trackIntroPreludePendingV1 = false;
      _trackIntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowWorld1IntroPreludeV1() {
    if (!_world1IntroPreludePendingV1 || _showWorld1IntroPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1) {
      return;
    }
    if ((_currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz &&
            _currentCampaignRunnerMode != _CampaignRunnerMode.handLoop) ||
        _outcomeSurfaceVisible ||
        _completionInProgress) {
      return;
    }
    _world1IntroPreludeTimerV1?.cancel();
    _world1IntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showWorld1IntroPreludeV1 = true;
      _world1IntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _world1IntroPreludeTimerV1 = Timer(const Duration(milliseconds: 5200), () {
      if (!mounted) return;
      _dismissWorld1IntroPreludeV1();
    });
  }

  void _requestDismissWorld1IntroPreludeFromInteractionV1() {
    if (!_showWorld1IntroPreludeV1) {
      return;
    }
    final shownAt = _world1IntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissWorld1IntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissWorld1IntroPreludeV1();
      return;
    }
    _world1IntroPreludeMinVisibleTimerV1?.cancel();
    _world1IntroPreludeMinVisibleTimerV1 = Timer(minVisible - elapsed, () {
      if (!mounted) return;
      _dismissWorld1IntroPreludeV1();
    });
  }

  void _dismissWorld1IntroPreludeV1() {
    _world1IntroPreludeTimerV1?.cancel();
    _world1IntroPreludeTimerV1 = null;
    _world1IntroPreludeMinVisibleTimerV1?.cancel();
    _world1IntroPreludeMinVisibleTimerV1 = null;
    if (!_showWorld1IntroPreludeV1 && !_world1IntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWorld1IntroPreludeV1 = false;
      _world1IntroPreludePendingV1 = false;
      _world1IntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowWorld1ActionIntroPreludeV1() {
    if (!_world1ActionIntroPreludePendingV1 ||
        _showWorld1ActionIntroPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1 ||
        _world1IntroPreludePendingV1 ||
        _showWorld1IntroPreludeV1) {
      return;
    }
    if (_currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz ||
        _outcomeSurfaceVisible ||
        _completionInProgress) {
      return;
    }
    _world1ActionIntroPreludeTimerV1?.cancel();
    _world1ActionIntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showWorld1ActionIntroPreludeV1 = true;
      _world1ActionIntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _world1ActionIntroPreludeTimerV1 = Timer(
      const Duration(milliseconds: 4200),
      () {
        if (!mounted) return;
        _dismissWorld1ActionIntroPreludeV1();
      },
    );
  }

  void _requestDismissWorld1ActionIntroPreludeFromInteractionV1() {
    if (!_showWorld1ActionIntroPreludeV1) {
      return;
    }
    final shownAt = _world1ActionIntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissWorld1ActionIntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1000);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissWorld1ActionIntroPreludeV1();
      return;
    }
    _world1ActionIntroPreludeMinVisibleTimerV1?.cancel();
    _world1ActionIntroPreludeMinVisibleTimerV1 = Timer(
      minVisible - elapsed,
      () {
        if (!mounted) return;
        _dismissWorld1ActionIntroPreludeV1();
      },
    );
  }

  void _dismissWorld1ActionIntroPreludeV1() {
    _world1ActionIntroPreludeTimerV1?.cancel();
    _world1ActionIntroPreludeTimerV1 = null;
    _world1ActionIntroPreludeMinVisibleTimerV1?.cancel();
    _world1ActionIntroPreludeMinVisibleTimerV1 = null;
    if (!_showWorld1ActionIntroPreludeV1 &&
        !_world1ActionIntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWorld1ActionIntroPreludeV1 = false;
      _world1ActionIntroPreludePendingV1 = false;
      _world1ActionIntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowWorld1StreetFlowIntroPreludeV1() {
    if (!_world1StreetFlowIntroPreludePendingV1 ||
        _showWorld1StreetFlowIntroPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1 ||
        _world1IntroPreludePendingV1 ||
        _showWorld1IntroPreludeV1 ||
        _world1ActionIntroPreludePendingV1 ||
        _showWorld1ActionIntroPreludeV1) {
      return;
    }
    if (_currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz ||
        _outcomeSurfaceVisible ||
        _completionInProgress) {
      return;
    }
    _world1StreetFlowIntroPreludeTimerV1?.cancel();
    _world1StreetFlowIntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showWorld1StreetFlowIntroPreludeV1 = true;
      _world1StreetFlowIntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _world1StreetFlowIntroPreludeTimerV1 = Timer(
      const Duration(milliseconds: 4200),
      () {
        if (!mounted) return;
        _dismissWorld1StreetFlowIntroPreludeV1();
      },
    );
  }

  void _requestDismissWorld1StreetFlowIntroPreludeFromInteractionV1() {
    if (!_showWorld1StreetFlowIntroPreludeV1) {
      return;
    }
    final shownAt = _world1StreetFlowIntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissWorld1StreetFlowIntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1000);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissWorld1StreetFlowIntroPreludeV1();
      return;
    }
    _world1StreetFlowIntroPreludeMinVisibleTimerV1?.cancel();
    _world1StreetFlowIntroPreludeMinVisibleTimerV1 = Timer(
      minVisible - elapsed,
      () {
        if (!mounted) return;
        _dismissWorld1StreetFlowIntroPreludeV1();
      },
    );
  }

  void _dismissWorld1StreetFlowIntroPreludeV1() {
    _world1StreetFlowIntroPreludeTimerV1?.cancel();
    _world1StreetFlowIntroPreludeTimerV1 = null;
    _world1StreetFlowIntroPreludeMinVisibleTimerV1?.cancel();
    _world1StreetFlowIntroPreludeMinVisibleTimerV1 = null;
    if (!_showWorld1StreetFlowIntroPreludeV1 &&
        !_world1StreetFlowIntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWorld1StreetFlowIntroPreludeV1 = false;
      _world1StreetFlowIntroPreludePendingV1 = false;
      _world1StreetFlowIntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _maybeShowWorld2IntroPreludeV1() {
    if (!_world2IntroPreludePendingV1 || _showWorld2IntroPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1 ||
        _world1IntroPreludePendingV1 ||
        _showWorld1IntroPreludeV1 ||
        _world2HandoffPreludePendingV1 ||
        _showWorld2HandoffPreludeV1) {
      return;
    }
    if (_currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz ||
        _outcomeSurfaceVisible ||
        _completionInProgress) {
      return;
    }
    _world2IntroPreludeTimerV1?.cancel();
    _world2IntroPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showWorld2IntroPreludeV1 = true;
      _world2IntroPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _world2IntroPreludeTimerV1 = Timer(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      _dismissWorld2IntroPreludeV1();
    });
  }

  void _maybeShowWorld2HandoffPreludeV1() {
    if (!_world2HandoffPreludePendingV1 || _showWorld2HandoffPreludeV1) {
      return;
    }
    if (_globalTrainingIntroPreludePendingV1 ||
        _showGlobalTrainingIntroPreludeV1 ||
        _world1IntroPreludePendingV1 ||
        _showWorld1IntroPreludeV1) {
      return;
    }
    if (_currentCampaignRunnerMode != _CampaignRunnerMode.seatQuiz ||
        _outcomeSurfaceVisible ||
        _completionInProgress) {
      return;
    }
    _world2HandoffPreludeTimerV1?.cancel();
    _world2HandoffPreludeMinVisibleTimerV1?.cancel();
    setState(() {
      _showWorld2HandoffPreludeV1 = true;
      _world2HandoffPreludeShownAtV1 = DateTime.now().toUtc();
    });
    _world2HandoffPreludeTimerV1 = Timer(
      const Duration(milliseconds: 3500),
      () {
        if (!mounted) return;
        _dismissWorld2HandoffPreludeV1();
      },
    );
  }

  void _requestDismissWorld2HandoffPreludeFromInteractionV1() {
    if (!_showWorld2HandoffPreludeV1) {
      return;
    }
    final shownAt = _world2HandoffPreludeShownAtV1;
    if (shownAt == null) {
      _dismissWorld2HandoffPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissWorld2HandoffPreludeV1();
      return;
    }
    _world2HandoffPreludeMinVisibleTimerV1?.cancel();
    _world2HandoffPreludeMinVisibleTimerV1 = Timer(minVisible - elapsed, () {
      if (!mounted) return;
      _dismissWorld2HandoffPreludeV1();
    });
  }

  void _dismissWorld2HandoffPreludeV1() {
    _world2HandoffPreludeTimerV1?.cancel();
    _world2HandoffPreludeTimerV1 = null;
    _world2HandoffPreludeMinVisibleTimerV1?.cancel();
    _world2HandoffPreludeMinVisibleTimerV1 = null;
    if (!_showWorld2HandoffPreludeV1 && !_world2HandoffPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWorld2HandoffPreludeV1 = false;
      _world2HandoffPreludePendingV1 = false;
      _world2HandoffPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  void _requestDismissWorld2IntroPreludeFromInteractionV1() {
    if (!_showWorld2IntroPreludeV1) {
      return;
    }
    final shownAt = _world2IntroPreludeShownAtV1;
    if (shownAt == null) {
      _dismissWorld2IntroPreludeV1();
      return;
    }
    const minVisible = Duration(milliseconds: 1200);
    final elapsed = DateTime.now().toUtc().difference(shownAt);
    if (elapsed >= minVisible) {
      _dismissWorld2IntroPreludeV1();
      return;
    }
    _world2IntroPreludeMinVisibleTimerV1?.cancel();
    _world2IntroPreludeMinVisibleTimerV1 = Timer(minVisible - elapsed, () {
      if (!mounted) return;
      _dismissWorld2IntroPreludeV1();
    });
  }

  void _dismissWorld2IntroPreludeV1() {
    _world2IntroPreludeTimerV1?.cancel();
    _world2IntroPreludeTimerV1 = null;
    _world2IntroPreludeMinVisibleTimerV1?.cancel();
    _world2IntroPreludeMinVisibleTimerV1 = null;
    if (!_showWorld2IntroPreludeV1 && !_world2IntroPreludePendingV1) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _showWorld2IntroPreludeV1 = false;
      _world2IntroPreludePendingV1 = false;
      _world2IntroPreludeShownAtV1 = null;
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  @override
  void dispose() {
    _detachHostShellControllerV1(widget.hostShellControllerV1);
    if (_settingsListener != null) {
      AppSettingsService.instance.changes.removeListener(_settingsListener!);
      _settingsListener = null;
    }
    if (!_sessionTerminalEventSent) {
      _sessionTerminalEventSent = true;
      _emitTelemetry('session_abort', <String, dynamic>{
        'module_id': widget.moduleId,
        'mode': _mode,
        'duration_ms': _elapsedMs(_sessionStartedAt),
      });
    }
    _successPulseTimer?.cancel();
    _failurePulseTimer?.cancel();
    _failureShakeTimer?.cancel();
    _bustPulseTimer?.cancel();
    _successBadgeTimer?.cancel();
    _dailyCompletedBadgeTimer?.cancel();
    _checkpointCompleteTimer?.cancel();
    _loopRewardBannerTimer?.cancel();
    _completionNavigateTimer?.cancel();
    _resultAutoContinueTimer?.cancel();
    _globalTrainingIntroPreludeTimerV1?.cancel();
    _globalTrainingIntroPreludeMinVisibleTimerV1?.cancel();
    _world1IntroPreludeTimerV1?.cancel();
    _world1IntroPreludeMinVisibleTimerV1?.cancel();
    _world1ActionIntroPreludeTimerV1?.cancel();
    _world1ActionIntroPreludeMinVisibleTimerV1?.cancel();
    _world1StreetFlowIntroPreludeTimerV1?.cancel();
    _world1StreetFlowIntroPreludeMinVisibleTimerV1?.cancel();
    _world2HandoffPreludeTimerV1?.cancel();
    _world2HandoffPreludeMinVisibleTimerV1?.cancel();
    _world2IntroPreludeTimerV1?.cancel();
    _world2IntroPreludeMinVisibleTimerV1?.cancel();
    _trackIntroPreludeTimerV1?.cancel();
    _trackIntroPreludeMinVisibleTimerV1?.cancel();
    _engineV2StreetReplayTimer?.cancel();
    _engineV2PotPulseTimer?.cancel();
    super.dispose();
  }

  void _emitTelemetry(String name, Map<String, dynamic> payload) {
    _sessionTelemetrySamplesV1.add(
      World1TelemetrySampleV1(
        name: name,
        payload: Map<String, Object?>.from(payload),
      ),
    );
    unawaited(Telemetry.logEvent(name, payload));
  }

  Future<PersonalizedRecommendationV1?> _buildPersonalizationResultV1({
    OutcomeSummaryV1? outcomeSummary,
  }) async {
    await RecentActivitySignalStoreV1.instance.appendSignals(
      _sessionTelemetrySamplesV1
          .map(
            (sample) => RecentTelemetrySignalV1(
              name: sample.name,
              payload: sample.payload,
            ),
          )
          .toList(growable: false),
    );
    final recentSignals = await RecentActivitySignalStoreV1.instance
        .loadSignals();
    return RecentActivityPersonalizationV1.infer(
      RecentActivityPersonalizationInputV1(
        signals: recentSignals,
        isCampaignSession: _isCampaignSpineSession,
        latestOutcomeSummary: outcomeSummary,
      ),
    );
  }

  void _emitDebugLearningEffectSummaryIfNeededV1() {
    if (!kDebugMode) return;
    if (_learningEffectSliceMarkerV1 != kWorld1LearningEffectSliceIdV1) return;
    final summary = computeWorld1LearningEffectSummaryV1(
      moduleId: widget.moduleId,
      mode: _mode,
      events: _sessionTelemetrySamplesV1,
    );
    if ((summary['total_decisions'] as int? ?? 0) <= 0) return;
    debugPrint('[learning_effect_slice_v1] ${jsonEncode(summary)}');
  }

  Future<void> _loadEngineV2BackendSetting() async {
    await AppSettingsService.instance.load();
    if (!mounted) return;
    setState(() {
      _engineV2BackendEnabled =
          AppSettingsService.instance.snapshot.engineV2BackendEnabledV1;
      if (_engineV2BackendEnabled &&
          _engineV2CheckpointEligible &&
          !_engineV2BackendChoiceMadeInSession) {
        _engineV2UseLegacyBackend = false;
      }
    });
  }

  void _onSettingsChanged() {
    final enabled =
        AppSettingsService.instance.snapshot.engineV2BackendEnabledV1;
    if (!mounted || enabled == _engineV2BackendEnabled) return;
    setState(() {
      _engineV2BackendEnabled = enabled;
      if (!enabled) {
        _engineV2UseLegacyBackend = false;
        _engineV2BackendChoiceMadeInSession = false;
        _engineV2CurrentStreet = null;
        _engineV2StepStreet = null;
        _engineV2PotChips = 0;
        _engineV2ToCallChips = 0;
        _engineV2CurrentBetChips = 0;
        _engineV2PotPulse = false;
        _engineV2PlaybackBusy = false;
        _engineV2TurnFeedLines = const <String>[];
      } else if (_engineV2CheckpointEligible &&
          !_engineV2BackendChoiceMadeInSession) {
        _engineV2UseLegacyBackend = false;
      }
    });
  }

  String _truncateForOutcome(String text, int maxChars) {
    final normalized = text.replaceAll('\n', ' ').trim();
    if (normalized.length <= maxChars) {
      return normalized;
    }
    return '${normalized.substring(0, maxChars - 1).trimRight()}...';
  }

  String _classifyOutcomeError({
    required bool isCorrect,
    required String type,
  }) {
    if (isCorrect) return 'none';
    final normalized = type.trim().toLowerCase();
    if (normalized.contains('range')) return 'range';
    if (normalized.contains('size') || normalized.contains('bet'))
      return 'sizing';
    if (normalized.contains('time') || normalized.contains('select'))
      return 'timing';
    return 'logic';
  }

  String? _buildOutcomeFocusLineV1({
    required bool isCorrect,
    required String errorType,
    required String reason,
  }) {
    if (isCorrect || !_isWorld1SpineParityPackV1 || !kDebugMode) {
      return null;
    }
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    final requiredFocusLabel = truth?.requiredFocusLabelV1.trim();
    if (requiredFocusLabel != null && requiredFocusLabel.isNotEmpty) {
      final moduleId = recommendedModuleIdForFocus(
        focusLabel: requiredFocusLabel,
        reviewDue: false,
      );
      final moduleTitle = recommendedModuleTitleForId(moduleId);
      return _truncateForOutcome('Focus: $moduleTitle', 80);
    }
    final focusLabel =
        focusLabelForPhase1Signal(
          errorType: errorType,
          category: reason,
          subreason: reason,
        ) ??
        focusLabelForPhase1Error(errorType) ??
        'range';
    final moduleId = recommendedModuleIdForFocus(
      focusLabel: focusLabel,
      reviewDue: false,
    );
    final moduleTitle = recommendedModuleTitleForId(moduleId);
    return _truncateForOutcome('Focus: $moduleTitle', 80);
  }

  String? _buildOutcomeWhyLineV1({
    required bool isCorrect,
    required String errorType,
    required ActionKindV1? selectedActionKind,
  }) {
    if (isCorrect || !_isWorld1SpineParityPackV1) {
      return null;
    }
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    if (truth != null) {
      return _truncateForOutcome(truth.whyV1, 80);
    }
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
    return _truncateForOutcome(
      world1SpineOutcomeWhyLineV2(
        toCall: toCall,
        selectedActionKind: selectedActionKind,
        errorType: errorType,
        street: _step.street,
        allowedActions: _step.allowedActions,
      ),
      80,
    );
  }

  String _actionKindLabelV1(ActionKindV1 kind) {
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ??
        _step.toCall ??
        0;
    final isPreflop = _step.street == null;
    final canonicalKind = canonicalizeLearnerActionKindV1(
      kind: kind,
      isPreflop: isPreflop,
      toCall: toCall,
    );
    switch (kind) {
      case ActionKindV1.fold:
        return 'FOLD';
      case ActionKindV1.check:
        return 'CHECK';
      case ActionKindV1.call:
        return 'CALL';
      case ActionKindV1.bet:
        if (canonicalKind == ActionKindV1.raise) {
          return world1SpinePreferredRaiseLabelV1(_step.allowedActions);
        }
        return 'BET';
      case ActionKindV1.raise:
        return world1SpinePreferredRaiseLabelV1(_step.allowedActions);
    }
  }

  bool _selectedActionAllowedInStepV1(ActionKindV1 selectedActionKind) {
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ??
        _step.toCall ??
        0;
    final isPreflop = _step.street == null;
    final allowed = (_step.allowedActions ?? const <String>[])
        .map(
          (value) => canonicalizeLearnerActionTokenV1(
            token: value,
            isPreflop: isPreflop,
            toCall: toCall,
          ),
        )
        .where((value) => value.isNotEmpty)
        .toSet();
    if (allowed.isEmpty) {
      return false;
    }
    final canonicalSelectedActionKind = canonicalizeLearnerActionKindV1(
      kind: selectedActionKind,
      isPreflop: isPreflop,
      toCall: toCall,
    );
    switch (canonicalSelectedActionKind) {
      case ActionKindV1.fold:
        return allowed.contains('fold');
      case ActionKindV1.check:
        return allowed.contains('check');
      case ActionKindV1.call:
        return allowed.contains('call');
      case ActionKindV1.bet:
        return allowed.contains('bet');
      case ActionKindV1.raise:
        return allowed.contains('raise') ||
            allowed.contains('raise_to') ||
            allowed.contains('raise_min');
    }
  }

  bool _isExpectedActionMismatchV1({
    required bool isCorrect,
    required ActionKindV1? selectedActionKind,
  }) {
    if (isCorrect || selectedActionKind == null) {
      return false;
    }
    final expectedActionKind = world1SpineExpectedActionKindV1(_step);
    if (expectedActionKind == null ||
        expectedActionKind == selectedActionKind) {
      return false;
    }
    return _selectedActionAllowedInStepV1(selectedActionKind);
  }

  bool _isToCallLegalityMismatchV1({
    required bool isCorrect,
    required ActionKindV1? selectedActionKind,
  }) {
    if (isCorrect || selectedActionKind == null) {
      return false;
    }
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
    if (toCall > 0 &&
        (selectedActionKind == ActionKindV1.check ||
            selectedActionKind == ActionKindV1.bet)) {
      return true;
    }
    if (toCall == 0 && selectedActionKind == ActionKindV1.call) {
      return true;
    }
    return false;
  }

  bool _isUnnecessaryFoldWhenCheckAvailableV1({
    required bool isCorrect,
    required ActionKindV1? selectedActionKind,
  }) {
    if (isCorrect || selectedActionKind != ActionKindV1.fold) {
      return false;
    }
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
    if (toCall != 0) {
      return false;
    }
    return _selectedActionAllowedInStepV1(ActionKindV1.check);
  }

  String? _buildOutcomeBecauseLineV1({
    required bool isCorrect,
    required ActionKindV1? selectedActionKind,
  }) {
    if (_isToCallLegalityMismatchV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    )) {
      final toCall =
          _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
      if (toCall > 0) {
        return 'Because: You must call or fold when facing a bet.';
      }
      return 'Because: You can check when there is nothing to call.';
    }
    if (_isUnnecessaryFoldWhenCheckAvailableV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    )) {
      return 'Because: You can check when there is nothing to call.';
    }
    if (!_isExpectedActionMismatchV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    )) {
      return null;
    }
    final expectedActionKind = world1SpineExpectedActionKindV1(_step);
    if (expectedActionKind == null || selectedActionKind == null) {
      return null;
    }
    final expectedLabel = _actionKindLabelV1(expectedActionKind);
    final selectedLabel = _actionKindLabelV1(selectedActionKind);
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
    final street = _streetLabelForPromptV1(_step.street).toUpperCase();
    return _truncateForOutcome(
      'Because: $selectedLabel is legal, but $expectedLabel is the target in this $street spot (to call ${_unitsToBbDisplayV1(toCall)} BB).',
      120,
    );
  }

  String? _buildOutcomeCorrectLineV1({
    required bool isCorrect,
    required ActionKindV1? selectedActionKind,
  }) {
    if (!isCorrect || !_isWorld1SpineParityPackV1) {
      return null;
    }
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    if (truth != null) {
      return _truncateForOutcome(truth.feedbackCorrectV1, 60);
    }
    final toCall =
        _campaignActionUiStateForCurrentStep()?.actingSeatToCall ?? 0;
    final correct = world1SpineOutcomeCorrectLineV1(
      toCall: toCall,
      selectedActionKind: selectedActionKind,
      street: _step.street,
      allowedActions: _step.allowedActions,
    );
    return _truncateForOutcome(correct, 60);
  }

  String? _buildOutcomeExpectedLineV1({required bool isCorrect}) {
    if (isCorrect || !_isWorld1SpineParityPackV1) {
      return null;
    }
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    final expected = truth == null
        ? world1SpineOutcomeExpectedLineV1(_step)
        : world1ScenarioTruthExpectedLineV1(_step);
    if (expected == null) return null;
    return _truncateForOutcome(expected, 40);
  }

  void _showOutcomeSurfaceProfiledV1({
    required bool isCorrect,
    required String reason,
    required String errorType,
    required String nextHint,
    required Future<void> Function() onContinue,
    required bool continueAdvancesFlow,
    required bool autoContinue,
    ActionKindV1? selectedActionKind,
    SharedLearnerFeedbackExplanationV1? failExplanationV1,
    String? primaryCtaLabel,
    bool? showRetrySecondary,
  }) {
    _markDebugBeforeShowOutcomeV1();
    _showOutcomeSurface(
      isCorrect: isCorrect,
      reason: reason,
      errorType: errorType,
      nextHint: nextHint,
      onContinue: onContinue,
      continueAdvancesFlow: continueAdvancesFlow,
      autoContinue: autoContinue,
      selectedActionKind: selectedActionKind,
      failExplanationV1: failExplanationV1,
      primaryCtaLabel: primaryCtaLabel,
      showRetrySecondary: showRetrySecondary,
    );
    _markDebugAfterShowOutcomeCallV1();
  }

  void _showOutcomeSurface({
    required bool isCorrect,
    required String reason,
    required String errorType,
    required String nextHint,
    required Future<void> Function() onContinue,
    required bool continueAdvancesFlow,
    required bool autoContinue,
    ActionKindV1? selectedActionKind,
    SharedLearnerFeedbackExplanationV1? failExplanationV1,
    String? primaryCtaLabel,
    bool? showRetrySecondary,
  }) {
    if (kDebugMode) {
      _debugShowOutcomeEntryUsV1 = DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch;
    }
    final classification = _classifyOutcomeError(
      isCorrect: isCorrect,
      type: errorType,
    );
    final focusLine = _buildOutcomeFocusLineV1(
      isCorrect: isCorrect,
      errorType: errorType,
      reason: reason,
    );
    final whyLine = _buildOutcomeWhyLineV1(
      isCorrect: isCorrect,
      errorType: errorType,
      selectedActionKind: selectedActionKind,
    );
    final becauseLine = _buildOutcomeBecauseLineV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    );
    final correctLine = _buildOutcomeCorrectLineV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    );
    final expectedLine = _buildOutcomeExpectedLineV1(isCorrect: isCorrect);
    unawaited(
      LearningStatsV1Service.instance.recordDecision(
        isCorrect: isCorrect,
        errorBucket: classification,
      ),
    );
    final isToCallLegalityMismatch = _isToCallLegalityMismatchV1(
      isCorrect: isCorrect,
      selectedActionKind: selectedActionKind,
    );
    final isUnnecessaryFoldWhenCheckAvailable =
        _isUnnecessaryFoldWhenCheckAvailableV1(
          isCorrect: isCorrect,
          selectedActionKind: selectedActionKind,
        );
    if (isToCallLegalityMismatch) {
      unawaited(
        LearningStatsV1Service.instance.incrementToCallLegalityMismatchError(),
      );
    } else if (isUnnecessaryFoldWhenCheckAvailable) {
      unawaited(
        LearningStatsV1Service.instance
            .incrementUnnecessaryFoldWhenCheckAvailableError(),
      );
    } else if (becauseLine != null) {
      unawaited(
        LearningStatsV1Service.instance.incrementExpectedActionMismatchError(),
      );
    }
    final normalizedErrorType = errorType.trim().toLowerCase();
    final scenarioTruth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
    );
    final resolvedFailExplanationV1 = !isCorrect
        ? (failExplanationV1 ??
              tryParseSharedLearnerFeedbackExplanationV1(reason) ??
              tryParseSharedLearnerFeedbackExplanationV1(nextHint))
        : null;
    final outcomePrimaryLine =
        resolvedFailExplanationV1?.headlineText ??
        (!isCorrect && normalizedErrorType == 'expected_seat_mismatch'
            ? 'Incorrect seat.'
            : (correctLine ??
                  (isCorrect
                      ? _world1OutcomeVerdictLineV1(true)
                      : (scenarioTruth?.feedbackIncorrectV1 ??
                            'There is a stronger line here.'))));
    final reinforceLine = isCorrect
        ? _goldLearningSliceReinforceLineV1()
        : null;
    final lines = <String>[
      outcomePrimaryLine,
      if (expectedLine != null && resolvedFailExplanationV1 == null)
        expectedLine,
      if (resolvedFailExplanationV1?.teachingText case final teachingText?)
        teachingText,
      if (focusLine != null) focusLine,
      if (whyLine != null && resolvedFailExplanationV1?.teachingText == null)
        whyLine,
      if (!isCorrect &&
          normalizedErrorType == 'expected_seat_mismatch' &&
          _isConceptFirstSeatMicroSliceV1)
        _truncateForOutcome(_conceptFirstSeatMismatchWhyLineV1(), 86),
      if (!isCorrect &&
          normalizedErrorType == 'expected_seat_mismatch' &&
          _isActionLiteracyMicroSliceV1)
        _truncateForOutcome(_actionLiteracyMismatchWhyLineV1(), 86),
      if (!isCorrect &&
          normalizedErrorType == 'expected_seat_mismatch' &&
          _isStreetFlowMicroSliceV1)
        _truncateForOutcome(_streetFlowMismatchWhyLineV1(), 86),
      if (!isCorrect &&
          normalizedErrorType == 'expected_seat_mismatch' &&
          (_isConceptFirstSeatMicroSliceV1 ||
              _isActionLiteracyMicroSliceV1 ||
              _isStreetFlowMicroSliceV1) &&
          resolvedFailExplanationV1?.guidanceText == null)
        _truncateForOutcome(_seatQuizMismatchFixLineV1(), 86),
      if (becauseLine != null && resolvedFailExplanationV1 == null) becauseLine,
      if (resolvedFailExplanationV1?.guidanceText case final guidanceText?)
        guidanceText,
      _truncateForOutcome(reason, 120),
      if (isCorrect)
        if (reinforceLine != null) reinforceLine,
      if (isCorrect)
        _truncateForOutcome(nextHint, 80)
      else ...<String>[
        _truncateForOutcome(
          _world1OutcomeRetryTeachingLineV1(
            classification: classification,
            normalizedErrorType: normalizedErrorType,
          ),
          80,
        ),
        if (resolvedFailExplanationV1 == null)
          _truncateForOutcome(nextHint, 80),
      ],
    ];
    final outcomeLaneSemanticsV1 = resolveWorld1OutcomeLaneSemanticsV1(
      isCorrect: isCorrect,
      continueAdvancesFlow: continueAdvancesFlow,
      primaryCtaLabelOverride: primaryCtaLabel,
      showRetrySecondaryOverride: showRetrySecondary,
    );
    final progressionTargetV1 = _resolveWorld1OutcomeProgressionTargetV1(
      continueAdvancesFlow: continueAdvancesFlow,
    );
    _resultAutoContinueTimer?.cancel();
    if (kDebugMode) {
      _debugShowOutcomeBeforeSetStateUsV1 = DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch;
    }
    final presentationStateV1 =
        resolveWorld1CanonicalOutcomeSurfacePresentationStateV1(
          isCorrect: isCorrect,
          lines: lines,
          continueAdvancesFlow: continueAdvancesFlow,
          autoContinue: autoContinue,
          progressionTarget: progressionTargetV1,
          primaryLabel: outcomeLaneSemanticsV1.primaryLabel,
          showsRetrySecondary: outcomeLaneSemanticsV1.showsRetrySecondary,
        );
    setState(() {
      _outcomeSurfaceVisible = presentationStateV1.outcomeSurfaceVisible;
      _outcomeLastResultCorrect = presentationStateV1.outcomeLastResultCorrect;
      _outcomeLines = presentationStateV1.outcomeLines;
      _pendingContinueAction = onContinue;
      _outcomeContinueAdvancesFlowV1 =
          presentationStateV1.outcomeContinueAdvancesFlow;
      _outcomeAutoContinueArmedV1 =
          presentationStateV1.outcomeAutoContinueArmed;
      _outcomeProgressionTargetV1 =
          presentationStateV1.outcomeProgressionTarget
              as World1CanonicalProgressionTargetV1;
      _outcomePrimaryCtaLabel = presentationStateV1.outcomePrimaryCtaLabel;
      _outcomeShowRetrySecondary =
          presentationStateV1.outcomeShowRetrySecondary;
      _resultContinueBusy = presentationStateV1.resultContinueBusy;
      _markDebugStateAppliedV1();
    });
    if (kDebugMode) {
      _debugShowOutcomeAfterSetStateUsV1 = DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch;
    }
    _scheduleDebugOutcomeFirstFrameMarkV1();
    if (autoContinue) {
      _resultAutoContinueTimer = Timer(
        _isFirstSessionInLaunch
            ? const Duration(milliseconds: 260)
            : const Duration(milliseconds: 180),
        () {
          unawaited(_onContinueResult());
        },
      );
    }
  }

  Future<void> _onContinueResult() async {
    if (_resultContinueBusy) return;
    final action = _pendingContinueAction;
    if (action == null) {
      if (_outcomeLastResultCorrect) {
        if (mounted) {
          Navigator.of(context).maybePop(false);
        }
      } else {
        _onRetryResult();
      }
      return;
    }
    setState(() {
      _resultContinueBusy =
          kWorld1CanonicalOutcomeContinueBusyStartedV1.resultContinueBusy;
    });
    try {
      await action();
    } finally {
      if (!mounted) return;
      setState(() {
        _resultContinueBusy =
            kWorld1CanonicalOutcomeContinueBusyFinishedV1.resultContinueBusy;
      });
    }
  }

  void _clearOutcomeSurfaceOnly() {
    _resultAutoContinueTimer?.cancel();
    setState(_resetOutcomeSurfaceStateFieldsV1);
  }

  void _resetOutcomeSurfaceStateFieldsV1() {
    final resetStateV1 = resolveWorld1CanonicalOutcomeSurfaceResetStateV1(
      noneProgressionTarget: World1CanonicalProgressionTargetV1.none,
    );
    _seatQuizAutoAdvancePendingV1 = resetStateV1.seatQuizAutoAdvancePending;
    _outcomeSurfaceVisible = resetStateV1.outcomeSurfaceVisible;
    _outcomeLastResultCorrect = resetStateV1.outcomeLastResultCorrect;
    _outcomeLines = resetStateV1.outcomeLines;
    _pendingContinueAction = null;
    _outcomeContinueAdvancesFlowV1 = resetStateV1.outcomeContinueAdvancesFlow;
    _outcomeAutoContinueArmedV1 = resetStateV1.outcomeAutoContinueArmed;
    _outcomeProgressionTargetV1 =
        resetStateV1.outcomeProgressionTarget
            as World1CanonicalProgressionTargetV1;
    _outcomePrimaryCtaLabel = resetStateV1.outcomePrimaryCtaLabel;
    _outcomeShowRetrySecondary = resetStateV1.outcomeShowRetrySecondary;
    _resultContinueBusy = resetStateV1.resultContinueBusy;
  }

  void _applyReviewPassCursorStateFieldsV1({
    required int cursor,
    required String feedback,
  }) {
    final reviewPassStateV1 = resolveWorld1CanonicalReviewPassCursorStateV1(
      cursor: cursor,
      reviewQueueStepIndices: _reviewQueueStepIndices,
      feedback: feedback,
      decisionStartedAt: DateTime.now().toUtc(),
    );
    _isInReviewPass = reviewPassStateV1.isInReviewPass;
    _reviewQueueCursor = reviewPassStateV1.reviewQueueCursor;
    _stepIndex = reviewPassStateV1.stepIndex;
    _selectedSeatId = reviewPassStateV1.selectedSeatId;
    _showHint = reviewPassStateV1.showHint;
    _feedback = reviewPassStateV1.feedback;
    _decisionStartedAt = reviewPassStateV1.decisionStartedAt;
    _resetDebugDecisionLatencyV1();
  }

  void _clearReviewPassStateFieldsV1() {
    _reviewQueueSet.clear();
    _reviewQueueStepIndices.clear();
    _reviewQueueCursor = 0;
    _isInReviewPass = false;
  }

  World1CanonicalProgressionTargetV1 _resolveWorld1OutcomeProgressionTargetV1({
    required bool continueAdvancesFlow,
  }) {
    return resolveWorld1CanonicalProgressionTargetV1(
      continueAdvancesFlow: continueAdvancesFlow,
      isInReviewPass: _isInReviewPass,
      hasReviewQueue: _reviewQueueStepIndices.isNotEmpty,
      isAtLastStep: _stepIndex >= _steps.length - 1,
      isCheckpointSession: _isCheckpointSession,
      isCampaignSpineSession: _isCampaignSpineSession,
      isTablePracticeSession: _isTablePracticeSession,
      isDailyRunSession: _isDailyRunSession,
    );
  }

  Future<void> _runWorld1OutcomeProgressionTargetV1(
    World1CanonicalProgressionTargetV1 target,
  ) async {
    await runWorld1CanonicalProgressionDispatchV1(
      target: target,
      callbacks: World1CanonicalAdvancementCallbacksV1(
        onAdvanceReviewQueue: _advanceReviewQueueOrComplete,
        onStartReviewPass: _startReviewPass,
        onOpenCheckpointResult: () async {
          _clearOutcomeSurfaceOnly();
          await _completeCheckpointAndOpenResult();
        },
        onOpenCampaignSpineResult: () async {
          _clearOutcomeSurfaceOnly();
          await _completeCampaignSpineAndOpenResult();
        },
        onOpenTablePracticeResult: () async {
          _clearOutcomeSurfaceOnly();
          await _completeTablePracticeAndOpenResult();
        },
        onClosePack: () async {
          _clearOutcomeSurfaceOnly();
          await _completePackAndClose();
        },
        onAdvanceStep: _advanceStep,
      ),
    );
  }

  void _onRetryResult() {
    _clearOutcomeSurfaceOnly();
    setState(() {
      _selectedSeatId = kWorld1CanonicalRetryStateV1.selectedSeatId;
      _showHint = kWorld1CanonicalRetryStateV1.showHint;
    });
  }

  String _world1OutcomeRetryTeachingLineV1({
    required String classification,
    required String normalizedErrorType,
  }) {
    if (normalizedErrorType == 'expected_seat_mismatch') {
      return 'Follow the seat order and try again.';
    }
    if (classification == 'timing') {
      return 'Pick one clear answer and try again.';
    }
    if (classification == 'sizing') {
      return 'Try the smaller, cleaner move next time.';
    }
    if (classification == 'range') {
      return 'Stay with the stronger hands here.';
    }
    return 'Look for the stronger move next time.';
  }

  _World1OutcomeActionLaneInputsV1 _buildOutcomeActionLaneInputsV1({
    required World1SurfacedOutcomeProgressionHandoffContractV1
    outcomeProgressionHandoffContractV1,
  }) {
    final routeCompletionBoundaryV1 = outcomeProgressionHandoffContractV1
        .localPolicyBoundary
        .routeCompletionBoundary;
    return _World1OutcomeActionLaneInputsV1(
      primaryLabel: routeCompletionBoundaryV1.primaryAction.label,
      secondaryLabel: routeCompletionBoundaryV1.showsSecondaryAction
          ? routeCompletionBoundaryV1.secondaryAction.label
          : null,
      isPrimaryBusy: routeCompletionBoundaryV1.primaryAction.isBusy,
      onPrimaryPressed: routeCompletionBoundaryV1.primaryAction.onPressed!,
      onSecondaryPressed:
          routeCompletionBoundaryV1.secondaryAction.onPressed ?? () {},
      onBackToMapPressed:
          outcomeProgressionHandoffContractV1.onBackToMapPressed,
    );
  }

  Widget _buildOutcomeActionRowV1({
    required _World1OutcomeActionLaneInputsV1 inputs,
    required Color primaryBackgroundColor,
    required Color primaryTextColor,
    required double primaryElevation,
    Color? primaryShadowColor,
    BorderSide? primarySide,
  }) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              key: const Key('microtask_continue_cta'),
              onPressed: inputs.isPrimaryBusy ? null : inputs.onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBackgroundColor,
                foregroundColor: primaryTextColor,
                elevation: primaryElevation,
                shadowColor: primaryShadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                  side: primarySide ?? BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: Text(
                inputs.isPrimaryBusy ? 'OPENING...' : inputs.primaryLabel,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: primaryTextColor,
                ),
              ),
            ),
          ),
          if (inputs.secondaryLabel != null) ...[
            const SizedBox(width: AppSpacing.xs),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                key: const Key('microtask_retry_cta'),
                onPressed: inputs.onSecondaryPressed,
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(72, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: Text(inputs.secondaryLabel!),
              ),
            ),
          ],
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextButton(
                  key: const Key('microtask_back_to_map_cta'),
                  onPressed: inputs.onBackToMapPressed,
                  child: const Text('Back to Map'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatQuizConfirmPanelV1({
    required bool lockInNeedsSeatSelection,
    required bool introCaptionActive,
  }) {
    return IgnorePointer(
      ignoring: introCaptionActive,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: introCaptionActive ? 0 : 1,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _microAnimationsEnabled ? 130 : 0),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: SharkyTokensV1.surfaceCard.withOpacity(0.62),
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd + 2),
            border: Border.all(
              color: _awaitingSeatInput
                  ? SharkyTokensV1.brandGlow.withOpacity(0.76)
                  : SharkyTokensV1.slate600.withOpacity(0.58),
              width: _awaitingSeatInput ? 1.5 : 1.0,
            ),
            boxShadow: <BoxShadow>[
              if (!_isLockInBlocked && !lockInNeedsSeatSelection)
                BoxShadow(
                  color: SharkyTokensV1.brandGlow.withOpacity(0.18),
                  blurRadius: 10,
                  spreadRadius: 0.4,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: CampaignPrimaryCtaV1(
              controlKey: _isCheckpointSession
                  ? const Key('checkpoint_check_cta')
                  : (_isTablePracticeSession
                        ? const Key('table_practice_check_cta')
                        : const Key('microtask_check_cta')),
              onPressed:
                  (_isLockInBlocked ||
                      lockInNeedsSeatSelection ||
                      introCaptionActive)
                  ? null
                  : _onCheck,
              label: 'CONFIRM',
              compact: true,
              microAnimationsEnabled: _microAnimationsEnabled,
              leadingIcon: Icons.check_circle_rounded,
              textStyle: AppTypography.label.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  World1LearnerHostSupportContentContractV1
  _buildWorld1PortraitHostSupportContentContractV1({
    required bool compactPortrait,
    required bool showHandLoopActionBar,
    required bool allowSeatQuizConfirmPanelV1,
    required bool introCaptionActive,
    required bool lockInNeedsSeatSelection,
    required World1SurfacedInstructionPlacementFlowV1
    instructionPlacementFlowV1,
    required _CoachModeV1 coachModeV1,
    required _World1TeachingContractV1 teachingContractV1,
    required _World1CompactTeachingPayloadV1 compactTeachingPayloadV1,
    required int introCoachRailTotalV1,
    required int introCoachRailActiveIndexV1,
    required VoidCallback? introCaptionContinueOnPressedV1,
    required World1SurfacedSupportActionRuntimeStateV1
    supportActionRuntimeStateV1,
  }) {
    final sharedTeachingGrammarV1 = teachingContractV1.sharedTeachingGrammarV1;
    return World1LearnerHostSupportContentContractV1(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height:
                showHandLoopActionBar ||
                    instructionPlacementFlowV1.showBottomCoachStripV1
                ? 0
                : 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: supportActionRuntimeStateV1.showsPortraitIdleGuidance
                  ? 1
                  : 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child:
                      introCaptionActive ||
                          instructionPlacementFlowV1.feltInstructionVisibleV1
                      ? const SizedBox.shrink()
                      : Text(
                          _seatQuizIdleGuidanceLineV1(),
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (supportActionRuntimeStateV1.showsPortraitSeatQuizCoachStrip)
            _buildPortraitCoachStripV1(
              mode: coachModeV1,
              title: introCaptionActive
                  ? (_seatQuizInstructionForTargetV1() ??
                        teachingContractV1.introTitle)
                  : sharedTeachingGrammarV1.supportPrimaryText,
              subtitle: introCaptionActive
                  ? ''
                  : sharedTeachingGrammarV1.supportSecondaryText,
              ignorePointer: !introCaptionActive,
              showRail: introCaptionActive,
              railTotal: introCoachRailTotalV1,
              railActiveIndex: introCoachRailActiveIndexV1.toInt(),
              outcomeVisible: _outcomeSurfaceVisible,
              outcomeCorrect: _outcomeLastResultCorrect,
              pulseFailure: _pulseFailure,
            ),
          if (supportActionRuntimeStateV1.showsPortraitHandLoopCoachStrip)
            _buildPortraitCoachStripV1(
              mode: coachModeV1,
              title: _outcomeSurfaceVisible
                  ? compactTeachingPayloadV1.handLoopCoachTitle
                  : sharedTeachingGrammarV1.displayedPrompt,
              handLoopBody: _outcomeSurfaceVisible
                  ? compactTeachingPayloadV1.handLoopCoachBody
                  : sharedTeachingGrammarV1.displayedPrompt,
              ignorePointer: true,
              outcomeVisible: _outcomeSurfaceVisible,
              outcomeCorrect: _outcomeLastResultCorrect,
              pulseFailure: _pulseFailure,
            ),
        ],
      ),
    );
  }

  Widget? _buildWorld1PortraitHostActionSurfaceV1({
    required bool compactPortrait,
    required bool showHandLoopActionBar,
    required bool allowSeatQuizConfirmPanelV1,
    required bool introCaptionActive,
    required bool lockInNeedsSeatSelection,
    required World1SurfacedActionStateV1? campaignActionState,
    required World1SurfacedOutcomeProgressionHandoffContractV1
    outcomeProgressionHandoffContractV1,
    required _CoachModeV1 coachModeV1,
    required VoidCallback? introCaptionContinueOnPressedV1,
    required World1SurfacedSupportActionRuntimeStateV1
    supportActionRuntimeStateV1,
  }) {
    if (supportActionRuntimeStateV1.portraitActionMode ==
        World1SurfacedActionModeV1.introContinue) {
      return IgnorePointer(
        ignoring: false,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                width: double.infinity,
                child: FilledButton(
                  key: _showSeatQuizPreludeV1
                      ? const Key('microtask_prelude_continue_cta_v1')
                      : const Key('microtask_intro_continue_cta_v1'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(124, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 0,
                    ),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: introCaptionContinueOnPressedV1,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('CONTINUE', maxLines: 1, softWrap: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (supportActionRuntimeStateV1.portraitActionMode ==
        World1SurfacedActionModeV1.outcome) {
      return Column(
        key: const Key('microtask_outcome_surface'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOutcomeActionRowV1(
            inputs: _buildOutcomeActionLaneInputsV1(
              outcomeProgressionHandoffContractV1:
                  outcomeProgressionHandoffContractV1,
            ),
            primaryBackgroundColor: SharkyTokensV1.brandPrimary,
            primaryTextColor: Colors.white,
            primaryElevation: 3,
            primaryShadowColor: SharkyTokensV1.brandGlow.withOpacity(0.34),
            primarySide: BorderSide(
              color:
                  (_outcomeLastResultCorrect
                          ? SharkyTokensV1.semanticWin
                          : SharkyTokensV1.brandGlow)
                      .withOpacity(0.42),
              width: 1.0,
            ),
          ),
        ],
      );
    }
    if (supportActionRuntimeStateV1.portraitActionMode ==
        World1SurfacedActionModeV1.seatQuizConfirm) {
      return _buildSeatQuizConfirmPanelV1(
        lockInNeedsSeatSelection: lockInNeedsSeatSelection,
        introCaptionActive: introCaptionActive,
      );
    }
    if (supportActionRuntimeStateV1.portraitActionMode ==
        World1SurfacedActionModeV1.handLoopBar) {
      return SizedBox(
        height: compactPortrait ? 56 : 62,
        child: _buildCampaignActionChips(campaignActionState!),
      );
    }
    if (supportActionRuntimeStateV1.portraitActionMode ==
        World1SurfacedActionModeV1.hiddenConfirmGhost) {
      return Opacity(
        opacity: 0,
        child: SizedBox(
          width: 1,
          height: 1,
          child: CampaignPrimaryCtaV1(
            controlKey: const Key('microtask_check_cta'),
            onPressed: () {},
            label: 'CONFIRM',
            compact: true,
            microAnimationsEnabled: false,
          ),
        ),
      );
    }
    return null;
  }

  Widget? _buildWorld1LandscapeHostActionSurfaceV1({
    required World1SurfacedActionStateV1? campaignActionState,
    required _World1StableLayoutV1 stableLayoutV1,
    required bool showHandLoopActionBar,
    required bool allowSeatQuizConfirmPanelV1,
    required bool introCaptionActive,
    required bool lockInNeedsSeatSelection,
    required World1SurfacedOutcomeProgressionHandoffContractV1
    outcomeProgressionHandoffContractV1,
    required _CoachModeV1 coachModeV1,
    required World1SurfacedSupportActionRuntimeStateV1
    supportActionRuntimeStateV1,
  }) {
    if (supportActionRuntimeStateV1.landscapeActionMode ==
        World1SurfacedActionModeV1.handLoopBar) {
      return _buildCampaignActionChips(
        campaignActionState!,
        stableLayoutV1: stableLayoutV1,
      );
    }
    if (supportActionRuntimeStateV1.landscapeActionMode ==
        World1SurfacedActionModeV1.outcome) {
      return SafeArea(
        key: const Key('microtask_outcome_surface'),
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
        child: _buildOutcomeActionRowV1(
          inputs: _buildOutcomeActionLaneInputsV1(
            outcomeProgressionHandoffContractV1:
                outcomeProgressionHandoffContractV1,
          ),
          primaryBackgroundColor: SharkyTokensV1.brandPrimary,
          primaryTextColor: SharkyTokensV1.textPrimary,
          primaryElevation: 1,
        ),
      );
    }
    if (supportActionRuntimeStateV1.landscapeActionMode ==
        World1SurfacedActionModeV1.seatQuizConfirm) {
      return _buildSeatQuizConfirmPanelV1(
        lockInNeedsSeatSelection: lockInNeedsSeatSelection,
        introCaptionActive: introCaptionActive,
      );
    }
    if (supportActionRuntimeStateV1.landscapeActionMode ==
        World1SurfacedActionModeV1.hiddenConfirmGhost) {
      return Opacity(
        opacity: 0,
        child: SizedBox(
          width: 1,
          height: 1,
          child: CampaignPrimaryCtaV1(
            controlKey: const Key('microtask_check_cta'),
            onPressed: () {},
            label: 'CONFIRM',
            compact: true,
            microAnimationsEnabled: false,
          ),
        ),
      );
    }
    return null;
  }

  World1LearnerHostContentContractV1
  _buildWorld1LandscapeHostContentContractV1() {
    return World1LearnerHostContentContractV1(
      extrasSlots: SharedLearnerFamilyExtrasSlotsV1(
        beforePrimaryActionChildren: <Widget>[
          if (_showHintBubbleV1) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('microtask_hint_bubble'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.15),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                border: Border.all(
                  color: SharkyTokensV1.semanticInfo.withOpacity(0.8),
                ),
              ),
              child: Text(
                _step.hint,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textPrimary,
                ),
              ),
            ),
          ],
          if (_feedback != null && !_outcomeSurfaceVisible) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _feedback!,
              maxLines: _isCampaignSpineSession ? 2 : null,
              overflow: _isCampaignSpineSession
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              style: AppTypography.caption.copyWith(
                color: _pulseFailure
                    ? SharkyTokensV1.semanticLoss
                    : SharkyTokensV1.textSecondary,
              ),
            ),
          ],
        ],
        afterPrimaryActionChildren: <Widget>[
          if (_loopRewardBanner != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              key: const Key('microtask_loop_reward_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: SharkyTokensV1.semanticWin.withOpacity(0.16),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
                border: Border.all(
                  color: SharkyTokensV1.semanticWin.withOpacity(0.8),
                ),
              ),
              child: Text(
                _loopRewardBanner!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
        buildPromptRevealExtraChildren: (sheetContext) {
          final packLabel = switch (widget.moduleId.trim().toLowerCase()) {
            'world1_spine_campaign_v1' => 'World 1',
            'world2_spine_campaign_v1' => 'World 2',
            _ => widget.moduleId,
          };
          final outcomeLabel =
              (_outcomeSurfaceVisible || _outcomeLines.isNotEmpty)
              ? _world1OutcomeVerdictLineV1(_outcomeLastResultCorrect)
              : 'Pending.';
          final detailTextStyle = AppTypography.caption.copyWith(
            color: SharkyTokensV1.textSecondary,
            height: 1.25,
          );
          return <Widget>[
            const SizedBox(height: 8),
            Text(
              'Mistakes: $_spineMistakesCount',
              key: const Key('spine_calibration_mistakes_value'),
              style: detailTextStyle,
            ),
            Text(
              'Rank: ${ProgressService.spineRankLabel(_spineRank)}',
              key: const Key('spine_rank_value'),
              style: detailTextStyle,
            ),
            Text(
              'Pack: $packLabel',
              key: const Key('spine_campaign_pack_id_value'),
              style: detailTextStyle,
            ),
            Text(
              'Outcome: $outcomeLabel',
              key: const Key('spine_outcome_value'),
              style: detailTextStyle,
            ),
          ];
        },
      ),
    );
  }

  World1LearnerHostSupportContentContractV1?
  _buildWorld1LandscapeHostSupportContentContractV1({
    required bool lockInNeedsSeatSelection,
    required bool allowSeatQuizConfirmPanelV1,
    required bool introCaptionActive,
    required World1SurfacedInstructionPlacementFlowV1
    instructionPlacementFlowV1,
    required _World1TeachingContractV1 teachingContractV1,
    required _World1CompactTeachingPayloadV1 compactTeachingPayloadV1,
    required World1SurfacedSupportActionRuntimeStateV1
    supportActionRuntimeStateV1,
  }) {
    final preTeachingBlocksV1 = <Widget>[
      SizedBox(
        height: 18,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: supportActionRuntimeStateV1.showsPortraitIdleGuidance
              ? 1
              : 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child:
                introCaptionActive ||
                    instructionPlacementFlowV1.feltInstructionVisibleV1
                ? const SizedBox.shrink()
                : Text(
                    _seatQuizIdleGuidanceLineV1(),
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    ];
    final teachingBlockV1 =
        supportActionRuntimeStateV1.showsLandscapeOutcomeStatus
        ? Builder(
            builder: (context) {
              final viewportHeight = MediaQuery.of(context).size.height;
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _buildCompactOutcomeStatusBoxV1(
                  sharedTeachingGrammarV1:
                      teachingContractV1.sharedTeachingGrammarV1,
                  compactTeachingPayloadV1: compactTeachingPayloadV1,
                  compactOutcome: viewportHeight < 900,
                  ultraCompactOutcome: viewportHeight < 500,
                  centered: false,
                  dense: true,
                ),
              );
            },
          )
        : null;
    return World1LearnerHostSupportContentContractV1(
      child: SharedLearnerTeachingSectionStackV1(
        preTeachingBlocks: preTeachingBlocksV1,
        teachingBlock: teachingBlockV1,
        sectionSpacing: kCanonicalLearnerFeedbackActionGapV1,
      ),
    );
  }

  World1CanonicalShellSlotsV1 _buildWorld1CanonicalShellSlotsV1({
    required BuildContext context,
    required bool compactPortrait,
    required bool useRunnerCompactHeaderV1,
    required bool hidePromptCapsuleV1,
    required World1SurfacedHeaderPromptInputV1 headerPromptInputV1,
    required _World1TeachingContractV1 teachingContractV1,
    required World1SurfacedSupportActionComposerOutputV1
    supportActionCompositionV1,
  }) {
    return World1CanonicalShellSlotsV1(
      topShell: useRunnerCompactHeaderV1
          ? _buildRunnerCompactHeaderV1(
              context: context,
              compactPortrait: compactPortrait,
              teachingContractV1: teachingContractV1,
              hidePromptCapsuleV1: hidePromptCapsuleV1,
              headerPromptInputV1: headerPromptInputV1,
            )
          : null,
      portraitSupportContent: supportActionCompositionV1.portraitSupportContent,
      landscapeSupportContent:
          supportActionCompositionV1.landscapeSupportContent,
      portraitActionSurface: supportActionCompositionV1.portraitActionSurface,
      landscapeHostContent: supportActionCompositionV1.landscapeHostContent,
      landscapeActionSurface: supportActionCompositionV1.landscapeActionSurface,
    );
  }

  void _applyLegacyBackendSummary({
    required CampaignSpineBeatPointerV1 pointer,
    required ScenarioReplayerSpec replayerScenario,
    String? fallbackNote,
  }) {
    _engineV2StreetReplayTimer?.cancel();
    _engineV2PotPulseTimer?.cancel();
    final plan = CampaignSpineRunPlanV1(
      pointer: pointer,
      scenario: replayerScenario,
    );
    final legacyResult = _campaignSpineRunner.runScenario(plan: plan);
    final summary = _campaignSpineRunner.buildOutcomeSummary(
      plan: plan,
      result: legacyResult,
    );
    if (!mounted) return;
    final legacyStateV1 = resolveWorld1CanonicalLegacyBackendSummaryStateV1(
      verdict: summary.outcomeKind.name,
      errorType: summary.errorType,
      summaryLines: summary.lines,
      fallbackNote: fallbackNote,
    );
    setState(() {
      _engineV2UseLegacyBackend = legacyStateV1.engineUseLegacyBackend;
      _engineV2Verdict = legacyStateV1.engineVerdict;
      _engineV2ErrorType = legacyStateV1.engineErrorType;
      _engineV2SummaryLines = legacyStateV1.engineSummaryLines;
      _engineV2FallbackNote = legacyStateV1.engineFallbackNote;
      _engineV2CurrentStreet = legacyStateV1.engineCurrentStreet as StreetV1?;
      _engineV2StepStreet = legacyStateV1.engineStepStreet as StreetV1?;
      _engineV2PotChips = legacyStateV1.enginePotChips;
      _engineV2ToCallChips = legacyStateV1.engineToCallChips;
      _engineV2CurrentBetChips = legacyStateV1.engineCurrentBetChips;
      _engineV2PotPulse = legacyStateV1.enginePotPulse;
      _engineV2PlaybackBusy = legacyStateV1.enginePlaybackBusy;
      _engineV2TurnFeedLines = legacyStateV1.engineTurnFeedLines;
    });
  }

  void _triggerEngineV2PotPulse() {
    _engineV2PotPulseTimer?.cancel();
    if (!_microAnimationsEnabled) {
      if (!mounted) return;
      setState(() {
        _engineV2PotPulse = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _engineV2PotPulse = true;
    });
    _engineV2PotPulseTimer = Timer(const Duration(milliseconds: 170), () {
      if (!mounted) return;
      setState(() {
        _engineV2PotPulse = false;
      });
    });
  }

  void _startEngineV2StreetPlayback(
    ReplayTraceV1 trace, {
    VoidCallback? onComplete,
    bool skipPlaybackWait = false,
  }) {
    final snapshots = trace.entries
        .map((entry) => entry.result.state.snapshot)
        .toList(growable: false);
    if (snapshots.isEmpty) {
      if (!mounted) return;
      setState(() {
        _engineV2CurrentStreet =
            kWorld1CanonicalPlaybackEmptyStateV1.engineCurrentStreet
                as StreetV1?;
        _engineV2StepStreet =
            kWorld1CanonicalPlaybackEmptyStateV1.engineStepStreet as StreetV1?;
        _engineV2PotChips = kWorld1CanonicalPlaybackEmptyStateV1.enginePotChips;
        _engineV2ToCallChips =
            kWorld1CanonicalPlaybackEmptyStateV1.engineToCallChips;
        _engineV2CurrentBetChips =
            kWorld1CanonicalPlaybackEmptyStateV1.engineCurrentBetChips;
        _engineV2PotPulse = kWorld1CanonicalPlaybackEmptyStateV1.enginePotPulse;
        _engineV2PlaybackBusy =
            kWorld1CanonicalPlaybackEmptyStateV1.enginePlaybackBusy;
      });
      onComplete?.call();
      return;
    }
    _engineV2StreetReplayTimer?.cancel();
    _engineV2PotPulseTimer?.cancel();
    final first = snapshots.first;
    if (skipPlaybackWait || !_microAnimationsEnabled || snapshots.length == 1) {
      final last = snapshots.last;
      final immediateStateV1 = resolveWorld1CanonicalPlaybackImmediateStateV1(
        lastStreet: last.street,
        firstStreet: first.street,
        potChips: last.stacksState.pot.value,
        toCallChips: last.toCallFor(last.actingPlayer),
        currentBetChips: last.currentBet.value,
      );
      if (!mounted) return;
      setState(() {
        _engineV2CurrentStreet =
            immediateStateV1.engineCurrentStreet as StreetV1?;
        _engineV2StepStreet = immediateStateV1.engineStepStreet as StreetV1?;
        _engineV2PotChips = immediateStateV1.enginePotChips;
        _engineV2ToCallChips = immediateStateV1.engineToCallChips;
        _engineV2CurrentBetChips = immediateStateV1.engineCurrentBetChips;
        _engineV2PotPulse = immediateStateV1.enginePotPulse;
        _engineV2PlaybackBusy = immediateStateV1.enginePlaybackBusy;
      });
      onComplete?.call();
      return;
    }
    var index = 0;
    var previousPot = first.stacksState.pot.value;
    final initialPlaybackStateV1 = resolveWorld1CanonicalPlaybackInitialStateV1(
      firstStreet: first.street,
      potChips: previousPot,
      toCallChips: first.toCallFor(first.actingPlayer),
      currentBetChips: first.currentBet.value,
    );
    setState(() {
      _engineV2CurrentStreet =
          initialPlaybackStateV1.engineCurrentStreet as StreetV1?;
      _engineV2StepStreet =
          initialPlaybackStateV1.engineStepStreet as StreetV1?;
      _engineV2PotChips = initialPlaybackStateV1.enginePotChips;
      _engineV2ToCallChips = initialPlaybackStateV1.engineToCallChips;
      _engineV2CurrentBetChips = initialPlaybackStateV1.engineCurrentBetChips;
      _engineV2PotPulse = initialPlaybackStateV1.enginePotPulse;
      _engineV2PlaybackBusy = initialPlaybackStateV1.enginePlaybackBusy;
    });
    _engineV2StreetReplayTimer = Timer.periodic(
      const Duration(milliseconds: 180),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        index += 1;
        if (index >= snapshots.length) {
          timer.cancel();
          setState(() {
            _engineV2PlaybackBusy =
                kWorld1CanonicalPlaybackCompletedStateV1.enginePlaybackBusy;
          });
          onComplete?.call();
          return;
        }
        final next = snapshots[index];
        final nextPot = next.stacksState.pot.value;
        final potIncreased = nextPot > previousPot;
        final tickStateV1 = resolveWorld1CanonicalPlaybackTickStateV1(
          nextStreet: next.street,
          potChips: nextPot,
          toCallChips: next.toCallFor(next.actingPlayer),
          currentBetChips: next.currentBet.value,
          potIncreased: potIncreased,
        );
        setState(() {
          _engineV2CurrentStreet = tickStateV1.engineCurrentStreet as StreetV1?;
          _engineV2PotChips = tickStateV1.enginePotChips;
          _engineV2ToCallChips = tickStateV1.engineToCallChips;
          _engineV2CurrentBetChips = tickStateV1.engineCurrentBetChips;
          if (tickStateV1.enginePotPulse) {
            _engineV2PotPulse = true;
          }
        });
        if (potIncreased) {
          _triggerEngineV2PotPulse();
        }
        previousPot = nextPot;
      },
    );
  }

  int _visibleBoardCardsForStreet(StreetV1 street) {
    switch (street) {
      case StreetV1.preflop:
        return 0;
      case StreetV1.flop:
        return 3;
      case StreetV1.turn:
        return 4;
      case StreetV1.river:
        return 5;
    }
  }

  ReplayTraceV1 _asReplayTrace(World1CanonicalHandLoopRunV1 run) {
    final traceEntries = <ReplayTraceEntryV1>[];
    for (var i = 0; i < run.entries.length; i++) {
      final autoEntry = run.entries[i];
      final step = switch (autoEntry.event) {
        StartHandEventV1() => const StartHandStepV1(),
        PlayerActionEventV1(:final action) => PlayerActionStepV1(
          playerId: action.actorId,
          action: action,
        ),
        AdvanceEventV1() => const AdvanceStepV1(),
        FinishEventV1() => const FinishStepV1(),
        _ => const AdvanceStepV1(),
      };
      traceEntries.add(
        ReplayTraceEntryV1(
          stepIndex: i,
          step: step,
          result: autoEntry.result,
          violationSummary: autoEntry.result.violations.isEmpty
              ? null
              : autoEntry.result.violations.first.message,
        ),
      );
    }
    final stoppedAtStep = run.entries.isEmpty ? null : run.entries.length - 1;
    return ReplayTraceV1(
      scenarioId: 'runner_engine_v2_auto_trace',
      entries: List<ReplayTraceEntryV1>.unmodifiable(traceEntries),
      isSuccess: run.violations.isEmpty,
      stoppedAtStep: stoppedAtStep,
    );
  }

  int _elapsedMs(DateTime from) {
    return DateTime.now().toUtc().difference(from).inMilliseconds;
  }

  void _queueCurrentStepForReview() {
    if (_isInReviewPass || _isReviewQueueSession) return;
    if (_reviewQueueSet.add(_stepIndex)) {
      _reviewQueueStepIndices.add(_stepIndex);
      unawaited(_persistReviewQueueRefForCurrentStepV1(_stepIndex));
    }
  }

  Future<void> _persistReviewQueueRefForCurrentStepV1(int stepIndex) async {
    final packId = widget.moduleId.trim().toLowerCase();
    if (packId.isEmpty || stepIndex < 0) return;
    try {
      final hadQueue = await ProgressService.hasReviewQueueForPackV1(packId);
      await ProgressService.addReviewRefForPackV1(
        packId,
        ReviewRefV1(packId: packId, stepIndex: stepIndex),
      );
      final hasQueue = await ProgressService.hasReviewQueueForPackV1(packId);
      if (!hadQueue &&
          hasQueue &&
          !_reviewQueueCreatedTelemetrySentV1 &&
          mounted) {
        _reviewQueueCreatedTelemetrySentV1 = true;
        _emitTelemetry(TelemetryEvents.reviewQueueCreatedV1, <String, dynamic>{
          'packId': packId,
          'count_added': 1,
          'source': 'runner',
        });
      }
    } catch (_) {
      // Best-effort persistence/telemetry; runner flow must remain resilient.
    }
  }

  Future<void> _startReviewPass() async {
    if (_reviewQueueStepIndices.isEmpty || _isInReviewPass) return;
    _clearOutcomeSurfaceOnly();
    if (!mounted) return;
    setState(() {
      _applyReviewPassCursorStateFieldsV1(
        cursor: 0,
        feedback: 'Review queued spots.',
      );
    });
  }

  Future<void> _completeCurrentModeFlow() async {
    final action = resolveWorld1CanonicalModeCompletionActionV1(
      isReviewQueueSession: _isReviewQueueSession,
      isCheckpointSession: _isCheckpointSession,
      isCampaignSpineSession: _isCampaignSpineSession,
      isTablePracticeSession: _isTablePracticeSession,
      isDailyRunSession: _isDailyRunSession,
      isAtLastStep: _stepIndex >= _steps.length - 1,
    );
    switch (action) {
      case World1CanonicalModeCompletionActionV1.completeReviewQueueSession:
        await _completeReviewQueueSessionV1();
        return;
      case World1CanonicalModeCompletionActionV1.completeCheckpointResult:
        await _completeCheckpointAndOpenResult();
        return;
      case World1CanonicalModeCompletionActionV1.completeCampaignSpineResult:
        await _completeCampaignSpineAndOpenResult();
        return;
      case World1CanonicalModeCompletionActionV1.completeTablePracticeResult:
        await _completeTablePracticeAndOpenResult();
        return;
      case World1CanonicalModeCompletionActionV1.closePack:
        await _completePackAndClose();
        return;
      case World1CanonicalModeCompletionActionV1.advanceStep:
        await _advanceStep();
        return;
    }
  }

  Future<void> _advanceReviewQueueOrComplete() async {
    final action = resolveWorld1CanonicalReviewAdvanceActionV1(
      isInReviewPass: _isInReviewPass,
      isLastReviewStep:
          _reviewQueueCursor >= _reviewQueueStepIndices.length - 1,
    );
    switch (action) {
      case World1CanonicalReviewAdvanceActionV1.delegateToModeCompletion:
        await _completeCurrentModeFlow();
        return;
      case World1CanonicalReviewAdvanceActionV1
          .clearReviewAndDelegateToModeCompletion:
        _clearOutcomeSurfaceOnly();
        if (mounted) {
          setState(_clearReviewPassStateFieldsV1);
        }
        await _completeCurrentModeFlow();
        return;
      case World1CanonicalReviewAdvanceActionV1.applyNextReviewCursor:
        _clearOutcomeSurfaceOnly();
        if (!mounted) return;
        setState(() {
          _applyReviewPassCursorStateFieldsV1(
            cursor: _reviewQueueCursor + 1,
            feedback: 'Review queued spots.',
          );
        });
        return;
    }
  }

  Future<void> _advanceStep() async {
    if (_isCampaignSpineSession && !_isInReviewPass) {
      await ProgressService.setSpineNextHandIndexV1(_stepIndex + 1);
    }
    if (!mounted) return;
    _clearOutcomeSurfaceOnly();
    final advanceStateV1 = resolveWorld1CanonicalAdvanceStepStateV1(
      currentStepIndex: _stepIndex,
      decisionStartedAt: DateTime.now().toUtc(),
    );
    setState(() {
      _seatQuizAutoAdvancePendingV1 = advanceStateV1.seatQuizAutoAdvancePending;
      _stepIndex = advanceStateV1.stepIndex;
      _selectedSeatId = advanceStateV1.selectedSeatId;
      _showHint = advanceStateV1.showHint;
      _feedback = advanceStateV1.feedback;
      _decisionStartedAt = advanceStateV1.decisionStartedAt;
      _resetDebugDecisionLatencyV1();
    });
    _maybeShowHighestPriorityPreludeV1();
  }

  Future<void> _completeStepFlow() async {
    final progressionTargetV1 = _resolveWorld1OutcomeProgressionTargetV1(
      continueAdvancesFlow: true,
    );
    await _runWorld1OutcomeProgressionTargetV1(progressionTargetV1);
  }

  String _engineOutcomeReason({
    required OutcomeV1 outcome,
    required World1CanonicalHandLoopRunV1 handLoop,
  }) {
    if (outcome.error != null) {
      if (outcome.error!.code == 'range_expectation_mismatch' &&
          outcome.error!.message ==
              'Action is valid but does not match expected strategy action') {
        return _engineExpectedMismatchReasonV1(outcome.error!);
      }
      return outcome.error!.message;
    }
    if (handLoop.stopReason == EngineV2AutoResolveStopReasonV1.outcomeReached) {
      return 'Hand reached outcome after multi-street loop.';
    }
    return 'EngineV2 hand loop completed.';
  }

  String _engineExpectedMismatchReasonV1(ErrorDetailV1 error) {
    final selectedActionKind = _actionKindFromOutcomeLabelV1(error.actual);
    final expectedActionKind = _actionKindFromOutcomeLabelV1(error.expected);
    final truth = world1ScenarioTruthPilotForStepV1(
      step: _step,
      family: World1ScenarioTruthFamilyV1.handLoopMismatchFooterFeedback,
    );
    final expectedLabel =
        world1SpineOutcomeExpectedLineV1(_step) ??
        world1ScenarioTruthExpectedLineV1(_step) ??
        'Expected: UNKNOWN';
    final actualLabel = _normalizeOutcomeActionLabelV1(error.actual);
    final actionState = _campaignActionUiStateForCurrentStep();
    final canonicalExpectedLabel = expectedLabel.replaceFirst('Expected: ', '');
    final fixLine = resolveWorld1HandLoopMismatchFixLineV1(
      expectedActionKind: truth?.expectedActionFamilyV1 ?? expectedActionKind,
      expectedLabel: canonicalExpectedLabel,
      toCallMilliBb: actionState?.toCall,
    );
    final whyLine = truth?.whyV1;
    if (whyLine != null && whyLine.trim().isNotEmpty) {
      return _truncateForOutcome(
        buildWorld1HandLoopExpectedChosenFeedbackLineV1(
          expectedLabel: canonicalExpectedLabel,
          chosenLabel: actualLabel,
          factualContextLine: whyLine,
          fixLine: fixLine,
        ),
        120,
      );
    }
    final actual = actualLabel;
    if (actionState != null) {
      if (actionState.toCall > 0) {
        return _truncateForOutcome(
          buildWorld1HandLoopExpectedChosenFeedbackLineV1(
            expectedLabel: canonicalExpectedLabel,
            chosenLabel: actual,
            factualContextLine:
                'To call: ${_unitsToBbDisplayV1(actionState.toCall)} BB.',
            fixLine: fixLine,
          ),
          120,
        );
      }
      if (actionState.currentBet > 0) {
        return _truncateForOutcome(
          buildWorld1HandLoopExpectedChosenFeedbackLineV1(
            expectedLabel: canonicalExpectedLabel,
            chosenLabel: actual,
            factualContextLine:
                'Current bet: ${_unitsToBbDisplayV1(actionState.currentBet)} BB.',
            fixLine: fixLine,
          ),
          120,
        );
      }
      if (actionState.pot > 0) {
        return _truncateForOutcome(
          buildWorld1HandLoopExpectedChosenFeedbackLineV1(
            expectedLabel: canonicalExpectedLabel,
            chosenLabel: actual,
            factualContextLine:
                'Pot: ${_unitsToBbDisplayV1(actionState.pot)} BB.',
            fixLine: fixLine,
          ),
          120,
        );
      }
    }
    return _truncateForOutcome(
      buildWorld1HandLoopExpectedChosenFeedbackLineV1(
        expectedLabel: canonicalExpectedLabel,
        chosenLabel: actual,
        fixLine: fixLine,
      ),
      120,
    );
  }

  String _normalizeOutcomeActionLabelV1(String? raw) {
    final token = raw?.trim();
    if (token == null || token.isEmpty || token.endsWith('_UNAVAILABLE')) {
      return 'UNKNOWN';
    }
    final kind = _actionKindFromOutcomeLabelV1(token);
    if (kind != null) {
      return _actionKindLabelV1(kind);
    }
    return token.toUpperCase();
  }

  ActionKindV1? _actionKindFromOutcomeLabelV1(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    switch (normalized) {
      case 'FOLD':
        return ActionKindV1.fold;
      case 'CHECK':
        return ActionKindV1.check;
      case 'CALL':
        return ActionKindV1.call;
      case 'BET':
        return ActionKindV1.bet;
      case 'RAISE':
        return ActionKindV1.raise;
      default:
        return null;
    }
  }

  String _engineOutcomeHint({
    required OutcomeV1 outcome,
    required World1CanonicalHandLoopRunV1 handLoop,
  }) {
    if (outcome.verdict == DecisionVerdictV1.correct) {
      return 'Continue to the next spot.';
    }
    if (handLoop.violations.isNotEmpty) {
      return 'Retry to keep the loop deterministic.';
    }
    return 'Review the line and retry.';
  }

  _World1OutcomePresentationV1 _buildOutcomePresentationV1() {
    final expectedChosenLine = _outcomeLines.firstWhere((line) {
      final trimmed = line.trim();
      return isSharedLearnerComparisonHeadlineV1(trimmed);
    }, orElse: () => '');
    final summaryPrimary = _buildCompactOutcomeSummaryPrimaryV1();
    final summaryWhy = _buildCompactOutcomeSummaryWhyV1();
    final summaryNext = _buildCompactOutcomeSummaryNextV1(
      expectedChosenLine: expectedChosenLine,
    );
    final seatQuizCoachSubtitle = _joinCompactOutcomeSummaryLinesV1(<String>[
      if (summaryWhy.isNotEmpty) summaryWhy,
      if (summaryNext.isNotEmpty && summaryNext != expectedChosenLine)
        summaryNext,
    ]);
    final handLoopCoachBody = _joinCompactOutcomeSummaryLinesV1(<String>[
      if (summaryWhy.isNotEmpty) summaryWhy,
      if (summaryNext.isNotEmpty) summaryNext,
    ], separator: '\n');

    return _World1OutcomePresentationV1(
      showHeaderStatus: buildWorld1CompletionHeaderAdapterV1()
          .shouldShowOutcomeStatus(outcomeVisible: _outcomeSurfaceVisible),
      statusLine: summaryPrimary,
      summaryPrimary: summaryPrimary,
      summaryWhy: summaryWhy,
      summaryNext: summaryNext,
      expectedChosenLine: expectedChosenLine,
      seatQuizCoachTitle: summaryPrimary,
      seatQuizCoachSubtitle: seatQuizCoachSubtitle,
      handLoopCoachTitle: summaryPrimary,
      handLoopCoachBody: handLoopCoachBody,
    );
  }

  String _buildCompactOutcomeSummaryPrimaryV1() {
    if (_outcomeLines.isEmpty) {
      return _world1OutcomeVerdictLineV1(_outcomeLastResultCorrect);
    }
    return _outcomeLines.first.trim();
  }

  String _buildCompactOutcomeSummaryWhyV1() {
    if (_outcomeLines.isEmpty) return '';
    final noticeLine = _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Notice:'),
      orElse: () => '',
    );
    if (noticeLine.isNotEmpty) {
      return noticeLine;
    }
    return _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Why:'),
      orElse: () => '',
    );
  }

  String _buildCompactOutcomeSummaryNextV1({
    required String expectedChosenLine,
  }) {
    if (_outcomeLines.isEmpty) return '';
    if (_outcomeLastResultCorrect) {
      final reinforceLine = _outcomeLines.firstWhere(
        (line) => line.trim().startsWith('Reinforce:'),
        orElse: () => '',
      );
      if (reinforceLine.isNotEmpty) {
        return reinforceLine;
      }
      return _outcomeLines.last.trim();
    }
    final nextTimeLine = _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Next time:'),
      orElse: () => '',
    );
    if (nextTimeLine.isNotEmpty) {
      return nextTimeLine;
    }
    final fixLine = _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Fix:'),
      orElse: () => '',
    );
    if (fixLine.isNotEmpty) {
      return fixLine;
    }
    if (expectedChosenLine.isNotEmpty) {
      return expectedChosenLine;
    }
    final expectedLine = _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Expected:'),
      orElse: () => '',
    );
    if (expectedLine.isNotEmpty) {
      return expectedLine;
    }
    return _outcomeLines.firstWhere(
      (line) => line.trim().startsWith('Improve '),
      orElse: () => '',
    );
  }

  String _joinCompactOutcomeSummaryLinesV1(
    List<String> segments, {
    String separator = ' ',
  }) {
    final compactSegments = segments
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    return compactSegments.join(separator);
  }

  _World1CompactTeachingPayloadV1 _buildWorld1CompactTeachingPayloadV1({
    required _World1OutcomePresentationV1 outcomePresentationV1,
    required String supportTitle,
    required String supportSubtitle,
  }) {
    return _World1CompactTeachingPayloadV1(
      outcomePresentationV1: outcomePresentationV1,
      supportTitle: supportTitle.trim(),
      supportSubtitle: supportSubtitle.trim(),
      handLoopCoachTitle: outcomePresentationV1.handLoopCoachTitle.trim(),
      handLoopCoachBody: outcomePresentationV1.handLoopCoachBody.trim(),
    );
  }

  _World1TeachingContractV1 _buildWorld1TeachingContractV1({
    required String displayedPrompt,
    required String introTitle,
    required String introSubtitle,
    required String promptDetailsTitle,
    required String promptDetailsText,
    required bool canRevealPromptDetails,
    required bool enablePromptDetailsAffordance,
    required _World1CompactTeachingPayloadV1 compactTeachingPayloadV1,
  }) {
    return _World1TeachingContractV1(
      introTitle: introTitle.trim(),
      introSubtitle: introSubtitle.trim(),
      outcomeTitle: compactTeachingPayloadV1.outcomePrimary,
      outcomeDetail: compactTeachingPayloadV1.compactOutcomeDetailText(
        ultraCompactOutcome: false,
      ),
      handLoopCoachTitle: compactTeachingPayloadV1.handLoopCoachTitle,
      handLoopCoachBody: compactTeachingPayloadV1.handLoopCoachBody,
      sharedTeachingGrammarV1: SharedLearnerTeachingGrammarV1(
        headerStatusText: _runnerProgressionStatusTextV1(),
        headerHeadlineText: _runnerHeaderHeadlineTextV1(),
        headerPromptText: displayedPrompt.trim(),
        promptStatusText: _runnerPromptStatusTextV1(),
        displayedPrompt: displayedPrompt.trim(),
        promptDetailsTitle: promptDetailsTitle.trim(),
        promptDetailsText: promptDetailsText.trim(),
        canRevealPromptDetails: canRevealPromptDetails,
        enablePromptDetailsAffordance: enablePromptDetailsAffordance,
        supportPrimaryText: compactTeachingPayloadV1.supportTitle,
        supportSecondaryText: compactTeachingPayloadV1.supportSubtitle,
        supportTertiaryText: compactTeachingPayloadV1.expectedChosenLine,
        outcomePrimaryText: compactTeachingPayloadV1.outcomePrimary,
        outcomeWhyText:
            compactTeachingPayloadV1.outcomePresentationV1.summaryWhy,
        outcomeNextText:
            compactTeachingPayloadV1.outcomePresentationV1.summaryNext,
        outcomeDetailText: compactTeachingPayloadV1.compactOutcomeDetailText(
          ultraCompactOutcome: false,
        ),
      ),
      compactTeachingPayloadV1: compactTeachingPayloadV1,
    );
  }

  Widget _buildCompactOutcomeStatusBoxV1({
    SharedLearnerTeachingGrammarV1? sharedTeachingGrammarV1,
    required _World1CompactTeachingPayloadV1 compactTeachingPayloadV1,
    required bool compactOutcome,
    required bool ultraCompactOutcome,
    required bool centered,
    required bool dense,
  }) {
    final detailText = compactTeachingPayloadV1.compactOutcomeDetailText(
      ultraCompactOutcome: ultraCompactOutcome,
    );
    final effectiveTeachingGrammarV1 =
        sharedTeachingGrammarV1 ??
        SharedLearnerTeachingGrammarV1(
          headerStatusText: null,
          headerHeadlineText: '',
          headerPromptText: '',
          promptStatusText: null,
          displayedPrompt: '',
          promptDetailsTitle: '',
          promptDetailsText: '',
          canRevealPromptDetails: false,
          enablePromptDetailsAffordance: false,
          supportPrimaryText: compactTeachingPayloadV1.supportTitle,
          supportSecondaryText: compactTeachingPayloadV1.supportSubtitle,
          supportTertiaryText: compactTeachingPayloadV1.expectedChosenLine,
          outcomePrimaryText: compactTeachingPayloadV1.outcomePrimary,
          outcomeWhyText:
              compactTeachingPayloadV1.outcomePresentationV1.summaryWhy,
          outcomeNextText:
              compactTeachingPayloadV1.outcomePresentationV1.summaryNext,
          outcomeDetailText: compactTeachingPayloadV1.compactOutcomeDetailText(
            ultraCompactOutcome: false,
          ),
        );
    return SharedLearnerTeachingSupportOutcomeV1(
      grammar: effectiveTeachingGrammarV1,
      style: SharedLearnerTeachingSupportOutcomeStyleV1(
        surfaceKey: const Key('microtask_outcome_status_box_v1'),
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 7 : 9,
          vertical: dense ? 2 : 4,
        ),
        decoration: buildSharedLearnerTeachingCalmSupportDecorationV1(
          radius: SharkyTokensV1.radiusSm,
          compact: dense,
        ),
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        lines: <SharedLearnerTeachingSupportOutcomeLineStyleV1>[
          SharedLearnerTeachingSupportOutcomeLineStyleV1(
            role: SharedLearnerTeachingTextRoleV1.outcomePrimaryText,
            maxLines: compactOutcome ? 1 : 2,
            style: buildSharedLearnerTeachingPrimarySupportTextStyleV1(
              AppTypography.caption.copyWith(
                fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
          SharedLearnerTeachingSupportOutcomeLineStyleV1(
            role: SharedLearnerTeachingTextRoleV1.supportTertiaryText,
            key: const Key('microtask_seat_quiz_expected_chosen_v1'),
            textOverride: compactTeachingPayloadV1.showsExpectedChosenLine
                ? compactTeachingPayloadV1.expectedChosenLine
                : '',
            topSpacing: 2,
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: buildSharedLearnerTeachingSecondarySupportTextStyleV1(
              AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
              tertiary: true,
            ),
          ),
          SharedLearnerTeachingSupportOutcomeLineStyleV1(
            role: SharedLearnerTeachingTextRoleV1.outcomeDetailText,
            textOverride: detailText,
            topSpacing: 2,
            maxLines: 2,
            style: buildSharedLearnerTeachingSecondarySupportTextStyleV1(
              AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showWorld1OutcomeHeaderStatusV1 =>
      _buildOutcomePresentationV1().showHeaderStatus;

  bool get _showSeatQuizExpectedChosenLineV1 =>
      _buildOutcomePresentationV1().showsExpectedChosenLine;

  String get _seatQuizExpectedChosenLineV1 =>
      _buildOutcomePresentationV1().expectedChosenLine;

  _World1SeatQuizInstructionPresentationV1
  _buildSeatQuizInstructionPresentationV1({
    required String displayedPrompt,
    required String effectiveTopPrompt,
    required bool hideStepPromptInHeaderV1,
    required bool seatQuizHeaderInstructionActiveV1,
    required String seatQuizHeaderInstructionTextV1,
    World1SurfacedHandLoopPromptSurfaceV1? handLoopPromptSurfaceV1,
    bool seatQuizTableInstructionActiveV1 = false,
    String? seatQuizTableInstructionTextV1,
  }) {
    final usesHandLoopHeaderPromptV1 =
        handLoopPromptSurfaceV1 != null &&
        handLoopPromptSurfaceV1.isAffectedStateFamily &&
        handLoopPromptSurfaceV1.isMounted;
    final headerPromptText = usesHandLoopHeaderPromptV1
        ? handLoopPromptSurfaceV1.promptText
        : (hideStepPromptInHeaderV1
              ? ''
              : (seatQuizHeaderInstructionActiveV1
                    ? seatQuizHeaderInstructionTextV1
                    : effectiveTopPrompt));
    final headerPromptKey = usesHandLoopHeaderPromptV1
        ? const Key('microtask_step_prompt')
        : (hideStepPromptInHeaderV1
              ? const Key('microtask_step_prompt_header_hidden_v1')
              : (seatQuizHeaderInstructionActiveV1
                    ? const Key('microtask_seat_quiz_header_instruction_v1')
                    : const Key('microtask_step_prompt')));
    return _World1SeatQuizInstructionPresentationV1(
      headerPromptText: headerPromptText,
      headerPromptKey: headerPromptKey,
      headerMaxLines: usesHandLoopHeaderPromptV1
          ? 2
          : (seatQuizHeaderInstructionActiveV1 ? 2 : 1),
      headerOverflow: usesHandLoopHeaderPromptV1
          ? TextOverflow.clip
          : (seatQuizHeaderInstructionActiveV1
                ? TextOverflow.clip
                : TextOverflow.ellipsis),
      headerSoftWrap: usesHandLoopHeaderPromptV1
          ? true
          : seatQuizHeaderInstructionActiveV1,
      tablePromptText: seatQuizTableInstructionActiveV1
          ? (seatQuizTableInstructionTextV1 ?? displayedPrompt)
          : displayedPrompt,
    );
  }

  Widget _buildSeatQuizInstructionSurfaceV1({
    required Rect rect,
    required World1CanonicalSeatQuizInstructionSurfaceContractV1 policy,
    required bool compactPortrait,
    required bool trackIntroOverlayActiveV1,
  }) {
    final horizontalPadding = compactPortrait ? 10.0 : 12.0;
    final verticalPadding = compactPortrait ? 8.0 : 10.0;
    if (policy.showsOverlayPrelude) {
      return Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        child: IgnorePointer(
          child: Container(
            key: policy.overlayPreludeKey,
            padding: EdgeInsets.symmetric(
              horizontal: compactPortrait ? 12 : 14,
              vertical: compactPortrait ? 10 : 11,
            ),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceApp.withOpacity(0.72),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: SharkyTokensV1.slate500.withOpacity(0.4),
              ),
            ),
            child: Text(
              policy.placementText,
              textAlign: TextAlign.center,
              maxLines: trackIntroOverlayActiveV1 ? 3 : 5,
              overflow: TextOverflow.clip,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }
    if (!policy.showsTableInstruction) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      child: IgnorePointer(
        child: Container(
          key: const Key('microtask_seat_quiz_table_instruction_v1'),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: SharkyTokensV1.surfaceApp.withOpacity(0.72),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.4)),
          ),
          child: _buildSeatQuizInstructionSurfaceContentV1(
            policy: policy,
            compactPortrait: compactPortrait,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatQuizInstructionSurfaceContentV1({
    required World1CanonicalSeatQuizInstructionSurfaceContractV1 policy,
    required bool compactPortrait,
  }) {
    switch (policy.kind) {
      case World1CanonicalSeatQuizInstructionSurfaceKindV1.conceptPrelude:
        return _buildConceptFirstSeatPreludeCardV1(
          compact: true,
          embedded: true,
        );
      case World1CanonicalSeatQuizInstructionSurfaceKindV1
          .actionLiteracyPrelude:
        return _buildActionLiteracyPreludeCardV1(compact: true, embedded: true);
      case World1CanonicalSeatQuizInstructionSurfaceKindV1.streetFlowPrelude:
        return _buildStreetFlowPreludeCardV1(compact: true, embedded: true);
      case World1CanonicalSeatQuizInstructionSurfaceKindV1.plainText:
        final promptLines = policy.tablePromptText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false);
        final primaryLine = promptLines.isEmpty ? '' : promptLines.first;
        final orderLine = promptLines.length > 1
            ? promptLines.sublist(1).join(' ')
            : null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              primaryLine,
              key: const Key('microtask_step_prompt'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.clip,
              softWrap: true,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: compactPortrait ? 13.2 : 14.0,
                height: 1.12,
              ),
            ),
            if (orderLine != null) ...[
              SizedBox(height: compactPortrait ? 5 : 6),
              Text(
                orderLine,
                key: const Key('microtask_seat_quiz_order_hint_v1'),
                textAlign: TextAlign.center,
                maxLines: compactPortrait ? 3 : 2,
                overflow: TextOverflow.clip,
                softWrap: true,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textSecondary.withOpacity(0.98),
                  fontWeight: FontWeight.w700,
                  fontSize: compactPortrait ? 10.8 : 11.2,
                  height: 1.18,
                ),
              ),
            ],
          ],
        );
      case World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText:
      case World1CanonicalSeatQuizInstructionSurfaceKindV1.none:
        return const SizedBox.shrink();
    }
  }

  _World1StableLayoutV1 _resolveStableLayoutV1({
    required BuildContext context,
    required MediaQueryData media,
    Size? fallbackSize,
  }) {
    var viewportSize = media.size;
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      final view = View.maybeOf(context);
      if (view != null &&
          view.physicalSize.width > 0 &&
          view.physicalSize.height > 0 &&
          view.devicePixelRatio > 0) {
        viewportSize = Size(
          view.physicalSize.width / view.devicePixelRatio,
          view.physicalSize.height / view.devicePixelRatio,
        );
      }
    }
    if ((viewportSize.width <= 0 || viewportSize.height <= 0) &&
        fallbackSize != null &&
        fallbackSize.width > 0 &&
        fallbackSize.height > 0) {
      viewportSize = fallbackSize;
    }
    final portraitLayout = viewportSize.height > viewportSize.width;
    final compactPortrait = portraitLayout && viewportSize.height <= 820;
    return _World1StableLayoutV1(
      viewportSize: viewportSize,
      portraitLayout: portraitLayout,
      compactPortrait: compactPortrait,
    );
  }

  String _engineOutcomeType({
    required OutcomeV1 outcome,
    required World1CanonicalHandLoopRunV1 handLoop,
  }) {
    return outcome.error?.type.name ??
        (handLoop.violations.isEmpty ? 'none' : 'logic');
  }

  String _handLoopPromptV1(World1SurfacedActionStateV1? state) {
    if (state == null) {
      return _isDemoHandLoopVisualStepV1
          ? 'POT -- • TO CALL --'
          : 'Choose the best action.';
    }
    if (_isDemoHandLoopVisualStepV1) {
      return 'POT ${_unitsToBbDisplayV1(state.pot)} BB • TO CALL ${_unitsToBbDisplayV1(state.actingSeatToCall)} BB';
    }
    return 'Choose the best action.';
  }

  bool get _isSpinePromptQualityTargetV1 =>
      _isCampaignSpineSession &&
      _isWorld1SpineParityPackV1 &&
      _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop &&
      _currentCoachModeV1() == _CoachModeV1.action &&
      !_isDemoHandLoopVisualStepV1;

  String _streetLabelForPromptV1(MicroTaskStreetV1? street) {
    switch (street) {
      case MicroTaskStreetV1.flop:
        return 'Flop';
      case MicroTaskStreetV1.turn:
        return 'Turn';
      case MicroTaskStreetV1.river:
        return 'River';
      default:
        return 'Preflop';
    }
  }

  bool _hasActionTokenV1(List<String> actions, String token) {
    for (final action in actions) {
      if (action.trim().toLowerCase().contains(token)) {
        return true;
      }
    }
    return false;
  }

  String _spineActionPhraseForPromptV1({
    required int toCall,
    required List<String> actions,
  }) {
    final hasCheck = _hasActionTokenV1(actions, 'check');
    final hasCall = _hasActionTokenV1(actions, 'call');
    final hasFold = _hasActionTokenV1(actions, 'fold');
    final hasRaise = _hasActionTokenV1(actions, 'raise');
    final hasBet = _hasActionTokenV1(actions, 'bet');
    if (toCall > 0) {
      if (hasCall && hasFold && hasRaise) return 'Call/Fold/Raise';
      if (hasCall && hasFold) return 'Call or Fold';
      if (hasCall) return 'Call';
      return 'Choose action';
    }
    if (hasCheck && hasBet) return 'Check or Bet';
    if (hasCheck) return 'Check';
    if (hasBet) return 'Bet';
    if (hasRaise) return 'Bet or Raise';
    return 'Choose action';
  }

  String? _spineTaskLineV1(World1SurfacedActionStateV1? state) {
    if (!_isSpinePromptQualityTargetV1) return null;
    if (state == null) return null;
    final street = _streetLabelForPromptV1(_step.street);
    return 'Practice: $street decision. Choose the best action.';
  }

  String? _spineMicroPromptV1(World1SurfacedActionStateV1? state) {
    if (!_isSpinePromptQualityTargetV1) return null;
    final taskLine = _spineTaskLineV1(state);
    if (taskLine != null) {
      return taskLine;
    }
    if (state == null) return null;
    final actions = (_step.allowedActions ?? const <String>[])
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final street = _streetLabelForPromptV1(_step.street);
    final actionPhrase = _spineActionPhraseForPromptV1(
      toCall: state.actingSeatToCall,
      actions: actions,
    );
    return _truncateForOutcome('$street: $actionPhrase.', 60);
  }

  String _handLoopFeltCaptionTextV1(World1SurfacedActionStateV1? state) {
    final debugOverride = widget.debugHandLoopFeltCaptionOverrideV1?.trim();
    if (debugOverride != null && debugOverride.isNotEmpty) {
      return debugOverride;
    }
    if (!_isDemoHandLoopVisualStepV1) {
      if (_isReviewQueueSession) {
        return 'Review missed spots. Choose the best action.';
      }
      final spineMicroPrompt = _spineMicroPromptV1(state);
      if (spineMicroPrompt != null) {
        return spineMicroPrompt;
      }
      return 'Choose the best action.';
    }
    return _handLoopPromptV1(state);
  }

  bool _stepHasScenarioHandLoopVisualsV1(MicroTaskStep step) {
    return step.street != null ||
        step.boardCards != null ||
        step.heroCards != null ||
        step.allowedActions != null ||
        step.pot != null ||
        step.toCall != null;
  }

  bool get _isNonCampaignPackInCampaignModeV1 =>
      _isCampaignSpineSession &&
      !ProgressService.campaignPackIdsV1.contains(widget.moduleId);

  bool get _isWorld2SpinePackV1 =>
      widget.moduleId.trim().toLowerCase().startsWith('world2_spine_');

  bool get _isWorld2SeatQuizBeatV1 {
    if (!_isWorld2SpinePackV1) {
      return false;
    }
    final expectedActionKind = world1SpineExpectedActionKindV1(_step);
    final hasExpectedSeatIds = _step.expectedSeatIds
        .where((id) => id.trim().isNotEmpty)
        .isNotEmpty;
    final hasAllowedActions = (_step.allowedActions ?? const <String>[])
        .where((action) => action.trim().isNotEmpty)
        .isNotEmpty;
    final guidedScope = _step.guidedScope?.trim().toLowerCase();
    return guidedScope == 'seats' ||
        (hasExpectedSeatIds &&
            expectedActionKind == null &&
            !hasAllowedActions);
  }

  bool get _isDemoHandLoopVisualStepV1 =>
      (_isDemoHandLoopSession || _isNonCampaignPackInCampaignModeV1) &&
      _stepHasScenarioHandLoopVisualsV1(_step);

  World1CanonicalRunnerAuthorityStateV1 _currentRunnerAuthorityStateV1({
    World1SurfacedActionStateV1? actionStateOverride,
    int? visibleBoardCountOverride,
  }) {
    final runnerMode = _currentCampaignRunnerMode;
    final actionState =
        actionStateOverride ?? _campaignActionUiStateForCurrentStep();
    final visibleBoardCount =
        visibleBoardCountOverride ??
        _visibleBoardCardsForStreet(_effectiveBoardStreetForCurrentStepV1());
    return buildWorld1CanonicalRunnerAuthorityV1(
      runnerMode: runnerMode == _CampaignRunnerMode.handLoop
          ? World1CanonicalRunnerModeV1.handLoop
          : World1CanonicalRunnerModeV1.seatQuiz,
      isReviewPass: _isInReviewPass,
      outcomeVisible: _outcomeSurfaceVisible,
      actionStateAvailable: actionState != null,
      visibleBoardCount: visibleBoardCount,
      isCampaignSpineSession: _isCampaignSpineSession,
      forceHandLoopSurfaceForTest: _forceHandLoopSurfaceForTestV1,
      isDemoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
    );
  }

  World1SurfacedActionStateV1? _campaignActionUiStateForCurrentStep() {
    if (_isWorld2SeatQuizBeatV1) {
      return null;
    }
    final useHandLoopActionContext =
        (_isCampaignSpineSession &&
            _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop) ||
        _forceHandLoopSurfaceForTestV1 ||
        _isDemoHandLoopVisualStepV1;
    if (!useHandLoopActionContext) {
      return null;
    }
    final overrideToCall = _step.toCall;
    final overridePot = _step.pot;
    final overrideHeroSeatId = _normalizedScenarioSeatIdV1(_step.heroSeatId);
    final overrideLegalKinds = _decisionLegalKindsFromStepOverrideV1(
      _step.allowedActions,
    );
    final expectedActionKind = world1SpineExpectedActionKindV1(_step);
    final hasActionSpec =
        expectedActionKind != null ||
        (_step.allowedActions?.isNotEmpty ?? false);
    final isPreflopLikeStep = _step.street == null;
    final seedBlindsIntoCommittedV1 = hasActionSpec && isPreflopLikeStep;
    final pointer = _buildCurrentCampaignPointerForDebug();
    if (pointer == null) {
      return _buildFallbackActionUiStateFromStepV1(
        overridePot: overridePot,
        overrideToCall: overrideToCall,
        overrideLegalKinds: overrideLegalKinds,
        overrideHeroSeatId: overrideHeroSeatId,
        seedBlindsIntoCommittedV1: seedBlindsIntoCommittedV1,
      );
    }
    final replayerScenario = _campaignSpineRunner.scenarioForPointer(pointer);
    final interop = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'w1_real_${pointer.packId}_${pointer.beatIndex}',
      replayer: replayerScenario,
    );
    if (!interop.isSuccess || interop.scenario == null) {
      return _buildFallbackActionUiStateFromStepV1(
        overridePot: overridePot,
        overrideToCall: overrideToCall,
        overrideLegalKinds: overrideLegalKinds,
        overrideHeroSeatId: overrideHeroSeatId,
        seedBlindsIntoCommittedV1: seedBlindsIntoCommittedV1,
      );
    }
    final snapshot = interop.scenario!.initialSnapshot;
    final legalActions = replayerScenario.steps.isEmpty
        ? const <ReplayerActionSpec>[]
        : replayerScenario.steps.first.legalActions;
    final legalKinds = <DecisionLegalKindV1>{
      for (final action in legalActions)
        switch (action.kind) {
          ReplayerActionKind.fold => DecisionLegalKindV1.fold,
          ReplayerActionKind.callCheck => DecisionLegalKindV1.callCheck,
          ReplayerActionKind.betRaise => DecisionLegalKindV1.betRaise,
        },
    };
    const hero = PlayerIdV1('hero');
    const villain = PlayerIdV1('villain');
    final heroSeatId = overrideHeroSeatId ?? 'btn';
    const villainSeatId = 'utg';
    final actingPlayer = snapshot.actingPlayer;
    final heroStack = snapshot.stacksState.stackFor(hero).value;
    final committed = snapshot.stacksState.committedFor(hero).value;
    final actingSeatId = snapshot.actingPlayer.value == 'hero'
        ? heroSeatId
        : villainSeatId;
    final inHandBySeatId = <String, bool>{
      heroSeatId: !(snapshot.foldedByPlayer[hero] ?? false),
      villainSeatId: !(snapshot.foldedByPlayer[villain] ?? false),
    };
    final foldedBySeatId = <String, bool>{
      heroSeatId: snapshot.foldedByPlayer[hero] ?? false,
      villainSeatId: snapshot.foldedByPlayer[villain] ?? false,
    };
    final toCallBySeatId = <String, int>{
      heroSeatId: snapshot.toCallFor(hero),
      villainSeatId: snapshot.toCallFor(villain),
    };
    var committedBySeatId = <String, int>{
      heroSeatId: snapshot.stacksState.committedFor(hero).value,
      villainSeatId: snapshot.stacksState.committedFor(villain).value,
    };
    final shouldSeedBlindsFromSnapshotV1 =
        seedBlindsIntoCommittedV1 && snapshot.street == StreetV1.preflop;
    if (shouldSeedBlindsFromSnapshotV1) {
      committedBySeatId = _seedBlindCommittedBySeatIdV1(committedBySeatId);
      inHandBySeatId['sb'] = true;
      inHandBySeatId['bb'] = true;
      foldedBySeatId['sb'] = false;
      foldedBySeatId['bb'] = false;
    }
    final potTruth = deriveCampaignActionPotTruthV1(
      committedBySeatId: committedBySeatId,
      actingSeatId: actingSeatId,
    );
    final toCallFromTruth = potTruth.toCallBySeatId[heroSeatId] ?? 0;
    final toCall = overrideToCall == 0 ? 0 : toCallFromTruth;
    final actionStatePot = potTruth.potTotal;
    final lastActionSeatId = _seatIdForPlayerIdV1(
      snapshot.lastAction?.actorId,
      heroSeatId: heroSeatId,
      villainSeatId: villainSeatId,
    );
    final lastAggressorSeatId =
        (snapshot.lastAction?.kind == ActionKindV1.bet ||
            snapshot.lastAction?.kind == ActionKindV1.raise)
        ? lastActionSeatId
        : null;
    final priceSettingActionKindV1 =
        (snapshot.lastAction?.kind == ActionKindV1.bet ||
            snapshot.lastAction?.kind == ActionKindV1.raise)
        ? snapshot.lastAction?.kind
        : null;
    final betOwnerSeatId = _deriveBetOwnerSeatIdV1(
      currentBet: potTruth.currentBet,
      committedBySeatId: committedBySeatId,
      inHandBySeatId: inHandBySeatId,
      explicitBetOwnerSeatId: lastAggressorSeatId,
      heroSeatId: heroSeatId,
      villainSeatId: villainSeatId,
    );
    final decisionModel = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: toCall,
      currentBet: potTruth.currentBet,
      minRaiseTo: replayerScenario.initialSnapshot.minRaiseTo,
      pot: actionStatePot,
      heroStack: heroStack,
      heroCommitted: committed,
      legalActions: overrideLegalKinds ?? legalKinds,
    );
    _debugLogPotInvariantViolationV1(
      potTotal: actionStatePot,
      sumCommitted: potTruth.sumCommitted,
      committedBySeatId: committedBySeatId,
      context: 'campaign_action_state',
    );
    return World1SurfacedActionStateV1(
      pot: actionStatePot,
      toCall: toCall,
      currentBet: potTruth.currentBet,
      heroStack: heroStack,
      decisionModel: decisionModel,
      actingSeatId: actingSeatId,
      inHandBySeatId: inHandBySeatId,
      foldedBySeatId: foldedBySeatId,
      toCallBySeatId: potTruth.toCallBySeatId,
      committedBySeatId: committedBySeatId,
      actingSeatToCall: potTruth.actingSeatToCall,
      lastActionSeatId: lastActionSeatId,
      lastAggressorSeatId: lastAggressorSeatId,
      priceSettingActionKindV1: priceSettingActionKindV1,
      betOwnerSeatId: betOwnerSeatId,
      hasBetOwnerInState: potTruth.currentBet <= 0 || betOwnerSeatId != null,
    );
  }

  World1SurfacedActionStateV1? _buildFallbackActionUiStateFromStepV1({
    required int? overridePot,
    required int? overrideToCall,
    required Set<DecisionLegalKindV1>? overrideLegalKinds,
    required String? overrideHeroSeatId,
    required bool seedBlindsIntoCommittedV1,
  }) {
    const hero = PlayerIdV1('hero');
    final toCall = ((overrideToCall ?? 0).clamp(0, 1 << 20) as num).toInt();
    final legacyDisplayPot =
        ((overridePot ?? math.max(10, toCall * 2)).clamp(0, 1 << 24) as num)
            .toInt();
    final currentBet = toCall;
    const heroStack = 100;
    const heroCommitted = 0;
    final minRaiseTo =
        currentBet + (math.max(10, toCall == 0 ? 10 : toCall) as num).toInt();
    final heroSeatId = overrideHeroSeatId ?? 'btn';
    const villainSeatId = 'utg';
    final inHandBySeatId = <String, bool>{
      heroSeatId: true,
      villainSeatId: true,
    };
    final foldedBySeatId = <String, bool>{
      heroSeatId: false,
      villainSeatId: false,
    };
    var committedBySeatId = <String, int>{
      heroSeatId: 0,
      villainSeatId: currentBet,
    };
    if (seedBlindsIntoCommittedV1) {
      committedBySeatId = _seedBlindCommittedBySeatIdV1(committedBySeatId);
      inHandBySeatId['sb'] = true;
      inHandBySeatId['bb'] = true;
      foldedBySeatId['sb'] = false;
      foldedBySeatId['bb'] = false;
    }
    final potTruth = deriveCampaignActionPotTruthV1(
      committedBySeatId: committedBySeatId,
      actingSeatId: heroSeatId,
    );
    final pot = potTruth.potTotal;
    final betOwnerSeatId = _deriveBetOwnerSeatIdV1(
      currentBet: potTruth.currentBet,
      committedBySeatId: committedBySeatId,
      inHandBySeatId: inHandBySeatId,
      explicitBetOwnerSeatId: villainSeatId,
      heroSeatId: heroSeatId,
      villainSeatId: villainSeatId,
    );
    final decisionModel = DecisionBarV1.buildFromSnapshot(
      heroId: hero,
      toCall: potTruth.toCallBySeatId[heroSeatId] ?? 0,
      currentBet: potTruth.currentBet,
      minRaiseTo: minRaiseTo,
      pot: pot,
      heroStack: heroStack,
      heroCommitted: heroCommitted,
      legalActions: overrideLegalKinds ?? const <DecisionLegalKindV1>{},
    );
    _debugLogPotInvariantViolationV1(
      potTotal: pot,
      sumCommitted: potTruth.sumCommitted,
      committedBySeatId: committedBySeatId,
      context: 'fallback_action_state legacyDisplayPot=$legacyDisplayPot',
    );
    return World1SurfacedActionStateV1(
      pot: pot,
      toCall: potTruth.toCallBySeatId[heroSeatId] ?? 0,
      currentBet: potTruth.currentBet,
      heroStack: heroStack,
      decisionModel: decisionModel,
      actingSeatId: heroSeatId,
      inHandBySeatId: inHandBySeatId,
      foldedBySeatId: foldedBySeatId,
      toCallBySeatId: potTruth.toCallBySeatId,
      committedBySeatId: committedBySeatId,
      actingSeatToCall: potTruth.actingSeatToCall,
      lastActionSeatId: villainSeatId,
      lastAggressorSeatId: villainSeatId,
      priceSettingActionKindV1: ActionKindV1.raise,
      betOwnerSeatId: betOwnerSeatId,
      hasBetOwnerInState: potTruth.currentBet <= 0 || betOwnerSeatId != null,
    );
  }

  static const int _smallBlindCommittedUnitsV1 = 1;
  static const int _bigBlindCommittedUnitsV1 = 2;

  Map<String, int> _seedBlindCommittedBySeatIdV1(Map<String, int> source) {
    final seeded = Map<String, int>.from(source);
    seeded['sb'] = math.max(seeded['sb'] ?? 0, _smallBlindCommittedUnitsV1);
    seeded['bb'] = math.max(seeded['bb'] ?? 0, _bigBlindCommittedUnitsV1);
    return seeded;
  }

  void _debugLogPotInvariantViolationV1({
    required int potTotal,
    required int sumCommitted,
    required Map<String, int> committedBySeatId,
    required String context,
  }) {
    if (!kDebugMode || potTotal == sumCommitted) {
      return;
    }
    final pointer = _buildCurrentCampaignPointerForDebug();
    final pointerText = pointer == null
        ? 'pointer=n/a'
        : 'packId=${pointer.packId} beat=${pointer.beatIndex} beatPrompt="${pointer.beat.prompt}"';
    debugPrint(
      '[POT_INVARIANT_V1] violation context=$context $pointerText '
      'potTotal=$potTotal sumCommitted=$sumCommitted committedBySeatId=$committedBySeatId',
    );
    assert(
      potTotal == sumCommitted,
      'pot invariant violated: potTotal=$potTotal sumCommitted=$sumCommitted context=$context',
    );
  }

  String? _deriveBetOwnerSeatIdV1({
    required int currentBet,
    required Map<String, int> committedBySeatId,
    required Map<String, bool> inHandBySeatId,
    required String? explicitBetOwnerSeatId,
    required String heroSeatId,
    required String villainSeatId,
  }) {
    if (currentBet <= 0) return null;
    if (explicitBetOwnerSeatId != null &&
        (inHandBySeatId[explicitBetOwnerSeatId] ?? true)) {
      return explicitBetOwnerSeatId;
    }
    final owners = committedBySeatId.entries
        .where((entry) => entry.value == currentBet)
        .where((entry) => inHandBySeatId[entry.key] ?? true)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (owners.length == 1) {
      return owners.first;
    }
    if ((inHandBySeatId[heroSeatId] ?? false) &&
        (committedBySeatId[heroSeatId] ?? 0) >= currentBet) {
      return heroSeatId;
    }
    if ((inHandBySeatId[villainSeatId] ?? false) &&
        (committedBySeatId[villainSeatId] ?? 0) >= currentBet) {
      return villainSeatId;
    }
    return null;
  }

  String? _seatIdForPlayerIdV1(
    PlayerIdV1? playerId, {
    required String heroSeatId,
    required String villainSeatId,
  }) {
    if (playerId == null) return null;
    if (playerId.value == 'hero') return heroSeatId;
    if (playerId.value == 'villain') return villainSeatId;
    return null;
  }

  bool _showExtendedHudDetailsV1({required bool compactPortrait}) {
    return _campaignHudDetailsExpanded && !compactPortrait;
  }

  int get _expectedSeatIdsCountV1 =>
      _step.expectedSeatIds.where((id) => id.trim().isNotEmpty).length;

  int get _allowedActionsCountV1 => (_step.allowedActions ?? const <String>[])
      .where((action) => action.trim().isNotEmpty)
      .length;

  bool get _showWorld1IntroPreludeSurfaceV1 =>
      buildWorld1IntroPreludeAdapterV1().shouldShowIntroSurface(
        preludeVisible: _showSeatQuizPreludeV1,
        introVisible: _showIntroSequenceV1,
      );

  String _debugModeResolvedLabelV1() {
    if (_outcomeSurfaceVisible) {
      return 'outcome';
    }
    if (_showWorld1IntroPreludeSurfaceV1) {
      return 'intro';
    }
    return _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz
        ? 'seat_quiz'
        : 'action_decision';
  }

  String _debugModeReasonV1({
    required int expectedSeatIdsCount,
    required int allowedActionsCount,
    required ActionKindV1? expectedActionKind,
  }) {
    if (expectedActionKind != null) {
      return 'expectedActionKind';
    }
    if (allowedActionsCount > 0) {
      return 'allowedActions';
    }
    if (expectedSeatIdsCount > 0) {
      return 'expectedSeatIds';
    }
    return 'fallback';
  }

  bool _isSeatQuizByStepDataV1({required ActionKindV1? expectedActionKind}) {
    final hasExpectedSeatIds = _expectedSeatIdsCountV1 > 0;
    final hasAllowedActions = _allowedActionsCountV1 > 0;
    final hasExpectedAction = expectedActionKind != null;
    final guidedScope = _step.guidedScope?.trim().toLowerCase();
    return hasExpectedSeatIds &&
        !hasAllowedActions &&
        !hasExpectedAction &&
        guidedScope == 'seats';
  }

  double _computePortraitTableHeightV1({
    required Size mediaSize,
    required BoxConstraints tableConstraints,
    required bool seatQuizMode,
    bool useLiveReferenceParityV1 = false,
  }) {
    final targetHeight =
        (mediaSize.height * (useLiveReferenceParityV1 ? 0.85 : 0.66)).clamp(
          useLiveReferenceParityV1 ? 590.0 : 430.0,
          760.0,
        );
    final maxAllowedHeight = tableConstraints.maxHeight.isFinite
        ? tableConstraints.maxHeight
        : targetHeight;
    final minAllowedHeight = maxAllowedHeight < 320.0
        ? maxAllowedHeight
        : 320.0;
    return targetHeight.clamp(minAllowedHeight, maxAllowedHeight).toDouble();
  }

  _CampaignRunnerMode _resolveCampaignRunnerModeForCurrentStep() {
    final stepIndicatesActionDecision =
        (_step.allowedActions?.isNotEmpty ?? false) ||
        world1SpineExpectedActionKindV1(_step) != null;
    final normalizedPack = widget.moduleId.trim().toLowerCase();
    final pointer = _buildCurrentCampaignPointerForDebug();
    final replayerScenario = pointer == null
        ? null
        : _campaignSpineRunner.scenarioForPointer(pointer);
    final legalActions = replayerScenario?.steps.isNotEmpty == true
        ? replayerScenario!.steps.first.legalActions
        : const <ActionV1>[];
    final interopAvailable =
        pointer != null &&
        replayerScenario != null &&
        replayerScenario.steps.isNotEmpty &&
        legalActions.isNotEmpty &&
        (() {
          final interop = const ReplayerToEngineV2AdapterV1().tryConvert(
            scenarioId: 'w1_real_${pointer.packId}_${pointer.beatIndex}',
            replayer: replayerScenario,
          );
          return interop.isSuccess && interop.scenario != null;
        })();
    final resolved = resolveWorld1CanonicalRunnerModeV1(
      isWorld2SeatQuizBeat: _isWorld2SeatQuizBeatV1,
      stepIndicatesActionDecision: stepIndicatesActionDecision,
      isCampaignSpineSession: _isCampaignSpineSession,
      packContainsTableLiteracy: normalizedPack.contains('table_literacy'),
      hasCampaignPointer: pointer != null,
      replayerHasSteps: replayerScenario?.steps.isNotEmpty == true,
      legalActionsPresent: legalActions.isNotEmpty,
      engineInteropAvailable: interopAvailable,
    );
    return resolved == World1CanonicalRunnerModeV1.handLoop
        ? _CampaignRunnerMode.handLoop
        : _CampaignRunnerMode.seatQuiz;
  }

  void _onCampaignActionTap(ActionV1 action) {
    final plan = resolveWorld1CanonicalCampaignActionTapPlanV1(
      isLockInBlocked: _isLockInBlocked,
      action: action,
    );
    if (plan.shouldIgnoreTap) return;
    if (plan.shouldMarkDecisionTap) {
      _markDebugDecisionTapV1();
    }
    unawaited(
      _runCampaignHandLoopFromLockIn(
        heroActionOverride: plan.heroActionOverride,
      ),
    );
  }

  List<String> _buildTurnFeedLines(ReplayTraceV1 trace) {
    final lines = <String>[];
    StreetV1? previousStreet;
    int? previousPot;
    for (final entry in trace.entries) {
      final step = entry.step;
      final snapshot = entry.result.state.snapshot;
      final pot = snapshot.stacksState.pot.value;
      if (previousPot != null && pot != previousPot) {
        lines.add('Pot -> ${_unitsToBbDisplayV1(pot)} BB');
      }
      previousPot = pot;
      if (step is PlayerActionStepV1) {
        final actor = step.playerId.value == 'hero' ? 'Hero' : 'Villain';
        lines.add('$actor: ${step.action.kind.name.toUpperCase()}');
      } else if (step is AdvanceStepV1) {
        final street = snapshot.street;
        if (street != previousStreet) {
          lines.add('Street -> ${street.name.toUpperCase()}');
        }
        previousStreet = street;
      }
      if (lines.length >= 5) {
        break;
      }
    }
    return List<String>.unmodifiable(lines);
  }

  void _emitSessionEnd(String result) {
    if (_sessionTerminalEventSent) return;
    _sessionTerminalEventSent = true;
    _emitTelemetry('session_end', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
      'result': result,
      'duration_ms': _elapsedMs(_sessionStartedAt),
    });
    _emitDebugLearningEffectSummaryIfNeededV1();
    unawaited(_emitSessionEndEmotionTelemetryV1());
  }

  Future<void> _loadBeforeSessionPhraseV1() async {
    final payload =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.beforeSession,
        );
    final text = (payload['text'] ?? '').toString().trim();
    if (!mounted || text.isEmpty) return;
    setState(() {
      _beforeSessionPhraseTextV1 = text;
    });
  }

  Future<void> _emitSessionStartEmotionPhraseV1() async {
    final payload =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.beforeSession,
        );
    _emitTelemetry('emotion_phrase_shown_v1', payload);
  }

  Future<void> _emitSessionEndEmotionTelemetryV1() async {
    final tagPayload = await ProgressService.getEmotionTagTelemetryPayloadV1();
    _emitTelemetry('emotion_tag_v1', tagPayload);
    final phrasePayload =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.afterOutcome,
        );
    final text = (phrasePayload['text'] ?? '').toString().trim();
    if (mounted && text.isNotEmpty) {
      setState(() {
        _afterOutcomePhraseTextV1 = text;
      });
    }
    _emitTelemetry('emotion_phrase_shown_v1', phrasePayload);
  }

  void _dismissPreludeInteractionsV1() {
    _requestDismissGlobalTrainingIntroPreludeFromInteractionV1();
    _requestDismissWorld1IntroPreludeFromInteractionV1();
    _requestDismissWorld1ActionIntroPreludeFromInteractionV1();
    _requestDismissWorld1StreetFlowIntroPreludeFromInteractionV1();
    _requestDismissWorld2HandoffPreludeFromInteractionV1();
    _requestDismissWorld2IntroPreludeFromInteractionV1();
    _requestDismissTrackIntroPreludeFromInteractionV1();
  }

  void _selectSeat(String seatId) {
    final introStep = _introSequenceStepV1;
    final plan = resolveWorld1CanonicalSeatTapPlanV1(
      seatId: seatId,
      currentModeIsSeatQuiz:
          _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz,
      introStepRequiresSeatTap: introStep?.requiresSeatTap ?? false,
      introStepSeatId: introStep?.seatId,
      isCampaignSpineSession: _isCampaignSpineSession,
      campaignSeatQuizMode:
          _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz,
      showSeatQuizPrelude: _showSeatQuizPreludeV1,
      showIntroSequence: _showIntroSequenceV1,
      outcomeSurfaceVisible: _outcomeSurfaceVisible,
      completionInProgress: _completionInProgress,
    );
    if (plan.shouldPlayTapSound) {
      UiSoundV1.fire(UiSoundEventV1.tap);
    }
    if (plan.shouldMarkDecisionTap) {
      _markDebugDecisionTapV1();
    }
    if (plan.shouldDismissInteractivePreludes) {
      _dismissPreludeInteractionsV1();
    }
    if (plan.selectionState.shouldIgnoreTap) {
      return;
    }
    setState(() {
      _selectedSeatId = plan.selectionState.selectedSeatId;
      if (plan.selectionState.introStepSatisfied) {
        _introStepSatisfiedV1 = true;
      }
      _feedback = plan.selectionState.feedback;
    });
    if (plan.selectionState.shouldAutoRunSeatQuizCheck) {
      _runSeatQuizCheckFlow(decisionMs: _elapsedMs(_decisionStartedAt));
    }
  }

  void _triggerSuccessPulse() {
    _successPulseTimer?.cancel();
    if (!_microAnimationsEnabled) {
      if (!mounted) return;
      setState(() {
        _pulseSuccess = false;
        _pulseFailure = false;
      });
      return;
    }
    setState(() {
      _pulseSuccess = true;
      _pulseFailure = false;
    });
    _successPulseTimer = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() {
        _pulseSuccess = false;
      });
    });
  }

  void _triggerFailurePulse() {
    _failurePulseTimer?.cancel();
    _failureShakeTimer?.cancel();
    if (!_microAnimationsEnabled) {
      if (!mounted) return;
      setState(() {
        _pulseFailure = false;
        _pulseSuccess = false;
        _failureShakeDx = 0;
      });
      return;
    }
    setState(() {
      _pulseFailure = true;
      _pulseSuccess = false;
      _failureShakeDx = -0.01;
    });
    _failureShakeTimer = Timer(const Duration(milliseconds: 70), () {
      if (!mounted) return;
      setState(() {
        _failureShakeDx = 0.01;
      });
    });
    _failureShakeTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _failureShakeDx = 0;
      });
    });
    _failurePulseTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _pulseFailure = false;
      });
    });
  }

  void _triggerBustPulse() {
    _bustPulseTimer?.cancel();
    if (!_microAnimationsEnabled) {
      if (!mounted) return;
      setState(() {
        _pulseBust = false;
      });
      return;
    }
    setState(() {
      _pulseBust = true;
    });
    _bustPulseTimer = Timer(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() {
        _pulseBust = false;
      });
    });
  }

  void _showSuccessBadge(String text, {Duration? duration}) {
    _successBadgeTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _successBadgeText = text;
    });
    _successBadgeTimer = Timer(
      duration ?? const Duration(milliseconds: 420),
      () {
        if (!mounted) return;
        setState(() {
          _successBadgeText = null;
        });
      },
    );
  }

  Future<void> _applyCampaignConsequence(
    bool isCorrect, {
    required int handIndex,
    required int mistakesCountSoFar,
  }) async {
    if (!_isCampaignSpineSession) return;
    const basePositiveDelta = 8;
    const baseNegativeDelta = -6;
    final multiplier = ProgressService.stakeMultiplierForPackIdV1(
      widget.moduleId,
    );
    final rawDelta =
        ((isCorrect ? basePositiveDelta : baseNegativeDelta) * multiplier) ~/
        10;
    final delta = applyWorld1FairnessShieldDeltaV1(
      packId: widget.moduleId,
      isCorrect: isCorrect,
      rawDelta: rawDelta,
    );
    final worldIndex = ProgressService.worldIndexForPackIdV1(widget.moduleId);
    final bankroll = await ProgressService.applySpineBankrollDelta(delta);
    if (!mounted) return;
    setState(() {
      _spineDelta = delta;
      _spineSessionDelta += delta;
      _spineBankroll = bankroll;
      if (isCorrect) {
        _spineCorrectCount += 1;
      }
    });
    _emitTelemetry(TelemetryEvents.campaignHandResult, <String, dynamic>{
      'pack_id': widget.moduleId,
      'hand_index': handIndex,
      'correct': isCorrect,
      'delta': delta,
      'bankroll_after': bankroll,
      'mistakes_count_so_far': mistakesCountSoFar,
      'world_index': worldIndex,
      'multiplier': multiplier,
    });
    if (bankroll <= 0 && !_spineBustEventSent) {
      _spineBustEventSent = true;
      _triggerBustPulse();
      unawaited(AudioService.instance.playUiSfx('bust'));
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      _emitTelemetry(TelemetryEvents.campaignBust, <String, dynamic>{
        'pack_id': widget.moduleId,
        'hand_index': handIndex,
        'bankroll_after': bankroll,
      });
    }
  }

  int _pressureLineClamp(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return 1;
    if (width < 820) return 2;
    return 2;
  }

  void _onCheck() {
    final plan = resolveWorld1CanonicalCheckPlanV1(
      isWorld2SeatQuizBeat: _isWorld2SeatQuizBeatV1,
      isCampaignSpineSession: _isCampaignSpineSession,
      currentModeIsHandLoop:
          _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop,
    );
    if (plan.shouldMarkDecisionTap) {
      _markDebugDecisionTapV1();
    }
    switch (plan.route) {
      case World1CanonicalCheckRouteV1.seatQuizCheck:
        _runSeatQuizCheckFlow(decisionMs: _elapsedMs(_decisionStartedAt));
      case World1CanonicalCheckRouteV1.handLoopRun:
        unawaited(_runCampaignHandLoopFromLockIn());
    }
  }

  void _continueSeatQuizPreludeV1() {
    final introSteps = _activeIntroSequenceStepsV1;
    final state = resolveWorld1CanonicalSeatQuizPreludeContinueStateV1(
      firstIntroStepRequiresSeatTap: introSteps.isNotEmpty
          ? introSteps[0].requiresSeatTap
          : true,
    );
    setState(() {
      _preludeDismissedV1 = state.preludeDismissed;
      _introDismissedV1 = state.introDismissed;
      _introSequenceIndexV1 = state.introSequenceIndex;
      _introStepSatisfiedV1 = state.introStepSatisfied;
      _selectedSeatId = state.selectedSeatId;
    });
  }

  void _continueIntroSequenceV1() {
    final nextIndex = _introSequenceIndexV1 + 1;
    final introSteps = _activeIntroSequenceStepsV1;
    final state = resolveWorld1CanonicalIntroSequenceContinueStateV1(
      isIntroContinueEnabled: _isIntroContinueEnabledV1,
      introSequenceIndex: _introSequenceIndexV1,
      totalIntroSteps: introSteps.length,
      nextStepRequiresSeatTap: nextIndex < introSteps.length
          ? introSteps[nextIndex].requiresSeatTap
          : true,
    );
    if (state.shouldIgnore) {
      return;
    }
    setState(() {
      _introDismissedV1 = state.introDismissed;
      _introSequenceIndexV1 = state.introSequenceIndex;
      _introStepSatisfiedV1 = state.introStepSatisfied;
      _selectedSeatId = state.selectedSeatId;
    });
  }

  void _runSeatQuizCheckFlow({required int decisionMs}) {
    _markDebugEngineStartV1();
    final autoAdvanceSeatQuizFlow =
        !_isCampaignSpineSession &&
        (_isTablePracticeSession || _isDailyRunSession);
    final selected = _selectedSeatId;
    if (selected == null) {
      _emitTelemetry('user_choice', <String, dynamic>{
        'module_id': widget.moduleId,
        'mode': _mode,
        'step_index': _stepIndex,
        'choice': 'none',
      });
      _emitTelemetry('correct', <String, dynamic>{
        'module_id': widget.moduleId,
        'mode': _mode,
        'step_index': _stepIndex,
        'correct': false,
        'error_type': 'no_selection',
      });
      final resolutionStateV1 = resolveWorld1CanonicalSeatQuizResolutionStateV1(
        const World1CanonicalSeatQuizResolutionInputV1(
          kind: World1CanonicalSeatQuizResolutionKindV1.noSelection,
          isCampaignSpineSession: false,
          attempts: 0,
          wrongAttemptsCount: 0,
          negativeDelta: 0,
          conceptFirstSeatMicroSlice: false,
          actionLiteracyMicroSlice: false,
          streetFlowMicroSlice: false,
          conceptFirstSeatReinforceLine: '',
          actionLiteracyReinforceLine: '',
          streetFlowReinforceLine: '',
          insightText: null,
        ),
      );
      setState(() {
        _feedback = resolutionStateV1.feedback;
      });
      _markDebugEngineDoneV1();
      _markDebugPostEngineDoneV1();
      final seatQuizPrepStartUs = kDebugMode
          ? DateTime.now().toUtc().microsecondsSinceEpoch
          : 0;
      _showOutcomeSurfaceProfiledV1(
        isCorrect: false,
        reason: 'No seat selected.',
        errorType: 'timing',
        nextHint: 'Tap one seat.',
        onContinue: () async {
          if (!mounted) return;
          _clearOutcomeSurfaceOnly();
        },
        continueAdvancesFlow: false,
        autoContinue: autoAdvanceSeatQuizFlow,
        primaryCtaLabel: 'TRY AGAIN',
        showRetrySecondary: false,
      );
      if (kDebugMode) {
        _debugPreShowSeatQuizPrepUsV1 =
            DateTime.now().toUtc().microsecondsSinceEpoch - seatQuizPrepStartUs;
      }
      return;
    }
    _emitTelemetry('user_choice', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
      'step_index': _stepIndex,
      'choice': selected,
    });

    final expectedSeatIds = _seatQuizExpectedSeatIdsV1.toSet();
    final targetSeatId = _seatQuizTargetSeatIdV1;
    final normalizedSelectedSeatId = selected.trim().toLowerCase();
    final isCorrect = expectedSeatIds.length == 1
        ? targetSeatId == normalizedSelectedSeatId
        : expectedSeatIds.contains(normalizedSelectedSeatId);
    if (kDebugMode) {
      debugPrint(
        'seat_quiz_target=${targetSeatId ?? 'n/a'} '
        'expected=${expectedSeatIds.toList()..sort()} '
        'chosen=$normalizedSelectedSeatId',
      );
    }
    _guidedConsumedSteps.add(_stepIndex);
    if (!isCorrect) {
      _emitTelemetry('correct', <String, dynamic>{
        'module_id': widget.moduleId,
        'mode': _mode,
        'step_index': _stepIndex,
        'correct': false,
        'error_type': 'expected_seat_mismatch',
      });
      UiSoundV1.fire(UiSoundEventV1.error);
      unawaited(AudioService.instance.playUiSfx('chip_lose'));
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      final attempts = (_wrongAttemptsByStep[_stepIndex] ?? 0) + 1;
      _wrongAttemptsByStep[_stepIndex] = attempts;
      final negativeDelta =
          ((-6) *
              ProgressService.stakeMultiplierForPackIdV1(widget.moduleId)) ~/
          10;
      _triggerFailurePulse();
      unawaited(
        _applyCampaignConsequence(
          false,
          handIndex: _stepIndex,
          mistakesCountSoFar: _wrongAttemptsByStep.length,
        ),
      );
      final resolutionStateV1 = resolveWorld1CanonicalSeatQuizResolutionStateV1(
        World1CanonicalSeatQuizResolutionInputV1(
          kind: World1CanonicalSeatQuizResolutionKindV1.incorrect,
          isCampaignSpineSession: _isCampaignSpineSession,
          attempts: attempts,
          wrongAttemptsCount: _wrongAttemptsByStep.length,
          negativeDelta: negativeDelta,
          conceptFirstSeatMicroSlice: false,
          actionLiteracyMicroSlice: false,
          streetFlowMicroSlice: false,
          conceptFirstSeatReinforceLine: '',
          actionLiteracyReinforceLine: '',
          streetFlowReinforceLine: '',
          insightText: null,
        ),
      );
      setState(() {
        _spineMistakesCount = resolutionStateV1.spineMistakesCount!;
        _showHint = resolutionStateV1.showHint!;
        _feedback = resolutionStateV1.feedback;
      });
      final expectedSeatOrder = expectedSeatIds.toList()..sort();
      final expectedLabel = expectedSeatOrder.isEmpty
          ? 'N/A'
          : expectedSeatOrder.map(_seatQuizSeatDisplayV1).join('/');
      final chosenLabel = _seatQuizSeatDisplayV1(normalizedSelectedSeatId);
      final incorrectReasonLine = _seatQuizExpectedChosenFeedbackLineV1(
        expectedLabel: expectedLabel,
        chosenLabel: chosenLabel,
      );
      _markDebugEngineDoneV1();
      _markDebugPostEngineDoneV1();
      final seatQuizPrepStartUs = kDebugMode
          ? DateTime.now().toUtc().microsecondsSinceEpoch
          : 0;
      _showOutcomeSurfaceProfiledV1(
        isCorrect: false,
        reason: 'Incorrect seat.',
        errorType: 'expected_seat_mismatch',
        nextHint: incorrectReasonLine,
        onContinue: () async {
          if (!mounted) return;
          if (_isDailyRunSession) {
            await _completeStepFlow();
            return;
          }
          if (_isInReviewPass) {
            await _completeStepFlow();
            return;
          }
          _clearOutcomeSurfaceOnly();
        },
        continueAdvancesFlow:
            _isDailyRunSession || _isInReviewPass || attempts >= 2,
        autoContinue: autoAdvanceSeatQuizFlow,
        primaryCtaLabel: 'CONTINUE',
        showRetrySecondary: false,
      );
      if (kDebugMode) {
        _debugPreShowSeatQuizPrepUsV1 =
            DateTime.now().toUtc().microsecondsSinceEpoch - seatQuizPrepStartUs;
      }
      if (!_isInReviewPass) {
        _queueCurrentStepForReview();
      }
      return;
    }
    _emitTelemetry('correct', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
      'step_index': _stepIndex,
      'correct': true,
      'error_type': 'none',
    });
    _emitTelemetry('time_to_decision', <String, dynamic>{
      'module_id': widget.moduleId,
      'mode': _mode,
      'step_index': _stepIndex,
      'time_to_decision_ms': decisionMs,
    });

    UiSoundV1.fire(UiSoundEventV1.success);
    unawaited(AudioService.instance.playUiSfx('chip_win'));
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
    _triggerSuccessPulse();
    unawaited(
      _applyCampaignConsequence(
        true,
        handIndex: _stepIndex,
        mistakesCountSoFar: _wrongAttemptsByStep.length,
      ),
    );
    final positiveDelta =
        (8 * ProgressService.stakeMultiplierForPackIdV1(widget.moduleId)) ~/ 10;
    final successBadgeText = _isCampaignSpineSession
        ? '+$positiveDelta chips'
        : '+XP';
    _showSuccessBadge(successBadgeText);
    final resolutionStateV1 = resolveWorld1CanonicalSeatQuizResolutionStateV1(
      World1CanonicalSeatQuizResolutionInputV1(
        kind: World1CanonicalSeatQuizResolutionKindV1.correct,
        isCampaignSpineSession: _isCampaignSpineSession,
        attempts: 0,
        wrongAttemptsCount: 0,
        negativeDelta: 0,
        conceptFirstSeatMicroSlice: _isConceptFirstSeatMicroSliceV1,
        actionLiteracyMicroSlice: _isActionLiteracyMicroSliceV1,
        streetFlowMicroSlice: _isStreetFlowMicroSliceV1,
        conceptFirstSeatReinforceLine: _conceptFirstSeatReinforceLineV1(),
        actionLiteracyReinforceLine: _actionLiteracyReinforceLineV1(),
        streetFlowReinforceLine: _streetFlowReinforceLineV1(),
        insightText: _step.insightText,
      ),
    );
    if (resolutionStateV1.feedback != null) {
      setState(() {
        _feedback = resolutionStateV1.feedback;
      });
    }
    _markDebugEngineDoneV1();
    _markDebugPostEngineDoneV1();
    final seatQuizPrepStartUs = kDebugMode
        ? DateTime.now().toUtc().microsecondsSinceEpoch
        : 0;
    _clearOutcomeSurfaceOnly();
    if (mounted) {
      setState(() {
        _seatQuizAutoAdvancePendingV1 =
            resolutionStateV1.seatQuizAutoAdvancePending!;
      });
    }
    unawaited(_completeStepFlow());
    if (kDebugMode) {
      _debugPreShowSeatQuizPrepUsV1 =
          DateTime.now().toUtc().microsecondsSinceEpoch - seatQuizPrepStartUs;
    }
  }

  String _checkpointAnchorModuleId() {
    switch (widget.checkpointId) {
      case 3:
        return 'intro_actions';
      case 6:
        return 'core_rules_and_setup';
      default:
        return widget.moduleId;
    }
  }

  Future<void> _completeCheckpointAndOpenResult() async {
    if (_completionInProgress) return;
    _completionInProgress = true;
    _emitSessionEnd('completed');
    if (!mounted) return;
    _checkpointCompleteTimer?.cancel();
    setState(() {
      _showCheckpointCompleteBadge = true;
    });
    _checkpointCompleteTimer = Timer(
      const Duration(milliseconds: 320),
      () async {
        if (!mounted) return;
        final personalizationResult = await _buildPersonalizationResultV1();
        pushReplacementSessionResultV1<void, void>(
          context,
          correctCount: _steps.length,
          totalCount: _steps.length,
          moduleId: _checkpointAnchorModuleId(),
          personalizationResultV1: personalizationResult,
          campaignPersonalizationHint: personalizationResult?.shortHintText,
        );
      },
    );
  }

  Future<void> _completeTablePracticeAndOpenResult() async {
    if (_completionInProgress) return;
    _completionInProgress = true;
    _emitSessionEnd('completed');
    var streak = 0;
    try {
      await ProgressService.checkInStreak();
      await ReturnLoopServiceV1.instance.updateOnAppOpenOrProgressMapShown();
      streak = await ProgressService.getStreak();
    } catch (_) {
      // Keep completion resilient and avoid blocking result navigation.
    }
    if (!mounted) return;
    _loopRewardBannerTimer?.cancel();
    _completionNavigateTimer?.cancel();
    _showSuccessBadge('Streak +1', duration: const Duration(milliseconds: 520));
    setState(() {
      _loopRewardBanner = streak > 0 ? 'Streak $streak' : 'Streak +1';
    });
    _completionNavigateTimer = Timer(
      const Duration(milliseconds: 360),
      () async {
        if (!mounted) return;
        setState(() {
          _loopRewardBanner = null;
        });
        final personalizationResult = await _buildPersonalizationResultV1();
        pushReplacementSessionResultV1<void, void>(
          context,
          correctCount: _steps.length,
          totalCount: _steps.length,
          moduleId: widget.moduleId,
          personalizationResultV1: personalizationResult,
          campaignPersonalizationHint: personalizationResult?.shortHintText,
        );
      },
    );
  }

  Future<void> _completePackAndClose() async {
    if (_completionInProgress) {
      return;
    }
    _completionInProgress = true;
    _emitSessionEnd('completed');
    var rewardLabel = '+0 XP';
    var streakLabel = '';
    try {
      final alreadyCompletedToday = _isDailyRunSession
          ? (ProgressService.world1DailyCompletionInSession.value ||
                await ProgressService.isWorld1DailyCompletedToday())
          : _dailyCompletedInSession;
      if (!alreadyCompletedToday) {
        await ProgressService.addXp(15);
        await ProgressService.checkInStreak();
        await ReturnLoopServiceV1.instance.updateOnAppOpenOrProgressMapShown();
        final streak = await ProgressService.getStreak();
        rewardLabel = '+15 XP';
        streakLabel = ' · Streak $streak';
        _dailyCompletedInSession = true;
        if (_isDailyRunSession) {
          await ProgressService.markWorld1DailyCompletedToday();
          ProgressService.world1DailyCompletionInSession.value = true;
        }
      } else {
        if (_isDailyRunSession) {
          ProgressService.world1DailyCompletionInSession.value = true;
        }
        rewardLabel = 'Daily completed';
      }
    } catch (_) {
      // Keep completion resilient; display-only fallback is allowed.
    }
    if (!mounted) return;
    _loopRewardBannerTimer?.cancel();
    _showSuccessBadge(rewardLabel, duration: const Duration(milliseconds: 650));
    _dailyCompletedBadgeTimer?.cancel();
    setState(() {
      _loopRewardBanner = '$rewardLabel$streakLabel';
      _showDailyCompletedBadge = _isDailyRunSession;
    });
    _dailyCompletedBadgeTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _showDailyCompletedBadge = false;
      });
    });
    _loopRewardBannerTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _loopRewardBanner = null;
      });
      Navigator.of(context).pop(true);
    });
  }

  Future<void> _completeReviewQueueSessionV1() async {
    if (_completionInProgress) return;
    _completionInProgress = true;
    _emitSessionEnd('completed');
    final packId = widget.moduleId.trim().toLowerCase();
    try {
      if (packId.isNotEmpty) {
        await ProgressService.clearReviewQueueForPackV1(packId);
      }
    } catch (_) {
      // Non-blocking; still finish the review session flow.
    }
    if (!_reviewQueueCompletedTelemetrySentV1) {
      _reviewQueueCompletedTelemetrySentV1 = true;
      _emitTelemetry(TelemetryEvents.reviewQueueCompletedV1, <String, dynamic>{
        'packId': packId,
        'reviewed_count': _reviewQueueLaunchCountV1,
        'source': 'runner',
      });
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _completeCampaignSpineAndOpenResult() async {
    if (_completionInProgress) return;
    if (mounted) {
      setState(() {
        _completionInProgress = true;
      });
    } else {
      _completionInProgress = true;
    }
    _emitSessionEnd('completed');
    final mistakesCount = _wrongAttemptsByStep.length;
    final qualityScore = (_steps.length - mistakesCount).clamp(
      0,
      _steps.length,
    );
    final rank = ProgressService.resolveSpineRankFromQuality(
      correctCount: qualityScore,
      totalCount: _steps.length,
    );
    final calibrationBand = ProgressService.resolveSpineCalibrationBand(
      qualityScore: qualityScore,
      mistakesCount: mistakesCount,
    );
    final packId = widget.moduleId.trim().toLowerCase();
    await ProgressService.setSpineRankV1(rank);
    if (_isCampaignSpinePackId(packId)) {
      await _markCalibrationCompletedForCampaignPack(
        packId: packId,
        calibrationBand: calibrationBand,
      );
    }
    CampaignSpineCompletionV1? runnerCompletion;
    OutcomeSummaryV1? outcomeSummary;
    String? personalizationHint;
    PersonalizedRecommendationV1? personalizationResult;
    try {
      final runPlan = await _campaignSpineRunner.startRun();
      if (runPlan.pointer.packId == widget.moduleId &&
          runPlan.pointer.beatIndex == _stepIndex) {
        final runResult = _campaignSpineRunner.runScenario(plan: runPlan);
        runnerCompletion = await _campaignSpineRunner.completeRun(
          plan: runPlan,
          result: runResult,
        );
        outcomeSummary = _campaignSpineRunner.buildOutcomeSummary(
          plan: runPlan,
          result: runResult,
        );
        personalizationResult = await _buildPersonalizationResultV1(
          outcomeSummary: outcomeSummary,
        );
        personalizationHint =
            personalizationResult?.shortHintText ?? buildHint(outcomeSummary);
      }
    } catch (_) {
      runnerCompletion = null;
      outcomeSummary = null;
      personalizationHint = null;
      personalizationResult = null;
    }
    if (runnerCompletion == null) {
      await ProgressService.markSpinePackCompletedV1(packId);
      await ProgressService.clearSpineActivePackV1();
      await ProgressService.setSpineNextHandIndexV1(0);
    }
    _emitTelemetry(TelemetryEvents.campaignPackEnd, <String, dynamic>{
      'pack_id': packId,
      'hands_completed': _steps.length,
      'net_delta': _spineSessionDelta,
      'bankroll_after': _spineBankroll,
      'quality_score': qualityScore,
    });
    if (_isCampaignSpinePackId(packId)) {
      _emitTelemetry(
        TelemetryEvents.campaignCalibrationResolved,
        <String, dynamic>{
          'pack_id': packId,
          'band': calibrationBand,
          'mistakes': mistakesCount,
          'quality_score': qualityScore,
        },
      );
    }
    if (!mounted) return;
    setState(() {
      _seatQuizAutoAdvancePendingV1 = false;
      _spineRank = rank;
      _spineMistakesCount = mistakesCount;
      _spineCalibrationBand = calibrationBand;
    });
    pushReplacementSessionResultV1<void, void>(
      context,
      correctCount: qualityScore,
      totalCount: _steps.length,
      moduleId: widget.moduleId,
      campaignSessionDelta: _spineSessionDelta,
      campaignOutcomeSummary: outcomeSummary,
      campaignPersonalizationHint: personalizationHint,
      personalizationResultV1: personalizationResult,
    );
  }

  String _runnerSurfaceTitleV1() {
    if (_isCampaignSpineSession) {
      final contract =
          resolveWorld1FoundationsRunnerProgressionChromeContractV1(
            moduleId: widget.moduleId,
            currentStepIndex: _stepIndex,
            totalSteps: _steps.length,
          );
      if (contract != null) {
        return contract.titleText;
      }
    }
    if (_isCheckpointSession) {
      return 'Checkpoint ${widget.checkpointId ?? ''}';
    }
    return _isCampaignSpineSession ? 'Campaign Spine' : 'Foundations check';
  }

  String _runnerStepLabelV1() => 'Step ${_stepIndex + 1} of ${_steps.length}';

  bool get _usesSharedRunnerIdentityHeadlineV1 =>
      _isCampaignSpineSession || _isReviewQueueSession;

  String _runnerHeaderHeadlineTextV1() {
    if (_usesSharedRunnerIdentityHeadlineV1) {
      return _runnerSurfaceTitleV1();
    }
    return _runnerStepLabelV1();
  }

  String? _runnerPromptStatusTextV1() {
    if (_usesSharedRunnerIdentityHeadlineV1) {
      return _runnerStepLabelV1();
    }
    return null;
  }

  String? _runnerProgressionStatusTextV1() {
    if (_isReviewQueueSession) {
      return _runnerStepLabelV1();
    }
    if (!_isCampaignSpineSession) {
      return null;
    }
    return resolveWorld1FoundationsRunnerProgressionChromeContractV1(
      moduleId: widget.moduleId,
      currentStepIndex: _stepIndex,
      totalSteps: _steps.length,
    )?.statusText;
  }

  @override
  Widget build(BuildContext context) {
    final shellMediaV1 = MediaQuery.of(context);
    final shellStableLayoutV1 = _resolveStableLayoutV1(
      context: context,
      media: shellMediaV1,
    );
    final reviewSeatQuizUsesCanonicalShellV1 =
        shellStableLayoutV1.portraitLayout &&
        _isReviewQueueSession &&
        _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz;
    final reduceScaffoldChromeV1 =
        (_isCampaignSpineSession && shellStableLayoutV1.portraitLayout) ||
        reviewSeatQuizUsesCanonicalShellV1;
    final useLiveVerticalCompositionProfileV1 =
        _isCampaignSpineSession &&
        shellStableLayoutV1.portraitLayout &&
        _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop;
    final world2SeatQuizOverrideV1 = _isWorld2SeatQuizBeatV1;
    final stepIndicatesActionDecisionV1 =
        _isCampaignSpineSession &&
        !world2SeatQuizOverrideV1 &&
        ((_step.allowedActions?.isNotEmpty ?? false) ||
            world1SpineExpectedActionKindV1(_step) != null);
    final rawHandLoopModeV1 =
        ((_isCampaignSpineSession &&
            _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop) ||
        _forceHandLoopSurfaceForTestV1 ||
        _isDemoHandLoopVisualStepV1);
    final campaignActionState = rawHandLoopModeV1
        ? _campaignActionUiStateForCurrentStep()
        : null;
    final runnerAuthorityV1 = _currentRunnerAuthorityStateV1(
      actionStateOverride: campaignActionState,
    );
    final showHandLoopActionBar = runnerAuthorityV1.showHandLoopActionBar;
    final introCaptionActive = _showWorld1IntroPreludeSurfaceV1;
    final introCoachStepsV1 = _seatQuizCoachStepsV1;
    final activeIntroCoachStepV1 = _activeSeatQuizCoachStepV1;
    final introCoachRailTotalV1 = introCoachStepsV1.length;
    final hostViewBridgeV1 = resolveWorld1CanonicalHostViewBridgeV1(
      World1CanonicalHostViewBridgeInputV1(
        moduleId: widget.moduleId,
        stepIndex: _stepIndex,
        totalSteps: _steps.length,
        isWorld2SeatQuizBeat: world2SeatQuizOverrideV1,
        stepIndicatesActionDecision: stepIndicatesActionDecisionV1,
        isCampaignSpineSession: _isCampaignSpineSession,
        currentModeIsSeatQuiz:
            _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz,
        currentModeIsHandLoop:
            _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop,
        rawHandLoopMode: rawHandLoopModeV1,
        showHandLoopActionBar: showHandLoopActionBar,
        isDemoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
        introCaptionActive: introCaptionActive,
        showSeatQuizPrelude: _showSeatQuizPreludeV1,
        showIntroSequence: _showIntroSequenceV1,
        outcomeVisible: _outcomeSurfaceVisible,
        completionInProgress: _completionInProgress,
        enginePlaybackBusy: _engineV2PlaybackBusy,
        selectedSeatId: _selectedSeatId,
        introSequenceIndex: _introSequenceIndexV1,
        introCoachRailTotal: introCoachRailTotalV1,
        canonicalPrompt: _displayedStepPromptV1,
        handLoopPrompt: _handLoopPromptV1(campaignActionState),
        seatQuizInstruction: _seatQuizInstructionForTargetV1(),
        activeIntroCoachTitle: activeIntroCoachStepV1?.title,
        activeIntroCoachSubtitle: activeIntroCoachStepV1?.subtitle,
        seatQuizPreviewTitle: _seatQuizPreviewTitleV1,
        seatQuizPreviewSubtitle: _seatQuizPreviewSubtitleV1,
        introSequencePrompt: _introSequenceStepV1?.prompt,
        guidedSeatSubtitle: _guidedSeatStepV1?.subtitle,
        seatQuizFallbackGuidanceTitle: _seatQuizFallbackGuidanceTitleV1,
        onSeatQuizPreludeContinue: _continueSeatQuizPreludeV1,
        onIntroSequenceContinue: _continueIntroSequenceV1,
      ),
    );
    final progress = hostViewBridgeV1.progress;
    final isSeatQuizStepV1 = hostViewBridgeV1.isSeatQuizStep;
    final handLoopMode = hostViewBridgeV1.handLoopMode;
    final teachingFlowV1 = hostViewBridgeV1.teachingFlow;
    var displayedPrompt = teachingFlowV1.displayedPrompt;
    final detailsSurfaceAdapterV1 = teachingFlowV1.detailsSurfaceAdapter;
    final promptPresentationV1 = detailsSurfaceAdapterV1.presentation;
    final effectiveTopPrompt = teachingFlowV1.effectiveTopPrompt;
    var introCoachTitleV1 = teachingFlowV1.introCoachTitle;
    var introCoachSubtitleRawV1 = teachingFlowV1.introCoachSubtitleRaw;
    var showIntroCoachSubtitleV1 = teachingFlowV1.showIntroCoachSubtitle;
    final introCoachRailActiveIndexV1 =
        teachingFlowV1.introCoachRailActiveIndex;
    final lockInNeedsSeatSelection = teachingFlowV1.lockInNeedsSeatSelection;
    final allowSeatQuizConfirmPanelV1 =
        teachingFlowV1.allowSeatQuizConfirmPanel;
    final hideAppBarBack = hostViewBridgeV1.hideAppBarBack;
    final introCaptionContinueOnPressedV1 =
        hostViewBridgeV1.introCaptionContinueOnPressed;
    return SharedLearnerTopLevelShellV1(
      contract: SharedLearnerTopLevelShellContractV1(
        backgroundColor: AppColors.background,
        appBar: useLiveVerticalCompositionProfileV1
            ? null
            : AppBar(
                automaticallyImplyLeading: !hideAppBarBack,
                leading: hideAppBarBack ? const SizedBox.shrink() : null,
                backgroundColor: reduceScaffoldChromeV1
                    ? Colors.transparent
                    : AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: reduceScaffoldChromeV1 ? 40 : kToolbarHeight,
                titleSpacing: reduceScaffoldChromeV1 ? 0 : null,
                iconTheme: IconThemeData(color: SharkyTokensV1.textSecondary),
                title: reduceScaffoldChromeV1
                    ? null
                    : GestureDetector(
                        onLongPress: () {
                          if (kReleaseMode) return;
                          setState(() {
                            _showEngineV2Controls = !_showEngineV2Controls;
                            if (_showEngineV2Controls &&
                                _engineV2CheckpointEligible &&
                                _engineV2BackendEnabled &&
                                !_engineV2BackendChoiceMadeInSession) {
                              _engineV2UseLegacyBackend = false;
                            }
                          });
                        },
                        child: Text(
                          _runnerSurfaceTitleV1(),
                          style: AppTypography.h3.copyWith(
                            color: SharkyTokensV1.textPrimary,
                          ),
                        ),
                      ),
              ),
        wrapBodyInSafeArea: true,
        safeAreaBottom: true,
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          _requestDismissGlobalTrainingIntroPreludeFromInteractionV1();
          _requestDismissWorld1IntroPreludeFromInteractionV1();
          _requestDismissWorld1ActionIntroPreludeFromInteractionV1();
          _requestDismissWorld1StreetFlowIntroPreludeFromInteractionV1();
          _requestDismissWorld2HandoffPreludeFromInteractionV1();
          _requestDismissWorld2IntroPreludeFromInteractionV1();
          _requestDismissTrackIntroPreludeFromInteractionV1();
        },
        child: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            final stableLayoutV1 = _resolveStableLayoutV1(
              context: context,
              media: media,
            );
            final portraitLayout = stableLayoutV1.portraitLayout;
            final compactPortrait = stableLayoutV1.compactPortrait;
            final seatQuizUsesCanonicalShellV1 =
                portraitLayout &&
                _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz &&
                (_isCampaignSpineSession || _isReviewQueueSession);
            final useRunnerCompactHeaderV1 =
                portraitLayout &&
                (_isCampaignSpineSession || seatQuizUsesCanonicalShellV1);
            final hasFeedbackTextV1 =
                _feedback != null && _feedback!.trim().isNotEmpty;
            final handLoopPromptSurfaceV1 =
                resolveWorld1SurfacedHandLoopPromptSurfaceV1(
                  World1SurfacedHandLoopPromptSurfaceInputV1(
                    handLoopMode: handLoopMode,
                    isDemoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
                    showSeatQuizPrelude: _showSeatQuizPreludeV1,
                    showIntroSequence: _showIntroSequenceV1,
                    promptText: _handLoopFeltCaptionTextV1(
                      campaignActionState,
                    ).trim(),
                    outcomeSurfaceVisible: _outcomeSurfaceVisible,
                    debugCaptionOverrideVisible:
                        widget.debugHandLoopFeltCaptionOverrideV1
                            ?.trim()
                            .isNotEmpty ??
                        false,
                    runnerAuthorityIsReviewPass: runnerAuthorityV1.isReviewPass,
                    runnerAuthorityVisibleBoardCount:
                        runnerAuthorityV1.visibleBoardCount,
                    portraitLayout: stableLayoutV1.portraitLayout,
                    reviewQueueSession: _isReviewQueueSession,
                  ),
                );
            final instructionPlacementFlowV1 =
                resolveWorld1SurfacedInstructionPlacementFlowV1(
                  World1SurfacedInstructionPlacementInputV1(
                    portraitLayout: portraitLayout,
                    compactPortrait: compactPortrait,
                    handLoopMode: handLoopMode,
                    introCaptionActive: introCaptionActive,
                    showInstructionOverlay: _showInstructionOverlay,
                    useRunnerCompactHeaderV1: useRunnerCompactHeaderV1,
                    hasFeedbackTextV1: hasFeedbackTextV1,
                    awaitingSeatInput: _awaitingSeatInput,
                    lockInNeedsSeatSelection: lockInNeedsSeatSelection,
                    allowSeatQuizConfirmPanelV1: allowSeatQuizConfirmPanelV1,
                    showHandLoopActionBar: showHandLoopActionBar,
                    mediaSize: media.size,
                    outcomeSurfaceVisible: _outcomeSurfaceVisible,
                    showHintBubble: _showHintBubbleV1,
                    showSeatQuizPrelude: _showSeatQuizPreludeV1,
                    showIntroSequence: _showIntroSequenceV1,
                    campaignHudDetailsExpanded: _campaignHudDetailsExpanded,
                    currentModeIsSeatQuiz:
                        _currentCampaignRunnerMode ==
                        _CampaignRunnerMode.seatQuiz,
                    isDemoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
                    handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
                  ),
                );
            final canonicalHeaderOwnsHandLoopPromptV1 =
                _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop &&
                useRunnerCompactHeaderV1 &&
                !handLoopPromptSurfaceV1.usesFeltCaptionHost;
            final coachModeV1 = _currentCoachModeV1();
            final outcomePresentationV1 = _buildOutcomePresentationV1();
            var coachOutcomePresentationV1 = outcomePresentationV1;
            if (_afterOutcomePhraseTextV1.isNotEmpty) {
              coachOutcomePresentationV1 = coachOutcomePresentationV1.copyWith(
                summaryNext: coachOutcomePresentationV1.summaryNext.isEmpty
                    ? _afterOutcomePhraseTextV1
                    : '${coachOutcomePresentationV1.summaryNext} $_afterOutcomePhraseTextV1',
                seatQuizCoachSubtitle:
                    coachOutcomePresentationV1.seatQuizCoachSubtitle.isEmpty
                    ? _afterOutcomePhraseTextV1
                    : '${coachOutcomePresentationV1.seatQuizCoachSubtitle} $_afterOutcomePhraseTextV1',
                handLoopCoachBody:
                    coachOutcomePresentationV1.handLoopCoachBody.isEmpty
                    ? _afterOutcomePhraseTextV1
                    : '${coachOutcomePresentationV1.handLoopCoachBody}\n$_afterOutcomePhraseTextV1',
              );
            }
            var coachStatusTitleV1 = _outcomeSurfaceVisible
                ? coachOutcomePresentationV1.seatQuizCoachTitle
                : (_showHintBubbleV1
                      ? _step.hint.trim()
                      : (hasFeedbackTextV1
                            ? _feedback!.trim()
                            : (lockInNeedsSeatSelection &&
                                      allowSeatQuizConfirmPanelV1
                                  ? _seatQuizIdleGuidanceLineV1()
                                  : '')));
            var coachStatusSubtitleV1 = _outcomeSurfaceVisible
                ? coachOutcomePresentationV1.seatQuizCoachSubtitle
                : (!_outcomeSurfaceVisible &&
                          _showHintBubbleV1 &&
                          hasFeedbackTextV1 &&
                          _feedback!.trim().toLowerCase() !=
                              _step.hint.trim().toLowerCase()
                      ? _feedback!.trim()
                      : '');
            if (!_outcomeSurfaceVisible &&
                _beforeSessionPhraseTextV1.isNotEmpty &&
                !handLoopMode) {
              coachStatusSubtitleV1 = coachStatusSubtitleV1.isEmpty
                  ? _beforeSessionPhraseTextV1
                  : '$coachStatusSubtitleV1 | $_beforeSessionPhraseTextV1';
            }
            final instructionSourceV1 = widget.instructionSourceV1;
            final lockSeatQuizInstructionOverrideV1 =
                instructionPlacementFlowV1.seatQuizInstructionModeActiveV1;
            if (instructionSourceV1 != null &&
                !lockSeatQuizInstructionOverrideV1) {
              if (introCaptionActive) {
                final overriddenIntro = instructionSourceV1.getIntroInstruction(
                  moduleId: widget.moduleId,
                  moduleTitle: widget.moduleTitle,
                  railIndex: introCoachRailActiveIndexV1.toInt(),
                  railTotal: introCoachRailTotalV1,
                  fallback: RunnerInstructionContentV1(
                    title: introCoachTitleV1,
                    subtitle: showIntroCoachSubtitleV1
                        ? introCoachSubtitleRawV1
                        : '',
                  ),
                );
                if (overriddenIntro != null) {
                  introCoachTitleV1 = overriddenIntro.title.trim();
                  introCoachSubtitleRawV1 = overriddenIntro.subtitle.trim();
                  showIntroCoachSubtitleV1 =
                      introCoachSubtitleRawV1.isNotEmpty &&
                      introCoachSubtitleRawV1.toLowerCase() !=
                          introCoachTitleV1.toLowerCase();
                }
                if (_beforeSessionPhraseTextV1.isNotEmpty) {
                  introCoachSubtitleRawV1 = showIntroCoachSubtitleV1
                      ? '$introCoachSubtitleRawV1 | $_beforeSessionPhraseTextV1'
                      : _beforeSessionPhraseTextV1;
                  showIntroCoachSubtitleV1 = true;
                }
              } else if (_outcomeSurfaceVisible) {
                final overriddenOutcome = instructionSourceV1
                    .getOutcomeInstruction(
                      moduleId: widget.moduleId,
                      handLoopMode: handLoopMode,
                      isCorrect: _outcomeLastResultCorrect,
                      fallback: RunnerInstructionContentV1(
                        title: coachOutcomePresentationV1.seatQuizCoachTitle,
                        subtitle:
                            coachOutcomePresentationV1.seatQuizCoachSubtitle,
                      ),
                    );
                if (overriddenOutcome != null) {
                  coachOutcomePresentationV1 = coachOutcomePresentationV1
                      .copyWith(
                        statusLine: overriddenOutcome.title.trim(),
                        summaryPrimary: overriddenOutcome.title.trim(),
                        summaryWhy: '',
                        summaryNext: '',
                        seatQuizCoachTitle: overriddenOutcome.title.trim(),
                        seatQuizCoachSubtitle: overriddenOutcome.subtitle
                            .trim(),
                        handLoopCoachTitle: overriddenOutcome.title.trim(),
                        handLoopCoachBody: overriddenOutcome.subtitle.trim(),
                      );
                  coachStatusTitleV1 =
                      coachOutcomePresentationV1.seatQuizCoachTitle;
                  coachStatusSubtitleV1 =
                      coachOutcomePresentationV1.seatQuizCoachSubtitle;
                }
              } else {
                final overriddenStep = instructionSourceV1.getStepInstruction(
                  moduleId: widget.moduleId,
                  handLoopMode: handLoopMode,
                  fallback: RunnerInstructionContentV1(
                    title: handLoopMode ? displayedPrompt : coachStatusTitleV1,
                    subtitle: handLoopMode ? '' : coachStatusSubtitleV1,
                  ),
                );
                if (overriddenStep != null) {
                  if (handLoopMode) {
                    displayedPrompt = overriddenStep.title.trim();
                  } else {
                    coachStatusTitleV1 = overriddenStep.title.trim();
                    coachStatusSubtitleV1 = overriddenStep.subtitle.trim();
                  }
                }
              }
            }
            final compactTeachingPayloadV1 =
                _buildWorld1CompactTeachingPayloadV1(
                  outcomePresentationV1: coachOutcomePresentationV1,
                  supportTitle: coachStatusTitleV1,
                  supportSubtitle: coachStatusSubtitleV1,
                );
            final teachingContractV1 = _buildWorld1TeachingContractV1(
              displayedPrompt: displayedPrompt,
              introTitle: introCoachTitleV1,
              introSubtitle: showIntroCoachSubtitleV1
                  ? introCoachSubtitleRawV1
                  : '',
              promptDetailsTitle: 'Step ${_stepIndex + 1} of ${_steps.length}',
              promptDetailsText: promptPresentationV1.detailsPrompt,
              canRevealPromptDetails: promptPresentationV1.canReveal,
              enablePromptDetailsAffordance:
                  promptPresentationV1.reveal.isAffordanceEnabled,
              compactTeachingPayloadV1: compactTeachingPayloadV1,
            );
            final surfacedOutcomeProgressionHandoffContractV1 =
                resolveWorld1SurfacedOutcomeRuntimeControllerV1(
                  World1SurfacedOutcomeRuntimeControllerInputV1(
                    outcomeVisible: _outcomeSurfaceVisible,
                    continueAdvancesFlow: _outcomeContinueAdvancesFlowV1,
                    autoContinue: _outcomeAutoContinueArmedV1,
                    progressionTarget: _outcomeProgressionTargetV1,
                    primaryLabel: _outcomePrimaryCtaLabel,
                    showsRetrySecondary: _outcomeShowRetrySecondary,
                    isPrimaryBusy: _resultContinueBusy,
                    onPrimaryPressed: _onContinueResult,
                    onSecondaryPressed: _onRetryResult,
                    onBackToMapPressed: () {
                      Navigator.of(context).maybePop(false);
                    },
                  ),
                );
            final supportActionRuntimeStateV1 =
                resolveWorld1SurfacedSupportActionRuntimeV1(
                  World1SurfacedSupportActionRuntimeInputV1(
                    showHandLoopActionBar: showHandLoopActionBar,
                    allowSeatQuizConfirmPanel: allowSeatQuizConfirmPanelV1,
                    introCaptionActive: introCaptionActive,
                    lockInNeedsSeatSelection: lockInNeedsSeatSelection,
                    instructionPlacementFlowV1: instructionPlacementFlowV1,
                    outcomeProgressionHandoffContractV1:
                        surfacedOutcomeProgressionHandoffContractV1,
                    coachModeIsAction: coachModeV1 == _CoachModeV1.action,
                    showIntroSequence: _showIntroSequenceV1,
                    outcomeSurfaceVisible: _outcomeSurfaceVisible,
                    hasHandLoopActionState: campaignActionState != null,
                  ),
                );
            final packLabelV1 = switch (widget.moduleId.trim().toLowerCase()) {
              'world1_spine_campaign_v1' => 'World 1',
              'world2_spine_campaign_v1' => 'World 2',
              _ => widget.moduleId,
            };
            final outcomeLabelV1 =
                (_outcomeSurfaceVisible || _outcomeLines.isNotEmpty)
                ? _world1OutcomeVerdictLineV1(_outcomeLastResultCorrect)
                : 'Pending.';
            final supportActionCompositionV1 =
                resolveWorld1SurfacedSupportActionComposerV1(
                  World1SurfacedSupportActionComposerInputV1(
                    compactPortrait: compactPortrait,
                    showHandLoopActionBar: showHandLoopActionBar,
                    introCaptionActive: introCaptionActive,
                    feltInstructionVisible:
                        instructionPlacementFlowV1.feltInstructionVisibleV1,
                    showBottomCoachStrip:
                        instructionPlacementFlowV1.showBottomCoachStripV1,
                    showSeatQuizPrelude: _showSeatQuizPreludeV1,
                    introCaptionContinueOnPressed:
                        introCaptionContinueOnPressedV1,
                    seatQuizIdleGuidanceText: _seatQuizIdleGuidanceLineV1(),
                    confirmGhostControlKey: const Key('microtask_check_cta'),
                    runtimeState: supportActionRuntimeStateV1,
                    landscapeExtrasFeed:
                        World1SurfacedLandscapeHostExtrasFeedV1(
                          showHintBubble: _showHintBubbleV1,
                          hintText: _step.hint,
                          feedbackText: _feedback,
                          outcomeVisible: _outcomeSurfaceVisible,
                          isCampaignSpineSession: _isCampaignSpineSession,
                          pulseFailure: _pulseFailure,
                          loopRewardBanner: _loopRewardBanner,
                          spineMistakesCount: _spineMistakesCount,
                          spineRankLabel: ProgressService.spineRankLabel(
                            _spineRank,
                          ),
                          packLabel: packLabelV1,
                          outcomeLabel: outcomeLabelV1,
                        ),
                    slots: World1SurfacedSupportActionWidgetSlotsV1(
                      portraitSeatQuizCoachStrip:
                          supportActionRuntimeStateV1
                              .showsPortraitSeatQuizCoachStrip
                          ? _buildPortraitCoachStripV1(
                              mode: coachModeV1,
                              title: introCaptionActive
                                  ? (_seatQuizInstructionForTargetV1() ??
                                        teachingContractV1.introTitle)
                                  : teachingContractV1
                                        .sharedTeachingGrammarV1
                                        .supportPrimaryText,
                              subtitle: introCaptionActive
                                  ? ''
                                  : teachingContractV1
                                        .sharedTeachingGrammarV1
                                        .supportSecondaryText,
                              ignorePointer: !introCaptionActive,
                              showRail: introCaptionActive,
                              railTotal: introCoachRailTotalV1,
                              railActiveIndex: introCoachRailActiveIndexV1
                                  .toInt(),
                              outcomeVisible: _outcomeSurfaceVisible,
                              outcomeCorrect: _outcomeLastResultCorrect,
                              pulseFailure: _pulseFailure,
                            )
                          : null,
                      portraitHandLoopCoachStrip:
                          supportActionRuntimeStateV1
                              .showsPortraitHandLoopCoachStrip
                          ? _buildPortraitCoachStripV1(
                              mode: coachModeV1,
                              title: _outcomeSurfaceVisible
                                  ? compactTeachingPayloadV1.handLoopCoachTitle
                                  : teachingContractV1
                                        .sharedTeachingGrammarV1
                                        .displayedPrompt,
                              handLoopBody: _outcomeSurfaceVisible
                                  ? compactTeachingPayloadV1.handLoopCoachBody
                                  : teachingContractV1
                                        .sharedTeachingGrammarV1
                                        .displayedPrompt,
                              ignorePointer: true,
                              outcomeVisible: _outcomeSurfaceVisible,
                              outcomeCorrect: _outcomeLastResultCorrect,
                              pulseFailure: _pulseFailure,
                            )
                          : null,
                      portraitOutcomeAction:
                          supportActionRuntimeStateV1.portraitActionMode ==
                              World1SurfacedActionModeV1.outcome
                          ? Column(
                              key: const Key('microtask_outcome_surface'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildOutcomeActionRowV1(
                                  inputs: _buildOutcomeActionLaneInputsV1(
                                    outcomeProgressionHandoffContractV1:
                                        surfacedOutcomeProgressionHandoffContractV1,
                                  ),
                                  primaryBackgroundColor:
                                      SharkyTokensV1.brandPrimary,
                                  primaryTextColor: Colors.white,
                                  primaryElevation: 3,
                                  primaryShadowColor: SharkyTokensV1.brandGlow
                                      .withOpacity(0.34),
                                  primarySide: BorderSide(
                                    color:
                                        (_outcomeLastResultCorrect
                                                ? SharkyTokensV1.semanticWin
                                                : SharkyTokensV1.brandGlow)
                                            .withOpacity(0.42),
                                    width: 1.0,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      landscapeOutcomeAction:
                          supportActionRuntimeStateV1.landscapeActionMode ==
                              World1SurfacedActionModeV1.outcome
                          ? SafeArea(
                              key: const Key('microtask_outcome_surface'),
                              top: false,
                              minimum: const EdgeInsets.only(bottom: 6),
                              child: _buildOutcomeActionRowV1(
                                inputs: _buildOutcomeActionLaneInputsV1(
                                  outcomeProgressionHandoffContractV1:
                                      surfacedOutcomeProgressionHandoffContractV1,
                                ),
                                primaryBackgroundColor:
                                    SharkyTokensV1.brandPrimary,
                                primaryTextColor: SharkyTokensV1.textPrimary,
                                primaryElevation: 1,
                              ),
                            )
                          : null,
                      portraitSeatQuizConfirmPanel:
                          _buildSeatQuizConfirmPanelV1(
                            lockInNeedsSeatSelection: lockInNeedsSeatSelection,
                            introCaptionActive: introCaptionActive,
                          ),
                      landscapeSeatQuizConfirmPanel:
                          _buildSeatQuizConfirmPanelV1(
                            lockInNeedsSeatSelection: lockInNeedsSeatSelection,
                            introCaptionActive: introCaptionActive,
                          ),
                      portraitHandLoopBar: campaignActionState == null
                          ? null
                          : _buildCampaignActionChips(campaignActionState),
                      landscapeHandLoopBar: campaignActionState == null
                          ? null
                          : _buildCampaignActionChips(
                              campaignActionState,
                              stableLayoutV1: stableLayoutV1,
                            ),
                      landscapeOutcomeStatus:
                          supportActionRuntimeStateV1
                              .showsLandscapeOutcomeStatus
                          ? Builder(
                              builder: (context) {
                                final viewportHeight = MediaQuery.of(
                                  context,
                                ).size.height;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _buildCompactOutcomeStatusBoxV1(
                                    sharedTeachingGrammarV1: teachingContractV1
                                        .sharedTeachingGrammarV1,
                                    compactTeachingPayloadV1:
                                        compactTeachingPayloadV1,
                                    compactOutcome: viewportHeight < 900,
                                    ultraCompactOutcome: viewportHeight < 500,
                                    centered: false,
                                    dense: true,
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                );
            final bodyPadding = portraitLayout
                ? EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: compactPortrait ? 1 : 4,
                  )
                : const EdgeInsets.all(AppSpacing.lg);
            final runnerPanelPadding = portraitLayout
                ? EdgeInsets.symmetric(
                    horizontal: compactPortrait ? 6 : 8,
                    vertical: compactPortrait ? 2 : 5,
                  )
                : const EdgeInsets.all(AppSpacing.md);
            final seatQuizHeaderInstructionTextV1 =
                _seatQuizGuidanceForTargetV1(includeConfirmHint: false);
            final usesHandLoopHeaderPromptV1 =
                handLoopPromptSurfaceV1.isAffectedStateFamily &&
                !handLoopPromptSurfaceV1.usesFeltCaptionHost &&
                handLoopPromptSurfaceV1.isMounted;
            final seatQuizInstructionPresentationV1 =
                _buildSeatQuizInstructionPresentationV1(
                  displayedPrompt: teachingContractV1.displayedPrompt,
                  effectiveTopPrompt: effectiveTopPrompt,
                  hideStepPromptInHeaderV1:
                      instructionPlacementFlowV1.hideStepPromptInHeaderV1,
                  seatQuizHeaderInstructionActiveV1: instructionPlacementFlowV1
                      .seatQuizHeaderInstructionActiveV1,
                  seatQuizHeaderInstructionTextV1:
                      seatQuizHeaderInstructionTextV1,
                  handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
                );
            final detailsSurfaceAdapterForHeaderV1 =
                buildWorld1DetailsSurfaceAdapterV1(
                  sourceId: '${widget.moduleId}#step${_stepIndex + 1}',
                  canonicalPrompt: _displayedStepPromptV1,
                  detailsPromptOverride:
                      (_currentCampaignRunnerMode ==
                              _CampaignRunnerMode.handLoop &&
                          !_isDemoHandLoopVisualStepV1)
                      ? 'Choose the best action.'
                      : _seatQuizInstructionForTargetV1(),
                );
            final headerPromptInputV1 = World1SurfacedHeaderPromptInputV1(
              statusText:
                  teachingContractV1.sharedTeachingGrammarV1.headerStatusText,
              headlineText:
                  teachingContractV1.sharedTeachingGrammarV1.headerHeadlineText,
              headerPromptText:
                  seatQuizInstructionPresentationV1.headerPromptText,
              headerPromptKey:
                  seatQuizInstructionPresentationV1.headerPromptKey,
              headerMaxLines: seatQuizInstructionPresentationV1.headerMaxLines,
              headerOverflow: seatQuizInstructionPresentationV1.headerOverflow,
              headerSoftWrap: seatQuizInstructionPresentationV1.headerSoftWrap,
              canOpenDetailsSheet:
                  detailsSurfaceAdapterForHeaderV1.canOpenDetailsSheet,
            );
            final world1CanonicalShellSlotsV1 =
                _buildWorld1CanonicalShellSlotsV1(
                  context: context,
                  compactPortrait: compactPortrait,
                  useRunnerCompactHeaderV1: useRunnerCompactHeaderV1,
                  hidePromptCapsuleV1:
                      _currentCampaignRunnerMode ==
                          _CampaignRunnerMode.handLoop &&
                      handLoopPromptSurfaceV1.usesFeltCaptionHost &&
                      handLoopPromptSurfaceV1.isMounted,
                  headerPromptInputV1: headerPromptInputV1,
                  teachingContractV1: teachingContractV1,
                  supportActionCompositionV1: supportActionCompositionV1,
                );
            final effectiveBoardStreetV1 =
                _effectiveBoardStreetForCurrentStepV1();
            final tableRenderBranchV1 = resolveWorld1SurfacedTableRenderFeedV1(
              World1SurfacedTableRenderFeedInputV1(
                currentModeIsSeatQuiz:
                    _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz,
                currentModeIsHandLoop:
                    _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop,
                stepIndicatesActionDecision:
                    (_step.allowedActions?.isNotEmpty ?? false) ||
                    world1SpineExpectedActionKindV1(_step) != null,
                isDemoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
                forceHandLoopSurfaceForTest: _forceHandLoopSurfaceForTestV1,
                showEngineV2StreetUi: _showEngineV2StreetUi,
                visibleBoardCount: _visibleBoardCardsForStreet(
                  effectiveBoardStreetV1,
                ),
                seatQuizTargetSeatId: _seatQuizTargetSeatIdV1,
              ),
            );
            final showLegacyOverlaySurfaceV1 =
                (_showGlobalTrainingIntroPreludeV1 &&
                    _isWorld1SpineCampaignEntryV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showWorld1IntroPreludeSurfaceV1 &&
                    _isWorld1FirstUserOnboardingTargetV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showWorld1ActionIntroPreludeV1 &&
                    _isWorld1ActionLiteracyContinuityTargetV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showWorld1StreetFlowIntroPreludeV1 &&
                    _isWorld1StreetFlowContinuityTargetV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showWorld2IntroPreludeV1 &&
                    _isWorld2SpineCampaignEntryV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showWorld2HandoffPreludeV1 &&
                    _isWorld2SpineCampaignEntryV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode) ||
                (_showTrackIntroPreludeV1 &&
                    _isWorld10TrackFollowupPackV1 &&
                    tableRenderBranchV1.seatQuizVisualMode &&
                    !tableRenderBranchV1.handLoopVisualMode);
            final tableRouteV1 = resolveWorld1EmbeddedTableRouteV1(
              handLoopVisualMode: tableRenderBranchV1.handLoopVisualMode,
              seatQuizVisualMode: tableRenderBranchV1.seatQuizVisualMode,
              isCampaignSpineSession: _isCampaignSpineSession,
              isReviewQueueSession: _isReviewQueueSession,
              isTablePracticeSession: _isTablePracticeSession,
              isDailyRunSession: _isDailyRunSession,
              showSeatQuizPrelude: _showSeatQuizPreludeV1,
              showIntroSequence: _showIntroSequenceV1,
              showLegacyOverlaySurface: showLegacyOverlaySurfaceV1,
              showConceptPreludeCard: _showConceptFirstSeatPreludeCardV1,
              showActionLiteracyPreludeCard: _showActionLiteracyPreludeCardV1,
              showStreetFlowPreludeCard: _showStreetFlowPreludeCardV1,
            );
            final useEmbeddedCanonicalSeatQuizShellV1 =
                tableRouteV1 == World1EmbeddedTableRouteV1.sharedEmbedded;
            final surfacedTableSectionV1 = buildWorld1SurfacedTableSectionV1(
              World1SurfacedTableSectionComposerInputV1(
                fillsAvailableSpace: useEmbeddedCanonicalSeatQuizShellV1,
                tableKey: _isCheckpointSession
                    ? const Key('checkpoint_table')
                    : (_isTablePracticeSession
                          ? const Key('table_practice_table')
                          : const Key('microtask_table')),
                blockTableInteractions:
                    _showSeatQuizPreludeV1 ||
                    (_showIntroSequenceV1 &&
                        !(_introSequenceStepV1?.requiresSeatTap ?? false)),
                tableBuilder: (context) => useEmbeddedCanonicalSeatQuizShellV1
                    ? _buildWorld1CanonicalEmbeddedTableV1(
                        tableRenderBranchV1: tableRenderBranchV1,
                        handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
                        canonicalHeaderOwnsHandLoopPromptV1:
                            canonicalHeaderOwnsHandLoopPromptV1,
                        portraitLayout: portraitLayout,
                      )
                    : _buildWorld1TableV1(
                        stableLayoutV1: stableLayoutV1,
                        tableRenderBranchV1: tableRenderBranchV1,
                        handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
                        compactTeachingPayloadV1: compactTeachingPayloadV1,
                      ),
                resolvePortraitHeight: (tableConstraints, mediaSize) =>
                    _computePortraitTableHeightV1(
                      mediaSize: mediaSize,
                      tableConstraints: tableConstraints,
                      seatQuizMode: tableRenderBranchV1.seatQuizVisualMode,
                      useLiveReferenceParityV1:
                          portraitLayout &&
                          _isCampaignSpineSession &&
                          tableRenderBranchV1.handLoopVisualMode,
                    ),
              ),
            );
            final world1SurfacedRenderModelV1 =
                resolveWorld1SurfacedRenderModelV1(
                  World1SurfacedRenderModelInputV1(
                    headerPromptInput: headerPromptInputV1,
                    presentationInput: World1SurfacedPresentationInputV1(
                      portraitLayout: portraitLayout,
                      compactPortrait: compactPortrait,
                      useRunnerCompactHeader: useRunnerCompactHeaderV1,
                      useFeltOverlayAsPromptSource: instructionPlacementFlowV1
                          .useFeltOverlayAsPromptSourceV1,
                      compactHeaderUnderFeedbackPressure:
                          instructionPlacementFlowV1
                              .compactHeaderUnderFeedbackPressureV1,
                      collapsePortraitHeaderForFeltCaption:
                          instructionPlacementFlowV1
                              .collapsePortraitHeaderForFeltCaptionV1,
                      currentModeIsSeatQuiz:
                          _currentCampaignRunnerMode ==
                          _CampaignRunnerMode.seatQuiz,
                      hideStepPromptInHeader:
                          instructionPlacementFlowV1.hideStepPromptInHeaderV1,
                      showCompactInstructionOverlay: instructionPlacementFlowV1
                          .showCompactInstructionOverlayV1,
                      showBottomCoachStrip:
                          instructionPlacementFlowV1.showBottomCoachStripV1,
                      mediaSize: media.size,
                    ),
                    capabilityInput: World1SurfacedCapabilityInputV1(
                      promptSourceId:
                          '${widget.moduleId}#step${_stepIndex + 1}',
                      showIntro: introCaptionActive,
                      showSourceMeta:
                          detailsSurfaceAdapterV1.sections.showSourceMeta,
                      showRecap: detailsSurfaceAdapterV1.sections.showRecap,
                      showCompletionInHeader: _showWorld1OutcomeHeaderStatusV1,
                      showEmbeddedFeedbackBelowTable:
                          !portraitLayout &&
                          !_outcomeSurfaceVisible &&
                          (_showHintBubbleV1 || hasFeedbackTextV1),
                    ),
                    outcomeProgressionHandoffContract:
                        surfacedOutcomeProgressionHandoffContractV1,
                    shellSlots: world1CanonicalShellSlotsV1,
                    tableSection: surfacedTableSectionV1,
                    topPromptText: effectiveTopPrompt,
                    detailsPrompt: promptPresentationV1.detailsPrompt,
                    sessionTitle: _runnerSurfaceTitleV1(),
                    stepLabel: 'Step ${_stepIndex + 1} of ${_steps.length}',
                    outerPadding: bodyPadding,
                    portraitLayout: portraitLayout,
                    shellBody: const SizedBox.shrink(),
                  ),
                );
            final surfacedPresentationContractV1 =
                world1SurfacedRenderModelV1.presentationContract;
            final surfacedFamilyAdapterV1 =
                world1SurfacedRenderModelV1.familyAdapter;
            final runnerProgressionStatusTextV1 =
                _runnerProgressionStatusTextV1();
            final topPanelContractV1 = resolveWorld1CanonicalTopPanelContractV1(
              World1CanonicalTopPanelContractInputV1(
                isCheckpointSession: _isCheckpointSession,
                isTablePracticeSession: _isTablePracticeSession,
                useFeltOverlayAsPromptSource:
                    instructionPlacementFlowV1.useFeltOverlayAsPromptSourceV1,
                showCompactInstructionOverlay: surfacedFamilyAdapterV1
                    .presentationContract
                    .showsCompactInstructionOverlay,
                introCaptionActive: introCaptionActive,
                compactPortrait: compactPortrait,
                campaignHudDetailsExpanded: _campaignHudDetailsExpanded,
                progressionStatusText: runnerProgressionStatusTextV1,
                showGoldLearningSlicePreludeCard:
                    _showGoldLearningSlicePreludeCardV1,
                showConceptFirstSeatPreludeCard:
                    _showConceptFirstSeatPreludeCardV1,
                isCampaignSpineSession: _isCampaignSpineSession,
                hasContextText: _step.contextText != null,
                hasTradeoffText: _step.tradeoffText != null,
                hasConsequenceText: _step.consequenceText != null,
                showExtendedHudDetails: _showExtendedHudDetailsV1(
                  compactPortrait: compactPortrait,
                ),
                pulseBust: _pulseBust,
                successBadgeText: _successBadgeText,
              ),
            );
            final surfacedShellBodyV1 = SharedLearnerTableAdjacentFrameV1(
              topRegion: useRunnerCompactHeaderV1 && !_showEngineV2StreetUi
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!useRunnerCompactHeaderV1)
                          ConstrainedBox(
                            constraints: surfacedFamilyAdapterV1
                                .presentationContract
                                .topPanelConstraints,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 160),
                              opacity: _pulseFailure ? 0.9 : 1.0,
                              child: AnimatedSlide(
                                duration: Duration(
                                  milliseconds: _microAnimationsEnabled
                                      ? 90
                                      : 0,
                                ),
                                offset: Offset(_failureShakeDx, 0),
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  child: Container(
                                    key: _isCheckpointSession
                                        ? const Key('checkpoint_runner')
                                        : (_isTablePracticeSession
                                              ? const Key(
                                                  'table_practice_runner',
                                                )
                                              : const Key('microtask_runner')),
                                    width: double.infinity,
                                    padding: runnerPanelPadding,
                                    decoration: BoxDecoration(
                                      color: SharkyTokensV1.surfaceCard
                                          .withOpacity(0.72),
                                      borderRadius: BorderRadius.circular(
                                        SharkyTokensV1.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: _pulseBust
                                            ? SharkyTokensV1.semanticLoss
                                            : _pulseSuccess
                                            ? SharkyTokensV1.semanticWin
                                            : (_pulseFailure
                                                  ? SharkyTokensV1.semanticLoss
                                                  : SharkyTokensV1.slate600
                                                        .withOpacity(0.38)),
                                        width: _pulseBust ? 2.0 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (topPanelContractV1
                                            .showInstructionOverlay) ...[
                                          Container(
                                            key: const Key(
                                              'microtask_instruction_overlay',
                                            ),
                                            width: double.infinity,
                                            margin: EdgeInsets.only(
                                              bottom: compactPortrait ? 2 : 6,
                                            ),
                                            padding: EdgeInsets.all(
                                              compactPortrait
                                                  ? 4
                                                  : AppSpacing.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.semanticInfo
                                                  .withOpacity(0.14),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SharkyTokensV1.radiusMd,
                                                  ),
                                              border: Border.all(
                                                color: SharkyTokensV1
                                                    .semanticInfo
                                                    .withOpacity(0.74),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (_step.instructionText !=
                                                    null)
                                                  Text(
                                                    _step.instructionText!,
                                                    key: const Key(
                                                      'microtask_instruction_text',
                                                    ),
                                                    maxLines: compactPortrait
                                                        ? 1
                                                        : 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTypography.caption
                                                        .copyWith(
                                                          color: SharkyTokensV1
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize:
                                                              compactPortrait
                                                              ? 11
                                                              : null,
                                                        ),
                                                  ),
                                                if (_step.goalText != null &&
                                                    topPanelContractV1
                                                        .showOverlayGoalText) ...[
                                                  SizedBox(
                                                    height: compactPortrait
                                                        ? 2
                                                        : 4,
                                                  ),
                                                  Text(
                                                    _step.goalText!,
                                                    key: const Key(
                                                      'microtask_goal_text',
                                                    ),
                                                    maxLines: compactPortrait
                                                        ? 1
                                                        : 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTypography.caption
                                                        .copyWith(
                                                          color: SharkyTokensV1
                                                              .textSecondary,
                                                          fontSize:
                                                              compactPortrait
                                                              ? 10.8
                                                              : null,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (topPanelContractV1
                                            .showProgressionStatus)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Text(
                                              runnerProgressionStatusTextV1!,
                                              key: const Key(
                                                'microtask_runner_progression_status_v1',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textSecondary,
                                                    fontSize: compactPortrait
                                                        ? 10.8
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                        Semantics(
                                          label:
                                              'Foundations check, step ${_stepIndex + 1} of ${_steps.length}',
                                          child: Text(
                                            'Step ${_stepIndex + 1} of ${_steps.length}',
                                            key: topPanelContractV1
                                                .stepHeaderKey,
                                            style: AppTypography.h3.copyWith(
                                              color: SharkyTokensV1.textPrimary,
                                              fontSize: compactPortrait
                                                  ? 15
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (topPanelContractV1
                                            .showGoldLearningSlicePreludeCard)
                                          Container(
                                            key: const Key(
                                              'gold_learning_slice_prelude_card_v1',
                                            ),
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                              bottom: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.surfaceCard
                                                  .withOpacity(0.82),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SharkyTokensV1.radiusMd,
                                                  ),
                                              border: Border.all(
                                                color: SharkyTokensV1
                                                    .semanticInfo
                                                    .withOpacity(0.42),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _goldLearningSliceSetupLineV1(),
                                                  key: const Key(
                                                    'gold_learning_slice_setup_v1',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                        color: SharkyTokensV1
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                if (_goldLearningLiteracyWhyLineV1() !=
                                                    null) ...[
                                                  Text(
                                                    _goldLearningLiteracyWhyLineV1()!,
                                                    key: const Key(
                                                      'gold_learning_slice_literacy_why_v1',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTypography.caption
                                                        .copyWith(
                                                          color: SharkyTokensV1
                                                              .textSecondary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                ],
                                                Text(
                                                  _goldLearningSliceFocusLineV1(),
                                                  key: const Key(
                                                    'gold_learning_slice_focus_v1',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                        color: SharkyTokensV1
                                                            .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (topPanelContractV1
                                            .showConceptFirstSeatPreludeCard)
                                          _buildConceptFirstSeatPreludeCardV1(),
                                        if (topPanelContractV1
                                            .showHeaderPrompt) ...[
                                          SizedBox(
                                            height: compactPortrait
                                                ? 2
                                                : AppSpacing.xs,
                                          ),
                                          Text(
                                            seatQuizInstructionPresentationV1
                                                .headerPromptText,
                                            key:
                                                seatQuizInstructionPresentationV1
                                                    .headerPromptKey,
                                            maxLines:
                                                seatQuizInstructionPresentationV1
                                                    .headerMaxLines,
                                            overflow:
                                                seatQuizInstructionPresentationV1
                                                    .headerOverflow,
                                            softWrap:
                                                seatQuizInstructionPresentationV1
                                                    .headerSoftWrap,
                                            style: AppTypography.body.copyWith(
                                              color: introCaptionActive
                                                  ? SharkyTokensV1.textMuted
                                                  : SharkyTokensV1
                                                        .textSecondary,
                                              fontSize: compactPortrait
                                                  ? (introCaptionActive
                                                        ? 11.2
                                                        : 12.4)
                                                  : null,
                                            ),
                                          ),
                                        ],
                                        Offstage(
                                          offstage: true,
                                          child: Text(
                                            _effectiveExpectedSeatIdsV1.isEmpty
                                                ? ''
                                                : _effectiveExpectedSeatIdsV1
                                                      .first,
                                            key: const Key(
                                              'microtask_expected_seat_value',
                                            ),
                                          ),
                                        ),
                                        Offstage(
                                          offstage: true,
                                          child: Text(
                                            _selectedSeatId ?? '',
                                            key: const Key(
                                              'microtask_selected_seat_value',
                                            ),
                                          ),
                                        ),
                                        if (topPanelContractV1
                                            .showCampaignContext)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              _step.contextText!,
                                              key: const Key(
                                                'spine_hand_context',
                                              ),
                                              maxLines: _pressureLineClamp(
                                                context,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textMuted,
                                                  ),
                                            ),
                                          ),
                                        if (topPanelContractV1
                                            .showCampaignTradeoff)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              _step.tradeoffText!,
                                              key: const Key(
                                                'spine_hand_tradeoff',
                                              ),
                                              maxLines: _pressureLineClamp(
                                                context,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ),
                                        if (topPanelContractV1
                                            .showCampaignConsequence)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: CampaignInfoCardV1(
                                              duration: Duration(
                                                milliseconds:
                                                    _microAnimationsEnabled
                                                    ? 130
                                                    : 0,
                                              ),
                                              curve: Curves.easeOut,
                                              microAnimationsEnabled:
                                                  _microAnimationsEnabled,
                                              compact: true,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.sm,
                                                    vertical: AppSpacing.xs,
                                                  ),
                                              decoration:
                                                  _consequenceCardDecoration(),
                                              child: _buildConsequenceBody(),
                                            ),
                                          ),
                                        if (topPanelContractV1.showCampaignHud)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Step ${_stepIndex + 1}/${_steps.length} • Mistakes $_spineMistakesCount',
                                                        key: const Key(
                                                          'spine_bankroll_value',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                              color:
                                                                  SharkyTokensV1
                                                                      .textMuted,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 10.6,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _campaignHudDetailsExpanded =
                                                              !_campaignHudDetailsExpanded;
                                                        });
                                                      },
                                                      style: TextButton.styleFrom(
                                                        minimumSize: const Size(
                                                          44,
                                                          28,
                                                        ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .padded,
                                                      ),
                                                      child: Text(
                                                        _campaignHudDetailsExpanded
                                                            ? 'Hide'
                                                            : 'Details',
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                              color: SharkyTokensV1
                                                                  .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Offstage(
                                                  offstage: true,
                                                  child: Text(
                                                    'Rank: ${ProgressService.spineRankLabel(_spineRank)}',
                                                    key: const Key(
                                                      'spine_rank_value',
                                                    ),
                                                  ),
                                                ),
                                                Offstage(
                                                  offstage: true,
                                                  child: Text(
                                                    'Mistakes: $_spineMistakesCount',
                                                    key: const Key(
                                                      'spine_calibration_mistakes_value',
                                                    ),
                                                  ),
                                                ),
                                                if (topPanelContractV1
                                                    .showExtendedHudDetails)
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 2,
                                                    children: [
                                                      Text(
                                                        'Band: $_spineCalibrationBand',
                                                        key: const Key(
                                                          'spine_calibration_band_value',
                                                        ),
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                              color: SharkyTokensV1
                                                                  .brandPrimary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                      Text(
                                                        'Pack: ${widget.moduleId}',
                                                        key: const Key(
                                                          'spine_campaign_pack_id_value',
                                                        ),
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                              color: SharkyTokensV1
                                                                  .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                      Text(
                                                        'HandIndex: $_stepIndex',
                                                        key: const Key(
                                                          'spine_campaign_hand_index_value',
                                                        ),
                                                        style: AppTypography
                                                            .caption
                                                            .copyWith(
                                                              color: SharkyTokensV1
                                                                  .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                const SizedBox(height: 2),
                                                AnimatedScale(
                                                  scale: _pulseSuccess
                                                      ? 1.1
                                                      : (_pulseFailure
                                                            ? 0.98
                                                            : (_pulseBust
                                                                  ? 1.04
                                                                  : 1.0)),
                                                  duration: Duration(
                                                    milliseconds:
                                                        _microAnimationsEnabled
                                                        ? 140
                                                        : 0,
                                                  ),
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                      milliseconds:
                                                          _microAnimationsEnabled
                                                          ? 170
                                                          : 0,
                                                    ),
                                                    curve: Curves.easeOut,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (_spineDelta > 0
                                                                  ? SharkyTokensV1
                                                                        .semanticWin
                                                                  : (_spineDelta <
                                                                            0
                                                                        ? SharkyTokensV1
                                                                              .semanticLoss
                                                                        : SharkyTokensV1
                                                                              .textMuted))
                                                              .withOpacity(
                                                                _spineDelta == 0
                                                                    ? 0.14
                                                                    : 0.2,
                                                              ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            SharkyTokensV1
                                                                .radiusSm,
                                                          ),
                                                      border: Border.all(
                                                        color: _pulseBust
                                                            ? SharkyTokensV1
                                                                  .semanticLoss
                                                                  .withOpacity(
                                                                    0.7,
                                                                  )
                                                            : Colors
                                                                  .transparent,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      _spineDelta > 0
                                                          ? '+$_spineDelta chips'
                                                          : (_spineDelta < 0
                                                                ? '$_spineDelta chips'
                                                                : '0 chips'),
                                                      key: const Key(
                                                        'spine_bankroll_delta',
                                                      ),
                                                      style: AppTypography.caption.copyWith(
                                                        color: _spineDelta > 0
                                                            ? SharkyTokensV1
                                                                  .semanticWin
                                                            : (_spineDelta < 0
                                                                  ? SharkyTokensV1
                                                                        .semanticLoss
                                                                  : SharkyTokensV1
                                                                        .textSecondary),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (topPanelContractV1.showBustBanner)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              'BUST: backer can get you back in.',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .semanticLoss,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        const SizedBox(height: AppSpacing.sm),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          child: LinearProgressIndicator(
                                            key: _isCheckpointSession
                                                ? const Key(
                                                    'checkpoint_progress',
                                                  )
                                                : const Key(
                                                    'microtask_progress',
                                                  ),
                                            value: progress,
                                            minHeight: 6,
                                            backgroundColor: SharkyTokensV1
                                                .slate600
                                                .withOpacity(0.42),
                                            color: SharkyTokensV1.brandPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        if (topPanelContractV1.showSuccessBadge)
                                          Container(
                                            key: _isTablePracticeSession
                                                ? const Key(
                                                    'table_practice_success_badge',
                                                  )
                                                : const Key(
                                                    'microtask_success_badge',
                                                  ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.semanticWin
                                                  .withOpacity(0.14),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SharkyTokensV1.radiusSm,
                                                  ),
                                              border: Border.all(
                                                color: SharkyTokensV1
                                                    .semanticWin
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                            child: Text(
                                              _successBadgeText!,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        if (_showDailyCompletedBadge)
                                          Container(
                                            key: const Key(
                                              'microtask_daily_completed_badge',
                                            ),
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.brandPrimary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SharkyTokensV1.radiusSm,
                                                  ),
                                              border: Border.all(
                                                color: SharkyTokensV1
                                                    .brandPrimary
                                                    .withOpacity(0.78),
                                              ),
                                            ),
                                            child: Text(
                                              'Daily completed',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        if (_showCheckpointCompleteBadge)
                                          Container(
                                            key: const Key(
                                              'checkpoint_badge_complete',
                                            ),
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.semanticWin
                                                  .withOpacity(0.16),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    SharkyTokensV1.radiusSm,
                                                  ),
                                              border: Border.all(
                                                color: SharkyTokensV1
                                                    .semanticWin
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                            child: Text(
                                              'Checkpoint cleared',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: SharkyTokensV1
                                                        .textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!useRunnerCompactHeaderV1 || _showEngineV2StreetUi)
                          SizedBox(
                            height:
                                usesHandLoopHeaderPromptV1 && !portraitLayout
                                ? 20
                                : AppSpacing.xs,
                          ),
                        if (_showEngineV2StreetUi) ...[
                          _buildStreetTimeline(),
                          const SizedBox(height: 2),
                          _buildEngineV2TurnFeed(),
                          const SizedBox(height: 2),
                        ],
                      ],
                    ),
              viewportRegion:
                  surfacedFamilyAdapterV1.pathInputContract.tableSection,
              bottomRegion:
                  !portraitLayout ||
                      _showEngineV2Controls ||
                      _engineV2SummaryLines.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_showEngineV2Controls) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            key: const Key('microtask_engine_v2_toggle_row'),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: SharkyTokensV1.surfaceCard.withOpacity(
                                0.6,
                              ),
                              borderRadius: BorderRadius.circular(
                                SharkyTokensV1.radiusSm,
                              ),
                              border: Border.all(
                                color: SharkyTokensV1.slate600.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Use EngineV2 backend',
                                    style: AppTypography.caption.copyWith(
                                      color: SharkyTokensV1.textSecondary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  key: const Key(
                                    'microtask_engine_v2_backend_toggle',
                                  ),
                                  value: _engineV2BackendEnabled,
                                  onChanged: _engineV2CheckpointEligible
                                      ? (value) {
                                          setState(() {
                                            _engineV2BackendEnabled = value;
                                            if (!value) {
                                              _engineV2UseLegacyBackend = false;
                                            }
                                          });
                                          unawaited(
                                            AppSettingsService.instance
                                                .setEngineV2BackendEnabledV1(
                                                  value,
                                                ),
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          if (!_engineV2CheckpointEligible)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Checkpoint only',
                                style: AppTypography.caption.copyWith(
                                  color: SharkyTokensV1.textSecondary,
                                ),
                              ),
                            ),
                          if (_engineV2BackendEnabled) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              key: const Key('microtask_backend_mode_selector'),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: SharkyTokensV1.surfaceCard.withOpacity(
                                  0.6,
                                ),
                                borderRadius: BorderRadius.circular(
                                  SharkyTokensV1.radiusSm,
                                ),
                                border: Border.all(
                                  color: SharkyTokensV1.slate600.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              child: Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ChoiceChip(
                                    key: const Key(
                                      'microtask_backend_mode_engine_v2',
                                    ),
                                    label: const Text('EngineV2'),
                                    selected: !_engineV2UseLegacyBackend,
                                    onSelected: (selected) {
                                      if (!selected) return;
                                      setState(() {
                                        _engineV2UseLegacyBackend = false;
                                        _engineV2BackendChoiceMadeInSession =
                                            true;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    key: const Key(
                                      'microtask_backend_mode_legacy',
                                    ),
                                    label: const Text('Legacy'),
                                    selected: _engineV2UseLegacyBackend,
                                    onSelected: (selected) {
                                      if (!selected) return;
                                      setState(() {
                                        _engineV2UseLegacyBackend = true;
                                        _engineV2BackendChoiceMadeInSession =
                                            true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton(
                                key: const Key('microtask_engine_v2_run_cta'),
                                onPressed: _engineV2RunBusy
                                    ? null
                                    : _runEngineV2MvpFixture,
                                child: Text(
                                  _engineV2RunBusy
                                      ? (_engineV2UseLegacyBackend
                                            ? 'RUNNING LEGACY...'
                                            : 'RUNNING ENGINE V2...')
                                      : (_engineV2UseLegacyBackend
                                            ? 'RUN LEGACY BACKEND'
                                            : 'RUN ENGINE V2 BACKEND'),
                                ),
                              ),
                            ),
                          ],
                        ],
                        if (_showEngineV2Controls &&
                            _engineV2SummaryLines.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            key: const Key('microtask_engine_v2_summary'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: SharkyTokensV1.surfaceCard.withOpacity(
                                0.7,
                              ),
                              borderRadius: BorderRadius.circular(
                                SharkyTokensV1.radiusSm,
                              ),
                              border: Border.all(
                                color: SharkyTokensV1.slate600.withOpacity(0.6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EngineV2: ${_engineV2Verdict ?? 'unknown'}'
                                  '${_engineV2ErrorType == null ? '' : ' ($_engineV2ErrorType)'}',
                                  style: AppTypography.caption.copyWith(
                                    color: SharkyTokensV1.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_engineV2FallbackNote != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _engineV2FallbackNote!,
                                    style: AppTypography.caption.copyWith(
                                      color: SharkyTokensV1.textSecondary,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                for (final line in _engineV2SummaryLines)
                                  Text(
                                    line,
                                    style: AppTypography.caption.copyWith(
                                      color: SharkyTokensV1.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (!portraitLayout)
                          SharedLearnerActionSurfaceOwnerV1(
                            preActionChildren: <Widget>[
                              ...surfacedFamilyAdapterV1
                                  .pathInputContract
                                  .extrasSlots
                                  .beforePrimaryActionChildren,
                              if (useRunnerCompactHeaderV1)
                                SizedBox(
                                  height: surfacedFamilyAdapterV1
                                      .presentationContract
                                      .promptStripHeight,
                                )
                              else
                                const SizedBox(height: 8),
                              if (surfacedFamilyAdapterV1
                                      .pathInputContract
                                      .landscapeSupportContent !=
                                  null) ...[
                                const SizedBox(height: 4),
                                surfacedFamilyAdapterV1
                                    .pathInputContract
                                    .landscapeSupportContent!
                                    .child,
                              ],
                            ],
                            localPolicyBoundary:
                                surfacedOutcomeProgressionHandoffContractV1
                                    .localPolicyBoundary,
                            buildPrimaryActionSurface: (_, __) =>
                                surfacedFamilyAdapterV1
                                    .pathInputContract
                                    .actionSurface,
                            postActionChildren: <Widget>[
                              ...surfacedFamilyAdapterV1
                                  .pathInputContract
                                  .extrasSlots
                                  .afterPrimaryActionChildren,
                            ],
                            buildTrailingContinuation: (_, __) => null,
                          ),
                      ],
                    )
                  : null,
            );
            final surfacedSharedShellPayloadV1 =
                resolveWorld1SurfacedSharedShellPayloadContractV1(
                  outerPadding: bodyPadding,
                  portraitLayout: portraitLayout,
                  compactPortrait: compactPortrait,
                  shellSlots: world1CanonicalShellSlotsV1,
                  shellBody: surfacedShellBodyV1,
                );
            return Padding(
              padding: surfacedSharedShellPayloadV1.outerPadding,
              child: Stack(
                children: [
                  SharedLearnerCanonicalConsumerPathV1(
                    shellContract: surfacedSharedShellPayloadV1.shellContract,
                    frameTopRegion:
                        (surfacedSharedShellPayloadV1.shellContract.body
                                as SharedLearnerTableAdjacentFrameV1)
                            .topRegion,
                    frameViewportRegion:
                        (surfacedSharedShellPayloadV1.shellContract.body
                                as SharedLearnerTableAdjacentFrameV1)
                            .viewportRegion,
                    frameBottomRegion:
                        (surfacedSharedShellPayloadV1.shellContract.body
                                as SharedLearnerTableAdjacentFrameV1)
                            .bottomRegion,
                    overlayChild: surfacedSharedShellPayloadV1.portraitOverlay,
                  ),
                  _buildSpineContractHarnessV1(
                    useRunnerCompactHeaderV1: useRunnerCompactHeaderV1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConsequenceBody() {
    final deltaTone = _spineDelta < 0
        ? SharkyTokensV1.semanticLoss
        : (_spineDelta > 0
              ? SharkyTokensV1.semanticWin
              : SharkyTokensV1.semanticInfo);
    final prefix = _spineDelta < 0
        ? 'Outcome: Costly spot. '
        : (_spineDelta > 0 ? 'Outcome: Strong line. ' : 'Outcome: Neutral. ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            _spineDelta < 0
                ? Icons.trending_down_rounded
                : (_spineDelta > 0
                      ? Icons.trending_up_rounded
                      : Icons.info_outline_rounded),
            size: 15,
            color: deltaTone,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$prefix${_step.consequenceText!}',
            key: const Key('spine_hand_consequence'),
            maxLines: (_pressureLineClamp(context) + 1).clamp(2, 3),
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showRunnerDetailsSheetV1(BuildContext context) async {
    if (!mounted) return;
    final detailsSurfaceAdapterV1 = buildWorld1DetailsSurfaceAdapterV1(
      sourceId: '${widget.moduleId}#step${_stepIndex + 1}',
      canonicalPrompt: _displayedStepPromptV1,
      detailsPromptOverride:
          (_currentCampaignRunnerMode == _CampaignRunnerMode.handLoop &&
              !_isDemoHandLoopVisualStepV1)
          ? 'Choose the best action.'
          : _seatQuizInstructionForTargetV1(),
    );
    final revealPayloadV1 = detailsSurfaceAdapterV1.presentation.reveal;
    final teachingGrammarV1 = SharedLearnerTeachingGrammarV1(
      headerStatusText: _runnerProgressionStatusTextV1(),
      headerHeadlineText: _runnerHeaderHeadlineTextV1(),
      headerPromptText: detailsSurfaceAdapterV1.presentation.shortPrompt.trim(),
      promptStatusText: _runnerPromptStatusTextV1(),
      displayedPrompt: detailsSurfaceAdapterV1.presentation.shortPrompt.trim(),
      promptDetailsTitle: _runnerStepLabelV1(),
      promptDetailsText: revealPayloadV1.revealedText.trim(),
      canRevealPromptDetails: detailsSurfaceAdapterV1.canOpenDetailsSheet,
      enablePromptDetailsAffordance: revealPayloadV1.isAffordanceEnabled,
      supportPrimaryText: '',
      supportSecondaryText: '',
      supportTertiaryText: '',
      outcomePrimaryText: '',
      outcomeWhyText: '',
      outcomeNextText: '',
      outcomeDetailText: '',
    );
    if (!teachingGrammarV1.canRevealPromptDetails) {
      return;
    }
    final media = MediaQuery.of(context);
    final compactSheet = media.size.width < 420 || media.size.height < 820;
    await showSharedLearnerPromptRevealSheetV1(
      context: context,
      grammar: teachingGrammarV1,
      style: SharedLearnerPromptRevealLauncherStyleV1(
        backgroundColor: SharkyTokensV1.surfaceCard,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        sheetStyle: SharedLearnerTeachingPromptRevealSheetStyleV1(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          maxHeightFactor: compactSheet ? 0.68 : 0.75,
          headerTitle: 'Details',
          headerTitleStyle: AppTypography.label.copyWith(
            color: SharkyTokensV1.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          showCloseButton: true,
          detailsStyle: SharedLearnerTeachingPromptDetailsStyleV1(
            titleStyle: AppTypography.label.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            bodyStyle: AppTypography.body.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            titleBodySpacing: 6,
          ),
        ),
      ),
      buildExtraChildren: (sheetContext) {
        final extraRows = _buildWorld1LandscapeHostContentContractV1()
            .extrasSlots
            .resolvePromptRevealExtraChildren(sheetContext);
        if (extraRows.isNotEmpty) {
          return extraRows;
        }
        final packLabel = switch (widget.moduleId.trim().toLowerCase()) {
          'world1_spine_campaign_v1' => 'World 1',
          'world2_spine_campaign_v1' => 'World 2',
          _ => widget.moduleId,
        };
        final outcomeLabel =
            (_outcomeSurfaceVisible || _outcomeLines.isNotEmpty)
            ? _world1OutcomeVerdictLineV1(_outcomeLastResultCorrect)
            : 'Pending.';
        final detailTextStyle = AppTypography.caption.copyWith(
          color: SharkyTokensV1.textSecondary,
          height: 1.25,
        );
        final rows = <Widget>[
          const SizedBox(height: 8),
          Text(
            'Mistakes: $_spineMistakesCount',
            key: const Key('spine_calibration_mistakes_value'),
            style: detailTextStyle,
          ),
          Text(
            'Rank: ${ProgressService.spineRankLabel(_spineRank)}',
            key: const Key('spine_rank_value'),
            style: detailTextStyle,
          ),
          Text(
            'Pack: $packLabel',
            key: const Key('spine_campaign_pack_id_value'),
            style: detailTextStyle,
          ),
          Text(
            'HandIndex: $_stepIndex',
            key: const Key('spine_campaign_hand_index_value'),
            style: detailTextStyle,
          ),
        ];
        void addLabeled(String key, String value) {
          rows.add(const SizedBox(height: 8));
          rows.add(
            Text(
              value,
              key: Key(key),
              style: detailTextStyle.copyWith(
                color: SharkyTokensV1.textPrimary,
              ),
            ),
          );
        }

        if (_step.instructionText != null) {
          addLabeled('microtask_instruction_text', _step.instructionText!);
        }
        if (_step.goalText != null) {
          addLabeled('microtask_goal_text', _step.goalText!);
        }
        if (_step.contextText != null) {
          addLabeled('spine_hand_context', _step.contextText!);
        }
        if (_step.tradeoffText != null) {
          addLabeled('spine_hand_tradeoff', _step.tradeoffText!);
        }
        if (detailsSurfaceAdapterV1.sections.showRecap &&
            _step.consequenceText != null) {
          addLabeled('spine_hand_consequence', 'Outcome: $outcomeLabel');
        }
        if (kDebugMode) {
          final debugActionState = _campaignActionUiStateForCurrentStep();
          final expectedKind = world1SpineExpectedActionKindV1(_step);
          final expectedSeatIdsCount = _expectedSeatIdsCountV1;
          final allowedActionsCount = _allowedActionsCountV1;
          final resolvedModeLabel = _debugModeResolvedLabelV1();
          var modeReasonLabel = _debugModeReasonV1(
            expectedSeatIdsCount: expectedSeatIdsCount,
            allowedActionsCount: allowedActionsCount,
            expectedActionKind: expectedKind,
          );
          if (resolvedModeLabel == 'action_decision' &&
              expectedKind == null &&
              allowedActionsCount == 0 &&
              !_isSeatQuizByStepDataV1(expectedActionKind: expectedKind)) {
            modeReasonLabel = 'fallback_override';
          }
          final expectedAction = expectedKind == null
              ? 'n/a'
              : _actionKindLabelV1(expectedKind);
          final chosenAction = (_selectedSeatId ?? '').trim().isEmpty
              ? 'n/a'
              : _selectedSeatId!;
          final whyLine = _outcomeLines.firstWhere(
            (line) => line.startsWith('Why:'),
            orElse: () => 'n/a',
          );
          addLabeled('details_debug_header_v1', 'Debug');
          addLabeled('details_debug_pack_id_v1', 'packId: ${widget.moduleId}');
          addLabeled('details_debug_hand_index_v1', 'handIndex: $_stepIndex');
          addLabeled(
            'details_debug_step_has_expected_seat_ids_v1',
            'step_has_expectedSeatIds: ${expectedSeatIdsCount > 0} (count: $expectedSeatIdsCount)',
          );
          addLabeled(
            'details_debug_step_allowed_actions_count_v1',
            'step_allowedActions_count: $allowedActionsCount',
          );
          addLabeled(
            'details_debug_step_expected_action_kind_v1',
            'step_expectedActionKind: ${expectedKind?.name ?? 'null'}',
          );
          addLabeled(
            'details_debug_mode_resolved_v1',
            'mode_resolved: $resolvedModeLabel',
          );
          addLabeled(
            'details_debug_mode_reason_v1',
            'mode_reason: $modeReasonLabel',
          );
          final debugSeatQuizPreviewOnlyV1 =
              _isWorld2SeatQuizBeatV1 ||
              _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz ||
              _showSeatQuizPreludeV1 ||
              _showIntroSequenceV1;
          if (debugSeatQuizPreviewOnlyV1) {
            addLabeled(
              'details_debug_seat_quiz_preview_seats_v1',
              'seat_quiz_preview_seats: $_seatQuizPreviewSeatListDebugV1',
            );
          }
          if (_engineV2CurrentBetChips > 0) {
            addLabeled(
              'details_debug_current_bet_v1',
              'currentBet: $_engineV2CurrentBetChips',
            );
          }
          addLabeled(
            'details_debug_expected_chosen_v1',
            'expectedAction: $expectedAction | chosenAction: $chosenAction',
          );
          addLabeled(
            'details_debug_error_class_v1',
            'error_class: ${_engineV2ErrorType ?? 'n/a'}',
          );
          if (_isGlobalCheckpointPackV1) {
            final stepErrorClass =
                (_stepIndex >= 0 &&
                    _stepIndex < _checkpointStepErrorClassesV1.length)
                ? _checkpointStepErrorClassesV1[_stepIndex]
                : 'n/a';
            addLabeled(
              'details_debug_checkpoint_seed_v1',
              'checkpoint_seed_top3: ${_checkpointSeedTopErrorClassesV1.join(',')}',
            );
            addLabeled(
              'details_debug_checkpoint_step_error_class_v1',
              'checkpoint_step_error_class: $stepErrorClass',
            );
          }
          final debugSeatQuizModeV1 =
              _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz &&
              !_isDemoHandLoopVisualStepV1;
          if (!debugSeatQuizModeV1 &&
              debugActionState != null &&
              debugActionState.currentBet > 0 &&
              !debugActionState.hasBetOwnerInState) {
            addLabeled(
              'details_debug_bet_owner_warning_v1',
              'BET has no owner in state',
            );
          } else if (!debugSeatQuizModeV1 &&
              debugActionState?.betOwnerSeatId != null) {
            addLabeled(
              'details_debug_bet_owner_v1',
              'betOwner: ${debugActionState!.betOwnerSeatId}',
            );
          }
          if (debugActionState != null) {
            String unitsToBbDisplayV1(int units) {
              final negative = units < 0;
              final absUnits = units.abs();
              final whole = absUnits ~/ 2;
              final hasHalf = absUnits.isOdd;
              final bb = hasHalf ? '$whole.5' : '$whole';
              return negative ? '-$bb' : bb;
            }

            final sumCommitted = debugActionState.committedBySeatId.values.fold(
              0,
              (sum, amount) => sum + amount,
            );
            addLabeled(
              'details_debug_acting_seat_v1',
              'actingSeatId: ${debugActionState.actingSeatId}',
            );
            addLabeled(
              'details_debug_action_state_pot_total_v1',
              'actionState.potTotal: ${debugActionState.pot}',
            );
            addLabeled(
              'details_debug_action_state_sum_committed_v1',
              'actionState.sumCommitted: $sumCommitted',
            );
            addLabeled(
              'details_debug_action_state_current_bet_v1',
              'actionState.currentBet: ${debugActionState.currentBet}',
            );
            addLabeled(
              'details_debug_action_state_to_call_v1',
              'actionState.toCall(acting): ${debugActionState.actingSeatToCall}',
            );
            addLabeled(
              'details_debug_units_scale_v1',
              'units_scale: 1 unit = 0.5 BB',
            );
            addLabeled(
              'details_debug_pot_units_v1',
              'potTotal_units: ${debugActionState.pot}',
            );
            addLabeled(
              'details_debug_current_bet_units_v1',
              'currentBet_units: ${debugActionState.currentBet}',
            );
            addLabeled(
              'details_debug_to_call_units_v1',
              'actingToCall_units: ${debugActionState.actingSeatToCall}',
            );
            addLabeled(
              'details_debug_pot_display_v1',
              'potTotal_display: ${unitsToBbDisplayV1(debugActionState.pot)} BB',
            );
            addLabeled(
              'details_debug_current_bet_display_v1',
              'currentBet_display: ${unitsToBbDisplayV1(debugActionState.currentBet)} BB',
            );
            addLabeled(
              'details_debug_to_call_display_v1',
              'actingToCall_display: ${unitsToBbDisplayV1(debugActionState.actingSeatToCall)} BB',
            );
            if (debugActionState.lastActionSeatId != null) {
              addLabeled(
                'details_debug_last_action_seat_v1',
                'lastActionSeatId: ${debugActionState.lastActionSeatId}',
              );
            }
            if (debugActionState.lastAggressorSeatId != null) {
              addLabeled(
                'details_debug_last_aggressor_seat_v1',
                'lastAggressorSeatId: ${debugActionState.lastAggressorSeatId}',
              );
            }
            final seatRows = debugActionState.inHandBySeatId.keys.toList()
              ..sort();
            var inHandCount = 0;
            var foldedCount = 0;
            var outOfHandCount = 0;
            final quick = seatRows
                .map((seatId) {
                  final inHand =
                      debugActionState.inHandBySeatId[seatId] ?? true;
                  final folded =
                      debugActionState.foldedBySeatId[seatId] ?? false;
                  final contrib =
                      debugActionState.committedBySeatId[seatId] ?? 0;
                  final stateLabel = folded
                      ? 'folded'
                      : (inHand ? 'in' : 'out');
                  if (folded) {
                    foldedCount += 1;
                  } else if (inHand) {
                    inHandCount += 1;
                  } else {
                    outOfHandCount += 1;
                  }
                  return '$seatId:$stateLabel/c$contrib';
                })
                .join(' | ');
            addLabeled('details_debug_seat_quick_v1', 'seats: $quick');
            addLabeled(
              'details_debug_seat_counts_v1',
              'seat_counts in=$inHandCount folded=$foldedCount out=$outOfHandCount',
            );
            final debugStreetV1 = _effectiveBoardStreetForCurrentStepV1();
            final debugBoardCountV1 = _visibleBoardCardsForStreet(
              debugStreetV1,
            );
            addLabeled(
              'details_debug_street_v1',
              'street: ${debugStreetV1.name}',
            );
            addLabeled(
              'details_debug_board_count_v1',
              'board_count: $debugBoardCountV1',
            );
          }
          addLabeled('details_debug_why_v1', 'why_v1: $whyLine');
          addLabeled(
            'details_debug_session_started_v1',
            'session_started: ${_sessionStartedAt.toIso8601String()}',
          );
          addLabeled(
            'details_debug_decision_started_v1',
            'decision_started: ${_decisionStartedAt.toIso8601String()}',
          );
          final debugPathLabelV1 =
              _currentCampaignRunnerMode == _CampaignRunnerMode.seatQuiz
              ? 'seat_quiz'
              : 'action_decision';
          addLabeled('details_debug_path_v1', 'path: $debugPathLabelV1');
          addLabeled(
            'details_debug_decision_tap_us_v1',
            'decision_tap_us: ${_debugDecisionTapUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_state_applied_us_v1',
            'state_applied_us: ${_debugStateAppliedUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_engine_start_us_v1',
            'engine_start_us: ${_debugEngineStartUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_engine_done_us_v1',
            'engine_done_us: ${_debugEngineDoneUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_post_engine_done_us_v1',
            'post_engine_done_us: ${_debugPostEngineDoneUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_before_show_outcome_us_v1',
            'before_show_outcome_us: ${_debugBeforeShowOutcomeUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_after_show_outcome_call_us_v1',
            'after_show_outcome_call_us: ${_debugAfterShowOutcomeCallUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_outcome_entry_us_v1',
            'show_outcome_entry_us: ${_debugShowOutcomeEntryUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_outcome_before_setstate_us_v1',
            'show_outcome_before_setstate_us: ${_debugShowOutcomeBeforeSetStateUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_outcome_after_setstate_us_v1',
            'show_outcome_after_setstate_us: ${_debugShowOutcomeAfterSetStateUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_outcome_setstate_us_v1',
            'outcome_setstate_us: ${_debugOutcomeSetStateUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_outcome_first_frame_us_v1',
            'outcome_first_frame_us: ${_debugOutcomeFirstFrameUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_telemetry_us_v1',
            'pre_show_telemetry_us: ${_debugPreShowTelemetryUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_feedback_fx_us_v1',
            'pre_show_feedback_fx_us: ${_debugPreShowFeedbackFxUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_progression_us_v1',
            'pre_show_progression_us: ${_debugPreShowProgressionUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_feedback_setstate_us_v1',
            'pre_show_feedback_setstate_us: ${_debugPreShowFeedbackSetStateUsV1 ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_seat_quiz_prep_us_v1',
            'pre_show_seat_quiz_prep_us: ${_debugPreShowSeatQuizPrepUsV1 ?? 'n/a'}',
          );
          final deltaEngineMs =
              (_debugEngineStartUsV1 != null &&
                  _debugEngineDoneUsV1 != null &&
                  _debugEngineDoneUsV1! >= _debugEngineStartUsV1!)
              ? ((_debugEngineDoneUsV1! - _debugEngineStartUsV1!) / 1000)
                    .round()
              : null;
          final deltaCommitMs =
              (_debugEngineDoneUsV1 != null &&
                  _debugOutcomeSetStateUsV1 != null &&
                  _debugOutcomeSetStateUsV1! >= _debugEngineDoneUsV1!)
              ? ((_debugOutcomeSetStateUsV1! - _debugEngineDoneUsV1!) / 1000)
                    .round()
              : null;
          final commitPreShowMs =
              (_debugPostEngineDoneUsV1 != null &&
                  _debugBeforeShowOutcomeUsV1 != null &&
                  _debugBeforeShowOutcomeUsV1! >= _debugPostEngineDoneUsV1!)
              ? ((_debugBeforeShowOutcomeUsV1! - _debugPostEngineDoneUsV1!) /
                        1000)
                    .round()
              : null;
          final showCallMs =
              (_debugBeforeShowOutcomeUsV1 != null &&
                  _debugAfterShowOutcomeCallUsV1 != null &&
                  _debugAfterShowOutcomeCallUsV1! >=
                      _debugBeforeShowOutcomeUsV1!)
              ? ((_debugAfterShowOutcomeCallUsV1! -
                            _debugBeforeShowOutcomeUsV1!) /
                        1000)
                    .round()
              : null;
          final showPreSetStateMs =
              (_debugShowOutcomeEntryUsV1 != null &&
                  _debugShowOutcomeBeforeSetStateUsV1 != null &&
                  _debugShowOutcomeBeforeSetStateUsV1! >=
                      _debugShowOutcomeEntryUsV1!)
              ? ((_debugShowOutcomeBeforeSetStateUsV1! -
                            _debugShowOutcomeEntryUsV1!) /
                        1000)
                    .round()
              : null;
          final showSetStateMs =
              (_debugShowOutcomeBeforeSetStateUsV1 != null &&
                  _debugShowOutcomeAfterSetStateUsV1 != null &&
                  _debugShowOutcomeAfterSetStateUsV1! >=
                      _debugShowOutcomeBeforeSetStateUsV1!)
              ? ((_debugShowOutcomeAfterSetStateUsV1! -
                            _debugShowOutcomeBeforeSetStateUsV1!) /
                        1000)
                    .round()
              : null;
          final preShowTelemetryMs = _debugPreShowTelemetryUsV1 == null
              ? null
              : (_debugPreShowTelemetryUsV1! / 1000).round();
          final preShowFeedbackFxMs = _debugPreShowFeedbackFxUsV1 == null
              ? null
              : (_debugPreShowFeedbackFxUsV1! / 1000).round();
          final preShowProgressionMs = _debugPreShowProgressionUsV1 == null
              ? null
              : (_debugPreShowProgressionUsV1! / 1000).round();
          final preShowFeedbackSetStateMs =
              _debugPreShowFeedbackSetStateUsV1 == null
              ? null
              : (_debugPreShowFeedbackSetStateUsV1! / 1000).round();
          final preShowSeatQuizPrepMs = _debugPreShowSeatQuizPrepUsV1 == null
              ? null
              : (_debugPreShowSeatQuizPrepUsV1! / 1000).round();
          final hole1Ms =
              (_debugHole1T0UsV1 != null &&
                  _debugHole1T1UsV1 != null &&
                  _debugHole1T1UsV1! >= _debugHole1T0UsV1!)
              ? ((_debugHole1T1UsV1! - _debugHole1T0UsV1!) / 1000).round()
              : null;
          final hole2Ms =
              (_debugHole2T0UsV1 != null &&
                  _debugHole2T1UsV1 != null &&
                  _debugHole2T1UsV1! >= _debugHole2T0UsV1!)
              ? ((_debugHole2T1UsV1! - _debugHole2T0UsV1!) / 1000).round()
              : null;
          final hole3Ms =
              (_debugHole3T0UsV1 != null &&
                  _debugHole3T1UsV1 != null &&
                  _debugHole3T1UsV1! >= _debugHole3T0UsV1!)
              ? ((_debugHole3T1UsV1! - _debugHole3T0UsV1!) / 1000).round()
              : null;
          final deltaFrameMs =
              (_debugOutcomeSetStateUsV1 != null &&
                  _debugOutcomeFirstFrameUsV1 != null &&
                  _debugOutcomeFirstFrameUsV1! >= _debugOutcomeSetStateUsV1!)
              ? ((_debugOutcomeFirstFrameUsV1! - _debugOutcomeSetStateUsV1!) /
                        1000)
                    .round()
              : null;
          final totalMs =
              (_debugDecisionTapUsV1 != null &&
                  _debugOutcomeFirstFrameUsV1 != null &&
                  _debugOutcomeFirstFrameUsV1! >= _debugDecisionTapUsV1!)
              ? ((_debugOutcomeFirstFrameUsV1! - _debugDecisionTapUsV1!) / 1000)
                    .round()
              : (_debugDecisionTapUsV1 != null &&
                    _debugOutcomeSetStateUsV1 != null &&
                    _debugOutcomeSetStateUsV1! >= _debugDecisionTapUsV1!)
              ? ((_debugOutcomeSetStateUsV1! - _debugDecisionTapUsV1!) / 1000)
                    .round()
              : null;
          final latencyMs =
              (_debugDecisionTapUsV1 != null &&
                  _debugStateAppliedUsV1 != null &&
                  _debugStateAppliedUsV1! >= _debugDecisionTapUsV1!)
              ? ((_debugStateAppliedUsV1! - _debugDecisionTapUsV1!) / 1000)
                    .round()
              : null;
          addLabeled(
            'details_debug_delta_engine_ms_v1',
            'delta_engine_ms: ${deltaEngineMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_delta_commit_ms_v1',
            'delta_commit_ms: ${deltaCommitMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_commit_pre_show_ms_v1',
            'commit_pre_show_ms: ${commitPreShowMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_call_ms_v1',
            'show_call_ms: ${showCallMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_pre_setstate_ms_v1',
            'show_pre_setstate_ms: ${showPreSetStateMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_show_setstate_ms_v1',
            'show_setstate_ms: ${showSetStateMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_telemetry_ms_v1',
            'pre_show_telemetry_ms: ${preShowTelemetryMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_feedback_fx_ms_v1',
            'pre_show_feedback_fx_ms: ${preShowFeedbackFxMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_progression_ms_v1',
            'pre_show_progression_ms: ${preShowProgressionMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_feedback_setstate_ms_v1',
            'pre_show_feedback_setstate_ms: ${preShowFeedbackSetStateMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_pre_show_seat_quiz_prep_ms_v1',
            'pre_show_seat_quiz_prep_ms: ${preShowSeatQuizPrepMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_hole1_ms_v1',
            'hole1_ms($_debugHole1LabelV1): ${hole1Ms?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_hole2_ms_v1',
            'hole2_ms($_debugHole2LabelV1): ${hole2Ms?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_hole3_ms_v1',
            'hole3_ms($_debugHole3LabelV1): ${hole3Ms?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_delta_frame_ms_v1',
            'delta_frame_ms: ${deltaFrameMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_total_ms_v1',
            'total_ms: ${totalMs?.toString() ?? 'n/a'}',
          );
          addLabeled(
            'details_debug_latency_ms_v1',
            'latency_ms: ${latencyMs?.toString() ?? 'n/a'}',
          );
        }
        return <Widget>[const SizedBox(height: 8), ...rows.skip(2)];
      },
    );
  }

  Widget _buildRunnerCompactHeaderV1({
    required BuildContext context,
    required bool compactPortrait,
    required _World1TeachingContractV1 teachingContractV1,
    required bool hidePromptCapsuleV1,
    required World1SurfacedHeaderPromptInputV1 headerPromptInputV1,
  }) {
    final useLiveVerticalCompositionProfileV1 =
        _isCampaignSpineSession &&
        _resolveStableLayoutV1(
          context: context,
          media: MediaQuery.of(context),
        ).portraitLayout &&
        _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop;
    if (useLiveVerticalCompositionProfileV1) {
      final actionStateV1 = _campaignActionUiStateForCurrentStep();
      return _buildLiveReferenceParityHeaderBandV1(
        context: context,
        headerPromptInputV1: headerPromptInputV1,
        statusText: headerPromptInputV1.statusText ?? '',
        headlineText: headerPromptInputV1.headlineText,
        actionStateV1: actionStateV1,
      );
    }
    final headerGrammarV1 = teachingContractV1.sharedTeachingGrammarV1.copyWith(
      headerStatusText: headerPromptInputV1.statusText,
      headerHeadlineText: headerPromptInputV1.headlineText,
      headerPromptText: headerPromptInputV1.headerPromptText,
      promptStatusText: null,
      enablePromptDetailsAffordance: headerPromptInputV1.canOpenDetailsSheet,
    );
    return SharedLearnerTeachingHeaderV1(
      grammar: headerGrammarV1,
      onOpenDetails: () => _showRunnerDetailsSheetV1(context),
      style: SharedLearnerTeachingHeaderStyleV1(
        surfaceKey: _isCheckpointSession
            ? const Key('checkpoint_runner')
            : (_isTablePracticeSession
                  ? const Key('table_practice_runner')
                  : const Key('microtask_runner')),
        statusTextKey: const Key('microtask_runner_progression_status_v1'),
        headlineTextKey: _isCheckpointSession
            ? const Key('checkpoint_step_header')
            : (_isTablePracticeSession
                  ? const Key('table_practice_step_header')
                  : const Key('microtask_step_header')),
        promptSurfaceKey: const Key('microtask_runner_prompt_capsule_v1'),
        promptTextKey: headerPromptInputV1.headerPromptKey,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: headerPromptInputV1.canOpenDetailsSheet
                  ? () => _showRunnerDetailsSheetV1(context)
                  : null,
              style: TextButton.styleFrom(
                minimumSize: Size(40, compactPortrait ? 26 : 30),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(
                  horizontal: compactPortrait ? 4 : 6,
                ),
              ),
              icon: Icon(
                Icons.info_outline_rounded,
                size: compactPortrait ? 13 : 14,
              ),
              label: Text(
                'Details',
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: compactPortrait
                      ? (useLiveVerticalCompositionProfileV1 ? 9.8 : 10.2)
                      : 10.8,
                  height: 1.0,
                ),
              ),
            ),
            if (kDebugMode && _isGlobalCheckpointPackV1)
              Opacity(
                opacity: 0,
                child: Text(
                  (_stepIndex >= 0 &&
                          _stepIndex < _checkpointStepErrorClassesV1.length)
                      ? _checkpointStepErrorClassesV1[_stepIndex]
                      : 'n/a',
                  key: const Key('checkpoint_seed_step_error_class_v1'),
                ),
              ),
          ],
        ),
        compact: compactPortrait,
        surfaceColor: SharkyTokensV1.surfaceCard.withOpacity(0.18),
        borderColor: SharkyTokensV1.slate600.withOpacity(0.14),
        statusColor: SharkyTokensV1.textSecondary,
        headlineColor: SharkyTokensV1.textPrimary,
        promptForegroundColor: SharkyTokensV1.textSecondary,
        promptSurfaceColor: useLiveVerticalCompositionProfileV1
            ? SharkyTokensV1.surfaceCard.withOpacity(0.08)
            : SharkyTokensV1.surfaceCard.withOpacity(0.14),
        promptBorderColor: useLiveVerticalCompositionProfileV1
            ? SharkyTokensV1.slate600.withOpacity(0.08)
            : SharkyTokensV1.slate600.withOpacity(0.14),
        promptBadgeColor: useLiveVerticalCompositionProfileV1
            ? SharkyTokensV1.slate600.withOpacity(0.05)
            : SharkyTokensV1.slate600.withOpacity(0.10),
        promptPadding: useLiveVerticalCompositionProfileV1
            ? const EdgeInsets.fromLTRB(4, 1.5, 4, 1.5)
            : const EdgeInsets.fromLTRB(6, 2, 6, 2),
        surfacePadding: useLiveVerticalCompositionProfileV1
            ? const EdgeInsets.fromLTRB(6, 3, 6, 3)
            : null,
        surfaceBottomChildGap: useLiveVerticalCompositionProfileV1 ? 2 : null,
        showPromptCapsule: !hidePromptCapsuleV1,
        maxPromptLines: compactPortrait && headerPromptInputV1.headerSoftWrap
            ? math.max(headerPromptInputV1.headerMaxLines, 3)
            : headerPromptInputV1.headerMaxLines,
        promptOverflow: compactPortrait && headerPromptInputV1.headerSoftWrap
            ? TextOverflow.clip
            : headerPromptInputV1.headerOverflow,
        promptSoftWrap: headerPromptInputV1.headerSoftWrap,
      ),
    );
  }

  Widget _buildLiveReferenceParityHeaderBandV1({
    required BuildContext context,
    required World1SurfacedHeaderPromptInputV1 headerPromptInputV1,
    required String statusText,
    required String headlineText,
    required World1SurfacedActionStateV1? actionStateV1,
  }) {
    return Container(
      key: const Key('microtask_runner'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
        decoration: BoxDecoration(
          color: const Color(0xFF15223A).withOpacity(0.34),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF2A6BDA).withOpacity(0.16),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    statusText,
                    key: const Key('microtask_runner_progression_status_v1'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary.withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 9.0,
                      height: 1.0,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: headerPromptInputV1.canOpenDetailsSheet
                      ? () => _showRunnerDetailsSheetV1(context)
                      : null,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(26, 17),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 9),
                  label: Text(
                    'Details',
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary.withOpacity(0.88),
                      fontWeight: FontWeight.w700,
                      fontSize: 8.0,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0.5),
            Text(
              headlineText,
              key: const Key('microtask_step_header'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.4,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStateBadgeV1({
    required Key key,
    required String label,
    required Color fill,
    required Color border,
    required Color foreground,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 10.0,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildWorld1TableV1({
    required _World1StableLayoutV1 stableLayoutV1,
    required World1CanonicalTableRenderBranchStateV1 tableRenderBranchV1,
    required World1SurfacedHandLoopPromptSurfaceV1 handLoopPromptSurfaceV1,
    required _World1CompactTeachingPayloadV1 compactTeachingPayloadV1,
  }) {
    final visualCards = _engineVisualCardsForCurrentBeat();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox(key: Key('microtask_table_canvas'));
        }
        final portraitLayout = stableLayoutV1.portraitLayout;
        final compactPortrait = stableLayoutV1.compactPortrait;
        final seatsV1 =
            _World1FoundationsMicroTaskRunnerScreenState._seatsForMaxPlayersV1(
              _effectiveSeatLayoutMaxPlayersV1,
            );
        var introCaptionTitleV1 =
            (_activeSeatQuizCoachStepV1?.title ??
                    (_showSeatQuizPreludeV1
                        ? _seatQuizPreviewTitleV1
                        : (_introSequenceStepV1?.prompt ??
                              _seatQuizFallbackGuidanceTitleV1)))
                .trim();
        var introCaptionSubtitleV1 =
            (_activeSeatQuizCoachStepV1?.subtitle ??
                    (_showSeatQuizPreludeV1
                        ? _seatQuizPreviewSubtitleV1
                        : (_guidedSeatStepV1?.subtitle ?? '')))
                .trim();
        var showIntroCaptionSubtitleV1 =
            introCaptionSubtitleV1.isNotEmpty &&
            introCaptionSubtitleV1.toLowerCase() !=
                introCaptionTitleV1.toLowerCase();
        final instructionSourceV1 = widget.instructionSourceV1;
        final lockSeatQuizInstructionOverrideV1 =
            _showWorld1IntroPreludeSurfaceV1;
        if (_showWorld1IntroPreludeSurfaceV1 &&
            instructionSourceV1 != null &&
            !lockSeatQuizInstructionOverrideV1) {
          final introCoachRailTotalV1 = _seatQuizCoachStepsV1.length;
          final introCoachRailActiveIndexV1 = _showSeatQuizPreludeV1
              ? 0
              : (1 + _introSequenceIndexV1).clamp(
                  0,
                  math.max(0, introCoachRailTotalV1 - 1),
                );
          final overriddenIntro = instructionSourceV1.getIntroInstruction(
            moduleId: widget.moduleId,
            moduleTitle: widget.moduleTitle,
            railIndex: introCoachRailActiveIndexV1.toInt(),
            railTotal: introCoachRailTotalV1,
            fallback: RunnerInstructionContentV1(
              title: introCaptionTitleV1,
              subtitle: showIntroCaptionSubtitleV1
                  ? introCaptionSubtitleV1
                  : '',
            ),
          );
          if (overriddenIntro != null) {
            introCaptionTitleV1 = overriddenIntro.title.trim();
            introCaptionSubtitleV1 = overriddenIntro.subtitle.trim();
            showIntroCaptionSubtitleV1 =
                introCaptionSubtitleV1.isNotEmpty &&
                introCaptionSubtitleV1.toLowerCase() !=
                    introCaptionTitleV1.toLowerCase();
          }
        }
        if (_showWorld1IntroPreludeSurfaceV1 &&
            introCaptionTitleV1.trim().isEmpty) {
          introCaptionTitleV1 = _seatQuizFallbackGuidanceTitleV1;
        }
        final handLoopActionState = tableRenderBranchV1.handLoopVisualMode
            ? _campaignActionUiStateForCurrentStep()
            : null;
        final tableSceneRuntimeV1 = resolveWorld1SurfacedTableSceneRuntimeV1(
          World1SurfacedTableSceneRuntimeInputV1(
            canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
            portraitLayout: portraitLayout,
            compactPortrait: compactPortrait,
            seatIds: seatsV1.map((seat) => seat.id).toList(growable: false),
            selectedVisualSeatId: _seatVisualSelectionIdV1(),
            targetSeatId: tableRenderBranchV1.targetSeatId,
            demoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
            heroSeatId: _step.heroSeatId,
            normalizedHeroSeatId: _normalizedScenarioSeatIdV1(_step.heroSeatId),
            forceHandLoopSurfaceForTest: _forceHandLoopSurfaceForTestV1,
            seatQuizVisualMode: tableRenderBranchV1.seatQuizVisualMode,
            handLoopVisualMode: tableRenderBranchV1.handLoopVisualMode,
            outcomeSurfaceVisible: _outcomeSurfaceVisible,
            showSeatQuizPrelude: _showSeatQuizPreludeV1,
            showIntroSequence: _showIntroSequenceV1,
            reviewQueuePrefix: handLoopPromptSurfaceV1.reviewQueuePrefix,
            debugCaptionOverridePresent:
                widget.debugHandLoopFeltCaptionOverrideV1?.trim().isNotEmpty ??
                false,
            handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
            handLoopActionState: handLoopActionState,
            heroCards: visualCards.hero,
            boardCards: visualCards.board,
            fallbackFeltCaptionText: _handLoopFeltCaptionTextV1(
              _campaignActionUiStateForCurrentStep(),
            ),
            selectedSeatId: _seatVisualSelectionIdV1(),
            coachSeatGlowId: (_showSeatQuizPreludeV1 || _showIntroSequenceV1)
                ? _activeSeatQuizCoachStepV1?.highlightSeatId
                : null,
          ),
        );
        final tableSpatialScaffoldV1 = tableSceneRuntimeV1.spatialScaffoldV1;
        final compactPhone = tableSpatialScaffoldV1.compactPhone;
        final tableViewportWidthFactor =
            tableSpatialScaffoldV1.tableViewportWidthFactor;
        final tableViewportHeightFactor =
            tableSpatialScaffoldV1.tableViewportHeightFactor;
        final tableCenter = tableSpatialScaffoldV1.tableCenter;
        final tableGeom = tableSpatialScaffoldV1.geometry;
        final tableShellRectV1 = tableSpatialScaffoldV1.tableShellRect;
        final stadiumRect = tableSpatialScaffoldV1.stadiumRect;
        final nonOverlappingSeatSize =
            tableSpatialScaffoldV1.nonOverlappingSeatSize;
        final seatByIdMapV1 = <String, _SeatMeta>{
          for (final seat in seatsV1) seat.id: seat,
        };
        final seatRenderOrder = tableSpatialScaffoldV1.seatRenderOrderIds
            .map((id) => seatByIdMapV1[id]!)
            .toList(growable: false);
        final canonicalSeatOrderIdsV1 = List<String>.from(
          tableSpatialScaffoldV1.seatRingOrder,
          growable: false,
        );

        Offset resolvePointOnStadium({
          required Offset normalized,
          required double safeInset,
        }) => tableSpatialScaffoldV1.resolvePointOnStadium(
          normalized: normalized,
          safeInset: safeInset,
        );

        Alignment alignmentForPoint(Offset point) =>
            tableSpatialScaffoldV1.alignmentForPoint(point);

        Offset resolveSeatCenter(_SeatMeta seat) =>
            tableSpatialScaffoldV1.resolveSeatCenter(seat.id);

        Offset clampMarkerCenter(Offset center, double markerRadius) {
          final minX = markerRadius + 1;
          final maxX = constraints.maxWidth - markerRadius - 1;
          final minY = markerRadius + 1;
          final maxY = constraints.maxHeight - markerRadius - 1;
          final resolvedX = maxX < minX
              ? tableCenter.dx
              : center.dx.clamp(minX, maxX).toDouble();
          final resolvedY = maxY < minY
              ? tableCenter.dy
              : center.dy.clamp(minY, maxY).toDouble();
          return Offset(resolvedX, resolvedY);
        }

        bool markerIntersectsRect(Offset center, double radius, Rect rect) {
          final nearestX = center.dx.clamp(rect.left, rect.right).toDouble();
          final nearestY = center.dy.clamp(rect.top, rect.bottom).toDouble();
          final dx = center.dx - nearestX;
          final dy = center.dy - nearestY;
          return (dx * dx + dy * dy) <= (radius * radius);
        }

        _SeatMeta seatById(String id) =>
            seatsV1.firstWhere((seat) => seat.id == id);
        Widget buildFocusGlowRectV1({
          required Rect rect,
          required Color color,
          double inflateX = 12,
          double inflateY = 8,
          double borderRadius = 14,
          double opacity = 0.18,
          double blur = 22,
        }) {
          final glowRect = Rect.fromCenter(
            center: rect.center,
            width: rect.width + (inflateX * 2),
            height: rect.height + (inflateY * 2),
          );
          return Positioned(
            left: glowRect.left,
            top: glowRect.top,
            width: glowRect.width,
            height: glowRect.height,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: RadialGradient(
                    colors: <Color>[
                      color.withOpacity(opacity),
                      color.withOpacity(opacity * 0.45),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.55, 1.0],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withOpacity(opacity * 0.55),
                      blurRadius: blur,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        Widget buildFocusGlowCircleV1({
          required Offset center,
          required double radius,
          required Color color,
          double opacity = 0.16,
          double blur = 20,
        }) {
          final size = radius * 2;
          return Positioned(
            left: center.dx - radius,
            top: center.dy - radius,
            width: size,
            height: size,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      color.withOpacity(opacity),
                      color.withOpacity(opacity * 0.45),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.58, 1.0],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withOpacity(opacity * 0.5),
                      blurRadius: blur,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final seatQuizVisualMode = tableRenderBranchV1.seatQuizVisualMode;
        final handLoopVisualMode = tableRenderBranchV1.handLoopVisualMode;
        final targetSeatId = tableRenderBranchV1.targetSeatId;
        final targetSeatCenter = tableSpatialScaffoldV1.targetSeatCenter;
        final rotatingHeroSeatIdV1 = tableSpatialScaffoldV1.rotatingHeroSeatId;
        final canRotateSeatDisplayV1 =
            tableSpatialScaffoldV1.canRotateSeatDisplay;
        String displaySeatIdForLogicalV1(String logicalSeatId) {
          return tableSpatialScaffoldV1.displaySeatIdForLogical(logicalSeatId);
        }

        String logicalSeatIdForDisplayV1(String displaySeatId) {
          return tableSpatialScaffoldV1.logicalSeatIdForDisplay(displaySeatId);
        }

        final btnCenter = tableSpatialScaffoldV1.btnCenter;
        final sbCenter = tableSpatialScaffoldV1.sbCenter;
        final bbCenter = tableSpatialScaffoldV1.bbCenter;
        const cueRadius = 8.5;
        final seatVisualRadius = tableSpatialScaffoldV1.seatVisualRadius;
        final showCampaignHandVisuals =
            tableSceneRuntimeV1.showCampaignHandVisuals;
        final heroCardsRect = tableSceneRuntimeV1.heroCardsRect;
        final heroCardScale = tableSceneRuntimeV1.heroCardScale;
        final boardCardScale = tableSceneRuntimeV1.boardCardScale;
        final handLoopActionRequiredV1 =
            tableSceneRuntimeV1.handLoopActionRequiredV1;
        final handLoopOutcomeFocusDeemphasisV1 =
            tableSceneRuntimeV1.handLoopOutcomeFocusDeemphasisV1;
        final handLoopActingSeatCenterV1 =
            tableSceneRuntimeV1.handLoopActingSeatCenterV1;
        final activeSeatGlowIdV1 = tableSceneRuntimeV1.activeSeatGlowIdV1;
        const double captionLaneY = 0.16;
        final overlayLaneContractV1 = tableSceneRuntimeV1.overlayLaneContractV1;
        final overlayLaneRect = overlayLaneContractV1.overlayLaneRect;
        final feltCaptionTopInsetV1 = overlayLaneContractV1.feltCaptionTopInset;
        final feltCaptionTopV1 = overlayLaneContractV1.feltCaptionTop;
        final handLoopPromptTopBandCoexistenceV1 =
            tableSceneRuntimeV1.handLoopPromptTopBandCoexistenceV1;
        final feltCaptionContractV1 = tableSceneRuntimeV1.feltCaptionContractV1;
        final dealerCueCenter = tableSceneRuntimeV1.dealerCueCenter;
        final sbCueCenter = tableSceneRuntimeV1.sbCueCenter;
        final bbCueCenter = tableSceneRuntimeV1.bbCueCenter;
        final globalTrainingOverlayActiveV1 =
            _showGlobalTrainingIntroPreludeV1 &&
            _isWorld1SpineCampaignEntryV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final world1IntroOverlayActiveV1 =
            _showWorld1IntroPreludeV1 &&
            _isWorld1FirstUserOnboardingTargetV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final world1ActionIntroOverlayActiveV1 =
            _showWorld1ActionIntroPreludeV1 &&
            _isWorld1ActionLiteracyContinuityTargetV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final world1StreetFlowIntroOverlayActiveV1 =
            _showWorld1StreetFlowIntroPreludeV1 &&
            _isWorld1StreetFlowContinuityTargetV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final world2IntroOverlayActiveV1 =
            _showWorld2IntroPreludeV1 &&
            _isWorld2SpineCampaignEntryV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final world2HandoffOverlayActiveV1 =
            _showWorld2HandoffPreludeV1 &&
            _isWorld2SpineCampaignEntryV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode;
        final trackIntroOverlayActiveV1 =
            _showTrackIntroPreludeV1 && _isWorld10TrackFollowupPackV1;
        final worldIntroOverlayActiveV1 =
            globalTrainingOverlayActiveV1 ||
            world1IntroOverlayActiveV1 ||
            world1ActionIntroOverlayActiveV1 ||
            world1StreetFlowIntroOverlayActiveV1 ||
            world2HandoffOverlayActiveV1 ||
            world2IntroOverlayActiveV1 ||
            trackIntroOverlayActiveV1;
        final conceptSeatPreludeInstructionSurfaceActiveV1 =
            seatQuizVisualMode &&
            !handLoopVisualMode &&
            _showConceptFirstSeatPreludeCardV1 &&
            !worldIntroOverlayActiveV1;
        final actionLiteracyPreludeInstructionSurfaceActiveV1 =
            _showActionLiteracyPreludeCardV1 &&
            seatQuizVisualMode &&
            !handLoopVisualMode &&
            !worldIntroOverlayActiveV1;
        final streetFlowPreludeInstructionSurfaceActiveV1 =
            seatQuizVisualMode &&
            !handLoopVisualMode &&
            _showStreetFlowPreludeCardV1 &&
            !worldIntroOverlayActiveV1;
        final seatQuizTableInstructionTextV1 =
            conceptSeatPreludeInstructionSurfaceActiveV1
            ? _conceptFirstSeatPlacementPreviewTextV1()
            : (actionLiteracyPreludeInstructionSurfaceActiveV1
                  ? _actionLiteracyPlacementPreviewTextV1()
                  : (streetFlowPreludeInstructionSurfaceActiveV1
                        ? _streetFlowPlacementPreviewTextV1()
                        : (_seatQuizInstructionForTargetV1()?.trim() ?? '')));
        final trackHandoffStatusLineV1 = _trackHandoffStatusLineV1();
        final cashTrackIntroOverlayTextV1 =
            '${trackHandoffStatusLineV1 ?? 'Cash track'}\n'
            'Cash track: play deeper stacks and stable rules.\n'
            'Focus: value, fold equity, and position.';
        final tournamentTrackIntroOverlayTextV1 =
            '${trackHandoffStatusLineV1 ?? 'Tournament track'}\n'
            'Tournament track: survival pressure changes value.\n'
            'Focus: risk premium and avoiding punts.';
        final mixedTrackIntroOverlayTextV1 =
            '${trackHandoffStatusLineV1 ?? 'Mixed track'}\n'
            'Mixed track: balance cash fundamentals and tournament pressure.\n'
            'Focus: one adjustment at a time.';
        final seatSceneControllerV1 =
            resolveWorld1SurfacedSeatSceneControllerV1(
              World1SurfacedSeatSceneControllerInputV1(
                instructionInput:
                    World1SurfacedSeatSceneInstructionControllerInputV1(
                      seatQuizVisualMode: seatQuizVisualMode,
                      handLoopVisualMode: handLoopVisualMode,
                      globalTrainingOverlayActive:
                          globalTrainingOverlayActiveV1,
                      world1IntroOverlayActive: world1IntroOverlayActiveV1,
                      world1ActionIntroOverlayActive:
                          world1ActionIntroOverlayActiveV1,
                      world1StreetFlowIntroOverlayActive:
                          world1StreetFlowIntroOverlayActiveV1,
                      world2HandoffOverlayActive: world2HandoffOverlayActiveV1,
                      world2IntroOverlayActive: world2IntroOverlayActiveV1,
                      trackIntroOverlayActive: trackIntroOverlayActiveV1,
                      conceptPreludeInstructionSurfaceActive:
                          conceptSeatPreludeInstructionSurfaceActiveV1,
                      actionLiteracyPreludeInstructionSurfaceActive:
                          actionLiteracyPreludeInstructionSurfaceActiveV1,
                      streetFlowPreludeInstructionSurfaceActive:
                          streetFlowPreludeInstructionSurfaceActiveV1,
                      seatQuizTableInstructionText:
                          seatQuizTableInstructionTextV1,
                      cashTrackIntroOverlayText: cashTrackIntroOverlayTextV1,
                      tournamentTrackIntroOverlayText:
                          tournamentTrackIntroOverlayTextV1,
                      mixedTrackIntroOverlayText: mixedTrackIntroOverlayTextV1,
                      trackIntroKind: _trackIntroKindV1,
                      conceptPreludePlacementText:
                          _conceptFirstSeatPlacementPreviewTextV1(),
                      actionLiteracyPlacementText:
                          _actionLiteracyPlacementPreviewTextV1(),
                      streetFlowPlacementText:
                          _streetFlowPlacementPreviewTextV1(),
                      stadiumRect: stadiumRect,
                      availableWidth: constraints.maxWidth,
                      compactPortrait: compactPortrait,
                      textDirection: Directionality.of(context),
                      seatAvoidRects: seatsV1
                          .map(
                            (seat) => Rect.fromCenter(
                              center: resolveSeatCenter(seat),
                              width: nonOverlappingSeatSize,
                              height: nonOverlappingSeatSize,
                            ),
                          )
                          .toList(growable: false),
                    ),
                seatEntries: [
                  for (final displaySeat in seatRenderOrder)
                    (() {
                      final logicalSeat = seatById(
                        logicalSeatIdForDisplayV1(displaySeat.id),
                      );
                      final seatCenter = resolveSeatCenter(displaySeat);
                      return World1SurfacedSeatSceneEntryInputV1(
                        seatSceneInput: World1CanonicalTableSeatSceneInputV1(
                          displaySeatId: displaySeat.id,
                          logicalSeatId: logicalSeat.id,
                          seatLabel: logicalSeat.label,
                          displayLabelText: _displaySeatBadgeLabelV1(
                            logicalSeat.id,
                          ),
                          canonicalOrderBadgeText: seatQuizVisualMode
                              ? resolveWorld1CanonicalSeatOrderBadgeTextV1(
                                  logicalSeat.id,
                                  canonicalSeatOrderIdsV1,
                                )
                              : null,
                          seatCenter: seatCenter,
                          seatSize: nonOverlappingSeatSize,
                          seatColor: _seatColor(logicalSeat),
                          textColor: _seatTextColor(logicalSeat),
                          defaultBorderColor: _seatBorderColor(logicalSeat),
                          seatIsInteractable:
                              logicalSeat.occupied ||
                              _guidedTargetSeatIdV1 == logicalSeat.id,
                          seatQuizVisualMode: seatQuizVisualMode,
                          handLoopVisualMode: handLoopVisualMode,
                          seatInHand:
                              handLoopActionState?.inHandBySeatId[logicalSeat
                                  .id] ??
                              true,
                          foldedBySeatId:
                              handLoopActionState?.foldedBySeatId[logicalSeat
                                  .id] ??
                              false,
                          handLoopActionRequired: handLoopActionRequiredV1,
                          targetSeatId: targetSeatId,
                          activeSeatGlowId: activeSeatGlowIdV1,
                          actingSeatId: handLoopActionState?.actingSeatId,
                          rotatingHeroSeatId: rotatingHeroSeatIdV1,
                          canRotateSeatDisplay: canRotateSeatDisplayV1,
                          tablePracticeSession: _isTablePracticeSession,
                          compactPortrait: compactPortrait,
                          handLoopOutcomeFocusDeemphasis:
                              handLoopOutcomeFocusDeemphasisV1,
                          selectionActive:
                              _seatVisualSelectionIdV1() == logicalSeat.id,
                        ),
                        onTap: () => _selectSeat(logicalSeat.id),
                      );
                    })(),
                ],
              ),
            );
        final seatQuizInstructionSurfacePolicyV1 =
            seatSceneControllerV1.instruction.contract;
        final seatQuizTableInstructionRectV1 =
            seatSceneControllerV1.instruction.rect;
        return Stack(
          key: const Key('microtask_table_canvas'),
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: Duration(
                  milliseconds: _microAnimationsEnabled ? 130 : 0,
                ),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      SharkyTokensV1.surfaceCard.withOpacity(
                        portraitLayout ? 0.02 : 0.16,
                      ),
                      SharkyTokensV1.surfaceApp.withOpacity(
                        portraitLayout ? 0.18 : 0.56,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: alignmentForPoint(tableCenter),
                      radius: portraitLayout ? 0.9 : 0.72,
                      colors: <Color>[
                        SharkyTokensV1.semanticInfo.withOpacity(
                          portraitLayout ? 0.055 : 0.035,
                        ),
                        SharkyTokensV1.surfaceCard.withOpacity(
                          portraitLayout ? 0.035 : 0.02,
                        ),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.48, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withOpacity(portraitLayout ? 0.05 : 0.02),
                        Colors.transparent,
                        Colors.black.withOpacity(portraitLayout ? 0.08 : 0.03),
                      ],
                      stops: const <double>[0.0, 0.56, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            if (_guidedSeatsActive)
              (compactPortrait
                  ? Positioned(
                      left: math.max(6, stadiumRect.left - 4),
                      right: math.max(
                        6,
                        constraints.maxWidth - stadiumRect.right + 4,
                      ),
                      top: math.max(6, stadiumRect.top - 4),
                      bottom: math.max(
                        6,
                        constraints.maxHeight - stadiumRect.bottom + 4,
                      ),
                      child: IgnorePointer(
                        child: Container(
                          key: const Key('microtask_guided_scope_seats'),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              math.max(12, tableGeom.xRadius * 0.18),
                            ),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          key: const Key('microtask_guided_scope_seats'),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              SharkyTokensV1.radiusMd,
                            ),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                      ),
                    )),
            Center(
              child: SizedBox(
                key: const Key('microtask_table_center_cluster'),
                width: constraints.maxWidth * tableViewportWidthFactor,
                height: constraints.maxHeight * tableViewportHeightFactor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          key: const Key('microtask_table_stadium_shell_v1'),
                          width: tableGeom.clusterWidth,
                          height: tableGeom.clusterHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Transform.translate(
                                offset: const Offset(0, 6),
                                child: DecoratedBox(
                                  decoration: ShapeDecoration(
                                    color: const Color(0x66000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        tableGeom.xRadius,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ...buildWorld1CanonicalHandVisualClusterV1(
                                contract:
                                    tableSceneRuntimeV1.handVisualClusterV1,
                                boardChild: IgnorePointer(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: buildWorld1SurfacedBoardRevealBodyV1(
                                      input: World1SurfacedBoardPotLeafInputV1(
                                        effectiveStreet:
                                            _effectiveBoardStreetForCurrentStepV1(),
                                        boardCardsCount:
                                            visualCards.board.length,
                                        demoHandLoopVisualStep:
                                            _isDemoHandLoopVisualStepV1,
                                        demoHandLoopSession:
                                            _isDemoHandLoopSession,
                                        displayedPotChips:
                                            _campaignActionUiStateForCurrentStep()
                                                ?.pot ??
                                            _engineV2PotChips,
                                        compactPotBadge:
                                            MediaQuery.of(context).size.height <
                                            760,
                                        inlinePotBadge: true,
                                        potPulse: _engineV2PotPulse,
                                      ),
                                      boardCards: visualCards.board,
                                      cardScale: boardCardScale,
                                    ),
                                  ),
                                ),
                                potChild: const SizedBox.shrink(),
                                heroCardsChild: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: tableGeom.clusterWidth,
                          height: tableGeom.clusterHeight,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Color(0xFF25364A),
                                  Color(0xFF08111D),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  tableGeom.xRadius,
                                ),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF5F748E,
                                  ).withOpacity(0.44),
                                  width: tableGeom.rimThickness + 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: tableGeom.clusterWidth,
                          height: tableGeom.clusterHeight,
                          child: Container(
                            margin: EdgeInsets.all(
                              tableGeom.rimThickness + 1.5,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF09111C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  math.max(
                                    8,
                                    tableGeom.xRadius -
                                        (tableGeom.rimThickness + 1.5),
                                  ),
                                ),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFADC6D9,
                                  ).withOpacity(0.34),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: tableGeom.clusterWidth,
                          height: tableGeom.clusterHeight,
                          child: Container(
                            margin: EdgeInsets.all(
                              tableGeom.rimThickness + tableGeom.innerInset + 2,
                            ),
                            decoration: ShapeDecoration(
                              gradient: const RadialGradient(
                                center: Alignment(0, -0.02),
                                radius: 1.1,
                                colors: <Color>[
                                  Color(0xFF2A6D88),
                                  Color(0xFF15384C),
                                  Color(0xFF071520),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  math.max(
                                    8,
                                    tableGeom.xRadius -
                                        (tableGeom.rimThickness +
                                            tableGeom.innerInset +
                                            2),
                                  ),
                                ),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF88BDD2,
                                  ).withOpacity(0.32),
                                  width: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: tableGeom.clusterWidth,
                          height: tableGeom.clusterHeight,
                          child: Container(
                            margin: EdgeInsets.all(
                              tableGeom.rimThickness + tableGeom.innerInset + 6,
                            ),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  math.max(
                                    8,
                                    tableGeom.xRadius -
                                        (tableGeom.rimThickness +
                                            tableGeom.innerInset +
                                            6),
                                  ),
                                ),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFFFFFFF,
                                  ).withOpacity(0.14),
                                  width: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...(() {
              final portraitOverlayBodyV1 = portraitLayout
                  ? IgnorePointer(
                      child: Builder(
                        builder: (context) {
                          final compactOutcome =
                              MediaQuery.of(context).size.height < 900;
                          final portraitOverlayContractV1 =
                              resolveWorld1CanonicalPortraitOverlayContractV1(
                                World1CanonicalPortraitOverlayContractInputV1(
                                  portraitLayout: portraitLayout,
                                  handLoopVisualMode: handLoopVisualMode,
                                  showSeatQuizPrelude: _showSeatQuizPreludeV1,
                                  showIntroSequence: _showIntroSequenceV1,
                                  outcomeSurfaceVisible: _outcomeSurfaceVisible,
                                  showHint: _showHint,
                                  hasFeedback:
                                      _feedback != null &&
                                      _feedback!.trim().isNotEmpty,
                                  showOutcomeHeaderStatus:
                                      _showWorld1OutcomeHeaderStatusV1,
                                  showHintBubble: _showHintBubbleV1,
                                  pulseFailure: _pulseFailure,
                                  feedbackText: _feedback,
                                  hintText: _step.hint,
                                ),
                              );
                          return buildWorld1CanonicalPortraitOverlayBodyV1(
                            contract: portraitOverlayContractV1,
                            maxWidth: math.min(
                              overlayLaneRect.width,
                              constraints.maxWidth - 20,
                            ),
                            outcomeStatusChild: _buildCompactOutcomeStatusBoxV1(
                              compactTeachingPayloadV1:
                                  compactTeachingPayloadV1,
                              compactOutcome: compactOutcome,
                              ultraCompactOutcome:
                                  MediaQuery.of(context).size.height < 500,
                              centered: true,
                              dense: false,
                            ),
                          );
                        },
                      ),
                    )
                  : null;
              final seatQuizInstructionSurfaceV1 =
                  seatQuizTableInstructionRectV1 != null &&
                      seatQuizInstructionSurfacePolicyV1.isVisible
                  ? _buildSeatQuizInstructionSurfaceV1(
                      rect: seatQuizTableInstructionRectV1,
                      policy: seatQuizInstructionSurfacePolicyV1,
                      compactPortrait: compactPortrait,
                      trackIntroOverlayActiveV1: trackIntroOverlayActiveV1,
                    )
                  : null;
              final feltCaptionBodyV1 =
                  feltCaptionContractV1.showsPositionedCaption
                  ? IgnorePointer(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: buildWorld1CanonicalFeltCaptionBodyV1(
                          feltCaptionContractV1,
                        ),
                      ),
                    )
                  : null;
              return buildWorld1CanonicalTableSceneCompositorV1(
                input: World1CanonicalTableSceneCompositorInputV1(
                  showBoardGlow:
                      showCampaignHandVisuals && visualCards.board.isNotEmpty,
                  boardRect: tableSceneRuntimeV1.boardRect,
                  showPotGlow:
                      handLoopVisualMode && handLoopActionState != null,
                  potRect: tableSceneRuntimeV1.potRect,
                  showActingSeatGlow:
                      handLoopActionRequiredV1 &&
                      handLoopActingSeatCenterV1 != null,
                  actingSeatCenter: handLoopActingSeatCenterV1,
                  seatVisualRadius: seatVisualRadius,
                  compactPhone: compactPhone,
                  handVisualCluster: tableSceneRuntimeV1.handVisualClusterV1,
                  potChild: KeyedSubtree(
                    key: const Key('microtask_pot_center_v1'),
                    child: buildWorld1SurfacedPotBadgeBodyV1(
                      input: World1SurfacedBoardPotLeafInputV1(
                        effectiveStreet:
                            _effectiveBoardStreetForCurrentStepV1(),
                        boardCardsCount: 0,
                        demoHandLoopVisualStep: _isDemoHandLoopVisualStepV1,
                        demoHandLoopSession: _isDemoHandLoopSession,
                        displayedPotChips:
                            _campaignActionUiStateForCurrentStep()?.pot ??
                            _engineV2PotChips,
                        compactPotBadge:
                            MediaQuery.of(context).size.height < 760,
                        inlinePotBadge: true,
                        potPulse: _engineV2PotPulse,
                      ),
                    ),
                  ),
                  heroCardsChild: KeyedSubtree(
                    key: const Key('microtask_engine_hero_hole_cards'),
                    child: buildWorld1CanonicalHeroCardsBodyV1(
                      cardsRow: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          PlayingCardWidget(
                            card: visualCards.hero[0],
                            scale: heroCardScale,
                          ),
                          PlayingCardWidget(
                            card: visualCards.hero[1],
                            scale: heroCardScale,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actionTokenContract:
                      tableSceneRuntimeV1.actionTokenContractV1,
                  seatQuizCueBodies: buildWorld1SurfacedSeatQuizCueBodiesV1(
                    input: World1SurfacedSeatQuizCueInputV1(
                      seatQuizVisualMode:
                          seatQuizVisualMode && !handLoopVisualMode,
                      dealerCueCenter: dealerCueCenter,
                      sbCueCenter: sbCueCenter,
                      bbCueCenter: bbCueCenter,
                      targetSeatId: targetSeatId,
                      targetSeatCenter: targetSeatCenter,
                      cueRadius: cueRadius,
                      nonOverlappingSeatSize: nonOverlappingSeatSize,
                    ),
                  ),
                  handLoopChipCueBodies:
                      buildWorld1SurfacedHandLoopChipCueBodiesV1(
                        input: World1SurfacedHandLoopChipCueInputV1(
                          handLoopVisualMode: handLoopVisualMode,
                          demoActionDecisionStateV1:
                              _isDemoHandLoopVisualStepV1 &&
                              handLoopActionRequiredV1,
                          sbCueCenter: sbCueCenter,
                          bbCueCenter: bbCueCenter,
                          cueRadius: cueRadius,
                          sbDisplaySeatId: displaySeatIdForLogicalV1('sb'),
                          bbDisplaySeatId: displaySeatIdForLogicalV1('bb'),
                        ),
                      ),
                  instructionSurface: seatQuizInstructionSurfaceV1,
                  feltCaption: feltCaptionBodyV1,
                  feltCaptionLeft:
                      handLoopPromptTopBandCoexistenceV1?.captionLeft ??
                      stadiumRect.left + 10,
                  feltCaptionRight: handLoopPromptTopBandCoexistenceV1 != null
                      ? math.max(
                          10,
                          constraints.maxWidth -
                              handLoopPromptTopBandCoexistenceV1.captionRight,
                        )
                      : (stadiumRect.right + 10 > constraints.maxWidth
                            ? 10
                            : (constraints.maxWidth - stadiumRect.right) + 10),
                  feltCaptionTop: feltCaptionTopV1,
                  portraitOverlay: portraitOverlayBodyV1,
                  portraitOverlayLeft: overlayLaneRect.left,
                  portraitOverlayRight: math.max(
                    8,
                    constraints.maxWidth - overlayLaneRect.right,
                  ),
                  portraitOverlayTop: math.max(
                    overlayLaneRect.top + feltCaptionTopInsetV1 + 30,
                    stadiumRect.top +
                        (stadiumRect.height * captionLaneY) +
                        (compactPortrait ? 30 : 24),
                  ),
                ),
              );
            })(),
            for (final seatEntryV1 in seatSceneControllerV1.seatEntries)
              buildWorld1CanonicalTableSeatSceneBodyV1(
                contract: seatEntryV1.contract,
                onTap: seatEntryV1.onTap,
              ),
          ],
        );
      },
    );
  }

  Widget _buildWorld1CanonicalEmbeddedTableV1({
    required World1CanonicalTableRenderBranchStateV1 tableRenderBranchV1,
    required World1SurfacedHandLoopPromptSurfaceV1 handLoopPromptSurfaceV1,
    required bool canonicalHeaderOwnsHandLoopPromptV1,
    required bool portraitLayout,
  }) {
    final seatsV1 =
        _World1FoundationsMicroTaskRunnerScreenState._seatsForMaxPlayersV1(
          _effectiveSeatLayoutMaxPlayersV1,
        );
    final seatIdsV1 = seatsV1.map((seat) => seat.id).toList(growable: false);
    final actionStateV1 = tableRenderBranchV1.handLoopVisualMode
        ? _campaignActionUiStateForCurrentStep()
        : null;
    final effectiveStreetV1 = _effectiveBoardStreetForCurrentStepV1();
    final visualCardsV1 = _engineVisualCardsForCurrentBeat();
    final adapterV1 = resolveWorld1ModernTableAdapterV1(
      World1ModernTableAdapterInputV1(
        seatIds: seatIdsV1,
        heroSeatId: _normalizedScenarioSeatIdV1(_step.heroSeatId),
        actingSeatId: actionStateV1?.actingSeatId,
        selectedSeatId: tableRenderBranchV1.seatQuizVisualMode
            ? _seatVisualSelectionIdV1()
            : null,
        foldedBySeatId: actionStateV1?.foldedBySeatId ?? const <String, bool>{},
        committedBySeatId:
            actionStateV1?.committedBySeatId ?? const <String, int>{},
        pot: actionStateV1?.pot ?? (_step.pot ?? 0),
        currentBet: actionStateV1?.currentBet ?? 0,
        actingSeatToCall: actionStateV1?.actingSeatToCall ?? 0,
        lastAggressorSeatId: actionStateV1?.lastAggressorSeatId,
        priceSettingActionKindV1: actionStateV1?.priceSettingActionKindV1,
        betOwnerSeatId: actionStateV1?.betOwnerSeatId,
        currentStreet: _world1ModernTableStreetV1(effectiveStreetV1),
        visibleBoardCount: _visibleBoardCardsForStreet(effectiveStreetV1),
        heroCards: visualCardsV1.hero,
        boardCards: visualCardsV1.board,
        promptLabel: _world1ModernTablePromptLabelV1(
          tableRenderBranchV1: tableRenderBranchV1,
          handLoopPromptSurfaceV1: handLoopPromptSurfaceV1,
          actionStateV1: actionStateV1,
        ),
        showsActingSeat: tableRenderBranchV1.handLoopVisualMode,
      ),
    );
    final tableResetKeyV1 = ValueKey<String>(
      'world1_modern_table_${widget.moduleId}_${_stepIndex}_${tableRenderBranchV1.branch.name}_${adapterV1.scenarioSpec.heroSeat}_${adapterV1.scenarioSpec.actingSeatStart}_${adapterV1.scenarioSpec.decisionNodeV1.street.name}_${adapterV1.scenarioSpec.resolvedNodes.first.pot}',
    );
    final usesSceneOwnedLiveProfileV1 =
        portraitLayout &&
        _isCampaignSpineSession &&
        tableRenderBranchV1.handLoopVisualMode;
    final visualFamilyV1 = resolveSharedEmbeddedTableVisualFamilyV1(
      preset: usesSceneOwnedLiveProfileV1
          ? SharedEmbeddedTableVisualFamilyPresetV1.world1LiveSceneOwned
          : (_useActionLiteracyCalmSceneLaneV1
                ? SharedEmbeddedTableVisualFamilyPresetV1
                      .world1LearnerEmbeddedGuidedTeaching
                : (tableRenderBranchV1.handLoopVisualMode &&
                          canonicalHeaderOwnsHandLoopPromptV1
                      ? SharedEmbeddedTableVisualFamilyPresetV1
                            .world1LearnerEmbeddedStandard
                      : SharedEmbeddedTableVisualFamilyPresetV1
                            .world1LearnerEmbeddedCompactState)),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        usesSceneOwnedLiveProfileV1 ? 0 : 8,
        0,
        usesSceneOwnedLiveProfileV1 ? 0 : 8,
        0,
      ),
      child: KeyedSubtree(
        key: tableResetKeyV1,
        child: ModernTableScreenV1(
          key: tableResetKeyV1,
          embeddedV1: true,
          embeddedSceneGeometryProfileV1:
              visualFamilyV1.embeddedSceneGeometryProfileV1,
          seatStateVisualProfileV1: visualFamilyV1.seatStateVisualProfileV1,
          sceneLanePromptProfileV1: visualFamilyV1.sceneLanePromptProfileV1,
          useReferenceParityLiveProfileV1:
              visualFamilyV1.useReferenceParityLiveProfileV1,
          selectedSeatV1: adapterV1.selectedSeatIndex,
          showsActingSeatV1: adapterV1.showsActingSeat,
          scenarioSpec: adapterV1.scenarioSpec,
          debugScenePromptLabel: adapterV1.debugScenePromptLabel,
          debugEmbeddedInstructionLabelV1:
              visualFamilyV1.useSceneOwnedInstructionV1
              ? handLoopPromptSurfaceV1.promptText.trim().isNotEmpty
                    ? handLoopPromptSurfaceV1.promptText.trim()
                    : _displayedStepPromptV1.trim()
              : null,
          debugBoardCardLabels: adapterV1.debugBoardCardLabels,
          debugHeroCardLabels: adapterV1.debugHeroCardLabels,
          debugSeatRoleLabels: adapterV1.seatRoleLabels,
          debugSeatMarkerLabels: adapterV1.seatMarkerLabels,
          debugSeatContributionAmountsV1: adapterV1.seatContributionAmountsV1,
          debugPotDisplayLabelV1: adapterV1.debugPotDisplayLabelV1,
          debugScenePriceLabelV1: adapterV1.debugScenePriceLabelV1,
          debugPriceSetterSeatIndexV1: adapterV1.debugPriceSetterSeatIndexV1,
          debugPriceSetterCueLabelV1: adapterV1.debugPriceSetterCueLabelV1,
          onSeatTapV1: tableRenderBranchV1.seatQuizVisualMode
              ? (seatIndex) {
                  _selectSeat(adapterV1.seatIdForIndex(seatIndex));
                }
              : null,
        ),
      ),
    );
  }

  scenario_fsm.Street _world1ModernTableStreetV1(StreetV1 street) {
    switch (street) {
      case StreetV1.flop:
        return scenario_fsm.Street.flop;
      case StreetV1.turn:
        return scenario_fsm.Street.turn;
      case StreetV1.river:
        return scenario_fsm.Street.river;
      case StreetV1.preflop:
        return scenario_fsm.Street.preflop;
    }
  }

  String _world1ModernTablePromptLabelV1({
    required World1CanonicalTableRenderBranchStateV1 tableRenderBranchV1,
    required World1SurfacedHandLoopPromptSurfaceV1 handLoopPromptSurfaceV1,
    required World1SurfacedActionStateV1? actionStateV1,
  }) {
    if (tableRenderBranchV1.handLoopVisualMode) {
      final canonicalHeaderOwnsPromptV1 =
          _isCampaignSpineSession &&
          !handLoopPromptSurfaceV1.usesFeltCaptionHost;
      if (canonicalHeaderOwnsPromptV1) {
        return '';
      }
      if (_useActionLiteracyCalmSceneLaneV1) {
        return _actionLiteracySceneLanePromptLineV1();
      }
      final handLoopPromptV1 = handLoopPromptSurfaceV1.promptText.trim();
      if (handLoopPromptV1.isNotEmpty) {
        return handLoopPromptV1;
      }
      final displayedPromptV1 = _displayedStepPromptV1.trim();
      if (displayedPromptV1.isNotEmpty) {
        return displayedPromptV1;
      }
      return _handLoopPromptV1(actionStateV1);
    }
    return (_seatQuizInstructionForTargetV1() ?? _displayedStepPromptV1).trim();
  }

  String _unitsToBbDisplayV1(int units) {
    final negative = units < 0;
    final absUnits = units.abs();
    final whole = absUnits ~/ 2;
    final hasHalf = absUnits.isOdd;
    final bb = hasHalf ? '$whole.5' : '$whole';
    return negative ? '-$bb' : bb;
  }

  Widget _buildStreetTimeline() {
    final current = _engineV2CurrentStreet;
    if (current == null) {
      return const SizedBox.shrink();
    }
    final compact = MediaQuery.of(context).size.height < 760;
    final currentIndex = _streetTimelineOrder.indexOf(current);
    return Container(
      key: const Key('microtask_street_timeline'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(compact ? 0.16 : 0.2),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _streetTimelineLabels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? SharkyTokensV1.brandPrimary.withOpacity(0.75)
                        : SharkyTokensV1.slate600.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 5 : 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: i == currentIndex
                    ? SharkyTokensV1.brandPrimary.withOpacity(0.2)
                    : (i < currentIndex
                          ? SharkyTokensV1.semanticWin.withOpacity(0.14)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: i == currentIndex
                      ? SharkyTokensV1.brandGlow.withOpacity(0.85)
                      : SharkyTokensV1.slate600.withOpacity(0.45),
                ),
              ),
              child: Text(
                _streetTimelineLabels[i],
                style: AppTypography.caption.copyWith(
                  color: i == currentIndex
                      ? SharkyTokensV1.brandGlow
                      : (i < currentIndex
                            ? SharkyTokensV1.textSecondary
                            : SharkyTokensV1.textMuted),
                  fontWeight: i == currentIndex
                      ? FontWeight.w800
                      : FontWeight.w700,
                  fontSize: compact ? 9.0 : 9.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEngineV2TurnFeed() {
    if (!_showEngineV2StreetUi || _engineV2TurnFeedLines.isEmpty) {
      return const SizedBox.shrink();
    }
    final compactHeight = MediaQuery.of(context).size.height < 760;
    final visibleLines = _engineV2TurnFeedLines
        .take(compactHeight ? 1 : 2)
        .toList(growable: false);
    return Container(
      key: const Key('microtask_engine_turn_feed'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.04),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < visibleLines.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == visibleLines.length - 1 ? 0 : 2,
              ),
              child: Text(
                visibleLines[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textMuted.withOpacity(0.88),
                  fontWeight: FontWeight.w500,
                  fontSize: 9.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampaignActionChips(
    World1SurfacedActionStateV1 contextState, {
    _World1StableLayoutV1? stableLayoutV1,
  }) {
    final media = MediaQuery.of(context);
    final resolvedLayoutV1 =
        stableLayoutV1 ??
        _resolveStableLayoutV1(context: context, media: media);
    final portrait = resolvedLayoutV1.portraitLayout;
    final compact =
        media.size.width < 980 ||
        media.size.height < 760 ||
        MediaQuery.textScalerOf(context).scale(1.0) > 1.1;
    final compactPortraitPinnedVariant = portrait && compact;
    final allOptions = contextState.decisionModel.options;
    final useSpineAllowedActionSet =
        _isCampaignSpineSession &&
        _isWorld1SpineParityPackV1 &&
        !_isDemoHandLoopVisualStepV1;
    final rawSpineAllowedActionSet = useSpineAllowedActionSet
        ? (_step.allowedActions ?? const <String>[])
              .map((value) => value.trim().toLowerCase().replaceAll('-', '_'))
              .where((value) => value.isNotEmpty)
              .toSet()
        : const <String>{};
    final actingSeatToCallAmount = math.max(0, contextState.actingSeatToCall);
    final isPreflopLikeStep = _step.street == null;
    final spineAllowedActionSet = rawSpineAllowedActionSet
        .map(
          (value) => canonicalizeLearnerActionTokenV1(
            token: value,
            isPreflop: isPreflopLikeStep,
            toCall: actingSeatToCallAmount,
          ),
        )
        .where((value) => value.isNotEmpty)
        .toSet();
    final facingBetByActionStateV1 =
        contextState.currentBet > 0 && actingSeatToCallAmount > 0;
    final spineLabelOverrides = <DecisionActionOptionV1, String>{};

    DecisionActionOptionV1? pickSpineOption(
      bool Function(DecisionActionOptionV1 option) matcher, {
      Set<DecisionActionOptionV1>? used,
      bool enabledOnly = false,
    }) {
      for (final option in allOptions) {
        if (used != null && used.contains(option)) continue;
        if (enabledOnly && !option.enabled) continue;
        if (matcher(option)) return option;
      }
      return null;
    }

    List<DecisionActionOptionV1> buildSpineAllowedOptions() {
      final selected = <DecisionActionOptionV1>[];
      final used = <DecisionActionOptionV1>{};
      const maxSpineOptions = 6;

      void addOption(DecisionActionOptionV1? option, {String? overrideLabel}) {
        if (option == null || used.contains(option)) return;
        selected.add(option);
        used.add(option);
        if (overrideLabel != null) {
          spineLabelOverrides[option] = overrideLabel;
        }
      }

      final explicitlyForbidsFoldV1 =
          spineAllowedActionSet.contains('no_fold') ||
          spineAllowedActionSet.contains('forbid_fold') ||
          spineAllowedActionSet.contains('fold_forbidden');
      final explicitlyForbidsCheckV1 =
          spineAllowedActionSet.contains('no_check') ||
          spineAllowedActionSet.contains('forbid_check') ||
          spineAllowedActionSet.contains('check_forbidden');
      final explicitlyForbidsCallV1 =
          spineAllowedActionSet.contains('no_call') ||
          spineAllowedActionSet.contains('forbid_call') ||
          spineAllowedActionSet.contains('call_forbidden');
      final allowsFold = actingSeatToCallAmount > 0
          ? !explicitlyForbidsFoldV1
          : spineAllowedActionSet.contains('fold');
      final allowsCheck = actingSeatToCallAmount > 0
          ? false
          : (spineAllowedActionSet.contains('check') &&
                !explicitlyForbidsCheckV1);
      final allowsCall = actingSeatToCallAmount > 0
          ? !explicitlyForbidsCallV1
          : (spineAllowedActionSet.contains('call') &&
                !explicitlyForbidsCallV1);
      final hasRaiseFamilyAffordance =
          spineAllowedActionSet.contains('raise') ||
          spineAllowedActionSet.contains('raise_to') ||
          spineAllowedActionSet.contains('raise_min');
      final allowsCanonicalRaiseFromBet =
          isPreflopLikeStep && rawSpineAllowedActionSet.contains('bet');
      final allowsBet =
          spineAllowedActionSet.contains('bet') &&
          !(facingBetByActionStateV1 && hasRaiseFamilyAffordance);
      final allowsRaiseMin = spineAllowedActionSet.contains('raise_min');
      final allowsRaiseTo =
          spineAllowedActionSet.contains('raise_to') ||
          (spineAllowedActionSet.contains('raise') && !allowsRaiseMin);

      if (allowsFold) {
        addOption(
          pickSpineOption(
            (option) => option.kind == DecisionActionKindV1.fold,
            enabledOnly: true,
          ),
          overrideLabel: 'FOLD',
        );
      }
      if (allowsCheck) {
        addOption(
          pickSpineOption(
                (option) => option.kind == DecisionActionKindV1.check,
                enabledOnly: true,
              ) ??
              pickSpineOption(
                (option) => option.kind == DecisionActionKindV1.call,
                enabledOnly: true,
              ),
          overrideLabel: 'CHECK',
        );
      }
      if (allowsCall) {
        addOption(
          pickSpineOption(
            (option) => option.kind == DecisionActionKindV1.call,
            enabledOnly: true,
          ),
          overrideLabel: 'CALL',
        );
      }
      if (allowsBet) {
        addOption(
          pickSpineOption(
            (option) => option.kind == DecisionActionKindV1.bet,
            used: used,
            enabledOnly: true,
          ),
          overrideLabel: facingBetByActionStateV1 ? 'RAISE TO' : 'BET',
        );
      }
      if (allowsRaiseTo) {
        addOption(
          pickSpineOption(
                (option) => option.kind == DecisionActionKindV1.raiseTo,
                used: used,
                enabledOnly: true,
              ) ??
              (allowsCanonicalRaiseFromBet
                  ? pickSpineOption(
                      (option) => option.kind == DecisionActionKindV1.bet,
                      used: used,
                      enabledOnly: true,
                    )
                  : null),
          overrideLabel: allowsCanonicalRaiseFromBet
              ? 'RAISE'
              : world1SpinePreferredRaiseLabelV1(_step.allowedActions),
        );
      }
      if (allowsRaiseMin) {
        final raiseMinOption =
            pickSpineOption(
              (option) =>
                  option.kind == DecisionActionKindV1.raiseTo &&
                  option.label == 'RAISE MIN',
              used: used,
              enabledOnly: true,
            ) ??
            pickSpineOption(
              (option) => option.kind == DecisionActionKindV1.raiseTo,
              used: used,
              enabledOnly: true,
            );
        addOption(raiseMinOption, overrideLabel: 'RAISE MIN');
      }

      if (selected.length > maxSpineOptions) {
        return selected.take(maxSpineOptions).toList(growable: false);
      }
      return selected;
    }

    final leftOptions = allOptions
        .where((option) => option.group == DecisionActionGroupV1.left)
        .toList(growable: false);
    final middleOptions = allOptions
        .where((option) => option.group == DecisionActionGroupV1.middle)
        .toList(growable: false);
    final rightOptions = allOptions
        .where((option) => option.group == DecisionActionGroupV1.right)
        .toList(growable: false);
    final demoCompactSizingExpansion =
        _isDemoHandLoopVisualStepV1 || _isDemoHandLoopSession;
    final preferredCompactRightLabels = demoCompactSizingExpansion
        ? const <String>[
            'BET 1/3',
            'BET 1/2',
            'BET POT',
            'RAISE MIN',
            'RAISE 2X',
            'RAISE POT',
          ]
        : const <String>['BET 1/3', 'RAISE MIN'];
    final compactRight = <DecisionActionOptionV1>[
      for (final label in preferredCompactRightLabels)
        for (final option in rightOptions)
          if (option.label == label && option.enabled) option,
      if (rightOptions.isNotEmpty &&
          !rightOptions.any((option) => option.enabled))
        rightOptions.first,
    ].toList(growable: false);
    final preferredMiddleOption = middleOptions.isEmpty
        ? null
        : middleOptions.firstWhere(
            (option) => option.enabled,
            orElse: () => middleOptions.first,
          );
    final compactOptions = <DecisionActionOptionV1>[
      if (leftOptions.isNotEmpty) leftOptions.first,
      if (preferredMiddleOption != null) preferredMiddleOption,
      ...compactRight,
    ];
    final spineAllowedOptions = useSpineAllowedActionSet
        ? buildSpineAllowedOptions()
        : const <DecisionActionOptionV1>[];
    List<DecisionActionOptionV1> enforcePassiveActionInvariant(
      List<DecisionActionOptionV1> options,
    ) {
      if (!facingBetByActionStateV1) {
        return options;
      }
      final normalized = options
          .where((option) => option.kind != DecisionActionKindV1.check)
          .toList(growable: true);
      final hasCall = normalized.any(
        (option) => option.kind == DecisionActionKindV1.call,
      );
      if (!hasCall && allOptions.isNotEmpty) {
        final callOption = allOptions.firstWhere(
          (option) => option.kind == DecisionActionKindV1.call,
          orElse: () => allOptions.first,
        );
        if (callOption.kind == DecisionActionKindV1.call) {
          normalized.insert(0, callOption);
        }
      }
      return normalized;
    }

    final optionsToRender = enforcePassiveActionInvariant(
      canonicalLearnerPrimaryActionOrderV1(
        spineAllowedOptions.isNotEmpty
            ? spineAllowedOptions
            : (compact ? compactOptions : allOptions),
        (option) {
          switch (option.kind) {
            case DecisionActionKindV1.fold:
              return 'fold';
            case DecisionActionKindV1.check:
              return 'check';
            case DecisionActionKindV1.call:
              return 'call';
            case DecisionActionKindV1.bet:
              return facingBetByActionStateV1 ? 'raise' : 'bet';
            case DecisionActionKindV1.raiseTo:
              return 'raise';
          }
        },
      ),
    );
    Widget buildChipForOption(DecisionActionOptionV1 option) {
      final isSecondary = option.group == DecisionActionGroupV1.left;
      final isPrimary = option.group == DecisionActionGroupV1.middle;
      final isRaiseGroup = option.group == DecisionActionGroupV1.right;
      var buttonLabel = spineLabelOverrides[option] ?? option.label;
      String? buttonSuffix;
      if (option.kind == DecisionActionKindV1.call &&
          actingSeatToCallAmount > 0) {
        buttonLabel = 'CALL';
        buttonSuffix = '${_unitsToBbDisplayV1(actingSeatToCallAmount)} BB';
      } else if (option.kind == DecisionActionKindV1.raiseTo &&
          option.action.amount != null &&
          option.action.amount! > 0) {
        buttonSuffix = '${_unitsToBbDisplayV1(option.action.amount!)} BB';
      }
      var effectiveEnabled = option.enabled && !_isLockInBlocked;
      if (facingBetByActionStateV1 &&
          option.kind == DecisionActionKindV1.call) {
        effectiveEnabled = !_isLockInBlocked;
      } else if (facingBetByActionStateV1 &&
          option.kind == DecisionActionKindV1.check) {
        effectiveEnabled = false;
      }
      return _buildActionChipButton(
        label: buttonLabel,
        suffixLabel: buttonSuffix,
        enabled: effectiveEnabled,
        onTap: () => _onCampaignActionTap(option.action),
        emphasis: isPrimary
            ? _ActionChipEmphasisV1.primary
            : (isSecondary
                  ? _ActionChipEmphasisV1.secondary
                  : _ActionChipEmphasisV1.raised),
        inRaiseGroupChrome: isRaiseGroup,
      );
    }

    Widget buildRaiseGroupChrome(List<DecisionActionOptionV1> options) {
      if (options.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: SharkyTokensV1.brandPrimary.withOpacity(0.035),
          borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
          border: Border.all(
            color: SharkyTokensV1.brandPrimary.withOpacity(0.16),
            width: 0.8,
          ),
        ),
        child: compactPortraitPinnedVariant
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    buildChipForOption(options[i]),
                  ],
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in options) buildChipForOption(option),
                ],
              ),
      );
    }

    final barContent = compactPortraitPinnedVariant
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in optionsToRender.where(
                  (option) => option.group != DecisionActionGroupV1.right,
                )) ...[buildChipForOption(option), const SizedBox(width: 8)],
                if (optionsToRender.any(
                  (option) => option.group == DecisionActionGroupV1.right,
                ))
                  buildRaiseGroupChrome(
                    optionsToRender
                        .where(
                          (option) =>
                              option.group == DecisionActionGroupV1.right,
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action context',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textMuted.withOpacity(0.78),
                  fontWeight: FontWeight.w600,
                  fontSize: 9.0,
                ),
              ),
              const SizedBox(height: 3),
              const SizedBox(height: 1),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in optionsToRender.where(
                    (option) => option.group != DecisionActionGroupV1.right,
                  ))
                    buildChipForOption(option),
                  if (optionsToRender.any(
                    (option) => option.group == DecisionActionGroupV1.right,
                  ))
                    buildRaiseGroupChrome(
                      optionsToRender
                          .where(
                            (option) =>
                                option.group == DecisionActionGroupV1.right,
                          )
                          .toList(growable: false),
                    ),
                ],
              ),
            ],
          );

    final useLiveReferenceParityFooterV1 =
        _isCampaignSpineSession &&
        _currentCampaignRunnerMode == _CampaignRunnerMode.handLoop &&
        compactPortraitPinnedVariant &&
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SafeArea(
      top: false,
      minimum: kCanonicalLearnerActionSafeAreaMinimumV1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: useLiveReferenceParityFooterV1 ? 0 : 6,
        ),
        child: Container(
          key: const Key('microtask_campaign_action_bar'),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: useLiveReferenceParityFooterV1 ? 0 : 8,
            vertical: useLiveReferenceParityFooterV1
                ? 0
                : (compactPortraitPinnedVariant ? 4 : 6),
          ),
          decoration: BoxDecoration(
            color: useLiveReferenceParityFooterV1
                ? Colors.transparent
                : SharkyTokensV1.surfaceCard.withOpacity(
                    compact ? 0.04 : 0.055,
                  ),
            borderRadius: BorderRadius.circular(
              useLiveReferenceParityFooterV1 ? 0 : 16,
            ),
            border: useLiveReferenceParityFooterV1
                ? null
                : Border.all(color: SharkyTokensV1.slate600.withOpacity(0.035)),
          ),
          child: Stack(
            children: <Widget>[
              if (useLiveReferenceParityFooterV1)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            SharkyTokensV1.surfaceApp.withOpacity(0.0),
                            SharkyTokensV1.surfaceApp.withOpacity(0.14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              barContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChipButton({
    required String label,
    String? suffixLabel,
    required bool enabled,
    required VoidCallback onTap,
    _ActionChipEmphasisV1 emphasis = _ActionChipEmphasisV1.neutral,
    bool inRaiseGroupChrome = false,
  }) {
    final Color bgColor;
    final Color borderColor;
    final Color fgColor;
    final List<BoxShadow> shadows;
    double minWidth = 72;
    switch (emphasis) {
      case _ActionChipEmphasisV1.secondary:
        bgColor = SharkyTokensV1.surfaceCard.withOpacity(enabled ? 0.38 : 0.2);
        borderColor = SharkyTokensV1.slate500.withOpacity(
          enabled ? 0.26 : 0.16,
        );
        fgColor = enabled
            ? SharkyTokensV1.textPrimary.withOpacity(0.9)
            : SharkyTokensV1.textMuted.withOpacity(0.7);
        shadows = const <BoxShadow>[];
        minWidth = 68;
        break;
      case _ActionChipEmphasisV1.primary:
        bgColor = SharkyTokensV1.brandPrimary.withOpacity(enabled ? 0.24 : 0.1);
        borderColor = SharkyTokensV1.brandPrimary.withOpacity(
          enabled ? 0.66 : 0.24,
        );
        fgColor = enabled
            ? SharkyTokensV1.textPrimary
            : SharkyTokensV1.textMuted.withOpacity(0.78);
        shadows = enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: SharkyTokensV1.brandGlow.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0.6,
                  offset: const Offset(0, 2),
                ),
              ]
            : const <BoxShadow>[];
        minWidth = 84;
        break;
      case _ActionChipEmphasisV1.raised:
        bgColor = SharkyTokensV1.surfaceCard.withOpacity(enabled ? 0.62 : 0.24);
        borderColor = SharkyTokensV1.brandPrimary.withOpacity(
          enabled ? 0.34 : 0.18,
        );
        fgColor = enabled
            ? SharkyTokensV1.textPrimary
            : SharkyTokensV1.textMuted.withOpacity(0.76);
        shadows = enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: SharkyTokensV1.brandPrimary.withOpacity(0.12),
                  blurRadius: 8,
                  spreadRadius: 0.2,
                  offset: const Offset(0, 2),
                ),
              ]
            : const <BoxShadow>[];
        minWidth = 82;
        break;
      case _ActionChipEmphasisV1.neutral:
        bgColor = SharkyTokensV1.surfaceCard.withOpacity(enabled ? 0.52 : 0.2);
        borderColor = SharkyTokensV1.slate500.withOpacity(
          enabled ? 0.22 : 0.14,
        );
        fgColor = enabled
            ? SharkyTokensV1.textPrimary
            : SharkyTokensV1.textMuted.withOpacity(0.72);
        shadows = const <BoxShadow>[];
        break;
    }
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: shadows,
        ),
        child: OutlinedButton(
          onPressed: enabled ? onTap : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: inRaiseGroupChrome ? 10 : 12,
            ),
            minimumSize: Size(minWidth, 44),
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            side: BorderSide(
              color: borderColor,
              width: emphasis == _ActionChipEmphasisV1.primary ? 1.2 : 0.9,
            ),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ).copyWith(elevation: const WidgetStatePropertyAll<double>(0)),
          child: suffixLabel == null
              ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 4),
                    Text(
                      suffixLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPortraitCoachStripV1({
    required _CoachModeV1 mode,
    required String title,
    String subtitle = '',
    String? handLoopBody,
    bool ignorePointer = true,
    bool showRail = false,
    int railTotal = 0,
    int railActiveIndex = 0,
    required bool outcomeVisible,
    required bool outcomeCorrect,
    required bool pulseFailure,
  }) {
    final learningOutcomePanel = outcomeVisible && handLoopBody != null;
    final borderColor = outcomeVisible
        ? (learningOutcomePanel
              ? SharkyTokensV1.slate600.withOpacity(0.62)
              : (outcomeCorrect
                        ? SharkyTokensV1.semanticWin
                        : SharkyTokensV1.semanticLoss)
                    .withOpacity(0.28))
        : SharkyTokensV1.slate500.withOpacity(0.30);
    final accentColor = outcomeCorrect
        ? SharkyTokensV1.semanticWin.withOpacity(0.78)
        : SharkyTokensV1.semanticLoss.withOpacity(0.78);
    final container = Container(
      key: const Key('microtask_coach_strip_v1'),
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: outcomeVisible ? 0 : (mode == _CoachModeV1.intro ? 0 : 2),
        left: 2,
        right: 2,
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        outcomeVisible ? 3 : (mode == _CoachModeV1.intro ? 3 : 5),
        8,
        outcomeVisible ? 3 : (mode == _CoachModeV1.intro ? 3 : 5),
      ),
      decoration: BoxDecoration(
        color: outcomeVisible
            ? SharkyTokensV1.surfaceElevated.withOpacity(0.86)
            : SharkyTokensV1.surfaceApp.withOpacity(
                mode == _CoachModeV1.intro ? 0.62 : 0.68,
              ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: outcomeVisible || mode == _CoachModeV1.intro
            ? const <BoxShadow>[]
            : null,
      ),
      child: learningOutcomePanel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1, right: 8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.8,
                          height: 1.06,
                        ),
                      ),
                      if (handLoopBody.trim().isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          handLoopBody,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.0,
                            height: 1.06,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : mode == _CoachModeV1.demo || handLoopBody != null
          ? Text(
              handLoopBody ?? title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: outcomeVisible && !outcomeCorrect
                    ? SharkyTokensV1.semanticLoss
                    : SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: outcomeVisible && !outcomeCorrect
                        ? SharkyTokensV1.semanticLoss
                        : SharkyTokensV1.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: pulseFailure
                          ? SharkyTokensV1.semanticLoss
                          : SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.4,
                      height: 1.05,
                    ),
                  ),
                ],
                if (showRail && railTotal > 0) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: List<Widget>.generate(railTotal, (index) {
                      final active = index == railActiveIndex;
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(
                            right: index == railTotal - 1 ? 0 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? SharkyTokensV1.brandPrimary
                                : SharkyTokensV1.slate500.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
    );
    return IgnorePointer(
      ignoring: ignorePointer,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: 1,
        child: container,
      ),
    );
  }

  StreetV1 _effectiveBoardStreetForCurrentStepV1() {
    final streetOverride = _scenarioStreetOverrideForStepV1();
    if (_isDemoHandLoopVisualStepV1 || _isDemoHandLoopSession) {
      return streetOverride ?? (_engineV2CurrentStreet ?? StreetV1.preflop);
    }
    return streetOverride ??
        (_engineV2StepStreet ?? _engineV2CurrentStreet ?? StreetV1.preflop);
  }

  _EngineVisualCards _engineVisualCardsForCurrentBeat() {
    final overrideHero = _parseScenarioCardsOverrideV1(_step.heroCards);
    final overrideBoard = _parseScenarioCardsOverrideV1(_step.boardCards);
    final pointer = _buildCurrentCampaignPointerForDebug();
    if (pointer == null) {
      final deal = DeterministicDealV1.dealForPointer(
        packId: widget.moduleId,
        pointerKey: 'fallback',
        handIndex: _stepIndex,
      );
      return _EngineVisualCards(
        hero: overrideHero ?? deal.heroHole2,
        board: overrideBoard ?? deal.board5,
      );
    }
    final deal = DeterministicDealV1.dealForPointer(
      packId: pointer.packId,
      pointerKey: '${pointer.worldId}:${pointer.beatIndex}',
      handIndex: pointer.beatIndex,
    );
    return _EngineVisualCards(
      hero: overrideHero ?? deal.heroHole2,
      board: overrideBoard ?? deal.board5,
    );
  }

  Color _seatColor(_SeatMeta seat) {
    final visuallyActive = seat.occupied || _guidedTargetSeatIdV1 == seat.id;
    if (!visuallyActive) {
      return SharkyTokensV1.slate600.withOpacity(0.25);
    }
    if (_seatVisualSelectionIdV1() == seat.id) {
      return SharkyTokensV1.brandPrimary.withOpacity(0.28);
    }
    if (_guidedSeatsActive && visuallyActive) {
      return SharkyTokensV1.brandPrimary.withOpacity(0.18);
    }
    return SharkyTokensV1.surfaceCard.withOpacity(0.82);
  }

  Color _seatBorderColor(_SeatMeta seat) {
    final visuallyActive = seat.occupied || _guidedTargetSeatIdV1 == seat.id;
    if (!visuallyActive) {
      return SharkyTokensV1.slate600.withOpacity(0.7);
    }
    if (_seatVisualSelectionIdV1() == seat.id) {
      return SharkyTokensV1.brandPrimary;
    }
    return SharkyTokensV1.slate600;
  }

  Color _seatTextColor(_SeatMeta seat) {
    return (seat.occupied || _guidedTargetSeatIdV1 == seat.id)
        ? SharkyTokensV1.textPrimary
        : SharkyTokensV1.textMuted.withOpacity(0.8);
  }

  List<String> _seatRingOrderForTableV1(List<_SeatMeta> seats) {
    const canonicalSeatRenderOrderV1 = <String>[
      'btn',
      'sb',
      'bb',
      'utg',
      'utg1',
      'mp',
      'mp1',
      'hj',
      'co',
      'lj',
    ];
    final seatIds = seats.map((seat) => seat.id).toSet();
    return canonicalSeatRenderOrderV1
        .where(seatIds.contains)
        .toList(growable: false);
  }

  String _rotateSeatIdForDisplayV1({
    required String logicalSeatId,
    required String heroSeatId,
    required String bottomAnchorSeatId,
    required List<String> ring,
  }) {
    final logicalIndex = ring.indexOf(logicalSeatId);
    final heroIndex = ring.indexOf(heroSeatId);
    final bottomIndex = ring.indexOf(bottomAnchorSeatId);
    if (logicalIndex == -1 || heroIndex == -1 || bottomIndex == -1) {
      return logicalSeatId;
    }
    final delta = (bottomIndex - heroIndex) % ring.length;
    return ring[(logicalIndex + delta) % ring.length];
  }

  String _rotateSeatIdForLogicalFromDisplayV1({
    required String displaySeatId,
    required String heroSeatId,
    required String bottomAnchorSeatId,
    required List<String> ring,
  }) {
    final displayIndex = ring.indexOf(displaySeatId);
    final heroIndex = ring.indexOf(heroSeatId);
    final bottomIndex = ring.indexOf(bottomAnchorSeatId);
    if (displayIndex == -1 || heroIndex == -1 || bottomIndex == -1) {
      return displaySeatId;
    }
    final delta = (bottomIndex - heroIndex) % ring.length;
    return ring[(displayIndex - delta + ring.length) % ring.length];
  }

  String _displaySeatBadgeLabelV1(String logicalSeatId) {
    return logicalSeatId.toUpperCase();
  }

  String _seatQuizSeatDisplayV1(String seatId) {
    final normalized = seatId.trim().toLowerCase();
    return switch (normalized) {
      'bb' => 'BB (Big Blind)',
      'sb' => 'SB (Small Blind)',
      'btn' => 'BTN (Button)',
      'co' => 'CO (Cutoff)',
      'hj' => 'HJ (Hijack)',
      'utg' => 'UTG (Under the Gun)',
      'utg1' => 'UTG+1',
      'mp' => 'MP (Middle Position)',
      'mp1' => 'MP+1',
      'lj' => 'LJ (Lojack)',
      _ => normalized.toUpperCase(),
    };
  }

  String? _seatVisualSelectionIdV1() {
    if (_currentCampaignRunnerMode == _CampaignRunnerMode.handLoop) {
      final overrideSeatId = _normalizedScenarioSeatIdV1(_step.heroSeatId);
      if (overrideSeatId != null) return overrideSeatId;
    }
    return _selectedSeatId;
  }

  int get _effectiveSeatLayoutMaxPlayersV1 {
    final requested = widget.debugSeatLayoutMaxPlayersV1;
    if (requested == 9 || requested == 10) {
      return requested!;
    }
    final inferred = _seatLayoutMaxPlayersForPackIdV1(widget.moduleId);
    if (inferred == 9 || inferred == 10) {
      return inferred!;
    }
    return 6;
  }

  String? _normalizedScenarioSeatIdV1(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (_TableStadiumSpecV1.seatAnchorById.containsKey(normalized)) {
      return normalized;
    }
    return null;
  }

  Set<DecisionLegalKindV1>? _decisionLegalKindsFromStepOverrideV1(
    List<String>? actions,
  ) {
    if (actions == null) return null;
    final kinds = <DecisionLegalKindV1>{};
    var explicitlyForbidsFoldV1 = false;
    for (final raw in actions) {
      final token = raw.trim().toLowerCase().replaceAll('-', '_');
      switch (token) {
        case 'fold':
          kinds.add(DecisionLegalKindV1.fold);
          break;
        case 'no_fold':
        case 'forbid_fold':
        case 'fold_forbidden':
          explicitlyForbidsFoldV1 = true;
          break;
        case 'call':
        case 'check':
        case 'call_check':
        case 'callcheck':
        case 'check_call':
          kinds.add(DecisionLegalKindV1.callCheck);
          break;
        case 'bet':
        case 'raise':
        case 'bet_raise':
        case 'betraise':
        case 'raise_to':
          kinds.add(DecisionLegalKindV1.betRaise);
          break;
      }
    }
    if (!explicitlyForbidsFoldV1) {
      kinds.add(DecisionLegalKindV1.fold);
    }
    return kinds;
  }

  StreetV1? _scenarioStreetOverrideForStepV1() {
    switch (_step.street) {
      case MicroTaskStreetV1.flop:
        return StreetV1.flop;
      case MicroTaskStreetV1.turn:
        return StreetV1.turn;
      case MicroTaskStreetV1.river:
        return StreetV1.river;
      case null:
        return null;
    }
  }

  List<CardModel>? _parseScenarioCardsOverrideV1(List<String>? cards) {
    if (cards == null) return null;
    if (cards.isEmpty) return null;
    final parsed = <CardModel>[];
    for (final raw in cards) {
      final card = _tryParseCardCodeV1(raw);
      if (card == null) return null;
      parsed.add(card);
    }
    return parsed;
  }

  CardModel? _tryParseCardCodeV1(String raw) {
    final token = raw.trim();
    if (token.length < 2) return null;
    final rank = token.substring(0, token.length - 1).toUpperCase();
    final suitToken = token.substring(token.length - 1).toLowerCase();
    const suitMap = <String, String>{
      's': '♠',
      'h': '♥',
      'd': '♦',
      'c': '♣',
      '♠': '♠',
      '♥': '♥',
      '♦': '♦',
      '♣': '♣',
    };
    final suit = suitMap[suitToken];
    if (suit == null) return null;
    const validRanks = <String>{
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2',
      '10',
    };
    if (!validRanks.contains(rank)) return null;
    return CardModel(rank: rank == '10' ? 'T' : rank, suit: suit);
  }
}

class _SeatMeta {
  const _SeatMeta(this.id, this.label, this.alignment, this.occupied);

  final String id;
  final String label;
  final Alignment alignment;
  final bool occupied;
}

class _TableStadiumGeomV1 {
  const _TableStadiumGeomV1({
    required this.center,
    required this.clusterWidth,
    required this.clusterHeight,
    required this.xRadius,
    required this.yRadius,
    required this.seatRadiusX,
    required this.seatRadiusY,
    required this.rimThickness,
    required this.innerInset,
  });

  factory _TableStadiumGeomV1.fromLayout({
    required Size canvasSize,
    required Size clusterSize,
    required double rimThickness,
    required double innerInset,
    required double seatEdgeInset,
  }) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final resolvedClusterWidth = clusterSize.width.clamp(0.0, canvasSize.width);
    final resolvedClusterHeight = clusterSize.height.clamp(
      0.0,
      canvasSize.height,
    );
    final xRadius = (resolvedClusterWidth / 2).clamp(0.0, canvasSize.width / 2);
    final ovalYRadius = (resolvedClusterHeight / 2).clamp(
      0.0,
      canvasSize.height / 2,
    );
    final seatRadiusX = (xRadius - seatEdgeInset - 2).clamp(0.0, xRadius);
    final seatRadiusY = (ovalYRadius - seatEdgeInset - 2).clamp(
      0.0,
      ovalYRadius,
    );
    return _TableStadiumGeomV1(
      center: center,
      clusterWidth: resolvedClusterWidth,
      clusterHeight: resolvedClusterHeight,
      xRadius: xRadius,
      yRadius: ovalYRadius,
      seatRadiusX: seatRadiusX,
      seatRadiusY: seatRadiusY,
      rimThickness: rimThickness,
      innerInset: innerInset,
    );
  }

  final Offset center;
  final double clusterWidth;
  final double clusterHeight;
  final double xRadius;
  final double yRadius;
  final double seatRadiusX;
  final double seatRadiusY;
  final double rimThickness;
  final double innerInset;
}

class _TableStadiumSpecV1 {
  static const Offset stadiumCenter = Offset(0.50, 0.50);
  static const double stadiumWidth = 0.68;
  static const double stadiumHeight = 0.86;
  static const Map<String, Offset> seatAnchorById = <String, Offset>{
    // Canonical clockwise ring from BTN:
    // BTN -> SB -> BB -> UTG -> HJ -> CO.
    'btn': Offset(0.50, 0.93),
    'sb': Offset(0.16, 0.70),
    'bb': Offset(0.16, 0.30),
    'utg': Offset(0.50, 0.07),
    'hj': Offset(0.84, 0.30),
    'co': Offset(0.84, 0.70),
    // Additional anchors for debug 9-max / 10-max layouts.
    'utg1': Offset(0.28, 0.16),
    'mp': Offset(0.12, 0.42),
    'mp1': Offset(0.28, 0.84),
    'lj': Offset(0.72, 0.16),
  };
  static const double markerTowardCenterFactor = 0.14;
  static const Offset boardCenter = Offset(0.50, 0.46);
  static const Offset boardCenterLower = Offset(0.50, 0.57);
  static const Offset potCenter = Offset(0.50, 0.32);
  static const Offset heroCardsCenter = Offset(0.50, 0.72);

  static Offset resolveSeatCenter({
    required Size canvasSize,
    required String seatId,
    required double safeInset,
  }) {
    final anchor = seatAnchorById[seatId] ?? stadiumCenter;
    final rawX = canvasSize.width * anchor.dx;
    final rawY = canvasSize.height * anchor.dy;
    final minX = safeInset;
    final maxX = canvasSize.width - safeInset;
    final minY = safeInset;
    final maxY = canvasSize.height - safeInset;
    final resolvedX = maxX < minX
        ? canvasSize.width * stadiumCenter.dx
        : rawX.clamp(minX, maxX).toDouble();
    final resolvedY = maxY < minY
        ? canvasSize.height * stadiumCenter.dy
        : rawY.clamp(minY, maxY).toDouble();
    return Offset(resolvedX, resolvedY);
  }
}

enum _ActionChipEmphasisV1 { neutral, secondary, primary, raised }

enum _CoachModeV1 { none, intro, action, outcome, demo }

class _EngineVisualCards {
  const _EngineVisualCards({required this.hero, required this.board});

  final List<CardModel> hero;
  final List<CardModel> board;
}

class _World1OutcomeActionLaneInputsV1 {
  const _World1OutcomeActionLaneInputsV1({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isPrimaryBusy,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    required this.onBackToMapPressed,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool isPrimaryBusy;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onBackToMapPressed;
}

class _World1OutcomePresentationV1 {
  const _World1OutcomePresentationV1({
    required this.showHeaderStatus,
    required this.statusLine,
    required this.summaryPrimary,
    required this.summaryWhy,
    required this.summaryNext,
    required this.expectedChosenLine,
    required this.seatQuizCoachTitle,
    required this.seatQuizCoachSubtitle,
    required this.handLoopCoachTitle,
    required this.handLoopCoachBody,
  });

  final bool showHeaderStatus;
  final String statusLine;
  final String summaryPrimary;
  final String summaryWhy;
  final String summaryNext;
  final String expectedChosenLine;
  final String seatQuizCoachTitle;
  final String seatQuizCoachSubtitle;
  final String handLoopCoachTitle;
  final String handLoopCoachBody;

  bool get showsExpectedChosenLine => expectedChosenLine.isNotEmpty;

  _World1OutcomePresentationV1 copyWith({
    bool? showHeaderStatus,
    String? statusLine,
    String? summaryPrimary,
    String? summaryWhy,
    String? summaryNext,
    String? expectedChosenLine,
    String? seatQuizCoachTitle,
    String? seatQuizCoachSubtitle,
    String? handLoopCoachTitle,
    String? handLoopCoachBody,
  }) {
    return _World1OutcomePresentationV1(
      showHeaderStatus: showHeaderStatus ?? this.showHeaderStatus,
      statusLine: statusLine ?? this.statusLine,
      summaryPrimary: summaryPrimary ?? this.summaryPrimary,
      summaryWhy: summaryWhy ?? this.summaryWhy,
      summaryNext: summaryNext ?? this.summaryNext,
      expectedChosenLine: expectedChosenLine ?? this.expectedChosenLine,
      seatQuizCoachTitle: seatQuizCoachTitle ?? this.seatQuizCoachTitle,
      seatQuizCoachSubtitle:
          seatQuizCoachSubtitle ?? this.seatQuizCoachSubtitle,
      handLoopCoachTitle: handLoopCoachTitle ?? this.handLoopCoachTitle,
      handLoopCoachBody: handLoopCoachBody ?? this.handLoopCoachBody,
    );
  }
}

class _World1CompactTeachingPayloadV1 {
  const _World1CompactTeachingPayloadV1({
    required this.outcomePresentationV1,
    required this.supportTitle,
    required this.supportSubtitle,
    required this.handLoopCoachTitle,
    required this.handLoopCoachBody,
  });

  final _World1OutcomePresentationV1 outcomePresentationV1;
  final String supportTitle;
  final String supportSubtitle;
  final String handLoopCoachTitle;
  final String handLoopCoachBody;

  String get outcomePrimary => outcomePresentationV1.summaryPrimary;
  String get expectedChosenLine => outcomePresentationV1.expectedChosenLine;
  bool get showsExpectedChosenLine =>
      outcomePresentationV1.showsExpectedChosenLine;

  String compactOutcomeDetailText({required bool ultraCompactOutcome}) {
    return _joinCompactSegmentsV1(<String>[
      if (outcomePresentationV1.summaryWhy.isNotEmpty)
        outcomePresentationV1.summaryWhy,
      if ((!ultraCompactOutcome || outcomePresentationV1.summaryWhy.isEmpty) &&
          outcomePresentationV1.summaryNext.isNotEmpty &&
          outcomePresentationV1.summaryNext !=
              outcomePresentationV1.expectedChosenLine)
        outcomePresentationV1.summaryNext,
    ], separator: '\n');
  }

  static String _joinCompactSegmentsV1(
    List<String> segments, {
    String separator = ' ',
  }) {
    return segments
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .join(separator);
  }
}

class _World1TeachingContractV1 {
  const _World1TeachingContractV1({
    required this.introTitle,
    required this.introSubtitle,
    required this.outcomeTitle,
    required this.outcomeDetail,
    required this.handLoopCoachTitle,
    required this.handLoopCoachBody,
    required this.sharedTeachingGrammarV1,
    required this.compactTeachingPayloadV1,
  });

  final String introTitle;
  final String introSubtitle;
  final String outcomeTitle;
  final String outcomeDetail;
  final String handLoopCoachTitle;
  final String handLoopCoachBody;
  final SharedLearnerTeachingGrammarV1 sharedTeachingGrammarV1;
  final _World1CompactTeachingPayloadV1 compactTeachingPayloadV1;

  String? get headerStatusText => sharedTeachingGrammarV1.headerStatusText;
  String get headerHeadlineText => sharedTeachingGrammarV1.headerHeadlineText;
  String? get promptStatusText => sharedTeachingGrammarV1.promptStatusText;
  String get displayedPrompt => sharedTeachingGrammarV1.displayedPrompt;
  String get promptDetailsTitle => sharedTeachingGrammarV1.promptDetailsTitle;
  String get promptDetailsText => sharedTeachingGrammarV1.promptDetailsText;
  bool get canRevealPromptDetails =>
      sharedTeachingGrammarV1.canRevealPromptDetails;
  bool get enablePromptDetailsAffordance =>
      sharedTeachingGrammarV1.enablePromptDetailsAffordance;
  String get supportTitle => sharedTeachingGrammarV1.supportPrimaryText;
  String get supportSubtitle => sharedTeachingGrammarV1.supportSecondaryText;
  String get expectedChosenLine => sharedTeachingGrammarV1.supportTertiaryText;
  String get outcomePrimaryText => sharedTeachingGrammarV1.outcomePrimaryText;
  String get outcomeWhyText => sharedTeachingGrammarV1.outcomeWhyText;
  String get outcomeNextText => sharedTeachingGrammarV1.outcomeNextText;
  String get outcomeDetailText => sharedTeachingGrammarV1.outcomeDetailText;
}

class _World1SeatQuizInstructionPresentationV1 {
  const _World1SeatQuizInstructionPresentationV1({
    required this.headerPromptText,
    required this.headerPromptKey,
    required this.headerMaxLines,
    required this.headerOverflow,
    required this.headerSoftWrap,
    required this.tablePromptText,
  });

  final String headerPromptText;
  final Key headerPromptKey;
  final int headerMaxLines;
  final TextOverflow headerOverflow;
  final bool headerSoftWrap;
  final String tablePromptText;
}

class _World1StableLayoutV1 {
  const _World1StableLayoutV1({
    required this.viewportSize,
    required this.portraitLayout,
    required this.compactPortrait,
  });

  final Size viewportSize;
  final bool portraitLayout;
  final bool compactPortrait;
}

class _World1HandLoopTopBandCoexistenceV1 {
  const _World1HandLoopTopBandCoexistenceV1({
    required this.captionTop,
    required this.captionLeft,
    required this.captionRight,
    required this.maxCaptionWidth,
  });

  final double captionTop;
  final double captionLeft;
  final double captionRight;
  final double maxCaptionWidth;
}

enum _CampaignRunnerMode { seatQuiz, handLoop }
