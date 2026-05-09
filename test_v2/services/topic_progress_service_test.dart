import 'package:test/test.dart';
import 'package:poker_analyzer/services/topic_progress_service.dart';

/// Mock for SharedPreferences that uses in-memory storage for testing
class MockSharedPreferences {
  final Map<String, String> _store = {};

  String? getString(String key) => _store[key];

  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  void clear() => _store.clear();
}

void main() {
  group('TopicProgressService', () {
    test('TopicProgress initializes with default values', () {
      final progress = TopicProgress(topicId: 'test-topic');

      expect(progress.topicId, 'test-topic');
      expect(progress.seenCount, 0);
      expect(progress.correctCount, 0);
      expect(progress.streak, 0);
      expect(progress.accuracy, 0.0);
      expect(progress.history, isEmpty);
    });

    test('TopicProgress calculates accuracy correctly', () {
      final progress = TopicProgress(
        topicId: 'test-topic',
        seenCount: 10,
        correctCount: 7,
      );

      expect(progress.accuracy, 0.7);
    });

    test('TopicProgress accuracy is 0 when seenCount is 0', () {
      final progress = TopicProgress(
        topicId: 'test-topic',
        seenCount: 0,
        correctCount: 0,
      );

      expect(progress.accuracy, 0.0);
    });

    test('TopicProgress serializes to JSON correctly', () {
      final now = DateTime.now();
      final progress = TopicProgress(
        topicId: 'test-topic',
        seenCount: 5,
        correctCount: 3,
        streak: 2,
        lastUpdated: now,
        history: [
          {'timestamp': now.toIso8601String(), 'correct': true},
        ],
      );

      final json = progress.toJson();

      expect(json['topicId'], 'test-topic');
      expect(json['seenCount'], 5);
      expect(json['correctCount'], 3);
      expect(json['streak'], 2);
      expect(json['lastUpdated'], now.toIso8601String());
      expect(json['history'], isList);
    });

    test('TopicProgress deserializes from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'topicId': 'test-topic',
        'seenCount': 5,
        'correctCount': 3,
        'streak': 2,
        'lastUpdated': now.toIso8601String(),
        'history': [
          {'timestamp': now.toIso8601String(), 'correct': true},
        ],
      };

      final progress = TopicProgress.fromJson(json);

      expect(progress.topicId, 'test-topic');
      expect(progress.seenCount, 5);
      expect(progress.correctCount, 3);
      expect(progress.streak, 2);
      expect(progress.history.length, 1);
    });

    test('TopicProgress correctly increments on correct answer', () {
      final progress = TopicProgress(topicId: 'test-topic');

      progress.seenCount++;
      progress.correctCount++;
      progress.streak++;

      expect(progress.seenCount, 1);
      expect(progress.correctCount, 1);
      expect(progress.streak, 1);
      expect(progress.accuracy, 1.0);
    });

    test('TopicProgress resets streak on incorrect answer', () {
      final progress = TopicProgress(
        topicId: 'test-topic',
        seenCount: 5,
        correctCount: 4,
        streak: 4,
      );

      progress.seenCount++;
      progress.streak = 0; // Reset on incorrect

      expect(progress.seenCount, 6);
      expect(progress.correctCount, 4);
      expect(progress.streak, 0);
    });

    test('TopicProgress maintains history', () {
      final progress = TopicProgress(topicId: 'test-topic');
      final timestamp1 = DateTime.now().toIso8601String();
      final timestamp2 = DateTime.now()
          .add(Duration(seconds: 1))
          .toIso8601String();

      progress.history.add({'timestamp': timestamp1, 'correct': true});
      progress.history.add({'timestamp': timestamp2, 'correct': false});

      expect(progress.history.length, 2);
      expect(progress.history[0]['correct'], true);
      expect(progress.history[1]['correct'], false);
    });

    test('TopicProgressService singleton returns same instance', () {
      final instance1 = TopicProgressService.instance;
      final instance2 = TopicProgressService.instance;

      expect(identical(instance1, instance2), isTrue);
    });
  });
}
