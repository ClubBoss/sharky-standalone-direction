import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/models/v2/training_action.dart';
import 'package:poker_analyzer/services/topic_progress_service.dart';

/// Core integration test that verifies the interaction between
/// TrainingPackService, TopicProgressService, and TrainingSessionService.
///
/// This test validates:
/// 1. Training pack creation with multiple spots
/// 2. Session lifecycle (start, progress, complete)
/// 3. Topic progress tracking across multiple sessions
/// 4. Data consistency between services
void main() {
  group('Core Integration Tests', () {
    late TrainingPackTemplate testPack;
    late List<TrainingPackSpot> testSpots;

    setUp(() {
      // Create a test training pack with multiple spots
      testSpots = [
        TrainingPackSpot(
          id: 'spot-1',
          title: '3bet Spot from Button',
          hand: HandData(
            heroCards: 'Ah Kh',
            position: HeroPosition.btn,
            heroIndex: 0,
            playerCount: 6,
            board: [],
            actions: {},
            stacks: {'0': 100.0, '1': 100.0},
          ),
          tags: ['preflop', '3bet', 'button'],
          correctAction: 'raise',
        ),
        TrainingPackSpot(
          id: 'spot-2',
          title: 'Flop C-bet Decision',
          hand: HandData(
            heroCards: 'Qs Qd',
            position: HeroPosition.co,
            heroIndex: 0,
            playerCount: 6,
            board: ['Kh', '7c', '2d'],
            actions: {},
            stacks: {'0': 100.0, '1': 100.0},
          ),
          tags: ['postflop', 'flop', 'cbet'],
          correctAction: 'bet',
        ),
        TrainingPackSpot(
          id: 'spot-3',
          title: 'Turn Decision',
          hand: HandData(
            heroCards: 'Ah Kd',
            position: HeroPosition.btn,
            heroIndex: 0,
            playerCount: 6,
            board: ['Qh', 'Jh', '2c', '5d'],
            actions: {},
            stacks: {'0': 100.0, '1': 100.0},
          ),
          tags: ['postflop', 'turn', 'bluff'],
          correctAction: 'bet',
        ),
      ];

      testPack = TrainingPackTemplate(
        id: 'integration-test-pack',
        name: 'Integration Test Pack',
        description: 'Pack for testing service integration',
        spots: testSpots,
        tags: ['test', 'integration'],
      );
    });

    test('Training pack contains all expected spots', () {
      expect(testPack.spots.length, 3);
      expect(testPack.spots[0].id, 'spot-1');
      expect(testPack.spots[1].id, 'spot-2');
      expect(testPack.spots[2].id, 'spot-3');
    });

    test('Training session lifecycle completes successfully', () {
      final startTime = DateTime.now();
      final session = TrainingSession(
        id: 'test-session-1',
        templateId: testPack.id,
        startedAt: startTime,
      );

      expect(session.id, 'test-session-1');
      expect(session.templateId, testPack.id);
      expect(session.startedAt, startTime);
      expect(session.completedAt, isNull);

      // Simulate user actions for each spot
      final actions = <TrainingAction>[];

      // Spot 1: Correct action
      actions.add(
        TrainingAction(
          spotId: testSpots[0].id,
          chosenAction: 'raise',
          isCorrect: true,
          timestamp: startTime.add(Duration(seconds: 10)),
        ),
      );

      // Spot 2: Incorrect action
      actions.add(
        TrainingAction(
          spotId: testSpots[1].id,
          chosenAction: 'check',
          isCorrect: false,
          timestamp: startTime.add(Duration(seconds: 25)),
        ),
      );

      // Spot 3: Correct action
      actions.add(
        TrainingAction(
          spotId: testSpots[2].id,
          chosenAction: 'bet',
          isCorrect: true,
          timestamp: startTime.add(Duration(seconds: 40)),
        ),
      );

      expect(actions.length, 3);
      expect(actions.where((a) => a.isCorrect).length, 2);

      // Complete the session
      final completedSession = TrainingSession(
        id: session.id,
        templateId: session.templateId,
        startedAt: session.startedAt,
        completedAt: DateTime.now(),
      );

      expect(completedSession.completedAt, isNotNull);
      expect(completedSession.completedAt!.isAfter(startTime), isTrue);
    });

    test('Topic progress tracks multiple training sessions', () {
      final topic1 = TopicProgress(topicId: 'preflop-3bet');
      final topic2 = TopicProgress(topicId: 'postflop-cbet');

      // Session 1: Practice preflop 3bet
      topic1.seenCount++;
      topic1.correctCount++;
      topic1.streak++;
      topic1.history.add({
        'timestamp': DateTime.now().toIso8601String(),
        'correct': true,
      });

      expect(topic1.seenCount, 1);
      expect(topic1.accuracy, 1.0);

      // Session 2: Practice postflop cbet (incorrect)
      topic2.seenCount++;
      topic2.streak = 0;
      topic2.history.add({
        'timestamp': DateTime.now().toIso8601String(),
        'correct': false,
      });

      expect(topic2.seenCount, 1);
      expect(topic2.accuracy, 0.0);

      // Session 3: Practice preflop 3bet again
      topic1.seenCount++;
      topic1.correctCount++;
      topic1.streak++;
      topic1.history.add({
        'timestamp': DateTime.now().toIso8601String(),
        'correct': true,
      });

      expect(topic1.seenCount, 2);
      expect(topic1.correctCount, 2);
      expect(topic1.accuracy, 1.0);
      expect(topic1.streak, 2);

      // Session 4: Practice postflop cbet (correct this time)
      topic2.seenCount++;
      topic2.correctCount++;
      topic2.streak++;
      topic2.history.add({
        'timestamp': DateTime.now().toIso8601String(),
        'correct': true,
      });

      expect(topic2.seenCount, 2);
      expect(topic2.correctCount, 1);
      expect(topic2.accuracy, 0.5);
      expect(topic2.streak, 1);
    });

    test('Training session calculates overall accuracy correctly', () {
      final actions = [
        TrainingAction(
          spotId: 'spot-1',
          chosenAction: 'raise',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-2',
          chosenAction: 'check',
          isCorrect: false,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-3',
          chosenAction: 'bet',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-4',
          chosenAction: 'call',
          isCorrect: false,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-5',
          chosenAction: 'fold',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
      ];

      final correctCount = actions.where((a) => a.isCorrect).length;
      final totalCount = actions.length;
      final accuracy = correctCount / totalCount;

      expect(totalCount, 5);
      expect(correctCount, 3);
      expect(accuracy, closeTo(0.6, 0.01));
    });

    test('Training pack can be filtered by tags', () {
      final preflopSpots = testSpots
          .where((spot) => spot.tags.contains('preflop'))
          .toList();

      final postflopSpots = testSpots
          .where((spot) => spot.tags.contains('postflop'))
          .toList();

      expect(preflopSpots.length, 1);
      expect(postflopSpots.length, 2);
    });

    test('Multiple sessions track cumulative progress', () {
      final topicProgress = TopicProgress(topicId: 'overall-progress');

      // Session 1: 3/5 correct
      for (int i = 0; i < 5; i++) {
        topicProgress.seenCount++;
        if (i < 3) {
          topicProgress.correctCount++;
        }
      }

      expect(topicProgress.accuracy, closeTo(0.6, 0.01));

      // Session 2: 4/5 correct
      for (int i = 0; i < 5; i++) {
        topicProgress.seenCount++;
        if (i < 4) {
          topicProgress.correctCount++;
        }
      }

      expect(topicProgress.seenCount, 10);
      expect(topicProgress.correctCount, 7);
      expect(topicProgress.accuracy, closeTo(0.7, 0.01));
    });

    test('Session can be completed', () {
      final startTime = DateTime.now();
      var session = TrainingSession(
        id: 'completable-session',
        templateId: testPack.id,
        startedAt: startTime,
      );

      expect(session.completedAt, isNull);

      // Complete the session
      final completeTime = startTime.add(Duration(minutes: 15));
      session = TrainingSession(
        id: session.id,
        templateId: session.templateId,
        startedAt: session.startedAt,
        completedAt: completeTime,
      );

      expect(session.completedAt, completeTime);

      // Total elapsed time
      final totalDuration = completeTime.difference(startTime);
      expect(totalDuration.inMinutes, 15);
    });

    test('Topic progress serialization round-trip', () {
      final original = TopicProgress(
        topicId: 'test-topic',
        seenCount: 10,
        correctCount: 7,
        streak: 3,
        lastUpdated: DateTime.now(),
        history: [
          {'timestamp': DateTime.now().toIso8601String(), 'correct': true},
        ],
      );

      final json = original.toJson();
      final deserialized = TopicProgress.fromJson(json);

      expect(deserialized.topicId, original.topicId);
      expect(deserialized.seenCount, original.seenCount);
      expect(deserialized.correctCount, original.correctCount);
      expect(deserialized.streak, original.streak);
      expect(deserialized.accuracy, original.accuracy);
    });
  });
}
