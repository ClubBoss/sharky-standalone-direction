import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final engine = AdaptiveAbLoopEngine();
  await engine.run();
}

class AdaptiveAbLoopEngine {
  AdaptiveAbLoopEngine({
    this.profilePath = 'release/_reports/personalization_profile.json',
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.summaryPath = 'release/_reports/ab_experiment_summary.txt',
    this.telemetryOutputPath = 'release/_reports/telemetry.jsonl',
    double? variantARatioOverride,
  }) : _ratioOverride = variantARatioOverride;

  final String profilePath;
  final String telemetryPath;
  final String summaryPath;
  final String telemetryOutputPath;
  final double? _ratioOverride;

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final profile = await AdaptiveProfile.load(profilePath);
    final ratio = (_ratioOverride ?? profile.variantRatio).clamp(0.1, 0.9);
    final samples = await _loadSamples(profile);
    if (samples.isEmpty) {
      throw StateError(
        'adaptive_ab_loop_engine: no telemetry samples available.',
      );
    }

    final assignment = _assignVariants(samples, ratio);
    final statsA = _VariantStats('A')..ingest(assignment.variantA);
    final statsB = _VariantStats('B')..ingest(assignment.variantB);
    final deltas = _DeltaBundle.from(statsA, statsB);

    await _withReportsWritable(() async {
      await _writeSummary(
        profile: profile,
        ratio: ratio,
        statsA: statsA,
        statsB: statsB,
        deltas: deltas,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        profile: profile,
        ratio: ratio,
        statsA: statsA,
        statsB: statsB,
        deltas: deltas,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    stdout.writeln(
      'adaptive_ab_loop_engine: '
      'samples=${samples.length} a=${statsA.samples} b=${statsB.samples} '
      'Δret=${_round(deltas.retentionDelta)} '
      'Δeng=${_round(deltas.engagementDelta)} '
      'Δcmp=${_round(deltas.completionDelta)}',
    );
  }

  Future<List<_Sample>> _loadSamples(AdaptiveProfile profile) async {
    final file = File(telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry stream missing: $telemetryPath');
    }

    final lines = await file.readAsLines();
    var counter = 0;
    final samples = <_Sample>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      dynamic payload;
      try {
        payload = json.decode(line);
      } catch (_) {
        continue;
      }
      if (payload is! Map<String, dynamic>) continue;
      final event = payload['event']?.toString();
      if (event == null) continue;

      final builder = _SampleBuilder('${event}_$counter');
      counter++;

      switch (event) {
        case 'retention_funnel_updated':
          builder
            ..retention = _toDouble(payload['total_retention'])
            ..completion = _toDouble(payload['start_to_finish'])
            ..engagement = _mean([
              _toDouble(payload['first_to_signup']),
              _toDouble(payload['signup_to_start']),
              _toDouble(payload['start_to_finish']),
            ])
            ..sessionLength = _msToMinutes(payload['duration_ms']);
          break;
        case 'engagement_heatmap_generated':
          final heatmap = payload['heatmap'];
          if (heatmap is Map) {
            builder.engagement = _mean(
              heatmap.values.map(_toDouble).whereType<double>().toList(),
            );
          }
          builder.sessionLength = _msToMinutes(payload['duration_ms']);
          break;
        case 'engagement_retention_correlated':
          final normalized = payload['normalized_engagement'];
          if (normalized is Map) {
            builder.engagement = _mean(
              normalized.values
                  .map(_toDouble)
                  .whereType<double>()
                  .map((value) => value * 100)
                  .toList(),
            );
          }
          final normRetention = payload['normalized_retention'];
          if (normRetention is Map) {
            builder.retention = _mean(
              normRetention.values
                  .map(_toDouble)
                  .whereType<double>()
                  .map((value) => value * 100)
                  .toList(),
            );
          }
          builder.sessionLength = _msToMinutes(payload['duration_ms']);
          break;
        default:
          builder.sessionLength = _msToMinutes(payload['duration_ms']);
          final retentionIndex = _toDouble(payload['retentionIndex']);
          if (retentionIndex != null) {
            builder.retention = retentionIndex * 100;
          }
          final completionRate = _toDouble(payload['completionRate']);
          if (completionRate != null) {
            builder.completion = completionRate * 100;
          }
          final engagementScore = _toDouble(payload['engagementScore']);
          if (engagementScore != null) {
            builder.engagement = engagementScore * 100;
          }
          break;
      }

      if (!builder.hasAny) continue;
      builder.fillDefaults(profile);
      samples.add(builder.build());
    }

    if (samples.isEmpty) {
      samples.add(
        _Sample(
          id: 'fallback',
          retention: profile.baselineRetention,
          engagement: profile.baselineEngagement,
          completion: profile.baselineCompletion,
          sessionLength: profile.baselineSessionLength,
        ),
      );
    }

    return samples;
  }

  _Assignment _assignVariants(List<_Sample> samples, double ratio) {
    final a = <_Sample>[];
    final b = <_Sample>[];
    for (final sample in samples) {
      if (_belongsToA(sample.id, ratio)) {
        a.add(sample);
      } else {
        b.add(sample);
      }
    }
    if (a.isEmpty && b.isNotEmpty) {
      a.add(b.first);
    } else if (b.isEmpty && a.isNotEmpty) {
      b.add(a.first);
    }
    return _Assignment(variantA: a, variantB: b);
  }

  Future<void> _writeSummary({
    required AdaptiveProfile profile,
    required double ratio,
    required _VariantStats statsA,
    required _VariantStats statsB,
    required _DeltaBundle deltas,
    required int durationMs,
  }) async {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE AB LOOP SUMMARY')
      ..writeln('=======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Hypothesis: ${profile.hypothesis}')
      ..writeln(
        'Variant ratio (A/B): ${_round(ratio * 100)}% / '
        '${_round((1 - ratio) * 100)}%',
      )
      ..writeln();

    buffer
      ..writeln('Variant KPIs')
      ..writeln(
        'Variant | Samples | Retention% | Engagement% | Completion% '
        '| Avg Session (min)',
      )
      ..writeln(
        '--------+---------+------------+-------------+-------------'
        '+-------------------',
      )
      ..writeln(statsA.renderRow())
      ..writeln(statsB.renderRow())
      ..writeln();

    buffer
      ..writeln('Experiment deltas (B - A)')
      ..writeln(
        '- ΔRetention : ${_formatDelta(deltas.retentionDelta)} '
        '(Z=${_round(deltas.retentionZ)}, ${_significance(deltas.retentionZ)})',
      )
      ..writeln(
        '- ΔEngagement: ${_formatDelta(deltas.engagementDelta)} '
        '(Z=${_round(deltas.engagementZ)}, '
        '${_significance(deltas.engagementZ)})',
      )
      ..writeln(
        '- ΔCompletion: ${_formatDelta(deltas.completionDelta)} '
        '(Z=${_round(deltas.completionZ)}, '
        '${_significance(deltas.completionZ)})',
      )
      ..writeln(
        '- ΔSession   : ${_formatDeltaMinutes(deltas.sessionDelta)} '
        '(Z=${_round(deltas.sessionZ)}, ${_significance(deltas.sessionZ)})',
      )
      ..writeln();

    buffer
      ..writeln('Verdict: ${deltas.verdict}')
      ..writeln('Notes : ${deltas.notes}')
      ..writeln();

    await File(summaryPath).writeAsString('${buffer.toString()}');
  }

  Future<void> _emitTelemetry({
    required AdaptiveProfile profile,
    required double ratio,
    required _VariantStats statsA,
    required _VariantStats statsB,
    required _DeltaBundle deltas,
    required int durationMs,
  }) async {
    final payload = <String, Object?>{
      'event': 'ab_experiment_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'hypothesis': profile.hypothesis,
      'variant_ratio_a': _round(ratio),
      'samples_a': statsA.samples,
      'samples_b': statsB.samples,
      'retention_a': _round(statsA.retention.mean),
      'retention_b': _round(statsB.retention.mean),
      'engagement_a': _round(statsA.engagement.mean),
      'engagement_b': _round(statsB.engagement.mean),
      'completion_a': _round(statsA.completion.mean),
      'completion_b': _round(statsB.completion.mean),
      'session_a_min': _round(statsA.session.mean),
      'session_b_min': _round(statsB.session.mean),
      'delta_retention': _round(deltas.retentionDelta),
      'delta_engagement': _round(deltas.engagementDelta),
      'delta_completion': _round(deltas.completionDelta),
      'delta_session': _round(deltas.sessionDelta),
      'z_scores': {
        'retention': _round(deltas.retentionZ),
        'engagement': _round(deltas.engagementZ),
        'completion': _round(deltas.completionZ),
        'session': _round(deltas.sessionZ),
      },
      'duration_ms': durationMs,
    };

    await File(telemetryOutputPath).writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class AdaptiveProfile {
  const AdaptiveProfile({
    required this.variantRatio,
    required this.hypothesis,
    required this.baselineRetention,
    required this.baselineCompletion,
    required this.baselineEngagement,
    required this.baselineSessionLength,
  });

  static Future<AdaptiveProfile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return _defaults();
    }
    try {
      final raw = json.decode(await file.readAsString());
      if (raw is! Map<String, dynamic>) {
        return _defaults();
      }
      final fingerprint =
          raw['fingerprint'] as Map<String, dynamic>? ?? const {};
      final adjustments =
          raw['adjustments'] as Map<String, dynamic>? ?? const {};
      final ratioCandidate =
          _toDouble(adjustments['ab_ratio']) ??
          _toDouble(fingerprint['ab_ratio']);
      final hypothesis =
          adjustments['ab_hypothesis']?.toString() ??
          raw['hypothesis']?.toString() ??
          'increase_retention';

      final baselineRetention =
          (_toDouble(adjustments['retention_pct']) ??
                  _toDouble(fingerprint['accuracy']))
              ?.clamp(0, 1) ??
          0.7;
      final completion =
          (_toDouble(adjustments['completion_pct']) ??
                  _toDouble(fingerprint['accuracy']))
              ?.clamp(0, 1) ??
          0.65;
      final engagement = _toDouble(fingerprint['xp_rate'])?.clamp(0, 5) ?? 1.0;
      final session =
          _toDouble(adjustments['session_length_ms']) ??
          _toDouble(fingerprint['speed_ms']) ??
          4200;

      return AdaptiveProfile(
        variantRatio: (ratioCandidate ?? 0.5).clamp(0.1, 0.9),
        hypothesis: hypothesis,
        baselineRetention: baselineRetention * 100,
        baselineCompletion: completion * 100,
        baselineEngagement: engagement * 20, // Map XP rate -> %
        baselineSessionLength: (session / 60000).clamp(1, 60),
      );
    } catch (_) {
      return _defaults();
    }
  }

  final double variantRatio;
  final String hypothesis;
  final double baselineRetention;
  final double baselineCompletion;
  final double baselineEngagement;
  final double baselineSessionLength;

  static AdaptiveProfile _defaults() => const AdaptiveProfile(
    variantRatio: 0.5,
    hypothesis: 'baseline',
    baselineRetention: 70,
    baselineCompletion: 65,
    baselineEngagement: 55,
    baselineSessionLength: 8,
  );
}

class _VariantStats {
  _VariantStats(this.label);

