import 'emotion_preflight_v4.dart';

class EmotionPreflightConsistencyV4 {
  const EmotionPreflightConsistencyV4({
    this.moodConsistent,
    this.toneConsistent,
    this.arousalConsistent,
    this.valenceConsistent,
  });

  final bool? moodConsistent;
  final bool? toneConsistent;
  final bool? arousalConsistent;
  final bool? valenceConsistent;

  factory EmotionPreflightConsistencyV4.fromPreflight(
    EmotionPreflightV4 preflight,
  ) {
    return EmotionPreflightConsistencyV4(
      moodConsistent: preflight.hasMood,
      toneConsistent: preflight.hasTone,
      arousalConsistent: preflight.hasArousal,
      valenceConsistent: preflight.hasValence,
    );
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (moodConsistent != null) map['moodConsistent'] = moodConsistent;
    if (toneConsistent != null) map['toneConsistent'] = toneConsistent;
    if (arousalConsistent != null) {
      map['arousalConsistent'] = arousalConsistent;
    }
    if (valenceConsistent != null) {
      map['valenceConsistent'] = valenceConsistent;
    }
    return map;
  }
}
