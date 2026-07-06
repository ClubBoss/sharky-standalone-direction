import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R5 route matrix guard tracks current Act0 replacement coverage', () {
    final r5Gate = File('tools/run_release_gate_r5_v1.sh').readAsStringSync();
    final previewCoreTest = File(
      'test/ui_v2/act0_shell_preview_screen_v1_test.dart',
    ).readAsStringSync();
    final legacyPreviewBacklog = File(
      'test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart',
    ).readAsStringSync();
    final appRootOwnershipTest = File(
      'test/guards/app_root_shell_ownership_contract_test.dart',
    ).readAsStringSync();

    expect(
      r5Gate,
      contains('test/guards/world_campaign_map_home_contract_test.dart'),
    );
    expect(
      r5Gate,
      contains('test/guards/world_campaign_routing_matrix_contract_test.dart'),
    );
    expect(
      previewCoreTest,
      contains('Act0 preview shell renders Home and opens Learn lane'),
    );
    expect(
      previewCoreTest,
      contains('Act0 sample state keeps canonical W1-W12 runtime identity'),
    );
    expect(
      legacyPreviewBacklog,
      contains('Legacy Act0 preview backlog retained for provenance only.'),
    );
    expect(
      legacyPreviewBacklog,
      contains('Do not rename this file back to `_test.dart`'),
    );
    expect(
      appRootOwnershipTest,
      contains(
        'app root delegates canonical path root ownership to act0 shell',
      ),
    );
  });

  test(
    'stale legacy map and microtask runner imports stay out of this guard',
    () {
      final importLines =
          File('test/guards/world_campaign_routing_matrix_contract_test.dart')
              .readAsLinesSync()
              .where((line) => line.trimLeft().startsWith('import '))
              .join('\n');

      expect(importLines, isNot(contains('ui_v2_progress_map_screen_v2.dart')));
      expect(
        importLines,
        isNot(contains('world1_foundations_microtask_runner_screen.dart')),
      );
      expect(
        importLines,
        isNot(contains('World1FoundationsMicroTaskRunnerScreen')),
      );
      expect(importLines, isNot(contains('UiV2ProgressMapScreenV2')));
    },
  );
}
