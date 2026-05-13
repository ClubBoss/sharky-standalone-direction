import 'dart:io';

final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
final _runnerPath = File(
  'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
);

const _genericFeedbackTitles = <String>{
  'Almost there.',
  'Nice read.',
  'Good.',
  'Playable move.',
  'Playable instinct.',
  'Table takeaway.',
  'Card takeaway.',
  'Street takeaway.',
  'Action takeaway.',
  'Order takeaway.',
  'Position takeaway.',
  'Ranking takeaway.',
  'Showdown takeaway.',
  'World 1 takeaway.',
};

void main() {
  if (!_statePath.existsSync() || !_runnerPath.existsSync()) {
    stderr.writeln('Act0 feedback audit files are missing.');
    exitCode = 1;
    return;
  }

  final stateSource = _statePath.readAsStringSync();
  final runnerSource = _runnerPath.readAsStringSync();

  final titles = _extractQuotedValues(stateSource, 'feedbackTitle:');
  final reasons = _extractQuotedValues(stateSource, 'feedbackReason:');
  final emptySyntheticFeedbackPairs = RegExp(
    r"feedbackTitle:\s*''\s*,\s*feedbackReason:\s*''",
  ).allMatches(runnerSource).length;

  final genericTitleCounts = <String, int>{};
  for (final title in titles) {
    if (_genericFeedbackTitles.contains(title)) {
      genericTitleCounts[title] = (genericTitleCounts[title] ?? 0) + 1;
    }
  }

  final shortReasonCandidates = reasons
      .where((reason) => reason.trim().isNotEmpty && reason.trim().length <= 28)
      .toList(growable: false);
  final emptyReasons = reasons.where((reason) => reason.trim().isEmpty).length;
  final emptyTitles = titles.where((title) => title.trim().isEmpty).length;

  stdout.writeln('Act0 feedback floor audit');
  stdout.writeln('Feedback titles: ${titles.length}');
  stdout.writeln('Feedback reasons: ${reasons.length}');
  stdout.writeln('Empty feedback titles in state: $emptyTitles');
  stdout.writeln('Empty feedback reasons in state: $emptyReasons');
  stdout.writeln(
    'Empty synthetic feedback pairs in runner wiring: $emptySyntheticFeedbackPairs',
  );

  stdout.writeln('');
  stdout.writeln('Generic feedback title reuse');
  if (genericTitleCounts.isEmpty) {
    stdout.writeln('No generic title reuse found.');
  } else {
    final sortedTitles = genericTitleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedTitles) {
      stdout.writeln('${entry.value}x ${entry.key}');
    }
  }

  stdout.writeln('');
  stdout.writeln(
    'Short reason candidates (<= 28 chars): ${shortReasonCandidates.length}',
  );
  for (final reason in shortReasonCandidates.take(40)) {
    stdout.writeln(reason);
  }
}

List<String> _extractQuotedValues(String source, String anchor) {
  final singleQuotePattern = RegExp('${RegExp.escape(anchor)}\\s*\'([^\']*)\'');
  final doubleQuotePattern = RegExp('${RegExp.escape(anchor)}\\s*"([^"]*)"');
  return <String>[
    ...singleQuotePattern.allMatches(source).map((match) => match.group(1)!),
    ...doubleQuotePattern.allMatches(source).map((match) => match.group(1)!),
  ];
}
