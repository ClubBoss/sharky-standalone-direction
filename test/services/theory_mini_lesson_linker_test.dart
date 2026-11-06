import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/services/theory_mini_lesson_linker.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:poker_analyzer/services/pack_library_loader_service.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  final List<TheoryMiniLessonNode> lessons;
  _FakeLibrary(this.lessons);

  @override
  List<TheoryMiniLessonNode> get all => lessons;

  @override
  TheoryMiniLessonNode? getById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) {
    for (final lesson in lessons) {
      if (lesson.tags.contains(tag)) return lesson;
    }
    return null;
  }

  @override
  Future<TheoryMiniLessonNode?> getNextLesson() async =>
      lessons.isEmpty ? null : lessons.first;

  @override
  Future<bool> isLessonCompleted(String id) async => false;

  @override
  List<String> linkedPacksFor(String id) =>
      getById(id)?.linkedPackIds ?? const [];

  @override
  Future<void> loadAll() async {}

  @override
  Future<void> reload() async {}

  @override
  List<TheoryMiniLessonNode> findByTags(List<String> tags) => [
    for (final t in tags) ...lessons.where((l) => l.tags.contains(t)),
  ];

  @override
  List<TheoryMiniLessonNode> getByTags(Set<String> tags) =>
      findByTags(tags.toList());
}

class _FakeLoader implements PackLibraryLoaderService {
  final List<v2.TrainingPackTemplateV2> packs;
  _FakeLoader(this.packs);

  @override
  Future<List<v2.TrainingPackTemplateV2>> loadLibrary() async => packs;

  @override
  List<v2.TrainingPackTemplateV2> get library => packs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('linker maps lessons to packs by tags and stage', () async {
    final lesson = TheoryMiniLessonNode(
      id: 'l1',
      title: 'L1',
      content: '',
      stage: 'level2',
      tags: ['level2', '3bet-push'],
    );
    final packs = [
      v2.TrainingPackTemplateV2(
        id: 'p1',
        name: 'P1',
        trainingType: TrainingType.pushFold,
        tags: ['level2', '3bet-push'],
        meta: {'stage': 'level2'},
      ),
      v2.TrainingPackTemplateV2(
        id: 'p2',
        name: 'P2',
        trainingType: TrainingType.pushFold,
        tags: ['level1', '3bet-push'],
        meta: {'stage': 'level1'},
      ),
    ];
    final library = _FakeLibrary([lesson]);
    final loader = _FakeLoader(packs);
    final linker = TheoryMiniLessonLinker(library: library, loader: loader);

    await linker.link(force: true);

    expect(lesson.linkedPackIds, equals(['p1']));
  });
}
