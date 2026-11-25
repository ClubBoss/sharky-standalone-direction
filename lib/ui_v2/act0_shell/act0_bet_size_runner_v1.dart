import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_shell_state_v1.dart';

/// Turns authored pot fractions into an answer control without changing the
/// source choice IDs, grading, or purpose feedback.
class Act0BetSizeRunnerV1 {
  const Act0BetSizeRunnerV1._(this.potBb, this.options, this.presets);

  final double potBb;
  final List<Act0RunnerOptionV1> options;
  final List<Act0SizingPresetV1> presets;

  double amountBb(Act0SizingPresetV1 preset) => potBb * preset.potFraction;

  static Act0BetSizeRunnerV1? fromTask(
    Act0LessonTaskV1 task,
    Act0TableStateV1 table,
  ) {
    final fractions = task.betSize?.fractions;
    final ledger = table.handContributions;
    final authored = task.runner.options;
    if (fractions == null ||
        fractions.length < 3 ||
        fractions.length > 4 ||
        authored.length != fractions.length ||
        authored.map((option) => option.id).toSet().length != authored.length ||
        ledger == null ||
        ledger.fromStreet != PokerStreet.preflop) {
      return null;
    }

    final best = authored.where(
      (option) => option.quality == Act0FeedbackQualityV1.correct,
    );
    // Existing tasks need not author a near-correct size. Never invent one.
    if (best.length != 1 || !authored.any((o) => !o.quality.passes)) {
      return null;
    }
    final ({double potBb, double? toCallBb}) amounts;
    try {
      amounts = ledger.amounts(
        actorSeatId: table.decisionActorSeatId,
        seatIds: {
          for (final seat in table.seats)
            if (seat.isOccupied) seat.seatId,
        },
      );
    } on FormatException {
      return null;
    }
    final pot = amounts.potBb;
    if (!pot.isFinite || pot <= 0 || amounts.toCallBb != 0) return null;

    final presets = <Act0SizingPresetV1>[];
    final seenFractions = <double>{};
    for (final option in authored) {
      final fraction = fractions[option.id];
      if (fraction == null ||
          fraction.numerator < 0 ||
          (fraction.numerator == 0) !=
              (option.id == 'check' && option.label.toLowerCase() == 'check') ||
          fraction.denominator <= 0 ||
          option.seatId != null ||
          option.feedbackReason.trim().isEmpty ||
          option.isCorrect != option.quality.passes ||
          !const {
            Act0FeedbackQualityV1.correct,
            Act0FeedbackQualityV1.acceptable,
            Act0FeedbackQualityV1.suboptimal,
            Act0FeedbackQualityV1.wrong,
          }.contains(option.quality)) {
        return null;
      }
      final ratio = fraction.numerator / fraction.denominator;
      final bb = pot * ratio;
      if (!bb.isFinite || bb < 0 || !seenFractions.add(ratio)) return null;
      final isCheck = fraction.numerator == 0;
      final fractionLabel = isCheck
          ? 'Check'
          : fraction.denominator == 1
          ? '${fraction.numerator} pot'
          : '${fraction.numerator}/${fraction.denominator} pot';
      final rounded = bb.toStringAsFixed(2);
      final bbLabel = rounded.replaceFirst(RegExp(r'\.?0+$'), '');
      final approx = (double.parse(rounded) - bb).abs() > 1e-9 ? '≈' : '';
      presets.add(
        Act0SizingPresetV1(
          id: option.id,
          label: '$fractionLabel · $approx$bbLabel BB',
          semanticLabel:
              '${isCheck ? 'Check, zero' : _spokenFraction(fraction)} of the pot, ${approx.isEmpty ? '' : 'approximately '}$bbLabel ${bb == 1 ? 'big blind' : 'big blinds'}',
          potFraction: ratio,
          isPrimary: option.quality == Act0FeedbackQualityV1.correct,
        ),
      );
    }
    final primary = presets.singleWhere((preset) => preset.isPrimary);
    final preferred = primary.id == 'check' ? 'Check' : primary.label;
    return Act0BetSizeRunnerV1._(pot, [
      for (var i = 0; i < authored.length; i++)
        Act0RunnerOptionV1(
          id: authored[i].id,
          label: authored[i].id == 'check'
              ? authored[i].label
              : presets[i].label,
          isCorrect: authored[i].isCorrect,
          preferredLabel: preferred,
          quality: authored[i].quality,
          feedbackTitle: authored[i].feedbackTitle,
          feedbackReason: authored[i].feedbackReason,
          repairFocusSeatIds: authored[i].repairFocusSeatIds,
          repairFocusCardIds: authored[i].repairFocusCardIds,
          repairFocusLabels: authored[i].repairFocusLabels,
        ),
    ], List.unmodifiable(presets));
  }

  static String _spokenFraction(({int numerator, int denominator}) fraction) =>
      switch ((fraction.numerator, fraction.denominator)) {
        (1, 1) => 'all',
        (1, 2) => 'one half',
        (1, 3) => 'one third',
        (1, 4) => 'one quarter',
        (1, 6) => 'one sixth',
        (3, 2) => 'one and a half',
        _ => '${fraction.numerator} over ${fraction.denominator}',
      };

  Act0RunnerStateV1 project(Act0RunnerStateV1 source) => source.copyWith(
    options: options,
    sizingConfig: source.phase == Act0LessonPhaseV1.drill
        ? Act0SizingConfigV1(
            mode: Act0SizingUiModeV1.presetsOnly,
            presets: presets,
            showGuidance: false,
          )
        : const Act0SizingConfigV1.disabled(),
  );
}

/// OFF is an identity projection, even when a task has authored fractions.
/// Theory, diagnostics and multi-street tasks retain their existing path.
({Act0RunnerStateV1 runner, bool active}) act0ProjectBetSizeV1({
  required bool enabled,
  required Act0LessonTaskV1 task,
  required Act0RunnerStateV1 source,
}) {
  if (!enabled ||
      source.hideTable ||
      source.phase == Act0LessonPhaseV1.theory ||
      task.multiStreet != null) {
    return (runner: source, active: false);
  }
  final entry = Act0BetSizeRunnerV1.fromTask(task, source.table);
  return entry == null
      ? (runner: source, active: false)
      : (runner: entry.project(source), active: true);
}
