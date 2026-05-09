import 'dart:io';

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final sections = <String>{
    'overview',
    'core principles',
    'examples',
    'mistakes / leaks',
    'heuristics',
    'summary',
  };
  final report = StringBuffer();
  report.writeln('module | chars | lines | density | coverage | coherence');
  for (final file
      in root
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('theory.md'))) {
    final module = file.path.split(Platform.pathSeparator);
    final moduleId = module.length >= 3
        ? module[module.length - 3]
        : module.first;
    final content = file.readAsStringSync();
    final totalChars = content.length;
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).length;
    final density = totalChars == 0 ? 0.0 : (lines / totalChars) * 1000;
    final lower = content.toLowerCase();
    final present = sections.where(lower.contains).length;
    final coverage = present / sections.length;
    final coherence = density * 0.4 + coverage * 0.6;
    report.writeln(
      '$moduleId | $totalChars | $lines | ${density.toStringAsFixed(2)} | ${coverage.toStringAsFixed(2)} | ${coherence.toStringAsFixed(2)}',
    );
  }
  final out = File('release/_reports/content_theory_density.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(report.toString());
  stdout.write(report);
}
