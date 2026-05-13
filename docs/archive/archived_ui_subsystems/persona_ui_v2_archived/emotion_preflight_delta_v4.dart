import 'emotion_preflight_consistency_v4.dart';
import 'emotion_preflight_v4.dart';

class EmotionPreflightDeltaV4 {
  const EmotionPreflightDeltaV4({
    this.moodDelta,
    this.toneDelta,
    this.arousalDelta,
    this.valenceDelta,
  });

  final bool? moodDelta;
  final bool? toneDelta;
  final bool? arousalDelta;
  final bool? valenceDelta;

  factory EmotionPreflightDeltaV4.fromPreflightAndConsistency(
    EmotionPreflightV4 preflight,
    EmotionPreflightConsistencyV4 consistency,
  ) {
    final moodConsistent = consistency.moodConsistent ?? false;
    final toneConsistent = consistency.toneConsistent ?? false;
    final arousalConsistent = consistency.arousalConsistent ?? false;
    final valenceConsistent = consistency.valenceConsistent ?? false;
    return EmotionPreflightDeltaV4(
      moodDelta: !(moodConsistent),
      toneDelta: !(toneConsistent),
      arousalDelta: !(arousalConsistent),
      valenceDelta: !(valenceConsistent),
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (moodDelta != null) map['moodDelta'] = moodDelta;
    if (toneDelta != null) map['toneDelta'] = toneDelta;
    if (arousalDelta != null) map['arousalDelta'] = arousalDelta;
    if (valenceDelta != null) map['valenceDelta'] = valenceDelta;
    return map;
  }
}
