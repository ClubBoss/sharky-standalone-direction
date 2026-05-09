import 'dart:io';

Future<String> _capture() async {
  final result = await Process.run('dart', [
    'run',
    'tools/regression_gate.dart',
  ], runInShell: true);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  return result.stdout.toString();
}

Future<void> _saveSnapshot() async {
  final snapshot = await _capture();
  final dir = Directory('tools/_snapshots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final file = File('${dir.path}/regression_last.txt');
  file.writeAsStringSync(snapshot);
  print('[SAVED] snapshot');
}

Future<void> _compareSnapshot() async {
  final current = await _capture();
  final file = File('tools/_snapshots/regression_last.txt');
  if (!file.existsSync()) {
    stderr.writeln('No snapshot found. Run with "save" first.');
    exit(1);
  }
  final previous = file.readAsStringSync();
  final status = current == previous ? 'MATCH' : 'DRIFT';
  print('SNAPSHOT-COMPARE:');
  print('status: $status');
  if (status == 'DRIFT') {
    exit(1);
  }
  exit(0);
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/regression_snapshot.dart <save|compare>',
    );
    exit(1);
  }
  final mode = args.first;
  if (mode == 'save') {
    await _saveSnapshot();
  } else if (mode == 'compare') {
    await _compareSnapshot();
  } else {
    stderr.writeln('Unknown mode: $mode');
    exit(1);
  }
}
