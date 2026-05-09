import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final packager = _PreviewPackager();
  try {
    final report = await packager.generateReport();
    await packager.writeSummary(report);
    await packager.appendTelemetry(report);
  } finally {
    await packager.restorePermissions();
  }
}

class _PreviewPackager {
  bool _madeWritable = false;

  Future<_PreviewReport> generateReport() async {
    final watch = Stopwatch()..start();
    final warnings = <String>[];

    final uiStats = await _parseUiShowcase(
      File('release/_exports/public_showcase_audit.txt'),
      warnings,
    );
    final designerStats = await _parseDesignerManifest(
      File('release/_reports/designer_handoff_manifest.md'),
      warnings,
    );
    final visualStats = await _parseVisualSweep(
      File('release/_reports/visual_sweep_summary.txt'),
      warnings,
    );
    watch.stop();

    return _PreviewReport(
      widgetCount: uiStats.widgetCount,
      avgFps: uiStats.avgFps,
      uiWarnings: uiStats.warnings,
      assetCount: designerStats.assetCount,
      themeTokenCount: designerStats.themeTokens,
      colorTokenCount: designerStats.colorTokens,
      spacingTokenCount: designerStats.spacingTokens,
      typographyTokenCount: designerStats.typographyTokens,
      visualViolations: visualStats.violations,
      visualWarnings: visualStats.warnings,
      visualFiles: visualStats.files,
      visualScreens: visualStats.screens,
      durationMs: watch.elapsedMilliseconds,
      notes: warnings,
    );
  }

  Future<void> writeSummary(_PreviewReport report) async {
    final buffer = StringBuffer()
      ..writeln('Preview Packaging Summary')
      ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln()
      ..writeln('+---------------------+---------+')
      ..writeln('| Metric              | Value   |')
      ..writeln('+---------------------+---------+')
      ..writeln(
        '| Widget Samples      | ${report.widgetCount.toString().padLeft(7)} |',
      )
      ..writeln(
        '| Theme Tokens        | ${report.themeTokenCount.toString().padLeft(7)} |',
      )
      ..writeln(
        '| Asset Entries       | ${report.assetCount.toString().padLeft(7)} |',
      )
      ..writeln(
        '| Visual Violations   | ${report.visualViolations.toString().padLeft(7)} |',
      )
      ..writeln('+---------------------+---------+')
      ..writeln()
      ..writeln('UI Showcase (release/_exports/public_showcase_audit.txt)')
      ..writeln('- Samples captured : ${report.widgetCount}')
      ..writeln('- Avg FPS          : ${report.avgFps.toStringAsFixed(2)}')
      ..writeln('- Warning count    : ${report.uiWarnings}')
      ..writeln()
      ..writeln(
        'Designer Manifest (release/_reports/designer_handoff_manifest.md)',
      )
      ..writeln('- Color tokens     : ${report.colorTokenCount}')
      ..writeln('- Spacing tokens   : ${report.spacingTokenCount}')
      ..writeln('- Typography tokens: ${report.typographyTokenCount}')
      ..writeln('- Asset entries    : ${report.assetCount}')
      ..writeln()
      ..writeln('Visual Sweep (release/_reports/visual_sweep_summary.txt)')
      ..writeln('- Token violations : ${report.visualViolations}')
      ..writeln('- UX warnings      : ${report.visualWarnings}')
      ..writeln('- Files scanned    : ${report.visualFiles}')
      ..writeln('- Screens w/ warn  : ${report.visualScreens}');

    if (report.notes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Notes:')
        ..writeln(report.notes.map((n) => '- $n').join('\n'));
    }

    await _safeWrite(
      File('release/_reports/preview_packaging_summary.txt'),
      buffer.toString(),
    );
  }

  Future<void> appendTelemetry(_PreviewReport report) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.previewPackaged,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'widgets': report.widgetCount,
      'theme_tokens': report.themeTokenCount,
      'assets': report.assetCount,
      'violations': report.visualViolations,
      'duration_ms': report.durationMs,
    };
    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<void> restorePermissions() async {
    if (_madeWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _madeWritable = false;
    }
  }

  Future<void> _safeWrite(File file, String contents) async {
    try {
      await file.writeAsString(contents);
    } on FileSystemException catch (_) {
      await _makeWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _safeAppend(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents, mode: FileMode.append);
    } on FileSystemException catch (_) {
      await _makeWritable();
      await file.writeAsString(contents, mode: FileMode.append);
    }
  }

  Future<void> _makeWritable() async {
    if (_madeWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }
}

