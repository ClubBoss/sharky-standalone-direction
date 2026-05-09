import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: type adjust use v2
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: type adjust use v2
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/inline_theory_linking/postflop_jam_decision_theory_linker.dart';
import 'package:poker_analyzer/services/mini_lesson_library_service.dart';

class _FakeLibrary implements MiniLessonLibraryService {
  final List<TheoryMiniLessonNode> lessons; // fix: type adjust interface
  _FakeLibrary(this.lessons); // fix: type adjust interface

  @override
  List<TheoryMiniLessonNode> get all => lessons; // fix: type adjust interface

  @override
  TheoryMiniLessonNode? getById(String id) => // fix: type adjust interface
  lessons.cast<TheoryMiniLessonNode?>().firstWhere(
    (e) => e?.id == id,
    orElse: () => null,
  ); // fix: type adjust cast

  @override
  Future<TheoryMiniLessonNode?>
  getNextLesson() async => // fix: type adjust interface
      lessons.isEmpty ? null : lessons.first; // fix: type adjust interface

  @override
  Future<void> loadAll() async {} // fix: type adjust callback

  @override
  Future<void> reload() async {} // fix: type adjust callback

  @override
  List<TheoryMiniLessonNode> findByTags[List<String> tags] => lessons; // fix: type adjust interface

  @override
  List<TheoryMiniLessonNode> getByTags[Set<String> tags] => lessons; // fix: type adjust interface

  @override
  List<String> linkedPacksFor[String lessonId] => const <String>[]; // fix: type adjust generics

  @override
  Future<bool> isLessonCompleted(String lessonId) async => false; // fix: type adjust callback

  @override
  TheoryMiniLessonNode? findLessonByTag(String tag) => getById(tag); // fix: type adjust interface
}

void main() {
  test('links jam decision packs', () async {
    final lesson = TheoryMiniLessonNode(
      // fix: type adjust const
      id: 'l1',
      title: 'River Jam Decisions',
      content: '',
      tags: ['river', 'jam', 'decision'],
    );
    final library = _FakeLibrary([lesson]);
    final linker = PostflopJamDecisionTheoryLinker(library: library);
    final pack = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2
      id: 'p1',
      name: 'Pack',
      trainingType: TrainingType.postflop,
      tags: const <String>['jamDecision'], // fix: type adjust generics
      spots: <TrainingPackSpot>[
        TrainingPackSpot(id: 's1', hand: v2models.HandData()),
      ], // fix: type adjust generics
      spotCount: 1,
      meta: <String, Object?>{}, // fix: type adjust generics
    );

    await linker.link[[pack]];

    expect(pack.spots.first.meta['theoryRef'], {
      'lessonId': 'l1',
      'title': 'River Jam Decisions',
    });
  });

  test('ignores packs without jam tag', () async {
    final lesson = TheoryMiniLessonNode(
      // fix: type adjust const
      id: 'l1',
      title: 'River Jam Decisions',
      content: '',
      tags: ['river', 'jam', 'decision'],
    );
    final library = _FakeLibrary([lesson]);
    final linker = PostflopJamDecisionTheoryLinker(library: library);
    final pack = v2.TrainingPackTemplateV2(
      // fix: type adjust use v2
      id: 'p1',
      name: 'Pack',
      trainingType: TrainingType.postflop,
      tags: const <String>[], // fix: type adjust generics
      spots: <TrainingPackSpot>[
        TrainingPackSpot(id: 's1', hand: v2models.HandData()),
      ], // fix: type adjust generics
      spotCount: 1,
      meta: <String, Object?>{}, // fix: type adjust generics
    );

    await linker.link[[pack]];

    expect(pack.spots.first.meta.containsKey('theoryRef'), false);
  });
}

