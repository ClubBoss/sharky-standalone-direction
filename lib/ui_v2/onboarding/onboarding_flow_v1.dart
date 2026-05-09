import 'package:flutter/material.dart';

class OnboardingFlowV1 {
  const OnboardingFlowV1();

  Widget buildOnboardingEntry() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Onboarding'),
          SizedBox(height: 8),
          Text('Sharky Hint: Stay calm, read the board.'),
          SizedBox(height: 6),
          Text('Coaching Preview: Keep decisions simple.'),
          SizedBox(height: 16),
          Text('onboarding_v1_entry'),
        ],
      ),
    );
  }

  Widget buildOnboardingStep(String id, BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Onboarding'),
          const SizedBox(height: 8),
          const Text('Sharky Hint: Stay calm, read the board.'),
          const SizedBox(height: 6),
          const Text('Coaching Preview: Keep decisions simple.'),
          const SizedBox(height: 16),
          Text('onboarding_step_$id'),
        ],
      ),
    );
  }

  Future<void> navigateFromOnboardingToPsi2(BuildContext context) {
    return Navigator.of(context).pushNamed('/psi2_first_spot');
  }
}
