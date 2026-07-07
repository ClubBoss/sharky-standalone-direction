import 'dart:convert';
import 'dart:io';

const sessionWorldTruthSurfaceAuditToolPathV1 =
    'tools/session_world_truth_surface_audit_v1.dart';
const _worldSessionsManifestPathV1 =
    'content/_meta/world_sessions_manifest_v1.json';
const _worldDrillsManifestPathV1 =
    'content/_meta/world_drills_manifest_v1.json';

enum SessionWorldTruthSurfaceStatusV1 {
  executable('executable'),
  partial('partial'),
  missing('missing');

  const SessionWorldTruthSurfaceStatusV1(this.wireValue);

  final String wireValue;
}

class SessionWorldTruthSurfaceReportV1 {
  const SessionWorldTruthSurfaceReportV1({
    required this.worldId,
    required this.status,
    required this.worldRootPresent,
    required this.worldMarkdownPresent,
    required this.sessionsIndexPresent,
    required this.diskSessionCount,
    required this.manifestSessionCount,
    required this.indexSessionCount,
    required this.manifestDrillCount,
    required this.diskDrillCount,
    required this.missingSessionIds,
    required this.unexpectedSessionIds,
    required this.missingDrillPaths,
    required this.indexMatchesManifest,
    required this.ownerFiles,
    required this.measurableProofPath,
    required this.proofSurfaceTruth,
    required this.blockingGaps,
  });

  final String worldId;
  final SessionWorldTruthSurfaceStatusV1 status;
  final bool worldRootPresent;
  final bool worldMarkdownPresent;
  final bool sessionsIndexPresent;
  final int diskSessionCount;
  final int manifestSessionCount;
  final int indexSessionCount;
  final int manifestDrillCount;
  final int diskDrillCount;
  final List<String> missingSessionIds;
  final List<String> unexpectedSessionIds;
  final List<String> missingDrillPaths;
  final bool indexMatchesManifest;
  final List<String> ownerFiles;
  final List<String> measurableProofPath;
  final String proofSurfaceTruth;
  final List<String> blockingGaps;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'world_id': worldId,
      'proof_surface_status': status.wireValue,
      'world_root_present': worldRootPresent,
      'world_markdown_present': worldMarkdownPresent,
      'sessions_index_present': sessionsIndexPresent,
      'disk_session_count': diskSessionCount,
      'manifest_session_count': manifestSessionCount,
      'index_session_count': indexSessionCount,
      'manifest_drill_count': manifestDrillCount,
      'disk_drill_count': diskDrillCount,
      'missing_session_ids': missingSessionIds,
      'unexpected_session_ids': unexpectedSessionIds,
      'missing_drill_paths': missingDrillPaths,
      'index_matches_manifest': indexMatchesManifest,
      'owner_files': ownerFiles,
      'measurable_proof_path': measurableProofPath,
      'proof_surface_truth': proofSurfaceTruth,
      'blocking_gaps': blockingGaps,
    };
  }
}

List<SessionWorldTruthSurfaceReportV1> buildSessionWorldTruthSurfaceReportsV1({
  String rootPath = '.',
  Iterable<int>? worlds,
}) {
  final selectedWorlds =
      (worlds ?? const <int>[0])
          .toSet()
          .where((world) => world >= 0 && world <= 10)
          .toList(growable: false)
        ..sort();
  return selectedWorlds
      .map(
        (world) => buildSessionWorldTruthSurfaceReportV1(
          rootPath: rootPath,
          world: world,
        ),
      )
      .toList(growable: false);
}

