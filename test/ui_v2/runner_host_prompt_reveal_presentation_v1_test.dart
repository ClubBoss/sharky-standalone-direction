import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';

void main() {
  test('host prompt/reveal presentation resolves prompt and reveal together', () {
    final resolved = resolveRunnerHostPromptRevealPresentationV1(
      const RunnerHostPromptRevealPresentationInputV1(
        sourceId: ' w2.s08#drill2#step1 ',
        canonicalPrompt: 'Read the flop and count the outs.',
        shortPromptOverride: 'Count the outs.',
        detailsPromptOverride: 'Use the board to count the clean outs.',
      ),
    );

    expect(resolved.shortPrompt, 'Count the outs.');
    expect(resolved.detailsPrompt, 'Use the board to count the clean outs.');
    expect(resolved.reveal.sourceId, 'w2.s08#drill2#step1');
    expect(
      resolved.reveal.revealedText,
      'Use the board to count the clean outs.',
    );
    expect(resolved.canReveal, isTrue);
  });

  test('host prompt/reveal presentation falls back to canonical prompt', () {
    final resolved = resolveRunnerHostPromptRevealPresentationV1(
      const RunnerHostPromptRevealPresentationInputV1(
        sourceId: 'world1_spine_campaign_v1#step1',
        canonicalPrompt: 'Take the best action.',
      ),
    );

    expect(resolved.shortPrompt, 'Take the best action.');
    expect(resolved.detailsPrompt, 'Take the best action.');
    expect(resolved.reveal.sourceId, 'world1_spine_campaign_v1#step1');
    expect(resolved.canReveal, isTrue);
  });
}
