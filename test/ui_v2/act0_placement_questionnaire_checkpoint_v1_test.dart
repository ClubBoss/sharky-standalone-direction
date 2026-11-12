import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
// Private proposal tests, NOT RUN. Synthetic questionnaire, no poker claims.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_questionnaire_checkpoint_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const questions = [
  Act0PlacementQuestionV1(
    questionId: 'first',
    title: 'First',
    subtitle: '',
    options: [
      Act0PlacementOptionV1(
        optionId: 'a',
        label: 'A',
        score: 0,
        profileTag: 'synthetic',
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'second',
    title: 'Second',
    subtitle: '',
    options: [
      Act0PlacementOptionV1(
        optionId: 'b',
        label: 'B',
        score: 0,
        profileTag: 'synthetic',
      ),
    ],
  ),
];
const draft = Act0PlacementQuestionnaireCheckpointV1(
  showIntro: false,
  questionIndex: 1,
  answers: {
    'first': {'a'},
  },
);
void main() {
  test(
    'exact position and source choices roundtrip without completion fields',
    () {
      final raw = draft.encode(questions);
      final restored = Act0PlacementQuestionnaireCheckpointV1.decode(
        raw,
        questions,
      );
      expect(restored.questionIndex, 1);
      expect(restored.answers, {
        'first': {'a'},
      });
      expect(restored.showIntro, isFalse);
      expect(raw.contains('earnedXp'), isFalse);
      expect(raw.contains('completedTaskIds'), isFalse);
    },
  );
  test(
    'changed catalog, invalid choice, and missing prior answer fail closed',
    () {
      expect(
        () => Act0PlacementQuestionnaireCheckpointV1.decode(
          draft.encode(questions),
          questions.reversed.toList(),
        ),
        throwsFormatException,
      );
      for (final answers in <Map<String, Set<String>>>[
        {
          'first': {'unknown'},
        },
        {},
        {
          'ghost': {'a'},
        },
      ]) {
        final invalid = Act0PlacementQuestionnaireCheckpointV1(
          showIntro: false,
          questionIndex: 1,
          answers: answers,
        );
        expect(
          () => Act0PlacementQuestionnaireCheckpointV1.decode(
            invalid.encode(questions),
            questions,
          ),
          throwsFormatException,
        );
      }
    },
  );
  test('same IDs with changed authored meaning reject previous answers', () {
    final changed = [
      const Act0PlacementQuestionV1(
        questionId: 'first',
        title: 'Different meaning',
        subtitle: '',
        options: [
          Act0PlacementOptionV1(
            optionId: 'a',
            label: 'A',
            score: 1,
            profileTag: 'synthetic',
          ),
        ],
      ),
      questions[1],
    ];
    expect(
      () => Act0PlacementQuestionnaireCheckpointV1.decode(
        draft.encode(questions),
        changed,
      ),
      throwsFormatException,
    );
  });
  test(
    'queued save before explicit clear cannot resurrect after tombstone',
    () async {
      SharedPreferences.setMockInitialValues({});
      final writer = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision0:null',
      );
      final queued = writer.save(draft);
      final clearing = writer.clearAfterExplicitCompletionOrReset();
      expect(await writer.save(draft), isFalse);
      await queued;
      expect(await clearing, isTrue);
      expect(
        await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: 'revision0:null',
        ).load(),
        isNull,
      );
    },
  );
  test(
    'existing protocol persists draft and explicit clear cannot resurrect it',
    () async {
      SharedPreferences.setMockInitialValues({'unrelated': 'keep'});
      final store = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision0:null',
      );
      expect(await store.save(draft), isTrue);
      expect(
        (await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: 'revision0:null',
        ).load())!.answers,
        draft.answers,
      );
      final stale = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision0:null',
      );
      expect(await store.clearAfterExplicitCompletionOrReset(), isTrue);
      expect(await stale.save(draft), isFalse);
      expect(await store.save(draft), isFalse);
      expect(
        await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: 'revision0:null',
        ).load(),
        isNull,
      );
      expect(
        (await SharedPreferences.getInstance()).getString('unrelated'),
        'keep',
      );
    },
  );
  test(
    'canonical changed binding retires draft without deleting bytes; unchanged CAS keeps it',
    () async {
      SharedPreferences.setMockInitialValues({});
      final old = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision0:null',
      );
      expect(await old.save(draft), isTrue);
      final prefs = await SharedPreferences.getInstance();
      final before = {for (final key in prefs.getKeys()) key: prefs.get(key)};
      // Failed CAS leaves the authoritative revision unchanged.
      expect(
        (await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: 'revision0:null',
        ).load())!.answers,
        draft.answers,
      );
      // Successful or indeterminate-but-committed import changes resolved revision.
      expect(
        await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: 'revision1:imported',
        ).load(),
        isNull,
      );
      expect({for (final key in prefs.getKeys()) key: prefs.get(key)}, before);
      // An old callback remains bound to the old epoch, not the newer revision.
      final fresh = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision1:imported',
      );
      const newDraft = Act0PlacementQuestionnaireCheckpointV1(
        showIntro: false,
        questionIndex: 0,
        answers: {},
      );
      expect(await fresh.save(newDraft), isTrue);
      expect(await old.save(draft), isFalse);
      expect((await fresh.load())!.questionIndex, 0);
      expect((await fresh.load())!.answers, isEmpty);
    },
  );
  test(
    'real canonical CAS refusal preserves draft and commit retires it',
    () async {
      SharedPreferences.setMockInitialValues({});
      Act0ProgressStoreV1 canonical() => Act0ProgressStoreV1(
        key: 'onb01_test_canonical',
        isValidPayload: (_) => true,
      );
      String binding(({int revision, String? payload}) value) =>
          '${value.revision}:${sha256.convert(utf8.encode(jsonEncode(value.payload)))}';
      final store = canonical();
      final initial = await store.readDurableSnapshot();
      final checkpoint = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: binding(initial),
      );
      expect(await checkpoint.save(draft), isTrue);
      expect(
        await store.restoreIfUnchanged(
          expected: (revision: initial.revision + 1, payload: null),
          incomingPayload: '{"schemaVersion":18}',
          supportedProgressSchema: 18,
        ),
        Act0ProgressRestoreResultV1.changed,
      );
      expect((await checkpoint.load())!.answers, draft.answers);
      expect(
        await store.restoreIfUnchanged(
          expected: initial,
          incomingPayload: '{"schemaVersion":18}',
          supportedProgressSchema: 18,
        ),
        Act0ProgressRestoreResultV1.committed,
      );
      final resolved = await canonical().readDurableSnapshot();
      expect(resolved.revision, initial.revision + 1);
      expect(
        await Act0PlacementQuestionnaireStoreV1(
          questions,
          canonicalIdentity: binding(resolved),
        ).load(),
        isNull,
      );
    },
  );
  test(
    'corrupt existing bytes are not overwritten by a fresh default',
    () async {
      SharedPreferences.setMockInitialValues({
        Act0PlacementQuestionnaireStoreV1.storageKey: '{broken',
      });
      final store = Act0PlacementQuestionnaireStoreV1(
        questions,
        canonicalIdentity: 'revision0:null',
      );
      await expectLater(store.load(), throwsA(isA<FormatException>()));
      expect(await store.save(draft), isFalse);
      expect(
        (await SharedPreferences.getInstance()).getString(
          Act0PlacementQuestionnaireStoreV1.storageKey,
        ),
        '{broken',
      );
    },
  );
}
