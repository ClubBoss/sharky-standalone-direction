import 'dart:async';
import 'dart:convert';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/skill_tags_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/services/chips_ledger_v1.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';
import 'package:poker_analyzer/services/mastery_progress_v1.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'emotion_phrases_v1.dart';

class ReviewRefV1 {
  const ReviewRefV1({required this.packId, required this.stepIndex});

  final String packId;
  final int stepIndex;

  Map<String, Object> toJson() => <String, Object>{
    'packId': packId,
    'stepIndex': stepIndex,
  };

  static ReviewRefV1? tryParse(Object? raw, {required String fallbackPackId}) {
    if (raw is! Map) return null;
    final packId = (raw['packId'] ?? fallbackPackId)
        .toString()
        .trim()
        .toLowerCase();
    final stepIndexRaw = raw['stepIndex'];
    final stepIndex = stepIndexRaw is int
        ? stepIndexRaw
        : int.tryParse(stepIndexRaw?.toString() ?? '');
    if (packId.isEmpty || stepIndex == null || stepIndex < 0) {
      return null;
    }
    return ReviewRefV1(packId: packId, stepIndex: stepIndex);
  }

  @override
  bool operator ==(Object other) =>
      other is ReviewRefV1 &&
      other.packId == packId &&
      other.stepIndex == stepIndex;

  @override
  int get hashCode => Object.hash(packId, stepIndex);
}

class CheckpointSessionRecordV1 {
  const CheckpointSessionRecordV1({
    required this.sessionId,
    required this.worldId,
    required this.errorClassCounts,
  });

  final String sessionId;
  final String worldId;
  final Map<String, int> errorClassCounts;

  Map<String, Object> toJson() => <String, Object>{
    'session_id': sessionId,
    'world_id': worldId,
    'error_class_counts': errorClassCounts,
  };

  static CheckpointSessionRecordV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final sessionId = (raw['session_id'] ?? '').toString().trim().toLowerCase();
    final worldId = (raw['world_id'] ?? '').toString().trim().toLowerCase();
    if (sessionId.isEmpty || worldId.isEmpty) return null;
    final countsRaw = raw['error_class_counts'];
    final counts = <String, int>{};
    if (countsRaw is Map) {
      for (final entry in countsRaw.entries) {
        final key = entry.key.toString().trim().toLowerCase();
        if (key.isEmpty) continue;
        final value = entry.value;
        final parsed = value is int ? value : int.tryParse('$value');
        if (parsed == null || parsed <= 0) continue;
        counts[key] = parsed;
      }
    }
    return CheckpointSessionRecordV1(
      sessionId: sessionId,
      worldId: worldId,
      errorClassCounts: Map<String, int>.unmodifiable(counts),
    );
  }
}

class CheckpointProgressUpdateV1 {
  const CheckpointProgressUpdateV1({
    required this.completedSessionsSinceLastCheckpoint,
    required this.checkpointPending,
    required this.topErrorClasses,
  });

  final int completedSessionsSinceLastCheckpoint;
  final bool checkpointPending;
  final List<String> topErrorClasses;
}

class MasteryReadBundleV1 {
  const MasteryReadBundleV1({
    this.schemaVersion = 1,
    required this.snapshot,
    required this.badges,
  });

  final int schemaVersion;
  final MasterySnapshotV1 snapshot;
  final Map<String, MasteryBadgeV1> badges;

  Map<String, Object?> toJson() {
    final sortedSnapshotKeys = snapshot.perWorld.keys.toList(growable: false)
      ..sort();
    final snapshotPerWorld = <String, Object?>{};
    for (final worldId in sortedSnapshotKeys) {
      final item = snapshot.perWorld[worldId]!;
      snapshotPerWorld[worldId] = <String, Object?>{
        'totalSessions': item.totalSessions,
        'completedSessions': item.completedSessions,
        'rollingAccuracy': item.rollingAccuracy,
        'isEligibleForHighTier': item.isEligibleForHighTier,
      };
    }
    final sortedBadgeKeys = badges.keys.toList(growable: false)..sort();
    final badgeJson = <String, Object?>{};
    for (final worldId in sortedBadgeKeys) {
      badgeJson[worldId] = badges[worldId]!.name;
    }
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'snapshot': <String, Object?>{
        'schemaVersion': snapshot.schemaVersion,
        'perWorld': snapshotPerWorld,
      },
      'badges': badgeJson,
    };
  }
}

class GauntletPlanV1 {
  const GauntletPlanV1({
    this.schemaVersion = 1,
    required this.recommendedWorldIds,
    required this.reasonCodes,
  });

  final int schemaVersion;
  final List<String> recommendedWorldIds;
  final List<String> reasonCodes;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'recommendedWorldIds': List<String>.unmodifiable(recommendedWorldIds),
    'reasonCodes': List<String>.unmodifiable(reasonCodes),
  };
}

class EmotionReadBundleV1 {
  const EmotionReadBundleV1({
    this.schemaVersion = 1,
    required this.tag,
    required this.reasons,
    required this.recommendedWorldIds,
    required this.masteryBadges,
  });

  final int schemaVersion;
  final EmotionTagV1 tag;
  final List<String> reasons;
  final List<String> recommendedWorldIds;
  final Map<String, MasteryBadgeV1> masteryBadges;

  Map<String, Object?> toJson() {
    final sortedWorldIds = masteryBadges.keys.toList(growable: false)..sort();
    final badgeJson = <String, Object?>{};
    for (final worldId in sortedWorldIds) {
      badgeJson[worldId] = masteryBadges[worldId]!.name;
    }
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'tag': tag.name,
      'reasons': List<String>.unmodifiable(reasons),
      'recommendedWorldIds': List<String>.unmodifiable(recommendedWorldIds),
      'masteryBadges': badgeJson,
    };
  }
}

// Append-only order for consumers that rely on enum index stability.
enum EmotionTagV1 { neutral, confident, cautious, urgent }

enum AdaptiveRoutingFocusV1 { toCall, expectedAction }

EmotionTagV1 deriveEmotionTagV1({
  required MasteryReadBundleV1 mastery,
  required GauntletPlanV1 plan,
}) {
  final inProgressRatios = _recommendedInProgressRatiosV1(
    mastery: mastery,
    plan: plan,
  );
  if (inProgressRatios.any((ratio) => ratio < 0.34)) {
    return EmotionTagV1.urgent;
  }
  if (inProgressRatios.isNotEmpty) {
    return EmotionTagV1.cautious;
  }
  if (mastery.badges.values.any((badge) => badge == MasteryBadgeV1.highTier)) {
    return EmotionTagV1.confident;
  }
  return EmotionTagV1.neutral;
}

List<String> _deriveEmotionReasonsV1({
  required MasteryReadBundleV1 mastery,
  required GauntletPlanV1 plan,
}) {
  final reasons = <String>[];
  final inProgressRatios = _recommendedInProgressRatiosV1(
    mastery: mastery,
    plan: plan,
  );
  if (inProgressRatios.any((ratio) => ratio < 0.34)) {
    reasons.add('low_completion_ratio');
  } else if (inProgressRatios.isNotEmpty) {
    reasons.add('in_progress');
  } else if (mastery.badges.values.any(
    (badge) => badge == MasteryBadgeV1.highTier,
  )) {
    reasons.add('high_tier_ready');
  } else {
    reasons.add('neutral_baseline');
  }
  return List<String>.unmodifiable(reasons);
}

List<double> _recommendedInProgressRatiosV1({
  required MasteryReadBundleV1 mastery,
  required GauntletPlanV1 plan,
}) {
  final ratios = <double>[];
  for (final worldId in plan.recommendedWorldIds) {
    final badge = mastery.badges[worldId];
    final world = mastery.snapshot.perWorld[worldId];
    if (badge != MasteryBadgeV1.inProgress || world == null) {
      continue;
    }
    final ratio = world.totalSessions <= 0
        ? 1.0
        : world.completedSessions / world.totalSessions;
    ratios.add(ratio);
  }
  ratios.sort();
  return List<double>.unmodifiable(ratios);
}

class ProgressService {
  static const String _xpKey = 'user_xp';
  static const String unlockedPrefix = 'module_unlocked';
  static const String _completedPrefix = 'module_completed';
  static const String _streakKey = 'user_streak';
  static const String _lastVisitKey = 'last_visit_date';
  static const String completedPrefix = 'module_completed';
  static const String _world1DailyCompletedDateKey =
      'world1_completed_today_ymd';
  static const String _lessonFocusLabelKey = 'lesson_focus_label_v1';
  static const String _intakeProfileKey = 'intake_profile_v1';
  static const String _intakeCompletedKey = 'intake_completed_v1';
  static const String _nextReviewAtPrefix = 'next_review_at_v1_';
  static const String _reviewQueuePrefix = 'review_queue_v1::';
  static const String _checkpointSessionsSinceLastV1Key =
      'checkpoint_sessions_since_last_v1';
  static const String _checkpointPendingV1Key = 'checkpoint_pending_v1';
  static const String _checkpointHistoryV1Key = 'checkpoint_history_v1';
  static const String _checkpointSeedPrefixV1 = 'checkpoint_seed_v1::';
  static const int checkpointEverySessionsV1 = 4;
  static const int checkpointHistoryWindowV1 = 5;
  static const int checkpointTopErrorClassesLimitV1 = 3;
  static const String checkpointPackIdV1 = 'season1_checkpoint_global_v1';
  static const String _leaksLogV1Key = 'leaks_log_v1';
  static const String _leaksResolutionLogV1Key = 'leaks_resolution_log_v1';
  static const String _gauntletCompletionLogV1Key =
      'gauntlet_completion_log_v1';
  static const String _gauntletStepProgressV1Key = 'gauntlet_step_progress_v1';
  static const String _userCohortV1Key = 'user_cohort_v1';
  static const String _cohortPromotionEventV1Key = 'cohort_promotion_event_v1';
  static const String _cohortPromotionConsumedIdsV1Key =
      'cohort_promotion_consumed_ids_v1';
  static const String _worldMasteryPrefix = 'world_mastery_v1::';
  static const String _skillTagsPrefix = 'skill_tags_v1::';
  static const String _chipsBalanceV1Key = 'chips_balance_v1';
  static const String _chipsEarnedTotalV1Key = 'chips_earned_total_v1';
  static const String _chipsSpentTotalV1Key = 'chips_spent_total_v1';
  static const String _chipsAppliedTxnIdsV1Key = 'chips_applied_txn_ids_v1';
  static const String _masteryProgressV1Key = 'mastery_progress_v1';
  static const String _skillBandV1Key = 'skill_band_v1';
  static const String _placementScoreV1Key = 'placement_score_v1';
  static const String _freeRollRemainingV1Key = 'free_roll_remaining_v1';
  static const String _bankrollBalanceKey = 'training_bankroll_balance_v1';
  static const String _bankrollLastRegenAtKey =
      'training_bankroll_last_regen_at_v1';
  static const String _bankrollBackerUsedYmdKey =
      'training_bankroll_backer_used_ymd_v1';
  static const String _bankrollChargedPrefix = 'training_bankroll_charged_v1_';
  static const String _bankrollRakebackGrantedPrefix =
      'training_bankroll_rakeback_granted_v1_';
  static const String _bankrollPendingSessionIdKey =
      'training_bankroll_pending_session_id_v1';
  static const String _bankrollPendingCostKey =
      'training_bankroll_pending_cost_v1';
  static const String _bankrollPendingSessionKindKey =
      'training_bankroll_pending_session_kind_v1';
  static const String _bankrollPendingModuleIdKey =
      'training_bankroll_pending_module_id_v1';
  static const String _spineRankV1Key = 'spine_rank_v1';
  static const String _spineCalibrationBandV1Key = 'spine_calibration_band_v1';
  static const String _spineCalibrationCompletedV1Key =
      'spine_calibration_completed_v1';
  static const String _world2CalibrationCompletedV1Key =
      'world2_calibration_completed_v1';
  static const String _world3CalibrationCompletedV1Key =
      'world3_calibration_completed_v1';
  static const String _world4CalibrationCompletedV1Key =
      'world4_calibration_completed_v1';
  static const String _world5CalibrationCompletedV1Key =
      'world5_calibration_completed_v1';
  static const String _world6CalibrationCompletedV1Key =
      'world6_calibration_completed_v1';
  static const String _world7CalibrationCompletedV1Key =
      'world7_calibration_completed_v1';
  static const String _world8CalibrationCompletedV1Key =
      'world8_calibration_completed_v1';
  static const String _world9CalibrationCompletedV1Key =
      'world9_calibration_completed_v1';
  static const String _world10CalibrationCompletedV1Key =
      'world10_calibration_completed_v1';
  static const String _world10TrackChoiceSeenV1Key =
      'world10_track_choice_seen_v1';
  static const String _world10TrackChoiceV1Key = 'world10_track_choice_v1';
  static const String world10TrackChoiceCashV1 = 'cash';
  static const String world10TrackChoiceTournamentV1 = 'tournament';
  static const String world10TrackChoiceMixedV1 = 'mixed';
  static const String _spineCampaignActivePackIdV1Key =
      'spine_campaign_active_pack_id_v1';
  static const String _spineCampaignNextHandIndexV1Key =
      'spine_campaign_next_hand_index_v1';
  static const String _spineCampaignCompletedPacksV1Key =
      'spine_campaign_completed_packs_v1';
  static const String _campaignCompleteTelemetrySentV1Key =
      'campaign_complete_telemetry_sent_v1';
  static const String _campaignBankrollBalanceV1Key =
      'campaign_bankroll_balance_v1';
  static const int _dailyDripAmountV1 = 1;
  static const int _chipsAppliedTxnIdsMaxV1 = 512;
  static const int leaksLogMaxEntriesV1 = 200;
  static const int leaksResolutionLogMaxEntriesV1 = 200;
  static const int gauntletCompletionLogMaxEntriesV1 = 180;
  static const int gauntletStepProgressMaxEntriesV1 = 180;
  static const int leaksDailyCapV1 = 5;
  static const int _cohortPromotionMinCompletionsV1 = 5;
  static const int _cohortPromotionEventMaxEntriesV1 = 32;
  static const int _cohortPromotionConsumedIdsMaxV1 = 64;
  static const String leaksQueueAlgoVersionV1 = 'leaks_queue_v1';
  static Future<void> _chipsTxnTailV1 = Future<void>.value();
  static const String _campaignBackerLastUsedAtV1Key =
      'campaign_backer_last_used_at_v1';
  static const String spineInitialPackIdV1 = 'world1_spine_campaign_v1';
  static const List<String> campaignAct0PackIdsV1 = <String>[
    'world1_act0_table_literacy',
    'world1_act0_action_literacy',
    'world1_act0_street_flow',
  ];
  static const List<String> campaignFollowupPackIdsV1 = <String>[
    'world1_spine_followup_v1_b0',
    'world1_spine_followup_v1_b1',
    'world1_spine_followup_v1_b2',
  ];
  static final List<String> campaignPackIdsV1 = List<String>.unmodifiable(
    campaign_registry.kCampaignPackIdsV1,
  );
  static const String w7W10LearnerRouteGateTerminalPackIdV1 =
      'world6_spine_followup_v1_b2';
  static const Set<String> _w8W10LearnerRouteLockedPackIdsV1 = <String>{
    'world8_spine_campaign_v1',
    'world8_spine_followup_v1_b0',
    'world8_spine_followup_v1_b1',
    'world8_spine_followup_v1_b2',
    'world9_spine_campaign_v1',
    'world9_spine_followup_v1_b0',
    'world9_spine_followup_v1_b1',
    'world9_spine_followup_v1_b2',
    'world10_spine_campaign_v1',
    'world10_spine_followup_v1_b0',
    'world10_spine_followup_v1_b1',
    'world10_spine_followup_v1_b2',
  };
  static const int bankrollCap = 100;
  static const int bankrollRegenIntervalMinutes = 60;
  static const int bankrollRegenAmount = 10;
  static const int bankrollCostCoreSession = 20;
  static const int bankrollCostReviewSession = 5;
  static const int bankrollCostCheckpoint = 30;
  static const int freeRollInitialSessions = 3;
  static const int spineRankFish = 0;
  static const int spineRankGrinder = 1;
  static const int spineRankShark = 2;
  static const int campaignRankTadpole = 0;
  static const int campaignRankFish = 1;
  static const int campaignRankGrinder = 2;
  static const int campaignRankRegular = 3;
  static const int campaignRankCrusher = 4;
  static const int campaignRankShark = 5;
  static const int _campaignRankWorld1UnlockV1 = 1;
  static const int _campaignRankWorld2UnlockV1 = 3;
  static const int _campaignRankWorld3UnlockV1 = 5;
  static const int _campaignRankWorld4UnlockV1 = 7;
  static const int _campaignRankWorld5UnlockV1 = 10;
  static const int spineCalibrationBandBeginner = 0;
  static const int spineCalibrationBandIntermediate = 1;
  static const int spineCalibrationBandAdvanced = 2;
  static const int campaignBackerRefillAmountV1 = 20;
  static const int campaignBackerCooldownMinutesV1 = 30;
  static const int _masteryProgressSchemaVersionV1 = 1;
  static const int _masteryMinConfiguredSessionsPerWorldV1 = 10;
  static const String _masteryReadBundleTelemetryEventV1 =
      'mastery_read_bundle_v1';
  static const String _emotionTagTelemetryEventV1 = 'emotion_tag_v1';
  static const String _emotionPhraseShownTelemetryEventV1 =
      'emotion_phrase_shown_v1';
  static final RegExp _microSessionModuleIdPatternV1 = RegExp(
    r'^w([0-4])\.s(\d{2})$',
  );
  static final RegExp _sessionIdWorldPatternV1 = RegExp(r'^w([0-9])\.s\d{2}$');
  static final ValueNotifier<int> world1ProgressRevision = ValueNotifier<int>(
    0,
  );
  static final ValueNotifier<bool> world1DailyCompletionInSession =
      ValueNotifier<bool>(false);
  static bool intakeFlowActiveInSession = false;
  static DateTime Function()? debugNowOverride;

