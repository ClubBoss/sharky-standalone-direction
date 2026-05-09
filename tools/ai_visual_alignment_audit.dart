import 'dart:convert';
import 'dart:io';

const String _designSummaryPath = 'release/_reports/design_ai_sync_summary.txt';
const String _uiRoot = 'lib/ui_v3';
const String _outputPath = 'release/_reports/ai_visual_alignment_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _parseDesignSummary();
  final usage = await _scanUiTokenUsage();

  final moodReports = <_MoodAlignmentReport>[];
  int totalTokens = 0;
  int usedTokens = 0;

  for (final mood in moods) {
    final colorData = _collectUsageData(mood.colors, usage.visual);
    final spacingData = _collectUsageData(mood.spacings, usage.visual);
    final typographyData = _collectUsageData(mood.typography, usage.typography);
    final totalCount =
        colorData.totalCount +
        spacingData.totalCount +
        typographyData.totalCount;
    final usedCount =
        colorData.usedCount + spacingData.usedCount + typographyData.usedCount;
    totalTokens += totalCount;
    usedTokens += usedCount;
    moodReports.add(
      _MoodAlignmentReport(
        mood: mood.name,
        colorStats: colorData,
        spacingStats: spacingData,
        typographyStats: typographyData,
      ),
    );
  }

  final alignmentPct = totalTokens == 0
      ? 0.0
      : usedTokens / totalTokens * 100.0;
  final biasRatio = _computeBiasRatio(moodReports);

  await _withReportsWritable(() async {
    await _writeSummary(
      moodReports: moodReports,
      alignmentPct: alignmentPct,
      biasRatio: biasRatio,
    );
    await _appendTelemetry(
      alignmentPct: alignmentPct,
      biasRatio: biasRatio,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ai_visual_alignment_audit: moods=${moodReports.length} '
    'alignment=${alignmentPct.toStringAsFixed(1)}% '
    'bias=${biasRatio.toStringAsFixed(2)}',
  );
}

Future<List<_MoodMapping>> _parseDesignSummary() async {
  final file = File(_designSummaryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final moods = <_MoodMapping>[];
  _MoodMapping? current;

  String _valueFromLine(String line) {
    final parts = line.split(':');
    if (parts.length < 2) return '';
    return parts.sublist(1).join(':').trim();
  }

  void flush() {
    final mapping = current;
    if (mapping != null) moods.add(mapping);
  }

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      flush();
      current = _MoodMapping(name: line.substring(5).trim());
    } else if (current != null && line.startsWith('Colors:')) {
      final mapping = current;
      current = mapping.copyWith(colors: _splitTokens(_valueFromLine(line)));
    } else if (current != null && line.startsWith('Spacing:')) {
      final mapping = current;
      current = mapping.copyWith(spacings: _splitTokens(_valueFromLine(line)));
    } else if (current != null && line.startsWith('Typography:')) {
      final mapping = current;
      current = mapping.copyWith(
        typography: _splitTokens(_valueFromLine(line)),
      );
    }
  }
  flush();
  return moods;
}

List<String> _splitTokens(String value) {
  if (value.isEmpty || value == '—') return const [];
  return value
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();
}

Future<_UsageData> _scanUiTokenUsage() async {
  final visualCounts = <String, int>{};
  final typographyCounts = <String, int>{};
  final dir = Directory(_uiRoot);
  if (!await dir.exists())
    return _UsageData(visual: visualCounts, typography: typographyCounts);

  await for (final entity in dir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = await entity.readAsString();
    final visualMatches = RegExp(
      r'VisualThemeV3\.([a-zA-Z0-9_]+)',
    ).allMatches(content);
    for (final match in visualMatches) {
      final token = match.group(1);
      if (token != null && token.isNotEmpty) {
        visualCounts[token] = (visualCounts[token] ?? 0) + 1;
      }
    }
    final typeMatches = RegExp(
      r'AppTextStyles\.([a-zA-Z0-9_]+)',
    ).allMatches(content);
    for (final match in typeMatches) {
      final token = match.group(1);
      if (token != null && token.isNotEmpty) {
        typographyCounts[token] = (typographyCounts[token] ?? 0) + 1;
      }
    }
  }

  return _UsageData(visual: visualCounts, typography: typographyCounts);
}

