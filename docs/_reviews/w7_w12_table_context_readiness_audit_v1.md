# W7-W12 Table-Context Readiness Audit v1

## 1. Verdict

`w7_w12_table_context_ready_with_optional_gaps`

W7-W12 active route table context is ready for Phase 6 closure audit. No
position, stack, multi-street, route, screen, Modern Table, or production repair
is required from this audit.

## 2. Audit Scope

Audited active route evidence only:

- W7-W12 hidden runtime owner task specs.
- active W7-W12 real-text screenshot lane.
- Street Replay / How We Got Here source contract.
- W7-W12 route-admission and mapper/Practice guards.

No W13+, solver output, route expansion, broad curriculum rewrite, Modern Table
redesign, persistence, or speculative hand-history reconstruction was admitted.

## 3. Source Owners

| World | Active route owner | Route concept |
| --- | --- | --- |
| W7 | `act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart` | visible cards narrow possible hands |
| W8 | `act0_w8_draws_hidden_runtime_session_owner_v1.dart` | draws can improve on future cards |
| W9 | `act0_w9_price_hidden_runtime_session_owner_v1.dart` | call price versus pot reward |
| W10 | `act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart` | value / bluff purpose |
| W11 | `act0_w11_board_texture_hidden_runtime_session_owner_v1.dart` | board texture danger awareness |
| W12 | `act0_w12_review_decision_hidden_runtime_session_owner_v1.dart` | review clue and explanation |

These owner specs remain the active evidence source for W7-W12 visual route
captures. The older Act0 map/source offset is a known route-map context issue,
not a blocker for this table-context audit.

## 4. Active Table Context

The active screenshot lane builds table state from source-owned owner specs and
renders it through `Act0LessonRunnerShellV1`. The table state carries:

- six-max seat labels;
- BTN hero and active actor;
- visible hero cards;
- three-card flop board;
- source-owned board/context label;
- source-owned learning-purpose callout;
- pot label;
- W9-only call-price label.

## 5. Position Readiness

Position is ready for the admitted route depth. The active route table state
uses `heroSeatId: btn`, `activeSeatId: btn`, and visible BTN seat context. No
additional position repair is required.

## 6. Stack Readiness

No W7-W12 active route owner requires a source-backed stack decision for the
current visual route packet. Stack labels are therefore an optional future
enhancement, not a blocker. This audit does not authorize guessing effective
stack from prose.

## 7. Pot / Price Readiness

Pot context is present across the active route table state. W9 additionally
carries the source-owned call-price label (`Call 3 BB` in the screenshot lane),
which is the only current W7-W12 route concept that needs a visible price field.

## 8. Board / Street Readiness

The active route table state renders a flop with three board cards. This is
enough for the current W7-W12 route tasks because the admitted route packet is
concept-transfer and review oriented, not a full hand-history playback.

## 9. Multi-Street Readiness

No active W7-W12 owner spec requires source-owned turn/river reconstruction for
the current packet. Multi-street additions are therefore optional and deferred.
The audit does not authorize inventing turn/river context from review prose.

## 10. Street Replay Relationship

Street Replay remains correctly fail-closed for active route captures. The
active capture lane places learning-purpose prose in the `actionTrail`; the
Street Replay parser does not convert that prose into fake poker actions. The
new guard proves those states return `insufficient` with no consumer-safe steps.

## 11. Optional Gaps

Optional, non-blocking gaps:

- no stack label on the active route visual table;
- no source-owned multi-street action history for W7-W12 concept captures;
- Street Replay is hidden on active route captures because prose action-trail
  labels are not source-owned poker actions.

These gaps should not trigger product repair unless a later task admits a
specific source-backed table-context owner.

## 12. Blocking Gaps

No blocker was found.

Rejected blocker candidates:

- missing stack label: optional for current W7-W12 concepts;
- missing multi-street replay: optional and unsafe without source action truth;
- Act0 map/source offset: relevant to broader route-map cleanup, not this
  active screenshot lane or route-owner table-context readiness.

## 13. Guard Added

Added:

- `test/guards/w7_w12_table_context_readiness_audit_contract_test.dart`

The guard proves 24 active W7-W12 owner specs carry visible route context,
Practice remains blocked, forbidden expansion claims remain absent, and Street
Replay does not fabricate replay from prose action-trail labels.

## 14. Screenshot Evidence

Generated and copied local-only evidence to:

- `output/w7_w12_table_context_readiness_audit_v1/active_route_w7_w12_contact_sheet.png`
- `output/w7_w12_table_context_readiness_audit_v1/screen_review_active_route_w7_w12_fast.zip`
- `output/w7_w12_table_context_readiness_audit_v1/active_route_w7_w12_meta.json`
- `output/w7_w12_table_context_readiness_audit_v1/first_week_contact_sheet.png`
- `output/w7_w12_table_context_readiness_audit_v1/screen_review_first_week_fast.zip`
- `output/w7_w12_table_context_readiness_audit_v1/full_scroll_contact_sheet.png`
- `output/w7_w12_table_context_readiness_audit_v1/screen_review_full_scroll_fast.zip`

`output/**` remains local-only and must not be committed.

## 15. Route / Practice Boundary

The current W7-W12 route packs remain admitted route-owned packs, while mapper
and Practice CTA remain intentionally blocked for W7-W12. This audit does not
open Practice mapping or any new route.

## 16. Validation

Focused validation during the audit:

- `flutter test test/guards/w7_w12_table_context_readiness_audit_contract_test.dart --reporter expanded`
- `./tools/screen_review_fast_v1.sh active_route_w7_w12 compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Final repository validation is recorded in the implementation response.

## 17. Risk

Residual risk is limited to future owner specs changing the source-owned table
context without updating the guard. The new guard is intended to fail in that
case.

## 18. Capsule Advance

Advance route state:

- `W7-W12 Table-Context Readiness Audit v1` -> CLOSED
- `Phase 6 Closure Audit v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/w7_w12_table_context_readiness_audit_v1.md`

## 19. Next Recommendation

`Phase 6 Closure Audit v1`

## 20. Commit Boundary

Admitted commit contents:

- this audit artifact;
- the focused table-context readiness guard;
- active route / visual proof capsule updates.

Do not commit `output/**`.
