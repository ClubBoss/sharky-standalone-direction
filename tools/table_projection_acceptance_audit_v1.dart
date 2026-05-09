import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_defaults_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_hand_chain_projection_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_spatial_projection_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_world9_seat_id_projection_contract_v1.dart';

enum TableProjectionIssueSeverityV1 { error, warning }

enum _AuditHostSurfaceV1 { world1FoundationsRunner, sessionDrillPlayer }

class TableProjectionIssueV1 {
  const TableProjectionIssueV1({
    required this.world,
    required this.sessionId,
    required this.issueType,
    required this.reasonCode,
    required this.severity,
    required this.hostSurface,
    required this.layoutFamily,
    required this.requiredLayoutFamily,
    required this.drillId,
    required this.drillKind,
    required this.drillPath,
  });

  final int world;
  final String sessionId;
  final String issueType;
  final String reasonCode;
  final TableProjectionIssueSeverityV1 severity;
  final String hostSurface;
  final String layoutFamily;
  final String requiredLayoutFamily;
  final String drillId;
  final String drillKind;
  final String drillPath;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'session_id': sessionId,
    'issue_type': issueType,
    'reason_code': reasonCode,
    'severity': severity.name,
    'host_surface': hostSurface,
    'layout_family': layoutFamily,
    'required_layout_family': requiredLayoutFamily,
    'drill_id': drillId,
    'drill_kind': drillKind,
    'drill_path': drillPath,
  };
}

class TableProjectionAuditSummaryV1 {
  const TableProjectionAuditSummaryV1({
    required this.totalIssues,
    required this.errorCount,
    required this.warningCount,
    required this.reasonCounts,
  });

  final int totalIssues;
  final int errorCount;
  final int warningCount;
  final Map<String, int> reasonCounts;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'error_count': errorCount,
    'warning_count': warningCount,
    'reason_counts': reasonCounts,
  };
}

class TableProjectionAuditReportV1 {
  const TableProjectionAuditReportV1({
    required this.issues,
    required this.summary,
  });

  final List<TableProjectionIssueV1> issues;
  final TableProjectionAuditSummaryV1 summary;

  bool get hasBlockingIssues => summary.errorCount > 0;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summary': summary.toJson(),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

class TableProjectionAuditOptionsV1 {
  const TableProjectionAuditOptionsV1({this.world});

  final int? world;
}

class _TableProjectionCliV1 {
  const _TableProjectionCliV1({required this.wantsJson, required this.options});

  final bool wantsJson;
  final TableProjectionAuditOptionsV1 options;

  static _TableProjectionCliV1 parse(List<String> args) {
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
    return _TableProjectionCliV1(
      wantsJson: wantsJson,
      options: TableProjectionAuditOptionsV1(world: world),
    );
  }
}

class _SessionProjectionRefV1 {
  const _SessionProjectionRefV1({
    required this.world,
    required this.sessionId,
    required this.sessionPath,
    required this.hostSurface,
    required this.layoutFamily,
  });

  final int world;
  final String sessionId;
  final String sessionPath;
  final _AuditHostSurfaceV1 hostSurface;
  final String layoutFamily;
}

class _DrillProjectionRefV1 {
  const _DrillProjectionRefV1({
    required this.drillId,
    required this.drillPath,
    required this.spec,
    required this.hasSessionProjectionDefaults,
  });

