import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('shard_world_sessions_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final manifestFile = File('content/_meta/world_sessions_manifest_v1.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln(
      'shard_world_sessions_v1: manifest not found: content/_meta/world_sessions_manifest_v1.json',
    );
    exitCode = 1;
    return;
  }

  final sessions = _loadSessionsFromManifest(manifestFile);
  sessions.sort((a, b) {
    final byWorld = a.world.compareTo(b.world);
    if (byWorld != 0) return byWorld;
    return a.id.compareTo(b.id);
  });

  final packets = List<List<String>>.generate(
    parsed.packets!,
    (_) => <String>[],
    growable: false,
  );
  for (var i = 0; i < sessions.length; i++) {
    packets[i % parsed.packets!].add(sessions[i].id);
  }

  final outDir = Directory(parsed.outDir!);
  outDir.createSync(recursive: true);
  final outFile = File('${outDir.path}/packets_v1.json');
  outFile.writeAsStringSync(_buildPacketsJson(packets));

  stdout.writeln(
    'shard_world_sessions_v1: wrote ${outFile.path} (packets=${packets.length}, sessions=${sessions.length})',
  );
}

_ParsedArgs _parseArgs(List<String> args) {
  int? packets;
  String? outDir;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--packets':
        if (i + 1 >= args.length) {
          return const _ParsedArgs(error: 'missing value for --packets');
        }
        packets = int.tryParse(args[++i]);
        break;
      case '--out':
        if (i + 1 >= args.length) {
          return const _ParsedArgs(error: 'missing value for --out');
        }
        outDir = args[++i];
        break;
      default:
        return _ParsedArgs(error: 'unknown argument: $arg');
    }
  }
  if (packets == null || packets < 1) {
    return const _ParsedArgs(error: '--packets must be >=1');
  }
  if (outDir == null || outDir.isEmpty) {
    return const _ParsedArgs(error: '--out is required');
  }
  return _ParsedArgs(packets: packets, outDir: outDir);
}

List<_SessionRef> _loadSessionsFromManifest(File manifestFile) {
  final decoded = jsonDecode(manifestFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('shard_world_sessions_v1: manifest root must be object');
    exit(1);
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    stderr.writeln('shard_world_sessions_v1: manifest worlds must be array');
    exit(1);
  }
  final sessions = <_SessionRef>[];
  for (final worldEntry in worlds) {
    if (worldEntry is! Map) continue;
    final world = worldEntry['world'];
    final worldSessions = worldEntry['sessions'];
    if (world is! int || worldSessions is! List) continue;
    for (final sessionEntry in worldSessions) {
      if (sessionEntry is! Map) continue;
      final id = sessionEntry['id'];
      final path = sessionEntry['path'];
      if (id is! String || path is! String) continue;
      sessions.add(_SessionRef(world: world, id: id, path: path));
    }
  }
  return sessions;
}

String _buildPacketsJson(List<List<String>> packets) {
  final b = StringBuffer();
  b.writeln('{');
  b.writeln('  "version": 1,');
  b.writeln('  "packets": [');
  for (var i = 0; i < packets.length; i++) {
    final ids = List<String>.from(packets[i])..sort();
    b.writeln('    {');
    b.writeln('      "index": $i,');
    b.writeln('      "session_ids": [');
    for (var j = 0; j < ids.length; j++) {
      b.write('        "${_escapeJson(ids[j])}"');
      if (j != ids.length - 1) b.write(',');
      b.writeln();
    }
    b.writeln('      ]');
    b.write('    }');
    if (i != packets.length - 1) b.write(',');
    b.writeln();
  }
  b.writeln('  ]');
  b.writeln('}');
  return b.toString();
}

String _escapeJson(String value) =>
    value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

class _ParsedArgs {
  const _ParsedArgs({this.packets, this.outDir, this.error});

  final int? packets;
  final String? outDir;
  final String? error;
}

class _SessionRef {
  const _SessionRef({
    required this.world,
    required this.id,
    required this.path,
  });

  final int world;
  final String id;
  final String path;
}
