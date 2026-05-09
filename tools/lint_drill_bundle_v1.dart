import 'dart:convert';
import 'dart:io';

import 'world_intents_ssot_v1.dart';
import 'why_v1_ssot_v1.dart';

final RegExp _kSessionHeader = RegExp(r'^=== SESSION ([A-Za-z0-9._-]+) ===$');
final RegExp _kFileHeader = RegExp(r'^--- ([A-Za-z0-9._./-]+) ---$');
final RegExp _kDrillIndexLine = RegExp(r'^- ([a-z0-9_]+):');
final RegExp _kDrillBlockPath = RegExp(r'^drills/d\.([a-z0-9_]+)\.json$');

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('lint_drill_bundle_v1: ${parsed.error}');
    exitCode = 64;
    return;
  }

  final input = File(parsed.inputPath!);
  if (!input.existsSync()) {
    stderr.writeln(
      'lint_drill_bundle_v1: input file not found: ${parsed.inputPath}',
    );
    exitCode = 1;
    return;
  }

  final manifestIds = _loadSessionIds();
  final bundle = _parseBundle(input.readAsStringSync());
  final errors = <String>[...bundle.errors];

  final selectedIds =
      bundle.sessions.keys
          .where(
            (id) => parsed.onlySessionId == null || id == parsed.onlySessionId,
          )
          .toList()
        ..sort();
  if (parsed.onlySessionId != null &&
      !bundle.sessions.containsKey(parsed.onlySessionId)) {
    errors.add('session ${parsed.onlySessionId} not found in bundle');
  }

  final details = <String>[];
  for (final sessionId in selectedIds) {
    if (!manifestIds.contains(sessionId)) {
      errors.add('unknown session id: $sessionId');
      continue;
    }
    final blocks = bundle.sessions[sessionId]!;
    if (!blocks.containsKey('drills/index.md')) {
      errors.add('session $sessionId: missing block drills/index.md');
      continue;
    }
    final drillIds = _parseDrillIdsFromIndex(blocks['drills/index.md']!);
    final seen = <String>{};
    final dups = <String>{};
    for (final id in drillIds) {
      if (!seen.add(id)) dups.add(id);
    }
    for (final dup in (dups.toList()..sort())) {
      errors.add(
        'session $sessionId: duplicate drill id in drills/index.md: $dup',
      );
    }

    final drillBlockIds = <String>[];
    final unknownBlocks = <String>[];
    for (final key in blocks.keys) {
      if (key == 'drills/index.md') continue;
      final m = _kDrillBlockPath.firstMatch(key);
      if (m == null) {
        unknownBlocks.add(key);
        continue;
      }
      drillBlockIds.add(m.group(1)!);
    }
    unknownBlocks.sort();
    for (final k in unknownBlocks) {
      errors.add('session $sessionId: unknown block $k');
    }

    final drillBlockSet = drillBlockIds.toSet();
    final sortedIndexIds = seen.toList()..sort();
    var hasValidWhyV1InSession = false;
    for (final id in sortedIndexIds) {
      if (!drillBlockSet.contains(id)) {
        errors.add('session $sessionId: missing block drills/d.$id.json');
        continue;
      }
      hasValidWhyV1InSession =
          hasValidWhyV1InSession ||
          _drillJsonContentHasValidWhyV1(blocks['drills/d.$id.json']!);
      errors.addAll(
        _validateDrillJsonBlock(
          sessionId: sessionId,
          drillId: id,
          content: blocks['drills/d.$id.json']!,
        ),
      );
    }
    final extraBlockIds =
        drillBlockIds.where((id) => !seen.contains(id)).toList()..sort();
    for (final id in extraBlockIds) {
      errors.add(
        'session $sessionId: drill block not listed in drills/index.md: $id',
      );
    }
    if (kWhyV1StagedSessionsV1.contains(sessionId) && !hasValidWhyV1InSession) {
      errors.add('session $sessionId: missing_why_v1_for_session');
    }

    final bytesByBlock = <String>[];
    final sortedBlockKeys = blocks.keys.toList()..sort();
    for (final key in sortedBlockKeys) {
      final normalized = _normalize(blocks[key]!);
      bytesByBlock.add('$key=${utf8.encode(normalized).length}');
    }
    details.add(
      'lint_drill_bundle_v1: $sessionId blocks=${blocks.length} drills=${seen.length} ${bytesByBlock.join(',')}',
    );
  }

  if (selectedIds.isEmpty) {
    errors.add('no sessions selected for lint');
  }

  if (errors.isNotEmpty) {
    for (final e in (errors.toList()..sort())) {
      stderr.writeln('lint_drill_bundle_v1: $e');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'lint_drill_bundle_v1: sessions=${selectedIds.length} ids=${selectedIds.join(',')}',
  );
  details.sort();
  for (final d in details) {
    stdout.writeln(d);
  }
  stdout.writeln('lint_drill_bundle_v1: OK');
}

