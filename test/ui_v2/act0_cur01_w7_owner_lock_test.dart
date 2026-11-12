import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  test('exact identity denial never blanket-blocks other sources', () {
    for (final identity in [
      (
        'world_1',
        'range_thinking_lite_combo_density',
        'visible_king_combo_reduction_intro',
      ),
      ('world_7', 'other_lesson', 'visible_king_combo_reduction_intro'),
      ('world_7', 'range_thinking_lite_combo_density', 'unknown_task'),
    ]) {
      expect(
        act0RepairSourceExplicitlyUnavailableV1(
          worldId: identity.$1,
          lessonId: identity.$2,
          taskId: identity.$3,
        ),
        isFalse,
      );
    }
  });
  test('all explicitly locked W7 authored specs refuse repair intent', () {
    final world = Act0ShellStateV1.sample.worldById('world_7');
    final lesson = world.lessons.singleWhere(
      (l) => l.lessonId == 'range_thinking_lite_combo_density',
    );
    expect(act0W7VisibleAceHiddenTaskSpecsV1, hasLength(4));
    for (final spec in act0W7VisibleAceHiddenTaskSpecsV1) {
      expect(spec.practiceCtaAllowed, isFalse);
      final task = lesson.taskList.singleWhere((t) => t.taskId == spec.taskId);
      for (final option in task.runner.options) {
        expect(
          buildAct0RepairIntentV1(
            sourceWorldId: world.worldId,
            sourceLessonId: lesson.lessonId,
            sourceTaskId: task.taskId,
            runner: task.runner,
            selectedOption: option,
            mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
          ),
          isNull,
          reason:
              '${task.taskId}/${option.id} must not mint a locked-source obligation',
        );
      }
    }
  });
  test('known W1 allowed conceptual repair remains mapped', () {
    final world = Act0ShellStateV1.sample.worldById('world_1');
    final lesson = world.lessons.singleWhere(
      (l) => l.lessonId == 'fold_check_call_raise',
    );
    final task = lesson.taskList.singleWhere(
      (t) => t.taskId == 'actions_legal_context',
    );
    final wrong = task.runner.options.singleWhere((o) => o.id == 'fold');
    final intent = buildAct0RepairIntentV1(
      sourceWorldId: world.worldId,
      sourceLessonId: lesson.lessonId,
      sourceTaskId: task.taskId,
      runner: task.runner,
      selectedOption: wrong,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    );
    expect(intent, isNotNull);
    expect(intent!.targetWorldId, 'world_1');
    expect(intent.targetTaskId, 'actions_check_drill');
  });
}
