import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/canonical/world1_canonical_module_order_v1.dart';

enum LearnerPathHealthStatusV1 { ok, legacy, degraded, broken }

class LearnerPathHealthRowV1 {
  const LearnerPathHealthRowV1({
    required this.kind,
    required this.world,
    required this.id,
    required this.route,
    required this.mode,
    required this.status,
    required this.reason,
    required this.path,
  });

  final String kind;
  final int world;
  final String id;
  final String route;
  final String mode;
  final LearnerPathHealthStatusV1 status;
  final String reason;
  final String path;

  Map<String, Object> toJson() => <String, Object>{
    'kind': kind,
    'world': world,
    'id': id,
    'route': route,
    'mode': mode,
    'status': status.name.toUpperCase(),
    'reason': reason,
    'path': path,
  };
}

class LearnerPathHealthSummaryV1 {
  const LearnerPathHealthSummaryV1({
    required this.world,
    required this.okCount,
    required this.legacyCount,
    required this.degradedCount,
    required this.brokenCount,
  });

  final int world;
  final int okCount;
  final int legacyCount;
  final int degradedCount;
  final int brokenCount;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'OK': okCount,
    'LEGACY': legacyCount,
    'DEGRADED': degradedCount,
    'BROKEN': brokenCount,
  };
}

class LearnerPathHealthReportV1 {
  const LearnerPathHealthReportV1({
    required this.rows,
    required this.summaries,
  });

  final List<LearnerPathHealthRowV1> rows;
  final List<LearnerPathHealthSummaryV1> summaries;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summaries': summaries.map((item) => item.toJson()).toList(growable: false),
    'rows': rows.map((item) => item.toJson()).toList(growable: false),
  };
}

const Set<String> _kWorld1ModernizedPackIdsV1 = <String>{
  'world1_act0_table_literacy',
  'world1_act0_action_literacy',
  'world1_act0_street_flow',
};

const Set<String> _kCanonicalCampaignSpinePackIdsV1 = <String>{
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
  'world2_spine_campaign_v1',
  'world2_spine_followup_v1_b0',
  'world2_spine_followup_v1_b1',
  'world2_spine_followup_v1_b2',
  'world3_spine_campaign_v1',
  'world3_spine_followup_v1_b0',
  'world3_spine_followup_v1_b1',
  'world3_spine_followup_v1_b2',
  'world4_spine_campaign_v1',
  'world4_spine_followup_v1_b0',
  'world4_spine_followup_v1_b1',
  'world4_spine_followup_v1_b2',
  'world5_spine_campaign_v1',
  'world5_spine_followup_v1_b0',
  'world5_spine_followup_v1_b1',
  'world5_spine_followup_v1_b2',
  'world6_spine_campaign_v1',
  'world6_spine_followup_v1_b0',
  'world6_spine_followup_v1_b1',
  'world6_spine_followup_v1_b2',
  'world7_spine_campaign_v1',
  'world7_spine_followup_v1_b0',
  'world7_spine_followup_v1_b1',
  'world7_spine_followup_v1_b2',
  'world8_spine_campaign_v1',
  'world8_spine_followup_v1_b0',
  'world8_spine_followup_v1_b1',
  'world8_spine_followup_v1_b2',
  'world9_spine_campaign_v1',
  'world9_spine_followup_v1_b0',
  'world9_spine_followup_v1_b1',
  'world9_spine_followup_v1_b2',
  'world10_spine_campaign_v1',
  'world10_spine_followup_v1_b0',
  'world10_spine_followup_v1_b1',
  'world10_spine_followup_v1_b2',
};

const Set<String> _kSupplementLiveSessionIdsV1 = <String>{
  'w2.s02',
  'w2.s03',
  'w2.s04',
  'w2.s06',
};

const Set<String> _kSurfacedFactualSupplementGapSessionIdsV1 = <String>{
  'w2.s03',
  'w2.s04',
};

const Set<String> _kReusableFactualSessionIdsV1 = <String>{
  'w2.s07',
  'w2.s08',
  'w2.s09',
  'w2.s10',
  'w2.s11',
  'w2.s12',
  'w2.s13',
  'w2.s14',
  'w3.s01',
  'w3.s02',
  'w3.s03',
  'w3.s04',
  'w3.s05',
  'w3.s06',
  'w3.s07',
  'w3.s08',
  'w3.s09',
  'w3.s10',
  'w3.s11',
  'w3.s12',
  'w3.s13',
  'w3.s14',
};

