import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('key learner actions use the Sharky premium action token', () {
    final learn = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    final placement = File(
      'lib/ui_v2/act0_shell/act0_placement_shell_v1.dart',
    ).readAsStringSync();
    final welcome = File(
      'lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart',
    ).readAsStringSync();
    final runner = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(
      _widgetBlock(learn, "key: const Key('act0_shell_current_mission_cta')"),
      contains('premiumActionButtonStyle'),
    );
    expect(
      _widgetBlock(
        placement,
        "key: const Key('act0_shell_placement_flow_action_bar')",
      ),
      contains('premiumActionButtonStyle'),
    );
    expect(
      _widgetBlock(welcome, "key: const Key('act0_shell_welcome_primary_cta')"),
      contains('premiumActionButtonStyle'),
    );
    expect(
      _widgetBlock(
        runner,
        "key: const Key('act0_shell_block_summary_continue_cta')",
      ),
      contains('premiumActionButtonStyle'),
    );
  });

  test('tablet shell surfaces use the wider product frame', () {
    final home = File(
      'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
    ).readAsStringSync();
    final review = File(
      'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
    ).readAsStringSync();
    final runner = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(home, contains('tabletMaxWidth: 860'));
    expect(review, contains('tabletMaxWidth: 860'));
    expect(runner, contains('maxWidth: tabletLayout ? 720 : 388'));
  });

  test('visual pack v2 builder owns exact real-text coverage contract', () {
    final script = File('tools/build_real_text_visual_pack_v2.py');
    expect(script.existsSync(), isTrue);
    final source = script.readAsStringSync();

    expect(source, contains('real_text_visual_pack_v2'));
    expect(source, contains('"schema": "real_text_visual_pack_v2"'));
    expect(source, contains('"is_real_text": True'));
    expect(source, contains('"screen_count": 19'));
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('tablet_full_scroll_contact_sheet.png'));
    expect(source, isNot(contains('act0_product_100_proof')));
    expect(source, isNot(contains('masked')));
    expect(source, isNot(contains('skeleton')));
  });

  test('full-scroll capture allows the fixed-height Review bench', () {
    final source = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'review.scroll_01_top|review.scroll_02_mid|review.scroll_03_bottom',
      ),
    );
    expect(source, contains('fits inside one viewport'));
  });

  test('core evidence owns distinct empty and active Review fixtures', () {
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final preview = File(
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ).readAsStringSync();
    final pack = File(
      'tools/build_real_text_visual_pack_v2.py',
    ).readAsStringSync();

    expect(
      capture,
      contains("_CaptureSurfaceV1('review_empty', 'reviewEmpty')"),
    );
    expect(preview, contains('Act0ControlledDemoCaptureSurfaceV1.reviewEmpty'));
    expect(preview, contains('_debugReviewEmptyV1 = true'));
    expect(pack, contains('"review_empty"'));
    expect(pack, contains('"review_continuation"'));
  });

  test(
    'evidence freshness ignores only admitted local output and generated drift',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();

      expect(capture, contains("?? output/screen_review/"));
      expect(capture, contains("?? output/design_review/"));
      expect(
        capture,
        contains('macos/Flutter/GeneratedPluginRegistrant.swift'),
      );
      expect(capture, contains("return 'dirty';"));
    },
  );
}

String _widgetBlock(String source, String marker) {
  final start = source.indexOf(marker);
  expect(start, isNonNegative, reason: 'Missing marker: $marker');
  final end = source.indexOf('\n              ),', start);
  return source.substring(start, end == -1 ? source.length : end);
}
