import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';

enum Act0WelcomeBeatV1 { intro, demoSpot, handoff }

class Act0WelcomeShellV1 extends StatefulWidget {
  const Act0WelcomeShellV1({
    super.key,
    required this.replayMode,
    required this.onCompleted,
    this.onClose,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final bool replayMode;
  final VoidCallback onCompleted;
  final VoidCallback? onClose;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0WelcomeShellV1> createState() => _Act0WelcomeShellV1State();
}

class _Act0WelcomeShellV1State extends State<Act0WelcomeShellV1> {
  Act0WelcomeBeatV1 _beat = Act0WelcomeBeatV1.intro;
  Act0AccessibilityPrototypeStepV1? _accessibilityPrototypeStep;
  String? _orientationChoiceLabel;

  bool get _isRuLocaleV1 => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

  String _atomV1(String atomId, {required String fallback}) =>
      act0AcademySurfaceAtomV1(context, atomId, fallback: fallback);

  // F04: Welcome is truthful orientation, not a demo assessment. The real
  // table/task renders for a genuine first read, but picking an option never
  // enters the real grading/feedback phase here — there is no retry to offer,
  // so Welcome must never show a graded wrong/"Try same clue" state. Actual
  // wrong feedback and repair belong to the real decision route (Learn).
  Act0RunnerStateV1 get _microWinRunnerV1 {
    final lesson = Act0ShellStateV1.sample.lessonById('fold_check_call_raise');
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'actions_check_drill',
    );
    return task.runner.copyWith(
      beatIndex: 2,
      beatCount: 3,
      phase: Act0LessonPhaseV1.drill,
      selectedOptionId: null,
      teachingStepIndex: task.runner.teachingSteps.length,
      returnTarget: 'Welcome',
    );
  }

  @override
  Widget build(BuildContext context) {
    final microWinRunner = _microWinRunnerV1;
    final accessibilityPrototypeStep =
        act0ShouldActivateCompactAccessibilityPrototypeV1(
          context,
          question: microWinRunner.question,
          options: microWinRunner.options,
          tableCriticalLabels: <String>[
            microWinRunner.table.potLabel,
            microWinRunner.table.toCallLabel,
          ],
        )
        ? _accessibilityPrototypeStep ??
              Act0AccessibilityPrototypeStepV1.evidence
        : null;
    return switch (_beat) {
      Act0WelcomeBeatV1.intro => _WelcomeTextBeatV1(
        beatIndex: 1,
        beatCount: 3,
        title: _copyV1(
          en: 'Try one table read',
          ru: '\u041f\u043e\u043f\u0440\u043e\u0431\u0443\u0439 \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u0442\u044c \u0441\u0442\u043e\u043b',
        ),
        eyebrow: _atomV1('welcome_intro_eyebrow', fallback: 'Welcome'),
        line: _copyV1(
          en: 'Read the table, make a choice, then learn why.',
          ru: '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u0439 \u0441\u0442\u043e\u043b, \u0441\u0434\u0435\u043b\u0430\u0439 \u0432\u044b\u0431\u043e\u0440 \u0438 \u0443\u0437\u043d\u0430\u0439 \u043f\u0440\u0438\u0447\u0438\u043d\u0443.',
        ),
        detail: _copyV1(
          en: 'This preview is ungraded. Your first lesson comes next.',
          ru: '\u042d\u0442\u043e \u0437\u043d\u0430\u043a\u043e\u043c\u0441\u0442\u0432\u043e \u0431\u0435\u0437 \u043e\u0446\u0435\u043d\u043a\u0438. \u041d\u0430\u0441\u0442\u043e\u044f\u0449\u0438\u0439 \u0443\u0440\u043e\u043a \u0431\u0443\u0434\u0435\u0442 \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0438\u043c.',
        ),
        mood: act0SharkyMoodForCompanionStateV1(
          Act0SharkyCompanionStateV1.neutral,
        ),
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        visual: _WelcomeVisualPreviewCardV1(
          title: _copyV1(en: 'Your first table read', ru: 'Первый рид стола'),
          accent: Act0AcademyDesignTokensV1.focus,
          line: _copyV1(
            en: 'Start with one clear table decision.',
            ru: 'Начни с одного понятного решения за столом.',
          ),
          child: const SizedBox.shrink(),
        ),
        ctaLabel: _copyV1(
          en: 'Try one table read',
          ru: '\u041f\u043e\u043f\u0440\u043e\u0431\u043e\u0432\u0430\u0442\u044c',
        ),
        onNext: () => setState(() => _beat = Act0WelcomeBeatV1.demoSpot),
      ),
      Act0WelcomeBeatV1.demoSpot => Act0LessonRunnerShellV1(
        key: const Key('act0_shell_welcome_demo_spot'),
        runner: microWinRunner,
        accessibilityPrototypeStep: accessibilityPrototypeStep,
        onAccessibilityPrototypeStepChanged: (next) {
          setState(() => _accessibilityPrototypeStep = next);
        },
        onBack: widget.replayMode && widget.onClose != null
            ? widget.onClose!
            : () => setState(() => _beat = Act0WelcomeBeatV1.intro),
        onContinueTheory: () {},
        // Any pick moves straight to the truthful handoff beat: Welcome never
        // renders the real review/feedback phase, so no fabricated graded
        // choice (correct/wrong banner, fake retry CTA) can appear here.
        onChooseOption: (option) {
          setState(() {
            _orientationChoiceLabel = option.label;
            _beat = Act0WelcomeBeatV1.handoff;
          });
        },
        onContinueReview: () {
          setState(() => _beat = Act0WelcomeBeatV1.handoff);
        },
        tableVisualVariant: widget.tableVisualVariant,
      ),
      Act0WelcomeBeatV1.handoff => _WelcomeTextBeatV1(
        beatIndex: 3,
        beatCount: 3,
        title: _copyV1(
          en: widget.replayMode
              ? 'You can reopen this anytime.'
              : 'Your path is ready.',
          ru: widget.replayMode
              ? 'Ты можешь открыть это снова в любой момент.'
              : 'Твой маршрут готов.',
        ),
        eyebrow: _atomV1('welcome_handoff_eyebrow', fallback: 'Next step'),
        line: _copyV1(
          en: widget.replayMode
              ? 'Home still shows what to do now, and Learn keeps the next lessons visible.'
              : 'Your first useful hand is ready.',
          ru: widget.replayMode
              ? '\u0413\u043b\u0430\u0432\u043d\u0430\u044f \u043f\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442, \u0447\u0442\u043e \u0434\u0435\u043b\u0430\u0442\u044c \u0441\u0435\u0439\u0447\u0430\u0441, \u0430 \u0423\u0447\u0451\u0431\u0430 \u2014 \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0438\u0435 \u0443\u0440\u043e\u043a\u0438.'
              : 'Твоя первая полезная раздача готова.',
        ),
        detail: _copyV1(
          en: widget.replayMode
              ? 'Go back when you are ready. Your progress stays exactly where it was.'
              : 'Learn keeps the next one visible after that.',
          ru: widget.replayMode
              ? 'Возвращайся, когда будешь готов. Прогресс останется ровно там, где был.'
              : 'Затем учебный путь покажет следующий урок.',
        ),
        mood: act0SharkyMoodForCompanionStateV1(
          Act0SharkyCompanionStateV1.coach,
        ),
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        visual: _WelcomeVisualPreviewCardV1(
          title: _copyV1(
            en: 'PREVIEW COMPLETE',
            ru: '\u0417\u041d\u0410\u041a\u041e\u041c\u0421\u0422\u0412\u041e \u0417\u0410\u0412\u0415\u0420\u0428\u0415\u041d\u041e',
          ),
          accent: Act0AcademyDesignTokensV1.primaryAction,
          previewKey: const Key('act0_shell_welcome_handoff_preview'),
          line: _copyV1(
            en: _orientationChoiceLabel == null
                ? 'Your first useful hand is ready.'
                : 'You tried ${_orientationChoiceLabel!}. This preview was ungraded.',
            ru: _orientationChoiceLabel == null
                ? '\u0422\u0432\u043e\u044f \u043f\u0435\u0440\u0432\u0430\u044f \u043f\u043e\u043b\u0435\u0437\u043d\u0430\u044f \u0440\u0430\u0437\u0434\u0430\u0447\u0430 \u0433\u043e\u0442\u043e\u0432\u0430.'
                : '\u0422\u0432\u043e\u0439 \u0432\u044b\u0431\u043e\u0440: ${_welcomeChoiceRuV1(_orientationChoiceLabel!)}. \u042d\u0442\u043e \u0437\u043d\u0430\u043a\u043e\u043c\u0441\u0442\u0432\u043e \u0431\u0435\u0437 \u043e\u0446\u0435\u043d\u043a\u0438.',
          ),
          detail: _copyV1(
            en: 'Learn keeps the next one visible after that.',
            ru: 'Затем учебный путь покажет следующий урок.',
          ),
          child: Container(
            key: const Key('act0_shell_welcome_handoff_proof_block'),
            child: const SizedBox.shrink(),
          ),
        ),
        ctaLabel: _copyV1(
          en: widget.replayMode ? 'Back to profile' : 'Open my path',
          ru: widget.replayMode
              ? '\u041d\u0430\u0437\u0430\u0434 \u0432 \u043f\u0440\u043e\u0444\u0438\u043b\u044c'
              : '\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043c\u043e\u0439 \u043f\u0443\u0442\u044c',
        ),
        subline: widget.replayMode
            ? null
            : _copyV1(
                en: 'Placement done. Sharky mapped your start.',
                ru: 'Размещение готово. Sharky наметил твой старт.',
              ),
        ctaBridgeLine: widget.replayMode
            ? null
            : _copyV1(
                en: 'One hand · about 2 minutes.',
                ru: 'Одна раздача · около 2 минут.',
              ),
        onNext: widget.onCompleted,
      ),
    };
  }
}

class _WelcomeTextBeatV1 extends StatelessWidget {
  const _WelcomeTextBeatV1({
    required this.beatIndex,
    required this.beatCount,
    required this.title,
    required this.eyebrow,
    required this.line,
    required this.detail,
    required this.mood,
    required this.replayMode,
    required this.onNext,
    required this.ctaLabel,
    this.visual,
    this.onClose,
    this.subline,
    this.ctaBridgeLine,
  });

