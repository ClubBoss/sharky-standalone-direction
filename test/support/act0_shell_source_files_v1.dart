import 'dart:io';

/// Source files comprising the canonical Act0 catalog and runners.
///
/// Excludes `act0_shell_review_tasks_v1.dart` and `act0_shell_day7_*.dart`,
/// keeping the same static source scope that originally lived in
/// `act0_shell_state_v1.dart`.
const act0ShellStateCatalogSourcePathsV1 = <String>[
  'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_lessons_w1_w4_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_lessons_w5_w8_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_lessons_w9_w12_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_runners_part1_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_runners_part2_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_runners_part3_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_runners_part4_v1.dart',
];

/// Reads each Act0 catalog source file individually for per-unit AST parsing.
List<String> readAct0ShellStateCatalogSourcesV1() => [
  for (final path in act0ShellStateCatalogSourcePathsV1)
    File(path).readAsStringSync(),
];

/// Joins the Act0 catalog source files for regex/text-based source checks.
String readAct0ShellStateCatalogJoinedSourceV1() =>
    readAct0ShellStateCatalogSourcesV1().join('\n');
