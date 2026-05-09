import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _summaryPath =
    'release/_reports/adaptive_ad_optimizer_summary.txt';
const String _telemetryOut = 'release/_reports/telemetry.jsonl';
const double _ewmaAlpha = 0.4;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final placements = await _collectPlacementStats();
  if (placements.isEmpty) {
    throw StateError(
      'No telemetry impression/click/conversion events were found.',
    );
  }

  final recommendations =
      placements.entries.map((entry) {
        final placement = entry.key;
        final stats = entry.value;
        final ctr = stats.impressions == 0
            ? 0.0
            : stats.clicks / stats.impressions;
        final cvr = stats.clicks == 0 ? 0.0 : stats.conversions / stats.clicks;
        final revenue = stats.conversions * stats.avgRevenue;
        final historicalCtr = _ewma(stats.ctrHistory);
        final trend = ctr - historicalCtr;
        final weight = trend >= 0
            ? (0.7 + trend).clamp(0.5, 1.5)
            : (0.7 + trend).clamp(0.25, 0.9);

        return _PlacementRecommendation(
          placement: placement,
          ctr: ctr,
          conversionRate: cvr,
          revenuePerPlacement: revenue,
          recommendedWeight: double.parse(weight.toStringAsFixed(2)),
          trend: trend,
        );
      }).toList()..sort(
        (a, b) => b.revenuePerPlacement.compareTo(a.revenuePerPlacement),
      );

  await _withReportsWritable(() async {
    await _writeSummary(recommendations, stopwatch.elapsedMilliseconds);
    await _emitTelemetry(recommendations, stopwatch.elapsedMilliseconds);
  });

  stdout.writeln('adaptive_ad_optimizer: placements=${recommendations.length}');
}

Future<Map<String, _PlacementStats>> _collectPlacementStats() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) {
    throw StateError('Telemetry file missing at $_telemetryPath');
  }

  final stats = <String, _PlacementStats>{};
  final lines = await file.readAsLines();
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
    final placement = payload['placement']?.toString();
    if (placement == null) continue;

    final entry = stats.putIfAbsent(
      placement,
      () => _PlacementStats(placement),
    );

    switch (event) {
      case 'ad_impression':
        entry.impressions++;
        if (payload['ctr'] != null) {
          entry.ctrHistory.add(_toDouble(payload['ctr']) ?? 0);
        }
        break;
      case 'ad_click':
        entry.clicks++;
        break;
      case 'ad_conversion':
        entry.conversions++;
        entry.avgRevenue = _toDouble(payload['revenue']) ?? entry.avgRevenue;
        break;
      default:
        continue;
    }
  }

  return stats.map(MapEntry.new);
}

Future<void> _writeSummary(
  List<_PlacementRecommendation> recommendations,
  int durationMs,
) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE AD OPTIMIZER SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln()
    ..writeln('Placement | CTR | CVR | Revenue | Trend | Weight')
    ..writeln('----------+-----+-----+---------+-------+--------');
  for (final rec in recommendations) {
    buffer.writeln(
      '${rec.placement.padRight(10)} | '
      '${(rec.ctr * 100).toStringAsFixed(1)}% | '
      '${(rec.conversionRate * 100).toStringAsFixed(1)}% | '
      '\$${rec.revenuePerPlacement.toStringAsFixed(2)} | '
      '${rec.trend.toStringAsFixed(3)} | '
      '${rec.recommendedWeight}',
    );
  }
  buffer.writeln();

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry(
  List<_PlacementRecommendation> recommendations,
  int durationMs,
) async {
  final payload = <String, Object?>{
    'event': 'adaptive_ad_optimizer_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'placements': recommendations
        .map(
          (rec) => {
            'placement': rec.placement,
            'ctr': rec.ctr,
            'conversion_rate': rec.conversionRate,
            'revenue': rec.revenuePerPlacement,
            'weight': rec.recommendedWeight,
          },
        )
        .toList(),
    'duration_ms': durationMs,
  };

  await File(_telemetryOut).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _PlacementStats {
  _PlacementStats(this.placement);

  final String placement;
  int impressions = 0;
  int clicks = 0;
  int conversions = 0;
  double avgRevenue = 0;
  final List<double> ctrHistory = <double>[];
}

class _PlacementRecommendation {
  const _PlacementRecommendation({
    required this.placement,
    required this.ctr,
    required this.conversionRate,
    required this.revenuePerPlacement,
    required this.recommendedWeight,
    required this.trend,
  });

  final String placement;
  final double ctr;
  final double conversionRate;
  final double revenuePerPlacement;
  final double recommendedWeight;
  final double trend;
}

double _ewma(List<double> values) {
  if (values.isEmpty) return 0;
  var result = values.first;
  for (var i = 1; i < values.length; i++) {
    result = _ewmaAlpha * values[i] + (1 - _ewmaAlpha) * result;
  }
  return result;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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
