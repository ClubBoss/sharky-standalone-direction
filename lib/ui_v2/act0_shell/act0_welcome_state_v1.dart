enum Act0WelcomeBeatV1 { intro, demoSpot, handoff }

/// Local orientation state. The demo records only the label for the handoff.
class Act0WelcomeStateV1 {
  Act0WelcomeBeatV1 beat = Act0WelcomeBeatV1.intro;
  String? orientationChoiceLabel;

  void openDemo() => beat = Act0WelcomeBeatV1.demoSpot;

  void returnToIntro() => beat = Act0WelcomeBeatV1.intro;

  void choose(String label) {
    orientationChoiceLabel = label;
    finishDemo();
  }

  void finishDemo() => beat = Act0WelcomeBeatV1.handoff;
}
