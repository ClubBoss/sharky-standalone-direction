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
import 'package:poker_analyzer/models/evaluation_result.dart';
import 'package:poker_analyzer/screens/v2/training_pack_template_editor_screen.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  testWidgets('mistakes filter shows only incorrect spots', (tester) async {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(
        id: 's1',
        title: 'Spot 1',
        hand: v2models.HandData(),
        evalResult: EvaluationResult(
          correct: true,
          expectedAction: '-',
          userEquity: 0,
          expectedEquity: 0,
        ),
      ),
      TrainingPackSpot(
        id: 's2',
        title: 'Spot 2',
        hand: v2models.HandData(),
        evalResult: EvaluationResult(
          correct: false,
          expectedAction: '-',
          userEquity: 0,
          expectedEquity: 0,
        ),
      ),
    ]; // fix: v2 ctor/collections/types
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 'Test',
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
    expect(find.text('Spot 1'), findsOneWidget);
    expect(find.text('Spot 2'), findsOneWidget);
    await tester.tap(find.text('Mistakes'));
    await tester.pumpAndSettle();
    expect(find.text('Spot 1'), findsNothing);
    expect(find.text('Spot 2'), findsOneWidget);
  });
}
