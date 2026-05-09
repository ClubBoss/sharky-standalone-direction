import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/navigation/deep_link_target_v1.dart';

void main() {
  test('parses supported targets', () {
    expect(parseDeepLinkTargetV1('phase1'), equals(DeepLinkTargetV1.phase1));
    expect(parseDeepLinkTargetV1('PHASE1'), equals(DeepLinkTargetV1.phase1));
    expect(parseDeepLinkTargetV1(' phase1 '), equals(DeepLinkTargetV1.phase1));
  });

  test('returns null for unsupported tokens', () {
    expect(parseDeepLinkTargetV1(''), isNull);
    expect(parseDeepLinkTargetV1('unknown'), isNull);
    expect(parseDeepLinkTargetV1('phase2'), isNull);
  });
}
