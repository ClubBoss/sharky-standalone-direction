import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_phrase_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

String act0RuntimeTaskRailLabelV1(
  BuildContext context, {
  required bool isTeaching,
  required bool isTheory,
  required bool isDrill,
  required bool isReview,
  required bool isTrailHistory,
  required bool hasSeatTargets,
  required String question,
  required List<Act0RunnerOptionV1> options,
  Act0TaskFamilyV1? taskFamily,
}) {
  if (isReview) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'runner_task_check_reason_continue',
      fallback: 'Check the reason, then continue',
    );
  }
  if (isTeaching || isTheory) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'runner_task_read_table_first',
      fallback: 'Read the table first',
    );
  }
  if (isDrill && hasSeatTargets) {
    return act0LocalizedSurfaceAtomV1(
      context,
      'runner_task_tap_correct_seat',
      fallback: 'Tap the correct seat',
    );
  }
  if (isDrill && isTrailHistory) {
    return act0RuntimeTrailTaskLabelV1(context);
  }
  if (isDrill) {
    if (taskFamily == Act0TaskFamilyV1.sizing) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'runner_task_choose_best_size',
        fallback: 'Choose the best size',
      );
    }
    if (taskFamily == Act0TaskFamilyV1.compare) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'runner_task_choose_winning_hand',
        fallback: 'Choose the winning hand',
      );
    }
    if (taskFamily == Act0TaskFamilyV1.counting) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'runner_task_choose_correct_count',
        fallback: 'Choose the correct count',
      );
    }
    if (taskFamily == Act0TaskFamilyV1.recognition) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'runner_task_choose_correct_answer',
        fallback: 'Choose the correct answer',
      );
    }
    if (!_looksLikeActionDecisionDrillV1(
      question: question,
      options: options,
      taskFamily: taskFamily,
    )) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'runner_task_choose_correct_answer',
        fallback: 'Choose the correct answer',
      );
    }
    return act0LocalizedSurfaceAtomV1(
      context,
      'runner_task_choose_best_action',
      fallback: 'Choose the best action',
    );
  }
  return '';
}

bool _looksLikeActionDecisionDrillV1({
  required String question,
  required List<Act0RunnerOptionV1> options,
  required Act0TaskFamilyV1? taskFamily,
}) {
  if (taskFamily == Act0TaskFamilyV1.sizing) {
    return true;
  }
  final normalizedQuestion = question.trim().toLowerCase();
  const actionQuestionPhrases = <String>[
    'best action',
    'simple action',
    'clean action',
    'disciplined action',
    'simple response',
    'clean response',
    'disciplined response',
    'first-in action',
    'how to play',
    'what is cleaner',
    'what is the cleaner',
    'what is the clean action',
    'what action',
    'what response',
    'fits the price',
  ];
  if (actionQuestionPhrases.any(normalizedQuestion.contains)) {
    return true;
  }

  var actionLikeOptions = 0;
  for (final option in options) {
    final normalizedLabel = option.label.trim().toLowerCase();
    if (normalizedLabel.isEmpty) {
      continue;
    }
    if (normalizedLabel == 'fold' ||
        normalizedLabel == 'call' ||
        normalizedLabel == 'raise' ||
        normalizedLabel == 'check' ||
        normalizedLabel == 'bet' ||
        normalizedLabel == 'jam' ||
        normalizedLabel == 'shove' ||
        normalizedLabel == 'open' ||
        normalizedLabel.startsWith('fold ') ||
        normalizedLabel.startsWith('call ') ||
        normalizedLabel.startsWith('raise ') ||
        normalizedLabel.startsWith('check ') ||
        normalizedLabel.startsWith('bet ') ||
        normalizedLabel.startsWith('jam ') ||
        normalizedLabel.startsWith('shove ') ||
        normalizedLabel.startsWith('open ')) {
      actionLikeOptions += 1;
    }
  }
  return actionLikeOptions >= 2;
}

String act0RuntimeTrailTaskLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Read what happened' : 'Read what happened';
}

String act0RuntimeSeatTapStatusLabelV1(BuildContext context) =>
    act0LocalizedSurfaceAtomV1(
      context,
      'runner_badge_your_move',
      fallback: 'Your move',
    );

String act0RuntimeSeatTapHelperLabelV1(BuildContext context) =>
    act0LocalizedSurfaceAtomV1(
      context,
      'runner_prompt_read_table_then_tap',
      fallback: 'Read the table, then tap one seat.',
    );

String act0RuntimeTheoryRecallLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Review idea' : 'Review idea';
}

String act0RuntimeTheoryCoachLineV1(
  BuildContext context, {
  required String authoredLine,
  required String lessonId,
  required int beatIndex,
  required int teachingStepIndex,
  Act0TaskFamilyV1? taskFamily,
  required String prompt,
  required String supportLine,
}) {
  final localizedAuthored = act0RuntimeLocalizedGeneralLabelV1(
    context,
    authoredLine,
  ).trim();
  if (_shouldKeepAuthoredCoachLineV1(localizedAuthored)) {
    return localizedAuthored;
  }
  final candidates = _theoryCoachCandidatesV1(
    context,
    taskFamily: taskFamily,
    prompt: prompt,
    supportLine: supportLine,
  );
  return _pickDeterministicCoachLineV1(
    candidates,
    seed:
        'theory|$lessonId|$beatIndex|$teachingStepIndex|${taskFamily?.name ?? 'none'}|$prompt|$supportLine',
  );
}

