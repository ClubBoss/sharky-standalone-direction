import 'package:test/test.dart';
import 'package:poker_analyzer/services/adaptive_loop_v3_engine.dart';
import 'package:poker_analyzer/services/adaptive_loop_v2_engine.dart' as v2;
import 'package:poker_analyzer/services/adaptive_pacing_engine.dart';
import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';

void main() {
  group('Adaptive Loop V3 Smoke', () {
    test('runAdaptiveLoopV3 returns non-null report', () async {
      final report = await runAdaptiveLoopV3();
      expect(report, isNotNull);
      expect(report, isA<Map<String, Object>>());
    });

    test('runAdaptiveLoopV2 returns valid result', () async {
      final result = await v2.runAdaptiveLoopV2();
      expect(result, isNotNull);
      expect(result, isA<Map<String, Object>>());
    });

    test('AdaptivePacingEngine computePace returns valid value', () {
      final pace = AdaptivePacingEngine.computePace(
        momentum: 0.5,
        fatigue: 0.3,
        fps: 60.0,
      );
      expect(pace, greaterThan(0.0));
      expect(pace, lessThan(2.0));
    });

    test('EmotionAdaptiveEngine getAdaptiveTone returns valid preset', () {
      final engine = EmotionAdaptiveEngine.instance;
      final preset = engine.getAdaptiveTone(sentiment: 0.5, consistency: 0.8);
      expect(preset, isIn(['calm', 'motivating', 'energetic']));
    });
  });
}
