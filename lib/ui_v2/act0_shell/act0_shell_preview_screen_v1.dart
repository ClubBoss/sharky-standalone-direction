import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_premium_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_preferences_service.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

Act0RunnerStateV1 normalizeAct0SeatTapRunnerV1(Act0RunnerStateV1 runner) {
  final seatOptions = runner.options
      .where((option) => (option.seatId ?? '').trim().isNotEmpty)
      .toList(growable: false);
  if (seatOptions.isEmpty) {
    return runner;
  }

  Act0RunnerOptionV1? correctOption;
  for (final option in seatOptions) {
    if (option.isCorrect) {
      correctOption = option;
      break;
    }
  }
  if (correctOption == null) {
    return runner;
  }

  final visibleSeats = runner.table.seats
      .where((seat) {
        final seatId = seat.seatId.trim();
        return seatId.isNotEmpty && (seat.isOccupied || seat.isHero);
      })
      .toList(growable: false);
  if (visibleSeats.isEmpty) {
    return runner;
  }

  final optionsBySeatId = <String, Act0RunnerOptionV1>{
    for (final option in seatOptions) option.seatId!.trim(): option,
  };
  final correctSeatId = correctOption.seatId!.trim();
  final expandedOptions = <Act0RunnerOptionV1>[
    for (final seat in visibleSeats)
      optionsBySeatId[seat.seatId.trim()] ??
          Act0RunnerOptionV1(
            id: '__seat_tap__${runner.lessonId}_${seat.seatId.trim()}',
            label: seat.seatLabel,
            seatId: seat.seatId.trim(),
            isCorrect: false,
            preferredLabel: correctOption.preferredLabel,
            betterAnswerLabel: correctOption.betterAnswerLabel,
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Almost there.',
            feedbackReason:
                '${seat.seatLabel} is not the target seat in this spot.',
            repairFocusSeatIds: <String>[seat.seatId.trim(), correctSeatId],
            repairFocusLabels: <String>[
              seat.seatLabel,
              correctOption.preferredLabel,
            ],
          ),
  ];

  return runner.copyWith(
    options: expandedOptions,
    table: runner.table.copyWith(
      selectableSeatIds: visibleSeats
          .map((seat) => seat.seatId.trim())
          .toList(growable: false),
    ),
  );
}

Act0RunnerStateV1 normalizeAct0DrillSeatHighlightPolicyV1(
  Act0RunnerStateV1 runner,
) {
  if (runner.phase != Act0LessonPhaseV1.drill) {
    return runner;
  }
  final activeSeatId = (runner.table.activeSeatId ?? '').trim();
  return runner.copyWith(
    table: runner.table.copyWith(
      activeSeatId: activeSeatId,
      highlightedSeatIds: activeSeatId.isEmpty
          ? const <String>[]
          : <String>[activeSeatId],
    ),
  );
}

enum _Act0LearningNextActionKindV1 {
  repairDeepLeak,
  repairWeakSpot,
  reviewQuickFix,
  continueLesson,
  dailyDrill,
  categoryPractice,
  dailyDone,
}

const Set<String> _kPracticePrimaryGroupIdsV1 = <String>{'daily', 'weak_spots'};

class _Act0LearningRecommendationV1 {
  const _Act0LearningRecommendationV1({
    required this.kind,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.hint,
    required this.outcome,
    this.mistake,
    this.lessonId,
    this.taskId,
    this.practiceGroupId,
  });

  final _Act0LearningNextActionKindV1 kind;
  final String label;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String hint;
  final String outcome;
  final Act0MistakeCardV1? mistake;
  final String? lessonId;
  final String? taskId;
  final String? practiceGroupId;
}

class _Act0PracticeSurfaceRecommendationV1 {
  const _Act0PracticeSurfaceRecommendationV1({
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.reasonLabel,
    required this.outcomeLead,
    required this.outcome,
    required this.masteryLabel,
    required this.screenSubtitle,
  });

  final String groupId;
  final String title;
  final String subtitle;
  final String reasonLabel;
  final String outcomeLead;
  final String outcome;
  final String masteryLabel;
  final String screenSubtitle;
}

