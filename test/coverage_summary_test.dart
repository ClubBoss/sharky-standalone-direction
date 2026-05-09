import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/utils/template_coverage_utils.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('CoverageSummary calculates and applies meta', () {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(
        id: 's1',
        hand: v2models.HandData(
          heroCards: '',
          position: HeroPosition.sb,
          heroIndex: 0,
          playerCount: 2,
          stacks: <String, double>{'0': 10, '1': 10},
          actions: <int, List<ActionEntry>>{
            0: <ActionEntry>[ActionEntry(0, 0, 'push', amount: 10, ev: 1.0)),
          },
        ),
        priority: 2,
      ),
      TrainingPackSpot(
        id: 's2',
        hand: v2models.HandData(
          heroCards: '',
          position: HeroPosition.sb,
          heroIndex: 0,
          playerCount: 2,
          stacks: <String, double>{'0': 10, '1': 10},
          actions: <int, List<ActionEntry>>{
            0: <ActionEntry>[ActionEntry(0, 0, 'push', amount: 10)),
          },
        ),
        priority: 3,
      ),
    ];
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 't',
      spots: spots,
      spotCount: spots.length,
      trainingType: TrainingType.pushFold,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final summary = TemplateCoverageUtils.recountAll(tpl);
    expect(summary.ev, 2);
    expect(summary.icm, 0);
    expect(summary.total, 5);
    summary.applyTo(tpl.meta);
    expect(tpl.evCovered, 2);
    expect(tpl.icmCovered, 0);
    expect(tpl.totalWeight, 5);
  });
}
