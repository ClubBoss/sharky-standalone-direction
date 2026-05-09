import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/canonical/recap_reinforcement_system_v1.dart';

class RecapReinforcementAuditRowV1 {
  const RecapReinforcementAuditRowV1({
    required this.patternId,
    required this.patternLabel,
    required this.rolloutOrder,
    required this.placementKind,
    required this.world,
    required this.sessionId,
    required this.anchorPath,
    required this.exists,
    this.trackKind,
  });

  final String patternId;
  final String patternLabel;
  final int rolloutOrder;
  final String placementKind;
  final int world;
  final String sessionId;
  final String anchorPath;
  final bool exists;
  final String? trackKind;

  Map<String, Object?> toJson() => <String, Object?>{
    'pattern_id': patternId,
    'pattern_label': patternLabel,
    'rollout_order': rolloutOrder,
    'placement_kind': placementKind,
    'world': world,
    'session_id': sessionId,
    if (trackKind != null) 'track_kind': trackKind,
    'anchor_path': anchorPath,
    'exists': exists,
  };
}

class RecapReinforcementAuditReportV1 {
  const RecapReinforcementAuditReportV1({
    required this.rows,
    required this.totalRows,
    required this.existingRows,
    required this.missingRows,
    required this.patternCounts,
  });

  final List<RecapReinforcementAuditRowV1> rows;
  final int totalRows;
  final int existingRows;
  final int missingRows;
  final Map<String, int> patternCounts;
}

RecapReinforcementAuditReportV1 buildRecapReinforcementAuditReportV1() {
  final rows = <RecapReinforcementAuditRowV1>[];
  final patternCounts = <String, int>{};
  for (final profile in kRecapReinforcementPatternProfilesV1) {
    patternCounts[profile.id] = profile.anchors.length;
    for (final anchor in profile.anchors) {
      rows.add(
        RecapReinforcementAuditRowV1(
          patternId: profile.id,
          patternLabel: profile.label,
          rolloutOrder: profile.rolloutOrder,
          placementKind: recapReinforcementPlacementKindIdV1(
            profile.placementKind,
          ),
          world: anchor.world,
          sessionId: anchor.sessionId,
          trackKind: anchor.trackKind,
          anchorPath: anchor.anchorPath,
          exists: File(anchor.anchorPath).existsSync(),
        ),
      );
    }
  }
  rows.sort((a, b) {
    final orderCompare = a.rolloutOrder.compareTo(b.rolloutOrder);
    if (orderCompare != 0) return orderCompare;
    final worldCompare = a.world.compareTo(b.world);
    if (worldCompare != 0) return worldCompare;
    return a.sessionId.compareTo(b.sessionId);
  });
  final existingRows = rows.where((row) => row.exists).length;
  return RecapReinforcementAuditReportV1(
    rows: List<RecapReinforcementAuditRowV1>.unmodifiable(rows),
    totalRows: rows.length,
    existingRows: existingRows,
    missingRows: rows.length - existingRows,
    patternCounts: Map<String, int>.unmodifiable(patternCounts),
  );
}

String encodeRecapReinforcementAuditReportJsonV1(
  RecapReinforcementAuditReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
    'version': 'v1',
    'summary': <String, Object?>{
      'total_rows': report.totalRows,
      'existing_rows': report.existingRows,
      'missing_rows': report.missingRows,
      'pattern_counts': report.patternCounts,
    },
    'rows': report.rows.map((row) => row.toJson()).toList(growable: false),
  });
}

String renderRecapReinforcementAuditReportV1(
  RecapReinforcementAuditReportV1 report,
) {
  final buffer = StringBuffer()
    ..writeln('Recap Reinforcement Audit v1')
    ..writeln(
      'rows=${report.totalRows} existing=${report.existingRows} missing=${report.missingRows}',
    )
    ..writeln('')
    ..writeln('Pattern counts:');
  final sortedPatternIds = report.patternCounts.keys.toList(growable: false)
    ..sort();
  for (final patternId in sortedPatternIds) {
    buffer.writeln('  $patternId: ${report.patternCounts[patternId]}');
  }
  buffer
    ..writeln('')
    ..writeln(
      'ORDER | PATTERN | PLACEMENT | WORLD | SESSION | TRACK | EXISTS | ANCHOR',
    );
  for (final row in report.rows) {
    buffer.writeln(
      '${row.rolloutOrder} | ${row.patternId} | ${row.placementKind} | '
      '${row.world} | ${row.sessionId} | ${row.trackKind ?? '-'} | '
      '${row.exists ? 'yes' : 'no'} | ${row.anchorPath}',
    );
  }
  return buffer.toString().trimRight();
}

void main(List<String> args) {
  final report = buildRecapReinforcementAuditReportV1();
  if (args.contains('--json')) {
    stdout.writeln(encodeRecapReinforcementAuditReportJsonV1(report));
    return;
  }
  stdout.writeln(renderRecapReinforcementAuditReportV1(report));
}
