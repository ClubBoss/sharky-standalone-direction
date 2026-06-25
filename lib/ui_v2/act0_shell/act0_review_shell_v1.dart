import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) => false;

String _reviewCopyV1(
  BuildContext context, {
  String? atomId,
  String? fallback,
  String? en,
  String? ru,
}) {
  if (atomId != null) {
    return act0LocalizedSurfaceAtomV1(
      context,
      atomId,
      fallback: fallback ?? en ?? '',
    );
  }
  return _isRuLocaleV1(context) ? (ru ?? en ?? '') : (en ?? fallback ?? '');
}

class Act0ReviewShellV1 extends StatelessWidget {
  const Act0ReviewShellV1({
    super.key,
    required this.review,
    required this.selected,
    required this.onSelected,
    this.onFixMistake,
    this.onReplayFixedMistake,
    this.sessionDrillRecheckQueueItems =
        const <SessionDrillRecheckLaunchQueueItemV1>[],
    this.onStartSessionDrillRecheck,
    this.mistakeHistoryItems = const <Act0ReviewMistakeHistoryItemV1>[],
  });

  final Act0ReviewStateV1 review;
  final String? selected;
  final ValueChanged<String> onSelected;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final ValueChanged<Act0MistakeCardV1>? onReplayFixedMistake;
  final List<SessionDrillRecheckLaunchQueueItemV1>
  sessionDrillRecheckQueueItems;
  final ValueChanged<SessionDrillRecheckLaunchQueueItemV1>?
  onStartSessionDrillRecheck;
  final List<Act0ReviewMistakeHistoryItemV1> mistakeHistoryItems;

