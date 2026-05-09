import 'package:test/test.dart';
import 'package:poker_analyzer/canonical/recap_reinforcement_system_v1.dart';

void main() {
  test('recap reinforcement profiles stay deterministic and ordered', () {
    expect(
      kRecapReinforcementPatternProfilesV1
          .map((profile) => profile.id)
          .toList(growable: false),
      const <String>[
        'specialized_checkpoint_chain_v1',
        'block_closure_recap_chain_v1',
        'advanced_world_recap_closure_v1',
        'synthesis_checkpoint_closure_v1',
        'late_world_differentiated_recap_v1',
        'world10_applied_track_recap_v1',
      ],
    );
    expect(
      kRecapReinforcementPatternProfilesV1
          .map((profile) => profile.rolloutOrder)
          .toList(growable: false),
      const <int>[10, 20, 30, 40, 50, 60],
    );
  });

  test(
    'anchor paths stay unique and world10 recap remains fully differentiated',
    () {
      final anchorPaths = <String>{};
      for (final profile in kRecapReinforcementPatternProfilesV1) {
        for (final anchor in profile.anchors) {
          expect(anchorPaths.add(anchor.anchorPath), isTrue);
        }
      }

      final world10Profile = kRecapReinforcementPatternProfilesV1.last;
      expect(
        world10Profile.anchors
            .map((anchor) => anchor.trackKind)
            .toList(growable: false),
        const <String?>['cash', 'tournament', 'mixed'],
      );
    },
  );
}
