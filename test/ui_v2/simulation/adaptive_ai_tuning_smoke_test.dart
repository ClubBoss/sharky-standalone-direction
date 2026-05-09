import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Adaptive AI tuning', () {
    late File telemetryFile;

    setUp(() {
      telemetryFile = File('tools/_reports/unified_telemetry_summary.json');
      telemetryFile.parent.createSync(recursive: true);
    });

    tearDown(() {
      if (telemetryFile.existsSync()) {
        telemetryFile.deleteSync();
      }
    });

    void writeTelemetry({
      required double confidence,
      required double latencyMs,
      required double retention,
      int feeds = 3,
    }) {
      final payload = <String, dynamic>{
        'feeds_merged': feeds,
        'derived_metrics': <String, dynamic>{
          'avg_confidence': confidence,
          'avg_latency_ms': latencyMs,
          'retention_score': retention,
        },
      };
      telemetryFile.writeAsStringSync(jsonEncode(payload));
    }

    RuleAiOpponent buildOpponent() {
      return RuleAiOpponent(
        personality: AiPersonality.aggressive,
        position: 2,
        random: Random(42),
      );
    }

    test('tuning profile adjusts aggression, bluff, and fold scales', () {
      writeTelemetry(confidence: 62, latencyMs: 360, retention: 65);
      final neutralProfile = RuleAiOpponent.computeAdaptiveTuning(
        logTelemetry: false,
      );
      final neutralOpponent = buildOpponent()
        ..applyTuningProfile(neutralProfile);

      writeTelemetry(confidence: 86, latencyMs: 190, retention: 88);
      final highProfile = RuleAiOpponent.computeAdaptiveTuning(
        logTelemetry: false,
      );
      final highOpponent = buildOpponent()..applyTuningProfile(highProfile);

      writeTelemetry(confidence: 34, latencyMs: 640, retention: 42);
      final lowProfile = RuleAiOpponent.computeAdaptiveTuning(
        logTelemetry: false,
      );
      final lowOpponent = buildOpponent()..applyTuningProfile(lowProfile);

      expect(highProfile.aggression, greaterThan(neutralProfile.aggression));
      expect(lowProfile.aggression, lessThan(neutralProfile.aggression));

      expect(highProfile.bluff, greaterThan(neutralProfile.bluff));
      expect(lowProfile.bluff, lessThan(neutralProfile.bluff));

      expect(highProfile.fold, lessThan(neutralProfile.fold));
      expect(lowProfile.fold, greaterThan(neutralProfile.fold));

      expect(
        highOpponent.raiseFrequency,
        greaterThan(neutralOpponent.raiseFrequency),
      );
      expect(
        lowOpponent.raiseFrequency,
        lessThan(neutralOpponent.raiseFrequency),
      );

      expect(
        highOpponent.bluffFrequency,
        greaterThan(neutralOpponent.bluffFrequency),
      );
      expect(
        lowOpponent.bluffFrequency,
        lessThan(neutralOpponent.bluffFrequency),
      );

      expect(
        highOpponent.foldThreshold,
        lessThan(neutralOpponent.foldThreshold),
      );
      expect(
        lowOpponent.foldThreshold,
        greaterThan(neutralOpponent.foldThreshold),
      );
    });

    test('simulation engine applies adaptive tuning per round', () {
      writeTelemetry(confidence: 85, latencyMs: 200, retention: 82);
      final engine = SimulationEngine(
        playerCount: 4,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(7),
      );

      addTearDown(engine.dispose);

      engine.startRound();
      final opponent = engine.debugAiOpponent(1);
      expect(opponent, isNotNull);
      expect(opponent!.raiseFrequency, greaterThan(0.3));
      expect(opponent.bluffFrequency, greaterThan(0.1));

      writeTelemetry(confidence: 28, latencyMs: 720, retention: 35);
      final engineLow = SimulationEngine(
        playerCount: 4,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(11),
      );

      addTearDown(engineLow.dispose);

      engineLow.startRound();
      final cautiousOpponent = engineLow.debugAiOpponent(1);
      expect(cautiousOpponent, isNotNull);
      expect(
        cautiousOpponent!.raiseFrequency,
        lessThan(opponent.raiseFrequency),
      );
      expect(
        cautiousOpponent.bluffFrequency,
        lessThan(opponent.bluffFrequency),
      );
      expect(
        cautiousOpponent.foldThreshold,
        greaterThan(opponent.foldThreshold),
      );
    });
  });
}
