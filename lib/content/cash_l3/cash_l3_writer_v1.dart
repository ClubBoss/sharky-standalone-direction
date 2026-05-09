class CashL3WriterV1 {
  Map<String, Object?> writeTheory(String id, String theory) =>
      <String, Object?>{'id': id, 'theory_written': true};

  Map<String, Object?> writeDrills(String id, List<Object?> drills) =>
      <String, Object?>{'id': id, 'drills_written': drills.length};

  Map<String, Object?> writeRecap(String id, String recap) => <String, Object?>{
    'id': id,
    'recap_written': true,
  };

  Map<String, Object?> writeQuiz(String id, List<Object?> quiz) =>
      <String, Object?>{'id': id, 'quiz_written': quiz.length};
}
