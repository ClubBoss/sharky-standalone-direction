import 'dart:io';

const List<int> _kWorldIds = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
final RegExp _kSessionIndexLine = RegExp(r'^- ([A-Za-z0-9._-]+):');

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'export_world_sessions_manifest_v1: no arguments supported (deterministic export only)',
    );
    exitCode = 64;
    return;
  }

  final errors = <String>[];
  final worldEntries = <_WorldEntry>[];

  for (final world in _kWorldIds) {
    final worldRoot = Directory('content/worlds/world$world/v1');
    final sessionsIndex = File('${worldRoot.path}/sessions/index.md');
    if (!sessionsIndex.existsSync()) {
      errors.add('${sessionsIndex.path}: missing required file');
      continue;
    }

    final ids = _parseSessionIds(sessionsIndex);
    if (ids.isEmpty) {
      errors.add('${sessionsIndex.path}: no session ids found');
      continue;
    }

    final seen = <String>{};
    final dups = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) dups.add(id);
    }
    final sortedDups = dups.toList()..sort();
    for (final dup in sortedDups) {
      errors.add('${sessionsIndex.path}: duplicate session id $dup');
    }

    final sortedIds = seen.toList()..sort();
    final sessions = <_SessionEntry>[];
    for (final id in sortedIds) {
      if (!_isAscii(id) || id.contains(' ')) {
        errors.add('${sessionsIndex.path}: invalid session id $id');
        continue;
      }
      final sessionDirPath = 'content/worlds/world$world/v1/sessions/$id/';
      sessions.add(_SessionEntry(id: id, path: sessionDirPath));
    }
    worldEntries.add(_WorldEntry(world: world, sessions: sessions));
  }

  if (errors.isNotEmpty) {
    errors.sort();
    for (final error in errors) {
      stderr.writeln('export_world_sessions_manifest_v1: $error');
    }
    exitCode = 1;
    return;
  }

  worldEntries.sort((a, b) => a.world.compareTo(b.world));
  final outDir = Directory('content/_meta');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }
  final outFile = File('${outDir.path}/world_sessions_manifest_v1.json');
  final json = _buildManifestJson(worldEntries);
  outFile.writeAsStringSync(json);

  final totalSessions = worldEntries.fold<int>(
    0,
    (sum, w) => sum + w.sessions.length,
  );
  stdout.writeln(
    'export_world_sessions_manifest_v1: wrote ${outFile.path} (worlds=${worldEntries.length}, sessions=$totalSessions)',
  );
}

List<String> _parseSessionIds(File sessionIndexFile) {
  final ids = <String>[];
  final lines = sessionIndexFile.readAsLinesSync();
  for (final rawLine in lines) {
    final line = rawLine.trim();
    final match = _kSessionIndexLine.firstMatch(line);
    if (match == null) continue;
    ids.add(match.group(1)!);
  }
  return ids;
}

bool _isAscii(String value) {
  for (final unit in value.codeUnits) {
    if (unit < 32 || unit > 126) return false;
  }
  return true;
}

String _buildManifestJson(List<_WorldEntry> worlds) {
  final b = StringBuffer();
  b.writeln('{');
  b.writeln('  "version": 1,');
  b.writeln('  "generated_from": "content tree",');
  b.writeln('  "worlds": [');
  for (var i = 0; i < worlds.length; i++) {
    final world = worlds[i];
    b.writeln('    {');
    b.writeln('      "world": ${world.world},');
    b.writeln('      "sessions": [');
    for (var j = 0; j < world.sessions.length; j++) {
      final s = world.sessions[j];
      b.writeln('        {');
      b.writeln('          "id": "${_escapeJson(s.id)}",');
      b.writeln('          "path": "${_escapeJson(s.path)}"');
      b.write('        }');
      if (j != world.sessions.length - 1) b.write(',');
      b.writeln();
    }
    b.writeln('      ]');
    b.write('    }');
    if (i != worlds.length - 1) b.write(',');
    b.writeln();
  }
  b.writeln('  ]');
  b.writeln('}');
  return b.toString();
}

String _escapeJson(String value) =>
    value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

class _WorldEntry {
  const _WorldEntry({required this.world, required this.sessions});

  final int world;
  final List<_SessionEntry> sessions;
}

class _SessionEntry {
  const _SessionEntry({required this.id, required this.path});

  final String id;
  final String path;
}
