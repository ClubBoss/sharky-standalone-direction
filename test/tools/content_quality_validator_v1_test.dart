import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_quality_validator_v1.dart';

void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync(
      'content_quality_validator_',
    );
  });

  tearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  Future<ContentQualityValidationResultV1> validateModule(
    String moduleId, {
    required String theory,
    required List<String> drills,
    Map<String, Object?>? manifest,
  }) async {
    final dir = Directory('${tempRoot.path}/content/$moduleId/v1')
      ..createSync(recursive: true);
    File('${dir.path}/theory.md').writeAsStringSync(theory);
    File('${dir.path}/drills.jsonl').writeAsStringSync(drills.join('\n'));
    if (manifest != null) {
      File('${dir.path}/manifest.json').writeAsStringSync(jsonEncode(manifest));
    }
    return validateContentVersionDirV1(dir);
  }

  Directory repoModuleDir(String moduleId) {
    return Directory('${Directory.current.path}/content/$moduleId/v1');
  }

  test('passes on current beginner repo content smoke', () async {
    final dirs = <Directory>[
      repoModuleDir('world1_act0_table_literacy'),
      repoModuleDir('world1_act0_action_literacy'),
      repoModuleDir('world1_act0_street_flow'),
      repoModuleDir('intro_game_flow'),
      repoModuleDir('intro_hand_rankings'),
    ];

    for (final dir in dirs) {
      final result = await validateContentVersionDirV1(dir);
      expect(
        result.errors,
        isEmpty,
        reason: 'expected ${dir.path} to pass beginner unification gates',
      );
    }
  });

  test('passes on a minimal valid Act0 fixture', () async {
    final result = await validateModule(
      'world1_act0_table_literacy',
      theory: '''# Act 0 Table Literacy

- Start with one anchor: Button is your north star.
- Small Blind is left of Button. Big Blind is next.
- Preflop starts left of the Big Blind.
- After the flop, action starts with the Small Blind, or the first live seat left of Button.
- At showdown, the pot goes to the best five-card hand.
- Use one short ladder: High Card (no pair) < Pair < Two Pair.
''',
      drills: const <String>[
        '{"id":"d1","goal":"Tap Button.","instruction_text":"Find Button.","expected_action_kind":"tap_seat"}',
      ],
      manifest: const <String, Object?>{'id': 'world1_act0_table_literacy'},
    );

    expect(result.errors, isEmpty);
  });

  test('fails on duplicate drill id', () async {
    final result = await validateModule(
      'world1_act0_action_literacy',
      theory: '# Act 0 Action Literacy\n\n- Check means continue for free.',
      drills: const <String>[
        '{"id":"dup","goal":"One.","instruction_text":"First."}',
        '{"id":"dup","goal":"Two.","instruction_text":"Second."}',
      ],
    );

    expect(result.errors.any((e) => e.contains('duplicate id: dup')), isTrue);
  });

  test('fails on forbidden Act0 strategy keyword', () async {
    final result = await validateModule(
      'world1_act0_action_literacy',
      theory: '# Act 0 Action Literacy\n\n- You should always raise here.',
      drills: const <String>[
        '{"id":"d1","goal":"One.","instruction_text":"First."}',
      ],
    );

    expect(
      result.errors.any((e) => e.contains('forbidden Act0 strategy language')),
      isTrue,
    );
  });

  test('fails on overlong paragraph', () async {
    final longParagraph = 'a' * 321;
    final result = await validateModule(
      'world1_act0_street_flow',
      theory: '# Act 0 Street Flow\n\n$longParagraph',
      drills: const <String>[
        '{"id":"d1","goal":"One.","instruction_text":"First."}',
      ],
    );

    expect(
      result.errors.any((e) => e.contains('paragraph longer than 320 chars')),
      isTrue,
    );
  });

  test('fails on ambiguous choice drill', () async {
    final result = await validateModule(
      'intro_actions',
      theory: '# Intro Actions\n\n- Keep it simple.',
      drills: const <String>[
        '{"id":"d1","question":"Pick one","answer_choices":["A","B"],"correct_answer":"C"}',
      ],
    );

    expect(
      result.errors.any(
        (e) => e.contains('exactly one matching correct_answer'),
      ),
      isTrue,
    );
  });

  test('fails if Act0 jargon appears without nearby definition', () async {
    final result = await validateModule(
      'world1_act0_table_literacy',
      theory: '''# Act 0 Table Literacy

- Small Blind is left of Button. Big Blind is next.
- Preflop starts left of the Big Blind.
- After the flop, action starts with the Small Blind, or the first live seat left of Button.
- At showdown, top pair often wins the spot.
- At showdown, the pot goes to the best five-card hand.
- Use one short ladder: High Card (no pair) < Pair < Two Pair.
''',
      drills: const <String>[
        '{"id":"d1","goal":"Tap Button.","instruction_text":"Find Button."}',
      ],
    );

    expect(
      result.errors.any(
        (e) => e.contains('Act0 jargon without nearby definition: "top pair"'),
      ),
      isTrue,
    );
  });

  test('fails if Act0 theory uses lowercase big blind', () async {
    final result = await validateModule(
      'world1_act0_table_literacy',
      theory: '''# Act 0 Table Literacy

- Small Blind is left of Button. big blind is next.
- Preflop starts left of the Big Blind.
- After the flop, action starts with the Small Blind, or the first live seat left of Button.
- At showdown, the pot goes to the best five-card hand.
- Use one short ladder: High Card (no pair) < Pair < Two Pair.
''',
      drills: const <String>[
        '{"id":"d1","goal":"Tap Button.","instruction_text":"Find Button."}',
      ],
    );

    expect(
      result.errors.any((e) => e.contains('capitalize "Big Blind"')),
      isTrue,
    );
  });

  test('fails if table literacy ladder misses High Card', () async {
    final result = await validateModule(
      'world1_act0_table_literacy',
      theory: '''# Act 0 Table Literacy

- Small Blind is left of Button. Big Blind is next.
- Preflop starts left of the Big Blind.
- After the flop, action starts with the Small Blind, or the first live seat left of Button.
- At showdown, the pot goes to the best five-card hand.
- Use one short ladder: Pair < Two Pair < Trips.
''',
      drills: const <String>[
        '{"id":"d1","goal":"Tap Button.","instruction_text":"Find Button."}',
      ],
    );

    expect(
      result.errors.any(
        (e) => e.contains('missing required hand ladder anchor'),
      ),
      isTrue,
    );
  });

  test('fails if table literacy best-five concept is missing', () async {
    final result = await validateModule(
      'world1_act0_table_literacy',
      theory: '''# Act 0 Table Literacy

- Small Blind is left of Button. Big Blind is next.
- Preflop starts left of the Big Blind.
- After the flop, action starts with the Small Blind, or the first live seat left of Button.
- Use one short ladder: High Card (no pair) < Pair < Two Pair.
''',
      drills: const <String>[
        '{"id":"d1","goal":"Tap Button.","instruction_text":"Find Button."}',
      ],
    );

    expect(
      result.errors.any(
        (e) => e.contains('missing required showdown best-five concept'),
      ),
      isTrue,
    );
  });
}
