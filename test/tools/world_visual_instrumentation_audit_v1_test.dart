import 'package:poker_analyzer/audit_hub_v1/world_visual_instrumentation_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 visual instrumentation audit is executable on current repo', () {
    final report = buildWorldVisualInstrumentationReportV1(world: 0);

    expect(report.worldId, 'W0');
    expect(report.status, WorldVisualInstrumentationStatusV1.executable);
    expect(report.defaultsFilePresent, isTrue);
    expect(
      report.coveredSessionIds,
      containsAll(const <String>['w0.s01', 'w0.s05', 'w0.s10']),
    );
    expect(report.blockingGaps, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/world_visual_instrumentation_audit_v1.dart --world=0 --json',
      ),
    );
  });

  test('world10 visual instrumentation audit is executable on current repo', () {
    final report = buildWorldVisualInstrumentationReportV1(world: 10);

    expect(report.worldId, 'W10');
    expect(report.status, WorldVisualInstrumentationStatusV1.executable);
    expect(report.defaultsFilePresent, isTrue);
    expect(
      report.coveredSessionIds,
      containsAll(const <String>['cash.s01', 'tournament.s05', 'mixed.s10']),
    );
    expect(report.blockingGaps, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/world_visual_instrumentation_audit_v1.dart --world=10 --json',
      ),
    );
  });
}
