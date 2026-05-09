import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/canonical/world1_canonical_module_order_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';

enum SpineCohesionStatusV1 { canonical, mixed, divergent }

class SpineProgressionCohesionRowV1 {
  const SpineProgressionCohesionRowV1({
    required this.world,
    required this.id,
    required this.itemType,
    required this.progressionType,
    required this.hostFamily,
    required this.screenFamily,
    required this.modeFamily,
    required this.cohesionStatus,
    required this.reasonCodes,
    required this.orderIndex,
    this.runnerContract,
    this.hostGrammarProfile,
    this.hostGrammarPrimitives,
    this.remainingHostGaps,
    this.trackKind,
    this.source,
  });

  final int world;
  final String id;
  final String itemType;
  final String progressionType;
  final String hostFamily;
  final String screenFamily;
  final String modeFamily;
  final SpineCohesionStatusV1 cohesionStatus;
  final List<String> reasonCodes;
  final int orderIndex;
  final String? runnerContract;
  final String? hostGrammarProfile;
  final List<String>? hostGrammarPrimitives;
  final List<String>? remainingHostGaps;
  final String? trackKind;
  final String? source;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'id': id,
    'item_type': itemType,
    'progression_type': progressionType,
    'host_family': hostFamily,
    'screen_family': screenFamily,
    'mode_family': modeFamily,
    'cohesion_status': cohesionStatus.name,
    'reason_codes': reasonCodes,
    'order_index': orderIndex,
    if (runnerContract != null) 'runner_contract': runnerContract!,
    if (hostGrammarProfile != null) 'host_grammar_profile': hostGrammarProfile!,
    if (hostGrammarPrimitives != null)
      'host_grammar_primitives': hostGrammarPrimitives!,
    if (remainingHostGaps != null) 'remaining_host_gaps': remainingHostGaps!,
    if (trackKind != null) 'track_kind': trackKind!,
    if (source != null) 'source': source!,
  };

  SpineProgressionCohesionRowV1 copyWith({
    SpineCohesionStatusV1? cohesionStatus,
    List<String>? reasonCodes,
  }) {
    return SpineProgressionCohesionRowV1(
      world: world,
      id: id,
      itemType: itemType,
      progressionType: progressionType,
      hostFamily: hostFamily,
      screenFamily: screenFamily,
      modeFamily: modeFamily,
      cohesionStatus: cohesionStatus ?? this.cohesionStatus,
      reasonCodes: reasonCodes ?? this.reasonCodes,
      orderIndex: orderIndex,
      runnerContract: runnerContract,
      hostGrammarProfile: hostGrammarProfile,
      hostGrammarPrimitives: hostGrammarPrimitives,
      remainingHostGaps: remainingHostGaps,
      trackKind: trackKind,
      source: source,
    );
  }
}

class SpineProgressionCohesionWorldSummaryV1 {
  const SpineProgressionCohesionWorldSummaryV1({
    required this.world,
    required this.itemCount,
    required this.progressionTypes,
    required this.hostFamilies,
    required this.modeFamilies,
  });

  final int world;
  final int itemCount;
  final List<String> progressionTypes;
  final List<String> hostFamilies;
  final List<String> modeFamilies;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'item_count': itemCount,
    'progression_types': progressionTypes,
    'host_families': hostFamilies,
    'mode_families': modeFamilies,
  };
}

class SpineProgressionCohesionSummaryV1 {
  const SpineProgressionCohesionSummaryV1({
    required this.totalRows,
    required this.statusCounts,
    required this.progressionCounts,
    required this.hostCounts,
    required this.worlds,
  });

  final int totalRows;
  final Map<String, int> statusCounts;
  final Map<String, int> progressionCounts;
  final Map<String, int> hostCounts;
  final List<SpineProgressionCohesionWorldSummaryV1> worlds;