String act0RuntimePromptCoachLineV1(
  BuildContext context, {
  required String lessonId,
  required int beatIndex,
  required String question,
  Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
  required bool isTrailHistory,
}) {
  if (isTrailHistory) {
    return '';
  }
  final candidates = _promptCoachCandidatesV1(
    context,
    question: question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  );
  return _pickDeterministicCoachLineV1(
    candidates,
    seed:
        'prompt|$lessonId|$beatIndex|${taskFamily?.name ?? 'none'}|$hasSeatTargets|$question',
  );
}

String act0RuntimeFeedbackCoachLineV1(
  BuildContext context, {
  required String authoredLine,
  required String title,
  required Act0FeedbackQualityV1 quality,
  required String variationSeed,
  Act0TaskFamilyV1? taskFamily,
}) {
  final localizedAuthored = act0RuntimeLocalizedGeneralLabelV1(
    context,
    authoredLine,
  ).trim();
  final normalizedAuthored = localizedAuthored.toLowerCase();
  final normalizedTitle = act0RuntimeLocalizedGeneralLabelV1(
    context,
    title,
  ).trim().toLowerCase();
  if (localizedAuthored.isNotEmpty &&
      normalizedAuthored != normalizedTitle &&
      !_isGenericFeedbackCoachLineV1(normalizedAuthored)) {
    return localizedAuthored;
  }
  final candidates = _feedbackCoachCandidatesV1(
    context,
    quality: quality,
    taskFamily: taskFamily,
  );
  return _pickDeterministicCoachLineV1(
    candidates,
    seed:
        'feedback|$variationSeed|${quality.name}|${taskFamily?.name ?? 'none'}',
  );
}

String act0RuntimeQuestionBadgeLabelV1(
  BuildContext context, {
  bool isTrailHistory = false,
}) {
  if (isTrailHistory) {
    final isRu = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ru');
    return isRu ? 'Hand history' : 'Hand history';
  }
  return act0RuntimeLocalizedGeneralLabelV1(context, 'Spot check');
}

String act0RuntimeTrailPromptSupportLineV1(
  BuildContext context, {
  required String currentStreetLabel,
  required String trailStreetLabel,
}) {
  final currentStreet = currentStreetLabel.trim().isEmpty
      ? ''
      : act0RuntimeLocalizedStreetLabelV1(context, currentStreetLabel.trim());
  final trailStreet = trailStreetLabel.trim().isEmpty
      ? ''
      : act0RuntimeLocalizedStreetLabelV1(context, trailStreetLabel.trim());
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  if (currentStreet.isNotEmpty &&
      trailStreet.isNotEmpty &&
      currentStreet.toLowerCase() != trailStreet.toLowerCase()) {
    return isRu
        ? 'Current street: $currentStreet - Previous action: $trailStreet'
        : 'Current street: $currentStreet - Previous action: $trailStreet';
  }
  return isRu ? 'Read the hand history.' : 'Read the hand history.';
}

String act0RuntimeTrailFeedbackContextLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Hand history' : 'Hand history';
}

String act0RuntimeNeutralBucketCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Bucket check' : 'Bucket check';
}

String act0RuntimeNeutralHandReadCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Hand read' : 'Hand read';
}

String act0RuntimeNeutralTableReadCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Table read' : 'Table read';
}

String act0RuntimeNeutralDecisionCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Decision spot' : 'Decision spot';
}

String act0RuntimeNeutralFacingPriceCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Facing price' : 'Facing price';
}

String act0RuntimeNeutralPotAndPriceCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Pot and price' : 'Pot and price';
}

String act0RuntimeNeutralSizingCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Sizing spot' : 'Sizing spot';
}

String act0RuntimeNeutralFacingActorCueLabelV1(
  BuildContext context, {
  required String actor,
  required String amount,
}) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Facing $actor $amount' : 'Facing $actor $amount';
}

String act0RuntimeLocalizedOptionLabelV1(BuildContext context, String label) =>
    act0RuntimeLocalizedGeneralLabelV1(context, label);

String act0RuntimeFeedbackSelectedLineV1(
  BuildContext context,
  String selectedLabel,
) {
  final prefix = act0RuntimeLocalizedGeneralLabelV1(context, 'You picked');
  return '$prefix ${act0RuntimeLocalizedGeneralLabelV1(context, selectedLabel)}';
}

String act0RuntimeFeedbackActionPrefixV1(
  BuildContext context,
  Act0FeedbackQualityV1 quality, {
  Act0TaskFamilyV1? taskFamily,
  bool hasSeatTargets = false,
}) {
  if (quality == Act0FeedbackQualityV1.wrong) {
    return act0RuntimeLocalizedGeneralLabelV1(context, 'Better option');
  }
  if (quality == Act0FeedbackQualityV1.suboptimal) {
    return act0RuntimeLocalizedGeneralLabelV1(context, 'Sharper line');
  }
  if (hasSeatTargets) {
    return act0RuntimeLocalizedGeneralLabelV1(context, 'Correct answer');
  }
  switch (taskFamily) {
    case Act0TaskFamilyV1.decision:
    case Act0TaskFamilyV1.sizing:
    case Act0TaskFamilyV1.repair:
      return act0RuntimeLocalizedGeneralLabelV1(context, 'Best play');
    case Act0TaskFamilyV1.transfer:
    case Act0TaskFamilyV1.review:
      return act0RuntimeLocalizedGeneralLabelV1(context, 'Clean read');
    case Act0TaskFamilyV1.learn:
    case Act0TaskFamilyV1.recognition:
    case Act0TaskFamilyV1.compare:
    case Act0TaskFamilyV1.counting:
      return act0RuntimeLocalizedGeneralLabelV1(context, 'Correct answer');
    case null:
      break;
  }
  return act0RuntimeLocalizedGeneralLabelV1(context, 'Best play');
}

