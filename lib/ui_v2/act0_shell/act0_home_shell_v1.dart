import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
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
    this.dailyGoalCtaLabel = 'Start practice',
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
    final isTablet = Act0ShellTokensV1.isTabletWidth(context);
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final lesson = currentLesson ?? state.currentLesson;
    final title =
        nextActionTitle ?? act0LocalizedLessonTitleV1(context, lesson);
    final subtitle =
        nextActionSubtitle ?? act0LocalizedLessonSubtitleV1(context, lesson);
    final courseTitle = act0LocalizedWorldTitleV1(context, state.selectedWorld);
    final sharky = sharkyOverride ?? lesson.runner.sharky;
    final nextActionLabel = this.nextActionLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Next', ru: 'Дальше')
        : this.nextActionLabel;
    final nextActionCtaLabel = this.nextActionCtaLabel == 'Continue'
        ? _shellCopyV1(context, en: 'Continue', ru: 'Продолжить')
        : this.nextActionCtaLabel;
    final repairLabel = this.repairLabel == 'Review'
        ? _shellCopyV1(context, en: 'Review', ru: 'Разбор')
        : this.repairLabel;
    final dailyGoalCtaLabel = this.dailyGoalCtaLabel == 'Start practice'
        ? _shellCopyV1(context, en: 'Start practice', ru: 'Начать практику')
        : this.dailyGoalCtaLabel;
    final heroCard = Container(
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
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
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
                              const SizedBox(height: Act0ShellTokensV1.gapXs),
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
                      key: const Key('act0_shell_home_next_action_subtitle'),
                      style: Act0ShellTokensV1.muted,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
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
        ],
      ),
    );
    final repairCard = showRepairPanel
        ? _HomeRepairCardV1(
            localeIsRu: _isRuLocaleV1(context),
            embedded: true,
            repairLabel: showRepairPanel ? repairLabel : null,
            repairHeadline: showRepairPanel ? repairHeadline : null,
            repairDetail: showRepairPanel ? repairDetail : null,
            repairOutcome: showRepairPanel ? repairOutcome : null,
            repairCtaLabel: showRepairPanel ? repairCtaLabel : null,
            onStartRepair: showRepairPanel ? onStartRepair : null,
          )
        : null;
    final dailyCard = _DailyGoalCardV1(
      localeIsRu: _isRuLocaleV1(context),
      state: state,
      dailyGoalValue: dailyGoalValue,
      dailyGoalCtaLabel: dailyGoalCtaLabel,
      onStartDailyDrill: onStartDailyDrill,
    );
    final sharkyFooter = _HomeFooterSharkyLineV1(
      state: state,
      sharky: sharky,
      localeIsRu: _isRuLocaleV1(context),
    );
    final tabletBody = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              heroCard,
              if (repairCard != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                repairCard,
              ],
            ],
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapLg),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dailyCard,
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              sharkyFooter,
            ],
          ),
        ),
      ],
    );
    return ListView(
      key: const Key('act0_shell_home_screen'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapLg,
        pagePadding,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellScreenHeaderV1(
          title: _shellCopyV1(context, en: 'Home', ru: 'Главная'),
          subtitle: _shellCopyV1(
            context,
            en: 'One clear next step is waiting below.',
            ru: 'Ниже тебя ждёт один ясный следующий шаг.',
          ),
          eyebrow: _shellCopyV1(
            context,
            en: 'Active world: $courseTitle',
            ru: 'Активный мир: $courseTitle',
          ),
          trailing: onOpenDevMenu == null
              ? null
              : IconButton(
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
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 1080,
          child: isTablet
              ? tabletBody
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroCard,
                    if (repairCard != null) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapMd),
                      repairCard,
                    ],
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    dailyCard,
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    sharkyFooter,
                  ],
                ),
        ),
      ],
    );
  }
}

bool _isDailyGoalDoneValue(String goalValue) {
  return goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Done') ||
      goalValue.contains('3/3') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён') ||
      goalValue.startsWith('На сегодня всё');
}

String _dailyGoalSupportText(bool localeIsRu, String goalValue) {
  if (goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён')) {
    return localeIsRu
        ? 'Фикс засчитан. Ты честно удержал ритм на завтра.'
        : 'Repair banked. You earned tomorrow\'s rhythm.';
  }
  if (_isDailyGoalDoneValue(goalValue)) {
    return localeIsRu
        ? 'Цель на сегодня закрыта. Завтрашнее возвращение уже стало легче.'
        : 'Goal complete. Tomorrow\'s return already feels lighter.';
  }
  if (goalValue.startsWith('0/')) {
    return localeIsRu
        ? 'Один чистый спот запускает день.'
        : 'One clean spot starts the day.';
  }
  return localeIsRu
      ? 'Ещё один чистый реп держит темп.'
      : 'One more clean rep keeps the pace.';
}

