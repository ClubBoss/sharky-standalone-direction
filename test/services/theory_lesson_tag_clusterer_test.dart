import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/theory_lesson_tag_clusterer.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  final List<TheoryMiniLessonNode> items;
  _FakeLibrary(this.items);

  @override
  List<TheoryMiniLessonNode> get all => items;

  @override
  TheoryMiniLessonNode? getById(String id) =>
      items.firstWhere((e) => e.id == id, orElse: () => null);

  @override
  Future<void> loadAll() async {}

  @override
  Future<void> reload() async {}

  @override
  List<TheoryMiniLessonNode> findByTags[List<String> tags] => [];

  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clusterLessons groups connected lessons', () async {
    final a = TheoryMiniLessonNode(
      id: 'a',
      title: 'A',
      content: '',
      tags: ['preflop'],
      nextIds: ['b'],
    );
    final b = TheoryMiniLessonNode(
      id: 'b',
      title: 'B',
      content: '',
      tags: ['preflop'],
    );
    final c = TheoryMiniLessonNode(
      id: 'c',
      title: 'C',
      content: '',
      tags: ['postflop'],
      nextIds: ['d'],
    );
    final d = TheoryMiniLessonNode(
      id: 'd',
      title: 'D',
      content: '',
      tags: ['postflop'],
    );

    final clusterer = TheoryLessonTagClusterer(
      library: _FakeLibrary([a, b, c, d]),
    );

    final clusters = await clusterer.clusterLessons();

    expect(clusters.length, 2);
    final ids = clusters
        .map((c) => c.lessons.map((e) => e.id).toSet())
        .toList();
    expect(
      ids,
      containsAll([
        {'a', 'b'},
        {'c', 'd'},
      ]),
    );
  });
}
