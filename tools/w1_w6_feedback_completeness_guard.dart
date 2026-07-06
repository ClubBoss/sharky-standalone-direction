import 'dart:convert';
import 'dart:io';

const _decisionWorldMin = 1;
const _decisionWorldMax = 6;

void main(List<String> arguments) {
  final rootPath = _readOption(arguments, '--root') ?? Directory.current.path;
  final emitJson = arguments.contains('--json');
  final report = _scan(rootPath);

  if (emitJson) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report.toJson()));
  } else {
    stdout.writeln(
      'active decision rows scanned: ${report.activeDecisionRowsScanned}',
    );
    stdout.writeln(
      'missing correct/incorrect rows: '
      '${report.missingCorrectIncorrectCount}',
    );
    stdout.writeln(
      'missing acceptable feedback rows: '
      '${report.missingAcceptableFeedbackCount}',
    );
    stdout.writeln('missing why_v1 rows: ${report.missingWhyCount}');
    if (report.violations.isNotEmpty) {
      stderr.writeln('W1-W6 feedback completeness violations:');
      for (final violation in report.violations) {
        stderr.writeln(
          '- w${violation.world} ${violation.session} ${violation.id} '
          '${violation.field} ${violation.file}',
        );
      }
    }
  }

  if (report.violations.isNotEmpty) {
    exit(1);
  }
}

_FeedbackScanReport _scan(String rootPath) {
  final manifestFile = File(
    '$rootPath/content/_meta/world_drills_manifest_v1.json',
  );
  if (!manifestFile.existsSync()) {
    stderr.writeln('Missing world drills manifest: ${manifestFile.path}');
    exit(1);
  }
  final decoded =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final worlds = decoded['worlds'];
  if (worlds is! List<dynamic>) {
    stderr.writeln('world_drills_manifest_v1.json must contain worlds list.');
    exit(1);
  }

  final violations = <_FeedbackViolation>[];
  var activeRows = 0;
  final missingCorrectIncorrectIds = <String>{};
  final missingAcceptableIds = <String>{};
  final missingWhyIds = <String>{};

  for (final rawWorld in worlds) {
    final world = rawWorld as Map<String, dynamic>;
    final worldId = world['world'] as int;
    if (worldId < _decisionWorldMin || worldId > _decisionWorldMax) {
      continue;
    }
    final sessions = world['sessions'];
    if (sessions is! List<dynamic>) continue;
    for (final rawSession in sessions) {
      final session = rawSession as Map<String, dynamic>;
      final sessionId = session['id'] as String;
      final drills = session['drills'];
      if (drills is! List<dynamic>) continue;
      for (final rawDrill in drills) {
        final drill = rawDrill as Map<String, dynamic>;
        final drillId = drill['id'] as String;
        final path = drill['path'] as String;
        final file = File('$rootPath/$path');
        if (!file.existsSync()) {
          violations.add(
            _FeedbackViolation(
              world: worldId,
              session: sessionId,
              id: drillId,
              file: path,
              field: 'file',
              message: 'source file missing',
            ),
          );
          continue;
        }
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final kind = json['kind'] as String? ?? '';
        if (kind == 'hand_chain_v1') {
          final steps = json['steps'];
          if (steps is! List<dynamic>) continue;
          for (var index = 0; index < steps.length; index++) {
            final step = steps[index] as Map<String, dynamic>;
            if (!_isDecisionRow(step)) continue;
            activeRows++;
            final id = '$drillId#step${index + 1}';
            _checkRow(
              row: step,
              world: worldId,
              session: sessionId,
              id: id,
              file: path,
              violations: violations,
              missingCorrectIncorrectIds: missingCorrectIncorrectIds,
              missingAcceptableIds: missingAcceptableIds,
              missingWhyIds: missingWhyIds,
            );
          }
        } else {
          activeRows++;
          _checkRow(
            row: json,
            world: worldId,
            session: sessionId,
            id: drillId,
            file: path,
            violations: violations,
            missingCorrectIncorrectIds: missingCorrectIncorrectIds,
            missingAcceptableIds: missingAcceptableIds,
            missingWhyIds: missingWhyIds,
          );
        }
      }
    }
  }

  violations.sort((left, right) {
    final worldCompare = left.world.compareTo(right.world);
    if (worldCompare != 0) return worldCompare;
    final sessionCompare = left.session.compareTo(right.session);
    if (sessionCompare != 0) return sessionCompare;
    final idCompare = left.id.compareTo(right.id);
    if (idCompare != 0) return idCompare;
    return left.field.compareTo(right.field);
  });

  return _FeedbackScanReport(
    activeDecisionRowsScanned: activeRows,
    missingCorrectIncorrectCount: missingCorrectIncorrectIds.length,
    missingAcceptableFeedbackCount: missingAcceptableIds.length,
    missingWhyCount: missingWhyIds.length,
    violations: violations,
  );
}

