import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final history = await _readJson('adaptive_history.json');
  final tuning = await _readJson('economy_tuning.json');

  final records = (history?['records'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(Map<String, dynamic>.from)
      .toList();

  final stabilitySeries = records
      .where((r) => r['stability'] is num)
      .map((r) => _SeriesPoint(r['timestamp'], _asDouble(r['stability'])))
      .toList();
  final driftSeries = records
      .where((r) => r['drift'] is num)
      .map((r) => _SeriesPoint(r['timestamp'], _asDouble(r['drift'])))
      .toList();

  final stabilityTrend = _computeTrend(stabilitySeries);
  final driftTrend = _computeTrend(driftSeries);

  final latestXp = _asDouble(
    tuning?['xpFactor'] ?? tuning?['xp_factor'],
    fallback: 1.0,
  );
  final latestRefill = _asDouble(
    tuning?['refillMinutes'] ?? tuning?['refill'],
    fallback: 30.0,
  );

  final forecast = _forecastValues(
    stabilityTrend: stabilityTrend,
    driftTrend: driftTrend,
    baseXp: latestXp,
    baseRefill: latestRefill,
    steps: 10,
  );

  final volatility = _computeVolatility(driftSeries);
  final riskLevel = _riskLevel(volatility, stabilityTrend.slope);
  final pass = riskLevel != 'High' && stabilityTrend.slope >= -0.02;

  final trendPct = stabilityTrend.slope * 100;
  final trendSign = trendPct >= 0 ? '+' : '';
  stdout.writeln(
    'Adaptive Forecast: ${pass ? 'PASS' : 'FAIL'} '
    '(Δ stability $trendSign${trendPct.toStringAsFixed(1)} %, risk $riskLevel)',
  );

  final jsonPayload = {
    'trend_stability': double.parse(stabilityTrend.slope.toStringAsFixed(4)),
    'trend_drift': double.parse(driftTrend.slope.toStringAsFixed(4)),
    'forecast_drift': forecast.drift,
    'forecast_stability': forecast.stability,
    'forecast_xp': forecast.xp,
    'forecast_refill': forecast.refill,
    'risk_level': riskLevel,
    'volatility': double.parse(volatility.toStringAsFixed(4)),
    'pass': pass,
  };
  stdout.writeln(jsonEncode(jsonPayload));

  await File('adaptive_forecast.json').writeAsString(jsonEncode(jsonPayload));
}

class _SeriesPoint {
  final DateTime time;
  final double value;

  _SeriesPoint(String? timestamp, double value)
    : time = timestamp != null
          ? DateTime.tryParse(timestamp) ?? DateTime.now()
          : DateTime.now(),
      value = value;
}

class _Trend {
  final double slope;
  final double intercept;

  _Trend({required this.slope, required this.intercept});
}

class _Forecast {
  final List<double> drift;
  final List<double> stability;
  final List<double> xp;
  final List<double> refill;

  _Forecast({
    required this.drift,
    required this.stability,
    required this.xp,
    required this.refill,
  });
}

_Trend _computeTrend(List<_SeriesPoint> series) {
  if (series.length < 2)
    return _Trend(
      slope: 0,
      intercept: series.isNotEmpty ? series.last.value : 0,
    );
  final base = series.first.time;
  final xs = <double>[];
  final ys = <double>[];
  for (final point in series) {
    xs.add(
      base == point.time ? 0 : point.time.difference(base).inDays.toDouble(),
    );
    ys.add(point.value);
  }
  final n = xs.length.toDouble();
  final sumX = xs.reduce((a, b) => a + b);
  final sumY = ys.reduce((a, b) => a + b);
  final sumXY = List.generate(
    xs.length,
    (i) => xs[i] * ys[i],
  ).reduce((a, b) => a + b);
  final sumXX = xs.map((x) => x * x).reduce((a, b) => a + b);
  final denominator = n * sumXX - sumX * sumX;
  if (denominator == 0) {
    return _Trend(slope: 0, intercept: ys.last);
  }
  final slope = (n * sumXY - sumX * sumY) / denominator;
  final intercept = (sumY - slope * sumX) / n;
  return _Trend(slope: slope, intercept: intercept);
}

_Forecast _forecastValues({
  required _Trend stabilityTrend,
  required _Trend driftTrend,
  required double baseXp,
  required double baseRefill,
  required int steps,
}) {
  final drift = <double>[];
  final stability = <double>[];
  final xp = <double>[];
  final refill = <double>[];

  for (var i = 1; i <= steps; i++) {
    final futureDrift = driftTrend.intercept + driftTrend.slope * i;
    final futureStability =
        (stabilityTrend.intercept + stabilityTrend.slope * i).clamp(0.0, 1.5);
    final futureXp = (baseXp - futureDrift * 0.5).clamp(0.8, 1.2);
    final futureRefill = (baseRefill + futureStability * 0.1).clamp(15.0, 60.0);
    drift.add(double.parse(futureDrift.toStringAsFixed(4)));
    stability.add(double.parse(futureStability.toStringAsFixed(4)));
    xp.add(double.parse(futureXp.toStringAsFixed(3)));
    refill.add(double.parse(futureRefill.toStringAsFixed(2)));
  }

  return _Forecast(drift: drift, stability: stability, xp: xp, refill: refill);
}

double _computeVolatility(List<_SeriesPoint> series) {
  if (series.length < 2) return 0.0;
  final driftValues = series.map((p) => p.value).toList();
  final mean = driftValues.reduce((a, b) => a + b) / driftValues.length;
  final variance =
      driftValues.map((v) => pow((v - mean), 2)).reduce((a, b) => a + b) /
      driftValues.length;
  return sqrt(variance);
}

String _riskLevel(double volatility, double slope) {
  if (volatility > 0.15 || slope < -0.05) return 'High';
  if (volatility > 0.08 || slope < -0.02) return 'Medium';
  return 'Low';
}

Future<Map<String, dynamic>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return null;
}

double _asDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}
