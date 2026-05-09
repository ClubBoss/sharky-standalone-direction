import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'training session runtime family resolution is centralized in the canonical launch plan helper',
    () {
      final canonicalLaunchPlan = File(
        'lib/services/canonical_training_session_launch_plan_v1.dart',
      ).readAsStringSync();
      final trainingLauncher = File(
        'lib/services/training_session_launcher.dart',
      ).readAsStringSync();

      expect(
        canonicalLaunchPlan.contains(
          'enum CanonicalTrainingSessionLaunchFamilyV1',
        ),
        isTrue,
      );
      expect(
        canonicalLaunchPlan.contains(
          'class CanonicalTrainingSessionLaunchPlanV1',
        ),
        isTrue,
      );
      expect(
        canonicalLaunchPlan.contains(
          'resolveCanonicalTrainingSessionLaunchPlanV1(',
        ),
        isTrue,
      );
      expect(
        trainingLauncher.contains(
          'final launchPlan = await resolveCanonicalTrainingSessionLaunchPlanV1(',
        ),
        isTrue,
      );
      expect(
        trainingLauncher.contains(
          'if (launchPlan.launchesCanonicalWorld1Runner)',
        ),
        isTrue,
      );
      expect(
        trainingLauncher.contains('if (launchPlan.launchesTheoryPreview)'),
        isTrue,
      );
      expect(
        trainingLauncher.contains('if (launchPlan.launchesSessionDrill)'),
        isTrue,
      );
    },
  );
}
