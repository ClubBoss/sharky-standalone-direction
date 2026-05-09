import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:poker_analyzer/services/review_prompt_service_v1.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ReviewPromptServiceV1.instance.resetForTesting();
  });

  test('prompts only after cooldown expires', () async {
    var calls = 0;
    ReviewPromptServiceV1.instance.requestReviewOverride = () async {
      calls++;
    };

    ReviewPromptServiceV1.instance.clockOverride = () => DateTime(2024, 1, 1);
    await ReviewPromptServiceV1.instance.maybePromptAfterPositiveMoment(
      ReviewPositiveMomentV1.onboardingCompleted,
    );
    expect(calls, equals(1));

    ReviewPromptServiceV1.instance.clockOverride = () => DateTime(2024, 1, 1);
    await ReviewPromptServiceV1.instance.maybePromptAfterPositiveMoment(
      ReviewPositiveMomentV1.onboardingCompleted,
    );
    expect(calls, equals(1));

    ReviewPromptServiceV1.instance.clockOverride = () => DateTime(2024, 2, 29);
    await ReviewPromptServiceV1.instance.maybePromptAfterPositiveMoment(
      ReviewPositiveMomentV1.onboardingCompleted,
    );
    expect(calls, equals(1));

    ReviewPromptServiceV1.instance.clockOverride = () => DateTime(2024, 3, 1);
    await ReviewPromptServiceV1.instance.maybePromptAfterPositiveMoment(
      ReviewPositiveMomentV1.onboardingCompleted,
    );
    expect(calls, equals(2));
  });
}
