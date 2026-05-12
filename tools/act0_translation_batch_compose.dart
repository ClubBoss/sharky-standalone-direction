import 'dart:io';

final _packsDir = Directory('docs/l10n/act0_world_packs');
final _outputFile = File('docs/l10n/act0_world_packs/ACT0_RU_NEXT_BATCH_v1.md');

const _recommendedOrder = <String>[
  'world_3',
  'world_5',
  'world_7',
  'world_8',
  'world_9',
  'world_10',
  'world_11',
  'world_12',
];

void main() {
  if (!_packsDir.existsSync()) {
    stderr.writeln('Missing packs directory: ${_packsDir.path}');
    exitCode = 1;
    return;
  }

  final packFiles = {
    for (final file in _packsDir.listSync().whereType<File>())
      _worldIdFromPackName(file.uri.pathSegments.last): file,
  };

  final buffer = StringBuffer()
    ..writeln('# Act0 RU Next Batch v1')
    ..writeln()
    ..writeln('Status: GENERATED')
    ..writeln('Purpose: one-file handoff for the next highest-EV RU batch')
    ..writeln()
    ..writeln('## Recommended Order')
    ..writeln('1. `world_3`')
    ..writeln(
      'Reason: tiny remaining gap, cheap closure, keeps early route coherent.',
    )
    ..writeln('2. `world_5`')
    ..writeln('Reason: first large empty teaching block with real task volume.')
    ..writeln('3. `world_7` to `world_10`')
    ..writeln(
      'Reason: consecutive mid-course empty blocks; best batching efficiency.',
    )
    ..writeln('4. `world_11` to `world_12`')
    ..writeln(
      'Reason: tail blocks can be drafted last without blocking active route.',
    )
    ..writeln()
    ..writeln('## Runtime Rule')
    ..writeln(
      'Do not paste raw machine output straight into `act0_copy_ru_v1.dart`.',
    )
    ..writeln(
      'First fill this batch doc, then review, then ingest selected worlds back into the language file.',
    )
    ..writeln()
    ..writeln('## Included Packs');

  for (final worldId in _recommendedOrder) {
    final file = packFiles[worldId];
    if (file == null) {
      buffer
        ..writeln()
        ..writeln('### $worldId')
        ..writeln('Pack missing.');
      continue;
    }
    buffer
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## Pack: $worldId')
      ..writeln()
      ..write(file.readAsStringSync().trim())
      ..writeln()
      ..writeln();
  }

  _outputFile.parent.createSync(recursive: true);
  _outputFile.writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${_outputFile.path}');
}

String _worldIdFromPackName(String name) {
  final match = RegExp(r'^W\d+_(world_\d+)_').firstMatch(name);
  return match?.group(1) ?? name;
}
