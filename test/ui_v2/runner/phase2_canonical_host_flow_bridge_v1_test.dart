import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/phase2_canonical_host_flow_bridge_v1.dart';

void main() {
  test('phase2 flow bridge triggers aha once and shows bubble', () {
    const initial = Phase2CanonicalHostFlowStateV1.initial();

    final trigger = Phase2CanonicalHostFlowBridgeV1.triggerAha(initial);
    expect(trigger.firesAha, isTrue);
    expect(trigger.showsBubble, isTrue);
    expect(trigger.nextState.ahaFired, isTrue);
    expect(trigger.nextState.bubbleVisible, isTrue);

    final repeated = Phase2CanonicalHostFlowBridgeV1.triggerAha(
      trigger.nextState,
    );
    expect(repeated.firesAha, isFalse);
    expect(repeated.nextState.ahaFired, isTrue);
  });

  test('phase2 flow bridge dismisses bubble and resolves finish plan', () {
    const state = Phase2CanonicalHostFlowStateV1(
      ahaFired: true,
      bubbleVisible: true,
      navigationHappened: false,
    );

    final dismissed = Phase2CanonicalHostFlowBridgeV1.dismissBubble(state);
    expect(dismissed.bubbleVisible, isFalse);

    final finish = Phase2CanonicalHostFlowBridgeV1.finish(state);
    expect(finish.shouldNavigate, isTrue);
    expect(finish.flowResult, 'signaled');
    expect(finish.hidesBubble, isTrue);
    expect(finish.nextState.navigationHappened, isTrue);
    expect(finish.nextState.bubbleVisible, isFalse);

    final repeatedFinish = Phase2CanonicalHostFlowBridgeV1.finish(
      finish.nextState,
    );
    expect(repeatedFinish.shouldNavigate, isFalse);
  });
}
