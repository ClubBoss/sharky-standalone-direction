import 'dart:convert';
import 'dart:io';

const List<String> _kRequiredBlockPaths = <String>[
  'session.md',
  'notes.md',
  'drills/index.md',
];
const List<String> _kRequiredSessionSubheadings = <String>[
  '## Objective',
  '## Scenario',
  '## Decision',
  '## Explanation',
];
final RegExp _kSessionHeader = RegExp(r'^=== SESSION ([A-Za-z0-9._-]+) ===$');
final RegExp _kFileHeader = RegExp(r'^--- ([A-Za-z0-9._/-]+) ---$');

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('lint_session_bundle_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final inputFile = File(parsed.inputPath!);
  if (!inputFile.existsSync()) {
    stderr.writeln(
      'lint_session_bundle_v1: input file not found: ${parsed.inputPath}',
    );
    exitCode = 1;
    return;
  }

  final manifestIds = _loadManifestIds();
  final parsedBundle = _parseBundle(inputFile.readAsStringSync());
  final errors = <String>[...parsedBundle.errors];

  final allIds = parsedBundle.sessions.keys.toList()..sort();
  final selectedIds = <String>[];
  for (final id in allIds) {
    if (parsed.onlySessionId != null && id != parsed.onlySessionId) continue;
    selectedIds.add(id);
  }
  if (parsed.onlySessionId != null &&
      !parsedBundle.sessions.containsKey(parsed.onlySessionId)) {
    errors.add('session ${parsed.onlySessionId} not found in bundle');
  }

  final summaries = <String>[];
  for (final id in selectedIds) {
    if (!manifestIds.contains(id)) {
      errors.add('unknown session id: $id');
      continue;
    }
    final blocks = parsedBundle.sessions[id]!;
    final unknownBlocks =
        blocks.keys.where((k) => !_kRequiredBlockPaths.contains(k)).toList()
          ..sort();
    for (final key in unknownBlocks) {
      errors.add('session $id: unknown block $key');
    }
    for (final req in _kRequiredBlockPaths) {
      if (!blocks.containsKey(req)) {
        errors.add('session $id: missing block $req');
      }
    }
    if (parsed.semantic && blocks.containsKey('session.md')) {
      errors.addAll(
        _validateSessionStructureFromBundle(id, blocks['session.md']!),
      );
    }
    final byteParts = <String>[];
    for (final req in _kRequiredBlockPaths) {
      final content = blocks[req];
      if (content == null) continue;
      final normalized = _normalizeBlockContent(content);
      byteParts.add('$req=${utf8.encode(normalized).length}');
    }
    summaries.add(
      'lint_session_bundle_v1: $id blocks=${blocks.length} ${byteParts.join(',')}',
    );
  }

  if (selectedIds.isEmpty) {
    errors.add('no sessions selected for lint');
  }

  if (errors.isNotEmpty) {
    final sortedErrors = errors.toList()..sort();
    for (final e in sortedErrors) {
      stderr.writeln('lint_session_bundle_v1: $e');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'lint_session_bundle_v1: sessions=${selectedIds.length} ids=${selectedIds.join(',')}',
  );
  summaries.sort();
  for (final line in summaries) {
    stdout.writeln(line);
  }
  stdout.writeln('lint_session_bundle_v1: OK');
}

_ParsedArgs _parseArgs(List<String> args) {
  String? inputPath;
  String? onlySessionId;
  var semantic = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--semantic':
        semantic = true;
        break;
      case '--in':
        if (i + 1 >= args.length)
          return const _ParsedArgs(error: 'missing value for --in');
        inputPath = args[++i];
        break;
      case '--only':
        if (i + 1 >= args.length)
          return const _ParsedArgs(error: 'missing value for --only');
        onlySessionId = args[++i];
        break;
      default:
        return _ParsedArgs(error: 'unknown argument: $arg');
    }
  }
  if (inputPath == null) return const _ParsedArgs(error: '--in is required');
  return _ParsedArgs(
    inputPath: inputPath,
    onlySessionId: onlySessionId,
    semantic: semantic,
  );
}

Set<String> _loadManifestIds() {
  final file = File('content/_meta/world_sessions_manifest_v1.json');
  if (!file.existsSync()) {
    stderr.writeln(
      'lint_session_bundle_v1: manifest not found: content/_meta/world_sessions_manifest_v1.json',
    );
    exit(1);
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('lint_session_bundle_v1: manifest root must be object');
    exit(1);
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    stderr.writeln('lint_session_bundle_v1: manifest worlds must be array');
    exit(1);
  }
  final ids = <String>{};
  for (final worldEntry in worlds) {
    if (worldEntry is! Map) continue;
    final sessions = worldEntry['sessions'];
    if (sessions is! List) continue;
    for (final session in sessions) {
      if (session is! Map) continue;
      final id = session['id'];
      if (id is String) ids.add(id);
    }
  }
  return ids;
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
        currentBuffer == null)
      return;
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
      .toList();
  final body = cleaned.join('\n');
  return body.isEmpty ? '\n' : '$body\n';
}

List<String> _validateSessionStructureFromBundle(
  String sessionId,
  String rawBlock,
) {
  final errors = <String>[];
  final normalized = rawBlock.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = normalized.split('\n');
  final expectedTitle = '# Session $sessionId';
  if (lines.isEmpty || lines.first != expectedTitle) {
    errors.add(
      'session $sessionId: session.md first line must be "$expectedTitle"',
    );
  }

  final headingLines = <String>[];
  for (final line in lines) {
    if (line.startsWith('#')) headingLines.add(line);
  }
  final requiredHeadings = <String>[
    expectedTitle,
    ..._kRequiredSessionSubheadings,
  ];
  final positions = <String, int>{};
  for (final heading in requiredHeadings) {
    final matches = <int>[];
    for (var i = 0; i < headingLines.length; i++) {
      if (headingLines[i] == heading) matches.add(i);
    }
    if (matches.isEmpty) {
      errors.add(
        'session $sessionId: session.md missing required heading $heading',
      );
      continue;
    }
    if (matches.length > 1) {
      errors.add(
        'session $sessionId: session.md duplicate required heading $heading',
      );
    }
    positions[heading] = matches.first;
  }
  var previous = -1;
  for (final heading in requiredHeadings) {
    final pos = positions[heading];
    if (pos == null) continue;
    if (pos <= previous) {
      errors.add(
        'session $sessionId: session.md required headings out of order (expected ${requiredHeadings.join(' -> ')})',
      );
      break;
    }
    previous = pos;
  }
  return errors;
}

class _ParsedArgs {
  const _ParsedArgs({
    this.inputPath,
    this.onlySessionId,
    this.semantic = false,
    this.error,
  });

  final String? inputPath;
  final String? onlySessionId;
  final bool semantic;
  final String? error;
}

class _ParsedBundle {
  const _ParsedBundle({required this.sessions, required this.errors});

  final Map<String, Map<String, String>> sessions;
  final List<String> errors;
}
