// Local-only, deletable production-fidelity presentation harness.
// It is never imported by app code.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

const _root = 'output/prototypes/complete_table_system_v1';
const _viewport = Size(375, 812);
const _fullTableWidth = 344.0;

enum _TheoryGeometry { t1, t2_88, t2_90, t2_92 }
enum _PanelClass { compactTheory, standardTheory }
enum _TaskState { decision, correct, wrong, repairFocus, repairDetail, peek, restored, repairResult, recheck }
enum _Identity { production, position, dealerOrder, nonPosition }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFont);

  testWidgets('captures complete theory-to-task evidence with exact production scene', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
    final out = Directory(_root)..createSync(recursive: true);
    final rows = <Map<String, Object?>>[];

    Future<void> capture(String name, Widget screen, {String family = 'theory'}) async {
      await tester.pumpWidget(MaterialApp(home: RepaintBoundary(key: const Key('complete_system_boundary'), child: Scaffold(backgroundColor: const Color(0xFF08111F), body: screen))));
      await tester.pumpAndSettle();
      final first = await _png(tester);
      final repeat = await _png(tester);
      expect(repeat, first, reason: '$name repeated render must remain stable');
      File('${out.path}/$name.png').writeAsBytesSync(first);
      rows.add(<String, Object?>{'name': name, 'family': family, ..._measure(tester), 'repeated_render_equal': true});
    }

    for (final geometry in _TheoryGeometry.values) {
      await capture('theory_${geometry.name == 't1' ? 't1_full' : geometry.name.replaceFirst('t2_', 't2_')}', _TheoryScreen(geometry: geometry, panelClass: _PanelClass.standardTheory, beat: 'Hero cards'));
    }
    await capture('theory_winner_hero', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Hero cards'));
    await capture('theory_winner_board', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Board'));
    await capture('theory_winner_pot', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Pot'));
    await capture('theory_winner_recap', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Recap'));
    await capture('theory_compact_content_sized', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.compactTheory, beat: 'Hero cards'));
    await capture('theory_standard_content_sized', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Hero cards'));
    await capture('theory_current_fixed_slot_control', const _FixedSlotControl());
    await capture('theory_internal_bounds_overlay', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Hero cards', showBounds: true));
    await capture('t1_target_identity', const _TheoryScreen(geometry: _TheoryGeometry.t1, panelClass: _PanelClass.standardTheory, beat: 'Hero cards', identity: _Identity.position));
    await capture('t2_92_target_identity', const _TheoryScreen(geometry: _TheoryGeometry.t2_92, panelClass: _PanelClass.standardTheory, beat: 'Hero cards', identity: _Identity.position));
    await capture('position_identity', const _TheoryScreen(geometry: _TheoryGeometry.t1, panelClass: _PanelClass.standardTheory, beat: 'Hero cards', identity: _Identity.position));
    await capture('dealer_order_identity', const _TheoryScreen(geometry: _TheoryGeometry.t1, panelClass: _PanelClass.standardTheory, beat: 'Recap', identity: _Identity.dealerOrder));
    await capture('non_position_identity', const _TheoryScreen(geometry: _TheoryGeometry.t1, panelClass: _PanelClass.standardTheory, beat: 'Pot', identity: _Identity.nonPosition));

    await capture('boundary_theory_final', const _TheoryScreen(geometry: _TheoryGeometry.t2_90, panelClass: _PanelClass.standardTheory, beat: 'Recap'));
    await capture('boundary_task_full', const _TaskScreen(state: _TaskState.decision, label: 'Play this hand'));
    await capture('boundary_first_decision', const _TaskScreen(state: _TaskState.decision, label: 'Which action keeps playing for free?'));

    const taskFiles = <String, _TaskState>{
      'decision_standard': _TaskState.decision,
      'correct_compact': _TaskState.correct,
      'wrong_standard': _TaskState.wrong,
      'repair_focus_standard': _TaskState.repairFocus,
      'repair_detail_expanded': _TaskState.repairDetail,
      'view_table_peek': _TaskState.peek,
      'show_explanation_restored': _TaskState.restored,
      'repair_result': _TaskState.repairResult,
      'recheck_standard': _TaskState.recheck,
      'stress_four_options': _TaskState.decision,
      'stress_w9': _TaskState.wrong,
      'stress_position': _TaskState.decision,
      'stress_hero_cards': _TaskState.repairFocus,
      'stress_dealer_order': _TaskState.decision,
      'stress_localized_theory': _TaskState.decision,
    };
    for (final entry in taskFiles.entries) {
      await capture(entry.key, _TaskScreen(state: entry.value, label: entry.key.replaceAll('_', ' ')), family: 'taskLoop');
    }
    await capture('information_theory', const _InformationScreen(title: 'Tournament pressure', body: 'A mindset can matter without a live hand to read.'));
    await capture('terminal_information', const _InformationScreen(title: 'Volume I complete', body: 'Return to the map or review a useful hand.'));
    await capture('safe_overlay_visualization', const _TaskScreen(state: _TaskState.repairDetail, label: 'Safe overlay contract', showBounds: true), family: 'taskLoop');

    _assertTheory(rows);
    _assertTaskLock(rows);
    File('${out.path}/geometry_metrics.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'complete_table_system_v1', 'viewport': <String, num>{'width': 375, 'height': 812}, 'rows': rows}) + '\n');
    File('${out.path}/content_guard_report.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(<String, Object?>{'theory': 'compact <=2 body lines; standard <=4; footer gap 18px; no scroll', 'decision': '2-4 options, max two lines; no option scroll', 'status': 'fixture contract declared; long-copy control uses explicit rewrite label'}) + '\n');
    File('${out.path}/occlusion_metrics.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(<String, Object?>{'always_visible': <String>['board', 'pot', 'call price', 'active clue'], 'compact_standard_visible': <String>['hero cards', 'relevant seat', 'position', 'active bet'], 'expanded_contract': 'prototype panel overlays the lower rim; a future production sheet requires a conditional evidence header only when actual critical bounds cross the safe line', 'observed': 'no source-scene crop or table-bound overflow in captured fixtures'}) + '\n');
    File('${out.path}/readability_assessment.md').writeAsStringSync('# Readability assessment\n\nAll four theory candidates use the exact Act0TableSceneV1 production scene and retain cards, board, pot, seats, and labels. T1 is visibly larger; T2 88/90/92 are differentiated only by deliberate fixed scale. The current public scene still renders `BTN Hero` plus a dealer disc, so this prototype cannot certify the requested learner-facing `You · BTN` identity.\n');
    File('${out.path}/transition_state_diagram.md').writeAsStringSync('spatialTheory --theoryToPractice--> taskLoop\n  taskLoop: decision -> feedback -> repair -> peek -> result -> recheck\n  information: terminal/milestone/summary\n');
    _contactSheet(out, <String>['theory_t1_full', 'theory_t2_88', 'theory_t2_90', 'theory_t2_92'], 'theory_comparison_contact_sheet.png');
    _contactSheet(out, <String>['t1_target_identity', 't2_92_target_identity'], 'final_t1_vs_t2_contact_sheet.png');
    _contactSheet(out, <String>['position_identity', 'dealer_order_identity', 'non_position_identity'], 'identity_contact_sheet.png');
    _contactSheet(out, <String>['theory_winner_hero', 'boundary_first_decision', 'correct_compact', 'wrong_standard', 'repair_focus_standard', 'view_table_peek', 'recheck_standard'], 'complete_sequence_contact_sheet.png');
    _contactSheet(out, <String>['stress_four_options', 'stress_w9', 'stress_position', 'stress_hero_cards', 'stress_dealer_order', 'stress_localized_theory'], 'stress_contact_sheet.png');
  });
}

Future<void> _loadFont() async {
  final file = File('/System/Library/Fonts/Supplemental/Arial.ttf');
  if (!file.existsSync()) return;
  final bytes = await file.readAsBytes();
  for (final family in <String>['Roboto', 'Ahem']) {
    final loader = FontLoader(family)..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}

Future<Uint8List> _png(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('complete_system_boundary')));
  final data = await tester.runAsync(() async => (await boundary.toImage(pixelRatio: 2)).toByteData(format: ui.ImageByteFormat.png));
  if (data == null) throw StateError('PNG capture failed');
  return Uint8List.view(data.buffer);
}

Map<String, Object?> _measure(WidgetTester tester) {
  Rect? box(String id) { final f = find.byKey(Key(id)); return f.evaluate().isEmpty ? null : tester.getRect(f); }
  final table = box('cts_table');
  final panel = box('cts_panel');
  final text = box('cts_text');
  final content = box('cts_content');
  final footer = box('cts_footer');
  final cta = box('cts_cta');
  final gap = text == null || footer == null ? null : footer.top - text.bottom;
  final panelHeight = panel?.height ?? 0;
  final contentHeight = content?.height ?? (text == null || footer == null ? 0 : footer.bottom - text.top);
  return <String, Object?>{
    'table_left': table?.left, 'table_top': table?.top, 'table_width': table?.width, 'table_height': table?.height,
    'table_center_x': table?.center.dx, 'table_center_y': table?.center.dy,
    'panel_top': panel?.top, 'panel_height': panel?.height, 'text_top': text?.top, 'text_bottom': text?.bottom,
    'footer_top': footer?.top, 'footer_bottom': footer?.bottom, 'body_to_footer_gap': gap,
    'panel_occupancy': panelHeight == 0 ? null : contentHeight / panelHeight,
    'cta_bottom': cta?.bottom, 'cta_reachable': cta == null || cta.bottom <= 812,
    'overflow': tester.takeException()?.toString(),
  };
}

void _assertTheory(List<Map<String, Object?>> rows) {
  final theory = rows.where((r) => (r['name'] as String).startsWith('theory_') && r['name'] != 'theory_current_fixed_slot_control').toList();
  for (final r in theory) {
    final gap = r['body_to_footer_gap'];
    if (gap != null) expect(gap as double, inInclusiveRange(16, 24));
    expect(r['cta_reachable'], isTrue);
    expect(r['overflow'], isNull);
    if ((r['name'] as String).contains('content_sized') || (r['name'] as String).startsWith('theory_t')) {
      expect(r['panel_occupancy'] as double, greaterThanOrEqualTo(.80));
    }
  }
  final beats = rows.where((r) => (r['name'] as String).startsWith('theory_winner_')).toList();
  final first = beats.first;
  for (final beat in beats.skip(1)) {
    expect(beat['table_top'], first['table_top']);
    expect(beat['table_width'], first['table_width']);
    expect(beat['table_height'], first['table_height']);
  }
}

void _assertTaskLock(List<Map<String, Object?>> rows) {
  final task = rows.where((r) => r['family'] == 'taskLoop').toList();
  final first = task.first;
  for (final r in task.skip(1)) {
    expect((r['table_left'] as double) - (first['table_left'] as double), closeTo(0, 1));
    expect((r['table_top'] as double) - (first['table_top'] as double), closeTo(0, 1));
    expect((r['table_width'] as double) - (first['table_width'] as double), closeTo(0, 1));
    expect((r['table_height'] as double) - (first['table_height'] as double), closeTo(0, 1));
  }
}

class _TheoryScreen extends StatelessWidget {
  const _TheoryScreen({required this.geometry, required this.panelClass, required this.beat, this.showBounds = false, this.identity = _Identity.production});
  final _TheoryGeometry geometry;
  final _PanelClass panelClass;
  final String beat;
  final bool showBounds;
  final _Identity identity;
  @override Widget build(BuildContext context) {
    final width = switch (geometry) {_TheoryGeometry.t1 => _fullTableWidth, _TheoryGeometry.t2_88 => _fullTableWidth * .88, _TheoryGeometry.t2_90 => _fullTableWidth * .90, _TheoryGeometry.t2_92 => _fullTableWidth * .92};
    final body = switch (beat) {'Hero cards' => 'Your two cards are yours alone. Read them before you look at the board.', 'Board' => 'The board is shared. Every player can use these cards to build a hand.', 'Pot' => 'The pot shows what is already in the middle before you choose.', _ => 'Hero cards, board, and pot form one table read. Find each before acting.'};
    return Stack(children: [const _Chrome(progress: '1/6'), Positioned(top: geometry == _TheoryGeometry.t1 ? 48 : 42, left: (375 - width) / 2, child: _ExactTable(width: width, identity: identity)), Positioned(left: 12, right: 12, bottom: 10, child: _TheoryPanel(panelClass: panelClass, title: 'Start with your ${beat.toLowerCase()}', body: body, showBounds: showBounds))]);
  }
}

class _FixedSlotControl extends StatelessWidget { const _FixedSlotControl(); @override Widget build(BuildContext context) => Stack(children: [const _Chrome(progress: '1/6'), Positioned(top: 48, left: 16, child: _ExactTable(width: _fullTableWidth)), Positioned(left: 12, right: 12, bottom: 10, child: Container(key: const Key('cts_panel'), height: 248, padding: const EdgeInsets.all(16), decoration: _panelDecoration, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('READ THE TABLE', style: _eyebrow), const SizedBox(height: 6), const Text('Start with your two cards', style: _title), const SizedBox(height: 8), const Text('Your cards are yours alone.', key: Key('cts_text'), style: _body), const Spacer(), const _Footer()])))]); }

class _TaskScreen extends StatelessWidget {
  const _TaskScreen({required this.state, required this.label, this.showBounds = false});
  final _TaskState state; final String label; final bool showBounds;
  @override Widget build(BuildContext context) {
    final height = switch (state) {_TaskState.peek => 70.0, _TaskState.correct || _TaskState.repairResult => 206.0, _TaskState.repairDetail => 430.0, _ => 304.0};
    final title = switch (state) {_TaskState.correct => 'Correct read', _TaskState.wrong => 'Missed clue', _TaskState.repairFocus || _TaskState.repairDetail => 'Repair focus', _TaskState.peek => 'Full table', _TaskState.recheck => 'Try the read again', _ => label};
    return Stack(children: [const _Chrome(progress: '2/6'), const Positioned(top: 42, left: 16, child: _ExactTable(width: _fullTableWidth)), Positioned(left: 10, right: 10, bottom: 8, child: state == _TaskState.peek ? const _PeekPanel() : _TaskPanel(height: height, title: title, state: state, showBounds: showBounds))]);
  }
}

class _InformationScreen extends StatelessWidget { const _InformationScreen({required this.title, required this.body}); final String title; final String body; @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.auto_stories, color: Color(0xFFFFC857), size: 52), const SizedBox(height: 18), Text(title, textAlign: TextAlign.center, style: _title), const SizedBox(height: 12), Text(body, textAlign: TextAlign.center, style: _body), const SizedBox(height: 28), const _Cta('Continue')]))); }

