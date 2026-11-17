// Local-only evidence generator. It mounts the real production preview shell
// and uses its existing direct-state capture entry only for real source-owned
// W1 states; no substitute route or widget is introduced.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:crypto/crypto.dart' show sha256;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _device = String.fromEnvironment(
  'ACTION_EVIDENCE_DEVICE',
  defaultValue: 'compact',
);
const _root = String.fromEnvironment(
  'ACTION_EVIDENCE_OUTPUT',
  defaultValue: 'output/evidence/action_sequence_convergence_v1_$_device',
);
final _textScale =
    double.tryParse(
      const String.fromEnvironment(
        'ACTION_EVIDENCE_TEXT_SCALE',
        defaultValue: '1',
      ),
    ) ??
    1;
final _viewport = switch (_device) {
  'iphone14_pro' => const Size(393, 852),
  'iphone17_class' => const Size(402, 874),
  'tall_phone' => const Size(390, 844),
  'large_phone' => const Size(430, 932),
  _ => const Size(375, 812),
};
const _boundaryKey = Key('action_sequence_raster_boundary');
const _expectsWaveA = bool.fromEnvironment(
  'ACTION_EVIDENCE_EXPECT_WAVE_A',
  defaultValue: true,
);

// Route semantics are separate from the existing Wave A presentation flag.
const _comparisonRole = String.fromEnvironment(
  'ACTION_EVIDENCE_COMPARISON_ROLE',
  defaultValue: 'candidate',
);
const _routeContract = String.fromEnvironment(
  'ACTION_EVIDENCE_ROUTE_CONTRACT',
  defaultValue: 'canonical_goal_v1',
);
const _expectedProductSha = String.fromEnvironment(
  'ACTION_EVIDENCE_PRODUCT_SHA',
);
const _expectedCaptureSha = String.fromEnvironment(
  'ACTION_EVIDENCE_CAPTURE_OWNER_SHA256',
);
const _expectedLockSha = String.fromEnvironment('ACTION_EVIDENCE_LOCK_SHA256');
const _historicalBaselineSha = '22b3d0c868a3770b982697b81f3d420dd3d48332';
bool get _historicalBaselineRoute =>
    _routeContract == 'historical_check_self_22b3d0c';

