import 'dart:io';

const foundationPaths = [
  'lib/ui_v2/screens/phase1_runner_screen.dart',
  'lib/ui_v2/screens/phase2_runner_screen.dart',
  'lib/ui_v2/screens/phase3_runner_screen.dart',
  'phase1_learning_effect_stop_point.md',
  'phase2_value_aha_stop_point.md',
  'phase3_engagement_return_stop_point.md',
  'phases_index.md',
];

const overrideMarker = '[FOUNDATION_OVERRIDE]';

void main() {
  final changedFiles = _gatherChangedFiles();
  if (changedFiles.isEmpty) {
    stdout.writeln('INFO: foundation guard: no changed files detected');
    exit(0);
  }

  final relevant = changedFiles.where(_isFrozenPath).toList();
  if (relevant.isEmpty) {
    exit(0);
  }

  final commitMessage = _getLastCommitMessage();
  if (commitMessage.contains(overrideMarker)) {
    stdout.writeln(
      'INFO: foundation guard override detected; allowing changes.',
    );
    exit(0);
  }

  stderr.writeln('FOUNDATION immutability guard: $overrideMarker missing.');
  stderr.writeln('Modified frozen artifacts: ${relevant.join(', ')}');
  stderr.writeln('Add $overrideMarker to the latest commit message to bypass.');
  exit(1);
}

List<String> _gatherChangedFiles() {
  final attempts = <List<String> Function()>[
    () => _runDiff(['git', 'diff', '--name-only', '--cached']),
    () {
      if (_refExists('main')) {
        return _runDiff(['git', 'diff', '--name-only', 'main...HEAD']);
      }
      return [];
    },
    () {
      if (_refExists('master')) {
        return _runDiff(['git', 'diff', '--name-only', 'master...HEAD']);
      }
      return [];
    },
    () {
      if (_refExists('HEAD~1')) {
        return _runDiff(['git', 'diff', '--name-only', 'HEAD~1', 'HEAD']);
      }
      return [];
    },
    () => _runDiff(['git', 'show', '--name-only', '--pretty=', 'HEAD']),
  ];

  for (final attempt in attempts) {
    final files = attempt();
    if (files.isNotEmpty) {
      return files;
    }
  }
  return [];
}

List<String> _runDiff(List<String> args) {
  final result = Process.runSync(args.first, args.sublist(1));
  if (result.exitCode != 0) {
    return [];
  }
  final output = result.stdout.toString().trim();
  if (output.isEmpty) {
    return [];
  }
  return output
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

bool _refExists(String ref) {
  final result = Process.runSync('git', ['rev-parse', '--verify', ref]);
  return result.exitCode == 0;
}

String _getLastCommitMessage() {
  final result = Process.runSync('git', ['log', '-1', '--pretty=%B']);
  if (result.exitCode != 0) {
    return '';
  }
  return result.stdout.toString();
}

bool _isFrozenPath(String path) {
  for (final frozen in foundationPaths) {
    if (path == frozen || path.endsWith('/$frozen')) {
      return true;
    }
  }
  return false;
}
