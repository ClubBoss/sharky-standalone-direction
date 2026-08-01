import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('capture owners emit a source-owned visual identity sidecar', () {
    final surfaces = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final runner = File(
      'tools/act0_production_real_runner_capture_v1.dart',
    ).readAsStringSync();
    final packager = File(
      'tools/package_screen_review_v1.py',
    ).readAsStringSync();
    final validator = File(
      'tools/visual_evidence_identity_v1.py',
    ).readAsStringSync();
    final bundleBuilder = File(
      'tools/build_current_head_product_surface_v3.py',
    ).readAsStringSync();
    for (final source in <String>[surfaces, runner]) {
      expect(source, contains('visual_evidence_identity_v1.json'));
      expect(source, contains('evidence_id'));
      expect(source, contains('evidence_baseline_sha'));
      expect(source, contains('png_sha256'));
      expect(source, contains('identity_source_owner'));
    }
    expect(runner, contains("'task_id': row['task_id']"));
    expect(
      runner,
      contains("'text_scale': modifier == 'text_scale_1_4' ? 1.4 : 1.0"),
    );
    expect(surfaces, contains("'scroll_position': scroll"));
    expect(packager, contains('VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1.json'));
    expect(packager, contains('IDENTITY_UNMAPPED'));
    expect(validator, contains('IDENTITY_HASH_MISMATCH'));
    expect(validator, contains('owner.lookalike.png'));
    expect(validator, contains('canonical_evidence_id'));
    expect(bundleBuilder, contains('current_head_product_surface_v3.zip'));
    expect(bundleBuilder, contains('SHA256SUMS.json'));
    expect(
      packager,
      contains('filenames are only file locations, never identity inputs'),
    );
    final selfTest = Process.runSync('python3', <String>[
      'tools/visual_evidence_identity_v1.py',
      '--self-test',
    ]);
    expect(
      selfTest.exitCode,
      0,
      reason: '${selfTest.stdout}\n${selfTest.stderr}',
    );
    expect(selfTest.stdout, contains('self-test passed'));
  });
}
