import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/module_generator_v3.dart <output_path>',
    );
    exit(1);
  }

  final templateFile = File('tools/module_template_v3.txt');
  if (!templateFile.existsSync()) {
    stderr.writeln('module_template_v3.txt missing');
    exit(1);
  }

  final raw = templateFile.readAsStringSync();
  final content = raw
      .replaceAll('<placeholder>', 'TBD')
      .replaceAll('<TERM> : <meaning>', 'TERM : meaning');

  final output = File(args[0]);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(content);
  stdout.writeln('Generated module at ${args[0]}');
}