  final int beatIndex;
  final int beatCount;
  final String title;
  final String eyebrow;
  final String line;
  final String detail;
  final Act0SharkyMoodV1 mood;
  final bool replayMode;
  final VoidCallback onNext;
  final String ctaLabel;
  final Widget? visual;
  final VoidCallback? onClose;
  final String? subline;
  final String? ctaBridgeLine;

  @override
  Widget build(BuildContext context) {
    final blocks = act0BuildInstructionBlocksV1(text: detail, compact: true);
    final centerContent = beatIndex == beatCount;
    return Container(
      color: Act0AcademyDesignTokensV1.pageSurface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 20.0 : 24.0;
            final tabletLayout = constraints.maxWidth >= 700;
            final contentMaxWidth = math.min(
              math.max(0.0, constraints.maxWidth - (tabletLayout ? 96 : 48)),
              tabletLayout ? 760.0 : 400.0,
            );
            final smallPhone = constraints.maxHeight < 700;
            final bottomPadding = math.max(
              Act0ShellTokensV1.gapLg,
              MediaQuery.viewPaddingOf(context).bottom,
            );
            final content = centerContent
                ? _WelcomeHandoffContentGroupV1(
                    title: title,
                    subline: subline ?? '',
                    mood: mood,
                    visual: visual,
                    smallPhone: smallPhone,
                  )
                : _WelcomeStandardBeatFrameV1(
                    title: title,
                    eyebrow: eyebrow,
                    line: line,
                    detail: blocks.join(' '),
                    mood: mood,
                    visual: visual,
                    tabletLayout: tabletLayout,
                  );
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WelcomeTopBarV1(
                        beatIndex: beatIndex,
                        beatCount: beatCount,
                        replayMode: replayMode,
                        onClose: onClose,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(width: contentMaxWidth, child: content),
                      ),
                      const SizedBox(height: 24),
                      if (ctaBridgeLine?.trim().isNotEmpty == true) ...[
                        Text(
                          ctaBridgeLine!,
                          key: const Key('act0_shell_welcome_cta_bridge'),
                          textAlign: TextAlign.center,
                          style: Act0AcademyDesignTokensV1.supporting,
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton(
                        key: const Key('act0_shell_welcome_primary_cta'),
                        onPressed: onNext,
                        style: Act0AcademyDesignTokensV1.primaryButtonStyle(),
                        child: Text(ctaLabel, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeStandardBeatFrameV1 extends StatelessWidget {
  const _WelcomeStandardBeatFrameV1({
    required this.title,
    required this.eyebrow,
    required this.line,
    required this.detail,
    required this.mood,
    required this.visual,
    required this.tabletLayout,
  });

  final String title;
  final String eyebrow;
  final String line;
  final String detail;
  final Act0SharkyMoodV1 mood;
  final Widget? visual;
  final bool tabletLayout;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _WelcomeSharkyPresenterTileV1(mood: mood, size: 164)),
        const SizedBox(height: Act0AcademyDesignTokensV1.gapXl),
        Text(line, style: Act0AcademyDesignTokensV1.body),
        const SizedBox(height: Act0AcademyDesignTokensV1.gapSm),
        Text(detail, style: Act0AcademyDesignTokensV1.supporting),
      ],
    );
    return Container(
      key: const Key('act0_shell_welcome_beat_frame'),
      padding: const EdgeInsets.all(Act0AcademyDesignTokensV1.gapMd),
      decoration: Act0AcademyDesignTokensV1.cardDecoration(
        borderColor: Act0AcademyDesignTokensV1.focus.withValues(alpha: 0.24),
      ),
      child: Column(
        mainAxisAlignment: tabletLayout
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0AcademyDesignTokensV1.display),
          const SizedBox(height: Act0AcademyDesignTokensV1.gapMd),
          body,
        ],
      ),
    );
  }
}

class _WelcomeHandoffContentGroupV1 extends StatelessWidget {
  const _WelcomeHandoffContentGroupV1({
    required this.title,
    required this.subline,
    required this.mood,
    required this.visual,
    required this.smallPhone,
  });

