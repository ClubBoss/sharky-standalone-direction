import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_source_v1.dart';

void main() {
  test('runner prompt source falls back to canonical prompt by default', () {
    final resolved = resolveRunnerPromptSourceV1(
      const RunnerPromptSourceInputV1(canonicalPrompt: 'Read the board.'),
    );

    expect(resolved.shortPrompt, 'Read the board.');
    expect(resolved.detailsPrompt, 'Read the board.');
  });

  test('runner prompt source keeps short and details precedence separate', () {
    final resolved = resolveRunnerPromptSourceV1(
      const RunnerPromptSourceInputV1(
        canonicalPrompt: 'Read the full condition.',
        shortPromptOverride: 'Follow caption.',
        detailsPromptOverride: 'Choose the best action.',
      ),
    );

    expect(resolved.shortPrompt, 'Follow caption.');
    expect(resolved.detailsPrompt, 'Choose the best action.');
  });
}
