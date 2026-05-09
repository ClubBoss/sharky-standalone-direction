import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('learning path launcher wrappers keep legacy practice launching explicit', () {
    final packLauncher = File(
      'lib/services/training_pack_launcher_service.dart',
    ).readAsStringSync();
    final pathLauncher = File(
      'lib/services/learning_path_launcher_service.dart',
    ).readAsStringSync();
    final stageLauncher = File(
      'lib/services/learning_path_stage_launcher.dart',
    ).readAsStringSync();
    final canonicalPracticePlan = File(
      'lib/services/canonical_learning_path_practice_launch_v1.dart',
    ).readAsStringSync();
    final dashboard = File(
      'lib/screens/learning_path_dashboard.dart',
    ).readAsStringSync();
    final horizontal = File(
      'lib/screens/learning_path_horizontal_view_screen.dart',
    ).readAsStringSync();
    final linear = File(
      'lib/screens/learning_path_linear_view_screen.dart',
    ).readAsStringSync();

    expect(
      packLauncher.contains('launcher = launcher ?? TrainingSessionLauncher()'),
      isTrue,
      reason:
          'Training pack launcher service should remain an explicit wrapper over TrainingSessionLauncher.',
    );
    expect(
      pathLauncher.contains(
        'stageLauncher = stageLauncher ?? LearningPathStageLauncher()',
      ),
      isTrue,
      reason:
          'Learning path launcher service should funnel next-stage execution through the stage launcher seam.',
    );
    expect(
      stageLauncher.contains(
        '_launcher = launcher ?? TrainingSessionLauncher()',
      ),
      isTrue,
      reason:
          'Learning path stage launcher should keep its practice-stage launcher dependency explicit.',
    );
    expect(
      stageLauncher.contains(
        'resolveCanonicalLearningPathPracticeLaunchPlanV1(stage)',
      ),
      isTrue,
      reason:
          'Learning path stage launcher should delegate practice-family resolution to the shared canonical plan seam.',
    );
    expect(
      stageLauncher.contains('await _launcher.launch(tpl);'),
      isTrue,
      reason:
          'Legacy practice fallback should still route through the legacy launcher wrapper after canonical planning resolves the family.',
    );
    expect(
      stageLauncher.contains('case StageType.theory:'),
      isTrue,
      reason: 'Theory stages should stay separate from practice launching.',
    );
    expect(
      stageLauncher.contains('TheoryPackReaderScreen('),
      isTrue,
      reason:
          'Theory stage routing should remain on theory-owned screens, not the training launcher.',
    );

    expect(
      packLauncher.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Learning path wrapper services should not directly own canonical runner launching in this seam.',
    );
    expect(
      pathLauncher.contains('TrainingSessionLauncher()'),
      isFalse,
      reason:
          'Learning path launcher service should no longer bypass the stage launcher seam with a direct legacy launcher.',
    );
    expect(
      pathLauncher.contains('await stageLauncher.launch(context, stage);'),
      isTrue,
      reason:
          'Learning path launcher service should hand next-stage execution to LearningPathStageLauncher.',
    );
    expect(
      pathLauncher.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Learning path launcher service should not directly own canonical runner launching in this seam.',
    );
    expect(
      stageLauncher.contains('pushCanonicalWorld1RunnerV1<void>'),
      isTrue,
      reason:
          'Learning path stage launcher should default to canonical runner ownership, not the legacy screen wrapper.',
    );
    expect(
      stageLauncher.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Learning path stage launcher should no longer depend on the table-first screen wrapper for canonical runner handoff.',
    );
    expect(
      canonicalPracticePlan.contains(
        'CanonicalLearningPathPracticeLaunchPlanV1',
      ),
      isTrue,
      reason:
          'Learning path practice-family resolution should now live in a shared canonical plan model.',
    );
    expect(
      canonicalPracticePlan.contains(
        'resolveCanonicalLearningPathPracticeLaunchPlanV1(',
      ),
      isTrue,
      reason:
          'Learning path practice-family resolution should be centralized in the shared canonical plan helper.',
    );

    expect(
      dashboard.contains('LearningPathStageLauncher().launch(context, next);'),
      isTrue,
      reason:
          'Active learning path dashboard should still funnel stage opening through the stage launcher wrapper.',
    );
    expect(
      horizontal.contains('TrainingPackLauncherService().launch(node);'),
      isTrue,
      reason:
          'Learning path horizontal view should still funnel dynamic practice nodes through the pack launcher wrapper.',
    );
    expect(
      linear.contains('TrainingPackLauncherService().launch(node);'),
      isTrue,
      reason:
          'Learning path linear view should still funnel dynamic practice nodes through the pack launcher wrapper.',
    );
  });
}
