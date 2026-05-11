# world_2 RU Translation Pack

Status: GENERATED
World number: 2
EN title: Hand Discipline
EN subtitle: Learn which hands deserve chips and which can fold.
title_ru: Дисциплина рук
subtitle_ru: Пойми, какие руки стоят фишек, а какие спокойно уходят в пас.

## Coverage
- Lessons: 2/2
- Tasks: 12/12
- Runner prompts: 12/12
- Runner supports: 12/12
- Runner questions: 12/12

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson hand_discipline_buckets
status: landed_or_partial
title_en: Hand buckets
subtitle_en: Sort hands before putting chips in.
title_ru: Группы стартовых рук
subtitle_ru: Сначала разложи руку по простой группе, а уже потом вкладывай фишки.

- taskId: hand_discipline_buckets_intro
  status: landed_or_partial
  title_en: Four buckets
  phase: theory
  stepKind: learn
  runner: _world3BucketsIntroRunner
  runnerPrompt_en: Preflop starts by sorting the hand into a simple bucket.
  runnerSupport_en: Use premium, strong, medium, and trash before choosing. No charts needed at this stage.
  runnerQuestion_en: What should you name before the action?
  title_ru: Четыре группы
  runnerPrompt_ru: Сначала назови группу руки, а уже потом думай о действии.
  runnerSupport_ru: Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.
  runnerQuestion_ru: Что лучше назвать до действия?

- taskId: hand_discipline_buckets_premium
  status: landed_or_partial
  title_en: Premium hand
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  title_ru: Премиум-рука
  runnerPrompt_ru: Сначала определи группу руки.
  runnerSupport_ru: Премиум-руки не требуют сложных оправданий: они чаще хотят строить банк, а не прятаться.
  runnerQuestion_ru: Какая группа у АА?

- taskId: hand_discipline_buckets_strong
  status: landed_or_partial
  title_en: Strong hand
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  title_ru: Сильная рука
  runnerPrompt_ru: Назови группу руки до выбора линии.
  runnerSupport_ru: Сильная рука почти всегда играбельна, но это ещё не вершина диапазона.
  runnerQuestion_ru: Какая группа у JJ?

- taskId: hand_discipline_buckets_medium
  status: landed_or_partial
  title_en: Medium hand
  phase: drill
  stepKind: practice
  runner: _w1MediumBucketRunner
  runnerPrompt_en: KQo is a medium preflop hand.
  runnerSupport_en: Medium hands play best in good positions with the right frame.
  runnerQuestion_en: Which bucket is KQo?
  title_ru: Средняя рука
  runnerPrompt_ru: Сначала пойми, насколько рука пограничная.
  runnerSupport_ru: Средняя рука не обязана лезть в каждый банк. Ей нужен более удобный спот, чем премиуму.
  runnerQuestion_ru: Какая группа у KQo?

- taskId: hand_discipline_buckets_trash
  status: landed_or_partial
  title_en: Trash hand
  phase: drill
  stepKind: practice
  runner: _world3TrashBucketRunner
  runnerPrompt_en: J8o is a weak offsuit starter from early position.
  runnerSupport_en: Weak early hands should not be forced into action.
  runnerQuestion_en: Which bucket fits J8o early?
  title_ru: Мусорная рука
  runnerPrompt_ru: Слабая рука не обязана становиться приключением.
  runnerSupport_ru: Если рука не тянет на продолжение, дисциплина экономит фишки простым фолдом.
  runnerQuestion_ru: К какой группе отнести J8o в ранней позиции?

- taskId: hand_discipline_buckets_borderline
  status: landed_or_partial
  title_en: Borderline strong
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  title_ru: Погранично сильная
  runnerPrompt_ru: Не путай просто сильную руку с премиумом.
  runnerSupport_ru: Эта группа всё ещё играет уверенно, но ей не нужно приписывать силу самого верха.
  runnerQuestion_ru: Какая группа здесь ближе всего?

- taskId: hand_discipline_buckets_recap
  status: landed_or_partial
  title_en: Bucket recap
  phase: review
  stepKind: review
  runner: _world3BucketsRecapRunner
  runnerPrompt_en: Lesson learned: bucket the hand before the action.
  runnerSupport_en: Premium, strong, medium, or trash is the first preflop read.
  runnerQuestion_en: What is the first preflop habit?
  title_ru: Повтор по группам
  runnerPrompt_ru: До действия сначала назови группу руки.
  runnerSupport_ru: Когда рука быстро попадает в нужную группу, префлоп-решения становятся спокойнее и чище.
  runnerQuestion_ru: Какая префлоп-привычка здесь первая?

## lesson hand_discipline_apply
status: landed_or_partial
title_en: Discipline at the table
subtitle_en: Bucket, seat, and frame — then the action is simple.
title_ru: Дисциплина за столом
subtitle_ru: Сначала группа руки, потом место и ситуация. Дальше решение проще.

- taskId: apply_intro
  status: landed_or_partial
  title_en: Three-step habit
  phase: theory
  stepKind: learn
  runner: _w1DisciplineApplyIntroRunner
  runnerPrompt_en: Three steps make the decision easier.
  runnerSupport_en: Bucket the hand, read the seat, read the frame — then act. No chart memorization required.
  runnerQuestion_en: What order helps most?
  title_ru: Привычка в три шага
  runnerPrompt_ru: Иди по порядку: группа руки, место, ситуация, потом действие.
  runnerSupport_ru: Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоят ли фишки входа.
  runnerQuestion_ru: Какой порядок здесь самый чистый?

- taskId: apply_utg_fold
  status: landed_or_partial
  title_en: UTG, trash hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  title_ru: UTG, мусорная рука
  runnerPrompt_ru: Ранняя позиция плюс мусорная рука редко требуют героизма.
  runnerSupport_ru: Не усложняй спот. Если рука слабая и ты говоришь первым, фолд сохраняет фишки и внимание.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_btn_open
  status: landed_or_partial
  title_en: BTN, strong hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyLateOpenRunner
  runnerPrompt_en: BTN. Pot unopened. Hero holds A♠ J♦.
  runnerSupport_en: Late position, strong hand, no one entered. Clean open.
  runnerQuestion_en: What is the clean action?
  title_ru: Баттон, сильная рука
  runnerPrompt_ru: Сильная рука на баттоне любит инициативу.
  runnerSupport_ru: Когда до тебя все выбросили, поздняя позиция и хорошая рука дают чистый повод открыть раздачу.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_hj_decision
  status: landed_or_partial
  title_en: HJ, medium hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  title_ru: HJ, средняя рука
  runnerPrompt_ru: Средняя рука любит контекст сильнее, чем автопилот.
  runnerSupport_ru: Здесь важно не упрямство, а трезвый каркас: группа руки, место и ситуация должны дать чистую причину продолжать.
  runnerQuestion_ru: Какое решение здесь выглядит наиболее дисциплинированным?

- taskId: apply_recap
  status: landed_or_partial
  title_en: Discipline holds
  phase: review
  stepKind: proveIt
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  title_ru: Дисциплина держится
  runnerPrompt_ru: Собери весь каркас в один спокойный префлоп-ритм.
  runnerSupport_ru: Хорошая дисциплина не ищет подвигов. Она снова и снова приводит к чистому решению по понятным причинам.
  runnerQuestion_ru: Чего должны избегать знакомые, но слабые руки?

