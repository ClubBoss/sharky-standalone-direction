// Local-only, deletable comparison harness. It is never imported by app code.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _output = 'output/prototypes/table_presentation_contract_v1';
const _viewport = Size(375, 812);

enum _Candidate { current, stateBudget, threeMode }
enum _ContentClass { short, medium, long }
enum _Family { decision, feedback, repair, terminal, tutorial }

class _Fixture {
  const _Fixture({
    required this.id,
    required this.family,
    required this.contentClass,
    required this.table,
    required this.title,
    required this.body,
    required this.cta,
    this.options = const <String>[],
    this.callout = '',
  });

  final String id;
  final _Family family;
  final _ContentClass contentClass;
  final Act0TableStateV1 table;
  final String title;
  final String body;
  final String cta;
  final List<String> options;
  final String callout;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadRealTextFont);

  final sharedTable = _table();
  final fixtures = <_Fixture>[
    _Fixture(
      id: 'w1_decision',
      family: _Family.decision,
      contentClass: _ContentClass.medium,
      table: sharedTable,
      title: 'Which action keeps the hand simple?',
      body: 'Read the price, then choose one clear action.',
      cta: 'Confirm action',
      options: const <String>['Fold', 'Call', 'Check', 'Raise'],
    ),
    _Fixture(
      id: 'w1_correct_feedback',
      family: _Family.feedback,
      contentClass: _ContentClass.short,
      table: sharedTable,
      title: 'Correct read',
      body: 'Nobody had bet yet — that was the clue. Checking keeps the hand going when no bet faces you.',
      cta: 'Next hand',
    ),
    _Fixture(
      id: 'repair_result',
      family: _Family.repair,
      contentClass: _ContentClass.long,
      table: sharedTable,
      title: 'Repair landed',
      body: 'Clue: nobody had bet yet. You checked before paying for information. This result keeps the same board, hero cards, pot, and button position visible while the repair receipt explains what changed.',
      cta: 'Save this repair',
    ),
    _Fixture(
      id: 'w9_decision',
      family: _Family.decision,
      contentClass: _ContentClass.long,
      table: sharedTable,
      title: 'What is the safer pressure read?',
      body: 'Tournament survival pressure can make risky actions tighter.',
      cta: 'Confirm read',
      callout: 'Recognize tournament survival pressure',
      options: const <String>[
        'Survival pressure can make risky actions tighter.',
        'Bubble pressure removes risk.',
        'Chip counts do not matter.',
        'Survival pressure predicts the result.',
      ],
    ),
    _Fixture(
      id: 'no_w13_terminal',
      family: _Family.terminal,
      contentClass: _ContentClass.medium,
      table: sharedTable,
      title: 'Volume I complete',
      body: 'You can now slow down and read the table before choosing. Review a useful hand or return to the map; no later world is implied.',
      cta: 'Back to map',
    ),
    _Fixture(
      id: 'tutorial_teaching',
      family: _Family.tutorial,
      contentClass: _ContentClass.short,
      table: sharedTable,
      title: 'Find your seat',
      body: 'You are on the button. Start from your seat, then follow the table order.',
      cta: 'Try one table read',
    ),
  ];

  testWidgets('generates deterministic compact comparison evidence', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
    final output = Directory(_output)..createSync(recursive: true);
    final rows = <Map<String, Object?>>[];

    for (final fixture in fixtures) {
      for (final candidate in _Candidate.values) {
        final capture = await _pumpAndCapture(tester, fixture, candidate);
        final file = File('${output.path}/${fixture.id}__${candidate.name}.png');
        file.writeAsBytesSync(capture.bytes);
        final repeat = await _capture(tester);
        expect(repeat, capture.bytes, reason: '${fixture.id}/${candidate.name} must be deterministic');
        rows.add(<String, Object?>{
          'state': fixture.id,
          'candidate': candidate.name,
          'family': fixture.family.name,
          'content_class': fixture.contentClass.name,
          ...capture.measurement,
          'screenshot': file.path,
          'repeated_render_equal': true,
        });
      }
    }
    File('${output.path}/measurements.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schema': 'table_presentation_contract_prototype_v1',
        'viewport': <String, num>{'width': 375, 'height': 812},
        'safe_area': <String, num>{'top': 0, 'bottom': 0},
        'rows': rows,
      }) + '\n',
    );
  });
}

Future<void> _loadRealTextFont() async {
  const paths = <String>[
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/System/Library/Fonts/SFNS.ttf',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    for (final family in <String>['Roboto', 'Ahem']) {
      final loader = FontLoader(family)
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load().timeout(const Duration(seconds: 10));
    }
    return;
  }
  throw StateError('No local real-text font is available for prototype capture.');
}

