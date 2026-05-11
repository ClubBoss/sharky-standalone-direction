import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

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
  });

  final Act0ReviewStateV1 review;
  final String? selected;
  final ValueChanged<String> onSelected;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final ValueChanged<Act0MistakeCardV1>? onReplayFixedMistake;

  @override
  Widget build(BuildContext context) {
    final localeIsRu = _isRuLocaleV1(context);
    final nextMistake = review.mistakes.isEmpty ? null : review.mistakes.first;
    final recovered = <Act0MistakeCardV1>[
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel != 'Quick fix',
      ),
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel == 'Quick fix',
      ),
    ];
    return ListView(
      key: const Key('act0_shell_review_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Text(
          _reviewCopyV1(
            context,
            atomId: 'review_title',
            fallback: review.title,
          ),
          style: Act0ShellTokensV1.screenTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          _reviewCopyV1(
            context,
            atomId: 'review_subtitle',
            fallback: review.subtitle,
          ),
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Act0SharkyGuideCardV1(
          eyebrow: localeIsRu ? 'Шарки' : 'Sharky',
          line: _reviewSharkyLineV1(
            localeIsRu: localeIsRu,
            nextMistake: nextMistake,
            recoveredCount: recovered.length,
          ),
          detail: _reviewSharkyDetailV1(
            localeIsRu: localeIsRu,
            nextMistake: nextMistake,
            recoveredCount: recovered.length,
          ),
          mood: nextMistake != null
              ? Act0SharkyMoodV1.repair
              : Act0SharkyMoodV1.happy,
          tone: nextMistake != null
              ? Act0ShellTokensV1.gold
              : Act0ShellTokensV1.primary,
          compact: true,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _ReviewBoardV1(
          review: review,
          nextMistake: nextMistake,
          onFixMistake: onFixMistake,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        if (review.mistakes.isEmpty)
          _ReviewEmptyStateV1(review: review)
        else ...[
          Text(
            _reviewCopyV1(
              context,
              atomId: 'review_fix_next_label',
              fallback: 'Fix next',
            ),
            style: Act0ShellTokensV1.sectionTitle,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            _reviewCopyV1(
              context,
              en: 'Start with the highest-pressure miss. The rest can wait.',
              ru: 'Начни с самой давящей ошибки. Остальное может подождать.',
            ),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          _MistakeCardV1(
            mistake: review.mistakes.first,
            prominent: true,
            onFixMistake: onFixMistake,
          ),
          if (review.mistakes.length > 1) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Container(
              key: const Key('act0_shell_review_more_repairs_line'),
              padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
              decoration: Act0ShellTokensV1.surfaceDecoration(
                color: Act0ShellTokensV1.surface2.withOpacity(0.56),
                glow: false,
              ),
              child: Text(
                localeIsRu
                    ? (review.mistakes.length == 2
                          ? 'После этого ждёт ещё один фикс.'
                          : 'После этого ждут ещё ${review.mistakes.length - 1} фикса.')
                    : (review.mistakes.length == 2
                          ? '1 more repair is waiting after this one.'
                          : '${review.mistakes.length - 1} more repairs are waiting after this one.'),
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textDim,
                ),
              ),
            ),
          ],
        ],
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
                      ? 'Один спот уже снова под контролем. Так протечки перестают казаться вечными.'
                      : '${recovered.length} спота уже снова под контролем. Так игра начинает ощущаться легче.')
                : (recovered.length == 1
                      ? 'One spot is already back under control. That is how leaks stop feeling permanent.'
                      : '${recovered.length} spots are already back under control. That is how the board starts feeling lighter.'),
            style: Act0ShellTokensV1.muted,
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
      ],
    );
  }
}

String _reviewSharkyLineV1({
  required bool localeIsRu,
  required Act0MistakeCardV1? nextMistake,
  required int recoveredCount,
}) {
  if (nextMistake == null) {
    return localeIsRu
        ? (recoveredCount > 0
              ? 'Стол снова чист. Этот фикс закрепился.'
              : 'Стол чист. Держи маршрут в движении.')
        : (recoveredCount > 0
              ? 'Board is clean again. That repair work stuck.'
              : 'Board is clean. Keep the route moving.');
  }
  if (recoveredCount > 0) {
    return localeIsRu
        ? 'Сначала один чистый фикс. ${recoveredCount == 1 ? 'Один спот уже вернулся.' : '$recoveredCount спота уже вернулись.'}'
        : 'One clean fix first. ${recoveredCount == 1 ? 'One spot is already back.' : '$recoveredCount spots are already back.'}';
  }
  return localeIsRu
      ? 'Сначала один чистый фикс. Остальное может подождать.'
      : 'One clean fix first. The rest can wait.';
}

String _reviewSharkyDetailV1({
  required bool localeIsRu,
  required Act0MistakeCardV1? nextMistake,
  required int recoveredCount,
}) {
  if (nextMistake == null) {
    return localeIsRu
        ? (recoveredCount > 0
              ? 'Сейчас в маршруте нет ничего срочного.'
              : 'Сейчас путь не тянет ни в какой срочный фикс.')
        : (recoveredCount > 0
              ? 'Nothing urgent is pulling on the route right now.'
              : 'No urgent repair is pulling on the path right now.');
  }
  if (recoveredCount > 0) {
    return localeIsRu
        ? '${nextMistake.weaknessLabel} — следующая точка давления. Почини её, и игра снова станет легче.'
        : '${nextMistake.weaknessLabel} is the next pressure point. Clean it and the board gets lighter again.';
  }
  return nextMistake.weaknessLabel;
}

class _ReviewBoardV1 extends StatelessWidget {
  const _ReviewBoardV1({
    required this.review,
    required this.nextMistake,
    this.onFixMistake,
  });