String act0RuntimeLocalizedContextLabelV1(BuildContext context, String label) =>
    act0RuntimeLocalizedGeneralLabelV1(context, label);

String act0RuntimeLocalizedStreetLabelV1(BuildContext context, String label) {
  final atomId = act0RuntimeStreetLabelAtomByEnglishV1[label.trim()];
  if (atomId == null) {
    return label;
  }
  return act0LocalizedSurfaceAtomV1(context, atomId, fallback: label);
}

String act0RuntimeLocalizedCenterLabelV1(BuildContext context, String label) {
  final trimmed = label.trim();
  final atomId = act0RuntimeCenterLabelAtomByEnglishV1[trimmed];
  if (atomId == null) {
    return trimmed;
  }
  return act0LocalizedSurfaceAtomV1(context, atomId, fallback: trimmed);
}

bool _shouldKeepAuthoredCoachLineV1(String line) {
  final normalized = line.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }
  return !_genericCoachLineInputsV1.contains(normalized);
}

bool _isGenericFeedbackCoachLineV1(String line) {
  if (line.trim().isEmpty) {
    return true;
  }
  return _genericFeedbackCoachLineInputsV1.contains(line);
}

List<String> _theoryCoachCandidatesV1(
  BuildContext context, {
  required Act0TaskFamilyV1? taskFamily,
  required String prompt,
  required String supportLine,
}) {
  final normalizedPrompt = prompt.toLowerCase();
  final normalizedSupport = supportLine.toLowerCase();
  if (normalizedPrompt.contains('board') ||
      normalizedSupport.contains('board') ||
      normalizedSupport.contains('pot') ||
      normalizedSupport.contains('price')) {
    return <String>[
      _coachLineV1(
        context,
        en: 'Start with what is visible.',
        ru: 'Start with what is visible.',
      ),
      _coachLineV1(
        context,
        en: 'Board, price, then action.',
        ru: 'Board, price, then action.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then decide.',
        ru: 'One clean read, then decide.',
      ),
    ];
  }
  if (taskFamily == Act0TaskFamilyV1.counting ||
      normalizedPrompt.contains('count') ||
      normalizedPrompt.contains('how many')) {
    return <String>[
      _coachLineV1(
        context,
        en: 'Count what the table shows.',
        ru: 'Count what the table shows.',
      ),
      _coachLineV1(
        context,
        en: 'Start with what is visible.',
        ru: 'Start with what is visible.',
      ),
      _coachLineV1(
        context,
        en: 'Read once, then name it.',
        ru: 'Read once, then name it.',
      ),
    ];
  }
  return <String>[
    _coachLineV1(
      context,
      en: 'Read the table first.',
      ru: 'Read the table first.',
    ),
    _coachLineV1(
      context,
      en: 'Start with what is visible.',
      ru: 'Start with what is visible.',
    ),
    _coachLineV1(
      context,
      en: 'One clean read, then decide.',
      ru: 'One clean read, then decide.',
    ),
  ];
}

