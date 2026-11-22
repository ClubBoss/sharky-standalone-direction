import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_shell_source_files_v1.dart';

const _baselineFile = 'test/fixtures/act0_learning_order_baseline_v1.json';

final _route = [
  for (final world in Act0ShellStateV1.sample.worlds)
    if (world.worldNumber >= 1 && world.worldNumber <= 4)
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          (lesson: lesson.lessonId, task: task),
];

// Explicit definitions, including forms L1 can use for concepts that currently
// have no worked definition. Names and use patterns belong to the glossary.
// Title words, examples without a rule, optional hints and feedback alone
// cannot establish knowledge for a later first attempt.
const _definitions = {
  'Strongest starting hand':
      r'(?:two aces|pocket aces|a pair of aces|aa) (?:is|are) the strongest starting hand',
  'Hero': r'hero means you',
  'Blinds (SB, BB)':
      r'blinds? (?:are|means?) (?:forced|mandatory)|bb also measures chips|small blind (?:\(sb\) )?is .*half.*big blind',
  'Button (BTN)': r'btn is button|btn marks the (?:dealer )?button',
  'Positions (UTG, HJ, CO)':
      r'utg means under the gun.*hj is hijack.*co is cutoff',
  'All-in':
      r'(?:all-in (?:means|is) (?:no chips behind|putting in|when you)|0 bb behind = all-in)',
  'Preflop': r'preflop (?:means|starts with) no board',
  'Flop':
      r'first three (?:board|shared) cards|three (?:shared|board) cards \(the flop\)|flop (?:has|shows) (?:three|3)',
  'Turn': r'turn (?:means one more board card|shows 4|is the fourth)',
  'River':
      r'last street, the river|river (?:shows 5|adds the fifth|is the fifth)',
  'Postflop':
      r'postflop (?:means|is) (?:after|every betting round after) the flop',
  'Showdown':
      r'at showdown, the best 5-card hand wins|players compare hands at showdown|showdown (?:means|is when) (?:players compare|reveal)',
  'Pot':
      r'pot (?:is the chips in the middle|is in the middle\..*stack|means chips already committed)|how many chips are already in the pot',
  'Limp':
      r'limping \(just calling the big blind\)|limp(?:ing)? (?:means|is) (?:just )?calling the big blind',
  'First in':
      r'first[- ]in (?:means|is) (?:the |being )?first (?:player )?to (?:enter|put chips in) voluntarily',
  'Open / opener':
      r'(?:an )?open (?:is|means) the first raise (?:before the flop|preflop)|the opener is the (?:player|first player) who (?:opens|raises first)',
  'In position':
      r'in position (?:means|when) you act after|in position when you act after',
  'Offsuit':
      r'o means offsuit.*(?:different|two) suits|offsuit (?:means|is) (?:two cards (?:of|with) )?different suits',
  'Suited':
      r'suited (?:means|is) (?:two cards (?:of|with) )?(?:the )?same suit|same suit.*(?:means|is) suited',
  'Kicker':
      r'(?:kickers? break some ties|kicker (?:is|means) a (?:side|unpaired) card)',
  'Straight':
      r'a straight is five ranks in a row|straight (?:means|is) (?:five ranks|a sequence of five)',
  'Flush':
      r'flush(?:es)? \(five cards of one suit\)|flush means same suit.*five hearts|a flush (?:is|means) five cards of one suit',
  'For value':
      r'value means worse hands can still call|value (?:bet|betting) (?:is|means) .*weaker hands .*call',
  'Bluff':
      r'a bluff tries to make better hands fold|a bluff tries to win when better hands fold',
  'Protection': r'protection (?:bets )?makes? the next card cost',
  'One-third pot':
      r'one-third(?: of the pot| pot) (?:means|is) (?:betting )?(?:one-third|a third)',
  'Half-pot': r'half[- ]pot (?:means|is) (?:betting )?half the pot',
  'Pot-size':
      r'pot[- ]size (?:means|is) (?:a bet that matches|a bet equal to|the bet matches) the pot',
  'Broadway':
      r'broadway (?:cards|ranks) are t(?:en)?, j(?:ack)?, q(?:ueen)?, k(?:ing)?, and a(?:ce)?',
  'Dominated':
      r'dominated (?:means|when).*?(?:same|share).*?(?:rank|ace).*?(?:lower|weaker|worse)',
  'Top pair':
      r'top pair (?:is|means|when).*?(?:matches|matching) the highest (?:rank|card) on the (?:board|flop)',
  'Middle pair':
      r'(?:middle|second) pair (?:is|means|when).*?(?:matches|matching) the second-highest (?:rank|card) on the (?:board|flop)',
  'Set':
      r'(?:a )?set (?:is|means).*?(?:pair in (?:your|the) (?:private cards|hand)|pocket pair).*?(?:board|flop)',
  'Draw':
      r'draw (?:is|means) (?:a chance|an unfinished hand|a hand that can improve)',
  'Flush draw':
      r'flush draw (?:is|means).*?four (?:cards of one suit|cards of the same suit)',
  'Dry board':
      r'dry (?:board|flop) (?:is|means|has).*?few.*?(?:draws|ways to complete)',
};

