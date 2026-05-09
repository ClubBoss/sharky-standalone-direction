import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final index = StringBuffer();
  index.writeln('module | snapshots');
  for (final dir
      in root
          .listSync(recursive: true)
          .whereType<Directory>()
          .where((d) => d.path.endsWith('${Platform.pathSeparator}v1'))) {
    final module = dir.parent.path.split(Platform.pathSeparator).last;
    final snapshotDir = Directory('release/_snapshots/$module');
    snapshotDir.createSync(recursive: true);
    final files = {
      'theory.md': 'theory.before.md',
      'explain.json': 'explain.before.json',
      'drills.jsonl': 'drills.before.jsonl',
    };
    final copied = <String>[];
    for (final entry in files.entries) {
      final source = File('${dir.path}${Platform.pathSeparator}${entry.key}');
      if (!source.existsSync()) continue;
      source.copySync(
        '${snapshotDir.path}${Platform.pathSeparator}${entry.value}',
      );
      copied.add(entry.value);
    }
    index.writeln('$module | ${copied.isEmpty ? 'none' : copied.join(',')}');
  }
  final indexFile = File('release/_snapshots/_index.txt');
  indexFile.parent.createSync(recursive: true);
  indexFile.writeAsStringSync(index.toString());
  stdout.write(index.toString());
}
