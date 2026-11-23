import 'package:test/test.dart';

import '../../lib/ui_v2/act0_shell/act0_placement_view_model_v1.dart';
import '../../lib/ui_v2/act0_shell/act0_welcome_state_v1.dart';

void main() {
  test('Welcome starts fresh, opens the demo and supports going back', () {
    final view = Act0WelcomeStateV1();
    expect(view.beat, Act0WelcomeBeatV1.intro);
    expect(view.orientationChoiceLabel, isNull);
    view.openDemo();
    expect(view.beat, Act0WelcomeBeatV1.demoSpot);
    view.returnToIntro();
    expect(view.beat, Act0WelcomeBeatV1.intro);
  });

  test('Welcome hands off with the picked label or no label', () {
    final picked = Act0WelcomeStateV1()..openDemo();
    picked.choose('Check');
    expect(picked.beat, Act0WelcomeBeatV1.handoff);
    expect(picked.orientationChoiceLabel, 'Check');

    final unpicked = Act0WelcomeStateV1()..openDemo();
    unpicked.finishDemo();
    expect(unpicked.beat, Act0WelcomeBeatV1.handoff);
    expect(unpicked.orientationChoiceLabel, isNull);
  });

  Act0PlacementActionV1? action({
    bool intro = false,
    String? questionId,
    Set<String> selections = const {},
    int minimum = 1,
  }) => Act0PlacementViewModelV1(
    showIntro: intro,
    questionId: questionId,
    selections: selections,
    minSelections: minimum,
  ).primaryAction;

  test(
    'Placement intro takes precedence and no remaining question starts the check',
    () {
      expect(action(intro: true), Act0PlacementActionV1.start);
      expect(action(), Act0PlacementActionV1.diagnostic);
    },
  );

  test('Placement starts a self-identified beginner from zero', () {
    expect(
      action(questionId: 'experience', selections: {'new'}, minimum: 2),
      Act0PlacementActionV1.startFromZero,
    );
  });

  test('Placement enables Continue only at the question minimum', () {
    expect(action(questionId: 'confidence', minimum: 0), isNull);
    expect(
      action(questionId: 'confidence', selections: {'rules'}, minimum: 0),
      Act0PlacementActionV1.next,
    );
    expect(
      action(questionId: 'goals', selections: {'rules'}, minimum: 2),
      isNull,
    );
    expect(
      action(questionId: 'goals', selections: {'rules', 'cards'}, minimum: 2),
      Act0PlacementActionV1.next,
    );
  });
}
