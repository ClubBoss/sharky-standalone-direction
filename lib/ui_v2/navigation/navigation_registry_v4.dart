import 'package:flutter/material.dart';

import '../onboarding/onboarding_flow_v1.dart';
import '../psi2/psi2_first_spot_flow_v1.dart';

class NavigationRegistryV4 {
  NavigationRegistryV4()
    : _flow = const OnboardingFlowV1(),
      _psi2Flow = const Psi2FirstSpotFlowV1();

  final OnboardingFlowV1 _flow;
  final Psi2FirstSpotFlowV1 _psi2Flow;

  static const String onboardingRoute = '/onboarding_v1';
  static const String onboardingStepRoute = '/onboarding_step_v1';
  static const String psi2Route = '/psi2_first_spot';
  static const String psi2StepRoute = '/psi2_first_spot_step';

  Route<dynamic>? createRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingRoute:
        return MaterialPageRoute(
          builder: (_) => _flow.buildOnboardingEntry(),
          settings: settings,
        );
      case onboardingStepRoute:
        final stepId = settings.arguments?.toString() ?? 'default';
        return MaterialPageRoute(
          builder: (context) => _flow.buildOnboardingStep(stepId, context),
          settings: settings,
        );
      case psi2Route:
        return MaterialPageRoute(
          builder: (_) => _psi2Flow.buildPsi2Entry(),
          settings: settings,
        );
      case psi2StepRoute:
        final stepId = settings.arguments?.toString() ?? 'default';
        return MaterialPageRoute(
          builder: (context) => _psi2Flow.buildPsi2Step(stepId, context),
          settings: settings,
        );
    }
    return null;
  }
}