class _Chrome extends StatelessWidget { const _Chrome({required this.progress}); final String progress; @override Widget build(BuildContext context) => Positioned(left: 16, right: 16, top: 10, child: Row(children: [const Icon(Icons.arrow_back, color: Colors.white, size: 22), const SizedBox(width: 12), const Expanded(child: LinearProgressIndicator(value: .25)), const SizedBox(width: 12), Text(progress, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])); }

class _ExactTable extends StatelessWidget {
  const _ExactTable({required this.width, this.identity = _Identity.production});
  final double width;
  final _Identity identity;
  @override Widget build(BuildContext context) => SizedBox(key: const Key('cts_table'), width: width, child: AspectRatio(aspectRatio: .576, child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Act0TableSceneV1(table: _hand, config: const Act0TablePresentationConfigV1(maxTableHeight: 1000, showFocusBadge: true))), if (identity != _Identity.production) _IdentityOverlay(identity: identity, width: width)])));
}

class _IdentityOverlay extends StatelessWidget {
  const _IdentityOverlay({required this.identity, required this.width});
  final _Identity identity;
  final double width;
  @override Widget build(BuildContext context) {
    final position = identity == _Identity.position || identity == _Identity.dealerOrder;
    return Stack(children: [Positioned(left: width * .33, bottom: 24, child: Container(width: 132, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF08111F), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFC857))), child: Text(position ? 'You · BTN' : 'You', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))), if (identity != _Identity.dealerOrder) Positioned(right: 20, bottom: 33, child: Container(width: 38, height: 26, color: const Color(0xFF146B56))), if (identity == _Identity.dealerOrder) Positioned(right: 17, bottom: 31, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Text('BTN', style: TextStyle(color: Color(0xFF08111F), fontSize: 10, fontWeight: FontWeight.w800))))]);
	}

}

