import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

const atlasChecklistConceptsV1 = {
  'C1': ['Side pot', 'Overcard', 'Backdoor draw', 'Bankroll', 'Middle pair'],
  'C2': [
    'Expected value (EV)',
    'Continuation bet (c-bet)',
    '3-bet',
    'Overpair',
    'Tilt',
    'Nit',
    'Passive player',
    'Aggressive player',
  ],
  'C3': ['Broadway', 'Wheel'],
};

const _additionalTerms = [
  Act0GlossaryTermV1('Bankroll', r'\bbankroll\b', ''),
  Act0GlossaryTermV1('Expected value (EV)', r'\b(?:expected value|EV)\b', ''),
  Act0GlossaryTermV1('Tilt', r'\btilt(?:ed|ing)?\b', ''),
  Act0GlossaryTermV1('Nit', r'\bnits?\b|very tight player', ''),
  Act0GlossaryTermV1(
    'Passive player',
    r'\bpassive (?:player|opponent)s?\b',
    '',
  ),
  Act0GlossaryTermV1(
    'Aggressive player',
    r'\baggressive (?:player|opponent)s?\b',
    '',
  ),
  Act0GlossaryTermV1('Wheel', r'\bwheel\b|A[– -]2[– -]3[– -]4[– -]5', ''),
  Act0GlossaryTermV1(
    'One in N',
    r'\b(?:1|one) (?:time )?(?:out of|in) \d+\b',
    '',
  ),
  Act0GlossaryTermV1('Pocket pair', r'\bpocket pairs?\b', ''),
  Act0GlossaryTermV1('One pair', r'\bone pair\b', ''),
  Act0GlossaryTermV1('Two pair', r'\btwo pairs?\b', ''),
  Act0GlossaryTermV1('Three of a kind', r'\bthree of a kind\b', ''),
  Act0GlossaryTermV1('Straight', r'\bstraight\b(?! draw| flush)', ''),
  Act0GlossaryTermV1('Flush', r'(?<!straight )\bflush\b(?! draw)', ''),
  Act0GlossaryTermV1('Full house', r'\bfull[- ]house\b', ''),
  Act0GlossaryTermV1('Four of a kind', r'\bfour of a kind\b|\bquads\b', ''),
  Act0GlossaryTermV1('Straight flush', r'\bstraight[- ]flush\b', ''),
];

final _definitionCue = RegExp(
  r'\b(?:is|are|means?|refers? to|when|needs?|stands? for|you have|must hit|has to hit)\b|=',
  caseSensitive: false,
);

bool atlasIsGradedV1(CatalogTask row) =>
    row.task.phase != Act0LessonPhaseV1.theory &&
    row.task.runner.options.any((option) => option.isCorrect);

class AtlasConceptCoverageV1 {
  CatalogTask? explained;
  CatalogTask? used;
  int? explainedIndex;
  int? usedIndex;
  final assessed = <CatalogTask>[];

  bool get explainedBeforeUse =>
      explainedIndex != null &&
      usedIndex != null &&
      explainedIndex! <= usedIndex!;
}

/// Use the product glossary's aliases and inline definitions. The atlas adds
/// names missing from the in-app glossary. TEACH mentions are candidates for
/// D1 density. For C1/C2, require a definition cue in the TEACH body or a
/// product glossary inline pattern. Prompt/correct choice is an assessment
/// signal. Title, hints and feedback-only mentions do not earn assessment credit.
Map<String, AtlasConceptCoverageV1> auditAtlasConceptsV1(
  List<CatalogTask> rows,
) {
  final terms = [...act0GlossaryTermsV1, ..._additionalTerms];
  final requiredDefinitions = {
    ...atlasChecklistConceptsV1['C1']!,
    ...atlasChecklistConceptsV1['C2']!,
  };
  return {
    for (final term in terms)
      term.name: _coverage(term, rows, requiredDefinitions.contains(term.name)),
  };
}

AtlasConceptCoverageV1 _coverage(
  Act0GlossaryTermV1 term,
  List<CatalogTask> rows,
  bool requireDefinition,
) {
  final use = RegExp(term.use, caseSensitive: false);
  final inline = term.inline == null
      ? null
      : RegExp(term.inline!, caseSensitive: false);
  final coverage = AtlasConceptCoverageV1();
  for (final (index, row) in rows.indexed) {
    final runner = row.task.runner;
    final teach = [
      for (final step in runner.teachingSteps) '${step.title} ${step.body}',
    ];
    final question = catalogQuestion(row.task);
    final correct = runner.options.where((option) => option.isCorrect);
    final assessment = [
      question,
      for (final option in correct) option.label,
      if (term.name == 'One in N') runner.caption,
    ];
    final copy = [
      catalogTitle(row.task),
      ...teach,
      ...assessment,
      runner.caption,
      runner.hint,
      for (final option in runner.options) ...[
        option.label,
        option.feedbackReason,
      ],
    ];
    if (coverage.used == null && copy.any(use.hasMatch)) {
      coverage.used = row;
      coverage.usedIndex = index;
    }
    if (coverage.explained == null &&
        (teach.any(
              (text) =>
                  use.hasMatch(text) &&
                  (!requireDefinition || _definitionCue.hasMatch(text)),
            ) ||
            (inline != null && copy.any(inline.hasMatch)))) {
      coverage.explained = row;
      coverage.explainedIndex = index;
    }
    if (atlasIsGradedV1(row) && assessment.any(use.hasMatch)) {
      coverage.assessed.add(row);
    }
  }
  return coverage;
}
