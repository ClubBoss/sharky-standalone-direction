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
    questionId == 'experience' || questionId == 'confidence';

String _placementQuestionTitleV1(
  BuildContext context,
  Act0PlacementQuestionV1 question,
) {
  return switch (question.questionId) {
    'experience' => _placementCopyV1(
      context,
      en: 'Where are you starting from?',
      ru: 'С чего ты начинаешь?',
    ),
    'confidence' => _placementCopyV1(
      context,
      en: 'How should Sharky start?',
      ru: 'Как Шарки начать?',
    ),
    _ => question.title,
  };
}

String _placementQuestionSubtitleV1(
  BuildContext context,
  Act0PlacementQuestionV1 question,
) {
  return switch (question.questionId) {
    'experience' => _placementCopyV1(
      context,
      en: 'This is not a test. It only sets your pace.',
      ru: 'Это не тест. Так Шарки просто подберёт темп.',
    ),
    'confidence' => _placementCopyV1(
      context,
      en: 'Pick the start that feels easiest.',
      ru: 'Выбери самый простой старт.',
    ),
    _ => question.subtitle,
  };
}

String? _placementQuestionHelperV1(
  BuildContext context,
  Act0PlacementQuestionV1 question,
) {
  return switch (question.questionId) {
    'experience' => _placementCopyV1(
      context,
      en: 'No ranking. No pressure. Sharky can always start simple.',
      ru: 'Без рейтинга и давления. Шарки всегда может начать просто.',
    ),
    'confidence' => _placementCopyV1(
      context,
      en: 'No poker knowledge needed. Let Sharky choose if unsure.',
      ru: 'Знание покера не нужно. Если сомневаешься, пусть выберет Шарки.',
    ),
    _ => question.helper,
  };
}

String _placementOptionLabelV1(
  BuildContext context,
  Act0PlacementQuestionV1 question,
  Act0PlacementOptionV1 option,
) {
  if (question.questionId == 'experience') {
    return switch (option.optionId) {
      'new' => _placementCopyV1(
        context,
        en: 'I’m new to poker',
        ru: 'Я новичок в покере',
      ),
      'friends' => _placementCopyV1(
        context,
        en: 'I’ve played casually',
        ru: 'Я играл казуально',
      ),
      'watching' => _placementCopyV1(
        context,
        en: 'I watch poker but freeze in hands',
        ru: 'Я смотрю покер, но теряюсь в раздачах',
      ),
      'online' => _placementCopyV1(
        context,
        en: 'I’ve played online or live',
        ru: 'Я играл онлайн или вживую',
      ),
      _ => option.label,
    };
  }
  if (question.questionId == 'confidence') {
    return switch (option.optionId) {
      'rules' => _placementCopyV1(
        context,
        en: 'Start from zero',
        ru: 'Начать с нуля',
      ),
      'cards' => _placementCopyV1(
        context,
        en: 'Try one quick check',
        ru: 'Попробовать быструю проверку',
      ),
      'decisions' => _placementCopyV1(
        context,
        en: 'Move a little faster',
        ru: 'Идти чуть быстрее',
      ),
      'board' => _placementCopyV1(
        context,
        en: 'Let Sharky choose',
        ru: 'Пусть Шарки выберет',
      ),
      'pressure' => _placementCopyV1(
        context,
        en: 'Betting pressure',
        ru: 'Давление ставок',
      ),
      _ => option.label,
    };
  }
  return option.label;
}

List<Act0PlacementOptionV1> _placementVisibleOptionsV1(
  Act0PlacementQuestionV1 question,
) {
  if (question.questionId == 'confidence') {
    return question.options
        .where((option) => option.optionId != 'pressure')
        .toList(growable: false);
  }
  return question.options;
}