  /// --- XP LOGIC ---
  static Future<int> getXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<void> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, current + amount);
  }

  /// --- MODULE LOGIC ---
  static Future<bool> isModuleUnlocked(String moduleId) async {
    if (moduleId == 'core_rules_and_setup') return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$unlockedPrefix$moduleId') ?? false;
  }

  static Future<bool> isModuleCompleted(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_completedPrefix$moduleId') ?? false;
  }

  static Future<void> markModuleCompleted(
    String moduleId, {
    int? correctCount,
    int? totalCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedPrefix$moduleId';
    final alreadyCompleted = prefs.getBool(key) ?? false;
    await prefs.setBool(key, true);
    if (!alreadyCompleted) {
      await _maybeUpdateMasteryProgressV1OnCompletion(
        moduleId: moduleId,
        correctCount: correctCount,
        totalCount: totalCount,
      );
      await _maybeMarkWorld3CalibrationFromSessionBridgeV1(moduleId);
      await _maybeMarkWorld4CalibrationFromSessionBridgeV1(moduleId);
      await _maybeMarkWorld5CalibrationFromSessionBridgeV1(moduleId);
      unawaited(_emitMasteryReadBundleTelemetryV1());
      unawaited(_emitEmotionTagTelemetryV1());
      unawaited(
        _emitEmotionPhraseShownTelemetryForContextV1(
          EmotionPhraseContextV1.identity,
        ),
      );
      world1ProgressRevision.value = world1ProgressRevision.value + 1;
    }
    // Placeholder: In a real graph we'd unlock dependencies here.
  }

  static Future<void> _maybeMarkWorld4CalibrationFromSessionBridgeV1(
    String moduleId,
  ) async {
    final normalized = moduleId.trim().toLowerCase();
    if (normalized != 'w4.s01' &&
        normalized != 'w4.s02' &&
        normalized != 'w4.s03' &&
        normalized != 'w4.s04' &&
        normalized != 'w4.s05' &&
        normalized != 'w4.s06' &&
        normalized != 'w4.s07' &&
        normalized != 'w4.s08' &&
        normalized != 'w4.s09' &&
        normalized != 'w4.s10') {
      return;
    }
    const requiredSessions = <String>[
      'w4.s01',
      'w4.s02',
      'w4.s03',
      'w4.s04',
      'w4.s05',
      'w4.s06',
      'w4.s07',
      'w4.s08',
      'w4.s09',
      'w4.s10',
    ];
    for (final sessionId in requiredSessions) {
      if (!await isModuleCompleted(sessionId)) {
        return;
      }
    }
    await markWorld4CalibrationCompletedV1();
  }

  static Future<void> _maybeMarkWorld3CalibrationFromSessionBridgeV1(
    String moduleId,
  ) async {
    final normalized = moduleId.trim().toLowerCase();
    if (normalized != 'w3.s01' &&
        normalized != 'w3.s02' &&
        normalized != 'w3.s03' &&
        normalized != 'w3.s04' &&
        normalized != 'w3.s05' &&
        normalized != 'w3.s06' &&
        normalized != 'w3.s07' &&
        normalized != 'w3.s08' &&
        normalized != 'w3.s09' &&
        normalized != 'w3.s10' &&
        normalized != 'w3.s11' &&
        normalized != 'w3.s12' &&
        normalized != 'w3.s13' &&
        normalized != 'w3.s14') {
      return;
    }
    const requiredSessions = <String>[
      'w3.s01',
      'w3.s02',
      'w3.s03',
      'w3.s04',
      'w3.s05',
      'w3.s06',
      'w3.s07',
      'w3.s08',
      'w3.s09',
      'w3.s10',
      'w3.s11',
      'w3.s12',
      'w3.s13',
      'w3.s14',
    ];
    for (final sessionId in requiredSessions) {
      if (!await isModuleCompleted(sessionId)) {
        return;
      }
    }
    await markWorld3CalibrationCompletedV1();
  }

  static Future<void> _maybeMarkWorld5CalibrationFromSessionBridgeV1(
    String moduleId,
  ) async {
    final normalized = moduleId.trim().toLowerCase();
    if (normalized != 'w5.s01' &&
        normalized != 'w5.s02' &&
        normalized != 'w5.s03' &&
        normalized != 'w5.s04' &&
        normalized != 'w5.s05' &&
        normalized != 'w5.s06' &&
        normalized != 'w5.s07' &&
        normalized != 'w5.s08' &&
        normalized != 'w5.s09' &&
        normalized != 'w5.s10') {
      return;
    }
    const requiredSessions = <String>[
      'w5.s01',
      'w5.s02',
      'w5.s03',
      'w5.s04',
      'w5.s05',
      'w5.s06',
      'w5.s07',
      'w5.s08',
      'w5.s09',
      'w5.s10',
    ];
    for (final sessionId in requiredSessions) {
      if (!await isModuleCompleted(sessionId)) {
        return;
      }
    }
    await markWorld5CalibrationCompletedV1();
  }

  static Future<void> _emitMasteryReadBundleTelemetryV1() async {
    final bundle = await getMasteryReadBundleV1();
    final sortedWorldIds = bundle.snapshot.perWorld.keys.toList(growable: false)
      ..sort();
    final perWorld = <String, Object?>{};
    for (final worldId in sortedWorldIds) {
      final world = bundle.snapshot.perWorld[worldId];
      if (world == null) continue;
      perWorld[worldId] = <String, Object?>{
        'completedSessions': world.completedSessions,
        'totalSessions': world.totalSessions,
        'rollingAccuracy': world.rollingAccuracy,
        'badge': (bundle.badges[worldId] ?? MasteryBadgeV1.none).name,
      };
    }
    await Telemetry.logEvent(
      _masteryReadBundleTelemetryEventV1,
      <String, dynamic>{
        'schemaVersion': bundle.schemaVersion,
        'perWorld': perWorld,
      },
    );
  }

  static Future<void> _emitEmotionTagTelemetryV1() async {
    final payload = await getEmotionTagTelemetryPayloadV1();
    await Telemetry.logEvent(_emotionTagTelemetryEventV1, payload);
  }

  static Future<Map<String, dynamic>> getEmotionTagTelemetryPayloadV1() async {
    try {
      final json = (await getEmotionReadBundleV1().timeout(
        const Duration(milliseconds: 150),
      )).toJson();
      final masteryBadgesRaw = json['masteryBadges'];
      final masteryBadges = masteryBadgesRaw is Map
          ? Map<String, dynamic>.from(masteryBadgesRaw)
          : <String, dynamic>{};
      return <String, dynamic>{
        'schemaVersion': json['schemaVersion'],
        'tag': json['tag'],
        'reasons': json['reasons'],
        'recommendedWorldIds': json['recommendedWorldIds'],
        'masteryBadges': masteryBadges,
      };
    } catch (_) {
      return <String, dynamic>{
        'schemaVersion': 1,
        'tag': EmotionTagV1.neutral.name,
        'reasons': const <String>['unavailable'],
        'recommendedWorldIds': const <String>[],
        'masteryBadges': const <String, dynamic>{},
      };
    }
  }

  static Map<String, dynamic> getEmotionPhraseTelemetryPayloadV1({
    required EmotionPhraseContextV1 context,
    required EmotionTagV1 tag,
  }) {
    final json = selectEmotionPhraseV1(context: context, tag: tag).toJson();
    return <String, dynamic>{
      'schemaVersion': json['schemaVersion'],
      'phraseId': json['phraseId'],
      'context': json['context'],
      'tag': json['tag'],
      'text': json['text'],
    };
  }

  static Future<Map<String, dynamic>>
  getEmotionPhraseTelemetryPayloadForContextV1({
    required EmotionPhraseContextV1 context,
  }) async {
    try {
      final emotion = await getEmotionReadBundleV1().timeout(
        const Duration(milliseconds: 150),
      );
      return getEmotionPhraseTelemetryPayloadV1(
        context: context,
        tag: emotion.tag,
      );
    } catch (_) {
      return getEmotionPhraseTelemetryPayloadV1(
        context: context,
        tag: EmotionTagV1.neutral,
      );
    }
  }

  static Future<void> _emitEmotionPhraseShownTelemetryForContextV1(
    EmotionPhraseContextV1 context,
  ) async {
    final payload = await getEmotionPhraseTelemetryPayloadForContextV1(
      context: context,
    );
    await Telemetry.logEvent(_emotionPhraseShownTelemetryEventV1, payload);
  }

  static Future<Map<String, MasteryProgressV1>> getMasteryProgressV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_masteryProgressV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <String, MasteryProgressV1>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const <String, MasteryProgressV1>{};
      final schemaVersion = decoded['schema_version'];
      if (schemaVersion != _masteryProgressSchemaVersionV1) {
        return const <String, MasteryProgressV1>{};
      }
      final worldsRaw = decoded['worlds'];
      if (worldsRaw is! List) return const <String, MasteryProgressV1>{};
      final entries = <String, MasteryProgressV1>{};
      for (final item in worldsRaw) {
        final parsed = MasteryProgressV1.tryParse(item);
        if (parsed == null) continue;
        entries[parsed.worldId] = parsed;
      }
      return Map<String, MasteryProgressV1>.unmodifiable(entries);
    } catch (_) {
      return const <String, MasteryProgressV1>{};
    }
  }

  static Future<MasteryTierConfigV1> masteryTierConfigForSessionIdV1(
    String sessionId,
  ) async {
    final worldId = _worldIdFromSessionIdV1(sessionId);
    if (worldId == null) {
      return masteryTierConfigForSessionV1(
        sessionId: sessionId,
        progressForWorld: null,
      );
    }
    final store = await getMasteryProgressV1();
    return masteryTierConfigForSessionV1(
      sessionId: sessionId,
      progressForWorld: store[worldId],
    );
  }

  static Future<MasterySnapshotV1> getMasterySnapshotV1() async {
    final store = await getMasteryProgressV1();
    final sortedWorldIds = store.keys.toList(growable: false)..sort();
    final perWorld = <String, MasteryWorldSnapshotV1>{};
    for (final worldId in sortedWorldIds) {
      final progress = store[worldId];
      if (progress == null) continue;
      perWorld[worldId] = MasteryWorldSnapshotV1(
        totalSessions: progress.totalSessions,
        completedSessions: progress.completedSessions,
        rollingAccuracy: progress.rollingAccuracy,
        isEligibleForHighTier: isEligibleForHighTierV1(progress),
      );
    }
    return MasterySnapshotV1(
      perWorld: Map<String, MasteryWorldSnapshotV1>.unmodifiable(perWorld),
    );
  }

  static Future<Map<String, MasteryBadgeV1>> getMasteryBadgesV1() async {
    final snapshot = await getMasterySnapshotV1();
    final sortedWorldIds = snapshot.perWorld.keys.toList(growable: false)
      ..sort();
    final badges = <String, MasteryBadgeV1>{};
    for (final worldId in sortedWorldIds) {
      badges[worldId] = masteryBadgeForWorldSnapshotV1(
        snapshot.perWorld[worldId],
      );
    }
    return Map<String, MasteryBadgeV1>.unmodifiable(badges);
  }

  static Future<MasteryReadBundleV1> getMasteryReadBundleV1() async {
    final snapshot = await getMasterySnapshotV1();
    final badges = await getMasteryBadgesV1();
    final sortedSnapshotKeys = snapshot.perWorld.keys.toList(growable: false)
      ..sort();
    final normalizedPerWorld = <String, MasteryWorldSnapshotV1>{};
    for (final worldId in sortedSnapshotKeys) {
      final value = snapshot.perWorld[worldId];
      if (value != null) normalizedPerWorld[worldId] = value;
    }
    final sortedBadgeKeys = badges.keys.toList(growable: false)..sort();
    final normalizedBadges = <String, MasteryBadgeV1>{};
    for (final worldId in sortedBadgeKeys) {
      final value = badges[worldId];
      if (value != null) normalizedBadges[worldId] = value;
    }
    return MasteryReadBundleV1(
      snapshot: MasterySnapshotV1(
        schemaVersion: snapshot.schemaVersion,
        perWorld: Map<String, MasteryWorldSnapshotV1>.unmodifiable(
          normalizedPerWorld,
        ),
      ),
      badges: Map<String, MasteryBadgeV1>.unmodifiable(normalizedBadges),
    );
  }

  static Future<GauntletPlanV1> getGauntletPlanV1() async {
    final bundle = await getMasteryReadBundleV1();
    final snapshot = bundle.snapshot.perWorld;
    final inProgressWorlds = <String>[];
    final completeWorlds = <String>[];
    for (final worldId in snapshot.keys) {
      final world = snapshot[worldId];
      final badge = bundle.badges[worldId] ?? MasteryBadgeV1.none;
      if (world == null) continue;
      if (badge == MasteryBadgeV1.inProgress) {
        inProgressWorlds.add(worldId);
      } else if (badge == MasteryBadgeV1.complete) {
        completeWorlds.add(worldId);
      }
    }
    inProgressWorlds.sort((a, b) {
      final wa = snapshot[a]!;
      final wb = snapshot[b]!;
      final ra = wa.totalSessions <= 0
          ? 1.0
          : wa.completedSessions / wa.totalSessions;
      final rb = wb.totalSessions <= 0
          ? 1.0
          : wb.completedSessions / wb.totalSessions;
      final byRatio = ra.compareTo(rb);
      if (byRatio != 0) return byRatio;
      return a.compareTo(b);
    });
    completeWorlds.sort();

    final recommended = <String>[];
    final reasonCodes = <String>[];
    for (final worldId in inProgressWorlds) {
      if (recommended.length >= 3) break;
      recommended.add(worldId);
      if (!reasonCodes.contains('needs_completion')) {
        reasonCodes.add('needs_completion');
      }
    }
    for (final worldId in completeWorlds) {
      if (recommended.length >= 3) break;
      recommended.add(worldId);
      if (!reasonCodes.contains('high_tier_ready')) {
        reasonCodes.add('high_tier_ready');
      }
    }
    if (recommended.isEmpty) {
      reasonCodes.add('no_progress');
    }
    return GauntletPlanV1(
      recommendedWorldIds: List<String>.unmodifiable(recommended),
      reasonCodes: List<String>.unmodifiable(reasonCodes),
    );
  }

  static Future<EmotionReadBundleV1> getEmotionReadBundleV1() async {
    final mastery = await getMasteryReadBundleV1();
    final plan = await getGauntletPlanV1();
    final tag = deriveEmotionTagV1(mastery: mastery, plan: plan);
    final reasons = _deriveEmotionReasonsV1(mastery: mastery, plan: plan);
    final sortedWorldIds = mastery.badges.keys.toList(growable: false)..sort();
    final normalizedBadges = <String, MasteryBadgeV1>{};
    for (final worldId in sortedWorldIds) {
      final badge = mastery.badges[worldId];
      if (badge != null) normalizedBadges[worldId] = badge;
    }
    return EmotionReadBundleV1(
      tag: tag,
      reasons: List<String>.unmodifiable(reasons),
      recommendedWorldIds: List<String>.unmodifiable(plan.recommendedWorldIds),
      masteryBadges: Map<String, MasteryBadgeV1>.unmodifiable(normalizedBadges),
    );
  }

  static String? _worldIdFromSessionIdV1(String sessionId) {
    final normalized = sessionId.trim().toLowerCase();
    final match = _sessionIdWorldPatternV1.firstMatch(normalized);
    if (match == null) return null;
    final worldIndex = int.tryParse(match.group(1) ?? '');
    if (worldIndex == null || worldIndex < 0 || worldIndex > 9) {
      return null;
    }
    return 'world$worldIndex';
  }

  static Future<void> _maybeUpdateMasteryProgressV1OnCompletion({
    required String moduleId,
    int? correctCount,
    int? totalCount,
  }) async {
    final normalizedModuleId = moduleId.trim().toLowerCase();
    final match = _microSessionModuleIdPatternV1.firstMatch(normalizedModuleId);
    if (match == null) {
      return;
    }
    final worldIndex = int.tryParse(match.group(1) ?? '');
    final sessionOrdinal = int.tryParse(match.group(2) ?? '');
    if (worldIndex == null || sessionOrdinal == null) {
      return;
    }
    final worldId = 'world$worldIndex';
    final existing = await getMasteryProgressV1();
    final previous = existing[worldId];
    final previousCompleted = previous?.completedSessions ?? 0;
    final nextCompleted = previousCompleted + 1;
    final configuredTotalSessions =
        previous?.totalSessions ?? _masteryMinConfiguredSessionsPerWorldV1;
    final nextTotalSessions = <int>[
      configuredTotalSessions,
      _masteryMinConfiguredSessionsPerWorldV1,
      sessionOrdinal,
      nextCompleted,
    ].reduce((value, element) => value >= element ? value : element);

    final sessionAccuracy = _resolveSessionAccuracyV1(
      correctCount: correctCount,
      totalCount: totalCount,
      previousAccuracy: previous?.rollingAccuracy,
    );
    final previousAccuracy = previous?.rollingAccuracy ?? sessionAccuracy;
    final nextAccuracy =
        ((previousAccuracy * previousCompleted) + sessionAccuracy) /
        nextCompleted;
    final next = MasteryProgressV1(
      worldId: worldId,
      totalSessions: nextTotalSessions,
      completedSessions: nextCompleted,
      rollingAccuracy: nextAccuracy,
    );
    final mutable = <String, MasteryProgressV1>{...existing, worldId: next};
    await _persistMasteryProgressV1(mutable);
  }

  static double _resolveSessionAccuracyV1({
    required int? correctCount,
    required int? totalCount,
    required double? previousAccuracy,
  }) {
    final safeTotal = totalCount ?? 0;
    final safeCorrect = correctCount ?? 0;
    if (safeTotal > 0) {
      final ratio = safeCorrect / safeTotal;
      if (ratio.isNaN || ratio.isInfinite) {
        return previousAccuracy ?? 1.0;
      }
      return ratio.clamp(0.0, 1.0);
    }
    return previousAccuracy ?? 1.0;
  }

  static Future<void> _persistMasteryProgressV1(
    Map<String, MasteryProgressV1> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = values.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final payload = <String, Object>{
      'schema_version': _masteryProgressSchemaVersionV1,
      'worlds': sorted
          .map((entry) => entry.value.toJson())
          .toList(growable: false),
    };
    await prefs.setString(_masteryProgressV1Key, jsonEncode(payload));
  }

  static Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static String buildTodayEntryTxnIdV1({
    required String utcDayKey,
    required String cohort,
  }) {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeCohort = _requireAsciiTokenV1(cohort, field: 'cohort');
    return 'today_entry:v1:$safeDay:$safeCohort';
  }

  static String buildDailyDripTxnIdV1({required String utcDayKey}) {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    return 'daily_drip:v1:$safeDay';
  }

  static TodayEntitlementsV1 getTodayEntitlementsV1() =>
      const TodayEntitlementsV1.free();

  static const List<String> _allowedUserCohortsV1 = <String>[
    'beginner',
    'intermediate',
    'advanced',
  ];

  static Future<String> getCurrentCohortV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = (prefs.getString(_userCohortV1Key) ?? 'beginner').trim();
    if (_allowedUserCohortsV1.contains(raw)) {
      return raw;
    }
    return 'beginner';
  }

  static Future<void> setCurrentCohortV1(String cohort) async {
    final safe = _requireAsciiTokenV1(cohort, field: 'cohort');
    if (!_allowedUserCohortsV1.contains(safe)) {
      throw ArgumentError.value(
        cohort,
        'cohort',
        'must be one of ${_allowedUserCohortsV1.join(', ')}',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCohortV1Key, safe);
  }

  static bool isChipsTxnAppliedForTestOrRouterV1(
    List<String> appliedTxnIds,
    String txnId,
  ) {
    return appliedTxnIds.contains(txnId.trim());
  }

  static Future<List<String>> getAppliedChipsTxnIdsV1() async {
    final prefs = await SharedPreferences.getInstance();
    return List<String>.from(
      prefs.getStringList(_chipsAppliedTxnIdsV1Key) ?? const <String>[],
    );
  }

  static Future<ChipsIdempotentTxnResultV1> applyTodayEntryTxnV1({
    required String utcDayKey,
    required String cohort,
  }) {
    return applyChipsTxnIdempotentV1(
      txnId: buildTodayEntryTxnIdV1(utcDayKey: utcDayKey, cohort: cohort),
      deltaChips: -kChipsStartPackCostV1,
      contextTag: 'today_entry',
    );
  }

  static Future<ChipsIdempotentTxnResultV1> applyDailyDripTxnV1({
    required String utcDayKey,
  }) {
    // Small anti-lockout credit: deterministic once per UTC day.
    return applyChipsTxnIdempotentV1(
      txnId: buildDailyDripTxnIdV1(utcDayKey: utcDayKey),
      deltaChips: _dailyDripAmountV1,
      contextTag: 'daily_drip',
    );
  }

  static Future<ChipsIdempotentTxnResultV1> applyChipsTxnIdempotentV1({
    required String txnId,
    required int deltaChips,
    required String contextTag,
  }) {
    final safeTxnId = _requireAsciiTokenV1(txnId, field: 'txnId');
    final safeContext = _requireAsciiTokenV1(contextTag, field: 'contextTag');
    return _runChipsTxnCriticalV1<ChipsIdempotentTxnResultV1>(() async {
      final prefs = await SharedPreferences.getInstance();
      final appliedTxnIds =
          (prefs.getStringList(_chipsAppliedTxnIdsV1Key) ?? const <String>[])
              .toList(growable: true);
      if (appliedTxnIds.contains(safeTxnId)) {
        return ChipsIdempotentTxnResultV1.alreadyApplied(
          txnId: safeTxnId,
          contextTag: safeContext,
          deltaChips: deltaChips,
          snapshot: await getChipsLedgerSnapshotV1(),
        );
      }

      final before = await getChipsLedgerSnapshotV1();
      final mutation = deltaChips >= 0
          ? earnChipsV1(before, amount: deltaChips)
          : spendChipsV1(before, amount: -deltaChips);
      if (mutation.appliedAmount <= 0) {
        return ChipsIdempotentTxnResultV1.notApplied(
          txnId: safeTxnId,
          contextTag: safeContext,
          deltaChips: deltaChips,
          mutation: mutation,
        );
      }

      await _persistChipsLedgerSnapshotV1(mutation.after);
      appliedTxnIds.add(safeTxnId);
      if (appliedTxnIds.length > _chipsAppliedTxnIdsMaxV1) {
        final trimFrom = appliedTxnIds.length - _chipsAppliedTxnIdsMaxV1;
        appliedTxnIds.removeRange(0, trimFrom);
      }
      await prefs.setStringList(_chipsAppliedTxnIdsV1Key, appliedTxnIds);
      return ChipsIdempotentTxnResultV1.applied(
        txnId: safeTxnId,
        contextTag: safeContext,
        deltaChips: deltaChips,
        mutation: mutation,
      );
    });
  }

  static Future<void> appendLeakLogEntryV1({
    required int utcTsMs,
    required String source,
    String? packId,
    String? moduleId,
    String? errorType,
  }) async {
    final safeSource = _requireAsciiTokenV1(source, field: 'source');
    final safePackId = _optionalAsciiTokenV1(packId);
    final safeModuleId = _optionalAsciiTokenV1(moduleId);
    final safeErrorType = _optionalAsciiTokenV1(errorType);
    final entry = LeakLogEntryV1(
      leakId: _buildLeakIdV1(
        utcTsMs: utcTsMs,
        source: safeSource,
        packId: safePackId,
        moduleId: safeModuleId,
        errorType: safeErrorType,
      ),
      utcTsMs: utcTsMs,
      source: safeSource,
      packId: safePackId,
      moduleId: safeModuleId,
      errorType: safeErrorType,
    );
    final prefs = await SharedPreferences.getInstance();
    final list = await getLeakLogEntriesV1();
    final next = <LeakLogEntryV1>[...list, entry];
    if (next.length > leaksLogMaxEntriesV1) {
      next.removeRange(0, next.length - leaksLogMaxEntriesV1);
    }
    await prefs.setString(
      _leaksLogV1Key,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  static Future<List<LeakLogEntryV1>> getLeakLogEntriesV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_leaksLogV1Key);
    if (raw == null || raw.trim().isEmpty) return const <LeakLogEntryV1>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <LeakLogEntryV1>[];
      final entries = <LeakLogEntryV1>[];
      for (final item in decoded) {
        final parsed = LeakLogEntryV1.tryParse(item);
        if (parsed != null) {
          entries.add(parsed);
        }
      }
      return List<LeakLogEntryV1>.unmodifiable(entries);
    } catch (_) {
      return const <LeakLogEntryV1>[];
    }
  }

  static Future<void> appendLeakResolutionEntryV1({
    required String leakId,
    required int resolvedUtcTsMs,
  }) async {
    final safeLeakId = _requireAsciiTokenV1(leakId, field: 'leakId');
    final prefs = await SharedPreferences.getInstance();
    final existing = await getLeakResolutionLogEntriesV1();
    final next = <LeakResolutionLogEntryV1>[
      ...existing,
      LeakResolutionLogEntryV1(
        leakId: safeLeakId,
        resolvedUtcTsMs: resolvedUtcTsMs,
      ),
    ];
    if (next.length > leaksResolutionLogMaxEntriesV1) {
      next.removeRange(0, next.length - leaksResolutionLogMaxEntriesV1);
    }
    await prefs.setString(
      _leaksResolutionLogV1Key,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  static Future<void> markGauntletCompletedV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeCohort = _requireAsciiTokenV1(cohort, field: 'cohort');
    final safeGauntletId = _requireAsciiTokenV1(
      gauntletId,
      field: 'gauntletId',
    );
    final prefs = await SharedPreferences.getInstance();
    final existing = await getGauntletCompletionLogEntriesV1();
    final next = <GauntletCompletionLogEntryV1>[
      ...existing,
      GauntletCompletionLogEntryV1(
        utcDayKey: safeDay,
        cohort: safeCohort,
        gauntletId: safeGauntletId,
      ),
    ];
    if (next.length > gauntletCompletionLogMaxEntriesV1) {
      next.removeRange(0, next.length - gauntletCompletionLogMaxEntriesV1);
    }
    await prefs.setString(
      _gauntletCompletionLogV1Key,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
    await _evaluateCohortPromotionAfterGauntletCompletionV1(next);
  }

  static Future<bool> isGauntletCompletedV1({
    required String utcDayKey,
    required String cohort,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeCohort = _requireAsciiTokenV1(cohort, field: 'cohort');
    final entries = await getGauntletCompletionLogEntriesV1();
    for (final entry in entries.reversed) {
      if (entry.utcDayKey == safeDay && entry.cohort == safeCohort) {
        return true;
      }
    }
    return false;
  }

  static Future<List<GauntletCompletionLogEntryV1>>
  getGauntletCompletionLogEntriesV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gauntletCompletionLogV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <GauntletCompletionLogEntryV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <GauntletCompletionLogEntryV1>[];
      final entries = <GauntletCompletionLogEntryV1>[];
      for (final item in decoded) {
        final parsed = GauntletCompletionLogEntryV1.tryParse(item);
        if (parsed != null) entries.add(parsed);
      }
      return List<GauntletCompletionLogEntryV1>.unmodifiable(entries);
    } catch (_) {
      return const <GauntletCompletionLogEntryV1>[];
    }
  }

  static Future<List<CohortPromotionEventEntryV1>>
  getCohortPromotionEventEntriesV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cohortPromotionEventV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <CohortPromotionEventEntryV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <CohortPromotionEventEntryV1>[];
      final entries = <CohortPromotionEventEntryV1>[];
      for (final item in decoded) {
        final parsed = CohortPromotionEventEntryV1.tryParse(item);
        if (parsed != null) entries.add(parsed);
      }
      return List<CohortPromotionEventEntryV1>.unmodifiable(entries);
    } catch (_) {
      return const <CohortPromotionEventEntryV1>[];
    }
  }

  static Future<CohortPromotionEventEntryV1?> consumeLatestPromotionEventV1({
    required String utcDayKey,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final prefs = await SharedPreferences.getInstance();
    final events = await getCohortPromotionEventEntriesV1();
    final consumedIds = <String>{
      ...(prefs.getStringList(_cohortPromotionConsumedIdsV1Key) ??
          const <String>[]),
    };
    CohortPromotionEventEntryV1? match;
    for (final event in events.reversed) {
      if (event.utcDayKey != safeDay) continue;
      if (consumedIds.contains(event.eventId)) continue;
      match = event;
      break;
    }
    if (match == null) return null;
    final nextConsumed = <String>[...consumedIds, match.eventId]..sort();
    if (nextConsumed.length > _cohortPromotionConsumedIdsMaxV1) {
      nextConsumed.removeRange(
        0,
        nextConsumed.length - _cohortPromotionConsumedIdsMaxV1,
      );
    }
    await prefs.setStringList(_cohortPromotionConsumedIdsV1Key, nextConsumed);
    return match;
  }

  static Future<void> _evaluateCohortPromotionAfterGauntletCompletionV1(
    List<GauntletCompletionLogEntryV1> completionEntries,
  ) async {
    final current = await getCurrentCohortV1();
    if (current != 'beginner') {
      return;
    }
    if (completionEntries.length < _cohortPromotionMinCompletionsV1) {
      return;
    }
    final latest = completionEntries.last;
    await _appendCohortPromotionEventV1(
      utcDayKey: latest.utcDayKey,
      fromCohort: 'beginner',
      toCohort: 'intermediate',
    );
    await setCurrentCohortV1('intermediate');
  }

  static Future<void> _appendCohortPromotionEventV1({
    required String utcDayKey,
    required String fromCohort,
    required String toCohort,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeFrom = _requireAsciiTokenV1(fromCohort, field: 'fromCohort');
    final safeTo = _requireAsciiTokenV1(toCohort, field: 'toCohort');
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCohortPromotionEventEntriesV1();
    final next = <CohortPromotionEventEntryV1>[
      ...existing,
      CohortPromotionEventEntryV1(
        utcDayKey: safeDay,
        fromCohort: safeFrom,
        toCohort: safeTo,
      ),
    ];
    if (next.length > _cohortPromotionEventMaxEntriesV1) {
      next.removeRange(0, next.length - _cohortPromotionEventMaxEntriesV1);
    }
    await prefs.setString(
      _cohortPromotionEventV1Key,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  static Future<int> getGauntletStepIndexV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeCohort = _requireAsciiTokenV1(cohort, field: 'cohort');
    final safeGauntletId = _requireAsciiTokenV1(
      gauntletId,
      field: 'gauntletId',
    );
    final entries = await getGauntletStepProgressEntriesV1();
    for (final entry in entries.reversed) {
      if (entry.utcDayKey == safeDay &&
          entry.cohort == safeCohort &&
          entry.gauntletId == safeGauntletId) {
        return entry.currentStepIndex;
      }
    }
    return 0;
  }

  static Future<void> advanceGauntletStepV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
    required int currentStepIndex,
  }) {
    return _appendGauntletStepProgressEntryV1(
      utcDayKey: utcDayKey,
      cohort: cohort,
      gauntletId: gauntletId,
      currentStepIndex: currentStepIndex + 1,
    );
  }

  static Future<void> resetGauntletStepV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
  }) {
    return _appendGauntletStepProgressEntryV1(
      utcDayKey: utcDayKey,
      cohort: cohort,
      gauntletId: gauntletId,
      currentStepIndex: 0,
    );
  }

  static Future<void> _appendGauntletStepProgressEntryV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
    required int currentStepIndex,
  }) async {
    final safeDay = _requireAsciiTokenV1(utcDayKey, field: 'utcDayKey');
    final safeCohort = _requireAsciiTokenV1(cohort, field: 'cohort');
    final safeGauntletId = _requireAsciiTokenV1(
      gauntletId,
      field: 'gauntletId',
    );
    if (currentStepIndex < 0) {
      throw ArgumentError.value(
        currentStepIndex,
        'currentStepIndex',
        'must be >= 0',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    final existing = await getGauntletStepProgressEntriesV1();
    final next = <GauntletStepProgressEntryV1>[
      ...existing,
      GauntletStepProgressEntryV1(
        utcDayKey: safeDay,
        cohort: safeCohort,
        gauntletId: safeGauntletId,
        currentStepIndex: currentStepIndex,
      ),
    ];
    if (next.length > gauntletStepProgressMaxEntriesV1) {
      next.removeRange(0, next.length - gauntletStepProgressMaxEntriesV1);
    }
    await prefs.setString(
      _gauntletStepProgressV1Key,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  static Future<List<GauntletStepProgressEntryV1>>
  getGauntletStepProgressEntriesV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gauntletStepProgressV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <GauntletStepProgressEntryV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <GauntletStepProgressEntryV1>[];
      final entries = <GauntletStepProgressEntryV1>[];
      for (final item in decoded) {
        final parsed = GauntletStepProgressEntryV1.tryParse(item);
        if (parsed != null) entries.add(parsed);
      }
      return List<GauntletStepProgressEntryV1>.unmodifiable(entries);
    } catch (_) {
      return const <GauntletStepProgressEntryV1>[];
    }
  }

  static Future<List<LeakResolutionLogEntryV1>>
  getLeakResolutionLogEntriesV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_leaksResolutionLogV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <LeakResolutionLogEntryV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <LeakResolutionLogEntryV1>[];
      final entries = <LeakResolutionLogEntryV1>[];
      for (final item in decoded) {
        final parsed = LeakResolutionLogEntryV1.tryParse(item);
        if (parsed != null) entries.add(parsed);
      }
      return List<LeakResolutionLogEntryV1>.unmodifiable(entries);
    } catch (_) {
      return const <LeakResolutionLogEntryV1>[];
    }
  }

  static Future<bool> isLeaksDueForDayV1({required String utcDayKey}) async {
    final queue = await getLeaksQueueForDayV1(utcDayKey: utcDayKey);
    return queue.isNotEmpty;
  }

  static Future<List<LeakLogEntryV1>> getLeaksQueueForDayV1({
    required String utcDayKey,
  }) async {
    final all = await getLeakLogEntriesV1();
    final resolutions = await getLeakResolutionLogEntriesV1();
    return computeLeaksQueueForDayV1(
      all,
      utcDayKey: utcDayKey,
      dailyCap: leaksDailyCapV1,
      resolutionEntries: resolutions,
    );
  }

  static List<LeakLogEntryV1> computeLeaksQueueForDayV1(
    List<LeakLogEntryV1> entries, {
    required String utcDayKey,
    int dailyCap = leaksDailyCapV1,
    List<LeakResolutionLogEntryV1> resolutionEntries =
        const <LeakResolutionLogEntryV1>[],
  }) {
    final endExclusive = _utcDayEndExclusiveMsV1(utcDayKey);
    final latestResolutionByLeakId = <String, int>{};
    for (final resolution in resolutionEntries) {
      final current = latestResolutionByLeakId[resolution.leakId];
      if (current == null || resolution.resolvedUtcTsMs > current) {
        latestResolutionByLeakId[resolution.leakId] =
            resolution.resolvedUtcTsMs;
      }
    }
    final sorted =
        entries
            .where((e) => e.utcTsMs < endExclusive)
            .where((e) {
              final resolvedTs = latestResolutionByLeakId[e.leakId];
              if (resolvedTs == null) return true;
              // Deterministic v1 hardening: any later resolution suppresses the leak.
              return resolvedTs <= e.utcTsMs;
            })
            .toList(growable: true)
          ..sort((a, b) {
            final tsCmp = a.utcTsMs.compareTo(b.utcTsMs);
            if (tsCmp != 0) return tsCmp;
            return a.leakId.compareTo(b.leakId);
          });
    if (dailyCap <= 0) return const <LeakLogEntryV1>[];
    if (sorted.length <= dailyCap) {
      return List<LeakLogEntryV1>.unmodifiable(sorted);
    }
    return List<LeakLogEntryV1>.unmodifiable(sorted.take(dailyCap));
  }

  static Future<ChipsLedgerSnapshotV1> getChipsLedgerSnapshotV1() async {
    final prefs = await SharedPreferences.getInstance();
    return ChipsLedgerSnapshotV1(
      balance: prefs.getInt(_chipsBalanceV1Key) ?? 0,
      earnedTotal: prefs.getInt(_chipsEarnedTotalV1Key) ?? 0,
      spentTotal: prefs.getInt(_chipsSpentTotalV1Key) ?? 0,
    );
  }

  static Future<void> _persistChipsLedgerSnapshotV1(
    ChipsLedgerSnapshotV1 snapshot,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chipsBalanceV1Key, snapshot.balance);
    await prefs.setInt(_chipsEarnedTotalV1Key, snapshot.earnedTotal);
    await prefs.setInt(_chipsSpentTotalV1Key, snapshot.spentTotal);
  }

  static Future<ChipsLedgerMutationV1> spendChipsForSessionStartV1() async {
    final snapshot = await getChipsLedgerSnapshotV1();
    final mutation = spendChipsV1(snapshot, amount: kChipsStartPackCostV1);
    if (mutation.appliedAmount > 0) {
      await _persistChipsLedgerSnapshotV1(mutation.after);
    }
    return mutation;
  }

  static Future<T> _runChipsTxnCriticalV1<T>(
    Future<T> Function() action,
  ) async {
    final previous = _chipsTxnTailV1;
    final completer = Completer<void>();
    _chipsTxnTailV1 = completer.future;
    await previous.catchError((_) {});
    try {
      return await action();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  static String _requireAsciiTokenV1(String value, {required String field}) {
    final trimmed = value.trim();
    if (!RegExp(r'^[A-Za-z0-9:_-]+$').hasMatch(trimmed)) {
      throw ArgumentError.value(
        value,
        field,
        'must be ASCII token [A-Za-z0-9:_-]+',
      );
    }
    return trimmed;
  }

  static String? _optionalAsciiTokenV1(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return _requireAsciiTokenV1(trimmed, field: 'optional');
  }

  static String _buildLeakIdV1({
    required int utcTsMs,
    required String source,
    String? packId,
    String? moduleId,
    String? errorType,
  }) {
    final pack = packId ?? '-';
    final module = moduleId ?? '-';
    final error = errorType ?? '-';
    return 'leak:v1:$utcTsMs:$source:$pack:$module:$error';
  }

  static int _utcDayEndExclusiveMsV1(String utcDayKey) {
    final day = _parseUtcDayKeyV1(utcDayKey);
    return day.add(const Duration(days: 1)).millisecondsSinceEpoch;
  }

  static DateTime _parseUtcDayKeyV1(String utcDayKey) {
    final trimmed = utcDayKey.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      throw ArgumentError.value(utcDayKey, 'utcDayKey', 'expected YYYY-MM-DD');
    }
    final parsed = DateTime.tryParse('${trimmed}T00:00:00Z');
    if (parsed == null) {
      throw ArgumentError.value(utcDayKey, 'utcDayKey', 'invalid UTC day key');
    }
    return parsed.toUtc();
  }

  static Future<ChipsLedgerMutationV1> earnChipsForSessionCompletionV1({
    required bool isCheckpoint,
  }) async {
    final snapshot = await getChipsLedgerSnapshotV1();
    final reward = chipsCompletionRewardForSessionV1(
      isCheckpoint: isCheckpoint,
    );
    final mutation = earnChipsV1(snapshot, amount: reward);
    if (mutation.appliedAmount > 0) {
      await _persistChipsLedgerSnapshotV1(mutation.after);
    }
    return mutation;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<void> checkInStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastVisitKey);
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    if (lastDateStr == todayStr) return;

    var currentStreak = prefs.getInt(_streakKey) ?? 0;
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final difference = now.difference(lastDate).inDays;
      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    await prefs.setInt(_streakKey, currentStreak);
    await prefs.setString(_lastVisitKey, now.toIso8601String());
  }

  static Future<void> markWorld1DailyCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_world1DailyCompletedDateKey, _todayYmd());
  }

  static Future<bool> isWorld1DailyCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_world1DailyCompletedDateKey) == _todayYmd();
  }

  static Future<void> setLessonFocusLabel(String focusLabel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lessonFocusLabelKey,
      focusLabel.trim().toLowerCase(),
    );
  }

  static Future<String?> getLessonFocusLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lessonFocusLabelKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim().toLowerCase();
  }

  static Future<void> clearLessonFocusLabel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lessonFocusLabelKey);
  }

  static Future<bool> isIntakeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_intakeCompletedKey) ?? false;
  }

  static Future<void> saveIntakeProfile(Map<String, Object?> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_intakeProfileKey, jsonEncode(profile));
    await prefs.setBool(_intakeCompletedKey, true);
    if (!prefs.containsKey(_freeRollRemainingV1Key)) {
      await prefs.setInt(_freeRollRemainingV1Key, freeRollInitialSessions);
    }
  }

  static Future<Map<String, Object?>?> getIntakeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_intakeProfileKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
    return null;
  }

  static Future<void> scheduleFocusReviewIn24h(String focusLabel) async {
    final normalized = focusLabel.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final nextReviewAt = _now().add(const Duration(hours: 24));
    await prefs.setString(
      '$_nextReviewAtPrefix$normalized',
      nextReviewAt.toIso8601String(),
    );
  }

  static Future<DateTime?> getFocusReviewAt(String focusLabel) async {
    final normalized = focusLabel.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_nextReviewAtPrefix$normalized');
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<bool> isFocusReviewDue(String focusLabel) async {
    final reviewAt = await getFocusReviewAt(focusLabel);
    if (reviewAt == null) return false;
    return !reviewAt.isAfter(_now().toUtc());
  }

  static Future<void> clearFocusReview(String focusLabel) async {
    final normalized = focusLabel.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_nextReviewAtPrefix$normalized');
  }

  static Future<List<ReviewRefV1>> getReviewQueueForPackV1(
    String packId,
  ) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return const <ReviewRefV1>[];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_reviewQueuePrefix$normalized');
    if (raw == null || raw.trim().isEmpty) return const <ReviewRefV1>[];

    final maxStepCount = _reviewQueueMaxStepCountForPackV1(normalized);
    final parsed = <ReviewRefV1>[];
    final seen = <int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <ReviewRefV1>[];
      }
      for (final item in decoded) {
        final ref = ReviewRefV1.tryParse(item, fallbackPackId: normalized);
        if (ref == null) continue;
        if (ref.packId != normalized) continue;
        if (maxStepCount != null && ref.stepIndex >= maxStepCount) continue;
        if (!seen.add(ref.stepIndex)) continue;
        parsed.add(ref);
      }
    } catch (_) {
      return const <ReviewRefV1>[];
    }

    if (parsed.isEmpty) {
      await prefs.remove('$_reviewQueuePrefix$normalized');
      return const <ReviewRefV1>[];
    }

    // Canonicalize persisted payload after read (dedupe + bounds filtering).
    await prefs.setString(
      '$_reviewQueuePrefix$normalized',
      jsonEncode(parsed.map((e) => e.toJson()).toList(growable: false)),
    );
    return List<ReviewRefV1>.unmodifiable(parsed);
  }

  static Future<void> addReviewRefForPackV1(
    String packId,
    ReviewRefV1 ref,
  ) async {
    final normalized = packId.trim().toLowerCase();
    final normalizedRefPack = ref.packId.trim().toLowerCase();
    if (normalized.isEmpty || normalizedRefPack.isEmpty) return;
    if (normalizedRefPack != normalized) return;
    if (ref.stepIndex < 0) return;
    final maxStepCount = _reviewQueueMaxStepCountForPackV1(normalized);
    if (maxStepCount != null && ref.stepIndex >= maxStepCount) return;

    final existing = await getReviewQueueForPackV1(normalized);
    if (existing.any((e) => e.stepIndex == ref.stepIndex)) {
      return;
    }
    final next = <ReviewRefV1>[
      ReviewRefV1(packId: normalized, stepIndex: ref.stepIndex),
      ...existing,
    ];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_reviewQueuePrefix$normalized',
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  static Future<void> clearReviewQueueForPackV1(String packId) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_reviewQueuePrefix$normalized');
  }

  static Future<bool> hasReviewQueueForPackV1(String packId) async {
    final queue = await getReviewQueueForPackV1(packId);
    return queue.isNotEmpty;
  }

  static Future<CheckpointProgressUpdateV1> recordSessionForCheckpointV1({
    required String sessionId,
    required String worldId,
    List<String> errorClasses = const <String>[],
  }) async {
    final normalizedSessionId = sessionId.trim().toLowerCase();
    final normalizedWorldId = worldId.trim().toLowerCase();
    if (normalizedSessionId.isEmpty || normalizedWorldId.isEmpty) {
      return getCheckpointProgressStateV1();
    }
    final prefs = await SharedPreferences.getInstance();
    final previousCount = prefs.getInt(_checkpointSessionsSinceLastV1Key) ?? 0;
    final nextCount = previousCount + 1;
    final checkpointPending = nextCount >= checkpointEverySessionsV1;
    final storedCount = checkpointPending ? 0 : nextCount;
    await prefs.setInt(_checkpointSessionsSinceLastV1Key, storedCount);
    await prefs.setBool(_checkpointPendingV1Key, checkpointPending);

    final record = CheckpointSessionRecordV1(
      sessionId: normalizedSessionId,
      worldId: normalizedWorldId,
      errorClassCounts: _countErrorClassesV1(errorClasses),
    );
    final history = await _getCheckpointHistoryV1();
    final nextHistory = <CheckpointSessionRecordV1>[...history, record];
    if (nextHistory.length > checkpointHistoryWindowV1) {
      nextHistory.removeRange(
        0,
        nextHistory.length - checkpointHistoryWindowV1,
      );
    }
    await _setCheckpointHistoryV1(nextHistory);

    return CheckpointProgressUpdateV1(
      completedSessionsSinceLastCheckpoint: storedCount,
      checkpointPending: checkpointPending,
      topErrorClasses: _topCheckpointErrorClassesV1(nextHistory),
    );
  }

  static Future<CheckpointProgressUpdateV1>
  getCheckpointProgressStateV1() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_checkpointSessionsSinceLastV1Key) ?? 0;
    final pending = prefs.getBool(_checkpointPendingV1Key) ?? false;
    final history = await _getCheckpointHistoryV1();
    return CheckpointProgressUpdateV1(
      completedSessionsSinceLastCheckpoint: count < 0 ? 0 : count,
      checkpointPending: pending,
      topErrorClasses: _topCheckpointErrorClassesV1(history),
    );
  }

  static Future<void> clearCheckpointPendingV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkpointPendingV1Key, false);
  }

  static Future<String> getNextPackConsideringCheckpointV1(
    String currentPackId,
  ) async {
    final normalizedCurrent = currentPackId.trim().toLowerCase();
    final state = await getCheckpointProgressStateV1();
    if (state.checkpointPending && normalizedCurrent != checkpointPackIdV1) {
      await setCheckpointSeedForPackV1(
        checkpointPackIdV1,
        state.topErrorClasses,
      );
      return checkpointPackIdV1;
    }
    return getNextSpinePackToRunV1();
  }

  static Future<void> setCheckpointSeedForPackV1(
    String packId,
    List<String> errorClasses,
  ) async {
    final normalizedPackId = packId.trim().toLowerCase();
    if (normalizedPackId.isEmpty) return;
    final normalizedErrors = <String>[];
    final seen = <String>{};
    for (final raw in errorClasses) {
      final normalized = raw.trim().toLowerCase();
      if (normalized.isEmpty || normalized == 'none') continue;
      if (!seen.add(normalized)) continue;
      normalizedErrors.add(normalized);
      if (normalizedErrors.length >= checkpointTopErrorClassesLimitV1) break;
    }
    final bounded = normalizedErrors.take(checkpointTopErrorClassesLimitV1);
    final payload = jsonEncode(bounded.toList(growable: false));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_checkpointSeedPrefixV1$normalizedPackId', payload);
  }

  static Future<List<String>> getCheckpointSeedForPackV1(String packId) async {
    final normalizedPackId = packId.trim().toLowerCase();
    if (normalizedPackId.isEmpty) return const <String>[];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_checkpointSeedPrefixV1$normalizedPackId');
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <String>[];
      return decoded
          .map((value) => value.toString().trim().toLowerCase())
          .where((value) => value.isNotEmpty && value != 'none')
          .toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  static Future<List<String>> getCheckpointTopErrorClassesV1() async {
    final history = await _getCheckpointHistoryV1();
    return _topCheckpointErrorClassesV1(history);
  }

  static Future<List<CheckpointSessionRecordV1>>
  _getCheckpointHistoryV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checkpointHistoryV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return const <CheckpointSessionRecordV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <CheckpointSessionRecordV1>[];
      }
      final parsed = <CheckpointSessionRecordV1>[];
      for (final item in decoded) {
        final record = CheckpointSessionRecordV1.tryParse(item);
        if (record == null) continue;
        parsed.add(record);
      }
      return List<CheckpointSessionRecordV1>.unmodifiable(parsed);
    } catch (_) {
      return const <CheckpointSessionRecordV1>[];
    }
  }

  static Future<void> _setCheckpointHistoryV1(
    List<CheckpointSessionRecordV1> history,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = jsonEncode(
      history.map((record) => record.toJson()).toList(growable: false),
    );
    await prefs.setString(_checkpointHistoryV1Key, serialized);
  }

  static Map<String, int> _countErrorClassesV1(List<String> rawClasses) {
    final counts = <String, int>{};
    for (final raw in rawClasses) {
      final normalized = raw.trim().toLowerCase();
      if (normalized.isEmpty || normalized == 'none') continue;
      counts.update(normalized, (value) => value + 1, ifAbsent: () => 1);
    }
    final keys = counts.keys.toList(growable: false)..sort();
    return <String, int>{for (final key in keys) key: counts[key]!};
  }

  static List<String> _topCheckpointErrorClassesV1(
    List<CheckpointSessionRecordV1> history,
  ) {
    final aggregate = <String, int>{};
    for (final record in history) {
      for (final entry in record.errorClassCounts.entries) {
        aggregate.update(
          entry.key,
          (value) => value + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }
    final ranked = aggregate.entries.toList(growable: false)
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });
    return ranked
        .take(checkpointTopErrorClassesLimitV1)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  static Future<void> setWorldMasteryForPackV1(
    String packId,
    WorldMasteryLevelV1 level,
  ) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_worldMasteryPrefix$normalized', level.name);
  }

  static Future<WorldMasteryLevelV1?> getWorldMasteryForPackV1(
    String packId,
  ) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_worldMasteryPrefix$normalized');
    if (raw == null || raw.trim().isEmpty) return null;
    final normalizedRaw = raw.trim().toLowerCase();
    for (final level in WorldMasteryLevelV1.values) {
      if (level.name == normalizedRaw) return level;
    }
    return null;
  }

  static Future<void> setSkillTagsForPackV1(
    String packId,
    List<String> tags,
  ) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final cleaned = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .take(3)
        .toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_skillTagsPrefix$normalized', jsonEncode(cleaned));
  }

  static Future<List<String>> getSkillTagsForPackV1(String packId) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return const <String>[];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_skillTagsPrefix$normalized');
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <String>[];
      return decoded
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .take(3)
          .toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  static Future<void> seedSkillTagsForPackFromRulesV1(String packId) async {
    final tags = skillTagsForPackIdV1(packId);
    if (tags.isEmpty) return;
    await setSkillTagsForPackV1(packId, tags);
  }

  static int? _reviewQueueMaxStepCountForPackV1(String normalizedPackId) {
    final pack = campaign_registry.kCampaignPacksV1[normalizedPackId];
    return pack?.length;
  }

  static DateTime nowUtc() => _now();

  static String todayYmd() => _todayYmd();

  static Future<void> setSkillBandV1(String band) async {
    final normalized = band.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skillBandV1Key, normalized);
  }

  static Future<String?> getSkillBandV1() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_skillBandV1Key);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim().toLowerCase();
  }

  static Future<void> setPlacementScoreV1(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_placementScoreV1Key, score.clamp(0, 3));
  }

  static Future<int?> getPlacementScoreV1() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_placementScoreV1Key)) return null;
    return prefs.getInt(_placementScoreV1Key);
  }

  static Future<int> getFreeRollRemainingV1() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_freeRollRemainingV1Key);
    if (current == null) {
      await prefs.setInt(_freeRollRemainingV1Key, freeRollInitialSessions);
      return freeRollInitialSessions;
    }
    return current.clamp(0, freeRollInitialSessions);
  }

  static Future<int> decrementFreeRollRemainingV1() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFreeRollRemainingV1();
    final next = (current - 1).clamp(0, freeRollInitialSessions);
    await prefs.setInt(_freeRollRemainingV1Key, next);
    return next;
  }

  static Future<bool> isFreeRollAvailable() async {
    final remaining = await getFreeRollRemainingV1();
    return remaining > 0;
  }

  static String _todayYmd() {
    final now = _now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static DateTime _now() =>
      (debugNowOverride?.call() ?? DateTime.now()).toUtc();

  static int bankrollCostForSessionKind(String sessionKind) {
    switch (sessionKind) {
      case 'review':
        return bankrollCostReviewSession;
      case 'checkpoint':
        return bankrollCostCheckpoint;
      default:
        return bankrollCostCoreSession;
    }
  }

  static int bankrollRakebackForOutcome({
    required int cost,
    required int correctCount,
    required int totalCount,
  }) {
    if (cost <= 0 || totalCount <= 0) {
      return 0;
    }
    final mistakes = (totalCount - correctCount).clamp(0, totalCount);
    int percent;
    if (mistakes == 0) {
      percent = 50;
    } else if (mistakes == 1) {
      percent = 25;
    } else {
      percent = 10;
    }
    final value = (cost * percent) ~/ 100;
    return value > 0 ? value : 1;
  }

  static Future<void> setBankrollBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    await _ensureBankrollInitialized(prefs, now);
    await prefs.setInt(_bankrollBalanceKey, balance.clamp(0, bankrollCap));
    await prefs.setString(_bankrollLastRegenAtKey, now.toIso8601String());
  }

  static Future<int> getBankrollBalance() async {
    final status = await getBankrollStatus();
    return status.balance;
  }

  static Future<int> getSpineBankrollBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_campaignBankrollBalanceV1Key)) {
      await prefs.setInt(_campaignBankrollBalanceV1Key, bankrollCap);
    }
    return prefs.getInt(_campaignBankrollBalanceV1Key) ?? bankrollCap;
  }

  static Future<int> applySpineBankrollDelta(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_campaignBankrollBalanceV1Key)) {
      await prefs.setInt(_campaignBankrollBalanceV1Key, bankrollCap);
    }
    final before = prefs.getInt(_campaignBankrollBalanceV1Key) ?? bankrollCap;
    final after = (before + delta).clamp(0, bankrollCap);
    await prefs.setInt(_campaignBankrollBalanceV1Key, after);
    return after;
  }

  static Future<void> setCampaignBankrollBalanceV1(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _campaignBankrollBalanceV1Key,
      balance.clamp(0, bankrollCap),
    );
  }

  static Future<int> getCampaignBankrollBalanceV1() async {
    return getSpineBankrollBalance();
  }

  static Future<bool> isCampaignBustedV1() async {
    final balance = await getSpineBankrollBalance();
    return balance <= 0;
  }

  static Future<bool> canUseBackerNowV1({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final ref = (now ?? _now()).toUtc();
    final raw = prefs.getString(_campaignBackerLastUsedAtV1Key);
    if (raw == null || raw.trim().isEmpty) return true;
    final last = DateTime.tryParse(raw)?.toUtc();
    if (last == null) return true;
    return ref.difference(last).inMinutes >= campaignBackerCooldownMinutesV1;
  }

  static Future<int> backerCooldownRemainingMinutesV1({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final ref = (now ?? _now()).toUtc();
    final raw = prefs.getString(_campaignBackerLastUsedAtV1Key);
    if (raw == null || raw.trim().isEmpty) return 0;
    final last = DateTime.tryParse(raw)?.toUtc();
    if (last == null) return 0;
    final usedAgo = ref.difference(last).inMinutes;
    final remain = campaignBackerCooldownMinutesV1 - usedAgo;
    return remain > 0 ? remain : 0;
  }

  static Future<String> backerCooldownRemainingLabelV1({DateTime? now}) async {
    final remain = await backerCooldownRemainingMinutesV1(now: now);
    if (remain <= 0) return 'Backer ready';
    return 'Backer cooldown: ${remain}m';
  }

  static Future<int> backerRefillCampaignV1({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final ref = (now ?? _now()).toUtc();
    final canUse = await canUseBackerNowV1(now: ref);
    final before = await getSpineBankrollBalance();
    if (!canUse) {
      return before;
    }
    final after = (before + campaignBackerRefillAmountV1).clamp(0, bankrollCap);
    await prefs.setInt(_campaignBankrollBalanceV1Key, after);
    await prefs.setString(
      _campaignBackerLastUsedAtV1Key,
      ref.toIso8601String(),
    );
    return after;
  }

  static Future<void> setSpineRankV1(int rank) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _spineRankV1Key,
      rank.clamp(spineRankFish, spineRankShark),
    );
  }

  static Future<int> getSpineRankV1() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_spineRankV1Key);
    if (value == null) {
      return spineRankFish;
    }
    return value.clamp(spineRankFish, spineRankShark);
  }

  static int resolveSpineRankFromQuality({
    required int correctCount,
    required int totalCount,
  }) {
    if (totalCount <= 0) {
      return spineRankFish;
    }
    final percent = ((correctCount * 100) / totalCount).round();
    if (percent >= 80) {
      return spineRankShark;
    }
    if (percent >= 50) {
      return spineRankGrinder;
    }
    return spineRankFish;
  }

  static String spineRankLabel(int rank) {
    switch (rank) {
      case spineRankShark:
        return 'Shark';
      case spineRankGrinder:
        return 'Grinder';
      default:
        return 'Fish';
    }
  }

  static int _campaignWorldsCompletedV1(Set<String> completedPackIds) {
    var count = 0;
    for (var world = 1; world <= 10; world++) {
      if (isCampaignWorldDoneByCompletedSetV1(
        world: world,
        completedPackIds: completedPackIds,
      )) {
        count++;
      }
    }
    return count;
  }

  static int campaignRankIndexFromProgressV1({
    required int worldsCompleted,
    required int completedHands,
  }) {
    final worlds = worldsCompleted < 0 ? 0 : worldsCompleted;
    final hands = completedHands < 0 ? 0 : completedHands;
    if (worlds >= _campaignRankWorld5UnlockV1) return campaignRankShark;
    if (worlds >= _campaignRankWorld4UnlockV1) return campaignRankCrusher;
    if (worlds >= _campaignRankWorld3UnlockV1) return campaignRankRegular;
    if (worlds >= _campaignRankWorld2UnlockV1) return campaignRankGrinder;
    if (worlds >= _campaignRankWorld1UnlockV1) return campaignRankFish;
    if (hands >= 10) return campaignRankFish;
    return campaignRankTadpole;
  }

  static String campaignRankLabelForIndexV1(int index) {
    switch (index) {
      case campaignRankShark:
        return 'Shark';
      case campaignRankCrusher:
        return 'Crusher';
      case campaignRankRegular:
        return 'Regular';
      case campaignRankGrinder:
        return 'Angler';
      case campaignRankFish:
        return 'Minnow';
      default:
        return 'Fish';
    }
  }

  static bool _campaignRankIsMaxIndexV1(int rankIndex) {
    return rankIndex >= campaignRankShark;
  }

  static int _campaignNextRankWorldUnlockV1(int rankIndex) {
    switch (rankIndex) {
      case campaignRankTadpole:
        return _campaignRankWorld1UnlockV1;
      case campaignRankFish:
        return _campaignRankWorld2UnlockV1;
      case campaignRankGrinder:
        return _campaignRankWorld3UnlockV1;
      case campaignRankRegular:
        return _campaignRankWorld4UnlockV1;
      default:
        return _campaignRankWorld5UnlockV1;
    }
  }

  static Future<int> campaignRankIndexV1() async {
    final completed = await _getSpineCompletedPacksV1();
    final worldsCompleted = _campaignWorldsCompletedV1(completed);
    final completedHands = await completedHandsInCampaignV1();
    return campaignRankIndexFromProgressV1(
      worldsCompleted: worldsCompleted,
      completedHands: completedHands,
    );
  }

  static Future<String> campaignRankLabelV1() async {
    final index = await campaignRankIndexV1();
    return campaignRankLabelForIndexV1(index);
  }

  static Future<String> campaignNextRankLabelV1() async {
    final index = await campaignRankIndexV1();
    if (_campaignRankIsMaxIndexV1(index)) {
      return '';
    }
    return campaignRankLabelForIndexV1(index + 1);
  }

  static Future<String> campaignRankProgressLabelV1() async {
    final completed = await _getSpineCompletedPacksV1();
    final worldsCompleted = _campaignWorldsCompletedV1(completed).clamp(0, 10);
    final rankLabel = await campaignRankLabelV1();
    return 'Rank: $rankLabel ($worldsCompleted/10 worlds)';
  }

  static Future<String> campaignNextRankUnlockHintV1() async {
    final completed = await _getSpineCompletedPacksV1();
    final worldsCompleted = _campaignWorldsCompletedV1(completed);
    final completedHands = await completedHandsInCampaignV1();
    final rankIndex = campaignRankIndexFromProgressV1(
      worldsCompleted: worldsCompleted,
      completedHands: completedHands,
    );
    if (_campaignRankIsMaxIndexV1(rankIndex)) {
      return '';
    }
    final nextLabel = campaignRankLabelForIndexV1(rankIndex + 1);
    final unlockWorld = _campaignNextRankWorldUnlockV1(rankIndex);
    return 'Next: $nextLabel at World $unlockWorld';
  }

  static int resolveSpineCalibrationBand({
    required int qualityScore,
    required int mistakesCount,
  }) {
    final quality = qualityScore.clamp(0, 10);
    final mistakes = mistakesCount < 0 ? 0 : mistakesCount;
    if (quality <= 4 || mistakes >= 6) {
      return spineCalibrationBandBeginner;
    }
    if (quality >= 8 && mistakes <= 2) {
      return spineCalibrationBandAdvanced;
    }
    return spineCalibrationBandIntermediate;
  }

  static Future<void> setSpineCalibrationBandV1(int band) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _spineCalibrationBandV1Key,
      band.clamp(spineCalibrationBandBeginner, spineCalibrationBandAdvanced),
    );
  }

  static Future<int?> getSpineCalibrationBandV1() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_spineCalibrationBandV1Key)) {
      return null;
    }
    final value = prefs.getInt(_spineCalibrationBandV1Key);
    if (value == null) return null;
    return value.clamp(
      spineCalibrationBandBeginner,
      spineCalibrationBandAdvanced,
    );
  }

  static Future<void> markSpineCalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_spineCalibrationCompletedV1Key, true);
  }

  static Future<bool> isSpineCalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_spineCalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld2CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world2CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld2CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world2CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld3CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world3CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld3CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world3CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld4CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world4CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld4CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world4CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld5CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world5CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld5CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world5CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld6CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world6CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld6CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world6CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld7CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world7CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld7CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world7CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld8CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world8CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld8CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world8CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld9CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world9CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld9CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world9CalibrationCompletedV1Key) ?? false;
  }

  static Future<void> markWorld10CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_world10CalibrationCompletedV1Key, true);
  }

  static Future<bool> isWorld10CalibrationCompletedV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world10CalibrationCompletedV1Key) ?? false;
  }

  static bool _isValidWorld10TrackChoiceV1(String value) {
    return value == world10TrackChoiceCashV1 ||
        value == world10TrackChoiceTournamentV1 ||
        value == world10TrackChoiceMixedV1;
  }

  static Future<bool> isWorld10TrackChoiceSeenV1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_world10TrackChoiceSeenV1Key) ?? false;
  }

  static Future<String?> getWorld10TrackChoiceV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_world10TrackChoiceV1Key)?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;
    if (!_isValidWorld10TrackChoiceV1(raw)) return null;
    return raw;
  }

  static Future<void> setWorld10TrackChoiceV1(String choice) async {
    final normalized = choice.trim().toLowerCase();
    if (!_isValidWorld10TrackChoiceV1(normalized)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_world10TrackChoiceV1Key, normalized);
    await prefs.setBool(_world10TrackChoiceSeenV1Key, true);
  }

  static String world10TrackEntryPackIdForChoiceV1(String choice) {
    final normalized = choice.trim().toLowerCase();
    switch (normalized) {
      case world10TrackChoiceCashV1:
        return 'world10_spine_followup_v1_b0';
      case world10TrackChoiceTournamentV1:
        return 'world10_spine_followup_v1_b1';
      case world10TrackChoiceMixedV1:
      default:
        return 'world10_spine_followup_v1_b2';
    }
  }

  static Future<String?> getSpineActivePackIdV1() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_spineCampaignActivePackIdV1Key);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim().toLowerCase();
  }

  static Future<void> setSpineActivePackIdV1(String packId) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spineCampaignActivePackIdV1Key, normalized);
  }

  static Future<void> clearSpineActivePackV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spineCampaignActivePackIdV1Key);
  }

  static Future<void> resetSpineProgressV1() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = <String>{
      _spineCampaignActivePackIdV1Key,
      _spineCampaignNextHandIndexV1Key,
      _spineCampaignCompletedPacksV1Key,
      _campaignCompleteTelemetrySentV1Key,
      _spineRankV1Key,
      _spineCalibrationBandV1Key,
      _spineCalibrationCompletedV1Key,
      _world2CalibrationCompletedV1Key,
      _world3CalibrationCompletedV1Key,
      _world4CalibrationCompletedV1Key,
      _world5CalibrationCompletedV1Key,
      _world6CalibrationCompletedV1Key,
      _world7CalibrationCompletedV1Key,
      _world8CalibrationCompletedV1Key,
      _world9CalibrationCompletedV1Key,
      _world10CalibrationCompletedV1Key,
      _world10TrackChoiceSeenV1Key,
      _world10TrackChoiceV1Key,
      _campaignBackerLastUsedAtV1Key,
      _campaignBankrollBalanceV1Key,
    };
    for (final packId in campaignPackIdsV1) {
      keysToRemove
        ..add('$_completedPrefix$packId')
        ..add('$unlockedPrefix$packId');
    }
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
    world1ProgressRevision.value = world1ProgressRevision.value + 1;
    world1DailyCompletionInSession.value = false;
    intakeFlowActiveInSession = false;
  }

  static Future<int> getSpineNextHandIndexV1() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_spineCampaignNextHandIndexV1Key);
    if (value == null || value < 0) return 0;
    return value;
  }

  static Future<void> setSpineNextHandIndexV1(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_spineCampaignNextHandIndexV1Key, index < 0 ? 0 : index);
  }

  static Future<Set<String>> _getSpineCompletedPacksV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_spineCampaignCompletedPacksV1Key);
    if (raw == null || raw.trim().isEmpty) {
      return <String>{};
    }
    return raw
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static Future<void> markSpinePackCompletedV1(String packId) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final completed = await _getSpineCompletedPacksV1();
    completed.add(normalized);
    await prefs.setString(
      _spineCampaignCompletedPacksV1Key,
      completed.join(','),
    );
    if ((prefs.getBool(_campaignCompleteTelemetrySentV1Key) ?? false)) {
      return;
    }
    final act0Complete = _campaignRequiredAct0PacksV1().every(
      completed.contains,
    );
    final isCompleteNow =
        act0Complete &&
        isCampaignWorldDoneByCompletedSetV1(
          world: 1,
          completedPackIds: completed,
        );
    if (!isCompleteNow) {
      return;
    }
    await prefs.setBool(_campaignCompleteTelemetrySentV1Key, true);
    unawaited(
      Telemetry.logEvent(TelemetryEvents.campaignComplete, <String, dynamic>{
        'final_pack_id': normalized,
        'completed_packs_count': completed.length,
      }),
    );
  }

  static Future<bool> isSpinePackCompletedV1(String packId) async {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final completed = await _getSpineCompletedPacksV1();
    return completed.contains(normalized);
  }

  static Future<Set<String>> getSpineCompletedPackIdsV1() async {
    return _getSpineCompletedPacksV1();
  }

  static String campaignWorldCompletionPackIdV1(int world) {
    return 'world${world}_spine_followup_v1_b2';
  }

  static Set<String> campaignWorldCompletionPackIdsV1(int world) {
    if (world <= 0) return const <String>{};
    if (world == 2) {
      return const <String>{
        'world2_spine_followup_v1_b0',
        'world2_spine_followup_v1_b1',
        'world2_spine_followup_v1_b2',
      };
    }
    return <String>{campaignWorldCompletionPackIdV1(world)};
  }

  static bool isCampaignWorldDoneByCompletedSetV1({
    required int world,
    required Set<String> completedPackIds,
  }) {
    if (world <= 0) return false;
    for (final packId in campaignWorldCompletionPackIdsV1(world)) {
      if (completedPackIds.contains(packId)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> isEffectiveCampaignWorldDoneV1({
    required int world,
    Set<String>? completedPackIds,
    Iterable<String> canonicalPlayableSessionIds = const <String>[],
  }) async {
    if (world <= 0) return false;
    final resolvedCompletedPackIds =
        completedPackIds ?? await getSpineCompletedPackIdsV1();
    if (isCampaignWorldDoneByCompletedSetV1(
      world: world,
      completedPackIds: resolvedCompletedPackIds,
    )) {
      return true;
    }
    if (world < 4) {
      return false;
    }
    final normalizedSessionIds = canonicalPlayableSessionIds
        .map((id) => id.trim().toLowerCase())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (normalizedSessionIds.isEmpty) {
      return false;
    }
    for (final sessionId in normalizedSessionIds) {
      if (!await isModuleCompleted(sessionId)) {
        return false;
      }
    }
    return true;
  }

  static int worldIndexForPackIdV1(String packId) {
    final normalized = packId.trim().toLowerCase();
    if (normalized.startsWith('world1_act0_')) {
      return 1;
    }
    final match = RegExp(r'^world(\d+)_').firstMatch(normalized);
    final parsed = int.tryParse(match?.group(1) ?? '');
    if (parsed == null || parsed <= 0) {
      return 1;
    }
    return parsed;
  }

  /// Returns an integer multiplier in x10 units (e.g. 15 => 1.5x).
  static int stakeMultiplierForPackIdV1(String packId) {
    final world = worldIndexForPackIdV1(packId);
    switch (world) {
      case 1:
      case 2:
        return 10;
      case 3:
        return 15;
      case 4:
        return 20;
      case 5:
        return 30;
      case 6:
        return 40;
      case 7:
        return 50;
      case 8:
        return 60;
      case 9:
        return 80;
      case 10:
      default:
        return 100;
    }
  }

  static Future<bool> isCampaignCompleteV1() async {
    final completed = await _getSpineCompletedPacksV1();
    final world1Act0Packs = _campaignRequiredAct0PacksV1();
    for (final required in world1Act0Packs) {
      if (!completed.contains(required)) {
        return false;
      }
    }
    return isCampaignWorldDoneByCompletedSetV1(
      world: 1,
      completedPackIds: completed,
    );
  }

  static Set<String> _campaignRequiredAct0PacksV1() {
    final required = <String>{};
    for (final packId in campaign_registry.kCampaignPackIdsV1) {
      if (packId.startsWith('world1_act0_')) {
        required.add(packId);
      }
    }
    return required;
  }

  static String campaignFollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world1_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world1_spine_followup_v1_b1';
      default:
        return 'world1_spine_followup_v1_b0';
    }
  }

  static String world2FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world2_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world2_spine_followup_v1_b1';
      default:
        return 'world2_spine_followup_v1_b0';
    }
  }

  static String world3FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world3_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world3_spine_followup_v1_b1';
      default:
        return 'world3_spine_followup_v1_b0';
    }
  }

  static String world4FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world4_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world4_spine_followup_v1_b1';
      default:
        return 'world4_spine_followup_v1_b0';
    }
  }

  static String world5FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world5_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world5_spine_followup_v1_b1';
      default:
        return 'world5_spine_followup_v1_b0';
    }
  }

  static String world6FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world6_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world6_spine_followup_v1_b1';
      default:
        return 'world6_spine_followup_v1_b0';
    }
  }

  static String world7FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world7_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world7_spine_followup_v1_b1';
      default:
        return 'world7_spine_followup_v1_b0';
    }
  }

  static String world8FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world8_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world8_spine_followup_v1_b1';
      default:
        return 'world8_spine_followup_v1_b0';
    }
  }

  static String world9FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world9_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world9_spine_followup_v1_b1';
      default:
        return 'world9_spine_followup_v1_b0';
    }
  }

  static String world10FollowupPackIdForBandV1(int band) {
    switch (band) {
      case spineCalibrationBandAdvanced:
        return 'world10_spine_followup_v1_b2';
      case spineCalibrationBandIntermediate:
        return 'world10_spine_followup_v1_b1';
      default:
        return 'world10_spine_followup_v1_b0';
    }
  }

  static int _campaignPackHandsForIdV1(String packId) {
    return campaign_registry.campaignHandCountForPackIdV1(packId);
  }

  static bool isCampaignPackIdV1(String packId) {
    return campaign_registry.isCampaignPackIdV1(packId);
  }

  static bool _isW8W10LearnerRouteLockedPackIdV1(String packId) {
    final normalized = packId.trim().toLowerCase();
    return _w8W10LearnerRouteLockedPackIdsV1.contains(normalized);
  }

  static Future<int> totalHandsInCampaignV1() async {
    final calibrationCompleted = await isSpineCalibrationCompletedV1();
    final band =
        await getSpineCalibrationBandV1() ?? spineCalibrationBandBeginner;
    final followupPack = calibrationCompleted
        ? campaignFollowupPackIdForBandV1(band)
        : campaignFollowupPackIdForBandV1(spineCalibrationBandBeginner);
    return campaignAct0PackIdsV1.fold<int>(
          0,
          (sum, id) => sum + _campaignPackHandsForIdV1(id),
        ) +
        _campaignPackHandsForIdV1(spineInitialPackIdV1) +
        _campaignPackHandsForIdV1(followupPack);
  }

  static Future<int> completedHandsInCampaignV1() async {
    final completed = await _getSpineCompletedPacksV1();
    var hands = 0;
    for (final packId in completed) {
      hands += _campaignPackHandsForIdV1(packId);
    }

    final activePackId = await getSpineActivePackIdV1();
    if (activePackId == null ||
        completed.contains(activePackId) ||
        !isCampaignPackIdV1(activePackId)) {
      return hands;
    }
    final nextIndex = await getSpineNextHandIndexV1();
    final maxHands = _campaignPackHandsForIdV1(activePackId);
    final clamped = nextIndex.clamp(0, maxHands);
    return hands + clamped;
  }

  static String segmentLabelForPackIdV1(String packId) {
    final normalized = packId.trim().toLowerCase();
    if (campaignAct0PackIdsV1.contains(normalized)) {
      return 'Act 0';
    }
    if (normalized == spineInitialPackIdV1) {
      return 'Spine';
    }
    if (normalized == 'world1_spine_followup_v1_b0') {
      return 'Followup B0';
    }
    if (normalized == 'world1_spine_followup_v1_b1') {
      return 'Followup B1';
    }
    if (normalized == 'world1_spine_followup_v1_b2') {
      return 'Followup B2';
    }
    if (normalized == 'world2_spine_campaign_v1') {
      return 'World2 Spine';
    }
    if (normalized == 'world2_spine_followup_v1_b0') {
      return 'World2 Followup B0';
    }
    if (normalized == 'world2_spine_followup_v1_b1') {
      return 'World2 Followup B1';
    }
    if (normalized == 'world2_spine_followup_v1_b2') {
      return 'World2 Followup B2';
    }
    if (normalized == 'world3_spine_campaign_v1') {
      return 'World3 Spine';
    }
    if (normalized == 'world3_spine_followup_v1_b0') {
      return 'World3 Followup B0';
    }
    if (normalized == 'world3_spine_followup_v1_b1') {
      return 'World3 Followup B1';
    }
    if (normalized == 'world3_spine_followup_v1_b2') {
      return 'World3 Followup B2';
    }
    if (normalized == 'world4_spine_campaign_v1') {
      return 'World4 Spine';
    }
    if (normalized == 'world4_spine_followup_v1_b0') {
      return 'World4 Followup B0';
    }
    if (normalized == 'world4_spine_followup_v1_b1') {
      return 'World4 Followup B1';
    }
    if (normalized == 'world4_spine_followup_v1_b2') {
      return 'World4 Followup B2';
    }
    if (normalized == 'world5_spine_campaign_v1') {
      return 'World5 Spine';
    }
    if (normalized == 'world5_spine_followup_v1_b0') {
      return 'World5 Followup B0';
    }
    if (normalized == 'world5_spine_followup_v1_b1') {
      return 'World5 Followup B1';
    }
    if (normalized == 'world5_spine_followup_v1_b2') {
      return 'World5 Followup B2';
    }
    if (normalized == 'world6_spine_campaign_v1') {
      return 'World6 Spine';
    }
    if (normalized == 'world6_spine_followup_v1_b0') {
      return 'World6 Followup B0';
    }
    if (normalized == 'world6_spine_followup_v1_b1') {
      return 'World6 Followup B1';
    }
    if (normalized == 'world6_spine_followup_v1_b2') {
      return 'World6 Followup B2';
    }
    if (normalized == 'world7_spine_campaign_v1') {
      return 'World7 Spine';
    }
    if (normalized == 'world7_spine_followup_v1_b0') {
      return 'World7 Followup B0';
    }
    if (normalized == 'world7_spine_followup_v1_b1') {
      return 'World7 Followup B1';
    }
    if (normalized == 'world7_spine_followup_v1_b2') {
      return 'World7 Followup B2';
    }
    if (normalized == 'world8_spine_campaign_v1') {
      return 'World8 Spine';
    }
    if (normalized == 'world8_spine_followup_v1_b0') {
      return 'World8 Followup B0';
    }
    if (normalized == 'world8_spine_followup_v1_b1') {
      return 'World8 Followup B1';
    }
    if (normalized == 'world8_spine_followup_v1_b2') {
      return 'World8 Followup B2';
    }
    if (normalized == 'world9_spine_campaign_v1') {
      return 'World9 Spine';
    }
    if (normalized == 'world9_spine_followup_v1_b0') {
      return 'World9 Followup B0';
    }
    if (normalized == 'world9_spine_followup_v1_b1') {
      return 'World9 Followup B1';
    }
    if (normalized == 'world9_spine_followup_v1_b2') {
      return 'World9 Followup B2';
    }
    if (normalized == 'world10_spine_campaign_v1') {
      return 'World10 Spine';
    }
    if (normalized == 'world10_spine_followup_v1_b0') {
      return 'World10 Followup B0';
    }
    if (normalized == 'world10_spine_followup_v1_b1') {
      return 'World10 Followup B1';
    }
    if (normalized == 'world10_spine_followup_v1_b2') {
      return 'World10 Followup B2';
    }
    return 'Campaign';
  }

  static Future<String> currentSegmentLabelV1() async {
    final active = await getSpineActivePackIdV1();
    if (active != null && active.isNotEmpty) {
      return segmentLabelForPackIdV1(active);
    }
    final next = await getNextSpinePackToRunV1();
    return segmentLabelForPackIdV1(next);
  }

  static Future<String> getNextSpinePackToRunV1() async {
    final active = await getSpineActivePackIdV1();
    if (active != null) {
      if (_isW8W10LearnerRouteLockedPackIdV1(active)) {
        return w7W10LearnerRouteGateTerminalPackIdV1;
      }
      return active;
    }

    if (!await isSpinePackCompletedV1('world1_act0_table_literacy')) {
      return 'world1_act0_table_literacy';
    }
    if (!await isSpinePackCompletedV1('world1_act0_action_literacy')) {
      return 'world1_act0_action_literacy';
    }
    if (!await isSpinePackCompletedV1('world1_act0_street_flow')) {
      return 'world1_act0_street_flow';
    }

    final world1CalibrationCompleted = await isSpineCalibrationCompletedV1();
    if (world1CalibrationCompleted) {
      final band =
          await getSpineCalibrationBandV1() ?? spineCalibrationBandBeginner;
      final routingFocus = await _resolveAdaptiveRoutingFocusV1();
      final world1Followup = await _resolveAdaptiveFollowupPackV1(
        world: 1,
        fallbackPackId: campaignFollowupPackIdForBandV1(band),
        focus: routingFocus,
      );
      if (!await isSpinePackCompletedV1(world1Followup)) {
        return world1Followup;
      }
      final world2CalibrationCompleted = await isWorld2CalibrationCompletedV1();
      if (world2CalibrationCompleted) {
        final world2Followup = await _resolveAdaptiveFollowupPackV1(
          world: 2,
          fallbackPackId: world2FollowupPackIdForBandV1(band),
          focus: routingFocus,
        );
        if (!await isSpinePackCompletedV1(world2Followup)) {
          return world2Followup;
        }
        final world3CalibrationCompleted =
            await isWorld3CalibrationCompletedV1();
        if (world3CalibrationCompleted) {
          final world3Followup = await _resolveAdaptiveFollowupPackV1(
            world: 3,
            fallbackPackId: world3FollowupPackIdForBandV1(band),
            focus: routingFocus,
          );
          if (!await isSpinePackCompletedV1(world3Followup)) {
            return world3Followup;
          }
          final world4CalibrationCompleted =
              await isWorld4CalibrationCompletedV1();
          if (world4CalibrationCompleted) {
            final world4Followup = await _resolveAdaptiveFollowupPackV1(
              world: 4,
              fallbackPackId: world4FollowupPackIdForBandV1(band),
              focus: routingFocus,
            );
            if (!await isSpinePackCompletedV1(world4Followup)) {
              return world4Followup;
            }
            final world5CalibrationCompleted =
                await isWorld5CalibrationCompletedV1();
            if (world5CalibrationCompleted) {
              final world5Followup = await _resolveAdaptiveFollowupPackV1(
                world: 5,
                fallbackPackId: world5FollowupPackIdForBandV1(band),
                focus: routingFocus,
              );
              if (!await isSpinePackCompletedV1(world5Followup)) {
                return world5Followup;
              }
              final world6CalibrationCompleted =
                  await isWorld6CalibrationCompletedV1();
              if (world6CalibrationCompleted) {
                final world6Followup = await _resolveAdaptiveFollowupPackV1(
                  world: 6,
                  fallbackPackId: world6FollowupPackIdForBandV1(band),
                  focus: routingFocus,
                );
                if (!await isSpinePackCompletedV1(world6Followup)) {
                  return world6Followup;
                }
                final world7CalibrationCompleted =
                    await isWorld7CalibrationCompletedV1();
                if (!world7CalibrationCompleted &&
                    !await isSpinePackCompletedV1('world7_spine_campaign_v1')) {
                  return 'world7_spine_campaign_v1';
                }
                return w7W10LearnerRouteGateTerminalPackIdV1;
              }
              return 'world6_spine_campaign_v1';
            }
            return 'world5_spine_campaign_v1';
          }
          return 'world4_spine_campaign_v1';
        }
        return 'world3_spine_campaign_v1';
      }
      return 'world2_spine_campaign_v1';
    }
    return spineInitialPackIdV1;
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveAdaptiveRoutingFocusV1() async {
    final expectedActionMismatchCount = await LearningStatsV1Service.instance
        .getExpectedActionMismatchErrorCount();
    final toCallLegalityMismatchCount = await LearningStatsV1Service.instance
        .getToCallLegalityMismatchErrorCount();
    if (toCallLegalityMismatchCount > expectedActionMismatchCount) {
      return AdaptiveRoutingFocusV1.toCall;
    }
    if (expectedActionMismatchCount > toCallLegalityMismatchCount) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }
    final unnecessaryFoldWhenCheckAvailableCount = await LearningStatsV1Service
        .instance
        .getUnnecessaryFoldWhenCheckAvailableErrorCount();
    final hasPrimaryMismatchConflict =
        expectedActionMismatchCount == toCallLegalityMismatchCount &&
        expectedActionMismatchCount > 0;
    if (hasPrimaryMismatchConflict &&
        unnecessaryFoldWhenCheckAvailableCount > 0) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }
    final checkpointFallback = await _resolveCheckpointFallbackRoutingFocusV1();
    if (checkpointFallback != null) {
      return checkpointFallback;
    }
    final focusReviewDueFallback = await _resolveFocusReviewDueRoutingFocusV1();
    if (focusReviewDueFallback != null) {
      return focusReviewDueFallback;
    }
    final placementScoreFallback = await _resolvePlacementScoreRoutingFocusV1();
    if (placementScoreFallback != null) {
      return placementScoreFallback;
    }
    final skillBandFallback = await _resolveSkillBandRoutingFocusV1();
    if (skillBandFallback != null) {
      return skillBandFallback;
    }
    final skillTagsFallback = await _resolveSkillTagsRoutingFocusV1();
    if (skillTagsFallback != null) {
      return skillTagsFallback;
    }
    final worldMasteryFallback = await _resolveWorldMasteryRoutingFocusV1();
    if (worldMasteryFallback != null) {
      return worldMasteryFallback;
    }
    final intakeProfileFallback = await _resolveIntakeProfileRoutingFocusV1();
    if (intakeProfileFallback != null) {
      return intakeProfileFallback;
    }
    return null;
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveCheckpointFallbackRoutingFocusV1() async {
    final state = await getCheckpointProgressStateV1();
    for (final rawErrorClass in state.topErrorClasses) {
      final mapped = _adaptiveRoutingFocusForErrorClassV1(rawErrorClass);
      if (mapped != null) return mapped;
    }
    return null;
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveFocusReviewDueRoutingFocusV1() async {
    final focusLabel = await getLessonFocusLabel();
    if (focusLabel == null || focusLabel.trim().isEmpty) {
      return null;
    }
    final reviewDue = await isFocusReviewDue(focusLabel);
    if (!reviewDue) {
      return null;
    }
    return _adaptiveRoutingFocusForFocusLabelV1(focusLabel);
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolvePlacementScoreRoutingFocusV1() async {
    final score = await getPlacementScoreV1();
    if (score == null) {
      return null;
    }
    if (score <= 1) {
      return AdaptiveRoutingFocusV1.toCall;
    }
    if (score >= 3) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }
    return null;
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveSkillBandRoutingFocusV1() async {
    final skillBand = await getSkillBandV1();
    if (skillBand == null || skillBand.isEmpty) {
      return null;
    }
    switch (skillBand) {
      case 'beginner':
        return AdaptiveRoutingFocusV1.toCall;
      case 'advanced':
        return AdaptiveRoutingFocusV1.expectedAction;
      default:
        return null;
    }
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveSkillTagsRoutingFocusV1() async {
    final band =
        await getSpineCalibrationBandV1() ?? spineCalibrationBandBeginner;
    final packId = campaignFollowupPackIdForBandV1(band);
    final tags = await getSkillTagsForPackV1(packId);
    if (tags.isEmpty) {
      return null;
    }
    for (final tag in tags) {
      final normalized = tag.trim();
      if (normalized.isEmpty) continue;
      final mappedFocusLabel =
          focusLabelForPhase1Signal(
            errorType: normalized,
            category: normalized,
            subreason: normalized,
          ) ??
          normalized;
      final mapped = _adaptiveRoutingFocusForFocusLabelV1(mappedFocusLabel);
      if (mapped != null) {
        return mapped;
      }
    }
    return null;
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveWorldMasteryRoutingFocusV1() async {
    final band =
        await getSpineCalibrationBandV1() ?? spineCalibrationBandBeginner;
    final packId = campaignFollowupPackIdForBandV1(band);
    final mastery = await getWorldMasteryForPackV1(packId);
    if (mastery == null) {
      return null;
    }
    switch (mastery) {
      case WorldMasteryLevelV1.bronze:
        return AdaptiveRoutingFocusV1.toCall;
      case WorldMasteryLevelV1.gold:
        return AdaptiveRoutingFocusV1.expectedAction;
      case WorldMasteryLevelV1.silver:
        return null;
    }
  }

  static Future<AdaptiveRoutingFocusV1?>
  _resolveIntakeProfileRoutingFocusV1() async {
    final profile = await _getIntakeProfileForRoutingV1();
    if (profile == null || profile.isEmpty) {
      return null;
    }
    final rawFocusLabel = profile['focusLabel'];
    if (rawFocusLabel is String) {
      final mappedFocus = _adaptiveRoutingFocusForFocusLabelV1(rawFocusLabel);
      if (mappedFocus != null) {
        return mappedFocus;
      }
    }
    final normalizedPlacementScore = _normalizeIntakePlacementScoreV1(
      profile['placementScore'],
    );
    if (normalizedPlacementScore != null) {
      if (normalizedPlacementScore <= 1) {
        return AdaptiveRoutingFocusV1.toCall;
      }
      if (normalizedPlacementScore >= 3) {
        return AdaptiveRoutingFocusV1.expectedAction;
      }
    }
    final rawSkillBand = profile['skillBand'];
    if (rawSkillBand is String) {
      switch (rawSkillBand.trim().toLowerCase()) {
        case 'beginner':
          return AdaptiveRoutingFocusV1.toCall;
        case 'advanced':
          return AdaptiveRoutingFocusV1.expectedAction;
        default:
          return null;
      }
    }
    return null;
  }

  static int? _normalizeIntakePlacementScoreV1(Object? rawValue) {
    if (rawValue is int) return rawValue;
    if (rawValue is num && rawValue.isFinite) {
      final asDouble = rawValue.toDouble();
      final asInt = rawValue.toInt();
      if (asDouble == asInt.toDouble()) {
        return asInt;
      }
      return null;
    }
    if (rawValue is String) {
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return null;
      return int.tryParse(trimmed);
    }
    return null;
  }

  static Future<Map<String, Object?>?> _getIntakeProfileForRoutingV1() async {
    try {
      return await getIntakeProfile();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static AdaptiveRoutingFocusV1? _adaptiveRoutingFocusForFocusLabelV1(
    String focusLabel,
  ) {
    final normalized = focusLabel.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'none') {
      return null;
    }
    if (normalized == 'pot_odds' || normalized == 'equity') {
      return AdaptiveRoutingFocusV1.toCall;
    }
    if (const <String>{
      'initiative',
      'action_order',
      'starting_hands',
      'hand_selection',
      'board_texture',
      'flop',
      'equity_realization',
      'turn',
      'river',
      'bankroll',
      'range',
    }.contains(normalized)) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }
    return null;
  }

  static AdaptiveRoutingFocusV1? _adaptiveRoutingFocusForErrorClassV1(
    String errorClass,
  ) {
    final normalized = errorClass.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'none') {
      return null;
    }

    final focusLabel =
        focusLabelForPhase1Error(normalized) ??
        focusLabelForPhase1Signal(
          errorType: normalized,
          category: normalized,
          subreason: normalized,
        );
    final normalizedFocus = (focusLabel ?? '').trim().toLowerCase();
    if (normalizedFocus == 'pot_odds' || normalizedFocus == 'equity') {
      return AdaptiveRoutingFocusV1.toCall;
    }
    if (normalizedFocus.isNotEmpty) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }

    if (normalized.contains('tocall') ||
        normalized.contains('to_call') ||
        normalized.contains('pot_odds') ||
        normalized.contains('equity')) {
      return AdaptiveRoutingFocusV1.toCall;
    }
    if (normalized.contains('expected_action') ||
        normalized.contains('action') ||
        normalized.contains('range') ||
        normalized.contains('timing') ||
        normalized.contains('sizing')) {
      return AdaptiveRoutingFocusV1.expectedAction;
    }
    return null;
  }

  static Future<String> _resolveAdaptiveFollowupPackV1({
    required int world,
    required String fallbackPackId,
    required AdaptiveRoutingFocusV1? focus,
  }) async {
    if (focus == null) {
      return fallbackPackId;
    }
    final focusedPackId = switch (focus) {
      AdaptiveRoutingFocusV1.toCall => 'world${world}_spine_followup_v1_b0',
      AdaptiveRoutingFocusV1.expectedAction =>
        'world${world}_spine_followup_v1_b2',
    };
    if (!await isSpinePackCompletedV1(focusedPackId)) {
      return focusedPackId;
    }
    return fallbackPackId;
  }

  static Future<BankrollStatus> getBankrollStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    final regenApplied = await _applyBankrollRegenWithPrefs(prefs, now);
    final balance = prefs.getInt(_bankrollBalanceKey) ?? bankrollCap;
    final minutesUntilNext = _minutesUntilNextRegen(prefs, now, balance);
    final backerAvailable = await isBackerAvailable(now: now);
    return BankrollStatus(
      balance: balance,
      cap: bankrollCap,
      regenApplied: regenApplied,
      minutesUntilNextRegen: minutesUntilNext,
      backerAvailable: backerAvailable,
    );
  }

  static Future<bool> canAfford(int cost) async {
    final balance = await getBankrollBalance();
    return balance >= cost;
  }

  static Future<BankrollChargeResult> chargeBuyInOnce({
    required String sessionId,
    required int cost,
    required String sessionKind,
    required String moduleId,
    bool sponsored = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    await _applyBankrollRegenWithPrefs(prefs, now);
    final chargedKey = '$_bankrollChargedPrefix$sessionId';
    if (prefs.getBool(chargedKey) ?? false) {
      final balance = prefs.getInt(_bankrollBalanceKey) ?? bankrollCap;
      return BankrollChargeResult(
        charged: false,
        blockedInsufficient: false,
        sponsored: sponsored,
        balanceBefore: balance,
        balanceAfter: balance,
        cost: cost,
      );
    }
    final balanceBefore = prefs.getInt(_bankrollBalanceKey) ?? bankrollCap;
    if (!sponsored && cost > balanceBefore) {
      return BankrollChargeResult(
        charged: false,
        blockedInsufficient: true,
        sponsored: false,
        balanceBefore: balanceBefore,
        balanceAfter: balanceBefore,
        cost: cost,
      );
    }
    final balanceAfter = sponsored
        ? balanceBefore
        : (balanceBefore - cost).clamp(0, bankrollCap);
    await prefs.setInt(_bankrollBalanceKey, balanceAfter);
    await prefs.setBool(chargedKey, true);
    await prefs.setString(_bankrollPendingSessionIdKey, sessionId);
    await prefs.setInt(_bankrollPendingCostKey, cost.clamp(0, bankrollCap));
    await prefs.setString(_bankrollPendingSessionKindKey, sessionKind);
    await prefs.setString(_bankrollPendingModuleIdKey, moduleId);
    return BankrollChargeResult(
      charged: true,
      blockedInsufficient: false,
      sponsored: sponsored,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      cost: cost,
    );
  }

  static Future<BankrollPendingSession?> getPendingBuyIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_bankrollPendingSessionIdKey);
    if (sessionId == null || sessionId.trim().isEmpty) {
      return null;
    }
    return BankrollPendingSession(
      sessionId: sessionId,
      cost: prefs.getInt(_bankrollPendingCostKey) ?? 0,
      sessionKind: prefs.getString(_bankrollPendingSessionKindKey) ?? 'core',
      moduleId: prefs.getString(_bankrollPendingModuleIdKey) ?? '',
    );
  }

  static Future<void> clearPendingBuyIn(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(_bankrollPendingSessionIdKey);
    if (pending != sessionId) return;
    await prefs.remove(_bankrollPendingSessionIdKey);
    await prefs.remove(_bankrollPendingCostKey);
    await prefs.remove(_bankrollPendingSessionKindKey);
    await prefs.remove(_bankrollPendingModuleIdKey);
  }

  static Future<BankrollRakebackResult> grantRakeback({
    required String sessionId,
    required int amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final grantedKey = '$_bankrollRakebackGrantedPrefix$sessionId';
    final balanceBefore = prefs.getInt(_bankrollBalanceKey) ?? bankrollCap;
    if (prefs.getBool(grantedKey) ?? false) {
      return BankrollRakebackResult(
        granted: false,
        amount: 0,
        balanceBefore: balanceBefore,
        balanceAfter: balanceBefore,
      );
    }
    if (amount <= 0) {
      await prefs.setBool(grantedKey, true);
      return BankrollRakebackResult(
        granted: false,
        amount: 0,
        balanceBefore: balanceBefore,
        balanceAfter: balanceBefore,
      );
    }
    final balanceAfter = (balanceBefore + amount).clamp(0, bankrollCap);
    final grantedAmount = balanceAfter - balanceBefore;
    await prefs.setInt(_bankrollBalanceKey, balanceAfter);
    await prefs.setBool(grantedKey, true);
    return BankrollRakebackResult(
      granted: grantedAmount > 0,
      amount: grantedAmount,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
    );
  }

  static Future<bool> isBackerAvailable({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final usedYmd = prefs.getString(_bankrollBackerUsedYmdKey);
    if (usedYmd == null || usedYmd.trim().isEmpty) {
      return true;
    }
    return usedYmd != _toYmd((now ?? _now()).toUtc());
  }

  static Future<bool> useBacker({DateTime? now}) async {
    final available = await isBackerAvailable(now: now);
    if (!available) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bankrollBackerUsedYmdKey,
      _toYmd((now ?? _now()).toUtc()),
    );
    return true;
  }

  static Future<int> applyBankrollRegenIfDue([DateTime? now]) async {
    final prefs = await SharedPreferences.getInstance();
    return _applyBankrollRegenWithPrefs(prefs, (now ?? _now()).toUtc());
  }

  static Future<void> _ensureBankrollInitialized(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    if (!prefs.containsKey(_bankrollBalanceKey)) {
      await prefs.setInt(_bankrollBalanceKey, bankrollCap);
    }
    if (!prefs.containsKey(_bankrollLastRegenAtKey)) {
      await prefs.setString(_bankrollLastRegenAtKey, now.toIso8601String());
    }
  }

  static Future<int> _applyBankrollRegenWithPrefs(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    await _ensureBankrollInitialized(prefs, now);
    final balanceBefore = prefs.getInt(_bankrollBalanceKey) ?? bankrollCap;
    if (balanceBefore >= bankrollCap) {
      return 0;
    }
    final lastRaw = prefs.getString(_bankrollLastRegenAtKey);
    final last = DateTime.tryParse(lastRaw ?? '') ?? now;
    final elapsedMinutes = now.difference(last).inMinutes;
    final intervals = elapsedMinutes ~/ bankrollRegenIntervalMinutes;
    if (intervals <= 0) {
      return 0;
    }
    final regenTotal = intervals * bankrollRegenAmount;
    final balanceAfter = (balanceBefore + regenTotal).clamp(0, bankrollCap);
    final applied = balanceAfter - balanceBefore;
    await prefs.setInt(_bankrollBalanceKey, balanceAfter);
    await prefs.setString(
      _bankrollLastRegenAtKey,
      last
          .add(Duration(minutes: intervals * bankrollRegenIntervalMinutes))
          .toIso8601String(),
    );
    return applied;
  }

  static int _minutesUntilNextRegen(
    SharedPreferences prefs,
    DateTime now,
    int balance,
  ) {
    if (balance >= bankrollCap) {
      return 0;
    }
    final lastRaw = prefs.getString(_bankrollLastRegenAtKey);
    final last = DateTime.tryParse(lastRaw ?? '') ?? now;
    final elapsedMinutes = now.difference(last).inMinutes;
    final remainder = elapsedMinutes % bankrollRegenIntervalMinutes;
    return remainder == 0
        ? bankrollRegenIntervalMinutes
        : (bankrollRegenIntervalMinutes - remainder);
  }

  static String _toYmd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}

