import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known P1 Visual UX copy stays bounded and unambiguous', () {
    final learnSource = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    final welcomeSource = File(
      'lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart',
    ).readAsStringSync();
    final runnerSource = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();
    final runtimeCopySource = File(
      'lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart',
    ).readAsStringSync();

    expect(learnSource, contains('Start Volume I'));
    expect(learnSource, isNot(contains('The 36-world path starts here')));

    expect(welcomeSource, isNot(contains('Your first lesson is ready')));
    expect(
      welcomeSource,
      contains('Placement done. Sharky mapped your start.'),
    );
    expect(
      welcomeSource,
      contains('Learn keeps the next one visible after that.'),
    );
    expect(welcomeSource, isNot(contains('Learn will keep')));
    expect(welcomeSource, contains('Open first lesson'));
    expect(welcomeSource, isNot(contains('Open the start')));

    expect(runtimeCopySource, contains('Use the table, then retry.'));
    expect(runtimeCopySource, isNot(contains('One table retry')));

    expect(runnerSource, contains('First milestone in Volume I.'));
    expect(
      runnerSource,
      contains('Keep replaying this clue to deepen the read before moving on.'),
    );
    expect(runnerSource, contains("'error' : 'errors'"));
    expect(
      runnerSource,
      isNot(contains('Need \$unlockAccuracyPercent% accuracy')),
    );
    expect(runnerSource, isNot(contains('36-world Core Shark Path')));
  });
}
