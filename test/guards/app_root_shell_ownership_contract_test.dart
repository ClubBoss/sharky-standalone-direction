import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('app root delegates canonical path root ownership to beta shell', () {
    final appRoot = File('lib/ui_v2/app_root.dart').readAsStringSync();
    final betaShell = File(
      'lib/ui_v2/ui_v2_beta_shell.dart',
    ).readAsStringSync();

    expect(
      betaShell.contains('Widget buildCanonicalPathRootV1('),
      isTrue,
      reason: 'Beta shell should own the canonical path root builder.',
    );
    expect(
      appRoot.contains('builder: (_) => buildCanonicalPathRootV1()'),
      isTrue,
      reason:
          'App root legacy redirects should delegate to shell-owned path root.',
    );
    expect(
      appRoot.contains("AppRoot (_EntryGate) -> UiV2BetaShell"),
      isTrue,
      reason:
          'Entry matrix should name the shell owner on the completed branch.',
    );
  });
}
