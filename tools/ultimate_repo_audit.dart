// filepath: tools/ultimate_repo_audit.dart
// Ultimate Repo Audit (Stage Ω10 companion) – ASCII-only, pure Dart, no deps.
// Usage: dart run tools/ultimate_repo_audit.dart
// Outputs multiple reports to release/_reports and emits telemetry.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final started = DateTime.now();
  final outDir = Directory('release/_reports');
  outDir.createSync(recursive: true);

  final auditor = _Audit();
  await auditor.run();

  // Write artifacts
  await _writeText(
    'release/_reports/ultimate_repo_audit_summary.txt',
    auditor.summaryTable(),
  );
  await _writeJson('release/_reports/ultimate_repo_map.json', auditor.manifest);
  await _writeCsv('release/_reports/duplication_matrix.csv', auditor.dupCsv);
  await _writeJson('release/_reports/orphan_index.json', auditor.orphanIndex);
  await _writeJson('release/_reports/i18n_audit.json', auditor.i18nAudit);
  await _writeText(
    'release/_reports/visual_token_violations.txt',
    auditor.visualViolations.join('\n'),
  );

  final durationMs = DateTime.now().difference(started).inMilliseconds;
  final telemetry = {
    'event': 'ultimate_repo_audit_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'counts': auditor.counts(),
    'duration_ms': durationMs,
  };
  await File(
    'release/_reports/telemetry.jsonl',
  ).writeAsString('${jsonEncode(telemetry)}\n', mode: FileMode.append);

  final hardFails =
      (auditor.jsonInvalidCount > 0) ||
      (auditor.telemetryUndeclaredCount > 0) ||
      (auditor.visualViolations.isNotEmpty);
  if (hardFails) {
    // Non-zero exit on true blockers
    stderr.writeln('Audit completed with blockers. See summary.');
    exitCode = 2;
  } else {
    stdout.writeln('Audit completed successfully.');
  }
}

class _Audit {
  // Manifest dir->files
  final Map<String, List<String>> manifest = {};

  // Duplicate matrix rows: [hash,size,path]
  final List<List<String>> dupCsv = [
    ['hash', 'size', 'path'],
  ];

  // Orphan index detail
  final Map<String, dynamic> orphanIndex = {
    'backups': <String>[],
    'unmatched_tests': <String>[],
    'unused_assets': <String>[],
  };

  // i18n audit
  final Map<String, dynamic> i18nAudit = {
    'non_ascii_literals': <String>[],
    'missing_keys': <String, List<String>>{}, // lang->missing
    'total_keys_per_lang': <String, int>{},
  };

  // Visual violations lines
  final List<String> visualViolations = [];

  // Counters
  int jsonInvalidCount = 0;
  int telemetryUndeclaredCount = 0;

  // Internals
  final List<File> _allFiles = [];
  final Map<String, List<String>> _byName = {};
  final Map<String, List<String>> _byPrefix = {
    'booster_': [],
    'theory_': [],
    'smart_': [],
    'adaptive_': [],
    'goal_': [],
  };

  Future<void> run() async {
    await _crawl();
    _buildStructure();
    await _scanDuplicates();
    await _scanOrphans();
    await _scanTelemetry();
    await _scanI18n();
    await _scanVisualTokens();
    await _scanPacks();
  }

  Map<String, Object> counts() => {
    'files': _allFiles.length,
    'duplicate_candidates': dupCsv.length - 1,
    'orphans_backups': (orphanIndex['backups'] as List).length,
    'orphans_unmatched_tests': (orphanIndex['unmatched_tests'] as List).length,
    'orphans_unused_assets': (orphanIndex['unused_assets'] as List).length,
    'i18n_non_ascii': (i18nAudit['non_ascii_literals'] as List).length,
    'i18n_missing_langs': (i18nAudit['missing_keys'] as Map).length,
    'visual_violations': visualViolations.length,
    'json_invalid': jsonInvalidCount,
    'telemetry_undeclared': telemetryUndeclaredCount,
  };

  String summaryTable() {
    String row(String k, Object v) =>
        '| ${k.padRight(32)} | ${v.toString().padLeft(8)} |';
    final lines = <String>[
      'ULTIMATE REPO AUDIT SUMMARY',
      '-----------------------------------------------',
      row('Total files scanned', _allFiles.length),
      row('Duplicate rows (csv)', dupCsv.length - 1),
      row('Orphans: backups', (orphanIndex['backups'] as List).length),
      row(
        'Orphans: unmatched tests',
        (orphanIndex['unmatched_tests'] as List).length,
      ),
      row(
        'Orphans: unused assets',
        (orphanIndex['unused_assets'] as List).length,
      ),
      row(
        'i18n: non-ascii literals',
        (i18nAudit['non_ascii_literals'] as List).length,
      ),
      row(
        'i18n: langs with missing',
        (i18nAudit['missing_keys'] as Map).length,
      ),
      row('Visual token violations', visualViolations.length),
      row('JSON invalid files', jsonInvalidCount),
      row('Telemetry undeclared used', telemetryUndeclaredCount),
      '-----------------------------------------------',
      'See detailed artifacts in release/_reports',
    ];
    return lines.join('\n');
  }

