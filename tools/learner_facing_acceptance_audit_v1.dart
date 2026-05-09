import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';
import 'spine_progression_cohesion_audit_v1.dart' as spine_audit;

enum LearnerFacingAcceptanceIssueTypeV1 { assetLaunchability, presentation }

enum LearnerFacingAcceptanceSeverityV1 { warning, error }

class LearnerFacingAcceptanceIssueV1 {
  const LearnerFacingAcceptanceIssueV1({
    required this.world,
    required this.itemId,
    required this.itemType,
    required this.issueType,
    required this.severity,
    required this.reasonCode,
    this.path,
    this.hostFamily,
    this.screenFamily,
    this.layoutFamily,
    this.promptPositionFamily,
    this.supportLaneFamily,
    this.headerCompositionFamily,
    this.sceneTextPlacementFamily,
  });

  final int world;
  final String itemId;
  final String itemType;
  final LearnerFacingAcceptanceIssueTypeV1 issueType;
  final LearnerFacingAcceptanceSeverityV1 severity;
  final String reasonCode;
  final String? path;
  final String? hostFamily;
  final String? screenFamily;
  final String? layoutFamily;
  final String? promptPositionFamily;
  final String? supportLaneFamily;
  final String? headerCompositionFamily;
  final String? sceneTextPlacementFamily;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'item_id': itemId,
    'item_type': itemType,
    'issue_type': issueType.name,
    'severity': severity.name,
    'reason_code': reasonCode,
    if (path != null) 'path': path!,
    if (hostFamily != null) 'host_family': hostFamily!,
    if (screenFamily != null) 'screen_family': screenFamily!,
    if (layoutFamily != null) 'layout_family': layoutFamily!,
    if (promptPositionFamily != null)
      'prompt_position_family': promptPositionFamily!,
    if (supportLaneFamily != null) 'support_lane_family': supportLaneFamily!,
    if (headerCompositionFamily != null)
      'header_composition_family': headerCompositionFamily!,
    if (sceneTextPlacementFamily != null)
      'scene_text_placement_family': sceneTextPlacementFamily!,
  };
}

class LearnerFacingAcceptanceSummaryV1 {
  const LearnerFacingAcceptanceSummaryV1({
    required this.totalIssues,
    required this.errorCount,
    required this.warningCount,
    required this.assetIssueCount,
    required this.presentationIssueCount,
    required this.reasonCounts,
  });

  final int totalIssues;
  final int errorCount;
  final int warningCount;
  final int assetIssueCount;
  final int presentationIssueCount;
  final Map<String, int> reasonCounts;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'error_count': errorCount,
    'warning_count': warningCount,
    'asset_issue_count': assetIssueCount,
    'presentation_issue_count': presentationIssueCount,
    'reason_counts': reasonCounts,
  };
}

class LearnerFacingAcceptanceAuditReportV1 {
  const LearnerFacingAcceptanceAuditReportV1({
    required this.issues,
    required this.summary,
  });

  final List<LearnerFacingAcceptanceIssueV1> issues;
  final LearnerFacingAcceptanceSummaryV1 summary;

  bool get hasBlockingIssues => summary.errorCount > 0;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summary': summary.toJson(),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

class LearnerFacingAcceptanceAuditOptionsV1 {
  const LearnerFacingAcceptanceAuditOptionsV1({
    this.world,
    this.includePresentationIssues = true,
  });

  final int? world;
  final bool includePresentationIssues;
}

class _LearnerFacingAcceptanceCliV1 {
  const _LearnerFacingAcceptanceCliV1({
    required this.wantsJson,
    required this.options,
  });

  final bool wantsJson;
  final LearnerFacingAcceptanceAuditOptionsV1 options;

