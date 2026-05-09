import 'dart:io';

const List<int> _kWorldIds = <int>[0, 1, 2, 3, 4];
final RegExp _kSessionIndexLine = RegExp(r'^- (w(\d+)\.s(\d{2})):');

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('audit_worlds_0_4_session_chain_v1: no arguments supported');
    exitCode = 64;
    return;
  }

  final reports = <_WorldChainReport>[];
  for (final worldId in _kWorldIds) {
    reports.add(_auditWorld(worldId));
  }

  final hasFailures = reports.any((report) => !report.ok);
  final out = StringBuffer();
  out.writeln('# Worlds 0-4 Session Chain Audit v1');
  out.writeln();
  out.writeln('- Source: `content/worlds/worldN/v1/sessions/index.md`');
  out.writeln('- Expected chain: world-specific canonical session spine');
  out.writeln('- Role convention: world-specific canonical session roles');

  for (final report in reports) {
    out.writeln();
    out.writeln('## World ${report.worldId}');
    out.writeln('- status: ${report.ok ? 'OK' : 'BROKEN'}');
    out.writeln('- parsed_sessions: ${report.orderedSessionIds.length}');

    if (report.missingSessions.isEmpty) {
      out.writeln('- missing_sessions: NONE');
    } else {
      out.writeln('- missing_sessions: ${report.missingSessions.join(', ')}');
    }

    if (report.unexpectedSessions.isEmpty) {
      out.writeln('- unexpected_sessions: NONE');
    } else {
      out.writeln(
        '- unexpected_sessions: ${report.unexpectedSessions.join(', ')}',
      );
    }

    if (report.chainViolations.isEmpty) {
      out.writeln('- chain_violations: NONE');
    } else {
      out.writeln('- chain_violations: ${report.chainViolations.join(' | ')}');
    }

    if (report.roleOrderingViolations.isEmpty) {
      out.writeln('- role_order_violations: NONE');
    } else {
      out.writeln(
        '- role_order_violations: ${report.roleOrderingViolations.join(' | ')}',
      );
    }

    out.writeln();
    out.writeln('| session | role | next_expected | next_actual | status |');
    out.writeln('| --- | --- | --- | --- | --- |');

    if (report.orderedSessionIds.isEmpty) {
      out.writeln('| NONE | NONE | NONE | NONE | NO_SESSIONS |');
      continue;
    }

    for (var i = 0; i < report.orderedSessionIds.length; i++) {
      final sessionId = report.orderedSessionIds[i];
      final role = _roleLabelForSession(report.worldId, sessionId);
      final expectedNext = _nextExpected(report.worldId, sessionId);
      final actualNext = i + 1 < report.orderedSessionIds.length
          ? report.orderedSessionIds[i + 1]
          : 'END';
      final status = expectedNext == actualNext ? 'OK' : 'CHAIN_BREAK';
      out.writeln(
        '| $sessionId | $role | $expectedNext | $actualNext | $status |',
      );
    }
  }

  out.writeln();
  out.writeln(hasFailures ? 'SESSION_CHAIN_BROKEN' : 'SESSION_CHAIN_OK');
  stdout.write(out.toString());
  exitCode = hasFailures ? 2 : 0;
}

