import 'dart:io';

void main() {
  final file = File('release/_reports/theory_density_normalized.txt');
  if (!file.existsSync()) return;
  final lines = file.readAsLinesSync();
  final index = StringBuffer();
  index.writeln('module | density | coherence | severity');
  final dir = Directory('release/_reports/density_coherence_suggestions');
  dir.createSync(recursive: true);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!line.startsWith('module:')) continue;
    final module = line.split(':').last.trim();
    double density = 0;
    double coherence = 0;
    for (var j = i + 1; j < lines.length && lines[j].isNotEmpty; j++) {
      final current = lines[j];
      if (current.startsWith('density:')) {
        density =
            double.tryParse(current.split(':').last.split('(').first.trim()) ??
            0.0;
      }
      if (current.startsWith('coherence:')) {
        coherence =
            double.tryParse(current.split(':').last.split('(').first.trim()) ??
            0.0;
      }
    }
    final suggestions = <String>[];
    var severity = 'LOW';
    if (density < 85) {
      suggestions.add('expand with 2-4 sentences to cover core ideas');
      severity = 'MEDIUM';
    } else if (density > 135) {
      suggestions.add('remove redundant lines or split sections');
      severity = 'MEDIUM';
    }
    if (coherence < 0.85) {
      suggestions.add('tighten transitions between concepts');
      severity = 'HIGH';
    }
    if (suggestions.isEmpty) {
      suggestions.add('maintain current explanatory flow');
    }
    final buffer = StringBuffer();
    buffer.writeln('Module: $module');
    buffer.writeln('Density Score: ${density.toStringAsFixed(2)}');
    buffer.writeln('Coherence Score: ${coherence.toStringAsFixed(2)}');
    buffer.writeln('Suggestions:');
    for (final s in suggestions) {
      buffer.writeln('  - [$severity] $s');
    }
    File('${dir.path}/$module.txt').writeAsStringSync(buffer.toString());
    index.writeln(
      '$module | ${density.toStringAsFixed(2)} | ${coherence.toStringAsFixed(2)} | $severity',
    );
  }
  File('${dir.path}/_index.txt').writeAsStringSync(index.toString());
  stdout.write(index.toString());
}
