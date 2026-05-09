import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/booster_queue_pressure_monitor.dart';
import 'package:poker_analyzer/services/recap_booster_queue.dart';
import 'package:poker_analyzer/services/goal_queue.dart';
import 'package:poker_analyzer/services/inbox_booster_tracker_service.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/smart_skill_gap_booster_engine.dart';

class _FakeSkillGapEngine extends SmartSkillGapBoosterEngine {
  final int count;
  _FakeSkillGapEngine(this.count);
  @override
  Future<List<TheoryMiniLessonNode>> recommend[{int max = 3}] async {
    final c = count < max ? count : max;
    return [
      for (var i = 0; i < c; i++)
        TheoryMiniLessonNode(id: 'l', title: 't', content: '', tags: []),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecapBoosterQueue.instance.clear();
    GoalQueue.instance.clear();
    InboxBoosterTrackerService.instance.resetForTest();
  });

  test('pressure score accounts for queue sizes', () async {
    await RecapBoosterQueue.instance.add('a1');
    GoalQueue.instance.push(
      TheoryMiniLessonNode(id: 'g1', title: 't', content: '', tags: []),
    );
    await InboxBoosterTrackerService.instance.addToInbox('i1');

    final monitor = BoosterQueuePressureMonitor(
      recapQueue: RecapBoosterQueue.instance,
      goalQueue: GoalQueue.instance,
      inboxQueue: InboxBoosterTrackerService.instance,
      skillGap: _FakeSkillGapEngine(2),
    );
    final score = await monitor.computeScore();
    expect(score, greaterThan(0.0));
    expect(await monitor.isOverloaded(threshold: score - 0.01), true);
  });
}