SessionWorldTruthSurfaceReportV1 buildSessionWorldTruthSurfaceReportV1({
  String rootPath = '.',
  required int world,
}) {
  if (world < 0 || world > 10) {
    throw ArgumentError.value(
      world,
      'world',
      'session-world truth surface audit supports worlds 0..10 only',
    );
  }

  final worldId = 'W$world';
  final worldLabel = 'world$world';
  final worldRoot = Directory('$rootPath/content/worlds/$worldLabel/v1');
  final worldMarkdown = File('${worldRoot.path}/world.md');
  final sessionsIndex = File('${worldRoot.path}/sessions/index.md');
  final sessionsRoot = Directory('${worldRoot.path}/sessions');

  final manifestSessionIds = _readManifestSessionIdsV1(
    '$rootPath/$_worldSessionsManifestPathV1',
    world,
  );
  final manifestDrillPaths = _readManifestDrillPathsV1(
    '$rootPath/$_worldDrillsManifestPathV1',
    world,
  );
  final diskSessionIds = _readDiskSessionIdsV1(sessionsRoot, world);
  final indexSessionIds = _readIndexSessionIdsV1(sessionsIndex, world);
  final diskDrillCount = _countDiskDrillsV1(sessionsRoot, world);

  final missingSessionIds = manifestSessionIds
      .where((sessionId) => !diskSessionIds.contains(sessionId))
      .toList(growable: false);
  final unexpectedSessionIds = diskSessionIds
      .where((sessionId) => !manifestSessionIds.contains(sessionId))
      .toList(growable: false);
  final missingDrillPaths = manifestDrillPaths
      .where((path) => !File('$rootPath/$path').existsSync())
      .toList(growable: false);
  final indexMatchesManifest = _listEqualsV1(
    indexSessionIds,
    manifestSessionIds,
  );

  final ownerFiles = <String>[
    'content/worlds/$worldLabel/v1/world.md',
    'content/worlds/$worldLabel/v1/sessions/index.md',
    _worldSessionsManifestPathV1,
    _worldDrillsManifestPathV1,
  ];
  final measurableProofPath = <String>[
    'dart run $sessionWorldTruthSurfaceAuditToolPathV1 --world=$world --json',
  ];

  final blockingGaps = <String>[
    if (!worldRoot.existsSync())
      'Missing world root `content/worlds/$worldLabel/v1`.',
    if (!worldMarkdown.existsSync())
      'Missing world markdown `content/worlds/$worldLabel/v1/world.md`.',
    if (!sessionsIndex.existsSync())
      'Missing session index `content/worlds/$worldLabel/v1/sessions/index.md`.',
    if (manifestSessionIds.isEmpty)
      'No session entries exist in `$_worldSessionsManifestPathV1` for $worldId.',
    if (manifestDrillPaths.isEmpty)
      'No drill entries exist in `$_worldDrillsManifestPathV1` for $worldId.',
    if (missingSessionIds.isNotEmpty)
      '$worldId manifest-backed session dirs missing on disk: ${missingSessionIds.join(', ')}.',
    if (unexpectedSessionIds.isNotEmpty)
      '$worldId has unexpected session dirs outside manifest truth: ${unexpectedSessionIds.join(', ')}.',
    if (!indexMatchesManifest)
      '$worldId session index does not match manifest session spine.',
    if (missingDrillPaths.isNotEmpty)
      '$worldId manifest-backed drill files missing on disk: ${missingDrillPaths.length}.',
  ];

  final status = blockingGaps.isEmpty
      ? SessionWorldTruthSurfaceStatusV1.executable
      : (worldRoot.existsSync() ||
            worldMarkdown.existsSync() ||
            sessionsIndex.existsSync() ||
            manifestSessionIds.isNotEmpty)
      ? SessionWorldTruthSurfaceStatusV1.partial
      : SessionWorldTruthSurfaceStatusV1.missing;

  final proofSurfaceTruth =
      status == SessionWorldTruthSurfaceStatusV1.executable
      ? 'Executable session-world proof surface is wired for $worldId: '
            'world.md, sessions/index.md, ${manifestSessionIds.length} manifest-backed sessions, '
            '${manifestDrillPaths.length} manifest-backed drills.'
      : 'Session-world proof surface for $worldId remains ${status.wireValue}; '
            'blocking gaps: ${blockingGaps.join(' | ')}';

  return SessionWorldTruthSurfaceReportV1(
    worldId: worldId,
    status: status,
    worldRootPresent: worldRoot.existsSync(),
    worldMarkdownPresent: worldMarkdown.existsSync(),
    sessionsIndexPresent: sessionsIndex.existsSync(),
    diskSessionCount: diskSessionIds.length,
    manifestSessionCount: manifestSessionIds.length,
    indexSessionCount: indexSessionIds.length,
    manifestDrillCount: manifestDrillPaths.length,
    diskDrillCount: diskDrillCount,
    missingSessionIds: missingSessionIds,
    unexpectedSessionIds: unexpectedSessionIds,
    missingDrillPaths: missingDrillPaths,
    indexMatchesManifest: indexMatchesManifest,
    ownerFiles: ownerFiles,
    measurableProofPath: measurableProofPath,
    proofSurfaceTruth: proofSurfaceTruth,
    blockingGaps: blockingGaps,
  );
}

