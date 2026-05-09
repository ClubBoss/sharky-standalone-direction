import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'module launcher keeps branch-only pack-play bridge isolated from canonical routes',
    () {
      final moduleLauncher = File(
        'lib/ui_v2/screens/module_launcher_screen.dart',
      ).readAsStringSync();

      expect(
        moduleLauncher.contains('if (branch != null) {'),
        isTrue,
        reason:
            'ModuleLauncherScreen should keep branch progression as an explicit sub-flow.',
      );
      expect(
        moduleLauncher.contains('return _buildBranchProgression(context);'),
        isTrue,
        reason:
            'Branch progression should remain structurally isolated from the default launcher surface.',
      );
      expect(
        moduleLauncher.contains('TrainingPackPlayScreen('),
        isTrue,
        reason:
            'Branch progression should keep an explicit pack-play bridge instead of falling back to the generic training launcher.',
      );
      expect(
        moduleLauncher.contains(
          "name: 'branch_launcher_\${branch?.name ?? 'unknown'}'",
        ),
        isTrue,
        reason:
            'Branch launches from ModuleLauncherScreen should stay tagged as branch-only traffic.',
      );

      expect(
        moduleLauncher.contains('await pushWorld1FoundationsRunnerV1<void>('),
        isTrue,
        reason:
            'Canonical campaign launches from ModuleLauncherScreen should stay on the modern runner seam.',
      );
      expect(
        moduleLauncher.contains(
          'canonicalSessionDrillRouteV1(sessionId: entry.packId)',
        ),
        isTrue,
        reason:
            'Session drill launches from ModuleLauncherScreen should use the shared canonical surfaced launch helper.',
      );
      expect(
        moduleLauncher.contains('canonicalDevAccessHubRouteV1()'),
        isTrue,
        reason:
            'The canonical dev hub should remain a distinct launcher surface, not a legacy branch wrapper.',
      );
    },
  );
}
