import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run tools/content_module_linker.dart <moduleId> <prevId> <nextId>',
    );
    exit(1);
  }

  final moduleId = args[0];
  final prevId = args[1];
  final nextId = args[2];
  final metadataFile = File('content/$moduleId/metadata.json');
  if (!metadataFile.existsSync()) {
    stderr.writeln('metadata.json missing for $moduleId');
    exit(1);
  }

  final encoder = JsonEncoder.withIndent('  ');
  final json =
      jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
  var added = false;

  if (!json.containsKey('prev')) {
    json['prev'] = prevId;
    added = true;
  }

  if (!json.containsKey('next')) {
    json['next'] = nextId;
    added = true;
  }

  if (added) {
    metadataFile.writeAsStringSync(encoder.convert(json));
    print('[LINKED] $moduleId -> prev:$prevId next:$nextId');
  } else {
    print('[SKIP] already linked');
  }
}