const Set<String> _kCanonicalSingleStepSessionIdsV1 = <String>{
  'w0.s01',
  'w0.s02',
  'w0.s03',
  'w0.s04',
  'w0.s05',
  'w0.s06',
  'w0.s07',
  'w0.s08',
  'w0.s09',
  'w0.s10',
  'w1.s01',
  'w1.s02',
  'w1.s03',
  'w1.s04',
  'w1.s05',
  'w1.s06',
  'w1.s07',
  'w1.s08',
  'w1.s09',
  'w1.s10',
  'w2.s01',
  'w2.s05',
  'w4.s01',
  'w4.s02',
  'w4.s03',
  'w4.s04',
  'w4.s05',
  'w4.s06',
  'w4.s07',
  'w4.s08',
  'w4.s09',
  'w4.s10',
  'w5.s01',
  'w5.s02',
  'w5.s03',
  'w5.s04',
  'w5.s05',
  'w5.s06',
  'w5.s07',
  'w5.s08',
  'w5.s09',
  'w5.s10',
  'w6.s01',
  'w6.s02',
  'w6.s03',
  'w6.s04',
  'w6.s05',
  'w6.s06',
  'w6.s07',
  'w6.s08',
  'w6.s09',
  'w6.s10',
  'w7.s01',
  'w7.s02',
  'w7.s03',
  'w7.s04',
  'w7.s05',
  'w7.s06',
  'w7.s07',
  'w7.s08',
  'w7.s09',
  'w7.s10',
  'w8.s01',
  'w8.s02',
  'w8.s03',
  'w8.s04',
  'w8.s05',
  'w8.s06',
  'w8.s07',
  'w8.s08',
  'w8.s09',
  'w8.s10',
  'w9.s01',
  'w9.s02',
  'w9.s03',
  'w9.s04',
  'w9.s05',
  'w9.s06',
  'w9.s07',
  'w9.s08',
  'w9.s09',
  'w9.s10',
};

const Set<String> _kCanonicalTrackSessionIdsV1 = <String>{
  'cash.s01',
  'cash.s02',
  'cash.s03',
  'cash.s04',
  'cash.s05',
  'cash.s06',
  'cash.s07',
  'cash.s08',
  'cash.s09',
  'cash.s10',
  'tournament.s01',
  'tournament.s02',
  'tournament.s03',
  'tournament.s04',
  'tournament.s05',
  'tournament.s06',
  'tournament.s07',
  'tournament.s08',
  'tournament.s09',
  'tournament.s10',
  'mixed.s01',
  'mixed.s02',
  'mixed.s03',
  'mixed.s04',
  'mixed.s05',
  'mixed.s06',
  'mixed.s07',
  'mixed.s08',
  'mixed.s09',
  'mixed.s10',
};

const Set<String> _kWorld10TrackRootEntryPilotSessionIdsV1 = <String>{
  'cash.s01',
  'tournament.s01',
  'mixed.s01',
};

const Set<String> _kWorld10TrackEarlyChainPilotSessionIdsV1 = <String>{
  'cash.s02',
  'cash.s03',
  'tournament.s02',
  'tournament.s03',
  'mixed.s02',
  'mixed.s03',
};

const Set<String> _kWorld10TrackTailChainPilotSessionIdsV1 = <String>{
  'cash.s04',
  'cash.s05',
  'cash.s06',
  'cash.s07',
  'cash.s08',
  'cash.s09',
  'cash.s10',
  'tournament.s04',
  'tournament.s05',
  'tournament.s06',
  'tournament.s07',
  'tournament.s08',
  'tournament.s09',
  'tournament.s10',
  'mixed.s04',
  'mixed.s05',
  'mixed.s06',
  'mixed.s07',
  'mixed.s08',
  'mixed.s09',
  'mixed.s10',
};

const Set<int> _kDefaultIncludedWorldsV1 = <int>{
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
};

