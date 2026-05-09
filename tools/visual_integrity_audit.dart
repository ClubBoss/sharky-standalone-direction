import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_core.dart';

Future<void> main(List<String> args) async {
  final auditor = _VisualIntegrityAuditor();
  final report = await auditor.run();
  report.printTable();
  await report.writeReport('release/_reports/visual_integrity_audit.txt');
  report.emitTelemetry();
  if (!report.isClean) {
    exit(1);
  }
}

class _VisualIntegrityAuditor {
  Future<_AuditReport> run() async {
    final assetIssues = <String>[];
    final i18nIssues = <String>[];
    final i18nWarnings = <String>[];
    final telemetryIssues = <String>[];
    final telemetryEvents = _loadTelemetryEvents();
    final referencedEvents = <String>{};
    final localization = LocalizationCore.instance;
    final fallbackStore = _I18nFallbackStore(kLocalizationFallbackPath);

    for (final file in _targetFiles()) {
      final lines = await file.readAsLines();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final match in _assetPattern.allMatches(line)) {
          final assetPath = match.group(1)!;
          if (!_looksLikeLocalAsset(assetPath)) {
            continue;
          }
          final assetFile = File(assetPath);
          if (!assetFile.existsSync()) {
            assetIssues.add('${file.path}:${i + 1} missing asset "$assetPath"');
          }
        }

        for (final match in _textLiteralPattern.allMatches(line)) {
          final literal = match.group(1)!;
          if (!_containsLetters(literal)) {
            continue;
          }
          final hasTranslation = localization.hasKey(literal);
          final asciiOk = _isAscii(literal);
          if (!asciiOk) {
            i18nIssues.add('${file.path}:${i + 1} non-ASCII Text("$literal")');
          }
          if (hasTranslation) {
            continue;
          }
          if (fallbackStore.contains(literal)) {
            i18nWarnings.add(
              '${file.path}:${i + 1} Text("$literal") covered by fallback list',
            );
            continue;
          }
          i18nIssues.add(
            '${file.path}:${i + 1} direct Text("$literal") without localization',
          );
          fallbackStore.record(literal);
        }
      }

      final content = lines.join('\n');
      for (final match in _telemetryPattern.allMatches(content)) {
        referencedEvents.add(match.group(1)!);
      }
    }

    for (final event in referencedEvents) {
      if (!telemetryEvents.contains(event)) {
        telemetryIssues.add('Event "$event" missing from TELEMETRY_EVENTS.md');
      }
    }

    fallbackStore.persist();

    return _AuditReport(
      assetIssues: assetIssues,
      i18nIssues: i18nIssues,
      i18nWarnings: i18nWarnings,
      telemetryIssues: telemetryIssues,
    );
  }

  Iterable<File> _targetFiles() sync* {
    for (final dir in ['lib/ui_v2', 'lib/ui_v3']) {
      final root = Directory(dir);
      if (!root.existsSync()) {
        continue;
      }
      for (final entity in root.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          yield entity;
        }
      }
    }
  }

  Set<String> _loadTelemetryEvents() {
    final doc = File('TELEMETRY_EVENTS.md');
    if (!doc.existsSync()) {
      return <String>{};
    }
    final events = <String>{};
    for (final line in doc.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ')) {
        final name = trimmed.substring(2).trim();
        if (name.isNotEmpty) {
          events.add(name);
        }
      }
    }
    return events;
  }

  bool _looksLikeLocalAsset(String value) {
    if (value.startsWith('http')) return false;
    if (value.startsWith('package:')) return false;
    return value.contains('assets/');
  }

  bool _containsLetters(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value);
  }

  bool _isAscii(String value) {
    return value.codeUnits.every((code) => code <= 0x7F);
  }
}

class _AuditReport {
  _AuditReport({
    required this.assetIssues,
    required this.i18nIssues,
    required this.i18nWarnings,
    required this.telemetryIssues,
  });

  final List<String> assetIssues;
  final List<String> i18nIssues;
  final List<String> i18nWarnings;
  final List<String> telemetryIssues;