String encodeSessionWorldTruthSurfaceReportJsonV1(
  SessionWorldTruthSurfaceReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

String renderSessionWorldTruthSurfaceReportV1(
  SessionWorldTruthSurfaceReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('SESSION_WORLD_TRUTH_SURFACE_AUDIT_V1')
    ..writeln('WORLD\t${report.worldId}')
    ..writeln('STATUS\t${report.status.wireValue}')
    ..writeln('WORLD_ROOT\t${report.worldRootPresent ? 'present' : 'missing'}')
    ..writeln(
      'WORLD_MD\t${report.worldMarkdownPresent ? 'present' : 'missing'}',
    )
    ..writeln(
      'SESSIONS_INDEX\t${report.sessionsIndexPresent ? 'present' : 'missing'}',
    )
    ..writeln('DISK_SESSIONS\t${report.diskSessionCount}')
    ..writeln('MANIFEST_SESSIONS\t${report.manifestSessionCount}')
    ..writeln('INDEX_SESSIONS\t${report.indexSessionCount}')
    ..writeln('MANIFEST_DRILLS\t${report.manifestDrillCount}')
    ..writeln('DISK_DRILLS\t${report.diskDrillCount}')
    ..writeln('INDEX_MATCHES_MANIFEST\t${report.indexMatchesManifest}')
    ..writeln('PROOF_SURFACE\t${report.proofSurfaceTruth}');
  if (report.missingSessionIds.isNotEmpty) {
    buffer.writeln('MISSING_SESSIONS\t${report.missingSessionIds.join(",")}');
  }
  if (report.unexpectedSessionIds.isNotEmpty) {
    buffer.writeln(
      'UNEXPECTED_SESSIONS\t${report.unexpectedSessionIds.join(",")}',
    );
  }
  if (report.missingDrillPaths.isNotEmpty) {
    buffer.writeln('MISSING_DRILLS\t${report.missingDrillPaths.length}');
  }
  if (report.blockingGaps.isNotEmpty) {
    buffer.writeln('BLOCKERS');
    for (final gap in report.blockingGaps) {
      buffer.writeln('- $gap');
    }
  }
  return buffer.toString();
}

List<String> _readManifestSessionIdsV1(String path, int world) {
  final file = File(path);
  if (!file.existsSync()) {
    return const <String>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <String>[];
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    return const <String>[];
  }
  for (final entry in worlds.whereType<Map>()) {
    if (entry['world'] != world) {
      continue;
    }
    return (entry['sessions'] as List<Object?>? ?? const [])
        .whereType<Map>()
        .map((session) => session['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }
  return const <String>[];
}

List<String> _readManifestDrillPathsV1(String path, int world) {
  final file = File(path);
  if (!file.existsSync()) {
    return const <String>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <String>[];
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    return const <String>[];
  }
  for (final entry in worlds.whereType<Map>()) {
    if (entry['world'] != world) {
      continue;
    }
    return (entry['sessions'] as List<Object?>? ?? const [])
        .whereType<Map>()
        .expand(
          (session) => (session['drills'] as List<Object?>? ?? const [])
              .whereType<Map>()
              .map((drill) => drill['path'] as String? ?? '')
              .where((path) => path.isNotEmpty),
        )
        .toList(growable: false);
  }
  return const <String>[];
}

List<String> _readDiskSessionIdsV1(Directory sessionsRoot, int world) {
  if (!sessionsRoot.existsSync()) {
    return const <String>[];
  }
  final sessionPattern = RegExp(r'^w(\d+)\.s\d{2}$');
  return sessionsRoot
      .listSync(followLinks: false)
      .whereType<Directory>()
      .map((directory) => _baseNameV1(directory.path))
      .where((name) {
        final match = sessionPattern.firstMatch(name);
        return match != null && int.tryParse(match.group(1)!) == world;
      })
      .toList(growable: false)
    ..sort();
}

List<String> _readIndexSessionIdsV1(File indexFile, int world) {
  if (!indexFile.existsSync()) {
    return const <String>[];
  }
  final pattern = RegExp(r'^- (w(\d+)\.s(\d{2})):');
  final ids = <String>[];
  for (final rawLine in indexFile.readAsLinesSync()) {
    final match = pattern.firstMatch(rawLine.trim());
    if (match == null) {
      continue;
    }
    if (int.tryParse(match.group(2)!) != world) {
      continue;
    }
    ids.add(match.group(1)!);
  }
  return ids;
}

int _countDiskDrillsV1(Directory sessionsRoot, int world) {
  if (!sessionsRoot.existsSync()) {
    return 0;
  }
  final sessionPattern = RegExp(r'^w(\d+)\.s\d{2}$');
  final drillPattern = RegExp(r'^d\..+\.json$');
  var count = 0;
  for (final directory
      in sessionsRoot.listSync(followLinks: false).whereType<Directory>()) {
    final sessionId = _baseNameV1(directory.path);
    final match = sessionPattern.firstMatch(sessionId);
    if (match == null || int.tryParse(match.group(1)!) != world) {
      continue;
    }
    final drillsDir = Directory('${directory.path}/drills');
    if (!drillsDir.existsSync()) {
      continue;
    }
    count += drillsDir
        .listSync(followLinks: false)
        .whereType<File>()
        .where((file) => drillPattern.hasMatch(_baseNameV1(file.path)))
        .length;
  }
  return count;
}

bool _listEqualsV1(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}

String _baseNameV1(String path) {
  final normalized = path.replaceAll('\\', '/');
  final index = normalized.lastIndexOf('/');
  return index == -1 ? normalized : normalized.substring(index + 1);
}
