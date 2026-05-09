import 'dart:convert';
import 'dart:io';

const String _cohesionSummaryPath =
    'release/_reports/adaptive_cohesion_summary.txt';
const String _reinforcementSummaryPath =
    'release/_reports/dynamic_reinforcement_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _outputPath = 'release/_reports/ux_consolidation_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final cohesion = await _parseCohesionSummary();
  final reinforcement = await _parseReinforcementSummary();

  final alignmentGap = _alignmentGap(cohesion);
  final finalIndex = _finalIndex(cohesion, reinforcement);
  final verdict = _verdict(finalIndex, alignmentGap);
  final alignmentTag = alignmentGap != null && alignmentGap <= 0.1
      ? 'PASS'
      : 'FAIL';
  final cohesionTag = finalIndex >= 0.8 ? 'PASS' : 'FAIL';
  final notes = _buildNotes(reinforcement, alignmentGap);

  await _withReportsWritable(() async {
    await _writeSummary(
      cohesion: cohesion,
      reinforcement: reinforcement,
      finalIndex: finalIndex,
      alignmentGap: alignmentGap,
      cohesionTag: cohesionTag,
      alignmentTag: alignmentTag,
      verdict: verdict,
      notes: notes,
    );
    await _appendTelemetry(
      finalIndex: finalIndex,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ux_consolidation_qa: final=${(finalIndex * 100).toStringAsFixed(1)}% '
    'verdict=$verdict',
  );
}

Future<_CohesionMetrics> _parseCohesionSummary() async {
  final file = File(_cohesionSummaryPath);
  if (!await file.exists()) return const _CohesionMetrics();

  final lines = await file.readAsLines();
  final headerRegex = RegExp(
    r'Drift score:\s*([\d.]+)%\s+Alignment score:\s*([\d.]+)%\s+'
    r'Cohesion index:\s*([\d.]+)%\s*\(([^)]+)\)',
  );

  for (final line in lines) {
    final match = headerRegex.firstMatch(line);
    if (match != null) {
      return _CohesionMetrics(
        driftScore: (double.tryParse(match.group(1) ?? '') ?? 0) / 100,
        alignmentScore: (double.tryParse(match.group(2) ?? '') ?? 0) / 100,
        cohesionIndex: (double.tryParse(match.group(3) ?? '') ?? 0) / 100,
        classification: match.group(4)?.trim(),
      );
    }
  }

  return const _CohesionMetrics();
}

Future<_ReinforcementMetrics> _parseReinforcementSummary() async {
  final file = File(_reinforcementSummaryPath);
  if (!await file.exists()) return const _ReinforcementMetrics();

  final lines = await file.readAsLines();
  double? preIndex;
  double? postIndex;
  double? delta;

  final preRegex = RegExp(r'Pre-index:\s*([\d.]+)%');
  final postRegex = RegExp(
    r'Projected post-index:\s*([\d.]+)%\s*\(Δ\s*([\d.-]+)',
  );
  final beforeWeightsRegex = RegExp(
    r'Weights before → behavioral:\s*([\d.]+)\s+visual:\s*([\d.]+)',
  );
  final afterWeightsRegex = RegExp(
    r'Weights after\s*→\s*behavioral:\s*([\d.]+)\s+visual:\s*([\d.]+)',
  );

  double? beforeBehavioral;
  double? beforeVisual;
  double? afterBehavioral;
  double? afterVisual;

  for (final line in lines) {
    final preMatch = preRegex.firstMatch(line);
    if (preMatch != null) {
      preIndex = (double.tryParse(preMatch.group(1) ?? '') ?? 0) / 100;
    }
    final postMatch = postRegex.firstMatch(line);
    if (postMatch != null) {
      postIndex = (double.tryParse(postMatch.group(1) ?? '') ?? 0) / 100;
      delta = (double.tryParse(postMatch.group(2) ?? '') ?? 0) / 100;
    }
    final beforeMatch = beforeWeightsRegex.firstMatch(line);
    if (beforeMatch != null) {
      beforeBehavioral = double.tryParse(beforeMatch.group(1) ?? '');
      beforeVisual = double.tryParse(beforeMatch.group(2) ?? '');
    }
    final afterMatch = afterWeightsRegex.firstMatch(line);
    if (afterMatch != null) {
      afterBehavioral = double.tryParse(afterMatch.group(1) ?? '');
      afterVisual = double.tryParse(afterMatch.group(2) ?? '');
    }
  }

  return _ReinforcementMetrics(
    preIndex: preIndex,
    postIndex: postIndex,
    delta: delta,
    beforeBehavioral: beforeBehavioral,
    beforeVisual: beforeVisual,
    afterBehavioral: afterBehavioral,
    afterVisual: afterVisual,
  );
}

double _finalIndex(
  _CohesionMetrics cohesion,
  _ReinforcementMetrics reinforcement,
) {
  final values = <double>[
    if (cohesion.cohesionIndex != null) cohesion.cohesionIndex!,
    if (reinforcement.postIndex != null) reinforcement.postIndex!,
  ];
  if (values.isEmpty) {
    return 0.0;
  }
  return values.reduce((a, b) => a + b) / values.length;
}

double? _alignmentGap(_CohesionMetrics cohesion) {
  if (cohesion.driftScore == null || cohesion.alignmentScore == null) {
    return null;
  }
  return (cohesion.driftScore! - cohesion.alignmentScore!).abs();
}

String _verdict(double finalIndex, double? alignmentGap) {
  final aligns = alignmentGap == null || alignmentGap <= 0.1;
  if (finalIndex >= 0.85 && aligns) return 'PASS';
  if (finalIndex >= 0.7) return 'WARN';
  return 'FAIL';
}

String _buildNotes(_ReinforcementMetrics reinforcement, double? gap) {
  final notes = <String>[];
  if (reinforcement.delta != null) {
    final deltaPercent = (reinforcement.delta! * 100).toStringAsFixed(2);
    notes.add('Reinforcement delta: $deltaPercent pts');
  } else {
    notes.add('No reinforcement delta available');
  }
  if (gap != null) {
    notes.add('Alignment gap: ${(gap * 100).toStringAsFixed(1)}%');
  } else {
    notes.add('Alignment data missing');
  }
  return notes.join(' | ');
}

Future<void> _writeSummary({
  required _CohesionMetrics cohesion,
  required _ReinforcementMetrics reinforcement,
  required double finalIndex,
  required double? alignmentGap,
  required String cohesionTag,
  required String alignmentTag,
  required String verdict,
  required String notes,
}) async {
  final buffer = StringBuffer()
    ..writeln('UX CONSOLIDATION SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Final cohesion index: ${(finalIndex * 100).toStringAsFixed(1)}% '
      '($verdict)',
    )
    ..writeln('Cohesion tag: $cohesionTag')
    ..writeln(
      'Alignment tag: $alignmentTag '
      '(gap: ${alignmentGap != null ? (alignmentGap * 100).toStringAsFixed(1) : 'n/a'}%)',
    )
    ..writeln('Notes: $notes')
    ..writeln()
    ..writeln('Inputs')
    ..writeln('------')
    ..writeln(
      'Adaptive cohesion → drift: '
      '${_pct(cohesion.driftScore)}   alignment: ${_pct(cohesion.alignmentScore)}   '
      'index: ${_pct(cohesion.cohesionIndex)} (${cohesion.classification ?? 'Unknown'})',
    )
    ..writeln(
      'Dynamic reinforcement → pre: ${_pct(reinforcement.preIndex)}   '
      'post: ${_pct(reinforcement.postIndex)}   Δ: ${_pct(reinforcement.delta)}',
    )
    ..writeln(
      'Weights before → behavioral: '
      '${_ratio(reinforcement.beforeBehavioral)}   visual: '
      '${_ratio(reinforcement.beforeVisual)}',
    )
    ..writeln(
      'Weights after  → behavioral: '
      '${_ratio(reinforcement.afterBehavioral)}   visual: '
      '${_ratio(reinforcement.afterVisual)}',
    )
    ..writeln();

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double finalIndex,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'ux_consolidation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'final_index': double.parse(finalIndex.toStringAsFixed(3)),
    'verdict': verdict,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _pct(double? value) {
  if (value == null) return 'n/a';
  return '${(value * 100).toStringAsFixed(1)}%';
}

String _ratio(double? value) {
  if (value == null) return 'n/a';
  return value.toStringAsFixed(2);
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'ux_consolidation_qa: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CohesionMetrics {
  const _CohesionMetrics({
    this.driftScore,
    this.alignmentScore,
    this.cohesionIndex,
    this.classification,
  });

  final double? driftScore;
  final double? alignmentScore;
  final double? cohesionIndex;
  final String? classification;
}

class _ReinforcementMetrics {
  const _ReinforcementMetrics({
    this.preIndex,
    this.postIndex,
    this.delta,
    this.beforeBehavioral,
    this.beforeVisual,
    this.afterBehavioral,
    this.afterVisual,
  });

  final double? preIndex;
  final double? postIndex;
  final double? delta;
  final double? beforeBehavioral;
  final double? beforeVisual;
  final double? afterBehavioral;
  final double? afterVisual;
}