class LeakLogEntryV1 {
  const LeakLogEntryV1({
    required this.leakId,
    required this.utcTsMs,
    required this.source,
    this.packId,
    this.moduleId,
    this.errorType,
  });

  final String leakId;
  final int utcTsMs;
  final String source;
  final String? packId;
  final String? moduleId;
  final String? errorType;

  Map<String, Object> toJson() {
    final map = <String, Object>{
      'leak_id': leakId,
      'utc_ts_ms': utcTsMs,
      'source': source,
    };
    if (packId != null && packId!.isNotEmpty) map['pack_id'] = packId!;
    if (moduleId != null && moduleId!.isNotEmpty) map['module_id'] = moduleId!;
    if (errorType != null && errorType!.isNotEmpty) {
      map['error_type'] = errorType!;
    }
    return map;
  }

  static LeakLogEntryV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final leakId = (raw['leak_id'] ?? '').toString().trim();
    final source = (raw['source'] ?? '').toString().trim();
    final tsRaw = raw['utc_ts_ms'];
    final utcTsMs = tsRaw is int ? tsRaw : int.tryParse('${tsRaw ?? ''}');
    if (leakId.isEmpty || source.isEmpty || utcTsMs == null) return null;
    return LeakLogEntryV1(
      leakId: leakId,
      utcTsMs: utcTsMs,
      source: source,
      packId: (raw['pack_id'] ?? '').toString().trim().isEmpty
          ? null
          : (raw['pack_id'] ?? '').toString().trim(),
      moduleId: (raw['module_id'] ?? '').toString().trim().isEmpty
          ? null
          : (raw['module_id'] ?? '').toString().trim(),
      errorType: (raw['error_type'] ?? '').toString().trim().isEmpty
          ? null
          : (raw['error_type'] ?? '').toString().trim(),
    );
  }
}

