import 'package:poker_analyzer/audit_hub_v1/session_world_truth_surface_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 truth surface is executable on current repo', () {
    final report = buildSessionWorldTruthSurfaceReportV1(world: 0);

    expect(report.worldId, 'W0');
    expect(report.status, SessionWorldTruthSurfaceStatusV1.executable);
    expect(report.worldMarkdownPresent, isTrue);
    expect(report.sessionsIndexPresent, isTrue);
    expect(report.diskSessionCount, 10);
    expect(report.manifestSessionCount, 10);
    expect(report.indexMatchesManifest, isTrue);
    expect(report.missingDrillPaths, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/session_world_truth_surface_audit_v1.dart --world=0 --json',
      ),
    );
  });

  test('world10 truth surface is executable on current repo', () {
    final report = buildSessionWorldTruthSurfaceReportV1(world: 10);

    expect(report.worldId, 'W10');
    expect(report.status, SessionWorldTruthSurfaceStatusV1.executable);
    expect(report.worldMarkdownPresent, isTrue);
    expect(report.sessionsIndexPresent, isTrue);
    expect(report.diskSessionCount, 10);
    expect(report.manifestSessionCount, 10);
    expect(report.manifestDrillCount, 80);
    expect(report.diskDrillCount, 80);
    expect(report.indexMatchesManifest, isTrue);
    expect(report.missingDrillPaths, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/session_world_truth_surface_audit_v1.dart --world=10 --json',
      ),
    );
  });
}
