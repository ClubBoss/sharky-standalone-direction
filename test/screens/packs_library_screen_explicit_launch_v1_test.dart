import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/screens/packs_library_screen.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/services/canonical_legacy_training_launch_v1.dart';

void main() {
  test(
    'packs library explicit session launch input preserves session payload and shared legacy launch semantics',
    () {
      final session = TrainingSession(
        id: 'packs_library_session_v1',
        templateId: 'packs_library_template_v1',
        index: 4,
      );

      final input = buildPacksLibrarySessionLaunchInputV1(session);
      final screen = buildCanonicalLegacyTrainingScreenV1(input);

      expect(input.launchesSession, isTrue);
      expect(input.launchesPack, isFalse);
      expect(input.session, same(session));
      expect(input.pack, isNull);
      expect(input.startIndex, 0);
      expect(input.source, isNull);
      expect(input.onSessionEnd, isNull);

      expect(screen, isA<TrainingSessionScreen>());
      expect(screen.session, same(session));
      expect(screen.pack, isNull);
      expect(screen.startIndex, 0);
      expect(screen.source, isNull);
      expect(screen.onSessionEnd, isNull);
    },
  );
}
