import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum RuntimeAssetResolutionIssueSeverityV1 { error, warning }

class RuntimeAssetResolutionIssueV1 {
  const RuntimeAssetResolutionIssueV1({
    required this.world,
    required this.sessionId,
    required this.assetType,
    required this.assetId,
    required this.severity,
    required this.reasonCode,
    required this.sourcePath,
    this.runtimeRoot,
    this.runtimePath,
  });

  final int world;
  final String sessionId;
  final String assetType;
  final String assetId;
  final RuntimeAssetResolutionIssueSeverityV1 severity;
  final String reasonCode;
  final String sourcePath;
  final String? runtimeRoot;
  final String? runtimePath;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'session_id': sessionId,
    'asset_type': assetType,
    'asset_id': assetId,
    'severity': severity.name,
    'reason_code': reasonCode,
    'source_path': sourcePath,
    if (runtimeRoot != null) 'runtime_root': runtimeRoot!,
    if (runtimePath != null) 'runtime_path': runtimePath!,
  };
}

class RuntimeAssetResolutionSummaryV1 {
  const RuntimeAssetResolutionSummaryV1({
    required this.totalIssues,
    required this.errorCount,
    required this.runtimeRootsScanned,
    required this.reasonCounts,
  });

  final int totalIssues;
  final int errorCount;
  final List<String> runtimeRootsScanned;
  final Map<String, int> reasonCounts;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'error_count': errorCount,
    'runtime_roots_scanned': runtimeRootsScanned,
    'reason_counts': reasonCounts,
  };
}

class RuntimeAssetResolutionAuditReportV1 {
  const RuntimeAssetResolutionAuditReportV1({
    required this.issues,
    required this.summary,
  });

  final List<RuntimeAssetResolutionIssueV1> issues;
  final RuntimeAssetResolutionSummaryV1 summary;

  bool get hasBlockingIssues => summary.errorCount > 0;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summary': summary.toJson(),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

class RuntimeAssetResolutionAuditOptionsV1 {
  const RuntimeAssetResolutionAuditOptionsV1({this.world, this.runtimeRoot});

  final int? world;
  final String? runtimeRoot;
}

class _RuntimeAssetResolutionCliV1 {
  const _RuntimeAssetResolutionCliV1({
    required this.wantsJson,
    required this.options,
  });

  final bool wantsJson;
  final RuntimeAssetResolutionAuditOptionsV1 options;

  static _RuntimeAssetResolutionCliV1 parse(List<String> args) {
    var wantsJson = false;
    int? world;
    String? runtimeRoot;
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
      if (arg.startsWith('--runtime-root=')) {
        runtimeRoot = arg.substring('--runtime-root='.length).trim();
        if (runtimeRoot.isEmpty) {
          stderr.writeln('Invalid --runtime-root value: $arg');
          exit(64);
        }
        continue;
      }
      stderr.writeln('Unknown option: $arg');
      _printUsageV1();
      exit(64);
    }
    return _RuntimeAssetResolutionCliV1(
      wantsJson: wantsJson,
      options: RuntimeAssetResolutionAuditOptionsV1(
        world: world,
        runtimeRoot: runtimeRoot,
      ),
    );
  }
}

class _LearnerFacingSessionRefV1 {
  const _LearnerFacingSessionRefV1({
    required this.world,
    required this.sessionId,
    required this.sessionPath,
    required this.drillIds,
  });

  final int world;
  final String sessionId;
  final String sessionPath;
  final List<String> drillIds;
}

void main(List<String> args) {
  final cli = _RuntimeAssetResolutionCliV1.parse(args);
  final report = buildRuntimeAssetResolutionAuditReportV1(options: cli.options);
  stdout.writeln(
    cli.wantsJson
        ? encodeRuntimeAssetResolutionAuditReportJsonV1(report)
        : renderRuntimeAssetResolutionAuditReportV1(report),
  );
  exitCode = report.hasBlockingIssues ? 1 : 0;
}