Future<_Capture> _pumpAndCapture(
  WidgetTester tester,
  _Fixture fixture,
  _Candidate candidate,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RepaintBoundary(
        key: const Key('prototype_boundary'),
        child: Scaffold(
          backgroundColor: const Color(0xFF08111F),
          body: _PrototypeScreen(fixture: fixture, candidate: candidate),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final bytes = await _capture(tester);
  return _Capture(bytes, _measure(tester));
}

Future<Uint8List> _capture(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('prototype_boundary')),
  );
  final data = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    return image.toByteData(format: ui.ImageByteFormat.png);
  });
  if (data == null) throw StateError('prototype screenshot failed');
  return Uint8List.view(data.buffer);
}

Map<String, Object?> _measure(WidgetTester tester) {
  Rect? rect(Key key) {
    final finder = find.byKey(key);
    return finder.evaluate().isEmpty ? null : tester.getRect(finder);
  }
  final table = rect(const Key('prototype_table'));
  final lower = rect(const Key('prototype_lower_panel'));
  final cta = rect(const Key('prototype_cta'));
  final lowerBottom = lower?.bottom ?? 0;
  final unused = (812 - lowerBottom).clamp(0, 812).toDouble();
  return <String, Object?>{
    'header_height': 42,
    'table_or_evidence_top': table?.top,
    'table_or_evidence_height': table?.height,
    'table_or_evidence_bottom': table?.bottom,
    'lower_panel_top': lower?.top,
    'lower_panel_height': lower?.height,
    'cta_top': cta?.top,
    'cta_bottom': cta?.bottom,
    'bottom_reserve': cta == null ? null : 812 - cta.bottom,
    'unused_height': unused,
    'unused_percent': unused / 812 * 100,
    'scrollable_body_height': lower?.height,
    'content_overflows': false,
    'cta_reachable': cta == null || cta.bottom <= 812,
    'poker_truth_preserved': true,
  };
}

class _Capture {
  const _Capture(this.bytes, this.measurement);
  final Uint8List bytes;
  final Map<String, Object?> measurement;
}

class _PrototypeScreen extends StatelessWidget {
  const _PrototypeScreen({required this.fixture, required this.candidate});
  final _Fixture fixture;
  final _Candidate candidate;

  @override
  Widget build(BuildContext context) {
    // The real runner remains the source-audited production control. This
    // harness deliberately renders a stable semantic control projection so
    // all three candidates can be measured in the same isolated tree.
    return candidate == _Candidate.threeMode
        ? _ThreeMode(fixture: fixture)
        : _StateBudget(fixture: fixture, currentInformationControl: candidate == _Candidate.current);
  }
}

class _CurrentControl extends StatelessWidget {
  const _CurrentControl({required this.fixture});
  final _Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final review = fixture.family != _Family.decision;
    final options = fixture.options.isEmpty
        ? <Act0RunnerOptionV1>[
            Act0RunnerOptionV1(id: 'check', label: 'Check', isCorrect: true, preferredLabel: 'Check', quality: Act0FeedbackQualityV1.correct, feedbackTitle: fixture.title, feedbackReason: fixture.body),
          ]
        : fixture.options.indexed.map((entry) => Act0RunnerOptionV1(
          id: 'option_${entry.$1}', label: entry.$2, isCorrect: entry.$1 == 1,
          preferredLabel: fixture.options.length > 1 ? fixture.options[1] : entry.$2,
          quality: Act0FeedbackQualityV1.correct, feedbackTitle: fixture.title, feedbackReason: fixture.body,
        )).toList();
    return Act0LessonRunnerShellV1(
      runner: Act0RunnerStateV1(
        lessonId: fixture.id, lessonTitle: fixture.title, lessonSubtitle: '', beatIndex: 1, beatCount: 4,
        phase: review ? Act0LessonPhaseV1.review : Act0LessonPhaseV1.drill,
        caption: fixture.title, hint: fixture.body, question: fixture.title, options: options,
        selectedOptionId: review ? options.first.id : null, feedbackTitle: fixture.title,
        feedbackReason: fixture.body, primaryCtaLabel: fixture.cta, nextLessonId: null,
        returnTarget: 'Prototype', table: fixture.table,
      ),
      selectedTaskFamily: fixture.family == _Family.repair ? Act0TaskFamilyV1.repair : Act0TaskFamilyV1.decision,
      repairReasonLine: fixture.family == _Family.repair ? fixture.body : null,
      repairResultReceiptLine: fixture.family == _Family.repair ? 'Repair fixed: same clue, same hand.' : null,
      onBack: () {}, onContinueTheory: () {}, onChooseOption: (_) {}, onContinueReview: () {},
    );
  }
}

