import 'dart:io';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_phrase_registry_v1.dart';

final _runnerPath = File(
  'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
);
final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');

const _bannedRunnerStrings = <String>[
  'Your move',
  'Tap the correct seat',
  'Read the table, then tap one seat.',
  'Check the reason, then continue',
  'Read the table first',
  'Choose the best size',
  'Choose the winning hand',
  'Choose the correct count',
  'Choose the best action',
  'To act - ',
  'Dealer',
  'Small blind',
  'Big blind',
  ' Hero',
  'Now',
];

void main() {
  final hardcodedEnglishFindings = <String>[];
  final riskyOverflowFindings = <String>[];

  if (!_runnerPath.existsSync() || !_statePath.existsSync()) {
    stderr.writeln('Act0 runtime audit files are missing.');
    exitCode = 1;
    return;
  }

  final runnerSource = _runnerPath.readAsStringSync();
  for (final banned in _bannedRunnerStrings) {
    if (runnerSource.contains("'$banned'") ||
        runnerSource.contains('"$banned"')) {
      hardcodedEnglishFindings.add('runner hardcoded English: $banned');
    }
  }

  final runnerLines = _runnerPath.readAsLinesSync();
  for (var index = 0; index < runnerLines.length; index += 1) {
    final line = runnerLines[index];
    if (!line.contains('TextOverflow.ellipsis')) {
      continue;
    }
    riskyOverflowFindings.add(
      '${_runnerPath.path}:${index + 1}: TextOverflow.ellipsis',
    );
  }

  final stateSource = _statePath.readAsStringSync();
  final extracted = <String, Set<String>>{
    'centerLabel': _extractQuotedValueSet(stateSource, 'centerLabel:'),
    'streetLabel': _extractQuotedValueSet(stateSource, 'streetLabel:'),
    'potLabel': _extractQuotedValueSet(stateSource, 'potLabel:'),
    'toCallLabel': _extractQuotedValueSet(stateSource, 'toCallLabel:'),
    'actionTrail': _extractActionTrailLabelSet(stateSource),
    'optionLabel': _extractQuotedValueSet(stateSource, 'label:'),
    'preferredLabel': _extractQuotedValueSet(stateSource, 'preferredLabel:'),
    'betterAnswerLabel': _extractQuotedValueSet(
      stateSource,
      'betterAnswerLabel:',
    ),
    'feedbackTitle': _extractQuotedValueSet(stateSource, 'feedbackTitle:'),
    'feedbackReason': _extractQuotedValueSet(stateSource, 'feedbackReason:'),
  };
  final duplicated = <String, List<String>>{
    'actionTrail': _extractActionTrailLabelList(stateSource),
    'optionLabel': _extractQuotedValueList(stateSource, 'label:'),
    'preferredLabel': _extractQuotedValueList(stateSource, 'preferredLabel:'),
    'betterAnswerLabel': _extractQuotedValueList(
      stateSource,
      'betterAnswerLabel:',
    ),
    'feedbackTitle': _extractQuotedValueList(stateSource, 'feedbackTitle:'),
    'feedbackReason': _extractQuotedValueList(stateSource, 'feedbackReason:'),
  };

  stdout.writeln('Act0 runtime surface audit');
  stdout.writeln(
    'Runner hardcoded English findings: ${hardcodedEnglishFindings.length}',
  );
  if (hardcodedEnglishFindings.isEmpty) {
    stdout.writeln('No banned runner literals found.');
  } else {
    for (final finding in hardcodedEnglishFindings) {
      stdout.writeln(finding);
    }
  }

  stdout.writeln('');
  stdout.writeln(
    'Runner risky ellipsis findings: ${riskyOverflowFindings.length}',
  );
  if (riskyOverflowFindings.isEmpty) {
    stdout.writeln('No remaining TextOverflow.ellipsis matches found.');
  } else {
    for (final finding in riskyOverflowFindings) {
      stdout.writeln(finding);
    }
  }

  stdout.writeln('');
  stdout.writeln('State runtime label inventory');
  for (final entry in extracted.entries) {
    stdout.writeln('${entry.key}: ${entry.value.length}');
    for (final value in entry.value.toList()..sort()) {
      stdout.writeln('  $value');
    }
  }

  final foreignResidue = <String>[
    ..._collectForeignResidue(extracted['actionTrail'] ?? const <String>{}),
    ..._collectForeignResidue(extracted['optionLabel'] ?? const <String>{}),
    ..._collectForeignResidue(extracted['preferredLabel'] ?? const <String>{}),
    ..._collectForeignResidue(
      extracted['betterAnswerLabel'] ?? const <String>{},
    ),
    ..._collectForeignResidue(extracted['feedbackTitle'] ?? const <String>{}),
    ..._collectForeignResidue(extracted['feedbackReason'] ?? const <String>{}),
  ].toSet().toList()..sort();

  stdout.writeln('');
  stdout.writeln('Foreign-residue candidates: ${foreignResidue.length}');
  for (final value in foreignResidue) {
    stdout.writeln('  $value');
  }

  final repeatedResidueCounts = _countForeignResidueOccurrences(duplicated);
  final normalizedResidueFamilies = _groupForeignResidueFamilies(duplicated);

  stdout.writeln('');
  stdout.writeln('Top repeated foreign-residue phrases');
  _printTopCounts(repeatedResidueCounts, limit: 40);

  stdout.writeln('');
  stdout.writeln('Top normalized foreign-residue families');
  _printTopFamilyCounts(normalizedResidueFamilies, limit: 40);
}

