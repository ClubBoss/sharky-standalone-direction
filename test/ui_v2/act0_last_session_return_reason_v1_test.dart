import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_last_session_return_reason_v1.dart';

void main() {
  test('fix landed copy uses safe repair focus label', () {
    const state = Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: 'no_bet_yet',
      lastSessionProofResult: act0LastSessionProofFixLandedV1,
      lastSessionDate: '2026-06-26',
      lastSessionWorldId: 'world_1',
    );

    expect(
      act0PersonalizedReturnReasonLineV1(
        state,
        repairFocusLabelsById: const <String, String>{
          'no_bet_yet': 'no-bet-yet clue',
        },
      ),
      'Yesterday you landed the fix. Keep the no-bet-yet clue fresh.',
    );
  });

  test('not-yet copy stays specific without claiming a fix landed', () {
    const state = Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: 'no_bet_yet',
      lastSessionProofResult: act0LastSessionProofNotYetV1,
      lastSessionDate: '2026-06-26',
      lastSessionWorldId: 'world_1',
    );

    expect(
      act0PersonalizedReturnReasonLineV1(
        state,
        repairFocusLabelsById: const <String, String>{
          'no_bet_yet': 'no-bet-yet clue',
        },
      ),
      'You were working on the no-bet-yet clue. One rep keeps it honest.',
    );
  });

  test(
    'unknown focus id falls back without exposing raw implementation ids',
    () {
      const state = Act0LastSessionLearnerStateV1(
        lastSessionRepairFocusId: 'actions_check_drill',
        lastSessionProofResult: act0LastSessionProofFixLandedV1,
        lastSessionDate: '2026-06-26',
        lastSessionWorldId: 'world_1',
      );

      final line = act0PersonalizedReturnReasonLineV1(state);

      expect(
        line,
        'Yesterday you landed the fix. One quick rep keeps it fresh.',
      );
      expect(line, isNot(contains('actions_check_drill')));
    },
  );

  test('storage round trip preserves cross-session learner fields', () {
    const state = Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: 'no_bet_yet',
      lastSessionProofResult: act0LastSessionProofFixLandedV1,
      lastSessionDate: '2026-06-26',
      lastSessionWorldId: 'world_1',
    );

    expect(Act0LastSessionLearnerStateV1.tryParse(state.toJson()), state);
  });

  test(
    'missing state returns null so Home can keep existing fallback copy',
    () {
      expect(act0PersonalizedReturnReasonLineV1(null), isNull);
    },
  );
}
