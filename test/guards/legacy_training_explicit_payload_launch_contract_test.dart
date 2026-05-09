import 'dart:io';

import 'package:test/test.dart';

final _directExplicitLegacyLaunchPattern = RegExp(
  r'TrainingSessionScreen\s*\(\s*(?:[^)]*?\bpack\s*:|[^)]*?\bsession\s*:)',
  dotAll: true,
);

void main() {
  test(
    'explicit pack and session legacy launches use the shared canonical legacy launch helper',
    () {
      const explicitLaunchOwners = <String>[
        'lib/services/training_session_launcher.dart',
        'lib/screens/pack_suggestion_preview_screen.dart',
        'lib/screens/training_pack_preview_screen.dart',
        'lib/screens/theory_pack_preview_screen.dart',
        'lib/screens/training_session_summary_screen.dart',
        'lib/screens/pack_preview_screen.dart',
        'lib/screens/training_recap_screen.dart',
        'lib/screens/training_packs_screen.dart',
        'lib/screens/packs_library_screen.dart',
        'lib/widgets/pack_suggestion_banner.dart',
        'lib/screens/theory_staging_preview_screen.dart',
      ];

      final sharedLaunchHelper = File(
        'lib/services/canonical_legacy_training_launch_v1.dart',
      ).readAsStringSync();

      expect(
        sharedLaunchHelper.contains(
          'class CanonicalLegacyTrainingLaunchInputV1',
        ),
        isTrue,
      );
      expect(
        sharedLaunchHelper.contains('pushCanonicalLegacyTrainingV1<'),
        isTrue,
      );
      expect(
        sharedLaunchHelper.contains(
          'pushReplacementCanonicalLegacyTrainingV1<',
        ),
        isTrue,
      );

      for (final path in explicitLaunchOwners) {
        final source = File(path).readAsStringSync();
        expect(
          source.contains('CanonicalLegacyTrainingLaunchInputV1.pack(') ||
              source.contains('CanonicalLegacyTrainingLaunchInputV1.session('),
          isTrue,
          reason:
              '$path should construct the shared explicit legacy-launch input model.',
        );
        expect(
          source.contains('pushCanonicalLegacyTrainingV1<') ||
              source.contains('pushReplacementCanonicalLegacyTrainingV1<'),
          isTrue,
          reason: '$path should launch through the shared canonical helper.',
        );
        expect(
          _directExplicitLegacyLaunchPattern.hasMatch(source),
          isFalse,
          reason:
              '$path should not instantiate TrainingSessionScreen directly for explicit pack/session launches, even across multiline constructor usage.',
        );
      }
    },
  );
}
