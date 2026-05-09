import 'package:poker_analyzer/services/outcome_summary_v1.dart';

String? buildHint(OutcomeSummaryV1 summary, {Map<String, String>? context}) {
  if (summary.outcomeKind != OutcomeKindV1.mistake) {
    return null;
  }
  final errorType = _normalizedErrorType(summary.errorType, context: context);
  final hint =
      'Hint: W${summary.worldId} #${summary.beatIndex + 1}, mistake type: $errorType.';
  return _clampHint(hint);
}

String _normalizedErrorType(String? errorType, {Map<String, String>? context}) {
  final raw = (errorType ?? context?['error_type'] ?? '').trim().toLowerCase();
  if (raw.isEmpty) return 'incorrect line';
  return raw.replaceAll('_', ' ');
}

String _clampHint(String value) {
  if (value.length <= 120) return value;
  return '${value.substring(0, 117)}...';
}
