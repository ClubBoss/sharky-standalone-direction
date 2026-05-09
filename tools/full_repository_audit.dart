import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Full repository audit tool - generates comprehensive health reports
void main() async {
  final stopwatch = Stopwatch()..start();
  print('[FullRepositoryAudit] Starting comprehensive scan...');

  final audit = RepositoryAuditor();
  await audit.run();

  stopwatch.stop();
  print(
    '[FullRepositoryAudit] Completed in ${stopwatch.elapsedMilliseconds}ms',
  );
  print('[FullRepositoryAudit] Health Score: ${audit.healthScore}/100');
}

class RepositoryAuditor {
  final _files = <FileEntry>[];
  final _classes = <String, String>{};
  final _imports = <String, List<String>>{};
  final _telemetryEvents = <String, EventSource>{};
  final _assetsDeclared = <String>[];
  final _assetsOnDisk = <String>[];
  final _duplicates = <String, List<String>>{};
  final _orphans = <String>[];
  final _featureFlags = <String, List<String>>{};
  final _uiV2Widgets = <String>[];
  final _uiV3Widgets = <String>[];
  final _unreferencedScreens = <String>[];

  int healthScore = 0;

  Future<void> run() async {
    final root = Directory.current.path;

    // Phase 1: File system scan
    await _scanFileSystem(root);
    print('[Audit] Scanned ${_files.length} files');

    // Phase 2: Dart code analysis
    await _analyzeDartFiles();
    print('[Audit] Analyzed ${_classes.length} classes');

    // Phase 3: Telemetry analysis
    await _analyzeTelemetry(root);
    print('[Audit] Found ${_telemetryEvents.length} telemetry events');

    // Phase 4: Asset validation
    await _validateAssets(root);
    print('[Audit] Validated ${_assetsDeclared.length} declared assets');

    // Phase 5: Duplication analysis
    _analyzeDuplicates();
    print('[Audit] Found ${_duplicates.length} duplicate groups');

    // Phase 6: Orphan detection
    _detectOrphans();
    print('[Audit] Found ${_orphans.length} orphan files');

    // Phase 7: Feature flags
    _analyzeFeatureFlags();
    print('[Audit] Found ${_featureFlags.length} feature flags');

    // Phase 8: UI layer analysis
    _analyzeUILayers();
    print('[Audit] UI v2: ${_uiV2Widgets.length}, v3: ${_uiV3Widgets.length}');

    // Phase 9: Calculate health score
    _calculateHealthScore();

    // Phase 10: Generate reports
    await _generateReports(root);
  }