List<String> _promptCoachCandidatesV1(
  BuildContext context, {
  required String question,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final normalizedQuestion = question.toLowerCase();
  if (hasSeatTargets) {
    return <String>[
      _coachLineV1(
        context,
        en: 'Read the table, then tap one seat.',
        ru: 'Read the table, then tap one seat.',
      ),
      _coachLineV1(
        context,
        en: 'Find the seat, then choose.',
        ru: 'Find the seat, then choose.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then tap.',
        ru: 'One clean read, then tap.',
      ),
    ];
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      normalizedQuestion.contains('call') ||
      normalizedQuestion.contains('raise') ||
      normalizedQuestion.contains('fold')) {
    return <String>[
      _coachLineV1(
        context,
        en: 'Check the price before acting.',
        ru: 'Check the price before acting.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then choose.',
        ru: 'One clean read, then choose.',
      ),
      _coachLineV1(
        context,
        en: 'Start with the table, not memory.',
        ru: 'Start with the table, not memory.',
      ),
    ];
  }
  if (normalizedQuestion.contains('bucket') ||
      normalizedQuestion.contains('hand') ||
      normalizedQuestion.contains('board')) {
    return <String>[
      _coachLineV1(
        context,
        en: 'Use the board, not memory.',
        ru: 'Use the board, not memory.',
      ),
      _coachLineV1(
        context,
        en: 'Read the table first.',
        ru: 'Read the table first.',
      ),
      _coachLineV1(
        context,
        en: 'Start with what is visible.',
        ru: 'Start with what is visible.',
      ),
    ];
  }
  return <String>[
    _coachLineV1(
      context,
      en: 'Read the table first.',
      ru: 'Read the table first.',
    ),
    _coachLineV1(
      context,
      en: 'One clean read, then choose.',
      ru: 'One clean read, then choose.',
    ),
    _coachLineV1(
      context,
      en: 'Start with what is visible.',
      ru: 'Start with what is visible.',
    ),
  ];
}

List<String> _feedbackCoachCandidatesV1(
  BuildContext context, {
  required Act0FeedbackQualityV1 quality,
  required Act0TaskFamilyV1? taskFamily,
}) {
  switch (quality) {
    case Act0FeedbackQualityV1.correct:
      return <String>[
        _coachLineV1(context, en: 'Sharp read.', ru: 'Sharp read.'),
        _coachLineV1(context, en: 'Clean read.', ru: 'Clean read.'),
        _coachLineV1(context, en: 'Good table check.', ru: 'Good table check.'),
        if (taskFamily == Act0TaskFamilyV1.review ||
            taskFamily == Act0TaskFamilyV1.transfer)
          _coachLineV1(context, en: 'Keep that cue.', ru: 'Keep that cue.'),
      ];
    case Act0FeedbackQualityV1.suboptimal:
      return <String>[
        _coachLineV1(context, en: 'Good spot to fix.', ru: 'Good spot to fix.'),
        _coachLineV1(
          context,
          en: 'Slow down the cue.',
          ru: 'Slow down the cue.',
        ),
        _coachLineV1(context, en: 'One clean reread.', ru: 'One clean reread.'),
      ];
    case Act0FeedbackQualityV1.wrong:
      return <String>[
        _coachLineV1(context, en: 'Good spot to fix.', ru: 'Good spot to fix.'),
        _coachLineV1(
          context,
          en: 'This is repairable.',
          ru: 'This is repairable.',
        ),
        _coachLineV1(
          context,
          en: 'Use the table, then retry.',
          ru: 'Use the table, then retry.',
        ),
        _coachLineV1(context, en: 'One calm retry.', ru: 'One calm retry.'),
      ];
  }
}

String _pickDeterministicCoachLineV1(
  List<String> candidates, {
  required String seed,
}) {
  final usable = candidates.where((line) => line.trim().isNotEmpty).toList();
  if (usable.isEmpty) {
    return '';
  }
  final index = _deterministicCoachIndexV1(seed, usable.length);
  return usable[index];
}

int _deterministicCoachIndexV1(String seed, int length) {
  if (length <= 1) {
    return 0;
  }
  var hash = 17;
  for (final codeUnit in seed.codeUnits) {
    hash = 37 * hash + codeUnit;
  }
  return hash.abs() % length;
}

String _coachLineV1(
  BuildContext context, {
  required String en,
  required String ru,
}) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? ru : en;
}

const Set<String> _genericCoachLineInputsV1 = <String>{
  'read the table first',
  'one clear read, then one clear action.',
  'one clear read, then one clear action',
  'one clean read, then decide.',
  'one clean read, then decide',
  'start with what is visible.',
  'start with what is visible',
};

const Set<String> _genericFeedbackCoachLineInputsV1 = <String>{
  '',
  'sharp read.',
  'sharp read',
  'good spot to fix.',
  'good spot to fix',
  'clean read.',
  'clean read',
};

String act0RuntimeLocalizedPotLabelV1(BuildContext context, String label) {
  final match = RegExp(r'^Pot (.+)$').firstMatch(label.trim());
  if (match == null) {
    return label;
  }
  final prefix = act0LocalizedSurfaceAtomV1(
    context,
    'table_word_pot',
    fallback: 'Pot',
  );
  return '$prefix ${match.group(1)!}';
}

String act0RuntimeLocalizedToCallLabelV1(BuildContext context, String label) {
  final match = RegExp(r'^To call (.+)$').firstMatch(label.trim());
  if (match == null) {
    return label;
  }
  final prefix = act0LocalizedSurfaceAtomV1(
    context,
    'table_word_to_call',
    fallback: 'To call',
  );
  return '$prefix ${match.group(1)!}';
}

String act0RuntimeLocalizedSeatPrimaryLabelV1(
  BuildContext context, {
  required Act0SeatStateV1 seat,
  required bool hero,
  required bool refined,
  Act0TableIdentityPolicyV1 identityPolicy =
      Act0TableIdentityPolicyV1.currentProduction,
}) {
  if (!hero) {
    return seat.seatLabel;
  }
  final learner = act0LocalizedSurfaceAtomV1(
    context,
    'table_word_you',
    fallback: 'You',
  );
  if (identityPolicy == Act0TableIdentityPolicyV1.learnerOnly) {
    return learner;
  }
  if (identityPolicy == Act0TableIdentityPolicyV1.learnerPosition ||
      identityPolicy ==
          Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder) {
    final position = seat.seatLabel.trim();
    return position.isEmpty ? learner : position;
  }
  final heroLabel = act0LocalizedSurfaceAtomV1(
    context,
    'table_word_you',
    fallback: 'Hero',
  );
  return refined
      ? '${seat.seatLabel} $heroLabel'
      : '${seat.seatLabel}  $heroLabel';
}

