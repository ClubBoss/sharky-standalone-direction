import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Learner-copy error classes, each checked across the whole W1–W12 route.
//
// Keep the existing W1–W12 terminology anchors. The stricter W1–W4
// definition-before-use contract lives in act0_learning_order_v1_test.dart.
final _terms = act0GlossaryTermsV1.where((t) => t.teachOrderChecked);

void main() {
  test('W1–W12 retain existing teaching anchors for tracked terms', () {
    final tasks = <({String lesson, String task, String teach, String rest})>[];
    for (final w in Act0ShellStateV1.sample.worlds) {
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
  test('W1–W12 wrong seat answers explain the seat that was chosen', () {
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
    for (final w in Act0ShellStateV1.sample.worlds) {
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
  test('W1–W12 text numbers, street and Hero hand match the table', () {
    final previousHand = RegExp(
      r'\b(?:last|previous) (?:hand|orbit)\b',
      caseSensitive: false,
    );
    double? bb(String s) {
      final m = RegExp(r'([\d.]+)\s*BB').firstMatch(s);
      return m == null ? null : double.parse(m[1]!);
    }

    final check = RegExp(r'^\w+ checks[.!]?$', caseSensitive: false);
    final betIntoPot = RegExp(
      r'\bbets ([\d.]+) BB into ([\d.]+) BB\b',
      caseSensitive: false,
    );
    const order = 'AKQJT98765432';
    final problems = <String>[];
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          final table = r.table;
          for (final item in table.actionTrail) {
            if (!item.isNote && previousHand.hasMatch(item.label)) {
              problems.add(
                '${t.taskId}: prior hand included as current action: "${item.label}"',
              );
            }
          }
          final pot = bb(table.potLabel);
          final call = bb(table.toCallLabel);
          if (table.toCallLabel.isNotEmpty && call == null) {
            problems.add(
              '${t.taskId}: a call label needs an amount: "${table.toCallLabel}"',
            );
          }
          // An explicit starting pot plus a single live wager gives the
          // amount shown now. The call is still only the unmatched wager.
          for (final match in betIntoPot.allMatches(r.caption)) {
            final wager = double.parse(match[1]!);
            final potBeforeBet = double.parse(match[2]!);
            if (pot != potBeforeBet + wager) {
              problems.add(
                '${t.taskId}: pot after ${match[0]} is ${potBeforeBet + wager} BB'
                ', table shows "${table.potLabel}"',
              );
            }
            final currentWagers = table.seats.where((seat) => seat.bet != null);
            if (currentWagers.length == 1 &&
                !currentWagers.single.isHero &&
                bb(currentWagers.single.bet!.amountLabel) == wager &&
                call != wager) {
              problems.add(
                '${t.taskId}: unmatched bet is $wager BB'
                ', table shows "${table.toCallLabel}"',
              );
            }
          }
          final street = table.streetLabel.toLowerCase();
          final actions = table.actionTrail.where((item) => !item.isNote);
          if (call != null &&
              call > 0 &&
              const {'flop', 'turn', 'river'}.contains(street) &&
              actions.isNotEmpty &&
              check.hasMatch(actions.last.label.trim())) {
            problems.add('${t.taskId}: a check cannot leave a price to call');
          }
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

  test('W1–W12 do not equate raw combo counts with action frequency', () {
    final unconditional = RegExp(
      r'(?:more combos means[^.!?]*\b(?:more often|more likely)\b|'
      r'which family appears more often in a range\?|'
      r'combo counts measure how often)',
      caseSensitive: false,
    );
    final problems = <String>[];
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          final copy = [
            r.caption,
            r.question,
            r.hint,
            r.feedbackReason,
            for (final step in r.teachingSteps) step.body,
            for (final option in r.options) option.feedbackReason,
          ];
          for (final text in copy.where(unconditional.hasMatch)) {
            problems.add('${t.taskId}: $text');
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  // Error class: one concept under two names ("shove" next to "all-in",
  // "hole cards" next to "private cards"). The route teaches one name per
  // concept; the right-hand name is the one learners have already seen.
  test('W1–W12 name each poker concept one way', () {
    const variants = <String, String>{
      r'\b[Ss]hov(e|es|ed|ing)\b': 'all-in',
      r'\b[Jj]am(s|med|ming)?\b': 'all-in',
      r'\ball in\b(?! one suit)': 'all-in',
      r'\b[Mm]uck': 'fold',
      r'\b([Hh]ole|[Pp]ocket) cards?\b': 'private cards',
      r'\btable cards?\b': 'board',
      r'\bcost to call\b': 'price / to call',
      r'\d ?bb\b': 'BB',
      r'\d big blinds\b': 'BB',
    };
    final problems = <String>[];
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          final texts = [
            l.title,
            l.subtitle,
            t.title,
            t.summary ?? '',
            r.caption,
            r.question,
            r.hint,
            for (final s in r.teachingSteps) ...[s.title, s.body],
            for (final o in r.options) ...[
              o.label,
              o.feedbackTitle,
              o.feedbackReason,
            ],
            for (final table in [
              r.table,
              for (final s in r.teachingSteps)
                if (s.table != null) s.table!,
            ]) ...[
              table.streetLabel,
              table.potLabel,
              table.toCallLabel,
              table.centerLabel,
              table.focusCalloutLabel,
              table.emptyBoardLabel,
              for (final a in table.actionTrail) a.label,
            ],
          ];
          for (final text in texts) {
            for (final v in variants.entries) {
              final m = RegExp(v.key).firstMatch(text);
              if (m != null) {
                problems.add('${t.taskId}: "${m[0]}" — say "${v.value}"');
              }
            }
            // "Community cards" only where the first lessons explain the
            // shared cards; everywhere else they are the board.
            if (RegExp(r'\bcommunity cards?\b').hasMatch(text) &&
                !const {
                  'what_poker_is',
                  'what_poker_is_content',
                }.contains(l.lessonId)) {
              problems.add('${t.taskId}: "community cards" — say "board"');
            }
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
