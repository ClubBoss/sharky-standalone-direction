import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingPackTemplate,
        TrainingPackTemplateV2,
        HandData; // fix: hide shim
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2; // fix: v2 alias
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models; // fix: v2 hand
import 'package:poker_analyzer/models/evaluation_result.dart';
import 'package:poker_analyzer/services/evaluation_executor_service.dart';
import 'package:poker_analyzer/screens/v2/training_pack_template_editor_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockEvaluationExecutorService implements EvaluationExecutorService {
  @override
  Future<EvaluationResult> evaluate[TrainingPackSpot spot] async {
    await Future.delayed(Duration(milliseconds: 50));
    return EvaluationResult(
      correct: true,
      expectedAction: '-',
      userEquity: 0,
      expectedEquity: 0,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('evaluate all spots', (tester) async {
    final spots = <TrainingPackSpot>[
      TrainingPackSpot(id: 's1', hand: v2models.HandData()),
      TrainingPackSpot(id: 's2', hand: v2models.HandData()),
      TrainingPackSpot(id: 's3', hand: v2models.HandData()),
    ]; // fix: v2 ctor/collections/types
    final tpl = v2.TrainingPackTemplateV2(
      id: 't1',
      name: 'Test',
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      Provider<EvaluationExecutorService>.value[value: _MockEvaluationExecutorService(],
        child: MaterialApp(
          home: TrainingPackTemplateEditorScreen(
            template: tpl,
            templates: [tpl],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evaluate All'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tpl.spots.every((s) => s.evalResult != null), isTrue);
    expect(find.textContaining('3 spots'), findsOneWidget);
  });
}