LearnerPathHealthReportV1 buildRuntimeWorldSessionHealthReportV1({
  String rootPath = '.',
  bool includeCampaignPacks = true,
  Set<int>? includedWorlds,
}) {
  final worlds = includedWorlds ?? _kDefaultIncludedWorldsV1;
  final sessionBackedCampaignPackIds = _loadSessionBackedCampaignPackIdsV1(
    rootPath,
  );
  final rows = <LearnerPathHealthRowV1>[
    if (includeCampaignPacks)
      ..._buildCampaignRowsV1(
        rootPath,
        includedWorlds: worlds,
        sessionBackedCampaignPackIds: sessionBackedCampaignPackIds,
      ),
    ..._buildManifestSessionRowsV1(rootPath, includedWorlds: worlds),
    ..._buildWorld10TrackSessionRowsV1(rootPath, includedWorlds: worlds),
  ]..sort(_compareRowsV1);

  return LearnerPathHealthReportV1(
    rows: List<LearnerPathHealthRowV1>.unmodifiable(rows),
    summaries: List<LearnerPathHealthSummaryV1>.unmodifiable(
      _buildSummariesV1(rows),
    ),
  );
}

String renderRuntimeWorldSessionHealthReportV1(
  LearnerPathHealthReportV1 report,
) {
  final out = StringBuffer();
  out.writeln('WORLD\tOK\tLEGACY\tDEGRADED\tBROKEN');
  for (final summary in report.summaries) {
    out.writeln(
      '${summary.world}\t${summary.okCount}\t${summary.legacyCount}\t${summary.degradedCount}\t${summary.brokenCount}',
    );
  }
  out.writeln();
  out.writeln('KIND\tWORLD\tID\tROUTE\tMODE\tSTATUS\tREASON');
  for (final row in report.rows) {
    out.writeln(
      '${row.kind}\t${row.world}\t${row.id}\t${row.route}\t${row.mode}\t${row.status.name.toUpperCase()}\t${row.reason}',
    );
  }
  return out.toString().trimRight();
}

