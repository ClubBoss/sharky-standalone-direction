import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

enum PersonalizedNextActionV1 {
  reviewFocus,
  repeatPack,
  continueCampaign,
  nextModule,
}

class RecentTelemetrySignalV1 {
  const RecentTelemetrySignalV1({required this.name, required this.payload});

  final String name;
  final Map<String, Object?> payload;
}

class PersonalizedRecommendationV1 {
  const PersonalizedRecommendationV1({
    required this.recommendedFocusId,
    required this.reasonCode,
    required this.shortHintText,
    required this.recommendedNextAction,
    required this.recommendedNextSessionTarget,
  });

  final String recommendedFocusId;
  final String reasonCode;
  final String shortHintText;
  final PersonalizedNextActionV1 recommendedNextAction;
  final String recommendedNextSessionTarget;

  @override
  bool operator ==(Object other) {
    return other is PersonalizedRecommendationV1 &&
        other.recommendedFocusId == recommendedFocusId &&
        other.reasonCode == reasonCode &&
        other.shortHintText == shortHintText &&
        other.recommendedNextAction == recommendedNextAction &&
        other.recommendedNextSessionTarget == recommendedNextSessionTarget;
  }

  @override
  int get hashCode => Object.hash(
    recommendedFocusId,
    reasonCode,
    shortHintText,
    recommendedNextAction,
    recommendedNextSessionTarget,
  );
}

class RecentActivityPersonalizationInputV1 {
  const RecentActivityPersonalizationInputV1({
    required this.signals,
    required this.isCampaignSession,
    this.moduleId,
    this.mode,
    this.latestOutcomeSummary,
  });

  final Iterable<RecentTelemetrySignalV1> signals;
  final bool isCampaignSession;
  final String? moduleId;
  final String? mode;
  final OutcomeSummaryV1? latestOutcomeSummary;
}

class RecentActivityPersonalizationV1 {
  RecentActivityPersonalizationV1._();

  static const int _recentDecisionWindow = 8;
  static const int _slowDecisionThresholdMs = 4500;

  static PersonalizedRecommendationV1? infer(
    RecentActivityPersonalizationInputV1 input,
  ) {
    final decisions = _collectRecentDecisions(input);
    if (decisions.isEmpty && input.latestOutcomeSummary == null) {
      return null;
    }

    final dominantChoiceFamily = _dominantChoiceFamily(decisions);
    final repeatedError = _strongestRepeatedError(decisions);
    if (repeatedError != null) {
      final focusId = _focusForSignal(
        errorType: repeatedError.errorType,
        choiceFamily: dominantChoiceFamily,
      );
      return PersonalizedRecommendationV1(
        recommendedFocusId: focusId,
        reasonCode: repeatedError.includesSlowMistake
            ? 'slow_incorrect_decision'
            : 'repeated_error_type',
        shortHintText: _hintForPattern(
          focusId: focusId,
          errorType: repeatedError.errorType,
          choiceFamily: dominantChoiceFamily,
          pattern: _HintPatternV1.repeatedError,
          repeatedCount: repeatedError.count,
          includesSlowMistake: repeatedError.includesSlowMistake,
        ),
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: recommendedModuleIdForFocus(
          focusLabel: focusId,
          reviewDue: false,
        ),
      );
    }

    final slowSuccessCount = decisions
        .where(
          (decision) =>
              decision.correct == true &&
              (decision.timeToDecisionMs ?? 0) >= _slowDecisionThresholdMs,
        )
        .length;
    if (slowSuccessCount >= 2) {
      final focusId = dominantChoiceFamily == _ChoiceFamilyV1.action
          ? 'initiative'
          : 'action_order';
      return PersonalizedRecommendationV1(
        recommendedFocusId: focusId,
        reasonCode: dominantChoiceFamily == _ChoiceFamilyV1.action
            ? 'slow_action_decisions'
            : 'slow_seat_decisions',
        shortHintText: _hintForPattern(
          focusId: focusId,
          errorType: null,
          choiceFamily: dominantChoiceFamily,
          pattern: _HintPatternV1.slowCorrect,
          slowCount: slowSuccessCount,
        ),
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: recommendedModuleIdForFocus(
          focusLabel: focusId,
          reviewDue: false,
        ),
      );
    }

    final outcomeSummary = input.latestOutcomeSummary;
    if (outcomeSummary != null &&
        outcomeSummary.outcomeKind == OutcomeKindV1.mistake) {
      final focusId = _focusForSignal(
        errorType: outcomeSummary.errorType,
        choiceFamily: dominantChoiceFamily,
      );
      return PersonalizedRecommendationV1(
        recommendedFocusId: focusId,
        reasonCode: 'latest_mistake_followup',
        shortHintText: _hintForPattern(
          focusId: focusId,
          errorType: outcomeSummary.errorType,
          choiceFamily: dominantChoiceFamily,
          pattern: _HintPatternV1.latestMistake,
        ),
        recommendedNextAction: input.isCampaignSession
            ? PersonalizedNextActionV1.repeatPack
            : PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: recommendedModuleIdForFocus(
          focusLabel: focusId,
          reviewDue: false,
        ),
      );
    }

    return null;
  }