RuntimeAssetResolutionAuditReportV1 buildRuntimeAssetResolutionAuditReportV1({
  String rootPath = '.',
  RuntimeAssetResolutionAuditOptionsV1 options =
      const RuntimeAssetResolutionAuditOptionsV1(),
}) {
  final runtimeRoots = _resolveRuntimeRootsV1(
    rootPath: rootPath,
    explicitRuntimeRoot: options.runtimeRoot,
  );
  final issues = <RuntimeAssetResolutionIssueV1>[];
  final refs =
      _loadLearnerFacingSessionRefsV1(
        rootPath: rootPath,
        worldFilter: options.world,
      )..sort((a, b) {
        final worldCompare = a.world.compareTo(b.world);
        if (worldCompare != 0) return worldCompare;
        return a.sessionId.compareTo(b.sessionId);
      });

  for (final ref in refs) {
    issues.addAll(
      _checkAssetV1(
        rootPath: rootPath,
        runtimeRoots: runtimeRoots,
        world: ref.world,
        sessionId: ref.sessionId,
        assetType: 'session_markdown',
        assetId: 'session.md',
        sourcePath: '${ref.sessionPath}/session.md',
      ),
    );
    issues.addAll(
      _checkAssetV1(
        rootPath: rootPath,
        runtimeRoots: runtimeRoots,
        world: ref.world,
        sessionId: ref.sessionId,
        assetType: 'drill_index',
        assetId: 'index.md',
        sourcePath: '${ref.sessionPath}/drills/index.md',
      ),
    );
    for (final drillId in ref.drillIds) {
      issues.addAll(
        _checkAssetV1(
          rootPath: rootPath,
          runtimeRoots: runtimeRoots,
          world: ref.world,
          sessionId: ref.sessionId,
          assetType: 'drill_json',
          assetId: drillId,
          sourcePath: '${ref.sessionPath}/drills/d.$drillId.json',
        ),
      );
    }
  }

  issues.sort(_compareIssuesV1);
  return RuntimeAssetResolutionAuditReportV1(
    issues: List<RuntimeAssetResolutionIssueV1>.unmodifiable(issues),
    summary: _buildSummaryV1(issues, runtimeRoots),
  );
}

String renderRuntimeAssetResolutionAuditReportV1(
  RuntimeAssetResolutionAuditReportV1 report,
) {
  final out = StringBuffer()
    ..writeln(
      'issues=${report.summary.totalIssues} '
      'errors=${report.summary.errorCount} '
      'runtime_roots=${report.summary.runtimeRootsScanned.length}',
    );
  if (report.summary.runtimeRootsScanned.isNotEmpty) {
    out.writeln('roots=${report.summary.runtimeRootsScanned.join(',')}');
  }
  out
    ..writeln()
    ..writeln(
      'WORLD | SESSION | ASSET_TYPE | ASSET_ID | SEVERITY | REASON | '
      'SOURCE_PATH | RUNTIME_ROOT | RUNTIME_PATH',
    );
  for (final issue in report.issues) {
    out.writeln(
      '${issue.world} | ${issue.sessionId} | ${issue.assetType} | '
      '${issue.assetId} | ${issue.severity.name} | ${issue.reasonCode} | '
      '${issue.sourcePath} | ${issue.runtimeRoot ?? '-'} | '
      '${issue.runtimePath ?? '-'}',
    );
  }
  return out.toString().trimRight();
}

String encodeRuntimeAssetResolutionAuditReportJsonV1(
  RuntimeAssetResolutionAuditReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

List<_LearnerFacingSessionRefV1> _loadLearnerFacingSessionRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  final refs = <_LearnerFacingSessionRefV1>[
    ..._loadManifestSessionRefsV1(rootPath: rootPath, worldFilter: worldFilter),
    ..._scanWorld10TrackRefsV1(rootPath: rootPath, worldFilter: worldFilter),
  ];
  final seen = <String>{};
  return refs
      .where((ref) => seen.add('${ref.world}|${ref.sessionId}'))
      .toList();
}