class Act0ShellPreviewScreenV1 extends StatefulWidget {
  const Act0ShellPreviewScreenV1({
    super.key,
    this.initialTab = Act0ShellTabV1.home,
    this.initialPhase = Act0LessonPhaseV1.theory,
    this.state,
    this.showPlacementOnStart = true,
    // Dev2 is now the canonical detached Act0 shell. The classic variant stays
    // available for explicit fallback comparisons.
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final Act0ShellTabV1 initialTab;
  final Act0LessonPhaseV1 initialPhase;
  final Act0ShellStateV1? state;
  final bool showPlacementOnStart;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0ShellPreviewScreenV1> createState() =>
      _Act0ShellPreviewScreenV1State();
}

class _Act0ShellPreviewScreenV1State extends State<Act0ShellPreviewScreenV1> {
  static const String _progressPrefsKey = 'act0_shell_progress_v1';
  static const int _homeHandoffDismissDays = 7;
  static const Set<String> _w5SizingDrillTaskIds = <String>{
    'w4_small_bet',
    'w4_half_pot_bet',
    'w4_pot_bet',
  };

  late Act0ShellTabV1 _tab;
  late Act0LessonPhaseV1 _phase;
  late String _selectedWorldId;
  late String _selectedLessonId;
  late String _selectedTaskId;
  String? _learnPopupTaskId;
  late Set<String> _completedLessonIds;
  late Set<String> _completedTaskIds;
  final Set<String> _skippedTaskIds = <String>{};
  final Set<String> _visibleSkippedTaskIds = <String>{};
  bool _showWorldMenu = false;
  String? _learnDetailWorldId;
  String? _learnDetailLessonId;
  String? _selectedOptionId;
  String? _selectedPresetId;
  String? _selectedPresetTaskId;
  String? _reviewConfidence;
  int _teachingStepIndex = 0;
  int _earnedXp = 0;
  int _lessonRunXp = 0;
  bool _showPlayHub = true;
  bool _returnToPlayHubOnBack = false;
  final Map<String, _Act0MistakeRecordV1> _mistakeRecords =
      <String, _Act0MistakeRecordV1>{};
  final Set<String> _resolvedMistakeTaskIds = <String>{};
  final Set<String> _cleanTaskIds = <String>{};
  final Set<String> _lessonRunMistakeTaskIds = <String>{};
  final Set<String> _lessonRunPendingRetryTaskIds = <String>{};
  final Set<String> _lessonRunRetriedTaskIds = <String>{};
  final Set<String> _lessonRunWrapUpCompletedTaskIds = <String>{};
  final Set<String> _lessonRunQuickFixTaskIds = <String>{};
  final Set<String> _lessonRunDeepLeakTaskIds = <String>{};
  final Map<String, int> _lessonRunSkillGainCounts = <String, int>{};
  final Set<String> _dailyCompletedTaskIds = <String>{};
  int _dailyCompletedRepCount = 0;
  bool _rapidPracticeLoop = false;
  int _persistedStreakDays = 0;
  String _lastDailyDate = '';
  String? _activePracticeGroupId;
  String? _activeRepairTaskId;
  String? _activeLessonWrapUpTaskId;
  String? _lessonRunWrapUpAnchorTaskId;
  String? _practiceCompletionTitle;
  String? _practiceCompletionBody;
  Act0BlockCompletionSummaryV1? _blockCompletionSummary;
  bool _showPlacement = false;
  bool _placementDiagnosticActive = false;
  bool _placementIntroVisible = true;
  bool _placementTrialPreviewSelected = false;
  int _placementQuestionIndex = 0;
  int _placementDiagnosticIndex = 0;
  int _placementDiagnosticCorrect = 0;
  int _placementDiagnosticScore = 0;
  bool get _isRuLocaleV1 => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

  String _localizedLessonTitleV1(Act0LessonCardV1 lesson) =>
      act0LocalizedLessonTitleAtomByIdV1(
        lesson.lessonId,
        fallback: lesson.title,
        isRu: _isRuLocaleV1,
      );

  String _localizedLessonSubtitleV1(Act0LessonCardV1 lesson) =>
      act0LocalizedLessonSubtitleAtomByIdV1(
        lesson.lessonId,
        fallback: lesson.subtitle,
        isRu: _isRuLocaleV1,
      );

  String _localizedTaskTitleV1(Act0LessonTaskV1 task) =>
      act0LocalizedTaskTitleAtomByIdV1(
        task.taskId,
        fallback: task.title,
        isRu: _isRuLocaleV1,
      );

  String _localizedTaskSummaryV1(Act0LessonTaskV1 task) =>
      act0LocalizedTaskSummaryAtomByIdV1(
        task.taskId,
        fallback: task.summary ?? task.runner.caption,
        isRu: _isRuLocaleV1,
      );

  List<Act0PlacementQuestionV1> _localizedPlacementQuestionsV1() {
    if (!_isRuLocaleV1) {
      return _placementQuestionsV1;
    }
    return _placementQuestionsV1
        .map(_localizePlacementQuestionV1)
        .toList(growable: false);
  }

  Act0PlacementQuestionV1 _localizePlacementQuestionV1(
    Act0PlacementQuestionV1 question,
  ) {
    return Act0PlacementQuestionV1(
      questionId: question.questionId,
      eyebrow: _localizedPlacementQuestionEyebrowV1(question),
      title: _localizedPlacementQuestionTitleV1(question),
      subtitle: _localizedPlacementQuestionSubtitleV1(question),
      helper: _localizedPlacementQuestionHelperV1(question),
      icon: question.icon,
      allowsMultiple: question.allowsMultiple,
      minSelections: question.minSelections,
      maxSelections: question.maxSelections,
      options: question.options
          .map(
            (option) => _localizePlacementOptionV1(question.questionId, option),
          )
          .toList(growable: false),
    );
  }

  Act0PlacementOptionV1 _localizePlacementOptionV1(
    String questionId,
    Act0PlacementOptionV1 option,
  ) {
    return Act0PlacementOptionV1(
      optionId: option.optionId,
      label: _localizedPlacementOptionLabelV1(questionId, option),
      score: option.score,
      profileTag: _localizedPlacementProfileTagV1(option.profileTag),
      subtitle: _localizedPlacementOptionSubtitleV1(questionId, option),
      icon: option.icon,
      badge: _localizedPlacementOptionBadgeV1(questionId, option),
    );
  }

  Act0PlacementResultV1 _localizedPlacementResultV1(
    Act0PlacementResultV1 result,
  ) {
    if (!_isRuLocaleV1) {
      return result;
    }
    return Act0PlacementResultV1(
      level: result.level,
      levelLabel: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics => 'Готов к базовым решениям',
        Act0PlacementResultLevelV1.rustyBeginner => 'Подзабывший новичок',
        Act0PlacementResultLevelV1.newPlayer => 'Новый игрок',
      },
      summary: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Ты уже достаточно читаешь стол, чтобы начать с реальных решений.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'База уже есть. Теперь нужно успокоить ход раздачи, прежде чем ускоряться.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Лучший старт сейчас - спокойно собрать фундамент и почувствовать стол.',
      },
      reportHeadline: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics => 'Стартуем с действий',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Сначала стабилизируем ход раздачи',
        Act0PlacementResultLevelV1.newPlayer =>
          'Сначала фундамент, потом решения',
      },
      reportBody: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Тебе уже не нужен долгий разгон. Шарки может быстрее перейти к языку действий и при этом держать структуру на виду.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Полный ресет уже не нужен, но раздача всё ещё размывается в ключевых местах. Сначала закрепим этот ритм, потом ускоримся.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Главный пробел сейчас не в стратегии, а в спокойном понимании стола. Сначала Шарки сделает ход раздачи очевидным.',
      },
      coachTitle: 'Шарки',
      coachLine: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Ты готов к языку действий. Я просто не дам структуре исчезнуть, пока чтение не станет уверенным.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'У тебя уже есть база. Теперь я уберу туман в раздаче, прежде чем темп вырастет.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Пока без сложной стратегии. Сначала сделаем стол и ход раздачи спокойными и понятными.',
      },
      profileSummary: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Профиль: уже знаком со столом и готов к первым настоящим решениям.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Профиль: база есть, но руке всё ещё не хватает устойчивости.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Профиль: чистый старт с понятным маршрутом без лишней спешки.',
      },
      diagnosticCorrect: result.diagnosticCorrect,
      diagnosticTotal: result.diagnosticTotal,
      profileSignals: result.profileSignals
          .map(_localizedPlacementSignalLineV1)
          .toList(growable: false),
      analysisHighlights: result.analysisHighlights
          .map(_localizedPlacementHighlightV1)
          .toList(growable: false),
      firstSessionPlan: result.firstSessionPlan
          .map(_localizedPlacementPlanStepV1)
          .toList(growable: false),
      skillStats: result.skillStats
          .map(
            (stat) => Act0PlacementSkillStatV1(
              label: _localizedPlacementSkillLabelV1(stat.label),
              value: stat.value,
              meaning: stat.meaning,
              affects: stat.affects,
              whyImportant: stat.whyImportant,
              locked: stat.locked,
            ),
          )
          .toList(growable: false),
      strengths: result.strengths
          .map(_localizedPlacementAtomV1)
          .toList(growable: false),
      weakSpots: result.weakSpots
          .map(_localizedPlacementAtomV1)
          .toList(growable: false),
      recommendedLessonId: result.recommendedLessonId,
      recommendedTaskId: result.recommendedTaskId,
      recommendedTitle: _localizedPlacementRecommendedTitleV1(
        result.recommendedTitle,
      ),
      recommendedReason: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Живой чек оказался чистым, так что можно начинать с языка действий, а не возвращаться к нулю.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Живой чек показывает: сначала лучше успокоить движение руки, а уже потом ускоряться.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Живой чек говорит, что сначала приложению стоит объяснить сам стол, а не сразу требовать сложные решения.',
      },
      routeTrustLine: switch (result.level) {
        Act0PlacementResultLevelV1.readyForBasics =>
          'Шарки всё равно держит маршрут рядом со стартом, чтобы ни одно важное звено не потерялось.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Ты пропускаешь полный ресет, но маршрут всё равно остаётся рядом с фундаментом.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Маршрут специально стартует со стола, чтобы ничего важного не пряталось под скоростью.',
      },
      premiumPitch:
          'Премиум добавит персональный разбор ошибок, больше практики и более умный недельный ритм после того, как ценность уже показана.',
      trialValuePoints: result.trialValuePoints
          .map(_localizedPlacementTrialPointV1)
          .toList(growable: false),
    );
  }

  String? _localizedPlacementQuestionEyebrowV1(
    Act0PlacementQuestionV1 question,
  ) {
    return switch (question.questionId) {
      'age' => 'Начнём с тебя',
      'experience' => 'Точка старта',
      'frequency' => 'Текущий ритм',
      'format' => 'Твоя цель',
      'confidence' => 'Где помочь сначала',
      'goal' => 'Стиль коучинга',
      _ => question.eyebrow,
    };
  }

  String _localizedPlacementQuestionTitleV1(Act0PlacementQuestionV1 question) {
    return switch (question.questionId) {
      'age' => 'Что сейчас больше всего похоже на тебя?',
      'experience' => 'С какой точки ты стартуешь?',
      'frequency' => 'Как часто ты играешь?',
      'format' => 'Для чего тебе покер?',
      'confidence' => 'Что больше всего путает?',
      'goal' => 'Как Шарки должен тебя вести?',
      _ => question.title,
    };
  }

  String _localizedPlacementQuestionSubtitleV1(
    Act0PlacementQuestionV1 question,
  ) {
    return switch (question.questionId) {
      'age' => 'Это помогает Шарки звучать как коуч, а не как форма настройки.',
      'experience' =>
        'Скажи честно. Это лишь влияет на то, с чего лучше начать.',
      'frequency' =>
        'Так Шарки понимает, нужен ли мягкий разогрев или более быстрые повторы.',
      'format' =>
        'Это влияет на примеры, язык и первые ситуации, которые покажет Шарки.',
      'confidence' => 'Выбери всё, что заставляет тебя тормозить или гадать.',
      'goal' => 'Выбери стиль, который реально удержит тебя в приложении.',
      _ => question.subtitle,
    };
  }

  String? _localizedPlacementQuestionHelperV1(
    Act0PlacementQuestionV1 question,
  ) {
    return switch (question.questionId) {
      'age' =>
        'Здесь нет неправильного ответа. Меняются только тон, темп и первые примеры.',
      'experience' =>
        'Задача не оценить тебя, а не тратить первые сессии впустую.',
      'frequency' =>
        'Если покер не у тебя в руках постоянно, приложение не должно притворяться, что мышечная память уже есть.',
      'format' =>
        'Выбери всё, что реально подходит. Шарки ищет доминирующий паттерн, а не загоняет тебя в одну дорожку.',
      'confidence' =>
        'Шарки использует это, чтобы подстроить первые объяснения, подсказки к разбору и ранние тренировочные споты.',
      'goal' =>
        'Выбери всё, что звучит мотивирующе. Давление должно быть правильным, а не лишним.',
      _ => question.helper,
    };
  }

  String _localizedPlacementOptionLabelV1(
    String questionId,
    Act0PlacementOptionV1 option,
  ) {
    return switch ('$questionId:${option.optionId}') {
      'age:age_18_24' => 'Я совсем новый и хочу, чтобы всё было просто',
      'age:age_25_34' =>
        'Какие-то слова я знаю, но реальные раздачи всё ещё хаотичны',
      'age:age_35_plus' =>
        'Я слежу за покером, но хочу принимать более точные решения',
      'experience:new' => 'Я пока почти не играл',
      'experience:friends' =>
        'Играл по-любительски, в основном угадывал с друзьями',
      'experience:watching' =>
        'Смотрю покерный контент, но в реальных решениях всё замирает',
      'experience:online' =>
        'Играл онлайн или вживую и хочу более чёткую структуру',
      'frequency:rarely' => 'Почти никогда или ещё не играл',
      'frequency:weekly' => 'То да, то нет: в одни недели играю, в другие нет',
      'frequency:often' => 'Довольно регулярно',
      'format:basics' => 'Хочу, чтобы игра наконец начала быть понятной',
      'format:cash' => 'Хочу увереннее чувствовать себя в кэш-спотах',
      'format:tournaments' => 'Мне важнее турнирные решения',
      'format:home_games' => 'Не хочу теряться в домашних играх',
      'format:content' =>
        'Хочу, чтобы видео и разговоры о раздачах перестали звучать загадочно',
      'confidence:rules' => 'Понимать, чей ход и как вообще движется раздача',
      'confidence:cards' => 'Быстро читать карты, пары и силу руки',
      'confidence:decisions' =>
        'Понимать, когда фолдить, коллировать или рейзить, без лишних сомнений',
      'confidence:board' => 'Видеть, что изменилось на флопе, тёрне или ривере',
      'confidence:pressure' =>
        'Сохранять ясность, когда начинаются ставки и давление',
      'goal:guided' => 'Веди меня спокойно и пошагово',
      'goal:practice' => 'Хочу учиться в основном через практику',
      'goal:diagnose' => 'Быстро показывай, где я чаще ошибаюсь',
      'goal:daily_plan' =>
        'Дай короткий план, которого реально можно придерживаться',
      'goal:honest' => 'Будь прямым, когда я начинаю угадывать',
      _ => option.label,
    };
  }

  String? _localizedPlacementOptionSubtitleV1(
    String questionId,
    Act0PlacementOptionV1 option,
  ) {
    return switch ('$questionId:${option.optionId}') {
      'age:age_18_24' => 'Спокойный и ясный старт, шаг за шагом.',
      'age:age_25_34' =>
        'Больше практических примеров и более чёткий ход раздачи.',
      'age:age_35_plus' =>
        'Если можно - двигаемся быстрее, но логику всё равно держим на виду.',
      'experience:new' => 'Старт с нуля и чистая сборка языка стола.',
      'experience:friends' =>
        'Слова уже знакомы, но структуру ещё нужно подтянуть.',
      'experience:watching' =>
        'Превратим пассивное знание в рабочий навык за столом.',
      'experience:online' =>
        'Можем сократить часть интро и быстрее выйти к действиям.',
      'frequency:rarely' =>
        'Сделаем упор на базу стола и очень чистую первую раздачу.',
      'frequency:weekly' =>
        'Какой-то ритм уже есть, но фундамент нужно закрепить.',
      'frequency:often' =>
        'Можно выдержать более плотную практику и более быстрый переход к решениям.',
      'format:basics' =>
        'Сначала грамотность стола, а уже потом стратегия и жаргон.',
      'format:cash' =>
        'Больше примеров про фишки, давление и практические решения.',
      'format:tournaments' =>
        'Больше примеров про выживание, давление и меняющийся leverage.',
      'format:home_games' =>
        'Больше фокуса на ходе раздачи, уверенности и темпе стола.',
      'format:content' =>
        'Больше примеров, которые расшифровывают язык стола, а не подразумевают его.',
      'confidence:rules' =>
        'Хочется, чтобы стол, блайнды и порядок действий перестали быть туманными.',
      'confidence:cards' =>
        'Хочется быстрее читать силу руки и увереннее чувствовать себя на шоудауне.',
      'confidence:decisions' =>
        'Хочется увереннее выбирать правильное действие в правильный момент.',
      'confidence:board' => 'Хочется, чтобы доска читалась, а не шумела.',
      'confidence:pressure' =>
        'Хочется спокойнее принимать решения, когда стол перестаёт быть пассивным.',
      'goal:guided' =>
        'Сначала короткие объяснения, потом мягкая практика, которая действительно укладывается.',
      'goal:practice' =>
        'Меньше разговоров, больше повторов, когда концепт уже виден.',
      'goal:diagnose' =>
        'Быстро подсвечивай слабые места и сразу веди к разбору.',
      'goal:daily_plan' =>
        'Компактный привычечный ритм с одним ясным следующим шагом каждый день.',
      'goal:honest' => 'Больше ясности и точнее разбор, но без жёсткости.',
      _ => option.subtitle,
    };
  }

  String? _localizedPlacementOptionBadgeV1(
    String questionId,
    Act0PlacementOptionV1 option,
  ) {
    return switch ('$questionId:${option.optionId}') {
      'age:age_18_24' => 'Лучший первый старт',
      'experience:new' => 'Лучше всего для нуля',
      'experience:online' => 'Более быстрый старт',
      'format:basics' => 'Основа',
      'confidence:rules' => 'Фундамент',
      'goal:guided' => 'Спокойный старт',
      _ => option.badge,
    };
  }

  String _localizedPlacementProfileTagV1(String profileTag) {
    return switch (profileTag) {
      'NewSimple' => 'НовыйСтарт',
      'KnowsSome' => 'ЧтоТоЗнает',
      'SharperDecisions' => 'ТочнееРешения',
      'New' => 'Новый',
      'Casual' => 'Любитель',
      'Watching' => 'Смотрит',
      'Played' => 'Играл',
      'Rarely' => 'Редко',
      'Weekly' => 'Иногда',
      'Frequent' => 'Часто',
      'Basics' => 'База',
      'Cash' => 'Кэш',
      'Tournament' => 'Турниры',
      'HomeGames' => 'ДомашниеИгры',
      'Content' => 'Контент',
      'Rules' => 'Правила',
      'Cards' => 'Карты',
      'Decisions' => 'Решения',
      'Board' => 'Борд',
      'Pressure' => 'Давление',
      'Guided' => 'Спокойно',
      'Practice' => 'Практика',
      'Diagnostic' => 'Диагностика',
      'DailyPlan' => 'ДневнойПлан',
      'Direct' => 'Прямо',
      _ => profileTag,
    };
  }

  String _localizedPlacementSignalLineV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementHighlightV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementPlanStepV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementTrialPointV1(String line) =>
      _localizedPlacementAtomV1(line);
  String _localizedPlacementRecommendedTitleV1(String title) =>
      act0LocalizedLessonTitleAtomV1(title, isRu: true);
  String _localizedPlacementSkillLabelV1(String label) =>
      _localizedPlacementAtomV1(label);

  String _localizedPlacementAtomV1(String value) {
    return switch (value) {
      'Table read' => 'Чтение стола',
      'Board read' => 'Чтение борда',
      'Action order' => 'Порядок действий',
      'Position pressure' => 'Давление позиции',
      'Fresh start' => 'Чистый старт',
      'Clear path' => 'Понятный маршрут',
      'Motivation' => 'Мотивация',
      'Some table language' => 'Немного языка стола',
      'Experience' => 'Опыт',
      'Decision comfort' => 'Комфорт в решениях',
      'Table' => 'Стол',
      'Pot' => 'Банк',
      'Blinds' => 'Блайнды',
      'Streets' => 'Улицы',
      'Actions' => 'Действия',
      'Positions' => 'Позиции',
      'Hand flow' => 'Ход раздачи',
      'Action decisions' => 'Решения по действиям',
      'Board tracking' => 'Чтение борда',
      'Pressure control' => 'Контроль давления',
      _ => value,
    };
  }

  bool _placementHandoffActive = false;
  final Map<String, Set<String>> _placementAnswerIds = <String, Set<String>>{};
  final Set<String> _placementDiagnosticHitSignals = <String>{};
  final Set<String> _placementDiagnosticMissSignals = <String>{};
  final Map<String, int> _profileSkillValues = <String, int>{};
  final List<Act0SkillGainV1> _recentSkillGains = <Act0SkillGainV1>[];
  Act0PlacementResultV1? _placementResult;
  int _progressPersistGeneration = 0;
  String _dismissedHomeHandoffKey = '';
  String _dismissedHomeHandoffDay = '';
  int _learnLessonOpenSequenceV1 = 0;
  String? _learnPendingAutoOpenLessonIdV1;
  bool _showWelcome = false;
  bool _bootSurfaceReady = true;
  bool _welcomeCompletedV1 = false;
  Act0ShellTabV1? _welcomeReturnTabV1;

  Set<String> get _pathClosedTaskIds => <String>{
    ..._completedTaskIds,
    ..._skippedTaskIds,
  };

  bool get _usesPersistedProgress => widget.state == null;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _phase = widget.initialPhase;
    _showPlacement = widget.showPlacementOnStart;
    _showWelcome = false;
    _bootSurfaceReady = !widget.showPlacementOnStart;
    _showPlayHub = widget.initialTab != Act0ShellTabV1.play;
    final state = widget.state ?? Act0ShellStateV1.sample;
    _selectedWorldId = state.selectedWorldId;
    _selectedLessonId = state.currentLesson.lessonId;
    _completedLessonIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed) lesson.lessonId,
    };
    _completedTaskIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed)
            for (final task in lesson.taskList) task.taskId,
    };
    _selectedTaskId = _firstIncompleteTask(state.currentLesson).taskId;
    _learnPopupTaskId = null;
    _resetLessonRunMetrics();
    unawaited(_bootstrapFirstStartRouteV1());
  }

  @override
  void dispose() {
    _learnLessonOpenSequenceV1++;
    _persistProgress();
    super.dispose();
  }

  Future<void> _bootstrapFirstStartRouteV1() async {
    if (_usesPersistedProgress) {
      await _restorePersistedProgress();
    }
    if (!widget.showPlacementOnStart) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPlacement = false;
        _showWelcome = false;
        _bootSurfaceReady = true;
      });
      return;
    }
    final intakeCompleted = await ProgressService.isIntakeCompleted();
    final welcomeCompleted =
        await Act0FirstStartPreferencesV1.hasCompletedWelcome();
    if (!mounted) {
      return;
    }
    setState(() {
      _welcomeCompletedV1 = welcomeCompleted;
      _showPlacement = !intakeCompleted;
      _showWelcome = intakeCompleted && !welcomeCompleted;
      _bootSurfaceReady = true;
      if (_showWelcome) {
        _tab = Act0ShellTabV1.home;
      }
    });
  }

  bool _handleLearnLessonSelectV1({
    required Act0LessonCardV1 lesson,
    required String lessonId,
  }) {
    if (_learnDetailLessonId == lessonId) {
      setState(() {
        _learnDetailLessonId = null;
        _learnPopupTaskId = null;
        _learnPendingAutoOpenLessonIdV1 = null;
      });
      return false;
    }
    _learnLessonOpenSequenceV1++;
    setState(() {
      _learnPopupTaskId = null;
      if (lesson.isSelectable) {
        _selectedLessonId = lessonId;
        _selectedTaskId = _firstIncompleteTask(lesson).taskId;
        _teachingStepIndex = 0;
        _resetLessonRunMetrics();
      }
      _learnDetailLessonId = null;
      _learnDetailWorldId = null;
      _learnPendingAutoOpenLessonIdV1 = lessonId;
    });
    return true;
  }

  void _handleLearnLessonOpenAfterScrollV1(String lessonId) {
    if (!mounted || _learnPendingAutoOpenLessonIdV1 != lessonId) {
      return;
    }
    setState(() {
      _learnDetailLessonId = lessonId;
      _learnPendingAutoOpenLessonIdV1 = null;
    });
  }

  Future<void> _restorePersistedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressPrefsKey);
    if (raw == null || raw.isEmpty || !mounted) {
      return;
    }
    final parsed = _Act0PersistedProgressV1.tryParse(raw);
    if (parsed == null) {
      return;
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final validTaskIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList) task.taskId,
    };
    final validLessonIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons) lesson.lessonId,
    };
    final completedTaskIds = parsed.completedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final skippedTaskIds = parsed.skippedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final completedLessonIds = parsed.completedLessonIds
        .where(validLessonIds.contains)
        .toSet();
    final closedTaskIds = <String>{...completedTaskIds, ...skippedTaskIds};
    final worldsAfterProgress = _progressWorldsWithTaskIds(
      state,
      closedTaskIds,
    );
    final persistedWorld = _worldById(
      worldsAfterProgress,
      worldsAfterProgress.any(
            (world) => world.worldId == parsed.selectedWorldId,
          )
          ? parsed.selectedWorldId
          : state.selectedWorldId,
    );
    final selectedWorld = persistedWorld.status == Act0WorldStateV1.current
        ? persistedWorld
        : worldsAfterProgress.firstWhere(
            (world) =>
                world.status == Act0WorldStateV1.current && world.isSelectable,
            orElse: () => persistedWorld,
          );
    final persistedLesson =
        selectedWorld.lessons.any(
          (lesson) => lesson.lessonId == parsed.selectedLessonId,
        )
        ? _lessonById(selectedWorld.lessons, parsed.selectedLessonId)
        : null;
    final selectedLesson =
        persistedLesson != null &&
            !_lessonCompleteWithTaskIds(persistedLesson, closedTaskIds)
        ? persistedLesson
        : _firstPlayableLesson(selectedWorld);
    final selectedTask =
        selectedLesson.taskList.any(
              (task) => task.taskId == parsed.selectedTaskId,
            ) &&
            !closedTaskIds.contains(parsed.selectedTaskId)
        ? _taskByIdWithTaskIds(
            selectedLesson,
            parsed.selectedTaskId,
            closedTaskIds,
          )
        : _firstIncompleteTaskWithTaskIds(selectedLesson, closedTaskIds);
    // Boot policy is Home-first. Persisted lesson/task progress is restored,
    // but ephemeral runner phase is not resumed over the launch surface.

    if (!mounted) {
      return;
    }
    final today = _todayDateString();
    final isNewDay = parsed.lastActiveDay != today;
    final isStreakContinued =
        !isNewDay || _isConsecutiveDay(parsed.lastActiveDay, today);
    final restoredStreakDays = isNewDay
        ? (isStreakContinued && parsed.lastActiveDay.isNotEmpty
              ? parsed.persistedStreakDays
              : 0)
        : parsed.persistedStreakDays;
    final restoredSkillValues = parsed.profileSkillValues.isEmpty
        ? _deriveSkillValuesFromCompletedTasks(completedTaskIds)
        : parsed.profileSkillValues;
    setState(() {
      _completedTaskIds = completedTaskIds;
      _completedLessonIds = completedLessonIds;
      _skippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _visibleSkippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _earnedXp = parsed.earnedXp;
      _profileSkillValues
        ..clear()
        ..addAll(restoredSkillValues);
      _recentSkillGains
        ..clear()
        ..addAll(parsed.recentSkillGains.take(6));
      _selectedWorldId = selectedWorld.worldId;
      _selectedLessonId = selectedLesson.lessonId;
      _selectedTaskId = selectedTask.taskId;
      _phase = selectedTask.phase;
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      _tab = widget.initialTab;
      _showPlayHub = widget.initialTab != Act0ShellTabV1.play;
      _blockCompletionSummary = null;
      _persistedStreakDays = restoredStreakDays;
      _lastDailyDate = isNewDay ? today : parsed.lastActiveDay;
      _dailyCompletedRepCount = isNewDay
          ? 0
          : parsed.dailyCompletedRepCount.clamp(0, 3);
      _dismissedHomeHandoffKey = parsed.dismissedHomeHandoffKey;
      _dismissedHomeHandoffDay = parsed.dismissedHomeHandoffDay;
      // Daily deck resets on new day
      if (isNewDay) {
        _dailyCompletedTaskIds.clear();
        _dailyCompletedRepCount = 0;
        _rapidPracticeLoop = false;
      }
    });
  }

  static String _todayDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static bool _isConsecutiveDay(String prevDay, String today) {
    if (prevDay.isEmpty) return false;
    try {
      final prev = DateTime.parse(prevDay);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(prev).inDays;
      return diff == 1;
    } catch (_) {
      return false;
    }
  }

  void _persistProgress() {
    if (!_usesPersistedProgress) {
      return;
    }
    final today = _todayDateString();
    final dailyDone = _dailyCompletedRepCount >= 3;
    final currentStreak = dailyDone
        ? (_lastDailyDate == today
              ? _persistedStreakDays
              : (_isConsecutiveDay(_lastDailyDate, today)
                    ? (_persistedStreakDays + 1).clamp(0, 365)
                    : 1))
        : _persistedStreakDays;
    final snapshot = _Act0PersistedProgressV1(
      completedTaskIds: _completedTaskIds,
      skippedTaskIds: _skippedTaskIds,
      completedLessonIds: _completedLessonIds,
      selectedWorldId: _selectedWorldId,
      selectedLessonId: _selectedLessonId,
      selectedTaskId: _selectedTaskId,
      earnedXp: _earnedXp,
      profileSkillValues: _profileSkillValues,
      recentSkillGains: _recentSkillGains,
      lastActiveDay: today,
      dailyCompletedRepCount: _dailyCompletedRepCount,
      persistedStreakDays: currentStreak,
      resumeInRunner:
          _tab == Act0ShellTabV1.play &&
          !_showPlayHub &&
          _blockCompletionSummary == null &&
          !_showPlacement,
      resumePhase: _phase.name,
      resumeTeachingStepIndex: _teachingStepIndex,
      resumeSelectedOptionId: _selectedOptionId,
      dismissedHomeHandoffKey: _dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: _dismissedHomeHandoffDay,
    );
    final generation = ++_progressPersistGeneration;
    unawaited(_writePersistedProgress(snapshot, generation));
  }

  Future<void> _writePersistedProgress(
    _Act0PersistedProgressV1 snapshot,
    int generation,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (generation != _progressPersistGeneration) {
      return;
    }
    await prefs.setString(_progressPrefsKey, snapshot.toStorageString());
  }

  Future<void> _invalidatePersistedProgressWrites() async {
    if (!_usesPersistedProgress) {
      return;
    }
    _progressPersistGeneration += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressPrefsKey);
  }

  void _restorePreviewToFreshStart({
    bool showPlacement = true,
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
  }) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final zeroProgressWorlds = _progressWorldsWithTaskIds(state, <String>{});
    final zeroWorld = zeroProgressWorlds.firstWhere(
      (world) => world.status == Act0WorldStateV1.current && world.isSelectable,
      orElse: () => zeroProgressWorlds.first,
    );
    final zeroLesson = _firstPlayableLesson(zeroWorld);
    final zeroTask = _firstIncompleteTask(zeroLesson);
    setState(() {
      _tab = tab;
      _phase = Act0LessonPhaseV1.theory;
      _selectedWorldId = zeroWorld.worldId;
      _selectedLessonId = zeroLesson.lessonId;
      _selectedTaskId = zeroTask.taskId;
      _learnPopupTaskId = null;
      _completedLessonIds = <String>{};
      _completedTaskIds = <String>{};
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
      _selectedOptionId = null;
      _reviewConfidence = null;
      _teachingStepIndex = 0;
      _earnedXp = 0;
      _lessonRunXp = 0;
      _showPlayHub = tab != Act0ShellTabV1.play;
      _returnToPlayHubOnBack = false;
      _mistakeRecords.clear();
      _resolvedMistakeTaskIds.clear();
      _cleanTaskIds.clear();
      _lessonRunMistakeTaskIds.clear();
      _lessonRunPendingRetryTaskIds.clear();
      _lessonRunRetriedTaskIds.clear();
      _lessonRunQuickFixTaskIds.clear();
      _lessonRunDeepLeakTaskIds.clear();
      _dailyCompletedTaskIds.clear();
      _dailyCompletedRepCount = 0;
      _rapidPracticeLoop = false;
      _activePracticeGroupId = null;
      _activeRepairTaskId = null;
      _blockCompletionSummary = null;
      _dismissedHomeHandoffKey = '';
      _dismissedHomeHandoffDay = '';
      _persistedStreakDays = 0;
      _lastDailyDate = '';
      _showPlacement = showPlacement;
      _showWelcome = false;
      _welcomeCompletedV1 = false;
      _welcomeReturnTabV1 = null;
      _placementDiagnosticActive = false;
      _placementIntroVisible = true;
      _placementTrialPreviewSelected = false;
      _placementQuestionIndex = 0;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementDiagnosticScore = 0;
      _placementHandoffActive = false;
      _placementAnswerIds.clear();
      _placementDiagnosticHitSignals.clear();
      _placementDiagnosticMissSignals.clear();
      _profileSkillValues.clear();
      _recentSkillGains.clear();
      _placementResult = null;
      _resetLessonRunMetrics();
    });
  }

  void _openDevMapSkippingPlacement() {
    setState(() {
      _showPlacement = false;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _placementDiagnosticActive = false;
      _placementIntroVisible = false;
      _placementTrialPreviewSelected = false;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementDiagnosticScore = 0;
      _placementDiagnosticHitSignals.clear();
      _placementDiagnosticMissSignals.clear();
      _tab = Act0ShellTabV1.learn;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
    });
  }

  void _openPlacementFlow() {
    setState(() {
      _showPlacement = true;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _placementDiagnosticActive = false;
      _placementIntroVisible = true;
      _placementTrialPreviewSelected = false;
      _placementQuestionIndex = 0;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementDiagnosticScore = 0;
      _placementHandoffActive = false;
      _placementAnswerIds.clear();
      _placementDiagnosticHitSignals.clear();
      _placementDiagnosticMissSignals.clear();
      _profileSkillValues.clear();
      _recentSkillGains.clear();
      _placementResult = null;
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _activePracticeGroupId = null;
      _activeRepairTaskId = null;
      _blockCompletionSummary = null;
    });
  }

  void _openDevSurface({required Act0ShellTabV1 tab, bool showPlayHub = true}) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final worlds = _progressWorlds(state);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final selectedTask = _taskById(selectedLesson, _selectedTaskId);
    setState(() {
      _showPlacement = false;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _placementDiagnosticActive = false;
      _placementTrialPreviewSelected = false;
      _tab = tab;
      _showPlayHub = tab == Act0ShellTabV1.play ? showPlayHub : true;
      _returnToPlayHubOnBack = false;
      _blockCompletionSummary = null;
      _activeRepairTaskId = null;
      _selectedOptionId = null;
      _phase = selectedTask.phase;
      _teachingStepIndex = 0;
      if (tab != Act0ShellTabV1.learn) {
        _learnDetailLessonId = null;
        _learnDetailWorldId = null;
        _showWorldMenu = false;
      }
    });
  }

  Future<void> _handleResetAppProgress() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears app progress and returns the dev shell to Today.',
          ),
          actions: [
            TextButton(
              key: const Key('act0_shell_dev_menu_reset_cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('act0_shell_dev_menu_reset_confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (shouldReset != true || !mounted) {
      return;
    }
    await _invalidatePersistedProgressWrites();
    await ProgressService.debugReset();
    await OnboardingPreferencesService.resetOnboarding();
    await Act0FirstStartPreferencesV1.resetWelcome();
    if (!mounted) {
      return;
    }
    _restorePreviewToFreshStart(showPlacement: true);
    _persistProgress();
  }

  Future<void> _openDevMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Act0ShellTokensV1.surface,
      builder: (context) {
        final languageController = Provider.of<AppLanguageController?>(
          context,
          listen: false,
        );
        final currentLanguageCode = languageController?.languageCode;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (languageController != null) ...[
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(
                      _copyV1(en: 'Preview language', ru: 'Язык предпросмотра'),
                    ),
                    subtitle: Text(
                      currentLanguageCode == 'ru'
                          ? 'Русский'
                          : AppLanguageController.getLanguageName(
                              currentLanguageCode ?? 'en',
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            key: const Key('act0_shell_dev_menu_lang_ru'),
                            onPressed: currentLanguageCode == 'ru'
                                ? null
                                : () async {
                                    await languageController.setLanguage('ru');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('Русский'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonal(
                            key: const Key('act0_shell_dev_menu_lang_en'),
                            onPressed: currentLanguageCode == 'en'
                                ? null
                                : () async {
                                    await languageController.setLanguage('en');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  },
                            child: const Text('English'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  key: const Key('act0_shell_dev_menu_reset_progress'),
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(
                    _copyV1(
                      en: 'Reset app progress',
                      ru: 'Сбросить прогресс приложения',
                    ),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Clear app prefs and return to Today.',
                      ru: 'Очистить настройки приложения и вернуться на главный экран.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleResetAppProgress();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_placement'),
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(
                    _copyV1(en: 'Open placement', ru: 'Открыть плейсмент'),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Jump into the placement flow manually.',
                      ru: 'Войти в поток плейсмента вручную.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openPlacementFlow();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_home'),
                  leading: const Icon(Icons.home_outlined),
                  title: Text(
                    _copyV1(en: 'Open Today', ru: 'Открыть главный экран'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.home);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_map'),
                  leading: const Icon(Icons.map_outlined),
                  title: Text(
                    _copyV1(en: 'Open Learn map', ru: 'Открыть карту обучения'),
                  ),
                  subtitle: Text(
                    _copyV1(
                      en: 'Jump to Learn and skip placement.',
                      ru: 'Перейти в обучение и пропустить плейсмент.',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevMapSkippingPlacement();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_play_hub'),
                  leading: const Icon(Icons.sports_esports_outlined),
                  title: Text(
                    _copyV1(en: 'Open Play hub', ru: 'Открыть хаб практики'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: true,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_runner'),
                  leading: const Icon(Icons.play_circle_outline_rounded),
                  title: Text(
                    _copyV1(
                      en: 'Open current runner',
                      ru: 'Открыть текущий раннер',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: false,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_review'),
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(_copyV1(en: 'Open Review', ru: 'Открыть разбор')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.review);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_profile'),
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(
                    _copyV1(en: 'Open Profile', ru: 'Открыть профиль'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPremiumPreviewSheet({
    required String eyebrow,
    required String title,
    required String summary,
    required List<String> valuePoints,
    required String trustLine,
    String? footerLine,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Act0PremiumPreviewSheetV1(
        eyebrow: eyebrow,
        title: title,
        summary: summary,
        valuePoints: valuePoints,
        trustLine: trustLine,
        footerLine: footerLine,
      ),
    );
  }

  void _previewPlacementTrial() {
    final result = _placementResult;
    setState(() {
      _placementTrialPreviewSelected = true;
    });
    if (result == null) {
      return;
    }
    unawaited(
      _openPremiumPreviewSheet(
        eyebrow: 'Premium preview',
        title: 'See the guided week before you ever upgrade.',
        summary: result.premiumPitch,
        valuePoints: result.trialValuePoints,
        trustLine:
            'The free route stays intact. Premium only expands the work after Sharky has already shown value.',
        footerLine:
            'Nothing here replaces the core path. It only adds sharper follow-up after real reps.',
      ),
    );
  }

  void _previewLockedWorldPremium(Act0WorldCardV1 world) {
    final worldTitle = act0LocalizedWorldTitleV1(context, world);
    final worldSubtitle = act0LocalizedWorldSubtitleV1(context, world);
    final valuePoints = <String>[
      'Extra drills tied to the exact spots that broke before this world.',
      'A calmer seven-day rhythm once $worldTitle opens.',
      'Progress signals that show what this world is really adding to your game.',
    ];
    unawaited(
      _openPremiumPreviewSheet(
        eyebrow: 'Premium preview',
        title: '$worldTitle gets deeper, not louder.',
        summary:
            '$worldSubtitle Premium adds extra reps and follow-up around this world once the free route unlocks it naturally.',
        valuePoints: valuePoints,
        trustLine:
            '${world.unlockLabel} The route still opens in order, so nothing important gets skipped.',
        footerLine:
            'This is a preview, not a gate. Free progression still owns the main path.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseState = widget.state ?? Act0ShellStateV1.sample;
    final progress = _progressSnapshot(baseState);
    final state = _stateWithProgress(baseState, progress);
    final reviewState = _reviewState(state.review);
    final profileState = _profileState(state.profile, progress);
    final reviewNavHasDot = reviewState.mistakes.isNotEmpty;
    final worlds = _progressWorlds(baseState);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final practiceGroups = _practiceGroups(
      state: state,
      world: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final practiceSurfaceRecommendation = _practiceSurfaceRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
      groups: practiceGroups,
    );
    final isPlayTab = _tab == Act0ShellTabV1.play;
    final isPlayRunner =
        isPlayTab && !_showPlayHub && _blockCompletionSummary == null;
    final playSelectedTask = isPlayTab
        ? _taskById(selectedLesson, _selectedTaskId)
        : null;
    final playTaskAlreadyCompleted =
        playSelectedTask != null &&
        _completedTaskIds.contains(playSelectedTask.taskId);
    final playTaskAwardXp = playSelectedTask == null || playTaskAlreadyCompleted
        ? 0
        : playSelectedTask.rewardXp;
    final playRunner = isPlayRunner
        ? normalizeAct0DrillSeatHighlightPolicyV1(
            normalizeAct0SeatTapRunnerV1(
              _repairRunnerForTask(playSelectedTask!).copyWith(
                lessonId: selectedLesson.lessonId,
                lessonTitle: _localizedLessonTitleV1(selectedLesson),
                lessonSubtitle: _localizedLessonSubtitleV1(selectedLesson),
                beatIndex:
                    _taskIndex(selectedLesson, playSelectedTask.taskId) + 1,
                beatCount: selectedLesson.taskList.length,
                phase: _phase,
                selectedOptionId: _selectedOptionId,
                sizingConfig: _activeSizingConfigV1(
                  selectedLesson,
                  playSelectedTask,
                ),
                selectedPresetId: _activeSelectedPresetIdV1(playSelectedTask),
                teachingStepIndex: _teachingStepIndex,
                nextLessonId: _nextLessonId(
                  selectedWorld.lessons,
                  selectedLesson.lessonId,
                ),
              ),
            ),
          )
        : null;
    final suppressTaskCompletionToast =
        isPlayRunner &&
        playSelectedTask != null &&
        _isTaskCompletingLessonMilestoneV1(
          lesson: selectedLesson,
          taskId: playSelectedTask.taskId,
        );
    final completionSummary =
        isPlayRunner &&
            widget.tableVisualVariant ==
                Act0ShellTableVisualVariantV1.refinedDev2 &&
            playTaskAwardXp > 0 &&
            !suppressTaskCompletionToast
        ? Act0RunnerCompletionSummaryV1(
            xpGain: playTaskAwardXp,
            startLevel: progress.level,
            endLevel: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playTaskAwardXp,
            ).level,
            startXp: progress.xp,
            endXp: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playTaskAwardXp,
            ).xp,
            xpTarget: baseState.xpTarget,
            skillGains: _skillGainsFromMapV1(
              _skillDeltaForAnswer(selectedLesson, playSelectedTask!),
              source: playSelectedTask.title,
            ),
          )
        : null;
    final showTopBar =
        _bootSurfaceReady && !_showPlacement && !_showWelcome && !isPlayRunner;
    return Scaffold(
      key: const Key('act0_shell_preview_screen'),
      backgroundColor: Act0ShellTokensV1.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showTopBar)
              _TopBarV1(state: state, goalLabel: _compactDailyLabel()),
            Expanded(
              child: !_bootSurfaceReady
                  ? const Center(child: CircularProgressIndicator())
                  : _showPlacement && !_placementDiagnosticActive
                  ? Act0PlacementShellV1(
                      questions: _localizedPlacementQuestionsV1(),
                      showIntro: _placementIntroVisible,
                      currentQuestionIndex: _placementQuestionIndex,
                      selectedOptionIds: _placementAnswerIds,
                      result: _placementResult == null
                          ? null
                          : _localizedPlacementResultV1(_placementResult!),
                      trialPreviewSelected: _placementTrialPreviewSelected,
                      onSelectOption: (question, optionId) => setState(() {
                        _togglePlacementOption(question, optionId);
                      }),
                      onStartPlacement: () => setState(() {
                        _placementIntroVisible = false;
                        _placementQuestionIndex = 0;
                      }),
                      onBack: () => setState(() {
                        if (_placementQuestionIndex > 0) {
                          _placementQuestionIndex -= 1;
                        } else {
                          _placementIntroVisible = true;
                        }
                      }),
                      onNext: () => setState(() {
                        _placementIntroVisible = false;
                        if (_placementQuestionIndex <
                            _placementQuestionsV1.length) {
                          _placementQuestionIndex += 1;
                        }
                      }),
                      onStartDiagnostic: () => setState(() {
                        _startPlacementDiagnostic(_progressWorlds(baseState));
                      }),
                      onStartRecommended: () {
                        unawaited(
                          _startPlacementRecommendation(
                            _progressWorlds(baseState),
                            fromZero: false,
                          ),
                        );
                      },
                      onStartFromZero: () {
                        unawaited(
                          _startPlacementRecommendation(
                            _progressWorlds(baseState),
                            fromZero: true,
                          ),
                        );
                      },
                      onStartTrialPreview: _previewPlacementTrial,
                    )
                  : _showWelcome
                  ? Act0WelcomeShellV1(
                      replayMode: _welcomeReturnTabV1 != null,
                      onCompleted: () {
                        unawaited(_completeWelcomeV1());
                      },
                      onClose: _welcomeReturnTabV1 != null
                          ? _closeWelcomeReplayV1
                          : null,
                      tableVisualVariant: widget.tableVisualVariant,
                    )
                  : switch (_tab) {
                      Act0ShellTabV1.home => Act0HomeShellV1(
                        state: state,
                        currentLesson: _firstPlayableLesson(selectedWorld),
                        pathProgressLabel: selectedWorld.progressLabel,
                        nextActionLabel: _homeNextActionLabel(),
                        nextActionTitle: _homeNextActionTitle(
                          _firstPlayableLesson(selectedWorld),
                        ),
                        nextActionSubtitle: _homeNextActionSubtitle(
                          _firstPlayableLesson(selectedWorld),
                        ),
                        nextActionCtaLabel: _homeNextActionCtaLabel(),
                        nextActionHint: _homeCtaHint(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        repairLabel: _homeRepairLabel(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        repairHeadline: _homeRepairHeadline(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        repairDetail: _homeRepairDetail(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        repairOutcome: _homeRepairOutcome(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        repairCtaLabel: _homeRepairCtaLabel(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        showRepairPanel: true,
                        onStartRepair: () => setState(() {
                          _startHomeRepairAction(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          );
                        }),
                        dailyGoalValue: _dailyGoalValueLabel(),
                        dailyGoalCtaLabel: _homeDailyGoalCtaLabel(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        sharkyOverride: _homeSharkyOverride(),
                        onOpenDevMenu: _openDevMenu,
                        onStartDailyDrill: _dailyCompletedRepCount < 3
                            ? () => setState(() {
                                final world = _worldById(
                                  _progressedWorlds(
                                    widget.state ?? Act0ShellStateV1.sample,
                                  ),
                                  _selectedWorldId,
                                );
                                final baseState =
                                    widget.state ?? Act0ShellStateV1.sample;
                                final lesson = _lessonById(
                                  world.lessons,
                                  _selectedLessonId,
                                );
                                final groups = _practiceGroups(
                                  state: baseState,
                                  world: world,
                                  selectedLesson: lesson,
                                );
                                final dailyGroup = groups.firstWhere(
                                  (g) => g.groupId == 'daily',
                                  orElse: () => groups.first,
                                );
                                _startPracticeGroup(dailyGroup, world);
                                _tab = Act0ShellTabV1.play;
                                _showPlayHub = false;
                              })
                            : null,
                        onContinue: () => setState(() {
                          _startHomeNextAction(selectedWorld);
                        }),
                      ),
                      Act0ShellTabV1.learn => Act0LearnPathShellV1(
                        moduleTitle: selectedWorld.title,
                        moduleProgressLabel: selectedWorld.progressLabel,
                        sharkyGuideTitle: _learnGuideTitle(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideLine: _learnGuideLine(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideDetail: _learnGuideDetail(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideMood: _learnGuideMood(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        worlds: worlds,
                        selectedWorldId: _selectedWorldId,
                        showWorldMenu: _showWorldMenu,
                        worldDetailId: _learnDetailWorldId,
                        lessons: selectedWorld.lessons,
                        selectedLessonId: _selectedLessonId,
                        selectedTaskId: _selectedTaskId,
                        activePopupTaskId: _learnPopupTaskId,
                        completedTaskIds: _completedTaskIds,
                        perfectTaskIds: _perfectTaskIds(),
                        skippedTaskIds: _visibleSkippedTaskIds,
                        pathClosedTaskIds: _pathClosedTaskIds,
                        detailLessonId: _learnDetailLessonId,
                        lessonOutcomeLabels: _lessonOutcomeLabels(
                          selectedWorld.lessons,
                        ),
                        onSelectWorld: (worldId) {
                          final world = _worldById(worlds, worldId);
                          setState(() {
                            if (world.isSelectable) {
                              final lesson = _firstPlayableLesson(world);
                              _selectedWorldId = worldId;
                              _selectedLessonId = lesson.lessonId;
                              _selectedTaskId = _firstIncompleteTask(
                                lesson,
                              ).taskId;
                              _phase = _taskById(lesson, _selectedTaskId).phase;
                              _selectedOptionId = null;
                              _teachingStepIndex = 0;
                              _showWorldMenu = false;
                              _learnDetailWorldId = null;
                              _learnDetailLessonId = null;
                              _learnPopupTaskId = null;
                              _learnPendingAutoOpenLessonIdV1 = null;
                            } else {
                              _learnDetailWorldId = worldId;
                              _learnDetailLessonId = null;
                              _learnPendingAutoOpenLessonIdV1 = null;
                            }
                          });
                        },
                        onOpenWorldMenu: () => setState(() {
                          _showWorldMenu = true;
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                          _learnPendingAutoOpenLessonIdV1 = null;
                        }),
                        onCloseWorldMenu: () => setState(() {
                          _showWorldMenu = false;
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onDismissWorldDetail: () => setState(() {
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onPreviewPremiumWorld: _previewLockedWorldPremium,
                        onSelectLesson: (lessonId) {
                          final lesson = selectedWorld.lessons
                              .cast<Act0LessonCardV1?>()
                              .firstWhere(
                                (candidate) => candidate?.lessonId == lessonId,
                                orElse: () => null,
                              );
                          if (lesson == null) {
                            return false;
                          }
                          return _handleLearnLessonSelectV1(
                            lesson: lesson,
                            lessonId: lessonId,
                          );
                        },
                        onOpenLessonAfterScroll:
                            _handleLearnLessonOpenAfterScrollV1,
                        onDismissDetail: () => setState(() {
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                          _learnPendingAutoOpenLessonIdV1 = null;
                        }),
                        onSelectTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.taskList.any(
                            (task) => task.taskId == taskId,
                          )) {
                            return;
                          }
                          final isSamePopupTask =
                              _learnDetailLessonId == lessonId &&
                              _learnPopupTaskId == taskId;
                          if (isSamePopupTask) {
                            setState(() {
                              _learnPopupTaskId = null;
                            });
                            return;
                          }
                          final taskAvailable = _taskAvailable(lesson, taskId);
                          setState(() {
                            if (lesson.isSelectable && taskAvailable) {
                              _selectedLessonId = lessonId;
                              _selectedTaskId = taskId;
                              _selectedOptionId = null;
                              _teachingStepIndex = 0;
                              _resetLessonRunMetrics();
                            }
                            _learnPopupTaskId = taskId;
                          });
                        },
                        onDismissTaskPopup: () => setState(() {
                          _learnPopupTaskId = null;
                        }),
                        onStartTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.isSelectable ||
                              !_taskAvailable(lesson, taskId)) {
                            return;
                          }
                          setState(() {
                            _selectedLessonId = lessonId;
                            _selectedTaskId = taskId;
                            _tab = Act0ShellTabV1.play;
                            _showPlayHub = false;
                            _returnToPlayHubOnBack = false;
                            _phase = _taskById(lesson, taskId).phase;
                            _selectedOptionId = null;
                            _teachingStepIndex = 0;
                            _resetLessonRunMetrics();
                            _activePracticeGroupId = null;
                            _learnDetailLessonId = null;
                            _learnPopupTaskId = null;
                            _learnDetailWorldId = null;
                          });
                        },
                      ),
                      Act0ShellTabV1.play =>
                        _showPlayHub && _blockCompletionSummary == null
                            ? Act0PlayShellV1(
                                groups: practiceGroups,
                                recommendedGroupId:
                                    practiceSurfaceRecommendation.groupId,
                                recommendedTitle:
                                    practiceSurfaceRecommendation.title,
                                recommendedSubtitle:
                                    practiceSurfaceRecommendation.subtitle,
                                recommendedReasonLabel:
                                    practiceSurfaceRecommendation.reasonLabel,
                                recommendedOutcome:
                                    practiceSurfaceRecommendation.outcome,
                                recommendedOutcomeLead:
                                    practiceSurfaceRecommendation.outcomeLead,
                                masteryLabel:
                                    practiceSurfaceRecommendation.masteryLabel,
                                screenSubtitle: practiceSurfaceRecommendation
                                    .screenSubtitle,
                                completionTitle: _practiceCompletionTitle,
                                completionBody: _practiceCompletionBody,
                                onStartGroup: (group) => setState(() {
                                  _startPracticeGroup(group, selectedWorld);
                                }),
                              )
                            : _blockCompletionSummary != null
                            ? Act0BlockCompletionShellV1(
                                summary: _blockCompletionSummary!,
                                onReplay: () => setState(() {
                                  _showPlayHub = false;
                                  _selectedTaskId =
                                      selectedLesson.taskList.first.taskId;
                                  _phase = _taskById(
                                    selectedLesson,
                                    _selectedTaskId,
                                  ).phase;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _resetLessonRunMetrics();
                                }),
                                onOpenReview: () => setState(() {
                                  _tab = Act0ShellTabV1.review;
                                  _showPlayHub = true;
                                  _returnToPlayHubOnBack = false;
                                  _learnDetailLessonId = null;
                                  _learnDetailWorldId = null;
                                  _showWorldMenu = false;
                                  _blockCompletionSummary = null;
                                }),
                                onBackToMap: () => setState(() {
                                  _tab = Act0ShellTabV1.learn;
                                  _learnDetailLessonId = null;
                                  _learnDetailWorldId = null;
                                  _showWorldMenu = false;
                                  _blockCompletionSummary = null;
                                }),
                                onContinue: () => setState(() {
                                  final progressedWorlds = _progressWorlds(
                                    baseState,
                                  );
                                  final nextLessonId = _nextLessonId(
                                    selectedWorld.lessons,
                                    selectedLesson.lessonId,
                                  );
                                  if (nextLessonId == null) {
                                    final nextWorld = _nextSelectableWorld(
                                      progressedWorlds,
                                      _selectedWorldId,
                                    );
                                    if (nextWorld == null) {
                                      _tab = Act0ShellTabV1.learn;
                                      _showPlayHub = true;
                                      _learnDetailLessonId = null;
                                      _learnDetailWorldId = null;
                                      _showWorldMenu = false;
                                      _blockCompletionSummary = null;
                                      return;
                                    }
                                    final nextLesson = _firstPlayableLesson(
                                      nextWorld,
                                    );
                                    _selectedWorldId = nextWorld.worldId;
                                    _selectedLessonId = nextLesson.lessonId;
                                    _selectedTaskId = _firstIncompleteTask(
                                      nextLesson,
                                    ).taskId;
                                    _phase = _taskById(
                                      nextLesson,
                                      _selectedTaskId,
                                    ).phase;
                                    _showPlayHub = false;
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                    _learnDetailLessonId = null;
                                    _learnDetailWorldId = null;
                                    _showWorldMenu = false;
                                    _blockCompletionSummary = null;
                                    _resetLessonRunMetrics();
                                    return;
                                  }
                                  final progressedWorld = _worldById(
                                    progressedWorlds,
                                    _selectedWorldId,
                                  );
                                  final nextLesson = _lessonById(
                                    progressedWorld.lessons,
                                    nextLessonId,
                                  );
                                  _selectedLessonId = nextLesson.lessonId;
                                  _selectedTaskId = _firstIncompleteTask(
                                    nextLesson,
                                  ).taskId;
                                  _phase = _taskById(
                                    nextLesson,
                                    _selectedTaskId,
                                  ).phase;
                                  _showPlayHub = false;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _blockCompletionSummary = null;
                                  _resetLessonRunMetrics();
                                }),
                              )
                            : Act0LessonRunnerShellV1(
                                runner: playRunner!,
                                selectedTaskId: playSelectedTask?.taskId,
                                selectedTaskFamily:
                                    playSelectedTask?.resolvedTaskFamily,
                                tableVisualVariant: widget.tableVisualVariant,
                                completionSummary: completionSummary,
                                relaxTheoryAdvanceLock: _completedTaskIds
                                    .contains(playSelectedTask!.taskId),
                                showLearningRailFocusLabels:
                                    _activeRepairTaskId ==
                                    playSelectedTask.taskId,
                                onBack: () => setState(() {
                                  if (_placementDiagnosticActive) {
                                    _placementDiagnosticActive = false;
                                    _showPlacement = true;
                                    _showPlayHub = true;
                                    _placementDiagnosticIndex = 0;
                                    _placementDiagnosticCorrect = 0;
                                    _placementDiagnosticScore = 0;
                                    _placementDiagnosticHitSignals.clear();
                                    _placementDiagnosticMissSignals.clear();
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_activeRepairTaskId != null) {
                                    _tab = Act0ShellTabV1.review;
                                    _showPlayHub = true;
                                    _returnToPlayHubOnBack = false;
                                    _activeRepairTaskId = null;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_returnToPlayHubOnBack) {
                                    _showPlayHub = true;
                                  } else {
                                    _tab = Act0ShellTabV1.learn;
                                  }
                                }),
                                onPreviousTheory: () => setState(() {
                                  if (_teachingStepIndex > 0) {
                                    _teachingStepIndex -= 1;
                                  }
                                }),
                                onUndoInteraction: () => setState(() {
                                  if (_phase == Act0LessonPhaseV1.review) {
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.drill;
                                    _teachingStepIndex =
                                        playRunner.teachingSteps.length;
                                    return;
                                  }
                                  if (_phase == Act0LessonPhaseV1.drill &&
                                      playRunner.teachingSteps.isNotEmpty) {
                                    _selectedOptionId = null;
                                    _teachingStepIndex =
                                        playRunner.teachingSteps.length - 1;
                                  }
                                }),
                                onContinueTheory: () => setState(() {
                                  if (_advanceTeachingStep(playRunner)) {
                                    return;
                                  }
                                  _completeCurrentTask(playSelectedTask);
                                  if (_maybeStartLessonWrapUpRetry(
                                    selectedLesson,
                                  )) {
                                    return;
                                  }
                                  if (_maybeShowBlockCompletionSummary(
                                    selectedWorld: selectedWorld,
                                    selectedLesson: selectedLesson,
                                    selectedTask: playSelectedTask,
                                  )) {
                                    return;
                                  }
                                  _advanceAfterTask(
                                    selectedWorld,
                                    selectedLesson,
                                  );
                                }),
                                onChooseOption: (option) => setState(() {
                                  _fireAnswerEffects(option);
                                  if (!_placementDiagnosticActive) {
                                    _recordAnswer(
                                      selectedLesson,
                                      playSelectedTask,
                                      option,
                                    );
                                  }
                                  _selectedOptionId = option.id;
                                  _selectedPresetId = null;
                                  _selectedPresetTaskId = null;
                                  _phase = Act0LessonPhaseV1.review;
                                  _teachingStepIndex = 0;
                                }),
                                onSelectSizingPreset: (preset) => setState(() {
                                  _selectedPresetId = preset.id;
                                  _selectedPresetTaskId =
                                      playSelectedTask.taskId;
                                }),
                                onConfirmSizingPreset: () => setState(() {
                                  _confirmSizingPresetAnswerV1(
                                    selectedLesson: selectedLesson,
                                    selectedTask: playSelectedTask,
                                  );
                                }),
                                onChooseSeat: (seatId) => setState(() {
                                  for (final option in playRunner.options) {
                                    if (option.seatId == seatId) {
                                      _fireAnswerEffects(option);
                                      if (!_placementDiagnosticActive) {
                                        _recordAnswer(
                                          selectedLesson,
                                          playSelectedTask,
                                          option,
                                        );
                                      }
                                      _selectedOptionId = option.id;
                                      _selectedPresetId = null;
                                      _selectedPresetTaskId = null;
                                      _phase = Act0LessonPhaseV1.review;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                  }
                                }),
                                rapidReviewMode: _rapidPracticeLoop,
                                onContinueReview: () => setState(() {
                                  if (_placementDiagnosticActive) {
                                    final spot = _placementDiagnosticSpotsV1
                                        .elementAt(_placementDiagnosticIndex);
                                    if (playRunner.selectedOption?.isCorrect ??
                                        false) {
                                      _placementDiagnosticCorrect += 1;
                                      _placementDiagnosticScore += 1;
                                      _placementDiagnosticHitSignals.add(
                                        spot.signalId,
                                      );
                                    } else {
                                      _placementDiagnosticMissSignals.add(
                                        spot.signalId,
                                      );
                                    }
                                    if (_startNextPlacementDiagnostic(
                                      _progressWorlds(baseState),
                                    )) {
                                      return;
                                    }
                                    _placementResult = _buildPlacementResult();
                                    _seedProfileSkillStats(
                                      _placementResult!.skillStats,
                                    );
                                    _placementDiagnosticActive = false;
                                    _showPlacement = true;
                                    _showPlayHub = true;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_activeRepairTaskId ==
                                      playSelectedTask.taskId) {
                                    final repaired =
                                        playRunner.selectedOption?.isCorrect ??
                                        false;
                                    if (repaired) {
                                      _completeCurrentTask(playSelectedTask);
                                    }
                                    _tab = Act0ShellTabV1.review;
                                    _showPlayHub = true;
                                    _returnToPlayHubOnBack = false;
                                    _activeRepairTaskId = null;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    _rapidPracticeLoop = false;
                                    return;
                                  }
                                  if (_rapidPracticeLoop &&
                                      _activePracticeGroupId == 'daily') {
                                    _completeCurrentTask(playSelectedTask);
                                    final nextDailyEntry = _nextDailyDeckEntry(
                                      state:
                                          widget.state ??
                                          Act0ShellStateV1.sample,
                                    );
                                    if (_dailyCompletedRepCount < 3 &&
                                        nextDailyEntry != null) {
                                      final launchWorld = _worldById(
                                        _progressedWorlds(
                                          widget.state ??
                                              Act0ShellStateV1.sample,
                                        ),
                                        nextDailyEntry.worldId,
                                      );
                                      _startTaskByIds(
                                        launchWorld,
                                        nextDailyEntry.lessonId,
                                        nextDailyEntry.taskId,
                                        skipTeaching: true,
                                        allowDrillBypass: true,
                                        rapidPracticeLoop: true,
                                      );
                                      _activePracticeGroupId = 'daily';
                                      _showPlayHub = false;
                                      _returnToPlayHubOnBack = true;
                                      return;
                                    }
                                    _finishRapidPracticeLoopToHub(
                                      completedLessonId:
                                          selectedLesson.lessonId,
                                    );
                                    return;
                                  }
                                  if (_rapidPracticeLoop) {
                                    _completeCurrentTask(playSelectedTask);
                                    _finishRapidPracticeLoopToHub(
                                      completedLessonId:
                                          selectedLesson.lessonId,
                                    );
                                    return;
                                  }
                                  if (_activeLessonWrapUpTaskId ==
                                      playSelectedTask.taskId) {
                                    final wrappedCorrect =
                                        playRunner.selectedOption?.isCorrect ??
                                        false;
                                    if (wrappedCorrect) {
                                      _completeCurrentTask(playSelectedTask);
                                    }
                                    _lessonRunWrapUpCompletedTaskIds.add(
                                      playSelectedTask.taskId,
                                    );
                                    _activeLessonWrapUpTaskId = null;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    if (_maybeStartLessonWrapUpRetry(
                                      selectedLesson,
                                    )) {
                                      return;
                                    }
                                    _restoreWrapUpAnchorTaskId(selectedLesson);
                                    if (_maybeShowBlockCompletionSummary(
                                      selectedWorld: selectedWorld,
                                      selectedLesson: selectedLesson,
                                      selectedTask: playSelectedTask,
                                    )) {
                                      return;
                                    }
                                    _advanceAfterTask(
                                      selectedWorld,
                                      selectedLesson,
                                    );
                                    return;
                                  }
                                  if (_shouldRetryInsideLesson(
                                    playSelectedTask,
                                    playRunner,
                                  )) {
                                    _startInsideLessonRetry(
                                      playSelectedTask,
                                      playRunner,
                                    );
                                    return;
                                  }
                                  _completeCurrentTask(playSelectedTask);
                                  if (_maybeStartLessonWrapUpRetry(
                                    selectedLesson,
                                  )) {
                                    return;
                                  }
                                  if (_maybeShowBlockCompletionSummary(
                                    selectedWorld: selectedWorld,
                                    selectedLesson: selectedLesson,
                                    selectedTask: playSelectedTask,
                                  )) {
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  _advanceAfterTask(
                                    selectedWorld,
                                    selectedLesson,
                                  );
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                }),
                              ),
                      Act0ShellTabV1.review => Act0ReviewShellV1(
                        review: reviewState,
                        selected: _reviewConfidence,
                        onSelected: (value) => setState(() {
                          _reviewConfidence = value;
                        }),
                        onFixMistake: (mistake) => setState(() {
                          _startMistakeRepair(
                            selectedWorld,
                            mistake,
                            returnToPlayHub: false,
                          );
                        }),
                        onReplayFixedMistake: (mistake) => setState(() {
                          _startMistakeRepair(
                            selectedWorld,
                            mistake,
                            returnToPlayHub: false,
                            practiceGroupId: 'weak_spots',
                          );
                        }),
                      ),
                      Act0ShellTabV1.profile => Act0ProfileShellV1(
                        profile: profileState,
                        onRetakePlacement: _openPlacementFlow,
                        onReplayWelcome: _openWelcomeReplayV1,
                        onGoToHome: () =>
                            setState(() => _tab = Act0ShellTabV1.home),
                      ),
                    },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          !_bootSurfaceReady ||
              _showWelcome ||
              (_showPlacement && !_placementDiagnosticActive) ||
              (_tab == Act0ShellTabV1.play && !_showPlayHub)
          ? null
          : _BottomNavV1(
              current: _tab,
              reviewHasDot: reviewNavHasDot,
              onSelected: (tab) => setState(() {
                _tab = tab;
                if (tab == Act0ShellTabV1.play) {
                  _showPlayHub = true;
                  _blockCompletionSummary = null;
                  _placementHandoffActive = false;
                }
                if (tab != Act0ShellTabV1.play) {
                  _practiceCompletionTitle = null;
                  _practiceCompletionBody = null;
                  _phase = Act0LessonPhaseV1.theory;
                  _selectedOptionId = null;
                  _teachingStepIndex = 0;
                  _blockCompletionSummary = null;
                  _showPlayHub = true;
                  _activeRepairTaskId = null;
                }
                if (tab != Act0ShellTabV1.home) {
                  _placementHandoffActive = false;
                }
                if (tab == Act0ShellTabV1.learn) {
                  // Auto-expand the current lesson so new users see their
                  // progress point immediately without extra taps.
                  _learnDetailLessonId ??= _selectedLessonId;
                }
                if (tab != Act0ShellTabV1.learn) {
                  _learnDetailLessonId = null;
                  _learnDetailWorldId = null;
                  _showWorldMenu = false;
                }
              }),
            ),
    );
  }

  List<Act0WorldCardV1> _progressWorlds(Act0ShellStateV1 state) {
    return _progressWorldsWithTaskIds(state, _pathClosedTaskIds);
  }

  List<Act0WorldCardV1> _progressWorldsWithTaskIds(
    Act0ShellStateV1 state,
    Set<String> completedTaskIds,
  ) {
    var previousWorldComplete = true;
    var lockedWorldSeen = false;
    final worlds = <Act0WorldCardV1>[];
    for (final world in state.worlds) {
      final progressed = _progressWorld(
        world,
        previousWorldComplete,
        isImmediateLockedWorld: !previousWorldComplete && !lockedWorldSeen,
        completedTaskIds: completedTaskIds,
      );
      worlds.add(progressed);
      if (progressed.status == Act0WorldStateV1.locked) {
        lockedWorldSeen = true;
      }
      previousWorldComplete = progressed.status == Act0WorldStateV1.completed;
    }
    return worlds;
  }

  List<Act0WorldCardV1> _progressedWorlds(Act0ShellStateV1 state) =>
      _progressWorlds(state);

  List<Act0PracticeGroupV1> _practiceGroups({
    required Act0ShellStateV1 state,
    required Act0WorldCardV1 world,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final currentTask = _firstIncompleteTask(selectedLesson);
    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    final recommendation = _learningRecommendation(
      selectedWorld: world,
      selectedLesson: selectedLesson,
    );
    final dailyDeckEntry = _nextDailyDeckEntry(state: state);
    return <Act0PracticeGroupV1>[
      Act0PracticeGroupV1(
        groupId: 'continue',
        title: _copyV1(en: 'Continue lesson', ru: 'Продолжить урок'),
        subtitle:
            '${_localizedLessonTitleV1(selectedLesson)}: ${_localizedTaskTitleV1(currentTask)}',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        categoryLabel: 'Next lesson step',
        isEnabled: selectedLesson.isSelectable,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        sessionLabel: 'Best next',
        durationLabel: '~5 min',
        isRecommended: recommendation.practiceGroupId == 'continue',
      ),
      Act0PracticeGroupV1(
        groupId: 'placement',
        title: 'Find my level',
        subtitle: 'Answer a short table spot before we tune your start point.',
        ctaLabel: 'Start check',
        categoryLabel: 'Placement',
        isEnabled: true,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        countLabel: 'Preview',
        sessionLabel: 'Diagnostic',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'placement',
      ),
      Act0PracticeGroupV1(
        groupId: 'weak_spots',
        title:
            quickFix?.title ??
            _copyV1(
              en: 'Review one quick fix',
              ru: 'Сделай один лёгкий повтор',
            ),
        subtitle: quickFix == null
            ? _copyV1(
                en: 'Quick fixes unlock after you repair one spot in Review.',
                ru: 'Лёгкие повторы откроются после одного разбора во вкладке Разбор.',
              )
            : 'One light review keeps this quick fix stable.',
        ctaLabel: quickFix != null
            ? _recommendationCtaLabel(
                _Act0LearningNextActionKindV1.reviewQuickFix,
              )
            : 'Review',
        categoryLabel: 'Repair',
        isEnabled: quickFix != null,
        targetLessonId: quickFix?.lessonId,
        targetTaskId: quickFix?.taskId,
        countLabel: quickFix == null
            ? ''
            : '${_quickFixMistakes().length} ready',
        sessionLabel: 'Quick fix',
        durationLabel: '~4 min',
        isRecommended: recommendation.practiceGroupId == 'weak_spots',
        skipTeaching: true,
        allowDrillBypass: true,
        useRapidPracticeLoop: false,
      ),
      Act0PracticeGroupV1(
        groupId: 'daily',
        title: dailyDeckEntry == null
            ? _copyV1(en: 'Daily practice', ru: 'Дневная практика')
            : _dailyCompletedRepCount >= 3
            ? _copyV1(en: 'Daily set complete', ru: 'Дневная серия закрыта')
            : _copyV1(en: 'Quick daily drill', ru: 'Быстрый дневной дрилл'),
        subtitle: dailyDeckEntry == null
            ? _copyV1(
                en: 'Unlock after one route drill.',
                ru: 'Откроется после одного дрилла на маршруте.',
              )
            : _dailyCompletedRepCount >= 3
            ? 'Nice. Keep going or repair weak spots next.'
            : dailyDeckEntry.isSpaced
            ? 'Finish three spaced spots across completed worlds.'
            : 'Finish three short spots for today.',
        ctaLabel: _dailyCompletedRepCount >= 3
            ? _recommendationCtaLabel(_Act0LearningNextActionKindV1.dailyDone)
            : _recommendationCtaLabel(_Act0LearningNextActionKindV1.dailyDrill),
        categoryLabel: 'Daily',
        isEnabled: dailyDeckEntry != null,
        targetWorldId: dailyDeckEntry?.worldId,
        targetLessonId: dailyDeckEntry?.lessonId,
        targetTaskId: dailyDeckEntry?.taskId,
        countLabel: _dailyGoalValueLabel(),
        sessionLabel: _dailyCompletedRepCount >= 3 ? 'Complete' : '3 spot set',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'daily',
        skipTeaching: true,
        allowDrillBypass: true,
        useRapidPracticeLoop: true,
      ),
      ..._topicPackSpecsV1.map(
        (spec) => _groupForTaskPack(
          state,
          spec: spec,
          isRecommended: recommendation.practiceGroupId == spec.groupId,
        ),
      ),
    ];
  }

  _Act0DailyDeckEntryV1? _nextDailyDeckEntry({
    required Act0ShellStateV1 state,
  }) {
    final deck = _dailyDeckEntries(state);
    if (deck.isEmpty) {
      return null;
    }
    return deck.firstWhere(
      (entry) => !_dailyCompletedTaskIds.contains(entry.taskId),
      orElse: () => deck.first,
    );
  }

  List<_Act0DailyDeckEntryV1> _dailyDeckEntries(Act0ShellStateV1 state) {
    final practiceWorlds = _progressedWorlds(
      state,
    ).where((world) => world.worldNumber <= 6).toList(growable: false);
    if (practiceWorlds.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final tasksByWorldId = <String, List<_Act0DailyDeckEntryV1>>{};
    for (final world in practiceWorlds) {
      final entries = <_Act0DailyDeckEntryV1>[];
      for (final lesson in world.lessons) {
        if (!lesson.isSelectable) {
          continue;
        }
        for (final task in lesson.taskList) {
          if (task.phase != Act0LessonPhaseV1.drill ||
              !_completedTaskIds.contains(task.taskId)) {
            continue;
          }
          entries.add(
            _Act0DailyDeckEntryV1(
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              taskId: task.taskId,
              isSpaced: true,
            ),
          );
        }
      }
      if (entries.isNotEmpty) {
        tasksByWorldId[world.worldId] = entries;
      }
    }
    if (tasksByWorldId.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final worldOrder = practiceWorlds
        .map((world) => world.worldId)
        .where(tasksByWorldId.containsKey)
        .toList(growable: false);
    final deck = <_Act0DailyDeckEntryV1>[];
    var hasAny = true;
    while (hasAny) {
      hasAny = false;
      for (final worldId in worldOrder) {
        final entries = tasksByWorldId[worldId]!;
        if (entries.isEmpty) {
          continue;
        }
        deck.add(entries.removeAt(0));
        hasAny = true;
      }
    }
    return deck;
  }

  _Act0LearningRecommendationV1 _learningRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      final isDeep = topMistake.severityLabel == 'Deep leak';
      return _Act0LearningRecommendationV1(
        kind: isDeep
            ? _Act0LearningNextActionKindV1.repairDeepLeak
            : _Act0LearningNextActionKindV1.repairWeakSpot,
        label: isDeep
            ? _copyV1(en: 'Deep leak', ru: 'Серьёзная ошибка')
            : _copyV1(en: 'Needs work', ru: 'Нужно подтянуть'),
        title: isDeep
            ? _copyV1(en: 'Fix a deep leak', ru: 'Разбери серьёзную ошибку')
            : _copyV1(
                en: 'Repair one weak spot',
                ru: 'Разбери одно слабое место',
              ),
        subtitle: isDeep
            ? _copyV1(
                en: 'This spot missed twice. Repair it before moving on.',
                ru: 'Этот спот уже дважды не дался. Разбери его, прежде чем идти дальше.',
              )
            : _copyV1(
                en: 'Fix this spot before it becomes a habit.',
                ru: 'Разбери этот спот, пока он не закрепился.',
              ),
        ctaLabel: _recommendationCtaLabel(
          isDeep
              ? _Act0LearningNextActionKindV1.repairDeepLeak
              : _Act0LearningNextActionKindV1.repairWeakSpot,
        ),
        hint: _copyV1(
          en: 'Repair this spot now.',
          ru: 'Разбери этот спот сейчас.',
        ),
        outcome: isDeep
            ? _copyV1(
                en: 'Deep leak first: repair ${_playDrillTitleForLesson(topMistake.lessonId)}.',
                ru: 'Сначала разбери серьёзную ошибку: ${_playDrillTitleForLesson(topMistake.lessonId)}.',
              )
            : _copyV1(
                en: 'On repair: return to ${_playDrillTitleForLesson(topMistake.lessonId)}.',
                ru: 'После разбора вернись к ${_playDrillTitleForLesson(topMistake.lessonId)}.',
              ),
        mistake: topMistake,
        lessonId: topMistake.lessonId,
        taskId: topMistake.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    if (quickFix != null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.reviewQuickFix,
        label: _copyV1(en: 'Quick fix', ru: 'Лёгкий повтор'),
        title: _copyV1(en: 'Review a quick fix', ru: 'Сделай лёгкий повтор'),
        subtitle: _copyV1(
          en: 'You already brought this spot back under control. One light review keeps it stable.',
          ru: 'Этот спот уже снова под контролем. Один лёгкий повтор поможет его закрепить.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.reviewQuickFix,
        ),
        hint: _copyV1(
          en: 'Light review in Review.',
          ru: 'Сделай лёгкий повтор во вкладке Разбор.',
        ),
        outcome: _copyV1(
          en: 'Light review: keep ${_playDrillTitleForLesson(quickFix.lessonId)} warm.',
          ru: 'Лёгкий повтор: ещё раз спокойно пройди ${_playDrillTitleForLesson(quickFix.lessonId)}.',
        ),
        mistake: quickFix,
        lessonId: quickFix.lessonId,
        taskId: quickFix.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final currentTask = _firstIncompleteTask(selectedLesson);

    if (_dailyCompletedRepCount >= 3 && _openMistakes().isEmpty) {
      final streakSaved = _streakSaveEarned();
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: streakSaved
            ? _copyV1(en: 'Streak saved', ru: 'Ритм сохранён')
            : _copyV1(en: 'Done for today', ru: 'На сегодня всё'),
        title: streakSaved
            ? _copyV1(
                en: 'Seat held for tomorrow',
                ru: 'Завтра будет легко вернуться',
              )
            : _copyV1(en: 'Tomorrow is set', ru: 'Завтрашний старт готов'),
        subtitle: streakSaved
            ? _copyV1(
                en: 'You earned tomorrow by repairing first and then closing the daily set.',
                ru: 'Сегодня ты сначала разобрал ошибки, а потом закрыл дневной набор. Завтра будет проще продолжить.',
              )
            : _copyV1(
                en: 'Today is banked. One short return tomorrow keeps the rhythm warm.',
                ru: 'Сегодняшний день закрыт. Короткий заход завтра поможет не выпадать из ритма.',
              ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: streakSaved
            ? _copyV1(
                en: 'Seat held. One clean daily tomorrow extends it.',
                ru: 'Завтра будет проще продолжить. Один чистый дневной набор продлит этот ритм.',
              )
            : _copyV1(
                en: 'Tomorrow starts ready. One clean daily keeps the loop warm.',
                ru: 'Завтра можно сразу продолжать. Один чистый дневной набор удержит ритм.',
              ),
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    if (!_completedTaskIds.contains(currentTask.taskId)) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: _cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
            ? _copyV1(en: 'Start here', ru: 'Начни здесь')
            : _copyV1(en: 'Continue', ru: 'Продолжить'),
        title: _localizedLessonTitleV1(selectedLesson),
        subtitle: _localizedLessonSubtitleV1(selectedLesson),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        hint: _copyV1(
          en: 'Continue this lesson now.',
          ru: 'Продолжи этот урок сейчас.',
        ),
        outcome:
            _nextLesson(selectedWorld.lessons, selectedLesson.lessonId) == null
            ? _copyV1(
                en: 'On return: keep the clean pass moving.',
                ru: 'Когда вернёшься, просто продолжай чистый проход.',
              )
            : _copyV1(
                en: 'On return: ${_nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.title} stays next to unlock.',
                ru: 'Когда вернёшься, следующим для открытия останется ${act0LocalizedLessonTitleAtomByIdV1(_nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.lessonId, fallback: _nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.title, isRu: _isRuLocaleV1)}.',
              ),
        lessonId: selectedLesson.lessonId,
        taskId: currentTask.taskId,
        practiceGroupId: 'continue',
      );
    }

    final dailyDeckEntry = _nextDailyDeckEntry(
      state: widget.state ?? Act0ShellStateV1.sample,
    );
    if (_dailyCompletedRepCount < 3 && dailyDeckEntry != null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDrill,
        label: _copyV1(en: 'Daily set', ru: 'Дневная серия'),
        title: _copyV1(en: 'Quick daily drill', ru: 'Быстрый дневной дрилл'),
        subtitle: _copyV1(
          en: 'Run three short spots to keep today clean.',
          ru: 'Пройди три коротких спота, чтобы держать день в ритме.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDrill,
        ),
        hint: _copyV1(
          en: 'Quick daily drill in Play.',
          ru: 'Быстрый дневной дрилл во вкладке Практика.',
        ),
        outcome: _copyV1(
          en: 'Daily set: 3 crisp reps, no extra noise.',
          ru: 'Дневной набор: 3 чётких спота без лишнего шума.',
        ),
        lessonId: dailyDeckEntry.lessonId,
        taskId: dailyDeckEntry.taskId,
        practiceGroupId: 'daily',
      );
    }

    if (_dailyCompletedRepCount >= 3 && _openMistakes().isEmpty) {
      final streakSaved = _streakSaveEarned();
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: streakSaved ? 'Streak saved' : 'Done for today',
        title: streakSaved ? 'Seat held for tomorrow' : 'Tomorrow is set',
        subtitle: streakSaved
            ? 'You earned tomorrow by repairing first and then closing the daily set.'
            : 'Today is banked. One short return tomorrow keeps the rhythm warm.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: streakSaved
            ? 'Seat held. One clean daily tomorrow extends it.'
            : 'Tomorrow starts ready. One clean daily keeps the loop warm.',
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    final categoryPracticeTarget = _topicPackLaunchTarget(
      widget.state ?? Act0ShellStateV1.sample,
      _topicPackSpecsV1.first,
    );
    if (categoryPracticeTarget == null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: _copyV1(en: 'Keep going', ru: 'Продолжай'),
        title: _localizedLessonTitleV1(selectedLesson),
        subtitle: _copyV1(
          en: 'Practice unlocks from reps you already cleared on the route.',
          ru: 'Практика открывается из спотов, которые ты уже закрыл на маршруте.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        hint: _copyV1(
          en: 'Clear one more route rep first.',
          ru: 'Сначала закрой ещё один спот на маршруте.',
        ),
        outcome: _copyV1(
          en: 'On return: Practice will repeat what you already know.',
          ru: 'Когда вернёшься, Практика будет повторять то, что ты уже знаешь.',
        ),
        lessonId: selectedLesson.lessonId,
        taskId: currentTask.taskId,
        practiceGroupId: 'continue',
      );
    }
    return _Act0LearningRecommendationV1(
      kind: _Act0LearningNextActionKindV1.categoryPractice,
      label: _copyV1(en: 'Keep going', ru: 'Продолжай'),
      title: _copyV1(en: 'Actions', ru: 'Действия'),
      subtitle: _copyV1(
        en: 'Lock in one core action pattern.',
        ru: 'Закрепи один базовый паттерн действий.',
      ),
      ctaLabel: _recommendationCtaLabel(
        _Act0LearningNextActionKindV1.categoryPractice,
      ),
      hint: _copyV1(
        en: 'Category practice in Play.',
        ru: 'Практика по категории во вкладке Практика.',
      ),
      outcome: _copyV1(
        en: 'Category practice: keep your strongest reads warm.',
        ru: 'Практика по категории: закрепи то, что уже хорошо читается.',
      ),
      lessonId: categoryPracticeTarget.lessonId,
      taskId: categoryPracticeTarget.taskId,
      practiceGroupId: 'actions',
    );
  }

  String _recommendationCtaLabel(_Act0LearningNextActionKindV1 kind) {
    return switch (kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => _copyV1(
        en: 'Fix this now',
        ru: 'Исправить сейчас',
      ),
      _Act0LearningNextActionKindV1.repairWeakSpot => _copyV1(
        en: 'Fix this now',
        ru: 'Исправить сейчас',
      ),
      _Act0LearningNextActionKindV1.reviewQuickFix => _copyV1(
        en: 'Review now',
        ru: 'Повторить сейчас',
      ),
      _Act0LearningNextActionKindV1.continueLesson => _copyV1(
        en: 'Continue',
        ru: 'Продолжить',
      ),
      _Act0LearningNextActionKindV1.dailyDrill => _copyV1(
        en: 'Start daily set',
        ru: 'Начать дневную серию',
      ),
      _Act0LearningNextActionKindV1.dailyDone => _copyV1(
        en: 'View progress',
        ru: 'Смотреть прогресс',
      ),
      _Act0LearningNextActionKindV1.categoryPractice => _copyV1(
        en: 'Practice',
        ru: 'Практика',
      ),
    };
  }

  String _homeNextActionLabel() {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Start here', ru: 'Начни здесь');
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).label;
  }

  String _homeNextActionTitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).title;
  }

  String _homeNextActionSubtitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).subtitle;
  }

  String _homeNextActionCtaLabel() {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Start first hand', ru: 'Начать первую раздачу');
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).ctaLabel;
  }

  String? _homeCtaHint(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(
        en: 'One tap opens the first hand chosen from your placement result.',
        ru: 'Одно нажатие откроет первую раздачу, выбранную по результату плейсмента.',
      );
    }
    final hint = _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).hint;
    if (hint == 'Continue this lesson now.') {
      return null;
    }
    return hint.isEmpty ? null : hint;
  }

  _Act0LearningRecommendationV1 _homePrimaryRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final currentTask = _firstIncompleteTask(selectedLesson);
    final nextLesson = _nextLesson(
      selectedWorld.lessons,
      selectedLesson.lessonId,
    );
    return _Act0LearningRecommendationV1(
      kind: _Act0LearningNextActionKindV1.continueLesson,
      label: _cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
          ? _copyV1(en: 'Start here', ru: 'Начни здесь')
          : _copyV1(en: 'Next', ru: 'Дальше'),
      title: _localizedLessonTitleV1(selectedLesson),
      subtitle: _localizedLessonSubtitleV1(selectedLesson),
      ctaLabel: _copyV1(en: 'Continue', ru: 'Продолжить'),
      hint: _copyV1(
        en: 'Continue this lesson now.',
        ru: 'Продолжи этот урок сейчас.',
      ),
      outcome: nextLesson == null
          ? _copyV1(
              en: 'On return: keep the clean pass moving.',
              ru: 'Когда вернёшься, просто продолжай чистый проход.',
            )
          : _copyV1(
              en: 'On return: ${nextLesson.title} stays next to unlock.',
              ru: 'Когда вернёшься, следующим для открытия останется ${nextLesson.title}.',
            ),
      lessonId: selectedLesson.lessonId,
      taskId: currentTask.taskId,
      practiceGroupId: 'continue',
    );
  }

  String _homeRepairLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Review', ru: 'Разбор');
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => _copyV1(
        en: 'Fix next',
        ru: 'Исправь следующим',
      ),
      _Act0LearningNextActionKindV1.repairWeakSpot => _copyV1(
        en: 'Fix next',
        ru: 'Исправь следующим',
      ),
      _Act0LearningNextActionKindV1.reviewQuickFix => _copyV1(
        en: 'Review next',
        ru: 'Повтори следующим',
      ),
      _Act0LearningNextActionKindV1.dailyDrill => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.categoryPractice => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.continueLesson => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.dailyDone => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
    };
  }

  String _homeDailyGoalCtaLabel(
    Act0WorldCardV1 _selectedWorld,
    Act0LessonCardV1 _currentLesson,
  ) {
    return _copyV1(en: 'Start practice', ru: 'Начать практику');
  }

  String _homeRepairHeadline(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(en: 'All sharp.', ru: 'Всё чётко.');
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return 'Fix ${recommendation.mistake!.title}.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'Review this quick fix.',
        ru: 'Сделай здесь лёгкий повтор.',
      );
    }
    return _copyV1(en: 'All sharp.', ru: 'Всё чётко.');
  }

  String _homeRepairDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(
        en: 'No leaks open. Keep going.',
        ru: 'Сейчас явных ошибок нет. Просто продолжай.',
      );
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(
        en: 'Last miss came from ${_playDrillTitleForLesson(recommendation.mistake!.lessonId)}.',
        ru: 'Последняя ошибка пришла из ${_playDrillTitleForLesson(recommendation.mistake!.lessonId)}.',
      );
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'Last repair came from ${_playDrillTitleForLesson(recommendation.lessonId ?? currentLesson.lessonId)}.',
        ru: 'Последний разбор был по уроку ${_playDrillTitleForLesson(recommendation.lessonId ?? currentLesson.lessonId)}.',
      );
    }
    return _copyV1(
      en: 'No leaks open. Keep going.',
      ru: 'Сейчас явных ошибок нет. Просто продолжай.',
    );
  }

  String _homeRepairOutcome(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(
        en: 'One fix now keeps the leak from following you forward.',
        ru: 'Один разбор сейчас не даст этой ошибке закрепиться.',
      );
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'One light review keeps this spot stable.',
        ru: 'Один лёгкий повтор удержит этот спот стабильным.',
      );
    }
    return '';
  }

  String? _homeRepairCtaLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(en: 'Fix now', ru: 'Исправить сейчас');
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(en: 'Open Review', ru: 'Открыть разбор');
    }
    return null;
  }

  _Act0PracticeSurfaceRecommendationV1 _practiceSurfaceRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required List<Act0PracticeGroupV1> groups,
  }) {
    Act0PracticeGroupV1? groupById(String groupId) {
      for (final group in groups) {
        if (group.groupId == groupId) {
          return group;
        }
      }
      return null;
    }

    final topMistake = _topOpenMistake();
    final quickFixGroup = groupById('weak_spots');
    final dailyGroup = groupById('daily');
    final firstPack = groups.firstWhere(
      (group) =>
          group.isEnabled &&
          !_kPracticePrimaryGroupIdsV1.contains(group.groupId) &&
          group.groupId != 'continue' &&
          group.groupId != 'placement',
      orElse: () => dailyGroup ?? groups.first,
    );

    if (quickFixGroup != null && quickFixGroup.isEnabled) {
      return _Act0PracticeSurfaceRecommendationV1(
        groupId: quickFixGroup.groupId,
        title: _copyV1(
          en: 'Review one quick fix',
          ru: 'Сделай один лёгкий повтор',
        ),
        subtitle: _copyV1(
          en: 'Keep one repaired spot stable without dropping back into Review.',
          ru: 'Закрепи один уже разобранный спот, не возвращаясь в полный режим Разбора.',
        ),
        reasonLabel: _copyV1(en: 'Quick refresh', ru: 'Лёгкий повтор'),
        outcomeLead: _copyV1(en: 'One calm rep.', ru: 'Один спокойный повтор.'),
        outcome: _copyV1(
          en: 'Then move back into daily reps or a skill pack.',
          ru: 'После этого можно вернуться к дневной серии или к одному паку.',
        ),
        masteryLabel: _copyV1(en: 'Quick refresh', ru: 'Лёгкий повтор'),
        screenSubtitle: _copyV1(
          en: 'Repeat what you already know. Repairs stay light here.',
          ru: 'Здесь повторяем только уже знакомое. Разборы остаются лёгкими.',
        ),
      );
    }

    if (dailyGroup != null && dailyGroup.isEnabled) {
      final repairStillOpen = topMistake != null;
      return _Act0PracticeSurfaceRecommendationV1(
        groupId: dailyGroup.groupId,
        title: dailyGroup.title,
        subtitle: repairStillOpen
            ? _copyV1(
                en: 'Deeper repair stays in Review. Practice keeps one short set ready here.',
                ru: 'Глубокий разбор остаётся во вкладке Разбор. Здесь держим только короткую серию повторов.',
              )
            : dailyGroup.subtitle,
        reasonLabel: _copyV1(en: 'Daily set', ru: 'Дневная серия'),
        outcomeLead: repairStillOpen
            ? _copyV1(en: 'After Review:', ru: 'После Разбора:')
            : _copyV1(en: 'Daily set:', ru: 'Эта серия:'),
        outcome: repairStillOpen
            ? _copyV1(
                en: 'keep one clean repetition lane ready while Review owns the repair.',
                ru: 'удержит под рукой одну чистую дорожку повторения, пока Разбор забирает ошибки на себя.',
              )
            : _copyV1(
                en: 'three short reps keep the route warm without extra drag.',
                ru: 'три коротких повтора удержат маршрут в тонусе без лишней паузы.',
              ),
        masteryLabel: repairStillOpen
            ? _copyV1(en: 'Review first', ru: 'Сначала разбор')
            : _copyV1(en: 'Daily set', ru: 'Дневная серия'),
        screenSubtitle: repairStillOpen
            ? _copyV1(
                en: 'Repair stays in Review. Practice keeps extra reps light here.',
                ru: 'Разбор остаётся во вкладке Разбор. Здесь — только лёгкая дополнительная практика.',
              )
            : _copyV1(
                en: 'Repeat what you already know.',
                ru: 'Повторяй то, что уже видел.',
              ),
      );
    }

    return _Act0PracticeSurfaceRecommendationV1(
      groupId: firstPack.groupId,
      title: firstPack.title,
      subtitle: firstPack.subtitle,
      reasonLabel: _copyV1(en: 'Practice focus', ru: 'Фокус практики'),
      outcomeLead: _copyV1(en: 'One clean rep.', ru: 'Один чистый повтор.'),
      outcome: _copyV1(
        en: 'Keep one known skill family warm without reopening lesson mode.',
        ru: 'Закрепи одну уже знакомую семью навыков без возврата в режим урока.',
      ),
      masteryLabel: _copyV1(en: 'Practice focus', ru: 'Фокус практики'),
      screenSubtitle: _copyV1(
        en: 'Repeat what you already know.',
        ru: 'Повторяй то, что уже видел.',
      ),
    );
  }

  String _dailyGoalValueLabel() {
    final count = _dailyCompletedRepCount.clamp(0, 3);
    if (count < 3) {
      return _copyV1(en: '$count/3 daily spots', ru: '$count/3 дневных спота');
    }
    return _streakSaveEarned()
        ? _copyV1(
            en: 'Seat held for tomorrow',
            ru: 'Завтра будет легко вернуться',
          )
        : _copyV1(en: 'Done for today', ru: 'На сегодня всё');
  }

  String _compactDailyLabel() {
    final count = _dailyCompletedRepCount.clamp(0, 3);
    if (count < 3) {
      return _copyV1(en: 'Today $count/3', ru: 'Сегодня $count/3');
    }
    return _streakSaveEarned()
        ? _copyV1(en: 'Saved \u2713', ru: 'Сохранён \u2713')
        : _copyV1(en: 'Done \u2713', ru: 'Готово \u2713');
  }

  bool _streakSaveEarned() {
    return _dailyCompletedRepCount >= 3 && _resolvedMistakeTaskIds.isNotEmpty;
  }

  Act0SharkyCueV1? _homeSharkyOverride() {
    final state = widget.state ?? Act0ShellStateV1.sample;

    // Daily done after successful repair — celebrate saved streak effort
    if (_streakSaveEarned()) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Seat held. You earned tomorrow by fixing leaks today.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine:
            'Seat held by effort today. Repeat one clean set tomorrow.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // Daily goal complete — highest priority
    if (_dailyCompletedRepCount >= 3) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Good work. This seat stays warm for tomorrow.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine:
            'Tomorrow is ready. One more clean day strengthens the habit.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // First ever session — zero completed tasks
    if (_completedTaskIds.isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Let\'s see how the table looks to you.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Every strong player started exactly here.',
        preSessionMood: Act0SharkyMoodV1.neutral,
      );
    }

    // Streak milestone — 3+ day streak and daily not yet done
    if (state.streakDays >= 3 && _dailyCompletedRepCount == 0) {
      return Act0SharkyCueV1(
        preSessionLine:
            '${state.streakDays} days running. One clean rep keeps it alive.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Consistency is the edge. You have it.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Repair queue just cleared — all prior mistakes resolved
    if (_resolvedMistakeTaskIds.isNotEmpty && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Repair queue clear. Clean slate.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'No open leaks. That is a real edge.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Clean run — 5+ correct answers with no open mistakes
    if (_cleanTaskIds.length >= 5 && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Clean run. The reads are sharpening.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Accuracy builds trust. You are building it.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Open mistakes — repair prompt
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Fix one weak spot before you stop.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'One repair now saves two repairs tomorrow.',
        preSessionMood: Act0SharkyMoodV1.repair,
      );
    }

    return null;
  }

  void _startHomeNextAction(Act0WorldCardV1 selectedWorld) {
    _placementHandoffActive = false;
    final lesson = _lessonById(selectedWorld.lessons, _selectedLessonId);
    _startRecommendation(
      _homePrimaryRecommendation(
        selectedWorld: selectedWorld,
        selectedLesson: lesson,
      ),
      selectedWorld,
      returnToPlayHub: false,
    );
  }

  void _startHomeRepairAction(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      _startRecommendation(
        recommendation,
        selectedWorld,
        returnToPlayHub: false,
      );
      return;
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      _tab = Act0ShellTabV1.review;
    }
  }

  Act0PracticeGroupV1 _groupForLesson(
    Act0WorldCardV1 world, {
    required String groupId,
    required String lessonId,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required String categoryLabel,
    required String sessionLabel,
    String? countLabel,
    String durationLabel = '',
    bool preferDrill = false,
    bool isRecommended = false,
    bool skipTeaching = false,
    bool allowDrillBypass = false,
  }) {
    final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
      (candidate) => candidate?.lessonId == lessonId,
      orElse: () => null,
    );
    final task = lesson == null
        ? null
        : _playLaunchTaskForLesson(lesson, preferDrill: preferDrill);
    return Act0PracticeGroupV1(
      groupId: groupId,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      categoryLabel: categoryLabel,
      isEnabled: lesson != null && lesson.isSelectable && task != null,
      targetLessonId: lesson?.lessonId,
      targetTaskId: task?.taskId,
      countLabel:
          countLabel ??
          (lesson == null ? '' : '${lesson.taskList.length} steps'),
      sessionLabel: sessionLabel,
      durationLabel: durationLabel,
      isRecommended: isRecommended,
      skipTeaching: skipTeaching,
      allowDrillBypass: allowDrillBypass,
    );
  }

  Act0PracticeGroupV1 _groupForTaskPack(
    Act0ShellStateV1 state, {
    required _Act0TopicPackSpecV1 spec,
    bool isRecommended = false,
  }) {
    final target = _topicPackLaunchTarget(state, spec);
    return Act0PracticeGroupV1(
      groupId: spec.groupId,
      title: spec.title,
      subtitle: target == null
          ? _copyV1(
              en: 'Clear it on the route first.',
              ru: 'Сначала закрой это на маршруте.',
            )
          : spec.subtitle,
      ctaLabel: 'Practice',
      categoryLabel: spec.categoryLabel,
      isEnabled: target != null,
      targetWorldId: target?.worldId,
      targetLessonId: target?.lessonId,
      targetTaskId: target?.taskId,
      sessionLabel: spec.sessionLabel,
      durationLabel: spec.durationLabel,
      isRecommended: isRecommended,
      skipTeaching: true,
      allowDrillBypass: true,
      useRapidPracticeLoop: true,
    );
  }

  _Act0PracticeLaunchTargetV1? _topicPackLaunchTarget(
    Act0ShellStateV1 state,
    _Act0TopicPackSpecV1 spec,
  ) {
    for (final world in _progressedWorlds(state)) {
      for (final lesson in world.lessons) {
        if (lesson.lessonId != spec.lessonId) {
          continue;
        }
        for (final task in lesson.taskList) {
          if (task.taskId != spec.taskId ||
              task.phase != Act0LessonPhaseV1.drill ||
              !_completedTaskIds.contains(task.taskId)) {
            continue;
          }
          return _Act0PracticeLaunchTargetV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            taskId: task.taskId,
          );
        }
      }
    }
    return null;
  }

  Act0LessonTaskV1? _preferredPracticeTask(
    Act0LessonCardV1 lesson, {
    bool preferDrill = false,
  }) {
    final firstIncomplete = _firstIncompleteTask(lesson);
    if (!preferDrill || firstIncomplete.phase == Act0LessonPhaseV1.drill) {
      return firstIncomplete;
    }
    return lesson.taskList.firstWhere(
      (task) =>
          task.phase == Act0LessonPhaseV1.drill &&
          _taskAvailable(lesson, task.taskId),
      orElse: () => firstIncomplete,
    );
  }

  Act0LessonTaskV1? _playLaunchTaskForLesson(
    Act0LessonCardV1 lesson, {
    bool preferDrill = false,
  }) {
    if (!preferDrill) {
      return _firstIncompleteTask(lesson);
    }
    for (final task in lesson.taskList) {
      if (task.phase == Act0LessonPhaseV1.drill) {
        return task;
      }
    }
    return _firstIncompleteTask(lesson);
  }

  String _learnGuideTitle(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairLabel(selectedWorld, selectedLesson);
  }

  String _learnGuideLine(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairHeadline(selectedWorld, selectedLesson);
  }

  String _learnGuideDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairDetail(selectedWorld, selectedLesson);
  }

  Act0SharkyMoodV1 _learnGuideMood(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.repairWeakSpot => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.reviewQuickFix => Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.continueLesson => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.dailyDrill => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.categoryPractice =>
        Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.dailyDone => Act0SharkyMoodV1.celebrate,
    };
  }

  Map<String, String> _lessonOutcomeLabels(List<Act0LessonCardV1> lessons) {
    return <String, String>{
      for (final lesson in lessons)
        lesson.lessonId: _lessonOutcomeLabel(lessons, lesson),
    };
  }

  String _lessonOutcomeLabel(
    List<Act0LessonCardV1> lessons,
    Act0LessonCardV1 lesson,
  ) {
    final nextLesson = _nextLesson(lessons, lesson.lessonId);
    return switch (lesson.state) {
      Act0LessonStateV1.completed =>
        nextLesson == null
            ? 'Already clear. Replay any step when you want a clean pass.'
            : 'Already clear. Next open lesson: ${nextLesson.title}.',
      Act0LessonStateV1.current =>
        nextLesson == null
            ? 'On clear: move into Play and lock the pattern in.'
            : 'On clear: unlock ${nextLesson.title}.',
      Act0LessonStateV1.locked => 'Opens after the current lesson is cleared.',
    };
  }

  Act0LessonCardV1? _nextLesson(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    final nextLessonId = _nextLessonId(lessons, lessonId);
    if (nextLessonId == null) {
      return null;
    }
    return _lessonById(lessons, nextLessonId);
  }

  String _playDrillTitleForLesson(String lessonId) {
    if (_isRuLocaleV1) {
      return switch (lessonId) {
        'what_poker_is' => 'Действия',
        'cards_ranks_suits' => 'Старшинство рук',
        'your_first_hand' => 'Улицы',
        'fold_check_call_raise' => 'Действия',
        'blinds_action_order' => 'Позиции',
        'positions' => 'Позиции',
        'hand_rankings_table' => 'Старшинство рук',
        'showdown_winning' => 'Шоудаун',
        _ => 'Быстрый дневной дрилл',
      };
    }
    return switch (lessonId) {
      'what_poker_is' => 'Actions',
      'cards_ranks_suits' => 'Hand rankings',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Positions',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Hand rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Quick daily drill',
    };
  }

  void _startPracticeGroup(
    Act0PracticeGroupV1 group,
    Act0WorldCardV1 selectedWorld,
  ) {
    _practiceCompletionTitle = null;
    _practiceCompletionBody = null;
    final lessonId = group.targetLessonId;
    final taskId = group.targetTaskId;
    if (!group.isEnabled || lessonId == null || taskId == null) {
      return;
    }
    if (group.groupId == 'weak_spots') {
      final weakSpot = _topOpenMistake();
      if (weakSpot != null) {
        _startMistakeRepair(
          selectedWorld,
          weakSpot,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
          skipTeaching: group.skipTeaching,
          allowDrillBypass: group.allowDrillBypass,
          rapidPracticeLoop: group.useRapidPracticeLoop,
        );
        return;
      }
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
          skipTeaching: group.skipTeaching,
          allowDrillBypass: group.allowDrillBypass,
          rapidPracticeLoop: group.useRapidPracticeLoop,
        );
        return;
      }
      return;
    }
    var launchWorld = selectedWorld;
    final targetWorldId = group.targetWorldId;
    if (targetWorldId != null) {
      final baseState = widget.state ?? Act0ShellStateV1.sample;
      launchWorld = _worldById(_progressedWorlds(baseState), targetWorldId);
    }
    _startTaskByIds(
      launchWorld,
      lessonId,
      taskId,
      skipTeaching: group.skipTeaching,
      allowDrillBypass: group.allowDrillBypass,
      rapidPracticeLoop: group.useRapidPracticeLoop,
    );
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = group.groupId;
    _rapidPracticeLoop = group.useRapidPracticeLoop;
  }

  void _startMistakeRepair(
    Act0WorldCardV1 selectedWorld,
    Act0MistakeCardV1 mistake, {
    required bool returnToPlayHub,
    String? practiceGroupId,
    bool skipTeaching = false,
    bool allowDrillBypass = false,
    bool rapidPracticeLoop = false,
  }) {
    final launchWorld = mistake.worldId.trim().isEmpty
        ? selectedWorld
        : _worldById(
            _progressedWorlds(widget.state ?? Act0ShellStateV1.sample),
            mistake.worldId,
          );
    final launchLesson = _lessonById(launchWorld.lessons, mistake.lessonId);
    final launchTask = _taskById(launchLesson, mistake.taskId);
    _startTaskByIds(
      launchWorld,
      mistake.lessonId,
      mistake.taskId,
      skipTeaching: skipTeaching,
      allowDrillBypass:
          allowDrillBypass || launchTask.phase == Act0LessonPhaseV1.drill,
      rapidPracticeLoop: rapidPracticeLoop,
    );
    _activeRepairTaskId = mistake.taskId;
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = practiceGroupId;
    _rapidPracticeLoop = rapidPracticeLoop;
    _practiceCompletionTitle = null;
    _practiceCompletionBody = null;
  }

  void _startRecommendation(
    _Act0LearningRecommendationV1 recommendation,
    Act0WorldCardV1 selectedWorld, {
    required bool returnToPlayHub,
  }) {
    final mistake = recommendation.mistake;
    if (mistake != null &&
        (recommendation.kind == _Act0LearningNextActionKindV1.repairDeepLeak ||
            recommendation.kind ==
                _Act0LearningNextActionKindV1.repairWeakSpot)) {
      _startMistakeRepair(
        selectedWorld,
        mistake,
        returnToPlayHub: returnToPlayHub,
        practiceGroupId: recommendation.practiceGroupId,
      );
      return;
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: returnToPlayHub,
          practiceGroupId: recommendation.practiceGroupId,
        );
      }
      return;
    }
    final lessonId = recommendation.lessonId;
    final taskId = recommendation.taskId;
    if (lessonId == null || taskId == null) {
      return;
    }
    _startTaskByIds(selectedWorld, lessonId, taskId);
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = recommendation.practiceGroupId;
  }

  void _startPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    _placementDiagnosticIndex = 0;
    _placementDiagnosticCorrect = 0;
    _placementDiagnosticScore = 0;
    _placementDiagnosticHitSignals.clear();
    _placementDiagnosticMissSignals.clear();
    _placementIntroVisible = false;
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
  }

  bool _startNextPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    final nextIndex = _placementDiagnosticIndex + 1;
    if (nextIndex >= _placementDiagnosticSpotsV1.length) {
      return false;
    }
    _placementDiagnosticIndex = nextIndex;
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
    return true;
  }

  void _startPlacementDiagnosticAt(
    List<Act0WorldCardV1> worlds,
    int diagnosticIndex,
  ) {
    final spot = _placementDiagnosticSpotsV1[diagnosticIndex];
    final world = _worldById(worlds, spot.worldId);
    final lesson = _lessonById(world.lessons, spot.lessonId);
    final task = _taskById(lesson, spot.taskId);
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _tab = Act0ShellTabV1.play;
    _showPlacement = false;
    _placementDiagnosticActive = true;
    _placementIntroVisible = false;
    _showPlayHub = false;
    _returnToPlayHubOnBack = false;
    _phase = task.phase;
    _selectedOptionId = null;
    // Placement diagnostic is assessment-only. Skip lesson teaching copy here;
    // the same task still teaches normally when launched from the learning path.
    _teachingStepIndex = task.runner.teachingSteps.length;
    _resetLessonRunMetrics();
  }

  Future<void> _persistPlacementCompletionV1(
    Act0PlacementResultV1 result,
  ) async {
    await ProgressService.saveIntakeProfile(<String, Object?>{
      'version': 'act0_placement_v1',
      'completedAt': DateTime.now().toUtc().toIso8601String(),
      'diagnosticCorrect': result.diagnosticCorrect,
      'diagnosticTotal': result.diagnosticTotal,
      'placementLevel': result.level.name,
      'recommendedLessonId': result.recommendedLessonId,
      'recommendedTaskId': result.recommendedTaskId,
      'focusLabel': result.level.name,
    });
    await ProgressService.setPlacementScoreV1(_placementDiagnosticScore);
  }

  Future<void> _startPlacementRecommendation(
    List<Act0WorldCardV1> worlds, {
    required bool fromZero,
  }) async {
    final world = _worldById(worlds, 'world_1');
    final result = _placementResult;
    final lessonId = fromZero || result == null
        ? 'what_poker_is'
        : result.recommendedLessonId;
    final lesson = _lessonById(world.lessons, lessonId);
    final taskId = fromZero || result == null
        ? lesson.taskList.first.taskId
        : result.recommendedTaskId;
    final task = _taskByIdWithTaskIds(lesson, taskId, _pathClosedTaskIds);
    if (fromZero) {
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
    }
    if (!fromZero && result != null) {
      final skipPlan = _buildPlacementSkipPlan(
        world: world,
        recommendedLessonId: lesson.lessonId,
        recommendedTaskId: task.taskId,
      );
      _skippedTaskIds.addAll(skipPlan.taskIds);
      _visibleSkippedTaskIds.removeAll(skipPlan.taskIds);
      unawaited(_animatePlacementSkipReveal(skipPlan.orderedTaskIds));
    }
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _showPlacement = false;
    _showWelcome = !_welcomeCompletedV1;
    _placementDiagnosticActive = false;
    _placementIntroVisible = false;
    _placementHandoffActive = true;
    _tab = Act0ShellTabV1.home;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _showWorldMenu = false;
    _learnDetailWorldId = null;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
    _phase = task.phase;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _resetLessonRunMetrics();
    _persistProgress();
    await _persistPlacementCompletionV1(result ?? _buildPlacementResult());
  }

  void _openWelcomeReplayV1() {
    setState(() {
      _welcomeReturnTabV1 = _tab;
      _showWelcome = true;
      _showPlacement = false;
      _placementDiagnosticActive = false;
      _placementHandoffActive = false;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _blockCompletionSummary = null;
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
    });
  }

  void _closeWelcomeReplayV1() {
    final returnTab = _welcomeReturnTabV1 ?? Act0ShellTabV1.profile;
    setState(() {
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _tab = returnTab;
    });
  }

  Future<void> _completeWelcomeV1() async {
    await Act0FirstStartPreferencesV1.setWelcomeCompleted();
    if (!mounted) {
      return;
    }
    final replayMode = _welcomeReturnTabV1 != null;
    setState(() {
      _welcomeCompletedV1 = true;
      _showWelcome = false;
      if (replayMode) {
        _tab = _welcomeReturnTabV1 ?? Act0ShellTabV1.profile;
      } else {
        _tab = Act0ShellTabV1.home;
      }
      _welcomeReturnTabV1 = null;
    });
  }

  _Act0PlacementSkipPlanV1 _buildPlacementSkipPlan({
    required Act0WorldCardV1 world,
    required String recommendedLessonId,
    required String recommendedTaskId,
  }) {
    final orderedTaskIds = <String>[];
    final lessonIndex = world.lessons.indexWhere(
      (lesson) => lesson.lessonId == recommendedLessonId,
    );
    if (lessonIndex < 0) {
      return const _Act0PlacementSkipPlanV1(
        taskIds: <String>{},
        orderedTaskIds: <String>[],
      );
    }

    for (var i = 0; i < lessonIndex; i++) {
      final lesson = world.lessons[i];
      for (final task in lesson.taskList) {
        orderedTaskIds.add(task.taskId);
      }
    }

    final recommendedLesson = world.lessons[lessonIndex];
    final recommendedTaskIndex = recommendedLesson.taskList.indexWhere(
      (task) => task.taskId == recommendedTaskId,
    );
    if (recommendedTaskIndex > 0) {
      for (var i = 0; i < recommendedTaskIndex; i++) {
        orderedTaskIds.add(recommendedLesson.taskList[i].taskId);
      }
    }

    return _Act0PlacementSkipPlanV1(
      taskIds: orderedTaskIds.toSet(),
      orderedTaskIds: orderedTaskIds,
    );
  }

  Future<void> _animatePlacementSkipReveal(List<String> orderedTaskIds) async {
    for (final taskId in orderedTaskIds) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) {
        return;
      }
      if (!_skippedTaskIds.contains(taskId) ||
          _visibleSkippedTaskIds.contains(taskId)) {
        continue;
      }
      setState(() {
        _visibleSkippedTaskIds.add(taskId);
      });
    }
  }

  Act0PlacementResultV1 _buildPlacementResult() {
    final profileScore = _placementQuestionsV1.fold<int>(
      0,
      (sum, question) => sum + _placementQuestionScore(question),
    );
    final diagnosticTotal = _placementDiagnosticSpotsV1.length;
    final foundationTotal = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .length;
    final foundationCorrect = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .where((spot) => _placementDiagnosticHitSignals.contains(spot.signalId))
        .length;
    final foundationMisses = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .where(
          (spot) => _placementDiagnosticMissSignals.contains(spot.signalId),
        )
        .length;
    final advancedCorrect = _placementDiagnosticSpotsV1
        .where((spot) => !spot.isFoundation)
        .where((spot) => _placementDiagnosticHitSignals.contains(spot.signalId))
        .length;
    final foundationPerfect = foundationCorrect == foundationTotal;
    final diagnosticMostlyClean =
        foundationMisses <= 1 && _placementDiagnosticCorrect >= 3;

    if (foundationPerfect &&
        advancedCorrect >= 1 &&
        _placementDiagnosticCorrect >= 4) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.readyForBasics,
        levelLabel: 'Ready for action basics',
        summary:
            'You already track the table well enough to start on real decisions.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        strengths: _placementStrengthsFor(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        weakSpots: _placementWeakSpotsFor(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        recommendedLessonId: 'fold_check_call_raise',
        recommendedTaskId: 'actions_legal_context',
        recommendedTitle: 'Fold, check, call, raise',
        recommendedReason:
            'The live check stayed clean, so we can begin with action words instead of resetting the table.',
        routeTrustLine:
            'Sharky still keeps the start close to the basics, so no core link goes missing.',
        premiumPitch:
            'Premium can turn your diagnostic into daily weak-spot drills, review queues, and progress insights.',
        trialValuePoints: <String>[
          'Daily action reps from your misses',
          'Personal review queue after every block',
          'Progress insights by category',
        ],
      );
    }
    if (diagnosticMostlyClean) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.rustyBeginner,
        levelLabel: 'Rusty beginner',
        summary:
            'You have a base. The hand flow is there, but it still needs settling before faster decisions.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        strengths: _placementStrengthsFor(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        weakSpots: _placementWeakSpotsFor(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        recommendedLessonId: 'your_first_hand',
        recommendedTaskId: 'your_first_hand_preflop',
        recommendedTitle: 'Your first hand, dealt',
        recommendedReason:
            'The live check says we should steady the hand before we speed you up.',
        routeTrustLine:
            'You skip the full reset, but Sharky still keeps the start close to the foundations.',
        premiumPitch:
            'Premium can keep your review focused on the spots you miss instead of repeating everything.',
        trialValuePoints: <String>[
          'Guided street-order practice',
          'Repair drills for missed table cues',
          'A seven-day plan after placement',
        ],
      );
    }
    return Act0PlacementResultV1(
      level: Act0PlacementResultLevelV1.newPlayer,
      levelLabel: 'New player',
      summary:
          'Start from zero. We will build the table, pot, blinds, cards, and goal one step at a time.',
      reportHeadline: _placementReportHeadline(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      reportBody: _placementReportBody(Act0PlacementResultLevelV1.newPlayer),
      coachTitle: _placementCoachTitle(Act0PlacementResultLevelV1.newPlayer),
      coachLine: _placementCoachLine(Act0PlacementResultLevelV1.newPlayer),
      profileSummary: _placementProfileSummary(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      diagnosticCorrect: _placementDiagnosticCorrect,
      diagnosticTotal: _placementDiagnosticSpotsV1.length,
      profileSignals: _placementProfileSignals(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      analysisHighlights: _placementAnalysisHighlights(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      firstSessionPlan: _placementFirstSessionPlan(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      skillStats: _placementSkillStats(Act0PlacementResultLevelV1.newPlayer),
      strengths: _placementStrengthsFor(Act0PlacementResultLevelV1.newPlayer),
      weakSpots: _placementWeakSpotsFor(Act0PlacementResultLevelV1.newPlayer),
      recommendedLessonId: 'what_poker_is',
      recommendedTaskId: 'what_poker_is_theory',
      recommendedTitle: 'What poker is',
      recommendedReason:
          'The live check says the app should still teach the table itself before asking for harder decisions.',
      routeTrustLine:
          'The start stays at the table on purpose, so nothing important is hidden under speed.',
      premiumPitch:
          'Premium can add personal repair drills and a seven-day guided plan after this foundation.',
      trialValuePoints: <String>[
        'Step-by-step beginner path',
        'Extra repairs when a concept misses',
        'Simple progress insights',
      ],
    );
  }

  void _togglePlacementOption(
    Act0PlacementQuestionV1 question,
    String optionId,
  ) {
    final selectedIds = Set<String>.from(
      _placementAnswerIds[question.questionId] ?? const <String>{},
    );
    if (!question.allowsMultiple) {
      _placementAnswerIds[question.questionId] = <String>{optionId};
      return;
    }
    if (selectedIds.contains(optionId)) {
      selectedIds.remove(optionId);
    } else {
      selectedIds.add(optionId);
    }
    if (selectedIds.isEmpty) {
      _placementAnswerIds.remove(question.questionId);
      return;
    }
    _placementAnswerIds[question.questionId] = selectedIds;
  }

  int _placementQuestionScore(Act0PlacementQuestionV1 question) {
    final selectedIds = _placementAnswerIds[question.questionId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return 0;
    }
    var score = 0;
    for (final option in question.options) {
      if (selectedIds.contains(option.optionId) && option.score > score) {
        score = option.score;
      }
    }
    return score;
  }

  Act0PlacementQuestionV1? _placementQuestionById(String questionId) {
    for (final question in _placementQuestionsV1) {
      if (question.questionId == questionId) {
        return question;
      }
    }
    return null;
  }

  List<Act0PlacementOptionV1> _selectedPlacementOptions(String questionId) {
    final question = _placementQuestionById(questionId);
    final selectedIds = _placementAnswerIds[questionId];
    if (question == null || selectedIds == null || selectedIds.isEmpty) {
      return const <Act0PlacementOptionV1>[];
    }
    return <Act0PlacementOptionV1>[
      for (final option in question.options)
        if (selectedIds.contains(option.optionId)) option,
    ];
  }

  bool _placementHasSelection(String questionId, String optionId) {
    final selectedIds = _placementAnswerIds[questionId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return false;
    }
    return selectedIds.contains(optionId);
  }

  String _placementPrimaryLabel(String questionId, String fallback) {
    final options = _selectedPlacementOptions(questionId);
    if (options.isEmpty) {
      return fallback;
    }
    return options.first.label;
  }

  String _placementJoinedLabels(String questionId, String fallback) {
    final labels = <String>[
      for (final option in _selectedPlacementOptions(questionId))
        option.label.toLowerCase(),
    ];
    if (labels.isEmpty) {
      return fallback;
    }
    if (labels.length == 1) {
      return labels.first;
    }
    if (labels.length == 2) {
      return '${labels.first} + ${labels.last}';
    }
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  String _placementCoachingRead() {
    if (_placementHasSelection('goal', 'guided') &&
        _placementHasSelection('goal', 'daily_plan')) {
      return 'a guided path with one clear daily step';
    }
    if (_placementHasSelection('goal', 'guided')) {
      return 'a guided start before heavier drills';
    }
    if (_placementHasSelection('goal', 'diagnose')) {
      return 'fast leak-finding with close repairs';
    }
    if (_placementHasSelection('goal', 'practice')) {
      return 'tight repetitions once the concept is visible';
    }
    return 'a calm, progressive beginner path';
  }

  String _placementConfusionRead() {
    return _placementJoinedLabels('confidence', 'rules, blinds, and turns');
  }

  String _placementFormatRead() {
    return _placementJoinedLabels('format', 'learn the game from scratch');
  }

  String _placementExperienceRead() {
    if (_placementHasSelection('experience', 'new')) {
      return 'fresh start with little table repetition';
    }
    if (_placementHasSelection('experience', 'friends')) {
      return 'light real-world exposure that still needs structure';
    }
    if (_placementHasSelection('experience', 'online')) {
      return 'real table exposure and enough comfort to move faster';
    }
    return 'an early-stage poker profile';
  }

  String _placementReportHeadline(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Foundation before decisions',
      Act0PlacementResultLevelV1.rustyBeginner => 'Lock hand flow before speed',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Move into actions, keep structure close',
    };
  }

  String _placementReportBody(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'The first gap is table clarity, not strategy. Sharky should make $confusion feel obvious before real decisions start.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You can skip a full reset, but the hand still gets blurry around $confusion. Sharky should steady that first, then speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You have enough comfort to start on actions. The goal now is to make $confusion feel automatic while structure stays visible.',
    };
  }

  String _placementCoachTitle(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Sharky',
      Act0PlacementResultLevelV1.rustyBeginner => 'Sharky',
      Act0PlacementResultLevelV1.readyForBasics => 'Sharky',
    };
  }

  String _placementCoachLine(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'No hard strategy yet. First I want $confusion to feel calm and obvious.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You have enough exposure. Now I want to stop the hand from blurring before decisions speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You are ready for action language. I will keep structure visible while your reads settle.',
    };
  }

  String _placementProfileSummary(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'Base stats seeded from placement. More traits unlock as you play real spots.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'This is an early read, not a final judgment. The profile will tighten as your runs grow.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Core stats are seeded now. More specific reads like 3-bet and blind defense will calibrate later.',
    };
  }

  List<String> _placementProfileSignals(Act0PlacementResultLevelV1 level) {
    final signals = <String>[
      switch (level) {
        Act0PlacementResultLevelV1.newPlayer => 'Foundation start',
        Act0PlacementResultLevelV1.rustyBeginner => 'Bridge to action',
        Act0PlacementResultLevelV1.readyForBasics => 'Action-ready entry',
      },
      _placementPrimaryLabel('experience', 'New'),
      if (_placementHasSelection('format', 'home_games'))
        'Home-game confidence',
      if (_placementHasSelection('format', 'cash')) 'Cash-game examples',
      if (_placementHasSelection('format', 'tournaments'))
        'Tournament examples',
      if (_placementHasSelection('goal', 'daily_plan')) 'Daily plan friendly',
      if (_placementHasSelection('goal', 'diagnose')) 'Leak-finding bias',
      if (_placementHasSelection('goal', 'guided')) 'Guided coaching',
    ];
    return signals;
  }

  List<String> _placementStrengthsFor(Act0PlacementResultLevelV1 level) {
    final strengths = <String>[];
    for (final signalId in _placementDiagnosticHitSignals) {
      final label = _placementSignalLabel(signalId);
      if (!strengths.contains(label)) {
        strengths.add(label);
      }
    }
    if (strengths.isNotEmpty) {
      return strengths.take(3).toList(growable: false);
    }
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Fresh start',
        'Clear path',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>[
        'Motivation',
        'Some table language',
      ],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Experience',
        'Decision comfort',
      ],
    };
  }

  List<String> _placementWeakSpotsFor(Act0PlacementResultLevelV1 level) {
    final weakSpots = <String>[];
    for (final signalId in _placementDiagnosticMissSignals) {
      final label = _placementSignalLabel(signalId);
      if (!weakSpots.contains(label)) {
        weakSpots.add(label);
      }
    }
    if (weakSpots.isNotEmpty) {
      return weakSpots.take(3).toList(growable: false);
    }
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Table',
        'Pot',
        'Blinds',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>['Blinds', 'Streets'],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Actions',
        'Positions',
      ],
    };
  }

  String _placementSignalLabel(String signalId) {
    switch (signalId) {
      case 'table_read':
        return 'Table read';
      case 'board_read':
        return 'Board read';
      case 'action_order':
        return 'Action order';
      case 'action_menu':
        return 'Legal action';
      case 'position_pressure':
        return 'Position value';
      default:
        return 'Placement read';
    }
  }

  List<String> _placementAnalysisHighlights(Act0PlacementResultLevelV1 level) {
    final liveCheckRead = _placementDiagnosticMissSignals.isEmpty
        ? 'Live check stayed clean across table, board, and action flow.'
        : 'Live check flagged ${_placementWeakSpotsFor(level).join(', ').toLowerCase()} as the first friction points.';
    return <String>[
      'Experience read: ${_placementExperienceRead()}.',
      'Main friction area: ${_placementConfusionRead()}.',
      'Preferred use case: ${_placementFormatRead()}.',
      'Best coaching fit: ${_placementCoachingRead()}.',
      liveCheckRead,
      if (level == Act0PlacementResultLevelV1.readyForBasics)
        'Diagnostic confirms enough table comfort to begin with action vocabulary.',
      if (level == Act0PlacementResultLevelV1.rustyBeginner)
        'Diagnostic says the foundation exists, but the hand still needs a cleaner mental map.',
      if (level == Act0PlacementResultLevelV1.newPlayer)
        'Diagnostic says the app should teach the table itself before faster decision reps.',
    ];
  }

  List<Act0PlacementSkillStatV1> _placementSkillStats(
    Act0PlacementResultLevelV1 level,
  ) {
    var tableFlow = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 24,
      Act0PlacementResultLevelV1.rustyBeginner => 46,
      Act0PlacementResultLevelV1.readyForBasics => 62,
    };
    var handReading = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 18,
      Act0PlacementResultLevelV1.rustyBeginner => 40,
      Act0PlacementResultLevelV1.readyForBasics => 56,
    };
    var actionDecisions = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 10,
      Act0PlacementResultLevelV1.rustyBeginner => 30,
      Act0PlacementResultLevelV1.readyForBasics => 68,
    };
    var pressureControl = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 8,
      Act0PlacementResultLevelV1.rustyBeginner => 24,
      Act0PlacementResultLevelV1.readyForBasics => 38,
    };

    if (_placementHasSelection('confidence', 'rules')) {
      tableFlow -= 10;
    }
    if (_placementHasSelection('confidence', 'cards')) {
      handReading -= 8;
    }
    if (_placementHasSelection('confidence', 'board')) {
      handReading -= 6;
    }
    if (_placementHasSelection('confidence', 'decisions')) {
      actionDecisions -= 10;
    }
    if (_placementHasSelection('confidence', 'pressure')) {
      pressureControl -= 10;
    }
    if (_placementHasSelection('experience', 'online')) {
      actionDecisions += 6;
      tableFlow += 4;
    }
    if (_placementHasSelection('experience', 'friends') ||
        _placementHasSelection('experience', 'watching')) {
      handReading += 4;
    }
    if (_placementDiagnosticHitSignals.contains('position_pressure')) {
      actionDecisions += 4;
      tableFlow += 4;
    }
    if (_placementDiagnosticMissSignals.contains('position_pressure')) {
      actionDecisions -= 4;
      tableFlow -= 4;
    }

    int clampStat(int value) => value.clamp(8, 82);

    final tableSense = tableFlow + 2;
    final boardReading = handReading - 6;
    final handReadingScore = handReading;
    final bettingDecisions = actionDecisions + (pressureControl ~/ 2);
    final positionPlay = tableFlow - 12;
    final blindPlay = ((tableFlow + pressureControl) ~/ 2) - 10;

    return <Act0PlacementSkillStatV1>[
      Act0PlacementSkillStatV1.core(
        label: 'Table sense',
        value: clampStat(tableSense),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Board reading',
        value: clampStat(boardReading),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Hand reading',
        value: clampStat(handReadingScore),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Betting decisions',
        value: clampStat(bettingDecisions),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Position play',
        value: clampStat(positionPlay),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Blind play',
        value: clampStat(blindPlay),
      ),
    ];
  }

  List<String> _placementFirstSessionPlan(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Session 1: meet the table, seats, chips, and the goal of a hand.',
        'Session 2: walk through one full beginner hand without pressure.',
        'Session 3: confirm blinds, turns, and simple table cues in a short check.',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>[
        'Session 1: rebuild preflop-to-river flow so the hand stops feeling fuzzy.',
        'Session 2: reinforce streets and what changes after the flop.',
        'Session 3: hand off into action basics once the flow stays stable.',
      ],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Session 1: anchor legal actions and when each option is available.',
        'Session 2: connect action words to seat order and pressure.',
        'Session 3: turn misses into repair reps instead of replaying the whole intro.',
      ],
    };
  }

  void _startTaskByIds(
    Act0WorldCardV1 selectedWorld,
    String lessonId,
    String taskId, {
    bool skipTeaching = false,
    bool allowDrillBypass = false,
    bool rapidPracticeLoop = false,
  }) {
    final lesson = _lessonById(selectedWorld.lessons, lessonId);
    final task = _taskById(lesson, taskId);
    final drillBypass =
        allowDrillBypass && task.phase == Act0LessonPhaseV1.drill;
    final lessonAvailable = lesson.isSelectable || drillBypass;
    final taskAvailable = _taskAvailable(lesson, taskId) || drillBypass;
    if (!lessonAvailable || !taskAvailable) {
      return;
    }
    _selectedWorldId = selectedWorld.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _tab = Act0ShellTabV1.play;
    _showPlayHub = false;
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = null;
    _rapidPracticeLoop = rapidPracticeLoop;
    _phase = task.phase;
    _selectedOptionId = null;
    _teachingStepIndex = skipTeaching && task.phase == Act0LessonPhaseV1.drill
        ? task.runner.teachingSteps.length
        : 0;
    _blockCompletionSummary = null;
  }

  void _recordAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
    Act0RunnerOptionV1 option,
  ) {
    if (_activePracticeGroupId == 'daily') {
      _dailyCompletedTaskIds.add(selectedTask.taskId);
      _dailyCompletedRepCount = (_dailyCompletedRepCount + 1).clamp(0, 3);
    }
    final category = _categoryForLesson(selectedLesson.lessonId);
    final contextLabels = _repairContextLabels(selectedTask.runner, option);
    if (option.isCorrect) {
      _incrementSkillStatsForCorrectAnswer(selectedLesson, selectedTask);
      _cleanTaskIds.add(selectedTask.taskId);
      _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
      if (_mistakeRecords.containsKey(selectedTask.taskId)) {
        _resolvedMistakeTaskIds.add(selectedTask.taskId);
        if (_activeRepairTaskId != selectedTask.taskId &&
            _lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
          _lessonRunQuickFixTaskIds.add(selectedTask.taskId);
          _lessonRunDeepLeakTaskIds.remove(selectedTask.taskId);
        }
      }
      return;
    }
    _lessonRunMistakeTaskIds.add(selectedTask.taskId);
    if (_activeRepairTaskId != selectedTask.taskId &&
        !_lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
      _lessonRunPendingRetryTaskIds.add(selectedTask.taskId);
    } else if (_activeRepairTaskId != selectedTask.taskId &&
        _lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
      _lessonRunDeepLeakTaskIds.add(selectedTask.taskId);
      _lessonRunQuickFixTaskIds.remove(selectedTask.taskId);
    }
    _resolvedMistakeTaskIds.remove(selectedTask.taskId);
    final previous = _mistakeRecords[selectedTask.taskId];
    _mistakeRecords[selectedTask.taskId] = _Act0MistakeRecordV1(
      taskId: selectedTask.taskId,
      lessonId: selectedLesson.lessonId,
      worldId: _selectedWorldId,
      title: _localizedTaskTitleV1(selectedTask),
      weaknessLabel: category,
      selectedOptionId: option.id,
      selectedLabel: option.label,
      betterLabel: option.betterAnswerLabel,
      reason: _hardenMistakeReason(
        rawReason: option.feedbackReason,
        betterLabel: option.betterAnswerLabel,
        contextLabels: contextLabels,
      ),
      contextLabels: contextLabels,
      repairActionLabel: _repairActionLabel(selectedTask),
      attempts: (previous?.attempts ?? 0) + 1,
    );
  }

  bool _usesSizingPresetControlsV1(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    return selectedLesson.lessonId == 'small_half_pot' &&
        selectedTask.phase == Act0LessonPhaseV1.drill &&
        selectedTask.resolvedTaskFamily == Act0TaskFamilyV1.sizing &&
        _w5SizingDrillTaskIds.contains(selectedTask.taskId);
  }

  Act0SizingConfigV1 _activeSizingConfigV1(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    if (_phase != Act0LessonPhaseV1.drill ||
        !_usesSizingPresetControlsV1(selectedLesson, selectedTask)) {
      return const Act0SizingConfigV1.disabled();
    }
    return Act0SizingConfigV1(
      mode: Act0SizingUiModeV1.presetsOnly,
      showGuidance: false,
      presets: selectedTask.runner.options
          .map(
            (option) => Act0SizingPresetV1(
              id: option.id,
              label: option.label,
              potFraction: _potFractionFromSizingLabelV1(option.label),
              displayLabel: _sizingDisplayLabelV1(option.label),
              detailLabel: option.label,
              ctaLabel: 'Lock ${_sizingDisplayLabelV1(option.label)}',
              isPrimary: option.isCorrect,
            ),
          )
          .toList(growable: false),
    );
  }

  String? _activeSelectedPresetIdV1(Act0LessonTaskV1 selectedTask) {
    if (_phase != Act0LessonPhaseV1.drill ||
        _selectedPresetTaskId != selectedTask.taskId) {
      return null;
    }
    return _selectedPresetId;
  }

  double _potFractionFromSizingLabelV1(String label) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label);
    final amount = double.tryParse(match?.group(1) ?? '');
    if (amount == null || amount <= 0) {
      return 0;
    }
    return amount / 6;
  }

  String _sizingDisplayLabelV1(String label) {
    switch (label) {
      case '2 BB':
        return 'One-third';
      case '3 BB':
        return 'Half-pot';
      case '6 BB':
        return 'Pot-size';
      default:
        return label;
    }
  }

  void _confirmSizingPresetAnswerV1({
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    final presetId = _activeSelectedPresetIdV1(selectedTask);
    if (presetId == null) {
      return;
    }
    final option = _optionById(selectedTask.runner.options, presetId);
    if (option == null) {
      return;
    }
    _fireAnswerEffects(option);
    if (!_placementDiagnosticActive) {
      _recordAnswer(selectedLesson, selectedTask, option);
    }
    _selectedOptionId = option.id;
    _phase = Act0LessonPhaseV1.review;
    _teachingStepIndex = 0;
  }

  void _finishRapidPracticeLoopToHub({String? completedLessonId}) {
    final groupId = _activePracticeGroupId;
    if (groupId == 'daily') {
      _practiceCompletionTitle = _copyV1(
        en: 'Daily set complete',
        ru: 'Дневная серия закрыта',
      );
      _practiceCompletionBody = _copyV1(
        en: 'Three short reps landed. Pick one more lane or head back to Home.',
        ru: 'Три коротких повтора готовы. Можешь взять ещё одну дорожку или вернуться домой.',
      );
    } else if (completedLessonId != null) {
      final family = _playDrillTitleForLesson(completedLessonId);
      _practiceCompletionTitle = _copyV1(
        en: 'Rep complete',
        ru: 'Повтор готов',
      );
      _practiceCompletionBody = _copyV1(
        en: '$family stayed warm. Pick another pack when you want one more clean rep.',
        ru: '$family закреплены. Возьми другой пак, когда захочешь ещё один чистый повтор.',
      );
    }
    _showPlayHub = true;
    _returnToPlayHubOnBack = true;
    _selectedOptionId = null;
    _selectedPresetId = null;
    _selectedPresetTaskId = null;
    _phase = Act0LessonPhaseV1.theory;
    _teachingStepIndex = 0;
  }

  String _hardenMistakeReason({
    required String rawReason,
    required String betterLabel,
    required List<String> contextLabels,
  }) {
    final reason = rawReason.trim();
    final lowerReason = reason.toLowerCase();
    if (lowerReason.contains('next cue:')) {
      return reason;
    }
    final focus = contextLabels.firstWhere(
      (label) => label.trim().isNotEmpty,
      orElse: () => '',
    );
    final cue = betterLabel.trim().isEmpty
        ? (focus.isEmpty
              ? 'Next cue: compare seat, pressure, and legal actions before you continue.'
              : 'Next cue: check $focus, then compare seat, pressure, and legal actions.')
        : (focus.isEmpty
              ? 'Next cue: pause on seat and pressure, then choose $betterLabel.'
              : 'Next cue: check $focus, then choose $betterLabel.');
    if (reason.isEmpty) {
      return cue;
    }
    return '$reason $cue';
  }

  bool _shouldRetryInsideLesson(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    final selectedOption = runner.selectedOption;
    if (selectedOption == null || selectedOption.isCorrect) {
      return false;
    }
    if (_activeRepairTaskId == selectedTask.taskId ||
        _placementDiagnosticActive) {
      return false;
    }
    return _lessonRunPendingRetryTaskIds.contains(selectedTask.taskId) &&
        !_lessonRunRetriedTaskIds.contains(selectedTask.taskId);
  }

  void _startInsideLessonRetry(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
    _lessonRunRetriedTaskIds.add(selectedTask.taskId);
    _selectedOptionId = null;
    _phase = runner.options.isEmpty
        ? selectedTask.phase
        : Act0LessonPhaseV1.drill;
    _teachingStepIndex = runner.teachingSteps.length;
  }

  bool _maybeStartLessonWrapUpRetry(Act0LessonCardV1 selectedLesson) {
    if (_placementDiagnosticActive || _activeRepairTaskId != null) {
      return false;
    }
    final wrapUpAnchorTaskId = _lessonRunWrapUpAnchorTaskId ?? _selectedTaskId;
    if (_nextTask(selectedLesson, wrapUpAnchorTaskId) != null) {
      return false;
    }
    _lessonRunWrapUpAnchorTaskId ??= wrapUpAnchorTaskId;
    for (final task in selectedLesson.taskList) {
      if (!_lessonRunMistakeTaskIds.contains(task.taskId)) {
        continue;
      }
      if (_lessonRunWrapUpCompletedTaskIds.contains(task.taskId)) {
        continue;
      }
      _activeLessonWrapUpTaskId = task.taskId;
      _selectedTaskId = task.taskId;
      _selectedOptionId = null;
      _phase = task.runner.options.isEmpty
          ? task.phase
          : Act0LessonPhaseV1.drill;
      _teachingStepIndex = 0;
      _tab = Act0ShellTabV1.play;
      _showPlayHub = false;
      return true;
    }
    return false;
  }

  void _restoreWrapUpAnchorTaskId(Act0LessonCardV1 selectedLesson) {
    final wrapUpAnchorTaskId = _lessonRunWrapUpAnchorTaskId;
    if (wrapUpAnchorTaskId == null) {
      return;
    }
    final anchorTask = _taskById(selectedLesson, wrapUpAnchorTaskId);
    _selectedTaskId = anchorTask.taskId;
    _phase = anchorTask.phase;
  }

  String _repairActionLabel(Act0LessonTaskV1 task) {
    return switch (task.stepKind) {
      Act0LessonStepKindV1.learn => 'Replay the idea once',
      Act0LessonStepKindV1.practice => 'Replay this spot once',
      Act0LessonStepKindV1.fixMistakes => 'Replay the repair spot',
      Act0LessonStepKindV1.review => 'Replay the key spot',
      Act0LessonStepKindV1.proveIt => 'Replay the final check',
    };
  }

  List<String> _repairContextLabels(
    Act0RunnerStateV1 runner,
    Act0RunnerOptionV1 option,
  ) {
    if (option.repairFocusLabels.isNotEmpty) {
      return option.repairFocusLabels;
    }
    return <String>[
      if (runner.table.centerLabel.isNotEmpty) runner.table.centerLabel,
      if (runner.table.potLabel.isNotEmpty) runner.table.potLabel,
      if (runner.table.toCallLabel.isNotEmpty) runner.table.toCallLabel,
    ];
  }

  int _remainingWrapUpTaskCount() {
    return _lessonRunMistakeTaskIds
        .where((taskId) => !_lessonRunWrapUpCompletedTaskIds.contains(taskId))
        .length;
  }

  Act0RunnerStateV1 _repairRunnerForTask(Act0LessonTaskV1 selectedTask) {
    if (_activeLessonWrapUpTaskId == selectedTask.taskId) {
      final record = _mistakeRecords[selectedTask.taskId];
      final option = record == null
          ? null
          : _optionById(selectedTask.runner.options, record.selectedOptionId);
      final focusLabels = option == null || record == null
          ? const <String>[]
          : _repairContextLabels(selectedTask.runner, option);
      final focusTable = option == null || record == null
          ? selectedTask.runner.table
          : _repairFocusedTable(selectedTask.runner.table, option, record);
      final showWrapUpIntro = _lessonRunWrapUpCompletedTaskIds.isEmpty;
      final remainingWrapUpTaskCount = _remainingWrapUpTaskCount();
      final wrapUpCountLine = remainingWrapUpTaskCount <= 1
          ? 'One spot to revisit before the lesson summary.'
          : '$remainingWrapUpTaskCount spots to revisit before the lesson summary.';
      return selectedTask.runner.copyWith(
        sharky: showWrapUpIntro
            ? selectedTask.runner.sharky.copyWith(
                preSessionLine: 'One last check before the lesson wraps.',
                preSessionMood: Act0SharkyMoodV1.thinking,
              )
            : selectedTask.runner.sharky,
        table: focusTable,
        teachingSteps: showWrapUpIntro
            ? <Act0TeachingStepV1>[
                Act0TeachingStepV1(
                  title: 'One last check',
                  body: record == null
                      ? wrapUpCountLine
                      : 'You missed this earlier. $wrapUpCountLine',
                  table: focusTable,
                  focusSeatIds: option?.repairFocusSeatIds ?? const <String>[],
                  focusCardIds: option?.repairFocusCardIds ?? const <String>[],
                  focusLabels: focusLabels,
                  ctaLabel: 'Retry',
                ),
              ]
            : const <Act0TeachingStepV1>[],
      );
    }
    final record = _activeRepairTaskId == selectedTask.taskId
        ? _mistakeRecords[selectedTask.taskId]
        : null;
    if (record == null) {
      return selectedTask.runner;
    }
    final option = _optionById(
      selectedTask.runner.options,
      record.selectedOptionId,
    );
    final focusLabels = option == null
        ? record.contextLabels
        : _repairContextLabels(selectedTask.runner, option);
    final focusTable = option == null
        ? selectedTask.runner.table
        : _repairFocusedTable(selectedTask.runner.table, option, record);
    return selectedTask.runner.copyWith(
      sharky: selectedTask.runner.sharky.copyWith(
        preSessionLine: selectedTask.runner.sharky.repairLine,
        preSessionMood: Act0SharkyMoodV1.repair,
      ),
      table: focusTable,
      teachingSteps: <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: 'Repair this spot',
          body:
              'You chose ${record.selectedLabel}. Better: ${record.betterLabel}.',
          table: focusTable,
          focusSeatIds: option?.repairFocusSeatIds ?? const <String>[],
          focusCardIds: option?.repairFocusCardIds ?? const <String>[],
          focusLabels: focusLabels,
          ctaLabel: 'Practice',
        ),
        ...selectedTask.runner.teachingSteps,
      ],
    );
  }

  Act0RunnerOptionV1? _optionById(
    List<Act0RunnerOptionV1> options,
    String optionId,
  ) {
    for (final option in options) {
      if (option.id == optionId) {
        return option;
      }
    }
    return null;
  }

  Act0TableStateV1 _repairFocusedTable(
    Act0TableStateV1 table,
    Act0RunnerOptionV1 option,
    _Act0MistakeRecordV1 record,
  ) {
    return table.copyWith(
      highlightedSeatIds: option.repairFocusSeatIds.isEmpty
          ? table.highlightedSeatIds
          : option.repairFocusSeatIds,
      highlightedCardIds: option.repairFocusCardIds.isEmpty
          ? table.highlightedCardIds
          : option.repairFocusCardIds,
      focusCalloutLabel:
          'Repair: ${record.selectedLabel} misses this. Better: ${record.betterLabel}.',
    );
  }

  Act0ReviewStateV1 _reviewState(Act0ReviewStateV1 base) {
    final open = _openMistakes().isEmpty
        ? base.mistakes.where((mistake) => !mistake.resolved).toList()
        : _openMistakes();
    final fixed = _fixedMistakes().isEmpty
        ? base.fixedMistakes
        : _fixedMistakes();
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final strongSpots = _strongCategories().isEmpty
        ? base.strongSpots
        : _strongCategories();
    return Act0ReviewStateV1(
      title: 'Repair board',
      subtitle: recommendation.subtitle,
      weaknessLabel: open.isEmpty
          ? base.weaknessLabel
          : open.first.weaknessLabel,
      reason: open.isEmpty ? base.reason : open.first.reason,
      stats: <Act0ReviewStatV1>[
        Act0ReviewStatV1(label: 'Open', value: '${open.length}'),
        Act0ReviewStatV1(label: 'Deep', value: '${_deepLeakMistakes().length}'),
        Act0ReviewStatV1(
          label: 'Quick',
          value: '${_quickFixMistakes().length}',
        ),
        Act0ReviewStatV1(label: 'Fixed', value: '${fixed.length}'),
        Act0ReviewStatV1(label: 'Strong', value: '${strongSpots.length}'),
      ],
      chosenLabel: open.isEmpty ? base.chosenLabel : open.first.selectedLabel,
      betterLabel: open.isEmpty ? base.betterLabel : open.first.betterLabel,
      mistakes: open,
      fixedMistakes: fixed,
      strongSpots: strongSpots,
    );
  }

  Act0ProfileStateV1 _profileState(
    Act0ProfileStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final totalTasks = _allLessons().fold<int>(
      0,
      (count, lesson) => count + lesson.taskList.length,
    );
    final completedCount = _completedTaskIds.length.clamp(0, totalTasks);
    final wrongAttempts = _mistakeRecords.values.fold<int>(
      0,
      (count, mistake) => count + mistake.attempts,
    );
    final totalAttempts = _cleanTaskIds.length + wrongAttempts;
    final accuracy = totalAttempts == 0
        ? base.accuracyLine
        : '${((_cleanTaskIds.length / totalAttempts) * 100).round()}% practice accuracy';
    final perfectClearCount = _completedTaskIds.where((taskId) {
      if (!_cleanTaskIds.contains(taskId)) {
        return false;
      }
      return !_hasOpenMistakeRecord(taskId);
    }).length;
    final qualityLine = _profileQualityLineV1(
      perfectClearCount: perfectClearCount,
      completedCount: completedCount,
    );
    final streakDays = _effectiveStreakDays(state);
    final streakSaved = _streakSaveEarned();
    final focusTitle = recommendation.title.trim().isNotEmpty
        ? recommendation.title
        : (_weakCategories().isNotEmpty
              ? 'Repair ${_weakCategories().first}'
              : 'Keep the next clean rep simple');
    final focusBody = recommendation.subtitle.trim().isNotEmpty
        ? recommendation.subtitle
        : (_weakCategories().isNotEmpty
              ? 'One calm repair here will make the rest of the route lighter.'
              : 'Stay close to the active route and keep the next rep clean.');
    final focusCtaLabel = recommendation.ctaLabel.trim().isNotEmpty
        ? recommendation.ctaLabel
        : 'Open next step';
    return Act0ProfileStateV1(
      playerName: base.playerName,
      level: 'Level ${progress.level}',
      xpLine:
          '${progress.xp} / ${(widget.state ?? Act0ShellStateV1.sample).xpTarget} XP',
      lessonsLine: '$completedCount of $totalTasks tasks complete',
      accuracyLine: accuracy,
      qualityLine: qualityLine,
      streakLine: streakDays == 0
          ? 'No streak yet'
          : streakSaved
          ? (streakDays == 1
                ? '1 day streak · saved today'
                : '$streakDays day streak · saved today')
          : (streakDays == 1 ? '1 day streak' : '$streakDays day streak'),
      streakDays: streakDays,
      consistencyActiveDays: base.consistencyActiveDays,
      achievements: <Act0AchievementV1>[
        Act0AchievementV1(
          id: 'first_table_read',
          label: 'First clear read',
          locked: completedCount == 0,
        ),
        Act0AchievementV1(
          id: 'three_day_streak',
          label: 'Three day rhythm',
          locked: streakDays < 3,
        ),
        Act0AchievementV1(
          id: 'repair_queue_clear',
          label: 'Repair route clear',
          locked: _openMistakes().isNotEmpty,
        ),
        Act0AchievementV1(
          id: 'streak_save_earned',
          label: 'Rhythm saved today',
          locked: !streakSaved,
        ),
        Act0AchievementV1(
          id: 'clean_practice_run',
          label: 'Clean drill chain',
          locked: _cleanTaskIds.length < 3,
        ),
      ],
      strongCategories: _strongCategories(),
      weakCategories: _weakCategories(),
      recentProgress: _recentProgress(),
      recentSkillGains: _profileRecentSkillGains(base.recentSkillGains),
      skillStats: _profileSkillStats(base.skillStats),
      streakLast7: base.streakLast7,
      recommendedFocusTitle: focusTitle,
      recommendedFocusBody: focusBody,
      recommendedFocusCtaLabel: focusCtaLabel,
      worldsClearedCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.completed).length,
      worldsActiveCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.current).length,
      totalWorldsCount: _progressedWorlds(state).length,
      mistakesFixedLine: _resolvedMistakeTaskIds.isEmpty
          ? ''
          : _copyV1(
              en: _resolvedMistakeTaskIds.length == 1
                  ? '1 spot stabilized'
                  : '${_resolvedMistakeTaskIds.length} spots stabilized',
              ru: _resolvedMistakeTaskIds.length == 1
                  ? '1 спот закреплён'
                  : '${_resolvedMistakeTaskIds.length} спота закреплены',
            ),
    );
  }

  String _profileQualityLineV1({
    required int perfectClearCount,
    required int completedCount,
  }) {
    if (perfectClearCount > 0) {
      return _copyV1(
        en: perfectClearCount == 1
            ? '1 perfect clear'
            : '$perfectClearCount perfect clears',
        ru: perfectClearCount == 1
            ? '1 идеальный проход'
            : '$perfectClearCount идеальных прохода',
      );
    }
    if (completedCount > 0) {
      return _copyV1(en: 'Perfect path open', ru: 'Идеал открыт');
    }
    return _copyV1(en: 'Clean progress started', ru: 'Чистый прогресс начат');
  }

  Set<String> _perfectTaskIds() {
    return <String>{
      for (final taskId in _completedTaskIds)
        if (_cleanTaskIds.contains(taskId) && !_hasOpenMistakeRecord(taskId))
          taskId,
    };
  }

  bool _hasOpenMistakeRecord(String taskId) =>
      _mistakeRecords.containsKey(taskId) &&
      !_resolvedMistakeTaskIds.contains(taskId);

  Act0MistakeCardV1? _topOpenMistake() {
    final open = _openMistakes();
    return open.isEmpty ? null : open.first;
  }

  List<Act0MistakeCardV1> _openMistakes() {
    final open = <Act0MistakeCardV1>[
      for (final record in _mistakeRecords.values)
        if (!_resolvedMistakeTaskIds.contains(record.taskId)) record.toCard(),
    ];
    open.sort((a, b) {
      final priority = _mistakePriority(b).compareTo(_mistakePriority(a));
      if (priority != 0) {
        return priority;
      }
      return a.taskId.compareTo(b.taskId);
    });
    return open;
  }

  int _mistakePriority(Act0MistakeCardV1 mistake) {
    final severity = switch (mistake.severityLabel) {
      'Deep leak' => 300,
      'Needs repair' => 200,
      'Quick fix' => 100,
      _ => 0,
    };
    return severity + mistake.attempts.clamp(0, 99);
  }

  List<Act0MistakeCardV1> _fixedMistakes() => [
    for (final record in _mistakeRecords.values)
      if (_resolvedMistakeTaskIds.contains(record.taskId))
        record.toCard(
          resolved: true,
          completionState: _perfectTaskIds().contains(record.taskId)
              ? Act0CompletionDisplayStateV1.perfect
              : (_cleanTaskIds.contains(record.taskId)
                    ? Act0CompletionDisplayStateV1.clear
                    : null),
          qualityLine: _perfectTaskIds().contains(record.taskId)
              ? _copyV1(en: 'Perfect clear complete.', ru: 'Идеально пройдено.')
              : (_cleanTaskIds.contains(record.taskId)
                    ? _copyV1(
                        en: 'Clear path still open.',
                        ru: 'Путь к идеалу открыт.',
                      )
                    : ''),
        ),
  ];

  List<Act0MistakeCardV1> _quickFixMistakes() => [
    for (final mistake in _fixedMistakes())
      if (mistake.severityLabel == 'Quick fix') mistake,
  ];

  List<Act0MistakeCardV1> _deepLeakMistakes() => [
    for (final mistake in _openMistakes())
      if (mistake.severityLabel == 'Deep leak') mistake,
  ];

  List<String> _strongCategories() {
    final categories = <String>{};
    for (final taskId in _cleanTaskIds) {
      if (_hasOpenMistakeRecord(taskId)) {
        continue;
      }
      final lesson = _lessonForTaskId(taskId);
      if (lesson != null) {
        categories.add(_categoryForLesson(lesson.lessonId));
      }
    }
    return categories.take(4).toList();
  }

  List<String> _weakCategories() {
    final categories = <String>{};
    for (final mistake in _openMistakes()) {
      categories.add(mistake.weaknessLabel);
    }
    return categories.take(4).toList();
  }

  List<String> _recentProgress() {
    final items = <String>[];
    for (final taskId in _completedTaskIds.toList().reversed) {
      final task = _taskForId(taskId);
      if (task != null) {
        items.add(task.title);
        if (_isRuLocaleV1) {
          items[items.length - 1] = _localizedTaskTitleV1(task);
        }
      }
      if (items.length == 4) {
        break;
      }
    }
    return items;
  }

  void _seedProfileSkillStats(List<Act0PlacementSkillStatV1> stats) {
    for (final stat in stats) {
      _profileSkillValues[_canonicalSkillLabel(stat.label)] = stat.value;
    }
  }

  void _incrementSkillStatsForCorrectAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    final deltas = _skillDeltaForAnswer(selectedLesson, selectedTask);
    _mergeSkillGainCountsV1(_lessonRunSkillGainCounts, deltas);
    for (final entry in deltas.entries) {
      final current = _profileSkillValues[entry.key] ?? 0;
      _profileSkillValues[entry.key] = (current + entry.value).clamp(0, 99);
      _pushRecentSkillGain(
        label: entry.key,
        gain: entry.value,
        source: selectedTask.title,
      );
    }
  }

  void _mergeSkillGainCountsV1(
    Map<String, int> target,
    Map<String, int> deltas,
  ) {
    for (final entry in deltas.entries) {
      target[entry.key] = (target[entry.key] ?? 0) + entry.value;
    }
  }

  Map<String, int> _deriveSkillValuesFromCompletedTasks(Set<String> taskIds) {
    final values = <String, int>{};
    for (final taskId in taskIds) {
      final lesson = _lessonForTaskId(taskId);
      final task = lesson == null ? null : _taskForId(taskId);
      if (lesson == null || task == null) {
        continue;
      }
      final deltas = _skillDeltaForTask(lesson.lessonId, task.taskId);
      for (final entry in deltas.entries) {
        values[entry.key] = ((values[entry.key] ?? 0) + entry.value).clamp(
          0,
          99,
        );
      }
    }
    return values;
  }

  Map<String, int> _skillDeltaForTask(String lessonId, String taskId) {
    final exact = _taskSkillDeltasV1[taskId];
    if (exact != null) {
      return exact;
    }
    if (taskId.startsWith('positions_')) {
      return const <String, int>{'Position play': 4, 'Table sense': 2};
    }
    if (taskId.startsWith('blinds_')) {
      return const <String, int>{'Blind play': 4, 'Table sense': 2};
    }
    if (taskId.startsWith('actions_') ||
        taskId.contains('fold') ||
        taskId.contains('check') ||
        taskId.contains('call') ||
        taskId.contains('raise') ||
        taskId.contains('bet')) {
      return const <String, int>{'Betting decisions': 4, 'Table sense': 1};
    }
    if (taskId.startsWith('hand_rankings_') || taskId.startsWith('showdown_')) {
      return taskId.contains('best_five') ||
              taskId.contains('straight') ||
              taskId.contains('flush')
          ? const <String, int>{'Hand reading': 3, 'Board reading': 2}
          : const <String, int>{'Hand reading': 4, 'Board reading': 1};
    }
    if (taskId.contains('board') ||
        taskId.contains('river') ||
        taskId.contains('flop') ||
        taskId.contains('turn')) {
      return const <String, int>{'Board reading': 4, 'Hand reading': 1};
    }
    return switch (lessonId) {
      'what_poker_is' => <String, int>{'Table sense': 5},
      'cards_ranks_suits' => <String, int>{
        'Board reading': 3,
        'Hand reading': 2,
      },
      'your_first_hand' => <String, int>{
        'Table sense': 2,
        'Board reading': 2,
        'Betting decisions': 1,
      },
      'fold_check_call_raise' => <String, int>{
        'Betting decisions': 4,
        'Table sense': 1,
      },
      'blinds_action_order' => <String, int>{'Blind play': 4, 'Table sense': 2},
      'positions' => <String, int>{'Position play': 4, 'Table sense': 2},
      'hand_rankings_table' => <String, int>{'Hand reading': 4},
      'showdown_winning' => <String, int>{
        'Hand reading': 4,
        'Board reading': 1,
      },
      _ =>
        taskId.contains('blind')
            ? <String, int>{'Blind play': 3}
            : <String, int>{'Table sense': 2},
    };
  }

  Map<String, int> _skillDeltaForAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    return _skillDeltaForTask(selectedLesson.lessonId, selectedTask.taskId);
  }

  void _pushRecentSkillGain({
    required String label,
    required int gain,
    required String source,
  }) {
    _recentSkillGains.insert(
      0,
      Act0SkillGainV1(label: label, gain: gain, source: source),
    );
    if (_recentSkillGains.length > 6) {
      _recentSkillGains.removeRange(6, _recentSkillGains.length);
    }
  }

  List<Act0SkillGainV1> _skillGainsFromMapV1(
    Map<String, int> deltas, {
    required String source,
  }) {
    final entries = deltas.entries.toList()
      ..sort((a, b) {
        final gainCompare = b.value.compareTo(a.value);
        if (gainCompare != 0) {
          return gainCompare;
        }
        return a.key.compareTo(b.key);
      });
    return <Act0SkillGainV1>[
      for (final entry in entries.take(3))
        Act0SkillGainV1(label: entry.key, gain: entry.value, source: source),
    ];
  }

  bool _isTaskCompletingLessonMilestoneV1({
    required Act0LessonCardV1 lesson,
    required String taskId,
  }) {
    if (_nextTask(lesson, taskId) == null) {
      return true;
    }
    return _activeLessonWrapUpTaskId == taskId;
  }

  Map<String, int> _aggregateSkillDeltasForWorldV1(Act0WorldCardV1 world) {
    final totals = <String, int>{};
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        _mergeSkillGainCountsV1(
          totals,
          _skillDeltaForTask(lesson.lessonId, task.taskId),
        );
      }
    }
    return totals;
  }

  int _completedTaskCountForWorldV1(Act0WorldCardV1 world) {
    var count = 0;
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (_completedTaskIds.contains(task.taskId)) {
          count += 1;
        }
      }
    }
    return count;
  }

  int _perfectTaskCountForWorldV1(Act0WorldCardV1 world) {
    final perfectTaskIds = _perfectTaskIds();
    var count = 0;
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (perfectTaskIds.contains(task.taskId)) {
          count += 1;
        }
      }
    }
    return count;
  }

  int _openMistakeCountForLessonV1(Act0LessonCardV1 lesson) {
    var count = 0;
    for (final task in lesson.taskList) {
      if (_hasOpenMistakeRecord(task.taskId)) {
        count += 1;
      }
    }
    return count;
  }

  int _openMistakeCountForWorldV1(Act0WorldCardV1 world) {
    var count = 0;
    for (final lesson in world.lessons) {
      count += _openMistakeCountForLessonV1(lesson);
    }
    return count;
  }

  List<Act0SkillGainV1> _profileRecentSkillGains(
    List<Act0SkillGainV1> baseGains,
  ) {
    if (_recentSkillGains.isNotEmpty) {
      return _recentSkillGains.take(4).toList();
    }
    return _usesPersistedProgress ? const <Act0SkillGainV1>[] : baseGains;
  }

  List<Act0PlacementSkillStatV1> _profileSkillStats(
    List<Act0PlacementSkillStatV1> baseStats,
  ) {
    const statOrder = <String>[
      'Table sense',
      'Board reading',
      'Hand reading',
      'Betting decisions',
      'Position play',
      'Blind play',
    ];

    final seededValues = <String, int>{
      if (!_usesPersistedProgress)
        for (final stat in baseStats)
          _canonicalSkillLabel(stat.label): stat.value,
      ..._profileSkillValues,
    };

    return <Act0PlacementSkillStatV1>[
      for (final label in statOrder)
        Act0PlacementSkillStatV1.core(
          label: label,
          value: seededValues[label] ?? 0,
          locked: !seededValues.containsKey(label),
        ),
    ];
  }

  String _canonicalSkillLabel(String label) {
    return switch (label) {
      'Situational awareness' || 'Hand flow' || 'Table flow' => 'Table sense',
      'Action decisions' ||
      'Betting choices' ||
      'Calm under pressure' => 'Betting decisions',
      'Blind defense' || '3-bet pots' || '3-bet game' => 'Blind play',
      'Showdown reading' => 'Hand reading',
      _ => label,
    };
  }

  List<Act0LessonCardV1> _allLessons() => [
    for (final world in (widget.state ?? Act0ShellStateV1.sample).worlds)
      ...world.lessons,
  ];

  Act0LessonCardV1? _lessonForTaskId(String taskId) {
    for (final lesson in _allLessons()) {
      if (lesson.taskList.any((task) => task.taskId == taskId)) {
        return lesson;
      }
    }
    return null;
  }

  Act0LessonTaskV1? _taskForId(String taskId) {
    final lesson = _lessonForTaskId(taskId);
    if (lesson == null) {
      return null;
    }
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => lesson.taskList.first,
    );
  }

  String _categoryForLesson(String lessonId) {
    return switch (lessonId) {
      'what_poker_is' => 'Table',
      'cards_ranks_suits' => 'Cards',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Blinds',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Practice',
    };
  }

  Act0WorldCardV1 _progressWorld(
    Act0WorldCardV1 world,
    bool previousWorldComplete, {
    required bool isImmediateLockedWorld,
    Set<String>? completedTaskIds,
  }) {
    final progressTaskIds = completedTaskIds ?? _completedTaskIds;
    if (world.lessons.isEmpty) {
      return world.copyWith(
        status: previousWorldComplete
            ? Act0WorldStateV1.current
            : Act0WorldStateV1.locked,
        isSelectable: previousWorldComplete,
        isLocked: !previousWorldComplete,
      );
    }
    final allComplete = world.lessons.every(
      (lesson) => _lessonCompleteWithTaskIds(lesson, progressTaskIds),
    );
    final available = previousWorldComplete;
    final currentLessonId = available && !allComplete
        ? world.lessons
              .firstWhere(
                (lesson) =>
                    !_lessonCompleteWithTaskIds(lesson, progressTaskIds),
              )
              .lessonId
        : null;
    final lessons = [
      for (final lesson in world.lessons)
        _progressLesson(
          lesson,
          worldAvailable: available,
          currentLessonId: currentLessonId,
          completedTaskIds: progressTaskIds,
        ),
    ];
    final completedCount = lessons
        .where((lesson) => lesson.state == Act0LessonStateV1.completed)
        .length;
    final status = !available
        ? Act0WorldStateV1.locked
        : allComplete
        ? Act0WorldStateV1.completed
        : Act0WorldStateV1.current;
    return world.copyWith(
      status: status,
      progressLabel: !available
          ? act0LockedWorldProgressLabelV1(
              isImmediateNext: isImmediateLockedWorld,
            )
          : allComplete
          ? '${lessons.length} of ${lessons.length} lessons complete'
          : '$completedCount of ${lessons.length} lessons complete',
      primaryCtaLabel: !available
          ? act0LockedWorldPrimaryCtaLabelV1(
              isImmediateNext: isImmediateLockedWorld,
            )
          : allComplete
          ? 'Replay lessons'
          : 'Open lessons',
      unlockLabel: available ? 'Available now' : world.unlockLabel,
      isSelectable: available,
      isLocked: !available,
      lessons: lessons,
    );
  }

  Act0LessonCardV1 _progressLesson(
    Act0LessonCardV1 lesson, {
    required bool worldAvailable,
    required String? currentLessonId,
    Set<String>? completedTaskIds,
  }) {
    final completed = _lessonCompleteWithTaskIds(
      lesson,
      completedTaskIds ?? _completedTaskIds,
    );
    final current = lesson.lessonId == currentLessonId;
    final state = completed
        ? Act0LessonStateV1.completed
        : current
        ? Act0LessonStateV1.current
        : Act0LessonStateV1.locked;
    return lesson.copyWith(
      state: state,
      primaryCtaLabel: completed
          ? 'Replay'
          : current
          ? 'Start +${lesson.rewardXp} XP'
          : 'Locked',
      isSelectable: worldAvailable && (completed || current),
      isLocked: !worldAvailable || state == Act0LessonStateV1.locked,
    );
  }

  void _completeCurrentTask(Act0LessonTaskV1 selectedTask) {
    final alreadyCompleted = _completedTaskIds.contains(_selectedTaskId);
    _skippedTaskIds.remove(_selectedTaskId);
    _visibleSkippedTaskIds.remove(_selectedTaskId);
    _completedTaskIds.add(_selectedTaskId);
    if (!alreadyCompleted) {
      _earnedXp += selectedTask.rewardXp;
      _lessonRunXp += selectedTask.rewardXp;
    }
    final worlds = _progressWorlds(widget.state ?? Act0ShellStateV1.sample);
    final world = _worldById(worlds, _selectedWorldId);
    final lesson = _lessonById(world.lessons, _selectedLessonId);
    if (_lessonComplete(lesson)) {
      _completedLessonIds.add(lesson.lessonId);
    }
    _persistProgress();
  }

  bool _advanceTeachingStep(Act0RunnerStateV1 runner) {
    if (_teachingStepIndex < runner.teachingSteps.length) {
      _teachingStepIndex += 1;
      return true;
    }
    return false;
  }

  bool _maybeShowBlockCompletionSummary({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    if (widget.tableVisualVariant !=
        Act0ShellTableVisualVariantV1.refinedDev2) {
      return false;
    }
    if (_nextTask(selectedLesson, _selectedTaskId) != null) {
      return false;
    }
    final progressedWorlds = _progressWorlds(
      widget.state ?? Act0ShellStateV1.sample,
    );
    final progressedWorld = _worldById(progressedWorlds, selectedWorld.worldId);
    final nextLessonId = _nextLessonId(
      selectedWorld.lessons,
      selectedLesson.lessonId,
    );
    final nextWorld = _nextSelectableWorld(
      progressedWorlds,
      selectedWorld.worldId,
    );
    final isWorldComplete =
        nextLessonId == null &&
        progressedWorld.status == Act0WorldStateV1.completed;
    final lessonPerfectClearCount = _perfectTaskIds()
        .where(
          (taskId) =>
              selectedLesson.taskList.any((task) => task.taskId == taskId),
        )
        .length;
    final lessonOpenMistakeCount = _openMistakeCountForLessonV1(selectedLesson);
    final worldOpenMistakeCount = _openMistakeCountForWorldV1(progressedWorld);
    _blockCompletionSummary = Act0BlockCompletionSummaryV1(
      lessonTitle: _localizedLessonTitleV1(selectedLesson),
      xpEarned: _lessonRunXp,
      errorCount: _lessonRunMistakeTaskIds.length,
      taskCount: selectedLesson.taskList.length,
      correctCount:
          (selectedLesson.taskList.length - _lessonRunMistakeTaskIds.length)
              .clamp(0, selectedLesson.taskList.length),
      startLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).level,
      endLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).level,
      startXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).xp,
      endXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).xp,
      xpTarget: (widget.state ?? Act0ShellStateV1.sample).xpTarget,
      sharkyLine: selectedTask.runner.sharky.summaryLine,
      nextLessonTitle: nextLessonId == null
          ? null
          : act0LocalizedLessonTitleAtomByIdV1(
              nextLessonId,
              fallback: _lessonById(
                progressedWorld.lessons,
                nextLessonId,
              ).title,
              isRu: _isRuLocaleV1,
            ),
      quickFixCount: _lessonRunQuickFixTaskIds.length,
      deepLeakCount: _lessonRunDeepLeakTaskIds.length,
      skillGains: isWorldComplete
          ? _skillGainsFromMapV1(
              _aggregateSkillDeltasForWorldV1(progressedWorld),
              source: act0LocalizedWorldTitleV1(context, progressedWorld),
            )
          : _skillGainsFromMapV1(
              _lessonRunSkillGainCounts,
              source: _localizedLessonTitleV1(selectedLesson),
            ),
      milestoneTier: isWorldComplete
          ? Act0ProgressMilestoneTierV1.world
          : Act0ProgressMilestoneTierV1.lesson,
      worldNumber: progressedWorld.worldNumber,
      worldTitle: act0LocalizedWorldTitleV1(context, progressedWorld),
      nextWorldNumber: nextWorld?.worldNumber,
      nextWorldTitle: nextWorld == null
          ? null
          : act0LocalizedWorldTitleV1(context, nextWorld),
      perfectClearCount: isWorldComplete
          ? _perfectTaskCountForWorldV1(progressedWorld)
          : lessonPerfectClearCount,
      completedClearCount: isWorldComplete
          ? _completedTaskCountForWorldV1(progressedWorld)
          : selectedLesson.taskList.length,
      hasSafeReviewTarget: isWorldComplete
          ? worldOpenMistakeCount > 0
          : lessonOpenMistakeCount > 0,
      hasReplayForPerfectTarget:
          !isWorldComplete &&
          lessonOpenMistakeCount == 0 &&
          lessonPerfectClearCount < selectedLesson.taskList.length,
    );
    _fireBlockCompletionEffects(_blockCompletionSummary!);
    return true;
  }

  void _fireAnswerEffects(Act0RunnerOptionV1 option) {
    UiSoundV1.fire(
      option.isCorrect ? UiSoundEventV1.success : UiSoundEventV1.error,
    );
    unawaited(
      UiHapticsV1.fire(
        option.isCorrect ? UiHapticEventV1.success : UiHapticEventV1.error,
      ),
    );
  }

  void _fireBlockCompletionEffects(Act0BlockCompletionSummaryV1 summary) {
    if (!summary.qualifiesForNextLesson) {
      UiSoundV1.fire(UiSoundEventV1.error);
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      return;
    }
    UiSoundV1.fire(UiSoundEventV1.success);
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
  }

  void _resetLessonRunMetrics() {
    _lessonRunXp = 0;
    _lessonRunMistakeTaskIds.clear();
    _lessonRunPendingRetryTaskIds.clear();
    _lessonRunRetriedTaskIds.clear();
    _lessonRunWrapUpCompletedTaskIds.clear();
    _lessonRunQuickFixTaskIds.clear();
    _lessonRunDeepLeakTaskIds.clear();
    _lessonRunSkillGainCounts.clear();
    _activeLessonWrapUpTaskId = null;
    _lessonRunWrapUpAnchorTaskId = null;
    _blockCompletionSummary = null;
  }

  void _advanceAfterTask(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final nextTask = _nextTask(selectedLesson, _selectedTaskId);
    if (nextTask != null) {
      _selectedTaskId = nextTask.taskId;
      _phase = nextTask.phase;
      _tab = Act0ShellTabV1.play;
      _showPlayHub = false;
      _teachingStepIndex = 0;
      _persistProgress();
      return;
    }

    final progressedWorlds = _progressWorlds(
      widget.state ?? Act0ShellStateV1.sample,
    );
    var nextWorld = _worldById(progressedWorlds, selectedWorld.worldId);
    var nextLesson = _firstPlayableLesson(nextWorld);
    if (nextWorld.status == Act0WorldStateV1.completed) {
      final currentWorldIndex = progressedWorlds.indexWhere(
        (world) => world.worldId == selectedWorld.worldId,
      );
      final nextWorldIndex = currentWorldIndex + 1;
      if (nextWorldIndex < progressedWorlds.length &&
          progressedWorlds[nextWorldIndex].isSelectable) {
        nextWorld = progressedWorlds[nextWorldIndex];
        nextLesson = _firstPlayableLesson(nextWorld);
        _selectedWorldId = nextWorld.worldId;
      }
    }
    _selectedLessonId = nextLesson.lessonId;
    _selectedTaskId = _firstIncompleteTask(nextLesson).taskId;
    _phase = _taskById(nextLesson, _selectedTaskId).phase;
    _teachingStepIndex = 0;
    _tab = Act0ShellTabV1.learn;
    _learnDetailLessonId = null;
    _learnDetailWorldId = null;
    _showWorldMenu = false;
    _persistProgress();
  }

  void _normalizeSelection(List<Act0WorldCardV1> worlds) {
    final normalizedWorld = _worldById(worlds, _selectedWorldId);
    if (_selectedWorldId != normalizedWorld.worldId) {
      _selectedWorldId = normalizedWorld.worldId;
      if (_learnDetailWorldId != null &&
          _learnDetailWorldId != _selectedWorldId) {
        _learnDetailWorldId = null;
      }
    }

    final normalizedLesson =
        normalizedWorld.lessons.any(
          (lesson) => lesson.lessonId == _selectedLessonId,
        )
        ? _lessonById(normalizedWorld.lessons, _selectedLessonId)
        : _firstPlayableLesson(normalizedWorld);
    final lessonChanged = _selectedLessonId != normalizedLesson.lessonId;
    if (lessonChanged) {
      _selectedLessonId = normalizedLesson.lessonId;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
    }

    final taskExists = normalizedLesson.taskList.any(
      (task) => task.taskId == _selectedTaskId,
    );
    final normalizedTask = taskExists
        ? _taskById(normalizedLesson, _selectedTaskId)
        : _firstIncompleteTask(normalizedLesson);
    if (_selectedTaskId != normalizedTask.taskId) {
      _selectedTaskId = normalizedTask.taskId;
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      _phase = normalizedTask.phase;
    }

    final popupOwnerLesson =
        _learnDetailLessonId != null &&
            normalizedWorld.lessons.any(
              (lesson) => lesson.lessonId == _learnDetailLessonId,
            )
        ? _lessonById(normalizedWorld.lessons, _learnDetailLessonId!)
        : normalizedLesson;
    if (_learnPopupTaskId != null &&
        !popupOwnerLesson.taskList.any(
          (task) => task.taskId == _learnPopupTaskId,
        )) {
      _learnPopupTaskId = null;
    }
  }

  Act0WorldCardV1 _worldById(List<Act0WorldCardV1> worlds, String worldId) {
    return worlds.firstWhere(
      (world) => world.worldId == worldId,
      orElse: () => worlds.first,
    );
  }

  Act0LessonCardV1 _lessonById(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    return lessons.firstWhere(
      (lesson) => lesson.lessonId == lessonId,
      orElse: () => lessons.first,
    );
  }

  Act0LessonCardV1 _firstPlayableLesson(Act0WorldCardV1 world) {
    return world.lessons.firstWhere(
      (lesson) =>
          lesson.isSelectable && lesson.state == Act0LessonStateV1.current,
      orElse: () => world.lessons.firstWhere(
        (lesson) => lesson.isSelectable,
        orElse: () => world.lessons.first,
      ),
    );
  }

  Act0LessonTaskV1 _firstIncompleteTask(Act0LessonCardV1 lesson) {
    return _firstIncompleteTaskWithTaskIds(lesson, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _firstIncompleteTaskWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.firstWhere(
      (task) => !completedTaskIds.contains(task.taskId),
      orElse: () => lesson.taskList.first,
    );
  }

  bool _taskAvailable(Act0LessonCardV1 lesson, String taskId) {
    if (_completedTaskIds.contains(taskId)) {
      return true;
    }
    if (_skippedTaskIds.contains(taskId)) {
      return true;
    }
    return _firstIncompleteTask(lesson).taskId == taskId;
  }

  Act0LessonTaskV1 _taskById(Act0LessonCardV1 lesson, String taskId) {
    return _taskByIdWithTaskIds(lesson, taskId, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _taskByIdWithTaskIds(
    Act0LessonCardV1 lesson,
    String taskId,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => _firstIncompleteTaskWithTaskIds(lesson, completedTaskIds),
    );
  }

  int _taskIndex(Act0LessonCardV1 lesson, String taskId) {
    final index = lesson.taskList.indexWhere((task) => task.taskId == taskId);
    return index < 0 ? 0 : index;
  }

  Act0LessonTaskV1? _nextTask(Act0LessonCardV1 lesson, String taskId) {
    final index = _taskIndex(lesson, taskId);
    if (index < 0 || index + 1 >= lesson.taskList.length) {
      return null;
    }
    return lesson.taskList[index + 1];
  }

  bool _lessonComplete(Act0LessonCardV1 lesson) {
    return _lessonCompleteWithTaskIds(lesson, _completedTaskIds);
  }

  bool _lessonCompleteWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.every(
      (task) => completedTaskIds.contains(task.taskId),
    );
  }

  int _lessonIndex(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = lessons.indexWhere((lesson) => lesson.lessonId == lessonId);
    return index < 0 ? 0 : index;
  }

  String? _nextLessonId(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = _lessonIndex(lessons, lessonId);
    if (index < 0 || index + 1 >= lessons.length) {
      return null;
    }
    return lessons[index + 1].lessonId;
  }

  Act0WorldCardV1? _nextSelectableWorld(
    List<Act0WorldCardV1> worlds,
    String worldId,
  ) {
    final currentIndex = worlds.indexWhere((world) => world.worldId == worldId);
    if (currentIndex < 0) {
      return null;
    }
    for (var index = currentIndex + 1; index < worlds.length; index++) {
      final world = worlds[index];
      if (world.isSelectable) {
        return world;
      }
    }
    return null;
  }

  _Act0ProgressSnapshotV1 _progressSnapshot(
    Act0ShellStateV1 state, {
    int? earnedXpDelta,
  }) {
    final xpTarget = state.xpTarget <= 0 ? 1 : state.xpTarget;
    final baseLevel = _parseLevelNumber(state.levelLabel);
    final totalXp = state.xp + (earnedXpDelta ?? _earnedXp);
    return _Act0ProgressSnapshotV1(
      level: baseLevel + (totalXp ~/ xpTarget),
      xp: totalXp % xpTarget,
    );
  }

  int _parseLevelNumber(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  Act0ShellStateV1 _stateWithProgress(
    Act0ShellStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final levelLabel = 'Level ${progress.level}';
    return Act0ShellStateV1(
      courseTitle: base.courseTitle,
      courseSubtitle: base.courseSubtitle,
      levelLabel: levelLabel,
      xp: progress.xp,
      xpTarget: base.xpTarget,
      streakDays: _effectiveStreakDays(base),
      dailyGoalLabel: base.dailyGoalLabel,
      dailyGoalValue: base.dailyGoalValue,
      pathProgressLabel: base.pathProgressLabel,
      selectedWorldId: base.selectedWorldId,
      worlds: base.worlds,
      lessons: base.lessons,
      review: base.review,
      profile: Act0ProfileStateV1(
        playerName: base.profile.playerName,
        level: levelLabel,
        xpLine: '${progress.xp} / ${base.xpTarget} XP',
        lessonsLine: base.profile.lessonsLine,
        accuracyLine: base.profile.accuracyLine,
        qualityLine: base.profile.qualityLine,
        streakLine: base.profile.streakLine,
        streakDays: base.profile.streakDays,
        consistencyActiveDays: base.profile.consistencyActiveDays,
        achievements: base.profile.achievements,
        strongCategories: base.profile.strongCategories,
        weakCategories: base.profile.weakCategories,
        recentProgress: base.profile.recentProgress,
        recentSkillGains: base.profile.recentSkillGains,
        skillStats: base.profile.skillStats,
        streakLast7: base.profile.streakLast7,
        recommendedFocusTitle: base.profile.recommendedFocusTitle,
        recommendedFocusBody: base.profile.recommendedFocusBody,
        recommendedFocusCtaLabel: base.profile.recommendedFocusCtaLabel,
        worldsClearedCount: base.profile.worldsClearedCount,
        worldsActiveCount: base.profile.worldsActiveCount,
        totalWorldsCount: base.profile.totalWorldsCount,
        mistakesFixedLine: base.profile.mistakesFixedLine,
      ),
    );
  }

  int _effectiveStreakDays(Act0ShellStateV1 base) {
    if (_persistedStreakDays > 0) {
      // Persisted streak is source of truth once the user has prior data
      final today = _todayDateString();
      if (_dailyCompletedRepCount >= 3 && _lastDailyDate != today) {
        return (_persistedStreakDays + 1).clamp(0, 365);
      }
      return _persistedStreakDays;
    }
    // Fall back to state-provided streak (preview / no-prefs mode)
    return _dailyCompletedRepCount >= 3
        ? (base.streakDays + 1).clamp(0, 365)
        : base.streakDays;
  }
}

class _Act0ProgressSnapshotV1 {
  const _Act0ProgressSnapshotV1({required this.level, required this.xp});

  final int level;
  final int xp;
}

class _Act0DailyDeckEntryV1 {
  const _Act0DailyDeckEntryV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.isSpaced,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final bool isSpaced;
}

class _Act0PracticeLaunchTargetV1 {
  const _Act0PracticeLaunchTargetV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
}

class _Act0TopicPackSpecV1 {
  const _Act0TopicPackSpecV1({
    required this.groupId,
    required this.lessonId,
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.sessionLabel,
    required this.durationLabel,
  });

  final String groupId;
  final String lessonId;
  final String taskId;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final String sessionLabel;
  final String durationLabel;
}

const _taskSkillDeltasV1 = <String, Map<String, int>>{
  'what_poker_is_table_read_transfer': <String, int>{
    'Table sense': 4,
    'Board reading': 1,
  },
  'cards_ranks_suits_private_board': <String, int>{
    'Board reading': 3,
    'Hand reading': 2,
  },
  'your_first_hand_action_trail': <String, int>{
    'Table sense': 2,
    'Board reading': 2,
    'Betting decisions': 1,
  },
  'actions_legal_context': <String, int>{
    'Betting decisions': 4,
    'Table sense': 1,
  },
  'blinds_first_actor': <String, int>{'Blind play': 4, 'Table sense': 2},
  'positions_early_late': <String, int>{'Position play': 4, 'Table sense': 2},
  'hand_rankings_best_five_drill': <String, int>{
    'Hand reading': 3,
    'Board reading': 2,
  },
  'showdown_best_hand_drill': <String, int>{
    'Hand reading': 3,
    'Board reading': 2,
  },
};

const _topicPackSpecsV1 = <_Act0TopicPackSpecV1>[
  _Act0TopicPackSpecV1(
    groupId: 'actions',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    title: 'Actions',
    subtitle: 'Read the price and choose the legal action fast.',
    categoryLabel: 'Action',
    sessionLabel: 'Action drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'blinds',
    lessonId: 'blinds_action_order',
    taskId: 'blinds_first_actor',
    title: 'Blinds',
    subtitle: 'Track the blinds and who acts first preflop.',
    categoryLabel: 'Preflop',
    sessionLabel: 'Blind drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'positions',
    lessonId: 'positions',
    taskId: 'positions_early_late',
    title: 'Positions',
    subtitle: 'Separate early seats from late seats at a glance.',
    categoryLabel: 'Seats',
    sessionLabel: 'Seat drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'streets',
    lessonId: 'your_first_hand',
    taskId: 'your_first_hand_action_trail',
    title: 'Streets',
    subtitle: 'Follow the hand in order instead of losing the street.',
    categoryLabel: 'Hand flow',
    sessionLabel: 'Street drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'rankings',
    lessonId: 'hand_rankings_table',
    taskId: 'hand_rankings_best_five_drill',
    title: 'Hand rankings',
    subtitle: 'Choose the best five cards on a real board.',
    categoryLabel: 'Cards',
    sessionLabel: 'Card drill',
    durationLabel: '~2 min',
  ),
  _Act0TopicPackSpecV1(
    groupId: 'showdown',
    lessonId: 'showdown_winning',
    taskId: 'showdown_best_hand_drill',
    title: 'Showdown',
    subtitle: 'Compare the final hands and settle the pot cleanly.',
    categoryLabel: 'Winning',
    sessionLabel: 'Finish drill',
    durationLabel: '~2 min',
  ),
];

class _Act0PlacementSkipPlanV1 {
  const _Act0PlacementSkipPlanV1({
    required this.taskIds,
    required this.orderedTaskIds,
  });

  final Set<String> taskIds;
  final List<String> orderedTaskIds;
}

class _Act0PersistedProgressV1 {
  const _Act0PersistedProgressV1({
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.completedLessonIds,
    required this.selectedWorldId,
    required this.selectedLessonId,
    required this.selectedTaskId,
    required this.earnedXp,
    this.profileSkillValues = const <String, int>{},
    this.recentSkillGains = const <Act0SkillGainV1>[],
    this.lastActiveDay = '',
    this.dailyCompletedRepCount = 0,
    this.persistedStreakDays = 0,
    this.resumeInRunner = false,
    this.resumePhase = '',
    this.resumeTeachingStepIndex = 0,
    this.resumeSelectedOptionId,
    this.dismissedHomeHandoffKey = '',
    this.dismissedHomeHandoffDay = '',
  });

  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> completedLessonIds;
  final String selectedWorldId;
  final String selectedLessonId;
  final String selectedTaskId;
  final int earnedXp;
  final Map<String, int> profileSkillValues;
  final List<Act0SkillGainV1> recentSkillGains;
  final String lastActiveDay;
  final int dailyCompletedRepCount;
  final int persistedStreakDays;
  final bool resumeInRunner;
  final String resumePhase;
  final int resumeTeachingStepIndex;
  final String? resumeSelectedOptionId;
  final String dismissedHomeHandoffKey;
  final String dismissedHomeHandoffDay;

  String toStorageString() {
    final sortedTaskIds = completedTaskIds.toList(growable: false)..sort();
    final sortedSkippedTaskIds = skippedTaskIds.toList(growable: false)..sort();
    final sortedLessonIds = completedLessonIds.toList(growable: false)..sort();
    final sortedSkillKeys = profileSkillValues.keys.toList(growable: false)
      ..sort();
    return jsonEncode(<String, Object>{
      'schemaVersion': 7,
      'completedTaskIds': sortedTaskIds,
      'skippedTaskIds': sortedSkippedTaskIds,
      'completedLessonIds': sortedLessonIds,
      'selectedWorldId': selectedWorldId,
      'selectedLessonId': selectedLessonId,
      'selectedTaskId': selectedTaskId,
      'earnedXp': earnedXp,
      'profileSkillValues': <String, int>{
        for (final key in sortedSkillKeys) key: profileSkillValues[key]!,
      },
      'recentSkillGains': <Map<String, Object>>[
        for (final gain in recentSkillGains.take(6))
          <String, Object>{
            'label': gain.label,
            'gain': gain.gain,
            'source': gain.source,
          },
      ],
      'lastActiveDay': lastActiveDay,
      'dailyCompletedRepCount': dailyCompletedRepCount,
      'persistedStreakDays': persistedStreakDays,
      'resumeInRunner': resumeInRunner,
      'resumePhase': resumePhase,
      'resumeTeachingStepIndex': resumeTeachingStepIndex,
      'dismissedHomeHandoffKey': dismissedHomeHandoffKey,
      'dismissedHomeHandoffDay': dismissedHomeHandoffDay,
      if (resumeSelectedOptionId != null)
        'resumeSelectedOptionId': resumeSelectedOptionId!,
    });
  }

  static _Act0PersistedProgressV1? tryParse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) {
      return null;
    }
    final map = decoded.cast<String, Object?>();
    final schemaVersion = map['schemaVersion'];
    // Accept v1-v7 as the shell snapshot evolves.
    if (schemaVersion != 1 &&
        schemaVersion != 2 &&
        schemaVersion != 3 &&
        schemaVersion != 4 &&
        schemaVersion != 5 &&
        schemaVersion != 6 &&
        schemaVersion != 7) {
      return null;
    }
    final completedTaskIds = _stringSet(map['completedTaskIds']);
    final skippedTaskIds = _stringSet(map['skippedTaskIds']);
    final completedLessonIds = _stringSet(map['completedLessonIds']);
    final selectedWorldId = (map['selectedWorldId'] ?? '').toString();
    final selectedLessonId = (map['selectedLessonId'] ?? '').toString();
    final selectedTaskId = (map['selectedTaskId'] ?? '').toString();
    final earnedXpRaw = map['earnedXp'];
    final earnedXp = earnedXpRaw is int
        ? earnedXpRaw
        : int.tryParse(earnedXpRaw?.toString() ?? '') ?? 0;
    final profileSkillValues = _intMap(map['profileSkillValues']);
    final recentSkillGains = _skillGainList(map['recentSkillGains']);
    // v2 fields — gracefully default for v1 records
    final lastActiveDay = (map['lastActiveDay'] ?? '').toString();
    final dailyCompletedRepCountRaw = map['dailyCompletedRepCount'];
    final dailyCompletedRepCount = dailyCompletedRepCountRaw is int
        ? dailyCompletedRepCountRaw
        : int.tryParse(dailyCompletedRepCountRaw?.toString() ?? '') ??
              completedTaskIds.length.clamp(0, 3);
    final streakRaw = map['persistedStreakDays'];
    final persistedStreakDays = streakRaw is int
        ? streakRaw
        : int.tryParse(streakRaw?.toString() ?? '') ?? 0;
    final resumeInRunner = map['resumeInRunner'] == true;
    final resumePhase = (map['resumePhase'] ?? '').toString();
    final resumeTeachingStepRaw = map['resumeTeachingStepIndex'];
    final resumeTeachingStepIndex = resumeTeachingStepRaw is int
        ? resumeTeachingStepRaw
        : int.tryParse(resumeTeachingStepRaw?.toString() ?? '') ?? 0;
    final resumeSelectedOptionIdRaw = map['resumeSelectedOptionId'];
    final resumeSelectedOptionId = resumeSelectedOptionIdRaw == null
        ? null
        : resumeSelectedOptionIdRaw.toString();
    final dismissedHomeHandoffKey = (map['dismissedHomeHandoffKey'] ?? '')
        .toString();
    final dismissedHomeHandoffDay = (map['dismissedHomeHandoffDay'] ?? '')
        .toString();
    if (selectedWorldId.isEmpty ||
        selectedLessonId.isEmpty ||
        selectedTaskId.isEmpty) {
      return null;
    }
    return _Act0PersistedProgressV1(
      completedTaskIds: completedTaskIds,
      skippedTaskIds: skippedTaskIds,
      completedLessonIds: completedLessonIds,
      selectedWorldId: selectedWorldId,
      selectedLessonId: selectedLessonId,
      selectedTaskId: selectedTaskId,
      earnedXp: earnedXp < 0 ? 0 : earnedXp,
      profileSkillValues: profileSkillValues,
      recentSkillGains: recentSkillGains,
      lastActiveDay: lastActiveDay,
      dailyCompletedRepCount: dailyCompletedRepCount.clamp(0, 3),
      persistedStreakDays: persistedStreakDays < 0 ? 0 : persistedStreakDays,
      resumeInRunner: resumeInRunner,
      resumePhase: resumePhase,
      resumeTeachingStepIndex: resumeTeachingStepIndex < 0
          ? 0
          : resumeTeachingStepIndex,
      resumeSelectedOptionId: resumeSelectedOptionId,
      dismissedHomeHandoffKey: dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: dismissedHomeHandoffDay,
    );
  }

  static Set<String> _stringSet(Object? raw) {
    if (raw is! List) {
      return <String>{};
    }
    return raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static Map<String, int> _intMap(Object? raw) {
    if (raw is! Map) {
      return <String, int>{};
    }
    final map = <String, int>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;
      final value = entry.value;
      final parsed = value is int
          ? value
          : int.tryParse(value?.toString() ?? '');
      if (parsed == null || parsed < 0) continue;
      map[key] = parsed;
    }
    return map;
  }

  static List<Act0SkillGainV1> _skillGainList(Object? raw) {
    if (raw is! List) {
      return const <Act0SkillGainV1>[];
    }
    final gains = <Act0SkillGainV1>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final label = (item['label'] ?? '').toString().trim();
      final source = (item['source'] ?? '').toString().trim();
      final gainRaw = item['gain'];
      final gain = gainRaw is int
          ? gainRaw
          : int.tryParse(gainRaw?.toString() ?? '');
      if (label.isEmpty || source.isEmpty || gain == null || gain <= 0) {
        continue;
      }
      gains.add(Act0SkillGainV1(label: label, gain: gain, source: source));
    }
    return gains;
  }
}

