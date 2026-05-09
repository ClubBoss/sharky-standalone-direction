import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/drill_generator_v3.dart <output_path>',
    );
    exit(1);
  }

  final templateFile = File('tools/drill_template_v3.txt');
  if (!templateFile.existsSync()) {
    stderr.writeln('drill_template_v3.txt missing');
    exit(1);
  }

  final content = templateFile.readAsStringSync();
  final output = File(args[0]);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(content);
  stdout.writeln('Generated drill at ${args[0]}');
}
