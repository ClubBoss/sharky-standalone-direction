import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('Compact instruction builder prefers richer support beats over micro-pages', () {
    const source =
        'Each player gets 2 private hole cards. The table shares 5 community cards. '
        'You build the best 5-card hand from those 7. This course starts with No-Limit Hold\'em cash.';

    final segments = act0BuildInstructionBlocksV1(text: source, compact: true);

    expect(segments, hasLength(2));
    expect(
      segments.first,
      'Each player gets 2 private hole cards. The table shares 5 community cards.',
    );
    expect(
      segments.last,
      'You build the best 5-card hand from those 7. This course starts with No-Limit Hold\'em cash.',
    );
  });

  test(
    'English authored instruction blocks stay inside the compact contract',
    () {
      final issues = <Act0InstructionContentAuditIssueV1>[];
      final lessonIds = <String>{};

      for (final lesson in Act0ShellStateV1.sample.lessons) {
        if (!lessonIds.add(lesson.lessonId)) {
          continue;
        }
        for (final task in lesson.taskList) {
          final runner = task.runner;
          if (runner.hint.trim().isNotEmpty) {
            issues.addAll(
              act0AuditInstructionBlockV1(
                scope: 'en ${task.taskId} runner.hint',
                text: runner.hint,
                compact: true,
              ),
            );
          }
          for (var index = 0; index < runner.teachingSteps.length; index++) {
            final body = runner.teachingSteps[index].body.trim();
            if (body.isEmpty) {
              continue;
            }
            issues.addAll(
              act0AuditInstructionBlockV1(
                scope: 'en ${task.taskId} teachingSteps[$index].body',
                text: body,
                compact: true,
              ),
            );
          }
        }
      }

      expect(issues, isEmpty, reason: _formatIssues(issues));
    },
  );

  test(
    'Russian localized instruction blocks stay inside the compact contract',
    () {
      final bundle = act0CopyBundleForLanguageCodeV1('ru');
      expect(bundle, isNotNull);

      final issues = <Act0InstructionContentAuditIssueV1>[];
      for (final entry in bundle!.tasks.entries) {
        final taskId = entry.key;
        final task = entry.value;
        final runnerSupport = task.runnerSupport?.trim() ?? '';
        if (runnerSupport.isNotEmpty) {
          issues.addAll(
            act0AuditInstructionBlockV1(
              scope: 'ru $taskId runnerSupport',
              text: runnerSupport,
              compact: true,
            ),
          );
        }
        final teachingSteps =
            task.teachingSteps ?? const <Act0TeachingStepDisplayCopyV1>[];
        for (var index = 0; index < teachingSteps.length; index++) {
          final body = teachingSteps[index].body?.trim() ?? '';
          if (body.isEmpty) {
            continue;
          }
          issues.addAll(
            act0AuditInstructionBlockV1(
              scope: 'ru $taskId teachingSteps[$index].body',
              text: body,
              compact: true,
            ),
          );
        }
      }

      expect(issues, isEmpty, reason: _formatIssues(issues));
    },
  );
}

String _formatIssues(List<Act0InstructionContentAuditIssueV1> issues) {
  if (issues.isEmpty) {
    return '';
  }
  return issues.map((issue) => issue.toString()).join('\n');
}
