import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

class RecentTopMistakeSummaryV1 {
  const RecentTopMistakeSummaryV1({
    required this.focusLabel,
    required this.bucketLabel,
    required this.count,
    required this.dominantErrorType,
  });

  final String focusLabel;
  final String bucketLabel;
  final int count;
  final String dominantErrorType;
}

class RecentTopMistakeUtilityV1 {
  RecentTopMistakeUtilityV1._();

  static const int _maxRecentMistakeSignals = 12;

  static RecentTopMistakeSummaryV1? deriveTopMistake(
    Iterable<RecentTelemetrySignalV1> signals,
  ) {
    final bucketCounts = <String, int>{};
    final focusByBucket = <String, String>{};
    final dominantErrorByBucket = <String, String>{};
    for (final signal in signals) {
      if (signal.name != 'correct') continue;
      if (signal.payload['correct'] == true) continue;
      final focusLabel = focusLabelForPhase1Signal(
        errorClass: signal.payload['error_class']?.toString(),
        errorType: signal.payload['error_type']?.toString(),
        category: signal.payload['category']?.toString(),
        subreason: signal.payload['subreason']?.toString(),
      );
      if (focusLabel == null || focusLabel.isEmpty) {
        continue;
      }
      final bucketLabel = _bucketLabelForFocus(focusLabel);
      bucketCounts[bucketLabel] = (bucketCounts[bucketLabel] ?? 0) + 1;
      focusByBucket[bucketLabel] = focusLabel;
      dominantErrorByBucket[bucketLabel] = _normalizedErrorType(signal.payload);
    }

    if (bucketCounts.isEmpty) {
      return null;
    }

    final rankedBuckets = bucketCounts.entries.toList(growable: false)
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });
    final topBucket = rankedBuckets.first;
    return RecentTopMistakeSummaryV1(
      focusLabel: focusByBucket[topBucket.key] ?? 'action_order',
      bucketLabel: topBucket.key,
      count: topBucket.value,
      dominantErrorType:
          dominantErrorByBucket[topBucket.key] ?? 'recent_mistake',
    );
  }

  static List<MapEntry<String, int>> deriveTopBuckets(
    Iterable<RecentTelemetrySignalV1> signals, {
    int limit = 1,
  }) {
    final recentCorrectSignals = signals
        .where(
          (signal) =>
              signal.name == 'correct' && signal.payload['correct'] != true,
        )
        .toList(growable: false);
    if (recentCorrectSignals.isEmpty) {
      return const <MapEntry<String, int>>[];
    }
    final recentWindow = recentCorrectSignals.length <= _maxRecentMistakeSignals
        ? recentCorrectSignals
        : recentCorrectSignals.sublist(
            recentCorrectSignals.length - _maxRecentMistakeSignals,
          );
    final bucketCounts = <String, int>{};
    for (final signal in recentWindow) {
      final focusLabel = focusLabelForPhase1Signal(
        errorClass: signal.payload['error_class']?.toString(),
        errorType: signal.payload['error_type']?.toString(),
        category: signal.payload['category']?.toString(),
        subreason: signal.payload['subreason']?.toString(),
      );
      if (focusLabel == null || focusLabel.isEmpty) continue;
      final bucketLabel = _bucketLabelForFocus(focusLabel);
      bucketCounts[bucketLabel] = (bucketCounts[bucketLabel] ?? 0) + 1;
    }
    final rankedBuckets = bucketCounts.entries.toList(growable: false)
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });
    return rankedBuckets.take(limit).toList(growable: false);
  }

  static List<MapEntry<String, int>> mergeTopBuckets({
    required Iterable<MapEntry<String, int>> recentBuckets,
    required Iterable<MapEntry<String, int>> fallbackBuckets,
    int limit = 2,
  }) {
    final merged = <MapEntry<String, int>>[];
    final seen = <String>{};
    void appendBuckets(Iterable<MapEntry<String, int>> buckets) {
      for (final bucket in buckets) {
        final label = bucket.key.trim();
        if (label.isEmpty || bucket.value <= 0 || seen.contains(label)) {
          continue;
        }
        seen.add(label);
        merged.add(MapEntry<String, int>(label, bucket.value));
        if (merged.length >= limit) {
          return;
        }
      }
    }

    appendBuckets(recentBuckets);
    if (merged.length < limit) {
      appendBuckets(fallbackBuckets);
    }
    return merged;
  }

  static String _bucketLabelForFocus(String focusLabel) {
    final moduleId = recommendedModuleIdForFocus(
      focusLabel: focusLabel,
      reviewDue: false,
    );
    return recommendedModuleTitleForId(moduleId);
  }

  static String _normalizedErrorType(Map<String, Object?> payload) {
    final errorType = (payload['error_type'] ?? payload['error_class'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return errorType.isEmpty ? 'recent_mistake' : errorType;
  }
}
