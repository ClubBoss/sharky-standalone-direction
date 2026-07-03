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

  test(
    'active W7-W12 copy-detail feedback never renders raw internal concept-family ids',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();
      final activeSection = _activeRouteSection(capture);

      // The eye-icon/repair-focus label fed to the feedback panel must go
      // through a human-readable mapping, never the raw snake_case
      // conceptFamilyId used for internal content tracking.
      expect(
        activeSection,
        contains(
          'humanRepairFocusLabelForConceptFamily(task.conceptFamilyId as String)',
        ),
        reason:
            'repairFocusLabels must not pass task.conceptFamilyId through unchanged.',
      );
      expect(
        activeSection,
        isNot(
          contains(
            'repairFocusLabels: <String>[\n          task.conceptFamilyId as String,',
          ),
        ),
      );

      // Every raw concept-family id observed leaking into evidence in the
      // pre-human visual UX audit (docs/_reviews/
      // full_pre_human_visual_ux_audit_v2_10_10_gap_register_v1.md, GR-01/
      // GR-02) must resolve to a curated human label, and W8's label must
      // read as draw/improvement content, not price/pot content.
      const knownConceptFamilyLabels = <String, String>{
        'w7_combo_density_visible_card_removal': 'Visible cards',
        'w8_draw_improvement_potential': 'Draws that improve',
        'w9_price_intuition_call_price': 'Price to call',
        'w10_bet_purpose_value_bluff': 'Bet purpose',
        'w11_board_texture_danger_awareness': 'Board texture',
        'w12_review_decision_intuition': 'Review clue',
        'volume_i_terminal_review': 'Volume I review',
      };
      for (final entry in knownConceptFamilyLabels.entries) {
        expect(
          activeSection,
          contains("'${entry.key}': '${entry.value}'"),
          reason: entry.key,
        );
      }
      expect(
        knownConceptFamilyLabels['w8_draw_improvement_potential'],
        isNot(contains('Pot')),
      );
      expect(
        knownConceptFamilyLabels['w8_draw_improvement_potential'],
        isNot(contains('to call')),
      );
    },
  );

  test(
    'active W7-W12 copy-detail canvas matches the compact table canvas',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();
      final activeSection = _activeRouteSection(capture);

      // Regression guard for product_surface_visual_evidence_repair_v1:
      // copyDetailSize was previously Size(760, 1200), a canvas with a
      // different aspect ratio than the compact phone viewport the shell is
      // designed for. That mismatch made the table render tiny/centered
      // with a large dead dark gap below it in every copy-detail capture.
      // copyDetailSize must stay pinned to compactSize so the same clean
      // composition proven by the table captures applies here too.
      expect(
        activeSection,
        contains('const copyDetailSize = compactSize;'),
        reason:
            'copy_detail captures must reuse the compact phone canvas, not '
            'an oversized/disproportionate one.',
      );
      expect(activeSection, isNot(contains('Size(760, 1200)')));
    },
  );

  test(
    'active W7-W12 capture writes text-repair overlays like every other lane',
    () {
      final capture = File(
        'tools/act0_real_text_surface_capture_v1.dart',
      ).readAsStringSync();
      final activeSection = _activeRouteSection(capture);

      // Regression guard for product_surface_visual_evidence_repair_v1: the
      // active-route capture function never called writeTextRepairOverlays,
      // so screen_review_fast_text_repair_v1.py had no `.text_overlays.json`
      // sidecar to repair, and the primary CTA button (which uses a
      // fontFamily-less TextStyle and so falls back to the flutter_test
      // Ahem font) rendered as an unreadable solid block in every
      // copy-detail screenshot instead of legible text.
      expect(
        activeSection,
        contains('void writeTextRepairOverlays('),
        reason:
            'The active-route lane must define the same overlay-recording '
            'helper the other capture lanes use.',
      );
      expect(
        activeSection,
        contains('writeTextRepairOverlays(tester, fileName);'),
        reason:
            'captureActiveRouteSurface must call writeTextRepairOverlays '
            'before capturing the boundary image, so Ahem-rendered button '
            'labels get detected and repaired like every other lane.',
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
