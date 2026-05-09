import 'dart:convert';
import 'dart:io';

const List<String> _kRequiredBlockPaths = <String>[
  'session.md',
  'notes.md',
  'drills/index.md',
];
final RegExp _kSessionHeader = RegExp(r'^=== SESSION ([A-Za-z0-9._-]+) ===$');
final RegExp _kFileHeader = RegExp(r'^--- ([A-Za-z0-9._/-]+) ---$');

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('ingest_session_bundle_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final inputFile = File(parsed.inputPath!);
  if (!inputFile.existsSync()) {
    stderr.writeln(
      'ingest_session_bundle_v1: input file not found: ${parsed.inputPath}',
    );
    exitCode = 1;
    return;
  }

  final manifest = _loadManifest();
  final parsedBundle = _parseBundle(inputFile.readAsStringSync());
  final errors = <String>[...parsedBundle.errors];

  final allBundleIds = parsedBundle.sessions.keys.toList()..sort();
  final selectedIds = <String>[];
  for (final id in allBundleIds) {
    if (parsed.onlySessionId != null && id != parsed.onlySessionId) continue;
    selectedIds.add(id);
  }

  if (parsed.onlySessionId != null) {
    final onlyId = parsed.onlySessionId!;
    if (!_isAscii(onlyId) || onlyId.contains(' ')) {
      errors.add('invalid --only session id: $onlyId');
    } else if (!parsedBundle.sessions.containsKey(onlyId)) {
      errors.add('session $onlyId not found in bundle');
    }
  }

  final writes = <_PlannedWrite>[];
  for (final id in selectedIds) {
    if (!_isAscii(id) || id.contains(' ')) {
      errors.add('invalid session id: $id');
      continue;
    }

    final relSessionPath = manifest[id];
    if (relSessionPath == null) {
      errors.add('unknown session id: $id');
      continue;
    }
    if (!_isAscii(relSessionPath) || relSessionPath.contains(' ')) {
      errors.add('invalid manifest path for $id: $relSessionPath');
      continue;
    }

    final blocks = parsedBundle.sessions[id]!;
    final unknownBlocks =
        blocks.keys.where((k) => !_kRequiredBlockPaths.contains(k)).toList()
          ..sort();
    for (final key in unknownBlocks) {
      errors.add('session $id: unknown block $key');
    }
    for (final required in _kRequiredBlockPaths) {
      if (!blocks.containsKey(required)) {
        errors.add('session $id: missing block $required');
      }
    }
    if (unknownBlocks.isNotEmpty) continue;
    if (_kRequiredBlockPaths.any((p) => !blocks.containsKey(p))) continue;

    for (final relFile in _kRequiredBlockPaths) {
      final normalized = _normalizeBlockContent(blocks[relFile]!);
      writes.add(
        _PlannedWrite(
          sessionId: id,
          relativePath: '${relSessionPath}$relFile',
          content: normalized,
        ),
      );
    }
  }

  if (selectedIds.isEmpty) {
    errors.add('no sessions selected for ingest');
  }

  if (errors.isNotEmpty) {
    final sorted = errors.toList()..sort();
    for (final error in sorted) {
      stderr.writeln('ingest_session_bundle_v1: $error');
    }
    exitCode = 1;
    return;
  }

  writes.sort((a, b) {
    final byId = a.sessionId.compareTo(b.sessionId);
    if (byId != 0) return byId;
    return a.relativePath.compareTo(b.relativePath);
  });

  stdout.writeln(
    'ingest_session_bundle_v1: sessions=${selectedIds.length} ids=${selectedIds.join(',')}',
  );
  for (final write in writes) {
    stdout.writeln(
      'ingest_session_bundle_v1: ${write.sessionId} -> ${write.relativePath} bytes=${utf8.encode(write.content).length}',
    );
  }

  if (parsed.dryRun) {
    stdout.writeln('ingest_session_bundle_v1: DRY-RUN');
    return;
  }

  for (final write in writes) {
    final file = File(write.relativePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(write.content);
  }
  stdout.writeln('ingest_session_bundle_v1: APPLIED');
}

_ParsedArgs _parseArgs(List<String> args) {
  String? inputPath;
  String? onlySessionId;
  var dryRun = false;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--dry-run':
        dryRun = true;
        break;
      case '--in':
        if (i + 1 >= args.length) {
          return const _ParsedArgs(error: 'missing value for --in');
        }
        inputPath = args[++i];
        break;
      case '--only':
        if (i + 1 >= args.length) {
          return const _ParsedArgs(error: 'missing value for --only');
        }
        onlySessionId = args[++i];
        break;
      default:
        return _ParsedArgs(error: 'unknown argument: $arg');
    }
  }

  if (inputPath == null) {
    return const _ParsedArgs(error: '--in is required');
  }

  return _ParsedArgs(
    inputPath: inputPath,
    onlySessionId: onlySessionId,
    dryRun: dryRun,
  );
}

