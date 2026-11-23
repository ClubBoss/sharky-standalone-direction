import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Sample = ({int frames, int widgets, int runner, int peakMicros});

// One-way ceilings for the W1 widget harness. Counts are exact from the
// reference route. Time uses the median of the per-run peaks with headroom
// for shared CI hosts. Keep these ceilings or lower them after an improvement.
// The widget binding measures synchronous build/layout/paint, excluding raster.
const _baseline = <String, _Sample>{
  'enterTheory': (frames: 39, widgets: 396, runner: 1, peakMicros: 80000),
  // ACC-03 keyboard focus nodes (+6)
  'openDecision': (frames: 39, widgets: 709, runner: 2, peakMicros: 90000),
  'showFeedback': (frames: 152, widgets: 894, runner: 2, peakMicros: 120000),
  // ACC-03 keyboard focus nodes (+6)
  'openRepair': (frames: 19, widgets: 744, runner: 2, peakMicros: 120000),
  'showRecheck': (frames: 152, widgets: 835, runner: 2, peakMicros: 110000),
};

class _FrameBinding extends AutomatedTestWidgetsFlutterBinding {
  List<int>? frameMicros;

  @override
  void drawFrame() {
    final samples = frameMicros;
    if (samples == null) {
      super.drawFrame();
      return;
    }
    final clock = Stopwatch()..start();
    super.drawFrame();
    samples.add(clock.elapsedMicroseconds);
  }
}

Future<Map<String, _Sample>> _runFirstLesson(
  WidgetTester tester,
  _FrameBinding binding,
) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();

  final result = <String, _Sample>{};
  Future<void> tap(String transition, String label) async {
    final control = find.text(label).hitTestable();
    expect(control, findsOneWidget, reason: transition);
    var widgets = 0;
    var runner = 0;
    final frameMicros = <int>[];
    final previous = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      previous?.call(element, builtOnce);
      widgets++;
      if (element.widget is Act0LessonRunnerShellV1) runner++;
    };
    binding.frameMicros = frameMicros;
    try {
      await tester.tap(control);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 16));
    } finally {
      binding.frameMicros = null;
      debugOnRebuildDirtyWidget = previous;
    }
    expect(tester.takeException(), isNull, reason: transition);
    frameMicros.sort();
    result[transition] = (
      frames: frameMicros.length,
      widgets: widgets,
      runner: runner,
      peakMicros: frameMicros.last,
    );
  }

  await tap('enterTheory', 'Start with the basics');
  await tester.pump(const Duration(seconds: 1));
  await tap('openDecision', 'Next');
  await tap('showFeedback', 'The shared cards in the middle');
  await tap('openRepair', 'Try same clue');
  await tap('showRecheck', 'Board cards');
  expect(
    tester
        .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
        .runner
        .selectedOption
        ?.isCorrect,
    isTrue,
  );
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  return result;
}

int _median(Iterable<int> values) {
  final sorted = values.toList()..sort();
  return sorted[sorted.length ~/ 2];
}

void main() {
  final binding = _FrameBinding();
  testWidgets('W1 transitions stay within their frame and rebuild budgets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);
    expect(
      await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp()),
      isNotNull,
    );

    // Warm the assets and Dart code before collecting three complete samples.
    await _runFirstLesson(tester, binding);
    final runs = [
      for (var run = 0; run < 3; run++) await _runFirstLesson(tester, binding),
    ];

    for (final MapEntry(key: transition, value: baseline)
        in _baseline.entries) {
      final samples = runs.map((run) => run[transition]!).toList();
      final peak = _median(samples.map((sample) => sample.peakMicros));
      // ignore: avoid_print
      print('W1_FRAME_BUDGET $transition $samples medianPeakMicros=$peak');
      for (final sample in samples) {
        expect(
          sample.frames,
          lessThanOrEqualTo(baseline.frames),
          reason: '$transition frames',
        );
        expect(
          sample.widgets,
          lessThanOrEqualTo(baseline.widgets),
          reason: '$transition widget builds',
        );
        expect(
          sample.runner,
          lessThanOrEqualTo(baseline.runner),
          reason: '$transition lesson runner builds',
        );
      }
      expect(
        peak,
        lessThanOrEqualTo(baseline.peakMicros),
        reason: '$transition median peak draw in microseconds',
      );
    }
  });
}
