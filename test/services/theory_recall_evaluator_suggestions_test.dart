import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/theory_recall_evaluator.dart';
import 'package:poker_analyzer/services/booster_completion_tracker.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_type.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:collection/collection.dart';

class _FakeMiniLibrary implements MiniLessonLibraryService {
  final List<TheoryMiniLessonNode> lessons;
  _FakeMiniLibrary(this.lessons);
  @override
  List<TheoryMiniLessonNode> get all => lessons;
  @override
  Future<void> loadAll() async {}
  @override
  Future<void> reload() async {}
  @override
  TheoryMiniLessonNode? getById(String id) =>
      lessons.firstWhereOrNull((e) => e.id == id);
  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) =>
      lessons.firstWhereOrNull((lesson) => lesson.tags.contains(tag));
  @override
  List<TheoryMiniLessonNode> findByTags(List<String> tags) {
    final set = tags.map((e) => e.toLowerCase()).toSet();
    return [
      for (final l in lessons)
        if (l.tags.any((t) => set.contains(t))) l,
    ];
  }

  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] =>
      findByTags[tags.toList[]];

  @override
  TheoryMiniLessonNode? getNextLesson(String id) => null;

  @override
  bool isLessonCompleted(String id) => false;

  @override
  List<String> linkedPacksFor[String id] => const <String>[];
}

v2.TrainingPackTemplateV2 _booster(String id, String tag) =>
    v2.TrainingPackTemplateV2(
      id: id,
      name: id,
      trainingType: TrainingType.pushFold,
      tags: const <String>[],
      spots: const <TrainingPackSpot>[],
      spotCount: 1,
      created: DateTime.now(),
      gameType: GameType.tournament,
      positions: [],
      meta: {
        'type': 'booster',
        'tags': <String>[tag],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recallSuggestions returns lessons for weak booster tags', () async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'completed_boosters': ['b1'],
      'completed_at_tpl_b1': now.toIso8601String(),
      'last_accuracy_tpl_b1_0': 50.0,
      'mini_lesson_progress_l1':
          '{"viewCount":1,"lastViewed":"${now.subtract(Duration(days: 5)).toIso8601String()}","completed":false}',
    });
    BoosterCompletionTracker.instance.resetForTest();

    final boosters = [_booster('b1', 'push'));
    final lessons = [
      TheoryMiniLessonNode(
        id: 'l1',
        title: 'Push',
        content: '',
        tags: ['push'],
      ),
    ];
    final lib = _FakeMiniLibrary(lessons);
    final eval = TheoryRecallEvaluator();
    final result = await eval.recallSuggestions(
      boosterLibrary: boosters,
      library: lib,
      limit: 1,
    );
    expect(result.map((e) => e.id), ['l1']);
  });
}

