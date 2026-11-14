// Dependency-free source-tool checks. Run with the standalone Dart VM.
// These checks do not initialize Flutter or establish runtime/Human learning.
import 'dart:convert';
import 'dart:io';

import '_lib/act0_content_copy_source_parser.dart';
import '_lib/act0_content_copy_registry_parser.dart';

void require(bool value, String message) {
  if (!value) throw StateError(message);
}

void main() {
  final checks = <String, void Function()>{
    'nested string is not an owner field': () => require(
      extractStringField("child: Child(title: 'nested'),", 'title') == null,
      'nested string leaked',
    ),
    'nested identifier is not an owner field': () => require(
      extractIdentifierField('child: Child(runner: _nested),', 'runner') ==
          null,
      'nested identifier leaked',
    ),
    'nested enum is not an owner field': () => require(
      extractEnumField('child: Child(phase: Phase.drill),', 'phase') == null,
      'nested enum leaked',
    ),
    'nested number is not an owner field': () => require(
      extractIntField('child: Child(worldNumber: 99),', 'worldNumber') == null,
      'nested number leaked',
    ),
    'outer fields after nested children keep their owner': () {
      const source =
          "child: Child(title: 'nested', runner: _bad, phase: P.bad, worldNumber: 99), "
          "title: 'owner', runner: _owner, phase: P.theory, worldNumber: 1,";
      require(extractStringField(source, 'title') == 'owner', 'wrong title');
      require(extractIdentifierField(source, 'runner') == '_owner', 'wrong ID');
      require(extractEnumField(source, 'phase') == 'theory', 'wrong enum');
      require(extractIntField(source, 'worldNumber') == 1, 'wrong number');
    },
    'exact field names reject suffix collisions': () => require(
      extractStringField("subtitle: 'not a title',", 'title') == null,
      'field suffix matched',
    ),
    'comments and quoted field names are not arguments': () {
      const source =
          "// title: 'comment'\n"
          "/* outer /* title: 'nested comment' */ ) ] } */ "
          "note: \"title: 'quoted', ) ] }\", title: 'owner',";
      require(extractStringField(source, 'title') == 'owner', 'comment leaked');
    },
    'escaped delimiter and adjacent literals are preserved': () => require(
      extractStringField(
            r"body: 'Hero\'s [cards], ' /* gap */ 'then pot.',",
            'body',
          ) ==
          "Hero's [cards], then pot.",
      'adjacent source literal was truncated',
    ),
    'raw and multiline literal delimiters stay inside strings': () => require(
      extractStringField("body: r'[] ), \\n' '''more, [text]''',", 'body') ==
          r'[] ), \nmore, [text]',
      'raw/triple string drift',
    ),
    'typed map commas do not split arguments': () => require(
      extractStringField(
            "other: const <String, int>{'a': 1}, title: 'owner',",
            'title',
          ) ==
          'owner',
      'generic comma split owner fields',
    ),
    'unsupported values do not become partial literals': () {
      require(
        extractStringField("title: helper('nested'),", 'title') == null,
        'function evaluated',
      );
      require(
        extractStringField("title: 'partial' + helper(),", 'title') == null,
        'partial literal',
      );
      require(
        extractStringField(r"title: '$runtimeValue',", 'title') == null,
        'interpolation evaluated',
      );
      require(
        extractIdentifierField('runner: choose(_nested),', 'runner') == null,
        'nested runner',
      );
      require(
        extractIntField('worldNumber: choose(99),', 'worldNumber') == null,
        'nested number',
      );
    },
    'copyWith identifies only its direct base': () => require(
      extractIdentifierField(
            'runner: _owner.copyWith(child: _nested),',
            'runner',
          ) ==
          '_owner',
      'copyWith base drift',
    ),
    'typed fields tolerate trailing comments': () {
      require(
        extractEnumField('phase: P.drill /* owner */,', 'phase') == 'drill',
        'enum comment',
      );
      require(
        extractIntField('worldNumber: 4 // owner\n,', 'worldNumber') == 4,
        'integer comment',
      );
    },
    'malformed source fails instead of fabricating a field': () {
      var rejected = false;
      try {
        extractStringField("other: [Child(), title: 'fake',", 'title');
      } on FormatException {
        rejected = true;
      }
      require(rejected, 'malformed source accepted');
    },
    'shared delimiter skips comments and double quoted strings': () => require(
      findMatchingParen('(item: ")", /* ) */ next: Foo()) trailing', 0) ==
          '(item: ")", /* ) */ next: Foo())'.length - 1,
      'delimiter escaped its owner',
    ),
    'helper IDs follow actual retitling and insert before recap': () {
      final bundle = Act0SourceParser(_helperFixture).parse();
      final world = bundle.worlds.last;
      final ids = world.lessons.last.tasks.map((t) => t.taskId).toList();
      require(
        jsonEncode(ids) ==
            jsonEncode([
              'target_intro',
              'target_choice',
              'target_extra',
              'target_recap',
            ]),
        'helper canonical IDs/order drift: $ids',
      );
      require(
        world.lessons.last.tasks[1].feedbackReason == 'Owner feedback.',
        'nested feedback borrowed',
      );
      require(
        bundle.worlds.first.lessons.first.tasks[1].taskId == 'choice',
        'source lesson mutated',
      );
    },
    'registry consumer uses the same owner-field boundary': () {
      final registry = Act0CopyRegistryParser("""
const _enWorldCopyByIdV1 = <String, Act0WorldDisplayCopyV1>{
  'world_1': Act0WorldDisplayCopyV1(child: Child(title: 'nested'), title: 'owner', subtitle: 'goal'),
};
""", languageCode: 'en').parse();
      require(
        registry.worlds['world_1']?.title == 'owner',
        'registry nested field leak',
      );
    },
    'present unresolved copyWith fields do not inherit known base copy': () {
      final dynamicSource = _helperFixture
          .replaceFirst(
            'final _sourceLessons',
            'final _derived = _base.copyWith(question: runtimeQuestion, feedbackReason: makeReason(), teachingSteps: runtimeSteps);\nfinal _sourceLessons',
          )
          .replaceAll('runner: _base', 'runner: _derived');
      final task = Act0SourceParser(
        dynamicSource,
      ).parse().worlds.first.lessons.first.tasks.first;
      require(
        task.question == null && task.feedbackReason == null,
        'dynamic override borrowed base copy',
      );
      require(
        task.teachingSteps.isEmpty,
        'dynamic teaching borrowed base steps',
      );
      final absentSource = _helperFixture
          .replaceFirst(
            'final _sourceLessons',
            'final _inherits = _base.copyWith(options: []);\nfinal _sourceLessons',
          )
          .replaceAll('runner: _base', 'runner: _inherits');
      final inherited = Act0SourceParser(
        absentSource,
      ).parse().worlds.first.lessons.first.tasks.first;
      require(
        inherited.question == 'What is visible?' &&
            inherited.feedbackReason == 'Owner feedback.',
        'absent field lost valid base inheritance',
      );
      require(
        inherited.teachingSteps.single.body == 'Base teaching.',
        'absent teaching field lost valid inheritance',
      );
    },
    'inline copyWith resolves owner overrides without borrowing nested copy': () {
      final source = _helperFixture.replaceAll(
        'runner: _base.copyWith(options: [])',
        "runner: _base /* gap */ .copyWith (options: [Option(feedbackReason: 'nested')], question: 'Inline owner question', feedbackReason: dynamicReason)",
      );
      final task = Act0SourceParser(
        source,
      ).parse().worlds.first.lessons.first.tasks[1];
      require(
        task.question == 'Inline owner question',
        'inline owner question lost',
      );
      require(
        task.feedbackReason == null,
        'inline unknown borrowed base/nested feedback',
      );
    },
    'actual W1-W4 task IDs and owner feedback remain explicit': () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
      ).readAsStringSync();
      final worlds = Act0SourceParser(
        source,
      ).parse().worlds.where((w) => w.worldNumber <= 4).toList();
      require(
        jsonEncode(worlds.map((w) => w.lessons.length).toList()) == '[9,6,6,7]',
        'world/lesson extraction drift',
      );
      final tasks = worlds
          .expand((w) => w.lessons.expand((l) => l.tasks))
          .toList();
      require(
        tasks.length == 181,
        'task extraction changed; review actual source',
      );
      require(
        tasks.map((t) => t.taskId).toSet().length == tasks.length,
        'canonical task collision',
      );
      require(
        tasks.first.feedbackReason ==
            'You identifies the learner; BTN is the seat role that acts after CO here.',
        'real nested-feedback regression',
      );
      require(
        tasks.any((t) => t.taskId == 'weak_ace_warning_weak_ace_pressure_fold'),
        'real helper prefix absent',
      );
      require(
        tasks.any((t) => t.taskId == 'early_vs_late_early_pressure_choice'),
        'second helper prefix absent',
      );
    },
  };
  var passed = 0;
  for (final entry in checks.entries) {
    try {
      entry.value();
      passed += 1;
    } catch (error) {
      stderr.writeln('FAIL ${entry.key}: $error');
      exitCode = 1;
    }
  }
  stdout.writeln(
    jsonEncode({
      'scope': 'source-tool only',
      'passed': passed,
      'failed': checks.length - passed,
      'total': checks.length,
    }),
  );
}

