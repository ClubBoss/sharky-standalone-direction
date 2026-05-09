import 'dart:convert';

import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LatestSessionOutcomeSnapshotV1 {
  const LatestSessionOutcomeSnapshotV1({
    required this.moduleId,
    required this.correctCount,
    required this.totalCount,
    required this.isCampaignSession,
    this.outcomeKind,
    this.errorType,
  });

  final String moduleId;
  final int correctCount;
  final int totalCount;
  final bool isCampaignSession;
  final OutcomeKindV1? outcomeKind;
  final String? errorType;

  double get accuracy =>
      totalCount <= 0 ? 1.0 : (correctCount / totalCount).clamp(0.0, 1.0);

  bool get hadMistake =>
      outcomeKind == OutcomeKindV1.mistake || correctCount < totalCount;

  Map<String, Object?> toJson() => <String, Object?>{
    'module_id': moduleId,
    'correct_count': correctCount,
    'total_count': totalCount,
    'is_campaign_session': isCampaignSession,
    'outcome_kind': outcomeKind?.name,
    'error_type': errorType,
  };

  static LatestSessionOutcomeSnapshotV1? fromJson(Map<String, Object?> json) {
    final moduleId = (json['module_id'] ?? '').toString().trim();
    if (moduleId.isEmpty) return null;
    final outcomeKindName = (json['outcome_kind'] ?? '').toString().trim();
    OutcomeKindV1? outcomeKind;
    for (final value in OutcomeKindV1.values) {
      if (value.name == outcomeKindName) {
        outcomeKind = value;
        break;
      }
    }
    return LatestSessionOutcomeSnapshotV1(
      moduleId: moduleId,
      correctCount: _asInt(json['correct_count']),
      totalCount: _asInt(json['total_count']),
      isCampaignSession: json['is_campaign_session'] == true,
      outcomeKind: outcomeKind,
      errorType: (json['error_type'] ?? '').toString().trim(),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class ProgressionQualityDecisionV1 {
  const ProgressionQualityDecisionV1({
    required this.mode,
    required this.reason,
  });

  final ProgressionQualityModeV1 mode;
  final String reason;
}

enum ProgressionQualityModeV1 { continuePath, repeat, review }

class ProgressionQualityGateV1 {
  ProgressionQualityGateV1._();

  static const String _latestSessionSnapshotKey =
      'progression_quality_latest_session_v1';

  static Future<void> saveLatestSessionSnapshot(
    LatestSessionOutcomeSnapshotV1 snapshot,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _latestSessionSnapshotKey,
      jsonEncode(snapshot.toJson()),
    );
  }

  static Future<LatestSessionOutcomeSnapshotV1?>
  loadLatestSessionSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_latestSessionSnapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return LatestSessionOutcomeSnapshotV1.fromJson(
        Map<String, Object?>.from(
          decoded.map(
            (key, value) => MapEntry(key.toString(), value as Object?),
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latestSessionSnapshotKey);
  }

  static PersonalizedRecommendationV1? apply({
    required PersonalizedRecommendationV1? recommendation,
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required Iterable<RecentTelemetrySignalV1> recentSignals,
  }) {
    final base = recommendation;
    if (base == null) return null;
    final decision = decide(
      latestSession: latestSession,
      recentSignals: recentSignals,
      baseAction: base.recommendedNextAction,
    );
    switch (decision.mode) {
      case ProgressionQualityModeV1.continuePath:
        return base;
      case ProgressionQualityModeV1.repeat:
        final repeatTarget = latestSession?.moduleId.trim() ?? '';
        return PersonalizedRecommendationV1(
          recommendedFocusId: base.recommendedFocusId,
          reasonCode: 'progression_repeat_fit',
          shortHintText:
              '${decision.reason} Fix this spot once more before moving on.',
          recommendedNextAction: PersonalizedNextActionV1.repeatPack,
          recommendedNextSessionTarget: repeatTarget.isEmpty
              ? base.recommendedNextSessionTarget
              : repeatTarget,
        );
      case ProgressionQualityModeV1.review:
        return PersonalizedRecommendationV1(
          recommendedFocusId: base.recommendedFocusId,
          reasonCode: 'progression_review_fit',
          shortHintText:
              '${decision.reason} Review the weak pattern before adding a harder step.',
          recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
          recommendedNextSessionTarget: base.recommendedNextSessionTarget,
        );
    }
  }

  static ProgressionQualityDecisionV1 decide({
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required Iterable<RecentTelemetrySignalV1> recentSignals,
    required PersonalizedNextActionV1 baseAction,
  }) {
    final snapshot = latestSession;
    if (snapshot == null) {
      return const ProgressionQualityDecisionV1(
        mode: ProgressionQualityModeV1.continuePath,
        reason: '',
      );
    }
    final recentMistakes = _recentMistakeCount(recentSignals);
    final accuracy = snapshot.accuracy;
    final baseIsContinue =
        baseAction == PersonalizedNextActionV1.continueCampaign ||
        baseAction == PersonalizedNextActionV1.nextModule;
    if ((snapshot.hadMistake && recentMistakes >= 3) || accuracy <= 0.34) {
      return const ProgressionQualityDecisionV1(
        mode: ProgressionQualityModeV1.review,
        reason: 'Recent misses are still clustering around the same weakness.',
      );
    }
    if (baseIsContinue &&
        (snapshot.hadMistake || accuracy < 0.8) &&
        recentMistakes >= 1) {
      return const ProgressionQualityDecisionV1(
        mode: ProgressionQualityModeV1.repeat,
        reason: 'This last session was still shaky for the current level.',
      );
    }
    return const ProgressionQualityDecisionV1(
      mode: ProgressionQualityModeV1.continuePath,
      reason: '',
    );
  }

  static int _recentMistakeCount(Iterable<RecentTelemetrySignalV1> signals) {
    var count = 0;
    for (final signal in signals) {
      if (signal.name != 'correct') continue;
      if (signal.payload['correct'] == false) {
        count++;
      }
    }
    return count;
  }
}