  final Act0ReviewStateV1 review;
  final Act0MistakeCardV1? nextMistake;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;

  @override
  Widget build(BuildContext context) {
    final hasRepair = nextMistake != null;
    final tone = hasRepair ? Act0ShellTokensV1.gold : Act0ShellTokensV1.primary;
    final title = hasRepair
        ? _reviewCopyV1(
            context,
            atomId: 'review_board_title_fix',
            fallback: 'Fix next',
          )
        : _reviewCopyV1(
            context,
            atomId: 'review_board_title_clean',
            fallback: 'Review',
          );
    final headline = hasRepair
        ? nextMistake!.title
        : _reviewCopyV1(
            context,
            atomId: 'review_board_headline_clean',
            fallback: 'Board is clean',
          );
    final body = hasRepair
        ? nextMistake!.reason
        : _reviewCopyV1(
            context,
            atomId: 'review_board_body_clean',
            fallback:
                'No urgent fixes right now. Keep the board clean with one crisp run.',
          );
    final support = hasRepair
        ? _reviewCopyV1(
            context,
            atomId: 'review_board_support_fix',
            fallback:
                'One clean fix here matters more than scanning the whole board.',
          )
        : (review.strongSpots.isEmpty
              ? _reviewCopyV1(
                  context,
                  atomId: 'review_board_support_clean_empty',
                  fallback: 'Nothing to fix yet. Keep the route moving.',
                )
              : _reviewCopyV1(
                  context,
                  atomId: 'review_board_support_clean_strong',
                  fallback: 'You are clean right now. Keep the route moving.',
                ));

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
                  hasRepair ? Icons.route_rounded : Icons.trending_up_rounded,
                  size: 18,
                  color: tone,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    support,
                    key: const Key('act0_shell_review_board_support_text'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w800,
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
                  atomId: 'review_board_fix_cta',
                  fallback: 'Fix now',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewEmptyStateV1 extends StatelessWidget {
  const _ReviewEmptyStateV1({required this.review});

  final Act0ReviewStateV1 review;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_empty_state'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.34),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Act0ShellTokensV1.primary,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.emptyTitle, style: Act0ShellTokensV1.cardTitle),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(review.emptyBody, style: Act0ShellTokensV1.muted),
              ],
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
    this.prominent = false,
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
          Row(
            children: [
              _ReviewBoardMetricPillV1(
                key: prominent
                    ? const Key('act0_shell_mistake_priority_badge')
                    : Key('act0_shell_mistake_badge_${mistake.taskId}'),
                label: mistake.severityLabel,
                tone: Act0ShellTokensV1.danger,
                icon: prominent
                    ? Icons.flag_rounded
                    : Icons.radio_button_checked_rounded,
              ),
              const Spacer(),
              _ReviewBoardMetricPillV1(
                key: prominent
                    ? const Key('act0_shell_mistake_attempts_badge')
                    : Key(
                        'act0_shell_mistake_attempts_badge_${mistake.taskId}',
                      ),
                label: mistake.attempts == 1
                    ? '1 miss'
                    : '${mistake.attempts} misses',
                tone: Act0ShellTokensV1.gold,
                icon: Icons.replay_rounded,
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
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
                    label: 'You chose',
                    value: mistake.selectedLabel,
                    color: Act0ShellTokensV1.danger,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: _DecisionPanelV1(
                    label: 'Better',
                    value: mistake.betterLabel,
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  mistake.attempts == 1
                      ? 'Missed 1 time'
                      : 'Missed ${mistake.attempts} times',
                  key: const Key('act0_shell_mistake_attempts'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ),
              ),
              if (mistake.contextLabels.isNotEmpty)
                _ReviewBoardMetricPillV1(
                  key: prominent
                      ? const Key('act0_shell_mistake_context_count_badge')
                      : Key(
                          'act0_shell_mistake_context_count_badge_${mistake.taskId}',
                        ),
                  label: mistake.contextLabels.length == 1
                      ? '1 table cue'
                      : '${mistake.contextLabels.length} table cues',
                  tone: Act0ShellTokensV1.info,
                  icon: Icons.visibility_rounded,
                ),
            ],
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
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(mistake.weaknessLabel, style: Act0ShellTokensV1.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Text(mistake.reason, style: Act0ShellTokensV1.muted),
          if (mistake.contextLabels.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
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
            child: Text(prominent ? 'Repair next' : 'Fix this spot'),
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
    return Container(
      key: Key('act0_shell_fixed_mistake_${mistake.taskId}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.primary.withOpacity(0.12),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: Act0ShellTokensV1.primary.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Act0ShellTokensV1.primary,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mistake.title, style: Act0ShellTokensV1.body),
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                    Text(mistake.weaknessLabel, style: Act0ShellTokensV1.muted),
                  ],
                ),
              ),
              _ReviewBoardMetricPillV1(
                key: quick
                    ? Key('act0_shell_quick_fix_badge_${mistake.taskId}')
                    : Key('act0_shell_fixed_mistake_badge_${mistake.taskId}'),
                label: mistake.severityLabel,
                tone: Act0ShellTokensV1.primary,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            mistake.repairActionLabel,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0.2,
            ),
          ),
          if (onReplay != null) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            FilledButton(
              key: quick
                  ? Key('act0_shell_quick_fix_replay_${mistake.taskId}')
                  : Key('act0_shell_fixed_mistake_replay_${mistake.taskId}'),
              onPressed: () => onReplay!(mistake),
              style: Act0ShellTokensV1.primaryButtonStyle(
                height: Act0ShellTokensV1.compactCtaHeight,
              ),
              child: Text(quick ? 'Run fix again' : 'Replay fix'),
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