  final String drillId;
  final String drillPath;
  final DrillSpecV1 spec;
  final bool hasSessionProjectionDefaults;
}

// Mirrors the current SessionDrillPlayer embedded-table gate.
const Set<String> _kWorld2SingleStepScenarioSessionIdsAuditV1 = <String>{
  'w2.s01',
  'w2.s02',
  'w2.s03',
  'w2.s04',
  'w2.s06',
};

const Set<String> _kEmbeddedHandChainScenarioSessionIdsAuditV1 = <String>{
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

const Set<String> _kWorld5TextureScenarioSessionIdsAuditV1 = <String>{
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
};

void main(List<String> args) {
  final cli = _TableProjectionCliV1.parse(args);
  final report = buildTableProjectionAcceptanceAuditReportV1(
    options: cli.options,
  );
  stdout.writeln(
    cli.wantsJson
        ? const JsonEncoder.withIndent('  ').convert(report.toJson())
        : renderTableProjectionAcceptanceAuditReportV1(report),
  );
  exitCode = report.hasBlockingIssues ? 1 : 0;
}

TableProjectionAuditReportV1 buildTableProjectionAcceptanceAuditReportV1({
  String rootPath = '.',
  TableProjectionAuditOptionsV1 options = const TableProjectionAuditOptionsV1(),
}) {
  final sessions =
      _loadSessionProjectionRefsV1(
        rootPath: rootPath,
        worldFilter: options.world,
      )..sort((a, b) {
        final worldCompare = a.world.compareTo(b.world);
        if (worldCompare != 0) {
          return worldCompare;
        }
        return a.sessionId.compareTo(b.sessionId);
      });
  final issues = <TableProjectionIssueV1>[];
  for (final session in sessions) {
    final drills = _loadDrillsForSessionV1(
      rootPath: rootPath,
      session: session,
    );
    issues.addAll(_auditSessionV1(session: session, drills: drills));
  }
  issues.sort((a, b) {
    final worldCompare = a.world.compareTo(b.world);
    if (worldCompare != 0) {
      return worldCompare;
    }
    final sessionCompare = a.sessionId.compareTo(b.sessionId);
    if (sessionCompare != 0) {
      return sessionCompare;
    }
    final typeCompare = a.issueType.compareTo(b.issueType);
    if (typeCompare != 0) {
      return typeCompare;
    }
    return a.drillId.compareTo(b.drillId);
  });
  return TableProjectionAuditReportV1(
    issues: List<TableProjectionIssueV1>.unmodifiable(issues),
    summary: _buildSummaryV1(issues),
  );
}

String renderTableProjectionAcceptanceAuditReportV1(
  TableProjectionAuditReportV1 report,
) {
  final out = StringBuffer()
    ..writeln(
      'issues=${report.summary.totalIssues} '
      'errors=${report.summary.errorCount} '
      'warnings=${report.summary.warningCount}',
    )
    ..writeln()
    ..writeln(
      'WORLD | SESSION | ISSUE_TYPE | REASON | HOST | LAYOUT | REQUIRED | '
      'DRILL_ID | DRILL_KIND | PATH',
    );
  for (final issue in report.issues) {
    out.writeln(
      '${issue.world} | ${issue.sessionId} | ${issue.issueType} | '
      '${issue.reasonCode} | ${issue.hostSurface} | ${issue.layoutFamily} | '
      '${issue.requiredLayoutFamily} | ${issue.drillId} | '
      '${issue.drillKind} | ${issue.drillPath}',
    );
  }
  return out.toString().trimRight();
}

List<_SessionProjectionRefV1> _loadSessionProjectionRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  final refs = <_SessionProjectionRefV1>[
    ..._loadManifestSessionProjectionRefsV1(
      rootPath: rootPath,
      worldFilter: worldFilter,
    ),
    ..._scanWorld10TrackSessionProjectionRefsV1(
      rootPath: rootPath,
      worldFilter: worldFilter,
    ),
  ];
  final seen = <String>{};
  return refs.where((ref) => seen.add(ref.sessionId)).toList(growable: false);
}

List<_SessionProjectionRefV1> _loadManifestSessionProjectionRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <_SessionProjectionRefV1>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <_SessionProjectionRefV1>[];
  }
  final worlds = decoded['worlds'];
  if (worlds is! List<Object?>) {
    return const <_SessionProjectionRefV1>[];
  }
  final refs = <_SessionProjectionRefV1>[];
  for (final worldEntry in worlds) {
    if (worldEntry is! Map<String, Object?>) {
      continue;
    }
    final world = worldEntry['world'];
    final sessions = worldEntry['sessions'];
    if (world is! int || sessions is! List<Object?>) {
      continue;
    }
    if (worldFilter != null && world != worldFilter) {
      continue;
    }
    for (final sessionEntry in sessions) {
      if (sessionEntry is! Map<String, Object?>) {
        continue;
      }
      final sessionId = sessionEntry['id'];
      final sessionPath = sessionEntry['path'];
      if (sessionId is! String || sessionPath is! String) {
        continue;
      }
      refs.add(
        _SessionProjectionRefV1(
          world: world,
          sessionId: sessionId,
          sessionPath: sessionPath.replaceFirst(RegExp(r'/$'), ''),
          hostSurface: _hostSurfaceForSessionIdV1(sessionId),
          layoutFamily: _layoutFamilyForSessionIdV1(sessionId),
        ),
      );
    }
  }
  return refs;
}