  static List<_RecentDecisionV1> _collectRecentDecisions(
    RecentActivityPersonalizationInputV1 input,
  ) {
    final moduleId = input.moduleId?.trim();
    final mode = input.mode?.trim();
    final filteredSignals = input.signals.where((signal) {
      if (moduleId != null && moduleId.isNotEmpty) {
        final eventModuleId = (signal.payload['module_id'] ?? '').toString();
        if (eventModuleId != moduleId) return false;
      }
      if (mode != null && mode.isNotEmpty) {
        final eventMode = (signal.payload['mode'] ?? '').toString();
        if (eventMode != mode) return false;
      }
      return true;
    });

    final decisions = <_RecentDecisionV1>[];
    for (final signal in filteredSignals) {
      final stepIndex = signal.payload['step_index'];
      if (signal.name == 'user_choice') {
        decisions.add(
          _RecentDecisionV1(
            stepIndex: stepIndex,
            choice: (signal.payload['choice'] ?? '').toString(),
            scopeKey: _scopeKeyFor(signal),
          ),
        );
        continue;
      }

      final targetDecision = _findOpenDecision(
        decisions: decisions,
        stepIndex: stepIndex,
        scopeKey: _scopeKeyFor(signal),
      );
      if (targetDecision == null) {
        continue;
      }
      if (signal.name == 'correct') {
        targetDecision.correct = signal.payload['correct'] == true;
        targetDecision.errorType = (signal.payload['error_type'] ?? '')
            .toString();
      } else if (signal.name == 'time_to_decision') {
        targetDecision.timeToDecisionMs = _parseInt(
          signal.payload['time_to_decision_ms'],
        );
      }
    }

    if (decisions.length <= _recentDecisionWindow) {
      return decisions;
    }
    return decisions.sublist(decisions.length - _recentDecisionWindow);
  }

  static _RecentDecisionV1? _findOpenDecision({
    required List<_RecentDecisionV1> decisions,
    required Object? stepIndex,
    required String scopeKey,
  }) {
    for (var i = decisions.length - 1; i >= 0; i--) {
      final decision = decisions[i];
      if (decision.stepIndex != stepIndex) continue;
      if (decision.scopeKey != scopeKey) continue;
      if (decision.correct == null || decision.timeToDecisionMs == null) {
        return decision;
      }
    }
    return null;
  }

  static _ChoiceFamilyV1 _dominantChoiceFamily(
    List<_RecentDecisionV1> decisions,
  ) {
    var actionCount = 0;
    var seatCount = 0;
    for (final decision in decisions) {
      final choice = decision.choice.trim().toLowerCase();
      if (choice.isEmpty) continue;
      if (choice.startsWith('action_')) {
        actionCount += 1;
      } else {
        seatCount += 1;
      }
    }
    return actionCount > seatCount
        ? _ChoiceFamilyV1.action
        : _ChoiceFamilyV1.seat;
  }

