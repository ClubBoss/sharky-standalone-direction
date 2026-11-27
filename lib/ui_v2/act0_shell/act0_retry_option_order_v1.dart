import 'dart:math';

/// Stable across rebuilds; the triggering completed attempt supplies the seed.
/// Preserve option objects (including their IDs, grades and feedback).
List<T> act0RetryOptionOrderV1<T>(
  List<T> previous,
  String attemptKey, {
  required bool Function(T) isPreferred,
}) {
  if (previous.length < 2) return previous;
  // A stable hash rather than Object.hashCode, which is process-dependent.
  var seed = 0;
  for (final unit in attemptKey.codeUnits) {
    seed = (seed * 31 + unit) & 0x7fffffff;
  }
  final result = [...previous]..shuffle(Random(seed));
  final preferred = previous.where(isPreferred).toList();
  // Keep the first preferred ID canonical even when multiple options pass.
  // Only their positions may move, not the relative preferred order.
  var next = 0;
  for (var i = 0; i < result.length; i++) {
    if (isPreferred(result[i])) result[i] = preferred[next++];
  }
  final correct = previous.indexWhere(isPreferred);
  if (correct >= 0 && result[correct] == previous[correct]) {
    final alternatives = [
      for (var i = 0; i < result.length; i++)
        if (!isPreferred(result[i])) i,
    ];
    if (alternatives.isNotEmpty) {
      final other = alternatives[Random(seed).nextInt(alternatives.length)];
      final option = result.removeAt(other);
      result.insert(correct, option);
    }
  }
  return result;
}
