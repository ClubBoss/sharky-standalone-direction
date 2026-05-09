import 'dart:convert';
import 'dart:io';

const worldScreenshotEvidenceCaptureToolPathV1 =
    'tools/world_screenshot_evidence_capture_v1.dart';
const worldScreenshotEvidenceAuditToolPathV1 =
    'tools/world_screenshot_evidence_audit_v1.dart';
const _world0EvidenceDirPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world0';
const _world0EvidenceManifestPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world0/manifest.json';
const _world10EvidenceDirPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world10';
const _world10EvidenceManifestPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world10/manifest.json';
const _worldScreenshotMinBytesV1 = 5000;

enum WorldScreenshotEvidenceStatusV1 {
  executable('executable'),
  partial('partial'),
  missing('missing');

  const WorldScreenshotEvidenceStatusV1(this.wireValue);

  final String wireValue;
}

class WorldScreenshotEvidenceEntryV1 {
  const WorldScreenshotEvidenceEntryV1({
    required this.sessionId,
    required this.path,
    required this.bytes,
  });

  final String sessionId;
  final String path;
  final int bytes;

  Map<String, Object?> toJson() => <String, Object?>{
    'session_id': sessionId,
    'path': path,
    'bytes': bytes,
  };
}

class WorldScreenshotEvidenceReportV1 {
  const WorldScreenshotEvidenceReportV1({
    required this.worldId,
    required this.status,
    required this.screenshotEvidenceCount,
    required this.coveredSessionIds,
    required this.missingRepresentativeSessionIds,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.proofSurfaceTruth,
    required this.blockingGaps,
    required this.entries,
  });

  final String worldId;
  final WorldScreenshotEvidenceStatusV1 status;
  final int screenshotEvidenceCount;
  final List<String> coveredSessionIds;
  final List<String> missingRepresentativeSessionIds;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final String proofSurfaceTruth;
  final List<String> blockingGaps;
  final List<WorldScreenshotEvidenceEntryV1> entries;

  Map<String, Object?> toJson() => <String, Object?>{
    'world_id': worldId,
    'evidence_status': status.wireValue,
    'screenshot_evidence_count': screenshotEvidenceCount,
    'covered_session_ids': coveredSessionIds,
    'missing_representative_session_ids': missingRepresentativeSessionIds,
    'owner_files': ownerFiles,
    'measurable_proof_path': measurableProofPath,
    'proof_surface_truth': proofSurfaceTruth,
    'blocking_gaps': blockingGaps,
    'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
  };
}

