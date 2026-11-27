// B151: only this task moved. Both lesson IDs are still valid for other tasks.
const act0W11ReviewIntroTaskIdV1 = 'w11_review_loop_intro';
const act0W11ReviewIntroOldLessonV1 = 'table_trigger_multiway_and_spr';
const act0W11ReviewIntroLessonV1 = 'post_session_review_loop';

String act0CanonicalLessonForTaskV1(
  String worldId,
  String lessonId,
  String taskId,
) =>
    worldId == 'world_11' &&
        lessonId == act0W11ReviewIntroOldLessonV1 &&
        taskId == act0W11ReviewIntroTaskIdV1
    ? act0W11ReviewIntroLessonV1
    : lessonId;
