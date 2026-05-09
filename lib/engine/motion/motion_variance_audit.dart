import 'dart:ui';
import 'dart:math' as math;

import '../motion_frame_composer.dart';
import '../motion_playback_adapter.dart';

class VarianceResult {
  const VarianceResult({
    required this.delta,
    required this.variance,
    required this.unstable,
  });

  final double delta;
  final double variance;
  final bool unstable;
}

class MotionVarianceAudit {
  MotionVarianceAudit({this.windowSize = 24, this.threshold = 0.035});

  final int windowSize;
  final double threshold;
  final Map<String, Offset> _previous = {};
  final Map<String, List<double>> _history = {};

  Map<String, VarianceResult> update(MotionFrameSnapshot? snapshot) {
    if (snapshot == null) {
      return const {};
    }
    final results = <String, VarianceResult>{};
    final entries = <String, MotionPlaybackSample?>{
      ...snapshot.channels.seat,
      ...snapshot.channels.board,
      ...snapshot.channels.pot,
    };
    for (final entry in entries.entries) {
      final sample = entry.value;
      if (sample == null) {
        continue;
      }
      final prevPos = _previous[entry.key];
      final current = Offset(sample.x, sample.y);
      final delta = prevPos == null ? 0.0 : (current - prevPos).distance;
      _previous[entry.key] = current;
      final history = _history.putIfAbsent(entry.key, () => <double>[]);
      history.add(delta);
      if (history.length > windowSize) {
        history.removeAt(0);
      }
      final mean =
          history.fold(0.0, (sum, value) => sum + value) /
          (history.isEmpty ? 1 : history.length);
      double variance = 0.0;
      for (final value in history) {
        final diff = value - mean;
        variance += diff * diff;
      }
      variance = variance / (history.isEmpty ? 1 : history.length);
      final unstable = variance > threshold;
      results[entry.key] = VarianceResult(
        delta: delta,
        variance: variance,
        unstable: unstable,
      );
    }
    _lastResults = Map.unmodifiable(results);
    return results;
  }

  Map<String, VarianceResult> _lastResults = {};

  bool get hasUnstable => _lastResults.values.any((result) => result.unstable);

  int get unstableCount =>
      _lastResults.values.where((result) => result.unstable).length;

  double get maxVariance => _lastResults.values.fold(
    0.0,
    (prev, result) => math.max(prev, result.variance),
  );

  List<String> get unstableIds {
    final entries =
        _lastResults.entries.where((entry) => entry.value.unstable).toList()
          ..sort((a, b) => b.value.variance.compareTo(a.value.variance));
    return entries.take(5).map((entry) => entry.key).toList();
  }

  double varianceFor(String id) => _lastResults[id]?.variance ?? 0.0;
}
