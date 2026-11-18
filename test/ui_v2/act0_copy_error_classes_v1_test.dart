import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Learner-copy error classes, each checked across the whole W1–W4 route.
//
// Class: a poker term shows up
// in learner text before any lesson explains it. A term counts as explained
// at the first task whose teaching step uses it, or that defines it inline
// (the `inline` pattern). Use inside the same lesson as the explanation is
// allowed: that lesson is what teaches it.
class _Term {
  const _Term(this.name, this.use, {this.inline});
  final String name;
  final String use;
  final String? inline;
}

const _terms = <_Term>[
  _Term('preflop', r'\bpreflop\b'),
  _Term('flop', r'\bflop\b', inline: r'\(the flop\)'),
  _Term('river', r'\briver\b', inline: r'last street, the river'),
  _Term('postflop', r'\bpostflop\b'),
  _Term('limp', r'\blimp', inline: r'limping \(just calling the big blind\)'),
  _Term('first in', r'\bfirst in\b'),
  _Term('flush', r'\bflush', inline: r'flushes \(five cards of one suit\)'),
  _Term('straight', r'\bstraight\b'),
  _Term('kicker', r'\bkicker'),
  _Term('offsuit', r'\boffsuit\b'),
  _Term('range', r'\branges?\b'),
  _Term('equity', r'\bequity\b'),
  _Term('draw', r'\bdraws?\b|\bdraw-'),
  _Term('texture', r'\btexture\b'),
  _Term(
    'for value',
    r'\bfor value\b|\bvalue bet',
    inline: r'value bet wants weaker hands to call',
  ),
];

void main() {
  test('W1–W4 terms are explained before they are used', () {
    final tasks = <({String lesson, String task, String teach, String rest})>[];
    for (final w in Act0ShellStateV1.sample.worlds.where(
      (w) => w.worldNumber <= 4,
    )) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          tasks.add((
            lesson: l.lessonId,
            task: t.taskId,
            teach: [
              for (final s in r.teachingSteps) '${s.title} ${s.body}',
            ].join(' '),
            rest: [
              r.caption,
              r.question,
              r.hint,
              for (final o in r.options) '${o.label} ${o.feedbackReason}',
            ].join(' '),
          ));
        }
      }
    }
    final problems = <String>[];
    for (final term in _terms) {
      final use = RegExp(term.use, caseSensitive: false);
      final inline = term.inline == null
          ? null
          : RegExp(term.inline!, caseSensitive: false);
      int? firstUse;
      int? explained;
      for (var i = 0; i < tasks.length; i++) {
        final t = tasks[i];
        final text = '${t.teach} ${t.rest}';
        if (firstUse == null && use.hasMatch(text)) firstUse = i;
        if (explained == null &&
            (use.hasMatch(t.teach) || (inline?.hasMatch(text) ?? false))) {
          explained = i;
        }
      }
      if (firstUse == null) continue;
      final used = tasks[firstUse];
      final ok =
          explained != null &&
          (explained <= firstUse || tasks[explained].lesson == used.lesson);
      if (!ok) {
        problems.add(
          '${term.name}: used in ${used.task} before it is explained'
          '${explained == null ? ' (never explained)' : ' (explained in ${tasks[explained].task})'}',
        );
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  // Error class: a wrong seat answer whose explanation talks only about
  // other seats ("BTN is the dealer seat, not UTG" on an HJ answer).
  test('W1–W4 wrong seat answers explain the seat that was chosen', () {
    const names = {
      'utg': 'UTG',
      'hj': 'HJ',
      'co': 'CO',
      'btn': 'BTN',
      'sb': 'SB',
      'bb': 'BB',
    };
    const aliases = {
      'Button': 'BTN',
      'Cutoff': 'CO',
      'Hijack': 'HJ',
      'small blind': 'SB',
      'big blind': 'BB',
    };
    final seat = RegExp(
      r'\b(UTG|HJ|CO|BTN|SB|BB|Button|Cutoff|Hijack|small blind|big blind)\b',
    );
    final problems = <String>[];
    for (final w in Act0ShellStateV1.sample.worlds.where(
      (w) => w.worldNumber <= 4,
    )) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          for (final o in t.runner.options) {
            final own = names[o.seatId];
            if (o.isCorrect || own == null) continue;
            final named = {
              for (final m in seat.allMatches(o.feedbackReason))
                aliases[m[1]] ?? m[1]!,
            };
            if (named.isNotEmpty && !named.contains(own)) {
              problems.add('${t.taskId}/${o.id}: ${o.feedbackReason}');
            }
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  // Error class: task text states a pot, a price, a street or Hero's hand
  // that differs from what the table on the same screen shows.
  test('W1–W4 text numbers, street and Hero hand match the table', () {
    double? bb(String s) {
      final m = RegExp(r'([\d.]+)\s*BB').firstMatch(s);
      return m == null ? null : double.parse(m[1]!);
    }

    const order = 'AKQJT98765432';
    final problems = <String>[];
    for (final w in Act0ShellStateV1.sample.worlds.where(
      (w) => w.worldNumber <= 4,
    )) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          final table = r.table;
          final pot = bb(table.potLabel);
          final call = bb(table.toCallLabel);
          final street = table.streetLabel.toLowerCase();
          final hero = [for (final c in table.heroCards) c.rank]
            ..sort((a, b) => order.indexOf(a) - order.indexOf(b));
          for (final text in [r.caption, r.question, r.hint]) {
            for (final m in RegExp(
              r'\b[Pp]ot (?:is |of )?([\d.]+) BB',
            ).allMatches(text)) {
              if (pot != null && double.parse(m[1]!) != pot) {
                problems.add('${t.taskId}: "${m[0]}" vs ${table.potLabel}');
              }
            }
            for (final m in RegExp(
              r'\bto call ([\d.]+) BB',
              caseSensitive: false,
            ).allMatches(text)) {
              if (call != null && double.parse(m[1]!) != call) {
                problems.add('${t.taskId}: "${m[0]}" vs ${table.toCallLabel}');
              }
            }
            for (final s in ['preflop', 'flop', 'turn', 'river']) {
              final says = RegExp(
                '\\b(on|at) the $s\\b|\\bthis $s\\b',
                caseSensitive: false,
              ).hasMatch(text);
              if (says && street.isNotEmpty && s != street) {
                problems.add('${t.taskId}: says $s, table is $street');
              }
            }
            if (hero.length == 2 && !hero.contains('?')) {
              for (final m in RegExp(
                r'(?:Hero|You)[^.]*?\bwith ([AKQJT2-9])([AKQJT2-9])[so]?\b',
              ).allMatches(text)) {
                final named = [m[1]!, m[2]!]
                  ..sort((a, b) => order.indexOf(a) - order.indexOf(b));
                if (named.join() != hero.join()) {
                  problems.add('${t.taskId}: "${m[0]}" vs ${hero.join()}');
                }
              }
            }
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
