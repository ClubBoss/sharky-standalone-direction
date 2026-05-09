import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/goal_progress.dart';
import 'package:poker_analyzer/services/goal_completion_engine.dart';

void main() {
  test('detect completed goal', () {
    final engine = GoalCompletionEngine.instance;
    const done = GoalProgress(
      tag: 'cbet',
      stagesCompleted: 3,
      averageAccuracy: 80,
    );
    const notDone = GoalProgress(
      tag: 'cbet',
      stagesCompleted: 2,
      averageAccuracy: 90,
    );
    expect(engine.isGoalCompleted(done), isTrue);
    expect(engine.isGoalCompleted(notDone), isFalse);
  });
}