List<_LearnerFacingSessionRefV1> _loadManifestSessionRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  final file = File('$rootPath/content/_meta/world_drills_manifest_v1.json');
  if (!file.existsSync()) {
    return const <_LearnerFacingSessionRefV1>[];
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    return const <_LearnerFacingSessionRefV1>[];
  }
  final worlds = decoded['worlds'];
  if (worlds is! List<Object?>) {
    return const <_LearnerFacingSessionRefV1>[];
  }
  final refs = <_LearnerFacingSessionRefV1>[];
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
      final drills = sessionEntry['drills'];
      if (sessionId is! String ||
          sessionPath is! String ||
          drills is! List<Object?>) {
        continue;
      }
      final drillIds = <String>[];
      for (final drillEntry in drills) {
        if (drillEntry is! Map<String, Object?>) {
          continue;
        }
        final drillId = drillEntry['id'];
        if (drillId is String && drillId.isNotEmpty) {
          drillIds.add(drillId);
        }
      }
      refs.add(
        _LearnerFacingSessionRefV1(
          world: world,
          sessionId: sessionId,
          sessionPath: sessionPath.replaceFirst(RegExp(r'/$'), ''),
          drillIds: List<String>.unmodifiable(drillIds),
        ),
      );
    }
  }
  return refs;
}

List<_LearnerFacingSessionRefV1> _scanWorld10TrackRefsV1({
  required String rootPath,
  required int? worldFilter,
}) {
  if (worldFilter != null && worldFilter != 10) {
    return const <_LearnerFacingSessionRefV1>[];
  }
  final tracksDir = Directory('$rootPath/content/worlds/world10/v1/tracks');
  if (!tracksDir.existsSync()) {
    return const <_LearnerFacingSessionRefV1>[];
  }
  final refs = <_LearnerFacingSessionRefV1>[];
  for (final trackDir in tracksDir.listSync().whereType<Directory>()) {
    final sessionsDir = Directory('${trackDir.path}/sessions');
    if (!sessionsDir.existsSync()) {
      continue;
    }
    for (final sessionDir in sessionsDir.listSync().whereType<Directory>()) {
      final sessionId = sessionDir.uri.pathSegments.reversed.skip(1).first;
      final indexFile = File('${sessionDir.path}/drills/index.md');
      if (!indexFile.existsSync()) {
        refs.add(
          _LearnerFacingSessionRefV1(
            world: 10,
            sessionId: sessionId,
            sessionPath: sessionDir.path
                .replaceFirst('$rootPath/', '')
                .replaceFirst(RegExp(r'/$'), ''),
            drillIds: const <String>[],
          ),
        );
        continue;
      }
      final drillIds = parseDrillIdsFromIndexV1(indexFile.readAsStringSync());
      refs.add(
        _LearnerFacingSessionRefV1(
          world: 10,
          sessionId: sessionId,
          sessionPath: sessionDir.path
              .replaceFirst('$rootPath/', '')
              .replaceFirst(RegExp(r'/$'), ''),
          drillIds: List<String>.unmodifiable(drillIds),
        ),
      );
    }
  }
  return refs;
}

