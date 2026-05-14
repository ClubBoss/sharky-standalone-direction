import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';

enum Act0WelcomeBeatV1 { intro, whyEasier, appShape, demoSpot, handoff }

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
  String? _selectedOptionId;

  bool get _isRuLocaleV1 => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

  String _atomV1(String atomId, {required String fallback}) =>
      act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

  bool get _isDemoReviewV1 => _selectedOptionId != null;

  Act0RunnerStateV1 get _demoRunnerV1 {
    final correctId = 'hero_bottom';
    final selected = _selectedOptionId;
    final inReview = selected != null;
    return Act0RunnerStateV1(
      lessonId: 'welcome_demo_spot_v1',
      lessonTitle: _copyV1(
        en: 'Your first live read',
        ru: 'Твой первый живой рид',
      ),
      lessonSubtitle: _copyV1(
        en: 'One calm table read, then one clean answer.',
        ru: 'Один спокойный рид стола, потом один чистый ответ.',
      ),
      beatIndex: 4,
      beatCount: 5,
      phase: inReview ? Act0LessonPhaseV1.review : Act0LessonPhaseV1.drill,
      caption: _copyV1(
        en: 'Start with the seat that is always yours.',
        ru: 'Начни с места, которое всегда твоё.',
      ),
      hint: _copyV1(
        en: 'Find Hero before you think about action.',
        ru: 'Сначала найди Hero, потом думай о действии.',
      ),
      question: _copyV1(
        en: 'Which seat is your seat in Sharky reps?',
        ru: 'Какое место на столе всегда твоё?',
      ),
      options: <Act0RunnerOptionV1>[
        Act0RunnerOptionV1(
          id: 'hero_top',
          label: _copyV1(en: 'Top seat', ru: 'Верхнее место'),
          isCorrect: false,
          preferredLabel: _copyV1(en: 'Bottom seat', ru: 'Нижнее место'),
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: _copyV1(en: 'Almost there.', ru: 'Почти.'),
          feedbackReason: _copyV1(
            en: 'In Sharky reps, Hero stays at the bottom so the table always reads from your point of view.',
            ru: 'В тренировках Sharky твоё место всегда снизу, чтобы стол читался с твоей точки зрения.',
          ),
          repairFocusSeatIds: const <String>['BTN'],
          repairFocusLabels: <String>[
            _copyV1(en: 'Hero', ru: 'Твоё место'),
            _copyV1(en: 'Bottom seat', ru: 'Нижнее место'),
          ],
        ),
        Act0RunnerOptionV1(
          id: correctId,
          label: _copyV1(en: 'Bottom seat', ru: 'Нижнее место'),
          isCorrect: true,
          preferredLabel: _copyV1(en: 'Bottom seat', ru: 'Нижнее место'),
          quality: Act0FeedbackQualityV1.correct,
          feedbackTitle: _copyV1(en: 'Sharp read.', ru: 'Точный рид.'),
          feedbackReason: _copyV1(
            en: 'Good. Hero lives at the bottom, so every next read starts from your own seat.',
            ru: 'Отлично. Твоё место всегда снизу, поэтому любой следующий разбор начинается с твоей точки зрения.',
          ),
          repairFocusSeatIds: const <String>['BTN'],
          repairFocusLabels: <String>[
            _copyV1(en: 'Hero', ru: 'Твоё место'),
            _copyV1(en: 'Bottom seat', ru: 'Нижнее место'),
          ],
        ),
      ],
      selectedOptionId: selected,
      feedbackTitle: _copyV1(en: 'Sharp read.', ru: 'Точный рид.'),
      feedbackReason: _copyV1(
        en: 'Good. Hero lives at the bottom, so every next read starts from your own seat.',
        ru: 'Отлично. Твоё место всегда снизу, поэтому любой следующий разбор начинается с твоей точки зрения.',
      ),
      primaryCtaLabel: _copyV1(en: 'Continue', ru: 'Продолжить'),
      nextLessonId: null,
      returnTarget: _copyV1(en: 'Welcome', ru: 'Старт'),
      table: _demoTableV1(_copyV1),
      sharky: Act0SharkyCueV1.beginner.copyWith(
        preSessionLine: _copyV1(
          en: 'One clear read, then one clear action.',
          ru: 'Один ясный рид, потом одно ясное действие.',
        ),
        summaryLine: _copyV1(
          en: 'That is the loop: read, answer, understand, move on.',
          ru: 'Вот и цикл: увидел, ответил, понял, пошёл дальше.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_beat) {
      Act0WelcomeBeatV1.intro => _WelcomeTextBeatV1(
        beatIndex: 1,
        beatCount: 5,
        title: _atomV1(
          'welcome_intro_title',
          fallback: 'Learn one spot at a time.',
        ),
        eyebrow: _atomV1('welcome_intro_eyebrow', fallback: 'Welcome'),
        line: _atomV1(
          'welcome_intro_line',
          fallback:
              'Sharky keeps the next move obvious: one table read, one answer, one clear why.',
        ),
        detail: _atomV1(
          'welcome_intro_detail',
          fallback: 'No long theory wall. No guessing what matters first.',
        ),
        mood: Act0SharkyMoodV1.happy,
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        ctaLabel: _atomV1('welcome_intro_cta', fallback: 'See why it works'),
        onNext: () => setState(() => _beat = Act0WelcomeBeatV1.whyEasier),
      ),
      Act0WelcomeBeatV1.whyEasier => _WelcomeTextBeatV1(
        beatIndex: 2,
        beatCount: 5,
        title: _atomV1(
          'welcome_why_title',
          fallback: 'This feels lighter on purpose.',
        ),
        eyebrow: _atomV1('welcome_why_eyebrow', fallback: 'Why it works'),
        line: _atomV1(
          'welcome_why_line',
          fallback:
              'Sharky teaches one decision at a time, right next to the table.',
        ),
        detail: _atomV1(
          'welcome_why_detail',
          fallback:
              'You see the clue, answer once, get the reason, and keep moving.',
        ),
        mood: Act0SharkyMoodV1.thinking,
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        ctaLabel: _atomV1('welcome_why_cta', fallback: 'Show me the app shape'),
        onNext: () => setState(() => _beat = Act0WelcomeBeatV1.appShape),
      ),
      Act0WelcomeBeatV1.appShape => _WelcomeAppShapeBeatV1(
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        onNext: () => setState(() => _beat = Act0WelcomeBeatV1.demoSpot),
        copy: _copyV1,
      ),
      Act0WelcomeBeatV1.demoSpot => Act0LessonRunnerShellV1(
        key: const Key('act0_shell_welcome_demo_spot'),
        runner: _demoRunnerV1,
        onBack: widget.replayMode && widget.onClose != null
            ? widget.onClose!
            : () => setState(() => _beat = Act0WelcomeBeatV1.appShape),
        onContinueTheory: () {},
        onChooseOption: (option) {
          setState(() {
            _selectedOptionId = option.id;
          });
        },
        onContinueReview: () {
          setState(() {
            _selectedOptionId = null;
            _beat = Act0WelcomeBeatV1.handoff;
          });
        },
        tableVisualVariant: widget.tableVisualVariant,
      ),
      Act0WelcomeBeatV1.handoff => _WelcomeTextBeatV1(
        beatIndex: 5,
        beatCount: 5,
        title: _copyV1(
          en: widget.replayMode
              ? 'You can reopen this anytime.'
              : 'You are ready for Poker from Zero.',
          ru: widget.replayMode
              ? 'Ты можешь открыть это снова в любой момент.'
              : 'Ты готов к Poker from Zero.',
        ),
        eyebrow: _atomV1('welcome_handoff_eyebrow', fallback: 'Next step'),
        line: _copyV1(
          en: widget.replayMode
              ? 'The route stays the same: Home shows what to do now, and Learn keeps the path visible.'
              : 'Now the route can stay simple: Home shows what to do now, and Learn keeps the path visible.',
          ru: widget.replayMode
              ? 'Путь остаётся тем же: Home показывает, что делать сейчас, а Learn держит маршрут на виду.'
              : 'Теперь маршрут может быть простым: Home показывает, что делать сейчас, а Learn держит путь на виду.',
        ),
        detail: _copyV1(
          en: widget.replayMode
              ? 'Go back when you are ready. Your progress stays exactly where it was.'
              : 'You already know the loop. Next comes the first real lesson.',
          ru: widget.replayMode
              ? 'Возвращайся, когда будешь готов. Прогресс останется ровно там, где был.'
              : 'Цикл уже понятен. Дальше идёт первый настоящий урок.',
        ),
        mood: Act0SharkyMoodV1.celebrate,
        replayMode: widget.replayMode,
        onClose: widget.onClose,
        ctaLabel: _copyV1(
          en: widget.replayMode ? 'Back to profile' : 'Open Poker from Zero',
          ru: widget.replayMode ? 'Назад в профиль' : 'Открыть Poker from Zero',
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
            Text(title, style: Act0ShellTokensV1.sectionTitle),
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Act0SharkyGuideCardV1(
              eyebrow: eyebrow,
              line: line,
              detail: blocks.join(' '),
              mood: mood,
              compact: true,
            ),
            const Spacer(),
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

class _WelcomeAppShapeBeatV1 extends StatelessWidget {
  const _WelcomeAppShapeBeatV1({
    required this.replayMode,
    required this.onNext,
    required this.copy,
    this.onClose,
  });

  final bool replayMode;
  final VoidCallback onNext;
  final VoidCallback? onClose;
  final String Function({required String en, required String ru}) copy;

  @override
  Widget build(BuildContext context) {
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
              beatIndex: 3,
              beatCount: 5,
              replayMode: replayMode,
              onClose: onClose,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Text(
              copy(
                en: 'Each tab has one clear job.',
                ru: 'У каждой вкладки одна ясная задача.',
              ),
              style: Act0ShellTokensV1.sectionTitle,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapLg),
            Expanded(
              child: ListView(
                children: [
                  _WelcomeRoleCardV1(
                    keyName: 'home',
                    title: 'Home',
                    body: copy(
                      en: 'Shows the next useful move right now.',
                      ru: 'Показывает следующий полезный шаг прямо сейчас.',
                    ),
                    tone: Act0ShellTokensV1.primary,
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapMd),
                  _WelcomeRoleCardV1(
                    keyName: 'learn',
                    title: 'Learn',
                    body: copy(
                      en: 'Keeps the route visible so nothing important goes missing.',
                      ru: 'Держит маршрут на виду, чтобы ничего важного не терялось.',
                    ),
                    tone: Act0ShellTokensV1.info,
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapMd),
                  _WelcomeRoleCardV1(
                    keyName: 'play',
                    title: 'Play',
                    body: copy(
                      en: 'Gives extra reps when you want more volume.',
                      ru: 'Даёт больше практики, когда хочется ещё немного.',
                    ),
                    tone: Act0ShellTokensV1.gold,
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapMd),
                  _WelcomeRoleCardV1(
                    keyName: 'review',
                    title: 'Review',
                    body: copy(
                      en: 'Keeps mistakes close so leaks do not pile up quietly.',
                      ru: 'Возвращает к ошибкам сразу, чтобы они не копились.',
                    ),
                    tone: Act0ShellTokensV1.danger,
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
                child: Text(
                  copy(
                    en: 'Show me one live spot',
                    ru: 'Покажи один живой спот',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeRoleCardV1 extends StatelessWidget {
  const _WelcomeRoleCardV1({
    required this.keyName,
    required this.title,
    required this.body,
    required this.tone,
  });

  final String keyName;
  final String title;
  final String body;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_welcome_role_$keyName'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
        borderColor: tone.withOpacity(0.22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0ShellTokensV1.label.copyWith(color: tone)),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(body, style: Act0ShellTokensV1.body),
        ],
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

Act0TableStateV1 _demoTableV1(
  String Function({required String en, required String ru}) copy,
) {
  return Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      const Act0SeatStateV1(
        seatId: 'UTG',
        seatLabel: 'UTG',
        displayName: 'UTG',
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '', suit: ''),
          Act0CardStateV1(rank: '', suit: ''),
        ],
      ),
      const Act0SeatStateV1(
        seatId: 'HJ',
        seatLabel: 'HJ',
        displayName: 'HJ',
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '', suit: ''),
          Act0CardStateV1(rank: '', suit: ''),
        ],
      ),
      const Act0SeatStateV1(
        seatId: 'CO',
        seatLabel: 'CO',
        displayName: 'CO',
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '', suit: ''),
          Act0CardStateV1(rank: '', suit: ''),
        ],
      ),
      const Act0SeatStateV1(
        seatId: 'BTN',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: '♠'),
          Act0CardStateV1(rank: 'J', suit: '♣'),
        ],
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      const Act0SeatStateV1(
        seatId: 'SB',
        seatLabel: 'SB',
        displayName: 'SB',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        currentBetLabel: '0.5 BB',
        bet: Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'SB',
          amountLabel: '0.5 BB',
        ),
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '', suit: ''),
          Act0CardStateV1(rank: '', suit: ''),
        ],
      ),
      const Act0SeatStateV1(
        seatId: 'BB',
        seatLabel: 'BB',
        displayName: 'BB',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        currentBetLabel: '1 BB',
        bet: Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.post,
          label: 'BB',
          amountLabel: '1 BB',
        ),
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: '', suit: ''),
          Act0CardStateV1(rank: '', suit: ''),
        ],
      ),
    ],
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: '♠'),
      Act0CardStateV1(rank: 'J', suit: '♣'),
    ],
    boardCards: const <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: copy(en: 'Read the table first', ru: 'Сначала прочитай стол'),
    focusCalloutLabel: copy(
      en: 'Hero stays at the bottom',
      ru: 'Твоё место всегда снизу',
    ),
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(
        label: copy(en: 'Blinds posted', ru: 'Блайнды поставлены'),
      ),
      const Act0ActionTrailItemV1(label: 'Preflop'),
    ],
    activeSeatId: 'BTN',
    heroSeatId: 'BTN',
    highlightedSeatIds: const <String>['BTN'],
    highlightedCardIds: const <String>[],
    instructionAnchor: 'seat',
  );
}