List<_SessionProjectionRefV1> _scanWorld10TrackSessionProjectionRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  if (worldFilter != null && worldFilter != 10) {
    return const <_SessionProjectionRefV1>[];
  }
  final tracksDir = Directory('$rootPath/content/worlds/world10/v1/tracks');
  if (!tracksDir.existsSync()) {
    return const <_SessionProjectionRefV1>[];
  }
  final refs = <_SessionProjectionRefV1>[];
  for (final trackDir in tracksDir.listSync().whereType<Directory>()) {
    final sessionsDir = Directory('${trackDir.path}/sessions');
    if (!sessionsDir.existsSync()) {
      continue;
    }
    for (final sessionDir in sessionsDir.listSync().whereType<Directory>()) {
      final sessionId = sessionDir.path.split('/').last;
      refs.add(
        _SessionProjectionRefV1(
          world: 10,
          sessionId: sessionId,
          sessionPath: sessionDir.path
              .replaceFirst('$rootPath/', '')
              .replaceFirst(RegExp(r'/$'), ''),
          hostSurface: _AuditHostSurfaceV1.sessionDrillPlayer,
          layoutFamily: _layoutFamilyForSessionIdV1(sessionId),
        ),
      );
    }
  }
  return refs;
}

List<_DrillProjectionRefV1> _loadDrillsForSessionV1({
  required String rootPath,
  required _SessionProjectionRefV1 session,
}) {
  final drillsDir = Directory('$rootPath/${session.sessionPath}/drills');
  if (!drillsDir.existsSync()) {
    return const <_DrillProjectionRefV1>[];
  }
  final allowedDrillIds = _loadLearnerFacingDrillIdsForSessionV1(
    rootPath: rootPath,
    session: session,
  );
  final defaultsRaw = _loadOptionalFileTextV1(
    '$rootPath/${sessionDrillProjectionDefaultsPathForSessionPathV1(session.sessionPath)}',
  );
  final refs = <_DrillProjectionRefV1>[];
  for (final file in drillsDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.json')) {
      continue;
    }
    final raw = file.readAsStringSync();
    final drillId = file.uri.pathSegments.last
        .replaceFirst('d.', '')
        .replaceFirst('.json', '');
    if (allowedDrillIds.isNotEmpty && !allowedDrillIds.contains(drillId)) {
      continue;
    }
    final mergedRaw = mergeSessionDrillProjectionDefaultsIntoDrillJsonV1(
      sessionId: session.sessionId,
      drillId: drillId,
      drillRaw: raw,
      defaultsRaw: defaultsRaw,
    );
    final spec = DrillSpecV1.fromJsonString(mergedRaw);
    refs.add(
      _DrillProjectionRefV1(
        drillId: spec.id,
        drillPath: file.path.replaceFirst('$rootPath/', ''),
        spec: spec,
        hasSessionProjectionDefaults:
            sessionDrillProjectionDefaultsApplyToDrillV1(
              sessionId: session.sessionId,
              drillId: spec.id,
              defaultsRaw: defaultsRaw,
            ),
      ),
    );
  }
  refs.sort((a, b) => a.drillId.compareTo(b.drillId));
  return refs;
}

Set<String> _loadLearnerFacingDrillIdsForSessionV1({
  required String rootPath,
  required _SessionProjectionRefV1 session,
}) {
  final indexRaw = _loadOptionalFileTextV1(
    '$rootPath/${session.sessionPath}/drills/index.md',
  );
  if (indexRaw != null) {
    return parseDrillIdsFromIndexV1(indexRaw).toSet();
  }

  final manifestRaw = _loadOptionalFileTextV1(
    '$rootPath/content/_meta/world_drills_manifest_v1.json',
  );
  if (manifestRaw == null) {
    return const <String>{};
  }
  return _parseDrillIdsForSessionFromManifestV1(
    manifestRaw,
    session.sessionId,
  ).toSet();
}

