import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _placementCopyV1(
  BuildContext context, {
  required String en,
  required String ru,
}) => _isRuLocaleV1(context) ? ru : en;

String _placementAtomV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

bool _placementKeepFullSupportCopyV1(String questionId) =>
    questionId == 'experience';

class Act0PlacementShellV1 extends StatelessWidget {
  const Act0PlacementShellV1({
    super.key,
    required this.questions,
    required this.showIntro,
    required this.currentQuestionIndex,
    required this.selectedOptionIds,
    required this.result,
    required this.onSelectOption,
    required this.onStartPlacement,
    required this.onBack,
    required this.onNext,
    required this.onStartDiagnostic,
    required this.onStartRecommended,
    required this.onStartFromZero,
  });

  final List<Act0PlacementQuestionV1> questions;
  final bool showIntro;
  final int currentQuestionIndex;
  final Map<String, Set<String>> selectedOptionIds;
  final Act0PlacementResultV1? result;
  final void Function(Act0PlacementQuestionV1 question, String optionId)
  onSelectOption;
  final VoidCallback onStartPlacement;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onStartDiagnostic;
  final VoidCallback onStartRecommended;
  final VoidCallback onStartFromZero;

  @override
  Widget build(BuildContext context) {
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final localeIsRu = _isRuLocaleV1(context);
    final placementResult = result;
    if (placementResult == null) {
      final currentQuestion = currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;
      final currentQuestionSelections = currentQuestion == null
          ? const <String>{}
          : selectedOptionIds[currentQuestion.questionId] ?? const <String>{};
      final explicitBeginnerStart =
          currentQuestion?.questionId == 'experience' &&
          currentQuestionSelections.contains('new');
      final minimumCount = currentQuestion == null
          ? 0
          : (currentQuestion.minSelections <= 0
                ? 1
                : currentQuestion.minSelections);
      final allowNext =
          currentQuestion != null &&
          currentQuestionSelections.length >= minimumCount;
      return Column(
        key: const Key('act0_shell_placement_screen'),
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                Act0ShellTokensV1.gapMd,
                pagePadding,
                132,
              ),
              children: [
                Act0ShellTokensV1.centeredContent(
                  context,
                  tabletMaxWidth: 860,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlacementHeroV1(
                        title: _placementCopyV1(
                          context,
                          en: 'Find your start',
                          ru: 'Найди свой старт',
                        ),
                        subtitle: _placementCopyV1(
                          context,
                          en: 'A few fast answers, then Sharky picks where to begin.',
                          ru: 'Пара быстрых ответов — и Шарки подберёт маршрут.',
                        ),
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapMd),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        reverseDuration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        transitionBuilder: (child, animation) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.03, 0.02),
                                end: Offset.zero,
                              ).animate(curved),
                              child: child,
                            ),
                          );
                        },
                        child: showIntro
                            ? const KeyedSubtree(
                                key: ValueKey<String>(
                                  'act0_shell_placement_intro',
                                ),
                                child: _PlacementIntroViewV1(),
                              )
                            : KeyedSubtree(
                                key: ValueKey<String>(
                                  'act0_shell_placement_body_$currentQuestionIndex',
                                ),
                                child: _QuestionOrDiagnosticV1(
                                  questions: questions,
                                  currentQuestionIndex: currentQuestionIndex,
                                  selectedOptionIds: selectedOptionIds,
                                  onSelectOption: onSelectOption,
                                  onBack: onBack,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _PlacementFlowActionBarV1(
            title: showIntro
                ? (localeIsRu
                      ? 'Две минуты. Потом Шарки покажет, с чего начать.'
                      : 'Two minutes. Then Sharky shows where to start.')
                : explicitBeginnerStart
                ? (localeIsRu
                      ? 'Начни с нуля и пропусти живую проверку.'
                      : 'Start from zero and skip the live check.')
                : currentQuestionIndex >= questions.length
                ? (localeIsRu
                      ? 'Один короткий живой чек — и первый полезный старт готов.'
                      : 'One short live check, then your first useful start is ready.')
                : currentQuestion?.allowsMultiple == true
                ? (localeIsRu ? 'Выбери то, что подходит.' : 'Pick what fits.')
                : (localeIsRu
                      ? 'Отвечай быстро и двигайся дальше.'
                      : 'Answer fast and keep moving.'),
            buttonKey: Key(
              showIntro
                  ? 'act0_shell_placement_intro_cta'
                  : currentQuestionIndex >= questions.length
                  ? 'act0_shell_placement_start_diagnostic'
                  : 'act0_shell_placement_next_cta',
            ),
            buttonLabel: showIntro
                ? (localeIsRu ? 'Начать плейсмент' : 'Start placement')
                : explicitBeginnerStart
                ? (localeIsRu ? 'Начать с нуля' : 'Start from zero')
                : currentQuestionIndex >= questions.length
                ? (localeIsRu ? 'Начать проверку' : 'Start quick check')
                : (localeIsRu ? 'Продолжить' : 'Continue'),
            onPressed: showIntro
                ? onStartPlacement
                : explicitBeginnerStart
                ? onStartFromZero
                : currentQuestionIndex >= questions.length
                ? onStartDiagnostic
                : (allowNext ? onNext : null),
          ),
        ],
      );
    }

    return Column(
      key: const Key('act0_shell_placement_screen'),
      children: [
        Expanded(
          child: ListView(
            key: const Key('act0_shell_placement_result_scroll'),
            padding: EdgeInsets.fromLTRB(
              pagePadding,
              Act0ShellTokensV1.gapMd,
              pagePadding,
              116,
            ),
            children: [
              Act0ShellTokensV1.centeredContent(
                context,
                tabletMaxWidth: 860,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlacementHeroV1(
                      title: _placementCopyV1(
                        context,
                        en: 'Find your start',
                        ru: 'Найди свой старт',
                      ),
                      subtitle: _placementCopyV1(
                        context,
                        en: 'A few fast answers, then Sharky picks where to begin.',
                        ru: 'Пара быстрых ответов — и Шарки подберёт маршрут.',
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>(
                          'act0_shell_placement_result_${placementResult.level.name}',
                        ),
                        child: _PlacementResultViewV1(result: placementResult),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _PlacementResultActionBarV1(
          onStartRecommended: onStartRecommended,
          onStartFromZero: onStartFromZero,
        ),
      ],
    );
  }
}

class _QuestionOrDiagnosticV1 extends StatelessWidget {
  const _QuestionOrDiagnosticV1({
    required this.questions,
    required this.currentQuestionIndex,
    required this.selectedOptionIds,
    required this.onSelectOption,
    required this.onBack,
  });

  final List<Act0PlacementQuestionV1> questions;
  final int currentQuestionIndex;
  final Map<String, Set<String>> selectedOptionIds;
  final void Function(Act0PlacementQuestionV1 question, String optionId)
  onSelectOption;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= questions.length) {
      return Column(
        key: const Key('act0_shell_placement_diagnostic_ready'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlacementSectionCardV1(
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
            borderColor: Act0ShellTokensV1.info.withOpacity(0.18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      key: const Key('act0_shell_placement_back_arrow'),
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Act0ShellTokensV1.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapXs),
                    Expanded(
                      child: Text(
                        _placementAtomV1(
                          context,
                          'placement_ready_skill_check',
                          fallback: 'Skill check',
                        ),
                        style: Act0ShellTokensV1.sectionTitle,
                      ),
                    ),
                    Text(
                      '${questions.length + 1}/${questions.length + 1}',
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  _placementCopyV1(
                    context,
                    en: 'One short live check.',
                    ru: 'Одна короткая живая проверка.',
                  ),
                  style: Act0ShellTokensV1.cardTitle,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  _placementCopyV1(
                    context,
                    en: 'Answer a few table reads so Sharky can place you better.',
                    ru: 'Ответь на несколько чтений стола, и Шарки точнее выберет старт.',
                  ),
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final question = questions[currentQuestionIndex];
    final selectedIds =
        selectedOptionIds[question.questionId] ?? const <String>{};
    final selectedCount = selectedIds.length;
    final keepFullSupportCopy = _placementKeepFullSupportCopyV1(
      question.questionId,
    );
    final choiceLabel = question.allowsMultiple
        ? 'Choose what fits'
        : 'Choose one';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: Container(
        key: Key('act0_shell_placement_question_${question.questionId}'),
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
        decoration:
            Act0ShellTokensV1.surfaceDecoration(
              glow: true,
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.94),
              borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.24),
            ).copyWith(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Act0ShellTokensV1.primary.withValues(alpha: 0.07),
                  Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                  Act0ShellTokensV1.info.withValues(alpha: 0.06),
                ],
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('act0_shell_placement_back_arrow'),
                  onPressed: currentQuestionIndex == 0 ? null : onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Act0ShellTokensV1.primary,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapXs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.eyebrow ?? 'Placement profile',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    border: Border.all(
                      color: Act0ShellTokensV1.primary.withOpacity(0.22),
                    ),
                  ),
                  child: Text(
                    '${currentQuestionIndex + 1}/${questions.length}',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Text(question.title, style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              question.subtitle,
              style: Act0ShellTokensV1.muted,
              maxLines: keepFullSupportCopy ? null : 2,
              overflow: keepFullSupportCopy ? null : TextOverflow.fade,
            ),
            if (keepFullSupportCopy && question.helper != null) ...[
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                question.helper!,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
            ],
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              spacing: Act0ShellTokensV1.gapSm,
              runSpacing: Act0ShellTokensV1.gapSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  choiceLabel,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
                if (question.allowsMultiple)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.gold.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.gold.withOpacity(0.24),
                      ),
                    ),
                    child: Text(
                      '$selectedCount selected',
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.gold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            for (final option in question.options) ...[
              _PlacementOptionButtonV1(
                option: option,
                selected: selectedIds.contains(option.optionId),
                multiSelect: question.allowsMultiple,
                showBadge: keepFullSupportCopy,
                showSubtitle: keepFullSupportCopy,
                onTap: () => onSelectOption(question, option.optionId),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlacementIntroViewV1 extends StatelessWidget {
  const _PlacementIntroViewV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_placement_intro_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _placementAtomV1(
              context,
              'placement_intro_route_check',
              fallback: 'Route check',
            ),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _placementCopyV1(
              context,
              en: 'A few fast answers help Sharky choose your first hand.',
              ru: 'Пара быстрых ответов помогут Шарки выбрать твою первую раздачу.',
            ),
            style: Act0ShellTokensV1.screenTitle,
          ),
        ],
      ),
    );
  }
}

class _PlacementInstructionBlocksV1 extends StatelessWidget {
  const _PlacementInstructionBlocksV1({
    required this.text,
    required this.keyBase,
    required this.style,
  });

  final String text;
  final String keyBase;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final blocks = act0BuildInstructionBlocksV1(text: text, compact: true);
    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }
    return KeyedSubtree(
      key: Key(keyBase),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < blocks.length; index++) ...[
            if (index > 0) const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              blocks[index],
              key: Key('${keyBase}_block_$index'),
              style: style,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlacementResultViewV1 extends StatelessWidget {
  const _PlacementResultViewV1({required this.result});

  final Act0PlacementResultV1 result;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('act0_shell_placement_result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlacementSectionCardV1(
          key: const Key('act0_shell_placement_start_handoff'),
          borderColor: _placementToneForResult(result).withOpacity(0.34),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _placementCopyV1(context, en: 'Your start', ru: 'Твой старт'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: _placementToneForResult(result),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                '${_placementCopyV1(context, en: 'Your start:', ru: 'Твой старт:')} ${result.levelLabel}',
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                _placementCompactReasonLineV1(context, result),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                '${_placementCopyV1(context, en: 'First hand:', ru: 'Первая раздача:')} ${_firstRepProofLineV1(result)}',
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                '${_placementCopyV1(context, en: 'Open with:', ru: 'Начни с:')} ${result.recommendedTitle}',
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _placementCompactReasonLineV1(
  BuildContext context,
  Act0PlacementResultV1 result,
) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => _placementCopyV1(
      context,
      en: 'Start from the table itself before any faster decision work.',
      ru: 'Начни с самого стола, прежде чем ускорять решения.',
    ),
    Act0PlacementResultLevelV1.rustyBeginner => _placementCopyV1(
      context,
      en: 'Start with hand flow before speed.',
      ru: 'Сначала верни ясный ход раздачи, потом скорость.',
    ),
    Act0PlacementResultLevelV1.readyForBasics => _placementCopyV1(
      context,
      en: 'Start on action basics while the table structure stays visible.',
      ru: 'Начни с базовых действий, пока структура стола остаётся ясной.',
    ),
  };
}

Act0SharkyMoodV1 _placementMoodForResult(Act0PlacementResultV1 result) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => Act0SharkyMoodV1.thinking,
    Act0PlacementResultLevelV1.rustyBeginner => Act0SharkyMoodV1.repair,
    Act0PlacementResultLevelV1.readyForBasics => Act0SharkyMoodV1.happy,
  };
}

Color _placementToneForResult(Act0PlacementResultV1 result) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => Act0ShellTokensV1.info,
    Act0PlacementResultLevelV1.rustyBeginner => Act0ShellTokensV1.gold,
    Act0PlacementResultLevelV1.readyForBasics => Act0ShellTokensV1.primary,
  };
}

class _PlacementSectionCardV1 extends StatelessWidget {
  const _PlacementSectionCardV1({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Act0ShellTokensV1.gapMd),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface2,
            borderColor: borderColor ?? Act0ShellTokensV1.border,
          ).copyWith(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.white.withOpacity(0.015),
                Act0ShellTokensV1.surface2,
                Act0ShellTokensV1.surface.withOpacity(0.92),
              ],
            ),
          ),
      child: child,
    );
  }
}

