import 'dart:convert';

const worldRouteOwnershipInventoryToolPathV1 =
    'tools/world_route_ownership_inventory_v1.dart';

enum WorldRouteOwnershipInventoryStatusV1 {
  executable('executable'),
  partial('partial'),
  missing('missing');

  const WorldRouteOwnershipInventoryStatusV1(this.wireValue);

  final String wireValue;
}

class WorldRouteOwnershipInventoryRowV1 {
  const WorldRouteOwnershipInventoryRowV1({
    required this.label,
    required this.route,
    required this.expectation,
    required this.note,
  });

  final String label;
  final String route;
  final String expectation;
  final String note;

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'route': route,
    'expectation': expectation,
    'note': note,
  };
}

class WorldRouteOwnershipInventoryReportV1 {
  const WorldRouteOwnershipInventoryReportV1({
    required this.worldId,
    required this.status,
    required this.summary,
    required this.likelySeam,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.rows,
    required this.metrics,
    required this.blockingGaps,
  });

  final String worldId;
  final WorldRouteOwnershipInventoryStatusV1 status;
  final String summary;
  final String likelySeam;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final List<WorldRouteOwnershipInventoryRowV1> rows;
  final Map<String, int> metrics;
  final List<String> blockingGaps;

  Map<String, Object?> toJson() => <String, Object?>{
    'world_id': worldId,
    'inventory_status': status.wireValue,
    'summary': summary,
    'likely_seam': likelySeam,
    'owner_files': ownerFiles,
    'measurable_proof_path': measurableProofPath,
    'rows': rows.map((row) => row.toJson()).toList(growable: false),
    'metrics': metrics,
    'blocking_gaps': blockingGaps,
  };
}