WorldScreenshotEvidenceReportV1 buildWorldScreenshotEvidenceReportV1({
  String rootPath = '.',
  required int world,
}) {
  final worldId = 'W$world';
  if (world == 10) {
    return _buildScreenshotEvidenceReportForWorldV1(
      rootPath: rootPath,
      worldId: worldId,
      manifestPath: _world10EvidenceManifestPathV1,
      representativeSessionIds: const <String>[
        'cash.s01',
        'tournament.s05',
        'mixed.s10',
      ],
      ownerFilesSeed: const <String>[
        _world10EvidenceManifestPathV1,
        'tools/world_screenshot_evidence_capture_v1.dart',
        'tools/world_screenshot_evidence_audit_v1.dart',
        'lib/audit_hub_v1/world_screenshot_evidence_audit_v1.dart',
        'test/tools/world_screenshot_evidence_audit_v1_test.dart',
        'test/ui_v2/session_drill_player_completion_surface_contract_test.dart',
      ],
      measurableProofPathSeed: const <String>[
        'dart run tools/world_screenshot_evidence_capture_v1.dart --world=10',
        'dart run tools/world_screenshot_evidence_audit_v1.dart --world=10 --json',
        'flutter test test/ui_v2/session_drill_player_completion_surface_contract_test.dart',
      ],
      successSummaryBuilder: (entries, coveredSessionIds) =>
          'Screenshot-backed evidence is wired for representative World10 track surfaces: ${entries.length} captured screenshots cover sessions ${coveredSessionIds.join(', ')}.',
      failurePrefixBuilder: (status, blockingGaps) =>
          'World10 screenshot-backed evidence remains ${status.wireValue}; blocking gaps: ${blockingGaps.join(' | ')}',
      missingCoverageMessage: (missingRepresentativeSessionIds) =>
          'W10 screenshot evidence does not yet cover representative sessions: ${missingRepresentativeSessionIds.join(', ')}.',
    );
  }

  if (world != 0) {
    return WorldScreenshotEvidenceReportV1(
      worldId: worldId,
      status: WorldScreenshotEvidenceStatusV1.missing,
      screenshotEvidenceCount: 0,
      coveredSessionIds: const <String>[],
      missingRepresentativeSessionIds: const <String>[],
      ownerFiles: const <String>[],
      measurableProofPath: <String>[
        'dart run $worldScreenshotEvidenceCaptureToolPathV1 --world=$world',
        'dart run $worldScreenshotEvidenceAuditToolPathV1 --world=$world --json',
      ],
      proofSurfaceTruth:
          'No repo-owned representative screenshot evidence is wired yet for $worldId.',
      blockingGaps: <String>[
        '$worldId does not yet have repo-owned screenshot-backed evidence.',
      ],
      entries: const <WorldScreenshotEvidenceEntryV1>[],
    );
  }

  return _buildScreenshotEvidenceReportForWorldV1(
    rootPath: rootPath,
    worldId: worldId,
    manifestPath: _world0EvidenceManifestPathV1,
    representativeSessionIds: const <String>['w0.s01', 'w0.s05', 'w0.s10'],
    ownerFilesSeed: const <String>[
      _world0EvidenceManifestPathV1,
      'tools/world_screenshot_evidence_capture_v1.dart',
      'tools/world_screenshot_evidence_audit_v1.dart',
      'lib/audit_hub_v1/world_screenshot_evidence_audit_v1.dart',
      'test/tools/world_screenshot_evidence_audit_v1_test.dart',
      'test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
    ],
    measurableProofPathSeed: const <String>[
      'dart run tools/world_screenshot_evidence_capture_v1.dart --world=0',
      'dart run tools/world_screenshot_evidence_audit_v1.dart --world=0 --json',
      'flutter test test/ui_v2/session_drill_player_world0_surface_contract_test.dart',
    ],
    successSummaryBuilder: (entries, coveredSessionIds) =>
        'Screenshot-backed evidence is wired for representative World0 session-drill surfaces: ${entries.length} captured screenshots cover sessions ${coveredSessionIds.join(', ')}.',
    failurePrefixBuilder: (status, blockingGaps) =>
        'World0 screenshot-backed evidence remains ${status.wireValue}; blocking gaps: ${blockingGaps.join(' | ')}',
    missingCoverageMessage: (missingRepresentativeSessionIds) =>
        'W0 screenshot evidence does not yet cover representative sessions: ${missingRepresentativeSessionIds.join(', ')}.',
  );
}

