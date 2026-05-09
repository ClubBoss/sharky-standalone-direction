import 'mood_vector_v4.dart';
import 'tone_vector_v4.dart';

class EmotionEngineV4 {
  const EmotionEngineV4({
    this.mood,
    this.tone,
    this.moodVector,
    this.toneVector,
    this.arousal,
    this.valence,
    this.moodStability,
    this.arousalStability,
    this.moodRegulation,
    this.toneRegulation,
    this.arousalRegulation,
    this.valenceRegulation,
    this.moodCoherence,
    this.toneCoherence,
    this.arousalCoherence,
    this.valenceCoherence,
    this.moodFusion,
    this.toneFusion,
    this.arousalFusion,
    this.valenceFusion,
  });

  final Object? mood;
  final Object? tone;
  final MoodVectorV4? moodVector;
  final ToneVectorV4? toneVector;
  final double? arousal;
  final double? valence;
  final double? moodStability;
  final double? arousalStability;
  final double? moodRegulation;
  final double? toneRegulation;
  final double? arousalRegulation;
  final double? valenceRegulation;
  final double? moodCoherence;
  final double? toneCoherence;
  final double? arousalCoherence;
  final double? valenceCoherence;
  final double? moodFusion;
  final double? toneFusion;
  final double? arousalFusion;
  final double? valenceFusion;

  double get baseMood => _toDouble(mood) ?? 0.0;
  double get baseTone => _toDouble(tone) ?? 0.0;
  double get baseArousal => _toDouble(arousal) ?? 0.0;
  double get baseValence => _toDouble(valence) ?? 0.0;

  Map<String, Object?> asPassiveLogicMap() => {
    'baseMood': baseMood,
    'baseTone': baseTone,
    'baseArousal': baseArousal,
    'baseValence': baseValence,
  };

  double? _resolveMood() {
    return _toDouble(mood) ??
        _average([
          moodVector?.calm,
          moodVector?.focus,
          moodVector?.confidence,
        ]) ??
        0.0;
  }

  double? _resolveTone() {
    return _toDouble(tone) ??
        _average([
          toneVector?.softness,
          toneVector?.sharpness,
          toneVector?.warmth,
        ]) ??
        0.0;
  }

  double? _resolveArousal() {
    return _toDouble(arousal) ??
        _average([moodVector?.stress, toneVector?.sharpness]) ??
        0.0;
  }

  double? _resolveValence() {
    return _toDouble(valence) ??
        _average([
          toneVector?.warmth,
          toneVector?.neutrality,
          moodVector?.confidence,
        ]) ??
        0.0;
  }

  double? _average(Iterable<double?> values) {
    final list = values.where((value) => value != null).cast<double>().toList();
    if (list.isEmpty) return null;
    final sum = list.reduce((a, b) => a + b);
    return sum / list.length;
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{
      'mood': _resolveMood(),
      'tone': _resolveTone(),
      'arousal': _resolveArousal(),
      'valence': _resolveValence(),
      'moodStability': moodStability,
      'arousalStability': arousalStability,
      'moodRegulation': moodRegulation,
      'toneRegulation': toneRegulation,
      'arousalRegulation': arousalRegulation,
      'valenceRegulation': valenceRegulation,
      'moodCoherence': moodCoherence,
      'toneCoherence': toneCoherence,
      'arousalCoherence': arousalCoherence,
      'valenceCoherence': valenceCoherence,
      'moodFusion': moodFusion,
      'toneFusion': toneFusion,
      'arousalFusion': arousalFusion,
      'valenceFusion': valenceFusion,
    };
    if (moodVector != null) {
      map['moodVector'] = moodVector!.asReadOnlyMap();
    }
    if (toneVector != null) {
      map['toneVector'] = toneVector!.asReadOnlyMap();
    }
    return map;
  }
}
