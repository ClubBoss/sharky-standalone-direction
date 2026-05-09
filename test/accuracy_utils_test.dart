import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/helpers/accuracy_utils.dart';

void main() {
  test('calculateAccuracy returns percent', () {
    expect(calculateAccuracy(5, 10), 50);
    expect(calculateAccuracy(0, 0), 0);
  });
}
