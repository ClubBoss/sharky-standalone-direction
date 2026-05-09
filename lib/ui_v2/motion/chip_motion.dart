import 'dart:ui';

class ChipMotion {
  ChipMotion({
    required this.startOffset,
    required this.controlOffset,
    required this.endOffset,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.amount,
  });

  final Offset startOffset;
  final Offset controlOffset;
  final Offset endOffset;
  final double startTimeMs;
  final double endTimeMs;
  final double amount;

  double _progress(double nowMs) {
    if (nowMs <= startTimeMs) return 0.0;
    if (nowMs >= endTimeMs) return 1.0;
    final duration = endTimeMs - startTimeMs;
    if (duration <= 0) return 1.0;
    return (nowMs - startTimeMs) / duration;
  }

  Offset computePosition(double nowMs) {
    final t = _progress(nowMs);
    final oneMinus = 1.0 - t;
    return Offset(
      oneMinus * oneMinus * startOffset.dx +
          2 * oneMinus * t * controlOffset.dx +
          t * t * endOffset.dx,
      oneMinus * oneMinus * startOffset.dy +
          2 * oneMinus * t * controlOffset.dy +
          t * t * endOffset.dy,
    );
  }

  bool isDone(double nowMs) => nowMs >= endTimeMs;
}