String? act0RuntimeLocalizedSeatSubLabelV1(
  BuildContext context, {
  required bool hero,
  required bool active,
  required bool refined,
  required Act0SeatStateV1 seat,
}) {
  final explicitLabel =
      seat.currentBetLabel ?? seat.stackLabel ?? seat.blindAmountLabel;
  final toActAmountLabel = seat.currentBetLabel ?? seat.blindAmountLabel;
  if (!hero && active) {
    final toAct = act0LocalizedSurfaceAtomV1(
      context,
      'table_word_to_act',
      fallback: 'To act',
    );
    if (toActAmountLabel != null && toActAmountLabel.isNotEmpty) {
      return '$toAct: $toActAmountLabel';
    }
    return toAct;
  }
  if (explicitLabel != null && explicitLabel.isNotEmpty) {
    return explicitLabel;
  }
  if (refined && !hero) {
    if (seat.isDealerButton) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'table_word_dealer',
        fallback: 'Dealer',
      );
    }
    if (seat.isSmallBlind) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'table_word_small_blind',
        fallback: 'Small blind',
      );
    }
    if (seat.isBigBlind) {
      return act0LocalizedSurfaceAtomV1(
        context,
        'table_word_big_blind',
        fallback: 'Big blind',
      );
    }
  }
  return null;
}

String act0RuntimeLocalizedActionTrailLabelV1(
  BuildContext context,
  String label,
) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final streetPrefixed = RegExp(
    r'^(Preflop|Flop|Turn|River): (.+)$',
  ).firstMatch(trimmed);
  if (streetPrefixed != null) {
    final street = act0RuntimeLocalizedStreetLabelV1(
      context,
      streetPrefixed.group(1)!,
    );
    final fragment = _act0RuntimeLocalizedActionFragmentV1(
      context,
      streetPrefixed.group(2)!,
    );
    return '$street: $fragment';
  }

  if (trimmed == 'Flop dealt') {
    return act0LocalizedSurfaceAtomV1(
      context,
      'table_trail_flop_dealt',
      fallback: trimmed,
    );
  }

  return _act0RuntimeLocalizedActionFragmentV1(context, trimmed);
}

String act0RuntimeLocalizedLatestBadgeV1(BuildContext context) =>
    act0LocalizedSurfaceAtomV1(context, 'table_word_now', fallback: 'Now');

String act0RuntimeLocalizedGeneralLabelV1(BuildContext context, String label) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  final localeIsRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  final genericAtomId = act0RuntimeGenericLabelAtomByEnglishV1[trimmed];
  if (genericAtomId != null) {
    return act0LocalizedSurfaceAtomV1(
      context,
      genericAtomId,
      fallback: trimmed,
    );
  }

  if (trimmed.startsWith('Pot ')) {
    return act0RuntimeLocalizedPotLabelV1(context, trimmed);
  }
  if (trimmed.startsWith('To call ')) {
    return act0RuntimeLocalizedToCallLabelV1(context, trimmed);
  }
  if (act0RuntimeStreetLabelAtomByEnglishV1.containsKey(trimmed)) {
    return act0RuntimeLocalizedStreetLabelV1(context, trimmed);
  }
  if (act0RuntimeCenterLabelAtomByEnglishV1.containsKey(trimmed)) {
    return act0RuntimeLocalizedCenterLabelV1(context, trimmed);
  }

  final comboMatch = RegExp(r'^(\d+) combos$').firstMatch(trimmed);
  if (comboMatch != null && localeIsRu) {
    final count = int.tryParse(comboMatch.group(1)!) ?? 0;
    return '${comboMatch.group(1)!} ${_act0RuCombosWordV1(count)}';
  }

  final maxPlayersMatch = RegExp(r'^(\d+)-max$').firstMatch(trimmed);
  if (maxPlayersMatch != null && localeIsRu) {
    return '${maxPlayersMatch.group(1)!}-max';
  }

  final effectiveStackMatch = RegExp(
    r'^(\d+(\.\d+)?) BB effective stack$',
  ).firstMatch(trimmed);
  if (effectiveStackMatch != null) {
    final prefix = act0LocalizedSurfaceAtomV1(
      context,
      'table_center_effective_stack',
      fallback: 'Effective stack',
    );
    return '$prefix ${effectiveStackMatch.group(1)!} BB';
  }

  final tableReadMatch = RegExp(
    r'^(\d+) private cards, (\d+) board cards, (.+) in the pot$',
  ).firstMatch(trimmed);
  if (tableReadMatch != null) {
    final privateCards = tableReadMatch.group(1)!;
    final boardCards = tableReadMatch.group(2)!;
    final potAmount = tableReadMatch.group(3)!;
    if (!localeIsRu) {
      return '$privateCards private cards, $boardCards board cards, $potAmount in the pot';
    }
    return '$privateCards private cards, $boardCards board cards, $potAmount in the pot';
  }

  final handsMatch = RegExp(r'^([A-Z0-9+]+|Hero) acts$').firstMatch(trimmed);
  if (handsMatch != null ||
      trimmed.contains(' blind ') ||
      trimmed.contains(' opens ') ||
      trimmed.contains(' raises ') ||
      trimmed.contains(' bets ') ||
      trimmed.contains(' calls ') ||
      trimmed.contains(' folds') ||
      trimmed.contains(' checks')) {
    return act0RuntimeLocalizedActionTrailLabelV1(context, trimmed);
  }

  return trimmed;
}

