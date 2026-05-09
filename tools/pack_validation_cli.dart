import 'dart:convert';
import 'dart:io';

/// Automated pack validation CLI.
///
/// Scans content packs for required assets and reports validation results.
Future<void> main(List<String> args) async {
  final contentRoot = Directory('content');
  if (!await contentRoot.exists()) {
    stderr.writeln('No content directory found.');
    exit(1);
  }

  final modules = await _discoverModules(contentRoot);
  if (modules.isEmpty) {
    stdout.writeln('No packs discovered. Nothing to validate.');
    _emitTelemetry(total: 0, passed: 0, failed: 0, skipped: 0);
    return;
  }

  final rows = <_ValidationRow>[];
  var passed = 0;
  var failed = 0;
  var skipped = 0;

  for (final module in modules) {
    final result = await _validateModule(module);
    rows.add(result);
    switch (result.status) {
      case _Status.pass:
        passed += 1;
        break;
      case _Status.fail:
        failed += 1;
        break;
      case _Status.skip:
        skipped += 1;
        break;
    }
  }

  _printTable(rows);
  stdout.writeln('Totals: passed=$passed failed=$failed skipped=$skipped');

  _emitTelemetry(
    total: rows.length,
    passed: passed,
    failed: failed,
    skipped: skipped,
  );

  if (failed > 0) {
    exitCode = 1;
  }
}

Future<List<Directory>> _discoverModules(Directory root) async {
  final modules = <Directory>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is Directory && entity.path.endsWith('/v1')) {
      modules.add(entity);
    }
  }
  modules.sort((a, b) => a.path.compareTo(b.path));
  return modules;
}

Future<_ValidationRow> _validateModule(Directory module) async {
  final relativePath = module.path;
  if (_shouldSkipModule(relativePath)) {
    return _ValidationRow(relativePath, _Status.skip, 'skipped (reference)');
  }
  final buffer = StringBuffer();
  final requiredFiles = <String>['theory.md', 'drills.jsonl', 'demos.jsonl'];
  var status = _Status.pass;

  for (final name in requiredFiles) {
    final file = File('${module.path}/$name');
    if (!await file.exists()) {
      status = _Status.fail;
      buffer.writeln('missing $name');
    }
  }

  final metadataOk =
      await File('${module.path}/labels.txt').exists() ||
      await File('${module.path}/spec.yml').exists();
  if (!metadataOk) {
    status = _Status.fail;
    buffer.writeln('missing labels.txt or spec.yml');
  }

  final allowlist = File('${module.path}/allowlist.txt');
  if (!await allowlist.exists()) {
    buffer.writeln('missing allowlist.txt (optional)');
  }

  final drills = File('${module.path}/drills.jsonl');
  if (await drills.exists()) {
    final note = await _validateJsonl(drills);
    if (note != null) {
      status = _Status.fail;
      buffer.writeln('drills.jsonl: $note');
    }
  }

  final demos = File('${module.path}/demos.jsonl');
  if (await demos.exists()) {
    final note = await _validateJsonl(demos);
    if (note != null) {
      status = _Status.fail;
      buffer.writeln('demos.jsonl: $note');
    }
  }

  final theory = File('${module.path}/theory.md');
  if (await theory.exists()) {
    final asciiOk = await _isAsciiFile(theory);
    if (!asciiOk) {
      status = _Status.fail;
      buffer.writeln('theory.md contains non-ASCII characters');
    }
  }

  final notes = buffer.isEmpty
      ? 'ok'
      : buffer.toString().trim().replaceAll('\n', '; ');
  return _ValidationRow(relativePath, status, notes);
}

bool _shouldSkipModule(String path) {
  return path.contains('/_reference/') || path.contains('core_final/');
}

Future<String?> _validateJsonl(File file) async {
  try {
    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty) {
        continue;
      }
      if (!_isAscii(raw)) {
        return 'line ${i + 1} non-ASCII content';
      }
      try {
        jsonDecode(raw);
      } catch (error) {
        return 'line ${i + 1} invalid JSON (${error.runtimeType})';
      }
    }
  } catch (error) {
    return 'IO error: $error';
  }
  return null;
}

Future<bool> _isAsciiFile(File file) async {
  final stream = file.openRead();
  await for (final chunk in stream) {
    for (final byte in chunk) {
      if (byte > 0x7F) {
        await stream.drain<void>();
        return false;
      }
    }
  }
  return true;
}

bool _isAscii(String text) {
  for (final codeUnit in text.codeUnits) {
    if (codeUnit > 0x7F) {
      return false;
    }
  }
  return true;
}

void _printTable(List<_ValidationRow> rows) {
  if (rows.isEmpty) {
    stdout.writeln('No modules evaluated.');
    return;
  }
  const headerModule = 'Module';
  const headerStatus = 'Status';
  const headerNotes = 'Notes';

  final moduleWidth = rows
      .map((row) => row.module.length)
      .followedBy(const [headerModule.length])
      .reduce((a, b) => a > b ? a : b);
  const statusWidth = 8;

  final line =
      '+-${'-' * moduleWidth}-+-${'-' * statusWidth}-+-----------------------------';
  stdout.writeln(line);
  stdout.writeln(
    '| ${headerModule.padRight(moduleWidth)} | '
    '${headerStatus.padRight(statusWidth)} | $headerNotes',
  );
  stdout.writeln(line);

  for (final row in rows) {
    stdout.writeln(
      '| ${row.module.padRight(moduleWidth)} | '
      '${row.status.name.padRight(statusWidth)} | ${row.notes}',
    );
  }
  stdout.writeln(line);
}

void _emitTelemetry({
  required int total,
  required int passed,
  required int failed,
  required int skipped,
}) {
  final event = jsonEncode({
    'event': 'pack_validation_completed',
    'total': total,
    'passed': passed,
    'failed': failed,
    'skipped': skipped,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });
  stdout.writeln(event);
}

class _ValidationRow {
  const _ValidationRow(this.module, this.status, this.notes);

  final String module;
  final _Status status;
  final String notes;
}

enum _Status { pass, fail, skip }