WorldScreenshotEvidenceReportV1 _buildScreenshotEvidenceReportForWorldV1({
  required String rootPath,
  required String worldId,
  required String manifestPath,
  required List<String> representativeSessionIds,
  required List<String> ownerFilesSeed,
  required List<String> measurableProofPathSeed,
  required String Function(
    List<WorldScreenshotEvidenceEntryV1> entries,
    List<String> coveredSessionIds,
  )
  successSummaryBuilder,
  required String Function(
    WorldScreenshotEvidenceStatusV1 status,
    List<String> blockingGaps,
  )
  failurePrefixBuilder,
  required String Function(List<String> missingRepresentativeSessionIds)
  missingCoverageMessage,
}) {
  final manifestFile = File('$rootPath/$manifestPath');
  final blockingGaps = <String>[];
  final coveredSessionIds = <String>[];
  final missingRepresentativeSessionIds = <String>[];
  final entries = <WorldScreenshotEvidenceEntryV1>[];

  if (!manifestFile.existsSync()) {
    blockingGaps.add('Missing `$manifestPath`.');
  } else {
    try {
      final decoded = jsonDecode(manifestFile.readAsStringSync());
      if (decoded is! Map<String, Object?>) {
        blockingGaps.add(
          '`$manifestPath` must decode to a JSON object.',
        );
      } else {
        final rawEntries = decoded['entries'];
        if (rawEntries is! List<Object?>) {
          blockingGaps.add(
            '`$manifestPath` must contain an `entries` list.',
          );
        } else {
          for (final rawEntry in rawEntries.whereType<Map>()) {
            final entry = Map<String, Object?>.from(rawEntry);
            final sessionId = entry['session_id'] as String?;
            final path = entry['path'] as String?;
            final bytes = entry['bytes'] as int?;
            if (sessionId == null || path == null || bytes == null) {
              blockingGaps.add(
                'Malformed screenshot evidence entry in `$manifestPath`.',
              );
              continue;
            }
            final file = File('$rootPath/$path');
            if (!file.existsSync()) {
              blockingGaps.add('Missing screenshot evidence artifact `$path`.');
              continue;
            }
            final actualBytes = file.lengthSync();
            if (actualBytes < _worldScreenshotMinBytesV1) {
              blockingGaps.add(
                'Screenshot evidence artifact `$path` is too small ($actualBytes B < $_worldScreenshotMinBytesV1 B).',
              );
              continue;
            }
            entries.add(
              WorldScreenshotEvidenceEntryV1(
                sessionId: sessionId,
                path: path,
                bytes: actualBytes,
              ),
            );
          }
        }
      }
    } catch (error) {
      blockingGaps.add(
        'Failed to parse `$manifestPath`: $error',
      );
    }
  }

  for (final sessionId in representativeSessionIds) {
    if (entries.any((entry) => entry.sessionId == sessionId)) {
      coveredSessionIds.add(sessionId);
    } else {
      missingRepresentativeSessionIds.add(sessionId);
    }
  }
  if (missingRepresentativeSessionIds.isNotEmpty) {
    blockingGaps.add(missingCoverageMessage(missingRepresentativeSessionIds));
  }

  final status = blockingGaps.isEmpty
      ? WorldScreenshotEvidenceStatusV1.executable
      : manifestFile.existsSync()
      ? WorldScreenshotEvidenceStatusV1.partial
      : WorldScreenshotEvidenceStatusV1.missing;
  final ownerFiles = <String>[
    ...ownerFilesSeed,
    ...entries.map((entry) => entry.path),
  ];
  final measurableProofPath = <String>[...measurableProofPathSeed];
  final proofSurfaceTruth = status == WorldScreenshotEvidenceStatusV1.executable
      ? successSummaryBuilder(entries, coveredSessionIds)
      : failurePrefixBuilder(status, blockingGaps);

  return WorldScreenshotEvidenceReportV1(
    worldId: worldId,
    status: status,
    screenshotEvidenceCount: entries.length,
    coveredSessionIds: coveredSessionIds,
    missingRepresentativeSessionIds: missingRepresentativeSessionIds,
    ownerFiles: ownerFiles,
    measurableProofPath: measurableProofPath,
    proofSurfaceTruth: proofSurfaceTruth,
    blockingGaps: blockingGaps,
    entries: entries,
  );
}

String encodeWorldScreenshotEvidenceReportJsonV1(
  WorldScreenshotEvidenceReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

String renderWorldScreenshotEvidenceReportV1(
  WorldScreenshotEvidenceReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('WORLD_SCREENSHOT_EVIDENCE_AUDIT_V1')
    ..writeln('WORLD\t${report.worldId}')
    ..writeln('STATUS\t${report.status.wireValue}')
    ..writeln('SCREENSHOT_EVIDENCE_COUNT\t${report.screenshotEvidenceCount}')
    ..writeln('PROOF_SURFACE\t${report.proofSurfaceTruth}');
  if (report.coveredSessionIds.isNotEmpty) {
    buffer.writeln('COVERED_SESSIONS\t${report.coveredSessionIds.join(",")}');
  }
  for (final entry in report.entries) {
    buffer.writeln('ENTRY\t${entry.sessionId}\t${entry.path}\t${entry.bytes}');
  }
  if (report.blockingGaps.isNotEmpty) {
    buffer.writeln('BLOCKERS');
    for (final gap in report.blockingGaps) {
      buffer.writeln('- $gap');
    }
  }
  return buffer.toString();
}
