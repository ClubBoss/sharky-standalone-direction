import 'dart:io';

import 'package:test/test.dart';

final _directImplicitSourceLaunchPattern = RegExp(
  r'TrainingSessionScreen\s*\(\s*[^)]*?\bsource\s*:',
  dotAll: true,
);

final _directImplicitEmptyLaunchPattern = RegExp(
  r'(?:const\s+)?TrainingSessionScreen\s*\(\s*\)',
  dotAll: true,
);

void main() {
  test(
    'bare and source-only legacy training launches use the shared canonical implicit launch helper',
    () {
      final sharedHelper = File(
        'lib/screens/training_session_screen.dart',
      ).readAsStringSync();
      final reviewLauncher = File(
        'lib/services/review_launcher_service.dart',
      ).readAsStringSync();
      final activeSessionLauncher = File(
        'lib/services/smart_review_service.dart',
      ).readAsStringSync();

      expect(
        sharedHelper.contains(
          'class CanonicalLegacyTrainingImplicitLaunchInputV1',
        ),
        isTrue,
      );
      expect(
        sharedHelper.contains('canonicalLegacyTrainingImplicitRouteV1('),
        isTrue,
      );

      expect(
        reviewLauncher.contains(
          'CanonicalLegacyTrainingImplicitLaunchInputV1.reviewSingle(',
        ),
        isTrue,
      );
      expect(
        reviewLauncher.contains(
          'CanonicalLegacyTrainingImplicitLaunchInputV1.reviewMultiple(',
        ),
        isTrue,
      );
      expect(
        reviewLauncher.contains('canonicalLegacyTrainingImplicitRouteV1('),
        isTrue,
      );

      expect(
        activeSessionLauncher.contains(
          'CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession()',
        ),
        isTrue,
      );
      expect(
        activeSessionLauncher.contains(
          'canonicalLegacyTrainingImplicitRouteV1(',
        ),
        isTrue,
      );

      final dartFiles = <File>[
        for (final root in <String>[
          'lib/screens',
          'lib/services',
          'lib/widgets',
          'lib/shop',
        ])
          ...Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart')),
      ];

      var helperUsageCount = 0;
      for (final file in dartFiles) {
        final path = file.path;
        final source = file.readAsStringSync();
        if (path == 'lib/screens/training_session_screen.dart' ||
            path == 'lib/screens/v2/training_session_screen.dart' ||
            path == 'lib/services/canonical_legacy_training_launch_v1.dart') {
          continue;
        }

        if (source.contains('canonicalLegacyTrainingImplicitRouteV1(')) {
          helperUsageCount += 1;
        }

        expect(
          _directImplicitSourceLaunchPattern.hasMatch(source),
          isFalse,
          reason:
              '$path should not instantiate TrainingSessionScreen directly for source-only review launches, even across multiline constructor usage.',
        );
        expect(
          _directImplicitEmptyLaunchPattern.hasMatch(source),
          isFalse,
          reason:
              '$path should not instantiate TrainingSessionScreen directly for implicit active-session launches, even across multiline constructor usage.',
        );
      }

      expect(
        helperUsageCount,
        greaterThan(20),
        reason:
            'Wave 2 should cut a broad cluster of implicit legacy launches over to the shared helper.',
      );
    },
  );
}
