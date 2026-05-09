import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/state/ui_glass_frame.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/infra/telemetry_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_ai_personalization_v1.dart';

const double lessonSpacingTiny = 4.0;
const double lessonSpacingSmall = 8.0;
const double lessonSpacingMedium = 12.0;
const double lessonSpacingLarge = 16.0;
const double lessonSpacingXl = 24.0;
const double lessonLegendTableGap = 10.0;
const double lessonTableBottomGap = 12.0;
const double lessonTableHeightFraction = 0.38;
const double lessonCardPadding = 14.0;
const double lessonFocusModeOpacity = 0.68;

const Duration lessonChipMoveDuration = Duration(milliseconds: 500);
const Curve lessonChipMoveCurve = Curves.easeOutBack;
const Duration lessonSuccessIndicatorDuration = Duration(milliseconds: 600);
const Duration lessonComboIndicatorDuration = Duration(milliseconds: 650);
const bool kDebugForceIdealFirstRun = false;
const bool kDebugShowOverlayMetrics = false;
const String _lessonFocusLabelStorageKey = 'lesson_focus_label_v1';

// TABLE-FIRST FRAMEWORK FREEZE
const String kTableFirstFrameworkFreezeId = 'freeze_2025_12_25_v1';
final bool _tableFirstFreezeGuard = () {
  assert(
    kTableFirstFrameworkFreezeId == 'freeze_2025_12_25_v1',
    'Table-first framework freeze marker mismatch.',
  );
  return true;
}();

enum LessonUxPreset { defaultMode, fastMode, softMode }

const LessonUxPreset kLessonUxPreset = LessonUxPreset.defaultMode;
const String kLessonFrameworkContractId = 'lesson_framework_contract_v1';
bool get kLessonAutoAdvanceOnCorrectGate =>
    kLessonUxPreset == LessonUxPreset.fastMode;
int get kLessonLightSummaryEveryNCompletions {
  switch (kLessonUxPreset) {
    case LessonUxPreset.fastMode:
      return 3;
    case LessonUxPreset.softMode:
    case LessonUxPreset.defaultMode:
      return 1;
  }
}

final bool _lessonFrameworkContractGuard = (() {
  assert(() {
    if (kLessonUxPreset != LessonUxPreset.defaultMode) {
      throw FlutterError(
        'Lesson UX preset default changed without bumping $kLessonFrameworkContractId.',
      );
    }
    // Focus mode default: gates dim until user interacts.
    if (lessonFocusModeOpacity != 0.68) {
      throw FlutterError(
        'Lesson focus mode opacity changed without bumping $kLessonFrameworkContractId.',
      );
    }
    return true;
  }());
  return true;
})();

class UiTableLessonOverlayScaffold extends StatelessWidget {
  final List<Widget> legendChips;
  final Widget tableArea;
  final Widget content;
  final EdgeInsetsGeometry padding;
  final double legendOpacity;

  const UiTableLessonOverlayScaffold({
    super.key,
    required this.legendChips,
    required this.tableArea,
    required this.content,
    this.padding = const EdgeInsets.all(lessonSpacingLarge),
    this.legendOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final vignette = Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [Colors.black.withOpacity(0.35), Colors.transparent],
            ),
          ),
        ),
      ),
    );

    final tableFrameRadius = BorderRadius.circular(22);
    final decoratedTableArea = ClipRRect(
      borderRadius: tableFrameRadius,
      child: Container(
        decoration: kPremiumGlassSurfaceSpec.decoration(
          radius: tableFrameRadius,
        ),
        child: Stack(
          children: [
            tableArea,
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.08)),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: tableFrameRadius,
                    gradient: kPremiumGlassSurfaceSpec.specularGradient,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: tableFrameRadius,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      radius: 0.65,
                      center: const Alignment(-0.4, -0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final tableHeight =
        MediaQuery.of(context).size.height * lessonTableHeightFraction;

    final overlayMetrics = _buildOverlayMetrics(context);
    return Padding(
      padding: padding,
      child: Stack(
        children: [
          vignette,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: legendOpacity.clamp(0.0, 1.0),
                child: Wrap(
                  key: const Key('lesson_legend'),
                  spacing: lessonSpacingSmall,
                  runSpacing: lessonSpacingTiny,
                  children: _styledLegendChips(context),
                ),
              ),
              SizedBox(height: lessonLegendTableGap),
              SizedBox(height: tableHeight, child: decoratedTableArea),
              SizedBox(height: lessonTableBottomGap),
              Expanded(child: content),
            ],
          ),
          if (overlayMetrics != null) overlayMetrics,
        ],
      ),
    );
  }

  List<Widget> _styledLegendChips(BuildContext context) {
    return legendChips.map((chip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: LessonTypography.body(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.88),
          ),
          child: chip,
        ),
      );
    }).toList();
  }

  Widget? _buildOverlayMetrics(BuildContext context) {
    if (!kDebugMode || !kDebugShowOverlayMetrics) return null;
    final helper = LessonTypography.helper(
      context,
    ).copyWith(fontSize: 11, color: Colors.white70);
    return Positioned(
      top: lessonSpacingTiny,
      right: lessonSpacingTiny,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(lessonSpacingTiny),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legend pad ${lessonSpacingSmall.toStringAsFixed(1)}',
                style: helper,
              ),
              Text('Table radius 22.0', style: helper),
              Text('Table height 0.45', style: helper),
              Text('Card pad $lessonCardPadding', style: helper),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonTypography {
  LessonTypography._();

  static TextStyle title(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base = theme.titleLarge ?? theme.titleMedium ?? theme.bodyLarge;
    return (base ?? const TextStyle(color: Colors.white)).copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base = theme.bodyLarge ?? theme.bodyMedium;
    final color = (base?.color ?? Colors.white).withOpacity(0.72);
    return (base ?? const TextStyle(color: Colors.white)).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base = theme.bodyMedium ?? theme.bodyLarge;
    return (base ?? const TextStyle(color: Colors.white)).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
  }

  static TextStyle meta(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base = theme.labelSmall ?? theme.bodySmall;
    final color = (base?.color ?? Colors.white).withOpacity(0.6);
    return (base ?? const TextStyle(color: Colors.white)).copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      color: color,
    );
  }

  static TextStyle helper(BuildContext context) {
    final base = body(context);
    final color = base.color?.withOpacity(0.7) ?? Colors.white70;
    return base.copyWith(fontSize: 12, height: 1.4, color: color);
  }
}

