import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_phrase_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

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
    'what should',
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
  return isRu ? 'Проверь историю раздачи' : 'Read what happened';
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
  return isRu ? 'Повторить идею' : 'Review idea';
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
    return isRu ? 'История раздачи' : 'Hand history';
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
        ? 'Сейчас на столе: $currentStreet · В истории: $trailStreet'
        : 'Current street: $currentStreet · Previous action: $trailStreet';
  }
  return isRu ? 'Смотри историю раздачи.' : 'Read the hand history.';
}

String act0RuntimeTrailFeedbackContextLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'История раздачи' : 'Hand history';
}

String act0RuntimeNeutralBucketCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Проверка группы' : 'Bucket check';
}

String act0RuntimeNeutralHandReadCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Чтение руки' : 'Hand read';
}

String act0RuntimeNeutralTableReadCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Чтение стола' : 'Table read';
}

String act0RuntimeNeutralDecisionCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Решение' : 'Decision spot';
}

String act0RuntimeNeutralFacingPriceCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Цена колла' : 'Facing price';
}

String act0RuntimeNeutralPotAndPriceCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Банк и цена' : 'Pot and price';
}

String act0RuntimeNeutralSizingCueLabelV1(BuildContext context) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Размер ставки' : 'Sizing spot';
}

String act0RuntimeNeutralFacingActorCueLabelV1(
  BuildContext context, {
  required String actor,
  required String amount,
}) {
  final isRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  return isRu ? 'Против $actor $amount' : 'Facing $actor $amount';
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
        ru: 'Сначала смотри на то, что видно.',
      ),
      _coachLineV1(
        context,
        en: 'Board, price, then action.',
        ru: 'Сначала борд, цена, потом действие.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then decide.',
        ru: 'Одно чистое чтение, потом решение.',
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
        ru: 'Считай то, что показывает стол.',
      ),
      _coachLineV1(
        context,
        en: 'Start with what is visible.',
        ru: 'Сначала смотри на то, что видно.',
      ),
      _coachLineV1(
        context,
        en: 'Read once, then name it.',
        ru: 'Сначала прочитай, потом назови.',
      ),
    ];
  }
  return <String>[
    _coachLineV1(
      context,
      en: 'Read the table first.',
      ru: 'Сначала прочитай стол.',
    ),
    _coachLineV1(
      context,
      en: 'Start with what is visible.',
      ru: 'Сначала смотри на то, что видно.',
    ),
    _coachLineV1(
      context,
      en: 'One clean read, then decide.',
      ru: 'Одно чистое чтение, потом решение.',
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
        ru: 'Сначала прочитай стол, потом нажми на одно место.',
      ),
      _coachLineV1(
        context,
        en: 'Find the seat, then choose.',
        ru: 'Сначала найди место, потом выбери.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then tap.',
        ru: 'Одно чистое чтение, потом нажми.',
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
        ru: 'Сначала проверь цену решения.',
      ),
      _coachLineV1(
        context,
        en: 'One clean read, then choose.',
        ru: 'Одно чистое чтение, потом выбор.',
      ),
      _coachLineV1(
        context,
        en: 'Start with the table, not memory.',
        ru: 'Сначала стол, а не память.',
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
        ru: 'Смотри на борд, а не на память.',
      ),
      _coachLineV1(
        context,
        en: 'Read the table first.',
        ru: 'Сначала прочитай стол.',
      ),
      _coachLineV1(
        context,
        en: 'Start with what is visible.',
        ru: 'Сначала смотри на то, что видно.',
      ),
    ];
  }
  return <String>[
    _coachLineV1(
      context,
      en: 'Read the table first.',
      ru: 'Сначала прочитай стол.',
    ),
    _coachLineV1(
      context,
      en: 'One clean read, then choose.',
      ru: 'Одно чистое чтение, потом выбор.',
    ),
    _coachLineV1(
      context,
      en: 'Start with what is visible.',
      ru: 'Сначала смотри на то, что видно.',
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
        _coachLineV1(context, en: 'Sharp read.', ru: 'Хорошее чтение.'),
        _coachLineV1(context, en: 'Clean read.', ru: 'Чистое чтение.'),
        _coachLineV1(
          context,
          en: 'Good table check.',
          ru: 'Хорошая проверка стола.',
        ),
        if (taskFamily == Act0TaskFamilyV1.review ||
            taskFamily == Act0TaskFamilyV1.transfer)
          _coachLineV1(
            context,
            en: 'Keep that cue.',
            ru: 'Сохрани эту подсказку.',
          ),
      ];
    case Act0FeedbackQualityV1.suboptimal:
      return <String>[
        _coachLineV1(context, en: 'Good spot to fix.', ru: 'Полезный разбор.'),
        _coachLineV1(
          context,
          en: 'Slow down the cue.',
          ru: 'Замедлись и проверь подсказку.',
        ),
        _coachLineV1(
          context,
          en: 'One clean reread.',
          ru: 'Ещё одно чистое перечитывание.',
        ),
      ];
    case Act0FeedbackQualityV1.wrong:
      return <String>[
        _coachLineV1(context, en: 'Good spot to fix.', ru: 'Полезный разбор.'),
        _coachLineV1(
          context,
          en: 'This is repairable.',
          ru: 'Это легко починить.',
        ),
        _coachLineV1(
          context,
          en: 'Use the table, then retry.',
          ru: 'Вернись к столу и попробуй снова.',
        ),
        _coachLineV1(
          context,
          en: 'One calm retry.',
          ru: 'Одна спокойная попытка ещё раз.',
        ),
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
}) {
  if (!hero) {
    return seat.seatLabel;
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
    return '${maxPlayersMatch.group(1)!}-макс';
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
    return '$privateCards закрытые карты, $boardCards общие карты, в банке $potAmount';
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
    return 'комбинаций';
  }
  if (mod10 == 1) {
    return 'комбинация';
  }
  if (mod10 >= 2 && mod10 <= 4) {
    return 'комбинации';
  }
  return 'комбинаций';
}
