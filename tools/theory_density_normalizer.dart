import 'dart:io';

void main() {
  final file = File('release/_reports/content_theory_density.txt');
  if (!file.existsSync()) return;
  final lines = file.readAsLinesSync();
  final entries = <_Row>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    entries.add(
      _Row(
        module: parts[0],
        density: double.tryParse(parts[3]) ?? 0.0,
        coverage: double.tryParse(parts[4]) ?? 0.0,
        coherence: double.tryParse(parts[5]) ?? 0.0,
        chars: int.tryParse(parts[1]) ?? 0,
        lines: int.tryParse(parts[2]) ?? 0,
      ),
    );
  }
  final buffer = StringBuffer();
  buffer.writeln('==== THEORY DENSITY NORMALIZER ====');
  var total = 0;
  var outOfRange = 0;
  double deficiency = 0.0;
  for (final entry in entries) {
    total++;
    final charsPerLine = entry.lines == 0 ? 0.0 : entry.chars / entry.lines;
    final densityStatus = charsPerLine < 85
        ? 'under'
        : charsPerLine > 135
        ? 'over'
        : 'ideal';
    final coverageStatus = entry.coverage >= 0.9 ? 'ok' : 'low';
    final coherenceStatus = entry.coherence >= 0.85 ? 'ok' : 'low';
    if (densityStatus != 'ideal' ||
        coverageStatus != 'ok' ||
        coherenceStatus != 'ok') {
      outOfRange++;
    }
    deficiency +=
        (densityStatus == 'ideal' ? 0 : 10) +
        (coverageStatus == 'ok' ? 0 : 5) +
        (coherenceStatus == 'ok' ? 0 : 5);
    buffer.writeln('module: ${entry.module}');
    buffer.writeln(
      'density: ${charsPerLine.toStringAsFixed(1)} ($densityStatus)',
    );
    buffer.writeln(
      'coherence: ${entry.coherence.toStringAsFixed(2)} ($coherenceStatus)',
    );
    buffer.writeln(
      'coverage: ${entry.coverage.toStringAsFixed(2)} ($coverageStatus)',
    );
    buffer.writeln('suggestions:');
    if (densityStatus == 'over') {
      buffer.writeln('  - reduce verbosity or split theory sections');
    } else if (densityStatus == 'under') {
      buffer.writeln('  - add examples or expand explanations');
    }
    if (coherenceStatus == 'low') {
      buffer.writeln('  - reorganize sections to enhance flow');
    }
    if (coverageStatus == 'low') {
      buffer.writeln('  - ensure theory ties to drills/quizzes');
    }
    buffer.writeln('------------------------------------');
  }
  buffer.writeln('==== GLOBAL SUMMARY ====');
  final weighted = entries.isEmpty ? 0.0 : deficiency / entries.length;
  buffer.writeln('modules scanned | $total');
  buffer.writeln('out of range    | $outOfRange');
  buffer.writeln('deficiency idx  | ${weighted.toStringAsFixed(2)}');
  final out = File('release/_reports/theory_density_normalized.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

class _Row {
  _Row({
    required this.module,
    required this.density,
    required this.coverage,
    required this.coherence,
    required this.chars,
    required this.lines,
  });

  final String module;
  final double density;
  final double coverage;
  final double coherence;
  final int chars;
  final int lines;
}
