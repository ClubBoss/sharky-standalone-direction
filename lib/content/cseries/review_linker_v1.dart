/// Deterministic metadata descriptor for review linking across families.
class ReviewLinkerV1 {
  const ReviewLinkerV1();

  Map<String, Object?> buildReviewLinkDescriptor({
    required String recapFamily,
    required String quizFamily,
    required String checkpointFamily,
  }) => Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'recap_family': recapFamily,
    'quiz_family': quizFamily,
    'checkpoint_family': checkpointFamily,
    'note': 'Deterministic metadata descriptor; no content loaded.',
  });
}

ReviewLinkerV1 buildReviewLinkerV1() => const ReviewLinkerV1();
