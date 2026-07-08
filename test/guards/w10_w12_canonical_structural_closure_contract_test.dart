import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';

void main() {
  test('W10-W12 active campaign packs express canonical identities', () {
    _expectPackCanonical(
      packId: 'world10_spine_campaign_v1',
      requiredTerms: const <String>['player', 'adjust'],
      forbiddenTerms: const <String>[
        'value bet',
        'bet purpose',
        'stronger hands fold',
      ],
    );
    _expectPackCanonical(
      packId: 'world11_spine_campaign_v1',
      requiredTerms: const <String>['session', 'transfer'],
      forbiddenTerms: const <String>[
        'dry board',
        'board texture',
        'suited board',
      ],
    );
    _expectPackCanonical(
      packId: 'world12_spine_campaign_v1',
      requiredTerms: const <String>['process', 'reset'],
      forbiddenTerms: const <String>[
        'review checkpoint',
        'bet purpose',
        'clue stack',
      ],
    );
  });

  test('W10-W12 hidden specs use canonical concept families', () {
    expect(
      act0W10BetPurposeHiddenTaskSpecsV1.map((spec) => spec.conceptFamilyId),
      everyElement('w10_player_adjustment'),
    );
    expect(
      act0W11BoardTextureHiddenTaskSpecsV1.map((spec) => spec.conceptFamilyId),
      everyElement('w11_real_play_transfer'),
    );
    expect(
      act0W12ReviewDecisionHiddenTaskSpecsV1.map(
        (spec) => spec.conceptFamilyId,
      ),
      everyElement('w12_mindset_bridge'),
    );
    for (final spec in <dynamic>[
      ...act0W10BetPurposeHiddenTaskSpecsV1,
      ...act0W11BoardTextureHiddenTaskSpecsV1,
      ...act0W12ReviewDecisionHiddenTaskSpecsV1,
    ]) {
      expect(spec.practiceCtaAllowed, isTrue, reason: spec.taskId as String);
      expect(spec.mapperNoTargetReason, isEmpty, reason: spec.taskId as String);
    }
  });

  test(
    'W10-W12 concept candidates map to different launchable same-signal targets',
    () {
      final cases = <_MappingCase>[
        _MappingCase(
          spec: act0W10BetPurposeHiddenTaskSpecV1,
          targetWorldId: 'world_10',
          targetLessonId: 'player_type_basics',
          targetTaskId: 'w10_loose_passive_tag',
        ),
        _MappingCase(
          spec: act0W11BoardTextureHiddenTaskSpecV1,
          targetWorldId: 'world_11',
          targetLessonId: 'session_plan_basics',
          targetTaskId: 'w11_plan_avoid_overload',
        ),
        _MappingCase(
          spec: act0W12ReviewDecisionHiddenTaskSpecV1,
          targetWorldId: 'world_12',
          targetLessonId: 'tilt_reset_protocol',
          targetTaskId: 'w12_after_mistake_reset',
        ),
      ];

      for (final entry in cases) {
        final result = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
          Act0ConceptFamilyRepairCandidateV1(
            conceptFamilyId: entry.spec.conceptFamilyId as String,
            repairFocusId: entry.spec.repairFocusId as String,
            skillAtomId: entry.spec.skillAtomId as String,
            errorType: entry.spec.errorType as String,
            incorrectCount: 1,
            correctCount: 0,
            latestIncorrectOrder: 1,
            selectionReasonCode: 'w10_w12_canonical_structural_closure_v1',
          ),
        );
        expect(result.isMapped, isTrue, reason: entry.spec.taskId as String);
        final request = result.request!;
        expect(request.targetWorldId, entry.targetWorldId);
        expect(request.targetLessonId, entry.targetLessonId);
        expect(request.targetTaskId, entry.targetTaskId);
        expect(request.targetTaskId, isNot(entry.spec.taskId));
        expect(request.isLaunchable, isTrue);
      }
    },
  );

  test(
    'W10-W12 UI same-signal mapper returns route-reachable different tasks',
    () {
      final w10 = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'player_tendency',
        sourceTaskId: 'w10_nit_tag',
        receiptOutcome: 'repair_started',
      );
      final w11 = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'session_plan',
        sourceTaskId: 'w11_plan_focus_choice',
        receiptOutcome: 'repair_started',
      );
      final w12 = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'tilt_reset',
        sourceTaskId: 'w12_after_bad_beat_reset',
        receiptOutcome: 'repair_started',
      );

      expect(w10?.worldId, 'world_10');
      expect(w10?.lessonId, 'player_type_basics');
      expect(w10?.taskId, 'w10_loose_passive_tag');
      expect(w10?.taskId, isNot('w10_nit_tag'));
      expect(w10?.mappingType, 'repair');

      expect(w11?.worldId, 'world_11');
      expect(w11?.lessonId, 'session_plan_basics');
      expect(w11?.taskId, 'w11_plan_avoid_overload');
      expect(w11?.taskId, isNot('w11_plan_focus_choice'));
      expect(w11?.mappingType, 'repair');

      expect(w12?.worldId, 'world_12');
      expect(w12?.lessonId, 'tilt_reset_protocol');
      expect(w12?.taskId, 'w12_after_mistake_reset');
      expect(w12?.taskId, isNot('w12_after_bad_beat_reset'));
      expect(w12?.mappingType, 'repair');
    },
  );

  test('W12 terminal safety remains unchanged', () {
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
      isEmpty,
    );
    expect(kCampaignPackIdsV1, contains('volume_i_terminal_review_v1'));
  });
}

void _expectPackCanonical({
  required String packId,
  required List<String> requiredTerms,
  required List<String> forbiddenTerms,
}) {
  final pack = kCampaignPacksV1[packId]!;
  final text = pack
      .expand(
        (step) => <String>[
          step.prompt,
          step.hint,
          step.contextText ?? '',
          step.tradeoffText ?? '',
          step.consequenceText ?? '',
          step.insightText ?? '',
        ],
      )
      .join(' ')
      .toLowerCase();
  for (final term in requiredTerms) {
    expect(text, contains(term), reason: '$packId missing $term');
  }
  for (final term in forbiddenTerms) {
    expect(text, isNot(contains(term)), reason: '$packId contains $term');
  }
}

class _MappingCase {
  const _MappingCase({
    required this.spec,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
  });

  final dynamic spec;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
}
