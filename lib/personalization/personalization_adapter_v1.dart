import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/personalization/personalization_recommender_v1.dart';

typedef PersonalizationLogEvent =
    Future<void> Function(String name, Map<String, dynamic> payload);

PersonalizationRecommendation recommendFromReports({
  Map<String, Object?>? phase1ReportJson,
  Map<String, Object?>? phase2ReportJson,
  Map<String, Object?>? phase3ReportJson,
  PersonalizationLogEvent? logEvent,
}) {
  final presence = [
    if (phase1ReportJson != null) 'phase1',
    if (phase2ReportJson != null) 'phase2',
    if (phase3ReportJson != null) 'phase3',
  ];
  final base = recommend(
    phase1: phase1ReportJson,
    phase2: phase2ReportJson,
    phase3: phase3ReportJson,
  );
  final reason =
      '${base.reason}; inputs=${presence.isEmpty ? 'none' : presence.join(',')}';
  var finalReason = reason;
  final focusLabel = _deriveFocusLabel(phase1ReportJson);
  if (focusLabel != null) {
    finalReason = '$finalReason; focus_label=$focusLabel';
    final nextAction = base.action.name;
    if (logEvent != null) {
      logEvent(TelemetryEvents.focusLabelApplied, {
        'source': 'phase1',
        'focus_label': focusLabel,
        'next_action': nextAction,
      });
    }
  }
  return PersonalizationRecommendation(
    action: base.action,
    reason: finalReason,
  );
}

String? _deriveFocusLabel(Map<String, Object?>? phase1ReportJson) {
  final runs = phase1ReportJson?['runs'];
  if (runs is! List || runs.isEmpty) {
    return null;
  }
  for (final run in runs) {
    if (run is! Map) {
      continue;
    }
    final attempts = run['attempts'];
    if (attempts is! List) {
      continue;
    }
    for (final attempt in attempts) {
      if (attempt is! Map) {
        continue;
      }
      final errorType = attempt['error_type'];
      if (errorType == 'wrong_action') {
        return 'range';
      }
    }
  }
  return null;
}
