import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final cfg = _parseArgs(args);
  if (cfg.error != null) {
    stderr.writeln('render_drill_generation_prompts_v1: ${cfg.error}');
    exitCode = 64;
    return;
  }

  final packetsFile = File(cfg.packetsJsonPath!);
  if (!packetsFile.existsSync()) {
    stderr.writeln(
      'render_drill_generation_prompts_v1: packets file not found: ${cfg.packetsJsonPath}',
    );
    exitCode = 1;
    return;
  }

  final templatesDir = Directory(cfg.templatesDirPath!);
  if (!templatesDir.existsSync()) {
    stderr.writeln(
      'render_drill_generation_prompts_v1: templates dir not found: ${cfg.templatesDirPath}',
    );
    exitCode = 1;
    return;
  }

  final packets = _loadPackets(packetsFile);
  final selected = <_Packet>[];
  for (final p in packets) {
    if (cfg.onlyPacket != null && p.index != cfg.onlyPacket) continue;
    selected.add(p);
  }
  if (cfg.onlyPacket != null && selected.isEmpty) {
    stderr.writeln(
      'render_drill_generation_prompts_v1: packet not found: ${cfg.onlyPacket}',
    );
    exitCode = 1;
    return;
  }

  final outDir = Directory(cfg.outDirPath!);
  outDir.createSync(recursive: true);

  var writtenPackets = 0;
  var totalDrills = 0;
  for (final packet in selected) {
    final templatePath =
        '${templatesDir.path}/drill_bundle_template_packet_${packet.index}_v1.txt';
    final templateFile = File(templatePath);
    if (!templateFile.existsSync()) {
      stdout.writeln(
        'render_drill_generation_prompts_v1: skip packet=${packet.index} (no template)',
      );
      continue;
    }

    final templateContent = _normalizeText(templateFile.readAsStringSync());
    final prompt = _buildPrompt(
      packet: packet,
      templateContent: templateContent,
      style: cfg.style!,
    );
    final outFile = File(
      '${outDir.path}/prompt_drill_packet_${packet.index}_v1.md',
    );
    outFile.writeAsStringSync(prompt);
    writtenPackets++;
    totalDrills += packet.items.length;
    stdout.writeln(
      'render_drill_generation_prompts_v1: wrote ${outFile.path} (packet=${packet.index}, sessions=${packet.sessionIds.length}, drills=${packet.items.length}, style=${cfg.style})',
    );
  }

  stdout.writeln(
    'render_drill_generation_prompts_v1: OK (packets=${selected.length}, written=$writtenPackets, drills=$totalDrills, style=${cfg.style})',
  );
}

class _Args {
  const _Args({
    this.packetsJsonPath,
    this.templatesDirPath,
    this.outDirPath,
    this.onlyPacket,
    this.style,
    this.error,
  });

  final String? packetsJsonPath;
  final String? templatesDirPath;
  final String? outDirPath;
  final int? onlyPacket;
  final String? style;
  final String? error;
}

_Args _parseArgs(List<String> args) {
  String? packetsJson;
  String? templatesDir;
  String? outDir;
  int? onlyPacket;
  var style = 'full';

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '--packetsJson':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --packetsJson');
        }
        packetsJson = args[++i];
        break;
      case '--templatesDir':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --templatesDir');
        }
        templatesDir = args[++i];
        break;
      case '--outDir':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --outDir');
        }
        outDir = args[++i];
        break;
      case '--only-packet':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --only-packet');
        }
        onlyPacket = int.tryParse(args[++i]);
        if (onlyPacket == null || onlyPacket < 0) {
          return const _Args(error: '--only-packet must be a non-negative int');
        }
        break;
      case '--style':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --style');
        }
        style = args[++i];
        if (style != 'short' && style != 'full') {
          return const _Args(error: '--style must be short or full');
        }
        break;
      default:
        return _Args(error: 'unknown argument: $a');
    }
  }

  if (packetsJson == null)
    return const _Args(error: '--packetsJson is required');
  if (templatesDir == null)
    return const _Args(error: '--templatesDir is required');
  if (outDir == null) return const _Args(error: '--outDir is required');

  return _Args(
    packetsJsonPath: packetsJson,
    templatesDirPath: templatesDir,
    outDirPath: outDir,
    onlyPacket: onlyPacket,
    style: style,
  );
}

class _Packet {
  const _Packet({required this.index, required this.items});

  final int index;
  final List<_DrillItem> items;

