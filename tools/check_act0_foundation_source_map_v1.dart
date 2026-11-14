// Adversarial checks for the source map only. Temporary copies never mutate
// learner/product source, and subprocesses use this same standalone Dart VM.
import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.absolute.path;
  final temp = Directory.systemTemp.createTempSync('sharky-foundation-map-');
  final cases = <String, int>{};
  try {
    const paths = [
      'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
      'tools/_lib/act0_content_copy_source_parser.dart',
      'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.json',
      'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.md',
    ];
    for (final path in paths) {
      final target = File('${temp.path}/$path');
      target.parent.createSync(recursive: true);
      target.writeAsBytesSync(File(path).readAsBytesSync());
    }
    final jsonFile = File('${temp.path}/${paths[3]}');
    final original = jsonFile.readAsStringSync();
    void run(String name, {required bool succeeds}) {
      final result = Process.runSync(Platform.resolvedExecutable, [
        '$root/tools/act0_foundation_source_map_v1.dart',
        '--check',
      ], workingDirectory: temp.path);
      cases[name] = result.exitCode;
      if ((result.exitCode == 0) != succeeds) {
        throw StateError(
          '$name: unexpected exit ${result.exitCode}: ${result.stderr}',
        );
      }
    }

    void mutate(String name, void Function(Map<String, dynamic>) edit) {
      final map = jsonDecode(original) as Map<String, dynamic>;
      edit(map);
      jsonFile.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(map)}\n',
      );
      run(name, succeeds: false);
      jsonFile.writeAsStringSync(original);
    }

    run('exact source and map', succeeds: true);
    mutate(
      'missing goal rejected',
      (m) => (m['worlds'][0]['lessons'][0] as Map).remove('authored_goal'),
    );
    mutate(
      'invented canonical task ID rejected',
      (m) => m['worlds'][0]['lessons'][0]['tasks'][0]['task_id'] = 'invented',
    );
    mutate(
      'duplicate task ID rejected',
      (m) => m['worlds'][0]['lessons'][0]['tasks'][1]['task_id'] =
          m['worlds'][0]['lessons'][0]['tasks'][0]['task_id'],
    );
    mutate('stale map revision rejected', (m) => m['map_revision'] = 1);
    mutate(
      'missing candidate provenance rejected',
      (m) => m.remove('source_delta'),
    );
    mutate(
      'false accepted status rejected',
      (m) => m['source_status'] = 'ACCEPTED',
    );
    mutate('unknown map version rejected', (m) => m['schema'] = 'unknown');
    mutate('stale source revision rejected', (m) => m['source_git_blobs'] = {});
    final markdown = File('${temp.path}/${paths[4]}');
    markdown.writeAsStringSync('stale summary');
    run('stale Markdown rejected', succeeds: false);
    markdown.writeAsBytesSync(File(paths[4]).readAsBytesSync());
    final preview = File('${temp.path}/${paths[1]}');
    final previewBytes = preview.readAsBytesSync();
    preview.writeAsStringSync('// changed candidate Preview\n');
    run('changed Preview rejected', succeeds: false);
    preview.writeAsBytesSync(previewBytes);
    // Private source copy only; fail closed on any source revision drift.
    File('${temp.path}/${paths[0]}').writeAsStringSync('// changed source\n');
    run('changed source rejected', succeeds: false);
    stdout.writeln(
      jsonEncode({
        'scope': 'source-map controls only',
        'passed': cases.length,
        'failed': 0,
        'cases': cases,
      }),
    );
  } finally {
    temp.deleteSync(recursive: true);
  }
}