  Map<String, Object> toJson() => <String, Object>{
    'total_rows': totalRows,
    'status_counts': statusCounts,
    'progression_counts': progressionCounts,
    'host_counts': hostCounts,
    'worlds': worlds.map((item) => item.toJson()).toList(growable: false),
  };
}

class SpineProgressionCohesionReportV1 {
  const SpineProgressionCohesionReportV1({
    required this.rows,
    required this.summary,
  });

  final List<SpineProgressionCohesionRowV1> rows;
  final SpineProgressionCohesionSummaryV1 summary;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summary': summary.toJson(),
    'rows': rows.map((row) => row.toJson()).toList(growable: false),
  };
}

class SpineProgressionCohesionAuditOptionsV1 {
  const SpineProgressionCohesionAuditOptionsV1({this.world, this.idContains});

  final int? world;
  final String? idContains;
}

class SpineProgressionCohesionCliV1 {
  const SpineProgressionCohesionCliV1({
    required this.wantsJson,
    required this.options,
  });

  final bool wantsJson;
  final SpineProgressionCohesionAuditOptionsV1 options;

  static SpineProgressionCohesionCliV1 parse(List<String> args) {
    var wantsJson = false;
    int? world;
    String? idContains;
    for (final arg in args) {
      if (arg == '--json') {
        wantsJson = true;
        continue;
      }
      if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      }
      if (arg.startsWith('--world=')) {
        world = int.tryParse(arg.substring('--world='.length));
        if (world == null || world <= 0) {
          stderr.writeln('Invalid --world value: $arg');
          exit(64);
        }
        continue;
      }
      if (arg.startsWith('--id-contains=')) {
        final value = arg.substring('--id-contains='.length).trim();
        if (value.isEmpty) {
          stderr.writeln('Invalid --id-contains value: $arg');
          exit(64);
        }
        idContains = value.toLowerCase();
        continue;
      }
      stderr.writeln('Unknown option: $arg');
      _printUsage();
      exit(64);
    }
    return SpineProgressionCohesionCliV1(
      wantsJson: wantsJson,
      options: SpineProgressionCohesionAuditOptionsV1(
        world: world,
        idContains: idContains,
      ),
    );
  }
}

void main(List<String> args) {
  final cli = SpineProgressionCohesionCliV1.parse(args);
  final report = buildSpineProgressionCohesionAuditReportV1(
    options: cli.options,
  );
  stdout.writeln(
    cli.wantsJson
        ? encodeSpineProgressionCohesionAuditReportJsonV1(report)
        : renderSpineProgressionCohesionAuditReportV1(report),
  );
}

SpineProgressionCohesionReportV1 buildSpineProgressionCohesionAuditReportV1({
  SpineProgressionCohesionAuditOptionsV1 options =
      const SpineProgressionCohesionAuditOptionsV1(),
  Directory? repoRoot,
  Directory? contentRoot,
}) {
  final resolvedRepoRoot = repoRoot ?? Directory('.');
  final resolvedContentRoot = contentRoot ?? Directory('content');
  final repoTruth = _RepoSpineTruthV1.load(repoRoot: resolvedRepoRoot);
  final baseRows = <SpineProgressionCohesionRowV1>[
    ..._buildCampaignRowsV1(repoTruth),
    ..._buildSessionWorldRowsV1(repoTruth),
    ..._buildTrackRowsV1(repoTruth, resolvedContentRoot),
  ];
  final annotatedRows = _annotateCohesionRowsV1(
    baseRows,
    sessionWorldCohesionSessionIds: repoTruth.sessionWorldCohesionSessionIds,
  );
  final filteredRows = annotatedRows
      .where((row) {
        if (options.world != null && row.world != options.world) {
          return false;
        }
        final idContains = options.idContains;
        if (idContains != null && !row.id.toLowerCase().contains(idContains)) {
          return false;
        }
        return true;
      })
      .toList(growable: false);
  return SpineProgressionCohesionReportV1(
    rows: filteredRows,
    summary: _buildSummaryV1(filteredRows),
  );
}