  static _LearnerFacingAcceptanceCliV1 parse(List<String> args) {
    var wantsJson = false;
    int? world;
    for (final arg in args) {
      if (arg == '--json') {
        wantsJson = true;
        continue;
      }
      if (arg == '--help' || arg == '-h') {
        _printUsageV1();
        exit(0);
      }
      if (arg.startsWith('--world=')) {
        world = int.tryParse(arg.substring('--world='.length));
        if (world == null || world < 0) {
          stderr.writeln('Invalid --world value: $arg');
          exit(64);
        }
        continue;
      }
      stderr.writeln('Unknown option: $arg');
      _printUsageV1();
      exit(64);
    }
    return _LearnerFacingAcceptanceCliV1(
      wantsJson: wantsJson,
      options: LearnerFacingAcceptanceAuditOptionsV1(world: world),
    );
  }
}

class _SessionManifestDrillV1 {
  const _SessionManifestDrillV1({required this.id, required this.path});

  final String id;
  final String path;
}

class _SessionManifestEntryV1 {
  const _SessionManifestEntryV1({
    required this.world,
    required this.sessionId,
    required this.sessionPath,
    required this.drills,
  });

  final int world;
  final String sessionId;
  final String sessionPath;
  final Map<String, _SessionManifestDrillV1> drills;
}

class _PresentationLayoutClassificationV1 {
  const _PresentationLayoutClassificationV1({
    required this.layoutFamily,
    required this.promptPositionFamily,
    required this.supportLaneFamily,
    required this.headerCompositionFamily,
    required this.sceneTextPlacementFamily,
  });

