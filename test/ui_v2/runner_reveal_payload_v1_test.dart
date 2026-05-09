import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_reveal_payload_v1.dart';

void main() {
  test('runner reveal payload resolves trimmed text and source identity', () {
    final resolved = resolveRunnerRevealPayloadV1(
      const RunnerRevealPayloadInputV1(
        sourceId: ' w2.s12#step4 ',
        detailsPrompt: ' Keep pressure on. ',
      ),
    );

    expect(resolved.sourceId, 'w2.s12#step4');
    expect(resolved.revealedText, 'Keep pressure on.');
    expect(resolved.canReveal, isTrue);
    expect(resolved.isAffordanceEnabled, isTrue);
  });

  test('runner reveal payload reports empty reveal text as non-revealable', () {
    final resolved = resolveRunnerRevealPayloadV1(
      const RunnerRevealPayloadInputV1(
        sourceId: 'w1.step3',
        detailsPrompt: '   ',
      ),
    );

    expect(resolved.sourceId, 'w1.step3');
    expect(resolved.revealedText, isEmpty);
    expect(resolved.canReveal, isFalse);
    expect(resolved.isAffordanceEnabled, isFalse);
  });
}
