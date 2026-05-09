import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 pedagogical/progression audit surfaces progression and feedback truth', () {
    final snapshot = jsonDecode(
      File('assets/audit_hub_v1/operational_snapshot.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final worlds =
        (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false);
    final world0 = worlds.firstWhere((world) => world['world_id'] == 'W0');
    final report = buildWorldPedagogicalProgressionReportV1(
      worldSnapshot: world0,
    );

    expect(report.worldId, 'W0');
    expect(
      report.progressionCorrectnessStatus,
      PedagogicalProgressionTruthStatusV1.surfacedGap,
    );
    expect(
      report.wrongAnswerFeedbackQualityStatus,
      PedagogicalProgressionTruthStatusV1.surfacedGap,
    );
    expect(
      report.findings.any(
        (finding) => finding.category == 'progression_correctness',
      ),
      isTrue,
    );
    expect(
      report.findings.any(
        (finding) => finding.category == 'wrong_answer_feedback_quality',
      ),
      isTrue,
    );
  });

  test('pedagogical/progression truth summary aggregates world reports', () {
    final snapshot = jsonDecode(
      File('assets/audit_hub_v1/operational_snapshot.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final worlds =
        (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false);
    final reports = buildWorldPedagogicalProgressionReportsV1(worlds: worlds);
    final summary = buildPedagogicalProgressionTruthSummaryJsonV1(
      reports: reports,
    );

    expect(summary['status'], isNotNull);
    expect(summary['open_finding_count'], isA<int>());
    expect(summary['affected_worlds'], isA<List<Object?>>());
    expect(summary['category_counts'], isA<Map<Object?, Object?>>());
    expect(
      (summary['source_truth_owners'] as List<Object?>)
          .whereType<String>()
          .contains(progressionPrerequisiteMatrixPathV1),
      isTrue,
    );
  });
}
