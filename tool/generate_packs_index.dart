import 'dart:convert';
import 'dart:io';

void main() async {
  const outputFilePath = 'build/packs_index.json';
  final packsDir = Directory('build/packs');

  if (!packsDir.existsSync()) {
    stderr.writeln('Packs directory not found: ${packsDir.path}');
    exit(1);
  }

  final packFiles = packsDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.pack'))
      .toList();

  final metadataList = packFiles.map((file) {
    final fileName = file.uri.pathSegments.last;
    final id = fileName.replaceAll('.pack', '');

    // Generate title by humanizing the ID
    final title = id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    // Infer category from prefix
    final category = id.split('_').first;

    return {
      'id': id,
      'title': title,
      'category': category,
      'image': 'img/packs/$id.webp',
      'date': DateTime.now().toIso8601String().split('T').first,
    };
  }).toList()..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));

  final outputFile = File(outputFilePath);
  try {
    outputFile.writeAsStringSync(
      jsonEncode(metadataList),
      mode: FileMode.write,
      encoding: utf8,
    );
    stdout.writeln(
      'Generated ${metadataList.length} pack entries in $outputFilePath',
    );
  } catch (e) {
    stderr.writeln('Failed to write $outputFilePath: $e');
    exit(1);
  }
}
