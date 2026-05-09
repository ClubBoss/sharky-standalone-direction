import 'dart:io';

void main() async {
  final contentDir = Directory('assets/content');
  final pubspecFile = File('pubspec.yaml');

  // Step 1: Scan the assets/content directory recursively
  final contentFolders = <String>{};
  await for (var entity in contentDir.list(recursive: true)) {
    if (entity is Directory) {
      final hasJsonOrMd = await entity.list().any((file) {
        return file is File &&
            (file.path.endsWith('.json') || file.path.endsWith('.md'));
      });
      if (hasJsonOrMd) {
        contentFolders.add(entity.path);
      }
    }
  }

  // Step 2: Read pubspec.yaml
  final pubspecContent = await pubspecFile.readAsString();
  final lines = pubspecContent.split('\n');

  // Step 3: Locate the flutter: -> assets: section
  final newLines = <String>[];
  bool inAssetsSection = false;

  for (var line in lines) {
    if (line.trim() == 'flutter:') {
      newLines.add(line);
      inAssetsSection = true;
      continue;
    }
    if (inAssetsSection && line.trim().isEmpty) {
      // End of assets section
      inAssetsSection = false;
    }
    if (inAssetsSection && line.trim().startsWith('- assets/')) {
      // Skip existing asset lines
      continue;
    }
    newLines.add(line);
  }

  // Step 4: Replace the existing list of content assets
  if (inAssetsSection) {
    newLines.removeWhere((line) => line.trim().startsWith('- assets/content/'));
  }

  // Add new content asset paths
  for (var folder in contentFolders) {
    newLines.add('    - ${folder.replaceFirst('assets/', '')}/');
  }

  // Step 5: Save pubspec.yaml
  await pubspecFile.writeAsString(newLines.join('\n'));

  // Step 6: Print confirmation message
  print("Assets updated. Run 'flutter pub get'.");
}
