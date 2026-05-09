import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 drills expose explicit feedback coverage', () {
    final drillFiles =
        Directory('content/worlds/world0/v1/sessions')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .where(
              (file) => file.path.contains(
                '${Platform.pathSeparator}drills${Platform.pathSeparator}',
              ),
            )
            .toList(growable: false);

    expect(drillFiles, hasLength(71));
    for (final file in drillFiles) {
      final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      expect(
        (decoded['feedback_correct_v1'] as String?)?.trim(),
        isNotEmpty,
        reason: '${file.path} is missing feedback_correct_v1',
      );
      expect(
        (decoded['feedback_incorrect_v1'] as String?)?.trim(),
        isNotEmpty,
        reason: '${file.path} is missing feedback_incorrect_v1',
      );
    }

    final snapshot = jsonDecode(
      File('assets/audit_hub_v1/operational_snapshot.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final worldSnapshot =
        (snapshot['worlds'] as List<Object?>)
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .firstWhere((row) => row['world_id'] == 'W0');

    final report = buildWorldPedagogicalProgressionReportV1(
      worldSnapshot: worldSnapshot,
    );
    expect(report.wrongAnswerFeedbackQualityStatus, PedagogicalProgressionTruthStatusV1.clear);
    expect(
      report.findings.where((finding) => finding.category == 'wrong_answer_feedback_quality'),
      isEmpty,
    );
  });
}
