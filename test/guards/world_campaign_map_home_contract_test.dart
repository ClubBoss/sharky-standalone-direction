import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Act0 shell owns the canonical home entry contract', () {
    final canonicalRoot = File(
      'lib/ui_v2/act0_shell/act0_canonical_path_root_v1.dart',
    ).readAsStringSync();
    final appRoot = File('lib/ui_v2/app_root.dart').readAsStringSync();
    final broadPreviewTest = File(
      'test/ui_v2/act0_shell_preview_screen_v1_test.dart',
    ).readAsStringSync();

    expect(canonicalRoot, contains('Act0ShellPreviewScreenV1'));
    expect(canonicalRoot, contains('showPlacementOnStart: true'));
    expect(canonicalRoot, isNot(contains('UiV2ProgressMapScreenV2')));
    expect(appRoot, contains('builder: (_) => buildCanonicalPathRootV1()'));
    expect(appRoot, contains('Act0ShellPreviewScreenV1'));
    expect(
      broadPreviewTest,
      contains('Canonical path root remains Act0 preview shell'),
    );
    expect(broadPreviewTest, contains('Home shell shows Poker from Zero'));
    expect(
      broadPreviewTest,
      contains('Home mission command opens runner after checklist activation'),
    );
  });

  test('retired campaign map owner paths are not required by current route', () {
    expect(
      File('lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart').existsSync(),
      isFalse,
    );
    expect(
      File(
        'lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart',
      ).existsSync(),
      isTrue,
    );
  });
}