String encodeSpineProgressionCohesionAuditReportJsonV1(
  SpineProgressionCohesionReportV1 report,
) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(report.toJson());
}

String renderSpineProgressionCohesionAuditReportV1(
  SpineProgressionCohesionReportV1 report,
) {
  final buffer = StringBuffer();
  buffer.writeln('Spine Progression Cohesion Audit v1');
  buffer.writeln(
    'rows=${report.summary.totalRows} '
    'canonical=${report.summary.statusCounts['canonical'] ?? 0} '
    'mixed=${report.summary.statusCounts['mixed'] ?? 0} '
    'divergent=${report.summary.statusCounts['divergent'] ?? 0}',
  );
  buffer.writeln();
  buffer.writeln('World summaries:');
  for (final world in report.summary.worlds) {
    buffer.writeln(
      '  W${world.world}: items=${world.itemCount} '
      'progression=${world.progressionTypes.join(",")} '
      'hosts=${world.hostFamilies.join(",")} '
      'modes=${world.modeFamilies.join(",")}',
    );
  }
  buffer.writeln();
  buffer.writeln(
    'WORLD | ID | ITEM | PROGRESSION | HOST | SCREEN | MODE | CONTRACT | GRAMMAR | PRIMITIVES | STATUS | REASONS',
  );
  for (final row in report.rows) {
    buffer.writeln(
      '${row.world} | ${row.id} | ${row.itemType} | ${row.progressionType} | '
      '${row.hostFamily} | ${row.screenFamily} | ${row.modeFamily} | '
      '${row.runnerContract ?? '-'} | ${row.hostGrammarProfile ?? '-'} | '
      '${row.hostGrammarPrimitives?.join("+") ?? '-'} | '
      '${row.cohesionStatus.name} | ${row.reasonCodes.join(",")}',
    );
  }
  return buffer.toString().trimRight();
}

List<SpineProgressionCohesionRowV1> _buildCampaignRowsV1(
  _RepoSpineTruthV1 truth,
) {
  final rows = <SpineProgressionCohesionRowV1>[];
  final worlds = truth.campaignPackIdsByWorld.keys.toList(growable: false)
    ..sort();
  for (final world in worlds) {
    final packIds = truth.campaignPackIdsByWorld[world]!;
    for (var i = 0; i < packIds.length; i++) {
      final packId = packIds[i];
      final usesSessionDrillPlayer = truth.sessionBackedCampaignPackIds
          .contains(packId);
      final hostFamily = usesSessionDrillPlayer
          ? 'sessionDrillPlayer'
          : 'world1FoundationsRunner';
      final screenFamily = usesSessionDrillPlayer
          ? 'CanonicalTerminalSessionDrillSurfacedRunnerV1'
          : 'World1FoundationsMicroTaskRunnerScreen';
      final grammarFields = _resolveHostGrammarFieldsV1(
        hostFamily: hostFamily,
        screenFamily: screenFamily,
        itemType: 'campaign_pack',
        modeFamily: packId.contains('_act0_') ? 'seatQuiz' : 'campaignSpine',
      );
      rows.add(
        SpineProgressionCohesionRowV1(
          world: world,
          id: packId,
          itemType: 'campaign_pack',
          progressionType: 'campaign_spine_pack',
          hostFamily: hostFamily,
          screenFamily: screenFamily,
          modeFamily: packId.contains('_act0_') ? 'seatQuiz' : 'campaignSpine',
          cohesionStatus: SpineCohesionStatusV1.canonical,
          reasonCodes: const <String>['campaign_spine_surface'],
          orderIndex: i,
          runnerContract: 'sessionDrillRunnerProgressionChrome',
          hostGrammarProfile: grammarFields.hostGrammarProfile,
          hostGrammarPrimitives: grammarFields.hostGrammarPrimitives,
          remainingHostGaps: grammarFields.remainingHostGaps,
          source: 'canonical_truth_map_v1',
        ),
      );
    }
  }
  return rows;
}