String encodeRuntimeWorldSessionHealthReportJsonV1(
  LearnerPathHealthReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

List<LearnerPathHealthRowV1> _buildCampaignRowsV1(
  String rootPath, {
  required Set<int> includedWorlds,
  required Set<String> sessionBackedCampaignPackIds,
}) {
  final rows = <LearnerPathHealthRowV1>[];
  for (final packId in _orderedCampaignPackIdsV1()) {
    final world = _worldForCampaignPackIdV1(packId);
    if (world == null || !includedWorlds.contains(world)) {
      continue;
    }
    final isModernized = _kWorld1ModernizedPackIdsV1.contains(packId);
    final isCanonicalCampaignSpine = _kCanonicalCampaignSpinePackIdsV1.contains(
      packId,
    );
    final usesSessionDrillPlayer = sessionBackedCampaignPackIds.contains(
      packId,
    );
    rows.add(
      LearnerPathHealthRowV1(
        kind: 'campaign_pack',
        world: world,
        id: packId,
        route: usesSessionDrillPlayer
            ? 'sessionDrillPlayer'
            : 'world1FoundationsRunner',
        mode: packId.contains('_act0_') ? 'seatQuiz' : 'campaignSpine',
        status:
            usesSessionDrillPlayer || isModernized || isCanonicalCampaignSpine
            ? LearnerPathHealthStatusV1.ok
            : LearnerPathHealthStatusV1.legacy,
        reason: usesSessionDrillPlayer
            ? 'session_drill_campaign_entry_pilot'
            : isModernized
            ? 'world1_modernized_runner'
            : isCanonicalCampaignSpine
            ? 'canonical_campaign_spine_pack'
            : 'campaign_runner_legacy',
        path: 'pack:$packId',
      ),
    );
  }
  return rows;
}

Set<String> _loadSessionBackedCampaignPackIdsV1(String rootPath) {
  final canonicalTruthFile = File(
    '$rootPath/lib/canonical/canonical_truth_map_v1.dart',
  );
  if (!canonicalTruthFile.existsSync()) {
    return const <String>{};
  }
  final raw = canonicalTruthFile.readAsStringSync();
  return _parseStringSetConstV1(
    raw,
    name: '_kCanonicalSessionBackedCampaignPackIdsV1',
  );
}

List<LearnerPathHealthRowV1> _buildManifestSessionRowsV1(
  String rootPath, {
  required Set<int> includedWorlds,
}) {
  final manifest = _loadWorldManifestRowsV1(rootPath);
  final rows = <LearnerPathHealthRowV1>[];
  for (final worldEntry in manifest) {
    final world = worldEntry['world'];
    if (world is! int || !includedWorlds.contains(world)) {
      continue;
    }
    final sessions = worldEntry['sessions'];
    if (sessions is! List<Object?>) continue;
    for (final rawSession in sessions) {
      if (rawSession is! Map<String, Object?>) continue;
      final id = (rawSession['id'] ?? '').toString().trim().toLowerCase();
      final path = (rawSession['path'] ?? '').toString();
      final drills = rawSession['drills'];
      final drillPaths = drills is List<Object?>
          ? drills
                .whereType<Map<String, Object?>>()
                .map((item) => (item['path'] ?? '').toString())
                .where((item) => item.isNotEmpty)
                .toList(growable: false)
          : const <String>[];
      rows.add(
        _buildSessionRowV1(
          rootPath: rootPath,
          world: world,
          id: id,
          path: path,
          drillPaths: drillPaths,
          emptyDrillReason: 'missing_drill_manifest_entries',
        ),
      );
    }
  }
  return rows;
}

List<LearnerPathHealthRowV1> _buildWorld10TrackSessionRowsV1(
  String rootPath, {
  required Set<int> includedWorlds,
}) {
  if (!includedWorlds.contains(10)) {
    return const <LearnerPathHealthRowV1>[];
  }
  final rows = <LearnerPathHealthRowV1>[];
  for (final track in const <String>['cash', 'mixed', 'tournament']) {
    final sessionsDir = Directory(
      '$rootPath/content/worlds/world10/v1/tracks/$track/sessions',
    );
    if (!sessionsDir.existsSync()) {
      rows.add(
        LearnerPathHealthRowV1(
          kind: 'session',
          world: 10,
          id: '$track.*',
          route: 'sessionDrillPlayer',
          mode: 'trackSession',
          status: LearnerPathHealthStatusV1.broken,
          reason: 'missing_track_sessions_dir',
          path: 'content/worlds/world10/v1/tracks/$track/sessions',
        ),
      );
      continue;
    }
    final sessionIds =
        sessionsDir
            .listSync()
            .whereType<Directory>()
            .map(
              (item) => item.uri.pathSegments.lastWhere(
                (segment) => segment.isNotEmpty,
              ),
            )
            .where((item) => item.isNotEmpty)
            .toList(growable: true)
          ..sort();
    for (final sessionId in sessionIds) {
      final sessionPath =
          'content/worlds/world10/v1/tracks/$track/sessions/$sessionId';
      rows.add(
        _buildSessionRowV1(
          rootPath: rootPath,
          world: 10,
          id: sessionId,
          path: sessionPath,
          drillPaths: _scanSessionDrillPathsV1(rootPath, sessionPath),
          emptyDrillReason: 'missing_drill_files',
        ),
      );
    }
  }
  return rows;
}

LearnerPathHealthRowV1 _buildSessionRowV1({
  required String rootPath,
  required int world,
  required String id,
  required String path,
  required List<String> drillPaths,
  required String emptyDrillReason,
}) {
  final normalizedPath = path.isEmpty
      ? 'content/worlds/world$world/v1/sessions/$id/'
      : path;
  final sessionDir = Directory('$rootPath/$normalizedPath');
  if (!sessionDir.existsSync()) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.broken,
      reason: 'missing_session_dir',
      path: normalizedPath,
    );
  }
  if (drillPaths.isEmpty) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.broken,
      reason: emptyDrillReason,
      path: normalizedPath,
    );
  }
  final missingDrill = drillPaths.firstWhere(
    (item) => !File('$rootPath/$item').existsSync(),
    orElse: () => '',
  );
  if (missingDrill.isNotEmpty) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.broken,
      reason: 'missing_drill_file',
      path: missingDrill,
    );
  }
  if (_kSupplementLiveSessionIdsV1.contains(id)) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.ok,
      reason: 'supplements_live',
      path: normalizedPath,
    );
  }
  if (_kReusableFactualSessionIdsV1.contains(id)) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.ok,
      reason: 'reusable_factual_host',
      path: normalizedPath,
    );
  }
  if (_kCanonicalSingleStepSessionIdsV1.contains(id)) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.ok,
      reason: 'canonical_single_step_session',
      path: normalizedPath,
    );
  }
  if (_kCanonicalTrackSessionIdsV1.contains(id)) {
    final reason = _kWorld10TrackRootEntryPilotSessionIdsV1.contains(id)
        ? 'world10_track_root_entry_pilot'
        : _kWorld10TrackEarlyChainPilotSessionIdsV1.contains(id)
        ? 'world10_track_early_chain_pilot'
        : _kWorld10TrackTailChainPilotSessionIdsV1.contains(id)
        ? 'world10_track_tail_chain_pilot'
        : 'canonical_track_session';
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.ok,
      reason: reason,
      path: normalizedPath,
    );
  }
  if (_kSurfacedFactualSupplementGapSessionIdsV1.contains(id)) {
    return LearnerPathHealthRowV1(
      kind: 'session',
      world: world,
      id: id,
      route: 'sessionDrillPlayer',
      mode: _modeForSessionIdV1(id),
      status: LearnerPathHealthStatusV1.degraded,
      reason: 'surfaced_factual_without_supplements',
      path: normalizedPath,
    );
  }
  return LearnerPathHealthRowV1(
    kind: 'session',
    world: world,
    id: id,
    route: 'sessionDrillPlayer',
    mode: _modeForSessionIdV1(id),
    status: LearnerPathHealthStatusV1.legacy,
    reason: 'session_drill_player_legacy',
    path: normalizedPath,
  );
}

