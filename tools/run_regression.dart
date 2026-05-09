import 'dart:io';

Future<int> _run() async {
  final process = await Process.start('dart', [
    'run',
    'tools/regression_gate.dart',
  ], runInShell: true);

  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);
  return await process.exitCode;
}

Future<void> main(List<String> args) async {
  stdout.writeln('Ω-21 REGRESSION EXECUTION');
  final exitCode = await _run();
  exit(exitCode);
}