  List<String> get sessionIds {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in items) {
      if (seen.add(item.sessionId)) {
        ordered.add(item.sessionId);
      }
    }
    return ordered;
  }
}

class _DrillItem {
  const _DrillItem({
    required this.world,
    required this.sessionId,
    required this.drillId,
  });

  final int world;
  final String sessionId;
  final String drillId;
}

List<_Packet> _loadPackets(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln(
      'render_drill_generation_prompts_v1: packets root must be object',
    );
    exit(1);
  }
  final packetsRaw = decoded['packets'];
  if (packetsRaw is! List) {
    stderr.writeln('render_drill_generation_prompts_v1: packets must be array');
    exit(1);
  }

  final packets = <_Packet>[];
  for (final entry in packetsRaw) {
    if (entry is! Map) continue;
    final idx = entry['index'];
    final itemsRaw = entry['items'];
    if (idx is! int || itemsRaw is! List) continue;
    final items = <_DrillItem>[];
    for (final item in itemsRaw) {
      if (item is! Map) continue;
      final world = item['world'];
      final sessionId = item['session_id'];
      final drillId = item['drill_id'];
      if (world is! int || sessionId is! String || drillId is! String) continue;
      items.add(
        _DrillItem(world: world, sessionId: sessionId, drillId: drillId),
      );
    }
    items.sort((a, b) {
      final byWorld = a.world.compareTo(b.world);
      if (byWorld != 0) return byWorld;
      final bySession = a.sessionId.compareTo(b.sessionId);
      if (bySession != 0) return bySession;
      return a.drillId.compareTo(b.drillId);
    });
    packets.add(_Packet(index: idx, items: items));
  }
  packets.sort((a, b) => a.index.compareTo(b.index));
  return packets;
}

String _buildPrompt({
  required _Packet packet,
  required String templateContent,
  required String style,
}) {
  final drillLines = packet.items
      .map((d) => '  - w${d.world}:${d.sessionId}:${d.drillId}')
      .toList(growable: false);

  final b = StringBuffer();
  b.writeln('# Drill Packet Prompt v1 (packet ${packet.index})');
  b.writeln();
  b.writeln(
    'Fill the drill bundle template exactly; do not change delimiters, headers, session ids, drill ids, or block order.',
  );
  b.writeln();
  b.writeln('## Hard constraints');
  b.writeln('- ASCII-only content.');
  b.writeln('- Use LF newlines only.');
  b.writeln('- No trailing spaces.');
  b.writeln('- Keep exact delimiters and block headers unchanged.');
  b.writeln('- Do not add extra blocks or extra SESSION sections.');
  b.writeln('- Do not remove listed drill blocks.');
  b.writeln('- Do not wrap output in markdown fences.');
  b.writeln('- No commentary outside the template content.');
  b.writeln('- Keep sessions and drill blocks in deterministic order.');
  if (style == 'full') {
    b.writeln();
    b.writeln('## Drill contract reminders (v1)');
    b.writeln(
      '- seat_tap: JSON must include id, kind, prompt, expected, error_class; expected uses seatId and/or role identifiers only.',
    );
    b.writeln(
      '- action_choice: expected.actionId (case-sensitive string identifier).',
    );
    b.writeln(
      '- board_tap: expected.boardSlot (case-sensitive string identifier).',
    );
    b.writeln(
      '- hole_cards_tap: expected.cardSlot (p0 or p1; case-sensitive string identifier).',
    );
    b.writeln(
      '- No pixels/coords, no timestamps, no RNG-dependent values in drill JSON.',
    );
  }
  b.writeln();
  b.writeln('## Packet metadata');
  b.writeln('- packet_index: ${packet.index}');
  b.writeln('- session_count: ${packet.sessionIds.length}');
  b.writeln('- drill_count: ${packet.items.length}');
  b.writeln('- session_ids: ${packet.sessionIds.join(',')}');
  b.writeln('- drills:');
  for (final line in drillLines) {
    b.writeln(line);
  }
  b.writeln();
  b.writeln('## TEMPLATE (do not edit headers)');
  b.writeln();
  b.write(templateContent);
  if (!templateContent.endsWith('\n')) {
    b.writeln();
  }
  return _normalizeText(b.toString());
}

String _normalizeText(String input) {
  final lf = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = lf.split('\n');
  final trimmed = <String>[];
  for (final line in lines) {
    trimmed.add(line.replaceFirst(RegExp(r'[ \t]+$'), ''));
  }
  var out = trimmed.join('\n');
  out = out.replaceAll(RegExp(r'\n*$'), '');
  return '$out\n';
}