class LessonChipMoveTransition extends StatelessWidget {
  final bool active;
  final Widget child;
  final Offset hiddenOffset;

  const LessonChipMoveTransition({
    super.key,
    required this.active,
    required this.child,
    this.hiddenOffset = const Offset(0, -0.35),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: lessonChipMoveDuration,
      curve: lessonChipMoveCurve,
      offset: active ? Offset.zero : hiddenOffset,
      child: AnimatedOpacity(
        duration: lessonChipMoveDuration,
        curve: Curves.easeOut,
        opacity: active ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

class LessonMetaLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LessonMetaLabel({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: style ?? LessonTypography.meta(context),
    );
  }
}

class LessonActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? helperText;

  const LessonActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final helperStyle = LessonTypography.helper(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? const Color(0xFF4CAF50) : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: lessonSpacingSmall),
            child: Text(helperText!, style: helperStyle),
          ),
      ],
    );
  }
}

typedef LessonStepBodyBuilder =
    List<Widget> Function(
      BuildContext context,
      LessonStepController controller,
    );

class LessonStepController {
  LessonStepController({
    required VoidCallback advance,
    required void Function(int) advanceTo,
    required void Function()? showSuccessFeedback,
    required void Function()? registerWrongAnswerHint,
    required void Function()? clearWrongAnswerHint,
  }) : _advance = advance,
       _advanceTo = advanceTo,
       _showSuccessFeedback = showSuccessFeedback,
       _registerWrongAnswerHint = registerWrongAnswerHint,
       _clearWrongAnswerHint = clearWrongAnswerHint;

  final VoidCallback _advance;
  final void Function(int) _advanceTo;
  final void Function()? _showSuccessFeedback;
  final void Function()? _registerWrongAnswerHint;
  final void Function()? _clearWrongAnswerHint;

  void advance() => _advance();
  void advanceTo(int index) => _advanceTo(index);
  void showSuccessFeedback() => _showSuccessFeedback?.call();
  void registerWrongAnswerHint() => _registerWrongAnswerHint?.call();
  void clearWrongAnswerHint() => _clearWrongAnswerHint?.call();
}

@immutable
class GateEngagementConfig {
  const GateEngagementConfig({
    this.comboEligible = false,
    this.timeHintMs,
    this.onTimeHintExpired,
    this.hintText,
    this.showSuccessPulse = true,
  });

  final bool comboEligible;
  final int? timeHintMs;
  final VoidCallback? onTimeHintExpired;
  final String? hintText;
  final bool showSuccessPulse;
}

@immutable
class CompletionActions {
  const CompletionActions({
    this.showReplay = false,
    this.showNext = false,
    this.onNext,
    this.onReplay,
  });

  final bool showReplay;
  final bool showNext;
  final VoidCallback? onNext;
  final VoidCallback? onReplay;
}

@immutable
class LessonStep {
  const LessonStep({
    required this.metaLabel,
    required this.title,
    required this.bodyBuilder,
    this.timeHintMs,
    this.onTimeHintExpired,
    this.hintText,
    this.gateEngagementConfig,
    this.onEnter,
    this.requiresNumericText = false,
    this.comboEligible = false,
    this.countsAsGate = false,
    this.showSessionSummary = false,
    this.showRewardPing = false,
    this.completionActions,
  });

  final String metaLabel;
  final String title;
  final LessonStepBodyBuilder bodyBuilder;
  final int? timeHintMs;
  final VoidCallback? onTimeHintExpired;
  final String? hintText;
  final GateEngagementConfig? gateEngagementConfig;
  final VoidCallback? onEnter;
  final bool requiresNumericText;
  final bool comboEligible;
  final bool countsAsGate;
  final bool showSessionSummary;
  final bool showRewardPing;
  final CompletionActions? completionActions;
}

class LessonStepSequence extends StatefulWidget {
  const LessonStepSequence({
    super.key,
    required this.steps,
    required this.tableArea,
    required this.legendChips,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.switchInCurve = Curves.easeOutCubic,
    this.switchOutCurve = Curves.easeInCubic,
    this.lessonModuleId,
  });

  final List<LessonStep> steps;
  final Widget tableArea;
  final List<Widget> legendChips;
  final Duration transitionDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final String? lessonModuleId;

