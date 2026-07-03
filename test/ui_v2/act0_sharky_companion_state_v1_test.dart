import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  group('act0ResolveSharkyCompanionStateV1 — admission rules', () {
    test('missing/mismatched structured evidence resolves neutral', () {
      // repairPrompt momentType but no matching evidenceKind/repairState.
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.neutral,
      );
    });

    test('welcome/orientation resolves neutral', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.welcome,
        momentType: Act0SharkyCoachMomentTypeV1.welcome,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.neutral,
      );
    });

    test('open repair prompt resolves coach', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.coach,
      );
    });

    test('failed repair resolves repair', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairFailed,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
        repairState: Act0SharkyCoachRepairStateV1.failed,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.repair,
      );
    });

    test('successful/completed repair resolves confirm', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairCompleted,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
        repairState: Act0SharkyCoachRepairStateV1.completed,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.confirm,
      );
    });

    test('source-backed completed proof resolves confirm', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.summary,
        momentType: Act0SharkyCoachMomentTypeV1.sessionComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.proof,
        proofState: Act0SharkyCoachProofStateV1.localProof,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.confirm,
      );
    });

    test('valid later-improvement observation resolves improve', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.summary,
        momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.transferEvidence,
        transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.improve,
      );
    });

    test('world completion resolves milestone', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.milestone,
      );
    });

    test('W4->W5 band transition resolves milestone', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
        worldNumber: 4,
        nextWorldNumber: 5,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.milestone,
      );
    });

    test('incomplete/mismatched completion state cannot resolve milestone', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.none,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        isNot(Act0SharkyCompanionStateV1.milestone),
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.neutral,
      );
    });

    test(
      'a mismatched band-transition world number cannot resolve milestone',
      () {
        const context = Act0SharkyCoachPhraseContextV1(
          surface: Act0SharkyCoachSurfaceV1.completion,
          momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
          evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
          completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
          worldNumber: 6,
          nextWorldNumber: 7,
        );
        expect(
          act0ResolveSharkyCompanionStateV1(context),
          Act0SharkyCompanionStateV1.neutral,
        );
      },
    );

    test('generic direct-observation correct answer is not an improve claim', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.decisionCorrect,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        isNot(Act0SharkyCompanionStateV1.improve),
      );
    });

    test('repeated multi-session pattern resolves repair, not improve', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.reviewPattern,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.multiSessionPattern,
        proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.repair,
      );
    });

    test('same input yields deterministic state across repeated calls', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
      );
      final first = act0ResolveSharkyCompanionStateV1(context);
      final second = act0ResolveSharkyCompanionStateV1(context);
      expect(first, second);
    });
  });

  group('Tier behavior — state ignores tier, tier controls wording only', () {
    test('Foundation and Developing tiers resolve the identical state', () {
      for (final moment in Act0SharkyCoachMomentV1.values) {
        final foundationState = act0SharkyCompanionStateForMomentV1(
          moment,
          tier: Act0SharkyCoachTierV1.foundation,
        );
        final developingState = act0SharkyCompanionStateForMomentV1(
          moment,
          tier: Act0SharkyCoachTierV1.developing,
        );
        expect(
          foundationState,
          developingState,
          reason:
              'moment $moment must resolve the same companion state '
              'regardless of tier',
        );
      }
    });

    test('Foundation fallback (no matching evidence) remains neutral', () {
      const context = Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.home,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        tier: Act0SharkyCoachTierV1.foundation,
      );
      expect(
        act0ResolveSharkyCompanionStateV1(context),
        Act0SharkyCompanionStateV1.neutral,
      );
    });
  });

  group('Phrase/state consistency — same context, no conflicts', () {
    const expectedStateByMoment = <Act0SharkyCoachMomentV1, Act0SharkyCompanionStateV1>{
      Act0SharkyCoachMomentV1.welcomeOrientation: Act0SharkyCompanionStateV1.neutral,
      Act0SharkyCoachMomentV1.homeActiveRepair: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.homeMissionSupport: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.homeDoneSupport: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.homeDoneReturn: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.practiceCurrentFix: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.reviewActiveRepair: Act0SharkyCompanionStateV1.coach,
      Act0SharkyCoachMomentV1.repairResultProof: Act0SharkyCompanionStateV1.confirm,
      Act0SharkyCoachMomentV1.sessionSummaryProof: Act0SharkyCompanionStateV1.confirm,
      Act0SharkyCoachMomentV1.sessionSummaryEarnedMoment:
          Act0SharkyCompanionStateV1.confirm,
      Act0SharkyCoachMomentV1.worldOneCompletionPayoff:
          Act0SharkyCompanionStateV1.milestone,
      Act0SharkyCoachMomentV1.worldCompletionPayoff: Act0SharkyCompanionStateV1.milestone,
      Act0SharkyCoachMomentV1.bandTransitionPayoff: Act0SharkyCompanionStateV1.milestone,
    };

    test('every legacy moment resolves its one defined companion state', () {
      expectedStateByMoment.forEach((moment, expectedState) {
        expect(
          act0SharkyCompanionStateForMomentV1(moment),
          expectedState,
          reason: 'moment $moment should resolve $expectedState',
        );
      });
    });

    test('repair state never accompanies a success/completion moment', () {
      for (final moment in <Act0SharkyCoachMomentV1>[
        Act0SharkyCoachMomentV1.repairResultProof,
        Act0SharkyCoachMomentV1.sessionSummaryProof,
        Act0SharkyCoachMomentV1.worldOneCompletionPayoff,
        Act0SharkyCoachMomentV1.worldCompletionPayoff,
        Act0SharkyCoachMomentV1.bandTransitionPayoff,
      ]) {
        expect(
          act0SharkyCompanionStateForMomentV1(moment),
          isNot(Act0SharkyCompanionStateV1.repair),
        );
      }
    });

    test('milestone never appears on an ordinary (non-completion) moment', () {
      for (final moment in <Act0SharkyCoachMomentV1>[
        Act0SharkyCoachMomentV1.welcomeOrientation,
        Act0SharkyCoachMomentV1.homeActiveRepair,
        Act0SharkyCoachMomentV1.practiceCurrentFix,
        Act0SharkyCoachMomentV1.reviewActiveRepair,
        Act0SharkyCoachMomentV1.repairResultProof,
        Act0SharkyCoachMomentV1.sessionSummaryProof,
        Act0SharkyCoachMomentV1.sessionSummaryEarnedMoment,
      ]) {
        expect(
          act0SharkyCompanionStateForMomentV1(moment),
          isNot(Act0SharkyCompanionStateV1.milestone),
        );
      }
    });

    test(
      'the resolver function body does not read or branch on resolved phrase text',
      () {
        final source = File(
          'lib/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart',
        ).readAsStringSync();
        final start = source.indexOf(
          'Act0SharkyCompanionStateV1 act0ResolveSharkyCompanionStateV1(',
        );
        expect(start, greaterThan(-1));
        final end = source.indexOf(
          '\nAct0SharkyCompanionStateV1 act0SharkyCompanionStateForMomentV1(',
          start,
        );
        final body = source.substring(start, end == -1 ? source.length : end);
        expect(body, isNot(contains('.line')));
        expect(body, isNot(contains('resolved.line')));
      },
    );
  });

  group('Companion state vocabulary is bounded', () {
    test('exactly six semantic states exist, no rank/mood/rarity extras', () {
      expect(Act0SharkyCompanionStateV1.values.length, 6);
      final names = Act0SharkyCompanionStateV1.values
          .map((state) => state.name)
          .toSet();
      expect(
        names,
        <String>{
          'neutral',
          'coach',
          'repair',
          'confirm',
          'improve',
          'milestone',
        },
      );
      for (final forbidden in <String>[
        'happy',
        'sad',
        'angry',
        'disappointed',
        'excited',
        'confused',
        'mastery',
        'streak',
        'locked',
        'unlocked',
        'rarity',
      ]) {
        expect(names, isNot(contains(forbidden)));
      }
    });
  });
}
