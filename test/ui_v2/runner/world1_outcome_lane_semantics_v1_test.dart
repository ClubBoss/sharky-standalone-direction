import 'package:test/test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_outcome_lane_semantics_v1.dart';

void main() {
  test(
    'world1 outcome lane semantics default to NEXT with retry secondary',
    () {
      final semantics = resolveWorld1OutcomeLaneSemanticsV1(
        isCorrect: false,
        continueAdvancesFlow: true,
      );

      expect(semantics.primaryLabel, 'NEXT');
      expect(semantics.showsRetrySecondary, isTrue);
      expect(semantics.secondaryLabel, 'RETRY');
    },
  );

  test('world1 outcome lane semantics default to RETRY without secondary', () {
    final semantics = resolveWorld1OutcomeLaneSemanticsV1(
      isCorrect: false,
      continueAdvancesFlow: false,
    );

    expect(semantics.primaryLabel, 'RETRY');
    expect(semantics.showsRetrySecondary, isFalse);
    expect(semantics.secondaryLabel, isNull);
  });

  test('world1 outcome lane semantics respect explicit overrides', () {
    final semantics = resolveWorld1OutcomeLaneSemanticsV1(
      isCorrect: false,
      continueAdvancesFlow: false,
      primaryCtaLabelOverride: 'TRY AGAIN',
      showRetrySecondaryOverride: false,
    );

    expect(semantics.primaryLabel, 'TRY AGAIN');
    expect(semantics.showsRetrySecondary, isFalse);
  });

  test(
    'campaign spine next-step primary CTA can flow through shared completion contract',
    () {
      final completionContract = buildRunnerCompletionSurfaceContractV1(
        statusHeader: 'Correct.',
        bodyText: 'Next lesson ready: World 1 · Pack 5 of 7.',
        hasPrimaryNext: true,
        primaryNextLabel: 'CONTINUE',
        showSecondaryBackToMap: false,
      );

      final semantics = resolveWorld1OutcomeLaneSemanticsV1(
        isCorrect: true,
        continueAdvancesFlow: true,
        primaryCtaLabelOverride: completionContract.primaryCtaLabel,
        showRetrySecondaryOverride: false,
      );

      expect(completionContract.primaryCtaLabel, 'CONTINUE');
      expect(completionContract.secondaryCtaLabel, isNull);
      expect(semantics.primaryLabel, completionContract.primaryCtaLabel);
      expect(semantics.showsRetrySecondary, isFalse);
    },
  );
}