  final String title;
  final String subline;
  final Act0SharkyMoodV1 mood;
  final Widget? visual;
  final bool smallPhone;

  @override
  Widget build(BuildContext context) {
    final titleFontSize = smallPhone ? 24.0 : 28.0;
    final headlineGap = smallPhone ? Act0ShellTokensV1.gapSm : 14.0;
    final proofGap = smallPhone ? Act0ShellTokensV1.gapLg : 18.0;
    return Column(
      key: const Key('act0_shell_welcome_next_step_line'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: _WelcomeSharkyPresenterTileV1(
            mood: mood,
            size: smallPhone ? 64 : 80,
          ),
        ),
        SizedBox(height: headlineGap),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Act0AcademyDesignTokensV1.sectionHeading.copyWith(
            fontSize: titleFontSize,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        if (subline.trim().isNotEmpty)
          Text(
            subline,
            textAlign: TextAlign.center,
            style: Act0AcademyDesignTokensV1.supporting.copyWith(
              fontSize: 14,
              height: 1.22,
            ),
          ),
        if (visual != null) ...[SizedBox(height: proofGap), visual!],
      ],
    );
  }
}

class _WelcomeSharkyPresenterTileV1 extends StatelessWidget {
  const _WelcomeSharkyPresenterTileV1({required this.mood, required this.size});

