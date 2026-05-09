import 'dart:convert';
import 'dart:io';
import 'adaptive_reward_engine.dart' as are;

/// Aggregates UI metric samples into a per-screen summary file (ui_metrics.json).
///
/// Input: ui_metrics_events.jsonl (newline-delimited JSON records)
///   {"t":"2025-11-01T12:00:00Z","ms":16}
/// plus optional event lines produced by in-app logging of the form:
///   {"event":"ui_metrics","screen":"...","avgFps":58.2,"avgFrameMs":17.1,"samples":240}
///
/// Output: ui_metrics.json
///   {
///     "screens": {
///       "MainNavigationScreen": {"avgFps": 57.2, "avgFrameMs": 17.5, "samples": 1024},
///       "TrainingSessionScreen": {"avgFps": 54.0, "avgFrameMs": 18.5, "samples": 640}
///     },
///     "animations": { "avgTransitionMs": 241.6, "count": 48 },
///     "navigation": { "avgDurationMs": 180.0, "count": 32, "routes": {"/home": {"avgDurationMs": 160.0, "count": 10}} },
///     "updatedAt": "..."
///   }
Future<void> main(List<String> args) async {
  final eventsFile = File('ui_metrics_events.jsonl');
  final outFile = File('ui_metrics.json');
  if (!eventsFile.existsSync()) {
    stdout.writeln('No raw UI metric events found (ui_metrics_events.jsonl).');
    await outFile.writeAsString(
      jsonEncode({
        'screens': <String, Object>{},
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
    return;
  }

  // Aggregate by screen if available; otherwise into a global bucket
  final perScreen = <String, _Agg>{};
  final animAgg = _AnimAgg();
  final navOverall = _NavAgg();
  final navPerRoute = <String, _NavAgg>{};

  await for (final line
      in eventsFile
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
    if (line.trim().isEmpty) continue;
    Map<String, dynamic> obj;
    try {
      obj = jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    if (obj.containsKey('event') && obj['event'] == 'ui_metrics') {
      final screen = (obj['screen'] as String?)?.trim();
      if (screen == null || screen.isEmpty) continue;
      final fps = (obj['avgFps'] as num?)?.toDouble();
      final ms = (obj['avgFrameMs'] as num?)?.toDouble();
      final samples = (obj['samples'] as num?)?.toInt() ?? 0;
      final agg = perScreen.putIfAbsent(screen, _Agg.new);
      if (fps != null) agg.addFps(fps, samples);
      if (ms != null) agg.addMs(ms, samples);
    } else if (obj.containsKey('event') && obj['event'] == 'ui_anim') {
      // Animation summary or sample
      final ms =
          (obj['avgTransitionMs'] as num?)?.toDouble() ??
          (obj['ms'] as num?)?.toDouble();
      final count = (obj['count'] as num?)?.toInt();
      if (ms != null) {
        animAgg.add(ms, count ?? 1);
      }
    } else if (obj.containsKey('ms')) {
      // Check for navigation sample lines
      final ev = obj['event'];
      if (ev == 'ui_nav') {
        final route = (obj['route'] as String?)?.trim();
        final avg = (obj['avgDurationMs'] as num?)?.toDouble();
        final ms = (obj['ms'] as num?)?.toDouble();
        final count = (obj['count'] as num?)?.toInt();
        final weight = (count ?? 1) > 0 ? (count ?? 1) : 1;
        final v = avg ?? ms;
        if (v != null) {
          navOverall.add(v, weight);
          if (route != null && route.isNotEmpty) {
            (navPerRoute[route] ??= _NavAgg()).add(v, weight);
          }
        }
        continue;
      }
      // Raw frame time sample without screen context → put under 'global'
      final ms = (obj['ms'] as num?)?.toDouble();
      if (ms == null) continue;
      final agg = perScreen.putIfAbsent('global', _Agg.new);
      agg.addMs(ms, 1);
    }
  }

  final result = <String, Object>{};
  perScreen.forEach((screen, agg) {
    result[screen] = {
      'avgFps': agg.avgFps,
      'avgFrameMs': agg.avgMs,
      'samples': agg.samples,
    };
  });

  // Compute adaptive drift and maintain rolling history (last 10 values)
  final drift = await are.computeAdaptiveRewardDrift(playerLevel: 1);
  final prevJson = await _readExistingUiMetrics(outFile);
  final prevHistory = (prevJson['adaptive_drift_history'] is List)
      ? List<double>.from(
          (prevJson['adaptive_drift_history'] as List)
              .where((e) => e is num)
              .map((e) => (e as num).toDouble()),
        )
      : <double>[];
  prevHistory.add((drift['avgPercent'] as num?)?.toDouble() ?? 0.0);
  // keep last 10
  final trimmedHistory = prevHistory.length > 10
      ? prevHistory.sublist(prevHistory.length - 10)
      : prevHistory;

  final out = {
    'screens': result,
    'animations': {'avgTransitionMs': animAgg.avg, 'count': animAgg.samples},
    'navigation': {
      'avgDurationMs': navOverall.avg,
      'count': navOverall.samples,
      'routes': {
        for (final e in navPerRoute.entries)
          e.key: {'avgDurationMs': e.value.avg, 'count': e.value.samples},
      },
    },
    'adaptive_drift_history': trimmedHistory,
    'adaptive_drift_latest': drift,
    'updatedAt': DateTime.now().toIso8601String(),
  };
  await outFile.writeAsString(jsonEncode(out));
  stdout.writeln('ui_metrics.json written with ${result.length} screen(s).');
}

Future<Map<String, dynamic>> _readExistingUiMetrics(File outFile) async {
  try {
    if (!await outFile.exists()) return const {};
    final raw = await outFile.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return const {};
}

class _Agg {
  double _sumFps = 0;
  int _fpsWeight = 0;
  double _sumMs = 0;
  int _msWeight = 0;

  void addFps(double fps, int weight) {
    final w = weight > 0 ? weight : 1;
    _sumFps += fps * w;
    _fpsWeight += w;
  }

  void addMs(double ms, int weight) {
    final w = weight > 0 ? weight : 1;
    _sumMs += ms * w;
    _msWeight += w;
  }

  double get avgFps => _fpsWeight == 0
      ? 0.0
      : double.parse((_sumFps / _fpsWeight).toStringAsFixed(1));
  double get avgMs => _msWeight == 0
      ? 0.0
      : double.parse((_sumMs / _msWeight).toStringAsFixed(2));
  int get samples => _msWeight;
}

class _AnimAgg {
  double _sumMs = 0;
  int _weight = 0;
  void add(double ms, int weight) {
    final w = weight > 0 ? weight : 1;
    _sumMs += ms * w;
    _weight += w;
  }

  double get avg =>
      _weight == 0 ? 0.0 : double.parse((_sumMs / _weight).toStringAsFixed(1));
  int get samples => _weight;
}

class _NavAgg {
  double _sumMs = 0;
  int _weight = 0;
  void add(double ms, int weight) {
    final w = weight > 0 ? weight : 1;
    _sumMs += ms * w;
    _weight += w;
  }

  double get avg =>
      _weight == 0 ? 0.0 : double.parse((_sumMs / _weight).toStringAsFixed(1));
  int get samples => _weight;
}