  final String label;
  final _MetricAccumulator retention = _MetricAccumulator();
  final _MetricAccumulator engagement = _MetricAccumulator();
  final _MetricAccumulator completion = _MetricAccumulator();
  final _MetricAccumulator session = _MetricAccumulator();
  int samples = 0;

  void ingest(List<_Sample> bucket) {
    for (final sample in bucket) {
      samples++;
      retention.add(sample.retention);
      engagement.add(sample.engagement);
      completion.add(sample.completion);
      session.add(sample.sessionLength);
    }
  }

  String renderRow() {
    return [
      label.padRight(8),
      samples.toString().padLeft(7),
      '${_round(retention.mean).toString().padLeft(10)}',
      '${_round(engagement.mean).toString().padLeft(11)}',
      '${_round(completion.mean).toString().padLeft(11)}',
      '${_round(session.mean).toString().padLeft(17)}',
    ].join(' | ');
  }
}

class _Assignment {
  const _Assignment({required this.variantA, required this.variantB});

  final List<_Sample> variantA;
  final List<_Sample> variantB;
}

class _Sample {
  const _Sample({
    required this.id,
    required this.retention,
    required this.engagement,
    required this.completion,
    required this.sessionLength,
  });

  final String id;
  final double? retention;
  final double? engagement;
  final double? completion;
  final double? sessionLength;
}

class _SampleBuilder {
  _SampleBuilder(this.id);

