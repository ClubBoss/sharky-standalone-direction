# Wave 3.11 - Personalized Return Reason v1

## 1. Verdict

wave3_11_personalized_return_reason_ready

## 2. Target 10/10 block

Personalized Return Reason.

Target backcast row B: Day 2/Home return should say something that could not have been written before the learner's last session.

## 3. Current gap

Return was coherent but not proof-specific enough.

Before this slice, Home could orient the learner to the next useful action, but the visible return reason did not consume a stored last-session proof/focus receipt. That left the habit loop feeling more like a generic daily prompt than a deterministic return to the learner's own path.

## 4. Cross-Session Learner State Fields contract

Fields:

| Field | Semantics |
| --- | --- |
| `last_session_repair_focus_id` | Source-owned string ID for the last active repair focus. This uses the closest existing repair focus / repair target ID. Full concept-family mapping remains deferred to Wave 3.15 Mistake Family Taxonomy. |
| `last_session_proof_result` | Enum-like proof state: `fix_landed`, `not_yet`, or `skipped`. |
| `last_session_date` | Existing local date string representation for the recorded session day. |
| `last_session_world_id` | Source-owned world ID for the session context, for example `world_1`. |

Owner: Session close / proof receipt seam in the Act0 shell.

Reader: Day 2/Home return surface through the Act0 Home shell.

Storage: existing local Act0 progress persistence only. No server, network telemetry, analytics owner, or learner profile schema was added.

Limitations: the first implementation can map only known safe focus IDs to release-safe labels. Unknown IDs are not exposed and fall back to honest generic copy.

## 5. Implementation summary

State is written in `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` from the existing repair proof/answer seams:

- successful repair proof writes `fix_landed`;
- missed active repair focus writes `not_yet`;
- the persisted Act0 progress snapshot stores the contract as `lastSessionLearnerState`.

State is read by the same Act0 preview shell when constructing `Act0HomeShellV1`.

Copy is selected by `act0PersonalizedReturnReasonLineV1` in `lib/ui_v2/act0_shell/act0_last_session_return_reason_v1.dart`. It consumes only the stored proof result plus a small safe label map. If the focus ID has no readable safe label, the selector never prints the raw ID and falls back to state-based copy.

Fallback behavior is preserved: when no last-session state exists, Home keeps the existing generic daily support line.

## 6. Learner-visible change

After a real repair proof, the Home/Day 2 return support line can now say a stored-state-derived line such as:

- `Yesterday you landed the fix. Keep the no-bet-yet clue fresh.`
- `You were working on the no-bet-yet clue. One rep keeps it honest.`

Those lines depend on the prior session's proof result and repair focus. They could not be truthfully written before that session state existed.

## 7. Evidence

Focused tests:

- `flutter test test/ui_v2/act0_last_session_return_reason_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --name "successful repair writes personalized return reason for Home"`
- `flutter test test/ui_v2/act0_last_session_return_reason_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Home mission command owns path focus without standalone route banners"`

Screenshot proof:

- `./tools/screen_review_fast_v1.sh day2_return compact` passed and regenerated `output/screen_review/current/day2_return_fast/`.
- `./tools/screen_review_fast_v1.sh first_week compact` passed and regenerated `output/screen_review/current/first_week_fast/` because Home was touched.

Static validation:

- `flutter analyze` passed.
- `graphify hook-check` passed.
- `dart format --set-exit-if-changed` on touched Dart/test files passed.
- `git diff --check` passed.
- `git diff --cached --check` passed.

Generated screenshot artifacts remain local-only and untracked.

## 8. Anti-theater proof

This is deterministic personalization, not generic habit copy:

- the visible line is selected from persisted local state;
- the state is written by existing repair proof / answer seams;
- proof copy differs between `fix_landed`, `not_yet`, and missing state;
- unknown implementation IDs are hidden rather than dressed up as personalization;
- no generated text, LLM, chat layer, analytics inference, or broad profile claim is involved.

The copy does not claim Sharky remembers everything, mastery, leaks, GTO, solver correctness, or durable capability.

## 9. Not built

Not built:

- no AI/chat;
- no network/server;
- no full learner profile;
- no spaced repetition;
- no practice generator;
- no mistake taxonomy beyond the future mapping note;
- no monetization;
- no route rewrite;
- no onboarding flow;
- no RU rollout;
- no Modern Table change.

## 10. Expected TOP1 movement

Expected movement:

- habit credibility improves because Day 2 can refer to the learner's prior proof/focus;
- deterministic personalization trust improves because the reason is stored, bounded, and testable;
- Day 2 return motivation improves because the next rep feels tied to unfinished or landed work instead of a generic daily nudge.

## 11. Actual observed movement

The matrix row moved from coherent-but-generic return copy to source-owned personalized return copy.

Evidence is currently widget/state tests plus compact screenshot packet safety. The wave does not yet measure retention or click-through, so behavioral lift remains a future product metric rather than a claim in this artifact.

## 12. Next wave validity

Wave 3.12 - World 1 Completion Payoff v1 remains the next valid route.

Wave 3.11 should not be expanded into full learner profile, spaced repetition, mistake taxonomy, or Practice generator work. The next wave can build on this local proof-state pattern while preserving the current route and claim boundaries.