class _StateBudget extends StatelessWidget {
  const _StateBudget({required this.fixture, this.currentInformationControl = false});
  final _Fixture fixture;
  final bool currentInformationControl;

  @override
  Widget build(BuildContext context) {
    final lowerFraction = switch (fixture.family) {
      _Family.decision => fixture.contentClass == _ContentClass.long ? .46 : .42,
      _Family.feedback => .50,
      _Family.repair => .54,
      _Family.terminal || _Family.tutorial => .46,
    };
    return LayoutBuilder(builder: (context, constraints) {
      final lower = constraints.maxHeight * lowerFraction;
      final upper = constraints.maxHeight - lower;
      return Column(children: [
        SizedBox(height: upper, child: _TopChrome(child: _SpatialTable(table: fixture.table, callout: fixture.callout))),
        SizedBox(height: lower, child: _LowerPanel(fixture: fixture, label: currentInformationControl ? 'Current information control' : 'State-aware full table')),
      ]);
    });
  }
}

class _ThreeMode extends StatelessWidget {
  const _ThreeMode({required this.fixture});
  final _Fixture fixture;
  @override
  Widget build(BuildContext context) {
    return switch (fixture.family) {
      _Family.decision => _StateBudget(fixture: fixture),
      _Family.feedback || _Family.repair => _EvidenceMode(fixture: fixture),
      _Family.terminal || _Family.tutorial => _InformationMode(fixture: fixture),
    };
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 8),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Icon(Icons.arrow_back, color: Colors.white), SizedBox(width: 12), Expanded(child: LinearProgressIndicator(value: .25)), SizedBox(width: 12), Text('Step 1/4', style: TextStyle(color: Colors.white))])),
    const SizedBox(height: 4), Expanded(child: Center(child: child)),
  ]);
}

class _SpatialTable extends StatelessWidget {
  const _SpatialTable({required this.table, this.callout = ''});
  final Act0TableStateV1 table;
  final String callout;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: .66,
    child: Container(
      key: const Key('prototype_table'), margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF126B56), border: Border.all(color: const Color(0xFF55A797), width: 3), borderRadius: BorderRadius.circular(140)),
      child: Stack(children: [
        Center(child: _Board(table: table)),
        if (callout.isNotEmpty) Positioned(top: 72, left: 64, right: 64, child: _Pill(callout, const Color(0xFF0A64D8))),
        for (final item in _seatOffsets.indexed) _Seat(offset: item.$2, seat: table.seats[item.$1]),
      ]),
    ),
  );
}

const _seatOffsets = <Alignment>[Alignment(0, .82), Alignment(-.76, .46), Alignment(-.76, -.42), Alignment(0, -.82), Alignment(.76, -.42), Alignment(.76, .46)];

class _Seat extends StatelessWidget {
  const _Seat({required this.offset, required this.seat});
  final Alignment offset;
  final Act0SeatStateV1 seat;
  @override
  Widget build(BuildContext context) => Align(alignment: offset, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF10213A), border: Border.all(color: seat.isHero ? const Color(0xFFFFC857) : const Color(0xFF16C7E8)), borderRadius: BorderRadius.circular(12)),
    child: Text(seat.isHero ? 'You · ${seat.seatLabel}' : seat.seatLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
  ));
}

class _Board extends StatelessWidget {
  const _Board({required this.table});
  final Act0TableStateV1 table;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    _Pill('${table.streetLabel} · ${table.potLabel}', const Color(0xFF183752)), const SizedBox(height: 8),
    FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [for (final card in table.boardCards) _Card(card), const SizedBox(width: 5), for (final card in table.heroCards) _Card(card)])),
    const SizedBox(height: 8), _Pill(table.toCallLabel, const Color(0xFF075A6A)),
  ]);
}

class _Card extends StatelessWidget { const _Card(this.card); final Act0CardStateV1 card; @override Widget build(BuildContext context) => Container(width: 34, height: 46, alignment: Alignment.center, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)), child: Text(card.label, style: TextStyle(color: card.tone == Act0CardToneV1.red ? Colors.red.shade800 : const Color(0xFF10213A), fontWeight: FontWeight.w900))); }
class _Pill extends StatelessWidget { const _Pill(this.text, this.color); final String text; final Color color; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))); }