List<SpineProgressionCohesionRowV1> _buildSessionWorldRowsV1(
  _RepoSpineTruthV1 truth,
) {
  final rows = <SpineProgressionCohesionRowV1>[];
  final worlds = truth.sessionIdsByWorld.keys.toList(growable: false)..sort();
  for (final world in worlds) {
    final sessionIds = truth.sessionIdsByWorld[world]!;
    for (var i = 0; i < sessionIds.length; i++) {
      final sessionId = sessionIds[i];
      final modeFamily = truth.handChainSessionIds.contains(sessionId)
          ? 'handChain'
          : 'sessionDrillSingleStep';
      final grammarFields = _resolveHostGrammarFieldsV1(
        hostFamily: 'sessionDrillPlayer',
        screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
        itemType: 'session',
        modeFamily: modeFamily,
      );
      rows.add(
        SpineProgressionCohesionRowV1(
          world: world,
          id: sessionId,
          itemType: 'session',
          progressionType: 'session_world',
          hostFamily: 'sessionDrillPlayer',
          screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
          modeFamily: modeFamily,
          cohesionStatus: SpineCohesionStatusV1.canonical,
          reasonCodes: const <String>[
            'session_drill_surface',
            'session_world_surface',
          ],
          orderIndex: i,
          runnerContract: 'sessionDrillRunnerProgressionChrome',
          hostGrammarProfile: grammarFields.hostGrammarProfile,
          hostGrammarPrimitives: grammarFields.hostGrammarPrimitives,
          remainingHostGaps: grammarFields.remainingHostGaps,
          source: 'canonical_truth_map_v1',
        ),
      );
    }
  }
  return rows;
}

List<SpineProgressionCohesionRowV1> _buildTrackRowsV1(
  _RepoSpineTruthV1 truth,
  Directory contentRoot,
) {
  final rows = <SpineProgressionCohesionRowV1>[];
  final canonicalTrackKinds = truth.world10TrackSessionIdsByTrack.keys.toList(
    growable: false,
  )..sort();
  if (canonicalTrackKinds.isNotEmpty) {
    for (final trackKind in canonicalTrackKinds) {
      final sessionIds = truth.world10TrackSessionIdsByTrack[trackKind]!;
      for (var i = 0; i < sessionIds.length; i++) {
        final grammarFields = _resolveHostGrammarFieldsV1(
          hostFamily: 'sessionDrillPlayer',
          screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
          itemType: 'track_session',
          modeFamily: 'sessionDrillSingleStep',
        );
        rows.add(
          SpineProgressionCohesionRowV1(
            world: 10,
            id: sessionIds[i],
            itemType: 'track_session',
            progressionType: 'track_session',
            hostFamily: 'sessionDrillPlayer',
            screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
            modeFamily: 'sessionDrillSingleStep',
            cohesionStatus: SpineCohesionStatusV1.canonical,
            reasonCodes: const <String>[
              'session_drill_surface',
              'track_session_spine',
            ],
            orderIndex: i,
            runnerContract: 'sessionDrillRunnerProgressionChrome',
            hostGrammarProfile: grammarFields.hostGrammarProfile,
            hostGrammarPrimitives: grammarFields.hostGrammarPrimitives,
            remainingHostGaps: grammarFields.remainingHostGaps,
            trackKind: trackKind,
            source: 'canonical_truth_map_v1',
          ),
        );
      }
    }
    return rows;
  }

  final tracksRoot = Directory('${contentRoot.path}/worlds/world10/v1/tracks');
  const trackKinds = <String>['cash', 'mixed', 'tournament'];
  for (final trackKind in trackKinds) {
    final indexFile = File('${tracksRoot.path}/$trackKind/sessions/index.md');
    if (!indexFile.existsSync()) {
      continue;
    }
    final sessionIds = _parseIndexedSessionIdsV1(indexFile);
    for (var i = 0; i < sessionIds.length; i++) {
      rows.add(
        SpineProgressionCohesionRowV1(
          world: 10,
          id: sessionIds[i],
          itemType: 'track_session',
          progressionType: 'track_session',
          hostFamily: 'sessionDrillPlayer',
          screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
          modeFamily: 'sessionDrillSingleStep',
          cohesionStatus: SpineCohesionStatusV1.divergent,
          reasonCodes: const <String>[
            'not_in_canonical_truth_map',
            'session_drill_surface',
            'track_session_spine',
          ],
          orderIndex: i,
          runnerContract: null,
          trackKind: trackKind,
          source: 'world10_track_index_v1',
        ),
      );
    }
  }
  return rows;
}

