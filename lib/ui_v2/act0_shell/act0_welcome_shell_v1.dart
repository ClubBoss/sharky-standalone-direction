import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String? _selectedMicroWinOptionId;

  bool get _isRuLocaleV1 => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

  String _atomV1(String atomId, {required String fallback}) =>
      act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

  Act0RunnerStateV1 get _microWinRunnerV1 {
    final lesson = Act0ShellStateV1.sample.lessonById('fold_check_call_raise');
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'actions_check_drill',
    );
    final selectedOptionId = _selectedMicroWinOptionId;
    return task.runner.copyWith(
      beatIndex: 2,
      beatCount: 3,
      phase: selectedOptionId == null
          ? Act0LessonPhaseV1.drill
          : Act0LessonPhaseV1.review,
      selectedOptionId: selectedOptionId,
      teachingStepIndex: task.runner.teachingSteps.length,
      returnTarget: 'Welcome',
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_beat) {
      Act0WelcomeBeatV1.intro => _WelcomeTextBeatV1(
        beatIndex: 1,
        beatCount: 3,
        title: _atomV1('welcome_intro_title', fallback: 'Find your start'),
        eyebrow: _atomV1('welcome_intro_eyebrow', fallback: 'Welcome'),
        line: _atomV1(
          'welcome_intro_line',
          fallback: act0SharkyCoachLineForMomentV1(
            Act0SharkyCoachMomentV1.welcomeOrientation,
          ),
        ),
        detail: _atomV1(
          'welcome_intro_detail',
          fallback: 'About two minutes. Then your first lesson is ready.',
        ),
        mood: act0SharkyMoodForCompanionStateV1(
          Act0SharkyCompanionStateV1.neutral,
        ),
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        visual: _WelcomeVisualPreviewCardV1(
          title: _copyV1(en: 'First hand after', ru: 'Потом первая раздача'),
          accent: Act0ShellTokensV1.primary,
          bridge: _WelcomeLaunchPathV1(copy: _copyV1),
          child: _WelcomeLoopStripV1(copy: _copyV1),
        ),
        ctaLabel: 'Try one table read',
        onNext: () => setState(() => _beat = Act0WelcomeBeatV1.demoSpot),
      ),
      Act0WelcomeBeatV1.demoSpot => Act0LessonRunnerShellV1(
        key: const Key('act0_shell_welcome_demo_spot'),
        runner: _microWinRunnerV1,
        onBack: widget.replayMode && widget.onClose != null
            ? widget.onClose!
            : () => setState(() => _beat = Act0WelcomeBeatV1.intro),
        onContinueTheory: () {},
        onChooseOption: (option) {
          setState(() => _selectedMicroWinOptionId = option.id);
        },
        onContinueReview: () {
          setState(() {
            _selectedMicroWinOptionId = null;
            _beat = Act0WelcomeBeatV1.handoff;
          });
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
              ? 'Home по-прежнему показывает, что делать сейчас, а Learn держит следующие уроки на виду.'
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
          title: _copyV1(en: 'FIRST HAND READY', ru: 'ПЕРВАЯ РАЗДАЧА ГОТОВА'),
          accent: Act0ShellTokensV1.gold,
          previewKey: const Key('act0_shell_welcome_handoff_preview'),
          line: _copyV1(
            en: 'Your first useful hand is ready.',
            ru: 'Твоя первая полезная раздача готова.',
          ),
          detail: _copyV1(
            en: 'Learn keeps the next one visible after that.',
            ru: 'Затем учебный путь покажет следующий урок.',
          ),
          child: Container(
            key: const Key('act0_shell_welcome_handoff_proof_block'),
            child: _WelcomeLaunchPathV1(
              copy: ({required String en, required String ru}) =>
                  _copyV1(en: en, ru: ru),
            ),
          ),
        ),
        ctaLabel: _copyV1(
          en: widget.replayMode ? 'Back to profile' : 'Open first lesson',
          ru: widget.replayMode ? 'Назад в профиль' : 'Открыть свой старт',
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
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 380 ? 20.0 : 24.0;
          final contentMaxWidth = math.min(
            math.max(0.0, constraints.maxWidth - 48),
            400.0,
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
                );
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      Act0ShellTokensV1.gapLg,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WelcomeTopBarV1(
                          beatIndex: beatIndex,
                          beatCount: beatCount,
                          replayMode: replayMode,
                          onClose: onClose,
                        ),
                        Spacer(flex: centerContent ? 65 : 45),
                        Center(
                          child: SizedBox(
                            width: contentMaxWidth,
                            child: content,
                          ),
                        ),
                        Spacer(flex: centerContent ? 20 : 55),
                        if (ctaBridgeLine != null &&
                            ctaBridgeLine!.trim().isNotEmpty) ...[
                          Text(
                            ctaBridgeLine!,
                            key: const Key('act0_shell_welcome_cta_bridge'),
                            textAlign: TextAlign.center,
                            style: Act0ShellTokensV1.muted.copyWith(
                              fontSize: 13,
                              color: Act0ShellTokensV1.text.withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                        ] else
                          const SizedBox(height: Act0ShellTokensV1.gapLg),
                        SizedBox(
                          width: double.infinity,
                          height: Act0ShellTokensV1.primaryCtaHeight,
                          child: FilledButton(
                            key: const Key('act0_shell_welcome_primary_cta'),
                            onPressed: onNext,
                            style: Act0ShellTokensV1.primaryButtonStyle(),
                            child: Text(ctaLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
  });

  final String title;
  final String eyebrow;
  final String line;
  final String detail;
  final Act0SharkyMoodV1 mood;
  final Widget? visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_welcome_beat_frame'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
        borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          if (visual != null) ...[
            visual!,
            const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
          Act0SharkyGuideCardV1(
            eyebrow: eyebrow,
            line: line,
            detail: detail,
            mood: mood,
            compact: true,
            growthStage: Act0SharkyGrowthStageV1.foundation,
          ),
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
          style: Act0ShellTokensV1.sectionTitle.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: Act0ShellTokensV1.text,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        if (subline.trim().isNotEmpty)
          Text(
            subline,
            textAlign: TextAlign.center,
            style: Act0ShellTokensV1.muted.copyWith(
              fontSize: 14,
              color: Act0ShellTokensV1.text.withValues(alpha: 0.65),
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
    const tone = Act0ShellTokensV1.primary;
    return Container(
      key: const Key('act0_shell_welcome_presenter_tile'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: tone.withValues(alpha: 0.50)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: SvgPicture.asset(
        _welcomePresenterAssetForMoodV1(mood),
        key: Key('act0_shell_sharky_presence_mascot_${mood.name}'),
        fit: BoxFit.contain,
      ),
    );
  }
}

String _welcomePresenterAssetForMoodV1(Act0SharkyMoodV1 mood) {
  return switch (mood) {
    Act0SharkyMoodV1.thinking => 'assets/mascot/poker_shark_thinking.svg',
    Act0SharkyMoodV1.celebrate => 'assets/mascot/poker_shark_celebrate.svg',
    Act0SharkyMoodV1.happy ||
    Act0SharkyMoodV1.neutral ||
    Act0SharkyMoodV1.repair => 'assets/mascot/poker_shark_idle.svg',
  };
}

class _WelcomeVisualPreviewCardV1 extends StatelessWidget {
  const _WelcomeVisualPreviewCardV1({
    required this.title,
    required this.accent,
    required this.child,
    this.bridge,
    this.line,
    this.detail,
    this.previewKey = const Key('act0_shell_welcome_visual_preview'),
  });

  final String title;
  final Color accent;
  final Widget child;
  final Widget? bridge;
  final String? line;
  final String? detail;
  final Key previewKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: previewKey,
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.heroDecoration().copyWith(
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bridge != null) ...[
            bridge!,
            const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
          Text(title, style: Act0ShellTokensV1.label.copyWith(color: accent)),
          if (child is! SizedBox) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            child,
          ],
          if (line != null && line!.trim().isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text(
              line!,
              style: Act0ShellTokensV1.body.copyWith(
                fontWeight: FontWeight.w800,
                color: Act0ShellTokensV1.text,
              ),
            ),
          ],
          if (detail != null && detail!.trim().isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              detail!,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
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
            color: Act0ShellTokensV1.textMuted,
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
                          ? Act0ShellTokensV1.primary
                          : Act0ShellTokensV1.surface3,
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
          style: Act0ShellTokensV1.body.copyWith(
            color: Act0ShellTokensV1.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
