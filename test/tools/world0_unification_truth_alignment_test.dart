import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_route_ownership_inventory_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_screenshot_evidence_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_visual_instrumentation_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'world0 snapshot unification truth matches explicit route, instrumentation, and evidence surfaces',
    () {
      final snapshot =
          jsonDecode(
                File(
                  'assets/audit_hub_v1/operational_snapshot.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;

      final routeInventory = buildWorldRouteOwnershipInventoryReportV1(
        world: 0,
      );
      expect(
        routeInventory.status,
        WorldRouteOwnershipInventoryStatusV1.executable,
      );
      expect(routeInventory.blockingGaps, isEmpty);
      final visualInstrumentation = buildWorldVisualInstrumentationReportV1(
        world: 0,
      );
      expect(
        visualInstrumentation.status,
        WorldVisualInstrumentationStatusV1.executable,
      );
      expect(visualInstrumentation.blockingGaps, isEmpty);
      final screenshotEvidence = buildWorldScreenshotEvidenceReportV1(world: 0);
      expect(
        screenshotEvidence.status,
        WorldScreenshotEvidenceStatusV1.executable,
      );
      expect(screenshotEvidence.blockingGaps, isEmpty);

      final unificationRow = (snapshot['unification_matrix'] as List<Object?>)
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .firstWhere((row) => row['world_id'] == 'W0');
      expect(unificationRow['ownership_truth'], 'session_drill_surface');
      expect(unificationRow['current_status'], 'live');
      expect(unificationRow['runner_family'], 'session_drill_surface');
      expect(unificationRow['visual_family_status'], 'shared');
      expect(
        unificationRow['owner_seam_blocking_unification'],
        'none explicit in current W0 route/instrumentation/evidence truth',
      );

      final worldRow = (snapshot['worlds'] as List<Object?>)
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .firstWhere((row) => row['world_id'] == 'W0');
      expect(
        worldRow['ownership_truth'],
        contains(
          'Shared/local ownership is explicit for representative World0 routes',
        ),
      );
      expect(worldRow['visual_family_status'], 'shared');
      expect(worldRow['active_runner_families'], <String>[
        'session_drill_surface',
      ]);

      final block = (worldRow['blocks'] as List<Object?>)
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .firstWhere((row) => row['block_id'] == 'world_0_core_ladder');
      expect(block['current_status'], 'live');
      expect(block['runner_family'], 'session_drill_surface');
      expect(block['visual_family_status'], 'shared');
      expect(block['owner_truth'], 'session_drill_surface');
      expect(
        block['owner_seam_blocking_unification'],
        'none explicit in current W0 route/instrumentation/evidence truth',
      );
    },
  );
}
