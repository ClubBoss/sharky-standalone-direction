import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('early World 1 seat-quiz misses render a separate next-step line', () {
    final source = File(
      'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    ).readAsStringSync();

    expect(source, contains("resolvedFailExplanationV1?.guidanceText == null"));
    expect(source, contains("(line) => line.trim().startsWith('Next time:')"));
  });
}