String? _placementOptionSubtitleV1(
  BuildContext context,
  Act0PlacementQuestionV1 question,
  Act0PlacementOptionV1 option,
) {
  if (question.questionId == 'experience') {
    return switch (option.optionId) {
      'new' => _placementCopyV1(
        context,
        en: 'Start from zero.',
        ru: 'Начать с нуля.',
      ),
      'friends' => _placementCopyV1(
        context,
        en: 'Build structure without rushing.',
        ru: 'Собрать структуру без спешки.',
      ),
      'watching' => _placementCopyV1(
        context,
        en: 'Turn passive knowledge into table decisions.',
        ru: 'Превратить пассивные знания в решения за столом.',
      ),
      'online' => _placementCopyV1(
        context,
        en: 'Move faster through the basics.',
        ru: 'Пройти основы быстрее.',
      ),
      _ => option.subtitle,
    };
  }
  if (question.questionId == 'confidence') {
    return switch (option.optionId) {
      'rules' => _placementCopyV1(
        context,
        en: 'Learn the table language first.',
        ru: 'Сначала язык стола.',
      ),
      'cards' => _placementCopyV1(
        context,
        en: 'One short read, no score.',
        ru: 'Один короткий разбор без оценки.',
      ),
      'decisions' => _placementCopyV1(
        context,
        en: 'Skip basics if they feel easy.',
        ru: 'Пропустить основы, если они лёгкие.',
      ),
      'board' => _placementCopyV1(
        context,
        en: 'Safe start, no pressure.',
        ru: 'Безопасный старт без давления.',
      ),
      _ => option.subtitle,
    };
  }
  return option.subtitle;
}