  @override
  State<LessonStepSequence> createState() => _LessonStepSequenceState();
}

class _LessonStepSequenceState extends State<LessonStepSequence> {
  late final LessonStepNavigator _navigator;
  int _currentIndex = 0;
  int _lastStepIndex = -1;
  final _LessonInstrumentation _instrumentation = _LessonInstrumentation();
  final bool _idealFirstRunActive = kDebugForceIdealFirstRun && kDebugMode;
  late final int _idealGateIndex;
  late final LessonStep? _idealGateStep;
  bool _userInteracted = false;
  bool _hasUserInteracted = false;
  bool get _shouldShowLegend =>
      ((!_idealFirstRunActive || _userInteracted) && _hasUserInteracted);
  Timer? _decisionTimer;
  int? _decisionRemainingMs;
  Timer? _successIndicatorTimer;
  bool _successIndicatorVisible = false;
  bool _hintVisible = false;
  int _comboCount = 0;
  Timer? _comboIndicatorTimer;
  bool _comboIndicatorVisible = false;
  int _gateCorrectCount = 0;
  int _wrongAttemptCount = 0;
  int _hintUsageCount = 0;
  bool _rewardPingVisible = false;
  Timer? _rewardPingTimer;
  DateTime? _lessonStartTime;
  DateTime? _firstInteractionTime;
  bool _scorecardDismissed = false;
  bool _autoAdvancePending = false;
  int _completionRuns = 0;
  bool _lightSummaryAllowedForCurrentCompletion = false;
  bool _wrongFeedbackActive = false;
  Timer? _wrongFeedbackTimer;
  final LessonLeakTracker _lessonLeakTracker = LessonLeakTracker();
  String? _patternLeakKey;
  String? _nextActionNudgeKey;
  bool _nextActionNudgeShown = false;
  bool _focusStored = false;

  GateEngagementConfig _engagementForStep(LessonStep step) =>
      step.gateEngagementConfig ??
      GateEngagementConfig(
        comboEligible: step.comboEligible,
        timeHintMs: step.timeHintMs,
        onTimeHintExpired: step.onTimeHintExpired,
        hintText: step.hintText,
      );

