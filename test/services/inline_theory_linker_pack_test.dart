import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/inline_theory_linker.dart';

void main() {
  test('linkPack adds inlineLessonId based on tags', () {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(
        id: 's1',
        hand: v2models.HandData(),
        tags: <String>['cbet'],
      ),
      TrainingPackSpot(
        id: 's2',
        hand: v2models.HandData(),
        tags: <String>['probe'],
      ),
      TrainingPackSpot(
        id: 's3',
        hand: v2models.HandData(),
        tags: <String>['cbet'],
        inlineLessonId: 'existing',
      ),
    ]; // fix: v2 ctor/collections/types
    final pack = v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'Pack',
      trainingType: TrainingType.pushFold,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types

    const lessons = [
      TheoryMiniLessonNode(
        id: 'l1',
        title: 'CBet',
        content: '',
        tags: ['cbet'],
      ),
      TheoryMiniLessonNode(
        id: 'l2',
        title: 'Probe',
        content: '',
        tags: ['probe'],
      ),
    ];

    InlineTheoryLinker.linkPack(pack, lessons);

    expect(pack.spots[0].inlineLessonId, 'l1');
    expect(pack.spots[1].inlineLessonId, 'l2');
    // Existing ID should remain untouched
    expect(pack.spots[2].inlineLessonId, 'existing');
  });
}