void _checkRow({
  required Map<String, dynamic> row,
  required int world,
  required String session,
  required String id,
  required String file,
  required List<_FeedbackViolation> violations,
  required Set<String> missingCorrectIncorrectIds,
  required Set<String> missingAcceptableIds,
  required Set<String> missingWhyIds,
}) {
  void add(String field, String message) {
    violations.add(
      _FeedbackViolation(
        world: world,
        session: session,
        id: id,
        file: file,
        field: field,
        message: message,
      ),
    );
  }

  final rowKey = '$world/$session/$id';
  final correct = _stringField(row, 'feedback_correct_v1');
  final incorrect = _stringField(row, 'feedback_incorrect_v1');
  if (correct == null) {
    missingCorrectIncorrectIds.add(rowKey);
    add('feedback_correct_v1', 'missing source-owned correct feedback');
  }
  if (incorrect == null) {
    missingCorrectIncorrectIds.add(rowKey);
    add('feedback_incorrect_v1', 'missing source-owned incorrect feedback');
  }
  if (_hasAcceptableOutcome(row) &&
      _stringField(row, 'feedback_acceptable_v1') == null) {
    missingAcceptableIds.add(rowKey);
    add(
      'feedback_acceptable_v1',
      'acceptable outcome lacks source-owned acceptable feedback',
    );
  }
  if (_stringField(row, 'why_v1') == null) {
    missingWhyIds.add(rowKey);
    add('why_v1', 'missing source-owned why_v1');
  }
}

bool _isDecisionRow(Map<String, dynamic> row) {
  return row.containsKey('expected_action') ||
      row.containsKey('expected_preset_id') ||
      row.containsKey('range_bucket_v1') ||
      row.containsKey('expected');
}

bool _hasAcceptableOutcome(Map<String, dynamic> row) {
  final actions = row['acceptable_actions'];
  if (actions is List && actions.isNotEmpty) return true;
  final presets = row['acceptable_preset_ids'];
  if (presets is List && presets.isNotEmpty) return true;
  return false;
}

String? _stringField(Map<String, dynamic> row, String field) {
  final value = row[field];
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _readOption(List<String> arguments, String name) {
  final index = arguments.indexOf(name);
  if (index == -1) return null;
  if (index + 1 >= arguments.length) {
    stderr.writeln('Missing value for $name');
    exit(1);
  }
  return arguments[index + 1];
}

class _FeedbackScanReport {
  const _FeedbackScanReport({
    required this.activeDecisionRowsScanned,
    required this.missingCorrectIncorrectCount,
    required this.missingAcceptableFeedbackCount,
    required this.missingWhyCount,
    required this.violations,
  });

  final int activeDecisionRowsScanned;
  final int missingCorrectIncorrectCount;
  final int missingAcceptableFeedbackCount;
  final int missingWhyCount;
  final List<_FeedbackViolation> violations;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'active_decision_rows_scanned': activeDecisionRowsScanned,
      'missing_correct_incorrect_count': missingCorrectIncorrectCount,
      'missing_acceptable_feedback_count': missingAcceptableFeedbackCount,
      'missing_why_count': missingWhyCount,
      'violations': violations
          .map((violation) => violation.toJson())
          .toList(growable: false),
    };
  }
}

class _FeedbackViolation {
  const _FeedbackViolation({
    required this.world,
    required this.session,
    required this.id,
    required this.file,
    required this.field,
    required this.message,
  });

  final int world;
  final String session;
  final String id;
  final String file;
  final String field;
  final String message;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'world': world,
      'session': session,
      'id': id,
      'file': file,
      'field': field,
      'message': message,
    };
  }
}
