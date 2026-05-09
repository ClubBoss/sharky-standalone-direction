import 'dart:convert';
import 'dart:io';

const String _contentRoot = 'content';
const String _previewRoot = 'content_adaptive_preview';
const String _schemaDir = 'content/_schemas';
const String _summaryPath =
    'release/_reports/content_schema_validator_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final validator = ContentSchemaValidator();
  final ok = await validator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContentSchemaValidator {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final schemas = await _loadSchemas();
    if (schemas.isEmpty) {
      throw StateError('No schemas found under $_schemaDir');
    }

    final modules = await _discoverModules();
    final audits = <_ModuleResult>[];
    for (final module in modules) {
      audits.add(await _validateModule(module, schemas));
    }

    final hasFailures = audits.any((result) => !result.isPass);
    await _withReportsWritable(() async {
      await _writeSummary(
        audits: audits,
        durationMs: stopwatch.elapsedMilliseconds,
        schemaCount: schemas.length,
      );
      await _emitTelemetry(
        audits: audits,
        durationMs: stopwatch.elapsedMilliseconds,
        schemaCount: schemas.length,
        verdict: hasFailures ? 'FAIL' : 'PASS',
      );
    });

    return !hasFailures;
  }

  Future<List<_SchemaDefinition>> _loadSchemas() async {
    final dir = Directory(_schemaDir);
    if (!await dir.exists()) {
      return const [];
    }
    final schemas = <_SchemaDefinition>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.schema.json')) continue;
      final content = json.decode(await entity.readAsString());
      if (content is! Map<String, dynamic>) continue;
      schemas.add(_SchemaDefinition.fromJson(content));
    }
    return schemas;
  }

  Future<List<_Module>> _discoverModules() async {
    final modules = <_Module>[];
    for (final root in [_contentRoot, _previewRoot]) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is Directory && entity.path.endsWith('/v1')) {
          modules.add(_Module(entity.path));
        }
      }
    }
    modules.sort((a, b) => a.path.compareTo(b.path));
    return modules;
  }

  Future<_ModuleResult> _validateModule(
    _Module module,
    List<_SchemaDefinition> schemas,
  ) async {
    final issues = <String>[];
    for (final schema in schemas) {
      final file = await module.resolveFile(schema.fileName);
      if (file == null) {
        continue;
      }
      final fileIssues = await schema.validate(file);
      if (fileIssues.isNotEmpty) {
        issues.addAll(fileIssues.map((msg) => '${schema.fileName}: $msg'));
      }
    }
    return _ModuleResult(module.path, issues);
  }
}

class _SchemaDefinition {
  _SchemaDefinition({
    required this.fileName,
    required this.type,
    required this.asciiOnly,
    required this.requiredFields,
  });

  final String fileName;
  final String type;
  final bool asciiOnly;
  final Map<String, String> requiredFields;

  static _SchemaDefinition fromJson(Map<String, dynamic> json) {
    return _SchemaDefinition(
      fileName: json['file']?.toString() ?? '',
      type: json['type']?.toString() ?? 'jsonl',
      asciiOnly: json['ascii_only'] == true,
      requiredFields:
          (json['required_fields'] as Map?)?.map(
            (key, value) => MapEntry('$key', '$value'),
          ) ??
          const {},
    );
  }

  Future<List<String>> validate(File file) async {
    if (type == 'jsonl') {
      return _validateJsonl(file);
    } else if (type == 'markdown') {
      return _validateMarkdown(file);
    }
    return ['Unknown schema type "$type"'];
  }

  Future<List<String>> _validateJsonl(File file) async {
    final issues = <String>[];
    final lines = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    var lineNumber = 0;
    await for (final line in lines) {
      lineNumber++;
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      Map<String, dynamic>? record;
      try {
        final decoded = json.decode(trimmed);
        if (decoded is Map<String, dynamic>) {
          record = decoded;
        }
      } catch (_) {
        issues.add('Line $lineNumber invalid JSON.');
        continue;
      }
      if (record == null) {
        issues.add('Line $lineNumber invalid JSON object.');
        continue;
      }
      for (final entry in requiredFields.entries) {
        final value = record[entry.key];
        if (value == null) {
          issues.add('Line $lineNumber missing field ${entry.key}.');
          continue;
        }
        if (!_matchesType(value, entry.value)) {
          issues.add(
            'Line $lineNumber field ${entry.key} expected ${entry.value}.',
          );
        }
      }
      if (asciiOnly && !_isAscii(trimmed)) {
        issues.add('Line $lineNumber contains non-ASCII characters.');
      }
    }
    if (asciiOnly && issues.isEmpty) {
      final full = await file.readAsBytes();
      if (!_isAsciiBytes(full)) {
        issues.add('File contains non-ASCII bytes.');
      }
    }
    return issues;
  }

  Future<List<String>> _validateMarkdown(File file) async {
    if (!asciiOnly) return const [];
    final bytes = await file.readAsBytes();
    if (_isAsciiBytes(bytes)) return const [];
    return const ['File contains non-ASCII characters.'];
  }

  bool _matchesType(dynamic value, String type) {
    switch (type) {
      case 'string':
        return value is String;
      case 'number':
        return value is num;
      case 'bool':
        return value is bool;
      case 'array':
        return value is List;
      case 'object':
        return value is Map;
      default:
        return true;
    }
  }

  bool _isAscii(String value) => value.codeUnits.every((c) => c <= 0x7F);

  bool _isAsciiBytes(List<int> bytes) => bytes.every((c) => c <= 0x7F);
}

class _Module {
  _Module(this.path);

  final String path;

  Future<File?> resolveFile(String fileName) async {
    final primary = File('$path/$fileName');
    if (await primary.exists()) return primary;
    final meta = File('$path/_meta/$fileName');
    if (await meta.exists()) return meta;
    return null;
  }
}

class _ModuleResult {
  _ModuleResult(this.path, this.issues);

  final String path;
  final List<String> issues;

  bool get isPass => issues.isEmpty;
}

Future<void> _writeSummary({
  required List<_ModuleResult> audits,
  required int durationMs,
  required int schemaCount,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTENT SCHEMA VALIDATOR SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Schemas loaded: $schemaCount')
    ..writeln('Modules checked: ${audits.length}')
    ..writeln();

  final failing = audits.where((audit) => !audit.isPass).toList();
  if (failing.isEmpty) {
    buffer.writeln('All modules conform to the restored schemas.');
  } else {
    buffer.writeln('Modules with schema violations:');
    for (final audit in failing) {
      buffer.writeln('- ${audit.path}');
      for (final issue in audit.issues) {
        buffer.writeln('  • $issue');
      }
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required List<_ModuleResult> audits,
  required int durationMs,
  required int schemaCount,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'content_schema_validator_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'verdict': verdict,
    'schemas': schemaCount,
    'modules_checked': audits.length,
    'violations': audits
        .where((audit) => !audit.isPass)
        .map((audit) => {'module': audit.path, 'issues': audit.issues})
        .toList(),
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
