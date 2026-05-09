import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

void main() {
  test(
    'canonical practice launch resolution keeps world1 table practice on the shared world1 branch',
    () async {
      final kind = await resolveCanonicalPracticeLaunchKindV1(
        'world1_act0_table_literacy',
      );

      expect(kind, CanonicalPracticeLaunchKindV1.world1TablePractice);
    },
  );

  test(
    'canonical practice launch resolution selects surfaced session drills when runtime data exists',
    () async {
      final kind = await resolveCanonicalPracticeLaunchKindV1(
        'module_with_session_drills',
        hasSessionDrillsOverrideV1: (_) async => true,
      );

      expect(kind, CanonicalPracticeLaunchKindV1.sessionDrill);
    },
  );

  test(
    'canonical practice launch resolution falls back to surfaced legacy drills when runtime data is absent',
    () async {
      final kind = await resolveCanonicalPracticeLaunchKindV1(
        'module_without_session_drills',
        hasSessionDrillsOverrideV1: (_) async => false,
      );

      expect(kind, CanonicalPracticeLaunchKindV1.legacyDrill);
    },
  );

  test(
    'canonical practice launch resolution falls back to surfaced legacy drills on malformed session drill metadata',
    () async {
      final kind = await resolveCanonicalPracticeLaunchKindV1(
        'module_with_bad_session_drill_manifest',
        hasSessionDrillsOverrideV1: (_) async {
          throw const FormatException('bad manifest');
        },
      );

      expect(kind, CanonicalPracticeLaunchKindV1.legacyDrill);
    },
  );
}