  final String layoutFamily;
  final String promptPositionFamily;
  final String supportLaneFamily;
  final String headerCompositionFamily;
  final String sceneTextPlacementFamily;
}

void main(List<String> args) {
  final cli = _LearnerFacingAcceptanceCliV1.parse(args);
  final report = buildLearnerFacingAcceptanceAuditReportV1(
    options: cli.options,
  );
  stdout.writeln(
    cli.wantsJson
        ? encodeLearnerFacingAcceptanceAuditReportJsonV1(report)
        : renderLearnerFacingAcceptanceAuditReportV1(report),
  );
  exitCode = report.hasBlockingIssues ? 1 : 0;
}

LearnerFacingAcceptanceAuditReportV1 buildLearnerFacingAcceptanceAuditReportV1({
  String rootPath = '.',
  LearnerFacingAcceptanceAuditOptionsV1 options =
      const LearnerFacingAcceptanceAuditOptionsV1(),
}) {
  final spineRows = options.includePresentationIssues
      ? spine_audit
            .buildSpineProgressionCohesionAuditReportV1(
              options: spine_audit.SpineProgressionCohesionAuditOptionsV1(
                world: options.world,
              ),
              repoRoot: Directory(rootPath),
              contentRoot: Directory('$rootPath/content'),
            )
            .rows
      : const <spine_audit.SpineProgressionCohesionRowV1>[];
  final issues = <LearnerFacingAcceptanceIssueV1>[
    ..._buildAssetIssuesV1(rootPath, spineRows, options.world),
    if (options.includePresentationIssues)
      ..._buildPresentationIssuesV1(spineRows),
  ]..sort(_compareIssuesV1);
  return LearnerFacingAcceptanceAuditReportV1(
    issues: List<LearnerFacingAcceptanceIssueV1>.unmodifiable(issues),
    summary: _buildSummaryV1(issues),
  );
}

String renderLearnerFacingAcceptanceAuditReportV1(
  LearnerFacingAcceptanceAuditReportV1 report,
) {
  final out = StringBuffer()
    ..writeln(
      'issues=${report.summary.totalIssues} '
      'errors=${report.summary.errorCount} '
      'warnings=${report.summary.warningCount} '
      'asset=${report.summary.assetIssueCount} '
      'presentation=${report.summary.presentationIssueCount}',
    )
    ..writeln()
    ..writeln(
      'WORLD | ITEM | ITEM_TYPE | ISSUE_TYPE | SEVERITY | REASON | PATH | '
      'HOST | SCREEN | LAYOUT | PROMPT | SUPPORT | HEADER | SCENE_TEXT',
    );
  for (final issue in report.issues) {
    out.writeln(
      '${issue.world} | ${issue.itemId} | ${issue.itemType} | '
      '${issue.issueType.name} | ${issue.severity.name} | ${issue.reasonCode} | '
      '${issue.path ?? '-'} | ${issue.hostFamily ?? '-'} | '
      '${issue.screenFamily ?? '-'} | ${issue.layoutFamily ?? '-'} | '
      '${issue.promptPositionFamily ?? '-'} | '
      '${issue.supportLaneFamily ?? '-'} | '
      '${issue.headerCompositionFamily ?? '-'} | '
      '${issue.sceneTextPlacementFamily ?? '-'}',
    );
  }
  return out.toString().trimRight();
}

String encodeLearnerFacingAcceptanceAuditReportJsonV1(
  LearnerFacingAcceptanceAuditReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

List<LearnerFacingAcceptanceIssueV1> _buildAssetIssuesV1(
  String rootPath,
  List<spine_audit.SpineProgressionCohesionRowV1> rows,
  int? worldFilter,
) {
  final manifestBySession = _loadSessionManifestMapV1(rootPath);
  final issues = <LearnerFacingAcceptanceIssueV1>[];
  final targetSessions = <({int world, String id, String itemType})>[
    if (rows.isNotEmpty)
      ...rows
          .where((row) => row.itemType != 'campaign_pack')
          .map((row) => (world: row.world, id: row.id, itemType: row.itemType))
    else
      ...manifestBySession.values
          .where((entry) => worldFilter == null || entry.world == worldFilter)
          .map(
            (entry) => (
              world: entry.world,
              id: entry.sessionId,
              itemType: entry.sessionId.startsWith('w')
                  ? 'session'
                  : 'track_session',
            ),
          ),
  ];
  targetSessions.sort((a, b) {
    final worldCompare = a.world.compareTo(b.world);
    if (worldCompare != 0) return worldCompare;
    return a.id.compareTo(b.id);
  });

  for (final row in targetSessions) {
    final sessionPath = _sessionPathForItemIdV1(row.id);
    final sessionDir = Directory('$rootPath/$sessionPath');
    if (!sessionDir.existsSync()) {
      issues.add(
        LearnerFacingAcceptanceIssueV1(
          world: row.world,
          itemId: row.id,
          itemType: row.itemType,
          issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
          severity: LearnerFacingAcceptanceSeverityV1.error,
          reasonCode: 'missing_session_dir',
          path: sessionPath,
        ),
      );
      continue;
    }

    final indexPath = '$sessionPath/drills/index.md';
    final indexFile = File('$rootPath/$indexPath');
    final indexIds = <String>{};
    if (!indexFile.existsSync()) {
      issues.add(
        LearnerFacingAcceptanceIssueV1(
          world: row.world,
          itemId: row.id,
          itemType: row.itemType,
          issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
          severity: LearnerFacingAcceptanceSeverityV1.error,
          reasonCode: 'missing_drills_index',
          path: indexPath,
        ),
      );
    } else {
      final source = indexFile.readAsStringSync();
      if (source.trim().isEmpty) {
        issues.add(
          LearnerFacingAcceptanceIssueV1(
            world: row.world,
            itemId: row.id,
            itemType: row.itemType,
            issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
            severity: LearnerFacingAcceptanceSeverityV1.error,
            reasonCode: 'empty_drills_index',
            path: indexPath,
          ),
        );
      } else {
        try {
          indexIds.addAll(parseDrillIdsFromIndexV1(source));
        } on FormatException {
          issues.add(
            LearnerFacingAcceptanceIssueV1(
              world: row.world,
              itemId: row.id,
              itemType: row.itemType,
              issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
              severity: LearnerFacingAcceptanceSeverityV1.error,
              reasonCode: 'invalid_drills_index',
              path: indexPath,
            ),
          );
        }
      }
    }

    final manifestEntry = manifestBySession[row.id];
    final manifestIds = manifestEntry?.drills.keys.toSet() ?? const <String>{};
    final drillIds = <String>{...indexIds, ...manifestIds}.toList()..sort();
    for (final drillId in drillIds) {
      final derivedPath = '$sessionPath/drills/d.$drillId.json';
      final manifestPath = manifestEntry?.drills[drillId]?.path;
      final candidatePaths = <String>[
        derivedPath,
        if (manifestPath != null && manifestPath != derivedPath) manifestPath,
      ];
      File? resolvedFile;
      String? resolvedPath;
      for (final candidatePath in candidatePaths) {
        final file = File('$rootPath/$candidatePath');
        if (file.existsSync()) {
          resolvedFile = file;
          resolvedPath = candidatePath;
          break;
        }
      }

      if (resolvedFile == null || resolvedPath == null) {
        issues.add(
          LearnerFacingAcceptanceIssueV1(
            world: row.world,
            itemId: row.id,
            itemType: row.itemType,
            issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
            severity: LearnerFacingAcceptanceSeverityV1.error,
            reasonCode: indexIds.contains(drillId)
                ? 'broken_drill_reference'
                : 'missing_manifest_drill_asset',
            path: manifestPath ?? derivedPath,
          ),
        );
        continue;
      }

      final source = resolvedFile.readAsStringSync();
      if (source.trim().isEmpty) {
        issues.add(
          LearnerFacingAcceptanceIssueV1(
            world: row.world,
            itemId: row.id,
            itemType: row.itemType,
            issueType: LearnerFacingAcceptanceIssueTypeV1.assetLaunchability,
            severity: LearnerFacingAcceptanceSeverityV1.error,
            reasonCode: 'empty_drill_file',
            path: resolvedPath,
          ),
        );
      }
    }
  }

  return issues;
}

Map<String, _SessionManifestEntryV1> _loadSessionManifestMapV1(
  String rootPath,
) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <String, _SessionManifestEntryV1>{};
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <String, _SessionManifestEntryV1>{};
  }
  final worlds = decoded['worlds'];
  if (worlds is! List<Object?>) {
    return const <String, _SessionManifestEntryV1>{};
  }
  final entries = <String, _SessionManifestEntryV1>{};
  for (final worldEntry in worlds) {
    if (worldEntry is! Map<String, Object?>) {
      continue;
    }
    final world = worldEntry['world'];
    final sessions = worldEntry['sessions'];
    if (world is! int || sessions is! List<Object?>) {
      continue;
    }
    for (final sessionEntry in sessions) {
      if (sessionEntry is! Map<String, Object?>) {
        continue;
      }
      final sessionId = sessionEntry['id'];
      final sessionPath = sessionEntry['path'];
      final drills = sessionEntry['drills'];
      if (sessionId is! String ||
          sessionId.isEmpty ||
          sessionPath is! String ||
          sessionPath.isEmpty ||
          drills is! List<Object?>) {
        continue;
      }
      final drillEntries = <String, _SessionManifestDrillV1>{};
      for (final drillEntry in drills) {
        if (drillEntry is! Map<String, Object?>) {
          continue;
        }
        final drillId = drillEntry['id'];
        final drillPath = drillEntry['path'];
        if (drillId is! String ||
            drillId.isEmpty ||
            drillPath is! String ||
            drillPath.isEmpty) {
          continue;
        }
        drillEntries[drillId] = _SessionManifestDrillV1(
          id: drillId,
          path: drillPath,
        );
      }
      entries[sessionId] = _SessionManifestEntryV1(
        world: world,
        sessionId: sessionId,
        sessionPath: sessionPath,
        drills: Map<String, _SessionManifestDrillV1>.unmodifiable(drillEntries),
      );
    }
  }
  return Map<String, _SessionManifestEntryV1>.unmodifiable(entries);
}