List<String> _scanSessionDrillPathsV1(String rootPath, String sessionPath) {
  final drillsDir = Directory('$rootPath/$sessionPath/drills');
  if (!drillsDir.existsSync()) {
    return const <String>[];
  }
  final files =
      drillsDir
          .listSync()
          .whereType<File>()
          .map((item) => item.path)
          .where((item) => item.endsWith('.json'))
          .map((item) => _relativePathFromRootV1(rootPath, item))
          .toList(growable: true)
        ..sort();
  return List<String>.unmodifiable(files);
}

String _relativePathFromRootV1(String rootPath, String fullPath) {
  final normalizedRoot = rootPath == '.' ? '' : '$rootPath/';
  if (normalizedRoot.isNotEmpty && fullPath.startsWith(normalizedRoot)) {
    return fullPath.substring(normalizedRoot.length);
  }
  if (fullPath.startsWith('./')) {
    return fullPath.substring(2);
  }
  return fullPath;
}

List<String> _orderedCampaignPackIdsV1() {
  final byWorld = <int, List<String>>{};
  for (final packId in kCampaignPackIdsV1) {
    final world = _worldForCampaignPackIdV1(packId);
    if (world == null) {
      continue;
    }
    byWorld.putIfAbsent(world, () => <String>[]).add(packId);
  }
  final worlds = byWorld.keys.toList(growable: true)..sort();
  final ordered = <String>[];
  for (final world in worlds) {
    if (world == 1) {
      ordered.addAll(kWorld1CanonicalModuleOrder);
      continue;
    }
    final ids = byWorld[world]!..sort(_compareCampaignPackIdsV1);
    ordered.addAll(ids);
  }
  return List<String>.unmodifiable(ordered);
}

int _compareCampaignPackIdsV1(String a, String b) {
  const spineCoreToken = '_spine_campaign_v1';
  final aIsSpineCore = a.contains(spineCoreToken);
  final bIsSpineCore = b.contains(spineCoreToken);
  if (aIsSpineCore != bIsSpineCore) {
    return aIsSpineCore ? -1 : 1;
  }
  final aSuffix = RegExp(r'_b(\d+)$').firstMatch(a);
  final bSuffix = RegExp(r'_b(\d+)$').firstMatch(b);
  if (aSuffix != null && bSuffix != null) {
    final aNum = int.tryParse(aSuffix.group(1) ?? '');
    final bNum = int.tryParse(bSuffix.group(1) ?? '');
    if (aNum != null && bNum != null) {
      final byNum = aNum.compareTo(bNum);
      if (byNum != 0) {
        return byNum;
      }
    }
  }
  return a.compareTo(b);
}

