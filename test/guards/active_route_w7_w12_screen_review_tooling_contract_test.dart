import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active W7-W12 screen-review lane is registered end-to-end', () {
    final shell = File('tools/screen_review_fast_v1.sh').readAsStringSync();
    final packageShell = File(
      'tools/package_screen_review_v1.sh',
    ).readAsStringSync();
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final packager = File(
      'tools/package_screen_review_v1.py',
    ).readAsStringSync();

    expect(shell, contains('active_route_w7_w12'));
    expect(packageShell, contains('active_route_w7_w12_fast'));
    expect(capture, contains("'active_route_w7_w12'"));
    expect(packager, contains('"active_route_w7_w12_fast"'));

    for (final surface in <String>[
      'w7_first_route_task_table',
      'w7_first_route_task_copy_detail',
      'w8_route_task_table',
      'w8_route_task_copy_detail',
      'w9_first_route_task_table',
      'w9_first_route_task_copy_detail',
      'w10_route_task_table',
      'w10_route_task_copy_detail',
      'w11_danger_texture_task_table',
      'w11_danger_texture_task_copy_detail',
      'w12_first_review_task_table',
      'w12_first_review_task_copy_detail',
      'w12_payoff_completion_table',
      'w12_payoff_completion_copy_detail',
      'volume_i_terminal_review_table',
      'terminal_no_w13_copy_detail',
    ]) {
      expect(capture, contains(surface), reason: surface);
      expect(packager, contains(surface), reason: surface);
    }
  });

  test(
    'active W7-W12 lane uses active Act0 owners and blocks archive runner',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();

      final activeSection = _activeRouteSection(capture);
      expect(
        activeSection,
        contains('Act0LessonRunnerShellV1'),
        reason:
            'Active packet must render through the active Act0 runner shell.',
      );
      for (final owner in <String>[
        'act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart',
        'act0_w8_draws_hidden_runtime_session_owner_v1.dart',
        'act0_w9_price_hidden_runtime_session_owner_v1.dart',
        'act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart',
        'act0_w11_board_texture_hidden_runtime_session_owner_v1.dart',
        'act0_w12_review_decision_hidden_runtime_session_owner_v1.dart',
        'campaign_pack_registry_v1.dart',
      ]) {
        expect(activeSection, contains(owner), reason: owner);
      }
      expect(activeSection, isNot(contains('archive/legacy_runners')));
      expect(
        activeSection,
        isNot(contains('World1FoundationsMicroTaskRunnerScreen')),
      );
    },
  );

  test('active W7-W12 metadata is final-audit eligible', () {
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final packager = File(
      'tools/package_screen_review_v1.py',
    ).readAsStringSync();
    final allowlist =
        jsonDecode(
              File(
                'tools/screen_review_active_surface_allowlist_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;

    expect(
      capture,
      contains("'visual_audit_validity': 'active_runtime_visual_evidence'"),
    );
    expect(capture, contains("'final_visual_audit_eligible': true"));
    expect(capture, contains("'invalid_for_final_visual_ux_judgment': false"));
    expect(
      capture,
      contains("'allowed_use': 'final_pre_human_visual_ux_audit'"),
    );
    expect(packager, contains('"active_runtime_visual_evidence"'));
    expect(packager, contains('"final_pre_human_visual_ux_audit"'));
    expect(
      allowlist['active_route_w7_w12_fast'],
      containsPair('visual_audit_validity', 'active_runtime_visual_evidence'),
    );
    expect(
      allowlist['active_route_w7_w12_fast'],
      containsPair('final_visual_audit_eligible', true),
    );
  });
}

String _activeRouteSection(String source) {
  final start = source.indexOf('String _activeRouteFlutterTestSource');
  expect(start, isNonNegative);
  final legacyRouteStart = source.indexOf(
    'String _routeFlutterTestSource',
    start,
  );
  expect(legacyRouteStart, isNonNegative);
  return source.substring(start, legacyRouteStart);
}
