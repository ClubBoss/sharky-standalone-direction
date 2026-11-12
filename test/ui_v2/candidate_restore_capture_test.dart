import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

// Only consume actual old-source UI capture bytes, unchanged. Prerequisites of
// that capture are synthetic; this is not a fully earned historical journey.
void main() {
  for (final name in ['missed-feedback-progress', 'post-continue-progress']) {
    testWidgets('candidate preserves old-source UI capture $name twice', (
      t,
    ) async {
      final directory = Platform.environment['PKR_OLD_CAPTURE_DIRECTORY'];
      expect(directory, isNotNull);
      final bytes = File('$directory/$name.json').readAsStringSync();
      final original = jsonDecode(bytes) as Map<String, dynamic>;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_shell_progress_v1': bytes,
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
      });
      await t.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => t.binding.setSurfaceSize(null));
      for (var restart = 0; restart < 2; restart++) {
        await t.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              key: UniqueKey(),
              showPlacementOnStart: false,
            ),
          ),
        );
        await t.pumpAndSettle();
        (t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
            .debugPersistProgressV1();
        await t.pump(const Duration(milliseconds: 250));
        final saved =
            jsonDecode(
                  (await SharedPreferences.getInstance()).getString(
                    'act0_shell_progress_v1',
                  )!,
                )
                as Map<String, dynamic>;
        for (final key in [
          'earnedXp',
          'completedTaskIds',
          'learningEvidenceHistory',
          'reviewMistakeHistory',
          'reviewResolutionReceipts',
          'openRepairIntents',
          'multiRepairQueue',
        ]) {
          expect(
            saved[key],
            original[key],
            reason: '$key changed on restart $restart',
          );
        }
        expect(
          find.byType(Act0LessonRunnerShellV1),
          findsNothing,
          reason: 'Old hand must not silently resume as a vocabulary repair',
        );
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      }
    });
  }
}
