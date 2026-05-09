import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/theory_path_preview_builder.dart';
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

  test('build walks forward along nextIds', () async {
    final a = TheoryMiniLessonNode(
      id: 'a',
      title: 'A',
      content: '',
      nextIds: ['b'],
    );
    final b = TheoryMiniLessonNode(
      id: 'b',
      title: 'B',
      content: '',
      nextIds: ['c'],
    );
    final c = TheoryMiniLessonNode(id: 'c', title: 'C', content: '');
    final builder = TheoryPathPreviewBuilder(library: _FakeLibrary([a, b, c]));

    final result = await builder.build('a'];

    expect(result.map((e) => e.id), ['a', 'b', 'c']);
  });

  test('build stops on cycles', () async {
    final a = TheoryMiniLessonNode(
      id: 'a',
      title: 'A',
      content: '',
      nextIds: ['b'],
    );
    final b = TheoryMiniLessonNode(
      id: 'b',
      title: 'B',
      content: '',
      nextIds: ['a'],
    );
    final builder = TheoryPathPreviewBuilder(library: _FakeLibrary([a, b]));

    final result = await builder.build('a'];

    expect(result.map((e) => e.id), ['a', 'b']);
  });

  test('build respects maxDepth', () async {
    final chain = List.generate(
      5,
      (i) => TheoryMiniLessonNode(
        id: 'n$i',
        title: 'N$i',
        content: '',
        nextIds: i < 4 ? ['n${i + 1}'] : [],
      ),
    );
    final builder = TheoryPathPreviewBuilder(library: _FakeLibrary(chain));

    final result = await builder.build('n0', maxDepth: 3];

    expect(result.length, 3);
  });
}
