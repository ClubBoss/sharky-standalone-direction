import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 opener framing truth is clear when world docs and session ladder are explicit', () {
    final snapshot = jsonDecode(
      File('assets/audit_hub_v1/operational_snapshot.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final worlds =
        (snapshot['worlds'] as List<Object?>)
            .whereType<Map>()
            .map(Map<String, Object?>.from)
            .toList(growable: false);

    final world0 = worlds.firstWhere((row) => row['world_id'] == 'W0');
    final world1 = worlds.firstWhere((row) => row['world_id'] == 'W1');

    final world0Report = buildWorldPedagogicalProgressionReportV1(
      worldSnapshot: world0,
    );
    final world1Report = buildWorldPedagogicalProgressionReportV1(
      worldSnapshot: world1,
    );

    expect(
      world0Report.introFramingOnboardingQualityStatus,
      PedagogicalProgressionTruthStatusV1.clear,
    );
    expect(
      world0Report.findings.where(
        (finding) => finding.category == 'intro_framing_onboarding_quality',
      ),
      isEmpty,
    );
    expect(
      world1Report.introFramingOnboardingQualityStatus,
      PedagogicalProgressionTruthStatusV1.surfacedGap,
    );
  });
}
