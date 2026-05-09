// filepath: tools/ultimate_repo_consolidator.dart
// Ultimate Repo Consolidator – reads audit + existing reports and produces
// a single verdict MD and fixlist. Always exits 0. ASCII-only.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final started = DateTime.now();
  final outDir = Directory('release/_reports');
  outDir.createSync(recursive: true);

  final c = _Consolidator();
  await c.run();

  await _writeText('release/_reports/ultimate_repo_verdict.md', c.verdictMd);
  await _writeText('release/_reports/ultimate_fixlist.txt', c.fixlistTxt);

  final durationMs = DateTime.now().difference(started).inMilliseconds;
  final telemetry = {
    'event': 'ultimate_repo_consolidation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'blocking_count': c.blockingCount,
    'warn_count': c.warnCount,
    'duration_ms': durationMs,
  };
  await File(
    'release/_reports/telemetry.jsonl',
  ).writeAsString('${jsonEncode(telemetry)}\n', mode: FileMode.append);

  stdout.writeln('Consolidation complete. Verdict: ${c.finalVerdict}');
}

class _Consolidator {
  int blockingCount = 0;
  int warnCount = 0;
  String finalVerdict = 'PASS';

  // Inputs
  Map<String, dynamic> ultimateMap = {};
  Map<String, dynamic> i18nAudit = {};
  List<String> visualViolations = [];
  List<List<String>> dupCsv = [];
  Map<String, dynamic> orphanIndex = {};

  // Existing optional reports
  final List<String> optionals = [
    'release/_reports/launch_readiness_summary.txt',
    'release/_reports/visual_integrity_audit.txt',
    'release/_reports/localization_content_audit.json',
    'release/_reports/ai_reliability_audit.txt',
    'release/_reports/duplication_matrix.csv',
    'release/_reports/telemetry_drift_report.txt',
  ];
  final Map<String, String> _optionalText = {};

  // Outputs
  late String verdictMd;
  late String fixlistTxt;

  Future<void> run() async {
    await _readAuditArtifacts();
    await _readOptionals();
    _computeVerdict();
    _buildOutputs();
  }

  Future<void> _readAuditArtifacts() async {
    ultimateMap = await _safeJson('release/_reports/ultimate_repo_map.json');
    i18nAudit = await _safeJson('release/_reports/i18n_audit.json');
    visualViolations = await _safeLines(
      'release/_reports/visual_token_violations.txt',
    );
    dupCsv = await _safeCsv('release/_reports/duplication_matrix.csv');
    orphanIndex = await _safeJson('release/_reports/orphan_index.json');
  }

  Future<void> _readOptionals() async {
    for (final p in optionals) {
      final f = File(p);
      if (!f.existsSync()) continue;
      try {
        _optionalText[p] = await f.readAsString();
      } catch (_) {}
    }
  }

  void _computeVerdict() {
    final jsonInvalid =
        (i18nAudit['json_invalid'] ?? 0) as int? ?? 0; // may be absent
    final missingI18n = (i18nAudit['missing_keys'] as Map?)?.length ?? 0;
    final visualCount = visualViolations.length;
    final dupCount = dupCsv.isEmpty ? 0 : dupCsv.length - 1;
    final orphanBackups = (orphanIndex['backups'] as List?)?.length ?? 0;

    // Blocking: visual violations or json invalid
    if (visualCount > 0) blockingCount += 1;
    if (jsonInvalid > 0) blockingCount += 1;

    // Warns
    warnCount += missingI18n > 0 ? 1 : 0;
    warnCount += dupCount > 0 ? 1 : 0;
    warnCount += orphanBackups > 0 ? 1 : 0;

    finalVerdict = blockingCount > 0
        ? 'FAIL'
        : (warnCount > 0 ? 'WARN' : 'PASS');
  }