List<LearnerFacingAcceptanceIssueV1> _buildPresentationIssuesV1(
  List<spine_audit.SpineProgressionCohesionRowV1> rows,
) {
  final classifiedRows =
      <
        ({
          spine_audit.SpineProgressionCohesionRowV1 row,
          _PresentationLayoutClassificationV1 classification,
        })
      >[];
  for (final row in rows) {
    final classification = _classifyPresentationV1(row);
    if (classification == null || row.hostGrammarProfile == null) {
      continue;
    }
    classifiedRows.add((row: row, classification: classification));
  }

  final majorityByGrammar = <String, _PresentationLayoutClassificationV1>{};
  final countsByGrammar = <String, Map<String, int>>{};
  final sampleByGrammarAndLayout =
      <String, Map<String, _PresentationLayoutClassificationV1>>{};

  for (final entry in classifiedRows) {
    final grammarId = entry.row.hostGrammarProfile!;
    final layoutFamily = entry.classification.layoutFamily;
    countsByGrammar
        .putIfAbsent(grammarId, () => <String, int>{})
        .update(layoutFamily, (value) => value + 1, ifAbsent: () => 1);
    sampleByGrammarAndLayout
        .putIfAbsent(
          grammarId,
          () => <String, _PresentationLayoutClassificationV1>{},
        )
        .putIfAbsent(layoutFamily, () => entry.classification);
  }

  for (final entry in countsByGrammar.entries) {
    final sortedLayouts = entry.value.keys.toList()
      ..sort((a, b) {
        final countCompare = entry.value[b]!.compareTo(entry.value[a]!);
        if (countCompare != 0) return countCompare;
        return a.compareTo(b);
      });
    final layoutFamily = sortedLayouts.first;
    majorityByGrammar[entry.key] =
        sampleByGrammarAndLayout[entry.key]![layoutFamily]!;
  }

  final issues = <LearnerFacingAcceptanceIssueV1>[];
  for (final entry in classifiedRows) {
    final grammarId = entry.row.hostGrammarProfile!;
    final majority = majorityByGrammar[grammarId];
    if (majority == null) {
      continue;
    }
    if (entry.classification.layoutFamily == majority.layoutFamily) {
      continue;
    }
    issues.add(
      LearnerFacingAcceptanceIssueV1(
        world: entry.row.world,
        itemId: entry.row.id,
        itemType: entry.row.itemType,
        issueType: LearnerFacingAcceptanceIssueTypeV1.presentation,
        severity: LearnerFacingAcceptanceSeverityV1.warning,
        reasonCode: 'layout_family_mismatch_with_shared_grammar_majority',
        hostFamily: entry.row.hostFamily,
        screenFamily: entry.row.screenFamily,
        layoutFamily: entry.classification.layoutFamily,
        promptPositionFamily: entry.classification.promptPositionFamily,
        supportLaneFamily: entry.classification.supportLaneFamily,
        headerCompositionFamily: entry.classification.headerCompositionFamily,
        sceneTextPlacementFamily: entry.classification.sceneTextPlacementFamily,
      ),
    );
  }
  return issues;
}