  bool _excluded(String path) {
    if (path.startsWith('release/_quarantine/')) return true;
    if (path.startsWith('build/')) return true;
    if (path.startsWith('.dart_tool/')) return true;
    if (path.startsWith('ios/')) return true;
    if (path.startsWith('android/')) return true;
    return false;
  }

  Future<void> _crawl() async {
    final root = Directory('.');
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final p = e.path.replaceAll('\\', '/');
      if (_excluded(p)) continue;
      _allFiles.add(e);
      final dir = p.contains('/') ? p.substring(0, p.lastIndexOf('/')) : '.';
      (manifest[dir] ??= []).add(p);
      final name = p.substring(p.lastIndexOf('/') + 1);
      (_byName[name] ??= []).add(p);
      for (final pre in _byPrefix.keys) {
        if (name.startsWith(pre)) _byPrefix[pre]!.add(p);
      }
    }
    for (final k in manifest.keys) {
      manifest[k]!.sort();
    }
  }

  void _buildStructure() {
    // We also detect "dead" dirs: directories with files but no .dart/.arb/.yaml
    final dead = <String>[];
    for (final e in manifest.entries) {
      final hasActive = e.value.any(
        (p) => p.endsWith('.dart') || p.endsWith('.arb') || p.endsWith('.yaml'),
      );
      if (!hasActive && e.value.isNotEmpty) dead.add(e.key);
    }
    manifest['__dead_dirs__'] = dead;
  }

  Future<void> _scanDuplicates() async {
    final groups = <String, List<File>>{}; // key: size:hash
    for (final f in _allFiles) {
      try {
        final bytes = await f.readAsBytes();
        final size = bytes.length;
        final hash = _simpleHash(bytes);
        final key = '$size:$hash';
        (groups[key] ??= []).add(f);
      } catch (_) {}
    }
    for (final e in groups.entries) {
      if (e.value.length < 2) continue; // duplicates only
      for (final f in e.value) {
        dupCsv.add([e.key.split(':')[1], e.key.split(':')[0], f.path]);
      }
    }
  }

  Future<void> _scanOrphans() async {
    final backups = <String>[];
    for (final f in _allFiles) {
      final p = f.path;
      if (RegExp(
        r'(\.bak$|_old\.|_copy\.|_backup\.|_deprecated\.)',
      ).hasMatch(p)) {
        backups.add(p);
      }
    }
    orphanIndex['backups'] = backups..sort();

    // Unmatched tests
    final tests = _allFiles.where(
      (f) => f.path.startsWith('test/') && f.path.endsWith('_test.dart'),
    );
    final unmatched = <String>[];
    for (final t in tests) {
      final rel = t.path.substring('test/'.length);
      final libPath = 'lib/${rel.replaceAll('_test.dart', '.dart')}';
      if (!File(libPath).existsSync()) unmatched.add(t.path);
    }
    orphanIndex['unmatched_tests'] = unmatched..sort();

    // Unused assets (simple): anything under assets/ not referenced by name in repo
    final assets = _allFiles.where((f) => f.path.startsWith('assets/'));
    final allText = await _readAllText();
    final unused = <String>[];
    for (final a in assets) {
      final name = a.path.substring(a.path.lastIndexOf('/') + 1);
      if (!allText.contains(name)) unused.add(a.path);
    }
    orphanIndex['unused_assets'] = unused..sort();
  }

  Future<void> _scanTelemetry() async {
    // Collect declared events
    final declared = <String>{};
    final declFile = File('lib/constants/telemetry_events.dart');
    if (declFile.existsSync()) {
      final txt = await declFile.readAsString();
      final re = RegExp("'([a-z0-9_]+)'", caseSensitive: false);
      for (final m in re.allMatches(txt)) {
        declared.add(m.group(1)!);
      }
    }
    final md = File('TELEMETRY_EVENTS.md');
    if (md.existsSync()) {
      final txt = await md.readAsString();
      for (final line in txt.split('\n')) {
        final t = line.trim();
        if (t.startsWith('- ')) declared.add(t.substring(2));
      }
    }

    // Used events: search .dart for .logEvent('name') and TelemetryEvents.<name>
    final used = <String>{};
    for (final f in _allFiles.where((f) => f.path.endsWith('.dart'))) {
      try {
        final txt = await f.readAsString();
        for (final m in RegExp(
          r"logEvent\(\s*'([^']+)'",
          multiLine: true,
        ).allMatches(txt)) {
          used.add(m.group(1)!);
        }
        for (final m in RegExp(
          r'TelemetryEvents\.([a-zA-Z0-9_]+)',
        ).allMatches(txt)) {
          used.add(
            m
                .group(1)!
                .replaceAll(RegExp('[^a-z0-9_]', caseSensitive: false), '')
                .toLowerCase(),
          );
        }
      } catch (_) {}
    }

    final undeclared = used.difference(declared);
    telemetryUndeclaredCount = undeclared.length;

    manifest['__telemetry_declared__'] = declared.toList()..sort();
    manifest['__telemetry_used__'] = used.toList()..sort();
    manifest['__telemetry_undeclared__'] = undeclared.toList()..sort();
  }

  Future<void> _scanI18n() async {
    // Non-ASCII literals in lib/** and tools/** (exclude l10n/ and .arb files)
    final offenders = <String>[];
    for (final f in _allFiles.where(
      (f) =>
          (f.path.startsWith('lib/') || f.path.startsWith('tools/')) &&
          f.path.endsWith('.dart') &&
          !f.path.contains('/l10n/'),
    )) {
      final lines = (await f.readAsString()).split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('"') || line.contains("'")) {
          if (!_isAscii(line)) {
            offenders.add('${f.path}:${i + 1}');
          }
        }
      }
    }
    i18nAudit['non_ascii_literals'] = offenders;

    // Missing ARB keys per language
    final arbFiles = _allFiles.where(
      (f) => f.path.startsWith('lib/l10n/') && f.path.endsWith('.arb'),
    );
    final keySets = <String, Set<String>>{};
    for (final f in arbFiles) {
      try {
        final m = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
        final lang = f.path.substring(
          f.path.lastIndexOf('_') + 1,
          f.path.length - 4,
        );
        final keys = m.keys.where((k) => !k.startsWith('@')).toSet();
        keySets[lang] = keys;
        i18nAudit['total_keys_per_lang'][lang] = keys.length;
      } catch (_) {
        jsonInvalidCount++;
      }
    }
    final union = <String>{};
    for (final s in keySets.values) union.addAll(s);
    final missing = <String, List<String>>{};
    keySets.forEach((lang, keys) {
      final miss = union.difference(keys).toList()..sort();
      if (miss.isNotEmpty) missing[lang] = miss;
    });
    i18nAudit['missing_keys'] = missing;
  }

  Future<void> _scanVisualTokens() async {
    for (final f in _allFiles.where((f) => f.path.endsWith('.dart'))) {
      // Skip canonical theme definition file by design
      if (f.path.contains('lib/ui_v3/theme/visual_theme_v3.dart')) {
        continue;
      }
      final lines = (await f.readAsString()).split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final skip =
            line.contains('VisualThemeV3') ||
            line.contains('ColorScheme') ||
            line.contains('Theme.of(context)');
        if (skip) continue;
        if (RegExp(r'Colors\.[A-Za-z]').hasMatch(line) ||
            line.contains('Color(0x') ||
            RegExp(r'Duration\(milliseconds:\s*\d+\)').hasMatch(line)) {
          visualViolations.add('${f.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
  }

  Future<void> _scanPacks() async {
    final contentDirs = manifest.keys
        .where((d) => d.startsWith('content/'))
        .toList();
    for (final dir in contentDirs) {
      if (!dir.endsWith('/v1') && !dir.contains('/v1/')) continue;
      final files = manifest[dir] ?? [];
      for (final p in files) {
        if (p.endsWith('.json')) {
          try {
            jsonDecode(await File(p).readAsString());
          } catch (_) {
            jsonInvalidCount++;
          }
        } else if (p.endsWith('.jsonl')) {
          try {
            for (final ln in await File(p).readAsLines()) {
              if (ln.trim().isEmpty) continue;
              jsonDecode(ln);
            }
          } catch (_) {
            jsonInvalidCount++;
          }
        }
      }
    }
  }
}

String _simpleHash(List<int> bytes) {
  // Fast, non-crypto rolling hash
  int h = 2166136261;
  for (final b in bytes) {
    h ^= b;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(8, '0');
}

Future<void> _writeText(String path, String text) async {
  final f = File(path);
  f.parent.createSync(recursive: true);
  await f.writeAsString(text, flush: true);
}

Future<void> _writeJson(String path, Object obj) async =>
    _writeText(path, const JsonEncoder.withIndent('  ').convert(obj));

Future<void> _writeCsv(String path, List<List<String>> rows) async {
  final buf = StringBuffer();
  for (final r in rows) {
    buf.writeln(r.map((c) => '"${c.replaceAll('"', '""')}"').join(','));
  }
  await _writeText(path, buf.toString());
}

Future<String> _readAllText() async {
  final buf = StringBuffer();
  final root = Directory('.');
  await for (final e in root.list(recursive: true, followLinks: false)) {
    if (e is File) {
      final p = e.path.replaceAll('\\', '/');
      if (p.startsWith('build/') ||
          p.startsWith('.dart_tool/') ||
          p.startsWith('release/_quarantine/'))
        continue;
      if (p.endsWith('.png') ||
          p.endsWith('.jpg') ||
          p.endsWith('.jpeg') ||
          p.endsWith('.webp'))
        continue;
      try {
        buf.write(await e.readAsString());
      } catch (_) {}
    }
  }
  return buf.toString();
}

bool _isAscii(String s) {
  for (final code in s.codeUnits) {
    if (code > 127) return false;
  }
  return true;
}