  final Act0SharkyMoodV1 mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    const tone = Act0AcademyDesignTokensV1.focus;
    return Container(
      key: const Key('act0_shell_welcome_presenter_tile'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Act0AcademyDesignTokensV1.cardSurface,
        borderRadius: BorderRadius.circular(
          Act0AcademyDesignTokensV1.radiusCoachFrame,
        ),
        border: Border.all(color: tone.withValues(alpha: 0.50)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: Image.asset(
        act0SharkyCompanionAssetForMoodV1(mood),
        key: Key('act0_shell_sharky_presence_mascot_${mood.name}'),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _WelcomeVisualPreviewCardV1 extends StatelessWidget {
  const _WelcomeVisualPreviewCardV1({
    required this.title,
    required this.accent,
    required this.child,
    this.line,
    this.detail,
    this.previewKey = const Key('act0_shell_welcome_visual_preview'),
  });

  final String title;
  final Color accent;
  final Widget child;
  final String? line;
  final String? detail;
  final Key previewKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: previewKey,
      padding: const EdgeInsets.all(Act0AcademyDesignTokensV1.gapMd),
      decoration: Act0AcademyDesignTokensV1.cardDecoration(
        borderColor: accent.withOpacity(0.32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Act0AcademyDesignTokensV1.label.copyWith(color: accent),
          ),
          if (child is! SizedBox) ...[
            const SizedBox(height: Act0AcademyDesignTokensV1.gapMd),
            child,
          ],
          if (line != null && line!.trim().isNotEmpty) ...[
            const SizedBox(height: Act0AcademyDesignTokensV1.gapMd),
            Text(
              line!,
              style: Act0AcademyDesignTokensV1.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (detail != null && detail!.trim().isNotEmpty) ...[
            const SizedBox(height: Act0AcademyDesignTokensV1.gapXs),
            Text(
              detail!,
              style: Act0AcademyDesignTokensV1.supporting.copyWith(
                height: 1.22,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WelcomeLaunchPathV1 extends StatelessWidget {
  const _WelcomeLaunchPathV1({required this.copy});

  final String Function({required String en, required String ru}) copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_welcome_launch_path'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapSm,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withOpacity(0.44),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.14)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Act0ShellTokensV1.gapXs,
        runSpacing: Act0ShellTokensV1.gapXs,
        children: [
          _WelcomeLaunchStepV1(
            label: copy(en: 'Answer', ru: 'Ответы'),
            state: _WelcomeLaunchVisualStateV1.complete,
          ),
          _WelcomeLaunchStepV1(
            label: copy(en: 'Quick check', ru: 'Быстрая проверка'),
            state: _WelcomeLaunchVisualStateV1.complete,
          ),
          _WelcomeLaunchStepV1(
            label: copy(en: 'First hand', ru: 'Первая раздача'),
            state: _WelcomeLaunchVisualStateV1.active,
          ),
        ],
      ),
    );
  }
}

enum _WelcomeLaunchVisualStateV1 { complete, active }

class _WelcomeLaunchStepV1 extends StatelessWidget {
  const _WelcomeLaunchStepV1({required this.label, required this.state});

  final String label;
  final _WelcomeLaunchVisualStateV1 state;

  @override
  Widget build(BuildContext context) {
    final tone = state == _WelcomeLaunchVisualStateV1.complete
        ? Act0ShellTokensV1.primary
        : Act0ShellTokensV1.gold;
    final icon = state == _WelcomeLaunchVisualStateV1.complete
        ? Icons.check_rounded
        : Icons.play_arrow_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: Act0ShellTokensV1.label.copyWith(
              color: tone,
              letterSpacing: 0.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeLoopStripV1 extends StatelessWidget {
  const _WelcomeLoopStripV1({required this.copy});

  final String Function({required String en, required String ru}) copy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Act0ShellTokensV1.gapSm,
      runSpacing: Act0ShellTokensV1.gapSm,
      children: [
        _WelcomeLoopChipV1(
          label: copy(en: 'Read', ru: 'Рид'),
          tone: Act0ShellTokensV1.primary,
        ),
        _WelcomeLoopChipV1(
          label: copy(en: 'Answer', ru: 'Ответ'),
          tone: Act0ShellTokensV1.info,
        ),
        _WelcomeLoopChipV1(
          label: copy(en: 'Reason', ru: 'Причина'),
          tone: Act0ShellTokensV1.gold,
        ),
        _WelcomeLoopChipV1(
          label: copy(en: 'Move on', ru: 'Дальше'),
          tone: Act0ShellTokensV1.primary,
        ),
      ],
    );
  }
}

class _WelcomeLoopChipV1 extends StatelessWidget {
  const _WelcomeLoopChipV1({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: tone,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _WelcomeTopBarV1 extends StatelessWidget {
  const _WelcomeTopBarV1({
    required this.beatIndex,
    required this.beatCount,
    required this.replayMode,
    this.onClose,
  });

  final int beatIndex;
  final int beatCount;
  final bool replayMode;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (replayMode && onClose != null)
          IconButton(
            key: const Key('act0_shell_welcome_close'),
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: Act0AcademyDesignTokensV1.inkMuted,
          )
        else
          const SizedBox(width: 48),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Row(
            children: [
              for (var index = 0; index < beatCount; index++) ...[
                Expanded(
                  child: Container(
                    key: Key('act0_shell_welcome_progress_$index'),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index < beatIndex
                          ? Act0AcademyDesignTokensV1.focus
                          : Act0AcademyDesignTokensV1.rule,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                  ),
                ),
                if (index < beatCount - 1)
                  const SizedBox(width: Act0ShellTokensV1.gapXs),
              ],
            ],
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapMd),
        Text(
          '$beatIndex/$beatCount',
          key: const Key('act0_shell_welcome_progress_label'),
          style: Act0AcademyDesignTokensV1.supporting.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _welcomeChoiceRuV1(String label) => switch (label) {
  'Fold' => '\u0444\u043e\u043b\u0434',
  'Check' => '\u0447\u0435\u043a',
  'Call' => '\u043a\u043e\u043b\u043b',
  _ => label,
};
