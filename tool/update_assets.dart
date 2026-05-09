import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  final scriptDir = Directory(p.dirname(p.fromUri(Platform.script)));
  final repoRoot = scriptDir.parent;
  final assetsContentDir = Directory(
    p.join(repoRoot.path, 'assets', 'content'),
  );
  final pubspecFile = File(p.join(repoRoot.path, 'pubspec.yaml'));

  if (!assetsContentDir.existsSync()) {
    stderr.writeln(
      'assets/content/ directory not found at ${assetsContentDir.path}',
    );
    exitCode = 1;
    return;
  }
  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml not found at ${pubspecFile.path}');
    exitCode = 1;
    return;
  }

  final contentDirs = _findContentDirs(assetsContentDir, repoRoot);
  if (contentDirs.isEmpty) {
    stdout.writeln(
      'No content folders with .json or .md found under assets/content/. Nothing to update.',
    );
    return;
  }

  final pubspecText = pubspecFile.readAsStringSync();
  final updated = _updatePubspec(pubspecText, contentDirs);
  pubspecFile.writeAsStringSync(updated);

  stdout.writeln("Assets updated. Run 'flutter pub get'.");
}

Set<String> _findContentDirs(Directory assetsContentDir, Directory repoRoot) {
  final dirs = <String>{};
  for (final entity in assetsContentDir.listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;
    final ext = p.extension(entity.path).toLowerCase();
    if (ext != '.json' && ext != '.md') continue;
    final dirPath = p.dirname(entity.path);
    final relative = p.relative(dirPath, from: repoRoot.path);
    // Ensure trailing slash per pubspec asset conventions for folders.
    final normalized = relative.endsWith('/') ? relative : '$relative/';
    dirs.add(normalized);
  }
  final sorted = dirs.toList()..sort();
  return sorted.toSet();
}

String _updatePubspec(String pubspecText, Set<String> newContentDirs) {
  final yamlDoc = loadYaml(pubspecText);
  if (yamlDoc is! YamlMap || yamlDoc['flutter'] is! YamlMap) {
    throw StateError('Invalid pubspec.yaml: missing flutter section');
  }

  final flutterMap = yamlDoc['flutter'] as YamlMap;
  final assets = flutterMap['assets'];
  if (assets is! YamlList) {
    throw StateError('Invalid pubspec.yaml: flutter.assets must be a list');
  }

  // Preserve non-content assets, replace assets/content entries with new list.
  final preserved = <String>[];
  for (final item in assets) {
    if (item is! String) continue;
    if (item.startsWith('assets/content/')) continue;
    preserved.add(item);
  }

  final updatedAssets = <String>[...preserved, ...newContentDirs];

  final editor = YamlEditor(pubspecText);
  editor.update(['flutter', 'assets'], updatedAssets);
  return editor.toString();
}
