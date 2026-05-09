import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/smart_recap_banner_reinjection_service.dart';
import 'package:poker_analyzer/services/recap_auto_repeat_scheduler.dart';
import 'package:poker_analyzer/services/smart_recap_banner_controller.dart';
import 'package:poker_analyzer/services/recap_fatigue_evaluator.dart';
import 'package:poker_analyzer/services/theory_recap_suppression_engine.dart';
import 'package:poker_analyzer/services/smart_theory_recap_dismissal_memory.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:poker_analyzer/services/recap_history_tracker.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  // fix: type adjust interface
  final List<TheoryMiniLessonNode> items; // fix: type adjust interface
  _FakeLibrary(this.items); // fix: type adjust interface
  @override
  List<TheoryMiniLessonNode> get all => items; // fix: type adjust interface
  @override
  Future<TheoryMiniLessonNode?>
  getNextLesson() async => // fix: type adjust interface
      items.isEmpty ? null : items.first; // fix: type adjust interface
  @override
  Future<void> loadAll() async {} // fix: type adjust callback
  @override
  Future<void> reload() async {} // fix: type adjust callback
  @override
  TheoryMiniLessonNode? getById(String id) => // fix: type adjust interface
  items.cast<TheoryMiniLessonNode?>().firstWhere(
    (e) => e?.id == id,
    orElse: () => null,
  ); // fix: type adjust cast
  @override
  List<String> linkedPacksFor[String lessonId] => const <String>[]; // fix: type adjust generics
  @override
  Future<bool> isLessonCompleted(String lessonId) async => false; // fix: type adjust callback
  @override
  List<TheoryMiniLessonNode> findByTags[List<String> tags] =>
      const <TheoryMiniLessonNode>[]; // fix: type adjust generics
  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] =>
      const <TheoryMiniLessonNode>[]; // fix: type adjust generics
  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) => getById(tag); // fix: type adjust interface
}

class _FakeController extends SmartRecapBannerController {
  // fix: type adjust interface
  _FakeController()
    : super(sessions: TrainingSessionService()); // fix: type adjust interface
  int count = 0;
  TheoryMiniLessonNode? last;
  @override
  Future<void> showManually(TheoryMiniLessonNode lesson) async {
    count++;
    last = lesson;
  }
}

class _FakeSuppression extends TheoryRecapSuppressionEngine {
  final bool value;
  _FakeSuppression(this.value) : super();
  @override
  Future<bool> shouldSuppress({
    required String lessonId,
    required String trigger,
  }) async => value;
}

class _FakeDismissal implements SmartTheoryRecapDismissalMemory {
  // fix: type adjust interface
  final bool value; // fix: type adjust interface
  _FakeDismissal(this.value); // fix: type adjust interface
  @override
  Future<bool> shouldThrottle(String key) async => value; // fix: type adjust callback
  @override
  Future<void> registerDismissal(String key) async {} // fix: type adjust callback
  @override
  Future<Map<String, int>> debugCounts() async => const <String, int>{}; // fix: type adjust generics
  @override
  void resetForTest() {} // fix: type adjust callback
}

class _FakeFatigue extends RecapFatigueEvaluator {
  final bool value;
  _FakeFatigue(this.value) : super(tracker: RecapHistoryTracker.instance);
  @override
  Future<bool> isFatigued(String lessonId) async => value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecapAutoRepeatScheduler.instance.resetForTest();
    RecapHistoryTracker.instance.resetForTest();
  });

  test('shows due recap banner', () async {
    final lesson = TheoryMiniLessonNode(id: 'l1', title: 't', content: '');
    final lib = _FakeLibrary([lesson]);
    final controller = _FakeController();
    final service = SmartRecapBannerReinjectionService(
      scheduler: RecapAutoRepeatScheduler.instance,
      library: lib,
      controller: controller,
      fatigue: _FakeFatigue(false),
      suppression: _FakeSuppression(false),
      dismissal: _FakeDismissal(false),
    );
    await RecapAutoRepeatScheduler.instance.scheduleRepeat('l1', Duration.zero);
    await service.start(interval: Duration(milliseconds: 10));
    await Future.delayed(Duration(milliseconds: 20));
    expect(controller.count, 1);
    expect(controller.last?.id, 'l1');
    await service.dispose();
  });

  test('skips when suppressed', () async {
    final lesson = TheoryMiniLessonNode(id: 'l1', title: 't', content: '');
    final lib = _FakeLibrary([lesson]);
    final controller = _FakeController();
    final service = SmartRecapBannerReinjectionService(
      scheduler: RecapAutoRepeatScheduler.instance,
      library: lib,
      controller: controller,
      fatigue: _FakeFatigue(false),
      suppression: _FakeSuppression(true),
      dismissal: _FakeDismissal(false),
    );
    await RecapAutoRepeatScheduler.instance.scheduleRepeat('l1', Duration.zero);
    await service.start(interval: Duration(milliseconds: 10));
    await Future.delayed(Duration(milliseconds: 20));
    expect(controller.count, 0);
    await service.dispose();
  });
}