class _PreviewReport {
  _PreviewReport({
    required this.widgetCount,
    required this.avgFps,
    required this.uiWarnings,
    required this.assetCount,
    required this.themeTokenCount,
    required this.colorTokenCount,
    required this.spacingTokenCount,
    required this.typographyTokenCount,
    required this.visualViolations,
    required this.visualWarnings,
    required this.visualFiles,
    required this.visualScreens,
    required this.durationMs,
    required this.notes,
  });

  final int widgetCount;
  final double avgFps;
  final int uiWarnings;
  final int assetCount;
  final int themeTokenCount;
  final int colorTokenCount;
  final int spacingTokenCount;
  final int typographyTokenCount;
  final int visualViolations;
  final int visualWarnings;
  final int visualFiles;
  final int visualScreens;
  final int durationMs;
  final List<String> notes;
}

Future<_UiStats> _parseUiShowcase(File file, List<String> notes) async {
  if (!await file.exists()) {
    notes.add('UI showcase file missing: ${file.path}');
    return const _UiStats(widgetCount: 0, avgFps: 0, warnings: 0);
  }
  final lines = await file.readAsLines();
  final sessionRegex = RegExp(r'^\| \d+ \|');
  var widgetCount = 0;
  double avgFps = 0;
  var warnings = 0;
  for (final raw in lines) {
    final line = raw.replaceAll('│', '').trim();
    if (sessionRegex.hasMatch(line)) {
      widgetCount++;
    } else if (line.startsWith('| avg_fps |')) {
      final parts = line.split('|').map((p) => p.trim()).toList();
      avgFps = double.tryParse(parts[2]) ?? 0;
    } else if (line.startsWith('| warnings |')) {
      final parts = line.split('|').map((p) => p.trim()).toList();
      warnings = int.tryParse(parts[2]) ?? 0;
    }
  }
  return _UiStats(widgetCount: widgetCount, avgFps: avgFps, warnings: warnings);
}

Future<_DesignerStats> _parseDesignerManifest(
  File file,
  List<String> notes,
) async {
  if (!await file.exists()) {
    notes.add('Designer manifest missing: ${file.path}');
    return const _DesignerStats(
      colorTokens: 0,
      spacingTokens: 0,
      typographyTokens: 0,
      assetCount: 0,
    );
  }
  final lines = await file.readAsLines();
  final colors = _countTableEntries(lines, '### Colors');
  final spacing = _countTableEntries(lines, '### Spacing');
  final typography = _countTableEntries(lines, '### Typography');
  final assets = _countTableEntries(lines, '## Section 2 — Asset List');

  return _DesignerStats(
    colorTokens: colors,
    spacingTokens: spacing,
    typographyTokens: typography,
    assetCount: assets,
  );
}

Future<_VisualStats> _parseVisualSweep(File file, List<String> notes) async {
  if (!await file.exists()) {
    notes.add('Visual sweep summary missing: ${file.path}');
    return const _VisualStats(violations: 0, warnings: 0, files: 0, screens: 0);
  }
  final content = await file.readAsString();
  int _matchInt(String label) {
    final regex = RegExp('$label:\\s*(\\d+)', multiLine: true);
    final match = regex.firstMatch(content);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  return _VisualStats(
    violations: _matchInt('Visual token violations'),
    warnings: _matchInt('UX polish warnings'),
    files: _matchInt('Unique files with violations'),
    screens: _matchInt('Screens with warnings'),
  );
}

int _countTableEntries(List<String> lines, String header) {
  final index = lines.indexWhere((line) => line.trim().startsWith(header));
  if (index == -1) return 0;
  var count = 0;
  for (var i = index + 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || !line.startsWith('|')) {
      if (count > 0) break;
      continue;
    }
    if (line.contains('-----')) continue;
    count++;
  }
  return count;
}

class _UiStats {
  const _UiStats({
    required this.widgetCount,
    required this.avgFps,
    required this.warnings,
  });

  final int widgetCount;
  final double avgFps;
  final int warnings;
}

class _DesignerStats {
  const _DesignerStats({
    required this.colorTokens,
    required this.spacingTokens,
    required this.typographyTokens,
    required this.assetCount,
  });

  final int colorTokens;
  final int spacingTokens;
  final int typographyTokens;
  final int assetCount;

  int get themeTokens => colorTokens + spacingTokens + typographyTokens;
}

class _VisualStats {
  const _VisualStats({
    required this.violations,
    required this.warnings,
    required this.files,
    required this.screens,
  });

  final int violations;
  final int warnings;
  final int files;
  final int screens;
}