class LeakResolutionLogEntryV1 {
  const LeakResolutionLogEntryV1({
    required this.leakId,
    required this.resolvedUtcTsMs,
  });

  final String leakId;
  final int resolvedUtcTsMs;

  Map<String, Object> toJson() => <String, Object>{
    'leak_id': leakId,
    'resolved_utc_ts_ms': resolvedUtcTsMs,
  };

  static LeakResolutionLogEntryV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final leakId = (raw['leak_id'] ?? '').toString().trim();
    final tsRaw = raw['resolved_utc_ts_ms'];
    final resolvedUtcTsMs = tsRaw is int
        ? tsRaw
        : int.tryParse('${tsRaw ?? ''}');
    if (leakId.isEmpty || resolvedUtcTsMs == null) return null;
    return LeakResolutionLogEntryV1(
      leakId: leakId,
      resolvedUtcTsMs: resolvedUtcTsMs,
    );
  }
}

class GauntletCompletionLogEntryV1 {
  const GauntletCompletionLogEntryV1({
    required this.utcDayKey,
    required this.cohort,
    required this.gauntletId,
  });

  final String utcDayKey;
  final String cohort;
  final String gauntletId;

  Map<String, Object> toJson() => <String, Object>{
    'utcDayKey': utcDayKey,
    'cohort': cohort,
    'gauntlet_id': gauntletId,
  };

