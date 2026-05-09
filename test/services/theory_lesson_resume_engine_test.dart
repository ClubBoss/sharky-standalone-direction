import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/theory_lesson_resume_engine.dart';
import 'package:poker_analyzer/services/theory_lesson_trail_tracker.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:poker_analyzer/services/mini_lesson_progress_tracker.dart';
import 'package:poker_analyzer/services/theory_lesson_tag_clusterer.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  final List<TheoryMiniLessonNode> items;
  _FakeLibrary(this.items);

  @override
  List<TheoryMiniLessonNode> get all => List<TheoryMiniLessonNode>.from(items); // fix: type adjust expose list copy

  @override
  TheoryMiniLessonNode? getById(String id) {
    // fix: type adjust safe lookup
    for (final node in items) {
      if (node.id == id) return node;
    }
    return null;
  }

  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) {
    // fix: type adjust tag search
    for (final node in items) {
      if (node.tags.contains(tag)) return node;
    }
    return null;
  }

  @override
  Future<TheoryMiniLessonNode?> getNextLesson() async {
    // fix: type adjust next lesson
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<bool> isLessonCompleted(String lessonId) async => false; // fix: type adjust default completion

  @override
  List<String> linkedPacksFor[String lessonId] => const []; // fix: type adjust no linked packs

  @override
  Future<void> loadAll() async {}

  @override
  Future<void> reload() async {}

  @override
  List<TheoryMiniLessonNode> findByTags(List<String> tags) {
    // fix: type adjust tag filter
    final result = <TheoryMiniLessonNode>[];
    for (final tag in tags) {
      for (final node in items) {
        if (node.tags.contains(tag) && !result.contains(node)) {
          result.add(node);
        }
      }
    }
    return result;
  }

  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] =>
      findByTags[tags.toList[]]; // fix: type adjust set support
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TheoryLessonTrailTracker.instance.clearTrail();
  });

  test('returns first unfinished lesson from trail', () async {
    final lessons = [
      TheoryMiniLessonNode(id: 'l1', title: 'A', content: ''),
      TheoryMiniLessonNode(id: 'l2', title: 'B', content: ''),
    ];
    final tracker = TheoryLessonTrailTracker.instance;
    await tracker.recordVisit('l1');
    await tracker.recordVisit('l2');
    await MiniLessonProgressTracker.instance.markCompleted('l1');

    final engine = TheoryLessonResumeEngine(
      library: _FakeLibrary(lessons),
      clusterer: TheoryLessonTagClusterer(library: _FakeLibrary(lessons)),
    );
    final res = await engine.getResumeTarget();
    expect(res?.id, 'l2');
  });

  test('falls back to first incomplete in cluster', () async {
    final lessons = [
      TheoryMiniLessonNode(
        id: 'l1',
        title: 'A',
        content: '',
        tags: ['x'],
        nextIds: ['l2'],
      ),
      TheoryMiniLessonNode(id: 'l2', title: 'B', content: '', tags: ['x']),
    ];
    final tracker = TheoryLessonTrailTracker.instance;
    await tracker.recordVisit('l1');
    await MiniLessonProgressTracker.instance.markCompleted('l1');

    final library = _FakeLibrary(lessons);
    final engine = TheoryLessonResumeEngine(
      library: library,
      clusterer: TheoryLessonTagClusterer(library: library),
    );
    final res = await engine.getResumeTarget();
    expect(res?.id, 'l2');
  });

  test('returns null when all completed', () async {
    final lessons = [TheoryMiniLessonNode(id: 'l1', title: 'A', content: ''));
    final tracker = TheoryLessonTrailTracker.instance;
    await tracker.recordVisit('l1');
    await MiniLessonProgressTracker.instance.markCompleted('l1');

    final library = _FakeLibrary(lessons);
    final engine = TheoryLessonResumeEngine(
      library: library,
      clusterer: TheoryLessonTagClusterer(library: library),
    );
    final res = await engine.getResumeTarget();
    expect(res, isNull);
  });
}
