import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/world1_scenario_truth_pilot_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'world1 seat quiz mismatch copy stays stage-specific and beginner-safe',
    () {
      expect(
        resolveWorld1SeatQuizMismatchFixLineV1(
          slice: World1SeatQuizFeedbackSliceV1.conceptFirstSeat,
          stepIndex: 0,
          expectedSeatId: 'btn',
        ),
        'Fix: Start from Button, then read clockwise.',
      );
      expect(
        resolveWorld1SeatQuizMismatchFixLineV1(
          slice: World1SeatQuizFeedbackSliceV1.streetFlow,
          stepIndex: 0,
        ),
        'Fix: Find Button before the street changes.',
      );
      expect(
        resolveWorld1SeatQuizMismatchFixLineV1(
          slice: World1SeatQuizFeedbackSliceV1.streetFlow,
          stepIndex: 2,
        ),
        'Fix: After the blinds, move to the next live seat.',
      );
    },
  );

  test(
    'world1 hand loop fallback fix line avoids generic expected-action wording',
    () {
      expect(
        resolveWorld1HandLoopMismatchFixLineV1(
          expectedActionKind: null,
          expectedLabel: 'UNKNOWN',
        ),
        'Fix: Pick the stronger move before you continue.',
      );
    },
  );

  test(
    'world1 early action-choice truth avoids legal-suboptimal policy verdicts',
    () {
      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final step = pack12(pack!).firstWhere(
        (candidate) =>
            (candidate.allowedActions ?? const <String>[]).isNotEmpty,
      );
      final truth = world1ScenarioTruthPilotForStepV1(
        step: step,
        family: World1ScenarioTruthFamilyV1.actionChoiceEarlyDecision,
      );

      expect(truth, isNotNull);
      expect(
        truth!.feedbackIncorrectV1,
        isNot(contains('Legal, but worse than our recommended play.')),
      );
      expect(truth.feedbackIncorrectV1, isNot(contains('recommended play')));
      expect(truth.feedbackIncorrectV1, contains('better here'));
    },
  );

  test(
    'world1 runner sources avoid generic feedback family and policy-style early-path leakage',
    () {
      final runnerSource = File(
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
      ).readAsStringSync();
      final scenarioTruthSource = File(
        'lib/campaign/world1_scenario_truth_pilot_v1.dart',
      ).readAsStringSync();
      final seatQuizSource = File(
        'lib/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart',
      ).readAsStringSync();
      final handLoopSource = File(
        'lib/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart',
      ).readAsStringSync();

      expect(
        runnerSource,
        isNot(contains('World1SeatQuizFeedbackSliceV1.generic')),
      );
      expect(runnerSource, isNot(contains("'Correct.'")));
      expect(runnerSource, isNot(contains("'Incorrect.'")));
      expect(
        runnerSource,
        isNot(contains('Checkpoint: review your top mistakes.')),
      );
      expect(runnerSource, isNot(contains('Checkpoint L3:')));
      expect(runnerSource, isNot(contains('Checkpoint L6:')));
      expect(
        runnerSource,
        isNot(contains('Improve \$categoryLabel decisions next.')),
      );
      expect(runnerSource, isNot(contains('Category: \$categoryLabel')));
      expect(runnerSource, isNot(contains('dealer anchor')));
      expect(runnerSource, isNot(contains('seat anchor')));
      expect(runnerSource, isNot(contains('action-order anchor')));
      expect(runnerSource, isNot(contains('table anchor')));
      expect(runnerSource, isNot(contains('This is UTG. Tap it.')));
      expect(runnerSource, isNot(contains('Skip empty UTG and tap Hijack.')));
      expect(runnerSource, isNot(contains('Skip empty seats and tap Hijack.')));
      expect(runnerSource, isNot(contains('Tap a seat and lock in.')));
      expect(
        scenarioTruthSource,
        isNot(contains('Legal, but worse than our recommended play.')),
      );
      expect(seatQuizSource, isNot(contains('generic,')));
      expect(
        handLoopSource,
        isNot(contains('Fix: Choose the expected action before you continue.')),
      );
    },
  );
}
