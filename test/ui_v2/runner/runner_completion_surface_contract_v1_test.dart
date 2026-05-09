import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';

void main() {
  test('completion contract keeps next-step and back-to-map rhythm', () {
    final contract = buildRunnerCompletionSurfaceContractV1(
      statusHeader: 'Session complete',
      bodyText: 'Next session ready: World 5 · Session 2 of 10.',
      hasPrimaryNext: true,
      primaryNextLabel: 'NEXT LESSON',
    );

    expect(contract.statusHeader, 'Session complete');
    expect(contract.bodyText, 'Next session ready: World 5 · Session 2 of 10.');
    expect(contract.primaryCtaLabel, 'NEXT LESSON');
    expect(contract.secondaryCtaLabel, 'BACK TO MAP');
    expect(contract.showsSecondaryCta, isTrue);
  });

  test('completion contract collapses to one CTA when no next step exists', () {
    final contract = buildRunnerCompletionSurfaceContractV1(
      statusHeader: 'Session complete',
      bodyText: 'Back to the map when you are ready for the next session.',
      hasPrimaryNext: false,
      primaryNextLabel: 'NEXT LESSON',
    );

    expect(contract.primaryCtaLabel, 'BACK TO MAP');
    expect(contract.secondaryCtaLabel, isNull);
    expect(contract.showsSecondaryCta, isFalse);
  });
}
