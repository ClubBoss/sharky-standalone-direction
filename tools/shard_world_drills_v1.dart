import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('shard_world_drills_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final manifestFile = File('content/_meta/world_drills_manifest_v1.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln(
      'shard_world_drills_v1: manifest not found: content/_meta/world_drills_manifest_v1.json',
    );
    exitCode = 1;
    return;
  }

  final items = _loadDrillsFromManifest(manifestFile);
  items.sort((a, b) {
    final byWorld = a.world.compareTo(b.world);
    if (byWorld != 0) return byWorld;
    final bySession = a.sessionId.compareTo(b.sessionId);
    if (bySession != 0) return bySession;
    return a.drillId.compareTo(b.drillId);
  });

  final packets = List<List<_DrillRef>>.generate(
    parsed.packets!,
    (_) => <_DrillRef>[],
    growable: false,
  );
  for (var i = 0; i < items.length; i++) {
    packets[i % parsed.packets!].add(items[i]);
  }

  final outDir = Directory(parsed.outDir!);
  outDir.createSync(recursive: true);
  final outFile = File('${outDir.path}/packets_drills_v1.json');
  outFile.writeAsStringSync(_buildPacketsJson(packets));

  stdout.writeln(
    'shard_world_drills_v1: wrote ${outFile.path} (packets=${packets.length}, drills=${items.length})',
  );
}

class _ParsedArgs {
  const _ParsedArgs({this.packets, this.outDir, this.error});

  final int? packets;
  final String? outDir;
  final String? error;
}

_ParsedArgs _parseArgs(List<String> args) {
  int? packets;
  String? outDir;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
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
        return _ParsedArgs(error: 'unknown argument: ${args[i]}');
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

List<_DrillRef> _loadDrillsFromManifest(File manifestFile) {
  final decoded = jsonDecode(manifestFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('shard_world_drills_v1: manifest root must be object');
    exit(1);
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    stderr.writeln('shard_world_drills_v1: manifest worlds must be array');
    exit(1);
  }
  final out = <_DrillRef>[];
  for (final worldEntry in worlds) {
    if (worldEntry is! Map) continue;
    final world = worldEntry['world'];
    final sessions = worldEntry['sessions'];
    if (world is! int || sessions is! List) continue;
    for (final sessionEntry in sessions) {
      if (sessionEntry is! Map) continue;
      final sessionId = sessionEntry['id'];
      final sessionPath = sessionEntry['path'];
      final drills = sessionEntry['drills'];
      if (sessionId is! String || sessionPath is! String || drills is! List) {
        continue;
      }
      for (final drillEntry in drills) {
        if (drillEntry is! Map) continue;
        final drillId = drillEntry['id'];
        final drillPath = drillEntry['path'];
        if (drillId is! String || drillPath is! String) continue;
        out.add(
          _DrillRef(
            world: world,
            sessionId: sessionId,
            sessionPath: sessionPath,
            drillId: drillId,
            drillPath: drillPath,
          ),
        );
      }
    }
  }
  return out;
}

String _buildPacketsJson(List<List<_DrillRef>> packets) {
  final b = StringBuffer();
  b.writeln('{');
  b.writeln('  "version": 1,');
  b.writeln('  "strategy": "round_robin_drill_items",');
  b.writeln('  "packets": [');
  for (var i = 0; i < packets.length; i++) {
    final items = List<_DrillRef>.from(packets[i])
      ..sort((a, b) {
        final byWorld = a.world.compareTo(b.world);
        if (byWorld != 0) return byWorld;
        final bySession = a.sessionId.compareTo(b.sessionId);
        if (bySession != 0) return bySession;
        return a.drillId.compareTo(b.drillId);
      });
    b.writeln('    {');
    b.writeln('      "index": $i,');
    b.writeln('      "items": [');
    for (var j = 0; j < items.length; j++) {
      final item = items[j];
      b.writeln('        {');
      b.writeln('          "world": ${item.world},');
      b.writeln('          "session_id": "${_e(item.sessionId)}",');
      b.writeln('          "session_path": "${_e(item.sessionPath)}",');
      b.writeln('          "drill_id": "${_e(item.drillId)}",');
      b.writeln('          "drill_path": "${_e(item.drillPath)}"');
      b.write('        }');
      if (j != items.length - 1) b.write(',');
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

String _e(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

class _DrillRef {
  const _DrillRef({
    required this.world,
    required this.sessionId,
    required this.sessionPath,
    required this.drillId,
    required this.drillPath,
  });

  final int world;
  final String sessionId;
  final String sessionPath;
  final String drillId;
  final String drillPath;
}
