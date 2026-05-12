import 'dart:io';

final _packsDir = Directory('docs/l10n/act0_world_packs');
final _outputFile = File(
  'docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md',
);

const _worldOrder = <String>[
  'world_1',
  'world_2',
  'world_3',
  'world_4',
  'world_5',
  'world_6',
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

  final packFiles = <String, File>{
    for (final file in _packsDir.listSync().whereType<File>())
      _worldIdFromPackName(file.uri.pathSegments.last): file,
  };

  final buffer = StringBuffer()
    ..writeln('# Act0 RU Consolidated Editor Export v1')
    ..writeln()
    ..writeln('Status: GENERATED')
    ..writeln('Scope: `world_1` to `world_12`')
    ..writeln(
      'Purpose: one-file bilingual handoff for external translation review',
    )
    ..writeln()
    ..writeln('## How To Use')
    ..writeln('1. Review or improve only `*_ru` fields.')
    ..writeln('2. Keep ids unchanged.')
    ..writeln('3. Keep tone compact, learner-facing, and poker-literate.')
    ..writeln(
      '4. Do not treat this file as runtime truth; it is an editorial handoff artifact.',
    )
    ..writeln()
    ..writeln('## Runtime Truth')
    ..writeln(
      '- Runtime language file: `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`',
    )
    ..writeln(
      '- Core API/reader layer: `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`',
    )
    ..writeln()
    ..writeln('## Included World Packs');

  for (final worldId in _worldOrder) {
    final file = packFiles[worldId];
    if (file == null) {
      buffer
        ..writeln()
        ..writeln('---')
        ..writeln()
        ..writeln('## Pack: $worldId')
        ..writeln()
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
