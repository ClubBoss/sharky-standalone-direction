import 'package:poker_analyzer/testing/test_shims.dart';
@TestOn('vm')
import 'package:test/test.dart';

void main() {
  test('smoke runs', () {
    expect(1 + 1, 2);
  });
}
