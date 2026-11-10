import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_presentation_gate_v1.dart';

Widget host(
  String identity,
  Future<bool> Function() reserve, {
  VoidCallback? exit,
}) => MaterialApp(
  home: Scaffold(
    body: Act0ContentPresentationGateV1(
      presentationKey: identity,
      reserveExposure: reserve,
      onExit: exit ?? () {},
      child: const Text('Private task content'),
    ),
  ),
);

void main() {
  testWidgets(
    'content is never built before acknowledged exposure reservation',
    (tester) async {
      final pending = Completer<bool>();
      await tester.pumpWidget(host('a', () => pending.future));
      expect(find.text('Private task content'), findsNothing);
      pending.complete(true);
      await tester.pump();
      expect(find.text('Private task content'), findsOneWidget);
    },
  );

  testWidgets(
    'failed and thrown persistence keep content hidden and allow safe retry',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        host('a', () async {
          attempts++;
          if (attempts == 1) throw StateError('write unavailable');
          return attempts >= 3;
        }),
      );
      await tester.pump();
      expect(find.text('Private task content'), findsNothing);
      await tester.tap(
        find.byKey(const Key('act0_content_presentation_retry')),
      );
      await tester.pump();
      expect(find.text('Private task content'), findsNothing);
      await tester.tap(
        find.byKey(const Key('act0_content_presentation_retry')),
      );
      await tester.pump();
      expect(find.text('Private task content'), findsOneWidget);
      expect(attempts, 3);
    },
  );

  testWidgets('stale acknowledgement cannot expose a newer task', (
    tester,
  ) async {
    final first = Completer<bool>();
    final second = Completer<bool>();
    await tester.pumpWidget(host('a', () => first.future));
    await tester.pumpWidget(host('b', () => second.future));
    first.complete(true);
    await tester.pump();
    expect(find.text('Private task content'), findsNothing);
    second.complete(true);
    await tester.pump();
    expect(find.text('Private task content'), findsOneWidget);
  });

  testWidgets('exit does not let late writes reopen content', (tester) async {
    final pending = Completer<bool>();
    var exits = 0;
    await tester.pumpWidget(
      host('a', () => pending.future, exit: () => exits++),
    );
    await tester.tap(find.byKey(const Key('act0_content_presentation_exit')));
    expect(exits, 1);
    pending.complete(true);
    await tester.pump();
    expect(find.text('Private task content'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposal while pending ignores a later acknowledgement', (
    tester,
  ) async {
    final pending = Completer<bool>();
    await tester.pumpWidget(host('a', () => pending.future));
    await tester.pumpWidget(const SizedBox());
    pending.complete(true);
    await tester.pump();
    expect(find.text('Private task content'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('acknowledged task is hidden immediately when next task waits', (
    tester,
  ) async {
    await tester.pumpWidget(host('a', () async => true));
    await tester.pump();
    expect(find.text('Private task content'), findsOneWidget);
    final next = Completer<bool>();
    await tester.pumpWidget(host('b', () => next.future));
    expect(find.text('Private task content'), findsNothing);
    next.complete(true);
    await tester.pump();
    expect(find.text('Private task content'), findsOneWidget);
  });
}