WorldRouteOwnershipInventoryReportV1 buildWorldRouteOwnershipInventoryReportV1({
  required int world,
}) {
  if (world == 0) {
    const ownerFiles = <String>[
      'lib/services/placement_service_v1.dart',
      'test/services/placement_service_v1_test.dart',
      'lib/services/drill_runtime_adapter_v1.dart',
      'lib/ui_v2/screens/session_drill_player_v1_screen.dart',
      'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
      'test/ui_v2/drill_host_capability_contract_v1_test.dart',
    ];
    const measurableProofPath = <String>[
      'dart run tools/world_route_ownership_inventory_v1.dart --world=0 --json',
      'flutter test test/services/placement_service_v1_test.dart',
      'dart test test/tools/runtime_world_session_health_audit_v1_test.dart',
      'flutter test test/ui_v2/drill_host_capability_contract_v1_test.dart',
    ];
    const rows = <WorldRouteOwnershipInventoryRowV1>[
      WorldRouteOwnershipInventoryRowV1(
        label: 'Beginner table-basics repair route',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Placement weak-area routing explicitly repairs table basics through `w0.s01`.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label: 'World0 first-run orientation drills (`w0.s01`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Runtime health classifies `w0.s01` as a canonical single-step session route.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label: 'World0 repeat-reading drills (`w0.s05`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Repeat-reading content stays inside the same governed session drill route family.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label: 'World0 checkpoint drills (`w0.s10`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Checkpoint content remains inside the same governed session drill route family.',
      ),
    ];

    return WorldRouteOwnershipInventoryReportV1(
      worldId: 'W0',
      status: WorldRouteOwnershipInventoryStatusV1.executable,
      summary:
          'Shared/local ownership is explicit for representative World0 routes (4 session-drill surfaces, 0 shared, 0 expected local legacy differences).',
      likelySeam: 'World0 shared-vs-local route ownership',
      ownerFiles: ownerFiles,
      measurableProofPath: measurableProofPath,
      rows: rows,
      metrics: const <String, int>{
        'session_drill_surface': 4,
        'shared_embedded': 0,
        'expected_local_difference': 0,
      },
      blockingGaps: const <String>[],
    );
  }

  if (world == 10) {
    const ownerFiles = <String>[
      'lib/canonical/canonical_truth_map_v1.dart',
      'lib/canonical/progression_route_story_v1.dart',
      'lib/services/drill_runtime_adapter_v1.dart',
      'lib/services/progress_service.dart',
      'test/guards/world10_campaign_routing_contract_test.dart',
      'test/guards/world10_followup_map_campaign_runtime_sync_contract_test.dart',
      'test/guards/session_result_spine_continuation_parity_contract_test.dart',
      'test/tools/runtime_world_session_health_audit_v1_test.dart',
    ];
    const measurableProofPath = <String>[
      'dart run tools/world_route_ownership_inventory_v1.dart --world=10 --json',
      'flutter test test/guards/world10_campaign_routing_contract_test.dart',
      'flutter test test/guards/world10_followup_map_campaign_runtime_sync_contract_test.dart',
      'flutter test test/guards/session_result_spine_continuation_parity_contract_test.dart',
      'dart test test/tools/runtime_world_session_health_audit_v1_test.dart',
    ];
    const rows = <WorldRouteOwnershipInventoryRowV1>[
      WorldRouteOwnershipInventoryRowV1(
        label: 'World10 campaign entry (`world10_spine_campaign_v1`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Campaign launch stays on the canonical session-drill player for the World10 core spine.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label: 'Cash track handoff (`world10_spine_followup_v1_b0 -> cash.s01`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Canonical truth map, map launch, and runtime adapter all resolve the cash followup to `cash.s01`.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label:
            'Tournament track handoff (`world10_spine_followup_v1_b1 -> tournament.s01`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Result continuation, map launch, and runtime adapter all resolve the tournament followup to `tournament.s01`.',
      ),
      WorldRouteOwnershipInventoryRowV1(
        label: 'Mixed track handoff (`world10_spine_followup_v1_b2 -> mixed.s01`)',
        route: 'session_drill_surface',
        expectation: 'pass',
        note:
            'Canonical truth map, map launch, and runtime adapter all resolve the mixed followup to `mixed.s01`.',
      ),
    ];

    return WorldRouteOwnershipInventoryReportV1(
      worldId: 'W10',
      status: WorldRouteOwnershipInventoryStatusV1.executable,
      summary:
          'Shared/local ownership is explicit for representative World10 routes (4 session-drill surfaces spanning campaign entry plus all three track handoffs, 0 shared, 0 expected local legacy differences).',
      likelySeam: 'World10 shared-vs-local route ownership',
      ownerFiles: ownerFiles,
      measurableProofPath: measurableProofPath,
      rows: rows,
      metrics: const <String, int>{
        'session_drill_surface': 4,
        'shared_embedded': 0,
        'expected_local_difference': 0,
      },
      blockingGaps: const <String>[],
    );
  }

  if (world != 0) {
    return WorldRouteOwnershipInventoryReportV1(
      worldId: 'W$world',
      status: WorldRouteOwnershipInventoryStatusV1.missing,
      summary:
          'No explicit repo-owned world route ownership inventory is wired yet for W$world.',
      likelySeam: 'shared-vs-local route ownership',
      ownerFiles: const <String>[],
      measurableProofPath: <String>[
        'dart run $worldRouteOwnershipInventoryToolPathV1 --world=$world --json',
      ],
      rows: const <WorldRouteOwnershipInventoryRowV1>[],
      metrics: const <String, int>{},
      blockingGaps: <String>[
        'W$world does not yet have a repo-owned representative route ownership inventory.',
      ],
    );
  }

  throw StateError('Unreachable world route ownership inventory branch for W$world');
}

String encodeWorldRouteOwnershipInventoryReportJsonV1(
  WorldRouteOwnershipInventoryReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

String renderWorldRouteOwnershipInventoryReportV1(
  WorldRouteOwnershipInventoryReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('WORLD_ROUTE_OWNERSHIP_INVENTORY_V1')
    ..writeln('WORLD\t${report.worldId}')
    ..writeln('STATUS\t${report.status.wireValue}')
    ..writeln('SUMMARY\t${report.summary}')
    ..writeln('LIKELY_SEAM\t${report.likelySeam}');
  if (report.metrics.isNotEmpty) {
    final metrics = report.metrics.keys.toList()..sort();
    buffer.writeln(
      'METRICS\t${metrics.map((key) => '$key=${report.metrics[key]}').join("\t")}',
    );
  }
  for (final row in report.rows) {
    buffer.writeln(
      'ROW\t${row.label}\t${row.route}\t${row.expectation}\t${row.note}',
    );
  }
  if (report.blockingGaps.isNotEmpty) {
    buffer.writeln('BLOCKERS');
    for (final gap in report.blockingGaps) {
      buffer.writeln('- $gap');
    }
  }
  return buffer.toString();
}