  @override
  Widget build(BuildContext context) {
    final isTablet = Act0ShellTokensV1.isTabletWidth(context);
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final localeIsRu = _isRuLocaleV1(context);
    final nextMistake = review.mistakes.isEmpty ? null : review.mistakes.first;
    final isClean = nextMistake == null;
    final recovered = <Act0MistakeCardV1>[
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel != 'Quick fix',
      ),
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel == 'Quick fix',
      ),
    ];
    final leftColumn = <Widget>[
      _ReviewBoardV1(
        review: review,
        nextMistake: null,
        hasMistakeHistory: mistakeHistoryItems.isNotEmpty,
        onFixMistake: onFixMistake,
      ),
      if (mistakeHistoryItems.isNotEmpty) ...[
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _MistakeHistoryListV1(items: mistakeHistoryItems.take(3).toList()),
      ],
    ];
    final activeRepairColumn = <Widget>[
      if (sessionDrillRecheckQueueItems.isNotEmpty &&
          onStartSessionDrillRecheck != null) ...[
        _SessionDrillRecheckQueueCardV1(
          item: sessionDrillRecheckQueueItems.first,
          onStart: onStartSessionDrillRecheck!,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
      ],
      if (!isClean) ...[
        _ReviewRepairCoachCardV1(
          mistake: review.mistakes.first,
          onFixMistake: onFixMistake,
        ),
      ],
    ];
    final historyColumn = <Widget>[
      if (mistakeHistoryItems.isNotEmpty) ...[
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _MistakeHistoryListV1(items: mistakeHistoryItems.take(3).toList()),
      ],
    ];
    final recoveredColumn = <Widget>[
      if (recovered.isNotEmpty) ...[
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Text(
          _reviewCopyV1(
            context,
            atomId: 'review_recovered_lately_label',
            fallback: 'Recovered lately',
          ),
          style: Act0ShellTokensV1.sectionTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          localeIsRu
              ? (recovered.length == 1
                    ? 'Один спот уже снова под контролем. Так ошибки перестают казаться вечными.'
                    : '${recovered.length} ${act0RussianPluralV1(recovered.length, 'спот', 'спота', 'спотов')} уже снова под контролем. Так игра начинает ощущаться легче.')
              : (recovered.length == 1
                    ? 'One spot is already back under control. That is how mistakes stop feeling permanent.'
                    : '${recovered.length} spots are already back under control. That is how the board starts feeling lighter.'),
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          key: const Key('act0_shell_review_recovered_proof_line'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0VisualCanonV1.greenTable.withOpacity(0.07),
            borderColor: Act0VisualCanonV1.greenTable.withOpacity(0.18),
            glow: false,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Act0VisualCanonV1.greenTable,
                size: 18,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  localeIsRu
                      ? 'Исправленные споты остаются лёгкими повторами, а не техническим отчётом.'
                      : 'Fixed spots stay as light replays, not a debug log.',
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        for (final mistake in recovered.take(2)) ...[
          _FixedMistakeCardV1(
            mistake: mistake,
            quick: mistake.severityLabel == 'Quick fix',
            onReplay: onReplayFixedMistake,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
      ],
    ];
    final rightColumn = <Widget>[...activeRepairColumn, ...recoveredColumn];
    return ListView(
      key: const Key('act0_shell_review_screen'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapLg,
        pagePadding,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellScreenHeaderV1(
          title: _reviewCopyV1(context, fallback: 'Review'),
          subtitle: isClean
              ? _reviewCopyV1(
                  context,
                  fallback: 'Review notes and what to revisit.',
                )
              : _reviewCopyV1(
                  context,
                  en: 'One clue to keep in view.',
                  ru: 'Одна подсказка, которую стоит держать в фокусе.',
                ),
          eyebrow: _reviewHeaderEyebrowV1(
            localeIsRu: localeIsRu,
            hasActiveRepair: !isClean,
          ),
          eyebrowTone: review.mistakes.isEmpty
              ? Act0ShellTokensV1.primary
              : Act0ShellTokensV1.gold,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 1080,
          child: isTablet && isClean
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: leftColumn,
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapLg),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rightColumn,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isClean) ...[
                      ...leftColumn,
                      if (rightColumn.isNotEmpty) ...[
                        const SizedBox(height: Act0ShellTokensV1.gapLg),
                        ...rightColumn,
                      ],
                    ] else ...[
                      ...activeRepairColumn,
                      ...historyColumn,
                      ...recoveredColumn,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SessionDrillRecheckQueueCardV1 extends StatelessWidget {
  const _SessionDrillRecheckQueueCardV1({
    required this.item,
    required this.onStart,
  });

  final SessionDrillRecheckLaunchQueueItemV1 item;
  final ValueChanged<SessionDrillRecheckLaunchQueueItemV1> onStart;

  @override
  Widget build(BuildContext context) {
    final signalLabel = item.missedSignalLabel.trim().isEmpty
        ? 'Range bucket'
        : item.missedSignalLabel;
    final chosen = item.chosenActionId.trim().isEmpty
        ? 'your last choice'
        : item.chosenActionId;
    final expected = item.expectedActionId.trim().isEmpty
        ? 'the better action'
        : item.expectedActionId;
    return Container(
      key: const Key('act0_shell_review_recheck_queue_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.info.withOpacity(0.10),
        borderColor: Act0ShellTokensV1.info.withOpacity(0.28),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice this spot again',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Text(
            'Review this practice mistake',
            style: Act0ShellTokensV1.sectionTitle,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            '$signalLabel: you chose $chosen; try the $expected line again.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Text(
            'This opens the exact practice drill again, not an Act0 task repair.',
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          FilledButton(
            key: const Key('act0_shell_review_recheck_cta'),
            onPressed: () => onStart(item),
            style: Act0ShellTokensV1.primaryButtonStyle(
              height: Act0ShellTokensV1.compactCtaHeight,
            ),
            child: const Text('Practice this spot again'),
          ),
        ],
      ),
    );
  }
}

class _ReviewRepairCoachCardV1 extends StatelessWidget {
  const _ReviewRepairCoachCardV1({required this.mistake, this.onFixMistake});

  final Act0MistakeCardV1 mistake;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;

  @override
  Widget build(BuildContext context) {
    final guardedLines = act0ReviewRepairCoachCopyGuardLinesV1(
      clueLabel: mistake.title,
    );
    final clueLine = guardedLines.isEmpty
        ? 'This clue is still worth a closer look.'
        : guardedLines.first;
    final actionLine = mistake.repairActionLabel.trim().isEmpty
        ? mistake.reason
        : mistake.repairActionLabel;
    return Container(
      key: const Key('act0_shell_review_repair_coach_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.22),
        glow: false,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: Act0ShellTokensV1.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active repair note',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  clueLine,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(actionLine, style: Act0ShellTokensV1.muted),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  'Keep this clue in view before your next hand.',
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.textDim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _reviewHeaderEyebrowV1({
  required bool localeIsRu,
  required bool hasActiveRepair,
}) {
  return hasActiveRepair
      ? (localeIsRu ? 'Активный разбор' : 'Active repair')
      : (localeIsRu ? 'Обзор' : 'Review');
}

class _ReviewBoardV1 extends StatelessWidget {
  const _ReviewBoardV1({
    required this.review,
    required this.nextMistake,
    required this.hasMistakeHistory,
    this.onFixMistake,
  });

  final Act0ReviewStateV1 review;
  final Act0MistakeCardV1? nextMistake;
  final bool hasMistakeHistory;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;

  @override
  Widget build(BuildContext context) {
    final hasRepair = nextMistake != null;
    final hasRecovered = review.fixedMistakes.isNotEmpty;
    final isEmpty = !hasRepair && !hasRecovered && !hasMistakeHistory;
    final tone = hasRepair ? Act0ShellTokensV1.gold : Act0ShellTokensV1.primary;
    final title = isEmpty
        ? _reviewCopyV1(context, fallback: 'Review notes')
        : hasRepair
        ? _reviewCopyV1(
            context,
            atomId: 'review_board_title_fix',
            fallback: 'One reread',
          )
        : _reviewCopyV1(
            context,
            atomId: 'review_board_title_clean',
            fallback: 'Clean board',
          );
    final headline = isEmpty
        ? _reviewCopyV1(context, fallback: 'No past spots to review yet')
        : hasRepair
        ? nextMistake!.title
        : hasMistakeHistory
        ? _reviewCopyV1(context, fallback: 'Past spots to review')
        : _reviewCopyV1(
            context,
            atomId: 'review_board_headline_clean',
            fallback: 'Board is clean',
          );
    final body = isEmpty
        ? _reviewCopyV1(
            context,
            fallback:
                'Finish more hands and Sharky will keep useful review notes here.',
          )
        : hasRepair
        ? nextMistake!.reason
        : hasMistakeHistory
        ? _reviewCopyV1(
            context,
            fallback: 'Read-only notes from completed hands.',
          )
        : _reviewCopyV1(
            context,
            atomId: 'review_board_body_clean',
            fallback:
                'No active repair right now. Recovered spots stay available below.',
          );
    final support = hasRepair
        ? (nextMistake!.repairActionLabel.trim().isNotEmpty
              ? nextMistake!.repairActionLabel
              : _reviewCopyV1(
                  context,
                  fallback:
                      'Stabilize this spot first. Then come back for the next check.',
                ))
        : hasMistakeHistory
        ? _reviewCopyV1(
            context,
            fallback:
                'Active repairs stay separate. These notes do not change progress.',
          )
        : _reviewCopyV1(
            context,
            en: isEmpty
                ? 'Review stays quiet until completed hands create something useful to revisit.'
                : 'That repair work stuck. Keep the next read light.',
            ru: 'Этот ремонт закрепился. Держи следующее чтение лёгким.',
          );

    return Container(
      key: const Key('act0_shell_review_board'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            tone.withOpacity(0.16),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(color: tone.withOpacity(0.30)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tone.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(color: tone.withOpacity(0.28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasRepair
                          ? Icons.priority_high_rounded
                          : Icons.verified_rounded,
                      size: 14,
                      color: tone,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      key: const Key('act0_shell_review_board_title'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: tone,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hasRepair)
                Text(
                  nextMistake!.weaknessLabel,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            headline,
            key: const Key('act0_shell_review_board_headline'),
            style: Act0ShellTokensV1.screenTitle.copyWith(fontSize: 26),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            body,
            key: const Key('act0_shell_review_board_body'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.textMuted,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Container(
            key: const Key('act0_shell_review_board_support_line'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withOpacity(0.72),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: Row(
              children: [
                Icon(
                  hasRepair ? Icons.route_rounded : Icons.support_agent_rounded,
                  size: 18,
                  color: tone,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    support,
                    key: hasRepair
                        ? const Key('act0_shell_review_board_support_text')
                        : const Key('act0_shell_review_clean_sharky_line'),
                    maxLines: 4,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: hasRepair
                          ? Act0ShellTokensV1.text
                          : Act0ShellTokensV1.textMuted,
                      fontWeight: hasRepair ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasRepair && onFixMistake != null) ...<Widget>[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            OutlinedButton.icon(
              key: const Key('act0_shell_review_board_fix_cta'),
              onPressed: () => onFixMistake!(nextMistake!),
              style: Act0ShellTokensV1.quietButtonStyle(),
              icon: const Icon(Icons.build_rounded, size: 18),
              label: Text(
                _reviewCopyV1(
                  context,
                  en: 'Repair this clue',
                  ru: 'Разобрать эту подсказку',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MistakeHistoryListV1 extends StatelessWidget {
  const _MistakeHistoryListV1({required this.items});

  final List<Act0ReviewMistakeHistoryItemV1> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_mistake_history_list'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.border,
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Past spots to review', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            'Read-only notes from completed hands.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (final item in items) ...[
            _MistakeHistoryRowV1(item: item),
            if (item != items.last)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _MistakeHistoryRowV1 extends StatelessWidget {
  const _MistakeHistoryRowV1({required this.item});

  final Act0ReviewMistakeHistoryItemV1 item;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_review_mistake_history_row_${item.stableKey}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: Act0ShellTokensV1.border.withOpacity(0.86)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  item.primaryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Text(
                item.orderLabel,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(item.detailLine, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            item.decisionLine,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            item.contextLine,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeCardV1 extends StatelessWidget {
  const _MistakeCardV1({
    required this.mistake,
    required this.onFixMistake,
    required this.prominent,
  });

  final Act0MistakeCardV1 mistake;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: prominent
          ? const Key('act0_shell_mistake_card')
          : Key('act0_shell_mistake_card_${mistake.taskId}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.danger.withOpacity(prominent ? 0.14 : 0.08),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.danger.withOpacity(prominent ? 0.56 : 0.38),
        ),
        boxShadow: <BoxShadow>[
          if (prominent)
            BoxShadow(
              color: Act0ShellTokensV1.danger.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!prominent) ...[
            Row(
              children: [
                _ReviewBoardMetricPillV1(
                  key: Key('act0_shell_mistake_badge_${mistake.taskId}'),
                  label: mistake.severityLabel,
                  tone: Act0ShellTokensV1.danger,
                  icon: Icons.radio_button_checked_rounded,
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
          Container(
            key: prominent
                ? const Key('act0_shell_mistake_decision_strip')
                : Key('act0_shell_mistake_decision_strip_${mistake.taskId}'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withOpacity(0.84),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DecisionPanelV1(
                    label: _reviewCopyV1(
                      context,
                      atomId: 'review_you_chose_label',
                      fallback: 'You chose',
                    ),
                    value: mistake.selectedLabel,
                    color: Act0ShellTokensV1.danger,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: _DecisionPanelV1(
                    label: _reviewCopyV1(
                      context,
                      atomId: 'review_better_label',
                      fallback: 'Better',
                    ),
                    value: mistake.betterLabel,
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Act0ShellTokensV1.danger,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mistake.title, style: Act0ShellTokensV1.cardTitle),
                    if (!prominent) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapXs),
                      Text(
                        mistake.weaknessLabel,
                        style: Act0ShellTokensV1.muted,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            mistake.reason,
            key: prominent
                ? const Key('act0_shell_mistake_reason')
                : Key('act0_shell_mistake_reason_${mistake.taskId}'),
            maxLines: 4,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted,
          ),
          if (mistake.contextLabels.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              key: const Key('act0_shell_mistake_context_labels'),
              spacing: 6,
              runSpacing: 5,
              children: [
                for (final label in mistake.contextLabels)
                  _SpotPillV1(label: label, color: Act0ShellTokensV1.gold),
              ],
            ),
          ],
          if (!prominent) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Container(
              key: const Key('act0_shell_mistake_repair_plan'),
              padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withOpacity(0.24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    color: Act0ShellTokensV1.primary,
                    size: 19,
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Text(
                      mistake.repairActionLabel,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          FilledButton(
            key: prominent
                ? const Key('act0_shell_review_fix_next_cta')
                : Key('act0_shell_review_fix_${mistake.taskId}'),
            onPressed: onFixMistake == null
                ? null
                : () => onFixMistake!(mistake),
            style: Act0ShellTokensV1.primaryButtonStyle(
              height: Act0ShellTokensV1.compactCtaHeight,
            ),
            child: Text(
              prominent
                  ? _reviewCopyV1(
                      context,
                      atomId: 'review_repair_this_spot',
                      fallback: 'Repair this clue',
                    )
                  : _reviewCopyV1(
                      context,
                      atomId: 'review_repair_this_spot',
                      fallback: 'Repair this spot',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixedMistakeCardV1 extends StatelessWidget {
  const _FixedMistakeCardV1({
    required this.mistake,
    this.quick = false,
    this.onReplay,
  });

  final Act0MistakeCardV1 mistake;
  final bool quick;
  final ValueChanged<Act0MistakeCardV1>? onReplay;

  @override
  Widget build(BuildContext context) {
    final detailLine = _recoveredDetailLineV1(context, mistake);
    final replayLabel = mistake.severityLabel == 'Recheck'
        ? _reviewCopyV1(
            context,
            en: 'Replay this spot',
            ru: 'Повторить этот спот',
          )
        : _reviewCopyV1(
            context,
            en: 'Replay for perfect',
            ru: 'Повторить на идеально',
          );
    return Container(
      key: Key('act0_shell_fixed_mistake_${mistake.taskId}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0VisualCanonV1.greenTable.withOpacity(0.055),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0VisualCanonV1.greenTable.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Act0VisualCanonV1.greenTable.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(
                color: Act0VisualCanonV1.greenTable.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: Act0VisualCanonV1.greenTable,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mistake.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      key: Key(
                        'act0_shell_fixed_mistake_status_${mistake.taskId}',
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Act0VisualCanonV1.greenTable.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                        border: Border.all(
                          color: Act0VisualCanonV1.greenTable.withOpacity(0.24),
                        ),
                      ),
                      child: Text(
                        _reviewCopyV1(
                          context,
                          en: 'Repaired',
                          ru: 'Исправлено',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0VisualCanonV1.greenTable,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  mistake.weaknessLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
                const SizedBox(height: 4),
                Text(
                  detailLine,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (onReplay != null) ...[
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            SizedBox(
              width: 92,
              child: OutlinedButton(
                key: quick
                    ? Key('act0_shell_quick_fix_replay_${mistake.taskId}')
                    : Key('act0_shell_fixed_mistake_replay_${mistake.taskId}'),
                onPressed: () => onReplay!(mistake),
                style: Act0ShellTokensV1.quietButtonStyle(height: 38).copyWith(
                  minimumSize: WidgetStateProperty.all(const Size(92, 38)),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: Act0ShellTokensV1.primary.withOpacity(0.34),
                    ),
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Act0ShellTokensV1.primary,
                  ),
                ),
                child: Text(
                  replayLabel,
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewBoardMetricPillV1 extends StatelessWidget {
  const _ReviewBoardMetricPillV1({
    super.key,
    required this.label,
    required this.tone,
    required this.icon,
  });

  final String label;
  final Color tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.border.withOpacity(0.86)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: Act0ShellTokensV1.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

String _recoveredDetailLineV1(BuildContext context, Act0MistakeCardV1 mistake) {
  final qualityLine = mistake.qualityLine.trim();
  if (qualityLine == 'Perfect clear complete.' ||
      qualityLine == 'Идеально пройдено.') {
    return _reviewCopyV1(
      context,
      en: 'This clue is clean now.',
      ru: 'Эта подсказка теперь чистая.',
    );
  }
  if (qualityLine == 'Clear path still open.' ||
      qualityLine == 'Путь к идеалу открыт.') {
    return _reviewCopyV1(
      context,
      en: 'This clue is cleaner now.',
      ru: 'Эта подсказка стала чище.',
    );
  }
  final anxiousRecheckCopy = <String>{
    'Still yours? Run this spot once more.',
    'Ещё твоё? Пройди этот спот ещё раз.',
  };
  if (qualityLine.isNotEmpty && !anxiousRecheckCopy.contains(qualityLine)) {
    return qualityLine;
  }
  return _reviewCopyV1(
    context,
    en: 'Recovered from recent review.',
    ru: 'Закреплено после недавнего разбора.',
  );
}

class _SpotPillV1 extends StatelessWidget {
  const _SpotPillV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStatV1 extends StatelessWidget {
  const _ReviewStatV1({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(value, style: Act0ShellTokensV1.body),
        ],
      ),
    );
  }
}

class _DecisionPanelV1 extends StatelessWidget {
  const _DecisionPanelV1({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(value, style: Act0ShellTokensV1.cardTitle),
        ],
      ),
    );
  }
}
