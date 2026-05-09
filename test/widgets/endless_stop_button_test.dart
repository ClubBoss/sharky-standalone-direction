import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingSessionService,
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/screens/v2/training_pack_template_list_screen.dart';
import 'package:poker_analyzer/screens/session_result_screen.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('endless drill stop shows summary', (tester) async {
    final spot = TrainingPackSpot(
      id: 's1',
      hand: v2models.HandData(
        actions: <int, List<ActionEntry>>{
          0: <ActionEntry>[ActionEntry(0, 0, 'fold')),
        },
      ),
    );
    final spots = <TrainingPackSpot>[spot];
    final tpl = v2.TrainingPackTemplateV2(
      id: 't1',
      name: 'One',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    SharedPreferences.setMockInitialValues({
      'training_pack_templates': jsonEncode([tpl.toJson())),
    });
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TrainingSessionService(),
        child: const MaterialApp(home: TrainingPackTemplateListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mixed Drill'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.tap(find.text('Endless Drill'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingSessionScreen), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Stop Drill & show summary'));
    await tester.pumpAndSettle();
    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(find.textContaining(' / 1'), findsOneWidget);
  });
}
