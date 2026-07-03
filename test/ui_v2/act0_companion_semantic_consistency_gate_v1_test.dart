import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  group('Companion Semantic Consistency Gate v1', () {
    test('active moments keep phrase, state, and growth semantics aligned', () {
      final cases = <_SemanticCaseV1>[
        _SemanticCaseV1(
          name: 'Welcome',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.welcome,
            momentType: Act0SharkyCoachMomentTypeV1.welcome,
            tier: Act0SharkyCoachTierV1.foundation,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.orient,
          expectedState: Act0SharkyCompanionStateV1.neutral,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'lesson feedback correct',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: Act0SharkyCoachMomentTypeV1.decisionCorrect,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
            worldNumber: 2,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.confirm,
          expectedState: Act0SharkyCompanionStateV1.confirm,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'lesson feedback miss',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: Act0SharkyCoachMomentTypeV1.decisionIncorrect,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
            worldNumber: 2,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.explain,
          expectedState: Act0SharkyCompanionStateV1.repair,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'repair prompt',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.review,
            momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
            repairState: Act0SharkyCoachRepairStateV1.open,
            worldNumber: 3,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.repair,
          expectedState: Act0SharkyCompanionStateV1.coach,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'failed repair',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: Act0SharkyCoachMomentTypeV1.repairFailed,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
            repairState: Act0SharkyCoachRepairStateV1.failed,
            worldNumber: 3,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.repair,
          expectedState: Act0SharkyCompanionStateV1.repair,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'completed repair',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: Act0SharkyCoachMomentTypeV1.repairCompleted,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
            repairState: Act0SharkyCoachRepairStateV1.completed,
            worldNumber: 3,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.reinforce,
          expectedState: Act0SharkyCompanionStateV1.confirm,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
        _SemanticCaseV1(
          name: 'later improvement',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.summary,
            momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
            tier: Act0SharkyCoachTierV1.developing,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.transferEvidence,
            transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
            worldNumber: 6,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.reflect,
          expectedState: Act0SharkyCompanionStateV1.improve,
          expectedGrowth: Act0SharkyGrowthStageV1.developing,
        ),
        _SemanticCaseV1(
          name: 'session proof',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.summary,
            momentType: Act0SharkyCoachMomentTypeV1.sessionComplete,
            tier: Act0SharkyCoachTierV1.developing,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.proof,
            proofState: Act0SharkyCoachProofStateV1.localProof,
            worldNumber: 6,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.reinforce,
          expectedState: Act0SharkyCompanionStateV1.confirm,
          expectedGrowth: Act0SharkyGrowthStageV1.developing,
        ),
        _SemanticCaseV1(
          name: 'W1 completion payoff',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.completion,
            momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
            completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
            worldNumber: 1,
            nextWorldNumber: 2,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.transition,
          expectedState: Act0SharkyCompanionStateV1.milestone,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
          expectedLine: 'You banked the first table read.',
        ),
        _SemanticCaseV1(
          name: 'W4 to W5 boundary payoff',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.completion,
            momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
            completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
            worldNumber: 4,
            nextWorldNumber: 5,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.transition,
          expectedState: Act0SharkyCompanionStateV1.milestone,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
          expectedLine: 'Foundation complete.',
        ),
        _SemanticCaseV1(
          name: 'W5 completion payoff',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.completion,
            momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
            tier: Act0SharkyCoachTierV1.developing,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
            completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
            worldNumber: 5,
            nextWorldNumber: 6,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.transition,
          expectedState: Act0SharkyCompanionStateV1.milestone,
          expectedGrowth: Act0SharkyGrowthStageV1.developing,
        ),
        _SemanticCaseV1(
          name: 'Review pattern',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.review,
            momentType: Act0SharkyCoachMomentTypeV1.reviewPattern,
            tier: Act0SharkyCoachTierV1.developing,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.multiSessionPattern,
            proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
            worldNumber: 6,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.reflect,
          expectedState: Act0SharkyCompanionStateV1.repair,
          expectedGrowth: Act0SharkyGrowthStageV1.developing,
        ),
        _SemanticCaseV1(
          name: 'return reason',
          context: const Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.home,
            momentType: Act0SharkyCoachMomentTypeV1.returnReason,
            tier: Act0SharkyCoachTierV1.foundation,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
            repairState: Act0SharkyCoachRepairStateV1.open,
            worldNumber: 2,
          ),
          expectedFamily: Act0SharkyCoachPhraseFamilyV1.orient,
          expectedState: Act0SharkyCompanionStateV1.coach,
          expectedGrowth: Act0SharkyGrowthStageV1.foundation,
        ),
      ];

      for (final entry in cases) {
        final phrase = act0ResolveSharkyCoachPhraseV1(entry.context);
        expect(phrase.family, entry.expectedFamily, reason: entry.name);
        expect(
          act0ResolveSharkyCompanionStateV1(entry.context),
          entry.expectedState,
          reason: entry.name,
        );
        expect(
          act0SharkyGrowthStageForWorldNumberV1(entry.context.worldNumber ?? 0),
          entry.expectedGrowth,
          reason: entry.name,
        );
        if (entry.expectedLine != null) {
          expect(phrase.line, entry.expectedLine, reason: entry.name);
        }
      }
    });

    test('fallback contexts do not fabricate proof or growth', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.none,
        worldNumber: 0,
      );

      final phrase = act0ResolveSharkyCoachPhraseV1(context);
      expect(phrase.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
      expect(phrase.family, Act0SharkyCoachPhraseFamilyV1.orient);
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.neutral,
      );
      expect(
        act0SharkyGrowthStageForWorldNumberV1(context.worldNumber!),
        Act0SharkyGrowthStageV1.foundation,
      );
    });

    test('Home and Profile remain deferred rather than partially migrated', () {
      final homeSource = File(
        'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
      ).readAsStringSync();
      final profileSource = File(
        'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
      ).readAsStringSync();
      final previewSource = File(
        'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
      ).readAsStringSync();

      expect(homeSource, isNot(contains('Act0SharkyCompanionStateV1')));
      expect(homeSource, isNot(contains('Act0SharkyGrowthStageV1')));
      expect(
        previewSource,
        contains('preSessionMood:'),
        reason: 'Home still owns deferred ad hoc mood literals.',
      );

      expect(profileSource, isNot(contains('Act0SharkyCompanionStateV1')));
      expect(profileSource, isNot(contains('Act0SharkyGrowthStageV1')));
      expect(
        profileSource,
        contains('Act0SharkyPresenceMascotV1'),
        reason: 'Profile still uses the frozen bespoke mascot frame.',
      );
    });
  });
}

class _SemanticCaseV1 {
  const _SemanticCaseV1({
    required this.name,
    required this.context,
    required this.expectedFamily,
    required this.expectedState,
    required this.expectedGrowth,
    this.expectedLine,
  });

  final String name;
  final Act0SharkyCoachPhraseContextV1 context;
  final Act0SharkyCoachPhraseFamilyV1 expectedFamily;
  final Act0SharkyCompanionStateV1 expectedState;
  final Act0SharkyGrowthStageV1 expectedGrowth;
  final String? expectedLine;
}
