import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

typedef CatalogRubricFindingV1 = ({String rule, String task, String detail});

const catalogSnapshotPathV1 = 'test/fixtures/act0_catalog_snapshot_v1.txt';

final _lateAssumption = RegExp(
  r'(?:^|[.!?]\s+)\s*(?:in this (?:spot|model),\s*)?'
  r'(?:assume (?:that )?|this (?:answer|decision|model) assumes (?:that )?)'
  r'([^.!?;]+)',
  caseSensitive: false,
);
final _answerCue = RegExp(
  r'(?:^|[.!?]\s+)\s*(?:the (?:correct|best|right) '
  r'(?:answer|option|choice|move) (?:is|:)\s*|'
  r'(?:choose|pick|select)\s+)([^.!?;]+)',
  caseSensitive: false,
);
final _filler = RegExp(
  r'^(?:correct|good choice|great choice|well done|try again|'
  r'not quite|wrong|look again|on seat (?:utg|hj|co|btn|sb|bb)|'
  r'n/?a|tbd|todo|placeholder)$',
);
final _pokerJargon = RegExp(
  r'\b(?:'
  r'donk[- ]bets?|overlimps?|limp[- ]behinds?|'
  r'snap[- ]calls?|click[- ]backs?|float[- ]bets?|'
  r'open[- ]jams?|re[- ]jams?|rakeback|backraises?|tilt[- ]shoves?|'
  r'hole cards?|pocket cards?|table cards?|muck(?:s|ed|ing)?|'
  r'shov(?:e|es|ed|ing)|jam(?:s|med|ming)?'
  r')\b',
  caseSensitive: false,
);
final _glossaryUses = [
  for (final entry in act0GlossaryTermsV1)
    RegExp('^(?:${entry.use})\$', caseSensitive: false),
];
final _nonWords = RegExp(r'[^a-z0-9%]+');

String _normalize(String text) =>
    text.toLowerCase().replaceAll(_nonWords, ' ').trim();

Iterable<CatalogRubricFindingV1> catalogRubricFindingsV1(
  Act0LessonTaskV1 task,
) sync* {
  final runner = task.runner;
  final question = catalogQuestion(task);
  final teach = [
    for (final step in runner.teachingSteps) ...[step.title, step.body],
  ];
  final prompt = [
    runner.caption,
    question,
    ...teach,
    if (runner.hintPolicy == Act0HintPolicyV1.always) runner.hint,
  ];

  CatalogRubricFindingV1 finding(String rule, String detail) =>
      (rule: rule, task: task.taskId, detail: detail);

  final answers = {
    for (final option in runner.options)
      if (option.isCorrect) _normalize(option.label),
  };
  final normalizedPrompt = prompt.map((text) => ' ${_normalize(text)} ');
  for (final option in runner.options) {
    if (!option.isCorrect) continue;
    for (final match in _lateAssumption.allMatches(option.feedbackReason)) {
      final premise = _normalize(match[1]!);
      if (premise.isNotEmpty &&
          !normalizedPrompt.any((surface) => surface.contains(' $premise '))) {
        yield finding('E17', '${option.id}: ${match[1]}');
      }
    }
  }

  if (runner.options.any((option) => !option.isCorrect)) {
    for (final surface in [question, ...teach]) {
      for (final match in _answerCue.allMatches(surface)) {
        final named = _normalize(match[1]!);
        if (answers.contains(named) && named.isNotEmpty) {
          yield finding('E18', match[0]!.trim());
        }
      }
    }
  }

  final required = {
    if (runner.options.isNotEmpty) 'question': question,
    for (final option in runner.options)
      'feedback/${option.id}': option.feedbackReason,
  };
  for (final field in required.entries) {
    final value = _normalize(field.value);
    if (value.isEmpty || _filler.hasMatch(value)) {
      yield finding('E20', '${field.key}: "${field.value}"');
    }
  }

  final text = [
    task.title,
    ...prompt,
    for (final option in runner.options) ...[
      option.label,
      option.feedbackTitle,
      option.feedbackReason,
    ],
    if (runner.options.isEmpty) runner.feedbackReason,
  ];
  final jargon = {
    for (final surface in text)
      for (final match in _pokerJargon.allMatches(surface))
        match[0]!.toLowerCase(),
  };
  for (final term in jargon) {
    // W1 introduces "muck" once as a definition at showdown.
    if (task.taskId == 'showdown_theory' && term == 'muck') continue;
    if (!_glossaryUses.any((use) => use.hasMatch(term))) {
      yield finding('E11', term);
    }
  }
}

