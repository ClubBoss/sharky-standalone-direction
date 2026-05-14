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
  required bool hasSeatTargets,
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
    return act0LocalizedSurfaceAtomV1(
      context,
      'runner_task_choose_best_action',
      fallback: 'Choose the best action',
    );
  }
  return '';
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

String act0RuntimeQuestionBadgeLabelV1(BuildContext context) =>
    act0RuntimeLocalizedGeneralLabelV1(context, 'Spot check');

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
  Act0FeedbackQualityV1 quality,
) {
  if (quality == Act0FeedbackQualityV1.wrong) {
    return act0RuntimeLocalizedGeneralLabelV1(context, 'Better option');
  }
  if (quality == Act0FeedbackQualityV1.suboptimal) {
    return act0RuntimeLocalizedGeneralLabelV1(context, 'Sharper line');
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