_WorldChainReport _auditWorld(int worldId) {
  final indexFile = File('content/worlds/world$worldId/v1/sessions/index.md');
  final parsedSessions = <String>[];
  final seen = <String>{};

  if (indexFile.existsSync()) {
    for (final raw in indexFile.readAsLinesSync()) {
      final line = raw.trim();
      final match = _kSessionIndexLine.firstMatch(line);
      if (match == null) {
        continue;
      }
      final sessionId = match.group(1)!;
      final parsedWorld = int.tryParse(match.group(2)!);
      if (parsedWorld != worldId) {
        continue;
      }
      if (seen.add(sessionId)) {
        parsedSessions.add(sessionId);
      }
    }
  }

  final expected = _expectedSessionChainForWorld(worldId);
  final expectedSet = expected.toSet();
  final parsedSet = parsedSessions.toSet();

  final missing = expected.where((id) => !parsedSet.contains(id)).toList();
  final unexpected = parsedSessions
      .where((id) => !expectedSet.contains(id))
      .toList();

  final chainViolations = <String>[];
  for (var i = 0; i < parsedSessions.length; i++) {
    final current = parsedSessions[i];
    final expectedNext = _nextExpected(worldId, current);
    final actualNext = i + 1 < parsedSessions.length
        ? parsedSessions[i + 1]
        : 'END';
    if (expectedNext != actualNext) {
      chainViolations.add(
        '$current expected_next=$expectedNext actual_next=$actualNext',
      );
    }
  }

  final roleOrderingViolations = <String>[];
  for (var i = 0; i < parsedSessions.length; i++) {
    final sessionId = parsedSessions[i];
    if (i >= expected.length) {
      continue;
    }
    final expectedRole = _roleLabelForSession(worldId, expected[i]);
    final actualRole = _roleLabelForSession(worldId, sessionId);
    if (expectedRole != actualRole) {
      roleOrderingViolations.add(
        '$sessionId role=$actualRole expected_role=$expectedRole at_position=${i + 1}',
      );
    }
  }

  final ok =
      missing.isEmpty &&
      unexpected.isEmpty &&
      chainViolations.isEmpty &&
      roleOrderingViolations.isEmpty;

  return _WorldChainReport(
    worldId: worldId,
    orderedSessionIds: parsedSessions,
    missingSessions: missing,
    unexpectedSessions: unexpected,
    chainViolations: chainViolations,
    roleOrderingViolations: roleOrderingViolations,
    ok: ok,
  );
}

List<String> _expectedSessionChainForWorld(int worldId) {
  if (worldId == 2 || worldId == 3) {
    return List<String>.generate(
      14,
      (i) => 'w$worldId.s${(i + 1).toString().padLeft(2, '0')}',
    );
  }
  return List<String>.generate(
    10,
    (i) => 'w$worldId.s${(i + 1).toString().padLeft(2, '0')}',
  );
}

String _nextExpected(int worldId, String sessionId) {
  final match = RegExp(r'^w(\d+)\.s(\d{2})$').firstMatch(sessionId);
  if (match == null) {
    return 'INVALID';
  }
  final world = match.group(1)!;
  final step = int.tryParse(match.group(2)!);
  if (step == null) {
    return 'INVALID';
  }
  final lastSequence = worldId == 2 || worldId == 3 ? 14 : 10;
  if (step >= lastSequence) {
    return 'END';
  }
  final next = (step + 1).toString().padLeft(2, '0');
  return 'w$world.s$next';
}

int _roleRankForSession(int worldId, String sessionId) {
  final match = RegExp(r'^w\d+\.s(\d{2})$').firstMatch(sessionId);
  if (match == null) {
    return 99;
  }
  final step = int.tryParse(match.group(1)!);
  if (step == null) {
    return 99;
  }
  if (step >= 1 && step <= 3) {
    return 0;
  }
  if (step >= 4 && step <= 9) {
    return 1;
  }
  if (step == 10) {
    return 2;
  }
  if (worldId == 2 || worldId == 3) {
    if (step >= 11 && step <= 13) {
      return 1;
    }
    if (step == 14) {
      return 2;
    }
  }
  return 99;
}

String _roleLabelForSession(int worldId, String sessionId) {
  final rank = _roleRankForSession(worldId, sessionId);
  if (rank == 0) {
    return 'Learn';
  }
  if (rank == 1) {
    return 'Practice';
  }
  if (rank == 2) {
    return 'Checkpoint';
  }
  return 'UNKNOWN';
}

class _WorldChainReport {
  const _WorldChainReport({
    required this.worldId,
    required this.orderedSessionIds,
    required this.missingSessions,
    required this.unexpectedSessions,
    required this.chainViolations,
    required this.roleOrderingViolations,
    required this.ok,
  });

  final int worldId;
  final List<String> orderedSessionIds;
  final List<String> missingSessions;
  final List<String> unexpectedSessions;
  final List<String> chainViolations;
  final List<String> roleOrderingViolations;
  final bool ok;
}