enum _PlacementLaunchStepV1 { answer, quickCheck, firstHand }

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
                      Container(
                        key: const Key(
                          'act0_shell_placement_route_check_frame',
                        ),
                        padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
                        decoration: Act0ShellTokensV1.surfaceDecoration(
                          color: Act0ShellTokensV1.surface2.withValues(
                            alpha: 0.52,
                          ),
                          borderColor: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.12,
                          ),
                        ),
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
                                en: 'Answer two quick questions. Then Sharky opens the first useful hand.',
                                ru: 'Ответь на два коротких вопроса. Затем Шарки откроет первую полезную раздачу.',
                              ),
                            ),
                            const SizedBox(height: Act0ShellTokensV1.gapSm),
                            _PlacementLaunchPathV1(
                              currentStep:
                                  showIntro ||
                                      currentQuestionIndex < questions.length
                                  ? _PlacementLaunchStepV1.answer
                                  : _PlacementLaunchStepV1.quickCheck,
                            ),
                          ],
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
                      ? 'Около двух минут. Потом первый урок будет готов.'
                      : 'About two minutes. Then your first lesson is ready.')
                : explicitBeginnerStart
                ? (localeIsRu
                      ? 'Шарки начнёт просто.'
                      : 'Sharky will start simple.')
                : currentQuestionIndex >= questions.length
                ? (localeIsRu
                      ? 'Три короткие проверки — и первая раздача готова.'
                      : 'Three short checks, then your first hand is ready.')
                : currentQuestion?.allowsMultiple == true
                ? (localeIsRu ? 'Выбери то, что подходит.' : 'Pick what fits.')
                : currentQuestion?.questionId == 'experience'
                ? (localeIsRu
                      ? 'Если сомневаешься, выбери «Я новичок в покере».'
                      : 'If unsure, choose “I’m new to poker.”')
                : (localeIsRu
                      ? 'Выбери то, что ближе всего.'
                      : 'Choose what feels closest.'),
            buttonKey: Key(
              showIntro
                  ? 'act0_shell_placement_intro_cta'
                  : currentQuestionIndex >= questions.length
                  ? 'act0_shell_placement_start_diagnostic'
                  : 'act0_shell_placement_next_cta',
            ),
            buttonLabel: showIntro
                ? (localeIsRu ? 'Найти мой старт' : 'Find my start')
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
                        en: 'Your first hand is ready.',
                        ru: 'Первая раздача готова.',
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapSm),
                    const _PlacementLaunchPathV1(
                      currentStep: _PlacementLaunchStepV1.firstHand,
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
                          fallback: 'Quick table check',
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
                    en: 'Three short checks before your first hand.',
                    ru: 'Три короткие проверки перед первой раздачей.',
                  ),
                  style: Act0ShellTokensV1.cardTitle,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  _placementCopyV1(
                    context,
                    en: 'No score. Just read what is visible.',
                    ru: 'Без оценки. Просто прочитай то, что видно.',
                  ),
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.text,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _PlacementLaunchSupportCardV1(
                  key: const Key('act0_shell_placement_ready_preview'),
                  tone: Act0ShellTokensV1.info,
                  title: _placementCopyV1(
                    context,
                    en: 'What you’ll do',
                    ru: 'Что ты сделаешь',
                  ),
                  body: _placementCopyV1(
                    context,
                    en: 'Read hand, board, and first actions.',
                    ru: 'Прочитай руку, борд и первые действия.',
                  ),
                  chips: <String>[
                    _placementCopyV1(
                      context,
                      en: 'Short checks',
                      ru: 'Короткие проверки',
                    ),
                    _placementCopyV1(context, en: 'No score', ru: 'Без оценки'),
                    _placementCopyV1(
                      context,
                      en: 'First hand after',
                      ru: 'Дальше первая раздача',
                    ),
                  ],
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
    final displayTitle = _placementQuestionTitleV1(context, question);
    final displaySubtitle = _placementQuestionSubtitleV1(context, question);
    final displayHelper = _placementQuestionHelperV1(context, question);
    final displayOptions = _placementVisibleOptionsV1(question);
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
            Text(displayTitle, style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              displaySubtitle,
              style: Act0ShellTokensV1.muted,
              maxLines: keepFullSupportCopy ? null : 2,
              overflow: keepFullSupportCopy ? null : TextOverflow.fade,
            ),
            if (keepFullSupportCopy && displayHelper != null) ...[
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                displayHelper,
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
            for (final option in displayOptions) ...[
              _PlacementOptionButtonV1(
                option: option,
                displayLabel: _placementOptionLabelV1(
                  context,
                  question,
                  option,
                ),
                displaySubtitle: _placementOptionSubtitleV1(
                  context,
                  question,
                  option,
                ),
                selected: selectedIds.contains(option.optionId),
                multiSelect: question.allowsMultiple,
                showBadge: question.questionId == 'experience',
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
              en: 'Fast start, no exam.',
              ru: 'Быстрый старт без экзамена.',
            ),
            style: Act0ShellTokensV1.screenTitle,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            _placementCopyV1(
              context,
              en: 'No long setup before the first hand.',
              ru: 'Без долгой настройки перед первой раздачей.',
            ),
            key: const Key('act0_shell_placement_intro_support'),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _PlacementLaunchSupportCardV1(
            key: const Key('act0_shell_placement_intro_preview'),
            tone: Act0ShellTokensV1.primary,
            title: _placementCopyV1(
              context,
              en: 'No exam. Just your starting point.',
              ru: 'Без экзамена. Только твоя точка старта.',
            ),
            body: _placementCopyV1(
              context,
              en: 'Two answers and one short check are enough to open the first hand.',
              ru: 'Двух ответов и короткого чека достаточно, чтобы открыть первую раздачу.',
            ),
            chips: <String>[
              _placementCopyV1(
                context,
                en: 'Beginner-safe',
                ru: 'Безопасно для новичка',
              ),
              _placementCopyV1(
                context,
                en: 'Fast handoff',
                ru: 'Быстрый переход',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlacementLaunchPathV1 extends StatelessWidget {
  const _PlacementLaunchPathV1({required this.currentStep});

  final _PlacementLaunchStepV1 currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = <(_PlacementLaunchStepV1, String)>[
      (
        _PlacementLaunchStepV1.answer,
        _placementCopyV1(context, en: 'Answer', ru: 'Ответы'),
      ),
      (
        _PlacementLaunchStepV1.quickCheck,
        _placementCopyV1(context, en: 'Quick check', ru: 'Быстрая проверка'),
      ),
      (
        _PlacementLaunchStepV1.firstHand,
        _placementCopyV1(context, en: 'First hand', ru: 'Первая раздача'),
      ),
    ];
    final currentIndex = steps.indexWhere((step) => step.$1 == currentStep);
    return Container(
      key: const Key('act0_shell_placement_launch_path'),
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.84),
        borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.16),
      ),
      child: Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: _PlacementLaunchStepChipV1(
                label: steps[index].$2,
                state: index < currentIndex
                    ? _PlacementLaunchVisualStateV1.complete
                    : index == currentIndex
                    ? _PlacementLaunchVisualStateV1.active
                    : _PlacementLaunchVisualStateV1.upcoming,
              ),
            ),
            if (index < steps.length - 1)
              Container(
                width: Act0ShellTokensV1.gapMd,
                height: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapXs,
                ),
                color: index < currentIndex
                    ? Act0ShellTokensV1.primary.withValues(alpha: 0.34)
                    : Act0ShellTokensV1.border,
              ),
          ],
        ],
      ),
    );
  }
}

