import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _catalogPath = '$_reportsDir/localization_catalog.json';
const String _summaryTextPath = '$_reportsDir/glossary_summary.txt';
const String _summaryJsonPath = '$_reportsDir/glossary_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _glossarySource = '_shared/metrics_glossary/v1/fv_buckets.md';

const double _maxMissingShare = 0.05;

Future<void> main(List<String> args) async {
  final core = LocalizationGlossaryCore();
  final ok = await core.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LocalizationGlossaryCore {
  Future<bool> run() async {
    final scan = await _scanUiStrings();
    final glossary = await _loadGlossary();

    final missingRatio = scan.missingCount == 0 && scan.totalStrings == 0
        ? 0
        : scan.missingCount / scan.totalStrings;
    final glossaryOk = glossary.isNotEmpty;
    final pass = missingRatio <= _maxMissingShare && glossaryOk;

    final summaryText = _buildTextSummary(scan, glossary, pass);
    final summaryJson = _buildJsonSummary(scan, glossary, pass);

    await _withReportsWritable(() async {
      await File(
        _catalogPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(scan.catalog));
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(scan, glossary, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Localization Glossary Core failed: missing ratio '
        '${(missingRatio * 100).toStringAsFixed(2)}%, '
        'glossary entries=${glossary.length}',
      );
    }
    return pass;
  }

  Future<_ScanResult> _scanUiStrings() async {
    final dir = Directory('lib/ui');
    if (!await dir.exists()) {
      return const _ScanResult(
        catalog: {},
        totalStrings: 0,
        missingCount: 0,
        localizedCount: 0,
      );
    }
    final catalog = <String, String>{};
    var autoIndex = 0;
    var localizedCount = 0;
    var missingCount = 0;
    var totalStrings = 0;

    final files = await dir
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    final lPattern = RegExp(
      r"_l\(\s*[^,]+,\s*'([^']+)'\s*,\s*'([^']+)'",
      multiLine: true,
    );
    final textPattern = RegExp(
      r'''(?:Text|tooltip|label|title|message)\s*:\s*['"]([^'" \n]{3,})['"]''',
      multiLine: true,
    );
    final constTextPattern = RegExp(
      r'''Text\(\s*['"]([^'" \n]{3,})['"]''',
      multiLine: true,
    );

    for (final file in files) {
      final contents = await file.readAsString();

      for (final match in lPattern.allMatches(contents)) {
        final key = match.group(1)!;
        final value = match.group(2)!;
        localizedCount++;
        totalStrings++;
        catalog.putIfAbsent(key, () => value);
      }

      void capturePlainMatches(Iterable<RegExpMatch> matches) {
        for (final match in matches) {
          final value = match.group(1)?.trim();
          if (value == null || value.length < 3) continue;
          totalStrings++;
          missingCount++;
          final key = 'auto_${++autoIndex}';
          catalog.putIfAbsent(key, () => value);
        }
      }

      capturePlainMatches(textPattern.allMatches(contents));
      capturePlainMatches(constTextPattern.allMatches(contents));
    }

    return _ScanResult(
      catalog: catalog,
      totalStrings: totalStrings,
      missingCount: missingCount,
      localizedCount: localizedCount,
    );
  }

  Future<Map<String, String>> _loadGlossary() async {
    final file = File(_glossarySource);
    if (!await file.exists()) {
      return const {};
    }
    final entries = <String, String>{};
    final lines = await file.readAsLines();
    for (final raw in lines) {
      final line = raw.trim();
      if (!line.startsWith('- ')) continue;
      final body = line.substring(2).trim();
      final parts = body.split(':');
      if (parts.length < 2) continue;
      final term = parts.first.trim();
      final def = parts.sublist(1).join(':').trim();
      if (term.isEmpty || def.isEmpty) continue;
      entries[term] = def;
    }
    return entries;
  }

  String _buildTextSummary(
    _ScanResult scan,
    Map<String, String> glossary,
    bool pass,
  ) {
    final missingPct = scan.totalStrings == 0
        ? 0
        : (scan.missingCount / scan.totalStrings) * 100;
    final buffer = StringBuffer()
      ..writeln('LOCALIZATION GLOSSARY SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Catalog entries: ${scan.catalog.length}')
      ..writeln('Localized strings: ${scan.localizedCount}')
      ..writeln('Missing strings: ${scan.missingCount}')
      ..writeln('Missing ratio: ${missingPct.toStringAsFixed(2)}%')
      ..writeln('Glossary terms: ${glossary.length}')
      ..writeln(
        'Threshold: missing <= ${(_maxMissingShare * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    _ScanResult scan,
    Map<String, String> glossary,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'catalog_entries': scan.catalog.length,
      'localized_count': scan.localizedCount,
      'missing_count': scan.missingCount,
      'total_strings': scan.totalStrings,
      'missing_ratio': scan.totalStrings == 0
          ? 0
          : scan.missingCount / scan.totalStrings,
      'glossary_terms': glossary.length,
      'thresholds': {'max_missing_ratio': _maxMissingShare},
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    _ScanResult scan,
    Map<String, String> glossary,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'localization_glossary_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'catalog_entries': scan.catalog.length,
      'missing_ratio': scan.totalStrings == 0
          ? 0
          : scan.missingCount / scan.totalStrings,
      'glossary_terms': glossary.length,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _ScanResult {
  const _ScanResult({
    required this.catalog,
    required this.totalStrings,
    required this.missingCount,
    required this.localizedCount,
  });

  final Map<String, String> catalog;
  final int totalStrings;
  final int missingCount;
  final int localizedCount;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