_TokenStats _collectUsageData(List<String> tokens, Map<String, int> usageMap) {
  int used = 0;
  final entries = <_TokenUsage>[];
  for (final token in tokens) {
    final count = usageMap[token] ?? 0;
    if (count > 0) used++;
    entries.add(_TokenUsage(token: token, count: count));
  }
  return _TokenStats(
    entries: entries,
    usedCount: used,
    totalCount: tokens.length,
  );
}

double _computeBiasRatio(List<_MoodAlignmentReport> reports) {
  if (reports.isEmpty) return 0;
  double minSum = double.infinity;
  double maxSum = 0;
  for (final report in reports) {
    final sum = report.totalUsage.toDouble();
    if (sum < minSum) minSum = sum;
    if (sum > maxSum) maxSum = sum;
  }
  if (maxSum == 0) return 0;
  return (maxSum + 0.01) / (minSum + 0.01);
}

Future<void> _writeSummary({
  required List<_MoodAlignmentReport> moodReports,
  required double alignmentPct,
  required double biasRatio,
}) async {
  final buffer = StringBuffer()
    ..writeln('AI VISUAL ALIGNMENT SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Alignment: ${alignmentPct.toStringAsFixed(1)}%   '
      'Bias ratio: ${biasRatio.toStringAsFixed(2)}',
    )
    ..writeln();

  for (final report in moodReports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln('  Color tokens:')
      ..writeln(_formatTokenUsage(report.colorStats.entries))
      ..writeln('  Spacing tokens:')
      ..writeln(_formatTokenUsage(report.spacingStats.entries))
      ..writeln('  Typography tokens:')
      ..writeln(_formatTokenUsage(report.typographyStats.entries))
      ..writeln(
        '  Used ${report.usedTokenCount}/${report.totalTokenCount} tokens '
        '(usage sum: ${report.totalUsage})',
      )
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

String _formatTokenUsage(List<_TokenUsage> entries) {
  if (entries.isEmpty) return '    —';
  return entries
      .map(
        (entry) =>
            '    ${entry.token.isEmpty ? '(unknown)' : entry.token}: ${entry.count}',
      )
      .join('\n');
}

Future<void> _appendTelemetry({
  required double alignmentPct,
  required double biasRatio,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'ai_visual_alignment_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'alignment_pct': double.parse(alignmentPct.toStringAsFixed(2)),
    'bias_ratio': double.parse(biasRatio.toStringAsFixed(3)),
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'ai_visual_alignment_audit: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MoodMapping {
  const _MoodMapping({
    required this.name,
    this.colors = const [],
    this.spacings = const [],
    this.typography = const [],
  });

  final String name;
  final List<String> colors;
  final List<String> spacings;
  final List<String> typography;

  _MoodMapping copyWith({
    List<String>? colors,
    List<String>? spacings,
    List<String>? typography,
  }) {
    return _MoodMapping(
      name: name,
      colors: colors ?? this.colors,
      spacings: spacings ?? this.spacings,
      typography: typography ?? this.typography,
    );
  }
}

class _UsageData {
  const _UsageData({required this.visual, required this.typography});

  final Map<String, int> visual;
  final Map<String, int> typography;
}

class _TokenUsage {
  const _TokenUsage({required this.token, required this.count});

  final String token;
  final int count;
}

class _TokenStats {
  const _TokenStats({
    required this.entries,
    required this.usedCount,
    required this.totalCount,
  });

  final List<_TokenUsage> entries;
  final int usedCount;
  final int totalCount;
}

class _MoodAlignmentReport {
  const _MoodAlignmentReport({
    required this.mood,
    required this.colorStats,
    required this.spacingStats,
    required this.typographyStats,
  });

  final String mood;
  final _TokenStats colorStats;
  final _TokenStats spacingStats;
  final _TokenStats typographyStats;

  int get usedTokenCount =>
      colorStats.usedCount + spacingStats.usedCount + typographyStats.usedCount;

  int get totalTokenCount =>
      colorStats.totalCount +
      spacingStats.totalCount +
      typographyStats.totalCount;

  int get totalUsage =>
      colorStats.entries.fold<int>(0, (sum, entry) => sum + entry.count) +
      spacingStats.entries.fold<int>(0, (sum, entry) => sum + entry.count) +
      typographyStats.entries.fold<int>(0, (sum, entry) => sum + entry.count);
}