  static GauntletCompletionLogEntryV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final utcDayKey = (raw['utcDayKey'] ?? '').toString().trim();
    final cohort = (raw['cohort'] ?? '').toString().trim();
    final gauntletId = (raw['gauntlet_id'] ?? '').toString().trim();
    if (utcDayKey.isEmpty || cohort.isEmpty || gauntletId.isEmpty) {
      return null;
    }
    return GauntletCompletionLogEntryV1(
      utcDayKey: utcDayKey,
      cohort: cohort,
      gauntletId: gauntletId,
    );
  }
}

class GauntletStepProgressEntryV1 {
  const GauntletStepProgressEntryV1({
    required this.utcDayKey,
    required this.cohort,
    required this.gauntletId,
    required this.currentStepIndex,
  });

  final String utcDayKey;
  final String cohort;
  final String gauntletId;
  final int currentStepIndex;

  Map<String, Object> toJson() => <String, Object>{
    'utcDayKey': utcDayKey,
    'cohort': cohort,
    'gauntlet_id': gauntletId,
    'currentStepIndex': currentStepIndex,
  };

  static GauntletStepProgressEntryV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final utcDayKey = (raw['utcDayKey'] ?? '').toString().trim();
    final cohort = (raw['cohort'] ?? '').toString().trim();
    final gauntletId = (raw['gauntlet_id'] ?? '').toString().trim();
    final stepRaw = raw['currentStepIndex'];
    final currentStepIndex = stepRaw is int
        ? stepRaw
        : int.tryParse('${stepRaw ?? ''}');
    if (utcDayKey.isEmpty ||
        cohort.isEmpty ||
        gauntletId.isEmpty ||
        currentStepIndex == null ||
        currentStepIndex < 0) {
      return null;
    }
    return GauntletStepProgressEntryV1(
      utcDayKey: utcDayKey,
      cohort: cohort,
      gauntletId: gauntletId,
      currentStepIndex: currentStepIndex,
    );
  }
}

