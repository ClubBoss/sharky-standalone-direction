import 'dart:convert';
import 'dart:io';

/// Patches the cached `file_picker` plugin so that its desktop platforms defer
/// to the local stub implementations instead of declaring inline support.
Future<void> main() async {
  final packageConfig = File('.dart_tool/package_config.json');
  if (!packageConfig.existsSync()) {
    stderr.writeln(
      'package_config.json not found. Run `flutter pub get` before patching.',
    );
    exitCode = 1;
    return;
  }

  final configJson =
      jsonDecode(await packageConfig.readAsString()) as Map<String, dynamic>;
  final packages = (configJson['packages'] as List<dynamic>?);
  if (packages == null) {
    stderr.writeln('Invalid package_config.json format.');
    exitCode = 1;
    return;
  }

  Map<String, dynamic>? filePickerEntry;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'file_picker') {
      filePickerEntry = pkg;
      break;
    }
  }
  if (filePickerEntry == null) {
    stderr.writeln('file_picker package not found in package_config.json.');
    exitCode = 1;
    return;
  }

  final rootUri = filePickerEntry['rootUri']?.toString();
  if (rootUri == null) {
    stderr.writeln('file_picker entry missing rootUri.');
    exitCode = 1;
    return;
  }

  final root = Uri.parse(rootUri);
  final configDir = packageConfig.parent.uri;
  final pluginUri = root.isAbsolute ? root : configDir.resolveUri(root);
  final pluginDir = Directory.fromUri(pluginUri);
  final pubspecFile = File('${pluginDir.path}/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln(
      'Unable to locate file_picker pubspec at ${pubspecFile.path}.',
    );
    exitCode = 1;
    return;
  }

  final contents = await pubspecFile.readAsString();
  final replacements = <String, String>{
    '      macos:\n        default_package: file_picker':
        '      macos:\n        default_package: file_picker_macos',
    '      windows:\n        default_package: file_picker':
        '      windows:\n        default_package: file_picker_windows',
    '      linux:\n        default_package: file_picker':
        '      linux:\n        default_package: file_picker_linux',
  };

  var updated = contents;
  var changed = false;
  replacements.forEach((from, to) {
    if (updated.contains(from)) {
      updated = updated.replaceFirst(from, to);
      changed = true;
    }
  });

  if (!changed) {
    stdout.writeln('file_picker pubspec already patched; no changes made.');
    return;
  }

  await pubspecFile.writeAsString(updated);
  stdout.writeln('Patched file_picker desktop default_package entries.');
}
