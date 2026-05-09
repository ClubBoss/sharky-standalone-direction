import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2; // fix: v2 alias
import 'package:poker_analyzer/screens/v2/training_pack_template_editor_screen.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: v2 hand
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('clipboard paste bubble appears', (tester) async {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(id: 's', hand: v2models.HandData()),
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
    SharedPreferences.setMockInitialValues({});
    await Clipboard.setData(ClipboardData(text: 'GGPoker Hand #1'));
    await tester.pumpWidget(
      MaterialApp(
        home: TrainingPackTemplateEditorScreen(template: tpl, templates: [tpl]),
      ),
    );
    await tester.pumpAndSettle();
    final state =
        tester.state[find.byType(TrainingPackTemplateEditorScreen]) as dynamic;
    await state._checkClipboard();
    await tester.pump();
    expect(find.text('Paste Hands'), findsOneWidget);
    await Clipboard.setData(ClipboardData(text: 'foo'));
    await state._checkClipboard();
    await tester.pump();
    expect(find.text('Paste Hands'), findsNothing);
  });
}
