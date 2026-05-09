import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  var failures = 0;
  final sections = ['drills', 'demos'];

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );

    for (final section in sections) {
      final dir = Directory('${module.path}/$section');
      if (!dir.existsSync()) {
        print('[$section] $moduleId -> missing directory');
        failures++;
        continue;
      }

      final files = dir.listSync().whereType<File>().where((file) {
        final name = file.uri.pathSegments.last;
        return !name.startsWith('.') &&
            (name.endsWith('.md') || name.endsWith('.jsonl'));
      }).toList();

      if (files.isEmpty) {
        print('[$section] $moduleId -> empty');
        failures++;
        continue;
      }

      final hasNonEmpty = files.any((file) => file.lengthSync() > 0);
      if (!hasNonEmpty) {
        print('[$section] $moduleId -> all blank');
        failures++;
      }
    }
  }

  if (failures == 0) {
    print('Drills/Demos OK');
    exit(0);
  }
  exit(1);
}