String _act0RuntimeLocalizedActionFragmentV1(
  BuildContext context,
  String fragment,
) {
  final blindMatch = RegExp(r'^(SB|BB) blind (.+)$').firstMatch(fragment);
  if (blindMatch != null) {
    return '${blindMatch.group(1)!} ${_act0SurfaceWordV1(context, 'table_word_blind', 'blind')} ${blindMatch.group(2)!}';
  }

  final actsMatch = RegExp(r'^([A-Z0-9+]+|Hero) acts$').firstMatch(fragment);
  if (actsMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, actsMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_acts', 'acts')}';
  }

  final opensMatch = RegExp(
    r'^([A-Z0-9+]+|Hero) opens (.+)$',
  ).firstMatch(fragment);
  if (opensMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, opensMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_opens', 'opens')} ${opensMatch.group(2)!}';
  }

  final betsMatch = RegExp(
    r'^([A-Z0-9+]+|Hero) bets (.+)$',
  ).firstMatch(fragment);
  if (betsMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, betsMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_bets', 'bets')} ${betsMatch.group(2)!}';
  }

  final callsMatch = RegExp(
    r'^([A-Z0-9+]+|Hero) calls (.+)$',
  ).firstMatch(fragment);
  if (callsMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, callsMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_calls', 'calls')} ${callsMatch.group(2)!}';
  }

  final raisesMatch = RegExp(
    r'^([A-Z0-9+]+|Hero) raises (.+)$',
  ).firstMatch(fragment);
  if (raisesMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, raisesMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_raises', 'raises')} ${raisesMatch.group(2)!}';
  }

  final checksMatch = RegExp(
    r'^([A-Z0-9+]+|Hero) checks$',
  ).firstMatch(fragment);
  if (checksMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, checksMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_checks', 'checks')}';
  }

  final foldsMatch = RegExp(r'^([A-Z0-9+]+|Hero) folds$').firstMatch(fragment);
  if (foldsMatch != null) {
    return '${_act0RuntimeLocalizedActorV1(context, foldsMatch.group(1)!)} ${_act0SurfaceWordV1(context, 'table_word_folds', 'folds')}';
  }

  return fragment;
}

String _act0RuntimeLocalizedActorV1(BuildContext context, String actor) {
  if (actor != 'Hero') {
    return actor;
  }
  return act0LocalizedSurfaceAtomV1(context, 'table_word_you', fallback: actor);
}

String _act0SurfaceWordV1(
  BuildContext context,
  String atomId,
  String fallback,
) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

String _act0RuCombosWordV1(int count) {
  final mod100 = count % 100;
  final mod10 = count % 10;
  if (mod100 >= 11 && mod100 <= 14) {
    return 'combos';
  }
  if (mod10 == 1) {
    return 'combo';
  }
  if (mod10 >= 2 && mod10 <= 4) {
    return 'combos';
  }
  return 'combos';
}

// Academy-only locale projection. The legacy context helpers deliberately
// select EN for table consumers; use the existing ID bundles explicitly here.
String act0AcademyLanguageV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String act0AcademySurfaceAtomV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomByIdV1(
  atomId,
  fallback: fallback,
  languageCode: act0AcademyLanguageV1(context),
);

String act0AcademyWorldTitleV1(BuildContext context, Act0WorldCardV1 world) =>
    act0LocalizedWorldTitleAtomV1(
      world.worldId,
      fallback: world.title,
      languageCode: act0AcademyLanguageV1(context),
    );
String act0AcademyWorldSubtitleV1(
  BuildContext context,
  Act0WorldCardV1 world,
) => act0LocalizedWorldSubtitleAtomV1(
  world.worldId,
  fallback: world.subtitle,
  languageCode: act0AcademyLanguageV1(context),
);

String act0AcademyLessonTitleV1(BuildContext context, Act0LessonCardV1 lesson) {
  // This stable ID now names First Table Guide, not the older poker lesson.
  if (act0AcademyLanguageV1(context) == 'ru' &&
      lesson.lessonId == 'what_poker_is')
    return '\u041f\u0435\u0440\u0432\u044b\u0439 \u0440\u0430\u0437\u0431\u043e\u0440 \u0441\u0442\u043e\u043b\u0430';
  return act0LocalizedLessonTitleAtomByIdV1(
    lesson.lessonId,
    fallback: lesson.title,
    languageCode: act0AcademyLanguageV1(context),
  );
}

String act0AcademyLessonSubtitleV1(
  BuildContext context,
  Act0LessonCardV1 lesson,
) {
  if (act0AcademyLanguageV1(context) == 'ru' &&
      lesson.lessonId == 'what_poker_is')
    return '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u0439 \u0441\u0442\u043e\u043b, \u043e\u0442\u0432\u0435\u0442\u044c \u043e\u0434\u0438\u043d \u0440\u0430\u0437 \u0438 \u0443\u0437\u043d\u0430\u0439 \u043f\u0440\u0438\u0447\u0438\u043d\u0443.';
  return act0LocalizedLessonSubtitleAtomByIdV1(
    lesson.lessonId,
    fallback: lesson.subtitle,
    languageCode: act0AcademyLanguageV1(context),
  );
}

