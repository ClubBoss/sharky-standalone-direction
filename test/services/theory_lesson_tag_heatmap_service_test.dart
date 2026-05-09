import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/theory_lesson_tag_heatmap_service.dart';
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

  test('computeHeatmap aggregates link metrics per tag', () async {
    final a = TheoryMiniLessonNode(
      id: 'a',
      title: 'A',
      content: '',
      tags: ['preflop'],
      nextIds: ['b', 'c'],
    );
    final b = TheoryMiniLessonNode(
      id: 'b',
      title: 'B',
      content: '',
      tags: ['preflop', 'icm'],
      nextIds: ['c'],
    );
    final c = TheoryMiniLessonNode(
      id: 'c',
      title: 'C',
      content: '',
      tags: ['icm'],
      nextIds: [],
    );
    final service = TheoryLessonTagHeatmapService(
      library: _FakeLibrary([a, b, c]),
    );

    final result = await service.computeHeatmap();

    expect(result['preflop']!.count, 2);
    expect(result['preflop']!.incomingLinks, 1);
    expect(result['preflop']!.outgoingLinks, 3);
    expect(result['icm']!.count, 2);
    expect(result['icm']!.incomingLinks, 2);
    expect(result['icm']!.outgoingLinks, 1);
  });

  test('deadTags lists tags with no links', () {
    final stats = {
      'x': TheoryTagStats(
        tag: 'x',
        count: 1,
        incomingLinks: 0,
        outgoingLinks: 0,
      ),
      'y': TheoryTagStats(
        tag: 'y',
        count: 2,
        incomingLinks: 1,
        outgoingLinks: 1,
      ),
    };
    final service = TheoryLessonTagHeatmapService(library: _FakeLibrary([]));
    final dead = service.deadTags[stats];
    expect(dead, ['x']);
  });
}