String _dailyGoalTrustLineV1({
  required bool localeIsRu,
  required String goalValue,
  required int streakDays,
}) {
  if (goalValue.startsWith('Streak saved') ||
      goalValue.startsWith('Seat held') ||
      goalValue.startsWith('Saved') ||
      goalValue.startsWith('Завтра будет легко вернуться') ||
      goalValue.startsWith('Ритм сохранён') ||
      goalValue.startsWith('Сохранён')) {
    return localeIsRu
        ? (streakDays > 0
              ? '$streakDays дн. сохранены'
              : 'Импульс на завтра сохранён.')
        : (streakDays > 0
              ? '$streakDays day rhythm held'
              : 'Momentum protected for tomorrow.');
  }
  if (_isDailyGoalDoneValue(goalValue)) {
    return localeIsRu
        ? (streakDays > 0
              ? '$streakDays дн. в порядке'
              : 'Сегодняшний день засчитан. Завтра будет легче.')
        : (streakDays > 0
              ? '$streakDays day streak safe'
              : 'Today is banked. Tomorrow starts lighter.');
  }
  if (streakDays >= 7) {
    return localeIsRu ? '$streakDays дн.' : '$streakDays day streak';
  }
  if (streakDays >= 3) {
    return localeIsRu ? '$streakDays дня' : '$streakDays day streak';
  }
  return localeIsRu ? 'Стартуй ритм' : 'Start the rhythm';
}

class _DailyGoalCardV1 extends StatelessWidget {
  const _DailyGoalCardV1({
    required this.localeIsRu,
    required this.state,
    required this.dailyGoalValue,
    required this.dailyGoalCtaLabel,
    this.onStartDailyDrill,
  });

  final bool localeIsRu;
  final Act0ShellStateV1 state;
  final String? dailyGoalValue;
  final String dailyGoalCtaLabel;
  final VoidCallback? onStartDailyDrill;

