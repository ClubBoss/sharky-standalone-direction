import 'dart:convert';
import 'dart:io';

final RegExp _kDrillIndexLine = RegExp(r'^- ([a-z0-9_]+):');

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('export_world_drills_manifest_v1: no arguments supported');
    exitCode = 64;
    return;
  }

  final sessionsManifest = File(
    'content/_meta/world_sessions_manifest_v1.json',
  );
  if (!sessionsManifest.existsSync()) {
    stderr.writeln(
      'export_world_drills_manifest_v1: manifest not found: ${sessionsManifest.path}',
    );
    exitCode = 1;
    return;
  }

  final parsed = _loadSessionsManifest(sessionsManifest);
  if (parsed.errors.isNotEmpty) {
    for (final e in parsed.errors..sort()) {
      stderr.writeln('export_world_drills_manifest_v1: $e');
    }
    exitCode = 1;
    return;
  }

  final errors = <String>[];
  final worldEntries = <_WorldEntry>[];
  final tupleSeen = <String>{};

  for (final world in parsed.worlds) {
    final sessions = <_SessionEntry>[];
    for (final session in world.sessions) {
      final drillsIndex = File('${session.path}drills/index.md');
      if (!drillsIndex.existsSync()) {
        errors.add('${drillsIndex.path}: missing required file');
        continue;
      }
      final drillIds = _parseDrillIds(drillsIndex);
      final seen = <String>{};
      final dups = <String>{};
      for (final id in drillIds) {
        if (!seen.add(id)) dups.add(id);
      }
      for (final dup in (dups.toList()..sort())) {
        errors.add('${drillsIndex.path}: duplicate drill id $dup');
      }
      final sortedIds = seen.toList()..sort();
      final drills = <_DrillEntry>[];
      for (final drillId in sortedIds) {
        final tuple = '${session.id}/$drillId';
        if (!tupleSeen.add(tuple)) {
          errors.add('${drillsIndex.path}: duplicate drill tuple $tuple');
          continue;
        }
        drills.add(
          _DrillEntry(
            id: drillId,
            path: '${session.path}drills/d.$drillId.json',
          ),
        );
      }
      sessions.add(
        _SessionEntry(id: session.id, path: session.path, drills: drills),
      );
    }
    sessions.sort((a, b) => a.id.compareTo(b.id));
    worldEntries.add(_WorldEntry(world: world.world, sessions: sessions));
  }

  if (errors.isNotEmpty) {
    for (final e in errors..sort()) {
      stderr.writeln('export_world_drills_manifest_v1: $e');
    }
    exitCode = 1;
    return;
  }

  worldEntries.sort((a, b) => a.world.compareTo(b.world));
  final outDir = Directory('content/_meta')..createSync(recursive: true);
  final outFile = File('${outDir.path}/world_drills_manifest_v1.json');
  final jsonText = _buildJson(worldEntries);
  outFile.writeAsStringSync(jsonText);

  final totalSessions = worldEntries.fold<int>(
    0,
    (s, w) => s + w.sessions.length,
  );
  final totalDrills = worldEntries.fold<int>(
    0,
    (s, w) => s + w.sessions.fold<int>(0, (a, x) => a + x.drills.length),
  );
  stdout.writeln(
    'export_world_drills_manifest_v1: wrote ${outFile.path} (worlds=${worldEntries.length}, sessions=$totalSessions, drills=$totalDrills)',
  );
}

class _ParsedSessionsManifest {
  const _ParsedSessionsManifest({required this.worlds, required this.errors});
  final List<_WorldEntry> worlds;
  final List<String> errors;
}

_ParsedSessionsManifest _loadSessionsManifest(File file) {
  final errors = <String>[];
  final worldsOut = <_WorldEntry>[];
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    return const _ParsedSessionsManifest(
      worlds: <_WorldEntry>[],
      errors: <String>['manifest root must be object'],
    );
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    return const _ParsedSessionsManifest(
      worlds: <_WorldEntry>[],
      errors: <String>['manifest worlds must be array'],
    );
  }
  for (final w in worlds) {
    if (w is! Map) continue;
    final worldNum = w['world'];
    final sessions = w['sessions'];
    if (worldNum is! int || sessions is! List) continue;
    final sessionEntries = <_SessionEntry>[];
    for (final s in sessions) {
      if (s is! Map) continue;
      final id = s['id'];
      final path = s['path'];
      if (id is! String || path is! String) continue;
      sessionEntries.add(_SessionEntry(id: id, path: path, drills: const []));
    }
    sessionEntries.sort((a, b) => a.id.compareTo(b.id));
    worldsOut.add(_WorldEntry(world: worldNum, sessions: sessionEntries));
  }
  return _ParsedSessionsManifest(worlds: worldsOut, errors: errors);
}

List<String> _parseDrillIds(File file) {
  final ids = <String>[];
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    final m = _kDrillIndexLine.firstMatch(line);
    if (m == null) continue;
    ids.add(m.group(1)!);
  }
  return ids;
}

String _buildJson(List<_WorldEntry> worlds) {
  final b = StringBuffer();
  b.writeln('{');
  b.writeln('  "version": 1,');
  b.writeln('  "generated_from": "content tree",');
  b.writeln('  "worlds": [');
  for (var i = 0; i < worlds.length; i++) {
    final w = worlds[i];
    b.writeln('    {');
    b.writeln('      "world": ${w.world},');
    b.writeln('      "sessions": [');
    for (var j = 0; j < w.sessions.length; j++) {
      final s = w.sessions[j];
      b.writeln('        {');
      b.writeln('          "id": "${_e(s.id)}",');
      b.writeln('          "path": "${_e(s.path)}",');
      b.writeln('          "drills": [');
      for (var k = 0; k < s.drills.length; k++) {
        final d = s.drills[k];
        b.writeln('            {');
        b.writeln('              "id": "${_e(d.id)}",');
        b.writeln('              "path": "${_e(d.path)}"');
        b.write('            }');
        if (k != s.drills.length - 1) b.write(',');
        b.writeln();
      }
      b.writeln('          ]');
      b.write('        }');
      if (j != w.sessions.length - 1) b.write(',');
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

String _e(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

class _WorldEntry {
  const _WorldEntry({required this.world, required this.sessions});
  final int world;
  final List<_SessionEntry> sessions;
}

class _SessionEntry {
  const _SessionEntry({
    required this.id,
    required this.path,
    required this.drills,
  });
  final String id;
  final String path;
  final List<_DrillEntry> drills;
}

class _DrillEntry {
  const _DrillEntry({required this.id, required this.path});
  final String id;
  final String path;
}
