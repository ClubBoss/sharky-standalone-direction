import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/replay_recorder.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

void main() {
  group('ReplayRecorder smoke tests', () {
    late Directory tempDir;
    late String replayDir;

    setUp(() {
      // Create temporary directory for test output
      tempDir = Directory.systemTemp.createTempSync('replay_test_');
      replayDir = '${tempDir.path}/replays';
    });

    tearDown(() {
      // Clean up temporary directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('captures 5 events and exports to JSONL file', () async {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(42),
      );

      final recorder = ReplayRecorder(
        engine: engine,
        maxEvents: 100,
        replayDir: replayDir,
      );

      // Start round and let AI take actions
      engine.startRound();

      // Wait for events to be captured
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Take hero action to generate more events
      engine.playerAction(PlayerAction.fold);

      // Wait for round to complete
      await Future<void>.delayed(const Duration(seconds: 2));

      // Verify events were captured
      expect(recorder.eventCount, greaterThan(0));

      // Export replay
      final filePath = await recorder.exportReplay();

      // Verify file was created
      expect(filePath, isNotNull);
      final file = File(filePath!);
      expect(file.existsSync(), isTrue);

      // Read file contents
      final lines = await file.readAsLines();

      // Verify file contains at least some events
      expect(lines.length, greaterThan(0));

      // Verify each line is valid JSON
      for (final line in lines) {
        expect(() => jsonDecode(line), returnsNormally);
      }

      // Clean up
      recorder.dispose();
      engine.dispose();
    });

    test('validates JSON structure and timestamp ordering', () async {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(123),
      );

      final recorder = ReplayRecorder(engine: engine, replayDir: replayDir);

      // Generate events
      engine.startRound();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      engine.playerAction(PlayerAction.call);
      await Future<void>.delayed(const Duration(seconds: 2));

      // Export replay
      final filePath = await recorder.exportReplay();
      expect(filePath, isNotNull);

      final file = File(filePath!);
      final lines = await file.readAsLines();

      // Verify JSON structure
      DateTime? lastTimestamp;
      for (final line in lines) {
        final json = jsonDecode(line) as Map<String, dynamic>;

        // Verify required fields
        expect(json, containsPair('timestamp', isA<String>()));
        expect(json, containsPair('type', isA<String>()));
        expect(json, containsPair('seat_index', isA<int>()));

        // Verify timestamp is valid ISO 8601
        final timestamp = DateTime.parse(json['timestamp'] as String);
        expect(timestamp, isA<DateTime>());

        // Verify timestamps are ordered (or equal for same-time events)
        if (lastTimestamp != null) {
          expect(
            timestamp.isAfter(lastTimestamp) ||
                timestamp.isAtSameMomentAs(lastTimestamp),
            isTrue,
            reason: 'Timestamps should be ordered',
          );
        }
        lastTimestamp = timestamp;

        // Verify optional fields have correct types when present
        if (json.containsKey('action')) {
          expect(json['action'], isA<String>());
        }
        if (json.containsKey('amount')) {
          expect(json['amount'], isA<int>());
        }
        if (json.containsKey('street')) {
          expect(json['street'], isA<String>());
        }
        if (json.containsKey('pot')) {
          expect(json['pot'], isA<int>());
        }
      }

      // Clean up
      recorder.dispose();
      engine.dispose();
    });

    test('circular buffer maintains max size', () async {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(456),
      );

      final recorder = ReplayRecorder(
        engine: engine,
        maxEvents: 5, // Small buffer for testing
        replayDir: replayDir,
      );

      // Generate many events
      for (int i = 0; i < 3; i++) {
        engine.startRound();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        engine.playerAction(PlayerAction.fold);
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      // Verify buffer doesn't exceed max size
      expect(recorder.eventCount, lessThanOrEqualTo(5));

      // Clean up
      recorder.dispose();
      engine.dispose();
    });

    test('handles no events gracefully', () async {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(789),
      );

      final recorder = ReplayRecorder(engine: engine, replayDir: replayDir);

      // Don't generate any events
      // Export immediately
      final filePath = await recorder.exportReplay();

      // Should return null when no events
      expect(filePath, isNull);

      // Clean up
      recorder.dispose();
      engine.dispose();
    });

    test('clearBuffer resets event count', () async {
      final engine = SimulationEngine(
        playerCount: 2,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: false,
        trainingMode: false,
        enableHistory: false,
        random: Random(101),
      );

      final recorder = ReplayRecorder(engine: engine, replayDir: replayDir);

      // Generate events
      engine.startRound();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Verify events captured
      expect(recorder.eventCount, greaterThan(0));

      // Clear buffer
      recorder.clearBuffer();

      // Verify buffer is empty
      expect(recorder.eventCount, 0);

      // Clean up
      recorder.dispose();
      engine.dispose();
    });
  });
}
