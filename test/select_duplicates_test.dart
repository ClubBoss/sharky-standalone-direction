import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/screens/v2/training_pack_template_editor_screen.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('select duplicates', (tester) async {
    final hand = v2models.HandData(
      heroCards: 'Ah Kh',
      position: HeroPosition.sb,
    ); // fix: v2 ctor/collections/types
    final dup1 = TrainingPackSpot(id: 'a', hand: hand);
    final dup2 = TrainingPackSpot(id: 'b', hand: hand);
    final unique = TrainingPackSpot(
      id: 'c',
      hand: v2models.HandData(heroCards: '2c 2d'),
    );
    final spots = <TrainingPackSpot>[dup1, dup2, unique];
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 't',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    await tester.pumpWidget(
      MaterialApp(
        home: TrainingPackTemplateEditorScreen(template: tpl, templates: [tpl]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Duplicate').first);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
  });
}