int? _worldForCampaignPackIdV1(String packId) {
  final match = RegExp(r'^world(\d+)_').firstMatch(packId.trim().toLowerCase());
  return int.tryParse(match?.group(1) ?? '');
}

List<LearnerPathHealthSummaryV1> _buildSummariesV1(
  List<LearnerPathHealthRowV1> rows,
) {
  final counts = <int, Map<LearnerPathHealthStatusV1, int>>{};
  for (final row in rows) {
    counts.putIfAbsent(
      row.world,
      () => <LearnerPathHealthStatusV1, int>{
        LearnerPathHealthStatusV1.ok: 0,
        LearnerPathHealthStatusV1.legacy: 0,
        LearnerPathHealthStatusV1.degraded: 0,
        LearnerPathHealthStatusV1.broken: 0,
      },
    );
    counts[row.world]![row.status] = counts[row.world]![row.status]! + 1;
  }
  final worlds = counts.keys.toList(growable: false)..sort();
  return worlds
      .map(
        (world) => LearnerPathHealthSummaryV1(
          world: world,
          okCount: counts[world]![LearnerPathHealthStatusV1.ok] ?? 0,
          legacyCount: counts[world]![LearnerPathHealthStatusV1.legacy] ?? 0,
          degradedCount:
              counts[world]![LearnerPathHealthStatusV1.degraded] ?? 0,
          brokenCount: counts[world]![LearnerPathHealthStatusV1.broken] ?? 0,
        ),
      )
      .toList(growable: false);
}

List<Map<String, Object?>> _loadWorldManifestRowsV1(String rootPath) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <Map<String, Object?>>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <Map<String, Object?>>[];
  }
  final worlds = decoded['worlds'];
  if (worlds is! List<Object?>) {
    return const <Map<String, Object?>>[];
  }
  return worlds.whereType<Map<String, Object?>>().toList(growable: false);
}

int _compareRowsV1(LearnerPathHealthRowV1 a, LearnerPathHealthRowV1 b) {
  final byWorld = a.world.compareTo(b.world);
  if (byWorld != 0) return byWorld;
  final byKind = a.kind.compareTo(b.kind);
  if (byKind != 0) return byKind;
  return a.id.compareTo(b.id);
}

String _modeForSessionIdV1(String sessionId) {
  if (sessionId.startsWith('cash.') ||
      sessionId.startsWith('mixed.') ||
      sessionId.startsWith('tournament.')) {
    return 'trackSession';
  }
  return _kReusableFactualSessionIdsV1.contains(sessionId)
      ? 'handChain'
      : 'singleStep';
}

Set<String> _parseStringSetConstV1(String source, {required String name}) {
  final match = RegExp(
    'const Set<String> $name = <String>\\{([\\s\\S]*?)\\};',
  ).firstMatch(source);
  if (match == null) {
    throw StateError('Missing const set $name.');
  }
  return Set<String>.unmodifiable(_parseQuotedStringsV1(match.group(1)!));
}

List<String> _parseQuotedStringsV1(String source) {
  return RegExp(r"'([^']+)'")
      .allMatches(source)
      .map((match) => match.group(1)!.trim().toLowerCase())
      .toList(growable: false);
}

void main(List<String> args) {
  final wantsJson = args.contains('--json');
  final sessionsOnly = args.contains('--sessions-only');
  final worldArg = args
      .where((item) => item.startsWith('--world='))
      .map((item) => int.tryParse(item.split('=').last))
      .whereType<int>()
      .toList(growable: false);
  final report = buildRuntimeWorldSessionHealthReportV1(
    includeCampaignPacks: !sessionsOnly,
    includedWorlds: worldArg.isEmpty ? null : worldArg.toSet(),
  );
  stdout.writeln(
    wantsJson
        ? encodeRuntimeWorldSessionHealthReportJsonV1(report)
        : renderRuntimeWorldSessionHealthReportV1(report),
  );
}
