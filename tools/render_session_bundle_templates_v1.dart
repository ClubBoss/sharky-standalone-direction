import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('render_session_bundle_templates_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final packetsFile = File(parsed.inputPath!);
  if (!packetsFile.existsSync()) {
    stderr.writeln(
      'render_session_bundle_templates_v1: packets file not found: ${parsed.inputPath}',
    );
    exitCode = 1;
    return;
  }

  final packets = _loadPackets(packetsFile);
  final outDir = Directory(parsed.outDir!);
  outDir.createSync(recursive: true);

  var totalSessions = 0;
  for (final packet in packets) {
    final ids = List<String>.from(packet.sessionIds)..sort();
    totalSessions += ids.length;
    final file = File(
      '${outDir.path}/bundle_template_packet_${packet.index}_v1.txt',
    );
    file.writeAsStringSync(_buildBundleTemplate(ids));
    stdout.writeln(
      'render_session_bundle_templates_v1: wrote ${file.path} (packet=${packet.index}, sessions=${ids.length})',
    );
  }
  stdout.writeln(
    'render_session_bundle_templates_v1: OK (packets=${packets.length}, sessions=$totalSessions)',
  );
}

_ParsedArgs _parseArgs(List<String> args) {
  String? inputPath;
  String? outDir;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--in':
        if (i + 1 >= args.length)
          return const _ParsedArgs(error: 'missing value for --in');
        inputPath = args[++i];
        break;
      case '--out':
        if (i + 1 >= args.length)
          return const _ParsedArgs(error: 'missing value for --out');
        outDir = args[++i];
        break;
      default:
        return _ParsedArgs(error: 'unknown argument: $arg');
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
      'render_session_bundle_templates_v1: packets root must be object',
    );
    exit(1);
  }
  final packetsRaw = decoded['packets'];
  if (packetsRaw is! List) {
    stderr.writeln('render_session_bundle_templates_v1: packets must be array');
    exit(1);
  }
  final packets = <_Packet>[];
  for (final packetEntry in packetsRaw) {
    if (packetEntry is! Map) continue;
    final idx = packetEntry['index'];
    final idsRaw = packetEntry['session_ids'];
    if (idx is! int || idsRaw is! List) continue;
    final ids = <String>[];
    for (final id in idsRaw) {
      if (id is String) ids.add(id);
    }
    packets.add(_Packet(index: idx, sessionIds: ids));
  }
  packets.sort((a, b) => a.index.compareTo(b.index));
  return packets;
}

String _buildBundleTemplate(List<String> sessionIds) {
  final b = StringBuffer();
  for (var i = 0; i < sessionIds.length; i++) {
    final id = sessionIds[i];
    b.writeln('=== SESSION $id ===');
    b.writeln('--- session.md ---');
    b.writeln('TODO');
    b.writeln('--- notes.md ---');
    b.writeln('TODO');
    b.writeln('--- drills/index.md ---');
    b.writeln('TODO');
    if (i != sessionIds.length - 1) {
      b.writeln();
    }
  }
  return b.toString();
}

class _ParsedArgs {
  const _ParsedArgs({this.inputPath, this.outDir, this.error});

  final String? inputPath;
  final String? outDir;
  final String? error;
}

class _Packet {
  const _Packet({required this.index, required this.sessionIds});

  final int index;
  final List<String> sessionIds;
}
