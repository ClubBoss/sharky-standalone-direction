/// Metadata-only linker describing recap-to-quiz relationships.
class ReviewLinkerV2 {
  const ReviewLinkerV2();

  Map<String, Object?> buildRecapToQuizLink({
    required String recapFamily,
    required String quizFamily,
  }) => Map.unmodifiable(<String, Object?>{
    'version': 'v2',
    'recap_family': recapFamily,
    'quiz_family': quizFamily,
    'link': Map.unmodifiable(<String, Object?>{
      'relationship': 'recap_to_quiz',
      'strength': 'placeholder',
      'note': 'Deterministic metadata only; no content loaded.',
    }),
  });
}

ReviewLinkerV2 buildReviewLinkerV2() => const ReviewLinkerV2();
