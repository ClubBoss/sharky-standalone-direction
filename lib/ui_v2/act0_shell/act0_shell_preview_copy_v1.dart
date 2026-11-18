part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewCopyV1 on _Act0ShellPreviewScreenV1State {
  String _copyV1({required String en, required String ru}) =>
      _isRuLocaleV1 ? ru : en;

  String _localizedLessonTitleV1(Act0LessonCardV1 lesson) =>
      act0AcademyLessonTitleV1(context, lesson);

  String _localizedLessonSubtitleV1(Act0LessonCardV1 lesson) =>
      act0AcademyLessonSubtitleV1(context, lesson);

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
          'Следующий шаг останется безопасным для новичка.',
        Act0PlacementResultLevelV1.rustyBeginner =>
          'Сначала удержим движение раздачи видимым, а скорость добавим позже.',
        Act0PlacementResultLevelV1.newPlayer =>
          'Начнем со стола, чтобы первая раздача оставалась понятной.',
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

  String _localizedPlacementRecommendedTitleV1(String title) =>
      act0LocalizedLessonTitleAtomV1(title, isRu: true);

  String _localizedPlacementSkillLabelV1(String label) =>
      _localizedPlacementAtomV1(label);
}