class CohortPromotionEventEntryV1 {
  const CohortPromotionEventEntryV1({
    required this.utcDayKey,
    required this.fromCohort,
    required this.toCohort,
  });

  final String utcDayKey;
  final String fromCohort;
  final String toCohort;

  String get eventId => 'cohort_promo:v1:$utcDayKey:$fromCohort:$toCohort';

  Map<String, Object> toJson() => <String, Object>{
    'utcDayKey': utcDayKey,
    'fromCohort': fromCohort,
    'toCohort': toCohort,
  };

  static CohortPromotionEventEntryV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final utcDayKey = (raw['utcDayKey'] ?? '').toString().trim();
    final fromCohort = (raw['fromCohort'] ?? '').toString().trim();
    final toCohort = (raw['toCohort'] ?? '').toString().trim();
    if (utcDayKey.isEmpty || fromCohort.isEmpty || toCohort.isEmpty) {
      return null;
    }
    return CohortPromotionEventEntryV1(
      utcDayKey: utcDayKey,
      fromCohort: fromCohort,
      toCohort: toCohort,
    );
  }
}

class TodayEntitlementsV1 {
  const TodayEntitlementsV1({required this.todayEntriesPerDay});

  const TodayEntitlementsV1.free() : this(todayEntriesPerDay: 1);

