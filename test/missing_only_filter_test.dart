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
import 'package:poker_analyzer/screens/v2/training_pack_template_editor_screen.dart';
import 'package:poker_analyzer/widgets/v2/training_pack_spot_preview_card.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('toggle missing-only filter', (tester) async {
    final spot1 = TrainingPackSpot(
      id: 'a',
      hand: v2models.HandData(),
      heroEv: 1,
      heroIcmEv: 1,
    );
    final spot2 = TrainingPackSpot(id: 'b', hand: v2models.HandData());
    final spot3 = TrainingPackSpot(
      id: 'c',
      hand: v2models.HandData(),
      heroEv: 1,
    );
    final spots = <TrainingPackSpot>[spot1, spot2, spot3];
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
    expect(find.byType(TrainingPackSpotPreviewCard), findsNWidgets(3));
    await tester.tap(find.text('Missing only'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingPackSpotPreviewCard), findsNWidgets(2));
    await tester.tap(find.text('Missing only'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingPackSpotPreviewCard), findsNWidgets(3));
  });
}