List<String> _validateDrillJsonBlock({
  required String sessionId,
  required String drillId,
  required String content,
}) {
  final errors = <String>[];
  Object? decoded;
  try {
    decoded = jsonDecode(content);
  } catch (_) {
    return <String>[
      'session $sessionId: invalid JSON in drills/d.$drillId.json',
    ];
  }
  if (decoded is! Map<String, dynamic>) {
    return <String>[
      'session $sessionId: drill JSON root must be object in drills/d.$drillId.json',
    ];
  }
  final id = decoded['id'];
  if (id is! String || id != drillId) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json id must match "$drillId"',
    );
  }
  final intentV1 = decoded['intent_v1'];
  if (intentV1 != null && (intentV1 is! String || !isValidIntentV1(intentV1))) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json intent_v1 must match [a-z0-9_]+ when present',
    );
  }
  final whyV1 = decoded['why_v1'];
  if (whyV1 != null && !isRuntimeValidWhyV1V1(whyV1)) {
    errors.add('session $sessionId: drills/d.$drillId.json invalid_why_v1');
  }
  errors.addAll(_validateIntentForSession(sessionId, drillId, intentV1));
  final kind = decoded['kind'];
  if (kind is! String) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json kind must be a string',
    );
    return errors;
  }
  final expected = decoded['expected'];
  if (expected is! Map<String, dynamic>) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json expected must be an object',
    );
    return errors;
  }
  switch (kind) {
    case 'seat_tap':
      final seatId = expected['seatId'];
      final role = expected['role'];
      if ((seatId is! String || seatId.isEmpty) &&
          (role is! String || role.isEmpty)) {
        errors.add(
          'session $sessionId: drills/d.$drillId.json seat_tap requires expected.seatId and/or expected.role',
        );
      }
      break;
    case 'action_choice':
      final actionId = expected['actionId'];
      if (actionId is! String || actionId.isEmpty) {
        errors.add(
          'session $sessionId: drills/d.$drillId.json action_choice requires expected.actionId',
        );
      }
      break;
    case 'board_tap':
      final boardSlot = expected['boardSlot'];
      if (boardSlot is! String || boardSlot.isEmpty) {
        errors.add(
          'session $sessionId: drills/d.$drillId.json board_tap requires expected.boardSlot',
        );
      }
      break;
    case 'hole_cards_tap':
      final cardSlot = expected['cardSlot'];
      if (cardSlot is! String || (cardSlot != 'p0' && cardSlot != 'p1')) {
        errors.add(
          'session $sessionId: drills/d.$drillId.json hole_cards_tap requires expected.cardSlot (p0|p1)',
        );
      }
      final cardId = expected['cardId'];
      if (cardId != null &&
          (cardId is! String || !_kCardIdV1Pattern.hasMatch(cardId))) {
        errors.add(
          'session $sessionId: drills/d.$drillId.json hole_cards_tap expected.cardId must match [AKQJT98765432][shdc]',
        );
      }
      break;
    default:
      errors.add(
        'session $sessionId: drills/d.$drillId.json unsupported drill kind $kind',
      );
      break;
  }
  return errors;
}

final RegExp _kCardIdV1Pattern = RegExp(r'^[AKQJT98765432][shdc]$');

