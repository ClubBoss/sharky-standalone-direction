class Phase2CanonicalHostFlowStateV1 {
  const Phase2CanonicalHostFlowStateV1({
    required this.ahaFired,
    required this.bubbleVisible,
    required this.navigationHappened,
  });

  const Phase2CanonicalHostFlowStateV1.initial()
    : ahaFired = false,
      bubbleVisible = false,
      navigationHappened = false;

  final bool ahaFired;
  final bool bubbleVisible;
  final bool navigationHappened;

  Phase2CanonicalHostFlowStateV1 copyWith({
    bool? ahaFired,
    bool? bubbleVisible,
    bool? navigationHappened,
  }) {
    return Phase2CanonicalHostFlowStateV1(
      ahaFired: ahaFired ?? this.ahaFired,
      bubbleVisible: bubbleVisible ?? this.bubbleVisible,
      navigationHappened: navigationHappened ?? this.navigationHappened,
    );
  }
}

class Phase2CanonicalTriggerAhaResultV1 {
  const Phase2CanonicalTriggerAhaResultV1({
    required this.nextState,
    required this.firesAha,
    required this.showsBubble,
  });

  final Phase2CanonicalHostFlowStateV1 nextState;
  final bool firesAha;
  final bool showsBubble;
}

class Phase2CanonicalFinishPlanV1 {
  const Phase2CanonicalFinishPlanV1({
    required this.nextState,
    required this.shouldNavigate,
    required this.flowResult,
    required this.hidesBubble,
  });

  final Phase2CanonicalHostFlowStateV1 nextState;
  final bool shouldNavigate;
  final String flowResult;
  final bool hidesBubble;
}

class Phase2CanonicalHostFlowBridgeV1 {
  const Phase2CanonicalHostFlowBridgeV1._();

  static Phase2CanonicalHostFlowStateV1 dismissBubble(
    Phase2CanonicalHostFlowStateV1 state,
  ) {
    if (!state.bubbleVisible) {
      return state;
    }
    return state.copyWith(bubbleVisible: false);
  }

  static Phase2CanonicalTriggerAhaResultV1 triggerAha(
    Phase2CanonicalHostFlowStateV1 state,
  ) {
    if (state.ahaFired) {
      return Phase2CanonicalTriggerAhaResultV1(
        nextState: state,
        firesAha: false,
        showsBubble: false,
      );
    }
    return Phase2CanonicalTriggerAhaResultV1(
      nextState: state.copyWith(ahaFired: true, bubbleVisible: true),
      firesAha: true,
      showsBubble: true,
    );
  }

  static Phase2CanonicalFinishPlanV1 finish(
    Phase2CanonicalHostFlowStateV1 state,
  ) {
    if (state.navigationHappened) {
      return Phase2CanonicalFinishPlanV1(
        nextState: state,
        shouldNavigate: false,
        flowResult: state.ahaFired ? 'signaled' : 'canceled',
        hidesBubble: false,
      );
    }
    return Phase2CanonicalFinishPlanV1(
      nextState: state.copyWith(navigationHappened: true, bubbleVisible: false),
      shouldNavigate: true,
      flowResult: state.ahaFired ? 'signaled' : 'canceled',
      hidesBubble: state.bubbleVisible,
    );
  }
}
