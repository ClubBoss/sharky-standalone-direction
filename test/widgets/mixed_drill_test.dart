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
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: v2 hand
import 'package:poker_analyzer/screens/v2/training_pack_template_list_screen.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mixed drill creates session with N spots', (tester) async {
    final spots1 = <TrainingPackSpot>[
      for (int i = 0; i < 5; i++)
        TrainingPackSpot(
          id: 's1_\$i',
          hand: v2models.HandData(),
        ),
    ]; // fix: v2 ctor/collections/types
    final t1 = v2.TrainingPackTemplateV2(
      id: 't1',
      name: 'One',
      spots: spots1,
      spotCount: spots1.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final spots2 = <TrainingPackSpot>[
      for (int i = 0; i < 5; i++)
        TrainingPackSpot(
          id: 's2_\$i',
          hand: v2models.HandData(),
        ),
    ]; // fix: v2 ctor/collections/types
    final t2 = v2.TrainingPackTemplateV2(
      id: 't2',
      name: 'Two',
      spots: spots2,
      spotCount: spots2.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    SharedPreferences.setMockInitialValues({
      'training_pack_templates': jsonEncode([t1.toJson(), t2.toJson())),
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
    await tester.enterText(find.byType(TextField).first, '3');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingSessionScreen), findsOneWidget);
    final state = tester.state[find.byType(TrainingSessionScreen]);
    final service = Provider.of<TrainingSessionService>(
      state.context,
      listen: false,
    );
    expect(service.spots.length, 3);
  });
}
