import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingSessionService,
        TrainingType,
        HandData,
        TrainingPackTemplate,
        TrainingPackTemplateV2; // fix: shadowed type name
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/widgets/training_pack_history_list_widget.dart';
import 'package:poker_analyzer/services/completed_training_pack_registry.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';

class MockLauncher extends Mock implements TrainingSessionLauncher {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  v2.TrainingPackTemplateV2 buildPack(String id) {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(id: 's1', hand: v2models.HandData()),
    ];
    return v2.TrainingPackTemplateV2(
      id: id,
      name: 'Pack $id',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
  }

  testWidgets('shows completed pack history', (tester) async {
    final registry = CompletedTrainingPackRegistry();
    final pack = buildPack('p1');
    await registry.storeCompletedPack(
      pack,
      completedAt: DateTime.utc(2024, 1, 1),
      accuracy: 0.9,
      duration: const Duration(minutes: 5),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TrainingPackHistoryListWidget())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pack p1'), findsOneWidget);
    expect(find.textContaining('Accuracy: 90%'), findsOneWidget);
    expect(find.textContaining('Duration'), findsOneWidget);
  });

  testWidgets('shows placeholder when no history', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TrainingPackHistoryListWidget())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No completed packs yet'), findsOneWidget);
  });

  testWidgets('tapping history item replays pack', (tester) async {
    final registry = CompletedTrainingPackRegistry();
    final pack = buildPack('p1');
    await registry.storeCompletedPack(pack);

    final launcher = MockLauncher();
    when(() => launcher.launchFromYaml(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TrainingPackHistoryListWidget(launcher: launcher)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pack p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replay'));
    await tester.pumpAndSettle();

    verify(() => launcher.launchFromYaml(any())).called(1);
  });
}
