import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'real-text capture supports the four canonical viewport evidence lanes',
    () {
      final shell = File('tools/screen_review_fast_v1.sh').readAsStringSync();
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();
      final packager = File(
        'tools/package_screen_review_v1.py',
      ).readAsStringSync();
      final textRepair = File(
        'tools/screen_review_fast_text_repair_v1.py',
      ).readAsStringSync();

      expect(
        shell,
        contains(
          '<alpha_journey|core|runner|first_week|day2_return|profile_evidence|sharky_evidence|full_scroll|route_w7_w12|active_route_w7_w12|presentation_closure|review_return> <compact|tall_phone|large_phone|tablet|iphone17_class>',
        ),
      );
      expect(capture, contains("'tall_phone': Size(390, 844)"));
      expect(capture, contains("'large_phone': Size(430, 932)"));
      expect(capture, contains("'tablet': Size(834, 1194)"));
      expect(capture, contains("'alpha_journey': <_CaptureSurfaceV1>["));
      expect(capture, contains("'presentation_closure'"));
      expect(capture, contains("'review_return'"));
      expect(capture, contains("'sharky_evidence': <_CaptureSurfaceV1>["));
      expect(capture, contains('captureSharkyState'));
      expect(capture, contains("'review_full_shell_authority'"));
      expect(
        capture,
        contains('Act0ControlledDemoCaptureSurfaceV1.firstWeekReview'),
      );
      expect(capture, contains("'iphone17_class'"));
      expect(
        capture,
        contains("final packetName = group == 'presentation_closure'"),
      );
      expect(capture, contains("'long_copy_repair_feedback'"));
      expect(capture, contains("'what_poker_is_table_read_transfer'"));
      expect(capture, contains("'hand_first_only'"));
      expect(capture, contains("'act0_shell_lower_stage_scroll'"));
      expect(capture, contains('capture must fail on framework layout errors'));
      expect(capture, contains("'functional_integrity': 'PASS'"));
      expect(capture, contains("'premium_visual_quality': 'UNASSESSED'"));
      expect(
        capture,
        contains("_CaptureSurfaceV1('learn_detail', 'firstWeekLearn')"),
      );
      expect(capture, contains("fileName.contains('learn_detail')"));
      expect(packager, contains('device = _device_from_manifest'));
      expect(packager, contains('("learn_detail", "Learn detail")'));
      expect(
        textRepair,
        contains(
          '{"compact", "tall_phone", "large_phone", "tablet", "iphone17_class"}',
        ),
      );
    },
  );

  test(
    'real-text manifests expose current-head and allowed-claims metadata',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();
      final packager = File(
        'tools/package_screen_review_v1.py',
      ).readAsStringSync();

      for (final required in <String>[
        "'lane_type': 'real_text_product_proof'",
        "'evidence_type': 'product_real_text'",
        "'is_real_text': true",
        "'supports_product_copy_review': true",
        "'supports_alpha_admission': false",
        "'git_commit': currentGitCommit",
        "'git_status': currentGitStatus",
        "'git_status_classification': currentGitStatusClassification",
        "'matches_current_head': true",
        "'allowed_claims': _realTextAllowedClaimsV1",
        "'unsupported_claims': _unsupportedViewportClaimsV1(device)",
        "'surface_identity':",
        "'semantic_assertions':",
        "'debug_surface':",
      ]) {
        expect(capture, contains(required), reason: required);
      }
      expect(packager, contains('"matches_current_head"'));
      expect(packager, contains('"allowed_claims"'));
    },
  );

  test('screenshot tooling records duplicate-hash policy', () {
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final product = File(
      'tools/act0_product_100_proof_capture_v1.dart',
    ).readAsStringSync();

    expect(capture, contains('duplicate_hash_policy'));
    expect(capture, contains('intentional_same_state_allowlist'));
    expect(capture, contains('repair_focus|session_repair'));
    expect(product, contains('duplicate_hash_policy'));
    expect(product, contains('disallow_unlisted_duplicates'));
  });

  test('Human QA capsule owns current W1-W12 scope without fake QA claims', () {
    final capsule = File(
      'docs/context/HUMAN_QA_CAPSULE_v1.md',
    ).readAsStringSync();

    expect(capsule, contains('W1-W12'));
    expect(
      capsule,
      isNot(contains('No W7-W12 opening as part of W1-W6 Human QA')),
    );
    expect(capsule, contains('No fake Human QA'));
    expect(capsule, contains('No synthetic participant claims'));
    expect(capsule, contains('No public launch claims'));
  });
}