Map<String, Object?> _captureSourceProvenance() {
  String gitValue(List<String> args) {
    final result = Process.runSync('git', args);
    expect(
      result.exitCode,
      0,
      reason: 'Capture source identity: ${result.stderr}',
    );
    return (result.stdout as String).trim();
  }

  final productSha = gitValue(['rev-parse', 'HEAD']);
  final productTree = gitValue(['rev-parse', 'HEAD^{tree}']);
  final unchanged = Process.runSync('git', [
    'diff',
    '--quiet',
    'HEAD',
    '--',
    'lib',
    'assets',
    'content',
    'packages',
    'third_party',
    'firebase_storage_stub',
    'appinio_swiper_stub',
    'pubspec.yaml',
  ]);
  expect(unchanged.exitCode, anyOf(0, 1));
  final exactProductSource = unchanged.exitCode == 0;
  if (_expectedProductSha.isNotEmpty || _comparisonRole == 'baseline') {
    expect(
      exactProductSource,
      isTrue,
      reason:
          'Declared product SHA requires unchanged product source; only capture/lock overlays are allowed.',
    );
  }
  final captureSha = sha256
      .convert(
        File(
          'test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart',
        ).readAsBytesSync(),
      )
      .toString();
  final lockSha = sha256
      .convert(File('pubspec.lock').readAsBytesSync())
      .toString();
  expect(_comparisonRole, anyOf('candidate', 'baseline'));
  expect(
    _routeContract,
    anyOf('canonical_goal_v1', 'historical_check_self_22b3d0c'),
  );
  if (_expectedProductSha.isNotEmpty) expect(productSha, _expectedProductSha);
  if (_expectedCaptureSha.isNotEmpty) expect(captureSha, _expectedCaptureSha);
  if (_expectedLockSha.isNotEmpty) expect(lockSha, _expectedLockSha);
  if (_comparisonRole == 'baseline') {
    expect(_expectedProductSha, matches(RegExp(r'^[0-9a-f]{40}$')));
    expect(_expectedCaptureSha, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(_expectedLockSha, matches(RegExp(r'^[0-9a-f]{64}$')));
  }
  if (_historicalBaselineRoute) {
    expect(_comparisonRole, 'baseline');
    expect(productSha, _historicalBaselineSha);
    expect(_expectedProductSha, _historicalBaselineSha);
  }
  return {
    'comparisonRole': _comparisonRole,
    'productSha': exactProductSource ? productSha : null,
    'productTree': exactProductSource ? productTree : null,
    'checkoutHead': productSha,
    'productSourceScope': exactProductSource
        ? 'exact_checkout'
        : 'local_uncommitted_source',
    'captureOwnerSha256': captureSha,
    'dependencyLockSha256': lockSha,
    'routeContract': _routeContract,
    'routeEvidenceClass': _historicalBaselineRoute
        ? 'historical_22b_legacy_action_dispatch_rendered_route'
        : 'current_goal_owned_rendered_route',
    'evidenceClass':
        'deterministic rendered widget evidence; not native/Human/application proof',
  };
}

void main() {
  setUpAll(() async {
    final fontFile =
        <File>[
          File('/System/Library/Fonts/Supplemental/Arial.ttf'),
          File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),
        ].firstWhere(
          (candidate) => candidate.existsSync(),
          orElse: () => throw StateError('No real-text test font found.'),
        );
    final bytes = await fontFile.readAsBytes();
    for (final family in <String>['Roboto', 'Ahem']) {
      await (FontLoader(
        family,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
    for (final candidate in const <(String, String)>[
      (
        'MaterialIcons',
        'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
      ),
      (
        'CupertinoIcons',
        'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
    ]) {
      final file = File(candidate.$2);
      if (!file.existsSync()) continue;
      final iconBytes = await file.readAsBytes();
      await (FontLoader(candidate.$1)
            ..addFont(Future<ByteData>.value(ByteData.sublistView(iconBytes))))
          .load();
    }
  });

  testWidgets('captures canonical W1 Action production states', (tester) async {
    final provenance = _captureSourceProvenance();
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
    const realTextStyle = TextStyle(fontFamily: 'Roboto');
    final realTextTheme = ThemeData(
      fontFamily: 'Roboto',
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
    );
    final out = Directory(_root)..createSync(recursive: true);
    final rows = <Map<String, Object?>>[];

    void writeGeometryMetrics({bool captureAssertionsPassed = false}) {
      File('${out.path}/raster_geometry_metrics.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(<String, Object?>{
              'viewport': <String, int>{
                'width': _viewport.width.toInt(),
                'height': _viewport.height.toInt(),
              },
              'textScale': _textScale,
              'provenance': provenance,
              'captureAssertionsPassed': captureAssertionsPassed,
              'states': rows,
            }) +
            '\n',
      );
    }

    Future<void> saveMounted(String name) async {
      File('${out.path}/$name.png').writeAsBytesSync(await _png(tester));
    }

    Future<void> capture({
      required String name,
      required Act0ControlledDemoCaptureSurfaceV1 surface,
      String taskId = 'actions_check_drill',
      String lessonId = 'fold_check_call_raise',
      String phase = 'selected',
      bool captureMountedState = false,
    }) async {
      final realRepair =
          surface == Act0ControlledDemoCaptureSurfaceV1.repairFocus ||
          surface == Act0ControlledDemoCaptureSurfaceV1.repairResult;
      if (!captureMountedState) {
        await tester.pumpWidget(
          MaterialApp(
            theme: realTextTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(_textScale)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: _boundaryKey,
              child: Act0ShellPreviewScreenV1(
                key: ValueKey<String>('action_sequence_capture_$name'),
                state: Act0ShellStateV1.sample,
                showPlacementOnStart: false,
                debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                  mode: Act0ControlledDemoCaptureModeV1.directState,
                  surface: realRepair
                      ? Act0ControlledDemoCaptureSurfaceV1.runnerDrill
                      : surface,
                  worldId: 'world_1',
                  lessonId: lessonId,
                  taskId: taskId,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (realRepair) {
          Future<void> tapKey(String key) async {
            final target = find.byKey(Key(key));
            expect(target, findsOneWidget, reason: key);
            await tester.ensureVisible(target);
            await tester.tap(target);
            await tester.pumpAndSettle();
          }

          Future<void> advanceTo(String choice) async {
            final answer = find.byKey(Key('act0_shell_option_$choice'));
            for (var i = 0; i < 12 && answer.evaluate().isEmpty; i++) {
              await tapKey('act0_shell_continue_cta');
            }
            expect(answer, findsOneWidget);
          }

          await advanceTo('fold');
          await tester.pump(const Duration(seconds: 3));
          await tapKey('act0_shell_option_fold');
          await tapKey('act0_shell_runner_back');
          final review = find.descendant(
            of: find.byKey(const Key('act0_shell_bottom_nav')),
            matching: find.text('Review'),
          );
          expect(review, findsOneWidget);
          await tester.tap(review);
          await tester.pumpAndSettle();
          await tapKey(
            act0AcademyReviewPreviewV1
                ? 'act0_academy_review_leaf_repair_cta'
                : 'act0_shell_review_practice_cta',
          );
          final current = tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
          expect(current.selectedTaskId, 'actions_check_drill');
          final dynamic shell = tester.state(
            find.byType(Act0ShellPreviewScreenV1),
          );
          expect(
            shell.debugActiveRepairContextPayloadV1()['sourceTaskId'],
            'actions_legal_context',
          );
          await advanceTo('check');
          if (surface == Act0ControlledDemoCaptureSurfaceV1.repairResult) {
            await tester.pump(const Duration(seconds: 3));
            await tapKey('act0_shell_option_check');
            expect(
              find.byKey(const Key('act0_shell_feedback_card')),
              findsOneWidget,
            );
            expect(shell.debugRepairOutcomeProjectionPayloadV1(), hasLength(1));
          }
        }
      }
      final bytes = await _png(tester);
      File('${out.path}/$name.png').writeAsBytesSync(bytes);
      final runnerRoots = find
          .byKey(const Key('act0_shell_runner_screen'))
          .evaluate()
          .length;
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      final runner = runnerFinder.evaluate().isEmpty
          ? null
          : tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
      if (_expectsWaveA) {
        final expectedPurpose = switch (runner?.runner.phase) {
          Act0LessonPhaseV1.theory => 'ONE TABLE IDEA',
          Act0LessonPhaseV1.drill => 'YOUR MOVE',
          Act0LessonPhaseV1.review =>
            runner!.runner.reviewQuality == Act0FeedbackQualityV1.wrong
                ? 'MISSED CLUE'
                : 'CORRECT READ',
          null => throw StateError('Expected an Act0 lesson runner for $name'),
        };
        expect(
          find.byKey(const Key('act0_wave_a_learning_context')),
          findsOneWidget,
        );
        expect(find.text(expectedPurpose), findsOneWidget);
      }
      final table = find.byKey(const Key('act0_shell_table'));
      final rect = table.evaluate().isEmpty ? null : tester.getRect(table);
      Map<String, double>? rectData(Finder finder) {
        if (finder.evaluate().isEmpty) return null;
        final value = tester.getRect(finder.first);
        return <String, double>{
          'left': value.left,
          'top': value.top,
          'width': value.width,
          'height': value.height,
        };
      }

      final promptRect = rectData(
        find.byKey(const Key('act0_integrated_scene_prompt')),
      );
      final silhouetteRect = rectData(
        find.byKey(const Key('act0_integrated_scene_perspective_silhouette')),
      );
      final actionRect = rectData(
        find.byKey(const Key('act0_integrated_scene_action_foreground')),
      );
      final heroRect = rectData(
        find.byWidgetPredicate(
          (widget) =>
              widget.key?.toString().contains('act0_shell_hero_identity_') ??
              false,
        ),
      );
      final depthAnchors = <String, Map<String, double>>{};
      for (final element
          in find
              .byWidgetPredicate(
                (widget) =>
                    widget.key?.toString().contains(
                      'act0_integrated_scene_depth_',
                    ) ??
                    false,
              )
              .evaluate()) {
        final key = element.widget.key?.toString() ?? 'unknown';
        final anchorRect = tester.getRect(
          find.byElementPredicate((candidate) {
            return identical(candidate, element);
          }),
        );
        depthAnchors[key] = <String, double>{
          'centerX': anchorRect.center.dx,
          'centerY': anchorRect.center.dy,
          'width': anchorRect.width,
          'height': anchorRect.height,
        };
      }
      final stableBounds = find.byKey(
        const Key('act0_task_owned_practice_table_bounds'),
      );
      final stableRect = stableBounds.evaluate().isEmpty
          ? null
          : tester.getRect(stableBounds);
      final informativeObjectCollisions = <Map<String, Object?>>[];
      for (final seatId in const <String>['sb', 'bb']) {
        final seat = find.byKey(Key('act0_shell_seat_node_$seatId'));
        final chip = find.byKey(Key('act0_shell_bet_chip_owner_$seatId'));
        if (seat.evaluate().isEmpty || chip.evaluate().isEmpty) continue;
        final seatRect = tester.getRect(seat);
        final chipRect = tester.getRect(chip);
        informativeObjectCollisions.add(<String, Object?>{
          'objects': <String>['seat:$seatId', 'chip:$seatId'],
          'overlap': seatRect.overlaps(chipRect),
          'seatBounds': <String, double>{
            'left': seatRect.left,
            'top': seatRect.top,
            'right': seatRect.right,
            'bottom': seatRect.bottom,
          },
          'chipBounds': <String, double>{
            'left': chipRect.left,
            'top': chipRect.top,
            'right': chipRect.right,
            'bottom': chipRect.bottom,
          },
        });
      }
      if (_expectsWaveA) {
        expect(
          informativeObjectCollisions.every((row) => row['overlap'] == false),
          isTrue,
          reason:
              '$name must keep blind chips outside their informative seats. '
              '${jsonEncode(informativeObjectCollisions)}',
        );
      }
      if (captureMountedState) {
        rows.removeWhere((row) => row['name'] == name);
      }
      rows.add(<String, Object?>{
        'name': name,
        'phase': phase,
        'taskId': taskId,
        'owner': 'Act0ShellPreviewScreenV1',
        'comparisonRole': provenance['comparisonRole'],
        'productSha': provenance['productSha'],
        'captureOwnerSha256': provenance['captureOwnerSha256'],
        'routeContract': provenance['routeContract'],
        'sequenceId': 'w1_action_words_check_v1',
        'tableContextRelation': 'related_read',
        'runnerRootCount': runnerRoots,
        'runnerPhase': runner?.runner.phase.name,
        'runnerSelectedTaskId': runner?.selectedTaskId,
        'runnerTeachingStepIndex': runner?.runner.teachingStepIndex,
        'runnerTeachingStepCount': runner?.runner.teachingSteps.length,
        'eligibleTableObjects': find
            .byWidgetPredicate(
              (widget) =>
                  widget.key?.toString().contains('act0_shell_seat_tap_') ??
                  false,
            )
            .evaluate()
            .length,
        'stablePracticeSelected': stableRect != null,
        'stablePracticeBounds': stableRect == null
            ? null
            : <String, double>{
                'left': stableRect.left,
                'top': stableRect.top,
                'width': stableRect.width,
                'height': stableRect.height,
              },
        'table': rect == null
            ? null
            : <String, double>{
                'left': rect.left,
                'top': rect.top,
                'width': rect.width,
                'height': rect.height,
              },
        'integratedGeometry': <String, Object?>{
          'promptEnvelope': promptRect,
          'tableSceneAllocation': rect?.height,
          'visibleTableBounds': silhouetteRect,
          'heroBounds': heroRect,
          'heroY': heroRect?['top'],
          'actionEnvelope': actionRect,
          'actionEnvelopeTop': actionRect?['top'],
          'explicitTableScale': 1.0,
          'seatAnchors': depthAnchors,
        },
        'informativeObjectCollisions': informativeObjectCollisions,
        'overflow': tester.takeException()?.toString(),
      });
      writeGeometryMetrics();
      expect(tester.takeException(), isNull);
    }

    await capture(
      name: 'theory',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
      taskId: 'actions_theory',
      phase: 'theory',
    );
    await capture(
      name: 'first_lesson_theory_1',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
      lessonId: 'what_poker_is',
      taskId: 'what_poker_is_theory',
      phase: 'first_lesson_theory_1',
    );
    if (_expectsWaveA) {
      expect(find.text('One loop first.'), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
    await tester.pumpAndSettle();
    if (_expectsWaveA) {
      expect(find.text('Start with the table.'), findsOneWidget);
    }
    await saveMounted('first_lesson_theory_2');
    await capture(
      name: 'table_object_task',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      lessonId: 'what_poker_is',
      taskId: 'what_poker_is_find_hero',
      phase: 'table_object_task',
    );
    final tappableSeats = find.byWidgetPredicate(
      (widget) =>
          widget.key?.toString().contains('act0_shell_seat_tap_') ?? false,
    );
    final mountedRunner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final usesSeatTapOptions = mountedRunner.runner.options.any(
      (option) => option.seatId != null,
    );
    const seatTapPrompt = 'Tap one equally highlighted seat on the table.';
    const abstractPrompt =
        'Which label could change next hand while the player is still you?';
    if (usesSeatTapOptions) {
      expect(tappableSeats, findsAtLeastNWidgets(2));
    } else {
      for (final optionId in const <String>['top', 'bottom', 'random']) {
        expect(find.byKey(Key('act0_shell_option_$optionId')), findsOneWidget);
      }
      expect(find.text(seatTapPrompt), findsNothing);
    }
    if (_expectsWaveA) {
      expect(
        find.text(usesSeatTapOptions ? seatTapPrompt : abstractPrompt),
        findsOneWidget,
      );
    }
    await capture(
      name: 'decision',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      phase: 'decision',
    );
    await capture(
      name: 'correct_feedback',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback,
      phase: 'correct_feedback',
    );
    await capture(
      name: 'wrong_feedback',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
      phase: 'wrong_feedback',
    );
    await capture(
      name: 'targeted_repair',
      surface: Act0ControlledDemoCaptureSurfaceV1.repairFocus,
      taskId: 'actions_legal_context',
      phase: 'existing_repair_surface',
    );
    await capture(
      name: 'repair_success',
      surface: Act0ControlledDemoCaptureSurfaceV1.repairResult,
      taskId: 'actions_legal_context',
      phase: 'existing_repair_result_surface',
    );

    final ctaHitRows = <Map<String, Object?>>[];
    final feedbackAllocationRows = <Map<String, Object?>>[];

    void recordCtaHitGeometry(String state) {
      final target = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final rect = tester.getRect(target);
      final targetBox = tester.renderObject<RenderBox>(target);
      final insetX = rect.width < 24 ? rect.width / 4 : 8.0;
      final insetY = rect.height < 24 ? rect.height / 4 : 8.0;
      final samples = <String, Offset>{
        'center': rect.center,
        'upperLeft': Offset(rect.left + insetX, rect.top + insetY),
        'upperRight': Offset(rect.right - insetX, rect.top + insetY),
        'lowerLeft': Offset(rect.left + insetX, rect.bottom - insetY),
        'lowerRight': Offset(rect.right - insetX, rect.bottom - insetY),
        'outsideLeft': Offset(rect.left - 6, rect.center.dy),
      };
      bool hitsTarget(Offset point) => tester
          .hitTestOnBinding(point)
          .path
          .any((entry) => identical(entry.target, targetBox));
      ctaHitRows.add(<String, Object?>{
        'state': state,
        'visibleOwner': 'FilledButton#act0_shell_feedback_continue_cta',
        'hitOwner': targetBox.runtimeType.toString(),
        'bounds': <String, double>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'width': rect.width,
          'height': rect.height,
        },
        'samples': <String, bool>{
          for (final sample in samples.entries)
            sample.key: hitsTarget(sample.value),
        },
      });
    }

    Future<void> recordFeedbackAllocation(String state) async {
      final body = find.byKey(
        const Key('act0_shell_feedback_allocated_body_scroll'),
      );
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final primaryResult = find.byKey(
        const Key('act0_shell_feedback_primary_result_label'),
      );
      expect(body, findsOneWidget);
      expect(primaryResult, findsOneWidget);
      final bodyEnd = find.byKey(
        Key(
          state == 'wrong_feedback'
              ? 'act0_shell_feedback_missed_cue_treatment'
              : 'act0_shell_feedback_non_miss_treatment',
        ),
      );
      expect(bodyEnd, findsOneWidget);
      final position = Scrollable.of(tester.element(bodyEnd)).position;
      final bodyRect = tester.getRect(body);
      final primaryResultRect = tester.getRect(primaryResult);
      final ctaBefore = tester.getRect(cta);
      final maxScrollExtent = position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        await tester.ensureVisible(bodyEnd);
        await tester.pumpAndSettle();
      }
      final ctaAfter = tester.getRect(cta);
      feedbackAllocationRows.add(<String, Object?>{
        'state': state,
        'bodyViewport': <String, double>{
          'left': bodyRect.left,
          'top': bodyRect.top,
          'width': bodyRect.width,
          'height': bodyRect.height,
        },
        'primaryResultInitiallyVisible':
            primaryResultRect.top >= bodyRect.top &&
            primaryResultRect.bottom <= bodyRect.bottom,
        'maxScrollExtent': maxScrollExtent,
        'reachedBodyEnd':
            maxScrollExtent == 0 ||
            (position.pixels - maxScrollExtent).abs() < 0.5,
        'ctaPinnedWhileBodyScrolled': ctaBefore == ctaAfter,
      });
    }

    Future<void> tapVisible(Finder target) async {
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      final rect = tester.getRect(target);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(_viewport.height));
      await tester.tap(target);
    }

    Future<void> advanceToVisibleChoice({
      required String expectedTaskId,
      required String choiceId,
    }) async {
      final choice = find.byKey(Key('act0_shell_option_$choiceId'));
      for (var step = 0; step < 12; step++) {
        final current = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(current.selectedTaskId, expectedTaskId);
        expect(current.runner.selectedOptionId, isNull);
        if (current.runner.phase == Act0LessonPhaseV1.drill &&
            choice.evaluate().isNotEmpty) {
          // Ordinary animation time only. An already-ready prompt needs no
          // extra Continue; no answer, status or evidence is injected.
          for (var beat = 0; beat < 6; beat++) {
            await tester.pump(const Duration(milliseconds: 500));
          }
          await tester.pumpAndSettle();
          expect(choice.hitTestable(), findsOneWidget);
          return;
        }
        await tapVisible(find.byKey(const Key('act0_shell_continue_cta')));
        await tester.pumpAndSettle();
      }
      fail('Authored choice $choiceId was not ready for $expectedTaskId.');
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: realTextTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: _boundaryKey,
          child: Act0ShellPreviewScreenV1(
            key: const ValueKey<String>('wave_a_first_lesson_landing'),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.wave2LearnFresh,
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              taskId: 'what_poker_is_theory',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await saveMounted('first_lesson_landing');
    expect(
      find.byKey(const Key('act0_shell_current_mission_cta')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: realTextTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: _boundaryKey,
          child: Act0ShellPreviewScreenV1(
            key: const ValueKey<String>('wave_a_table_object_ack'),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              taskId: 'what_poker_is_find_hero',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tapVisible(
      find.byKey(
        Key(
          usesSeatTapOptions
              ? 'act0_shell_seat_tap_btn'
              : 'act0_shell_option_bottom',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await saveMounted('table_object_evaluated');
    if (usesSeatTapOptions) {
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.key?.toString().contains(
                'act0_shell_seat_state_btn_confirmedSelected',
              ) ??
              false,
        ),
        findsOneWidget,
      );
    } else {
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: realTextTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: _boundaryKey,
          child: Act0ShellPreviewScreenV1(
            key: const ValueKey<String>('action_sequence_live_wrong_route'),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_check_drill',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final source = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final actionSourceTaskId = source.selectedTaskId!;
    expect(actionSourceTaskId, 'actions_check_drill');
    final wrongChoice = source.runner.options.firstWhere(
      (option) => !option.isCorrect,
    );
    await advanceToVisibleChoice(
      expectedTaskId: actionSourceTaskId,
      choiceId: wrongChoice.id,
    );
    await tapVisible(find.byKey(Key('act0_shell_option_${wrongChoice.id}')));
    await tester.pumpAndSettle();
    final submittedSource = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(submittedSource.runner.selectedOptionId, wrongChoice.id);
    expect(submittedSource.runner.selectedOption!.isCorrect, isFalse);
    final dynamic liveRoot = tester.state(
      find.byType(Act0ShellPreviewScreenV1),
    );
    final rawIntent =
        liveRoot.debugOpenRepairIntentPayloadForSourceTaskV1(actionSourceTaskId)
            as Map<String, Object?>?;
    expect(
      rawIntent,
      isNotNull,
      reason:
          'The visible wrong answer must create its actual canonical repair intent.',
    );
    final intent = rawIntent!;
    final declaredRepairTaskId = intent['targetTaskId'] as String;
    expect(declaredRepairTaskId, 'actions_legal_context');
    final actionRepairTaskId = _historicalBaselineRoute
        ? 'actions_check_drill'
        : declaredRepairTaskId;
    final sourceOccurrenceId = intent['repairOccurrenceId'] as String;
    expect(sourceOccurrenceId, isNotEmpty);
    expect(intent['sourceTaskId'], actionSourceTaskId);
    expect(intent['choiceId'], wrongChoice.id);
    expect(intent['targetWorldId'], 'world_1');
    expect(intent['targetLessonId'], 'fold_check_call_raise');
    if (_historicalBaselineRoute) {
      // Exact immutable22b baseline only: observe its older self-Check Action dispatch. The stored intent still names Legal.
      expect(actionRepairTaskId, 'actions_check_drill');
    } else {
      // The new candidate must never fall back to the historical same-task route.
      expect(actionRepairTaskId, 'actions_legal_context');
      for (final key in [
        'goalId',
        'relationId',
        'sourceFingerprint',
        'targetFingerprint',
      ]) {
        expect(intent[key], isNotEmpty, reason: 'Current source-owned $key.');
      }
      expect(intent['relationRevision'], greaterThan(0));
    }
    await capture(
      name: 'wrong_feedback',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFeedback,
      taskId: actionSourceTaskId,
      phase: 'wrong_feedback',
      captureMountedState: true,
    );
    recordCtaHitGeometry('wrong_feedback');
    await recordFeedbackAllocation('wrong_feedback');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    final repair = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(repair.selectedTaskId, actionRepairTaskId);
    if (_historicalBaselineRoute) {
      expect(
        liveRoot.debugActiveRepairContextPayloadV1(),
        isEmpty,
        reason:
            'Exact22b inline Action dispatch never starts the mapped Legal repair.',
      );
    } else {
      expect(
        liveRoot.debugActiveRepairContextPayloadV1()['sourceTaskId'],
        actionSourceTaskId,
      );
    }
    final repairChoice = repair.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    await advanceToVisibleChoice(
      expectedTaskId: actionRepairTaskId,
      choiceId: repairChoice.id,
    );
    await capture(
      name: 'targeted_repair',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      taskId: actionRepairTaskId,
      phase: 'targeted_repair',
      captureMountedState: true,
    );
    await tapVisible(find.byKey(Key('act0_shell_option_${repairChoice.id}')));
    await tester.pumpAndSettle();
    final submittedRepair = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(submittedRepair.selectedTaskId, actionRepairTaskId);
    expect(submittedRepair.runner.selectedOptionId, repairChoice.id);
    expect(submittedRepair.runner.selectedOption!.isCorrect, isTrue);
    final outcomes = (liveRoot.debugRepairOutcomeProjectionPayloadV1() as List)
        .cast<Map<String, Object?>>();
    final Map<String, Object?>? canonicalRepair;
    if (_historicalBaselineRoute) {
      expect(
        outcomes,
        isEmpty,
        reason:
            'Exact22b records the visible Check decision without a mapped repair request.',
      );
      canonicalRepair = null;
    } else {
      canonicalRepair = outcomes.singleWhere(
        (outcome) => outcome['repairOccurrenceId'] == sourceOccurrenceId,
      );
      expect(canonicalRepair['sourceTaskId'], actionSourceTaskId);
      expect(canonicalRepair['targetTaskId'], actionRepairTaskId);
      expect(canonicalRepair['selectedChoiceId'], repairChoice.id);
      expect(canonicalRepair['isCorrect'], isTrue);
      expect(canonicalRepair['repairAttemptId'], isNotEmpty);
    }
    await capture(
      name: 'repair_success',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFeedback,
      taskId: actionRepairTaskId,
      phase: 'repair_success',
      captureMountedState: true,
    );
    recordCtaHitGeometry('repair_success');
    await recordFeedbackAllocation('repair_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    final recheck = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(recheck.selectedTaskId, actionSourceTaskId);
    final recheckChoice = recheck.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    await advanceToVisibleChoice(
      expectedTaskId: actionSourceTaskId,
      choiceId: recheckChoice.id,
    );
    await capture(
      name: 'targeted_recheck',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      taskId: actionSourceTaskId,
      phase: 'targeted_recheck',
      captureMountedState: true,
    );
    await tapVisible(find.byKey(Key('act0_shell_option_${recheckChoice.id}')));
    await tester.pumpAndSettle();
    final submittedRecheck = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(submittedRecheck.selectedTaskId, actionSourceTaskId);
    expect(submittedRecheck.runner.selectedOptionId, recheckChoice.id);
    expect(submittedRecheck.runner.selectedOption!.isCorrect, isTrue);
    if (_historicalBaselineRoute) {
      expect(liveRoot.debugActiveRepairContextPayloadV1(), isEmpty);
      expect(liveRoot.debugRepairOutcomeProjectionPayloadV1(), isEmpty);
    }
    await capture(
      name: 'recheck_success',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFeedback,
      taskId: actionSourceTaskId,
      phase: 'recheck_success',
      captureMountedState: true,
    );
    recordCtaHitGeometry('recheck_success');
    await recordFeedbackAllocation('recheck_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('completion');
    await tester.pumpAndSettle();
    await saveMounted('next_step');
    File('${out.path}/action_route_receipt.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
            'provenance': provenance,
            'sourceTaskId': actionSourceTaskId,
            'sourceChoiceId': wrongChoice.id,
            'sourceOccurrenceId': sourceOccurrenceId,
            'declaredRepairTaskId': declaredRepairTaskId,
            'launchedTargetMatchesDeclaredIntent':
                actionRepairTaskId == declaredRepairTaskId,
            'repairTaskId': actionRepairTaskId,
            'repairChoiceId': repairChoice.id,
            'repairAttemptId': canonicalRepair?['repairAttemptId'],
            'recordedRepairOutcome': canonicalRepair,
            'canonicalOutcomeStatus': _historicalBaselineRoute
                ? 'historical_inline_stage_no_mapped_outcome'
                : 'current_goal_bound_actual_attempt',
            'observedRepairIsCorrect':
                submittedRepair.runner.selectedOption!.isCorrect,
            'recheckTaskId': submittedRecheck.selectedTaskId,
            'recheckChoiceId': recheckChoice.id,
            'historicalCurrentGoalValidityClaimed': false,
            'routeScope': _historicalBaselineRoute
                ? 'Exact22b inline Action display with no active mapped repair or canonical outcome; raw choice/grade observed, no current goal/proof admission.'
                : 'Current source-owned relation and actual canonical attempts; no independent application/native/Human proof.',
          }) +
          '\n',
    );

    writeGeometryMetrics();
    final ctaHitGeometryJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(ctaHitRows);
    File(
      '${out.path}/cta_hit_geometry.json',
    ).writeAsStringSync('$ctaHitGeometryJson\n');
    final feedbackAllocationJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(feedbackAllocationRows);
    File(
      '${out.path}/feedback_allocation_geometry.json',
    ).writeAsStringSync('$feedbackAllocationJson\n');
    File('${out.path}/raster_state_inventory.md').writeAsStringSync(
      '''# Canonical Action raster inventory

Product source: `${provenance['productSha']}` / `${provenance['productTree']}`.
Capture owner: `${provenance['captureOwnerSha256']}`. Role: `$_comparisonRole`.
Route contract: `$_routeContract` (${provenance['routeEvidenceClass']}).

The same collector mounts `Act0ShellPreviewScreenV1` on each exact product tree.
Theory, decision, and initial feedback use existing production capture entries.
The live route records a real wrong choice on `$actionSourceTaskId`, follows the
observed `$actionRepairTaskId`, taps its real correct choice and the original
source recheck, then records completion and the next rendered state. The current
candidate requires Check -> Legal actions -> Check with full current witnesses.
Only exact22b baseline may use its historical Check -> Check -> Check Action dispatch despite its stored Legal intent;
its recorded outcomes are historical observations, not current goal validation.
Capture names remain matched by phase, not a claim of identical task semantics.
The collector remeasures already-mounted states, so geometry and actual
`runnerSelectedTaskId` describe the final PNGs. No native/Human/application proof.
''',
    );
    _sheet(out, <String>[
      'first_lesson_theory_1',
      'first_lesson_theory_2',
      'table_object_task',
      'table_object_evaluated',
    ], 'wave_a_first_lesson_contact_sheet.png');
    _sheet(out, <String>[
      'theory',
      'table_object_task',
      'decision',
      'correct_feedback',
      'wrong_feedback',
    ], 'wave_a_learning_sequence_contact_sheet.png');
    _sheet(out, <String>[
      'theory',
      'decision',
      'correct_feedback',
      'wrong_feedback',
    ], 'canonical_sequence_contact_sheet.png');
    _sheet(out, <String>[
      'first_lesson_landing',
      'table_object_task',
      'table_object_evaluated',
    ], 'wave_a_entry_and_interaction_contact_sheet.png');
    _sheet(out, <String>[
      'wrong_feedback',
      'targeted_repair',
      'repair_success',
      'targeted_recheck',
      'recheck_success',
    ], 'wrong_repair_recheck_contact_sheet.png');
    _sheet(out, <String>[
      'correct_feedback',
      'recheck_success',
      'completion',
      'next_step',
    ], 'correct_completion_contact_sheet.png');
    _sheet(out, <String>[
      'theory',
      'decision',
      'wrong_feedback',
    ], 'runner_control_contact_sheet.png');
    expect(
      ctaHitRows.every((row) {
        final bounds = row['bounds']! as Map<String, double>;
        final samples = row['samples']! as Map<String, bool>;
        return bounds['height']! >= 44 &&
            samples['center']! &&
            samples['upperLeft']! &&
            samples['upperRight']! &&
            samples['lowerLeft']! &&
            samples['lowerRight']! &&
            !samples['outsideLeft']!;
      }),
      isTrue,
      reason: 'Every visible feedback CTA must retain usable hit geometry.',
    );
    expect(
      feedbackAllocationRows.every(
        (row) =>
            row['primaryResultInitiallyVisible'] == true &&
            row['reachedBodyEnd'] == true &&
            row['ctaPinnedWhileBodyScrolled'] == true,
      ),
      isTrue,
      reason:
          'Feedback content must remain reachable while the CTA stays pinned.',
    );
    writeGeometryMetrics(captureAssertionsPassed: true);
    final pngs =
        out
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    File('${out.path}/capture_file_manifest.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
            'provenance': provenance,
            'captureAssertionsPassed': true,
            'pngs': [
              for (final file in pngs)
                {
                  'name': file.uri.pathSegments.last,
                  'bytes': file.lengthSync(),
                  'sha256': sha256.convert(file.readAsBytesSync()).toString(),
                },
            ],
          }) +
          '\n',
    );
  });
}

Future<Uint8List> _png(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundaryKey),
  );
  final data = await tester.runAsync(
    () async => (await boundary.toImage(
      pixelRatio: 1,
    )).toByteData(format: ui.ImageByteFormat.png),
  );
  if (data == null) throw StateError('PNG capture failed');
  return Uint8List.view(data.buffer);
}

void _sheet(Directory out, List<String> names, String fileName) {
  final images = names
      .map(
        (name) =>
            image.decodePng(File('${out.path}/$name.png').readAsBytesSync())!,
      )
      .toList();
  final canvas = image.Image(
    width: images.first.width * images.length,
    height: images.first.height,
  );
  for (var index = 0; index < images.length; index++) {
    image.compositeImage(
      canvas,
      images[index],
      dstX: images.first.width * index,
    );
  }
  File('${out.path}/$fileName').writeAsBytesSync(image.encodePng(canvas));
}