String act0AcademyTaskTitleV1(BuildContext context, Act0LessonTaskV1 task) =>
    act0LocalizedTaskTitleAtomByIdV1(
      task.taskId,
      fallback: task.title,
      languageCode: act0AcademyLanguageV1(context),
    );
String act0AcademyTaskSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.summary ?? '',
  languageCode: act0AcademyLanguageV1(context),
);
String act0AcademyTaskLockedSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskLockedSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.lockedSummary ?? '',
  languageCode: act0AcademyLanguageV1(context),
);

// An exact presentation format produced by the World progress projection.
// Unknown labels are preserved; never infer progress or translate identifiers.
String act0AcademyProgressLabelV1(BuildContext context, String label) {
  if (act0AcademyLanguageV1(context) != 'ru') return label;
  final match = RegExp(
    r'^(\d+) of (\d+) lessons( complete)?$',
  ).firstMatch(label);
  if (match == null) return label;
  return '\u0423\u0440\u043e\u043a\u0438: ${match[1]} \u0438\u0437 ${match[2]}' +
      (match[3] == null
          ? ''
          : ' \u0437\u0430\u0432\u0435\u0440\u0448\u0435\u043d\u043e');
}

String act0AcademyNavLabelV1(BuildContext context, Act0ShellTabV1 tab) {
  final ru = act0AcademyLanguageV1(context) == 'ru';
  return switch (tab) {
    Act0ShellTabV1.home =>
      ru ? '\u0413\u043b\u0430\u0432\u043d\u0430\u044f' : 'Home',
    Act0ShellTabV1.learn => ru ? '\u0423\u0447\u0451\u0431\u0430' : 'Learn',
    Act0ShellTabV1.play =>
      ru ? '\u041f\u0440\u0430\u043a\u0442\u0438\u043a\u0430' : 'Practice',
    Act0ShellTabV1.review =>
      ru ? '\u0420\u0430\u0437\u0431\u043e\u0440' : 'Review',
    Act0ShellTabV1.profile =>
      ru ? '\u041f\u0440\u043e\u0444\u0438\u043b\u044c' : 'You',
  };
}

// Current authored First Table Guide beats supersede the older task-ID copy.
// Match the runner identity AND the exact source strings, so source revisions
// fail back to authored text instead of silently attaching a stale translation.
String act0AcademyTeachingCopyV1(
  BuildContext context, {
  required String runnerLessonId,
  required String source,
  required String fallback,
}) {
  if (act0AcademyLanguageV1(context) != 'ru') return source;
  final copy = _firstValueTeachingRuV1[runnerLessonId];
  return copy == null ? fallback : copy[source] ?? source;
}

