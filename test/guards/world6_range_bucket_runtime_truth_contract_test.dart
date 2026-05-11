import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'standalone world6 range-bucket drills stay action-authored while the canonical runner renders the action bar',
    () {
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final rangeBucketContract = File(
        'test/ui_v2/session_drill_player_range_bucket_contract_test.dart',
      ).readAsStringSync();
      final strongRaiseDrill = File(
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.classify_strong_raise.json',
      ).readAsStringSync();
      final missedFoldDrill = File(
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.classify_missed_fold.json',
      ).readAsStringSync();

      expect(strongRaiseDrill, contains('"expected_action": "raise"'));
      expect(missedFoldDrill, contains('"expected_action": "fold"'));
      expect(strongRaiseDrill, contains('"acceptable_actions": ["call"]'));
      expect(
        runnerSource,
        contains('spec.kind == DrillKindV1.rangeBucketClassifier'),
      );
      expect(runnerSource, contains('return _buildBoardTextureActionBarV1();'));
      expect(
        runnerSource,
        isNot(
          contains(
            'return _buildRangeBucketActionBarV1(isHandChainV1: false);',
          ),
        ),
      );
      expect(
        rangeBucketContract,
        contains(
          "find.byKey(const Key('session_drill_player_texture_action_bar_v1'))",
        ),
      );
      expect(
        rangeBucketContract,
        contains(
          "find.byKey(const Key('session_drill_player_range_bucket_bar_v1'))",
        ),
      );
    },
  );
}
