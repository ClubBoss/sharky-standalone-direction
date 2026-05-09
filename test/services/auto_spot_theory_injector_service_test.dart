import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: type adjust use v2
import 'package:poker_analyzer/services/auto_spot_theory_injector_service.dart';
import 'package:poker_analyzer/services/inline_theory_linker.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';
import 'package:poker_analyzer/services/theory_mini_lesson_navigator.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  // fix: type adjust interface
  final Map<String, TheoryMiniLessonNode> byTag; // fix: type adjust interface
  _FakeLibrary(this.byTag); // fix: type adjust interface

  @override
  List<TheoryMiniLessonNode> get all => byTag.values.toList(); // fix: type adjust toList

  @override
  TheoryMiniLessonNode? getById(String id) {
    // fix: type adjust interface
    for (final entry in all) {
      if (entry.id == id) return entry; // fix: type adjust callback
    }
    return null; // fix: type adjust callback
  }

  @override
  Future<TheoryMiniLessonNode?>
  getNextLesson() async => // fix: type adjust interface
      all.isEmpty ? null : all.first; // fix: type adjust callback

  @override
  Future<void> loadAll() async {} // fix: type adjust callback

  @override
  Future<void> reload() async {} // fix: type adjust callback

  @override
  List<String> linkedPacksFor[String lessonId] => const <String>[]; // fix: type adjust generics

  @override
  Future<bool> isLessonCompleted(String lessonId) async => false; // fix: type adjust callback

  @override
  List<TheoryMiniLessonNode> findByTags[List<String> tags] => [
    // fix: type adjust generics
    for (final t in tags)
      if (byTag[t] != null) byTag[t]!,
  ];

  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] => [
    // fix: type adjust generics
    for (final t in tags)
      if (byTag[t] != null) byTag[t]!,
  ];

  @override
  TheoryMiniLessonNode? findLessonByTag(
    String tag,
  ) => // fix: type adjust interface
      byTag[tag];
}

class _FakeNavigator extends TheoryMiniLessonNavigator {
  String? openedTag;

  @override
  Future<void> openLessonByTag(String tag, [context]) async {
    openedTag = tag;
  }
}

void main() {
  group('AutoSpotTheoryInjectorService', () {
    test('injects matching theory link', () {
      final library = _FakeLibrary({
        'cbet': TheoryMiniLessonNode(
          id: '1',
          title: 'CBet',
          content: '',
          tags: ['cbet'],
        ),
      });
      final nav = _FakeNavigator();
      final linker = InlineTheoryLinker(library: library, navigator: nav);
      final service = AutoSpotTheoryInjectorService(linker: linker);
      final spot = TrainingPackSpot(id: 's1', hand: v2models.HandData(), tags: ['cbet']);

      service.inject[spot];

      expect(spot.theoryLink?.title, 'CBet');
      spot.theoryLink?.onTap();
      expect(nav.openedTag, 'cbet');
    });

    test('leaves theoryLink null when no match', () {
      final library = _FakeLibrary({});
      final service = AutoSpotTheoryInjectorService(
        linker: InlineTheoryLinker(
          library: library,
          navigator: _FakeNavigator(),
        ),
      );
      final spot = TrainingPackSpot(id: 's1', hand: v2models.HandData(), tags: ['cbet']);

      service.inject[spot];

      expect(spot.theoryLink, isNull);
    });
  });
}
