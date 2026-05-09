import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/models/saved_hand.dart';
import 'package:poker_analyzer/services/saved_hand_export_service.dart';
import 'package:poker_analyzer/services/saved_hand_manager_service.dart';
import 'package:poker_analyzer/services/saved_hand_stats_service.dart';
import 'package:poker_analyzer/services/saved_hand_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavedHandExportService', () {
    late SavedHandManagerService manager;
    late SavedHandStatsService stats;
    late SavedHandExportService exporter;

    // Stub path_provider method channels to avoid platform dependencies
    setUpAll(() async {
      // Point all path provider requests to system temp
      const chDefault = MethodChannel('plugins.flutter.io/path_provider');
      const chMac = MethodChannel('plugins.flutter.io/path_provider_macos');
      const chIOS = MethodChannel('plugins.flutter.io/path_provider_ios');
      const chLinux = MethodChannel('plugins.flutter.io/path_provider_linux');
      const chWindows = MethodChannel(
        'plugins.flutter.io/path_provider_windows',
      );

      Future<dynamic> handler(MethodCall call) async {
        final tmp = Directory.systemTemp.path;
        switch (call.method) {
          case 'getApplicationDocumentsDirectory':
            return tmp;
          case 'getTemporaryDirectory':
            return tmp;
          case 'getLibraryDirectory':
            return tmp;
          case 'getDownloadsDirectory':
            return tmp;
          default:
            return tmp;
        }
      }

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(chDefault, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(chMac, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(chIOS, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(chLinux, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(chWindows, handler);
    });

    setUp(() async {
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
      final storage = SavedHandStorageService();
      manager = SavedHandManagerService(storage: storage);
      stats = SavedHandStatsService(manager: manager);
      exporter = SavedHandExportService(manager: manager, stats: stats);

      // Seed with 200 hands across 50 sessions to generate substantial CSV/PDF
      // CSV exports session summaries (1 row per session), so more sessions = larger files
      // Need 50+ sessions to exceed 1KB CSV threshold (each row ~20-30 bytes)
      final now = DateTime.now();
      final hands = <SavedHand>[];
      final positions = ['BTN', 'CO', 'MP', 'UTG', 'SB', 'BB'];
      final actions = ['fold', 'call', 'raise', 'check', 'bet', 'allin'];

      for (int i = 0; i < 200; i++) {
        final sessionId = (i ~/ 4) + 1; // 4 hands per session = 50 sessions
        final posIdx = i % positions.length;
        final actIdx = i % actions.length;

        hands.add(
          SavedHand(
            name:
                'Hand ${i + 1} Session $sessionId ${positions[posIdx]} vs ${positions[(posIdx + 1) % positions.length]}',
            heroIndex: 0,
            heroPosition: positions[posIdx],
            numberOfPlayers: 6,
            playerCards: [
              [
                CardModel(
                  rank: ['A', 'K', 'Q', 'J', 'T', '9'][i % 6],
                  suit: '♠',
                ),
                CardModel(
                  rank: ['A', 'K', 'Q', 'J', 'T', '9'][(i + 1) % 6],
                  suit: '♦',
                ),
              ],
              [
                CardModel(rank: 'Q', suit: '♣'),
                CardModel(rank: 'J', suit: '♥'),
              ],
              [
                CardModel(rank: '9', suit: '♠'),
                CardModel(rank: '8', suit: '♦'),
              ],
              [
                CardModel(rank: '7', suit: '♣'),
                CardModel(rank: '6', suit: '♥'),
              ],
              [
                CardModel(rank: '5', suit: '♠'),
                CardModel(rank: '4', suit: '♦'),
              ],
              [
                CardModel(rank: '3', suit: '♣'),
                CardModel(rank: '2', suit: '♥'),
              ],
            ],
            boardCards: i % 3 == 0
                ? [
                    CardModel(rank: 'A', suit: '♥'),
                    CardModel(rank: 'K', suit: '♠'),
                    CardModel(rank: 'Q', suit: '♦'),
                  ]
                : [],
            boardStreet: i % 3 == 0 ? 1 : 0,
            actions: [
              ActionEntry(
                0,
                0,
                actions[actIdx],
                amount: 2 + (i % 10),
                ev: (i % 5 - 2).toDouble(),
              ),
              ActionEntry(
                0,
                1,
                actions[(actIdx + 1) % actions.length],
                amount: 4 + (i % 8),
              ),
              ActionEntry(0, 2, actions[(actIdx + 2) % actions.length]),
              ActionEntry(0, 3, 'fold'),
            ],
            stackSizes: {0: 100, 1: 95, 2: 110, 3: 80, 4: 120, 5: 90},
            playerPositions: {
              0: positions[posIdx],
              1: positions[(posIdx + 1) % positions.length],
              2: positions[(posIdx + 2) % positions.length],
              3: positions[(posIdx + 3) % positions.length],
              4: positions[(posIdx + 4) % positions.length],
              5: positions[(posIdx + 5) % positions.length],
            },
            tags: [
              'test',
              'session_$sessionId',
              positions[posIdx],
              actions[actIdx],
            ],
            sessionId:
                0, // Will be auto-assigned by SavedHandManagerService based on time gaps
            // Space sessions >60min apart: session start + hand offset within session (<60min)
            // sessionId starts at 1, so subtract 1 for 0-based calculation
            savedAt: now.add(
              Duration(hours: (sessionId - 1) * 2, minutes: (i % 4) * 10),
            ),
            expectedAction: actions[actIdx],
            gtoAction: actions[(actIdx + 1) % actions.length],
            evLoss: (i % 4) * 0.25,
            rangeGroup: 'Group ${i % 5}',
            feedbackText:
                'Detailed feedback for hand ${i + 1}: Consider ${actions[(actIdx + 2) % actions.length]} in this spot with your range advantage and stack-to-pot ratio.',
            comment:
                'Session $sessionId hand notes and strategic observations for future review',
          ),
        );
      }
      // Persist hands
      for (final h in hands) {
        await manager.save(h);
      }
    });

    test('exports CSV and PDF and writes metrics', () async {
      // Verify hands were persisted across sessions
      final allHands = manager.hands;
      expect(allHands.length, 200, reason: 'Should have 200 hands');

      // Verify session distribution
      final sessions = <int>{};
      for (final h in allHands) {
        sessions.add(h.sessionId);
      }
      expect(
        sessions.length,
        greaterThanOrEqualTo(50),
        reason: 'Should have at least 50 sessions',
      );

      // Add detailed session notes to increase export file size
      final sessionNotes = <int, String>{};
      for (int i = 1; i <= 50; i++) {
        sessionNotes[i] =
            'Session $i comprehensive notes: Strategy adjustments, opponent tendencies observed, key decision points requiring further review and analysis. Specific focus on bet sizing, range construction, and exploitative adjustments based on population tendencies and individual player reads.';
      }

      // CSV (all sessions)
      final csvPath = await exporter.exportAllSessionsCsv(sessionNotes);
      expect(csvPath, isNotNull);
      final csvFile = File(csvPath!);
      expect(await csvFile.exists(), isTrue);
      final csvBytes = await csvFile.length();
      expect(csvBytes, greaterThan(1000));

      // PDF (specific sessions) — uses no share plugin internally
      // Export first 20 sessions to generate substantial PDF content
      final pdfPath = await exporter.exportSessionsPdf(
        List.generate(20, (i) => i + 1),
        sessionNotes,
      );
      expect(pdfPath, isNotNull);
      final pdfFile = File(pdfPath!);
      expect(await pdfFile.exists(), isTrue);
      final pdfBytes = await pdfFile.length();
      expect(pdfBytes, greaterThan(1000));

      // Emit export metrics for Health Dashboard consumption
      final items = [
        {'path': csvPath, 'bytes': csvBytes},
        {'path': pdfPath, 'bytes': pdfBytes},
      ];
      final total = csvBytes + pdfBytes;
      final minB = [csvBytes, pdfBytes].reduce((a, b) => a < b ? a : b);
      final metrics = {
        'count': items.length,
        'totalBytes': total,
        'minBytes': minB,
        'files': items,
      };
      await File('export_metrics.json').writeAsString(jsonEncode(metrics));

      // Basic sanity on metrics file
      final raw = await File('export_metrics.json').readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      expect(decoded['count'], 2);
      expect((decoded['minBytes'] as num) >= 1024, isTrue);
    });
  });
}
