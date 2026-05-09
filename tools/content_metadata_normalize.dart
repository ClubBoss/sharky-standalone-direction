import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) {
    stderr.writeln('content/ missing');
    exit(1);
  }

  final encoder = JsonEncoder.withIndent('  ');

  for (final module in root.listSync().whereType<Directory>()) {
    final moduleId = module.uri.pathSegments.lastWhere(
      (element) => element.isNotEmpty,
    );
    final metadataFile = File('${module.path}/metadata.json');
    if (!metadataFile.existsSync()) {
      continue;
    }

    final raw = metadataFile.readAsStringSync();
    final json =
        (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
            as Map<String, dynamic>;
    final missing = <String>[];

    void ensure(String key, dynamic defaultValue) {
      if (!json.containsKey(key)) {
        json[key] = defaultValue;
        missing.add(key);
      }
    }

    ensure('id', moduleId);
    ensure('version', 'v1');
    ensure('description', '');
    ensure('tags', <String>[]);

    if (missing.isEmpty) {
      print('[OK] $moduleId');
      continue;
    }

    metadataFile.writeAsStringSync(encoder.convert(json));
    print('[NORMALIZED] $moduleId -> ${missing.join(', ')}');
  }
}
