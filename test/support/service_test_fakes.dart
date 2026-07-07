import 'package:poker_analyzer/models/recall_success_entry.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/decay_recall_evaluator_service.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:poker_analyzer/services/recall_success_logger_service.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/smart_theory_recap_dismissal_memory.dart';

class TestMiniLessonLibraryService implements MiniLessonLibraryService {
  @override
  List<TheoryMiniLessonNode> get all => const [];

  @override
  TheoryMiniLessonNode? getById(String id) => null;

  @override
  List<String> linkedPacksFor(String lessonId) => const [];

  @override
  Future<bool> isLessonCompleted(String lessonId) async => false;

  @override
  Future<TheoryMiniLessonNode?> getNextLesson() async => null;

  @override
  Future<void> loadAll() async {}

  @override
  Future<void> reload() async {}

  @override
  List<TheoryMiniLessonNode> findByTags(List<String> tags) => const [];

  @override
  List<TheoryMiniLessonNode> getByTags(Set<String> tags) => const [];

  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) => null;
}

class TestRecallSuccessLoggerService implements RecallSuccessLoggerService {
  @override
  DecayRecallEvaluatorService get evaluator => DecayRecallEvaluatorService();

  @override
  Future<void> logSuccess(String tag, {String? source}) async {}

  @override
  Future<List<RecallSuccessEntry>> getSuccesses({String? tag}) async =>
      const [];

  @override
  void resetForTest() {}
}

class TestSmartTheoryRecapDismissalMemory
    implements SmartTheoryRecapDismissalMemory {
  @override
  Future<bool> shouldThrottle(String key) async => false;

  @override
  Future<void> registerDismissal(String key) async {}

  @override
  Future<Map<String, int>> debugCounts() async => const {};

  @override
  void resetForTest() {}
}

class TestSessionLogService implements SessionLogService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