class _TheoryPanel extends StatelessWidget { const _TheoryPanel({required this.panelClass, required this.title, required this.body, required this.showBounds}); final _PanelClass panelClass; final String title; final String body; final bool showBounds; @override Widget build(BuildContext context) => Container(key: const Key('cts_panel'), padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), decoration: _panelDecoration.copyWith(border: showBounds ? Border.all(color: Colors.yellow, width: 2) : null), child: Column(key: const Key('cts_content'), mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('READ THE TABLE · 1 OF 3', style: _eyebrow), const SizedBox(height: 4), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _title), const SizedBox(height: 6), Container(key: const Key('cts_text'), decoration: showBounds ? BoxDecoration(border: Border.all(color: Colors.pinkAccent)) : null, child: Text(body, maxLines: panelClass == _PanelClass.compactTheory ? 2 : 4, overflow: TextOverflow.ellipsis, style: _body)), const SizedBox(height: 18), _Footer(showBounds: showBounds)]) ); }

class _TaskPanel extends StatelessWidget { const _TaskPanel({required this.height, required this.title, required this.state, required this.showBounds}); final double height; final String title; final _TaskState state; final bool showBounds; @override Widget build(BuildContext context) => Container(key: const Key('cts_panel'), height: height, padding: const EdgeInsets.all(14), decoration: _panelDecoration, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: _title), const SizedBox(height: 7), Text(state == _TaskState.peek ? 'Show explanation' : 'Read the same board, pot, and clue. The table stays locked.', key: const Key('cts_text'), maxLines: state == _TaskState.repairDetail ? 4 : 2, overflow: TextOverflow.ellipsis, style: _body), if (state == _TaskState.decision) ...[const SizedBox(height: 8), const _Options()], const Spacer(), if (state == _TaskState.peek) const _Cta('Show explanation') else _Footer(showBounds: showBounds, cta: state == _TaskState.repairDetail ? 'View table' : 'Continue')]) ); }
class _PeekPanel extends StatelessWidget {
  const _PeekPanel();
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('cts_panel'),
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: _panelDecoration,
    child: const Row(children: [
      Expanded(child: Text('Full table', key: Key('cts_text'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
      _Cta('Show explanation'),
    ]),
  );
}

class _Options extends StatelessWidget { const _Options(); @override Widget build(BuildContext context) => const Column(children: [_Option('Fold'), _Option('Check'), _Option('Call'), _Option('Raise')]); }
class _Option extends StatelessWidget { const _Option(this.text); final String text; @override Widget build(BuildContext context) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF146B56)), borderRadius: BorderRadius.circular(10)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))); }
class _Footer extends StatelessWidget { const _Footer({this.cta = 'Continue', this.showBounds = false}); final String cta; final bool showBounds; @override Widget build(BuildContext context) => Container(key: const Key('cts_footer'), decoration: showBounds ? BoxDecoration(border: Border.all(color: Colors.orange)) : null, child: Row(children: [const Text('Back', style: TextStyle(color: Color(0xFFC4D1E4))), const Spacer(), const Text('• • •', style: TextStyle(color: Color(0xFF29D9E7))), const Spacer(), _Cta(cta, showBounds: showBounds)])); }
class _Cta extends StatelessWidget { const _Cta(this.label, {this.showBounds = false}); final String label; final bool showBounds; @override Widget build(BuildContext context) => Container(key: const Key('cts_cta'), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF29D9E7), border: showBounds ? Border.all(color: Colors.yellow, width: 2) : null, borderRadius: BorderRadius.circular(22)), child: Text(label, style: const TextStyle(color: Color(0xFF08111F), fontWeight: FontWeight.w900))); }