  final int todayEntriesPerDay;
}

class ChipsIdempotentTxnResultV1 {
  const ChipsIdempotentTxnResultV1._({
    required this.txnId,
    required this.contextTag,
    required this.deltaChips,
    required this.alreadyApplied,
    required this.applied,
    required this.snapshotAfter,
    this.mutation,
  });

  factory ChipsIdempotentTxnResultV1.applied({
    required String txnId,
    required String contextTag,
    required int deltaChips,
    required ChipsLedgerMutationV1 mutation,
  }) {
    return ChipsIdempotentTxnResultV1._(
      txnId: txnId,
      contextTag: contextTag,
      deltaChips: deltaChips,
      alreadyApplied: false,
      applied: true,
      snapshotAfter: mutation.after,
      mutation: mutation,
    );
  }

  factory ChipsIdempotentTxnResultV1.alreadyApplied({
    required String txnId,
    required String contextTag,
    required int deltaChips,
    required ChipsLedgerSnapshotV1 snapshot,
  }) {
    return ChipsIdempotentTxnResultV1._(
      txnId: txnId,
      contextTag: contextTag,
      deltaChips: deltaChips,
      alreadyApplied: true,
      applied: false,
      snapshotAfter: snapshot,
    );
  }

  factory ChipsIdempotentTxnResultV1.notApplied({
    required String txnId,
    required String contextTag,
    required int deltaChips,
    required ChipsLedgerMutationV1 mutation,
  }) {
    return ChipsIdempotentTxnResultV1._(
      txnId: txnId,
      contextTag: contextTag,
      deltaChips: deltaChips,
      alreadyApplied: false,
      applied: false,
      snapshotAfter: mutation.after,
      mutation: mutation,
    );
  }