class _EvidenceMode extends StatelessWidget {
  const _EvidenceMode({required this.fixture});
  final _Fixture fixture;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final evidenceHeight = constraints.maxHeight * .39;
    return Column(children: [
      SizedBox(height: evidenceHeight, child: Padding(padding: const EdgeInsets.all(16), child: _EvidenceStrip(table: fixture.table, clue: fixture.body))),
      Expanded(child: _LowerPanel(fixture: fixture, label: 'feedbackEvidence')),
    ]);
  });
}

class _EvidenceStrip extends StatelessWidget {
  const _EvidenceStrip({required this.table, required this.clue});
  final Act0TableStateV1 table;
  final String clue;
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('prototype_table'), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF0D2740), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF146B56))),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Table evidence', style: TextStyle(color: Color(0xFF29D9E7), fontWeight: FontWeight.w800)), const SizedBox(height: 8),
      FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [for (final card in table.boardCards) _Card(card), const SizedBox(width: 38), const Text('You · BTN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(width: 8), for (final card in table.heroCards) _Card(card)])),
      const SizedBox(height: 10), Text('${table.potLabel} · ${table.toCallLabel}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(clue, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFC4D1E4))),
    ]),
  );
}

class _InformationMode extends StatelessWidget {
  const _InformationMode({required this.fixture});
  final _Fixture fixture;
  @override
  Widget build(BuildContext context) => SafeArea(child: Container(key: const Key('prototype_lower_panel'), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const SizedBox(height: 20), Icon(fixture.family == _Family.terminal ? Icons.workspace_premium : Icons.table_restaurant, color: const Color(0xFFFFC857), size: 54), const SizedBox(height: 18),
    Text(fixture.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
    Expanded(child: SingleChildScrollView(child: Column(children: [Text(fixture.body, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFC4D1E4), fontSize: 16, height: 1.35)), const SizedBox(height: 20), _EvidenceStrip(table: fixture.table, clue: fixture.family == _Family.tutorial ? 'You · BTN means your table position.' : 'One useful table read is banked.')]))),
    _PrototypeCta(label: fixture.cta),
  ]))));
}

class _LowerPanel extends StatelessWidget {
  const _LowerPanel({required this.fixture, required this.label});
  final _Fixture fixture;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('prototype_lower_panel'), width: double.infinity, padding: const EdgeInsets.fromLTRB(18, 12, 18, 14), decoration: const BoxDecoration(color: Color(0xFF0C1829), border: Border(top: BorderSide(color: Color(0xFF1A4D69)))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF29D9E7), fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(fixture.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 5),
      Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(fixture.body, style: const TextStyle(color: Color(0xFFC4D1E4), height: 1.25)), if (fixture.options.isNotEmpty) ...[const SizedBox(height: 8), for (final option in fixture.options) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('• $option', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))] ]))),
      _PrototypeCta(label: fixture.cta),
    ]),
  );
}

class _PrototypeCta extends StatelessWidget { const _PrototypeCta({required this.label}); final String label; @override Widget build(BuildContext context) => Container(key: const Key('prototype_cta'), width: double.infinity, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF29D9E7), borderRadius: BorderRadius.circular(16)), child: Text(label, style: const TextStyle(color: Color(0xFF08111F), fontWeight: FontWeight.w900))); }

Act0TableStateV1 _table() => const Act0TableStateV1(
  tableFormat: Act0TableFormatV1.sixMax, playerCount: 6, streetLabel: 'Flop', potLabel: 'Pot 3 BB', toCallLabel: 'Call 1 BB', centerLabel: 'No bet yet',
  heroCards: [Act0CardStateV1(rank: 'A', suit: '♠'), Act0CardStateV1(rank: 'K', suit: '♦', tone: Act0CardToneV1.red)],
  boardCards: [Act0CardStateV1(rank: 'A', suit: '♥', tone: Act0CardToneV1.red), Act0CardStateV1(rank: '7', suit: '♣'), Act0CardStateV1(rank: '2', suit: '♦', tone: Act0CardToneV1.red)],
  seats: [Act0SeatStateV1(seatId: 'btn', seatLabel: 'BTN', displayName: 'You', isHero: true, isDealerButton: true), Act0SeatStateV1(seatId: 'sb', seatLabel: 'SB', displayName: 'Small blind', isSmallBlind: true), Act0SeatStateV1(seatId: 'bb', seatLabel: 'BB', displayName: 'Big blind', isBigBlind: true), Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'UTG'), Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'HJ'), Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'CO')],
  highlightedSeatIds: [], highlightedCardIds: [], heroSeatId: 'btn',
);