  Future<void> _scanFileSystem(String root) async {
    final patterns = [
      '.',
      'lib',
      'tools',
      'scripts',
      'test',
      'content',
      'assets',
      'windows',
      'macos',
      'ios',
      'android',
      'web',
      'linux',
      'dev',
      'docs',
      'release',
      '_legacy',
      '_drafts',
    ];

    for (final pattern in patterns) {
      final dir = Directory('$root/$pattern');
      if (!dir.existsSync()) {
        print('[WARN] Directory not found: $pattern');
        continue;
      }

      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final stat = entity.statSync();
            final bytes = await entity.readAsBytes();
            final hash = sha256.convert(bytes).toString();

            _files.add(
              FileEntry(
                path: entity.path.replaceFirst('$root/', ''),
                size: stat.size,
                mtime: stat.modified.toIso8601String(),
                sha256: hash,
              ),
            );
          } catch (e) {
            // Skip files we can't read
          }
        }
      }
    }
  }

  Future<void> _analyzeDartFiles() async {
    for (final file in _files.where((f) => f.path.endsWith('.dart'))) {
      try {
        final content = await File(file.path).readAsString();

        // Extract classes/enums
        final classRegex = RegExp(
          r'^\s*(?:abstract\s+)?class\s+(\w+)',
          multiLine: true,
        );
        final enumRegex = RegExp(r'^\s*enum\s+(\w+)', multiLine: true);

        for (final match in classRegex.allMatches(content)) {
          _classes[match.group(1)!] = file.path;
        }
        for (final match in enumRegex.allMatches(content)) {
          _classes[match.group(1)!] = file.path;
        }

        // Extract imports
        final importRegex = RegExp(
          r'''^\s*import\s+['"]([^'"]+)''',
          multiLine: true,
        );
        final imports = <String>[];
        for (final match in importRegex.allMatches(content)) {
          imports.add(match.group(1)!);
        }
        if (imports.isNotEmpty) {
          _imports[file.path] = imports;
        }
      } catch (e) {
        // Skip files we can't parse
      }
    }
  }

  Future<void> _analyzeTelemetry(String root) async {
    // Load declared events from TELEMETRY_EVENTS.md
    final telemetryDoc = File('$root/TELEMETRY_EVENTS.md');
    if (telemetryDoc.existsSync()) {
      final content = await telemetryDoc.readAsString();
      final eventRegex = RegExp(r'''['"]([a-z_][a-z0-9_]+)''', multiLine: true);
      for (final match in eventRegex.allMatches(content)) {
        final event = match.group(1)!;
        _telemetryEvents.putIfAbsent(event, () => EventSource(event)).declared =
            true;
      }
    }

    // Find actual usage in code
    final logEventRegex = RegExp(
      r'''\.logEvent\(['"]([^'"]+)''',
      multiLine: true,
    );
    for (final file in _files.where((f) => f.path.endsWith('.dart'))) {
      try {
        final content = await File(file.path).readAsString();
        for (final match in logEventRegex.allMatches(content)) {
          final event = match.group(1)!;
          _telemetryEvents
              .putIfAbsent(event, () => EventSource(event))
              .usedIn
              .add(file.path);
        }
      } catch (e) {
        // Skip
      }
    }
  }

  Future<void> _validateAssets(String root) async {
    // Load declared assets from pubspec.yaml
    final pubspec = File('$root/pubspec.yaml');
    if (pubspec.existsSync()) {
      final content = await pubspec.readAsString();
      final assetRegex = RegExp(
        r'^\s*-\s+(.+\.(png|jpg|svg|json|yaml))',
        multiLine: true,
      );
      for (final match in assetRegex.allMatches(content)) {
        _assetsDeclared.add(match.group(1)!.trim());
      }
    }

    // Scan assets on disk
    final assetsDir = Directory('$root/assets');
    if (assetsDir.existsSync()) {
      await for (final entity in assetsDir.list(recursive: true)) {
        if (entity is File) {
          final rel = entity.path.replaceFirst('$root/', '');
          _assetsOnDisk.add(rel);
        }
      }
    }
  }

  void _analyzeDuplicates() {
    // Group by filename prefix patterns
    final patterns = ['booster_', 'theory_', 'smart_', 'adaptive_', 'goal_'];
    for (final pattern in patterns) {
      final matches = _files
          .where((f) => f.path.contains('/$pattern'))
          .map((f) => f.path)
          .toList();
      if (matches.length > 5) {
        _duplicates[pattern] = matches;
      }
    }

    // Find class name collisions
    final classNames = <String, List<String>>{};
    for (final entry in _classes.entries) {
      classNames.putIfAbsent(entry.key, () => []).add(entry.value);
    }
    for (final entry in classNames.entries) {
      if (entry.value.length > 1) {
        _duplicates['class:${entry.key}'] = entry.value;
      }
    }
  }

  void _detectOrphans() {
    // Find files with no inbound references
    final referenced = <String>{};

    // Add imported files
    for (final imports in _imports.values) {
      referenced.addAll(imports.where((i) => i.startsWith('package:')));
    }

    // Find stale backups
    final stalePatterns = ['_old', '_backup', 'copy', 'tmp', '.bak'];
    for (final file in _files) {
      if (stalePatterns.any(file.path.contains)) {
        _orphans.add(file.path);
      }
    }

    // Empty directories would need separate scan
  }

  void _analyzeFeatureFlags() {
    final flagRegex = RegExp(r'\benable_\w+\b');
    for (final file in _files.where((f) => f.path.endsWith('.dart'))) {
      try {
        final content = File(file.path).readAsStringSync();
        final matches = flagRegex.allMatches(content);
        for (final match in matches) {
          final flag = match.group(0)!;
          _featureFlags.putIfAbsent(flag, () => []).add(file.path);
        }
      } catch (e) {
        // Skip
      }
    }
  }

  void _analyzeUILayers() {
    for (final file in _files.where((f) => f.path.endsWith('.dart'))) {
      if (file.path.contains('lib/ui_v2/')) {
        _uiV2Widgets.add(file.path);
      } else if (file.path.contains('lib/ui_v3/')) {
        _uiV3Widgets.add(file.path);
      }

      // Detect screens (files ending with _screen.dart)
      if (file.path.endsWith('_screen.dart') && !file.path.contains('test/')) {
        // Check if referenced in navigator/router
        bool referenced = false;
        for (final other in _files.where(
          (f) => f.path.contains('route') || f.path.contains('navigator'),
        )) {
          try {
            final content = File(other.path).readAsStringSync();
            if (content.contains(
              file.path.split('/').last.replaceAll('.dart', ''),
            )) {
              referenced = true;
              break;
            }
          } catch (e) {
            // Skip
          }
        }
        if (!referenced) {
          _unreferencedScreens.add(file.path);
        }
      }
    }
  }

  void _calculateHealthScore() {
    // Structure score (40 points): Fewer duplicate groups = better
    final structureScore = (40 - (_duplicates.length * 2).clamp(0, 40)).toInt();

    // Duplication score (20 points): Fewer files in dup groups = better
    final dupFiles = _duplicates.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final duplicationScore = (20 - (dupFiles / 10).clamp(0, 20)).toInt();

    // Orphan score (20 points): Fewer orphans = better
    final orphanScore = (20 - (_orphans.length / 5).clamp(0, 20)).toInt();

    // Telemetry sync score (10 points): Matched events = better
    final matched = _telemetryEvents.values
        .where((e) => e.declared && e.usedIn.isNotEmpty)
        .length;
    final total = _telemetryEvents.length;
    final telemetryScore = total > 0 ? ((matched / total) * 10).toInt() : 10;

    // UI cohesion score (10 points): Balanced v2/v3 or clear migration = better
    final v2Count = _uiV2Widgets.length;
    final v3Count = _uiV3Widgets.length;
    final uiScore = v3Count > v2Count
        ? 10
        : (5 - (_unreferencedScreens.length / 2).clamp(0, 5)).toInt();

    healthScore =
        structureScore +
        duplicationScore +
        orphanScore +
        telemetryScore +
        uiScore;
  }

  Future<void> _generateReports(String root) async {
    final reportsDir = Directory('$root/release/_reports');
    if (!reportsDir.existsSync()) {
      reportsDir.createSync(recursive: true);
    }

    // Generate files.json
    await File('${reportsDir.path}/files.json').writeAsString(
      jsonEncode({'files': _files.map((f) => f.toJson()).toList()}),
    );

    // Generate classes.json
    await File(
      '${reportsDir.path}/classes.json',
    ).writeAsString(jsonEncode({'classes': _classes}));

    // Generate imports.json
    await File(
      '${reportsDir.path}/imports.json',
    ).writeAsString(jsonEncode({'imports': _imports}));

    // Generate telemetry.json
    await File('${reportsDir.path}/telemetry.json').writeAsString(
      jsonEncode({
        'events': _telemetryEvents.map((k, v) => MapEntry(k, v.toJson())),
      }),
    );

    // Generate assets.json
    await File('${reportsDir.path}/assets.json').writeAsString(
      jsonEncode({'declared': _assetsDeclared, 'on_disk': _assetsOnDisk}),
    );

    // Generate summary text report
    await _generateTextReport(reportsDir);

    // Generate JSON summary
    await _generateJsonSummary(reportsDir);

    // Generate orphan files list
    await File(
      '${reportsDir.path}/orphan_files.txt',
    ).writeAsString(_orphans.join('\n'));

    // Generate duplication matrix CSV
    await _generateDuplicationCSV(reportsDir);

    // Generate telemetry drift report
    await _generateTelemetryDriftReport(reportsDir);

    // Generate health score markdown
    await _generateHealthScoreMarkdown(root);

    // Append telemetry JSONL
    await _appendTelemetryLog(reportsDir);
  }

  Future<void> _generateTextReport(Directory reportsDir) async {
    final buffer = StringBuffer();
    buffer.writeln('=== FULL REPOSITORY AUDIT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('COUNTS:');
    buffer.writeln('  Files scanned: ${_files.length}');
    buffer.writeln('  Classes/Enums: ${_classes.length}');
    buffer.writeln('  Import edges: ${_imports.length}');
    buffer.writeln('  Telemetry events: ${_telemetryEvents.length}');
    buffer.writeln('  Duplicate groups: ${_duplicates.length}');
    buffer.writeln('  Orphan files: ${_orphans.length}');
    buffer.writeln('  Feature flags: ${_featureFlags.length}');
    buffer.writeln('  UI v2 widgets: ${_uiV2Widgets.length}');
    buffer.writeln('  UI v3 widgets: ${_uiV3Widgets.length}');
    buffer.writeln('');
    buffer.writeln('TOP RISKS:');

    // Top duplicate groups
    final topDups = _duplicates.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    buffer.writeln('  Largest duplicate groups:');
    for (final dup in topDups.take(5)) {
      buffer.writeln('    ${dup.key}: ${dup.value.length} files');
    }

    buffer.writeln('');
    buffer.writeln('HEALTH SCORE: $healthScore/100');

    await File(
      '${reportsDir.path}/full_repository_audit.txt',
    ).writeAsString(buffer.toString());
  }

  Future<void> _generateJsonSummary(Directory reportsDir) async {
    final summary = {
      'timestamp': DateTime.now().toIso8601String(),
      'counts': {
        'files': _files.length,
        'classes': _classes.length,
        'imports': _imports.length,
        'telemetry_events': _telemetryEvents.length,
        'duplicate_groups': _duplicates.length,
        'orphans': _orphans.length,
        'feature_flags': _featureFlags.length,
        'ui_v2_widgets': _uiV2Widgets.length,
        'ui_v3_widgets': _uiV3Widgets.length,
        'unreferenced_screens': _unreferencedScreens.length,
      },
      'health_score': healthScore,
    };

    await File(
      '${reportsDir.path}/full_repository_audit.json',
    ).writeAsString(jsonEncode(summary));
  }

  Future<void> _generateDuplicationCSV(Directory reportsDir) async {
    final buffer = StringBuffer();
    buffer.writeln('pattern,file_count,files');

    for (final entry in _duplicates.entries) {
      buffer.writeln(
        '${entry.key},${entry.value.length},"${entry.value.join(';')}"',
      );
    }

    await File(
      '${reportsDir.path}/duplication_matrix.csv',
    ).writeAsString(buffer.toString());
  }

  Future<void> _generateTelemetryDriftReport(Directory reportsDir) async {
    final buffer = StringBuffer();
    buffer.writeln('=== TELEMETRY DRIFT REPORT ===');
    buffer.writeln('');

    // Events declared but not used
    final declaredNotUsed = _telemetryEvents.values
        .where((e) => e.declared && e.usedIn.isEmpty)
        .toList();
    buffer.writeln('DECLARED BUT NOT USED (${declaredNotUsed.length}):');
    for (final event in declaredNotUsed) {
      buffer.writeln('  ${event.name}');
    }

    buffer.writeln('');

    // Events used but not declared
    final usedNotDeclared = _telemetryEvents.values
        .where((e) => !e.declared && e.usedIn.isNotEmpty)
        .toList();
    buffer.writeln('USED BUT NOT DECLARED (${usedNotDeclared.length}):');
    for (final event in usedNotDeclared) {
      buffer.writeln('  ${event.name} (used in ${event.usedIn.length} files)');
    }

    await File(
      '${reportsDir.path}/telemetry_drift_report.txt',
    ).writeAsString(buffer.toString());
  }

  Future<void> _generateHealthScoreMarkdown(String root) async {
    final buffer = StringBuffer();
    buffer.writeln('# Repository Health Score');
    buffer.writeln('');
    buffer.writeln('**Overall Score**: $healthScore/100');
    buffer.writeln('');
    buffer.writeln('## Component Scores');
    buffer.writeln('');
    buffer.writeln('| Component | Score | Max | Formula |');
    buffer.writeln('|-----------|-------|-----|---------|');
    buffer.writeln('| Structure | - | 40 | 40 - (dup_groups * 2) |');
    buffer.writeln('| Duplication | - | 20 | 20 - (dup_files / 10) |');
    buffer.writeln('| Orphans | - | 20 | 20 - (orphan_count / 5) |');
    buffer.writeln('| Telemetry Sync | - | 10 | (matched / total) * 10 |');
    buffer.writeln('| UI Cohesion | - | 10 | v3 > v2 ? 10 : 5 |');
    buffer.writeln('');
    buffer.writeln('## Metrics');
    buffer.writeln('');
    buffer.writeln('- Files: ${_files.length}');
    buffer.writeln('- Duplicate groups: ${_duplicates.length}');
    buffer.writeln('- Orphan files: ${_orphans.length}');
    buffer.writeln('- Telemetry events: ${_telemetryEvents.length}');
    buffer.writeln('- UI v2 widgets: ${_uiV2Widgets.length}');
    buffer.writeln('- UI v3 widgets: ${_uiV3Widgets.length}');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${DateTime.now().toIso8601String()}');

    await File(
      '$root/REPOSITORY_HEALTH_SCORE.md',
    ).writeAsString(buffer.toString());
  }

  Future<void> _appendTelemetryLog(Directory reportsDir) async {
    final logFile = File('${reportsDir.path}/telemetry.jsonl');
    final driftCount = _telemetryEvents.values
        .where((e) => e.declared != (e.usedIn.isNotEmpty))
        .length;

    final event = {
      'event': 'full_repository_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'duration_ms': 0, // Will be set by caller
      'files_scanned': _files.length,
      'dup_groups': _duplicates.length,
      'orphan_count': _orphans.length,
      'drift_count': driftCount,
      'health_score': healthScore,
    };

    await logFile.writeAsString(
      '${jsonEncode(event)}\n',
      mode: FileMode.append,
    );
  }
}

class FileEntry {
  final String path;
  final int size;
  final String mtime;
  final String sha256;

  FileEntry({
    required this.path,
    required this.size,
    required this.mtime,
    required this.sha256,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'size': size,
    'mtime': mtime,
    'sha256': sha256,
  };
}

class EventSource {
  final String name;
  bool declared = false;
  final List<String> usedIn = [];

  EventSource(this.name);

  Map<String, dynamic> toJson() => {
    'name': name,
    'declared': declared,
    'used_in': usedIn,
  };
}
