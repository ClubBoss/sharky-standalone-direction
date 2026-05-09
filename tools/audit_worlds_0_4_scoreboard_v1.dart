import 'dart:io';

final RegExp _kSessionDirPattern = RegExp(r'^w(\d+)\.s\d{2}$');
final RegExp _kDrillFilePattern = RegExp(r'^d\..+\.json$');

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('audit_worlds_0_4_scoreboard_v1: no arguments supported');
    exitCode = 64;
    return;
  }

  const worldIds = <int>[0, 1, 2, 3, 4];
  final report = StringBuffer();
  report.writeln('# Worlds 0-4 Coverage Scoreboard v1');
  report.writeln();
  report.writeln('- Root: `content/worlds/world{0..4}/v1`');
  report.writeln('- Rule: session dirs `wN.sXX`, drills `d.*.json`');

  for (final worldId in worldIds) {
    final worldRoot = Directory('content/worlds/world$worldId/v1');
    report.writeln();
    report.writeln('## World $worldId');

    if (!worldRoot.existsSync()) {
      report.writeln('- status: MISSING_WORLD_ROOT');
      report.writeln('- sessions: 0');
      report.writeln('- total_drills: 0');
      report.writeln('- avg_drills_per_session: 0.00');
      report.writeln();
      report.writeln('| session_id | drill_count | status |');
      report.writeln('| --- | ---: | --- |');
      continue;
    }

    final sessionsRoot = Directory('${worldRoot.path}/sessions');
    final sessions = _collectSessions(worldId, sessionsRoot);
    final totalDrills = sessions.fold<int>(
      0,
      (sum, session) => sum + session.drillCount,
    );
    final average = sessions.isEmpty ? 0.0 : totalDrills / sessions.length;
    final coverage = _buildRoleCoverage(sessions);
    final missingRoles = _missingRoles(coverage);
    final unknownRoleCount = sessions
        .where((s) => s.role == _roleUnknown)
        .length;

    report.writeln('- sessions: ${sessions.length}');
    report.writeln('- total_drills: $totalDrills');
    report.writeln('- avg_drills_per_session: ${average.toStringAsFixed(2)}');
    report.writeln(
      '- role_coverage: Learn=${coverage.learn ? 'Y' : 'N'} Practice=${coverage.practice ? 'Y' : 'N'} Checkpoint=${coverage.checkpoint ? 'Y' : 'N'}',
    );
    if (missingRoles.isEmpty) {
      report.writeln('- role_gaps: NONE');
    } else {
      report.writeln('- role_gaps: ${missingRoles.join(', ')}');
    }
    if (unknownRoleCount > 0) {
      report.writeln('- unknown_roles: $unknownRoleCount');
    }
    report.writeln();
    report.writeln('| session_id | role | drill_count | status |');
    report.writeln('| --- | --- | ---: | --- |');

    if (sessions.isEmpty) {
      report.writeln('| NONE | UNKNOWN | 0 | NO_SESSIONS |');
      continue;
    }

    for (final session in sessions) {
      final statusParts = <String>[];
      if (session.drillCount == 0) {
        statusParts.add('ZERO_DRILLS');
      } else {
        statusParts.add('OK');
      }
      if (session.role == _roleUnknown) {
        statusParts.add('UNKNOWN_ROLE');
      }
      final status = statusParts.join(',');
      report.writeln(
        '| ${session.sessionId} | ${session.role} | ${session.drillCount} | $status |',
      );
    }
  }

  stdout.write(report.toString());
}

List<_SessionCoverage> _collectSessions(int worldId, Directory sessionsRoot) {
  if (!sessionsRoot.existsSync()) {
    return const <_SessionCoverage>[];
  }

  final sessions = <_SessionCoverage>[];
  final entries =
      sessionsRoot.listSync(followLinks: false).whereType<Directory>().toList()
        ..sort((a, b) => _baseName(a.path).compareTo(_baseName(b.path)));

  for (final sessionDir in entries) {
    final sessionId = _baseName(sessionDir.path);
    final match = _kSessionDirPattern.firstMatch(sessionId);
    if (match == null) {
      continue;
    }

    final parsedWorld = int.tryParse(match.group(1)!);
    if (parsedWorld != worldId) {
      continue;
    }

    final drillsDir = Directory('${sessionDir.path}/drills');
    var drillCount = 0;
    if (drillsDir.existsSync()) {
      final drillFiles =
          drillsDir
              .listSync(followLinks: false)
              .whereType<File>()
              .where(
                (file) => _kDrillFilePattern.hasMatch(_baseName(file.path)),
              )
              .map((file) => _baseName(file.path))
              .toList()
            ..sort();
      drillCount = drillFiles.length;
    }

    sessions.add(
      _SessionCoverage(
        sessionId: sessionId,
        role: _inferRoleFromSessionId(sessionId),
        drillCount: drillCount,
      ),
    );
  }

  return sessions;
}

const String _roleLearn = 'Learn';
const String _rolePractice = 'Practice';
const String _roleCheckpoint = 'Checkpoint';
const String _roleUnknown = 'UNKNOWN';

String _inferRoleFromSessionId(String sessionId) {
  final match = RegExp(r'^w\d+\.s(\d{2})$').firstMatch(sessionId);
  if (match == null) {
    return _roleUnknown;
  }

  final sequence = int.tryParse(match.group(1)!);
  if (sequence == null) {
    return _roleUnknown;
  }
  if (sequence >= 1 && sequence <= 3) {
    return _roleLearn;
  }
  if (sequence >= 4 && sequence <= 9) {
    return _rolePractice;
  }
  if (sequence == 10) {
    return _roleCheckpoint;
  }
  return _roleUnknown;
}

_RoleCoverage _buildRoleCoverage(List<_SessionCoverage> sessions) {
  var learn = false;
  var practice = false;
  var checkpoint = false;
  for (final session in sessions) {
    if (session.role == _roleLearn) {
      learn = true;
    } else if (session.role == _rolePractice) {
      practice = true;
    } else if (session.role == _roleCheckpoint) {
      checkpoint = true;
    }
  }
  return _RoleCoverage(
    learn: learn,
    practice: practice,
    checkpoint: checkpoint,
  );
}

List<String> _missingRoles(_RoleCoverage coverage) {
  final missing = <String>[];
  if (!coverage.learn) {
    missing.add('MISSING_ROLE:Learn');
  }
  if (!coverage.practice) {
    missing.add('MISSING_ROLE:Practice');
  }
  if (!coverage.checkpoint) {
    missing.add('MISSING_ROLE:Checkpoint');
  }
  return missing;
}

String _baseName(String path) {
  final normalized = path.replaceAll('\\\\', '/');
  final index = normalized.lastIndexOf('/');
  return index == -1 ? normalized : normalized.substring(index + 1);
}

class _SessionCoverage {
  const _SessionCoverage({
    required this.sessionId,
    required this.role,
    required this.drillCount,
  });

  final String sessionId;
  final String role;
  final int drillCount;
}

class _RoleCoverage {
  const _RoleCoverage({
    required this.learn,
    required this.practice,
    required this.checkpoint,
  });

  final bool learn;
  final bool practice;
  final bool checkpoint;
}
