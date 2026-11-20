import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_components_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';

typedef _T = Act0ClubNightTokensV1;

Widget _host(Widget child, {double textScale = 1}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(393, 852),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        backgroundColor: _T.wall,
        body: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    ),
  );
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Club Night tokens', () {
    test('text colours pass 4.5:1 on every background they sit on', () {
      for (final bg in [_T.wall, _T.surface, _T.raised]) {
        expect(_contrast(_T.text, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(_T.text2, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(_T.caption, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(_T.brass, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(_T.correct, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(_T.mistake, bg), greaterThanOrEqualTo(4.5));
      }
      expect(_contrast(_T.onBrass, _T.brass), greaterThanOrEqualTo(4.5));
    });

    test('type follows the iOS scale without a custom font', () {
      expect(_T.title.fontSize, 28);
      expect(_T.question.fontSize, 20);
      expect(_T.body.fontSize, 17);
      expect(_T.captionStyle.fontSize, 13);
      for (final style in [_T.title, _T.body, _T.question, _T.figure]) {
        expect(style.fontFamily, isNull);
      }
      expect(_T.figure.fontFeatures, isNotEmpty);
    });
  });

  group('Club Night components', () {
    testWidgets('primary button is brass, 56 pt and tappable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          Act0ClubPrimaryButtonV1(
            label: 'Start review',
            onPressed: () => taps++,
          ),
        ),
      );
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(_T.controlHeight));
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, _T.brass);
      await tester.tap(find.text('Start review'));
      expect(taps, 1);
    });

    testWidgets('answer verdicts carry a word and a spoken label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const Column(
            children: [
              Act0ClubAnswerRowV1(
                label: 'Call',
                verdict: Act0ClubAnswerVerdictV1.notThisOne,
              ),
              SizedBox(height: 8),
              Act0ClubAnswerRowV1(
                label: 'Raise to 2.5 BB',
                verdict: Act0ClubAnswerVerdictV1.better,
              ),
            ],
          ),
        ),
      );
      expect(find.text('Not this one'), findsOneWidget);
      expect(find.text('Better'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('Call, not this one'), findsOneWidget);
      expect(find.bySemanticsLabel('Raise to 2.5 BB, better'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('step bar marks done, current and ahead', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const Act0ClubStepBarV1(total: 6, current: 3)),
      );
      Color colorOf(int i) {
        final box = tester.widget<Container>(
          find.byKey(Key('act0_club_step_$i')),
        );
        return (box.decoration! as BoxDecoration).color!;
      }

      expect(colorOf(1), _T.brass);
      expect(colorOf(2), _T.brass);
      expect(colorOf(3), _T.text);
      expect(colorOf(4), _T.track);
      expect(find.bySemanticsLabel('Step 3 of 6'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('tab bar highlights the selected tab in brass', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.bottomCenter,
            child: Act0ClubTabBarV1(
              items: const [
                Act0ClubTabItemV1(label: 'Home', icon: Icons.home_outlined),
                Act0ClubTabItemV1(label: 'Review', icon: Icons.refresh),
              ],
              selectedIndex: 0,
              onSelected: (i) => selected = i,
            ),
          ),
        ),
      );
      final home = tester.widget<Text>(find.text('Home'));
      final review = tester.widget<Text>(find.text('Review'));
      expect(home.style!.color, _T.brass);
      expect(review.style!.color, _T.caption);
      await tester.tap(find.byKey(const Key('act0_club_tab_1')));
      expect(selected, 1);
    });

    testWidgets('text grows to 1.3× and no further', (tester) async {
      late double seen;
      await tester.pumpWidget(
        _host(
          Act0ClubTextScaleV1(
            child: Builder(
              builder: (context) {
                seen = MediaQuery.textScalerOf(context).scale(10) / 10;
                return const SizedBox();
              },
            ),
          ),
          textScale: 2,
        ),
      );
      expect(seen, closeTo(_T.maxTextScale, 0.001));
    });

    test('Sharky ring colour follows the moment', () {
      expect(
        Act0ClubSharkyRingV1.ringColorFor(Act0ClubSharkyMomentV1.mistake),
        _T.brass,
      );
      expect(
        Act0ClubSharkyRingV1.ringColorFor(Act0ClubSharkyMomentV1.selfFix),
        _T.correct,
      );
      expect(
        Act0ClubSharkyRingV1.ringColorFor(Act0ClubSharkyMomentV1.hint),
        _T.hairlineRing,
      );
    });

    testWidgets('card and tag render on the wall', (tester) async {
      await tester.pumpWidget(
        _host(
          const Act0ClubCardV1(
            emphasized: true,
            child: Act0ClubTagV1(label: 'Due now · Day 2'),
          ),
        ),
      );
      expect(find.text('Due now · Day 2'), findsOneWidget);
    });
  });
}
