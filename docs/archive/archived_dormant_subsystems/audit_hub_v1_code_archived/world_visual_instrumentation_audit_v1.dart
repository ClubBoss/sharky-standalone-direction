import 'dart:convert';
import 'dart:io';

const worldVisualInstrumentationAuditToolPathV1 =
    'tools/world_visual_instrumentation_audit_v1.dart';
const _world0DefaultsPathV1 =
    'content/worlds/world0/v1/sessions/spatial_projection_defaults_v1.json';
const _world10CashDefaultsPathV1 =
    'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json';
const _world10TournamentDefaultsPathV1 =
    'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json';
const _world10MixedDefaultsPathV1 =
    'content/worlds/world10/v1/tracks/mixed/sessions/spatial_projection_defaults_v1.json';

enum WorldVisualInstrumentationStatusV1 {
  executable('executable'),
  partial('partial'),
  missing('missing');

  const WorldVisualInstrumentationStatusV1(this.wireValue);

  final String wireValue;
}

class WorldVisualInstrumentationReportV1 {
  const WorldVisualInstrumentationReportV1({
    required this.worldId,
    required this.status,
    required this.defaultsFilePresent,
    required this.coveredSessionIds,
    required this.missingRepresentativeSessionIds,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.proofSurfaceTruth,
    required this.blockingGaps,
  });

  final String worldId;
  final WorldVisualInstrumentationStatusV1 status;
  final bool defaultsFilePresent;
  final List<String> coveredSessionIds;
  final List<String> missingRepresentativeSessionIds;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final String proofSurfaceTruth;
  final List<String> blockingGaps;

  Map<String, Object?> toJson() => <String, Object?>{
    'world_id': worldId,
    'instrumentation_status': status.wireValue,
    'defaults_file_present': defaultsFilePresent,
    'covered_session_ids': coveredSessionIds,
    'missing_representative_session_ids': missingRepresentativeSessionIds,
    'owner_files': ownerFiles,
    'measurable_proof_path': measurableProofPath,
    'proof_surface_truth': proofSurfaceTruth,
    'blocking_gaps': blockingGaps,
  };
}

