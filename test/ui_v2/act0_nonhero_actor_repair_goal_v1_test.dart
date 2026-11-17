// SIMULATED pure-contract controls on actual authored tasks. No app/native,
// person learning, actual persisted production miss or independent skill proof.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

import '../support/act0_authored_repair_goal_fixture_v1.dart';

const _subjects = [
  (
    lesson: 'blinds_action_order',
    task: 'blinds_first_actor',
    choice: 'btn',
    goal: 'six_max_initial_preflop_first_actor',
  ),
  (
    lesson: 'blinds_action_order',
    task: 'blinds_last_actor',
    choice: 'sb',
    goal: 'six_max_unraised_initial_pass_bb_option',
  ),
  (
    lesson: 'blinds_action_order',
    task: 'blinds_review',
    choice: 'btn',
    goal: 'six_max_initial_preflop_first_actor',
  ),
  (
    lesson: 'positions',
    task: 'positions_utg',
    choice: 'hj',
    goal: 'utg_seat_identity',
  ),
];

Act0RepairGoalResolutionV1 _resolve(
  Act0RepairIntentV1 intent,
  Act0LearningEvidenceHistoryV1 history,
) => act0RepairGoalResolutionForIntentV1(
  intent,
  learningEvidence: history,
  currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
);

void main() {
  for (final subject in _subjects) {
    Act0AuthoredRepairGoalFixtureV1 fixture() =>
        Act0AuthoredRepairGoalFixtureV1.source(
          lessonId: subject.lesson,
          taskId: subject.task,
          choiceId: subject.choice,
          occurrenceId: 'SIMULATED-${subject.task}-${subject.choice}',
        );

    test(
      '${subject.task}: fresh typed goal permits only its familiar exact source',
      () {
        final f = fixture();
        final i = f.intent;
        final history = act0AuthoredRepairFixtureHistoryV1(intents: [i]);
        final resolution = _resolve(i, history);
        expect(i.goalId, subject.goal);
        expect(i.targetTaskId, i.sourceTaskId);
        expect(i.mappingType, 'intentional_exact');
        expect(i.sourceFingerprint, i.targetFingerprint);
        expect(i.relationId, isNotEmpty);
        expect(i.relationRevision, 1);
        expect(i.missedSignalLabel.toLowerCase(), isNot(contains('button')));
        expect(
          i.missedSignalLabel.toLowerCase(),
          subject.task == 'blinds_last_actor'
              ? anyOf('bb', 'big blind')
              : 'utg',
        );
        expect(resolution.canLaunch, isTrue);
        expect(resolution.retainsObligation, isTrue);
        expect(resolution.contract!.requireCapturedGoalWitness, isTrue);
        expect(resolution.canClaimIndependentApplication, isFalse);
        expect(resolution.canClaimMatchedRecheck, isFalse);
        expect(history.records.single.isCorrect, isFalse);
        final bytes = jsonEncode(i.toPayload());
        expect(
          jsonEncode(
            Act0RepairIntentV1.tryParse(jsonDecode(bytes))!.toPayload(),
          ),
          bytes,
        );
      },
    );

    test(
      '${subject.task}: old unwitnessed and foreign/stale relations remain held',
      () {
        final f = fixture();
        final i = f.intent;
        final history = act0AuthoredRepairFixtureHistoryV1(intents: [i]);
        final before = jsonEncode(history.toPayload());
        final legacy = Map<String, Object?>.of(i.toPayload())
          ..remove('goalId')
          ..remove('relationId')
          ..remove('relationRevision')
          ..remove('sourceFingerprint')
          ..remove('targetFingerprint');
        final oldIntent = Act0RepairIntentV1.tryParse(legacy)!;
        expect(_resolve(oldIntent, history).canLaunch, isFalse);
        expect(
          _resolve(oldIntent, history).reason,
          'relation_capture_unconfirmed',
        );
        for (final mutation in <Map<String, Object?>>[
          {'goalId': 'player_identity_and_seat_role'},
          {'relationRevision': 0},
          {'sourceFingerprint': '0' * 64},
          {'targetFingerprint': '0' * 64},
          {'targetTaskId': 'what_poker_is_find_hero'},
          {'repairOccurrenceId': 'not-an-observed-miss'},
        ]) {
          final changed = Act0RepairIntentV1.tryParse({
            ...i.toPayload(),
            ...mutation,
          })!;
          expect(
            _resolve(changed, history).canLaunch,
            isFalse,
            reason: '$mutation',
          );
        }
        expect(jsonEncode(history.toPayload()), before);
      },
    );

    test(
      '${subject.task}: familiar correct retry keeps first miss and denies legacy remint',
      () {
        final f = fixture();
        final outcome = f.outcome();
        final history = act0AuthoredRepairFixtureHistoryV1(outcomes: [outcome]);
        final source = history.records.first;
        final sourceBytes = jsonEncode(source.toPayload());
        expect(source.isCorrect, isFalse);
        expect(source.reviewKind, Act0ReviewKindV1.initialAssessment);
        expect(history.records.last.reviewKind, Act0ReviewKindV1.exactReplay);
        expect(
          act0RepairGoalOutcomeIsEligibleV1(
            intent: f.intent,
            outcome: outcome,
            learningEvidence: history,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          ),
          isTrue,
        );
        final legacyOutcome = Act0RepairOutcomeV1.tryParse(
          Map<String, Object?>.of(outcome.toPayload())..remove('repairIntent'),
        )!;
        expect(
          act0RepairIntentForRecordedOutcomeV1(
            outcome: legacyOutcome,
            learningEvidence: history,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          ),
          isNull,
          reason:
              'A current lookup cannot mint a new captured goal for old data.',
        );
        expect(jsonEncode(history.records.first.toPayload()), sourceBytes);
        expect(
          _resolve(f.intent, history).canClaimIndependentApplication,
          isFalse,
        );
        expect(_resolve(f.intent, history).canClaimMatchedRecheck, isFalse);
      },
    );
  }

  test(
    'only the four new relations require capture; existing contracts keep old policy',
    () {
      final newRows = act0RepairGoalContractsV1
          .where((row) => row.requireCapturedGoalWitness)
          .toList();
      expect(newRows, hasLength(4));
      expect(
        newRows
            .map((row) => '${row.sourceTaskId}/${row.sourceChoiceId}')
            .toSet(),
        {for (final source in _subjects) '${source.task}/${source.choice}'},
      );
      expect(
        act0RepairGoalContractsV1.where(
          (row) => !row.requireCapturedGoalWitness,
        ),
        hasLength(18),
      );
    },
  );
}
