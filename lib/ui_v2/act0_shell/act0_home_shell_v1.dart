import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String _shellCopyV1(
  BuildContext context, {
  required String en,
  required String ru,
}) => _isRuLocaleV1(context) ? ru : en;

class Act0HomeShellV1 extends StatelessWidget {
  const Act0HomeShellV1({
    super.key,
    required this.state,
    this.currentLesson,
    this.pathProgressLabel,
    this.nextActionLabel = 'Continue',
    this.nextActionTitle,
    this.nextActionSubtitle,
    this.nextActionCtaLabel = 'Continue',
    this.nextActionHint,
    this.repairLabel = 'Review',
    this.repairHeadline,
    this.repairDetail,
    this.repairOutcome,
    this.repairCtaLabel,
    this.showRepairPanel = true,
    this.onStartRepair,
    this.dailyGoalValue,
    this.dailyGoalCtaLabel = 'Practice now →',
    this.sharkyOverride,
    this.onOpenDevMenu,
    this.onStartDailyDrill,
    required this.onContinue,
  });

  final Act0ShellStateV1 state;
  final Act0LessonCardV1? currentLesson;
  final String? pathProgressLabel;
  final String nextActionLabel;
  final String? nextActionTitle;
  final String? nextActionSubtitle;
  final String nextActionCtaLabel;
  final String? nextActionHint;
  final String repairLabel;
  final String? repairHeadline;
  final String? repairDetail;
  final String? repairOutcome;
  final String? repairCtaLabel;
  final bool showRepairPanel;
  final VoidCallback? onStartRepair;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final Act0SharkyCueV1? sharkyOverride;
  final VoidCallback? onOpenDevMenu;
  final VoidCallback? onStartDailyDrill;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final lesson = currentLesson ?? state.currentLesson;
    final title =
        nextActionTitle ?? act0LocalizedLessonTitleV1(context, lesson);
    final subtitle =
        nextActionSubtitle ?? act0LocalizedLessonSubtitleV1(context, lesson);
    final courseTitle = act0LocalizedWorldTitleV1(context, state.selectedWorld);
    final sharky = sharkyOverride ?? lesson.runner.sharky;
    final nextActionLabel = this.nextActionLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Continue', ru: 'Продолжить')
        : this.nextActionLabel;
    final nextActionCtaLabel = this.nextActionCtaLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Continue', ru: 'Продолжить')
        : this.nextActionCtaLabel;
    final repairLabel = this.repairLabel == 'Review'
        ? _shellCopyV1(context, en: 'Review', ru: 'Разбор')
        : this.repairLabel;
    final dailyGoalCtaLabel = this.dailyGoalCtaLabel == 'Practice now →'
        ? _shellCopyV1(context, en: 'Practice now →', ru: 'Начать практику →')
        : this.dailyGoalCtaLabel;
    return ListView(
      key: const Key('act0_shell_home_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shellCopyV1(context, en: 'Home', ru: 'Главная'),
                    style: Act0ShellTokensV1.screenTitle,
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  Text(
                    courseTitle,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (onOpenDevMenu != null)
              IconButton(
                key: const Key('act0_shell_home_dev_menu_button'),
                onPressed: onOpenDevMenu,
                icon: const Icon(Icons.more_horiz_rounded),
                color: Act0ShellTokensV1.muted.color,
                splashRadius: 18,
                tooltip: _shellCopyV1(
                  context,
                  en: 'Dev menu',
                  ru: 'Меню разработчика',
                ),
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -3,
                ),
              ),
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.heroDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('act0_shell_home_primary_tap_target'),
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXl,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Act0ShellTokensV1.primary,
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusMd,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Act0ShellTokensV1.primary.withValues(
                                      alpha: 0.38,
                                    ),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Act0ShellTokensV1.onPrimary,
                              ),
                            ),
                            const SizedBox(width: Act0ShellTokensV1.gapMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextActionLabel,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Act0ShellTokensV1.gapXs,
                                  ),
                                  Text(
                                    title,
                                    style: Act0ShellTokensV1.sectionTitle,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Act0ShellTokensV1.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          subtitle,
                          key: const Key(
                            'act0_shell_home_next_action_subtitle',
                          ),
                          style: Act0ShellTokensV1.muted,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              FilledButton(
                key: const Key('act0_shell_main_cta'),
                onPressed: onContinue,
                style: Act0ShellTokensV1.primaryButtonStyle(),
                child: Text(nextActionCtaLabel),
              ),
              if (nextActionHint != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  nextActionHint!,
                  key: const Key('act0_shell_home_cta_hint'),
                  style: Act0ShellTokensV1.muted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (showRepairPanel) ...[
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _HomeRepairCardV1(
            localeIsRu: _isRuLocaleV1(context),
            embedded: true,
            repairLabel: showRepairPanel ? repairLabel : null,
            repairHeadline: showRepairPanel ? repairHeadline : null,
            repairDetail: showRepairPanel ? repairDetail : null,
            repairOutcome: showRepairPanel ? repairOutcome : null,
            repairCtaLabel: showRepairPanel ? repairCtaLabel : null,
            onStartRepair: showRepairPanel ? onStartRepair : null,
          ),
        ],
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.64),
            borderColor: Act0ShellTokensV1.border.withValues(alpha: 0.44),
            glow: false,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shellCopyV1(
                  context,
                  en: 'Extra reps',
                  ru: 'Дополнительные репы',
                ),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.primary,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                _shellCopyV1(
                  context,
                  en: 'Play stays optional. The main route still lives in Learn.',
                  ru: 'Практика остаётся опциональной. Главный маршрут всё так же живёт в обучении.',
                ),
                key: const Key('act0_shell_home_optional_practice_hint'),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textDim,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _DailyGoalCardV1(
                localeIsRu: _isRuLocaleV1(context),
                state: state,
                dailyGoalValue: dailyGoalValue,
                dailyGoalCtaLabel: dailyGoalCtaLabel,
                onStartDailyDrill: onStartDailyDrill,
                subdued: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _HomeFooterSharkyLineV1(
          state: state,
          sharky: sharky,
          localeIsRu: _isRuLocaleV1(context),
        ),
      ],
    );
  }
}

