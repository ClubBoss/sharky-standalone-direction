import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/phase3_canonical_host_flow_bridge_v1.dart';

void main() {
  test('phase3 flow bridge sends signal once and exposes CTA shown log', () {
    const initial = Phase3CanonicalHostFlowStateV1.initial();
    final shownAt = DateTime.utc(2026, 1, 1, 12);

    final first = Phase3CanonicalHostFlowBridgeV1.sendSignal(initial, shownAt);
    expect(first.shouldEmitReturnSignal, isTrue);
    expect(first.shouldLogReturnCtaShown, isTrue);
    expect(first.nextState.signalSent, isTrue);
    expect(first.nextState.returnCtaLogged, isTrue);
    expect(first.nextState.ctaShownAtUtc, shownAt);

    final repeated = Phase3CanonicalHostFlowBridgeV1.sendSignal(
      first.nextState,
      shownAt.add(const Duration(seconds: 1)),
    );
    expect(repeated.shouldEmitReturnSignal, isFalse);
    expect(repeated.shouldLogReturnCtaShown, isFalse);
  });

  test('phase3 flow bridge resolves continue-training and finish plans', () {
    final shownAt = DateTime.utc(2026, 1, 1, 12);
    final state = Phase3CanonicalHostFlowStateV1.initial().copyWith(
      signalSent: true,
      returnCtaLogged: true,
      ctaShownAtUtc: shownAt,
    );

    final continuePlan = Phase3CanonicalHostFlowBridgeV1.tapContinueTraining(
      state,
      shownAt.add(const Duration(milliseconds: 250)),
    );
    expect(continuePlan.shouldLogReturnCtaTapped, isTrue);
    expect(continuePlan.shouldLogLatency, isTrue);
    expect(continuePlan.latencyMs, 250);
    expect(continuePlan.shouldLaunchNextStage, isTrue);
    expect(continuePlan.nextState.returnCtaActionExecuted, isTrue);

    final repeatedContinue =
        Phase3CanonicalHostFlowBridgeV1.tapContinueTraining(
          continuePlan.nextState,
          shownAt.add(const Duration(milliseconds: 500)),
        );
    expect(repeatedContinue.shouldLaunchNextStage, isFalse);

    final finish = Phase3CanonicalHostFlowBridgeV1.finish(state);
    expect(finish.shouldLogFlowEnd, isTrue);
    expect(finish.flowResult, 'signaled');
    expect(finish.shouldNavigateHome, isTrue);
    expect(finish.nextState.navigationHappened, isTrue);
    expect(finish.nextState.flowLogged, isTrue);

    final repeatedFinish = Phase3CanonicalHostFlowBridgeV1.finish(
      finish.nextState,
    );
    expect(repeatedFinish.shouldLogFlowEnd, isFalse);
    expect(repeatedFinish.shouldNavigateHome, isFalse);
  });
}
