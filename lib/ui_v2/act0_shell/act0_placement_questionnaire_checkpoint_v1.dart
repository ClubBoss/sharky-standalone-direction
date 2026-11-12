import 'dart:convert';
import 'act0_progress_store_v1.dart';
import 'act0_shell_state_v1.dart';

/// Questionnaire only: never a diagnostic answer, completion or XP receipt.
class Act0PlacementQuestionnaireCheckpointV1 {
  const Act0PlacementQuestionnaireCheckpointV1({
    required this.showIntro,
    required this.questionIndex,
    required this.answers,
  });
  final bool showIntro;
  final int questionIndex;
  final Map<String, Set<String>> answers;

  static String catalog(List<Act0PlacementQuestionV1> questions) => jsonEncode([
    for (final q in questions)
      {
        'id': q.questionId,
        'title': q.title,
        'subtitle': q.subtitle,
        'eyebrow': q.eyebrow,
        'helper': q.helper,
        'options': [
          for (final o in q.options)
            {
              'id': o.optionId,
              'label': o.label,
              'subtitle': o.subtitle,
              'score': o.score,
              'profileTag': o.profileTag,
              'badge': o.badge,
            },
        ],
        'multiple': q.allowsMultiple,
        'min': q.minSelections,
        'max': q.maxSelections,
      },
  ]);

  String encode(List<Act0PlacementQuestionV1> questions) => jsonEncode({
    'schema': 1,
    'catalog': catalog(questions),
    'intro': showIntro,
    'index': questionIndex,
    'answers': {
      for (final e in answers.entries) e.key: e.value.toList()..sort(),
    },
  });

  static Act0PlacementQuestionnaireCheckpointV1 decode(
    String raw,
    List<Act0PlacementQuestionV1> questions,
  ) {
    final x = jsonDecode(raw);
    if (x is! Map ||
        x.length != 5 ||
        x['schema'] != 1 ||
        x['catalog'] != catalog(questions) ||
        x['intro'] is! bool ||
        x['index'] is! int ||
        x['answers'] is! Map) {
      throw const FormatException('Questionnaire checkpoint incompatible');
    }
    final index = x['index'] as int;
    if (index < 0 ||
        index > questions.length ||
        (x['intro'] == true && index != 0)) {
      throw const FormatException('Questionnaire position invalid');
    }
    final answers = <String, Set<String>>{};
    for (final e in (x['answers'] as Map).entries) {
      final matches = questions.where((q) => q.questionId == e.key).toList();
      if (matches.length != 1 || e.value is! List) {
        throw const FormatException('Questionnaire answer identity invalid');
      }
      final q = matches.single;
      final values = e.value as List;
      if (values.any(
            (v) => v is! String || !q.options.any((o) => o.optionId == v),
          ) ||
          values.toSet().length != values.length ||
          values.length >
              (q.maxSelections ?? (q.allowsMultiple ? q.options.length : 1))) {
        throw const FormatException('Questionnaire answer invalid');
      }
      answers[q.questionId] = Set<String>.from(values);
    }
    for (var i = 0; i < index; i++) {
      if ((answers[questions[i].questionId]?.length ?? 0) <
          questions[i].minSelections) {
        throw const FormatException('Questionnaire prior choice missing');
      }
    }
    return Act0PlacementQuestionnaireCheckpointV1(
      showIntro: x['intro'] as bool,
      questionIndex: index,
      answers: answers,
    );
  }
}

/// Reuses the existing serialized/checksummed protocol; no new storage engine.
/// Corrupt or catalog-incompatible bytes fail closed, not overwritten by defaults.
class Act0PlacementQuestionnaireStoreV1 {
  Act0PlacementQuestionnaireStoreV1(
    this.questions, {
    required this.canonicalIdentity,
  }) {
    // Only construct from an authoritative resolved canonical snapshot while
    // the host's boot/reset/transfer gate is held. Never rebind a UI callback.
    if (_canonicalIdentity != canonicalIdentity) {
      _generation++;
      _canonicalIdentity = canonicalIdentity;
    }
    _lease = _generation;
  }
  static String? _canonicalIdentity;
  final String canonicalIdentity;
  static int _generation = 0;
  static bool _resetInFlight = false;
  late final int _lease;
  bool get _current => _lease == _generation && !_resetInFlight;
  static const storageKey = 'act0_placement_questionnaire_checkpoint_v1';
  final List<Act0PlacementQuestionV1> questions;
  late final Act0ProgressStoreV1 _store = Act0ProgressStoreV1(
    key: storageKey,
    isValidPayload: (raw) {
      try {
        final envelope = jsonDecode(raw);
        if (envelope is! Map ||
            envelope.length != 2 ||
            envelope['canonical'] is! String ||
            envelope['checkpoint'] is! String)
          return false;
        Act0PlacementQuestionnaireCheckpointV1.decode(
          envelope['checkpoint'] as String,
          questions,
        );
        return true;
      } catch (_) {
        return false;
      }
    },
  );
  Future<Act0PlacementQuestionnaireCheckpointV1?> load() async {
    if (!_current) throw const FormatException('Questionnaire lease retired');
    final raw = await _store.load();
    if (!_current) throw const FormatException('Questionnaire lease retired');
    if (raw == null) return null;
    final envelope = jsonDecode(raw) as Map;
    // Canonical reset/import changed truth: stale draft is logically retired,
    // not corrupt, and may be replaced by a new draft for the new epoch.
    if (envelope['canonical'] != canonicalIdentity) return null;
    return Act0PlacementQuestionnaireCheckpointV1.decode(
      envelope['checkpoint'] as String,
      questions,
    );
  }

  Future<bool> save(Act0PlacementQuestionnaireCheckpointV1 checkpoint) {
    if (!_current) return Future<bool>.value(false);
    return _store.save(
      jsonEncode({
        'canonical': canonicalIdentity,
        'checkpoint': checkpoint.encode(questions),
      }),
    );
  }

  /// Explicit reset retires earlier UI writers BEFORE enqueueing the tombstone.
  /// Already queued saves precede clear in the existing protocol queue.
  /// Host must keep reset UI fenced until canonical reset also finishes.
  Future<bool> clearAfterExplicitCompletionOrReset() async {
    if (!_current) return false;
    _generation++;
    _resetInFlight = true;
    try {
      return await _store.clear();
    } finally {
      _resetInFlight = false;
    }
  }

  Future<void> flush() => _store.flush();
}