  static _RepeatedErrorV1? _strongestRepeatedError(
    List<_RecentDecisionV1> decisions,
  ) {
    final errorScores = <String, double>{};
    final includesSlowMistake = <String, bool>{};
    final counts = <String, int>{};
    for (final decision in decisions) {
      if (decision.correct != false) continue;
      final errorType = _normalizeErrorType(decision.errorType);
      if (errorType == 'none') continue;
      var score = 1.0;
      counts.update(errorType, (value) => value + 1, ifAbsent: () => 1);
      if ((decision.timeToDecisionMs ?? 0) >= _slowDecisionThresholdMs) {
        score += 0.75;
        includesSlowMistake[errorType] = true;
      }
      errorScores.update(
        errorType,
        (value) => value + score,
        ifAbsent: () {
          return score;
        },
      );
    }
    if (errorScores.isEmpty) return null;

    final strongestKey = errorScores.keys.toList(growable: false)
      ..sort((a, b) {
        final scoreCompare = errorScores[b]!.compareTo(errorScores[a]!);
        if (scoreCompare != 0) return scoreCompare;
        return a.compareTo(b);
      });
    final errorType = strongestKey.first;
    final score = errorScores[errorType]!;
    if (score < 1.5) {
      return null;
    }
    return _RepeatedErrorV1(
      errorType: errorType,
      includesSlowMistake: includesSlowMistake[errorType] ?? false,
      count: counts[errorType] ?? 0,
    );
  }

  static String _focusForSignal({
    required String? errorType,
    required _ChoiceFamilyV1 choiceFamily,
  }) {
    final normalizedErrorType = _normalizeErrorType(errorType);
    if (normalizedErrorType == 'no_selection' ||
        normalizedErrorType == 'expected_seat_mismatch' ||
        normalizedErrorType == 'incorrect_seat') {
      return 'action_order';
    }
    if (normalizedErrorType == 'timing') {
      return choiceFamily == _ChoiceFamilyV1.action
          ? 'initiative'
          : 'action_order';
    }
    return focusLabelForPhase1Signal(
          errorType: normalizedErrorType,
          category: normalizedErrorType,
          subreason: normalizedErrorType,
        ) ??
        focusLabelForPhase1Error(normalizedErrorType) ??
        (choiceFamily == _ChoiceFamilyV1.action
            ? 'initiative'
            : 'action_order');
  }

  static String _hintForPattern({
    required String focusId,
    required String? errorType,
    required _ChoiceFamilyV1 choiceFamily,
    required _HintPatternV1 pattern,
    int? repeatedCount,
    int? slowCount,
    bool includesSlowMistake = false,
  }) {
    final why = _whyForPattern(
      focusId: focusId,
      errorType: errorType,
      choiceFamily: choiceFamily,
      pattern: pattern,
      repeatedCount: repeatedCount,
      slowCount: slowCount,
      includesSlowMistake: includesSlowMistake,
    );
    final fix = _fixForFocus(
      focusId: focusId,
      errorType: errorType,
      choiceFamily: choiceFamily,
    );
    return _clampHint('$why $fix');
  }

  static String _whyForPattern({
    required String focusId,
    required String? errorType,
    required _ChoiceFamilyV1 choiceFamily,
    required _HintPatternV1 pattern,
    int? repeatedCount,
    int? slowCount,
    bool includesSlowMistake = false,
  }) {
    final subject = _focusSubject(
      focusId: focusId,
      errorType: errorType,
      choiceFamily: choiceFamily,
    );
    switch (pattern) {
      case _HintPatternV1.repeatedError:
        final count = repeatedCount == null || repeatedCount < 2
            ? 2
            : repeatedCount;
        if (includesSlowMistake) {
          return 'Missed $subject ${_timesPhrase(count)} after long pauses.';
        }
        return 'Missed $subject ${_timesPhrase(count)} recently.';
      case _HintPatternV1.slowCorrect:
        final count = slowCount == null || slowCount < 2 ? 2 : slowCount;
        return 'Found $subject, but slowly ${_timesPhrase(count)}.';
      case _HintPatternV1.latestMistake:
        return 'Latest miss came from $subject.';
    }
  }

