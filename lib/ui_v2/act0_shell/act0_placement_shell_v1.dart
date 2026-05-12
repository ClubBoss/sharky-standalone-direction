import 'package:flutter/material.dart';
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

class Act0PlacementShellV1 extends StatelessWidget {
  const Act0PlacementShellV1({
    super.key,
    required this.questions,
    required this.showIntro,
    required this.currentQuestionIndex,
    required this.selectedOptionIds,
    required this.result,
    required this.trialPreviewSelected,
    required this.onSelectOption,
    required this.onStartPlacement,
    required this.onBack,
    required this.onNext,
    required this.onStartDiagnostic,
    required this.onStartRecommended,
    required this.onStartFromZero,
    required this.onStartTrialPreview,
  });

  final List<Act0PlacementQuestionV1> questions;
  final bool showIntro;
  final int currentQuestionIndex;
  final Map<String, Set<String>> selectedOptionIds;
  final Act0PlacementResultV1? result;
  final bool trialPreviewSelected;
  final void Function(Act0PlacementQuestionV1 question, String optionId)
  onSelectOption;
  final VoidCallback onStartPlacement;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onStartDiagnostic;
  final VoidCallback onStartRecommended;
  final VoidCallback onStartFromZero;
  final VoidCallback onStartTrialPreview;