String _dailyGoalSupportText(bool localeIsRu, String goalValue) {
  if (goalValue.startsWith('Streak saved')) {
    return localeIsRu
        ? 'Восстановление засчитано. Ритм на сегодня сохранён.'
        : 'Recovery earned. The rhythm stays alive today.';
  }
  if (goalValue.startsWith('Done') || goalValue.contains('3/3')) {
    return localeIsRu
        ? 'Цель на сегодня закрыта. Завтрашний старт уже готов.'
        : 'Goal complete. Tomorrow is already set up.';
  }
  if (goalValue.startsWith('0/')) {
    return localeIsRu
        ? 'Начни с одного чистого спота и задай ритм.'
        : 'Start one clean spot and let the rhythm begin.';
  }
  return localeIsRu
      ? 'Хороший старт. Ещё один чистый реп держит маршрут тёплым.'
      : 'Good start. One more clean rep keeps the route warm.';
}

String _dailyGoalTrustLineV1({
  required bool localeIsRu,
  required String goalValue,
  required int streakDays,
}) {
  if (goalValue.startsWith('Streak saved')) {
    return localeIsRu
        ? (streakDays > 0
              ? 'Ритм на $streakDays дн. сохранён.'
              : 'Импульс на завтра сохранён.')
        : (streakDays > 0
              ? '$streakDays day rhythm protected.'
              : 'Momentum protected for tomorrow.');
  }
  if (goalValue.startsWith('Done') || goalValue.contains('3/3')) {
    return localeIsRu
        ? (streakDays > 0
              ? 'Серия на $streakDays дн. в порядке. Завтра будет легче.'
              : 'Сегодняшний день засчитан. Завтра будет легче.')
        : (streakDays > 0
              ? '$streakDays day rhythm is safe. Tomorrow starts lighter.'
              : 'Today is banked. Tomorrow starts lighter.');
  }
  if (streakDays >= 7) {
    return localeIsRu
        ? '$streakDays дней стабильно.'
        : '$streakDays days steady.';
  }
  if (streakDays >= 3) {
    return localeIsRu
        ? 'Серия $streakDays дня жива.'
        : '$streakDays day streak live.';
  }
  return localeIsRu
      ? 'Один чистый реп запускает ритм.'
      : 'One clean rep starts the rhythm.';
}

class _DailyGoalCardV1 extends StatelessWidget {
  const _DailyGoalCardV1({
    required this.localeIsRu,
    required this.state,
    required this.dailyGoalValue,
    required this.dailyGoalCtaLabel,
    this.onStartDailyDrill,
    this.subdued = false,
  });

