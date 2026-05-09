import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import '../tool/validators/packs_validator.dart';

void main() {
  test('all L2 packs are valid', () {
    final errors = validateL2Packs();
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
