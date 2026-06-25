# Profile Evidence Projection v1

## 1. Verdict

profile_evidence_projection_data_only_ready

## 2. Trust-pack finding implemented

The Wave 3 trust pack selected `Profile Evidence Projection v1 — Data Only` as
the next safest PR after accepting Review read-only history. This slice
implements that data-only projection and does not admit Profile UI or
learner-facing capability copy.

Implemented:

- `Act0ProfileEvidenceProjectionV1`
- `Act0ProfileCapabilitySignalV1`
- conservative V1 thresholds
- focused projection tests

Not implemented:

- Profile UI consumer
- Profile capability copy
- Practice queue
- Review UI changes
- route/progression changes

## 3. Evidence source audit

The projection source is `Act0LearningEvidenceHistoryV1`, which already stores
durable completed-decision evidence. The projection imports only
`act0_learning_evidence_contract_v1.dart`.

Source boundary:

- `Act0LearningEvidenceHistoryV1` is allowed for Profile capability evidence.
- `Act0ReviewMistakeHistoryV1` is not used as Profile capability evidence.
- Review mistake history remains suitable only for future `needs review`
  surfaces.
- `Act0RepairIntentV1` remains active repair ownership and is not consumed by
  this projection.

## 4. Projection owner/model

Owner:

- `lib/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart`

Model:

- `Act0ProfileEvidenceProjectionV1` owns a deterministic list of
  `Act0ProfileCapabilitySignalV1` rows.
- `fromLearningEvidenceHistory(...)` groups completed-decision evidence by
  `skillAtomId`.
- Signals are ordered alphabetically by `skillAtomId`, not by accuracy or
  strength, so V1 does not imply ranking.
- `toPayload()` and `tryParse(...)` provide bounded serialization/parser support
  for the projection shape.

## 5. Capability signal schema

Each `Act0ProfileCapabilitySignalV1` exposes fact-only fields:

- `schemaVersion`
- `signalId`
- `skillAtomId`
- `attemptCount`
- `correctCount`
- `incorrectCount`
- `accuracyPercent`
- `sampleThreshold`
- `sampleThresholdMet`
- `positiveSignalThresholdMet`
- `worldIds`
- `lessonIds`
- `latestOrder`
- `eligibilityState`

The schema intentionally has no learner-facing label, no copy line, no ranking,
no badge state, and no mastery state.

## 6. Threshold rules

V1 constants:

- `act0ProfileEvidenceMinimumAttemptsV1 = 5`
- `act0ProfileEvidenceMinimumCorrectForPositiveSignalV1 = 3`

Rules:

- No capability signal is eligible below 5 attempts.
- A positive eligible signal requires at least 5 attempts and at least 3
  correct decisions for the same `skillAtomId`.
- A sampled signal with fewer than 3 correct decisions is internal
  `needs_more_practice_v1`, not learner-facing weakness/leak copy.
- V1 does not compute `strongest skill`, `weakest skill`, or any ranked output.
- V1 does not create a mastery state.

## 7. Eligibility-state rules

Internal states:

- `insufficient_sample_v1`: fewer than the sample threshold.
- `eligible_signal_v1`: sample threshold met and positive-signal correct-count
  threshold met.
- `needs_more_practice_v1`: sample threshold met but positive-signal correct
  threshold not met.

`isCapabilityEligible` is true only for `eligible_signal_v1`.

These are internal model states. They are not Profile copy and are not consumed
by Profile in this PR.

## 8. Forbidden-claim proof

The projection does not add fields or copy for:

- mastery
- leak
- AI detected
- GTO
- solver
- strongest/weakest skill
- based on your last N decisions/hands
- premium/paywall/trial

Focused tests assert the serialized projection payload does not contain the
forbidden claim families and that invalid parser states such as `mastered_v1`
are rejected.

## 9. Consumer admission status

No consumer is admitted in this PR.

Profile may consume the projection only in a future consumer-admission PR that:

- preserves threshold gates;
- introduces copy separately;
- avoids mastery/leak/AI/GTO/solver/premium/ranking claims unless separately
  admitted and tested;
- proves the Profile screen remains honest when no eligible signal exists.

## 10. Tests / validation

Passed focused tests:

- `flutter test test/ui_v2/act0_profile_evidence_projection_v1_test.dart`

Passed affected learning-evidence tests:

- `flutter test test/ui_v2/act0_learning_evidence_contract_v1_test.dart`

Passed validation:

- `graphify hook-check`
- `flutter analyze`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart test/ui_v2/act0_profile_evidence_projection_v1_test.dart`
- `git diff --check`
- `git status --short` showed only the new model/test/review files plus
  generated local output directories before staging.

## 11. Next recommended PR

Profile Evidence Consumer Admission v1 — Read-Only Profile Surface

Scope for the next PR:

- consume `Act0ProfileEvidenceProjectionV1` in Profile only after checking
  eligibility;
- show no capability row when no eligible signal exists;
- add learner-facing copy in a separate, tested copy contract;
- do not add ranking, mastery, leak, AI, GTO, solver, premium, achievements, or
  rewards;
- do not route Profile from Review mistake history.
