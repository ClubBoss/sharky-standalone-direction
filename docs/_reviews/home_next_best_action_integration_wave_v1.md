# Home Next-Best-Action Integration Wave v1

## 1. Branch / base commit

- Branch: `codex/home-next-best-action-integration-wave-v1`
- Base commit: `5f4f4a2d`

## 2. Files changed

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/home_next_best_action_integration_wave_v1.md`

## 3. Seam used

The wave uses the existing `Act0HomeShellV1.nextUsefulHandReasonLine` seam, which is already fed by the deterministic repair-intent resolver in `Act0ShellPreviewScreenV1`.

No new route, persistence, repair owner, telemetry owner, or payload contract was added.

## 4. Repair-aware Home behavior

When `nextUsefulHandReasonLine` contains a mapped repair reason for the no-bet-yet clue, Home now renders a compact next-best-action block with:

- primary action: `Repair the no-bet-yet clue`
- secondary reason: the existing learner-facing repair reason line

Exact replay reasons render replay-only action framing:

- `Replay this spot`

## 5. No-repair Home behavior

When no repair reason exists, Home still renders a clean generic next action:

- `Continue your first lesson`
- `Sharky has your next useful hand ready.`

This keeps Home useful without implying personalization that is not present.

## 6. Session ceremony containment

Home does not render the session-summary ceremony block or `Session proof` label. The session ceremony remains contained to the feedback/session summary seam.

## 7. Pills / chips handling

The next-best-action surface is a compact action/proof block, not a pill or chip. Existing pills remain tertiary metadata only.

## 8. Copy safety

No AI, adaptive, GTO, solver, optimal, win-rate, guarantee, premium, paywall, trial, unlock, leak detected, or forever-mastery language was added.

## 9. Telemetry safety

No telemetry event names, payload fields, sinks, or ownership changed. Existing telemetry tests remain the regression guard.

## 10. Checks

Local verification is recorded in the final PR report.

## 11. Exact next wave recommendation

Act0 Practice / Review Next-Best-Action Coherence v1: align the Practice and Review entry points with the same next-action hierarchy without adding dashboard breadth or new personalization claims.
