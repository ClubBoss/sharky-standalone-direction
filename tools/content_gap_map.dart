import 'dart:io';

void main() {
  final report = File('release/_reports/content_structure_audit.txt');
  if (!report.existsSync()) return;
  final lines = report.readAsLinesSync().skip(1);
  final entries = <_GapEntry>[];
  for (final line in lines) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    final module = parts[0];
    final missing = parts[1];
    final jsonValid = parts[2];
    final extras = parts[3];
    final orderFlag = parts[4];
    var deficiency = 0;
    final missingCount = missing == 'none' ? 0 : missing.split(',').length;
    deficiency += missingCount * 40;
    if (jsonValid != 'ok') deficiency += 20;
    final extrasCount = extras == 'none' ? 0 : extras.split(',').length;
    deficiency += extrasCount * 5;
    if (orderFlag == 'order-bad') deficiency += 10;
    deficiency = deficiency.clamp(0, 100);
    final weak = <String>[];
    if (missingCount > 0) weak.add('missing=$missingCount');
    if (jsonValid != 'ok') weak.add('json_invalid');
    if (extrasCount > 0) weak.add('extras=$extrasCount');
    if (orderFlag == 'order-bad') weak.add('order');
    entries.add(
      _GapEntry(
        module: module,
        deficiency: deficiency,
        missing: missingCount > 0 ? missing : 'none',
        weakAreas: weak.isEmpty ? 'none' : weak.join(','),
      ),
    );
  }
  entries.sort((a, b) => b.deficiency.compareTo(a.deficiency));
  final buffer = StringBuffer();
  buffer.writeln('==== GAP MAP ====');
  buffer.writeln('rank | module | deficiency | missing | weak_areas');
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.writeln(
      '${(i + 1).toString().padLeft(4)} | ${entry.module.padRight(30)} | ${entry.deficiency.toString().padLeft(3)} | ${entry.missing.padRight(20)} | ${entry.weakAreas}',
    );
  }
  final out = File('release/_reports/content_gap_map.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

class _GapEntry {
  _GapEntry({
    required this.module,
    required this.deficiency,
    required this.missing,
    required this.weakAreas,
  });

  final String module;
  final int deficiency;
  final String missing;
  final String weakAreas;
}
