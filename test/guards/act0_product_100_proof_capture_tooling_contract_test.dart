import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Act0 product proof capture uses local-only four-viewport matrix', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("'output/screen_review/current/act0_layout_masked_proof';"),
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

  test(
    'Act0 layout-masked capture records the canonical journey surface set',
    () {
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
        'feedback',
        'practice_repair',
        'completion_payoff',
        'summary',
        'review_profile',
        'w12_terminal',
      ]) {
        expect(source, contains("'$surface'"), reason: surface);
      }
    },
  );

  test('Act0 product proof manifest marks masked lane as layout only', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(source, contains("'lane_type': 'layout_contract'"));
    expect(source, contains("'evidence_type': 'layout_masked'"));
    expect(source, contains("'is_real_text': false"));
    expect(source, contains("'supports_product_copy_review': false"));
    expect(source, contains("'supports_alpha_admission': false"));
    expect(source, contains("'allowed_claims': _layoutAllowedClaimsV1"));
    expect(source, contains("'disallowed_claims': _maskedDisallowedClaimsV1"));
    expect(source, contains("'surface_identity': surface"));
    expect(source, contains("'semantic_assertions':"));
    expect(source, contains("'debug_surface':"));
  });

  test('Act0 product proof play captures live decision table', () {
    final source = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(source, contains('validatePlaySemanticEvidenceV1'));
    expect(source, contains('comparePlayHomeProofBytesV1'));
    expect(source, contains('Act0ControlledDemoCaptureSurfaceV1.runnerDrill'));
    expect(source, contains('act0_shell_runner_prompt_panel_compact_'));
    expect(source, contains('act0_shell_runner_action_dock'));
    expect(source, contains('act0_shell_table'));
    expect(
      source,
      isNot(contains("await openBottomTabByLabelV1(tester, 'Practice');")),
    );
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