_PresentationLayoutClassificationV1? _classifyPresentationV1(
  spine_audit.SpineProgressionCohesionRowV1 row,
) {
  final normalizedScreenFamily = normalizeSharedLearnerHostScreenFamilyV1(
    row.screenFamily,
  );
  if (row.hostFamily == 'sessionDrillPlayer' &&
      normalizedScreenFamily ==
          'CanonicalTerminalSessionDrillSurfacedRunnerV1') {
    return const _PresentationLayoutClassificationV1(
      layoutFamily: 'compact_header_above_scene_support_below_scene',
      promptPositionFamily: 'header_capsule_above_scene',
      supportLaneFamily: 'post_scene_support_lane',
      headerCompositionFamily: 'compact_header_band_plus_prompt_capsule',
      sceneTextPlacementFamily: 'scene_clean_support_below_table',
    );
  }
  if (row.hostFamily == 'world1FoundationsRunner' &&
      row.screenFamily == 'World1FoundationsMicroTaskRunnerScreen') {
    return const _PresentationLayoutClassificationV1(
      layoutFamily: 'step_header_above_scene_support_bottom_overlay',
      promptPositionFamily: 'header_instruction_or_hidden_prompt',
      supportLaneFamily: 'bottom_overlay_support_lane',
      headerCompositionFamily: 'step_header_plus_scene_prompt_variants',
      sceneTextPlacementFamily: 'scene_inline_guidance_plus_bottom_support',
    );
  }
  return null;
}