class _ResolvedHostGrammarFieldsV1 {
  const _ResolvedHostGrammarFieldsV1({
    this.hostGrammarProfile,
    this.hostGrammarPrimitives,
    this.remainingHostGaps,
  });

  final String? hostGrammarProfile;
  final List<String>? hostGrammarPrimitives;
  final List<String>? remainingHostGaps;
}

_ResolvedHostGrammarFieldsV1 _resolveHostGrammarFieldsV1({
  required String hostFamily,
  required String screenFamily,
  required String itemType,
  required String modeFamily,
}) {
  final adoption = resolveSharedLearnerHostGrammarAdoptionV1(
    hostFamily: hostFamily,
    screenFamily: screenFamily,
    itemType: itemType,
    modeFamily: modeFamily,
  );
  if (adoption == null) {
    return const _ResolvedHostGrammarFieldsV1();
  }
  return _ResolvedHostGrammarFieldsV1(
    hostGrammarProfile: adoption.profile.id,
    hostGrammarPrimitives: adoption.profile.primitives
        .map(sharedLearnerHostPrimitiveIdV1)
        .toList(growable: false),
    remainingHostGaps: adoption.profile.remainingGaps
        .map(sharedLearnerHostGapIdV1)
        .toList(growable: false),
  );
}

List<String> _parseIndexedSessionIdsV1(File indexFile) {
  final ids = <String>[];
  final matchLine = RegExp(r'^- ([A-Za-z0-9._-]+):');
  for (final rawLine in indexFile.readAsLinesSync()) {
    final line = rawLine.trim();
    final match = matchLine.firstMatch(line);
    if (match == null) continue;
    ids.add(match.group(1)!.trim().toLowerCase());
  }
  ids.sort();
  return List<String>.unmodifiable(ids);
}

List<SpineProgressionCohesionRowV1> _annotateCohesionRowsV1(
  List<SpineProgressionCohesionRowV1> rows, {
  required Set<String> sessionWorldCohesionSessionIds,
}) {
  final worldBuckets = <int, List<SpineProgressionCohesionRowV1>>{};
  for (final row in rows) {
    worldBuckets.putIfAbsent(
      row.world,
      () => <SpineProgressionCohesionRowV1>[],
    );
    worldBuckets[row.world]!.add(row);
  }

  final annotated = <SpineProgressionCohesionRowV1>[];
  for (final row in rows) {
    final cohortRows = _resolveCohesionBucketRowsV1(
      row: row,
      worldBuckets: worldBuckets,
      sessionWorldCohesionSessionIds: sessionWorldCohesionSessionIds,
    );
    final progressionTypes = cohortRows
        .map((item) => item.progressionType)
        .toSet();
    final hostFamilies = cohortRows.map((item) => item.hostFamily).toSet();
    final modeFamilies = cohortRows
        .map(
          (item) => _normalizeModeFamilyForCohesionV1(
            item,
            sessionWorldCohesionSessionIds: sessionWorldCohesionSessionIds,
          ),
        )
        .toSet();
    final reasonCodes = <String>{...row.reasonCodes};
    SpineCohesionStatusV1 status;
    if (row.source != 'canonical_truth_map_v1') {
      status = SpineCohesionStatusV1.divergent;
    } else if (progressionTypes.length > 1 || hostFamilies.length > 1) {
      status = SpineCohesionStatusV1.mixed;
    } else {
      status = SpineCohesionStatusV1.canonical;
    }
    if (progressionTypes.length > 1) {
      reasonCodes.add('progression_shape_mismatch');
    }
    if (hostFamilies.length > 1) {
      reasonCodes.add('host_family_split');
    }
    if (modeFamilies.length > 1) {
      reasonCodes.add('mode_family_split');
    }
    if (status == SpineCohesionStatusV1.canonical) {
      reasonCodes.add('canonical_spine_ok');
    }
    if (row.hostGrammarProfile != null) {
      reasonCodes.add('shared_host_grammar_adopted');
    }
    annotated.add(
      row.copyWith(
        cohesionStatus: status,
        reasonCodes: reasonCodes.toList(growable: false)..sort(),
      ),
    );
  }
  annotated.sort(_compareRowsV1);
  return List<SpineProgressionCohesionRowV1>.unmodifiable(annotated);
}