List<RuntimeAssetResolutionIssueV1> _checkAssetV1({
  required String rootPath,
  required List<String> runtimeRoots,
  required int world,
  required String sessionId,
  required String assetType,
  required String assetId,
  required String sourcePath,
}) {
  final issues = <RuntimeAssetResolutionIssueV1>[];
  final sourceFile = File('$rootPath/$sourcePath');
  if (!sourceFile.existsSync()) {
    issues.add(
      RuntimeAssetResolutionIssueV1(
        world: world,
        sessionId: sessionId,
        assetType: assetType,
        assetId: assetId,
        severity: RuntimeAssetResolutionIssueSeverityV1.error,
        reasonCode: 'missing_source_asset',
        sourcePath: sourcePath,
      ),
    );
    return issues;
  }
  final sourceText = sourceFile.readAsStringSync();
  if (sourceText.trim().isEmpty) {
    issues.add(
      RuntimeAssetResolutionIssueV1(
        world: world,
        sessionId: sessionId,
        assetType: assetType,
        assetId: assetId,
        severity: RuntimeAssetResolutionIssueSeverityV1.error,
        reasonCode: 'empty_source_asset',
        sourcePath: sourcePath,
      ),
    );
  }

  for (final runtimeRoot in runtimeRoots) {
    final runtimePath = '$runtimeRoot/$sourcePath';
    final runtimeFile = File(runtimePath);
    if (!runtimeFile.existsSync()) {
      issues.add(
        RuntimeAssetResolutionIssueV1(
          world: world,
          sessionId: sessionId,
          assetType: assetType,
          assetId: assetId,
          severity: RuntimeAssetResolutionIssueSeverityV1.error,
          reasonCode: 'runtime_bundle_omission',
          sourcePath: sourcePath,
          runtimeRoot: runtimeRoot,
          runtimePath: runtimePath,
        ),
      );
      continue;
    }
    if (runtimeFile.readAsStringSync().trim().isEmpty) {
      issues.add(
        RuntimeAssetResolutionIssueV1(
          world: world,
          sessionId: sessionId,
          assetType: assetType,
          assetId: assetId,
          severity: RuntimeAssetResolutionIssueSeverityV1.error,
          reasonCode: 'runtime_bundle_empty_asset',
          sourcePath: sourcePath,
          runtimeRoot: runtimeRoot,
          runtimePath: runtimePath,
        ),
      );
    }
  }

  return issues;
}

List<String> _resolveRuntimeRootsV1({
  required String rootPath,
  required String? explicitRuntimeRoot,
}) {
  if (explicitRuntimeRoot != null) {
    final directory = Directory(explicitRuntimeRoot);
    if (!directory.existsSync()) {
      return const <String>[];
    }
    return <String>[directory.path];
  }

  final buildFlutterAssets = Directory('$rootPath/build/flutter_assets');
  if (buildFlutterAssets.existsSync()) {
    return <String>[buildFlutterAssets.path];
  }

  final buildDir = Directory('$rootPath/build');
  if (!buildDir.existsSync()) {
    return const <String>[];
  }

  final roots = <String>{};
  for (final entity in buildDir.listSync(recursive: true).whereType<File>()) {
    if (!entity.path.endsWith(
      'flutter_assets/content/_meta/world_drills_manifest_v1.json',
    )) {
      continue;
    }
    roots.add(entity.parent.parent.parent.path);
  }
  final orderedRoots = roots.toList()..sort();
  return orderedRoots;
}

RuntimeAssetResolutionSummaryV1 _buildSummaryV1(
  List<RuntimeAssetResolutionIssueV1> issues,
  List<String> runtimeRoots,
) {
  var errorCount = 0;
  final reasonCounts = <String, int>{};
  for (final issue in issues) {
    if (issue.severity == RuntimeAssetResolutionIssueSeverityV1.error) {
      errorCount++;
    }
    reasonCounts.update(
      issue.reasonCode,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return RuntimeAssetResolutionSummaryV1(
    totalIssues: issues.length,
    errorCount: errorCount,
    runtimeRootsScanned: List<String>.unmodifiable(runtimeRoots),
    reasonCounts: Map<String, int>.unmodifiable(reasonCounts),
  );
}

int _compareIssuesV1(
  RuntimeAssetResolutionIssueV1 a,
  RuntimeAssetResolutionIssueV1 b,
) {
  final worldCompare = a.world.compareTo(b.world);
  if (worldCompare != 0) return worldCompare;
  final sessionCompare = a.sessionId.compareTo(b.sessionId);
  if (sessionCompare != 0) return sessionCompare;
  final assetTypeCompare = a.assetType.compareTo(b.assetType);
  if (assetTypeCompare != 0) return assetTypeCompare;
  final assetIdCompare = a.assetId.compareTo(b.assetId);
  if (assetIdCompare != 0) return assetIdCompare;
  return a.reasonCode.compareTo(b.reasonCode);
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/runtime_asset_resolution_audit_v1.dart '
    '[--json] [--world=<n>] [--runtime-root=<path>]',
  );
}