String _normalized(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

Set<String> _earlyUses() {
  final terms = {
    for (final term in [
      ...act0GlossaryTermsV1,
      const Act0GlossaryTermV1(
        'Strongest starting hand',
        r'\bstrongest starting hand\b',
        '',
      ),
    ])
      if (_definitions.containsKey(term.name))
        term: RegExp(_definitions[term.name]!, caseSensitive: false),
  };
  expect(
    terms.length,
    _definitions.length,
    reason: 'Definition checks must reference known glossary terms',
  );

  final known = <Act0GlossaryTermV1>{};
  final findings = <String>{};
  for (final row in _route) {
    final runner = row.task.runner;
    void read(String text, {bool canDefine = false}) {
      for (final entry in terms.entries) {
        final term = entry.key;
        if (known.contains(term)) continue;
        if (canDefine && entry.value.hasMatch(_normalized(text))) {
          known.add(term);
        } else if (term.usedIn(text)) {
          findings.add('${row.task.taskId}|${term.name}');
        }
      }
    }

    for (final step in runner.teachingSteps) {
      read('${step.title} ${step.body}', canDefine: true);
      for (final action
          in step.table?.actionTrail ?? const <Act0ActionTrailItemV1>[]) {
        read(action.learnerLabel);
      }
    }
    read(runner.caption, canDefine: true);
    for (final action in runner.table.actionTrail) {
      read(action.learnerLabel);
    }
    read(runner.question, canDefine: true);
    if (runner.hintPolicy != Act0HintPolicyV1.hidden) read(runner.hint);
    read(runner.feedbackReason);
    for (final option in runner.options) {
      read('${option.label} ${option.feedbackTitle} ${option.feedbackReason}');
    }
  }
  return findings;
}

String _cards(List<Act0CardStateV1> cards) {
  final sorted = [for (final card in cards) '${card.rank}${card.suit}']..sort();
  return sorted.join(' ');
}

Set<String> _exactRepeatViolations() {
  final firstIds = <Object, String>{};
  var allowedRepeatUsed = false;
  final findings = <String>{};
  for (final row in _route) {
    final runner = row.task.runner;
    final question = _normalized(runner.question);
    if (question.isEmpty) continue;
    final correct = [
      for (final option in runner.options)
        if (act0RunnerOptionIsAuthoredCorrectV1(option))
          '${_normalized(option.label)}|${option.seatId ?? ''}',
    ]..sort();
    final key = (
      question,
      _cards(runner.table.heroCards),
      _cards(runner.table.boardCards),
      correct.join('\n'),
    );
    final first = firstIds.putIfAbsent(key, () => row.task.taskId);
    if (first == row.task.taskId) continue;
    final inReview =
        row.task.phase == Act0LessonPhaseV1.review ||
        row.lesson.endsWith('_checkpoint');
    if (!inReview || allowedRepeatUsed) {
      findings.add('${row.task.taskId}|$first');
    } else {
      allowedRepeatUsed = true;
    }
  }
  return findings;
}

Set<String> _feedbackCollisions() => {
  for (final row in _route)
    for (final option in row.task.runner.options)
      if (!option.isCorrect &&
          option.feedbackReason.trim().isNotEmpty &&
          row.task.runner.options.any(
            (correct) =>
                correct.isCorrect &&
                _normalized(correct.feedbackReason) ==
                    _normalized(option.feedbackReason),
          ))
        '${row.task.taskId}|${option.id}',
};

Expression? _argument(ArgumentList list, String name) {
  for (final argument in list.arguments.whereType<NamedExpression>()) {
    if (argument.name.label.name == name) return argument.expression;
  }
  return null;
}

ArgumentList? _constructorArguments(AstNode? node, String name) =>
    switch (node) {
      InstanceCreationExpression()
          when node.constructorName.type.name2.lexeme == name =>
        node.argumentList,
      MethodInvocation()
          when node.target == null && node.methodName.name == name =>
        node.argumentList,
      _ => null,
    };

Object? _questionValue(Expression? expression) => expression is StringLiteral
    ? expression.stringValue
    : expression?.toSource();

// Walk only declarations feeding W1–W4, including their shared runner bases.
// Parsing Dart keeps nested copyWith calls, strings and comments distinct.
class _RunnerCopyCheck extends RecursiveAstVisitor<void> {
  _RunnerCopyCheck(this.declarations);

  final Map<String, Expression> declarations;
  final visited = <String>{};
  final failures = <String>{};
  var owner = '';

  void walk(String name) {
    final expression = declarations[name];
    if (expression == null || !visited.add(name)) return;
    final previous = owner;
    owner = name;
    expression.accept(this);
    owner = previous;
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) => walk(node.name);

  @override
  void visitIndexExpression(IndexExpression node) {
    final target = node.realTarget;
    final index = node.index;
    if (target is SimpleIdentifier && index is IntegerLiteral) {
      final list = declarations[target.name];
      final offset = index.value;
      if (list is ListLiteral &&
          offset != null &&
          offset >= 0 &&
          offset < list.elements.length &&
          list.elements.every((element) => element is Expression)) {
        // Active lessons can borrow a specific legacy lesson's task list.
        list.elements[offset].accept(this);
        return;
      }
    }
    super.visitIndexExpression(node);
  }

  Expression? field(Expression? runner, String key, Set<String> seen) {
    if (runner is SimpleIdentifier && seen.add(runner.name)) {
      return field(declarations[runner.name], key, seen);
    }
    final constructor = _constructorArguments(runner, 'Act0RunnerStateV1');
    if (constructor != null) return _argument(constructor, key);
    if (runner is MethodInvocation && runner.methodName.name == 'copyWith') {
      return _argument(runner.argumentList, key) ??
          field(runner.realTarget, key, seen);
    }
    return null;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final question = _argument(node.argumentList, 'question');
    final options = _argument(node.argumentList, 'options');
    final base = node.realTarget;
    if (node.methodName.name == 'copyWith' &&
        question != null &&
        (options == null ||
            options is NullLiteral ||
            options.toSource() == '${base?.toSource()}.options')) {
      final originalOptions = field(base, 'options', {});
      final originalQuestion = field(base, 'question', {});
      if ((originalOptions is! ListLiteral ||
              originalOptions.elements.isNotEmpty) &&
          _questionValue(question) != _questionValue(originalQuestion)) {
        var id = owner;
        for (
          AstNode? parent = node.parent;
          parent != null;
          parent = parent.parent
        ) {
          final task = _constructorArguments(parent, 'Act0LessonTaskV1');
          if (task != null) {
            id = _questionValue(_argument(task, 'taskId'))?.toString() ?? owner;
            break;
          }
        }
        failures.add('$id|${base?.toSource()}');
      }
    }
    super.visitMethodInvocation(node);
  }
}

Set<String> _inheritedChoices(Iterable<String> sources) {
  final declarations = <String, Expression>{};
  for (final source in sources) {
    final unit = parseString(content: source).unit;
    for (final declaration
        in unit.declarations.whereType<TopLevelVariableDeclaration>()) {
      for (final variable in declaration.variables.variables) {
        if (variable.initializer != null) {
          declarations[variable.name.lexeme] = variable.initializer!;
        }
      }
    }
  }
  final worlds = declarations['_act0PreviewWorlds']! as ListLiteral;
  final check = _RunnerCopyCheck(declarations);
  var rootCount = 0;
  for (final card in worlds.elements) {
    final arguments = _constructorArguments(card, 'Act0WorldCardV1');
    if (arguments == null) continue;
    final number = _argument(arguments, 'worldNumber');
    if (number is! IntegerLiteral ||
        !const {1, 2, 3, 4}.contains(number.value)) {
      continue;
    }
    rootCount++;
    final lessons = _argument(arguments, 'lessons')!;
    lessons.accept(check);
  }
  expect(rootCount, 4);
  return check.failures;
}

final _chartLabel = RegExp(r'\b(?:Premium|Strong|Medium|Weak)\b');
final _preflopAction = RegExp(
  r'^(?:fold|check|call|raise|re-?raise|limp|all-in|go all-in|jam)\b',
  caseSensitive: false,
);
final _mechanicalPrompt = RegExp(
  r'\b(?:makes? the next player match more|make the next player match more|'
  r'sets? a higher price|increases? the price|matches? the [0-9.]+ bb price|'
  r'gives? up the hand|keeps? playing for free|keeps? you in the hand without adding chips)\b',
  caseSensitive: false,
);
const _handStrengthDescription =
    r'\s+(?:is|are|belongs? to)\b[^.?!]{0,35}'
    r'(?:\b(?:premium|strong|medium|weak)\s+(?:bucket|group|tier)\b|'
    r'\b(?:strongest|top|premium|strong|medium|weak)\b[^.?!]{0,35}\b(?:starting|preflop)\b)';

bool _needsStartingStrength(Act0LessonTaskV1 task) {
  final runner = task.runner;
  return task.phase != Act0LessonPhaseV1.theory &&
      !task.repairOnly &&
      runner.table.streetLabel.toLowerCase() == 'preflop' &&
      runner.options.any(
        (option) => option.isCorrect && _preflopAction.hasMatch(option.label),
      ) &&
      runner.options
              .where((option) => _preflopAction.hasMatch(option.label))
              .length >=
          2 &&
      !_mechanicalPrompt.hasMatch(runner.question);
}

bool _teachesOwnStartingStrength(Act0LessonTaskV1 task, String text) {
  final code = startingHandCode(physicalCards(task.runner.table.heroCards));
  if (code == null) return false;
  final pairName = switch (code) {
    'AA' => 'aces',
    'KK' => 'kings',
    'QQ' => 'queens',
    'JJ' => 'jacks',
    'TT' => 'tens',
    '99' => 'nines',
    '88' => 'eights',
    '77' => 'sevens',
    '66' => 'sixes',
    '55' => 'fives',
    '44' => 'fours',
    '33' => 'threes',
    '22' => 'twos',
    _ => null,
  };
  final names = [
    RegExp.escape(code),
    if (pairName != null) '(?:two|pocket|a pair of) $pairName',
  ];
  return RegExp(
    r'\b(?:' + names.join('|') + r')\b' + _handStrengthDescription,
    caseSensitive: false,
  ).hasMatch(text);
}

Set<String> _earlyStartingHandFindings(
  Act0LessonTaskV1 task, {
  required bool checkChartLabels,
}) {
  final runner = task.runner;
  final teaching = [
    for (final step in runner.teachingSteps) '${step.title} ${step.body}',
  ];
  final findings = <String>{};
  if (_needsStartingStrength(task) &&
      !teaching.any((text) => _teachesOwnStartingStrength(task, text))) {
    findings.add('${task.taskId}: starting-hand strength missing from TEACH');
  }
  if (checkChartLabels &&
      [
        task.title,
        runner.caption,
        runner.question,
        runner.hint,
        runner.feedbackTitle,
        runner.feedbackReason,
        for (final option in runner.options) ...[
          option.label,
          option.preferredLabel,
          option.betterAnswerLabel,
          option.feedbackTitle,
          option.feedbackReason,
          ...option.repairFocusLabels,
        ],
        for (final text in teaching)
          if (!_teachesOwnStartingStrength(task, text)) text,
      ].any(_chartLabel.hasMatch)) {
    findings.add(
      '${task.taskId}: starting-chart label outside its TEACH explanation',
    );
  }
  return findings;
}

void main() {
  final baseline = jsonDecode(File(_baselineFile).readAsStringSync()) as Map;
  void guard(String name, Set<String> Function() check) {
    test(name, () {
      final current = check();
      final allowed = (baseline[name] as List).cast<String>().toSet();
      final added = current.difference(allowed).toList()..sort();
      final resolved = allowed.difference(current).toList()..sort();
      expect(added, isEmpty, reason: 'New violations:\n${added.join('\n')}');
      expect(
        resolved,
        isEmpty,
        reason: 'Remove resolved exceptions:\n${resolved.join('\n')}',
      );
    });
  }

  test(
    'Starting-hand decisions before Hand buckets explain their own hand',
    () {
      final end = catalogTasks.lastIndexWhere(
        (row) =>
            row.world.worldNumber == 2 &&
            row.lesson.lessonId == 'hand_discipline_buckets',
      );
      expect(end, greaterThan(0));
      final early = catalogTasks.take(end + 1).toList();
      expect({
        for (final row in early)
          ..._earlyStartingHandFindings(
            row.task,
            checkChartLabels: row.world.worldNumber == 1,
          ),
      }, isEmpty);
      final first = early.firstWhere(
        (row) =>
            row.world.worldNumber == 1 &&
            _needsStartingStrength(row.task) &&
            !row.task.guidedDecision,
      );
      expect(
        first.task.taskId,
        'cards_ranks_suits_premium_decision',
        reason: 'F1 counts the independent decision.',
      );
    },
  );

  test(
    'A preflop strength decision fails when the explanation is only after the choice',
    () {
      final source = catalogTasks
          .singleWhere(
            (row) => row.task.taskId == 'first_table_guide_first_decision',
          )
          .task;
      final withoutTeaching = Act0LessonTaskV1(
        taskId: source.taskId,
        title: source.title,
        phase: source.phase,
        runner: source.runner.copyWith(
          teachingSteps: const [],
          feedbackReason: 'Two aces are the strongest starting hand.',
        ),
        rewardXp: source.rewardXp,
        guidedDecision: true,
      );
      expect(
        _earlyStartingHandFindings(withoutTeaching, checkChartLabels: true),
        {
          'first_table_guide_first_decision: starting-hand strength missing from TEACH',
        },
      );
      expect(
        _teachesOwnStartingStrength(
          source,
          'You hold AA. Two kings are a top starting pair.',
        ),
        isFalse,
      );
      expect(
        _teachesOwnStartingStrength(source, 'AA is in the Premium group.'),
        isTrue,
      );
      expect(
        _earlyStartingHandFindings(source, checkChartLabels: true),
        isEmpty,
      );
    },
  );

  test('Foundation copy uses the learner name and plain hand facts', () {
    final jargon = RegExp(
      r'\b(?:hero|villain|w3|ante|antes|straddle|rake)\b',
      caseSensitive: false,
    );
    final violations = <String>[];
    for (final row in _route) {
      final runner = row.task.runner;
      final visible = <String>[
        row.task.title,
        runner.caption,
        runner.hint,
        runner.question,
        runner.feedbackTitle,
        runner.feedbackReason,
        runner.table.centerLabel,
        runner.table.focusCalloutLabel,
        for (final item in runner.table.actionTrail) item.learnerLabel,
        for (final step in runner.teachingSteps) ...[
          step.title,
          step.body,
          ...step.focusLabels,
          for (final item in step.table?.actionTrail ?? const [])
            item.learnerLabel,
        ],
        for (final option in runner.options) ...[
          option.label,
          option.preferredLabel,
          option.feedbackTitle,
          option.feedbackReason,
        ],
      ];
      for (final copy in visible.where(jargon.hasMatch)) {
        violations.add('${row.task.taskId}: $copy');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  guard('termsBeforeDefinition', _earlyUses);
  guard('exactRepeatsOutsideBudget', _exactRepeatViolations);
  guard(
    'questionOverridesInheritingOptions',
    () => _inheritedChoices(readAct0ShellStateCatalogSourcesV1()),
  );
  guard('wrongFeedbackEqualsCorrect', _feedbackCollisions);
}
