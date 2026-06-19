import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R5 route matrix guard tracks current Act0 replacement coverage', () {
    final r5Gate = File('tools/run_release_gate_r5_v1.sh').readAsStringSync();
    final broadPreviewTest = File(
      'test/ui_v2/act0_shell_preview_screen_v1_test.dart',
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
    expect(broadPreviewTest, contains('Bottom nav switches tabs'));
    expect(
      broadPreviewTest,
      contains('Learn tab CTA opens runner from expanded current lesson'),
    );
    expect(
      broadPreviewTest,
      contains('Play tab shows practice groups and launches a group runner'),
    );
    expect(
      broadPreviewTest,
      contains('Review repair session returns with a fixed summary'),
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
