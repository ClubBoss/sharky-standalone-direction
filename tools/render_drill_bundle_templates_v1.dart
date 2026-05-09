import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('render_drill_bundle_templates_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final packetsFile = File(parsed.inputPath!);
  if (!packetsFile.existsSync()) {
    stderr.writeln(
      'render_drill_bundle_templates_v1: packets file not found: ${parsed.inputPath}',
    );
    exitCode = 1;
    return;
  }

  final packets = _loadPackets(packetsFile);
  final outDir = Directory(parsed.outDir!);
  outDir.createSync(recursive: true);

  var totalDrills = 0;
  var totalSessions = 0;
  for (final packet in packets) {
    final grouped = _groupBySession(packet.items);
    final packetDrills = grouped.fold<int>(0, (s, g) => s + g.drills.length);
    if (grouped.isEmpty) {
      stdout.writeln(
        'render_drill_bundle_templates_v1: skipped packet=${packet.index} (sessions=0, drills=0)',
      );
      continue;
    }
    totalSessions += grouped.length;
    totalDrills += packetDrills;
    final file = File(
      '${outDir.path}/drill_bundle_template_packet_${packet.index}_v1.txt',
    );
    file.writeAsStringSync(_buildBundleTemplate(grouped));
    stdout.writeln(
      'render_drill_bundle_templates_v1: wrote ${file.path} (packet=${packet.index}, sessions=${grouped.length}, drills=$packetDrills)',
    );
  }
  stdout.writeln(
    'render_drill_bundle_templates_v1: OK (packets=${packets.length}, sessions=$totalSessions, drills=$totalDrills)',
  );
}

class _ParsedArgs {
  const _ParsedArgs({this.inputPath, this.outDir, this.error});
  final String? inputPath;
  final String? outDir;
  final String? error;
}

_ParsedArgs _parseArgs(List<String> args) {
  String? inputPath;
  String? outDir;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--in':
        if (i + 1 >= args.length) {
          return const _ParsedArgs(error: 'missing value for --in');
        }
        inputPath = args[++i];
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
  if (inputPath == null) return const _ParsedArgs(error: '--in is required');
  if (outDir == null) return const _ParsedArgs(error: '--out is required');
  return _ParsedArgs(inputPath: inputPath, outDir: outDir);
}

List<_Packet> _loadPackets(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln(
      'render_drill_bundle_templates_v1: packets root must be object',
    );
    exit(1);
  }
  final packetsRaw = decoded['packets'];
  if (packetsRaw is! List) {
    stderr.writeln('render_drill_bundle_templates_v1: packets must be array');
    exit(1);
  }
  final packets = <_Packet>[];
  for (final p in packetsRaw) {
    if (p is! Map) continue;
    final index = p['index'];
    final itemsRaw = p['items'];
    if (index is! int || itemsRaw is! List) continue;
    final items = <_DrillItem>[];
    for (final it in itemsRaw) {
      if (it is! Map) continue;
      final world = it['world'];
      final sessionId = it['session_id'];
      final drillId = it['drill_id'];
      final drillPath = it['drill_path'];
      if (world is! int ||
          sessionId is! String ||
          drillId is! String ||
          drillPath is! String) {
        continue;
      }
      final kind = _loadKindFromDrillFile(drillPath);
      items.add(
        _DrillItem(
          world: world,
          sessionId: sessionId,
          drillId: drillId,
          drillPath: drillPath,
          kind: kind,
        ),
      );
    }
    items.sort((a, b) {
      final byWorld = a.world.compareTo(b.world);
      if (byWorld != 0) return byWorld;
      final bySession = a.sessionId.compareTo(b.sessionId);
      if (bySession != 0) return bySession;
      return a.drillId.compareTo(b.drillId);
    });
    packets.add(_Packet(index: index, items: items));
  }
  packets.sort((a, b) => a.index.compareTo(b.index));
  return packets;
}

String _loadKindFromDrillFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln(
      'render_drill_bundle_templates_v1: drill file not found: $path',
    );
    exit(1);
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln(
      'render_drill_bundle_templates_v1: drill JSON root must be object: $path',
    );
    exit(1);
  }
  final kind = decoded['kind'];
  if (kind is! String) {
    stderr.writeln(
      'render_drill_bundle_templates_v1: drill kind missing in $path',
    );
    exit(1);
  }
  return kind;
}

List<_SessionGroup> _groupBySession(List<_DrillItem> items) {
  final bySession = <String, List<_DrillItem>>{};
  for (final item in items) {
    bySession.putIfAbsent(item.sessionId, () => <_DrillItem>[]).add(item);
  }
  final sessionIds = bySession.keys.toList()..sort();
  final groups = <_SessionGroup>[];
  for (final sessionId in sessionIds) {
    final drills = bySession[sessionId]!
      ..sort((a, b) => a.drillId.compareTo(b.drillId));
    groups.add(_SessionGroup(sessionId: sessionId, drills: drills));
  }
  return groups;
}

String _buildBundleTemplate(List<_SessionGroup> groups) {
  final b = StringBuffer();
  for (var i = 0; i < groups.length; i++) {
    final group = groups[i];
    b.writeln('=== SESSION ${group.sessionId} ===');
    b.writeln('--- drills/index.md ---');
    b.writeln('# Drills');
    for (final drill in group.drills) {
      b.writeln('- ${drill.drillId}: ${drill.kind} TODO');
    }
    for (final drill in group.drills) {
      b.writeln('--- drills/d.${drill.drillId}.json ---');
      b.writeln(_minimalDrillJson(drill));
    }
    if (i != groups.length - 1) {
      b.writeln();
    }
  }
  return _normalizeLf(b.toString());
}

String _minimalDrillJson(_DrillItem drill) {
  final expected = switch (drill.kind) {
    'seat_tap' => '{"role":"sb"}',
    'action_choice' => '{"actionId":"fold"}',
    'board_tap' => '{"boardSlot":"flop_left"}',
    'hole_cards_tap' => '{"cardSlot":"p0"}',
    _ => '{"role":"sb"}',
  };
  return '{"id":"${_e(drill.drillId)}","kind":"${_e(drill.kind)}","prompt":"TODO","expected":$expected,"error_class":"todo"}';
}

String _normalizeLf(String input) =>
    input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _e(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

class _Packet {
  const _Packet({required this.index, required this.items});
  final int index;
  final List<_DrillItem> items;
}

class _DrillItem {
  const _DrillItem({
    required this.world,
    required this.sessionId,
    required this.drillId,
    required this.drillPath,
    required this.kind,
  });
  final int world;
  final String sessionId;
  final String drillId;
  final String drillPath;
  final String kind;
}

class _SessionGroup {
  const _SessionGroup({required this.sessionId, required this.drills});
  final String sessionId;
  final List<_DrillItem> drills;
}
