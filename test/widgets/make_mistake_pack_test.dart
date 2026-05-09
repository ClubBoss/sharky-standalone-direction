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
import 'package:poker_analyzer/services/template_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('make mistake pack button', (tester) async {
    final spot1 = TrainingPackSpot(
      id: 'a',
      hand: v2models.HandData(),
      tags: <String>['Mistake'],
    );
    final spot2 = TrainingPackSpot(id: 'b', hand: v2models.HandData());
    final spots = <TrainingPackSpot>[spot1, spot2];
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
    final service = TemplateStorageService();
    await tester.pumpWidget(
      Provider<TemplateStorageService>.value(
        value: service,
        child: MaterialApp(
          home: TrainingPackTemplateEditorScreen(
            template: tpl,
            templates: [tpl],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Make Mistake Pack'));
    await tester.pumpAndSettle();
    expect(find.text('Test - Mistakes'), findsOneWidget);
    expect(service.templates.length, 1);
  });
}