List<String> _parseDrillIdsForSessionFromManifestV1(
  String raw,
  String sessionId,
) {
  final dynamic decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'world_drills_manifest_v1: root must be object',
    );
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    throw const FormatException(
      'world_drills_manifest_v1: worlds must be list',
    );
  }

  final normalizedSessionId = sessionId.trim().toLowerCase();
  for (final world in worlds) {
    if (world is! Map) {
      continue;
    }
    final sessions = world['sessions'];
    if (sessions is! List) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map) {
        continue;
      }
      final id = session['id'];
      if (id is! String || id.trim().toLowerCase() != normalizedSessionId) {
        continue;
      }
      final drills = session['drills'];
      if (drills is! List) {
        return const <String>[];
      }
      final out = <String>[];
      for (final drill in drills) {
        if (drill is! Map) {
          continue;
        }
        final drillId = drill['id'];
        if (drillId is String && drillId.isNotEmpty) {
          out.add(drillId);
        }
      }
      return List<String>.unmodifiable(out);
    }
  }
  return const <String>[];
}

List<TableProjectionIssueV1> _auditSessionV1({
  required _SessionProjectionRefV1 session,
  required List<_DrillProjectionRefV1> drills,
}) {
  final issues = <TableProjectionIssueV1>[];
  for (final drill in drills) {
    final effectiveLayoutFamily = _effectiveLayoutFamilyForDrillV1(
      session: session,
      drill: drill,
    );
    if (_isWorld2MixedHandChainNativeProjectedAdjunctV1(
      sessionId: session.sessionId,
      drill: drill.spec,
    )) {
      if (effectiveLayoutFamily != 'embedded_table_projected') {
        issues.add(
          TableProjectionIssueV1(
            world: session.world,
            sessionId: session.sessionId,
            issueType: 'table_presence',
            reasonCode: 'table_required_but_host_not_projected',
            severity: TableProjectionIssueSeverityV1.error,
            hostSurface: session.hostSurface.name,
            layoutFamily: effectiveLayoutFamily,
            requiredLayoutFamily: 'embedded_table_projected',
            drillId: drill.drillId,
            drillKind: drill.spec.kind.name,
            drillPath: drill.drillPath,
          ),
        );
      }
      continue;
    }
    if (_isWorld2SingleStepNativeProjectedAdjunctV1(
      sessionId: session.sessionId,
      drill: drill.spec,
    )) {
      if (effectiveLayoutFamily != 'embedded_table_projected') {
        issues.add(
          TableProjectionIssueV1(
            world: session.world,
            sessionId: session.sessionId,
            issueType: 'table_presence',
            reasonCode: 'table_required_but_host_not_projected',
            severity: TableProjectionIssueSeverityV1.error,
            hostSurface: session.hostSurface.name,
            layoutFamily: effectiveLayoutFamily,
            requiredLayoutFamily: 'embedded_table_projected',
            drillId: drill.drillId,
            drillKind: drill.spec.kind.name,
            drillPath: drill.drillPath,
          ),
        );
      }
      continue;
    }
    final baseSpatialContract =
        SessionDrillSpatialProjectionContractV1.evaluate(
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          drill: drill.spec,
        );
    final world9SpatialContract =
        SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
          sessionId: session.sessionId,
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          drill: drill.spec,
        );
    final contractApplies = world9SpatialContract.applies
        ? world9SpatialContract.applies
        : baseSpatialContract.applies;
    final requiredLayoutFamily = world9SpatialContract.applies
        ? world9SpatialContract.requiredLayoutFamily
        : baseSpatialContract.requiredLayoutFamily;
    final hostGateSatisfied = world9SpatialContract.applies
        ? world9SpatialContract.hostGateSatisfied
        : baseSpatialContract.hostGateSatisfied;
    final hostGateReasonCode = world9SpatialContract.applies
        ? world9SpatialContract.hostGateReasonCode
        : baseSpatialContract.hostGateReasonCode;
    final hasRequiredScenePayload = world9SpatialContract.applies
        ? world9SpatialContract.hasRequiredScenePayload
        : baseSpatialContract.hasRequiredScenePayload;
    final payloadReasonCode = world9SpatialContract.applies
        ? world9SpatialContract.payloadReasonCode
        : baseSpatialContract.payloadReasonCode;
    final handChainContract =
        SessionDrillHandChainProjectionContractV1.evaluate(
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          drill: drill.spec,
        );
    if (!contractApplies &&
        !handChainContract.applies &&
        !_requiresProjectedTableNonSpatialV1(drill.spec)) {
      continue;
    }
    if (contractApplies && !hostGateSatisfied) {
      issues.add(
        TableProjectionIssueV1(
          world: session.world,
          sessionId: session.sessionId,
          issueType: 'table_presence',
          reasonCode: hostGateReasonCode!,
          severity: TableProjectionIssueSeverityV1.error,
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          requiredLayoutFamily: requiredLayoutFamily,
          drillId: drill.drillId,
          drillKind: drill.spec.kind.name,
          drillPath: drill.drillPath,
        ),
      );
    }
    if (contractApplies && !hasRequiredScenePayload) {
      issues.add(
        TableProjectionIssueV1(
          world: session.world,
          sessionId: session.sessionId,
          issueType: 'scene_projection',
          reasonCode: payloadReasonCode!,
          severity: TableProjectionIssueSeverityV1.error,
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          requiredLayoutFamily: requiredLayoutFamily,
          drillId: drill.drillId,
          drillKind: drill.spec.kind.name,
          drillPath: drill.drillPath,
        ),
      );
    }
    if (contractApplies) {
      continue;
    }
    if (handChainContract.applies) {
      if (!handChainContract.hostGateSatisfied) {
        issues.add(
          TableProjectionIssueV1(
            world: session.world,
            sessionId: session.sessionId,
            issueType: 'table_presence',
            reasonCode: handChainContract.hostGateReasonCode!,
            severity: TableProjectionIssueSeverityV1.error,
            hostSurface: session.hostSurface.name,
            layoutFamily: effectiveLayoutFamily,
            requiredLayoutFamily: handChainContract.requiredLayoutFamily,
            drillId: drill.drillId,
            drillKind: drill.spec.kind.name,
            drillPath: drill.drillPath,
          ),
        );
      }
      if (!handChainContract.hasRequiredScenePayload) {
        issues.add(
          TableProjectionIssueV1(
            world: session.world,
            sessionId: session.sessionId,
            issueType: 'scene_projection',
            reasonCode: handChainContract.payloadReasonCode!,
            severity: TableProjectionIssueSeverityV1.error,
            hostSurface: session.hostSurface.name,
            layoutFamily: effectiveLayoutFamily,
            requiredLayoutFamily: handChainContract.requiredLayoutFamily,
            drillId: drill.drillId,
            drillKind: drill.spec.kind.name,
            drillPath: drill.drillPath,
          ),
        );
      }
      continue;
    }
    if (effectiveLayoutFamily == 'text_action_stack') {
      issues.add(
        TableProjectionIssueV1(
          world: session.world,
          sessionId: session.sessionId,
          issueType: 'table_presence',
          reasonCode: 'table_required_but_host_not_projected',
          severity: TableProjectionIssueSeverityV1.error,
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          requiredLayoutFamily: 'embedded_table_projected',
          drillId: drill.drillId,
          drillKind: drill.spec.kind.name,
          drillPath: drill.drillPath,
        ),
      );
    }
    if (_lacksProjectionPayloadNonSpatialV1(
      session: session,
      drill: drill.spec,
    )) {
      issues.add(
        TableProjectionIssueV1(
          world: session.world,
          sessionId: session.sessionId,
          issueType: 'scene_projection',
          reasonCode: 'missing_required_scene_fields',
          severity: TableProjectionIssueSeverityV1.error,
          hostSurface: session.hostSurface.name,
          layoutFamily: effectiveLayoutFamily,
          requiredLayoutFamily: 'embedded_table_projected',
          drillId: drill.drillId,
          drillKind: drill.spec.kind.name,
          drillPath: drill.drillPath,
        ),
      );
    }
  }
  return issues;
}

