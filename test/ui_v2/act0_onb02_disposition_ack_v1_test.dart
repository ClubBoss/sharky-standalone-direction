// SIMULATED widget/in-memory persistence failures only. No native fault injection.
// A refused disposition write must not become welcome/skip completion or navigation.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_first_start_preferences_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('SIMULATED ONB idle owner finishes in the unit-test zone', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Act0FirstStartPreferencesV1.setWelcomeCompleted();
    expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isTrue);
  });

  testWidgets('SIMULATED ONB idle owner crosses unit to widget zone', (
    tester,
  ) async {
    // Reset only the backend fixture, never the owner's operation queue.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    bool? completed;
    final read = Act0FirstStartPreferencesV1.hasCompletedWelcome().then((
      value,
    ) {
      completed = value;
    });
    await tester.pump();
    expect(
      completed,
      isFalse,
      reason: 'An idle owner must use the current zone.',
    );
    await read;
  });

  test('SIMULATED ONB idle owner crosses widget to unit zone', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Act0FirstStartPreferencesV1.setIntroductionSkipped();
    expect(await Act0FirstStartPreferencesV1.hasSkippedIntroduction(), isTrue);
  });

  for (final kind in ['welcome', 'skip']) {
    test('SIMULATED $kind acknowledged positive control', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final original = SharedPreferencesStorePlatform.instance;
      final gate = _DispositionGate(original, kind, 'none')..reject = false;
      SharedPreferencesStorePlatform.instance = gate;
      addTearDown(() => SharedPreferencesStorePlatform.instance = original);
      if (kind == 'welcome') {
        await Act0FirstStartPreferencesV1.setWelcomeCompleted();
        expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isTrue);
      } else {
        await Act0FirstStartPreferencesV1.setIntroductionSkipped();
        expect(
          await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
          isTrue,
        );
      }
      expect(gate.calls, 1);
      expect((await original.getAll())[gate.key], true);
    });
    for (final failure in ['false', 'throw']) {
      test(
        'SIMULATED $kind refuses $failure ACK without cached completion',
        () async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final original = SharedPreferencesStorePlatform.instance;
          final gate = _DispositionGate(original, kind, failure);
          SharedPreferencesStorePlatform.instance = gate;
          addTearDown(() => SharedPreferencesStorePlatform.instance = original);
          final write = kind == 'welcome'
              ? Act0FirstStartPreferencesV1.setWelcomeCompleted
              : Act0FirstStartPreferencesV1.setIntroductionSkipped;
          await expectLater(write(), throwsStateError);
          final completed = kind == 'welcome'
              ? await Act0FirstStartPreferencesV1.hasCompletedWelcome()
              : await Act0FirstStartPreferencesV1.hasSkippedIntroduction();
          expect(
            completed,
            isFalse,
            reason:
                'An unacknowledged write cannot become a cached disposition.',
          );
          expect(gate.calls, 1);
          final disk = await original.getAll();
          expect(disk.containsKey(gate.key), isFalse);
        },
      );
    }
  }

  for (final failure in ['none', 'false', 'throw']) {
    testWidgets('SIMULATED welcome stays retryable after $failure ACK', (
      tester,
    ) async {
      // Explicit valid widget fixture: intake finished, Welcome not yet finished.
      // This is not first-use native or Human evidence.
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
      });
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final original = SharedPreferencesStorePlatform.instance;
      _DispositionGate? gate;
      addTearDown(() async {
        try {
          if (gate != null) {
            gate.reject = false;
            gate.release();
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await _drainOnbOwner(tester);
          await tester.runAsync(
            () => Act0ProgressStoreV1(
              key: 'act0_shell_progress_v1',
              isValidPayload: (_) => false,
            ).flush(),
          );
        } finally {
          SharedPreferencesStorePlatform.instance = original;
        }
      });
      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();
      expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
      Future<void> tap(Key key) async {
        final target = find.byKey(key);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tap(const Key('act0_shell_welcome_primary_cta'));
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      // Welcome demo is explicitly ungraded; either real source choice reaches handoff.
      await tap(Key('act0_shell_option_${runner.runner.options.first.id}'));
      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
      gate = _DispositionGate(original, 'welcome', failure)
        ..reject = failure != 'none';
      SharedPreferencesStorePlatform.instance = gate;
      await tap(const Key('act0_shell_welcome_primary_cta'));
      expect(gate.calls, 1);
      if (failure == 'none') {
        expect(find.byType(Act0WelcomeShellV1), findsNothing);
        expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isTrue);
        expect((await original.getAll())[gate.key], true);
        expect(tester.takeException(), isNull);
        return;
      }
      expect(
        find.byType(Act0WelcomeShellV1),
        findsOneWidget,
        reason: 'Refused save must not advance the live production route.',
      );
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isFalse);
      gate.reject = false;
      await tap(const Key('act0_shell_welcome_primary_cta'));
      expect(find.byType(Act0WelcomeShellV1), findsNothing);
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  for (final refuse in [false, true]) {
    test(
      'SIMULATED ONB neighbor read waits for pending ACK: refuse=$refuse',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final original = SharedPreferencesStorePlatform.instance;
        final gate = _DispositionGate(original, 'welcome', 'false')
          ..reject = refuse
          ..held = Completer<void>()
          ..entered = Completer<void>();
        SharedPreferencesStorePlatform.instance = gate;
        addTearDown(() {
          gate.release();
          SharedPreferencesStorePlatform.instance = original;
        });
        final write = Act0FirstStartPreferencesV1.setWelcomeCompleted()
            .then<Object?>((_) => null, onError: (Object error) => error);
        var readCompleted = false;
        Future<bool>? read;
        Object? writeError;
        bool? observed;
        try {
          await gate.entered!.future;
          read = Act0FirstStartPreferencesV1.hasCompletedWelcome().then((
            value,
          ) {
            readCompleted = true;
            return value;
          });
          await Future<void>.delayed(Duration.zero);
          expect(
            readCompleted,
            isFalse,
            reason: 'Provisional cache is not a read receipt.',
          );
        } finally {
          gate.release();
          writeError = await write;
          if (read != null) observed = await read;
        }
        expect(writeError, refuse ? isA<StateError>() : isNull);
        expect(observed, !refuse);
        expect(gate.calls, 1);
      },
    );
  }

  test('SIMULATED ONB neighbor reset follows an older pending write', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onb_keep': 'keep',
    });
    final original = SharedPreferencesStorePlatform.instance;
    final gate = _DispositionGate(original, 'welcome', 'none')
      ..reject = false
      ..held = Completer<void>()
      ..entered = Completer<void>();
    SharedPreferencesStorePlatform.instance = gate;
    addTearDown(() {
      gate.release();
      SharedPreferencesStorePlatform.instance = original;
    });
    final write = Act0FirstStartPreferencesV1.setWelcomeCompleted();
    var resetCompleted = false;
    Future<void>? reset;
    try {
      await gate.entered!.future;
      reset = Act0FirstStartPreferencesV1.resetWelcome().then((_) {
        resetCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);
      expect(resetCompleted, isFalse);
    } finally {
      gate.release();
      await write;
      if (reset != null) await reset;
    }
    expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isFalse);
    expect(await Act0FirstStartPreferencesV1.hasSkippedIntroduction(), isFalse);
    expect(
      (await SharedPreferences.getInstance()).getString('onb_keep'),
      'keep',
    );
  });

  for (final kind in ['welcome', 'skip']) {
    test(
      'SIMULATED ONB neighbor preserves prior acknowledged $kind truth',
      () async {
        final key = kind == 'welcome'
            ? 'act0_welcome_completed_v1'
            : 'act0_introduction_skipped_v1';
        SharedPreferences.setMockInitialValues(<String, Object>{key: true});
        final original = SharedPreferencesStorePlatform.instance;
        final gate = _DispositionGate(original, kind, 'false');
        SharedPreferencesStorePlatform.instance = gate;
        addTearDown(() => SharedPreferencesStorePlatform.instance = original);
        final write = kind == 'welcome'
            ? Act0FirstStartPreferencesV1.setWelcomeCompleted
            : Act0FirstStartPreferencesV1.setIntroductionSkipped;
        await expectLater(write(), throwsStateError);
        expect(
          kind == 'welcome'
              ? await Act0FirstStartPreferencesV1.hasCompletedWelcome()
              : await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
          isTrue,
        );
        expect((await original.getAll())[gate.key], true);
      },
    );
  }

  test(
    'SIMULATED ONB neighbor normal reset retains unrelated preferences',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'act0_introduction_skipped_v1': true,
        'onb_keep': 'keep',
      });
      await Act0FirstStartPreferencesV1.resetWelcome();
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isFalse);
      expect(
        await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
        isFalse,
      );
      expect(
        (await SharedPreferences.getInstance()).getString('onb_keep'),
        'keep',
      );
    },
  );

  for (final failure in ['false', 'throw']) {
    testWidgets(
      'SIMULATED ONB neighbor Skip refusal survives remount: $failure',
      (tester) async {
        final original = await _mountOnbFixture(tester, intake: false);
        final gate = _DispositionGate(original, 'skip', failure);
        SharedPreferencesStorePlatform.instance = gate;
        await _onbTap(tester, const Key('act0_shell_placement_skip_intro'));
        expect(gate.calls, 1);
        expect(
          find.byKey(const Key('act0_shell_placement_screen')),
          findsOneWidget,
        );
        expect(find.text('Could not save. Please try again.'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(const AppRoot());
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_placement_skip_intro')),
          findsOneWidget,
        );
        expect(
          await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
          isFalse,
        );
        gate.reject = false;
        await _onbTap(tester, const Key('act0_shell_placement_skip_intro'));
        expect(
          find.byKey(const Key('act0_shell_placement_screen')),
          findsNothing,
        );
        expect(
          await Act0FirstStartPreferencesV1.hasSkippedIntroduction(),
          isTrue,
        );
        expect(
          await Act0FirstStartPreferencesV1.hasCompletedWelcome(),
          isFalse,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'SIMULATED ONB neighbor pending Welcome rejects duplicate completion',
    (tester) async {
      final original = await _mountOnbFixture(tester, intake: true);
      await _onbTap(tester, const Key('act0_shell_welcome_primary_cta'));
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      await _onbTap(
        tester,
        Key('act0_shell_option_${runner.runner.options.first.id}'),
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_next_step_line')),
        findsOneWidget,
      );
      final gate = _DispositionGate(original, 'welcome', 'none')
        ..reject = false
        ..held = Completer<void>()
        ..entered = Completer<void>();
      SharedPreferencesStorePlatform.instance = gate;
      final staleCallback = tester
          .widget<Act0WelcomeShellV1>(find.byType(Act0WelcomeShellV1))
          .onCompleted!;
      try {
        staleCallback();
        await tester.pumpAndSettle();
        expect(gate.entered!.isCompleted, isTrue);
        staleCallback();
        await tester.pumpAndSettle();
        expect(gate.calls, 1);
        expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
        expect(
          tester
              .widget<Act0WelcomeShellV1>(find.byType(Act0WelcomeShellV1))
              .onCompleted,
          isNull,
        );
        final action = tester
            .getSemantics(
              find.byKey(const Key('act0_shell_welcome_primary_cta')),
            )
            .getSemanticsData();
        expect(action.hasFlag(SemanticsFlag.isEnabled), isFalse);
      } finally {
        gate.release();
        await _drainOnbOwner(tester);
      }
      await tester.pumpAndSettle();
      expect(gate.calls, 1);
      expect(find.byType(Act0WelcomeShellV1), findsNothing);
      expect(await Act0FirstStartPreferencesV1.hasCompletedWelcome(), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

class _DispositionGate extends SharedPreferencesStorePlatform {
  _DispositionGate(this.delegate, String kind, this.failure)
    : key = kind == 'welcome'
          ? 'flutter.act0_welcome_completed_v1'
          : 'flutter.act0_introduction_skipped_v1';
  final SharedPreferencesStorePlatform delegate;
  final String key;
  final String failure;
  bool reject = true;
  int calls = 0;
  Completer<void>? held;
  Completer<void>? entered;
  void release() {
    if (held != null && !held!.isCompleted) held!.complete();
  }

  @override
  Future<Map<String, Object>> getAll() => delegate.getAll();
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key == this.key) {
      calls += 1;
      if (held != null) {
        if (entered != null && !entered!.isCompleted) entered!.complete();
        await held!.future;
      }
      if (reject) {
        if (failure == 'throw')
          throw StateError('SIMULATED disposition save refused');
        return false;
      }
    }
    return delegate.setValue(type, key, value);
  }

  @override
  Future<bool> remove(String key) => delegate.remove(key);
  @override
  Future<bool> clear() => delegate.clear();
}

Future<SharedPreferencesStorePlatform> _mountOnbFixture(
  WidgetTester tester, {
  required bool intake,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'intake_completed_v1': intake,
  });
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final original = SharedPreferencesStorePlatform.instance;
  addTearDown(() async {
    try {
      final current = SharedPreferencesStorePlatform.instance;
      if (current is _DispositionGate) {
        current.reject = false;
        current.release();
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await _drainOnbOwner(tester);
      await tester.runAsync(() async {
        await Act0ProgressStoreV1(
          key: 'act0_shell_progress_v1',
          isValidPayload: (_) => false,
        ).flush();
      });
    } finally {
      SharedPreferencesStorePlatform.instance = original;
    }
  });
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
  return original;
}

Future<void> _drainOnbOwner(WidgetTester tester) async {
  var drained = false;
  final read = Act0FirstStartPreferencesV1.hasSkippedIntroduction().then((_) {
    drained = true;
  });
  await tester.pumpAndSettle();
  expect(drained, isTrue, reason: 'Drain the owner in its widget-test zone.');
  await read;
}

Future<void> _onbTap(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
