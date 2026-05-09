import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final cfg = _parseArgs(args);
  if (cfg.error != null) {
    stderr.writeln('render_session_generation_prompts_v1: ${cfg.error}');
    exitCode = 64;
    return;
  }

  final packetsFile = File(cfg.packetsJsonPath!);
  if (!packetsFile.existsSync()) {
    stderr.writeln(
      'render_session_generation_prompts_v1: packets file not found: ${cfg.packetsJsonPath}',
    );
    exitCode = 1;
    return;
  }
  final templatesDir = Directory(cfg.templatesDirPath!);
  if (!templatesDir.existsSync()) {
    stderr.writeln(
      'render_session_generation_prompts_v1: templates dir not found: ${cfg.templatesDirPath}',
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
      'render_session_generation_prompts_v1: packet not found: ${cfg.onlyPacket}',
    );
    exitCode = 1;
    return;
  }

  final outDir = Directory(cfg.outDirPath!);
  outDir.createSync(recursive: true);

  var totalSessions = 0;
  for (final packet in selected) {
    final templatePath =
        '${templatesDir.path}/bundle_template_packet_${packet.index}_v1.txt';
    final templateFile = File(templatePath);
    if (!templateFile.existsSync()) {
      stderr.writeln(
        'render_session_generation_prompts_v1: template file not found: $templatePath',
      );
      exitCode = 1;
      return;
    }

    final templateContent = _normalizeText(templateFile.readAsStringSync());
    final prompt = _buildPrompt(
      packetIndex: packet.index,
      sessionIds: List<String>.from(packet.sessionIds)..sort(),
      templateContent: templateContent,
      style: cfg.style!,
    );
    final outFile = File('${outDir.path}/prompt_packet_${packet.index}_v1.md');
    outFile.writeAsStringSync(prompt);
    totalSessions += packet.sessionIds.length;
    stdout.writeln(
      'render_session_generation_prompts_v1: wrote ${outFile.path} (packet=${packet.index}, sessions=${packet.sessionIds.length}, style=${cfg.style})',
    );
  }

  stdout.writeln(
    'render_session_generation_prompts_v1: OK (packets=${selected.length}, sessions=$totalSessions, style=${cfg.style})',
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

  if (packetsJson == null) {
    return const _Args(error: '--packetsJson is required');
  }
  if (templatesDir == null) {
    return const _Args(error: '--templatesDir is required');
  }
  if (outDir == null) {
    return const _Args(error: '--outDir is required');
  }

  return _Args(
    packetsJsonPath: packetsJson,
    templatesDirPath: templatesDir,
    outDirPath: outDir,
    onlyPacket: onlyPacket,
    style: style,
  );
}

class _Packet {
  const _Packet({required this.index, required this.sessionIds});
  final int index;
  final List<String> sessionIds;
}

List<_Packet> _loadPackets(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln(
      'render_session_generation_prompts_v1: packets root must be object',
    );
    exit(1);
  }
  final packetsRaw = decoded['packets'];
  if (packetsRaw is! List) {
    stderr.writeln(
      'render_session_generation_prompts_v1: packets must be array',
    );
    exit(1);
  }
  final packets = <_Packet>[];
  for (final e in packetsRaw) {
    if (e is! Map) continue;
    final idx = e['index'];
    final idsRaw = e['session_ids'];
    if (idx is! int || idsRaw is! List) continue;
    final ids = <String>[];
    for (final id in idsRaw) {
      if (id is String) ids.add(id);
    }
    ids.sort();
    packets.add(_Packet(index: idx, sessionIds: ids));
  }
  packets.sort((a, b) => a.index.compareTo(b.index));
  return packets;
}

String _buildPrompt({
  required int packetIndex,
  required List<String> sessionIds,
  required String templateContent,
  required String style,
}) {
  final b = StringBuffer();
  b.writeln('# Packet Prompt v1 (packet $packetIndex)');
  b.writeln();
  b.writeln(
    'Fill the bundle template exactly; do not change delimiters/headers/ids.',
  );
  b.writeln();
  b.writeln('## Hard constraints');
  b.writeln('- ASCII-only content.');
  b.writeln('- Use LF newlines only.');
  b.writeln('- No trailing spaces.');
  b.writeln('- Keep exact block headers and delimiters unchanged.');
  b.writeln('- Do not add extra blocks or extra SESSION sections.');
  b.writeln('- Do not wrap the bundle output in markdown fences.');
  b.writeln('- Keep IDs unchanged.');
  b.writeln('- Keep deterministic ordering.');
  if (style == 'full') {
    b.writeln();
    b.writeln('## Content constraints');
    b.writeln(
      '- session.md: concise training session overview + objective + steps; factual; no motivational fluff.',
    );
    b.writeln(
      '- notes.md: short design notes + TODO list (ASCII only); no external links.',
    );
    b.writeln(
      '- drills/index.md: bullet drills with stable ASCII drill IDs and one-line descriptions.',
    );
  }
  b.writeln();
  b.writeln('## Packet metadata');
  b.writeln('- packet_index: $packetIndex');
  b.writeln('- session_count: ${sessionIds.length}');
  b.writeln('- session_ids: ${sessionIds.join(',')}');
  b.writeln();
  b.writeln('## Bundle template (copy and fill verbatim)');
  b.writeln();
  b.write(templateContent);
  if (!templateContent.endsWith('\n')) {
    b.writeln();
  }
  return b.toString();
}

String _normalizeText(String input) {
  final lf = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = lf.split('\n');
  final trimmed = <String>[];
  for (final line in lines) {
    trimmed.add(line.replaceFirst(RegExp(r'[ \t]+$'), ''));
  }
  var out = trimmed.join('\n');
  out = out.replaceAll(RegExp(r'\n+$'), '');
  return '$out\n';
}