const _firstValueTeachingRuV1 = <String, Map<String, String>>{
  'first_table_guide_meet_table': {
    'One loop first.':
        '\u0421\u043d\u0430\u0447\u0430\u043b\u0430 \u043e\u0434\u0438\u043d \u0443\u0447\u0435\u0431\u043d\u044b\u0439 \u0446\u0438\u043a\u043b.',
    'Read one table spot, answer once, then see the exact reason.':
        '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u0439 \u043e\u0434\u043d\u0443 \u0441\u0438\u0442\u0443\u0430\u0446\u0438\u044e \u0437\u0430 \u0441\u0442\u043e\u043b\u043e\u043c, \u043e\u0442\u0432\u0435\u0442\u044c \u043e\u0434\u0438\u043d \u0440\u0430\u0437 \u0438 \u0443\u0437\u043d\u0430\u0439 \u0442\u043e\u0447\u043d\u0443\u044e \u043f\u0440\u0438\u0447\u0438\u043d\u0443.',
    'Start with the table.':
        '\u041d\u0430\u0447\u043d\u0438 \u0441\u043e \u0441\u0442\u043e\u043b\u0430.',
    "You marks the learner. BTN is this hand's position and can change next hand. SB and BB post the blinds.":
        '\u041c\u0435\u0442\u043a\u0430 You \u043e\u0431\u043e\u0437\u043d\u0430\u0447\u0430\u0435\u0442 \u0442\u0435\u0431\u044f. BTN \u2014 \u043f\u043e\u0437\u0438\u0446\u0438\u044f \u0432 \u044d\u0442\u043e\u0439 \u0440\u0430\u0437\u0434\u0430\u0447\u0435; \u0432 \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0435\u0439 \u043e\u043d\u0430 \u043c\u043e\u0436\u0435\u0442 \u0438\u0437\u043c\u0435\u043d\u0438\u0442\u044c\u0441\u044f. SB \u0438 BB \u0441\u0442\u0430\u0432\u044f\u0442 \u0431\u043b\u0430\u0439\u043d\u0434\u044b.',
  },
  'first_table_guide_find_hero': {
    'You means learner.':
        'You \u043e\u0431\u043e\u0437\u043d\u0430\u0447\u0430\u0435\u0442 \u0442\u0435\u0431\u044f.',
    'The You badge marks your seat. BTN is a position, so You can be at a different position on another hand.':
        '\u041c\u0435\u0442\u043a\u0430 You \u043e\u0431\u043e\u0437\u043d\u0430\u0447\u0430\u0435\u0442 \u0442\u0432\u043e\u0451 \u043c\u0435\u0441\u0442\u043e. BTN \u2014 \u043f\u043e\u0437\u0438\u0446\u0438\u044f: \u0432 \u0434\u0440\u0443\u0433\u043e\u0439 \u0440\u0430\u0437\u0434\u0430\u0447\u0435 \u0442\u044b \u043c\u043e\u0436\u0435\u0448\u044c \u043e\u043a\u0430\u0437\u0430\u0442\u044c\u0441\u044f \u043d\u0430 \u0434\u0440\u0443\u0433\u043e\u0439 \u043f\u043e\u0437\u0438\u0446\u0438\u0438.',
  },
  'first_table_guide_read_table': {
    'Carry the first table scan.':
        '\u041f\u043e\u0432\u0442\u043e\u0440\u0438 \u043f\u0435\u0440\u0432\u044b\u0439 \u043e\u0441\u043c\u043e\u0442\u0440 \u0441\u0442\u043e\u043b\u0430.',
    'Real tables use the same simple scan.\n\nFind your two cards and the shared board.\n\nThen check how many chips are already in the pot.':
        '\u0417\u0430 \u043d\u0430\u0441\u0442\u043e\u044f\u0449\u0438\u043c \u0441\u0442\u043e\u043b\u043e\u043c \u043d\u0443\u0436\u0435\u043d \u0442\u043e\u0442 \u0436\u0435 \u043f\u0440\u043e\u0441\u0442\u043e\u0439 \u043e\u0441\u043c\u043e\u0442\u0440.\n\n\u041d\u0430\u0439\u0434\u0438 \u0434\u0432\u0435 \u043b\u0438\u0447\u043d\u044b\u0435 \u043a\u0430\u0440\u0442\u044b \u0438 \u043e\u0431\u0449\u0438\u0435 \u043a\u0430\u0440\u0442\u044b \u0431\u043e\u0440\u0434\u0430.\n\n\u0417\u0430\u0442\u0435\u043c \u043f\u0440\u043e\u0432\u0435\u0440\u044c, \u0441\u043a\u043e\u043b\u044c\u043a\u043e \u0444\u0438\u0448\u0435\u043a \u0443\u0436\u0435 \u0432 \u0431\u0430\u043d\u043a\u0435.',
  },
  'first_table_guide_one_clear_choice': {
    'Same scan, simpler job.':
        '\u0422\u043e\u0442 \u0436\u0435 \u043e\u0441\u043c\u043e\u0442\u0440, \u043f\u0440\u043e\u0441\u0442\u0430\u044f \u0437\u0430\u0434\u0430\u0447\u0430.',
    'Preflop means no board yet. Read You, blinds, pot, and who acts next. Name the setup once.':
        '\u041f\u0440\u0435\u0444\u043b\u043e\u043f \u043e\u0437\u043d\u0430\u0447\u0430\u0435\u0442, \u0447\u0442\u043e \u0431\u043e\u0440\u0434\u0430 \u0435\u0449\u0451 \u043d\u0435\u0442. \u041d\u0430\u0439\u0434\u0438 \u0441\u0432\u043e\u0451 \u043c\u0435\u0441\u0442\u043e, \u0431\u043b\u0430\u0439\u043d\u0434\u044b, \u0431\u0430\u043d\u043a \u0438 \u0442\u043e\u0433\u043e, \u043a\u0442\u043e \u0434\u0435\u0439\u0441\u0442\u0432\u0443\u0435\u0442 \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0438\u043c. \u041d\u0430\u0437\u043e\u0432\u0438 \u0441\u0438\u0442\u0443\u0430\u0446\u0438\u044e.',
  },
  'first_table_guide_route_roles': {
    'Know the five jobs.':
        '\u041f\u044f\u0442\u044c \u0440\u0430\u0437\u0434\u0435\u043b\u043e\u0432, \u043f\u044f\u0442\u044c \u0437\u0430\u0434\u0430\u0447.',
    'Home shows what to do now. Learn shows what to study next. Practice gives extra reps. Review fixes mistakes. You shows progress and settings.':
        '\u0413\u043b\u0430\u0432\u043d\u0430\u044f \u043f\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442, \u0447\u0442\u043e \u0434\u0435\u043b\u0430\u0442\u044c \u0441\u0435\u0439\u0447\u0430\u0441. \u0423\u0447\u0451\u0431\u0430 \u2014 \u0447\u0442\u043e \u0438\u0437\u0443\u0447\u0430\u0442\u044c \u0434\u0430\u043b\u044c\u0448\u0435. \u041f\u0440\u0430\u043a\u0442\u0438\u043a\u0430 \u0434\u0430\u0451\u0442 \u0434\u043e\u043f\u043e\u043b\u043d\u0438\u0442\u0435\u043b\u044c\u043d\u044b\u0435 \u043f\u043e\u043f\u044b\u0442\u043a\u0438. \u0420\u0430\u0437\u0431\u043e\u0440 \u043f\u043e\u043c\u043e\u0433\u0430\u0435\u0442 \u0438\u0441\u043f\u0440\u0430\u0432\u043b\u044f\u0442\u044c \u043e\u0448\u0438\u0431\u043a\u0438. \u041f\u0440\u043e\u0444\u0438\u043b\u044c \u043f\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442 \u043f\u0440\u043e\u0433\u0440\u0435\u0441\u0441 \u0438 \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438.',
  },
};
