import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  test('world-band tier mapping supports only proven phrase tiers', () {
    expect(
      act0SharkyCoachTierForWorldNumberV1(1),
      Act0SharkyCoachTierV1.foundation,
    );
    expect(
      act0SharkyCoachTierForWorldNumberV1(4),
      Act0SharkyCoachTierV1.foundation,
    );
    expect(
      act0SharkyCoachTierForWorldNumberV1(5),
      Act0SharkyCoachTierV1.developing,
    );
    expect(
      act0SharkyCoachTierForWorldNumberV1(12),
      Act0SharkyCoachTierV1.developing,
    );
    expect(Act0SharkyCoachTierV1.values, [
      Act0SharkyCoachTierV1.foundation,
      Act0SharkyCoachTierV1.developing,
    ]);
    expect(
      act0SharkyCoachTierForWorldNumberV1(13),
      Act0SharkyCoachTierV1.developing,
    );
  });

  test('foundation tier resolves beginner-safe wording', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.play,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        tier: Act0SharkyCoachTierV1.foundation,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      ),
    );

    expect(
      phrase.line,
      'Before choosing, check whether a bet is in front of you.',
    );
    expect(phrase.family, Act0SharkyCoachPhraseFamilyV1.repair);
    expect(phrase.claimBoundary, Act0SharkyCoachClaimBoundaryV1.repair);
  });

  test('Foundation welcome phrase is beginner-safe', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.welcome,
        momentType: Act0SharkyCoachMomentTypeV1.welcome,
      ),
    );

    expect(phrase.line, 'Start with one clear table clue.');
    expect(phrase.tier, Act0SharkyCoachTierV1.foundation);
    expect(phrase.family, Act0SharkyCoachPhraseFamilyV1.orient);
    expect(phrase.claimBoundary, Act0SharkyCoachClaimBoundaryV1.neutral);
  });

  test('developing tier resolves connected but claim-safe wording', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.play,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        tier: Act0SharkyCoachTierV1.developing,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      ),
    );

    expect(phrase.line, 'Rebuild the spot from position, action, and price.');
    expect(phrase.family, Act0SharkyCoachPhraseFamilyV1.repair);
  });

  test('missing tier falls back to Foundation-safe copy', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.reviewPattern,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.multiSessionPattern,
        proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
      ),
    );

    expect(phrase.tier, Act0SharkyCoachTierV1.foundation);
    expect(phrase.line, 'This same miss showed up in more than one session.');
  });

  test('correct moment cannot use repair-failed phrase', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.decisionCorrect,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
      ),
    );

    expect(phrase.line, 'Good read - nobody had bet yet.');
    expect(phrase.line.toLowerCase(), isNot(contains('try the repair')));
    expect(phrase.family, Act0SharkyCoachPhraseFamilyV1.confirm);
  });

  test('repair completed requires successful repair evidence', () {
    final missing = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairCompleted,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.none,
      ),
    );
    final landed = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairCompleted,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
        repairState: Act0SharkyCoachRepairStateV1.completed,
      ),
    );

    expect(missing.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(landed.line, 'That repair landed.');
  });

  test('later-improvement phrase requires valid transfer evidence', () {
    final missing = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.profile,
        momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
      ),
    );
    final backed = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.profile,
        momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.transferEvidence,
        transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
      ),
    );

    expect(missing.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(
      backed.line,
      'You missed this clue before. On a later hand, you caught it.',
    );
  });

  test(
    'developing later-improvement phrase stays structural and claim-safe',
    () {
      final phrase = act0ResolveSharkyCoachPhraseV1(
        const Act0SharkyCoachPhraseContextV1(
          surface: Act0SharkyCoachSurfaceV1.summary,
          momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
          tier: Act0SharkyCoachTierV1.developing,
          evidenceKind: Act0SharkyCoachEvidenceKindV1.transferEvidence,
          transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
        ),
      );

      expect(
        phrase.line,
        'You connected this signal correctly on a later hand.',
      );
      expect(
        phrase.claimBoundary,
        Act0SharkyCoachClaimBoundaryV1.conservativeTransfer,
      );
      expect(phrase.line.toLowerCase(), isNot(contains('master')));
      expect(phrase.line.toLowerCase(), isNot(contains('fixed forever')));
      expect(phrase.line.toLowerCase(), isNot(contains('weakest')));
      expect(phrase.line, isNot(contains('%')));
      expect(phrase.line, isNot(contains('AI')));
    },
  );

  test('pattern phrase requires multi-session evidence', () {
    final missing = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.reviewPattern,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
      ),
    );
    final backed = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.reviewPattern,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.multiSessionPattern,
        proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
      ),
    );

    expect(missing.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(backed.line, 'This same miss showed up in more than one session.');
  });

  test('world completion phrase requires actual completion', () {
    final missing = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
      ),
    );
    final complete = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
      ),
    );

    expect(missing.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(complete.line, 'World complete with a real table read.');
  });

  test('band transition phrase is only W4 to W5', () {
    final wrongBoundary = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
        worldNumber: 5,
        nextWorldNumber: 6,
      ),
    );
    final correctBoundary = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
        worldNumber: 4,
        nextWorldNumber: 5,
      ),
    );

    expect(wrongBoundary.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(correctBoundary.line, 'Foundation complete.');
  });

  test('unsupported evidence yields neutral fallback', () {
    final phrase = act0ResolveSharkyCoachPhraseV1(
      const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairFailed,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
      ),
    );

    expect(phrase.line, Act0SharkyCoachPhraseV1.neutralFallbackLine);
    expect(phrase.fallbackKey, 'neutral_fallback');
  });

  test('no mastery AI weakest-skill or always language is emitted', () {
    for (final tier in Act0SharkyCoachTierV1.values) {
      for (final moment in Act0SharkyCoachMomentTypeV1.values) {
        final line = act0ResolveSharkyCoachPhraseV1(
          Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: moment,
            tier: tier,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
            repairState: Act0SharkyCoachRepairStateV1.completed,
            transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
            proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
            completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
            worldNumber: 4,
            nextWorldNumber: 5,
          ),
        ).line.toLowerCase();

        for (final forbidden in <String>[
          'master',
          'ai',
          'weakest',
          'weakness',
          'always',
          'biggest leak',
          'intermediate player',
          'fixed forever',
          'remember this now',
          'solver',
          'gto',
          'level',
          'rating',
          'radar',
        ]) {
          expect(line, isNot(contains(forbidden)), reason: '$tier $moment');
        }
      }
    }
  });

  test('Foundation and Developing phrase sets remain bounded', () {
    final resolved = <String>{};
    for (final tier in Act0SharkyCoachTierV1.values) {
      for (final moment in Act0SharkyCoachMomentTypeV1.values) {
        final phrase = act0ResolveSharkyCoachPhraseV1(
          Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.feedback,
            momentType: moment,
            tier: tier,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
            repairState: Act0SharkyCoachRepairStateV1.completed,
            transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
            proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
            completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
            worldNumber: 4,
            nextWorldNumber: 5,
          ),
        );
        if (phrase.line != Act0SharkyCoachPhraseV1.neutralFallbackLine) {
          resolved.add('${tier.name}:${phrase.line}');
        }
      }
    }

    expect(resolved.length, lessThanOrEqualTo(22));
  });

  test('phrases are never blank and never leak template tokens', () {
    for (final tier in Act0SharkyCoachTierV1.values) {
      for (final moment in Act0SharkyCoachMomentTypeV1.values) {
        final line = act0ResolveSharkyCoachPhraseV1(
          Act0SharkyCoachPhraseContextV1(
            surface: Act0SharkyCoachSurfaceV1.home,
            momentType: moment,
            tier: tier,
            evidenceKind: Act0SharkyCoachEvidenceKindV1.directObservation,
            repairState: Act0SharkyCoachRepairStateV1.completed,
            transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
            proofState: Act0SharkyCoachProofStateV1.multiSessionPattern,
            completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
            worldNumber: 4,
            nextWorldNumber: 5,
          ),
        ).line;

        expect(line.trim(), isNotEmpty);
        expect(line, isNot(contains('{{')));
        expect(line, isNot(contains('}}')));
        expect(line.toLowerCase(), isNot('null'));
        expect(RegExp(r'^[\x00-\x7F]+$').hasMatch(line), isTrue);
      }
    }
  });

  test('same input resolves deterministically', () {
    const context = Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.summary,
      momentType: Act0SharkyCoachMomentTypeV1.sessionComplete,
      tier: Act0SharkyCoachTierV1.developing,
      evidenceKind: Act0SharkyCoachEvidenceKindV1.proof,
      proofState: Act0SharkyCoachProofStateV1.localProof,
    );

    expect(
      act0ResolveSharkyCoachPhraseV1(context),
      act0ResolveSharkyCoachPhraseV1(context),
    );
  });

  test('legacy widget wrapper does not infer state from phrase text', () {
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.practiceCurrentFix,
      ),
      'Before choosing, check whether a bet is in front of you.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.sessionSummaryProof,
      ),
      'You finished with one clear table-reading lesson.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.sessionSummaryEarnedMoment,
      ),
      'One clear win Sharky can prove.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.homeMissionSupport,
      ),
      'Sharky has one table clue ready.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(Act0SharkyCoachMomentV1.homeDoneSupport),
      "Today's table clue is warm for next time.",
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.worldCompletionPayoff,
        tier: Act0SharkyCoachTierV1.developing,
      ),
      'World complete with action, table, and price connected.',
    );
  });

  test('migrated widgets no longer own duplicated hardcoded phrases', () {
    final welcome = File(
      'lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart',
    ).readAsStringSync();
    final home = File(
      'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
    ).readAsStringSync();
    final summary = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(
      welcome,
      isNot(
        contains(
          'Answer two quick questions. Then Sharky opens the first useful hand.',
        ),
      ),
    );
    expect(home, isNot(contains('Sharky has one clean read ready.')));
    expect(
      home,
      isNot(
        contains("One table clue warmed. Sharky has tomorrow's read ready."),
      ),
    );
    expect(summary, isNot(contains('Small win earned. Sharky can prove it.')));
  });
}