List<SpineProgressionCohesionRowV1> _resolveCohesionBucketRowsV1({
  required SpineProgressionCohesionRowV1 row,
  required Map<int, List<SpineProgressionCohesionRowV1>> worldBuckets,
  required Set<String> sessionWorldCohesionSessionIds,
}) {
  final worldRows =
      worldBuckets[row.world] ?? const <SpineProgressionCohesionRowV1>[];
  if (row.itemType == 'campaign_pack') {
    return worldRows
        .where((item) => item.itemType == 'campaign_pack')
        .toList(growable: false);
  }
  if (row.itemType == 'track_session') {
    return worldRows
        .where((item) => item.itemType == 'track_session')
        .toList(growable: false);
  }
  final normalizedId = row.id.trim().toLowerCase();
  if (row.itemType == 'session' &&
      sessionWorldCohesionSessionIds.contains(normalizedId)) {
    return worldRows
        .where(
          (item) =>
              item.itemType == 'session' &&
              sessionWorldCohesionSessionIds.contains(
                item.id.trim().toLowerCase(),
              ),
        )
        .toList(growable: false);
  }
  return worldRows;
}

String _normalizeModeFamilyForCohesionV1(
  SpineProgressionCohesionRowV1 row, {
  required Set<String> sessionWorldCohesionSessionIds,
}) {
  final normalizedId = row.id.trim().toLowerCase();
  if (row.itemType == 'session' &&
      sessionWorldCohesionSessionIds.contains(normalizedId)) {
    return 'sessionWorldSpine';
  }
  return row.modeFamily;
}

SpineProgressionCohesionSummaryV1 _buildSummaryV1(
  List<SpineProgressionCohesionRowV1> rows,
) {
  final statusCounts = _countByV1(rows.map((row) => row.cohesionStatus.name));
  final progressionCounts = _countByV1(rows.map((row) => row.progressionType));
  final hostCounts = _countByV1(rows.map((row) => row.hostFamily));
  final worldBuckets = <int, List<SpineProgressionCohesionRowV1>>{};
  for (final row in rows) {
    worldBuckets.putIfAbsent(
      row.world,
      () => <SpineProgressionCohesionRowV1>[],
    );
    worldBuckets[row.world]!.add(row);
  }
  final worlds =
      worldBuckets.entries
          .map((entry) {
            final worldRows = entry.value;
            return SpineProgressionCohesionWorldSummaryV1(
              world: entry.key,
              itemCount: worldRows.length,
              progressionTypes:
                  worldRows
                      .map((row) => row.progressionType)
                      .toSet()
                      .toList(growable: false)
                    ..sort(),
              hostFamilies:
                  worldRows
                      .map((row) => row.hostFamily)
                      .toSet()
                      .toList(growable: false)
                    ..sort(),
              modeFamilies:
                  worldRows
                      .map((row) => row.modeFamily)
                      .toSet()
                      .toList(growable: false)
                    ..sort(),
            );
          })
          .toList(growable: false)
        ..sort((a, b) => a.world.compareTo(b.world));
  return SpineProgressionCohesionSummaryV1(
    totalRows: rows.length,
    statusCounts: statusCounts,
    progressionCounts: progressionCounts,
    hostCounts: hostCounts,
    worlds: worlds,
  );
}

