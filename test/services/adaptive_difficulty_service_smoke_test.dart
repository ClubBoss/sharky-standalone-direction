import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/adaptive_difficulty_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveDifficultyService', () {
    late File telemetryFile;
    late File releaseTelemetryFile;
    late File cacheFile;
    String? telemetryBackup;
    String? releaseTelemetryBackup;
    String? cacheBackup;

    setUp(() {
      telemetryFile = File('tools/_reports/unified_telemetry_summary.json');
      releaseTelemetryFile = File(
        'release/public_beta_v2/unified_telemetry_summary.json',
      );
      cacheFile = File('tools/_reports/.adaptive_difficulty_cache.json');

      telemetryBackup = telemetryFile.existsSync()
          ? telemetryFile.readAsStringSync()
          : null;
      releaseTelemetryBackup = releaseTelemetryFile.existsSync()
          ? releaseTelemetryFile.readAsStringSync()
          : null;
      cacheBackup = cacheFile.existsSync()
          ? cacheFile.readAsStringSync()
          : null;

      telemetryFile.parent.createSync(recursive: true);
      releaseTelemetryFile.parent.createSync(recursive: true);

      if (cacheFile.existsSync()) {
        cacheFile.deleteSync();
      }
    });

    tearDown(() {
      if (telemetryBackup != null) {
        telemetryFile.writeAsStringSync(telemetryBackup!);
      } else if (telemetryFile.existsSync()) {
        telemetryFile.deleteSync();
      }

      if (releaseTelemetryBackup != null) {
        releaseTelemetryFile.writeAsStringSync(releaseTelemetryBackup!);
      } else if (releaseTelemetryFile.existsSync()) {
        releaseTelemetryFile.deleteSync();
      }

      if (cacheBackup != null) {
        cacheFile
          ..createSync(recursive: true)
          ..writeAsStringSync(cacheBackup!);
      } else if (cacheFile.existsSync()) {
        cacheFile.deleteSync();
      }
    });

    void writeTelemetry({
      required double confidence,
      required double retention,
      required double latencyMs,
    }) {
      final payload = <String, dynamic>{
        'feeds_merged': 3,
        'derived_metrics': <String, dynamic>{
          'avg_confidence': confidence,
          'retention_score': retention,
          'avg_latency_ms': latencyMs,
        },
      };
      telemetryFile.writeAsStringSync(jsonEncode(payload));
      if (releaseTelemetryFile.existsSync()) {
        releaseTelemetryFile.deleteSync();
      }
    }

    test('computes multiplier within range and updates cache', () {
      writeTelemetry(confidence: 86, retention: 82, latencyMs: 210);
      final multiplierHigh = AdaptiveDifficultyService.instance
          .getCurrentDifficultyMultiplier();
      expect(multiplierHigh, inInclusiveRange(0.7, 1.3));
      expect(multiplierHigh, closeTo(1.3, 0.01));

      expect(cacheFile.existsSync(), isTrue);
      final cacheJson =
          jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
      final history = (cacheJson['history'] as List).cast<num>();
      expect(history.length, equals(1));

      writeTelemetry(confidence: 38, retention: 45, latencyMs: 640);
      final multiplierLow = AdaptiveDifficultyService.instance
          .getCurrentDifficultyMultiplier();

      expect(multiplierLow, inInclusiveRange(0.7, 1.3));
      expect(multiplierLow, lessThan(multiplierHigh));

      final updatedCache =
          jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
      final updatedHistory = (updatedCache['history'] as List)
          .cast<num>()
          .toList();
      expect(updatedHistory.length, equals(2));

      final average = (updatedCache['average'] as num).toDouble();
      expect(average, inInclusiveRange(0, 1.5));
    });
  });
}
