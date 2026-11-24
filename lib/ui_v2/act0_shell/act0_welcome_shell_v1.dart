import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_welcome_state_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';
import 'skin/act0_skin_components_v1.dart';

export 'act0_welcome_state_v1.dart' show Act0WelcomeBeatV1;

class Act0WelcomeShellV1 extends StatefulWidget {
  const Act0WelcomeShellV1({
    super.key,
    required this.replayMode,
    required this.onCompleted,
    this.handoffStartsRecommendedTask = false,
    this.onClose,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final bool replayMode;
  final bool handoffStartsRecommendedTask;
  final VoidCallback? onCompleted;
  final VoidCallback? onClose;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0WelcomeShellV1> createState() => _Act0WelcomeShellV1State();
}

class _Act0WelcomeShellV1State extends State<Act0WelcomeShellV1> {
  final _flow = Act0WelcomeStateV1();
  Act0AccessibilityPrototypeStepV1? _accessibilityPrototypeStep;

  bool get _isRuLocaleV1 => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

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
    return switch (_flow.beat) {
      Act0WelcomeBeatV1.intro => _WelcomeTextBeatV1(
        step: 1,
        title: 'Sharky Poker',
        line: _copyV1(
          en: 'Practice reading the table and learn why each choice matters.',
          ru: 'Учись читать стол и понимать, почему важен каждый выбор.',
        ),
        onClose: widget.replayMode ? widget.onClose : null,
        closeLabel: _copyV1(en: 'Close', ru: 'Закрыть'),
        ctaLabel: _copyV1(en: 'Try one table read', ru: 'Попробовать'),
        onNext: () => setState(_flow.openDemo),
      ),
      // Keep the existing Table rendering context while Academy text scales.
      Act0WelcomeBeatV1.demoSpot => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.0,
        child: Act0LessonRunnerShellV1(
          key: const Key('act0_shell_welcome_demo_spot'),
          runner: microWinRunner,
          accessibilityPrototypeStep: accessibilityPrototypeStep,
          onAccessibilityPrototypeStepChanged: (next) {
            setState(() => _accessibilityPrototypeStep = next);
          },
          onBack: widget.replayMode && widget.onClose != null
              ? widget.onClose!
              : () => setState(_flow.returnToIntro),
          onContinueTheory: () {},
          // Any pick moves straight to the truthful handoff beat: Welcome never
          // renders the real review/feedback phase, so no fabricated graded
          // choice (correct/wrong banner, fake retry CTA) can appear here.
          onChooseOption: (option) {
            setState(() => _flow.choose(option.label));
          },
          onContinueReview: () {
            setState(_flow.finishDemo);
          },
          tableVisualVariant: widget.tableVisualVariant,
        ),
      ),

      Act0WelcomeBeatV1.handoff => _WelcomeTextBeatV1(
        step: 3,
        title: _copyV1(en: 'Your path is ready.', ru: 'Твой маршрут готов.'),
        line: widget.replayMode
            ? _copyV1(
                en: 'Return to your saved progress.',
                ru: 'Вернись к сохранённому прогрессу.',
              )
            : _copyV1(
                en: 'Your first useful hand is ready.',
                ru: 'Твоя первая раздача готова.',
              ),
        onClose: widget.replayMode ? widget.onClose : null,
        closeLabel: _copyV1(en: 'Close', ru: 'Закрыть'),
        preview: Act0SkinCardV1(
          key: const Key('act0_shell_welcome_handoff_preview'),
          child: Column(
            key: const Key('act0_shell_welcome_handoff_proof_block'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _copyV1(en: 'PREVIEW COMPLETE', ru: 'ЗНАКОМСТВО ЗАВЕРШЕНО'),
                style: Act0SkinTokensV1.sectionLabel,
              ),
              if (_flow.orientationChoiceLabel case final choice?)
                Text(
                  _copyV1(
                    en: 'You tried $choice. This preview was ungraded.',
                    ru: 'Твой выбор: ${_welcomeChoiceRuV1(choice)}. Это знакомство без оценки.',
                  ),
                  style: Act0SkinTokensV1.secondary,
                ),
            ],
          ),
        ),
        ctaLabel: widget.replayMode
            ? _copyV1(en: 'Back to profile', ru: 'Назад в профиль')
            : widget.handoffStartsRecommendedTask
            ? _copyV1(
                en: 'Start recommended lesson',
                ru: 'Начать рекомендованный урок',
              )
            : _copyV1(en: 'Open my path', ru: 'Открыть мой путь'),
        bridge: widget.replayMode
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
    required this.step,
    required this.title,
    required this.line,
    required this.ctaLabel,
    required this.onNext,
    required this.closeLabel,
    this.preview,
    this.bridge,
    this.onClose,
  });

  final int step;
  final String title;
  final String line;
  final String ctaLabel;
  final VoidCallback? onNext;
  final String closeLabel;
  final Widget? preview;
  final String? bridge;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Act0SkinTokensV1.background,
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(Act0SkinTokensV1.screenGutter),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    key: Key(
                      step == 1
                          ? 'act0_shell_welcome_beat_frame'
                          : 'act0_shell_welcome_next_step_line',
                    ),
                    children: [
                      Act0SkinStepBarV1(current: step, total: 3),
                      Text(
                        '$step/3',
                        key: const Key('act0_shell_welcome_progress_label'),
                        style: Act0SkinTokensV1.captionStyle,
                      ),
                      const SizedBox(height: Act0SkinTokensV1.gapLg),
                      const Act0SkinSharkyExpressionV1(
                        key: Key('act0_shell_welcome_presenter_tile'),
                        moment: Act0SkinSharkyMomentV1.idle,
                      ),
                      const SizedBox(height: Act0SkinTokensV1.gapMd),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Act0SkinTokensV1.title,
                      ),
                      const SizedBox(height: Act0SkinTokensV1.gapSm),
                      Text(
                        line,
                        textAlign: TextAlign.center,
                        style: Act0SkinTokensV1.secondary,
                      ),
                      if (preview != null) ...[
                        const SizedBox(height: Act0SkinTokensV1.gapMd),
                        preview!,
                      ],
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: Act0SkinTokensV1.gapLg),
                      if (bridge != null)
                        Text(
                          bridge!,
                          key: const Key('act0_shell_welcome_cta_bridge'),
                          textAlign: TextAlign.center,
                          style: Act0SkinTokensV1.captionStyle,
                        ),
                      Act0SkinPrimaryButtonV1(
                        controlKey: const Key('act0_shell_welcome_primary_cta'),
                        label: ctaLabel,
                        onPressed: onNext,
                      ),
                      if (onClose != null) ...[
                        const SizedBox(height: Act0SkinTokensV1.gapSm),
                        Act0SkinSecondaryButtonV1(
                          controlKey: const Key('act0_shell_welcome_close'),
                          label: closeLabel,
                          onPressed: onClose,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String _welcomeChoiceRuV1(String label) => switch (label) {
  'Fold' => 'фолд',
  'Check' => 'чек',
  'Call' => 'колл',
  _ => label,
};