  final String txnId;
  final String contextTag;
  final int deltaChips;
  final bool alreadyApplied;
  final bool applied;
  final ChipsLedgerSnapshotV1 snapshotAfter;
  final ChipsLedgerMutationV1? mutation;
}

class BankrollStatus {
  const BankrollStatus({
    required this.balance,
    required this.cap,
    required this.regenApplied,
    required this.minutesUntilNextRegen,
    required this.backerAvailable,
  });

  final int balance;
  final int cap;
  final int regenApplied;
  final int minutesUntilNextRegen;
  final bool backerAvailable;
}

class BankrollChargeResult {
  const BankrollChargeResult({
    required this.charged,
    required this.blockedInsufficient,
    required this.sponsored,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.cost,
  });

  final bool charged;
  final bool blockedInsufficient;
  final bool sponsored;
  final int balanceBefore;
  final int balanceAfter;
  final int cost;
}

class BankrollPendingSession {
  const BankrollPendingSession({
    required this.sessionId,
    required this.cost,
    required this.sessionKind,
    required this.moduleId,
  });

  final String sessionId;
  final int cost;
  final String sessionKind;
  final String moduleId;
}

class BankrollRakebackResult {
  const BankrollRakebackResult({
    required this.granted,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
  });

  final bool granted;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
}
