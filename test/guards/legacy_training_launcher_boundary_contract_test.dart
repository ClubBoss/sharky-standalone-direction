import 'dart:io';

import 'package:test/test.dart';

final _directLegacyTrainingHostPattern = RegExp(
  r'TrainingSessionScreen\s*\(',
  dotAll: true,
);

void main() {
  test(
    'generic training session launcher quarantines world1 into the canonical learner loop',
    () {
      final trainingLauncher = File(
        'lib/services/training_session_launcher.dart',
      ).readAsStringSync();
      final canonicalLaunchPlan = File(
        'lib/services/canonical_training_session_launch_plan_v1.dart',
      ).readAsStringSync();
      final canonicalLegacyLaunch = File(
        'lib/services/canonical_legacy_training_launch_v1.dart',
      ).readAsStringSync();
      final trainingScreen = File(
        'lib/screens/training_session_screen.dart',
      ).readAsStringSync();
      final intake = File(
        'lib/ui_v2/screens/universal_intake_plan_screen.dart',
      ).readAsStringSync();
      final map = File(
        'lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart',
      ).readAsStringSync();
      final tableFirstNav = File(
        'lib/ui_v2/screens/table_first_navigation.dart',
      ).readAsStringSync();
      final runner = File(
        'lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart',
      ).readAsStringSync();
      final result = File(
        'lib/ui_v2/screens/session_result_screen.dart',
      ).readAsStringSync();

      expect(
        trainingLauncher.contains('pushCanonicalLegacyTrainingV1<void>('),
        isTrue,
        reason:
            'Legacy launcher should remain an explicit bridge for non-World1 training via the shared canonical legacy launch helper.',
      );
      expect(
        trainingLauncher.contains(
          'resolveCanonicalTrainingSessionLaunchPlanV1(',
        ),
        isTrue,
        reason:
            'TrainingSessionLauncher should delegate family resolution to the shared canonical launch plan seam.',
      );
      expect(
        trainingLauncher.contains('canonicalSessionDrillRouteV1('),
        isTrue,
        reason:
            'World/session launches should target the shared canonical surfaced launcher route.',
      );
      expect(
        canonicalLaunchPlan.contains(
          'class CanonicalTrainingSessionLaunchPlanV1',
        ),
        isTrue,
        reason:
            'Training session launch-family planning should live in a shared canonical plan model.',
      );
      expect(
        canonicalLaunchPlan.contains(
          'resolveCanonicalTrainingSessionLaunchPlanV1(',
        ),
        isTrue,
        reason:
            'Training session launch-family planning should be centralized in the shared canonical plan helper.',
      );
      expect(
        canonicalLegacyLaunch.contains(
          'class CanonicalLegacyTrainingLaunchInputV1',
        ),
        isTrue,
        reason:
            'Explicit legacy training payload launches should be normalized behind a shared canonical launch input model.',
      );
      expect(
        canonicalLegacyLaunch.contains(
          'Route<T> canonicalLegacyTrainingRouteV1<T>(',
        ),
        isTrue,
        reason:
            'Explicit legacy training payload launches should share one canonical route helper.',
      );
      expect(
        _directLegacyTrainingHostPattern.hasMatch(trainingLauncher),
        isFalse,
        reason:
            'TrainingSessionLauncher should not own raw TrainingSessionScreen construction after canonical legacy launch centralization.',
      );
      expect(
        trainingScreen.contains('_legacyWorld1ModuleIdV1()'),
        isTrue,
        reason:
            'The legacy host should retain a residual World1 quarantine for direct preview launches.',
      );
      expect(
        trainingScreen.contains('pushReplacement('),
        isTrue,
        reason:
            'Residual World1 legacy launches should replace the old host with the canonical runner.',
      );
      expect(
        intake.contains('training_session_launcher.dart'),
        isFalse,
        reason: 'Canonical intake must not import the generic legacy launcher.',
      );
      expect(
        map.contains('training_session_launcher.dart'),
        isFalse,
        reason: 'Canonical map must not import the generic legacy launcher.',
      );
      expect(
        tableFirstNav.contains('training_session_launcher.dart'),
        isFalse,
        reason:
            'Canonical table-first navigation must not import the generic legacy launcher.',
      );
      expect(
        runner.contains('training_session_launcher.dart'),
        isFalse,
        reason:
            'Canonical world1 runner must not import the generic legacy launcher.',
      );
      expect(
        result.contains('training_session_launcher.dart'),
        isFalse,
        reason:
            'Canonical result screen must not import the generic legacy launcher.',
      );
    },
  );
}