final _snapshotTask = RegExp(r'^TASK (\S+) \[');
final _labelSpaces = RegExp(r'\s+');
final _labelEndPunctuation = RegExp(r'[!?]+$');
String _normalizeLabel(String label) => label
    .trim()
    .toLowerCase()
    .replaceAll(_labelSpaces, ' ')
    .replaceFirst(_labelEndPunctuation, '');

final _snapshotOption = RegExp(r'^  [+-] \[(\w+)\] (.+?) — ');

Map<String, Map<String, Set<String>>> _labelsByGrade(String snapshot) {
  final tasks = <String, Map<String, Set<String>>>{};
  Map<String, Set<String>>? grades;
  for (final line in const LineSplitter().convert(snapshot)) {
    if (_snapshotTask.firstMatch(line) case final match?) {
      grades = tasks.putIfAbsent(match[1]!, () => {});
    } else if (_snapshotOption.firstMatch(line) case final match?) {
      grades!.putIfAbsent(match[1]!, () => {}).add(_normalizeLabel(match[2]!));
    }
  }
  return tasks;
}

Iterable<CatalogRubricFindingV1> catalogOptionLabelChangesV1(
  String previous,
  String current,
) sync* {
  final before = _labelsByGrade(previous);
  final after = _labelsByGrade(current);
  if (before.isEmpty || after.isEmpty) {
    throw const FormatException('No TASK records in catalog snapshot');
  }
  for (final task in after.entries) {
    final old = before[task.key];
    if (old == null) continue;
    final oldLabels = old.values.expand((labels) => labels).toSet();
    final newLabels = task.value.values.expand((labels) => labels).toSet();
    for (final grade in task.value.entries) {
      final removed = old[grade.key]?.difference(newLabels);
      final added = grade.value.difference(oldLabels);
      if (removed == null || removed.isEmpty || added.isEmpty) continue;
      yield (
        rule: 'E19',
        task: task.key,
        detail: '${grade.key}: ${removed.join(' / ')} → ${added.join(' / ')}',
      );
    }
  }
}

String? previousCatalogSnapshotV1({String path = catalogSnapshotPathV1}) {
  final environment = Platform.environment;
  final eventPath = environment['GITHUB_EVENT_PATH'];
  final tierA = environment['TEST_AUTHORITY_SHARD']?.endsWith('/3') ?? false;
  String? revision;
  if (eventPath != null && File(eventPath).existsSync()) {
    final event = jsonDecode(File(eventPath).readAsStringSync()) as Map;
    revision =
        (event['pull_request'] as Map?)?['base']['sha'] as String? ??
        event['before'] as String?;
  }
  if (revision?.startsWith(RegExp(r'^0+$')) ?? false) return null;
  if (revision == null) {
    final result = Process.runSync('git', [
      'merge-base',
      'HEAD',
      'origin/main',
    ]);
    if (result.exitCode != 0) return null;
    revision = (result.stdout as String).trim();
  }
  final result = Process.runSync('git', ['show', '$revision:$path']);
  if (result.exitCode != 0) {
    if (tierA)
      throw StateError('Catalog snapshot at $revision: ${result.stderr}');
    return null;
  }
  return result.stdout as String;
}