bool _isWorld2SingleStepNativeProjectedAdjunctV1({
  required String sessionId,
  required DrillSpecV1 drill,
}) {
  if (!_kWorld2SingleStepScenarioSessionIdsAuditV1.contains(
    sessionId.trim().toLowerCase(),
  )) {
    return false;
  }
  return drill.kind == DrillKindV1.seatTap ||
      drill.kind == DrillKindV1.boardTap;
}

bool _isWorld2MixedHandChainNativeProjectedAdjunctV1({
  required String sessionId,
  required DrillSpecV1 drill,
}) {
  const supportedSessions = <String>{'w2.s07', 'w2.s08', 'w2.s09', 'w2.s10'};
  if (!supportedSessions.contains(sessionId.trim().toLowerCase())) {
    return false;
  }
  return drill.kind == DrillKindV1.seatTap ||
      drill.kind == DrillKindV1.boardTap;
}

_AuditHostSurfaceV1 _hostSurfaceForSessionIdV1(String sessionId) {
  final normalized = sessionId.trim().toLowerCase();
  if (_isWorld10TrackSessionIdV1(normalized)) {
    return _AuditHostSurfaceV1.sessionDrillPlayer;
  }
  if (normalized.startsWith('w0.') || normalized.startsWith('w1.')) {
    return _AuditHostSurfaceV1.world1FoundationsRunner;
  }
  return _AuditHostSurfaceV1.sessionDrillPlayer;
}

