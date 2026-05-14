import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