enum _PlacementLaunchVisualStateV1 { upcoming, active, complete }

class _PlacementLaunchStepChipV1 extends StatelessWidget {
  const _PlacementLaunchStepChipV1({required this.label, required this.state});

  final String label;
  final _PlacementLaunchVisualStateV1 state;

  @override
  Widget build(BuildContext context) {
    final tone = switch (state) {
      _PlacementLaunchVisualStateV1.complete => Act0ShellTokensV1.primary,
      _PlacementLaunchVisualStateV1.active => Act0ShellTokensV1.gold,
      _PlacementLaunchVisualStateV1.upcoming => Act0ShellTokensV1.textMuted,
    };
    final background = switch (state) {
      _PlacementLaunchVisualStateV1.complete => tone.withValues(alpha: 0.14),
      _PlacementLaunchVisualStateV1.active => tone.withValues(alpha: 0.16),
      _PlacementLaunchVisualStateV1.upcoming =>
        Act0ShellTokensV1.surface3.withValues(alpha: 0.72),
    };
    final border = switch (state) {
      _PlacementLaunchVisualStateV1.complete => tone.withValues(alpha: 0.28),
      _PlacementLaunchVisualStateV1.active => tone.withValues(alpha: 0.30),
      _PlacementLaunchVisualStateV1.upcoming => Act0ShellTokensV1.border,
    };
    final icon = switch (state) {
      _PlacementLaunchVisualStateV1.complete => Icons.check_rounded,
      _PlacementLaunchVisualStateV1.active => Icons.play_arrow_rounded,
      _PlacementLaunchVisualStateV1.upcoming => Icons.circle_outlined,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: Act0ShellTokensV1.gapXs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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

class _PlacementLaunchSupportCardV1 extends StatelessWidget {
  const _PlacementLaunchSupportCardV1({
    super.key,
    required this.tone,
    required this.title,
    required this.body,
    required this.chips,
  });

  final Color tone;
  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.68),
            borderColor: tone.withValues(alpha: 0.18),
          ).copyWith(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                tone.withValues(alpha: 0.08),
                Act0ShellTokensV1.surface.withValues(alpha: 0.76),
                Act0ShellTokensV1.surface2.withValues(alpha: 0.92),
              ],
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0ShellTokensV1.label.copyWith(color: tone)),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            body,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              spacing: Act0ShellTokensV1.gapSm,
              runSpacing: Act0ShellTokensV1.gapSm,
              children: [
                for (final chip in chips)
                  _PlacementIntroChipV1(label: chip, tone: tone),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlacementIntroChipV1 extends StatelessWidget {
  const _PlacementIntroChipV1({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
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
    final focusChips = _placementFocusChipsV1(result);
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
                _placementCopyV1(
                  context,
                  en: 'Sharky found your start',
                  ru: 'Шарки нашёл твой старт',
                ),
                style: Act0ShellTokensV1.label.copyWith(
                  color: _placementToneForResult(result),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                result.levelLabel,
                key: const Key('act0_shell_placement_result_level'),
                style: Act0ShellTokensV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                result.recommendedReason,
                key: const Key('act0_shell_placement_recommended_reason'),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                _placementRouteTrustLineV1(context, result),
                key: const Key('act0_shell_placement_destination_trust_line'),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                  height: 1.38,
                ),
              ),
              if (focusChips.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                KeyedSubtree(
                  key: const Key('act0_shell_placement_focus_chips'),
                  child: Wrap(
                    spacing: Act0ShellTokensV1.gapSm,
                    runSpacing: Act0ShellTokensV1.gapSm,
                    children: [
                      for (final chip in focusChips)
                        _PlacementIntroChipV1(
                          label: chip,
                          tone: _placementToneForResult(result),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _PlacementLaunchSupportCardV1(
                key: const Key('act0_shell_placement_result_preview'),
                tone: _placementToneForResult(result),
                title: _placementCopyV1(
                  context,
                  en: 'Useful first hand ready',
                  ru: 'Полезная первая раздача готова',
                ),
                body: _placementCopyV1(
                  context,
                  en: 'It opens one table clue before the first lesson starts.',
                  ru: 'Она покажет одну подсказку стола перед первым уроком.',
                ),
                chips: <String>[
                  _placementCopyV1(
                    context,
                    en: 'Beginner-safe',
                    ru: 'Безопасно для новичка',
                  ),
                  _placementCopyV1(
                    context,
                    en: 'Fold, check, call, raise',
                    ru: 'Фолд, чек, колл, рейз',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<String> _placementFocusChipsV1(Act0PlacementResultV1 result) {
  final chips = <String>[];
  void addChip(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || chips.contains(trimmed)) {
      return;
    }
    chips.add(trimmed);
  }

  for (final strength in result.strengths.take(2)) {
    addChip(strength);
  }
  for (final weakSpot in result.weakSpots.take(1)) {
    addChip(weakSpot);
  }
  addChip(switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => 'Table basics',
    Act0PlacementResultLevelV1.rustyBeginner => 'Hand flow',
    Act0PlacementResultLevelV1.readyForBasics => 'Action basics',
  });
  return chips.take(4).toList(growable: false);
}

Color _placementToneForResult(Act0PlacementResultV1 result) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => Act0ShellTokensV1.info,
    Act0PlacementResultLevelV1.rustyBeginner => Act0ShellTokensV1.gold,
    Act0PlacementResultLevelV1.readyForBasics => Act0ShellTokensV1.primary,
  };
}

String _placementRouteTrustLineV1(
  BuildContext context,
  Act0PlacementResultV1 result,
) {
  return switch (result.level) {
    Act0PlacementResultLevelV1.newPlayer => _placementCopyV1(
      context,
      en: "We'll start with the table first, so the first hand stays clear.",
      ru: 'Начнем со стола, чтобы первая раздача оставалась понятной.',
    ),
    Act0PlacementResultLevelV1.rustyBeginner => _placementCopyV1(
      context,
      en: "We'll keep the hand flow visible before adding speed.",
      ru: 'Сначала удержим движение раздачи видимым, а скорость добавим позже.',
    ),
    Act0PlacementResultLevelV1.readyForBasics => _placementCopyV1(
      context,
      en: 'Your first hand will teach one table clue.',
      ru: 'Первая раздача научит одной подсказке стола.',
    ),
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
              fallback: 'Sharky found your start.',
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
                fallback: 'Start with the useful hand',
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
                fallback: 'Start from the beginning',
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
    required this.displayLabel,
    required this.displaySubtitle,
    required this.selected,
    required this.multiSelect,
    required this.showBadge,
    required this.showSubtitle,
    required this.onTap,
  });

  final Act0PlacementOptionV1 option;
  final String displayLabel;
  final String? displaySubtitle;
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
                          displayLabel,
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
                  if (showSubtitle && displaySubtitle != null) ...[
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(displaySubtitle!, style: Act0ShellTokensV1.muted),
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