  final String id;
  double? retention;
  double? engagement;
  double? completion;
  double? sessionLength;

  bool get hasAny =>
      retention != null ||
      engagement != null ||
      completion != null ||
      sessionLength != null;

  void fillDefaults(AdaptiveProfile profile) {
    retention ??= profile.baselineRetention;
    engagement ??= profile.baselineEngagement;
    completion ??= profile.baselineCompletion;
    sessionLength ??= profile.baselineSessionLength;
  }

  _Sample build() => _Sample(
    id: id,
    retention: retention,
    engagement: engagement,
    completion: completion,
    sessionLength: sessionLength,
  );
}

class _MetricAccumulator {
  double _sum = 0;
  double _sumSq = 0;
  int _count = 0;

  void add(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return;
    _sum += value;
    _sumSq += value * value;
    _count++;
  }

  double get mean => _count == 0 ? 0 : _sum / _count;

  double get variance {
    if (_count <= 1) return 0;
    final meanValue = mean;
    final raw = (_sumSq / _count) - (meanValue * meanValue);
    return raw.isNaN || raw.isInfinite ? 0 : max(raw, 1e-6);
  }

  int get count => _count;
}

class _DeltaBundle {
  const _DeltaBundle({
    required this.retentionDelta,
    required this.engagementDelta,
    required this.completionDelta,
    required this.sessionDelta,
    required this.retentionZ,
    required this.engagementZ,
    required this.completionZ,
    required this.sessionZ,
    required this.verdict,
    required this.notes,
  });

