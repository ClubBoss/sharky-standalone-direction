import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_chrome_v1.dart';
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
    final isTablet = Act0ShellTokensV1.isTabletWidth(context);
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final localeIsRu = _isRuLocaleV1(context);
    final nextMistake = review.mistakes.isEmpty ? null : review.mistakes.first;
    final dominantPattern = _dominantReviewPatternV1(review.mistakes);
    final recovered = <Act0MistakeCardV1>[
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel != 'Quick fix',
      ),
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel == 'Quick fix',
      ),
    ];
    final leftColumn = <Widget>[
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
      if (dominantPattern != null) ...[
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        _ReviewPatternCardV1(pattern: dominantPattern, localeIsRu: localeIsRu),
      ],
      const SizedBox(height: Act0ShellTokensV1.gapLg),
      _ReviewBoardV1(
        review: review,
        nextMistake: nextMistake,
        onFixMistake: onFixMistake,
      ),
    ];
    final activeRepairColumn = <Widget>[
      if (review.mistakes.isEmpty)
        _ReviewEmptyStateV1(review: review)
      else ...[
        Text(
          _reviewCopyV1(context, fallback: 'Start here'),
          style: Act0ShellTokensV1.sectionTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          _reviewCopyV1(
            context,
            en: 'Start with one calm repair rep. Fix this spot first and the rest of the board gets lighter again.',
            ru: 'Начни с одного спокойного ремонтного повтора. Сначала закрепи этот спот, и остальная доска снова станет легче.',
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
                        ? 'Начни с этого. Когда он стабилизируется, следующий спот тоже станет легче.'
                        : 'Начни с этого. Когда он стабилизируется, остальные ${review.mistakes.length - 1} спота тоже станут легче по одному.')
                  : (review.mistakes.length == 2
                        ? 'Start here. Once this settles, the next spot gets easier too.'
                        : 'Start here. Once this settles, the next ${review.mistakes.length - 1} spots get easier one by one.'),
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textDim,
              ),
            ),
          ),
        ],
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
          title: _reviewCopyV1(
            context,
            atomId: 'review_title',
            fallback: review.title,
          ),
          subtitle: _reviewCopyV1(
            context,
            atomId: 'review_subtitle',
            fallback: review.subtitle,
          ),
          eyebrow: _reviewHeaderEyebrowV1(
            localeIsRu: localeIsRu,
            pendingCount: review.mistakes.length,
          ),
          eyebrowTone: review.mistakes.isEmpty
              ? Act0ShellTokensV1.primary
              : Act0ShellTokensV1.gold,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 1080,
          child: isTablet
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
                    if (review.mistakes.isEmpty) ...[
                      ...leftColumn,
                      const SizedBox(height: Act0ShellTokensV1.gapLg),
                      ...rightColumn,
                    ] else ...[
                      ...activeRepairColumn,
                      const SizedBox(height: Act0ShellTokensV1.gapLg),
                      ...leftColumn,
                      ...recoveredColumn,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ReviewPatternSignalV1 {
  const _ReviewPatternSignalV1({
    required this.label,
    required this.count,
    required this.totalAttempts,
    required this.titles,
  });

  final String label;
  final int count;
  final int totalAttempts;
  final List<String> titles;
}

_ReviewPatternSignalV1? _dominantReviewPatternV1(
  List<Act0MistakeCardV1> mistakes,
) {
  if (mistakes.length < 2) {
    return null;
  }
  final grouped = <String, List<Act0MistakeCardV1>>{};
  for (final mistake in mistakes) {
    grouped
        .putIfAbsent(mistake.weaknessLabel, () => <Act0MistakeCardV1>[])
        .add(mistake);
  }
  _ReviewPatternSignalV1? best;
  for (final entry in grouped.entries) {
    final bucket = entry.value;
    final totalAttempts = bucket.fold<int>(
      0,
      (sum, mistake) => sum + mistake.attempts,
    );
    if (bucket.length < 2 && totalAttempts < 3) {
      continue;
    }
    final candidate = _ReviewPatternSignalV1(
      label: entry.key,
      count: bucket.length,
      totalAttempts: totalAttempts,
      titles: bucket.map((mistake) => mistake.title).take(2).toList(),
    );
    if (best == null ||
        candidate.count > best.count ||
        (candidate.count == best.count &&
            candidate.totalAttempts > best.totalAttempts)) {
      best = candidate;
    }
  }
  return best;
}

class _ReviewPatternCardV1 extends StatelessWidget {
  const _ReviewPatternCardV1({required this.pattern, required this.localeIsRu});

  final _ReviewPatternSignalV1 pattern;
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    final examples = pattern.titles.join(' · ');
    return Container(
      key: const Key('act0_shell_review_pattern_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.info.withOpacity(0.24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeIsRu
                ? 'Паттерн начинает проступать'
                : 'Pattern starting to form',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            localeIsRu
                ? '${pattern.label} всплывает ${pattern.count} раза. Сначала почини эту группу.'
                : '${pattern.label} is showing up ${pattern.count} times. Fix this family first.',
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              examples,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _reviewSharkyLineV1({
  required bool localeIsRu,
  required Act0MistakeCardV1? nextMistake,
  required int recoveredCount,
}) {
  final seed = recoveredCount + (nextMistake?.attempts ?? 0);
  if (nextMistake == null) {
    return _pickReviewPaletteLineV1(
      localeIsRu
          ? (recoveredCount > 0
                ? <String>[
                    'Стол снова чист. Этот фикс закрепился.',
                    'Чисто. Этот ремонт не откатился назад.',
                    'Очередь пустая. Исправление действительно закрепилось.',
                  ]
                : <String>[
                    'Стол чист. Держи маршрут в движении.',
                    'Сейчас чисто. Удержи ритм одним спокойным репом.',
                    'Ничего срочного нет. Продолжай ровный ход.',
                  ])
          : (recoveredCount > 0
                ? <String>[
                    'Board is clean again. That repair work stuck.',
                    'Clean board. That fix held up.',
                    'Queue is clear. The repair has actually landed.',
                  ]
                : <String>[
                    'Board is clean. Keep the next step easy.',
                    'Everything is clear right now. Keep rhythm with one calm rep.',
                    'Nothing urgent is pending. Continue with a steady pass.',
                  ]),
      seed: seed,
    );
  }
  if (recoveredCount > 0) {
    return _pickReviewPaletteLineV1(
      localeIsRu
          ? <String>[
              'Сначала один чистый фикс. ${recoveredCount == 1 ? 'Один спот уже вернулся.' : '$recoveredCount спота уже вернулись.'}',
              'Один прицельный фикс первым. ${recoveredCount == 1 ? 'Один спот уже снова под контролем.' : '$recoveredCount спота уже снова под контролем.'}',
              'Сначала снимаем главное давление. ${recoveredCount == 1 ? 'Один спот уже держится.' : '$recoveredCount спота уже держатся.'}',
            ]
          : <String>[
              'One clean fix first. ${recoveredCount == 1 ? 'One spot is already back.' : '$recoveredCount spots are already back.'}',
              'One targeted repair first. ${recoveredCount == 1 ? 'One spot is back under control.' : '$recoveredCount spots are back under control.'}',
              'Remove the main pressure first. ${recoveredCount == 1 ? 'One spot is already holding.' : '$recoveredCount spots are already holding.'}',
            ],
      seed: seed,
    );
  }
  return _pickReviewPaletteLineV1(
    localeIsRu
        ? <String>[
            'Сначала один чистый фикс. Остальное может подождать.',
            'Один фикс за раз. Так быстрее возвращается контроль.',
            'Начни с главного узла. Остальное подтянется следом.',
          ]
        : <String>[
            'One clean fix first. The rest can wait.',
            'One repair at a time. Control returns faster that way.',
            'Start with the top pressure node. The rest follows.',
          ],
    seed: seed,
  );
}

String _reviewHeaderEyebrowV1({
  required bool localeIsRu,
  required int pendingCount,
}) {
  if (pendingCount <= 0) {
    return localeIsRu ? 'Стол чист' : 'Board clean';
  }
  if (pendingCount == 1) {
    return localeIsRu ? '1 фикс ждёт' : '1 fix waiting';
  }
  return localeIsRu
      ? '$pendingCount фикса ждут'
      : '$pendingCount fixes waiting';
}

String _reviewSharkyDetailV1({
  required bool localeIsRu,
  required Act0MistakeCardV1? nextMistake,
  required int recoveredCount,
}) {
  final seed = recoveredCount + (nextMistake?.attempts ?? 0);
  if (nextMistake == null) {
    return _pickReviewPaletteLineV1(
      localeIsRu
          ? (recoveredCount > 0
                ? <String>[
                    'Сейчас в маршруте нет ничего срочного.',
                    'Срочных дырок сейчас нет, можно держать ровный ритм.',
                  ]
                : <String>[
                    'Сейчас путь не тянет ни в какой срочный фикс.',
                    'Пока ничто не требует аварийного ремонта.',
                  ])
          : (recoveredCount > 0
                ? <String>[
                    'Nothing urgent is pulling on the route right now.',
                    'No urgent leaks are pulling on the route right now.',
                  ]
                : <String>[
                    'No urgent repair is pulling on the path right now.',
                    'Nothing requires emergency repair right now.',
                  ]),
      seed: seed,
    );
  }
  if (recoveredCount > 0) {
    return _pickReviewPaletteLineV1(
      localeIsRu
          ? <String>[
              '${nextMistake.weaknessLabel} — следующая точка давления. Почини её, и игра снова станет легче.',
              '${nextMistake.weaknessLabel} сейчас давит сильнее всего. Один чистый фикс вернёт лёгкость.',
            ]
          : <String>[
              '${nextMistake.weaknessLabel} is the next pressure point. Clean it and the board gets lighter again.',
              '${nextMistake.weaknessLabel} is the strongest pressure point now. One clean fix restores flow.',
            ],
      seed: seed,
    );
  }
  return nextMistake.weaknessLabel;
}

String _pickReviewPaletteLineV1(List<String> variants, {required int seed}) {
  final cleaned = variants
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
  if (cleaned.isEmpty) {
    return '';
  }
  return cleaned[seed % cleaned.length];
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
        ? _reviewCopyV1(context, fallback: 'Recovery plan')
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
            fallback:
                'Stabilize this spot first. Then come back for the next check.',
          )
        : (review.strongSpots.isEmpty
              ? _reviewCopyV1(
                  context,
                  atomId: 'review_board_support_clean_empty',
                  fallback: 'Nothing to fix yet. Keep the next step easy.',
                )
              : _reviewCopyV1(
                  context,
                  atomId: 'review_board_support_clean_strong',
                  fallback: 'You are clean right now. Keep the next step easy.',
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
                    maxLines: 4,
                    overflow: TextOverflow.fade,
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
                _reviewCopyV1(context, fallback: 'Review repair cue'),
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
    final compact = !Act0ShellTokensV1.isTabletWidth(context);
    final iconTile = Container(
      width: compact ? 38 : 42,
      height: compact ? 38 : 42,
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: Act0ShellTokensV1.primary,
      ),
    );

    return Container(
      key: const Key('act0_shell_review_empty_state'),
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapMd : Act0ShellTokensV1.gapLg,
      ),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.34),
      ),
      child: compact
          ? Column(
              key: const Key('act0_shell_review_empty_state_layout'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconTile,
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Expanded(
                      child: Text(
                        review.emptyTitle,
                        style: Act0ShellTokensV1.cardTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Text(
                  review.emptyBody,
                  key: const Key('act0_shell_review_empty_body'),
                  maxLines: 4,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            )
          : Row(
              key: const Key('act0_shell_review_empty_state_layout'),
              children: [
                iconTile,
                const SizedBox(width: Act0ShellTokensV1.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.emptyTitle,
                        style: Act0ShellTokensV1.cardTitle,
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapXs),
                      Text(
                        review.emptyBody,
                        key: const Key('act0_shell_review_empty_body'),
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.muted,
                      ),
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
            child: Text(prominent ? 'Start repair rep' : 'Repair this spot'),
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
    final completionState = mistake.completionState;
    final badgeLabel = switch (completionState) {
      Act0CompletionDisplayStateV1.perfect => _reviewCopyV1(
        context,
        en: 'Perfect',
        ru: 'Идеально',
      ),
      Act0CompletionDisplayStateV1.clear => _reviewCopyV1(
        context,
        en: 'Clear',
        ru: 'Пройдено',
      ),
      _ => mistake.severityLabel,
    };
    final badgeTone = completionState == Act0CompletionDisplayStateV1.perfect
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final detailLine = mistake.qualityLine.isNotEmpty
        ? mistake.qualityLine
        : mistake.repairActionLabel;
    final replayLabel = switch (completionState) {
      Act0CompletionDisplayStateV1.perfect => _reviewCopyV1(
        context,
        en: 'Review this spot',
        ru: 'Разобрать этот спот',
      ),
      Act0CompletionDisplayStateV1.clear => _reviewCopyV1(
        context,
        en: 'Replay for perfect',
        ru: 'Повторить для идеала',
      ),
      _ =>
        quick
            ? _reviewCopyV1(
                context,
                en: 'Replay quick fix',
                ru: 'Повторить быстрый фикс',
              )
            : _reviewCopyV1(
                context,
                en: 'Replay this spot',
                ru: 'Повторить этот спот',
              ),
    };
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
                label: badgeLabel,
                tone: badgeTone,
                icon: completionState == Act0CompletionDisplayStateV1.perfect
                    ? Icons.auto_awesome_rounded
                    : Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            detailLine,
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
              child: Text(replayLabel),
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
