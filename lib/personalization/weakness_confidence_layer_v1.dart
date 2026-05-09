import 'dart:convert';

import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeaknessConfidenceStateV1 { emerging, active, stabilizing }

class WeaknessConfidenceHistoryEntryV1 {
  const WeaknessConfidenceHistoryEntryV1({
    required this.focusId,
    required this.nextAction,
    required this.moduleId,
    required this.hadMistake,
    required this.recordedAtMs,
  });

  final String focusId;
  final PersonalizedNextActionV1 nextAction;
  final String moduleId;
  final bool hadMistake;
  final int recordedAtMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'focus_id': focusId,
    'next_action': nextAction.name,
    'module_id': moduleId,
    'had_mistake': hadMistake,
    'recorded_at_ms': recordedAtMs,
  };

  static WeaknessConfidenceHistoryEntryV1? fromJson(Map<String, Object?> json) {
    final focusId = (json['focus_id'] ?? '').toString().trim();
    if (focusId.isEmpty) return null;
    final nextActionName = (json['next_action'] ?? '').toString().trim();
    PersonalizedNextActionV1? nextAction;
    for (final value in PersonalizedNextActionV1.values) {
      if (value.name == nextActionName) {
        nextAction = value;
        break;
      }
    }
    if (nextAction == null) return null;
    return WeaknessConfidenceHistoryEntryV1(
      focusId: focusId,
      nextAction: nextAction,
      moduleId: (json['module_id'] ?? '').toString().trim(),
      hadMistake: json['had_mistake'] == true,
      recordedAtMs: _asInt(json['recorded_at_ms']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class WeaknessConfidenceAssessmentV1 {
  const WeaknessConfidenceAssessmentV1({
    required this.focusId,
    required this.state,
    required this.recentMistakeCount,
    required this.correctiveHistoryCount,
  });

  final String focusId;
  final WeaknessConfidenceStateV1 state;
  final int recentMistakeCount;
  final int correctiveHistoryCount;
}

class WeaknessConfidenceLayerV1 {
  WeaknessConfidenceLayerV1._();

  static const String _historyKey = 'weakness_confidence_history_v1';
  static const int _maxEntries = 8;

  static Future<List<WeaknessConfidenceHistoryEntryV1>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const <WeaknessConfidenceHistoryEntryV1>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <WeaknessConfidenceHistoryEntryV1>[];
      }
      return decoded
          .whereType<Map>()
          .map(
            (entry) => WeaknessConfidenceHistoryEntryV1.fromJson(
              Map<String, Object?>.from(
                entry.map(
                  (key, value) => MapEntry(key.toString(), value as Object?),
                ),
              ),
            ),
          )
          .whereType<WeaknessConfidenceHistoryEntryV1>()
          .toList(growable: false);
    } catch (_) {
      return const <WeaknessConfidenceHistoryEntryV1>[];
    }
  }

  static Future<void> saveHistory(
    List<WeaknessConfidenceHistoryEntryV1> history,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = history.length <= _maxEntries
        ? history
        : history.sublist(history.length - _maxEntries);
    await prefs.setString(
      _historyKey,
      jsonEncode(trimmed.map((entry) => entry.toJson()).toList()),
    );
  }

  static Future<void> clearForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static List<WeaknessConfidenceHistoryEntryV1> appendInMemory({
    required List<WeaknessConfidenceHistoryEntryV1> history,
    required PersonalizedRecommendationV1? recommendation,
    required LatestSessionOutcomeSnapshotV1? latestSession,
  }) {
    final base = recommendation;
    final snapshot = latestSession;
    if (base == null || snapshot == null) {
      return history;
    }
    final focusId = base.recommendedFocusId.trim();
    if (focusId.isEmpty) {
      return history;
    }
    final entry = WeaknessConfidenceHistoryEntryV1(
      focusId: focusId,
      nextAction: base.recommendedNextAction,
      moduleId: snapshot.moduleId.trim(),
      hadMistake: snapshot.hadMistake,
      recordedAtMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    final updated = <WeaknessConfidenceHistoryEntryV1>[...history];
    final last = updated.isNotEmpty ? updated.last : null;
    final isDuplicate =
        last != null &&
        last.focusId == entry.focusId &&
        last.nextAction == entry.nextAction &&
        last.moduleId == entry.moduleId &&
        last.hadMistake == entry.hadMistake;
    if (!isDuplicate) {
      updated.add(entry);
    }
    return updated.length <= _maxEntries
        ? updated
        : updated.sublist(updated.length - _maxEntries);
  }

  static WeaknessConfidenceAssessmentV1? assess({
    required PersonalizedRecommendationV1? recommendation,
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required Iterable<RecentTelemetrySignalV1> recentSignals,
    required Iterable<WeaknessConfidenceHistoryEntryV1> history,
  }) {
    final base = recommendation;
    final snapshot = latestSession;
    if (base == null || snapshot == null) {
      return null;
    }
    final focusId = base.recommendedFocusId.trim();
    if (focusId.isEmpty) {
      return null;
    }
    final recentMistakeCount = _recentMistakeCountForFocus(
      focusId: focusId,
      signals: recentSignals,
    );
    final correctiveHistoryCount = history
        .where((entry) => entry.focusId == focusId)
        .where(
          (entry) =>
              entry.nextAction == PersonalizedNextActionV1.reviewFocus ||
              entry.nextAction == PersonalizedNextActionV1.repeatPack,
        )
        .length;
    final hasEvidence =
        recentMistakeCount >= 1 ||
        correctiveHistoryCount >= 1 ||
        snapshot.hadMistake;
    if (!hasEvidence) {
      return null;
    }
    if (correctiveHistoryCount >= 1 &&
        !snapshot.hadMistake &&
        recentMistakeCount == 0) {
      return WeaknessConfidenceAssessmentV1(
        focusId: focusId,
        state: WeaknessConfidenceStateV1.stabilizing,
        recentMistakeCount: recentMistakeCount,
        correctiveHistoryCount: correctiveHistoryCount,
      );
    }
    if (recentMistakeCount >= 2 ||
        (snapshot.hadMistake && correctiveHistoryCount >= 1) ||
        correctiveHistoryCount >= 2) {
      return WeaknessConfidenceAssessmentV1(
        focusId: focusId,
        state: WeaknessConfidenceStateV1.active,
        recentMistakeCount: recentMistakeCount,
        correctiveHistoryCount: correctiveHistoryCount,
      );
    }
    if (snapshot.hadMistake && recentMistakeCount >= 1) {
      return WeaknessConfidenceAssessmentV1(
        focusId: focusId,
        state: WeaknessConfidenceStateV1.emerging,
        recentMistakeCount: recentMistakeCount,
        correctiveHistoryCount: correctiveHistoryCount,
      );
    }
    return null;
  }

  static PersonalizedRecommendationV1? apply({
    required PersonalizedRecommendationV1? recommendation,
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required Iterable<RecentTelemetrySignalV1> recentSignals,
    required Iterable<WeaknessConfidenceHistoryEntryV1> history,
  }) {
    final base = recommendation;
    if (base == null) {
      return null;
    }
    final assessment = assess(
      recommendation: base,
      latestSession: latestSession,
      recentSignals: recentSignals,
      history: history,
    );
    if (assessment == null) {
      return base;
    }
    final nextAction = _resolveNextAction(
      base: base,
      latestSession: latestSession,
      assessment: assessment,
    );
    return PersonalizedRecommendationV1(
      recommendedFocusId: base.recommendedFocusId,
      reasonCode: 'weakness_confidence_${assessment.state.name}',
      shortHintText: _hintForAssessment(assessment),
      recommendedNextAction: nextAction,
      recommendedNextSessionTarget: _resolveTargetEntryId(
        base: base,
        latestSession: latestSession,
        nextAction: nextAction,
      ),
    );
  }

  static PersonalizedNextActionV1 _resolveNextAction({
    required PersonalizedRecommendationV1 base,
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required WeaknessConfidenceAssessmentV1 assessment,
  }) {
    switch (assessment.state) {
      case WeaknessConfidenceStateV1.emerging:
        return base.recommendedNextAction;
      case WeaknessConfidenceStateV1.active:
        if (base.recommendedNextAction ==
                PersonalizedNextActionV1.continueCampaign ||
            base.recommendedNextAction == PersonalizedNextActionV1.nextModule) {
          return PersonalizedNextActionV1.reviewFocus;
        }
        return base.recommendedNextAction;
      case WeaknessConfidenceStateV1.stabilizing:
        if (base.recommendedNextAction ==
                PersonalizedNextActionV1.reviewFocus &&
            latestSession != null &&
            latestSession.isCampaignSession) {
          return PersonalizedNextActionV1.repeatPack;
        }
        return base.recommendedNextAction;
    }
  }

  static String _resolveTargetEntryId({
    required PersonalizedRecommendationV1 base,
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required PersonalizedNextActionV1 nextAction,
  }) {
    if (nextAction == PersonalizedNextActionV1.repeatPack &&
        latestSession != null &&
        latestSession.moduleId.trim().isNotEmpty) {
      return latestSession.moduleId.trim();
    }
    if (nextAction == PersonalizedNextActionV1.reviewFocus) {
      return recommendedModuleIdForFocus(
        focusLabel: base.recommendedFocusId,
        reviewDue: false,
      );
    }
    return base.recommendedNextSessionTarget;
  }

  static String _hintForAssessment(WeaknessConfidenceAssessmentV1 assessment) {
    switch (assessment.state) {
      case WeaknessConfidenceStateV1.emerging:
        return 'This looks like an emerging wobble around ${assessment.focusId}. Stay close to it on the next rep before you widen the route.';
      case WeaknessConfidenceStateV1.active:
        return 'This weakness is still active across recent sessions. Review it directly before you add more difficulty.';
      case WeaknessConfidenceStateV1.stabilizing:
        return 'This weakness is stabilizing after recent corrective work. Keep the next step close and confirm the pattern under pressure.';
    }
  }

  static int _recentMistakeCountForFocus({
    required String focusId,
    required Iterable<RecentTelemetrySignalV1> signals,
  }) {
    var count = 0;
    for (final signal in signals) {
      if (signal.name != 'correct') {
        continue;
      }
      if (signal.payload['correct'] != false) {
        continue;
      }
      final errorType = (signal.payload['error_type'] ?? '').toString().trim();
      final category = (signal.payload['category'] ?? '').toString().trim();
      final subreason = (signal.payload['subreason'] ?? '').toString().trim();
      final mappedFocus =
          focusLabelForPhase1Signal(
            errorType: errorType,
            category: category.isEmpty ? errorType : category,
            subreason: subreason.isEmpty ? errorType : subreason,
          ) ??
          errorType;
      if (mappedFocus.trim() == focusId) {
        count += 1;
      }
    }
    return count;
  }
}
