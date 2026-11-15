import 'package:flutter_test/flutter_test.dart';
import '../../tools/cnt01_role_inventory_v1.dart';

Map<String, Object?> _row({
  String id = 'task_a',
  String role = 'UNKNOWN',
  String basis = 'UNKNOWN',
  String? sourcePath,
  String? mainSha,
  String? revision,
}) => <String, Object?>{
  'worldId': 'world_1',
  'lessonId': 'lesson_1',
  'taskId': id,
  'sourceRole': role,
  'roleBasis': basis,
  'catalogSourcePath': sourcePath ?? cnt01CatalogSourceV1,
  'catalogSourceMainSha': mainSha ?? List<String>.filled(40, 'a').join(),
  'semanticRevision': revision ?? List<String>.filled(64, 'b').join(),
  'authoredSourcePath': 'UNKNOWN',
  'authoredRevision': 'UNKNOWN',
  'responsibleAuthor': 'UNKNOWN',
  'choiceIds': <String>['choice_a', 'choice_b'],
  'authoredCorrectChoiceIds': <String>['choice_a'],
  'authoredRationaleByChoiceId': <String, String>{
    'choice_a': 'Source-authored explanation',
  },
};

Set<String> _codes(List<Map<String, Object?>> rows, {
  Set<String> seen = const <String>{},
  Set<String> assisted = const <String>{},
}) => Cnt01RoleInventoryV1.validateRows(
  rows,
  previouslyPresentedTaskIds: seen,
  assistanceExposedTaskIds: assisted,
).map((finding) => finding['code']!).toSet();

void main() {
  group('CNT-01 source-only inventory', () {
    test('reuses existing Act0 source fingerprint and does not infer unseen', () {
      final rows = Cnt01RoleInventoryV1.fromAct0(
        baselineMainSha: List<String>.filled(40, 'a').join(),
      );
      expect(rows, isNotEmpty);
      expect(
        rows.where((row) => row['taskId'] == 'what_poker_is_theory')
            .single['sourceRole'],
        'TEACHING',
      );
      for (final id in <String>[
        'what_poker_is_table_read_transfer',
        'what_poker_is_table_read_recheck',
      ]) {
        final row = rows.where((candidate) => candidate['taskId'] == id).single;
        expect(row['sourceRole'], 'UNKNOWN', reason: id);
        expect(row['semanticRevision'], isNot('UNKNOWN'), reason: id);
      }
      expect(rows.where((row) => row['sourceRole'] == 'UNSEEN'), isEmpty);
      expect(rows.where((row) => row['sourceRole'] == 'ELAPSED'), isEmpty);
    });

    test('global duplicate source task ID is an error', () {
      expect(_codes(<Map<String, Object?>>[
        _row(),
        _row(),
      ]), contains('DUPLICATE_TASK_ID'));
    });

    test('missing origin and missing semantic revision fail closed', () {
      final invalid = _row(sourcePath: '', mainSha: '', revision: '');
      final findings = _codes(<Map<String, Object?>>[invalid]);
      expect(findings, contains('MISSING_ORIGIN'));
      expect(findings, contains('MISSING_SEMANTIC_REVISION'));
    });

    test('a seen item cannot be claimed as unseen', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'UNSEEN'),
        ], seen: <String>{'task_a'}),
        contains('UNSEEN_ALREADY_PRESENTED'),
      );
    });

    test('an assistance-exposed item cannot be claimed as unseen', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'UNSEEN'),
        ], assisted: <String>{'task_a'}),
        contains('UNSEEN_ASSISTANCE_EXPOSED'),
      );
    });

    test('a new ID alone cannot establish unseen eligibility', () {
      expect(
        _codes(<Map<String, Object?>>[_row(role: 'UNSEEN')]),
        contains('UNSEEN_NEEDS_SOURCE_AND_LEARNER_PROOF'),
      );
    });

    test('a review label alone cannot establish elapsed retention', () {
      expect(
        _codes(<Map<String, Object?>>[_row(role: 'ELAPSED')]),
        contains('ELAPSED_NEEDS_REAL_TIME_INDEPENDENT_PROOF'),
      );
    });

    test('source role conflicts are detected', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'TEACHING', basis: 'stepKind.fixMistakes'),
        ]),
        contains('ROLE_COLLISION'),
      );
    });

    test('missing author revision and responsible origin remain gaps', () {
      final findings =
          Cnt01RoleInventoryV1.validateRows(<Map<String, Object?>>[_row()]);
      expect(
        findings.where((item) =>
            item['code'] == 'AUTHOR_REVISION_UNKNOWN' &&
            item['level'] == 'GAP'),
        hasLength(1),
      );
      expect(_codes(<Map<String, Object?>>[_row()]),
          contains('RESPONSIBLE_UNKNOWN'));
    });

    test('duplicated choice IDs and answers outside choices are rejected', () {
      final invalid = _row();
      invalid['choiceIds'] = <String>['choice_a', 'choice_a'];
      invalid['authoredCorrectChoiceIds'] = <String>['missing'];
      final codes = _codes(<Map<String, Object?>>[invalid]);
      expect(codes, contains('DUPLICATE_CHOICE_ID'));
      expect(codes, contains('ANSWER_NOT_IN_CHOICES'));
    });
  });
}
