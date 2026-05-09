import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run tools/content_semantic_linker.dart <moduleId> <theme> <difficulty>',
    );
    exit(1);
  }

  final moduleId = args[0];
  final theme = args[1];
  final difficulty = args[2];
  final metadataFile = File('content/$moduleId/metadata.json');
  if (!metadataFile.existsSync()) {
    stderr.writeln('metadata.json missing for $moduleId');
    exit(1);
  }

  final encoder = JsonEncoder.withIndent('  ');
  final json =
      jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
  var added = false;

  if (!json.containsKey('theme')) {
    json['theme'] = theme;
    added = true;
  }
  if (!json.containsKey('difficulty')) {
    json['difficulty'] = difficulty;
    added = true;
  }

  final defaultLinks = {
    'recap_to_quiz': 'Strengthens conceptual understanding',
    'quiz_to_drills': 'Moves from recognition to practice',
    'drills_to_demos': 'Applies concepts in realistic scenarios',
    'demos_to_checkpoint': 'Ensures readiness for next module',
  };

  if (!json.containsKey('links')) {
    json['links'] = defaultLinks;
    added = true;
  }

  if (added) {
    metadataFile.writeAsStringSync(encoder.convert(json));
    print('[SEMANTIC] linked $moduleId');
  } else {
    print('[SKIP] already semantic');
  }
}
