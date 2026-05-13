import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('app root delegates canonical path root ownership to act0 shell', () {
    final appRoot = File('lib/ui_v2/app_root.dart').readAsStringSync();
    final canonicalRoot = File(
      'lib/ui_v2/act0_shell/act0_canonical_path_root_v1.dart',
    ).readAsStringSync();

    expect(
      canonicalRoot.contains('Widget buildCanonicalPathRootV1('),
      isTrue,
      reason: 'Act0 shell should own the canonical path root builder.',
    );
    expect(
      appRoot.contains('builder: (_) => buildCanonicalPathRootV1()'),
      isTrue,
      reason:
          'App root legacy redirects should delegate to the Act0-owned path root.',
    );
    expect(
      appRoot.contains("AppRoot (_EntryGate) -> Act0ShellPreviewScreenV1"),
      isTrue,
      reason:
          'Entry matrix should name the Act0 owner on the completed branch.',
    );
  });
}