  factory _DeltaBundle.from(_VariantStats a, _VariantStats b) {
    double z(_MetricAccumulator left, _MetricAccumulator right) {
      if (left.count == 0 || right.count == 0) return 0;
      final denom = sqrt(
        (left.variance / left.count) + (right.variance / right.count),
      );
      if (denom == 0) return 0;
      return (right.mean - left.mean) / denom;
    }

    double delta(_MetricAccumulator left, _MetricAccumulator right) =>
        right.mean - left.mean;

    final retentionDelta = delta(a.retention, b.retention);
    final engagementDelta = delta(a.engagement, b.engagement);
    final completionDelta = delta(a.completion, b.completion);
    final sessionDelta = delta(a.session, b.session);

    final retentionZ = z(a.retention, b.retention);
    final engagementZ = z(a.engagement, b.engagement);
    final completionZ = z(a.completion, b.completion);
    final sessionZ = z(a.session, b.session);

    final score = <double>[
      retentionDelta,
      engagementDelta / 2,
      completionDelta,
    ].fold<double>(0, (acc, value) => acc + value);

    final verdict = score > 0.5
        ? 'Variant B improves KPIs'
        : score < -0.5
        ? 'Variant A remains superior'
        : 'Inconclusive';

    final confidence = [
      retentionZ.abs(),
      engagementZ.abs(),
      completionZ.abs(),
    ].reduce(max);
    final notes = confidence >= 1.96
        ? 'Statistically meaningful lift.'
        : 'Needs more data.';

    return _DeltaBundle(
      retentionDelta: retentionDelta,
      engagementDelta: engagementDelta,
      completionDelta: completionDelta,
      sessionDelta: sessionDelta,
      retentionZ: retentionZ,
      engagementZ: engagementZ,
      completionZ: completionZ,
      sessionZ: sessionZ,
      verdict: verdict,
      notes: notes,
    );
  }

  final double retentionDelta;
  final double engagementDelta;
  final double completionDelta;
  final double sessionDelta;
  final double retentionZ;
  final double engagementZ;
  final double completionZ;
  final double sessionZ;
  final String verdict;
  final String notes;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double? _msToMinutes(Object? value) {
  final doubleValue = _toDouble(value);
  if (doubleValue == null) return null;
  return (doubleValue / 60000).clamp(0.1, 120);
}

double? _mean(List<double?> values) {
  final filtered = values.whereType<double>().toList();
  if (filtered.isEmpty) return null;
  final sum = filtered.fold<double>(0, (acc, value) => acc + value);
  return sum / filtered.length;
}

bool _belongsToA(String seed, double ratio) {
  final hash = _stableHash(seed);
  final normalized = (hash & 0x7fffffff) / 0x7fffffff;
  return normalized < ratio;
}

int _stableHash(String input) {
  const int fnvPrime = 0x01000193;
  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0xffffffff;
  }
  return hash;
}

String _formatDelta(double value) {
  final rounded = _round(value);
  final sign = rounded >= 0 ? '+' : '';
  return '$sign$rounded%';
}

String _formatDeltaMinutes(double value) {
  final rounded = _round(value);
  final sign = rounded >= 0 ? '+' : '';
  return '$sign$rounded min';
}

String _significance(double z) {
  final absValue = z.abs();
  if (absValue >= 2.58) return 'p<0.01';
  if (absValue >= 1.96) return 'p<0.05';
  if (absValue >= 1.28) return 'directional';
  return 'insufficient';
}

double _round(double value) => (value.isNaN || value.isInfinite)
    ? 0
    : double.parse(value.toStringAsFixed(2));

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