  final bool localeIsRu;
  final Act0ShellStateV1 state;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final VoidCallback? onStartDailyDrill;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final isDone = goalValue.startsWith('Done') || goalValue.contains('3/3');
    final trustLine = _dailyGoalTrustLineV1(
      localeIsRu: localeIsRu,
      goalValue: goalValue,
      streakDays: state.streakDays,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('act0_shell_home_daily_goal_card'),
        onTap: isDone ? null : onStartDailyDrill,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: subdued
                ? Act0ShellTokensV1.surface2.withValues(alpha: 0.52)
                : Act0ShellTokensV1.surface.withValues(alpha: 0.88),
            borderColor: subdued
                ? Act0ShellTokensV1.border.withValues(alpha: 0.36)
                : Act0ShellTokensV1.border.withValues(alpha: 0.68),
            glow: false,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusLg,
                  ),
                ),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                  color: Act0ShellTokensV1.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localeIsRu ? 'Быстрая практика' : 'Quick practice',
                      style: Act0ShellTokensV1.label,
                    ),
                    const SizedBox(height: 4),
                    Text(goalValue, style: Act0ShellTokensV1.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      _dailyGoalSupportText(localeIsRu, goalValue),
                      style: Act0ShellTokensV1.muted.copyWith(fontSize: 11.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      key: const Key('act0_shell_home_daily_trust_line'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Act0ShellTokensV1.primary.withValues(
                          alpha: subdued ? 0.08 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                        border: Border.all(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.18,
                          ),
                        ),
                      ),
                      child: Text(
                        trustLine,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    if (!isDone && onStartDailyDrill != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        dailyGoalCtaLabel,
                        key: const Key('act0_shell_home_daily_practice_now'),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isDone)
                Container(
                  key: const Key('act0_shell_home_daily_done_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    localeIsRu ? 'Готово' : 'Done',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                      letterSpacing: 0.2,
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

class _HomeRepairCardV1 extends StatelessWidget {
  const _HomeRepairCardV1({
    required this.localeIsRu,
    this.embedded = false,
    this.repairLabel,
    this.repairHeadline,
    this.repairDetail,
    this.repairOutcome,
    this.repairCtaLabel,
    this.onStartRepair,
  });

  final bool localeIsRu;
  final bool embedded;
  final String? repairLabel;
  final String? repairHeadline;
  final String? repairDetail;
  final String? repairOutcome;
  final String? repairCtaLabel;
  final VoidCallback? onStartRepair;

  @override
  Widget build(BuildContext context) {
    final normalizedRepairLabel = (repairLabel ?? '').trim().isEmpty
        ? null
        : repairLabel;
    final normalizedRepairHeadline = (repairHeadline ?? '').trim().isEmpty
        ? null
        : repairHeadline;
    final normalizedRepairDetail = (repairDetail ?? '').trim().isEmpty
        ? null
        : repairDetail;
    final normalizedRepairOutcome = (repairOutcome ?? '').trim().isEmpty
        ? null
        : repairOutcome;
    final hasActionableRepair = repairCtaLabel != null && onStartRepair != null;
    return Container(
      key: const Key('act0_shell_home_repair_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: Act0ShellTokensV1.primary.withValues(alpha: 0.18),
        glow: false,
        color: embedded
            ? Act0ShellTokensV1.surface2.withValues(alpha: 0.42)
            : Act0ShellTokensV1.surface.withValues(alpha: 0.76),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (normalizedRepairHeadline != null ||
              normalizedRepairDetail != null ||
              normalizedRepairOutcome != null) ...[
            Container(
              key: const Key('act0_shell_home_repair_panel'),
              padding: const EdgeInsets.symmetric(
                horizontal: Act0ShellTokensV1.gapMd,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: hasActionableRepair
                    ? Act0ShellTokensV1.surface3.withValues(alpha: 0.72)
                    : Act0ShellTokensV1.surface3.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
                border: Border.all(
                  color: hasActionableRepair
                      ? Act0ShellTokensV1.border.withValues(alpha: 0.46)
                      : Act0ShellTokensV1.primary.withValues(alpha: 0.16),
                ),
              ),
              child: hasActionableRepair
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (normalizedRepairLabel != null)
                                Text(
                                  normalizedRepairLabel,
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: Act0ShellTokensV1.primary,
                                  ),
                                ),
                              if (normalizedRepairHeadline != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  normalizedRepairHeadline,
                                  key: const Key(
                                    'act0_shell_home_repair_headline',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Act0ShellTokensV1.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                              if (normalizedRepairDetail != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 14,
                                      color: Act0ShellTokensV1.textDim,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        normalizedRepairDetail,
                                        key: const Key(
                                          'act0_shell_home_repair_detail',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Act0ShellTokensV1.muted.copyWith(
                                          color: Act0ShellTokensV1.textDim,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (normalizedRepairOutcome != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  normalizedRepairOutcome,
                                  key: const Key(
                                    'act0_shell_home_repair_outcome',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Act0ShellTokensV1.muted.copyWith(
                                    color: Act0ShellTokensV1.textMuted,
                                  ),
                                ),
                              ],
                              const SizedBox(height: Act0ShellTokensV1.gapSm),
                              FilledButton.tonal(
                                key: const Key('act0_shell_home_repair_cta'),
                                onPressed: onStartRepair,
                                style: FilledButton.styleFrom(
                                  visualDensity: const VisualDensity(
                                    horizontal: -1,
                                    vertical: -1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  foregroundColor: Act0ShellTokensV1.primary,
                                ),
                                child: Text(repairCtaLabel!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      key: const Key('act0_shell_home_repair_clear_state'),
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Act0ShellTokensV1.primary.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(
                              Act0ShellTokensV1.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Act0ShellTokensV1.primary,
                          ),
                        ),
                        const SizedBox(width: Act0ShellTokensV1.gapSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (normalizedRepairHeadline != null)
                                Text(
                                  normalizedRepairHeadline,
                                  key: const Key(
                                    'act0_shell_home_repair_headline',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Act0ShellTokensV1.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              if (normalizedRepairDetail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  normalizedRepairDetail,
                                  key: const Key(
                                    'act0_shell_home_repair_detail',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Act0ShellTokensV1.muted.copyWith(
                                    color: Act0ShellTokensV1.textDim,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeFooterSharkyLineV1 extends StatelessWidget {
  const _HomeFooterSharkyLineV1({
    required this.state,
    required this.sharky,
    required this.localeIsRu,
  });

  final Act0ShellStateV1 state;
  final Act0SharkyCueV1 sharky;
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    final line = _footerLine();
    return Act0SharkyPresenceBubbleV1(
      line: line,
      mood: sharky.preSessionMood,
      tone: act0SharkyToneForMoodV1(sharky.preSessionMood),
      textKey: const Key('act0_shell_home_footer_sharky_line'),
      mascotSize: 76,
      bubblePadding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 12,
      ),
    );
  }

  String _footerLine() {
    switch (sharky.preSessionMood) {
      case Act0SharkyMoodV1.repair:
        return localeIsRu
            ? (state.streakDays >= 3
                  ? '${state.streakDays} дня подряд. Сначала почини это место и сохрани чистую серию.'
                  : 'Начни с этого фикса. Один чистый проход — и маршрут снова открыт.')
            : (state.streakDays >= 3
                  ? '${state.streakDays} days running. Fix this one first and keep the run clean.'
                  : 'Start with this fix. Clean it once, then the route opens up.');
      case Act0SharkyMoodV1.celebrate:
        return localeIsRu
            ? (state.streakDays > 0
                  ? 'Хорошая работа сегодня. Ритм сохранён. Я подержу место до завтра.'
                  : sharky.summaryLine)
            : (state.streakDays > 0
                  ? 'Nice work today. The rhythm is safe. I will hold the seat for tomorrow.'
                  : sharky.summaryLine);
      case Act0SharkyMoodV1.happy:
        if (state.streakDays >= 7) {
          return localeIsRu
              ? '${state.streakDays} дней стабильно. Этот ритм уже начинает превращаться в настоящее преимущество.'
              : '${state.streakDays} days steady. That rhythm is starting to feel like real edge.';
        }
        if (state.streakDays >= 3) {
          return localeIsRu
              ? '${state.streakDays} дня подряд. Один чистый реп — и серия жива.'
              : '${state.streakDays} days running. One clean rep keeps it alive.';
        }
        return localeIsRu
            ? 'Ты уже в ритме. Один быстрый чистый реп держит его тёплым.'
            : 'You are rolling. One quick clean rep keeps the rhythm warm.';
      case Act0SharkyMoodV1.thinking:
        return localeIsRu
            ? 'Один спокойный чистый реп сейчас лучше десяти спешных потом.'
            : 'One calm clean rep now beats ten rushed ones later.';
      case Act0SharkyMoodV1.neutral:
        return localeIsRu
            ? 'Не спеши. Чистые чтения собирают настоящее преимущество.'
            : 'Stay patient. Clean reads build real edge.';
    }
  }
}
