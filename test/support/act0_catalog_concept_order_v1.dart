import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

typedef CatalogConceptV1 = ({String id, RegExp mention});

final _sentence = RegExp(r'(?<=[.!?])\s+');
final _explanation = RegExp(
  r'\b(means?|refers to|is when|are when|is an?|are the|'
  r'consists? of|stands? for|completes?|makes?|calculate|divide|'
  r'because|lets you|allows? you|gives? you|is called|are called)\b',
  caseSensitive: false,
);

/// A lexical guard. A use does not teach a term by itself. The definition
/// signal has to share the sentence with the term in a teaching surface.
Map<String, String> catalogConceptOrderFindingsV1(
  Iterable<CatalogTask> route,
  List<CatalogConceptV1> concepts,
) {
  final taught = <String>{};
  final findings = <String, String>{};
  for (final row in route) {
    final task = row.task;
    final runner = task.runner;
    void inspect(String surface, String text, {bool teaching = false}) {
      for (final sentence in text.split(_sentence)) {
        final canExplain = teaching && _explanation.hasMatch(sentence);
        for (final concept in concepts) {
          if (taught.contains(concept.id) ||
              !concept.mention.hasMatch(sentence)) {
            continue;
          }
          if (canExplain) {
            taught.add(concept.id);
          } else {
            findings.putIfAbsent(
              'W${row.world.worldNumber}|${task.taskId}|${concept.id}',
              () => '$surface: $sentence',
            );
          }
        }
      }
    }

    for (final step in runner.teachingSteps) {
      inspect('TEACH', '${step.title}. ${step.body}', teaching: true);
    }
    inspect('CAPTION', runner.caption, teaching: true);
    if (runner.hintPolicy == Act0HintPolicyV1.always ||
        (runner.hintPolicy == Act0HintPolicyV1.theoryOnly &&
            task.phase == Act0LessonPhaseV1.theory)) {
      inspect('HINT', runner.hint, teaching: true);
    }
    inspect('Q', catalogQuestion(task));
    for (final option in runner.options) {
      inspect('OPTION', option.label);
      inspect('FEEDBACK', option.feedbackReason);
    }
  }
  return findings;
}
