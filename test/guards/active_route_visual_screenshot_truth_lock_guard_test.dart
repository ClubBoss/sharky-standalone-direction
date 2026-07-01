import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route W7-W12 packet is locked out of final visual audit evidence', () {
    final captureTool = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final packager = File(
      'tools/package_screen_review_v1.py',
    ).readAsStringSync();

    expect(
      captureTool,
      contains("'visual_audit_validity': routeVisualAuditValidity"),
    );
    expect(captureTool, contains("'final_visual_audit_eligible': false"));
    expect(
      captureTool,
      contains("'invalid_for_final_visual_ux_judgment': true"),
    );
    expect(
      captureTool,
      contains("const _routeAllowedUseV1 = 'route_state_smoke_evidence_only'"),
    );
    expect(captureTool, contains("'allowed_use': '\$_routeAllowedUseV1'"));
    expect(
      captureTool,
      contains("'capture_source_policy': 'legacy_reference_not_for_audit'"),
    );

    expect(packager, contains('"legacy_reference_not_for_audit"'));
    expect(packager, contains('"final_visual_audit_eligible": False'));
    expect(packager, contains('"invalid_for_final_visual_ux_judgment": True'));
    expect(packager, contains('"route_state_smoke_evidence_only"'));
  });

  test('active-surface allowlist records forbidden final audit sources', () {
    final allowlist = File(
      'tools/screen_review_active_surface_allowlist_v1.json',
    );
    expect(allowlist.existsSync(), isTrue);

    final parsed =
        jsonDecode(allowlist.readAsStringSync()) as Map<String, dynamic>;

    expect(parsed['schema'], 'screen_review_active_surface_allowlist_v1');
    expect(
      parsed['active_runtime_learner_facing'],
      contains('lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart'),
    );
    expect(
      parsed['active_runtime_learner_facing'],
      contains('lib/ui_v2/app_root.dart'),
    );
    expect(
      parsed['screenshot_only_harnesses'],
      contains('tools/act0_real_text_surface_capture_v1.dart'),
    );
    expect(
      parsed['legacy_reference_not_for_audit'],
      contains(
        'lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart',
      ),
    );
    expect(
      parsed['final_visual_audit_forbidden_sources'],
      contains('World1FoundationsMicroTaskRunnerScreen'),
    );
    expect(
      parsed['final_visual_audit_forbidden_sources'],
      contains('lib/archive/legacy_runners/'),
    );
  });
}
