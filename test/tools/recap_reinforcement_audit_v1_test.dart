import 'dart:convert';

import 'package:test/test.dart';

import '../../tools/recap_reinforcement_audit_v1.dart';

void main() {
  test('recap reinforcement audit is deterministic on current repo truth', () {
    final first = buildRecapReinforcementAuditReportV1();
    final second = buildRecapReinforcementAuditReportV1();

    expect(
      encodeRecapReinforcementAuditReportJsonV1(first),
      encodeRecapReinforcementAuditReportJsonV1(second),
    );
    expect(
      renderRecapReinforcementAuditReportV1(first),
      renderRecapReinforcementAuditReportV1(second),
    );
  });

  test('representative recap families are included and resolved', () {
    final report = buildRecapReinforcementAuditReportV1();
    final bySession = <String, RecapReinforcementAuditRowV1>{
      for (final row in report.rows) row.sessionId: row,
    };

    final earlyCheckpoint = bySession['w1.s06']!;
    expect(earlyCheckpoint.patternId, 'specialized_checkpoint_chain_v1');
    expect(earlyCheckpoint.placementKind, 'specialized_checkpoint');
    expect(earlyCheckpoint.rolloutOrder, 10);
    expect(earlyCheckpoint.exists, isTrue);

    final blockRecap = bySession['w5.s04']!;
    expect(blockRecap.patternId, 'block_closure_recap_chain_v1');
    expect(blockRecap.placementKind, 'block_closure_recap');
    expect(blockRecap.exists, isTrue);

    final synthesis = bySession['w8.s10']!;
    expect(synthesis.patternId, 'synthesis_checkpoint_closure_v1');
    expect(synthesis.placementKind, 'synthesis_checkpoint_closure');
    expect(synthesis.exists, isTrue);

    final trackRecap = bySession['cash.s03']!;
    expect(trackRecap.patternId, 'world10_applied_track_recap_v1');
    expect(trackRecap.trackKind, 'cash');
    expect(trackRecap.exists, isTrue);
  });

  test('json payload carries stable summary counts and no missing anchors', () {
    final report = buildRecapReinforcementAuditReportV1();
    final decoded =
        jsonDecode(encodeRecapReinforcementAuditReportJsonV1(report))
            as Map<String, dynamic>;

    expect(decoded['version'], 'v1');
    final summary = decoded['summary'] as Map<String, dynamic>;
    expect(summary['total_rows'], 23);
    expect(summary['existing_rows'], 23);
    expect(summary['missing_rows'], 0);
    expect(
      (summary['pattern_counts']
          as Map<String, dynamic>)['world10_applied_track_recap_v1'],
      3,
    );
  });
}
