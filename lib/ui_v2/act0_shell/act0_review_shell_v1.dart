import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

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
    final nextMistake = review.mistakes.isEmpty ? null : review.mistakes.first;
    final canDoBetter = review.mistakes
        .where((mistake) => mistake.severityLabel == 'Can do better')
        .toList();
    final deepLeaks = review.mistakes
        .where((mistake) => mistake.severityLabel == 'Deep leak')
        .toList();
    final stillOpen = review.mistakes
        .where(
          (mistake) =>
              mistake.severityLabel != 'Deep leak' &&
              mistake.severityLabel != 'Can do better',
        )
        .toList();
    final quickFixes = review.fixedMistakes
        .where((mistake) => mistake.severityLabel == 'Quick fix')
        .toList();
    final recentlyFixed = review.fixedMistakes
        .where((mistake) => mistake.severityLabel != 'Quick fix')
        .toList();
    return ListView(
      key: const Key('act0_shell_review_screen'),
      padding: const EdgeInsets.fromLTRB(
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.gapLg,
        Act0ShellTokensV1.pageX,
        Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
      ),
      children: [
        Text(review.title, style: Act0ShellTokensV1.screenTitle),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(review.subtitle, style: Act0ShellTokensV1.muted),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Row(
          children: [
            for (var index = 0; index < review.stats.length; index++) ...[
              Expanded(
                child: _ReviewStatV1(
                  label: review.stats[index].label,
                  value: review.stats[index].value,
                ),
              ),
              if (index < review.stats.length - 1)
                const SizedBox(width: Act0ShellTokensV1.gapSm),
            ],
          ],
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _ReviewBoardV1(
          review: review,
          nextMistake: nextMistake,
          onFixMistake: onFixMistake,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        if (review.mistakes.isEmpty)
          _ReviewEmptyStateV1(review: review)
        else ...[
          if (deepLeaks.isNotEmpty) ...[
            Text('Needs work', style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            for (final mistake in deepLeaks) ...[
              _MistakeCardV1(
                mistake: mistake,
                prominent: mistake.taskId == review.mistakes.first.taskId,
                onFixMistake: onFixMistake,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
            ],
          ],
          if (stillOpen.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Text('Still open', style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            for (final mistake in stillOpen) ...[
              _MistakeCardV1(
                mistake: mistake,
                prominent: mistake.taskId == review.mistakes.first.taskId,
                onFixMistake: onFixMistake,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
            ],
          ],
          if (canDoBetter.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Text('Can do better', style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            for (final item in canDoBetter) ...[
              _MistakeCardV1(
                mistake: item,
                prominent: false,
                onFixMistake: onFixMistake,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
            ],
          ],
        ],
        if (quickFixes.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          Text('Quick fixes', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (final mistake in quickFixes.take(3)) ...[
            _FixedMistakeCardV1(
              mistake: mistake,
              quick: true,
              onReplay: onReplayFixedMistake,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
        if (recentlyFixed.isNotEmpty) ...[
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          Text('Recently fixed', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (final mistake in recentlyFixed.take(3)) ...[
            _FixedMistakeCardV1(
              mistake: mistake,
              onReplay: onReplayFixedMistake,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Text('Strong spots', style: Act0ShellTokensV1.sectionTitle),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Wrap(
          spacing: Act0ShellTokensV1.gapSm,
          runSpacing: Act0ShellTokensV1.gapSm,
          children: [
            for (final spot in review.strongSpots)
              _SpotPillV1(label: spot, color: Act0ShellTokensV1.primary),
            if (review.strongSpots.isEmpty)
              const _SpotPillV1(
                label: 'Finish a clean drill',
                color: Act0ShellTokensV1.textDim,
              ),
          ],
        ),
      ],
    );
  }
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
    final openCount = review.mistakes.length;
    final fixedCount = review.fixedMistakes.length;
    final strongCount = review.strongSpots.length;
    final hasRepair = nextMistake != null;
    final tone = hasRepair ? Act0ShellTokensV1.gold : Act0ShellTokensV1.primary;
    final title = hasRepair ? 'Repair first' : 'Review board';
    final headline = hasRepair ? nextMistake!.title : 'Board is clean';
    final body = hasRepair
        ? nextMistake!.reason
        : 'No urgent fixes right now. Keep the board clean with one crisp run.';
    final support = hasRepair
        ? 'Fix one weak spot. Then keep the path moving.'
        : (review.strongSpots.isEmpty
              ? 'Finish one clean drill to start a momentum streak.'
              : 'Keep your strongest reads warm while the board stays clean.');
    final nextActionLabel = hasRepair ? 'Repair first' : 'Daily set';
    final nextActionTitle = hasRepair
        ? 'Fix ${nextMistake!.weaknessLabel} now'
        : 'Run daily set';
    final nextActionBody = hasRepair
        ? 'Fix this spot now. On repair: return to your main path.'
        : 'Three crisp reps keep this board empty and your strong reads warm.';

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
          Wrap(
            spacing: Act0ShellTokensV1.gapSm,
            runSpacing: Act0ShellTokensV1.gapSm,
            children: [
              _ReviewBoardMetricPillV1(
                key: const Key('act0_shell_review_board_open_count'),
                label: openCount == 1
                    ? '1 to fix now'
                    : '$openCount to fix now',
                tone: hasRepair
                    ? Act0ShellTokensV1.gold
                    : Act0ShellTokensV1.textDim,
                icon: Icons.flag_rounded,
              ),
              _ReviewBoardMetricPillV1(
                key: const Key('act0_shell_review_board_fixed_count'),
                label: fixedCount == 1
                    ? '1 recovered'
                    : '$fixedCount recovered',
                tone: Act0ShellTokensV1.primary,
                icon: Icons.check_circle_rounded,
              ),
              _ReviewBoardMetricPillV1(
                key: const Key('act0_shell_review_board_strong_count'),
                label: strongCount == 1
                    ? '1 strong read'
                    : '$strongCount strong reads',
                tone: Act0ShellTokensV1.info,
                icon: Icons.bolt_rounded,
              ),
            ],
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
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            'Mistakes are data. Your next decision is what counts.',
            key: const Key('act0_shell_review_board_trust_line'),
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Container(
            key: const Key('act0_shell_review_board_next_action'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(
                color: hasRepair
                    ? Act0ShellTokensV1.gold.withOpacity(0.28)
                    : Act0ShellTokensV1.primary.withOpacity(0.24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasRepair ? Icons.build_rounded : Icons.play_arrow_rounded,
                  size: 18,
                  color: hasRepair
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.primary,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextActionLabel,
                        key: const Key(
                          'act0_shell_review_board_next_action_label',
                        ),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: hasRepair
                              ? Act0ShellTokensV1.gold
                              : Act0ShellTokensV1.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextActionTitle,
                        key: const Key(
                          'act0_shell_review_board_next_action_title',
                        ),
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextActionBody,
                        key: const Key(
                          'act0_shell_review_board_next_action_body',
                        ),
                        style: Act0ShellTokensV1.muted,
                      ),
                    ],
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
              label: const Text('Fix now'),
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
            width: 8,
            height: 8,
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
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.border.withOpacity(0.92)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
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
