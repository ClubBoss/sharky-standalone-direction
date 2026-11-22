import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/cnt01_role_inventory_v1.dart';

import '../support/act0_wave6_contract_v1.dart';
import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';

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
  'hasAssessmentChoices': true,
  'choiceIds': <String>['choice_a', 'choice_b'],
  'authoredCorrectChoiceIds': <String>['choice_a'],
  'authoredRationaleByChoiceId': <String, String>{
    'choice_a': 'Source-authored explanation',
  },
};

Set<String> _codes(
  List<Map<String, Object?>> rows, {
  Set<String> seen = const <String>{},
  Set<String> assisted = const <String>{},
}) => Cnt01RoleInventoryV1.validateRows(
  rows,
  previouslyPresentedTaskIds: seen,
  assistanceExposedTaskIds: assisted,
).map((finding) => finding['code']!).toSet();

void main() {
  group('CNT-01 source-only inventory', () {
    test(
      'reuses existing Act0 source fingerprint and does not infer unseen',
      () {
        final rows = Cnt01RoleInventoryV1.fromAct0(
          // Unit-only placeholder is never exported as actual provenance.
          baselineMainSha:
              const String.fromEnvironment('SHARKY_CNT01_BASELINE').isEmpty
              ? List<String>.filled(40, 'a').join()
              : const String.fromEnvironment('SHARKY_CNT01_BASELINE'),
        );
        expect(rows, isNotEmpty);
        expect(
          rows
              .where((row) => row['taskId'] == 'what_poker_is_theory')
              .single['sourceRole'],
          'TEACHING',
        );
        for (final id in <String>[
          'what_poker_is_table_read_transfer',
          'what_poker_is_table_read_recheck',
        ]) {
          final row = rows
              .where((candidate) => candidate['taskId'] == id)
              .single;
          expect(row['sourceRole'], 'UNKNOWN', reason: id);
          expect(row['semanticRevision'], isNot('UNKNOWN'), reason: id);
        }
        expect(rows.where((row) => row['sourceRole'] == 'UNSEEN'), isEmpty);
        expect(rows.where((row) => row['sourceRole'] == 'ELAPSED'), isEmpty);
        _exportInventoryIfRequested(rows);
        expect(
          Cnt01RoleInventoryV1.validateRows(
            rows,
          ).where((finding) => finding['level'] == 'ERROR'),
          isEmpty,
          reason:
              'Actual typed catalogue must have no structural identity errors.',
        );
      },
    );

    List<Map<String, Object?>> sourceRows() => Cnt01RoleInventoryV1.fromAct0(
      baselineMainSha: List<String>.filled(40, 'a').join(),
    );

    Map<String, Object?> teachingRow() => Map<String, Object?>.from(
      sourceRows().singleWhere((r) => r['taskId'] == 'what_poker_is_theory'),
    );

    test('unaltered source has no classification mismatch', () {
      final codes = _codes(sourceRows());
      expect(codes, isNot(contains('SOURCE_CLASSIFICATION_MISMATCH')));
      expect(codes, isNot(contains('SOURCE_INPUT_MISMATCH')));
      expect(codes, isNot(contains('SOURCE_TASK_NOT_UNIQUE')));
    });

    test('complete JSON round trip preserves source validation', () {
      final decoded = (jsonDecode(jsonEncode(sourceRows())) as List)
          .map((row) => Map<String, Object?>.from(row as Map))
          .toList();
      final findings = Cnt01RoleInventoryV1.validateRows(decoded);
      expect(findings, equals(Cnt01RoleInventoryV1.validateRows(sourceRows())));
      expect(
        findings.where(
          (finding) =>
              finding['code']!.startsWith('SOURCE_FIELD_MISMATCH_') ||
              finding['code'] == 'SOURCE_TASK_MISSING',
        ),
        isEmpty,
      );
    });

    test('empty or truncated inventory cannot claim full source coverage', () {
      expect(_codes([]), contains('SOURCE_TASK_MISSING'));
      expect(
        _codes(sourceRows().skip(1).toList()),
        contains('SOURCE_TASK_MISSING'),
      );
    });

    test(
      'copied fingerprint cannot validate fabricated content or provenance',
      () {
        final mutations = <String, Object?>{
          'taskIdentity': 'FORGED',
          'choiceIds': <String>['invented_choice'],
          'authoredCorrectChoiceIds': <String>['invented_choice'],
          'authoredRationaleByChoiceId': <String, String>{
            'invented_choice': 'fake',
          },
          'hasAssessmentChoices': 'not_a_boolean',
          'authoredSourcePath': 'invented/source',
          'authoredRevision': 'invented_revision',
          'responsibleAuthor': 'invented_author',
        };
        for (final mutation in mutations.entries) {
          final row = teachingRow()..[mutation.key] = mutation.value;
          expect(
            _codes([row]),
            contains('SOURCE_FIELD_MISMATCH_${mutation.key}'),
            reason: mutation.key,
          );
        }
      },
    );

    test('coherent forged role and basis cannot override source', () {
      final row = teachingRow()
        ..['sourceRole'] = 'REPAIR'
        ..['roleBasis'] = 'stepKind.fixMistakes';
      expect(_codes([row]), contains('SOURCE_CLASSIFICATION_MISMATCH'));
    });

    test('forged basis and each source input are independently rejected', () {
      final basis = teachingRow()..['roleBasis'] = 'taskFamily.learn';
      expect(_codes([basis]), contains('SOURCE_CLASSIFICATION_MISMATCH'));
      for (final field in ['sourcePhase', 'sourceStepKind', 'sourceFamily']) {
        final row = teachingRow()..[field] = 'forged';
        expect(_codes([row]), contains('SOURCE_INPUT_MISMATCH'), reason: field);
      }
      final coherent = teachingRow()
        ..['sourcePhase'] = 'drill'
        ..['sourceStepKind'] = 'fixMistakes'
        ..['sourceFamily'] = 'repair'
        ..['sourceRole'] = 'REPAIR'
        ..['roleBasis'] = 'stepKind.fixMistakes';
      expect(
        _codes([coherent]),
        containsAll([
          'SOURCE_INPUT_MISMATCH',
          'SOURCE_CLASSIFICATION_MISMATCH',
        ]),
      );
    });

    test('unknown identity cannot borrow another task classification', () {
      final row = teachingRow()..['taskId'] = 'not_an_authored_task';
      expect(_codes([row]), contains('SOURCE_TASK_NOT_UNIQUE'));
    });

    test('well-formed copied semantic revision cannot hide changed source', () {
      final row = teachingRow()
        ..['semanticRevision'] = List<String>.filled(64, 'c').join();
      expect(_codes([row]), contains('SOURCE_SEMANTIC_REVISION_MISMATCH'));
    });

    test(
      'Foundation has explicit current purpose and accountable curation',
      () {
        final rows = sourceRows()
            .where(
              (r) => Cnt01RoleInventoryV1.isFoundationWorld(
                r['worldId']! as String,
              ),
            )
            .toList();
        expect(rows, hasLength(216));
        final counts = <String, int>{};
        for (final row in rows) {
          final purpose = row['declaredPurpose']! as String;
          counts[purpose] = (counts[purpose] ?? 0) + 1;
          expect(row['curationScope'], cnt01FoundationScopeV1);
          expect(
            row['currentResponsibleMaintainer'],
            cnt01CurationMaintainerV1,
          );
          expect(row['curationRevision'], cnt01CurationRevisionV1);
          expect(row['currentSourceRevision'], row['catalogSourceMainSha']);
          expect(row['inventoryEstablishesUnseen'], false);
          expect(row['inventoryEstablishesElapsed'], false);
          // Historic individual author/editorial history is still unknown.
          expect(row['responsibleAuthor'], cnt01UnknownV1);
          expect(row['authoredRevision'], cnt01UnknownV1);
        }
        expect(counts, <String, int>{
          'TEACHING': 30,
          'REPAIR': 12,
          'CORRECTION_CANDIDATE': 1,
          'PRACTICE': 134,
          'TRANSFER_CANDIDATE': 22,
          'REVIEW_CANDIDATE': 17,
        });
      },
    );

    test(
      'missing or forged Foundation purpose and maintainer are rejected',
      () {
        final mutations = <String, List<Object?>>{
          'declaredPurpose': [null, cnt01UnknownV1, 'PRACTICE'],
          'purposeBasis': ['forged'],
          'curationScope': [cnt01OutsideScopeV1],
          'currentResponsibleMaintainer': [
            null,
            cnt01UnknownV1,
            'unadmitted_owner',
          ],
          'curationRevision': ['', 'unadmitted_revision'],
          'eligibilityDisposition': ['INDEPENDENT_PROOF'],
        };
        for (final field in mutations.entries) {
          for (final value in field.value) {
            final row = teachingRow()..[field.key] = value;
            expect(
              _codes([row]),
              contains('SOURCE_FIELD_MISMATCH_${field.key}'),
              reason: '${field.key}: $value',
            );
          }
        }
        expect(
          _codes([teachingRow()..['declaredPurpose'] = cnt01UnknownV1]),
          contains('MISSING_FOUNDATION_PURPOSE'),
        );
        expect(
          _codes([teachingRow()..['currentResponsibleMaintainer'] = '']),
          contains('CURRENT_MAINTAINER_UNSUPPORTED'),
        );
      },
    );

    test(
      'current source revision fails closed separately from semantic SHA',
      () {
        final missing = teachingRow()..['currentSourceRevision'] = '';
        expect(_codes([missing]), contains('MISSING_CURRENT_SOURCE_REVISION'));
        final stale = teachingRow()
          ..['currentSourceRevision'] = List<String>.filled(40, 'c').join();
        expect(_codes([stale]), contains('CURRENT_SOURCE_REVISION_MISMATCH'));
        expect(stale['semanticRevision'], teachingRow()['semanticRevision']);
      },
    );

    test(
      'transfer and review source labels cannot establish learner proof',
      () {
        final rows = sourceRows();
        for (final field in [
          'inventoryEstablishesUnseen',
          'inventoryEstablishesElapsed',
        ]) {
          final source = rows.firstWhere(
            (r) =>
                Cnt01RoleInventoryV1.isFoundationWorld(
                  r['worldId']! as String,
                ) &&
                r['declaredPurpose'] ==
                    (field == 'inventoryEstablishesUnseen'
                        ? 'TRANSFER_CANDIDATE'
                        : 'REVIEW_CANDIDATE'),
          );
          expect(source[field], false);
          final forged = Map<String, Object?>.from(source)..[field] = true;
          expect(
            _codes([forged]),
            contains('STATIC_INVENTORY_CANNOT_ESTABLISH_PROOF'),
          );
          expect(_codes([forged]), contains('SOURCE_FIELD_MISMATCH_$field'));
        }
      },
    );

    test('outside-stage curation remains unadmitted and cannot be forged', () {
      final rows = sourceRows()
          .where(
            (r) => !Cnt01RoleInventoryV1.isFoundationWorld(
              r['worldId']! as String,
            ),
          )
          .toList();
      expect(
        rows,
        hasLength(
          223 +
              w11Wave4ChoiceContractV1.length +
              w12Wave4ChoiceContractV1.length +
              wave6TaskDeltaV1,
        ),
      );
      expect(
        rows.map((row) => row['taskId']).toSet(),
        containsAll([
          ...w11Wave4ChoiceContractV1.keys.where(
            (id) => !wave6PreviousRowsV1.containsKey(id),
          ),
          ...w12Wave4ChoiceContractV1.keys.where(
            (id) => !wave6PreviousRowsV1.containsKey(id),
          ),
          ...wave6CurrentRowsV1.keys,
        ]),
      );
      for (final row in rows) {
        expect(row['curationScope'], cnt01OutsideScopeV1);
        expect(row['declaredPurpose'], cnt01UnknownV1);
        expect(row['currentResponsibleMaintainer'], cnt01UnknownV1);
        expect(row['curationRevision'], cnt01UnknownV1);
        expect(row['currentSourceRevision'], cnt01UnknownV1);
      }
      final forged = Map<String, Object?>.from(rows.first)
        ..['currentResponsibleMaintainer'] = cnt01CurationMaintainerV1;
      expect(
        _codes([forged]),
        contains('SOURCE_FIELD_MISMATCH_currentResponsibleMaintainer'),
      );
    });

    test('global duplicate source task ID is an error', () {
      expect(
        _codes(<Map<String, Object?>>[_row(), _row()]),
        contains('DUPLICATE_TASK_ID'),
      );
    });

    test('missing origin and missing semantic revision fail closed', () {
      final invalid = _row(sourcePath: '', mainSha: '', revision: '');
      final findings = _codes(<Map<String, Object?>>[invalid]);
      expect(findings, contains('MISSING_ORIGIN'));
      expect(findings, contains('MISSING_SEMANTIC_REVISION'));
    });

    test('a seen item cannot be claimed as unseen', () {
      expect(
        _codes(
          <Map<String, Object?>>[_row(role: 'UNSEEN')],
          seen: <String>{'task_a'},
        ),
        contains('UNSEEN_ALREADY_PRESENTED'),
      );
    });

    test('an assistance-exposed item cannot be claimed as unseen', () {
      expect(
        _codes(
          <Map<String, Object?>>[_row(role: 'UNSEEN')],
          assisted: <String>{'task_a'},
        ),
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
      final findings = Cnt01RoleInventoryV1.validateRows(<Map<String, Object?>>[
        _row(),
      ]);
      expect(
        findings.where(
          (item) =>
              item['code'] == 'AUTHOR_REVISION_UNKNOWN' &&
              item['level'] == 'GAP',
        ),
        hasLength(1),
      );
      expect(
        _codes(<Map<String, Object?>>[_row()]),
        contains('RESPONSIBLE_UNKNOWN'),
      );
    });

    test('duplicated choice IDs and answers outside choices are rejected', () {
      final invalid = _row();
      invalid['choiceIds'] = <String>['choice_a', 'choice_a'];
      invalid['authoredCorrectChoiceIds'] = <String>['missing'];
      final codes = _codes(<Map<String, Object?>>[invalid]);
      expect(codes, contains('DUPLICATE_CHOICE_ID'));
      expect(codes, contains('ANSWER_NOT_IN_CHOICES'));
    });
    test('missing authored answers remain explicit gaps', () {
      final row = _row()..['authoredCorrectChoiceIds'] = <String>[];
      final findings = Cnt01RoleInventoryV1.validateRows([row]);
      expect(
        findings.where(
          (f) => f['code'] == 'AUTHORED_ANSWER_UNKNOWN' && f['level'] == 'GAP',
        ),
        hasLength(1),
      );
    });

    test('missing authored rationale remains an explicit gap', () {
      for (final rationale in <Object?>[null, '', 'UNKNOWN']) {
        final row = _row()
          ..['authoredRationaleByChoiceId'] = {'choice_a': rationale};
        expect(_codes([row]), contains('AUTHORED_RATIONALE_UNKNOWN'));
      }
    });

    test(
      'malformed choice IDs are rejected without silently dropping values',
      () {
        for (final value in <Object>[
          ['choice_a', 7],
          ['choice_a', ' '],
          'choice_a',
        ]) {
          final row = _row()..['choiceIds'] = value;
          expect(_codes([row]), contains('MALFORMED_CHOICE_IDS'));
        }
      },
    );

    test(
      'malformed answer IDs are rejected without silently dropping values',
      () {
        for (final value in <Object>[
          ['choice_a', 7],
          [''],
          'choice_a',
        ]) {
          final row = _row()..['authoredCorrectChoiceIds'] = value;
          expect(_codes([row]), contains('MALFORMED_ANSWER_IDS'));
        }
      },
    );

    test('an assessment cannot hide missing choices behind an empty list', () {
      final row = _row()
        ..['choiceIds'] = <String>[]
        ..['authoredCorrectChoiceIds'] = <String>[];
      final findings = Cnt01RoleInventoryV1.validateRows([row]);
      expect(_codes([row]), contains('ASSESSMENT_CHOICES_MISSING'));
      expect(_codes([row]), contains('AUTHORED_ANSWER_UNKNOWN'));
      expect(
        findings.where(
          (f) =>
              f['code'] == 'ASSESSMENT_CHOICES_MISSING' &&
              f['level'] == 'ERROR',
        ),
        hasLength(1),
      );
    });
  });
}

void _exportInventoryIfRequested(List<Map<String, Object?>> rows) {
  const output = String.fromEnvironment('SHARKY_CNT01_INVENTORY_OUTPUT');
  if (output.isEmpty) return;
  const baseline = String.fromEnvironment('SHARKY_CNT01_BASELINE');
  expect(RegExp(r'^[a-f0-9]{40}$').hasMatch(baseline), isTrue);
  expect(output.startsWith('output/'), isTrue);
  expect(output.split('/'), isNot(contains('..')));
  final file = File(output);
  expect(file.parent.existsSync(), isTrue);
  final owned = Directory('output').resolveSymbolicLinksSync();
  final parent = file.parent.resolveSymbolicLinksSync();
  expect(parent == owned || parent.startsWith('$owned/'), isTrue);
  expect(
    FileSystemEntity.typeSync(file.path, followLinks: false),
    FileSystemEntityType.notFound,
  );
  final head = Process.runSync('git', ['rev-parse', 'HEAD']);
  final sourceDiff = Process.runSync('git', [
    'diff',
    '--quiet',
    baseline,
    '--',
    'lib/ui_v2/act0_shell',
  ]);
  expect(head.exitCode, 0);
  expect(
    sourceDiff.exitCode,
    0,
    reason: 'Guard-supplied baseline must match current authored Act0 source.',
  );
  final findings = Cnt01RoleInventoryV1.validateRows(rows);
  final roleCounts = <String, int>{};
  final findingCounts = <String, int>{};
  for (final row in rows) {
    final role = row['sourceRole']! as String;
    roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    expect(row['catalogSourceMainSha'], baseline);
  }
  for (final finding in findings) {
    final code = finding['code']!;
    findingCounts[code] = (findingCounts[code] ?? 0) + 1;
  }
  final curatedRows = rows
      .where((row) => row['curationScope'] == cnt01FoundationScopeV1)
      .toList();
  final purposeCounts = <String, int>{};
  for (final row in curatedRows) {
    final purpose = row['declaredPurpose']! as String;
    purposeCounts[purpose] = (purposeCounts[purpose] ?? 0) + 1;
  }
  final curation = <String, Object?>{
    'scope': cnt01FoundationScopeV1,
    'revision': cnt01CurationRevisionV1,
    'currentResponsibleMaintainer': cnt01CurationMaintainerV1,
    'currentSourceRevision': baseline,
    'count': curatedRows.length,
    'declaredPurposeCounts': purposeCounts,
    'inventoryEstablishesUnseen': false,
    'inventoryEstablishesElapsed': false,
    'outsideStageCuration': 'NOT_ADMITTED',
  };
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({'schemaVersion': 'cnt01_role_inventory_v1', 'status': 'TECHNICAL_INVENTORY_ONLY_NOT_CNT01_ACCEPTANCE', 'scope': 'Compiled authored catalogue including locked/derived items; '
        'not runnable inventory, eligibility, exhaustion or learner proof.', 'baselineMainSha': baseline, 'checkoutHeadSha': (head.stdout as String).trim(), 'source': cnt01CatalogSourceV1, 'count': rows.length, 'sourceRoleCounts': roleCounts, 'foundationCuration': curation, 'findingCounts': findingCounts, 'errors': findings.where((finding) => finding['level'] == 'ERROR').toList(), 'rows': rows})}\n',
  );
}
