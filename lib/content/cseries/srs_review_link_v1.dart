/// Metadata-only descriptor linking recap/quiz to SRS families.
class SRSReviewLinkV1 {
  const SRSReviewLinkV1();

  Map<String, Object?> buildSRSReviewLink({
    required String recapFamily,
    required String quizFamily,
    required String srsFamily,
  }) => Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'recap_family': recapFamily,
    'quiz_family': quizFamily,
    'srs_family': srsFamily,
    'srs_link': Map.unmodifiable(<String, Object?>{
      'relationship': 'recap_quiz_to_srs',
      'stage': 'placeholder',
      'note': 'Deterministic metadata-only descriptor; no SRS logic executed.',
    }),
  });
}

SRSReviewLinkV1 buildSRSReviewLinkV1() => const SRSReviewLinkV1();
