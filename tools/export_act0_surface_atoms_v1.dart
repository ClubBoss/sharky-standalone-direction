import 'dart:io';

final _sourceFiles = <String>[
  'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
  'lib/ui_v2/act0_shell/act0_placement_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart',
];

final _contextAtomPattern = RegExp(
  r"(?:act0LocalizedSurfaceAtomV1|_playCopyV1|_placementAtomV1)\(\s*context\s*,\s*'([^']+)'\s*,\s*fallback:\s*'([^']*)'",
  dotAll: true,
);
final _profileAtomPattern = RegExp(
  r"_profileCopyV1\(\s*context\s*,[\s\S]*?atomId:\s*'([^']+)'[\s\S]*?fallback:\s*'([^']*)'",
  dotAll: true,
);
final _welcomeAtomPattern = RegExp(
  r"_atomV1\(\s*'([^']+)'\s*,\s*fallback:\s*'([^']*)'",
  dotAll: true,
);
final _ruAtomPattern = RegExp(
  r"'([^']+)':\s*Act0SurfaceAtomCopyV1\(\s*text:\s*'([^']*)'",
  dotAll: true,
);

class _AtomRow {
  const _AtomRow({
    required this.file,
    required this.atomId,
    required this.fallback,
    required this.ru,
  });

  final String file;
  final String atomId;
  final String fallback;
  final String ru;
}

void main() {
  final ruAtoms = _loadRuAtoms();
  final rows = <_AtomRow>[];
  final seen = <String>{};

  for (final path in _sourceFiles) {
    final source = File(path).readAsStringSync();
    for (final match in [
      ..._contextAtomPattern.allMatches(source),
      ..._profileAtomPattern.allMatches(source),
      ..._welcomeAtomPattern.allMatches(source),
    ]) {
      final atomId = match.group(1)!;
      final fallback = match.group(2)!;
      final dedupeKey = '$path::$atomId';
      if (!seen.add(dedupeKey)) {
        continue;
      }
      rows.add(
        _AtomRow(
          file: path,
          atomId: atomId,
          fallback: fallback,
          ru: ruAtoms[atomId] ?? '',
        ),
      );
    }
  }

  rows.sort((a, b) {
    final fileCompare = a.file.compareTo(b.file);
    if (fileCompare != 0) {
      return fileCompare;
    }
    return a.atomId.compareTo(b.atomId);
  });

  final buffer = StringBuffer()
    ..writeln('# Act0 Active Shell Surface Atoms Export')
    ..writeln()
    ..writeln(
      'Generated from active shell files. Columns: atom id, English fallback, Russian text.',
    )
    ..writeln();

  String? currentFile;
  for (final row in rows) {
    if (row.file != currentFile) {
      currentFile = row.file;
      buffer
        ..writeln('## `${row.file}`')
        ..writeln()
        ..writeln('| Atom ID | English Fallback | Russian |')
        ..writeln('| --- | --- | --- |');
    }
    buffer.writeln(
      '| `${_escape(row.atomId)}` | ${_escape(row.fallback)} | ${_escape(row.ru)} |',
    );
  }

  final output = File(
    'docs/content/ACT0_ACTIVE_SHELL_SURFACE_ATOMS_EXPORT_v1.md',
  );
  output.writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${output.path}');
}

Map<String, String> _loadRuAtoms() {
  final source = File(
    'lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart',
  ).readAsStringSync();
  final map = <String, String>{};
  for (final match in _ruAtomPattern.allMatches(source)) {
    map[match.group(1)!] = match.group(2)!;
  }
  return map;
}

String _escape(String value) =>
    value.replaceAll('|', r'\|').replaceAll('\n', '<br>');
