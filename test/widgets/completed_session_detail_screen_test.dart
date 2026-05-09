import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/screens/completed_session_detail_screen.dart';
import 'package:poker_analyzer/services/completed_training_pack_registry.dart';
import 'package:poker_analyzer/services/training_pack_fingerprint_generator.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart'
    as v2models; // fix: v2 hand
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  v2.TrainingPackTemplateV2 buildPack(String id) {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(id: 's1', hand: v2models.HandData()),
    ]; // fix: v2 ctor/collections/types
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

  testWidgets('displays session details', (tester) async {
    final registry = CompletedTrainingPackRegistry();
    final pack = buildPack('p1');
    await registry.storeCompletedPack(
      pack,
      completedAt: DateTime.utc(2024, 1, 1),
      accuracy: 0.8,
    );
    final fp = TrainingPackFingerprintGenerator().generateFromTemplate(pack);

    await tester.pumpWidget(
      MaterialApp(home: CompletedSessionDetailScreen(fingerprint: fp)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pack p1'), findsOneWidget);
    expect(find.textContaining('Training Type: Quiz'), findsOneWidget);
    expect(find.textContaining('Accuracy: 80%'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('shows not found when missing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CompletedSessionDetailScreen(fingerprint: 'missing')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Session not found'), findsOneWidget);
  });
}
