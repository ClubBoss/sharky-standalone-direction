import 'dart:io';

const allowedTags = <String>{
  'range_shape',
  'density',
  'caps',
  'fragility',
  'pressure_tier',
  'reaction_layer',
  'window_type',
  'continuity',
  'merge_band',
  'thin_value_band',
  'timing_window',
  'fold_window',
  'call_heavy',
  'fold_heavy',
};

Future<void> main() async {
  final indexFile = File('content/evolution_index/v1/index.txt');
  if (!await indexFile.exists()) {
    stderr.writeln('Index file not found: ${indexFile.path}');
    exit(1);
  }

  final lines = await indexFile.readAsLines();
  var lineNumber = 0;
  for (final raw in lines) {
    lineNumber++;
    final line = raw.trim();
    if (line.isEmpty) continue;
    final colonIndex = line.indexOf(':');
    if (colonIndex < 0) {
      stderr.writeln('Line $lineNumber missing module separator');
      exit(1);
    }
    final module = line.substring(0, colonIndex).trim();
    final tagText = line
        .substring(colonIndex + 1)
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (tagText.length < 3) {
      stderr.writeln('$module (line $lineNumber) has fewer than 3 tags');
      exit(1);
    }
    final seen = <String>{};
    for (final tag in tagText) {
      if (!allowedTags.contains(tag)) {
        stderr.writeln('$module (line $lineNumber) has invalid tag: $tag');
        exit(1);
      }
      if (!seen.add(tag)) {
        stderr.writeln('$module (line $lineNumber) has duplicate tag: $tag');
        exit(1);
      }
    }
  }

  stdout.writeln('OK: Evolution cohesion valid');
}
