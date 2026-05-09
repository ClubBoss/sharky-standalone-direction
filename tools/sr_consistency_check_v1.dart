import 'dart:convert';
import 'dart:io';

void main() {
  final srPath = File('content/spaced_repetition/v1/sr_items.jsonl');
  final allowpath = File('content/spaced_repetition/v1/allowlist.txt');

  if (!srPath.existsSync() || !allowpath.existsSync()) {
    stderr.writeln('MISSING_SOURCE_FILES');
    exit(2);
  }

  final srLines = srPath.readAsLinesSync();
  final allowLines = allowpath.readAsLinesSync().where(
    (line) => line.trim().isNotEmpty,
  );

  final srCounts = <String, int>{};
  final allowCounts = <String, int>{};
  final asciiIssues = <String>[];

  for (final line in srLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final id = _extractId(trimmed);
    if (id == null) {
      stderr.writeln('BAD_JSON_LINE');
      exit(2);
    }
    if (!_isAscii(id)) {
      asciiIssues.add(id);
    }
    srCounts[id] = (srCounts[id] ?? 0) + 1;
  }

  for (final line in allowLines) {
    final id = line.trim();
    if (!_isAscii(id)) {
      asciiIssues.add(id);
    }
    if (id.isEmpty) {
      continue;
    }
    allowCounts[id] = (allowCounts[id] ?? 0) + 1;
  }

  final missing = <String>[];
  final extra = <String>[];
  final duplicates = <String>[];

  for (final id in allowCounts.keys) {
    if (!srCounts.containsKey(id)) {
      missing.add(id);
    }
  }

  for (final id in srCounts.keys) {
    if (!allowCounts.containsKey(id)) {
      extra.add(id);
    }
  }

  for (final entry in allowCounts.entries) {
    if (entry.value > 1) {
      duplicates.add(entry.key);
    }
  }

  var statusCode = 0;

  if (asciiIssues.isNotEmpty) {
    for (final id in asciiIssues) {
      stdout.writeln('NON_ASCII: $id');
    }
    statusCode = 2;
  }

  if (missing.isNotEmpty) {
    for (final id in missing) {
      stdout.writeln('MISSING: $id');
    }
    statusCode = 2;
  }

  if (extra.isNotEmpty) {
    for (final id in extra) {
      stdout.writeln('EXTRA: $id');
    }
    statusCode = 2;
  }

  if (duplicates.isNotEmpty) {
    for (final id in duplicates) {
      stdout.writeln('DUPLICATE: $id');
    }
    statusCode = 2;
  }

  if (statusCode == 0) {
    stdout.writeln('OK: all items aligned');
  }

  exit(statusCode);
}

String? _extractId(String line) {
  try {
    final decoded = jsonDecode(line) as Map<String, dynamic>;
    final id = decoded['id'];
    if (id is String) {
      return id;
    }
  } catch (_) {
    return null;
  }
  return null;
}

bool _isAscii(String value) => value.codeUnits.every((unit) => unit <= 127);
