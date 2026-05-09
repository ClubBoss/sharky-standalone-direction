import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_scenario_embed.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final metadata = File('content/$moduleId/metadata.json');
  if (!metadata.existsSync()) {
    stderr.writeln('metadata.json missing for $moduleId');
    exit(1);
  }

  final encoder = JsonEncoder.withIndent('  ');
  final json = jsonDecode(metadata.readAsStringSync()) as Map<String, dynamic>;

  if (json.containsKey('scenario')) {
    print('[SKIP] real scenario');
    return;
  }

  json['scenario'] = {
    'setup':
        'A realistic situation illustrating when this module’s concept becomes crucial.',
    'problem':
        'Describe the challenge or decision point the learner must resolve.',
    'insight':
        'Explain the key idea that resolves the scenario and ties directly into the module’s recap.',
    'transition':
        'How this lesson prepares the learner for the next module’s demands.',
  };

  metadata.writeAsStringSync(encoder.convert(json));
  print('[EMBEDDED] scenario $moduleId');
}
