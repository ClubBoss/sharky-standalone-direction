// DEPRECATED (Archived legacy tool)
// Historical helper script kept for traceability; not part of active tooling.

import 'dart:io';

void main() async {
  const sourcePacksDir = 'build/packs';
  const sourceIndexFile = 'build/packs_index.json';
  const targetDir = 'build/pack_release';

  final targetDirectory = Directory(targetDir);

  // Clean or create the target directory
  if (targetDirectory.existsSync()) {
    targetDirectory.deleteSync(recursive: true);
  }
  targetDirectory.createSync(recursive: true);

  // Copy .pack files
  final sourcePacksDirectory = Directory(sourcePacksDir);
  if (!sourcePacksDirectory.existsSync()) {
    stderr.writeln('Source packs directory not found: $sourcePacksDir');
    exit(1);
  }

  final packFiles = sourcePacksDirectory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.pack'))
      .toList();

  for (final file in packFiles) {
    final targetFile = File(
      '${targetDirectory.path}/${file.uri.pathSegments.last}',
    );
    file.copySync(targetFile.path);
    stdout.writeln('Copied: ${file.path} → ${targetFile.path}');
  }

  // Copy packs_index.json
  final indexFile = File(sourceIndexFile);
  if (!indexFile.existsSync()) {
    stderr.writeln('Source index file not found: $sourceIndexFile');
    exit(1);
  }

  final targetIndexFile = File('${targetDirectory.path}/packs_index.json');
  indexFile.copySync(targetIndexFile.path);
  stdout.writeln('Copied: ${indexFile.path} → ${targetIndexFile.path}');

  // Log final file count
  final copiedFiles = targetDirectory.listSync().whereType<File>().toList();

  stdout.writeln('Total files in $targetDir: ${copiedFiles.length}');
}