const _helperFixture = """
final _base = Act0RunnerStateV1(caption: 'Read the table.', question: 'What is visible?', options: [Option(feedbackReason: 'nested')], feedbackReason: 'Owner feedback.', teachingSteps: <Act0TeachingStepV1>[Act0TeachingStepV1(title: 'Base title', body: 'Base teaching.')]);
final _sourceLessons = <Act0LessonCardV1>[
 Act0LessonCardV1(lessonId: 'source', title: 'Source', subtitle: 'Goal', tasks: <Act0LessonTaskV1>[
  Act0LessonTaskV1(taskId: 'intro', title: 'Intro', phase: Phase.theory, runner: _base),
  Act0LessonTaskV1(taskId: 'choice', title: 'Choice', phase: Phase.drill, runner: _base.copyWith(options: [])),
  Act0LessonTaskV1(taskId: 'recap', title: 'Recap', phase: Phase.review, runner: _base),
 ]),
];
final _targetLessons = <Act0LessonCardV1>[
 _lessonFromTasksV1(lessonId: 'target', title: 'Target', subtitle: 'Target goal', sourceTasks: _sourceLessons[0].taskList, extraDrills: <Act0LessonTaskV1>[
  Act0LessonTaskV1(taskId: 'extra', title: 'Extra', phase: Phase.drill, runner: _base),
 ]),
];
final _act0PreviewWorlds = <Act0WorldCardV1>[
 Act0WorldCardV1(worldId: 'world_1', worldNumber: 1, title: 'Source world', subtitle: 'Source goal', lessons: _sourceLessons),
 Act0WorldCardV1(worldId: 'world_2', worldNumber: 2, title: 'Target world', subtitle: 'Target goal', lessons: _targetLessons),
];
""";