  bool get isClean =>
      assetIssues.isEmpty && i18nIssues.isEmpty && telemetryIssues.isEmpty;

  void printTable() {
    final i18nCombined = <String>[
      ...i18nWarnings.map((warn) => '[warn] $warn'),
      ...i18nIssues,
    ];
    final data = <String, List<String>>{
      'Assets': assetIssues,
      'i18n': i18nCombined,
      'Telemetry': telemetryIssues,
    };
    final summaryLine =
        'asset_missing=${assetIssues.length} | i18n_missing=${i18nIssues.length} | i18n_warn=${i18nWarnings.length} | telemetry_mismatch=${telemetryIssues.length}';
    _asciiTable(data, summaryLine);
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': 'visual_integrity_audit_completed',
      'asset_missing': assetIssues.length,
      'i18n_missing': i18nIssues.length,
      'telemetry_mismatch': telemetryIssues.length,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    stdout.writeln(jsonEncode(payload));
  }

  void _asciiTable(Map<String, List<String>> data, String summaryLine) {
    final rows = <List<String>>[];
    for (final entry in data.entries) {
      final category = entry.key;
      final issues = entry.value;
      if (issues.isEmpty) {
        rows.add([category, 'OK']);
      } else {
        for (var i = 0; i < issues.length; i++) {
          final label = i == 0 ? category : '';
          rows.add([label, issues[i]]);
        }
      }
    }
    rows.add(['Summary', summaryLine]);

    final colWidths = <int>[0, 0];
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        colWidths[i] = row[i].length > colWidths[i]
            ? row[i].length
            : colWidths[i];
      }
    }
    final border = '+-${'-' * colWidths[0]}-+-${'-' * colWidths[1]}-+';
    stdout.writeln(border);
    stdout.writeln(
      '| ${'Category'.padRight(colWidths[0])} | '
      '${'Details'.padRight(colWidths[1])} |',
    );
    stdout.writeln(border);
    for (final row in rows) {
      stdout.writeln(
        '| ${row[0].padRight(colWidths[0])} | '
        '${row[1].padRight(colWidths[1])} |',
      );
    }
    stdout.writeln(border);
  }

  Future<void> writeReport(String path) async {
    final buffer = StringBuffer()
      ..writeln('Visual Integrity Audit')
      ..writeln('Assets: ${assetIssues.length}')
      ..writeln('i18n warnings: ${i18nWarnings.length}')
      ..writeln('i18n issues: ${i18nIssues.length}')
      ..writeln('Telemetry issues: ${telemetryIssues.length}')
      ..writeln('Status: ${isClean ? 'PASS' : 'FAIL'}');
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
  }
}

final RegExp _assetPattern = RegExp(r'''["']([^"']+\.(?:png|svg|ttf))["']''');
final RegExp _textLiteralPattern = RegExp(r'''Text\(\s*['"]([^'"]+)['"]''');
final RegExp _telemetryPattern = RegExp(
  r'''["']event["']\s*:\s*["']([a-z0-9_]+)["']''',
);

class _I18nFallbackStore {
  _I18nFallbackStore(this.path) {
    _load();
  }

  final String path;
  final Map<String, String> _existing = <String, String>{};
  final Map<String, String> _pending = <String, String>{};

  bool contains(String key) {
    return _existing.containsKey(key) || _pending.containsKey(key);
  }

  void record(String key) {
    if (contains(key)) {
      return;
    }
    _pending[key] = key;
  }

  void persist() {
    if (_pending.isEmpty) {
      return;
    }
    final file = File(path);
    file.parent.createSync(recursive: true);
    final merged = {..._existing, ..._pending};
    final encoder = const JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(merged));
    _existing
      ..clear()
      ..addAll(merged);
    _pending.clear();
  }

  void _load() {
    final file = File(path);
    if (!file.existsSync()) {
      return;
    }
    try {
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        decoded.forEach((key, value) {
          if (value is String) {
            _existing[key] = value;
          }
        });
      }
    } catch (_) {
      // Ignore malformed fallback file.
    }
  }
}
