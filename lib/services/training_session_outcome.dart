/// Append-only signaling for training session outcomes.
enum TrainingSessionEndReasonV1 { completed, aborted }

typedef TrainingSessionEndCallback =
    void Function(TrainingSessionEndReasonV1 reason);
