import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/learning_path_stage_model.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/services/canonical_learning_path_practice_launch_v1.dart';
import 'package:poker_analyzer/services/learning_path_stage_launcher.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('verified pair is the only canonical World1 runner launch case', () {
    final verifiedStage = LearningPathStageModel.fromJson(<String, dynamic>{
      'id': 'open_fold_early_mtt',
      'title': 'Open or Fold',
      'description': 'Evaluate opens from UTG and UTG+1',
      'packId': 'open_fold_early_mtt',
      'canonicalModuleId': 'world1_spine_campaign_v1',
      'requiredAccuracy': 80,
      'minHands': 10,
    });

    final wrongModule = LearningPathStageModel.fromJson(<String, dynamic>{
      'id': 'open_fold_early_mtt',
      'title': 'Open or Fold',
      'description': 'Evaluate opens from UTG and UTG+1',
      'packId': 'open_fold_early_mtt',
      'canonicalModuleId': 'world1_seat_map_basics_v1',
      'requiredAccuracy': 80,
      'minHands': 10,
    });

    final wrongPack = LearningPathStageModel.fromJson(<String, dynamic>{
      'id': 'open_fold_mid_cash',
      'title': 'Open or Fold',
      'description': 'Evaluate opens from LJ and HJ',
      'packId': 'open_fold_mid_cash',
      'canonicalModuleId': 'world1_spine_campaign_v1',
      'requiredAccuracy': 80,
      'minHands': 10,
    });

    expect(
      shouldLaunchCanonicalWorld1RunnerForLearningPathStageV1(verifiedStage),
      isTrue,
    );
    expect(
      shouldLaunchCanonicalWorld1RunnerForLearningPathStageV1(wrongModule),
      isFalse,
    );
    expect(
      shouldLaunchCanonicalWorld1RunnerForLearningPathStageV1(wrongPack),
      isFalse,
    );
  });

  testWidgets(
    'practice launch from the learning-path seam reaches the canonical World1 host',
    (tester) async {
      final stage = LearningPathStageModel.fromJson(<String, dynamic>{
        'id': 'open_fold_early_mtt',
        'title': 'Open or Fold',
        'description': 'Evaluate opens from UTG and UTG+1',
        'packId': 'open_fold_early_mtt',
        'canonicalModuleId': 'world1_spine_campaign_v1',
        'requiredAccuracy': 80,
        'minHands': 10,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await LearningPathStageLauncher(
                      canonicalWorld1Launcher:
                          (
                            BuildContext context, {
                            required String moduleId,
                            required String moduleTitle,
                            required String mode,
                          }) => Navigator.of(context).push<void>(
                            canonicalWorld1RunnerRouteV1<void>(
                              moduleId: moduleId,
                              moduleTitle: moduleTitle,
                              mode: mode,
                            ),
                          ),
                      overlayLauncher: (_) async {},
                    ).launch(context, stage);
                  },
                  child: const Text('OPEN_STAGE'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('OPEN_STAGE'));
      await tester.pumpAndSettle();

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      expect(find.byType(TrainingSessionScreen), findsNothing);
    },
  );
}
