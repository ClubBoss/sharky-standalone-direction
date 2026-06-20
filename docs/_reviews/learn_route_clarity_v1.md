# Act0 Learn Route Clarity v1

- Branch/base: `codex/act0-learn-route-clarity-v1` from local merged-PR head `859b655c`.
- Seam: existing `_CurrentMissionCardV1` and journey preview; no route, repair, or telemetry seam changed.
- Learn now names its primary card `Learning path`, frames the current concept as `Now`, and gives learner-facing `Why it matters` support. The existing journey preview remains the next-step route context.
- Generic/no-repair state remains route-first; no Review receipts, Home command, Practice launcher, Profile identity, or session proof ceremony is introduced.
- Pills remain tertiary metadata; the primary route entry is a card.
- Copy and telemetry safety: no prohibited claims or telemetry changes.
- Screenshot note: visible Learn hierarchy changed materially; capture before PR approval, without tooling work in this wave.
- Connectivity: evidence only; no Topology/TOP1 or Master Plan anchor is needed.
- Checks: focused Learn/preview, repair-copy, telemetry, analyze, diff, and fast loop pending final run.
- Exact next wave: capture Learn route screenshots, then package the bounded Learn route-clarity PR.

## Baseline Preview Note

- The nine Learn-specific preview assertions pass after preserving their existing lesson/support text contracts.
- Two Review-state preview failures reproduce on clean updated main `37c88f65fb403e443c0628053f3166d8291222c2`: `Review repair card prefers wrapped density over hard truncation` and `Second wrong answer becomes a deeper Review leak`.
- Learn is not the cause; the broad preview suite and fast loop remain baseline-blocked by those separate Review failures.