class _PlacementResultActionBarV1 extends StatelessWidget {
  const _PlacementResultActionBarV1({
    required this.onStartRecommended,
    required this.onStartFromZero,
  });

  final VoidCallback onStartRecommended;
  final VoidCallback onStartFromZero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapSm,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapMd,
      ),
      decoration: Act0ShellTokensV1.glassDecoration(top: true).copyWith(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Act0ShellTokensV1.surface2.withOpacity(0.96),
            Act0ShellTokensV1.surface.withOpacity(0.98),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _placementAtomV1(
              context,
              'placement_result_your_start_is_ready',
              fallback: 'Your start is ready.',
            ),
            textAlign: TextAlign.center,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          FilledButton(
            key: const Key('act0_shell_placement_start_recommended'),
            onPressed: onStartRecommended,
            style: Act0ShellTokensV1.primaryButtonStyle(),
            child: Text(
              _placementAtomV1(
                context,
                'placement_sheet_start_first_hand',
                fallback: 'Start first hand',
              ),
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          OutlinedButton(
            key: const Key('act0_shell_placement_start_zero'),
            onPressed: onStartFromZero,
            style: Act0ShellTokensV1.quietButtonStyle(),
            child: Text(
              _placementAtomV1(
                context,
                'placement_sheet_start_from_zero',
                fallback: 'Start from zero',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementFlowActionBarV1 extends StatelessWidget {
  const _PlacementFlowActionBarV1({
    required this.title,
    required this.buttonKey,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final Key buttonKey;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_placement_flow_action_bar'),
      decoration: Act0ShellTokensV1.glassDecoration(top: true).copyWith(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Act0ShellTokensV1.surface2.withOpacity(0.96),
            Act0ShellTokensV1.surface.withOpacity(0.98),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapSm,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapSm,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Act0ShellTokensV1.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            FilledButton(
              key: buttonKey,
              onPressed: onPressed,
              style: Act0ShellTokensV1.primaryButtonStyle(),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

String _firstRepProofLineV1(Act0PlacementResultV1 result) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer =>
      'By the end of the first hand, seats, blinds, and turn order should stop feeling random.',
    Act0PlacementResultLevelV1.rustyBeginner =>
      'By the end of the first hand, the hand should feel connected again from preflop to river.',
    Act0PlacementResultLevelV1.readyForBasics =>
      'By the end of the first hand, action words should attach to real table moments instead of floating as terms.',
  };
}

class _PlacementHeroV1 extends StatelessWidget {
  const _PlacementHeroV1({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final localeIsRu = _isRuLocaleV1(context);
    return Container(
      key: const Key('act0_shell_placement_hero'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.primary.withOpacity(0.22),
            Act0ShellTokensV1.info.withOpacity(0.08),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.primary.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Act0ShellScreenHeaderV1(
        eyebrow: localeIsRu ? 'Быстрый старт' : 'Quick start',
        title: title,
        subtitle: subtitle,
        trailing: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.primary,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Act0ShellTokensV1.primary.withOpacity(0.28),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_alt_rounded,
            color: Act0ShellTokensV1.onPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _PlacementProgressV1 extends StatelessWidget {
  const _PlacementProgressV1({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            child: LinearProgressIndicator(
              minHeight: Act0ShellTokensV1.progressHeight,
              value: current / total,
              backgroundColor: Act0ShellTokensV1.surface3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Act0ShellTokensV1.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Text(
          '$current/$total',
          style: Act0ShellTokensV1.label.copyWith(
            color: Act0ShellTokensV1.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PlacementResultChipV1 extends StatelessWidget {
  const _PlacementResultChipV1({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 92, maxWidth: 168),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.body,
          ),
        ],
      ),
    );
  }
}

class _PlacementSignalPillV1 extends StatelessWidget {
  const _PlacementSignalPillV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.20)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PlacementStepLineV1 extends StatelessWidget {
  const _PlacementStepLineV1({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Act0ShellTokensV1.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Act0ShellTokensV1.muted)),
      ],
    );
  }
}

class _PlacementOptionButtonV1 extends StatelessWidget {
  const _PlacementOptionButtonV1({
    required this.option,
    required this.selected,
    required this.multiSelect,
    required this.showBadge,
    required this.showSubtitle,
    required this.onTap,
  });

  final Act0PlacementOptionV1 option;
  final bool selected;
  final bool multiSelect;
  final bool showBadge;
  final bool showSubtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('act0_shell_placement_option_${option.optionId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
        decoration: Act0ShellTokensV1.surfaceDecoration(
          borderColor: selected
              ? Act0ShellTokensV1.primary
              : Act0ShellTokensV1.border,
          color: selected
              ? Act0ShellTokensV1.primaryDark
              : Act0ShellTokensV1.surface2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? Act0ShellTokensV1.primary.withOpacity(0.14)
                    : Act0ShellTokensV1.surface3,
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusBase,
                ),
                border: Border.all(
                  color: selected
                      ? Act0ShellTokensV1.primary.withOpacity(0.32)
                      : Act0ShellTokensV1.border,
                ),
              ),
              child: Icon(
                option.icon ?? Icons.label_rounded,
                size: 18,
                color: selected
                    ? Act0ShellTokensV1.primary
                    : Act0ShellTokensV1.textMuted,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: Act0ShellTokensV1.body,
                        ),
                      ),
                      if (showBadge && option.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Act0ShellTokensV1.info.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusPill,
                            ),
                            border: Border.all(
                              color: Act0ShellTokensV1.info.withOpacity(0.24),
                            ),
                          ),
                          child: Text(
                            option.badge!,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.info,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (showSubtitle && option.subtitle != null) ...[
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(option.subtitle!, style: Act0ShellTokensV1.muted),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            Icon(
              multiSelect
                  ? (selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded)
                  : (selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded),
              color: selected
                  ? Act0ShellTokensV1.primary
                  : Act0ShellTokensV1.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacementCategoryRowV1 extends StatelessWidget {
  const _PlacementCategoryRowV1({
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<String> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Act0ShellTokensV1.label.copyWith(color: color)),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Wrap(
          spacing: Act0ShellTokensV1.gapSm,
          runSpacing: Act0ShellTokensV1.gapSm,
          children: [
            for (final value in values)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapSm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(color: color.withOpacity(0.32)),
                ),
                child: Text(
                  value,
                  style: Act0ShellTokensV1.muted.copyWith(color: color),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PlacementCompactTagV1 extends StatelessWidget {
  const _PlacementCompactTagV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PlacementPlanCardV1 extends StatelessWidget {
  const _PlacementPlanCardV1({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: Act0ShellTokensV1.gold.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.gold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: Text(
              '$index',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted,
            ),
          ),
        ],
      ),
    );
  }
}
