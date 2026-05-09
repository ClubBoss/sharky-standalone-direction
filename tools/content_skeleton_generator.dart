import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_skeleton_generator.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final moduleDir = Directory('content/$moduleId');
  if (!moduleDir.existsSync()) {
    stderr.writeln('Module directory content/$moduleId missing');
    exit(1);
  }

  var seeded = 0;

  void ensureSection(String section, String fileName, String content) {
    final dir = Directory('${moduleDir.path}/$section');
    if (!dir.existsSync()) return;
    final contents = dir.listSync().whereType<File>().toList();
    if (contents.isEmpty) {
      final target = File('${dir.path}/$fileName');
      target.writeAsStringSync(content);
      print('[SEEDED] $section');
      seeded++;
    }
  }

  ensureSection(
    'drills',
    '001.md',
    '# Drill 1\n\nDescribe the first exercise.\n',
  );
  ensureSection('demos', '001.md', '# Demo 1\n\nWalk through an example.\n');

  if (seeded == 0) {
    print('[OK] nothing to do');
  }
}