Map<String, int> _countByV1(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    counts.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  final orderedKeys = counts.keys.toList(growable: false)..sort();
  return <String, int>{for (final key in orderedKeys) key: counts[key]!};
}

int _compareRowsV1(
  SpineProgressionCohesionRowV1 a,
  SpineProgressionCohesionRowV1 b,
) {
  final worldCmp = a.world.compareTo(b.world);
  if (worldCmp != 0) return worldCmp;
  final itemTypeRank = _itemTypeRankV1(
    a.itemType,
  ).compareTo(_itemTypeRankV1(b.itemType));
  if (itemTypeRank != 0) return itemTypeRank;
  final orderCmp = a.orderIndex.compareTo(b.orderIndex);
  if (orderCmp != 0) return orderCmp;
  return a.id.compareTo(b.id);
}

int _itemTypeRankV1(String itemType) {
  switch (itemType) {
    case 'campaign_pack':
      return 0;
    case 'session':
      return 1;
    case 'track_session':
      return 2;
  }
  return 99;
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/spine_progression_cohesion_audit_v1.dart '
    '[--json] [--world=N] [--id-contains=TEXT]',
  );
}

class _RepoSpineTruthV1 {
  const _RepoSpineTruthV1({
    required this.campaignPackIdsByWorld,
    required this.sessionIdsByWorld,
    required this.handChainSessionIds,
    required this.sessionWorldCohesionSessionIds,
    required this.world10TrackSessionIdsByTrack,
    required this.sessionBackedCampaignPackIds,
  });

  final Map<int, List<String>> campaignPackIdsByWorld;
  final Map<int, List<String>> sessionIdsByWorld;
  final Set<String> handChainSessionIds;
  final Set<String> sessionWorldCohesionSessionIds;
  final Map<String, List<String>> world10TrackSessionIdsByTrack;
  final Set<String> sessionBackedCampaignPackIds;

  factory _RepoSpineTruthV1.load({required Directory repoRoot}) {
    final canonicalTruthFile = File(
      '${repoRoot.path}/lib/canonical/canonical_truth_map_v1.dart',
    );
    final campaignRegistryFile = File(
      '${repoRoot.path}/lib/campaign/campaign_pack_registry_v1.dart',
    );
    final canonicalTruthRaw = canonicalTruthFile.readAsStringSync();
    final campaignRegistryRaw = campaignRegistryFile.readAsStringSync();
    final allCampaignPackIds = _parseStringSetConstV1(
      campaignRegistryRaw,
      name: 'kCampaignPackIdsV1',
    );
    final campaignPackIdsByWorld = _groupCampaignPackIdsByWorldV1(
      allCampaignPackIds: allCampaignPackIds,
      world1Order: kWorld1CanonicalModuleOrder,
    );
    final sessionIdsByWorld = _parsePlayableSessionIdsByWorldV1(
      canonicalTruthRaw,
    );
    final handChainSessionIds = _parseStringSetConstV1(
      canonicalTruthRaw,
      name: '_kCanonicalPlayableHandChainSessionIdsV1',
    );
    final sessionWorldCohesionSessionIds = _parseStringSetConstV1(
      canonicalTruthRaw,
      name: '_kCanonicalSessionWorldCohesionSessionIdsV1',
    );
    final sessionBackedCampaignPackIds = _parseStringSetConstV1(
      canonicalTruthRaw,
      name: '_kCanonicalSessionBackedCampaignPackIdsV1',
    );
    final world10TrackSessionIdsByTrack = _parseStringListMapConstV1(
      canonicalTruthRaw,
      name: '_kCanonicalWorld10TrackSessionIdsByTrackV1',
    );
    return _RepoSpineTruthV1(
      campaignPackIdsByWorld: campaignPackIdsByWorld,
      sessionIdsByWorld: sessionIdsByWorld,
      handChainSessionIds: handChainSessionIds,
      sessionWorldCohesionSessionIds: sessionWorldCohesionSessionIds,
      world10TrackSessionIdsByTrack: world10TrackSessionIdsByTrack,
      sessionBackedCampaignPackIds: sessionBackedCampaignPackIds,
    );
  }
}

