import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_route_ownership_inventory_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_screenshot_evidence_audit_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/world_visual_instrumentation_audit_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'world0 pedagogical finish truth closes when opener, drills, and proof surfaces are explicit',
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

      final report = buildWorldPedagogicalProgressionReportV1(
        worldSnapshot: worldSnapshot,
      );
      expect(report.status, PedagogicalProgressionTruthStatusV1.clear);
      expect(
        report.worldPedagogicalFinishStatus,
        PedagogicalProgressionTruthStatusV1.clear,
      );
      expect(report.findings, isEmpty);

      expect(worldSnapshot['readiness_status'], 'done');
      expect(worldSnapshot['top_open_gaps'], isEmpty);
      expect(worldSnapshot['release_grade_blocker_note'], isEmpty);
    },
  );
}
