import 'package:poker_analyzer/audit_hub_v1/world_route_ownership_inventory_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world0 route ownership inventory is explicit on current repo', () {
    final report = buildWorldRouteOwnershipInventoryReportV1(world: 0);

    expect(report.worldId, 'W0');
    expect(report.status, WorldRouteOwnershipInventoryStatusV1.executable);
    expect(report.rows, hasLength(4));
    expect(report.metrics['session_drill_surface'], 4);
    expect(report.blockingGaps, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
      ),
    );
  });

  test('world10 route ownership inventory is explicit on current repo', () {
    final report = buildWorldRouteOwnershipInventoryReportV1(world: 10);

    expect(report.worldId, 'W10');
    expect(report.status, WorldRouteOwnershipInventoryStatusV1.executable);
    expect(report.rows, hasLength(4));
    expect(report.metrics['session_drill_surface'], 4);
    expect(report.blockingGaps, isEmpty);
    expect(
      report.measurableProofPath,
      contains(
        'dart run tools/world_route_ownership_inventory_v1.dart --world=10 --json',
      ),
    );
    expect(
      report.rows.map((row) => row.label),
      contains(
        'Tournament track handoff (`world10_spine_followup_v1_b1 -> tournament.s01`)',
      ),
    );
  });
}
