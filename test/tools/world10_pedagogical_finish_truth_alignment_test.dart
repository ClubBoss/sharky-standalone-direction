import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'world10 pedagogical finish clears when authored finish support is present',
    () {
      final snapshot =
          jsonDecode(
                File(
                  'assets/audit_hub_v1/operational_snapshot.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final worlds = (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
      final world10 = worlds.firstWhere((world) => world['world_id'] == 'W10');

      final report = buildWorldPedagogicalProgressionReportV1(
        worldSnapshot: world10,
      );

      expect(report.worldId, 'W10');
      expect(
        report.worldPedagogicalFinishStatus,
        PedagogicalProgressionTruthStatusV1.clear,
      );
      expect(
        report.findings.where(
          (finding) =>
              finding.category == 'world_pedagogical_finish_completeness',
        ),
        isEmpty,
      );
    },
  );
}
