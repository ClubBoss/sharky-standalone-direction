import 'dart:io';

final RegExp _illegalPattern = RegExp(r'spot\.kind\s*(==|!=)');

void main(List<String> args) {
  final roots = <String>['lib', 'test'];
  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) {
      continue;
    }
    final violation = _scanDirectory(dir);
    if (violation != null) {
      stderr.writeln(violation);
      exit(1);
    }
  }
}

String? _scanDirectory(Directory dir) {
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    final violation = _checkFile(entity);
    if (violation != null) {
      return violation;
    }
  }
  return null;
}

String? _checkFile(File file) {
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//')) continue;
    final match = _illegalPattern.firstMatch(line);
    if (match != null && !line.contains('.contains(spot.kind)')) {
      final location = '${file.path}:${i + 1}';
      final code = line.trim();
      return '$location: $code';
    }
  }
  return null;
}
