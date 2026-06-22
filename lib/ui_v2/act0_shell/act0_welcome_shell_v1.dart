import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
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
          fallback:
              'Answer two quick questions. Then Sharky opens the first useful hand.',
        ),
        detail: _atomV1(
          'welcome_intro_detail',
          fallback: 'About two minutes. Then your first lesson is ready.',
        ),
        mood: Act0SharkyMoodV1.happy,
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
              : 'Home opens with one clear poker spot, and Learn keeps the next lessons visible.',
          ru: widget.replayMode
              ? 'Home по-прежнему показывает, что делать сейчас, а Learn держит следующие уроки на виду.'
              : 'Home открывает один ясный покерный спот, а Learn держит следующие уроки на виду.',
        ),
        detail: _copyV1(
          en: widget.replayMode
              ? 'Go back when you are ready. Your progress stays exactly where it was.'
              : 'You already know the loop. Open the start and take the first real lesson.',
          ru: widget.replayMode
              ? 'Возвращайся, когда будешь готов. Прогресс останется ровно там, где был.'
              : 'Цикл уже понятен. Открой старт и перейди к первому настоящему уроку.',
        ),
        mood: Act0SharkyMoodV1.celebrate,
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        visual: _WelcomeVisualPreviewCardV1(
          title: _copyV1(en: 'First hand ready', ru: 'Первая раздача готова'),
          accent: Act0ShellTokensV1.gold,
          bridge: _WelcomeLaunchPathV1(copy: _copyV1),
          previewKey: const Key('act0_shell_welcome_handoff_preview'),
          child: KeyedSubtree(
            key: const Key('act0_shell_welcome_handoff_proof_block'),
            child: _WelcomeLoopStripV1(copy: _copyV1),
          ),
        ),
        ctaLabel: _copyV1(
          en: widget.replayMode ? 'Back to profile' : 'Open your start',
          ru: widget.replayMode ? 'Назад в профиль' : 'Открыть свой старт',
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

  @override
  Widget build(BuildContext context) {
    final blocks = act0BuildInstructionBlocksV1(text: detail, compact: true);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeTopBarV1(
              beatIndex: beatIndex,
              beatCount: beatCount,
              replayMode: replayMode,
              onClose: onClose,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    key: const Key('act0_shell_welcome_beat_frame'),
                    padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                    decoration: Act0ShellTokensV1.surfaceDecoration(
                      color: Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
                      borderColor: Act0ShellTokensV1.primary.withValues(
                        alpha: 0.14,
                      ),
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
                          detail: blocks.join(' '),
                          mood: mood,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            SizedBox(
              width: double.infinity,
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
    );
  }
}

class _WelcomeVisualPreviewCardV1 extends StatelessWidget {
  const _WelcomeVisualPreviewCardV1({
    required this.title,
    required this.accent,
    required this.child,
    this.bridge,
    this.previewKey = const Key('act0_shell_welcome_visual_preview'),
  });

  final String title;
  final Color accent;
  final Widget child;
  final Widget? bridge;
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
      child: Row(
        children: [
          Expanded(
            child: _WelcomeLaunchStepV1(
              label: copy(en: 'Answer', ru: 'Ответы'),
              state: _WelcomeLaunchVisualStateV1.complete,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapXs),
          Expanded(
            child: _WelcomeLaunchStepV1(
              label: copy(en: 'Quick check', ru: 'Быстрая проверка'),
              state: _WelcomeLaunchVisualStateV1.complete,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapXs),
          Expanded(
            child: _WelcomeLaunchStepV1(
              label: copy(en: 'First hand', ru: 'Первая раздача'),
              state: _WelcomeLaunchVisualStateV1.active,
            ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Act0ShellTokensV1.label.copyWith(
                color: tone,
                letterSpacing: 0.12,
              ),
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
