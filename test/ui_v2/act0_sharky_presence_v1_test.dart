import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('Compact Sharky guide card keeps long copy without truncation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Act0SharkyGuideCardV1(
              eyebrow: 'Sharky',
              line:
                  'We start with Hold\'em cash. One clean table read, then one clear action.',
              detail:
                  'Each player gets 2 private hole cards. The table shares 5 community cards.',
              mood: Act0SharkyMoodV1.thinking,
              compact: true,
            ),
          ),
        ),
      ),
    );

    final lineText = tester.widget<Text>(
      find.byKey(const Key('act0_shell_sharky_guide_line')),
    );
    final detailText = tester.widget<Text>(
      find.byKey(const Key('act0_shell_sharky_guide_detail_block_0')),
    );

    expect(lineText.maxLines, isNull);
    expect(lineText.overflow, isNull);
    expect(detailText.maxLines, isNull);
    expect(detailText.overflow, isNull);
    expect(
      find.textContaining('We start with Hold\'em cash.\n'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Each player gets 2 private hole cards.\n'),
      findsOneWidget,
    );
  });

  testWidgets('Compact Sharky guide card splits long detail into calm blocks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Act0SharkyGuideCardV1(
              eyebrow: 'Sharky',
              line: 'We start with Hold\'em cash.',
              detail:
                  'Each player gets 2 private hole cards. The table shares 5 community cards. You build the best 5-card hand from those 7. Cash keeps chip values stable hand to hand.',
              mood: Act0SharkyMoodV1.thinking,
              compact: true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_sharky_guide_detail')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_sharky_guide_detail_block_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_sharky_guide_detail_block_1')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Hold\'em gives every player 2 private'),
      findsNothing,
    );
    expect(
      find.textContaining('Each player gets 2 private hole cards.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('The table shares 5 community cards.'),
      findsOneWidget,
    );
  });

  testWidgets('Compact Sharky guide card stacks readable text under the header', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Act0SharkyGuideCardV1(
              eyebrow: 'Sharky',
              line:
                  'Fix one pressure spot first. Then continue the route cleanly.',
              detail: 'The next rep should feel calm, short, and specific.',
              mood: Act0SharkyMoodV1.repair,
              compact: true,
            ),
          ),
        ),
      ),
    );

    final eyebrowTop = tester.getTopLeft(
      find.byKey(const Key('act0_shell_sharky_guide_eyebrow')),
    );
    final lineTop = tester.getTopLeft(
      find.byKey(const Key('act0_shell_sharky_guide_line')),
    );
    final detailTop = tester.getTopLeft(
      find.byKey(const Key('act0_shell_sharky_guide_detail')),
    );

    expect(lineTop.dy, greaterThan(eyebrowTop.dy));
    expect(detailTop.dy, greaterThan(lineTop.dy));
    expect(tester.takeException(), isNull);
  });

  group('Act0SharkyCompanionAvatarV1', () {
    for (final initiallyDisabled in [false, true]) {
      testWidgets(
        'dynamic reduced motion survives repeated toggles from $initiallyDisabled on one State',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(393, 852));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final disabled = ValueNotifier(initiallyDisabled);
          addTearDown(disabled.dispose);
          final mascotKey = GlobalKey();
          const motionKey = Key('act0_shell_sharky_presence_motion');
          const imageKey = Key('act0_shell_sharky_presence_mascot_happy');

          await tester.pumpWidget(
            MaterialApp(
              home: ValueListenableBuilder<bool>(
                valueListenable: disabled,
                builder: (context, value, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: value),
                  child: Scaffold(
                    body: Act0SharkyPresenceMascotV1(
                      key: mascotKey,
                      mood: Act0SharkyMoodV1.happy,
                      tone: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          );
          final originalState = mascotKey.currentState;
          expect(originalState, isNotNull);

          for (final value in [
            initiallyDisabled,
            !initiallyDisabled,
            initiallyDisabled,
            !initiallyDisabled,
            initiallyDisabled,
          ]) {
            disabled.value = value;
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(mascotKey.currentState, same(originalState));
            expect(find.byKey(imageKey), findsOneWidget);
            expect(tester.getSize(find.byKey(imageKey)).isEmpty, isFalse);

            if (value) {
              expect(find.byKey(motionKey), findsNothing);
              await tester.pumpAndSettle();
              expect(tester.binding.transientCallbackCount, 0);
              await tester.pump(const Duration(seconds: 3));
              expect(find.byKey(motionKey), findsNothing);
              expect(tester.binding.transientCallbackCount, 0);
            } else {
              expect(find.byKey(motionKey), findsOneWidget);
              List<List<double>> transforms() => tester
                  .widgetList<Transform>(
                    find.descendant(
                      of: find.byKey(motionKey),
                      matching: find.byType(Transform),
                    ),
                  )
                  .map((widget) => widget.transform.storage.toList())
                  .toList();
              final before = transforms();
              await tester.pump(const Duration(milliseconds: 600));
              expect(transforms(), isNot(equals(before)));
            }
            expect(tester.takeException(), isNull);
          }

          // Dispose both a running controller and the static-only state.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 3));
          expect(mascotKey.currentState, isNull);
          expect(tester.binding.transientCallbackCount, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('renders one keyed avatar per companion state, no exceptions', (
      tester,
    ) async {
      for (final state in Act0SharkyCompanionStateV1.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Act0SharkyCompanionAvatarV1(state: state)),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(Key('act0_shell_sharky_companion_avatar_${state.name}')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'improve and milestone render the accent ring, other states do not',
      (tester) async {
        for (final state in Act0SharkyCompanionStateV1.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: Act0SharkyCompanionAvatarV1(state: state)),
            ),
          );
          await tester.pump();

          final expectRing =
              state == Act0SharkyCompanionStateV1.improve ||
              state == Act0SharkyCompanionStateV1.milestone;
          expect(
            find.byKey(const Key('act0_shell_sharky_mascot_frame_accent_ring')),
            expectRing ? findsOneWidget : findsNothing,
            reason: 'state $state ring mismatch',
          );
        }
      },
    );

    testWidgets(
      'every state resolves to the declared admitted fallback asset',
      (tester) async {
        for (final state in Act0SharkyCompanionStateV1.values) {
          final mood = act0SharkyMoodForCompanionStateV1(state);
          expect(
            act0SharkyCompanionAssetForMoodV1(mood),
            'assets/images/mascot/sharky_neutral_fallback_v1.png',
          );
        }
      },
    );

    testWidgets(
      'reduced motion keeps every Sharky mood visible without a motion builder',
      (tester) async {
        for (final mood in Act0SharkyMoodV1.values) {
          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: MaterialApp(
                home: Scaffold(
                  body: Act0SharkyPresenceMascotV1(
                    mood: mood,
                    tone: act0SharkyToneForMoodV1(mood),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(
            find.byKey(Key('act0_shell_sharky_presence_mascot_${mood.name}')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('act0_shell_sharky_presence_motion')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  });
}