Map<String, String> _loadManifest() {
  final file = File('content/_meta/world_sessions_manifest_v1.json');
  if (!file.existsSync()) {
    stderr.writeln(
      'ingest_session_bundle_v1: manifest not found: content/_meta/world_sessions_manifest_v1.json',
    );
    exit(1);
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('ingest_session_bundle_v1: manifest root must be object');
    exit(1);
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    stderr.writeln('ingest_session_bundle_v1: manifest worlds must be array');
    exit(1);
  }

  final byId = <String, String>{};
  for (final worldEntry in worlds) {
    if (worldEntry is! Map) continue;
    final sessions = worldEntry['sessions'];
    if (sessions is! List) continue;
    for (final sessionEntry in sessions) {
      if (sessionEntry is! Map) continue;
      final id = sessionEntry['id'];
      final path = sessionEntry['path'];
      if (id is! String || path is! String) continue;
      byId[id] = path;
    }
  }
  return byId;
}

_ParsedBundle _parseBundle(String raw) {
  final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = text.split('\n');
  final sessions = <String, Map<String, String>>{};
  final errors = <String>[];

  String? currentSessionId;
  Map<String, String>? currentBlocks;
  String? currentBlockPath;
  StringBuffer? currentBuffer;

  void flushBlock() {
    if (currentBlocks == null ||
        currentBlockPath == null ||
        currentBuffer == null) {
      return;
    }
    if (currentBlocks!.containsKey(currentBlockPath!)) {
      errors.add(
        'session $currentSessionId: duplicate block $currentBlockPath',
      );
    } else {
      currentBlocks![currentBlockPath!] = currentBuffer.toString();
    }
    currentBlockPath = null;
    currentBuffer = null;
  }

  void flushSession() {
    flushBlock();
    if (currentSessionId == null || currentBlocks == null) return;
    if (sessions.containsKey(currentSessionId)) {
      errors.add('duplicate session block $currentSessionId');
    } else {
      sessions[currentSessionId!] = Map<String, String>.from(currentBlocks!);
    }
    currentSessionId = null;
    currentBlocks = null;
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    final sessionMatch = _kSessionHeader.firstMatch(trimmed);
    if (sessionMatch != null) {
      flushSession();
      currentSessionId = sessionMatch.group(1)!;
      currentBlocks = <String, String>{};
      continue;
    }

    final fileMatch = _kFileHeader.firstMatch(trimmed);
    if (fileMatch != null) {
      if (currentSessionId == null) {
        errors.add('file block before session header at line ${i + 1}');
        continue;
      }
      flushBlock();
      currentBlockPath = fileMatch.group(1)!;
      currentBuffer = StringBuffer();
      continue;
    }

    if (currentSessionId == null) {
      if (trimmed.isEmpty) continue;
      errors.add('content before first session header at line ${i + 1}');
      continue;
    }

    if (currentBlockPath == null || currentBuffer == null) {
      if (trimmed.isEmpty) continue;
      errors.add(
        'content before file block in session $currentSessionId at line ${i + 1}',
      );
      continue;
    }

    currentBuffer!.writeln(line);
  }

  flushSession();
  return _ParsedBundle(sessions: sessions, errors: errors);
}

String _normalizeBlockContent(String input) {
  final text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = text.split('\n');
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  final cleaned = lines
      .map((line) => line.replaceFirst(RegExp(r'[ \t]+$'), ''))
      .toList(growable: false);
  final body = cleaned.join('\n');
  return body.isEmpty ? '\n' : '$body\n';
}

bool _isAscii(String value) {
  for (final unit in value.codeUnits) {
    if (unit < 32 || unit > 126) return false;
  }
  return true;
}

class _ParsedArgs {
  const _ParsedArgs({
    this.inputPath,
    this.onlySessionId,
    this.dryRun = false,
    this.error,
  });

  final String? inputPath;
  final String? onlySessionId;
  final bool dryRun;
  final String? error;
}

class _ParsedBundle {
  const _ParsedBundle({required this.sessions, required this.errors});

  final Map<String, Map<String, String>> sessions;
  final List<String> errors;
}

class _PlannedWrite {
  const _PlannedWrite({
    required this.sessionId,
    required this.relativePath,
    required this.content,
  });

  final String sessionId;
  final String relativePath;
  final String content;
}
