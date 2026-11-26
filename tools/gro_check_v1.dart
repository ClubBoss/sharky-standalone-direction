// Run: flutter test tools/gro_check_v1.dart
// Uses B100's real shell route driver, with clean answers for the earned
// StoreKit milestone. This is an iOS-shaped widget run, not native sheet proof.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

import '../test/ui_v2/act0_w1_long_session_v1_test.dart';
import 'act0_widget_capture_v1.dart';

void main() => registerGroCheckV1();

void registerGroCheckV1() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAct0CaptureFontsV1);
  registerLongSessionRoutes(
    tierARange: (first: 1, last: 1),
    walkthrough: _GroCheckV1(),
    cleanWalkthrough: true,
  );
}

class _Entry {
  _Entry(this.entry, {String? unavailable}) {
    if (unavailable != null) exceptions.add(unavailable);
  }

  final String entry;
  bool reached = false;
  String payloadText = '';
  final exceptions = <String>[];

  Map<String, Object> toJson() => {
    'entry': entry,
    'reached': reached,
    'payload_text': payloadText,
    'exceptions': exceptions,
  };
}

class _GroCheckV1 implements Act0LongSessionObserverV1 {
  static const _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  final _share = _Entry('act0_lesson_result_share');
  final _review = _Entry('act0_world_review_prompt');
  final _legacy = [
    for (final id in [
      'legacy_hand_markdown_menu',
      'legacy_hand_markdown_button',
      'legacy_training_pack_share',
      'legacy_template_share',
      'legacy_session_summary_share',
      'legacy_summary_spot_share',
      'legacy_result_spot_share',
      'legacy_track_reward_share',
      'legacy_progress_pdf_share',
    ])
      _Entry(id, unavailable: 'Dormant legacy route; not exposed by Act0.'),
    for (final id in [
      'legacy_session_notes_pdf',
      'legacy_training_stats_share',
    ])
      _Entry(id, unavailable: 'Service-only share; no learner UI caller.'),
  ];
  final _routeErrors = <String>[];
  final _shareCalls = <MethodCall>[];
  final _reviewCalls = <MethodCall>[];
  bool _shareAttempted = false;
  bool _reviewChecked = false;

  List<_Entry> get _entries => [_share, _review, ..._legacy];

  @override
  void start(int world, Set<String> tasks, int priorXp) {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    messenger.setMockMethodCallHandler(_shareChannel, (call) async {
      _shareCalls.add(call);
      final args = call.arguments;
      if (args is Map && args['text'] is String) {
        _share.payloadText = args['text'] as String;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
      if (call.method == 'takeLink') return null;
      if (call.method == 'requestReview') {
        _reviewCalls.add(call);
        return true;
      }
      _review.exceptions.add('Unexpected growth method: ${call.method}');
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(_shareChannel, null);
      messenger.setMockMethodCallHandler(act0GrowthChannelV1, null);
      debugDefaultTargetPlatformOverride = null;
    });
    _writeReport();
  }

  Future<void> _settle(WidgetTester tester) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  }

  @override
  Future<void> screen(WidgetTester tester) async {
    final result = find.byType(Act0BlockCompletionShellV1);
    if (result.evaluate().isEmpty) return;
    final summary = tester.widget<Act0BlockCompletionShellV1>(result).summary;

    if (!summary.isWorldComplete &&
        _reviewCalls.isNotEmpty &&
        !_reviewChecked &&
        _review.exceptions.isEmpty) {
      _review.exceptions.add('Review requested before an earned world result.');
    }

    // Do not obscure the earned review milestone with a share modal.
    if (summary.isWorldComplete && !_reviewChecked) {
      _reviewChecked = true;
      _review.reached = true;
      if (_reviewCalls.isEmpty) {
        // Stay on the actual result long enough for its two-second timer.
        await tester.pump(const Duration(seconds: 3));
        await _settle(tester);
      }
      if (_reviewCalls.length != 1) {
        _review.exceptions.add(
          'Expected one requestReview at earned world result; got '
          '${_reviewCalls.length}. Mastery: ${summary.masteryStatus.name}.',
        );
      }
    }

    if (_shareAttempted || !summary.curriculumCompleted) return;
    _shareAttempted = true;
    final button = find.descendant(
      of: result,
      matching: find.byType(Act0ShareLessonResultButtonV1),
    );
    try {
      expect(button, findsOneWidget);
      await Scrollable.ensureVisible(tester.element(button), alignment: 0.5);
      await _settle(tester);
      expect(button.hitTestable(), findsOneWidget);
      _share.reached = true;

      // Preview and cancel must not publish anything.
      await tester.tap(button);
      await _settle(tester);
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(find.text('Share lesson result'), findsOneWidget);
      final preview = tester.widget<AlertDialog>(dialog).content as Text;
      expect(preview.data, isNotEmpty);
      expect(_shareCalls, isEmpty);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Cancel')),
      );
      await _settle(tester);
      expect(_shareCalls, isEmpty);

      await tester.tap(button);
      await _settle(tester);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Share')),
      );
      await _settle(tester);
      expect(_shareCalls, hasLength(1));
      final call = _shareCalls.single;
      expect(call.method, 'share');
      expect(_share.payloadText, isNotEmpty);
      expect(_share.payloadText, preview.data);
      expect(
        _share.payloadText,
        'I completed a poker lesson in Sharky.\nsharky://open/v1/learn',
      );
    } catch (error) {
      _share.exceptions.add(error.toString());
    }
  }

  @override
  Future<void> wrongAnswer(WidgetTester tester) async {
    _review.exceptions.add('Unexpected deliberate miss on clean route.');
  }

  @override
  Future<void> finalResult(WidgetTester tester) => screen(tester);

  @override
  void snapshot(Map<String, dynamic> progress) {}

  @override
  void failure(Object error) => _routeErrors.add(error.toString());

  File _writeReport() {
    final file = File('build/gro/report.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(_entries.map((entry) => entry.toJson()).toList())}\n',
    );
    return file;
  }

  @override
  void finish() {
    for (final entry in [_share, _review]) {
      if (!entry.reached) entry.exceptions.add('Learner entry not reached.');
      entry.exceptions.addAll(_routeErrors);
    }
    if (_reviewCalls.length != 1 && _review.exceptions.isEmpty) {
      _review.exceptions.add(
        'Expected one review request, got ${_reviewCalls.length}.',
      );
    }
    if (_shareCalls.length != 1 && _share.exceptions.isEmpty) {
      _share.exceptions.add(
        'Expected one share call, got ${_shareCalls.length}.',
      );
    }
    final report = _writeReport();

    // The CI smoke validates the actual persisted driver output, not sample JSON.
    // Preserve any original route exception rather than masking it in finally.
    if (_routeErrors.isNotEmpty) return;
    final rows = (jsonDecode(report.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    expect(rows.map((r) => r['entry']), _entries.map((e) => e.entry));
    for (final row in rows) {
      expect(row.keys.toSet(), {
        'entry',
        'reached',
        'payload_text',
        'exceptions',
      });
      expect(row['entry'], isA<String>());
      expect(row['reached'], isA<bool>());
      expect(row['payload_text'], isA<String>());
      expect(row['exceptions'], isA<List>());
    }
    final share = rows.first;
    expect(share['reached'], isTrue);
    expect(share['payload_text'], isNotEmpty);
    expect(share['exceptions'], isEmpty);
    final review = rows[1];
    expect(review['reached'], isTrue);
    expect(review['exceptions'], isEmpty);
  }
}
