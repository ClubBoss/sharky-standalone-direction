part of 'progress_service.dart';

// Append-only order for consumers that rely on enum index stability.
enum EmotionPhraseContextV1 { beforeSession, afterOutcome, identity }

class EmotionPhraseV1 {
  const EmotionPhraseV1({
    this.schemaVersion = 1,
    required this.phraseId,
    required this.context,
    required this.tag,
    required this.text,
  });

  final int schemaVersion;
  final String phraseId;
  final EmotionPhraseContextV1 context;
  final EmotionTagV1 tag;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'phraseId': phraseId,
    'context': context.name,
    'tag': tag.name,
    'text': text,
  };
}

const Map<EmotionPhraseContextV1, Map<EmotionTagV1, EmotionPhraseV1>>
_kEmotionPhraseCatalogV1 =
    <EmotionPhraseContextV1, Map<EmotionTagV1, EmotionPhraseV1>>{
      EmotionPhraseContextV1.beforeSession: <EmotionTagV1, EmotionPhraseV1>{
        EmotionTagV1.neutral: EmotionPhraseV1(
          phraseId: 'before_neutral_v1',
          context: EmotionPhraseContextV1.beforeSession,
          tag: EmotionTagV1.neutral,
          text: 'Start clean. One clear decision at a time.',
        ),
        EmotionTagV1.confident: EmotionPhraseV1(
          phraseId: 'before_confident_v1',
          context: EmotionPhraseContextV1.beforeSession,
          tag: EmotionTagV1.confident,
          text: 'You are ready. Keep pressure on the highest value spots.',
        ),
        EmotionTagV1.cautious: EmotionPhraseV1(
          phraseId: 'before_cautious_v1',
          context: EmotionPhraseContextV1.beforeSession,
          tag: EmotionTagV1.cautious,
          text: 'Stay precise. Complete the unfinished world first.',
        ),
        EmotionTagV1.urgent: EmotionPhraseV1(
          phraseId: 'before_urgent_v1',
          context: EmotionPhraseContextV1.beforeSession,
          tag: EmotionTagV1.urgent,
          text: 'Focus now. Recover completion depth before adding complexity.',
        ),
      },
      EmotionPhraseContextV1.afterOutcome: <EmotionTagV1, EmotionPhraseV1>{
        EmotionTagV1.neutral: EmotionPhraseV1(
          phraseId: 'after_neutral_v1',
          context: EmotionPhraseContextV1.afterOutcome,
          tag: EmotionTagV1.neutral,
          text: 'Outcome logged. Keep the next decision simple and clean.',
        ),
        EmotionTagV1.confident: EmotionPhraseV1(
          phraseId: 'after_confident_v1',
          context: EmotionPhraseContextV1.afterOutcome,
          tag: EmotionTagV1.confident,
          text: 'Strong finish. Keep the same disciplined range pressure.',
        ),
        EmotionTagV1.cautious: EmotionPhraseV1(
          phraseId: 'after_cautious_v1',
          context: EmotionPhraseContextV1.afterOutcome,
          tag: EmotionTagV1.cautious,
          text: 'Good signal. Tighten one leak and repeat this line.',
        ),
        EmotionTagV1.urgent: EmotionPhraseV1(
          phraseId: 'after_urgent_v1',
          context: EmotionPhraseContextV1.afterOutcome,
          tag: EmotionTagV1.urgent,
          text: 'Stabilize first. Rebuild completion before advanced lines.',
        ),
      },
      EmotionPhraseContextV1.identity: <EmotionTagV1, EmotionPhraseV1>{
        EmotionTagV1.neutral: EmotionPhraseV1(
          phraseId: 'identity_neutral_v1',
          context: EmotionPhraseContextV1.identity,
          tag: EmotionTagV1.neutral,
          text: 'You train with structure. Consistency builds edge.',
        ),
        EmotionTagV1.confident: EmotionPhraseV1(
          phraseId: 'identity_confident_v1',
          context: EmotionPhraseContextV1.identity,
          tag: EmotionTagV1.confident,
          text:
              'You are a disciplined closer. High-tier decisions stay controlled.',
        ),
        EmotionTagV1.cautious: EmotionPhraseV1(
          phraseId: 'identity_cautious_v1',
          context: EmotionPhraseContextV1.identity,
          tag: EmotionTagV1.cautious,
          text:
              'You are methodical. You finish worlds before pushing variance.',
        ),
        EmotionTagV1.urgent: EmotionPhraseV1(
          phraseId: 'identity_urgent_v1',
          context: EmotionPhraseContextV1.identity,
          tag: EmotionTagV1.urgent,
          text:
              'You reset quickly. Recovery discipline comes before complexity.',
        ),
      },
    };

EmotionPhraseV1 selectEmotionPhraseV1({
  required EmotionPhraseContextV1 context,
  required EmotionTagV1 tag,
}) {
  final contextCatalog = _kEmotionPhraseCatalogV1[context];
  if (contextCatalog == null || contextCatalog.isEmpty) {
    return const EmotionPhraseV1(
      phraseId: 'fallback_neutral_v1',
      context: EmotionPhraseContextV1.identity,
      tag: EmotionTagV1.neutral,
      text: 'Stable focus. Keep decisions clear.',
    );
  }
  return contextCatalog[tag] ??
      contextCatalog[EmotionTagV1.neutral] ??
      contextCatalog.values.first;
}
