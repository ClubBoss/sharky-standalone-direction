import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('onboarding keeps starter pack handoff isolated to the pack-play host seam', () {
    final onboarding = File(
      'lib/onboarding/onboarding_flow_manager.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'class _PackStep[\s\S]*?TrainingPackPlayScreen\(',
      ).hasMatch(onboarding),
      isTrue,
      reason:
          'Onboarding should keep its starter-pack handoff confined to the pack-play host seam.',
    );
    expect(
      RegExp(
        r'class _MistakeRepeatStep[\s\S]*?Navigator\.push\([\s\S]*?MistakeReviewScreen\(\)',
      ).hasMatch(onboarding),
      isTrue,
      reason:
          'Post-onboarding mistake review should stay on its own review surface, not reuse the legacy launcher.',
    );
    expect(
      onboarding.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Onboarding flow manager should not directly own canonical campaign-runner launching in this bounded seam.',
    );
    expect(
      onboarding.contains('world1_foundations_microtask_runner_screen.dart'),
      isFalse,
      reason:
          'Onboarding flow manager should not import canonical runner ownership directly here.',
    );
    expect(
      onboarding.contains("name: 'onboarding_starter_pack'"),
      isTrue,
      reason:
          'Onboarding starter-pack launches should stay explicitly tagged as onboarding traffic.',
    );
  });
}
