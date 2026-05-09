import 'package:shared_preferences/shared_preferences.dart';

class LearningStatsV1Service {
  LearningStatsV1Service._();

  static final LearningStatsV1Service instance = LearningStatsV1Service._();

  static const String _totalDecisionsKey = 'learning_stats_v1_total_decisions';
  static const String _correctDecisionsKey =
      'learning_stats_v1_correct_decisions';
  static const String _rangeErrorsKey = 'learning_stats_v1_range_errors';
  static const String _sizingErrorsKey = 'learning_stats_v1_sizing_errors';
  static const String _timingErrorsKey = 'learning_stats_v1_timing_errors';
  static const String _logicErrorsKey = 'learning_stats_v1_logic_errors';
  static const String _expectedActionMismatchErrorsKey =
      'learning_stats_v1_expected_action_mismatch_errors';
  static const String _toCallLegalityMismatchErrorsKey =
      'learning_stats_v1_tocall_legality_mismatch_errors';
  static const String _unnecessaryFoldWhenCheckAvailableErrorsKey =
      'learning_stats_v1_unnecessary_fold_when_check_available_errors';
  static const String _updatedAtMsKey = 'learning_stats_v1_updated_at_ms';

  Future<LearningStatsSnapshotV1> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LearningStatsSnapshotV1(
      totalDecisions: prefs.getInt(_totalDecisionsKey) ?? 0,
      correctDecisions: prefs.getInt(_correctDecisionsKey) ?? 0,
      rangeErrors: prefs.getInt(_rangeErrorsKey) ?? 0,
      sizingErrors: prefs.getInt(_sizingErrorsKey) ?? 0,
      timingErrors: prefs.getInt(_timingErrorsKey) ?? 0,
      logicErrors: prefs.getInt(_logicErrorsKey) ?? 0,
      updatedAtMs: prefs.getInt(_updatedAtMsKey),
    );
  }

  Future<void> recordDecision({
    required bool isCorrect,
    required String errorBucket,
  }) async {
    final normalized = _normalizeBucket(errorBucket);
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_totalDecisionsKey) ?? 0) + 1;
    final correct =
        (prefs.getInt(_correctDecisionsKey) ?? 0) + (isCorrect ? 1 : 0);
    await prefs.setInt(_totalDecisionsKey, total);
    await prefs.setInt(_correctDecisionsKey, correct);
    if (!isCorrect) {
      final bucketKey = switch (normalized) {
        'range' => _rangeErrorsKey,
        'sizing' => _sizingErrorsKey,
        'timing' => _timingErrorsKey,
        _ => _logicErrorsKey,
      };
      final next = (prefs.getInt(bucketKey) ?? 0) + 1;
      await prefs.setInt(bucketKey, next);
    }
    await prefs.setInt(_updatedAtMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> incrementExpectedActionMismatchError() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_expectedActionMismatchErrorsKey) ?? 0) + 1;
    await prefs.setInt(_expectedActionMismatchErrorsKey, next);
    await prefs.setInt(_updatedAtMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int> getExpectedActionMismatchErrorCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expectedActionMismatchErrorsKey) ?? 0;
  }

  Future<void> incrementToCallLegalityMismatchError() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_toCallLegalityMismatchErrorsKey) ?? 0) + 1;
    await prefs.setInt(_toCallLegalityMismatchErrorsKey, next);
    await prefs.setInt(_updatedAtMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int> getToCallLegalityMismatchErrorCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_toCallLegalityMismatchErrorsKey) ?? 0;
  }

  Future<void> incrementUnnecessaryFoldWhenCheckAvailableError() async {
    final prefs = await SharedPreferences.getInstance();
    final next =
        (prefs.getInt(_unnecessaryFoldWhenCheckAvailableErrorsKey) ?? 0) + 1;
    await prefs.setInt(_unnecessaryFoldWhenCheckAvailableErrorsKey, next);
    await prefs.setInt(_updatedAtMsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int> getUnnecessaryFoldWhenCheckAvailableErrorCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unnecessaryFoldWhenCheckAvailableErrorsKey) ?? 0;
  }

  String _normalizeBucket(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'range' || value.contains('range')) return 'range';
    if (value == 'sizing' || value.contains('size') || value.contains('bet')) {
      return 'sizing';
    }
    if (value == 'timing' ||
        value.contains('timing') ||
        value.contains('time') ||
        value.contains('select')) {
      return 'timing';
    }
    return 'logic';
  }
}

class LearningStatsSnapshotV1 {
  const LearningStatsSnapshotV1({
    required this.totalDecisions,
    required this.correctDecisions,
    required this.rangeErrors,
    required this.sizingErrors,
    required this.timingErrors,
    required this.logicErrors,
    required this.updatedAtMs,
  });

  final int totalDecisions;
  final int correctDecisions;
  final int rangeErrors;
  final int sizingErrors;
  final int timingErrors;
  final int logicErrors;
  final int? updatedAtMs;

  bool get hasMinimumAccuracySample => totalDecisions >= 5;

  int? get accuracyPercent {
    if (!hasMinimumAccuracySample || totalDecisions <= 0) return null;
    return ((correctDecisions * 100) / totalDecisions).round();
  }

  List<MapEntry<String, int>> topErrorBuckets({int limit = 2}) {
    final buckets =
        <MapEntry<String, int>>[
          MapEntry<String, int>('Range', rangeErrors),
          MapEntry<String, int>('Sizing', sizingErrors),
          MapEntry<String, int>('Timing', timingErrors),
          MapEntry<String, int>('Logic', logicErrors),
        ]..sort((a, b) {
          final countCompare = b.value.compareTo(a.value);
          if (countCompare != 0) return countCompare;
          return a.key.compareTo(b.key);
        });
    return buckets.where((entry) => entry.value > 0).take(limit).toList();
  }
}