  @override
  void initState() {
    super.initState();
    _idealGateIndex = widget.steps.indexWhere((step) => step.countsAsGate);
    _idealGateStep = _idealGateIndex >= 0
        ? widget.steps[_idealGateIndex]
        : null;
    _navigator = LessonStepNavigator(
      stepCount: widget.steps.length,
      onEnter: (index) {
        widget.steps[index].onEnter?.call();
        _prepareLightSummaryForStep(widget.steps[index]);
        if (_lastStepIndex >= 0) {
          _instrumentation.recordStepExit(_lastStepIndex);
        }
        _instrumentation.recordStepEnter(index);
        setState(() {
          _currentIndex = index;
          _lastStepIndex = index;
        });
        _startDecisionTimer(widget.steps[index]);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigator.init());
    if (widget.lessonModuleId != null) {
      _instrumentation.startLesson(widget.lessonModuleId!);
      _lessonStartTime = DateTime.now();
      _completionRuns = 0;
      _lightSummaryAllowedForCurrentCompletion = false;
    }
    if (_idealFirstRunActive && _idealGateIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigator.advanceTo(_idealGateIndex);
      });
    }
  }

  void _advance({bool userInitiated = true}) {
    if (_idealFirstRunActive && !_userInteracted) {
      _userInteracted = true;
      setState(() {});
    }
    if (userInitiated) {
      _recordUserInteraction();
    }
    _navigator.advance();
  }

  void _advanceTo(int index) {
    _navigator.advanceTo(index);
  }

  @override
  void dispose() {
    _instrumentation.recordStepExit(_currentIndex);
    _instrumentation.finishLesson();
    _decisionTimer?.cancel();
    _successIndicatorTimer?.cancel();
    _comboIndicatorTimer?.cancel();
    _rewardPingTimer?.cancel();
    _wrongFeedbackTimer?.cancel();
    super.dispose();
  }

  void _resetLesson() {
    _decisionTimer?.cancel();
    _decisionTimer = null;
    _successIndicatorTimer?.cancel();
    _successIndicatorTimer = null;
    _comboIndicatorTimer?.cancel();
    _comboIndicatorTimer = null;
    _rewardPingTimer?.cancel();
    _rewardPingTimer = null;
    _decisionRemainingMs = null;
    _hintVisible = false;
    _successIndicatorVisible = false;
    _comboIndicatorVisible = false;
    _rewardPingVisible = false;
    _comboCount = 0;
    _gateCorrectCount = 0;
    _wrongAttemptCount = 0;
    _hintUsageCount = 0;
    _firstInteractionTime = null;
    _scorecardDismissed = false;
    _autoAdvancePending = false;
    _completionRuns = 0;
    _lightSummaryAllowedForCurrentCompletion = false;
    _hasUserInteracted = false;
    _lessonLeakTracker.reset();
    _patternLeakKey = null;
    _nextActionNudgeKey = null;
    _nextActionNudgeShown = false;
    _focusStored = false;
    _navigator.advanceTo(0);
    if (mounted) {
      setState(() {});
    }
    if (widget.lessonModuleId != null) {
      _instrumentation.startLesson(widget.lessonModuleId!);
      _lessonStartTime = DateTime.now();
    }
    _wrongFeedbackTimer?.cancel();
    _wrongFeedbackActive = false;
  }

  void _clearWrongFeedback() {
    _wrongFeedbackTimer?.cancel();
    _wrongFeedbackTimer = null;
    if (!_wrongFeedbackActive) return;
    _wrongFeedbackActive = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _prepareLightSummaryForStep(LessonStep step) {
    if (!step.showSessionSummary) {
      _lightSummaryAllowedForCurrentCompletion = false;
      return;
    }
    final nextCount = _completionRuns + 1;
    _lightSummaryAllowedForCurrentCompletion =
        nextCount % kLessonLightSummaryEveryNCompletions == 0;
    _completionRuns = nextCount;
  }

  void _resetSuccessIndicator() {
    _successIndicatorTimer?.cancel();
    _successIndicatorTimer = null;
    if (_successIndicatorVisible && mounted) {
      setState(() {
        _successIndicatorVisible = false;
      });
    } else {
      _successIndicatorVisible = false;
    }
  }

  void _triggerSuccessIndicator() {
    final step = widget.steps[_currentIndex];
    final engagement = _engagementForStep(step);
    if (step.countsAsGate) {
      _gateCorrectCount += 1;
      _instrumentation.recordGateCorrect(_currentIndex);
    }
    _resetSuccessIndicator();
    _clearWrongAnswerHint();
    _lessonLeakTracker.registerDecision(isCorrect: true, errorClass: null);
    if (engagement.comboEligible) {
      _comboCount += 1;
      if (engagement.showSuccessPulse) {
        _showComboIndicator();
      }
    }
    _scheduleAutoAdvanceAfterGate(step);
    if (!engagement.showSuccessPulse) {
      return;
    }
    if (mounted) {
      setState(() {
        _successIndicatorVisible = true;
      });
    } else {
      _successIndicatorVisible = true;
    }
    _successIndicatorTimer = Timer(lessonSuccessIndicatorDuration, () {
      if (mounted) {
        setState(() {
          _successIndicatorVisible = false;
        });
      } else {
        _successIndicatorVisible = false;
      }
    });
  }

  void _scheduleAutoAdvanceAfterGate(LessonStep step) {
    if (!kLessonAutoAdvanceOnCorrectGate || !step.countsAsGate) return;
    if (_autoAdvancePending) return;
    _autoAdvancePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoAdvancePending = false;
      _advance(userInitiated: false);
    });
  }

  void _triggerWrongFeedback() {
    _wrongFeedbackTimer?.cancel();
    _wrongFeedbackActive = true;
    if (mounted) setState(() {});
    _wrongFeedbackTimer = Timer(const Duration(milliseconds: 320), () {
      _wrongFeedbackActive = false;
      if (mounted) setState(() {});
    });
  }

  void _resetComboStreak() {
    _comboIndicatorTimer?.cancel();
    _comboIndicatorTimer = null;
    if (_comboIndicatorVisible && mounted) {
      setState(() {
        _comboIndicatorVisible = false;
      });
    } else {
      _comboIndicatorVisible = false;
    }
    _comboCount = 0;
  }

  void _showComboIndicator() {
    _comboIndicatorTimer?.cancel();
    _comboIndicatorTimer = null;
    if (mounted) {
      setState(() {
        _comboIndicatorVisible = true;
      });
    } else {
      _comboIndicatorVisible = true;
    }
    _comboIndicatorTimer = Timer(lessonComboIndicatorDuration, () {
      if (mounted) {
        setState(() {
          _comboIndicatorVisible = false;
        });
      } else {
        _comboIndicatorVisible = false;
      }
    });
  }

  void _registerWrongAnswerHint() {
    _resetComboStreak();
    final step = widget.steps[_currentIndex];
    final leakKey = _lessonLeakTracker.registerDecision(
      isCorrect: false,
      errorClass: _errorClassForStep(step),
    );
    _patternLeakKey = leakKey;
    if (leakKey != null && !_nextActionNudgeShown) {
      _nextActionNudgeKey ??= leakKey;
      if (!_focusStored) {
        unawaited(_storeFocusLabelIfNeeded(leakKey));
      }
    }
    _wrongAttemptCount += 1;
    _instrumentation.recordGateAttempt(_currentIndex);
    _instrumentation.recordGateHint(_currentIndex);
    if (_idealFirstRunActive && !_userInteracted) {
      _userInteracted = true;
      setState(() {});
    }
    _recordUserInteraction();
    _triggerWrongFeedback();
    if (_hintVisible) return;
    _hintUsageCount += 1;
    if (mounted) {
      setState(() {
        _hintVisible = true;
      });
    } else {
      _hintVisible = true;
    }
  }

  void _triggerRewardPingIfNeeded(LessonStep step) {
    _rewardPingTimer?.cancel();
    if (!step.showRewardPing) {
      if (_rewardPingVisible && mounted) {
        setState(() {
          _rewardPingVisible = false;
        });
      } else {
        _rewardPingVisible = false;
      }
      return;
    }
    if (mounted) {
      setState(() {
        _rewardPingVisible = true;
      });
    } else {
      _rewardPingVisible = true;
    }
    _rewardPingTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _rewardPingVisible = false;
        });
      } else {
        _rewardPingVisible = false;
      }
    });
  }

  void _clearWrongAnswerHint() {
    if (!_hintVisible) return;
    if (mounted) {
      setState(() {
        _hintVisible = false;
        _patternLeakKey = null;
      });
    } else {
      _hintVisible = false;
      _patternLeakKey = null;
    }
  }

  Future<void> _storeFocusLabelIfNeeded(String leakKey) async {
    if (_focusStored) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_lessonFocusLabelStorageKey) != null) {
      _focusStored = true;
      return;
    }
    await prefs.setString(_lessonFocusLabelStorageKey, leakKey);
    Telemetry.logEvent(
      'hint_shown',
      buildTelemetry(
        sessionId: 'lesson_focus_bridge',
        data: {'has_focus': true},
      ),
    );
    _focusStored = true;
  }

  void _recordFirstInteraction() {
    if (_firstInteractionTime != null) return;
    _firstInteractionTime = DateTime.now();
  }

  void _recordUserInteraction() {
    _recordFirstInteraction();
    if (_hasUserInteracted) return;
    _hasUserInteracted = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _startDecisionTimer(LessonStep step) {
    final engagement = _engagementForStep(step);
    _decisionTimer?.cancel();
    _decisionTimer = null;
    _clearWrongFeedback();
    _resetSuccessIndicator();
    _clearWrongAnswerHint();
    _triggerRewardPingIfNeeded(step);
    if (engagement.timeHintMs == null) {
      if (mounted) {
        setState(() {
          _decisionRemainingMs = null;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _decisionRemainingMs = engagement.timeHintMs;
      });
    }
    _decisionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final remaining = (_decisionRemainingMs ?? 0) - 100;
      if (remaining <= 0) {
        timer.cancel();
        _decisionTimer = null;
        _decisionRemainingMs = 0;
        engagement.onTimeHintExpired?.call();
        if (mounted) setState(() {});
        return;
      }
      if (mounted) {
        setState(() {
          _decisionRemainingMs = remaining;
        });
      }
    });
  }

  Widget? _buildDecisionTimer(LessonStep step) {
    final engagement = _engagementForStep(step);
    final timeHintMs = engagement.timeHintMs;
    if (timeHintMs == null) return null;
    final remainingMs = _decisionRemainingMs ?? timeHintMs;
    final seconds = (remainingMs / 1000).ceil().clamp(0, 99);
    return Padding(
      padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
      child: Row(
        children: [
          const Icon(Icons.timer, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          LessonNumericText(
            '${seconds}s',
            style: LessonTypography.helper(context),
          ),
        ],
      ),
    );
  }

  Widget? _buildWrongAnswerHint(LessonStep step) {
    if (!_hintVisible) return null;
    final text = _engagementForStep(step).hintText;
    if (text == null) return null;
    final patternKey = _patternLeakKey;
    final patternLine = patternKey == null
        ? null
        : LessonLeakLabels.patternLine(patternKey, isRu: _isRuLocale());
    final hintStyle = LessonTypography.helper(
      context,
    ).copyWith(color: Colors.orangeAccent);
    return Padding(
      padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: hintStyle),
          if (patternLine != null) ...[
            const SizedBox(height: 6),
            Text(
              patternLine,
              style: LessonTypography.helper(
                context,
              ).copyWith(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildSuccessFeedback() {
    if (!_successIndicatorVisible || !_hasUserInteracted) return null;
    final comboBadge = _buildComboBadge();
    return Padding(
      padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.greenAccent),
          const SizedBox(width: 6),
          Text(
            'Correct',
            style: LessonTypography.helper(
              context,
            ).copyWith(color: Colors.greenAccent, fontWeight: FontWeight.w600),
          ),
          if (comboBadge != null) ...[const SizedBox(width: 10), comboBadge],
        ],
      ),
    );
  }

  Widget? _buildComboBadge() {
    if (!_comboIndicatorVisible || _comboCount <= 0 || !_hasUserInteracted)
      return null;
    final level = (_comboCount + 1).clamp(2, 3).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: LessonNumericText(
        'x$level',
        style: LessonTypography.helper(
          context,
        ).copyWith(color: Colors.amberAccent, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget? _buildSessionSummary(LessonStep step) {
    if (!step.showSessionSummary) return null;
    final hintsUsed = _hintUsageCount > 0;
    if (!_lightSummaryAllowedForCurrentCompletion) return null;
    final labelStyle = LessonTypography.helper(
      context,
    ).copyWith(fontSize: 12, letterSpacing: 0.5, color: Colors.white70);
    final valueStyle = LessonTypography.body(
      context,
    ).copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    final summaryLeakKey = _lessonLeakTracker.summaryLeakKey();
    final summaryLine = summaryLeakKey == null
        ? null
        : LessonLeakLabels.summaryLine(summaryLeakKey, isRu: _isRuLocale());
    return Container(
      margin: const EdgeInsets.only(bottom: lessonSpacingSmall),
      padding: const EdgeInsets.all(lessonSpacingSmall),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryColumn(
                label: 'Correct gates',
                value: LessonNumericText(
                  '$_gateCorrectCount',
                  style: valueStyle,
                ),
                labelStyle: labelStyle,
              ),
              _SummaryColumn(
                label: 'Wrong attempts',
                value: LessonNumericText(
                  '$_wrongAttemptCount',
                  style: valueStyle,
                ),
                labelStyle: labelStyle,
              ),
              _SummaryColumn(
                label: 'Hints used',
                value: Text(hintsUsed ? 'Yes' : 'No', style: valueStyle),
                labelStyle: labelStyle,
              ),
            ],
          ),
          if (summaryLine != null) ...[
            const SizedBox(height: 8),
            Text(
              summaryLine,
              style: labelStyle.copyWith(
                letterSpacing: 0,
                color: Colors.white60,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildLightCompletionCard(LessonStep step) {
    if (!step.showSessionSummary) return null;
    final totalGates = widget.steps
        .where((s) => s.countsAsGate)
        .length
        .clamp(0, widget.steps.length);
    final labelStyle = LessonTypography.helper(
      context,
    ).copyWith(fontSize: 12, letterSpacing: 0.5, color: Colors.white70);
    final valueStyle = LessonTypography.body(
      context,
    ).copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    final summaryLeakKey = _lessonLeakTracker.summaryLeakKey();
    final summaryLine = summaryLeakKey == null
        ? null
        : LessonLeakLabels.summaryLine(summaryLeakKey, isRu: _isRuLocale());
    return Container(
      margin: const EdgeInsets.only(bottom: lessonSpacingSmall),
      padding: const EdgeInsets.all(lessonSpacingSmall),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryColumn(
                label: 'Gates cleared',
                value: LessonNumericText(
                  '$_gateCorrectCount/$totalGates',
                  style: valueStyle,
                ),
                labelStyle: labelStyle,
              ),
              _SummaryColumn(
                label: 'Mistakes',
                value: LessonNumericText(
                  '$_wrongAttemptCount',
                  style: valueStyle,
                ),
                labelStyle: labelStyle,
              ),
              _SummaryColumn(
                label: 'Hints used',
                value: LessonNumericText('$_hintUsageCount', style: valueStyle),
                labelStyle: labelStyle,
              ),
            ],
          ),
          if (summaryLine != null) ...[
            const SizedBox(height: 8),
            Text(
              summaryLine,
              style: labelStyle.copyWith(
                letterSpacing: 0,
                color: Colors.white60,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isRuLocale() =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ru';

  String _errorClassForStep(LessonStep step) {
    final hintText = _engagementForStep(step).hintText ?? '';
    final source = '${step.metaLabel} ${step.title} $hintText'.toLowerCase();
    if (source.contains('blocker')) return 'blocker';
    if (source.contains('position') || source.contains('oop'))
      return 'position';
    if (source.contains('sizing') || source.contains('bet')) return 'sizing';
    if (source.contains('value')) return 'value';
    if (source.contains('bluff') || source.contains('jam')) return 'bluff';
    if (source.contains('range')) return 'range';
    if (source.contains('texture') || source.contains('board')) {
      return 'board';
    }
    if (source.contains('discipline')) return 'discipline';
    if (source.contains('timing')) return 'timing';
    return 'general';
  }

  Widget? _applyFocusDim(Widget? child, bool active) {
    if (!active || child == null) return child;
    return Opacity(opacity: lessonFocusModeOpacity, child: child);
  }

  bool _shouldShowScorecard(LessonStep step) {
    return _idealFirstRunActive &&
        !_scorecardDismissed &&
        step.showSessionSummary &&
        _lessonStartTime != null;
  }

  Widget _buildFirstRunScorecard() {
    final totalDurationMs = DateTime.now()
        .difference(_lessonStartTime!)
        .inMilliseconds;
    final timeToFirstInteractionMs = _firstInteractionTime == null
        ? 0
        : _firstInteractionTime!.difference(_lessonStartTime!).inMilliseconds;
    final gateCount = widget.steps.where((step) => step.countsAsGate).length;
    final labelStyle = LessonTypography.helper(
      context,
    ).copyWith(fontSize: 10, letterSpacing: 0.4, color: Colors.white70);
    final valueStyle = LessonTypography.body(
      context,
    ).copyWith(fontSize: 14, fontWeight: FontWeight.w600);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(lessonSpacingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'First run score',
                style: LessonTypography.meta(
                  context,
                ).copyWith(letterSpacing: 0.6, color: Colors.white70),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _scorecardDismissed = true;
                  });
                },
                child: const Icon(Icons.close, size: 16, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: lessonSpacingTiny),
          _SummaryColumn(
            label: 'Duration',
            value: LessonNumericText('${totalDurationMs}ms', style: valueStyle),
            labelStyle: labelStyle,
          ),
          const SizedBox(height: lessonSpacingTiny),
          _SummaryColumn(
            label: 'Time to interaction',
            value: LessonNumericText(
              '${timeToFirstInteractionMs}ms',
              style: valueStyle,
            ),
            labelStyle: labelStyle,
          ),
          const SizedBox(height: lessonSpacingTiny),
          _SummaryColumn(
            label: 'Gates',
            value: LessonNumericText('$gateCount', style: valueStyle),
            labelStyle: labelStyle,
          ),
          const SizedBox(height: lessonSpacingTiny),
          _SummaryColumn(
            label: 'Wrong answers',
            value: LessonNumericText('$_wrongAttemptCount', style: valueStyle),
            labelStyle: labelStyle,
          ),
          const SizedBox(height: lessonSpacingTiny),
          _SummaryColumn(
            label: 'Hints shown',
            value: LessonNumericText('$_hintUsageCount', style: valueStyle),
            labelStyle: labelStyle,
          ),
        ],
      ),
    );
  }

  Widget? _buildRewardPing(LessonStep step) {
    if (!step.showRewardPing) return null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _rewardPingVisible ? 1 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 450),
        scale: _rewardPingVisible ? 1 : 0.2,
        curve: Curves.easeOutBack,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.monetization_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget? _buildCompletionActions(LessonStep step) {
    final actions = step.completionActions;
    if (actions == null) return null;
    final buttons = <Widget>[];
    final nudgeKey = _nextActionNudgeShown ? null : _nextActionNudgeKey;
    if (actions.showReplay) {
      buttons.add(
        _SecondaryActionButton(
          label: 'Replay',
          onPressed: () {
            _recordUserInteraction();
            _instrumentation.recordEvent('replay_tapped');
            actions.onReplay?.call();
            _resetLesson();
            _nextActionNudgeShown = true;
            _nextActionNudgeKey = null;
          },
        ),
      );
    }
    if (actions.showNext && actions.onNext != null) {
      buttons.add(
        _SecondaryActionButton(
          label: 'Next',
          onPressed: () {
            _recordUserInteraction();
            _instrumentation.recordEvent('next_tapped');
            actions.onNext?.call();
            _nextActionNudgeShown = true;
            _nextActionNudgeKey = null;
          },
        ),
      );
    }
    if (buttons.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(top: lessonSpacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (nudgeKey != null)
            Padding(
              padding: const EdgeInsets.only(bottom: lessonSpacingTiny),
              child: Text(
                LessonLeakLabels.nudgeLine(nudgeKey),
                style: LessonTypography.helper(
                  context,
                ).copyWith(color: Colors.white70, fontSize: 12),
              ),
            ),
          Wrap(
            spacing: lessonSpacingSmall,
            runSpacing: lessonSpacingTiny,
            alignment: WrapAlignment.end,
            children: buttons,
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(LessonStep step, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonMetaLabel(
          text: step.metaLabel,
          style: LessonTypography.meta(
            context,
          ).copyWith(color: Colors.white70, letterSpacing: 1.2),
        ),
        const SizedBox(height: lessonSpacingTiny),
        Text(step.title, style: LessonTypography.title(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentIndex];
    final completionActions = _buildCompletionActions(step);
    final controller = LessonStepController(
      advance: _advance,
      advanceTo: _advanceTo,
      showSuccessFeedback: _triggerSuccessIndicator,
      registerWrongAnswerHint: _registerWrongAnswerHint,
      clearWrongAnswerHint: _clearWrongAnswerHint,
    );
    final body = step.bodyBuilder(context, controller);
    final usageScope = LessonNumericScope(
      required: step.requiresNumericText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: body,
      ),
    );
    final timerIndicator = _buildDecisionTimer(step);
    final hintIndicator = _buildWrongAnswerHint(step);
    final successIndicator = _buildSuccessFeedback();
    final focusModeActive = step.countsAsGate && !_hasUserInteracted;
    final sessionSummary = _applyFocusDim(
      _buildSessionSummary(step),
      focusModeActive,
    );
    final lightCompletionCard = _applyFocusDim(
      _buildLightCompletionCard(step),
      focusModeActive,
    );
    final rewardPing = _buildRewardPing(step);
    return UiTableLessonOverlayScaffold(
      legendOpacity: focusModeActive ? lessonFocusModeOpacity : 1.0,
      legendChips: _shouldShowLegend ? widget.legendChips : const [],
      tableArea: widget.tableArea,
      content: AnimatedSwitcher(
        duration: widget.transitionDuration,
        switchInCurve: widget.switchInCurve,
        switchOutCurve: widget.switchOutCurve,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: widget.switchInCurve,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              key: ValueKey(_currentIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: lessonSpacingLarge,
                ),
                child: AnimatedSlide(
                  offset: _wrongFeedbackActive
                      ? const Offset(0.02, 0)
                      : Offset.zero,
                  duration: const Duration(milliseconds: 140),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    key: ValueKey(
                      _wrongFeedbackActive
                          ? 'lesson_step_card_wrong'
                          : 'lesson_step_card',
                    ),
                    padding: const EdgeInsets.all(lessonCardPadding),
                    decoration: BoxDecoration(
                      gradient: kPremiumGlassSurfaceSpec.baseGradient,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _wrongFeedbackActive
                            ? Colors.redAccent.withOpacity(0.7)
                            : kPremiumGlassSurfaceSpec.borderColor,
                        width: kPremiumGlassSurfaceSpec.borderWidth,
                      ),
                      boxShadow: [
                        ...kPremiumGlassSurfaceSpec.shadows,
                        if (step.showSessionSummary)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.08),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStepHeader(step, context),
                            const SizedBox(height: lessonSpacingSmall),
                            if (timerIndicator != null) timerIndicator,
                            if (hintIndicator != null) hintIndicator,
                            if (successIndicator != null) successIndicator,
                            if (sessionSummary != null) sessionSummary,
                            if (lightCompletionCard != null)
                              lightCompletionCard,
                            if (rewardPing != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: rewardPing,
                              ),
                            if (completionActions != null) completionActions,
                            const SizedBox(height: lessonSpacingMedium),
                            usageScope,
                          ],
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient:
                                    kPremiumGlassSurfaceSpec.specularGradient,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_shouldShowScorecard(step))
              Positioned(
                top: lessonSpacingTiny,
                right: lessonSpacingTiny,
                child: _buildFirstRunScorecard(),
              ),
          ],
        ),
      ),
    );
  }
}

class LessonStepNavigator {
  LessonStepNavigator({required this.stepCount, required this.onEnter})
    : assert(stepCount > 0);

  final int stepCount;
  final void Function(int) onEnter;

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void init() {
    onEnter(_currentIndex);
  }

  void advance() => advanceTo(_currentIndex + 1);

  void advanceTo(int index) {
    final next = index.clamp(0, stepCount - 1).toInt();
    if (next == _currentIndex) return;
    _currentIndex = next;
    onEnter(_currentIndex);
  }
}

class LessonNumericUsageController {
  bool used = false;

  void registerUsage() {
    used = true;
  }
}

class LessonNumericScope extends StatefulWidget {
  const LessonNumericScope({
    super.key,
    required this.required,
    required this.child,
  });

  final bool required;
  final Widget child;

  static void validateRequirement({
    required bool required,
    required bool used,
  }) {
    assert(
      !required || used,
      'Lesson step declares numeric content but no NumericText rendered.',
    );
  }

  static LessonNumericUsageController? of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_LessonNumericScopeInherited>();
    return inherited?.controller;
  }

  @override
  State<LessonNumericScope> createState() => _LessonNumericScopeState();
}

class _LessonNumericScopeState extends State<LessonNumericScope> {
  final LessonNumericUsageController _controller =
      LessonNumericUsageController();

  void _scheduleValidation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      LessonNumericScope.validateRequirement(
        required: widget.required,
        used: _controller.used,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _scheduleValidation();
  }

  @override
  void didUpdateWidget(covariant LessonNumericScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleValidation();
  }

  @override
  Widget build(BuildContext context) {
    return _LessonNumericScopeInherited(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _LessonNumericScopeInherited extends InheritedWidget {
  const _LessonNumericScopeInherited({
    required this.controller,
    required super.child,
  });

  final LessonNumericUsageController controller;

  @override
  bool updateShouldNotify(_LessonNumericScopeInherited oldWidget) =>
      controller != oldWidget.controller;
}

class _LessonInstrumentation {
  String? _moduleId;
  DateTime? _lessonStart;
  final Map<int, Duration> _stepDurations = {};
  final Map<int, DateTime> _stepEntries = {};
  final Map<int, int> _gateAttempts = {};
  final Map<int, int> _gateHints = {};
  final Map<int, DateTime> _gateCorrect = {};

  bool get _enabled => kDebugMode;

  void startLesson(String moduleId) {
    if (!_enabled) return;
    _moduleId = moduleId;
    _lessonStart = DateTime.now();
    _stepDurations.clear();
    _stepEntries.clear();
    _gateAttempts.clear();
    _gateHints.clear();
    _gateCorrect.clear();
    debugPrint('LessonInstrumentation start module=$moduleId');
  }

  void finishLesson() {
    if (!_enabled || _moduleId == null || _lessonStart == null) return;
    final now = DateTime.now();
    final duration = now.difference(_lessonStart!);
    final steps = _stepDurations.entries
        .map((e) => '${e.key}:${e.value.inMilliseconds}ms')
        .join(',');
    final attempts = _gateAttempts.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    final hints = _gateHints.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    final corrects = _gateCorrect.entries
        .map((e) => '${e.key}:${e.value.toIso8601String()}')
        .join(',');
    debugPrint(
      'LessonInstrumentation finish module=$_moduleId duration=${duration.inMilliseconds}ms steps=[$steps] gateAttempts=[$attempts] gateHints=[$hints] gateCorrect=[$corrects]',
    );
    _moduleId = null;
    _lessonStart = null;
  }

  void recordStepEnter(int index) {
    if (!_enabled) return;
    _stepEntries[index] = DateTime.now();
  }

  void recordStepExit(int index) {
    if (!_enabled) return;
    final start = _stepEntries.remove(index);
    if (start == null) return;
    final duration = DateTime.now().difference(start);
    _stepDurations[index] = (_stepDurations[index] ?? Duration.zero) + duration;
  }

  void recordGateAttempt(int stepIndex) {
    if (!_enabled) return;
    _gateAttempts[stepIndex] = (_gateAttempts[stepIndex] ?? 0) + 1;
  }

  void recordGateHint(int stepIndex) {
    if (!_enabled) return;
    _gateHints[stepIndex] = (_gateHints[stepIndex] ?? 0) + 1;
  }

  void recordGateCorrect(int stepIndex) {
    if (!_enabled) return;
    _gateCorrect[stepIndex] = DateTime.now();
  }

  void recordEvent(String event) {
    if (!_enabled) return;
    debugPrint(
      'LessonInstrumentation event module=$_moduleId event=$event timestamp=${DateTime.now().toIso8601String()}',
    );
  }
}

class LessonNumericText extends StatelessWidget {
  const LessonNumericText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    LessonNumericScope.of(context)?.registerUsage();
    return NumericText(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textStyle = LessonTypography.helper(context).copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white70,
      letterSpacing: 0.3,
    );
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: textStyle),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.labelStyle,
  });

  final String label;
  final Widget value;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        value,
      ],
    );
  }
}
