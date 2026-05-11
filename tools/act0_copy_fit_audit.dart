import 'dart:io';

final _activeAct0SurfaceFiles = <String>[
  'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
];

void main() {
  final findings = <String>[];
  for (final path in _activeAct0SurfaceFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      findings.add('MISSING $path');
      continue;
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('maxLines: 1')) {
        findings.add('$path:${i + 1}: maxLines: 1');
      }
      if (line.contains('TextOverflow.fade')) {
        findings.add('$path:${i + 1}: TextOverflow.fade');
      }
    }
  }

  stdout.writeln('Act0 copy-fit audit');
  stdout.writeln('Files scanned: ${_activeAct0SurfaceFiles.length}');
  stdout.writeln('Findings: ${findings.length}');
  if (findings.isEmpty) {
    stdout.writeln('No risky maxLines: 1 or TextOverflow.fade matches found.');
    return;
  }

  for (final finding in findings) {
    stdout.writeln(finding);
  }
}