  @override
  Widget build(BuildContext context) {
    final localeIsRu = _isRuLocaleV1(context);
    final placementResult = result;
    if (placementResult == null) {
      final currentQuestion = currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;
      final currentQuestionSelections = currentQuestion == null
          ? const <String>{}
          : selectedOptionIds[currentQuestion.questionId] ?? const <String>{};
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
              padding: const EdgeInsets.fromLTRB(
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.gapMd,
                Act0ShellTokensV1.pageX,
                132,
              ),
              children: [
                _PlacementHeroV1(
                  title: _placementCopyV1(
                    context,
                    en: 'Find your start',
                    ru: 'Найди свой старт',
                  ),
                  subtitle: _placementCopyV1(
                    context,
                    en: 'A few fast answers, then Sharky picks the route.',
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
                          key: ValueKey<String>('act0_shell_placement_intro'),
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
          _PlacementFlowActionBarV1(
            title: showIntro
                ? (localeIsRu
                      ? 'Две минуты. Потом Шарки подберёт старт.'
                      : 'Two minutes. Then Sharky places you.')
                : currentQuestionIndex >= questions.length
                ? (localeIsRu
                      ? 'Один короткий живой чек — и маршрут готов.'
                      : 'One short live check, then your route is ready.')
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
                : currentQuestionIndex >= questions.length
                ? (localeIsRu ? 'Начать проверку' : 'Start skill check')
                : (localeIsRu ? 'Продолжить' : 'Continue'),
            onPressed: showIntro
                ? onStartPlacement
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
            padding: const EdgeInsets.fromLTRB(
              Act0ShellTokensV1.pageX,
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.pageX,
              116,
            ),
            children: [
              _PlacementHeroV1(
                title: _placementCopyV1(
                  context,
                  en: 'Find your start',
                  ru: 'Найди свой старт',
                ),
                subtitle: _placementCopyV1(
                  context,
                  en: 'A few fast answers, then Sharky picks the route.',
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
        _PlacementResultActionBarV1(
          result: placementResult,
          trialPreviewSelected: trialPreviewSelected,
          onStartRecommended: onStartRecommended,
          onStartFromZero: onStartFromZero,
          onStartTrialPreview: onStartTrialPreview,
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
                    const Expanded(
                      child: Text(
                        'Skill check',
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
                  'One short live check. Then Sharky locks the first route.',
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _PlacementSectionCardV1(
            key: const Key('act0_shell_placement_ready_steps'),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Three fast reads', style: Act0ShellTokensV1.cardTitle),
                SizedBox(height: Act0ShellTokensV1.gapSm),
                _PlacementStepLineV1(
                  icon: Icons.person_search_rounded,
                  label: 'Table read and seat orientation.',
                ),
                SizedBox(height: 10),
                _PlacementStepLineV1(
                  icon: Icons.view_kanban_rounded,
                  label: 'Board and street basics.',
                ),
                SizedBox(height: 10),
                _PlacementStepLineV1(
                  icon: Icons.alt_route_rounded,
                  label: 'Action order once the hand starts moving.',
                ),
                SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  'Then you land in one route that fits and opens fast.',
                  style: Act0ShellTokensV1.muted,
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
    final choiceLabel = question.allowsMultiple
        ? 'Choose anything that fits'
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
            Text(question.subtitle, style: Act0ShellTokensV1.muted),
            if (question.helper != null) ...[
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('act0_shell_placement_intro_card'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placement',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.primary,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              const Text(
                'Fast route in. No long setup.',
                style: Act0ShellTokensV1.screenTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                'Sharky uses this to choose your first route and skip the wrong start.',
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _PlacementSectionCardV1(
          key: const Key('act0_shell_placement_intro_for_who'),
          borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What you get', style: Act0ShellTokensV1.cardTitle),
              SizedBox(height: Act0ShellTokensV1.gapSm),
              _PlacementStepLineV1(
                icon: Icons.route_rounded,
                label: 'One clear start instead of a generic opener.',
              ),
              SizedBox(height: 10),
              _PlacementStepLineV1(
                icon: Icons.play_circle_rounded,
                label: 'One short live check built from real spots.',
              ),
              SizedBox(height: 10),
              _PlacementStepLineV1(
                icon: Icons.looks_3_rounded,
                label: 'A route you can open immediately.',
              ),
            ],
          ),
        ),
      ],
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
        Container(
          key: const Key('act0_shell_placement_report_panel'),
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Act0ShellTokensV1.primary.withOpacity(0.24),
                Act0ShellTokensV1.info.withOpacity(0.16),
                Act0ShellTokensV1.gold.withOpacity(0.12),
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Act0ShellTokensV1.primary.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Act0ShellTokensV1.radiusXl - 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Act0ShellTokensV1.surface2,
                  Act0ShellTokensV1.surface,
                  Act0ShellTokensV1.placementReportSurface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Act0ShellTokensV1.primary.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusBase,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        size: 18,
                        color: Act0ShellTokensV1.primary,
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Expanded(
                      child: Text(
                        'Sharky read',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                        ),
                      ),
                    ),
                    Text(
                      '${result.levelLabel} · ${result.diagnosticCorrect}/${result.diagnosticTotal}',
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Text(result.summary, style: Act0ShellTokensV1.screenTitle),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  result.reportBody,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.text,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Act0ShellTokensV1.gapMd,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusLg,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.radar_rounded,
                        size: 16,
                        color: Act0ShellTokensV1.gold,
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Text(
                          result.reportHeadline,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Text(
                  result.routeTrustLine,
                  key: const Key('act0_shell_placement_destination_trust_line'),
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Act0SharkyGuideCardV1(
                  eyebrow: 'Sharky says',
                  line: result.coachLine,
                  mood: _placementMoodForResult(result),
                  tone: _placementToneForResult(result),
                  compact: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _PlacementSectionCardV1(
          key: const Key('act0_shell_placement_destination_card'),
          borderColor: Act0ShellTokensV1.primary.withOpacity(0.34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusBase,
                      ),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: Act0ShellTokensV1.primary,
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Text(
                    'First route',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(result.recommendedTitle, style: Act0ShellTokensV1.cardTitle),
              const SizedBox(height: 6),
              Text(
                result.recommendedReason,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text,
                  height: 1.4,
                ),
              ),
              if (result.firstSessionPlan.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                _PlacementMicroStepV1(
                  index: 1,
                  text: result.firstSessionPlan.first,
                ),
              ],
              if (result.firstSessionPlan.length > 1) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Container(
                  key: const Key('act0_shell_placement_next_10_block'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface,
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusLg,
                    ),
                    border: Border.all(
                      color: Act0ShellTokensV1.info.withOpacity(0.24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Right after that',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.info,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.firstSessionPlan[1],
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _PlacementSectionCardV1(
          key: const Key('act0_shell_placement_skill_stats'),
          borderColor: Act0ShellTokensV1.border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.info.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusBase,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: Act0ShellTokensV1.info,
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core poker skills',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your first reads and action habits start here.',
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              Wrap(
                spacing: Act0ShellTokensV1.gapSm,
                runSpacing: Act0ShellTokensV1.gapSm,
                children: [
                  for (final stat in result.skillStats.take(4))
                    _PlacementSkillCardV1(stat: stat),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
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

class _PlacementMetricTileV1 extends StatelessWidget {
  const _PlacementMetricTileV1({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 102, maxWidth: 168),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: accent.withOpacity(0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: accent)),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(value, style: Act0ShellTokensV1.body),
        ],
      ),
    );
  }
}

class _PlacementResultActionBarV1 extends StatelessWidget {
  const _PlacementResultActionBarV1({
    required this.result,
    required this.trialPreviewSelected,
    required this.onStartRecommended,
    required this.onStartFromZero,
    required this.onStartTrialPreview,
  });

  final Act0PlacementResultV1 result;
  final bool trialPreviewSelected;
  final VoidCallback onStartRecommended;
  final VoidCallback onStartFromZero;
  final VoidCallback onStartTrialPreview;

  void _showRecommendedPathSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlacementRecommendedPathSheetV1(
        result: result,
        trialPreviewSelected: trialPreviewSelected,
        onStartRecommended: onStartRecommended,
        onStartFromZero: onStartFromZero,
        onStartTrialPreview: onStartTrialPreview,
      ),
    );
  }

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
            'Your route is ready.',
            textAlign: TextAlign.center,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.text,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          FilledButton(
            key: const Key('act0_shell_placement_open_recommended_path'),
            onPressed: () => _showRecommendedPathSheet(context),
            style: Act0ShellTokensV1.primaryButtonStyle(),
            child: const Text('See first route'),
          ),
        ],
      ),
    );
  }
}

class _PlacementRecommendedPathSheetV1 extends StatelessWidget {
  const _PlacementRecommendedPathSheetV1({
    required this.result,
    required this.trialPreviewSelected,
    required this.onStartRecommended,
    required this.onStartFromZero,
    required this.onStartTrialPreview,
  });

  final Act0PlacementResultV1 result;
  final bool trialPreviewSelected;
  final VoidCallback onStartRecommended;
  final VoidCallback onStartFromZero;
  final VoidCallback onStartTrialPreview;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        key: const Key('act0_shell_placement_recommended_sheet'),
        margin: const EdgeInsets.only(top: 28),
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Act0ShellTokensV1.primary.withOpacity(0.22),
              Act0ShellTokensV1.info.withOpacity(0.14),
              Act0ShellTokensV1.gold.withOpacity(0.14),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.fromLTRB(
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapLg,
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapLg,
          ),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(27)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.surface3,
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapLg),
                Text(
                  'First route',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  result.recommendedTitle,
                  style: Act0ShellTokensV1.sectionTitle,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  result.recommendedReason,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.text,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapLg),
                _PlacementSectionCardV1(
                  borderColor: Act0ShellTokensV1.primary.withOpacity(0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First sessions',
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.gold,
                        ),
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      for (
                        var i = 0;
                        i < result.firstSessionPlan.length;
                        i++
                      ) ...[
                        _PlacementMicroStepV1(
                          index: i + 1,
                          text: result.firstSessionPlan[i],
                        ),
                        if (i < result.firstSessionPlan.length - 1)
                          const SizedBox(height: Act0ShellTokensV1.gapXs),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  result.routeTrustLine,
                  key: const Key('act0_shell_placement_recommended_trust_line'),
                  style: Act0ShellTokensV1.muted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _PlacementSectionCardV1(
                  borderColor: Act0ShellTokensV1.gold.withOpacity(0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Act0ShellTokensV1.gold,
                            size: 18,
                          ),
                          const SizedBox(width: Act0ShellTokensV1.gapSm),
                          Text(
                            'Premium trial',
                            style: Act0ShellTokensV1.cardTitle.copyWith(
                              color: Act0ShellTokensV1.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      Text(result.premiumPitch, style: Act0ShellTokensV1.muted),
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      for (final point in result.trialValuePoints.take(2)) ...[
                        _PlacementStepLineV1(
                          icon: Icons.check_circle_rounded,
                          label: point,
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (trialPreviewSelected) ...[
                        const SizedBox(height: Act0ShellTokensV1.gapXs),
                        const Text(
                          'Trial preview saved. You can still continue free.',
                          style: Act0ShellTokensV1.muted,
                        ),
                      ],
                      const SizedBox(height: Act0ShellTokensV1.gapSm),
                      OutlinedButton(
                        key: const Key('act0_shell_placement_trial_cta'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onStartTrialPreview();
                        },
                        style: Act0ShellTokensV1.quietButtonStyle(height: 40),
                        child: const Text('Preview 7-day trial'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapLg),
                FilledButton(
                  key: const Key('act0_shell_placement_start_recommended'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStartRecommended();
                  },
                  style: Act0ShellTokensV1.primaryButtonStyle(),
                  child: const Text('Start first rep'),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                OutlinedButton(
                  key: const Key('act0_shell_placement_start_zero'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStartFromZero();
                  },
                  style: Act0ShellTokensV1.quietButtonStyle(),
                  child: const Text('Start from zero'),
                ),
              ],
            ),
          ),
        ),
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

class _PlacementMiniBannerV1 extends StatelessWidget {
  const _PlacementMiniBannerV1({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Act0ShellTokensV1.primary, size: 18),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Text(
              text,
              style: Act0ShellTokensV1.body.copyWith(
                color: Act0ShellTokensV1.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Act0ShellTokensV1.screenTitle),
                const SizedBox(height: 2),
                Text(subtitle, style: Act0ShellTokensV1.muted),
              ],
            ),
          ),
        ],
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
    required this.onTap,
  });

  final Act0PlacementOptionV1 option;
  final bool selected;
  final bool multiSelect;
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
                      if (option.badge != null)
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
                  if (option.subtitle != null) ...[
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

class _PlacementMicroStepV1 extends StatelessWidget {
  const _PlacementMicroStepV1({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 24,
            height: 24,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementSkillCardV1 extends StatelessWidget {
  const _PlacementSkillCardV1({required this.stat});

  final Act0PlacementSkillStatV1 stat;

  @override
  Widget build(BuildContext context) {
    final tone = stat.locked
        ? Act0ShellTokensV1.textDim
        : stat.level >= 3
        ? Act0ShellTokensV1.primary
        : stat.level >= 2
        ? Act0ShellTokensV1.info
        : Act0ShellTokensV1.gold;

    return SizedBox(
      width: 154,
      child: InkWell(
        key: Key('act0_shell_placement_skill_stat_${stat.label}'),
        onTap: () => _showPlacementSkillDetailsSheet(context, stat),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
            border: Border.all(
              color: stat.locked
                  ? Act0ShellTokensV1.border
                  : tone.withOpacity(0.24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(stat.label, style: Act0ShellTokensV1.body),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapXs),
                  Icon(
                    stat.locked
                        ? Icons.lock_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: stat.locked ? Act0ShellTokensV1.textMuted : tone,
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                stat.locked ? 'Locked' : stat.levelLabel,
                style: Act0ShellTokensV1.label.copyWith(color: tone),
              ),
              const SizedBox(height: 6),
              Text(
                stat.locked ? 'Unlock later' : stat.nextLevelLabel,
                style: Act0ShellTokensV1.muted,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: stat.nextLevelProgress,
                  backgroundColor: Act0ShellTokensV1.surface3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stat.locked ? Act0ShellTokensV1.textDim : tone,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPlacementSkillDetailsSheet(
  BuildContext context,
  Act0PlacementSkillStatV1 stat,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface,
            borderColor: Act0ShellTokensV1.info.withOpacity(0.24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.label,
                      style: Act0ShellTokensV1.sectionTitle,
                    ),
                  ),
                  Text(
                    stat.locked
                        ? 'Locked'
                        : '${stat.levelLabel}  ${stat.nextLevelLabel}',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: stat.locked
                          ? Act0ShellTokensV1.textMuted
                          : Act0ShellTokensV1.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _PlacementSkillDetailBlockV1(
                title: 'What it means',
                text: stat.meaning,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _PlacementSkillDetailBlockV1(
                title: 'What it affects',
                text: stat.affects,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              _PlacementSkillDetailBlockV1(
                title: 'Why it matters',
                text: stat.whyImportant,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PlacementSkillDetailBlockV1 extends StatelessWidget {
  const _PlacementSkillDetailBlockV1({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Act0ShellTokensV1.label.copyWith(
            color: Act0ShellTokensV1.info,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Act0ShellTokensV1.muted.copyWith(
            color: Act0ShellTokensV1.text,
          ),
        ),
      ],
    );
  }
}
