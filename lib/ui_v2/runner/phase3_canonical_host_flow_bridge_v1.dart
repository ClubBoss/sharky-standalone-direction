class Phase3CanonicalHostFlowStateV1 {
  const Phase3CanonicalHostFlowStateV1({
    required this.signalSent,
    required this.flowLogged,
    required this.navigationHappened,
    required this.returnCtaLogged,
    required this.returnCtaActionExecuted,
    required this.ctaShownAtUtc,
    required this.returnCtaLatencyLogged,
  });

  const Phase3CanonicalHostFlowStateV1.initial()
    : signalSent = false,
      flowLogged = false,
      navigationHappened = false,
      returnCtaLogged = false,
      returnCtaActionExecuted = false,
      ctaShownAtUtc = null,
      returnCtaLatencyLogged = false;

  final bool signalSent;
  final bool flowLogged;
  final bool navigationHappened;
  final bool returnCtaLogged;
  final bool returnCtaActionExecuted;
  final DateTime? ctaShownAtUtc;
  final bool returnCtaLatencyLogged;

  Phase3CanonicalHostFlowStateV1 copyWith({
    bool? signalSent,
    bool? flowLogged,
    bool? navigationHappened,
    bool? returnCtaLogged,
    bool? returnCtaActionExecuted,
    DateTime? ctaShownAtUtc,
    bool clearCtaShownAtUtc = false,
    bool? returnCtaLatencyLogged,
  }) {
    return Phase3CanonicalHostFlowStateV1(
      signalSent: signalSent ?? this.signalSent,
      flowLogged: flowLogged ?? this.flowLogged,
      navigationHappened: navigationHappened ?? this.navigationHappened,
      returnCtaLogged: returnCtaLogged ?? this.returnCtaLogged,
      returnCtaActionExecuted:
          returnCtaActionExecuted ?? this.returnCtaActionExecuted,
      ctaShownAtUtc: clearCtaShownAtUtc
          ? null
          : (ctaShownAtUtc ?? this.ctaShownAtUtc),
      returnCtaLatencyLogged:
          returnCtaLatencyLogged ?? this.returnCtaLatencyLogged,
    );
  }
}

class Phase3CanonicalSendSignalPlanV1 {
  const Phase3CanonicalSendSignalPlanV1({
    required this.nextState,
    required this.shouldEmitReturnSignal,
    required this.shouldLogReturnCtaShown,
  });

  final Phase3CanonicalHostFlowStateV1 nextState;
  final bool shouldEmitReturnSignal;
  final bool shouldLogReturnCtaShown;
}

class Phase3CanonicalFinishPlanV1 {
  const Phase3CanonicalFinishPlanV1({
    required this.nextState,
    required this.shouldLogFlowEnd,
    required this.flowResult,
    required this.shouldNavigateHome,
  });

  final Phase3CanonicalHostFlowStateV1 nextState;
  final bool shouldLogFlowEnd;
  final String flowResult;
  final bool shouldNavigateHome;
}

class Phase3CanonicalContinueTrainingPlanV1 {
  const Phase3CanonicalContinueTrainingPlanV1({
    required this.nextState,
    required this.shouldLogReturnCtaTapped,
    required this.shouldLogLatency,
    required this.latencyMs,
    required this.shouldLaunchNextStage,
  });

  final Phase3CanonicalHostFlowStateV1 nextState;
  final bool shouldLogReturnCtaTapped;
  final bool shouldLogLatency;
  final int? latencyMs;
  final bool shouldLaunchNextStage;
}

class Phase3CanonicalHostFlowBridgeV1 {
  const Phase3CanonicalHostFlowBridgeV1._();

  static Phase3CanonicalSendSignalPlanV1 sendSignal(
    Phase3CanonicalHostFlowStateV1 state,
    DateTime nowUtc,
  ) {
    if (state.signalSent) {
      return Phase3CanonicalSendSignalPlanV1(
        nextState: state,
        shouldEmitReturnSignal: false,
        shouldLogReturnCtaShown: false,
      );
    }
    return Phase3CanonicalSendSignalPlanV1(
      nextState: state.copyWith(
        signalSent: true,
        returnCtaLogged: true,
        ctaShownAtUtc: nowUtc,
      ),
      shouldEmitReturnSignal: true,
      shouldLogReturnCtaShown: !state.returnCtaLogged,
    );
  }

  static Phase3CanonicalFinishPlanV1 finish(
    Phase3CanonicalHostFlowStateV1 state,
  ) {
    final flowResult = state.signalSent ? 'signaled' : 'canceled';
    if (state.navigationHappened) {
      return Phase3CanonicalFinishPlanV1(
        nextState: state,
        shouldLogFlowEnd: false,
        flowResult: flowResult,
        shouldNavigateHome: false,
      );
    }
    return Phase3CanonicalFinishPlanV1(
      nextState: state.copyWith(navigationHappened: true, flowLogged: true),
      shouldLogFlowEnd: !state.flowLogged,
      flowResult: flowResult,
      shouldNavigateHome: true,
    );
  }

  static Phase3CanonicalContinueTrainingPlanV1 tapContinueTraining(
    Phase3CanonicalHostFlowStateV1 state,
    DateTime nowUtc,
  ) {
    if (state.returnCtaActionExecuted) {
      return Phase3CanonicalContinueTrainingPlanV1(
        nextState: state,
        shouldLogReturnCtaTapped: false,
        shouldLogLatency: false,
        latencyMs: null,
        shouldLaunchNextStage: false,
      );
    }

    final shownAt = state.ctaShownAtUtc;
    final shouldLogLatency = shownAt != null && !state.returnCtaLatencyLogged;
    final latencyMs = shouldLogLatency
        ? nowUtc.difference(shownAt).inMilliseconds
        : null;

    return Phase3CanonicalContinueTrainingPlanV1(
      nextState: state.copyWith(
        returnCtaActionExecuted: true,
        returnCtaLatencyLogged: shouldLogLatency
            ? true
            : state.returnCtaLatencyLogged,
      ),
      shouldLogReturnCtaTapped: true,
      shouldLogLatency: shouldLogLatency,
      latencyMs: latencyMs,
      shouldLaunchNextStage: true,
    );
  }
}
