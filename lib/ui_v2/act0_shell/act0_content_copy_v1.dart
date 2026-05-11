import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

class Act0WorldDisplayCopyV1 {
  const Act0WorldDisplayCopyV1({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0LessonDisplayCopyV1 {
  const Act0LessonDisplayCopyV1({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0TaskDisplayCopyV1 {
  const Act0TaskDisplayCopyV1({
    this.title,
    this.summary,
    this.lockedSummary,
    this.runnerPrompt,
    this.runnerSupport,
  });

  final String? title;
  final String? summary;
  final String? lockedSummary;
  final String? runnerPrompt;
  final String? runnerSupport;
}

class Act0SurfaceAtomCopyV1 {
  const Act0SurfaceAtomCopyV1({required this.text});

  final String text;
}

bool act0IsRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String act0LocalizedSurfaceAtomV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomByIdV1(
  atomId,
  fallback: fallback,
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedWorldTitleV1(BuildContext context, Act0WorldCardV1 world) =>
    act0LocalizedWorldTitleAtomV1(
      world.worldId,
      fallback: world.title,
      isRu: act0IsRuLocaleV1(context),
    );

String act0LocalizedWorldSubtitleV1(
  BuildContext context,
  Act0WorldCardV1 world,
) => act0LocalizedWorldSubtitleAtomV1(
  world.worldId,
  fallback: world.subtitle,
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedLessonTitleV1(
  BuildContext context,
  Act0LessonCardV1 lesson,
) => act0LocalizedLessonTitleAtomByIdV1(
  lesson.lessonId,
  fallback: lesson.title,
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedLessonSubtitleV1(
  BuildContext context,
  Act0LessonCardV1 lesson,
) => act0LocalizedLessonSubtitleAtomByIdV1(
  lesson.lessonId,
  fallback: lesson.subtitle,
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedWorldTitleAtomV1(
  String worldId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruWorldCopyByIdV1[worldId]?.title ?? fallback;
}

String act0LocalizedWorldSubtitleAtomV1(
  String worldId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruWorldCopyByIdV1[worldId]?.subtitle ?? fallback;
}

String act0LocalizedLessonTitleAtomByIdV1(
  String lessonId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruLessonCopyByIdV1[lessonId]?.title ?? fallback;
}

String act0LocalizedLessonSubtitleAtomByIdV1(
  String lessonId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruLessonCopyByIdV1[lessonId]?.subtitle ?? fallback;
}

String act0LocalizedLessonTitleAtomV1(String fallback, {required bool isRu}) {
  if (!isRu) {
    return fallback;
  }
  return _ruLessonTitleByEnglishV1[fallback] ?? fallback;
}

String act0LocalizedTaskTitleV1(BuildContext context, Act0LessonTaskV1 task) =>
    act0LocalizedTaskTitleAtomByIdV1(
      task.taskId,
      fallback: task.title,
      isRu: act0IsRuLocaleV1(context),
    );

String act0LocalizedTaskSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.summary ?? '',
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedTaskLockedSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskLockedSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.lockedSummary ?? '',
  isRu: act0IsRuLocaleV1(context),
);

String act0LocalizedTaskTitleAtomByIdV1(
  String taskId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruTaskCopyByIdV1[taskId]?.title ?? fallback;
}

String act0LocalizedTaskSummaryAtomByIdV1(
  String taskId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruTaskCopyByIdV1[taskId]?.summary ?? fallback;
}

String act0LocalizedTaskLockedSummaryAtomByIdV1(
  String taskId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruTaskCopyByIdV1[taskId]?.lockedSummary ?? fallback;
}

String act0LocalizedRunnerPromptAtomByTaskIdV1(
  String? taskId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu || taskId == null) {
    return fallback;
  }
  return _ruTaskCopyByIdV1[taskId]?.runnerPrompt ?? fallback;
}

String act0LocalizedRunnerSupportAtomByTaskIdV1(
  String? taskId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu || taskId == null) {
    return fallback;
  }
  return _ruTaskCopyByIdV1[taskId]?.runnerSupport ?? fallback;
}

String act0LocalizedSurfaceAtomByIdV1(
  String atomId, {
  required String fallback,
  required bool isRu,
}) {
  if (!isRu) {
    return fallback;
  }
  return _ruSurfaceAtomCopyByIdV1[atomId]?.text ?? fallback;
}

const Map<String, Act0WorldDisplayCopyV1>
_ruWorldCopyByIdV1 = <String, Act0WorldDisplayCopyV1>{
  'world_1': Act0WorldDisplayCopyV1(
    title: 'Покер с нуля',
    subtitle: 'Грамотность за столом: карты, места, блайнды, стек и банк.',
  ),
  'world_2': Act0WorldDisplayCopyV1(
    title: 'Дисциплина рук',
    subtitle: 'Пойми, какие руки стоят фишек, а какие спокойно уходят в пас.',
  ),
  'world_3': Act0WorldDisplayCopyV1(
    title: 'Мышление позицией',
    subtitle: 'Почувствуй, почему порядок мест меняет силу руки и комфорт.',
  ),
  'world_4': Act0WorldDisplayCopyV1(
    title: 'Префлоп-каркас',
    subtitle: 'Смотри на руку, место и действие до того, как выбирать линию.',
  ),
  'world_5': Act0WorldDisplayCopyV1(
    title: 'Смысл ставки и цена',
    subtitle: 'Пойми вэлью, блеф, защиту и цену колла без перегруза.',
  ),
  'world_6': Act0WorldDisplayCopyV1(
    title: 'Борд и дро',
    subtitle: 'Читай текстуру борда, дро и то, как улицы меняют план.',
  ),
  'world_7': Act0WorldDisplayCopyV1(
    title: 'Диапазоны без перегруза',
    subtitle: 'Группируй руки в простые диапазоны без солверного шума.',
  ),
  'world_8': Act0WorldDisplayCopyV1(
    title: 'Глубина стека и риск',
    subtitle: 'Пойми, почему 100 BB и 20 BB требуют разного мышления.',
  ),
  'world_9': Act0WorldDisplayCopyV1(
    title: 'Турнирное давление',
    subtitle: 'Почувствуй давление выживания и риска без формул.',
  ),
  'world_10': Act0WorldDisplayCopyV1(
    title: 'Подстройка под игроков',
    subtitle: 'Меняй один рычаг за раз против реальных типов игроков.',
  ),
  'world_11': Act0WorldDisplayCopyV1(
    title: 'Перенос в реальную игру',
    subtitle: 'Перенеси учебные решения в реальные игровые ритмы.',
  ),
  'world_12': Act0WorldDisplayCopyV1(
    title: 'Мост к мышлению игрока',
    subtitle: 'Собери дисциплину, ясность и устойчивый игровой тон.',
  ),
};

const Map<String, Act0LessonDisplayCopyV1>
_ruLessonCopyByIdV1 = <String, Act0LessonDisplayCopyV1>{
  'what_poker_is': Act0LessonDisplayCopyV1(
    title: 'Что такое покер',
    subtitle: 'Познакомься со столом, игроками и целью раздачи.',
  ),
  'cards_ranks_suits': Act0LessonDisplayCopyV1(
    title: 'Карты, ранги и масти',
    subtitle: '52 карты, 4 масти, 13 рангов.',
  ),
  'your_first_hand': Act0LessonDisplayCopyV1(
    title: 'Твоя первая раздача',
    subtitle: 'Проследи раздачу от старта до шоудауна.',
  ),
  'fold_check_call_raise': Act0LessonDisplayCopyV1(
    title: 'Фолд, чек, колл, рейз',
    subtitle: 'Научись называть каждое действие до решения.',
  ),
  'blinds_action_order': Act0LessonDisplayCopyV1(
    title: 'Блайнды и порядок действий',
    subtitle: 'Почему кто-то всегда кладёт фишки первым.',
  ),
  'positions': Act0LessonDisplayCopyV1(
    title: '6 позиций за столом',
    subtitle: 'У каждого места за столом есть имя и роль.',
  ),
  'hand_rankings_table': Act0LessonDisplayCopyV1(
    title: 'Старшинство рук на борде',
    subtitle: 'Что бьёт что на реальных бордах.',
  ),
  'showdown_winning': Act0LessonDisplayCopyV1(
    title: 'Шоудаун и победа',
    subtitle: 'Как раздача действительно заканчивается.',
  ),
  'hand_discipline_buckets': Act0LessonDisplayCopyV1(
    title: 'Группы стартовых рук',
    subtitle:
        'Сначала разложи руку по простой группе, а уже потом вкладывай фишки.',
  ),
  'hand_discipline_apply': Act0LessonDisplayCopyV1(
    title: 'Дисциплина за столом',
    subtitle:
        'Сначала группа руки, потом место и ситуация. Дальше решение проще.',
  ),
};

const Map<String, String> _ruLessonTitleByEnglishV1 = <String, String>{
  'What poker is': 'Что такое покер',
  'Cards, ranks & suits': 'Карты, ранги и масти',
  'Your first hand, dealt': 'Твоя первая раздача',
  'Fold, check, call, raise': 'Фолд, чек, колл, рейз',
  'Blinds & action order': 'Блайнды и порядок действий',
  'The 6 positions': '6 позиций за столом',
  'Hand rankings, on the table': 'Старшинство рук на борде',
  'Showdown & winning': 'Шоудаун и победа',
};

const Map<String, Act0TaskDisplayCopyV1>
_ruTaskCopyByIdV1 = <String, Act0TaskDisplayCopyV1>{
  'what_poker_is_theory': Act0TaskDisplayCopyV1(
    title: 'Знакомство со столом',
    summary:
        'Разберись в базовой картине: места, фишки, карты и то, что стол пытается определить.',
  ),
  'what_poker_is_find_hero': Act0TaskDisplayCopyV1(
    title: 'Найди своё место',
    summary:
        'Сначала научись видеть, где сидит Hero, и только потом отслеживай остальное.',
  ),
  'what_poker_is_pot_stack': Act0TaskDisplayCopyV1(
    title: 'Банк и стек',
    summary:
        'Отделяй фишки в банке от фишек, которые ещё лежат в стеке игрока.',
  ),
  'what_poker_is_win_ways': Act0TaskDisplayCopyV1(
    title: 'Как выигрывают банк',
    summary:
        'Увидь два базовых финала раздачи: все пасуют или карты доходят до шоудауна.',
  ),
  'what_poker_is_showdown_win': Act0TaskDisplayCopyV1(
    title: 'Победа на шоудауне',
    summary: 'Определи, какая рука выигрывает, когда все карты уже открыты.',
  ),
  'what_poker_is_table_read_transfer': Act0TaskDisplayCopyV1(
    title: 'Первое чтение живого стола',
    summary:
        'Перенеси первое чтение стола в живой спот: карманные карты, борд, потом банк.',
  ),
  'what_poker_is_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по столу',
    summary:
        'Пройди чтение стола целиком и чисто: место, банк и финал раздачи.',
  ),
  'cards_ranks_suits_theory': Act0TaskDisplayCopyV1(title: 'Колода'),
  'cards_ranks_suits_rank_drill': Act0TaskDisplayCopyV1(title: 'Старшая карта'),
  'cards_ranks_suits_suit_drill': Act0TaskDisplayCopyV1(title: 'Назови масть'),
  'cards_ranks_suits_private_board': Act0TaskDisplayCopyV1(
    title: 'Карманные и борд',
  ),
  'cards_ranks_suits_board_count': Act0TaskDisplayCopyV1(
    title: 'Сколько карт на борде',
  ),
  'cards_ranks_suits_best_five': Act0TaskDisplayCopyV1(
    title: 'Идея лучших пяти',
  ),
  'cards_ranks_suits_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по картам',
    summary:
        'Докажи, что уверенно разделяешь ранг, масть, борд и идею лучших пяти карт.',
  ),
  'your_first_hand_preflop': Act0TaskDisplayCopyV1(title: 'Префлоп'),
  'your_first_hand_flop': Act0TaskDisplayCopyV1(title: 'Флоп'),
  'your_first_hand_turn': Act0TaskDisplayCopyV1(title: 'Тёрн'),
  'your_first_hand_river': Act0TaskDisplayCopyV1(title: 'Ривер'),
  'your_first_hand_showdown': Act0TaskDisplayCopyV1(title: 'Чтение шоудауна'),
  'your_first_hand_action_trail': Act0TaskDisplayCopyV1(
    title: 'Цепочка действий',
  ),
  'your_first_hand_recap': Act0TaskDisplayCopyV1(title: 'Повтор по улицам'),
  'actions_theory': Act0TaskDisplayCopyV1(
    title: 'Слова действий',
    summary: 'Сначала закрепи четыре главных глагола: фолд, чек, колл и рейз.',
    runnerPrompt: 'Сначала назови действие, потом принимай решение.',
    runnerSupport:
        'Держись простого каркаса: фолд уходит, чек не добавляет фишек, колл уравнивает, рейз повышает цену.',
  ),
  'actions_legal_context': Act0TaskDisplayCopyV1(
    title: 'Разрешённые действия',
    summary:
        'Свяжи состояние стола с теми действиями, которые здесь действительно разрешены.',
    lockedSummary:
        'Сначала открой Слова действий, потом этот узел начнёт читаться правильно.',
    runnerPrompt: 'Смотри на ставку на столе и убери невозможные действия.',
    runnerSupport:
        'Сначала прочитай состояние стола, потом оставь только те действия, которые здесь вообще доступны.',
  ),
  'actions_check_drill': Act0TaskDisplayCopyV1(
    title: 'Чек без ставки',
    summary:
        'Распознай единственный момент, когда чек бесплатен и действительно правильный.',
    lockedSummary:
        'Сначала закрой Слова действий, потом откроется чтение спота без ставки.',
    runnerPrompt: 'Если ставки нет, проверь, открыт ли бесплатный чек.',
    runnerSupport:
        'Чек существует только тогда, когда до тебя никто не поставил. Ищи именно это условие.',
  ),
  'actions_fold_drill': Act0TaskDisplayCopyV1(
    title: 'Фолд слабых рук',
    summary:
        'Натренируй чистый выход из спота, где продолжение только сожжёт фишки.',
    lockedSummary:
        'Сначала пройди вступление, потом вернись к этому ремонтному узлу.',
    runnerPrompt: 'Слабая рука без цены не обязана продолжать.',
    runnerSupport:
        'Фолд сохраняет стек, когда продолжение не даёт внятной причины вкладывать фишки дальше.',
  ),
  'actions_call_drill': Act0TaskDisplayCopyV1(
    title: 'Колл по цене',
    summary:
        'Пойми, когда колл по цене остаётся самым дешёвым и верным продолжением.',
    lockedSummary:
        'Этот шаг откроется после Слов действий, когда базовые глаголы станут устойчивыми.',
    runnerPrompt: 'Когда цена разумная, колл просто держит раздачу в игре.',
    runnerSupport:
        'Колл не выигрывает раздачу сразу, но часто остаётся самым спокойным и дешёвым продолжением.',
  ),
  'actions_raise_drill': Act0TaskDisplayCopyV1(
    title: 'Открытие на баттоне',
    summary:
        'Используй рейз в самом чистом споте для новичка: все выбросили, а ты на баттоне.',
    lockedSummary:
        'Сначала выучи меню действий, потом открывай агрессивный вариант.',
    runnerPrompt:
        'Когда все выбросили до тебя на баттоне, рейз забирает инициативу.',
    runnerSupport:
        'Рейз открывает раздачу давлением. На баттоне без предыдущей ставки это самый чистый учебный пример.',
  ),
  'actions_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по действиям',
    summary: 'Докажи, что можешь называть правильное действие без подсказок.',
    lockedSummary:
        'Повтор откроется после того, как дриллы по действиям будут закрыты чисто.',
    runnerPrompt: 'Назови действие быстро и без лишних догадок.',
    runnerSupport:
        'Собери всё вместе: прочитай стол, отсеки невозможное и назови лучшее действие.',
  ),
  'blinds_theory': Act0TaskDisplayCopyV1(title: 'Блайнды ставятся первыми'),
  'blinds_posts_drill': Act0TaskDisplayCopyV1(title: 'Кто ставит 1 BB'),
  'blinds_first_actor': Act0TaskDisplayCopyV1(title: 'Первый на префлопе'),
  'blinds_last_actor': Act0TaskDisplayCopyV1(title: 'Последний на префлопе'),
  'blinds_postflop_button': Act0TaskDisplayCopyV1(
    title: 'Последний на постфлопе',
  ),
  'blinds_button_moves': Act0TaskDisplayCopyV1(title: 'Баттон двигается'),
  'blinds_review': Act0TaskDisplayCopyV1(title: 'Повтор по порядку'),
  'hand_discipline_buckets_intro': Act0TaskDisplayCopyV1(
    title: 'Четыре группы',
    summary:
        'Перед действием сначала назови группу руки: премиум, сильная, средняя или мусор.',
    runnerPrompt: 'Сначала назови группу руки, а уже потом думай о действии.',
    runnerSupport:
        'Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.',
  ),
  'hand_discipline_buckets_premium': Act0TaskDisplayCopyV1(
    title: 'Премиум-рука',
    summary:
        'Закрепи верхнюю группу стартовых рук, с которой банк чаще хочется разгонять.',
    runnerPrompt: 'Сначала определи группу руки.',
    runnerSupport:
        'Премиум-руки не требуют сложных оправданий: они чаще хотят строить банк, а не прятаться.',
  ),
  'hand_discipline_buckets_strong': Act0TaskDisplayCopyV1(
    title: 'Сильная рука',
    summary:
        'Отделяй очень играбельные руки от настоящего премиума без лишней драматизации.',
    runnerPrompt: 'Назови группу руки до выбора линии.',
    runnerSupport:
        'Сильная рука почти всегда играбельна, но это ещё не вершина диапазона.',
  ),
  'hand_discipline_buckets_medium': Act0TaskDisplayCopyV1(
    title: 'Средняя рука',
    summary:
        'Средние руки любят аккуратность: им уже важны место за столом и удобный контекст.',
    runnerPrompt: 'Сначала пойми, насколько рука пограничная.',
    runnerSupport:
        'Средняя рука не обязана лезть в каждый банк. Ей нужен более удобный спот, чем премиуму.',
  ),
  'hand_discipline_buckets_trash': Act0TaskDisplayCopyV1(
    title: 'Мусорная рука',
    summary:
        'Слабый оффсьют без хорошего места и цены чаще приносит только лишние проблемы.',
    runnerPrompt: 'Слабая рука не обязана становиться приключением.',
    runnerSupport:
        'Если рука не тянет на продолжение, дисциплина экономит фишки простым фолдом.',
  ),
  'hand_discipline_buckets_borderline': Act0TaskDisplayCopyV1(
    title: 'Погранично сильная',
    summary:
        'Некоторые руки уже сильные, хотя внешне ещё не выглядят как абсолютный топ.',
    runnerPrompt: 'Не путай просто сильную руку с премиумом.',
    runnerSupport:
        'Эта группа всё ещё играет уверенно, но ей не нужно приписывать силу самого верха.',
  ),
  'hand_discipline_buckets_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по группам',
    summary:
        'Собери привычку целиком: сначала группа руки, потом уже всё остальное.',
    runnerPrompt: 'До действия сначала назови группу руки.',
    runnerSupport:
        'Когда рука быстро попадает в нужную группу, префлоп-решения становятся спокойнее и чище.',
  ),
  'apply_intro': Act0TaskDisplayCopyV1(
    title: 'Привычка в три шага',
    summary:
        'Группа руки, место и ситуация дают простую опору ещё до выбора действия.',
    runnerPrompt:
        'Иди по порядку: группа руки, место, ситуация, потом действие.',
    runnerSupport:
        'Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоят ли фишки входа.',
  ),
  'apply_utg_fold': Act0TaskDisplayCopyV1(
    title: 'UTG, мусорная рука',
    summary:
        'Когда рука слабая, а место раннее, дисциплина чаще всего экономит стек простым фолдом.',
    runnerPrompt: 'Ранняя позиция плюс мусорная рука редко требуют героизма.',
    runnerSupport:
        'Не усложняй спот. Если рука слабая и ты говоришь первым, фолд сохраняет фишки и внимание.',
  ),
  'apply_btn_open': Act0TaskDisplayCopyV1(
    title: 'Баттон, сильная рука',
    summary:
        'Сильная рука на баттоне в чистом банке часто превращается в спокойное открытие.',
    runnerPrompt: 'Сильная рука на баттоне любит инициативу.',
    runnerSupport:
        'Когда до тебя все выбросили, поздняя позиция и хорошая рука дают чистый повод открыть раздачу.',
  ),
  'apply_hj_decision': Act0TaskDisplayCopyV1(
    title: 'HJ, средняя рука',
    summary:
        'Средняя рука в средней позиции просит аккуратного решения, а не автоматического продолжения.',
    runnerPrompt: 'Средняя рука любит контекст сильнее, чем автопилот.',
    runnerSupport:
        'Здесь важно не упрямство, а трезвый каркас: группа руки, место и ситуация должны дать чистую причину продолжать.',
  ),
  'apply_recap': Act0TaskDisplayCopyV1(
    title: 'Дисциплина держится',
    summary:
        'Проверь, что каркас не разваливается под давлением: группа руки, место, ситуация, действие.',
    runnerPrompt: 'Собери весь каркас в один спокойный префлоп-ритм.',
    runnerSupport:
        'Хорошая дисциплина не ищет подвигов. Она снова и снова приводит к чистому решению по понятным причинам.',
  ),
};

const Map<String, Act0SurfaceAtomCopyV1>
_ruSurfaceAtomCopyByIdV1 = <String, Act0SurfaceAtomCopyV1>{
  'play_title': Act0SurfaceAtomCopyV1(text: 'Практика'),
  'play_screen_subtitle': Act0SurfaceAtomCopyV1(
    text: 'Запусти один короткий сет и держи маршрут в движении.',
  ),
  'play_quick_practice_label': Act0SurfaceAtomCopyV1(text: 'Быстрая практика'),
  'play_recommended_repair_label': Act0SurfaceAtomCopyV1(
    text: 'Рекомендуемый фикс',
  ),
  'play_practice_lanes_label': Act0SurfaceAtomCopyV1(text: 'Линии практики'),
  'play_topic_preflop': Act0SurfaceAtomCopyV1(text: 'Префлоп'),
  'play_topic_position': Act0SurfaceAtomCopyV1(text: 'Позиция'),
  'play_topic_postflop': Act0SurfaceAtomCopyV1(text: 'Постфлоп'),
  'play_topic_hand_reading': Act0SurfaceAtomCopyV1(text: 'Чтение руки'),
  'play_topic_showdown': Act0SurfaceAtomCopyV1(text: 'Шоудаун'),
  'play_repair_empty_title': Act0SurfaceAtomCopyV1(
    text: 'Сейчас нечего чинить.',
  ),
  'play_repair_empty_body': Act0SurfaceAtomCopyV1(
    text: 'Используй практику по темам, чтобы добрать дополнительные репы.',
  ),
  'play_later_cta': Act0SurfaceAtomCopyV1(text: 'Позже'),
  'review_fix_next_label': Act0SurfaceAtomCopyV1(text: 'Чиним дальше'),
  'review_title': Act0SurfaceAtomCopyV1(text: 'Доска фиксов'),
  'review_subtitle': Act0SurfaceAtomCopyV1(
    text: 'Разбери один промах, прежде чем двигаться дальше.',
  ),
  'review_recovered_lately_label': Act0SurfaceAtomCopyV1(
    text: 'Недавно восстановлено',
  ),
  'review_board_title_fix': Act0SurfaceAtomCopyV1(text: 'Чиним следующим'),
  'review_board_title_clean': Act0SurfaceAtomCopyV1(text: 'Повтор'),
  'review_board_headline_clean': Act0SurfaceAtomCopyV1(text: 'Стол снова чист'),
  'review_board_body_clean': Act0SurfaceAtomCopyV1(
    text:
        'Срочных фиксов сейчас нет. Держи стол чистым через один спокойный прогон.',
  ),
  'review_board_support_fix': Act0SurfaceAtomCopyV1(
    text: 'Один чистый фикс здесь важнее, чем беглый взгляд на весь стол.',
  ),
  'review_board_support_clean_empty': Act0SurfaceAtomCopyV1(
    text: 'Пока чинить нечего. Просто держи маршрут в движении.',
  ),
  'review_board_support_clean_strong': Act0SurfaceAtomCopyV1(
    text: 'Сейчас всё чисто. Просто держи маршрут в движении.',
  ),
  'review_board_fix_cta': Act0SurfaceAtomCopyV1(text: 'Чинить сейчас'),
  'profile_title': Act0SurfaceAtomCopyV1(text: 'Ты'),
  'profile_recommended_focus_label': Act0SurfaceAtomCopyV1(
    text: 'Следующий фокус',
  ),
  'profile_working_well_label': Act0SurfaceAtomCopyV1(text: 'Уже получается'),
  'profile_next_reps_label': Act0SurfaceAtomCopyV1(text: 'Следующие репы'),
  'profile_consistency_label': Act0SurfaceAtomCopyV1(text: 'Ритм'),
  'profile_streak_label': Act0SurfaceAtomCopyV1(text: 'Серия'),
  'profile_momentum_streak_7': Act0SurfaceAtomCopyV1(
    text:
        'Семь дней подряд уже не выглядят случайностью. Это становится частью твоей игры.',
  ),
  'profile_momentum_streak_3': Act0SurfaceAtomCopyV1(
    text:
        'Серия уже настоящая. Продолжай набирать чистые репы, пока ритм тёплый.',
  ),
  'profile_momentum_worlds_cleared': Act0SurfaceAtomCopyV1(
    text: 'Закрытый мир важнее шумной цифры. Просто держи маршрут в движении.',
  ),
  'profile_momentum_first_habit': Act0SurfaceAtomCopyV1(
    text:
        'Первая устойчивая привычка здесь простая: вернуться ещё на один чистый реп.',
  ),
  'profile_support_no_streak_with_fix': Act0SurfaceAtomCopyV1(
    text: 'Ты уже починил живой промах. Ещё один чистый реп запускает ритм.',
  ),
  'profile_support_no_streak_plain': Act0SurfaceAtomCopyV1(
    text: 'Один чистый реп запускает ритм.',
  ),
  'profile_support_streak_7': Act0SurfaceAtomCopyV1(
    text: 'Это уже не случайная серия. Ритм становится частью твоей игры.',
  ),
  'profile_support_worlds_cleared': Act0SurfaceAtomCopyV1(
    text: 'Ритм уже оставляет после себя доказательства. Держи маршрут тёплым.',
  ),
  'profile_support_default': Act0SurfaceAtomCopyV1(
    text:
        'Держи ритм тёплым. Постоянство постепенно превращается в ощущение игры.',
  ),
};