WorldVisualInstrumentationReportV1 buildWorldVisualInstrumentationReportV1({
  String rootPath = '.',
  required int world,
}) {
  final worldId = 'W$world';
  if (world == 10) {
    const representativeSessionsByDefaultsPath = <String, String>{
      _world10CashDefaultsPathV1: 'cash.s01',
      _world10TournamentDefaultsPathV1: 'tournament.s05',
      _world10MixedDefaultsPathV1: 'mixed.s10',
    };
    final coveredSessionIds = <String>[];
    final missingRepresentativeSessionIds = <String>[];
    final blockingGaps = <String>[];
    var defaultsFilePresent = true;

    for (final entry in representativeSessionsByDefaultsPath.entries) {
      final defaultsPath = entry.key;
      final representativeSessionId = entry.value;
      final defaultsFile = File('$rootPath/$defaultsPath');
      if (!defaultsFile.existsSync()) {
        defaultsFilePresent = false;
        missingRepresentativeSessionIds.add(representativeSessionId);
        blockingGaps.add('Missing `$defaultsPath`.');
        continue;
      }

      try {
        final decoded = jsonDecode(defaultsFile.readAsStringSync());
        if (decoded is! Map<String, Object?>) {
          missingRepresentativeSessionIds.add(representativeSessionId);
          blockingGaps.add('`$defaultsPath` must decode to a JSON object.');
          continue;
        }
        final rawSessions = decoded['sessions'];
        if (rawSessions is! Map<String, Object?>) {
          missingRepresentativeSessionIds.add(representativeSessionId);
          blockingGaps.add('`$defaultsPath` must contain a `sessions` object.');
          continue;
        }
        final sessionEntry = rawSessions[representativeSessionId];
        if (sessionEntry is! Map<String, Object?>) {
          missingRepresentativeSessionIds.add(representativeSessionId);
          continue;
        }
        final drillIds = sessionEntry['drill_ids'];
        final shared = sessionEntry['shared'];
        final validDrillIds =
            drillIds is List<Object?> &&
            drillIds.whereType<String>().isNotEmpty;
        final validShared = shared is Map<String, Object?> && shared.isNotEmpty;
        if (validDrillIds && validShared) {
          coveredSessionIds.add(representativeSessionId);
        } else {
          missingRepresentativeSessionIds.add(representativeSessionId);
        }
      } catch (error) {
        missingRepresentativeSessionIds.add(representativeSessionId);
        blockingGaps.add('Failed to parse `$defaultsPath`: $error');
      }
    }

    if (missingRepresentativeSessionIds.isNotEmpty) {
      blockingGaps.add(
        'W10 track defaults do not yet cover representative visual sessions: ${missingRepresentativeSessionIds.join(', ')}.',
      );
    }

    final status = blockingGaps.isEmpty
        ? WorldVisualInstrumentationStatusV1.executable
        : defaultsFilePresent
        ? WorldVisualInstrumentationStatusV1.partial
        : WorldVisualInstrumentationStatusV1.missing;

    const ownerFiles = <String>[
      _world10CashDefaultsPathV1,
      _world10TournamentDefaultsPathV1,
      _world10MixedDefaultsPathV1,
      'lib/services/session_drill_projection_defaults_v1.dart',
      'lib/services/drill_runtime_adapter_v1.dart',
      'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      'test/services/drill_runtime_adapter_v1_asset_bundle_test.dart',
      'test/ui_v2/session_drill_player_completion_surface_contract_test.dart',
    ];
    const measurableProofPath = <String>[
      'dart run tools/world_visual_instrumentation_audit_v1.dart --world=10 --json',
      'flutter test test/services/drill_runtime_adapter_v1_asset_bundle_test.dart',
      'flutter test test/ui_v2/session_drill_player_completion_surface_contract_test.dart',
    ];
    final proofSurfaceTruth =
        status == WorldVisualInstrumentationStatusV1.executable
        ? 'Visual instrumentation is wired for representative World10 track surfaces: cash.s01, tournament.s05, and mixed.s10 are projection-backed through the bundled track defaults assets.'
        : 'World10 visual instrumentation remains ${status.wireValue}; blocking gaps: ${blockingGaps.join(' | ')}';

    return WorldVisualInstrumentationReportV1(
      worldId: worldId,
      status: status,
      defaultsFilePresent: defaultsFilePresent,
      coveredSessionIds: coveredSessionIds,
      missingRepresentativeSessionIds: missingRepresentativeSessionIds,
      ownerFiles: ownerFiles,
      measurableProofPath: measurableProofPath,
      proofSurfaceTruth: proofSurfaceTruth,
      blockingGaps: blockingGaps,
    );
  }

  if (world != 0) {
    return WorldVisualInstrumentationReportV1(
      worldId: worldId,
      status: WorldVisualInstrumentationStatusV1.missing,
      defaultsFilePresent: false,
      coveredSessionIds: const <String>[],
      missingRepresentativeSessionIds: const <String>[],
      ownerFiles: const <String>[],
      measurableProofPath: <String>[
        'dart run $worldVisualInstrumentationAuditToolPathV1 --world=$world --json',
      ],
      proofSurfaceTruth:
          'No repo-owned representative visual instrumentation audit is wired yet for $worldId.',
      blockingGaps: <String>[
        '$worldId does not yet have a repo-owned representative visual instrumentation surface.',
      ],
    );
  }

  const representativeSessionIds = <String>['w0.s01', 'w0.s05', 'w0.s10'];
  final defaultsFile = File('$rootPath/$_world0DefaultsPathV1');
  final defaultsFilePresent = defaultsFile.existsSync();
  final coveredSessionIds = <String>[];
  final missingRepresentativeSessionIds = <String>[];
  final blockingGaps = <String>[];

  Map<String, Object?>? sessions;
  if (!defaultsFilePresent) {
    blockingGaps.add('Missing `$_world0DefaultsPathV1`.');
  } else {
    try {
      final decoded = jsonDecode(defaultsFile.readAsStringSync());
      if (decoded is! Map<String, Object?>) {
        blockingGaps.add(
          '`$_world0DefaultsPathV1` must decode to a JSON object.',
        );
      } else {
        final rawSessions = decoded['sessions'];
        if (rawSessions is! Map<String, Object?>) {
          blockingGaps.add(
            '`$_world0DefaultsPathV1` must contain a `sessions` object.',
          );
        } else {
          sessions = rawSessions;
        }
      }
    } catch (error) {
      blockingGaps.add('Failed to parse `$_world0DefaultsPathV1`: $error');
    }
  }

  if (sessions != null) {
    for (final sessionId in representativeSessionIds) {
      final entry = sessions[sessionId];
      if (entry is! Map<String, Object?>) {
        missingRepresentativeSessionIds.add(sessionId);
        continue;
      }
      final drillIds = entry['drill_ids'];
      final shared = entry['shared'];
      final validDrillIds =
          drillIds is List<Object?> && drillIds.whereType<String>().isNotEmpty;
      final validShared = shared is Map<String, Object?> && shared.isNotEmpty;
      if (validDrillIds && validShared) {
        coveredSessionIds.add(sessionId);
      } else {
        missingRepresentativeSessionIds.add(sessionId);
      }
    }
  }

  if (missingRepresentativeSessionIds.isNotEmpty) {
    blockingGaps.add(
      'W0 defaults do not yet cover representative visual sessions: ${missingRepresentativeSessionIds.join(', ')}.',
    );
  }

  final status = blockingGaps.isEmpty
      ? WorldVisualInstrumentationStatusV1.executable
      : defaultsFilePresent
      ? WorldVisualInstrumentationStatusV1.partial
      : WorldVisualInstrumentationStatusV1.missing;

  final ownerFiles = <String>[
    _world0DefaultsPathV1,
    'lib/services/session_drill_projection_defaults_v1.dart',
    'lib/services/drill_runtime_adapter_v1.dart',
    'lib/ui_v2/screens/session_drill_player_v1_screen.dart',
    'test/services/world0_visual_instrumentation_defaults_v1_test.dart',
    'test/ui_v2/drill_host_capability_contract_v1_test.dart',
    'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
  ];
  final measurableProofPath = <String>[
    'dart run $worldVisualInstrumentationAuditToolPathV1 --world=0 --json',
    'flutter test test/services/world0_visual_instrumentation_defaults_v1_test.dart',
    'flutter test test/ui_v2/drill_host_capability_contract_v1_test.dart',
    'flutter test test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
  ];
  final proofSurfaceTruth =
      status == WorldVisualInstrumentationStatusV1.executable
      ? 'Visual instrumentation is wired for representative World0 session-drill surfaces: defaults asset present and sessions ${coveredSessionIds.join(', ')} are projection-backed.'
      : 'World0 visual instrumentation remains ${status.wireValue}; blocking gaps: ${blockingGaps.join(' | ')}';

  return WorldVisualInstrumentationReportV1(
    worldId: worldId,
    status: status,
    defaultsFilePresent: defaultsFilePresent,
    coveredSessionIds: coveredSessionIds,
    missingRepresentativeSessionIds: missingRepresentativeSessionIds,
    ownerFiles: ownerFiles,
    measurableProofPath: measurableProofPath,
    proofSurfaceTruth: proofSurfaceTruth,
    blockingGaps: blockingGaps,
  );
}

String encodeWorldVisualInstrumentationReportJsonV1(
  WorldVisualInstrumentationReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

String renderWorldVisualInstrumentationReportV1(
  WorldVisualInstrumentationReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('WORLD_VISUAL_INSTRUMENTATION_AUDIT_V1')
    ..writeln('WORLD\t${report.worldId}')
    ..writeln('STATUS\t${report.status.wireValue}')
    ..writeln(
      'DEFAULTS_FILE\t${report.defaultsFilePresent ? 'present' : 'missing'}',
    )
    ..writeln('PROOF_SURFACE\t${report.proofSurfaceTruth}');
  if (report.coveredSessionIds.isNotEmpty) {
    buffer.writeln('COVERED_SESSIONS\t${report.coveredSessionIds.join(",")}');
  }
  if (report.missingRepresentativeSessionIds.isNotEmpty) {
    buffer.writeln(
      'MISSING_REPRESENTATIVE_SESSIONS\t${report.missingRepresentativeSessionIds.join(",")}',
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
