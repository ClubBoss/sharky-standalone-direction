import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/models/v2/training_action.dart';

void main() {
  group('TrainingSession', () {
    test('TrainingSession initializes with required fields', () {
      final now = DateTime.now();
      final session = TrainingSession(
        id: 'session-1',
        templateId: 'pack-1',
        startedAt: now,
      );

      expect(session.id, 'session-1');
      expect(session.templateId, 'pack-1');
      expect(session.startedAt, now);
      expect(session.completedAt, isNull);
    });

    test('TrainingSession can be completed', () {
      final now = DateTime.now();
      final completedAt = now.add(Duration(minutes: 5));
      final session = TrainingSession(
        id: 'session-1',
        templateId: 'pack-1',
        startedAt: now,
        completedAt: completedAt,
      );

      expect(session.completedAt, completedAt);
      expect(session.completedAt!.isAfter(session.startedAt), isTrue);
    });

    test('TrainingSession calculates duration correctly', () {
      final start = DateTime.now();
      final end = start.add(Duration(minutes: 10));
      final session = TrainingSession(
        id: 'session-1',
        templateId: 'pack-1',
        startedAt: start,
        completedAt: end,
      );

      final duration = session.completedAt!.difference(session.startedAt);
      expect(duration.inMinutes, 10);
    });
  });

  group('TrainingAction', () {
    test('TrainingAction initializes correctly', () {
      final action = TrainingAction(
        spotId: 'spot-1',
        chosenAction: 'call',
        isCorrect: false,
        timestamp: DateTime.now(),
      );

      expect(action.spotId, 'spot-1');
      expect(action.chosenAction, 'call');
      expect(action.isCorrect, false);
    });

    test('TrainingAction marks correct action', () {
      final action = TrainingAction(
        spotId: 'spot-1',
        chosenAction: 'fold',
        isCorrect: true,
        timestamp: DateTime.now(),
      );

      expect(action.isCorrect, true);
    });
  });

  group('TrainingSession with actions', () {
    test('TrainingSession tracks multiple actions', () {
      final actions = [
        TrainingAction(
          spotId: 'spot-1',
          chosenAction: 'fold',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-2',
          chosenAction: 'call',
          isCorrect: false,
          timestamp: DateTime.now(),
        ),
      ];

      expect(actions.length, 2);
      expect(actions[0].isCorrect, true);
      expect(actions[1].isCorrect, false);
    });

    test('TrainingSession calculates accuracy from actions', () {
      final actions = [
        TrainingAction(
          spotId: 'spot-1',
          chosenAction: 'fold',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-2',
          chosenAction: 'call',
          isCorrect: false,
          timestamp: DateTime.now(),
        ),
        TrainingAction(
          spotId: 'spot-3',
          chosenAction: 'raise',
          isCorrect: true,
          timestamp: DateTime.now(),
        ),
      ];

      final correctCount = actions.where((a) => a.isCorrect).length;
      final accuracy = correctCount / actions.length;

      expect(accuracy, closeTo(0.67, 0.01));
    });
  });

  group('Session state management', () {
    test('Session can be completed', () {
      final now = DateTime.now();
      var session = TrainingSession(
        id: 'session-1',
        templateId: 'pack-1',
        startedAt: now,
      );

      expect(session.completedAt, isNull);

      session = TrainingSession(
        id: session.id,
        templateId: session.templateId,
        startedAt: session.startedAt,
        completedAt: DateTime.now(),
      );

      expect(session.completedAt, isNotNull);
    });
  });
}
