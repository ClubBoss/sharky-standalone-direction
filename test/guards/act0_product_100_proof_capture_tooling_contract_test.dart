import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Act0 product proof capture uses local-only four-viewport matrix', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "const _outputDirPathV1 = "
        "'output/screen_review/current/act0_product_100_proof';",
      ),
    );
    for (final viewport in <String>[
      'compact_phone',
      'tall_phone',
      'large_phone',
      'tablet',
    ]) {
      expect(source, contains("'$viewport'"), reason: viewport);
    }
    expect(source, isNot(contains("'output/device_audit/act0_product_100'")));
  });

  test('Act0 product proof capture avoids offscreen coordinate taps', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> tapVisibleTargetV1('));
    expect(source, contains('tester.ensureVisible(target)'));
    expect(source, contains('tester.getCenter(target)'));
    expect(source, contains('tester.view.physicalSize'));
    expect(source, isNot(contains('tapAt(')));
    expect(source, isNot(contains('itemWidth = rect.width / 5')));
  });

  test('Act0 product proof capture records the certification surface set', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    for (final surface in <String>[
      'placement',
      'welcome',
      'home',
      'learn',
      'learn_detail',
      'play',
      'correct_feedback',
      'wrong_feedback',
      'practice_repair',
      'completion_payoff',
      'summary',
      'review_profile',
      'w12_terminal',
    ]) {
      expect(source, contains("'$surface'"), reason: surface);
    }
  });

  test(
    'Act0 product proof capture exposes actionable missing-target errors',
    () {
      final source = File(
        'tools/act0_product_100_proof_capture_v1.dart',
      ).readAsStringSync();

      expect(source, contains('Missing visible target for'));
      expect(source, contains('Target center outside viewport for'));
      expect(source, contains('Learn detail panel did not open after tapping'));
      expect(source, contains('surfaceName + '));
    },
  );
}
