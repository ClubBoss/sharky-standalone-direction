import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'world0 foundational action buttons do not count as progression drift',
    () {
      final snapshot =
          jsonDecode(
                File(
                  'assets/audit_hub_v1/operational_snapshot.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final worldSnapshot = (snapshot['worlds'] as List<Object?>)
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .firstWhere((row) => row['world_id'] == 'W0');

      final report = buildWorldPedagogicalProgressionReportV1(
        worldSnapshot: worldSnapshot,
      );

      expect(
        report.progressionCorrectnessStatus,
        PedagogicalProgressionTruthStatusV1.clear,
      );
      expect(
        report.findings.where(
          (finding) => finding.category == 'progression_correctness',
        ),
        isEmpty,
      );
    },
  );
}