  void _buildOutputs() {
    final b = StringBuffer();
    b.writeln('# Ultimate Repository Verdict');
    b.writeln('Generated: ${DateTime.now().toIso8601String()}');
    b.writeln('Final Verdict: $finalVerdict');
    b.writeln('');

    b.writeln('## 1. Architecture & Coverage');
    final roots = ultimateMap.keys
        .where((k) => !k.startsWith('__'))
        .take(20)
        .join(', ');
    b.writeln('- Top-level entries (sample): $roots');
    if (_optionalText.containsKey(
      'release/_reports/launch_readiness_summary.txt',
    )) {
      b.writeln('- Launch readiness: present');
    }
    b.writeln('');

    b.writeln('## 2. Duplicates & Orphans (KEEP/MERGE)');
    final dupCount = dupCsv.isEmpty ? 0 : dupCsv.length - 1;
    b.writeln('- Duplicate groups (rows): $dupCount');
    final orphans = (orphanIndex['backups'] as List?)?.length ?? 0;
    b.writeln('- Backup/orphan files: $orphans');
    b.writeln(
      '- Suggestion: MERGE duplicate hash clusters; KEEP newest file per group.',
    );
    b.writeln('');

    b.writeln('## 3. Telemetry (declared/used/drift)');
    final declared =
        (ultimateMap['__telemetry_declared__'] as List?)?.length ?? 0;
    final used = (ultimateMap['__telemetry_used__'] as List?)?.length ?? 0;
    final undeclared =
        (ultimateMap['__telemetry_undeclared__'] as List?)?.length ?? 0;
    b.writeln(
      '- Declared: $declared, Used: $used, Undeclared used: $undeclared',
    );
    if (_optionalText.containsKey(
      'release/_reports/telemetry_drift_report.txt',
    )) {
      b.writeln('- Telemetry drift report: present');
    }
    b.writeln('');

    b.writeln('## 4. i18n & Visual tokens');
    final missingLangs = (i18nAudit['missing_keys'] as Map?)?.length ?? 0;
    final visualCount = visualViolations.length;
    b.writeln('- Languages with missing keys: $missingLangs');
    b.writeln('- Visual token violations: $visualCount');
    b.writeln('');

    b.writeln('## 5. Packs & CI gates');
    b.writeln('- content/v1 JSON/JSONL validity accounted in audit');
    if (_optionalText.containsKey(
      'release/_reports/ai_reliability_audit.txt',
    )) {
      b.writeln('- AI reliability audit: present');
    }
    b.writeln('');

    b.writeln('## 6. Final Verdict');
    b.writeln('- Verdict: $finalVerdict');
    b.writeln('- Blocking count: $blockingCount');
    b.writeln('- Warning count: $warnCount');
    if (finalVerdict != 'PASS') {
      b.writeln('- Blocking list:');
      if (visualCount > 0) b.writeln('  * Visual token violations exist');
      final jsonInvalid = (i18nAudit['json_invalid'] ?? 0) as int? ?? 0;
      if (jsonInvalid > 0) b.writeln('  * JSON/JSONL invalid entries');
    }

    verdictMd = b.toString();

    final fix = StringBuffer();
    if (visualCount > 0) {
      fix.writeln(
        'Replace hardcoded Colors/Color/Duration with VisualThemeV3 tokens',
      );
    }
    if (((i18nAudit['missing_keys'] as Map?)?.isNotEmpty ?? false)) {
      fix.writeln('Add missing ARB keys for parity across locales');
    }
    if (dupCount > 0) {
      fix.writeln('Consolidate duplicate files by hash, KEEP newest');
    }
    if (orphans > 0) {
      fix.writeln(
        'Remove or quarantine backup/orphan files (*.bak, *_old, *_copy, *_backup)',
      );
    }
    if (fix.isEmpty) fix.writeln('No actions required.');
    fixlistTxt = fix.toString();
  }
}

Future<Map<String, dynamic>> _safeJson(String path) async {
  final f = File(path);
  if (!f.existsSync()) return {};
  try {
    return jsonDecode(await f.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

Future<List<String>> _safeLines(String path) async {
  final f = File(path);
  if (!f.existsSync()) return const <String>[];
  try {
    return (await f.readAsString())
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();
  } catch (_) {
    return const <String>[];
  }
}

Future<List<List<String>>> _safeCsv(String path) async {
  final f = File(path);
  if (!f.existsSync()) return const <List<String>>[];
  try {
    final lines = await f.readAsLines();
    return [
      for (final ln in lines)
        ln.split(',').map((e) => e.replaceAll('"', '')).toList(),
    ];
  } catch (_) {
    return const <List<String>>[];
  }
}

Future<void> _writeText(String path, String text) async {
  final f = File(path);
  f.parent.createSync(recursive: true);
  await f.writeAsString(text, flush: true);
}