List<String> _validateIntentForSession(
  String sessionId,
  String drillId,
  Object? intentV1,
) {
  final errors = <String>[];
  final world = worldIndexFromSessionId(sessionId);
  if (world == null) return errors;
  if (!requiresIntentV1ForSessionId(sessionId)) return errors;
  if (intentV1 is! String || intentV1.isEmpty) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json world$world drills require intent_v1',
    );
    return errors;
  }
  final allowed = allowedIntentsV1ForSessionId(sessionId);
  if (allowed.isNotEmpty && !allowed.contains(intentV1)) {
    errors.add(
      'session $sessionId: drills/d.$drillId.json world$world intent_v1 not allowed: $intentV1',
    );
  }
  return errors;
}

bool _drillJsonContentHasValidWhyV1(String content) {
  Object? decoded;
  try {
    decoded = jsonDecode(content);
  } catch (_) {
    return false;
  }
  if (decoded is! Map<String, dynamic>) return false;
  return isRuntimeValidWhyV1V1(decoded['why_v1']);
}

class _Args {
  const _Args({this.inputPath, this.onlySessionId, this.error});
  final String? inputPath;
  final String? onlySessionId;
  final String? error;
}

_Args _parseArgs(List<String> args) {
  String? input;
  String? only;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--in':
        if (i + 1 >= args.length)
          return const _Args(error: 'missing value for --in');
        input = args[++i];
        break;
      case '--only':
        if (i + 1 >= args.length)
          return const _Args(error: 'missing value for --only');
        only = args[++i];
        break;
      default:
        return _Args(error: 'unknown argument: ${args[i]}');
    }
  }
  if (input == null) return const _Args(error: '--in is required');
  return _Args(inputPath: input, onlySessionId: only);
}

Set<String> _loadSessionIds() {
  final file = File('content/_meta/world_sessions_manifest_v1.json');
  if (!file.existsSync()) {
    stderr.writeln('lint_drill_bundle_v1: manifest not found: ${file.path}');
    exit(1);
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('lint_drill_bundle_v1: manifest root must be object');
    exit(1);
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    stderr.writeln('lint_drill_bundle_v1: manifest worlds must be array');
    exit(1);
  }
  final ids = <String>{};
  for (final w in worlds) {
    if (w is! Map) continue;
    final sessions = w['sessions'];
    if (sessions is! List) continue;
    for (final s in sessions) {
      if (s is! Map) continue;
      final id = s['id'];
      if (id is String) ids.add(id);
    }
  }
  return ids;
}

class _ParsedBundle {
  const _ParsedBundle({required this.sessions, required this.errors});
  final Map<String, Map<String, String>> sessions;
  final List<String> errors;
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
    final trimmed = lines[i].trim();
    final sm = _kSessionHeader.firstMatch(trimmed);
    if (sm != null) {
      flushSession();
      currentSessionId = sm.group(1)!;
      currentBlocks = <String, String>{};
      continue;
    }
    final fm = _kFileHeader.firstMatch(trimmed);
    if (fm != null) {
      if (currentSessionId == null) {
        errors.add('file block before session header at line ${i + 1}');
        continue;
      }
      flushBlock();
      currentBlockPath = fm.group(1)!;
      currentBuffer = StringBuffer();
      continue;
    }
    if (currentSessionId == null) {
      if (trimmed.isEmpty) continue;
      errors.add('content before first session header at line ${i + 1}');
      continue;
    }
    if (currentBuffer == null) {
      if (trimmed.isEmpty) continue;
      errors.add(
        'content before file block in session $currentSessionId at line ${i + 1}',
      );
      continue;
    }
    currentBuffer!.writeln(lines[i]);
  }
  flushSession();
  return _ParsedBundle(sessions: sessions, errors: errors);
}

List<String> _parseDrillIdsFromIndex(String content) {
  final ids = <String>[];
  final text = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    final m = _kDrillIndexLine.firstMatch(line);
    if (m == null) continue;
    ids.add(m.group(1)!);
  }
  return ids;
}

String _normalize(String input) {
  final text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = text.split('\n');
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  final cleaned = lines
      .map((l) => l.replaceFirst(RegExp(r'[ \t]+$'), ''))
      .toList();
  final body = cleaned.join('\n');
  return body.isEmpty ? '\n' : '$body\n';
}