LearnerFacingAcceptanceSummaryV1 _buildSummaryV1(
  List<LearnerFacingAcceptanceIssueV1> issues,
) {
  var errorCount = 0;
  var warningCount = 0;
  var assetIssueCount = 0;
  var presentationIssueCount = 0;
  final reasonCounts = <String, int>{};
  for (final issue in issues) {
    switch (issue.severity) {
      case LearnerFacingAcceptanceSeverityV1.warning:
        warningCount++;
      case LearnerFacingAcceptanceSeverityV1.error:
        errorCount++;
    }
    switch (issue.issueType) {
      case LearnerFacingAcceptanceIssueTypeV1.assetLaunchability:
        assetIssueCount++;
      case LearnerFacingAcceptanceIssueTypeV1.presentation:
        presentationIssueCount++;
    }
    reasonCounts.update(
      issue.reasonCode,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return LearnerFacingAcceptanceSummaryV1(
    totalIssues: issues.length,
    errorCount: errorCount,
    warningCount: warningCount,
    assetIssueCount: assetIssueCount,
    presentationIssueCount: presentationIssueCount,
    reasonCounts: Map<String, int>.unmodifiable(reasonCounts),
  );
}

int _compareIssuesV1(
  LearnerFacingAcceptanceIssueV1 a,
  LearnerFacingAcceptanceIssueV1 b,
) {
  final worldCompare = a.world.compareTo(b.world);
  if (worldCompare != 0) return worldCompare;
  final itemCompare = a.itemId.compareTo(b.itemId);
  if (itemCompare != 0) return itemCompare;
  final typeCompare = a.issueType.name.compareTo(b.issueType.name);
  if (typeCompare != 0) return typeCompare;
  return a.reasonCode.compareTo(b.reasonCode);
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/learner_facing_acceptance_audit_v1.dart '
    '[--json] [--world=<n>]',
  );
}

String _sessionPathForItemIdV1(String itemId) {
  final normalized = itemId.trim().toLowerCase();
  if (normalized == 'world10_spine_followup_v1_b0') {
    return 'content/worlds/world10/v1/tracks/cash/sessions/cash.s01';
  }
  if (normalized == 'world10_spine_followup_v1_b1') {
    return 'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01';
  }
  if (normalized == 'world10_spine_followup_v1_b2') {
    return 'content/worlds/world10/v1/tracks/mixed/sessions/mixed.s01';
  }
  final trackMatch = RegExp(
    r'^(cash|tournament|mixed)\.s[0-9]+$',
  ).firstMatch(normalized);
  if (trackMatch != null) {
    final track = trackMatch.group(1)!;
    return 'content/worlds/world10/v1/tracks/$track/sessions/$normalized';
  }
  final match = RegExp(r'^w([0-9]+)\.s[0-9]+$').firstMatch(itemId);
  if (match == null) {
    throw FormatException('Invalid learner-facing session id: $itemId');
  }
  final world = int.parse(match.group(1)!);
  return 'content/worlds/world$world/v1/sessions/$itemId';
}