  @override
  Widget build(BuildContext context) {
    final goalValue = dailyGoalValue ?? state.dailyGoalValue;
    final isDone = _isDailyGoalDoneValue(goalValue);
    final accentColor = isDone
        ? Act0ShellTokensV1.primary
        : (state.streakDays >= 3
              ? Act0ShellTokensV1.gold
              : Act0ShellTokensV1.info);
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
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.76),
            borderColor: accentColor.withValues(alpha: 0.18),
            glow: false,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusLg,
                      ),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.flash_on_rounded,
                      color: accentColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localeIsRu ? 'Опциональный реп' : 'Optional rep',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.textDim,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goalValue,
                          style: Act0ShellTokensV1.cardTitle.copyWith(
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone)
                    Text(
                      localeIsRu ? 'Готово' : 'Done',
                      key: const Key('act0_shell_home_daily_done_badge'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.primary,
                        letterSpacing: 0.1,
                      ),
                    )
                  else if (trustLine.isNotEmpty)
                    Text(
                      trustLine,
                      key: const Key('act0_shell_home_daily_trust_line'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: accentColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _dailyGoalSupportText(localeIsRu, goalValue),
                key: const Key('act0_shell_home_daily_support_line'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: 12.5,
                  color: Act0ShellTokensV1.textMuted,
                ),
              ),
              if (!isDone && onStartDailyDrill != null) ...[
                const SizedBox(height: 10),
                FilledButton.tonal(
                  key: const Key('act0_shell_home_daily_practice_now'),
                  onPressed: onStartDailyDrill,
                  style: Act0ShellTokensV1.tonalButtonStyle(
                    tone: accentColor,
                    fullWidth: true,
                  ),
                  child: Text(dailyGoalCtaLabel),
                ),
              ],
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
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: hasActionableRepair
            ? Act0ShellTokensV1.primary.withValues(alpha: 0.18)
            : Act0ShellTokensV1.primary.withValues(alpha: 0.16),
        glow: false,
        color: hasActionableRepair
            ? (embedded
                  ? Act0ShellTokensV1.surface2.withValues(alpha: 0.42)
                  : Act0ShellTokensV1.surface.withValues(alpha: 0.76))
            : Act0ShellTokensV1.primary.withValues(alpha: 0.07),
      ),
      child: KeyedSubtree(
        key: const Key('act0_shell_home_repair_panel'),
        child: hasActionableRepair
            ? Column(
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
                      key: const Key('act0_shell_home_repair_headline'),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (normalizedRepairDetail != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      normalizedRepairDetail,
                      key: const Key('act0_shell_home_repair_detail'),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textDim,
                      ),
                    ),
                  ],
                  if (normalizedRepairOutcome != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      normalizedRepairOutcome,
                      key: const Key('act0_shell_home_repair_outcome'),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  FilledButton.tonal(
                    key: const Key('act0_shell_home_repair_cta'),
                    onPressed: onStartRepair,
                    style: Act0ShellTokensV1.tonalButtonStyle(
                      tone: Act0ShellTokensV1.primary,
                    ),
                    child: Text(repairCtaLabel!),
                  ),
                ],
              )
            : Row(
                key: const Key('act0_shell_home_repair_clear_state'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.primary.withValues(alpha: 0.12),
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
                            key: const Key('act0_shell_home_repair_headline'),
                            style: Act0ShellTokensV1.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Act0ShellTokensV1.text,
                            ),
                          ),
                        if (normalizedRepairDetail != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            normalizedRepairDetail,
                            key: const Key('act0_shell_home_repair_detail'),
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            style: Act0ShellTokensV1.muted.copyWith(
                              color: Act0ShellTokensV1.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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
      mascotSize: 120,
      bubblePadding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 12,
      ),
    );
  }

  String _footerLine() {
    switch (sharky.preSessionMood) {
      case Act0SharkyMoodV1.repair:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Сначала почини это место. Потом маршрут снова станет лёгким.',
                  'Один чистый фикс сначала. Потом можно спокойно идти дальше.',
                  'Почини этот узел первым. Остальное сразу станет проще.',
                ]
              : <String>[
                  'Fix this spot first. Then the route feels clean again.',
                  'One clean repair first. Then continue with a clear head.',
                  'Repair this pressure point first. The rest gets easier right away.',
                ],
        );
      case Act0SharkyMoodV1.celebrate:
        if (state.streakDays > 0) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    'Место на завтра удержано. Один короткий чистый реп его продлит.',
                    'Ритм уже собран. Один короткий реп удержит ход.',
                    'Темп держится. Один чистый проход и завтра остаётся тёплым.',
                  ]
                : <String>[
                    'Seat held for tomorrow. One short clean rep extends it.',
                    'Rhythm is locked in. One short rep keeps it alive.',
                    'Pace is holding. One clean pass keeps tomorrow warm.',
                  ],
          );
        }
        return sharky.summaryLine;
      case Act0SharkyMoodV1.happy:
        if (state.streakDays >= 7) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    'Серия уже настоящая. Один спокойный чистый реп держит её честной.',
                    'Серия собрана. Один аккуратный реп не даёт ей распасться.',
                    'Это уже не случайность. Один чистый проход закрепит ритм.',
                  ]
                : <String>[
                    'The streak is real now. One calm clean rep keeps it honest.',
                    'This streak is earned. One tidy rep keeps it stable.',
                    'This is not random anymore. One clean pass secures the rhythm.',
                  ],
          );
        }
        if (state.streakDays >= 3) {
          return _pickPaletteLineV1(
            localeIsRu
                ? <String>[
                    '${state.streakDays} дня в ритме. Один чистый реп удерживает место тёплым.',
                    '${state.streakDays} дня подряд. Один короткий чистый реп и темп сохранён.',
                    'Уже ${state.streakDays} дня в движении. Один точный реп держит курс.',
                  ]
                : <String>[
                    '${state.streakDays} days running. One clean rep keeps the rhythm warm.',
                    '${state.streakDays} days in a row. One short clean rep keeps the pace.',
                    '${state.streakDays} days in motion already. One precise rep keeps the route steady.',
                  ],
          );
        }
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Ты уже входишь в ритм. Один чистый реп задаст тон.',
                  'Ритм уже появляется. Один точный проход его закрепит.',
                  'Ты разогреваешься. Один спокойный реп задаёт правильный вектор.',
                ]
              : <String>[
                  'You are settling in. One clean rep sets the tone.',
                  'Rhythm is starting to form. One precise pass locks it in.',
                  'You are warming up. One calm rep sets the right direction.',
                ],
        );
      case Act0SharkyMoodV1.thinking:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Один спокойный чистый реп сейчас лучше десяти спешных потом.',
                  'Сначала спокойное чтение, потом действие. Так меньше лишних ошибок.',
                  'Не форсируй темп. Один чистый проход даёт больше, чем серия спешных.',
                ]
              : <String>[
                  'One calm clean rep now beats ten rushed ones later.',
                  'Read calmly first, then act. That removes avoidable mistakes.',
                  'Do not force pace. One clean pass beats a rushed streak.',
                ],
        );
      case Act0SharkyMoodV1.neutral:
        return _pickPaletteLineV1(
          localeIsRu
              ? <String>[
                  'Не спеши. Чистые чтения собирают настоящее преимущество.',
                  'Держи темп ровным. Сначала качество чтения, потом скорость.',
                  'Спокойный ритм даёт лучший результат, чем спешка.',
                ]
              : <String>[
                  'Stay patient. Clean reads build real edge.',
                  'Keep the pace steady. Reading quality comes before speed.',
                  'A calm rhythm outperforms rushed decisions.',
                ],
        );
    }
  }

  String _pickPaletteLineV1(List<String> variants) {
    final cleaned = variants
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) {
      return localeIsRu
          ? 'Один чистый реп и дальше по маршруту.'
          : 'One clean rep, then continue the route.';
    }
    final seed = state.streakDays.abs();
    var index = seed % cleaned.length;
    final previous = sharky.preSessionLine.trim().toLowerCase();
    if (cleaned.length > 1 && cleaned[index].toLowerCase() == previous) {
      index = (index + 1) % cleaned.length;
    }
    return cleaned[index];
  }
}