  static String _fixForFocus({
    required String focusId,
    required String? errorType,
    required _ChoiceFamilyV1 choiceFamily,
  }) {
    final normalizedErrorType = _normalizeErrorType(errorType);
    return switch (focusId) {
      'action_order' =>
        normalizedErrorType == 'no_selection' ||
                normalizedErrorType == 'expected_seat_mismatch' ||
                normalizedErrorType == 'incorrect_seat'
            ? 'Name who acts first before you tap a seat.'
            : 'Read the seat order before you choose.',
      'initiative' =>
        choiceFamily == _ChoiceFamilyV1.action
            ? 'Pause on the initiative cue before you act.'
            : 'Confirm who owns the action before you continue.',
      'starting_hands' => 'Tighten the preflop range before you commit chips.',
      'pot_odds' => 'Count the price to call before you choose.',
      'board_texture' => 'Read the board texture before you continue.',
      'flop' => 'Name the flop plan before you tap your action.',
      'turn' => 'Re-check the turn story before you continue.',
      'river' => 'Slow down and compare showdown value on the river.',
      'equity_realization' =>
        'Look for how your hand realizes equity before acting.',
      'bankroll' => 'Protect the bankroll line before chasing the spot.',
      _ => 'Confirm the core cue before your next decision.',
    };
  }

  static String _focusSubject({
    required String focusId,
    required String? errorType,
    required _ChoiceFamilyV1 choiceFamily,
  }) {
    final normalizedErrorType = _normalizeErrorType(errorType);
    switch (focusId) {
      case 'action_order':
        return normalizedErrorType == 'incorrect_seat' ||
                normalizedErrorType == 'expected_seat_mismatch' ||
                normalizedErrorType == 'no_selection'
            ? 'seat order'
            : 'the acting seat';
      case 'initiative':
        return choiceFamily == _ChoiceFamilyV1.action
            ? 'the initiative cue'
            : 'who owns the action';
      case 'starting_hands':
        return 'starting-hand spots';
      case 'pot_odds':
        return 'the price to call';
      case 'board_texture':
        return 'board texture';
      case 'flop':
        return 'the flop plan';
      case 'turn':
        return 'the turn story';
      case 'river':
        return 'river showdown value';
      case 'equity_realization':
        return 'equity realization';
      case 'bankroll':
        return 'the bankroll line';
      default:
        return 'the core cue';
    }
  }

  static String _timesPhrase(int count) {
    if (count <= 1) return 'once';
    if (count == 2) return 'twice';
    return '$count times';
  }

  static String _normalizeErrorType(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return 'unknown';
    return normalized;
  }

  static int? _parseInt(Object? value) {
    return switch (value) {
      int number => number,
      String text => int.tryParse(text),
      _ => null,
    };
  }

  static String _scopeKeyFor(RecentTelemetrySignalV1 signal) {
    final moduleId = (signal.payload['module_id'] ?? '').toString().trim();
    final mode = (signal.payload['mode'] ?? '').toString().trim();
    final surface = (signal.payload['surface'] ?? '').toString().trim();
    if (moduleId.isNotEmpty || mode.isNotEmpty) {
      return 'module:$moduleId|mode:$mode';
    }
    if (surface.isNotEmpty) {
      return 'surface:$surface';
    }
    return 'global';
  }

  static String _clampHint(String value) {
    if (value.length <= 96) return value;
    return '${value.substring(0, 93).trimRight()}...';
  }
}

class _RecentDecisionV1 {
  _RecentDecisionV1({
    required this.stepIndex,
    required this.choice,
    required this.scopeKey,
  });

  final Object? stepIndex;
  final String choice;
  final String scopeKey;
  bool? correct;
  String? errorType;
  int? timeToDecisionMs;
}

class _RepeatedErrorV1 {
  const _RepeatedErrorV1({
    required this.errorType,
    required this.includesSlowMistake,
    required this.count,
  });

  final String errorType;
  final bool includesSlowMistake;
  final int count;
}

enum _ChoiceFamilyV1 { seat, action }

enum _HintPatternV1 { repeatedError, slowCorrect, latestMistake }
