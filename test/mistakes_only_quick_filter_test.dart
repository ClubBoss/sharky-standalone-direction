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
import 'package:poker_analyzer/widgets/v2/training_pack_spot_preview_card.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('toggle mistakes-only quick filter', (tester) async {
    final ok = TrainingPackSpot(
      id: 'a',
      hand: v2models.HandData(),
      evalResult: EvaluationResult(
        correct: true,
        expectedAction: '-',
        userEquity: 0,
        expectedEquity: 0,
      ),
    );
    final err = TrainingPackSpot(
      id: 'b',
      hand: v2models.HandData(),
      evalResult: EvaluationResult(
        correct: false,
        expectedAction: '-',
        userEquity: 0,
        expectedEquity: 0,
      ),
    );
    final spots = <TrainingPackSpot>[ok, err];
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
    expect(find.byType(TrainingPackSpotPreviewCard), findsNWidgets(2));
    await tester.tap(find.byTooltip('Mistakes Only'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingPackSpotPreviewCard), findsOneWidget);
    await tester.tap(find.byTooltip('Mistakes Only'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingPackSpotPreviewCard), findsNWidgets(2));
  });
}
