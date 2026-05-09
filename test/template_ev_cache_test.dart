import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/pack_generator_service.dart';
import 'package:poker_analyzer/services/training_pack_template_ui_service.dart';
import 'package:poker_analyzer/utils/template_coverage_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ev coverage counters update', (tester) async {
    final range = PackGeneratorService.topNHands(25).take(12).toList();
    final spots = <TrainingPackSpot>[];
    for (var i = 0; i < 10; i++) {
      final acts = {
        0: [ActionEntry(0, 0, 'push', amount: 10, ev: i < 4 ? 1.0 : null)),
      };
      spots.add(
        TrainingPackSpot(
          id: 's$i',
          hand: v2models.HandData(
            heroCards: '',
            position: HeroPosition.sb,
            heroIndex: 0,
            playerCount: 2,
            stacks: {'0': 10, '1': 10},
            actions: acts,
          ),
        ),
      );
    }
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 't',
      trainingType: TrainingType.custom,
      spotCount: 12,
      spots: spots,
    );
    tpl.meta['heroRange'] = range;
    expect(tpl.evCovered, 4);
    expect(tpl.icmCovered, 0);
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return SizedBox();
          },
        ),
      ),
    );
    final service = TrainingPackTemplateUiService();
    final generated = await service.generateMissingSpotsWithProgress(ctx, tpl);
    tpl.spots.addAll(generated);
    TemplateCoverageUtils.recountAll(tpl).applyTo(tpl.meta);
    expect(tpl.evCovered, 4 + generated.length);
  });
}
