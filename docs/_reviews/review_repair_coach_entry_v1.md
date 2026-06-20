# Act0 Review Repair-Coach Entry v1

## Scope and design checkpoint

- Branch: `codex/act0-review-repair-coach-entry-v1`.
- Local base: `e54cb6ff35f676cd08242ab8e68ed50bbcc3d414` (the locally available PR #23 head; merged-main `ac05ae05ad26d3d8522caff143c70f835ee5a525` was not fetched to preserve local-only mode).
- Review is a repair coach, not a dashboard or error log: the existing deterministic mistake card supplies the clue, learner-facing repair action, and existing repair callback.
- The primary entry is one block/card, never a primary pill/chip. Its pill-like metadata remains tertiary only.
- Home remains the top-level next-action owner; Practice remains the repetition surface. Review only explains the missed clue and invokes the existing repair handoff.
- Session proof ceremony is not rendered by Review.
- Capture screenshots before PR approval only because this visible Review structure changes materially.

## Behavior and safety

- Active repair: one `Repair coach` card explains the learner-facing clue, its next useful review action, and a deterministic next repair hand.
- Pending pattern: repeated mistake families surface as `Pattern to repair`, not an error log.
- Recovered mistakes: remain secondary `Recovered lately` proof; no permanent-mastery claim is used.
- No active repair: the existing calm clean-board fallback remains available, with recovered proof when present.
- Copy safety: Review coach copy is generated through `act0_repair_intent_copy_guard_v1.dart`; prohibited terms are not added.
- Telemetry: no event, owner, or payload contract changes.
- Pills/chips: existing contextual pills are tertiary metadata only; the repair coach is a card.

## Files and connectivity

- Changed: `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`, focused Review/copy tests, and this evidence artifact.
- No TOP1 or Topology anchor is needed: this is a bounded evidence artifact and does not alter route sequence, authority, or gates. No Master Plan edit is required.
- Exact next wave recommendation: capture the materially changed Review screenshots, then open the local branch as a PR for Review repair-coach verification.

## Checks

- Focused Review, repair-copy, telemetry, static analysis, diff, and fast-loop results are recorded from the final local verification run.

## Screenshot Capture Attempt / Waiver

- Screenshots were requested because Review visible structure changed materially.
- The existing controlled demo capture could not capture deterministic Review states.
- A targeted harness was attempted locally; it produced `review_active_repair.png` but the command did not terminate.
- The four required clean Review states were not captured, so this PR makes no visual screenshot approval claim.
- Raw screenshot artifacts remain local-only and uncommitted. The targeted surface screenshot harness is deferred as a separate tooling wave.
- This PR proceeds on focused tests, static analysis, diff validation, and the fast loop.
