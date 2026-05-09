import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';

void main() {
  test('active-session launches preserve the active runtime semantics', () {
    final screen = buildCanonicalLegacyTrainingImplicitScreenV1(
      const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
    );

    expect(screen, isA<TrainingSessionScreen>());
    expect(screen.pack, isNull);
    expect(screen.session, isNull);
    expect(screen.startIndex, 0);
    expect(screen.source, isNull);
  });

  test('review launches preserve source tagging semantics', () {
    final single = buildCanonicalLegacyTrainingImplicitScreenV1(
      const CanonicalLegacyTrainingImplicitLaunchInputV1.reviewSingle(
        moduleId: 'world1_spine_campaign_v1',
      ),
    );
    final multiple = buildCanonicalLegacyTrainingImplicitScreenV1(
      const CanonicalLegacyTrainingImplicitLaunchInputV1.reviewMultiple(
        moduleIds: 'w1,w2,w3',
      ),
    );

    expect(single, isA<TrainingSessionScreen>());
    expect(single.source, 'review_single:world1_spine_campaign_v1');

    expect(multiple, isA<TrainingSessionScreen>());
    expect(multiple.source, 'review_multiple:w1,w2,w3');
  });
}
