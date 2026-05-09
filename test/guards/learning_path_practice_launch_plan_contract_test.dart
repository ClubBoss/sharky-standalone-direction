import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'learning path practice family resolution is centralized in the canonical launch plan helper',
    () {
      final canonicalPracticePlan = File(
        'lib/services/canonical_learning_path_practice_launch_v1.dart',
      ).readAsStringSync();
      final stageLauncher = File(
        'lib/services/learning_path_stage_launcher.dart',
      ).readAsStringSync();

      expect(
        canonicalPracticePlan.contains(
          'enum CanonicalLearningPathPracticeLaunchFamilyV1',
        ),
        isTrue,
      );
      expect(
        canonicalPracticePlan.contains(
          'class CanonicalLearningPathPracticeLaunchPlanV1',
        ),
        isTrue,
      );
      expect(
        canonicalPracticePlan.contains(
          'resolveCanonicalLearningPathPracticeLaunchPlanV1(',
        ),
        isTrue,
      );
      expect(
        stageLauncher.contains(
          'resolveCanonicalLearningPathPracticeLaunchPlanV1(stage)',
        ),
        isTrue,
      );
      expect(stageLauncher.contains('final practiceLaunchPlan ='), isTrue);
      expect(
        stageLauncher.contains(
          'practiceLaunchPlan.launchesCanonicalWorld1Runner',
        ),
        isTrue,
      );
    },
  );
}
