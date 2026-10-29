// Shared harness for LEARN.UX.P1 (#331) on-table teaching integrity tests.
//
// Mounts the real Act0 lesson runner for one source-authored task and drives
// it with the same teaching-advance rules the preview screen uses
// (`_advanceTeachingStep` plus the drill-phase preamble exit), so tests observe
// what a learner actually sees at each authored step.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

class Act0TeachingTaskRefV1 {
  const Act0TeachingTaskRefV1({
    required this.worldId,
    required this.lessonId,
    required this.task,
  });

  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
}

/// Every source-authored task in the current Academy catalog, in order.
List<Act0TeachingTaskRefV1> act0TeachingCatalogV1() => <Act0TeachingTaskRefV1>[
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        Act0TeachingTaskRefV1(
          worldId: world.worldId,
          lessonId: lesson.lessonId,
          task: task,
        ),
];

Act0TeachingTaskRefV1 act0TeachingTaskByIdV1(String taskId) =>
    act0TeachingCatalogV1().firstWhere((ref) => ref.task.taskId == taskId);

class Act0TeachingHarnessV1 extends StatefulWidget {
  const Act0TeachingHarnessV1({
    super.key,
    required this.ref,
    required this.events,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final Act0TeachingTaskRefV1 ref;
  final List<String> events;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0TeachingHarnessV1> createState() => Act0TeachingHarnessStateV1();
}

class Act0TeachingHarnessStateV1 extends State<Act0TeachingHarnessV1> {
  late Act0LessonPhaseV1 phase = widget.ref.task.entryPhase;
  int teachingStepIndex = 0;
  String? selectedOptionId;
  bool taskCompleted = false;

  Act0RunnerStateV1 get _taskRunner => widget.ref.task.runner;

  void _continueTheory() {
    setState(() {
      final steps = _taskRunner.teachingSteps;
      if (teachingStepIndex + 1 < steps.length) {
        teachingStepIndex += 1;
        widget.events.add('teaching_step:$teachingStepIndex');
        return;
      }
      teachingStepIndex = steps.length;
      if (widget.ref.task.phase != Act0LessonPhaseV1.theory) {
        widget.events.add('teaching_done');
        return;
      }
      taskCompleted = true;
      widget.events.add('theory_task_completed');
    });
  }

  void _previousTheory() {
    setState(() {
      if (teachingStepIndex > 0) teachingStepIndex -= 1;
    });
  }

  void _chooseOption(String optionId) {
    setState(() {
      selectedOptionId = optionId;
      phase = Act0LessonPhaseV1.review;
      widget.events.add('choose:$optionId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;
    return Act0LessonRunnerShellV1(
      runner: _taskRunner.copyWith(
        phase: phase,
        teachingStepIndex: teachingStepIndex,
        selectedOptionId: selectedOptionId,
      ),
      selectedWorldId: ref.worldId,
      selectedLessonId: ref.lessonId,
      selectedTaskId: ref.task.taskId,
      selectedTaskTitle: ref.task.title,
      selectedTaskFamily: ref.task.resolvedTaskFamily,
      tablePresentation: ref.task.tablePresentation,
      tableVisualVariant: widget.tableVisualVariant,
      onBack: () {},
      onContinueTheory: _continueTheory,
      onPreviousTheory: _previousTheory,
      onChooseOption: (option) => _chooseOption(option.id),
      onChooseSeat: (seatId) => _chooseOption(
        _taskRunner.options
            .firstWhere(
              (option) => option.seatId == seatId,
              orElse: () => _taskRunner.options.first,
            )
            .id,
      ),
      onContinueReview: () => widget.events.add('continue_review'),
    );
  }
}

/// Replaces the square-glyph test font with a real proportional font so line
/// counts and fit approximate the device (Arial is metrically close to the
/// iOS system font). Call from `setUpAll`.
Future<void> act0LoadRealTextFontsV1() async {
  const dir = '/System/Library/Fonts/Supplemental';
  final files = <File>[
    File('$dir/Arial.ttf'),
    File('$dir/Arial Bold.ttf'),
  ].where((file) => file.existsSync()).toList();
  if (files.isEmpty) {
    throw StateError('No real-text test font found.');
  }
  for (final family in const <String>['Roboto', 'Ahem']) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

/// iPhone 14 Pro logical viewport (the native QA reference device).
const Size act0TeachingReferenceViewportV1 = Size(393, 852);

Future<Act0TeachingHarnessStateV1> act0PumpTeachingHarnessV1(
  WidgetTester tester,
  Act0TeachingTaskRefV1 ref, {
  List<String>? events,
  Locale locale = const Locale('en'),
  Size viewport = act0TeachingReferenceViewportV1,
  double textScale = 1,
  Act0ShellTableVisualVariantV1 tableVisualVariant =
      Act0ShellTableVisualVariantV1.refinedDev2,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.systemFontFamily = 'Roboto';
  addTearDown(tester.platformDispatcher.resetSystemFontFamily);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Act0TeachingHarnessV1(
          key: const ValueKey('act0_teaching_harness'),
          ref: ref,
          events: events ?? <String>[],
          tableVisualVariant: tableVisualVariant,
        ),
      ),
    ),
  );
  await act0SettleTeachingV1(tester);
  return tester.state<Act0TeachingHarnessStateV1>(
    find.byKey(const ValueKey('act0_teaching_harness')),
  );
}

/// Lets the runner's theory dwell lock (820ms) and entry motion elapse.
Future<void> act0SettleTeachingV1(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pump(const Duration(milliseconds: 600));
}

final Finder act0TeachingContinueFinderV1 = find.byKey(
  const Key('act0_shell_continue_cta'),
);

Future<void> act0TapTeachingContinueV1(WidgetTester tester) async {
  if (act0TeachingContinueFinderV1.evaluate().isEmpty) return;
  await tester.tap(act0TeachingContinueFinderV1, warnIfMissed: false);
  await act0SettleTeachingV1(tester);
}

String act0NormalizeCopyV1(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim();

/// One mounted Text, with whether a learner can actually read all of it.
class Act0PresentedTextV1 {
  const Act0PresentedTextV1({
    required this.text,
    required this.onScreen,
    required this.truncated,
    required this.scrollable,
    required this.fitsWithoutScroll,
  });

  final String text;

  /// Painted, not hidden, and entirely inside the screen.
  final bool onScreen;

  /// Ellipsized or clipped by maxLines.
  final bool truncated;

  /// Hosted in a scroll view.
  final bool scrollable;

  /// Entirely inside its scroll viewport (or not scrollable at all), so every
  /// line is visible without the learner scrolling.
  final bool fitsWithoutScroll;

  /// Genuinely readable. Scrolling counts only when [allowScroll] is set (for
  /// enlarged text); at the reference scale every line must already be shown.
  bool readable({bool allowScroll = false}) =>
      onScreen &&
      !truncated &&
      (fitsWithoutScroll || (allowScroll && scrollable));
}

List<Act0PresentedTextV1> act0PresentedTextsV1(WidgetTester tester) {
  final view = tester.view;
  final screen = (Offset.zero & (view.physicalSize / view.devicePixelRatio))
      .inflate(0.5);
  final result = <Act0PresentedTextV1>[];
  for (final element in find.byType(Text).evaluate()) {
    final widget = element.widget as Text;
    final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
    if (text.trim().isEmpty) continue;
    final render = element.findRenderObject();
    if (render is! RenderBox || !render.attached || !render.hasSize) continue;
    final paragraph = _paragraphOf(render);
    final rect = render.localToGlobal(Offset.zero) & render.size;
    var visible = true;
    Rect? viewport;
    element.visitAncestorElements((ancestor) {
      final w = ancestor.widget;
      if (w is Opacity && w.opacity == 0) visible = false;
      if (w is Offstage && w.offstage) visible = false;
      if (w is Visibility && !w.visible) visible = false;
      if (viewport == null && w is Scrollable) {
        final box = ancestor.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          viewport = (box.localToGlobal(Offset.zero) & box.size).inflate(0.5);
        }
      }
      return visible;
    });
    final inside =
        screen.contains(rect.topLeft) && screen.contains(rect.bottomRight);
    result.add(
      Act0PresentedTextV1(
        text: text,
        onScreen: visible && rect.width > 0 && rect.height > 0 && inside,
        truncated: paragraph?.didExceedMaxLines ?? false,
        scrollable: viewport != null,
        fitsWithoutScroll:
            viewport == null ||
            (viewport!.contains(rect.topLeft) &&
                viewport!.contains(rect.bottomRight)),
      ),
    );
  }
  return result;
}

RenderParagraph? _paragraphOf(RenderObject render) {
  if (render is RenderParagraph) return render;
  RenderParagraph? found;
  render.visitChildren((child) {
    found ??= _paragraphOf(child);
  });
  return found;
}

/// Whether [expected] is presented readably on screen, either as one Text or
/// as the exact concatenation the runner renders (title/body may share a
/// Text). Whitespace is normalized; wording is not.
bool act0CopyPresentedV1(
  WidgetTester tester,
  String expected, {
  bool allowScroll = false,
}) {
  final want = act0NormalizeCopyV1(expected);
  if (want.isEmpty) return true;
  for (final presented in act0PresentedTextsV1(tester)) {
    if (!presented.readable(allowScroll: allowScroll)) continue;
    if (act0NormalizeCopyV1(presented.text).contains(want)) return true;
  }
  return false;
}

String? act0TextByKeyV1(WidgetTester tester, String key) {
  final finder = find.byKey(Key(key));
  if (finder.evaluate().isEmpty) return null;
  final widget = tester.widget(finder.first);
  return widget is Text ? (widget.data ?? '') : null;
}

/// The table state the runner hands to its physical table stage.
Act0TableStateV1? act0StageTableV1(WidgetTester tester) {
  final stage = find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString() == '_RunnerTableStageV1',
  );
  if (stage.evaluate().isEmpty) return null;
  return (tester.widget(stage.first) as dynamic).table as Act0TableStateV1;
}

/// Learner decision controls currently mounted for [options].
int act0VisibleOptionCountV1(
  WidgetTester tester,
  List<Act0RunnerOptionV1> options,
) {
  var count = 0;
  for (final option in options) {
    final key = option.seatId == null
        ? 'act0_shell_option_${option.id}'
        : 'act0_shell_seat_tap_${option.seatId}';
    if (find.byKey(Key(key)).evaluate().isNotEmpty) {
      count += 1;
    }
  }
  return count;
}