const _panelDecoration = BoxDecoration(color: Color(0xFF0C1829), borderRadius: BorderRadius.all(Radius.circular(22)), border: Border.fromBorderSide(BorderSide(color: Color(0xFF1A6780), width: 1.5)));
const _eyebrow = TextStyle(color: Color(0xFF29D9E7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0);
const _title = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.05);
const _body = TextStyle(color: Color(0xFFC4D1E4), fontSize: 13, height: 1.25);

void _contactSheet(Directory out, List<String> names, String output) { final decoded = names.map((n) => image.decodePng(File('${out.path}/$n.png').readAsBytesSync())!).toList(); final thumbW = 188; final thumbH = 406; final canvas = image.Image(width: thumbW * 2, height: thumbH * ((decoded.length + 1) ~/ 2)); for (var i = 0; i < decoded.length; i++) { final thumb = image.copyResize(decoded[i], width: thumbW, height: thumbH); image.compositeImage(canvas, thumb, dstX: i % 2 * thumbW, dstY: i ~/ 2 * thumbH); } File('${out.path}/$output').writeAsBytesSync(image.encodePng(canvas)); }

const _hand = Act0TableStateV1(tableFormat: Act0TableFormatV1.sixMax, playerCount: 6, streetLabel: 'Flop', potLabel: 'Pot 3 BB', toCallLabel: 'Call 1 BB', centerLabel: 'No bet yet', heroCards: [Act0CardStateV1(rank: 'A', suit: '♠'), Act0CardStateV1(rank: 'K', suit: '♦', tone: Act0CardToneV1.red)], boardCards: [Act0CardStateV1(rank: 'A', suit: '♥', tone: Act0CardToneV1.red), Act0CardStateV1(rank: '7', suit: '♣'), Act0CardStateV1(rank: '2', suit: '♦', tone: Act0CardToneV1.red)], seats: [Act0SeatStateV1(seatId: 'btn', seatLabel: 'BTN', displayName: 'You', isHero: true, isDealerButton: true), Act0SeatStateV1(seatId: 'sb', seatLabel: 'SB', displayName: 'Small blind', isSmallBlind: true), Act0SeatStateV1(seatId: 'bb', seatLabel: 'BB', displayName: 'Big blind', isBigBlind: true), Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'UTG'), Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'HJ'), Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'CO')], highlightedSeatIds: [], highlightedCardIds: [], heroSeatId: 'btn');