Set<String> _extractQuotedValueSet(String source, String anchor) =>
    _extractQuotedValueList(source, anchor).toSet();

List<String> _extractQuotedValueList(String source, String anchor) {
  final pattern = RegExp('${RegExp.escape(anchor)}\\s*\'([^\']*)\'');
  return pattern
      .allMatches(source)
      .map((match) => match.group(1)!)
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
}

Set<String> _extractActionTrailLabelSet(String source) =>
    _extractActionTrailLabelList(source).toSet();

List<String> _extractActionTrailLabelList(String source) {
  final pattern = RegExp(r"Act0ActionTrailItemV1\(label:\s*'([^']+)'\)");
  return pattern
      .allMatches(source)
      .map((match) => match.group(1)!)
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
}

Iterable<String> _collectForeignResidue(Set<String> values) sync* {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    if (!_containsLatinWord(trimmed)) {
      continue;
    }
    if (_allowedForeignPattern(trimmed)) {
      continue;
    }
    if (act0RuntimeIsHandledEnglishPhraseV1(trimmed)) {
      continue;
    }
    yield trimmed;
  }
}

bool _containsLatinWord(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

bool _allowedForeignPattern(String value) {
  final trimmed = value.trim();
  if (RegExp(
    r'^(UTG|HJ|CO|BTN|SB|BB|LJ|MP|UTG\+1|UTG\+2|A|K|Q|J|T|9|8|7|6|5|4|3|2|h|d|c|s)$',
  ).hasMatch(trimmed)) {
    return true;
  }
  if (RegExp(r'^\d+(\.\d+)? BB$').hasMatch(trimmed)) {
    return true;
  }
  if (RegExp(r'^[AKQJT2-9][shdc]$').hasMatch(trimmed)) {
    return true;
  }
  return false;
}

Map<String, int> _countForeignResidueOccurrences(
  Map<String, List<String>> duplicated,
) {
  final counts = <String, int>{};
  for (final values in duplicated.values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty ||
          !_containsLatinWord(trimmed) ||
          _allowedForeignPattern(trimmed) ||
          act0RuntimeIsHandledEnglishPhraseV1(trimmed)) {
        continue;
      }
      counts.update(trimmed, (existing) => existing + 1, ifAbsent: () => 1);
    }
  }
  return counts;
}

Map<String, _ResidueFamily> _groupForeignResidueFamilies(
  Map<String, List<String>> duplicated,
) {
  final families = <String, _ResidueFamily>{};
  for (final values in duplicated.values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty ||
          !_containsLatinWord(trimmed) ||
          _allowedForeignPattern(trimmed) ||
          act0RuntimeIsHandledEnglishPhraseV1(trimmed)) {
        continue;
      }
      final key = _normalizeResidueFamilyKey(trimmed);
      final family = families.putIfAbsent(
        key,
        () => _ResidueFamily(key: key, sample: trimmed),
      );
      family.count += 1;
      family.samples.add(trimmed);
    }
  }
  return families;
}

String _normalizeResidueFamilyKey(String value) {
  var normalized = value.toLowerCase().trim();
  normalized = normalized.replaceAll(RegExp(r'\d+(\.\d+)?\s*bb'), '<bb>');
  normalized = normalized.replaceAll(RegExp(r'\d+'), '<n>');
  normalized = normalized.replaceAll(RegExp(r'\b(hero|villain)\b'), '<role>');
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
  normalized = normalized.replaceAll(RegExp(r'[^\w\s<>+-]'), '');
  return normalized;
}

void _printTopCounts(Map<String, int> counts, {required int limit}) {
  final sorted = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) {
        return byCount;
      }
      return a.key.compareTo(b.key);
    });
  if (sorted.isEmpty) {
    stdout.writeln('  none');
    return;
  }
  for (final entry in sorted.take(limit)) {
    stdout.writeln('  [${entry.value}] ${entry.key}');
  }
}

void _printTopFamilyCounts(
  Map<String, _ResidueFamily> families, {
  required int limit,
}) {
  final sorted = families.values.toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) {
        return byCount;
      }
      return a.key.compareTo(b.key);
    });
  if (sorted.isEmpty) {
    stdout.writeln('  none');
    return;
  }
  for (final family in sorted.take(limit)) {
    final sample = family.samples.toList()..sort();
    stdout.writeln('  [${family.count}] ${family.key}');
    stdout.writeln('    e.g. ${sample.take(3).join(' | ')}');
  }
}

class _ResidueFamily {
  _ResidueFamily({required this.key, required this.sample})
    : samples = <String>{sample};

  final String key;
  final String sample;
  int count = 0;
  final Set<String> samples;
}