Map<int, List<String>> _groupCampaignPackIdsByWorldV1({
  required Set<String> allCampaignPackIds,
  required List<String> world1Order,
}) {
  final worlds = <int>{};
  for (final packId in allCampaignPackIds) {
    final world = _worldForPackIdV1(packId);
    if (world != null) {
      worlds.add(world);
    }
  }
  final result = <int, List<String>>{};
  final orderedWorlds = worlds.toList(growable: false)..sort();
  for (final world in orderedWorlds) {
    if (world == 1) {
      result[world] = List<String>.unmodifiable(world1Order);
      continue;
    }
    final prefix = 'world${world}_';
    final sortable = allCampaignPackIds
        .where((id) => id.startsWith(prefix))
        .toList(growable: true);
    sortable.sort(_canonicalCampaignOrderCompareV1);
    result[world] = List<String>.unmodifiable(sortable);
  }
  return Map<int, List<String>>.unmodifiable(result);
}

int _canonicalCampaignOrderCompareV1(String a, String b) {
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

int? _worldForPackIdV1(String packId) {
  final match = RegExp(r'^world(\d+)_').firstMatch(packId.trim().toLowerCase());
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1) ?? '');
}

Map<int, List<String>> _parsePlayableSessionIdsByWorldV1(String source) {
  final blockMatch = RegExp(
    r'const Map<int, List<String>> _kCanonicalPlayableScenarioSessionIdsByWorldV1 =\s*<int, List<String>>\{([\s\S]*?)\n\s*\};',
  ).firstMatch(source);
  if (blockMatch == null) {
    throw StateError(
      'Missing _kCanonicalPlayableScenarioSessionIdsByWorldV1 source block.',
    );
  }
  final block = blockMatch.group(1)!;
  final entryMatches = RegExp(
    r'(\d+): <String>\[([\s\S]*?)\],',
    multiLine: true,
  ).allMatches(block);
  final result = <int, List<String>>{};
  for (final match in entryMatches) {
    final world = int.parse(match.group(1)!);
    final sessions = _parseQuotedStringsV1(match.group(2)!);
    result[world] = List<String>.unmodifiable(sessions);
  }
  return Map<int, List<String>>.unmodifiable(result);
}

Map<String, List<String>> _parseStringListMapConstV1(
  String source, {
  required String name,
}) {
  final match = RegExp(
    'const Map<String, List<String>> $name =\\s*<String, List<String>>\\{([\\s\\S]*?)\\n\\s*\\};',
  ).firstMatch(source);
  if (match == null) {
    throw StateError('Missing const string-list map $name.');
  }
  final block = match.group(1)!;
  final entryMatches = RegExp(
    r"'([^']+)': <String>\[([\s\S]*?)\],",
    multiLine: true,
  ).allMatches(block);
  final result = <String, List<String>>{};
  for (final entry in entryMatches) {
    final key = entry.group(1)!.trim().toLowerCase();
    final values = _parseQuotedStringsV1(entry.group(2)!);
    result[key] = List<String>.unmodifiable(values);
  }
  final orderedKeys = result.keys.toList(growable: false)..sort();
  return Map<String, List<String>>.unmodifiable({
    for (final key in orderedKeys) key: result[key]!,
  });
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
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}
