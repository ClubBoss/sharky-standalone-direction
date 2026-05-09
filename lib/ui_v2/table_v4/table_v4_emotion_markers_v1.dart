import 'package:flutter/material.dart';

/// Simple emotion marker overlay used inside the Table V4 preview path.
class TableV4EmotionMarkersV1 extends StatelessWidget {
  const TableV4EmotionMarkersV1({
    super.key,
    required this.emotionMap,
    this.typographyInjectorMap,
    this.spacingMap,
  });

  final Map<String, Object> emotionMap;
  final Map<String, Object?>? typographyInjectorMap;
  final Map<String, Object?>? spacingMap;

  static const Map<String, Color> _moodColors = <String, Color>{
    'calm': Color(0xff4caf50),
    'focus': Color(0xff2196f3),
    'tension': Color(0xffffc107),
    'tilt': Color(0xfff44336),
  };

  @override
  Widget build(BuildContext context) {
    final bool ready = emotionMap['ready'] == true;
    final String mood = _ascii(
      (emotionMap['mood'] as String? ?? 'none').toLowerCase(),
    );
    if (!ready || mood == 'none') {
      return const SizedBox.shrink();
    }
    final int intensity = _clampIntensity(emotionMap['intensity']);
    final double size = 12.0 + 2.0 * intensity;
    final Color color = _moodColors[mood] ?? _moodColors['calm']!;
    final double opacity = (0.4 + 0.1 * intensity).clamp(0.0, 1.0);
    final double offsetX = _clampOffset(
      spacingMap?['emotion_dx'] ?? spacingMap?['label_dx'],
    );
    final double offsetY = _clampOffset(
      spacingMap?['emotion_dy'] ?? spacingMap?['label_dy'],
    );
    final String label = _resolveLabel(mood);
    return Align(
      alignment: Alignment.topCenter,
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(opacity),
              ),
            ),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _clampIntensity(Object? value) {
    if (value is int) return value.clamp(0, 5);
    if (value is num) return value.toInt().clamp(0, 5);
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) return parsed.clamp(0, 5);
    }
    return 1;
  }

  double _clampOffset(Object? value) {
    double raw = 0.0;
    if (value is num) {
      raw = value.toDouble();
    } else if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) raw = parsed;
    }
    return raw.clamp(-12.0, 12.0);
  }

  String _resolveLabel(String mood) {
    final String? override = typographyInjectorMap?['emotion_label'] as String?;
    if (override != null && override.isNotEmpty) {
      return _ascii(override);
    }
    final String moodKey = 'emotion_label_$mood';
    final String? moodOverride = typographyInjectorMap?[moodKey] as String?;
    if (moodOverride != null && moodOverride.isNotEmpty) {
      return _ascii(moodOverride);
    }
    if (mood.isEmpty) return '';
    return mood[0].toUpperCase() + mood.substring(1);
  }

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