class _Act0MistakeRecordV1 {
  const _Act0MistakeRecordV1({
    required this.taskId,
    required this.lessonId,
    required this.worldId,
    required this.title,
    required this.weaknessLabel,
    required this.selectedOptionId,
    required this.selectedLabel,
    required this.betterLabel,
    required this.reason,
    required this.contextLabels,
    required this.repairActionLabel,
    required this.attempts,
  });

  final String taskId;
  final String lessonId;
  final String worldId;
  final String title;
  final String weaknessLabel;
  final String selectedOptionId;
  final String selectedLabel;
  final String betterLabel;
  final String reason;
  final List<String> contextLabels;
  final String repairActionLabel;
  final int attempts;

  Act0MistakeCardV1 toCard({
    bool resolved = false,
    Act0CompletionDisplayStateV1? completionState,
    String qualityLine = '',
  }) {
    return Act0MistakeCardV1(
      taskId: taskId,
      lessonId: lessonId,
      worldId: worldId,
      title: title,
      weaknessLabel: weaknessLabel,
      selectedOptionId: selectedOptionId,
      selectedLabel: selectedLabel,
      betterLabel: betterLabel,
      reason: reason,
      attempts: attempts,
      severityLabel: resolved
          ? attempts <= 1
                ? 'Quick fix'
                : 'Clear'
          : attempts >= 2
          ? 'Deep leak'
          : 'Needs repair',
      contextLabels: contextLabels,
      repairActionLabel: repairActionLabel,
      resolved: resolved,
      completionState: completionState,
      qualityLine: qualityLine,
    );
  }
}