bool _isWorld10TrackSessionIdV1(String sessionId) {
  return sessionId.startsWith('cash.') ||
      sessionId.startsWith('tournament.') ||
      sessionId.startsWith('mixed.');
}

String _layoutFamilyForSessionIdV1(String sessionId) {
  final normalized = sessionId.trim().toLowerCase();
  if (normalized.startsWith('w0.') || normalized.startsWith('w1.')) {
    return 'table_canvas_runner';
  }
  if (_kWorld2SingleStepScenarioSessionIdsAuditV1.contains(normalized) ||
      _kEmbeddedHandChainScenarioSessionIdsAuditV1.contains(normalized) ||
      _kWorld5TextureScenarioSessionIdsAuditV1.contains(normalized)) {
    return 'embedded_table_projected';
  }
  return 'text_action_stack';
}

bool _requiresProjectedTableNonSpatialV1(DrillSpecV1 spec) {
  switch (spec.kind) {
    case DrillKindV1.seatTap:
    case DrillKindV1.boardTap:
    case DrillKindV1.holeCardsTap:
      return false;
    case DrillKindV1.showdownWinnerChoice:
    case DrillKindV1.positionThinkingChoice:
    case DrillKindV1.initiativeAggressorChoice:
    case DrillKindV1.outsCountChoice:
    case DrillKindV1.boardTextureClassifier:
      return true;
    case DrillKindV1.handChain:
      return false;
    case DrillKindV1.actionChoice:
    case DrillKindV1.betSizingChoice:
    case DrillKindV1.rangeBucketClassifier:
      return false;
  }
}

bool _lacksProjectionPayloadNonSpatialV1({
  required _SessionProjectionRefV1 session,
  required DrillSpecV1 drill,
}) {
  if (session.layoutFamily != 'text_action_stack') {
    return false;
  }
  switch (drill.kind) {
    case DrillKindV1.seatTap:
    case DrillKindV1.boardTap:
    case DrillKindV1.holeCardsTap:
      return false;
    case DrillKindV1.showdownWinnerChoice:
      return drill.scenarioShowdownContextV1 == null;
    case DrillKindV1.positionThinkingChoice:
      return drill.scenarioPositionContextV1 == null;
    case DrillKindV1.initiativeAggressorChoice:
      return drill.scenarioInitiativeContextV1 == null;
    case DrillKindV1.outsCountChoice:
      return drill.scenarioOutsContextV1 == null;
    case DrillKindV1.boardTextureClassifier:
      return drill.scenarioBoardTextureContextV1 == null;
    case DrillKindV1.handChain:
      return false;
    case DrillKindV1.actionChoice:
    case DrillKindV1.betSizingChoice:
    case DrillKindV1.rangeBucketClassifier:
      return false;
  }
}

String _effectiveLayoutFamilyForDrillV1({
  required _SessionProjectionRefV1 session,
  required _DrillProjectionRefV1 drill,
}) {
  if (drill.hasSessionProjectionDefaults) {
    return 'embedded_table_projected';
  }
  return session.layoutFamily;
}

String? _loadOptionalFileTextV1(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }
  return file.readAsStringSync();
}

TableProjectionAuditSummaryV1 _buildSummaryV1(
  List<TableProjectionIssueV1> issues,
) {
  var errorCount = 0;
  var warningCount = 0;
  final reasonCounts = <String, int>{};
  for (final issue in issues) {
    if (issue.severity == TableProjectionIssueSeverityV1.error) {
      errorCount++;
    } else {
      warningCount++;
    }
    reasonCounts.update(
      issue.reasonCode,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return TableProjectionAuditSummaryV1(
    totalIssues: issues.length,
    errorCount: errorCount,
    warningCount: warningCount,
    reasonCounts: Map<String, int>.unmodifiable(reasonCounts),
  );
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/table_projection_acceptance_audit_v1.dart '
    '[--json] [--world=<n>]',
  );
}
