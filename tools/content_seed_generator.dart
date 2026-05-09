import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_seed_generator.dart <moduleId>',
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

  final recapFile = File('${moduleDir.path}/recap.md');
  if (!recapFile.existsSync()) {
    recapFile.createSync(recursive: true);
  }
  if (recapFile.lengthSync() == 0) {
    recapFile.writeAsStringSync(
      '# Recap\n\nThis module covers key fundamentals.\n',
    );
    print('[SEEDED] recap');
    seeded++;
  }

  final quizFile = File('${moduleDir.path}/quiz.jsonl');
  if (!quizFile.existsSync()) {
    quizFile.createSync(recursive: true);
  }
  if (quizFile.lengthSync() == 0) {
    quizFile.writeAsStringSync(
      '{"q":"Placeholder question?","a":"Placeholder answer."}\n',
    );
    print('[SEEDED] quiz');
    seeded++;
  }

  if (seeded == 0) {
    print('[OK] nothing to do');
  }
}
