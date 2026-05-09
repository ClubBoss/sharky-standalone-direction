import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/services/ux_feedback_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final file = File('tools/_reports/unified_telemetry_summary.json');
    if (await file.exists()) {
      await file.delete();
    }
    UxFeedbackManager.instance.resetSessionCounters();
  });

  group('UxFeedbackManager smoke', () {
    test('grantReward and playFeedback complete without errors', () {
      final manager = UxFeedbackManager.instance;
      expect(manager, isA<UxFeedbackManager>());

      manager.grantReward(xp: 3, chips: 2);
      manager.playFeedback(haptic: true, sound: true);
    });

    test('adaptive rewards boost high confidence with low latency', () async {
      await _writeUnifiedTelemetry(confidence: 80, latencyMs: 180);
      final manager = UxFeedbackManager.instance;
      final result = await manager.computeAdaptiveReward(xp: 100, chips: 50);
      expect(result.scalingFactor, closeTo(1.2, 0.01));
      expect(result.adjustedXp, 120);
      expect(result.adjustedChips, 60);
    });

    test('adaptive rewards stay flat for medium confidence', () async {
      await _writeUnifiedTelemetry(confidence: 55, latencyMs: 320);
      final manager = UxFeedbackManager.instance;
      final result = await manager.computeAdaptiveReward(xp: 100, chips: 50);
      expect(result.scalingFactor, closeTo(1.0, 0.01));
      expect(result.adjustedXp, 100);
      expect(result.adjustedChips, 50);
    });

    test(
      'adaptive rewards decrease for low confidence or high latency',
      () async {
        await _writeUnifiedTelemetry(confidence: 25, latencyMs: 750);
        final manager = UxFeedbackManager.instance;
        final result = await manager.computeAdaptiveReward(xp: 100, chips: 50);
        expect(result.scalingFactor, closeTo(0.8, 0.01));
        expect(result.adjustedXp, 80);
        expect(result.adjustedChips, 40);
      },
    );
  });
}

Future<void> _writeUnifiedTelemetry({
  required double confidence,
  required double latencyMs,
}) async {
  final file = File('tools/_reports/unified_telemetry_summary.json');
  file.parent.createSync(recursive: true);
  final payload = <String, dynamic>{
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'feeds_merged': 3,
    'derived_metrics': <String, dynamic>{
      'avg_confidence': confidence,
      'avg_ev_diff': 0.0,
      'avg_latency_ms': latencyMs,
      'retention_score': 50.0,
      'status': 'PASS [OK]',
    },
    'advisor': const <String, dynamic>{},
    'feedback': const <String, dynamic>{},
    'ux': const <String, dynamic>{},
  };
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
}