class _TopBarV1 extends StatelessWidget {
  const _TopBarV1({required this.state, required this.goalLabel});

  final Act0ShellStateV1 state;
  final String goalLabel;

  @override
  Widget build(BuildContext context) {
    final streakTone = state.streakDays > 0
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.textDim;
    return Container(
      key: const Key('act0_shell_top_bar'),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: Act0ShellTokensV1.pageX),
      decoration: Act0ShellTokensV1.glassDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goalLabel,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapSm),
                    Text(
                      '${state.xp} XP',
                      style: Act0ShellTokensV1.muted.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  child: LinearProgressIndicator(
                    minHeight: Act0ShellTokensV1.progressHeight,
                    value: state.xpProgress,
                    backgroundColor: Act0ShellTokensV1.surface3,
                    color: Act0ShellTokensV1.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: streakTone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(color: streakTone.withValues(alpha: 0.28)),
            ),
            child: Text(
              '${state.streakDays}d',
              style: Act0ShellTokensV1.muted.copyWith(
                color: streakTone,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavV1 extends StatelessWidget {
  const _BottomNavV1({
    required this.current,
    required this.onSelected,
    this.reviewHasDot = false,
  });

  final Act0ShellTabV1 current;
  final ValueChanged<Act0ShellTabV1> onSelected;
  final bool reviewHasDot;

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ru');
    return SizedBox(
      key: const Key('act0_shell_bottom_nav'),
      height: Act0ShellTokensV1.bottomNavHeight,
      child: DecoratedBox(
        decoration: Act0ShellTokensV1.glassDecoration(top: true),
        child: Row(
          children: [
            _NavItemV1(
              tab: Act0ShellTabV1.home,
              current: current,
              icon: Icons.home_rounded,
              label: isRu ? 'Главная' : 'Home',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.learn,
              current: current,
              icon: Icons.menu_book_rounded,
              label: isRu ? 'Обучение' : 'Learn',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.play,
              current: current,
              icon: Icons.spa_rounded,
              label: isRu ? 'Практика' : 'Practice',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.review,
              current: current,
              icon: Icons.refresh_rounded,
              label: isRu ? 'Разбор' : 'Review',
              showDot: reviewHasDot,
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.profile,
              current: current,
              icon: Icons.person_rounded,
              label: isRu ? 'Ты' : 'You',
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemV1 extends StatelessWidget {
  const _NavItemV1({
    required this.tab,
    required this.current,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.showDot = false,
  });

  final Act0ShellTabV1 tab;
  final Act0ShellTabV1 current;
  final IconData icon;
  final String label;
  final ValueChanged<Act0ShellTabV1> onSelected;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final color = selected
        ? Act0ShellTokensV1.primary
        : Act0ShellTokensV1.textMuted;
    final hasBadge = showDot;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(tab),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 21, color: color),
                  if (hasBadge)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: Container(
                        key: Key(
                          'act0_shell_nav_badge_${_navItemKeyLabelV1(tab)}',
                        ),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.gold,
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.surface,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _navItemKeyLabelV1(Act0ShellTabV1 tab) {
  return switch (tab) {
    Act0ShellTabV1.home => 'home',
    Act0ShellTabV1.learn => 'learn',
    Act0ShellTabV1.play => 'play',
    Act0ShellTabV1.review => 'review',
    Act0ShellTabV1.profile => 'profile',
  };
}

const _placementQuestionsV1 = <Act0PlacementQuestionV1>[
  Act0PlacementQuestionV1(
    questionId: 'experience',
    eyebrow: 'Starting point',
    title: 'Where are you starting from?',
    subtitle: 'Be honest. This only changes where Sharky should begin.',
    helper:
        'The goal is not to rank you. The goal is to avoid wasting your first sessions.',
    icon: Icons.flag_rounded,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'new',
        label: 'I have not really played yet',
        score: 0,
        profileTag: 'New',
        subtitle: 'Start from zero and build the table language cleanly.',
        icon: Icons.school_rounded,
        badge: 'Best for zero',
      ),
      Act0PlacementOptionV1(
        optionId: 'friends',
        label: 'I played casually, mostly guessing with friends',
        score: 1,
        profileTag: 'Casual',
        subtitle:
            'You know some words, but the structure still needs tightening.',
        icon: Icons.groups_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'watching',
        label: 'I watch poker content, but real decisions still freeze me',
        score: 1,
        profileTag: 'Watching',
        subtitle:
            'Translate passive knowledge into something usable at the table.',
        icon: Icons.live_tv_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'online',
        label: 'I have played online or live and want sharper structure',
        score: 3,
        profileTag: 'Played',
        subtitle:
            'Skip part of the intro and move faster into action language.',
        icon: Icons.insights_rounded,
        badge: 'Faster start',
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'format',
    eyebrow: 'Your use case',
    title: 'What do you want poker for?',
    subtitle:
        'This shapes examples, language, and the kind of situations Sharky shows first.',
    helper:
        'Choose everything that feels true right now. Sharky will look for the dominant pattern, not force a single lane.',
    icon: Icons.route_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'basics',
        label: 'I want the game to finally make sense',
        score: 0,
        profileTag: 'Basics',
        subtitle: 'Start with table literacy before strategy words and jargon.',
        icon: Icons.menu_book_rounded,
        badge: 'Core',
      ),
      Act0PlacementOptionV1(
        optionId: 'cash',
        label: 'I want to feel confident in cash-game spots',
        score: 2,
        profileTag: 'Cash',
        subtitle:
            'Bias examples toward chips, pressure, and practical decisions.',
        icon: Icons.attach_money_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'tournaments',
        label: 'I care more about tournament decisions',
        score: 2,
        profileTag: 'Tournament',
        subtitle:
            'Bias examples toward survival, pressure, and changing leverage.',
        icon: Icons.emoji_events_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'home_games',
        label: 'I do not want to feel lost in home games',
        score: 1,
        profileTag: 'HomeGames',
        subtitle:
            'Focus on hand flow, confidence, and keeping up with the table.',
        icon: Icons.table_restaurant_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'content',
        label: 'I want poker videos and hand talk to stop sounding cryptic',
        score: 1,
        profileTag: 'Content',
        subtitle:
            'Use examples that decode table language instead of assuming it.',
        icon: Icons.subscriptions_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'confidence',
    eyebrow: 'Where to help first',
    title: 'What feels most confusing?',
    subtitle: 'Pick every part that makes you hesitate or guess.',
    helper:
        'Sharky will use this to bias your first explanations, review hints, and early repair spots.',
    icon: Icons.lightbulb_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'rules',
        label: 'Knowing whose turn it is and how a hand even moves',
        score: 0,
        profileTag: 'Rules',
        subtitle:
            'You want the table flow, blinds, and action order to stop feeling fuzzy.',
        icon: Icons.account_tree_rounded,
        badge: 'Foundation',
      ),
      Act0PlacementOptionV1(
        optionId: 'cards',
        label: 'Reading cards, pairs, and hand strength fast enough',
        score: 1,
        profileTag: 'Cards',
        subtitle:
            'You want stronger recognition and more confidence at showdown.',
        icon: Icons.style_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'decisions',
        label: 'Knowing when to fold, call, or raise without second-guessing',
        score: 2,
        profileTag: 'Decisions',
        subtitle:
            'You mostly want help making the right action at the right time.',
        icon: Icons.touch_app_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'board',
        label: 'Seeing what changed on the flop, turn, or river',
        score: 1,
        profileTag: 'Board',
        subtitle: 'You want the board to feel readable instead of noisy.',
        icon: Icons.view_module_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'pressure',
        label: 'Staying clear when people bet and pressure starts building',
        score: 2,
        profileTag: 'Pressure',
        subtitle:
            'You want calmer decisions when the table stops feeling passive.',
        icon: Icons.local_fire_department_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'goal',
    eyebrow: 'Coaching style',
    title: 'How should Sharky coach you?',
    subtitle: 'Choose the style that would keep you coming back.',
    helper:
        'Choose everything that sounds motivating. Sharky should feel like the right kind of pressure, not the wrong kind.',
    icon: Icons.favorite_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'guided',
        label: 'Keep me calm and guided at the start',
        score: 0,
        profileTag: 'Guided',
        subtitle:
            'Short explanations first, then gentle practice that makes sense.',
        icon: Icons.explore_rounded,
        badge: 'Calm start',
      ),
      Act0PlacementOptionV1(
        optionId: 'practice',
        label: 'Let me learn mostly by doing',
        score: 1,
        profileTag: 'Practice',
        subtitle: 'Less talking, more repetition once the concept is visible.',
        icon: Icons.fitness_center_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'diagnose',
        label: 'Show me quickly where I leak',
        score: 2,
        profileTag: 'Diagnostic',
        subtitle: 'Surface weak spots quickly and keep repair close by.',
        icon: Icons.search_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'daily_plan',
        label: 'Give me a short plan I can actually stick to',
        score: 1,
        profileTag: 'DailyPlan',
        subtitle: 'A compact habit loop with one clear next step each day.',
        icon: Icons.today_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'honest',
        label: 'Be direct with me when I am guessing',
        score: 1,
        profileTag: 'Direct',
        subtitle: 'More clarity and sharper feedback, without turning harsh.',
        icon: Icons.record_voice_over_rounded,
      ),
    ],
  ),
];

class _Act0PlacementDiagnosticSpotV1 {
  const _Act0PlacementDiagnosticSpotV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.signalId,
    this.isFoundation = false,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final String signalId;
  final bool isFoundation;
}

const _placementDiagnosticSpotsV1 = <_Act0PlacementDiagnosticSpotV1>[
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'what_poker_is',
    taskId: 'what_poker_is_table_read_transfer',
    signalId: 'table_read',
    isFoundation: true,
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'cards_ranks_suits',
    taskId: 'cards_ranks_suits_private_board',
    signalId: 'board_read',
    isFoundation: true,
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'blinds_action_order',
    taskId: 'blinds_first_actor',
    signalId: 'action_order',
    isFoundation: true,
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    signalId: 'action_menu',
  ),
  _Act0PlacementDiagnosticSpotV1(
    worldId: 'world_1',
    lessonId: 'positions',
    taskId: 'positions_early_late',
    signalId: 'position_pressure',
  ),
];

// fromBeatV1 later: map BeatV1.caption/hint/options/feedback/table adapter
// into Act0RunnerStateV1, then replace Act0ShellStateV1.sample at the preview
// boundary without changing production Today, Map, Runner, or Result routes.
