# Runner Reveal State Boundary Audit v1

Purpose:

- identify the smallest host-state blockers that still prevent safe shared reveal-intent extraction
- select at most one tiny preparatory normalization

## Blockers

| Blocker | Where it currently lives | Why it blocks shared reveal-intent extraction | Recommendation | EV / priority |
| --- | --- | --- | --- | --- |
| active reveal payload is reconstructed locally | World 1 `_showRunnerDetailsSheetV1`; World 2 `showCompactPromptSheetV1` | each host separately rebuilds the revealed text payload for the active node instead of delegating through one shared reveal payload seam | normalize now | high |
| reveal affordance eligibility is still host-wired | World 1 compact header `Details` CTA; World 2 compact surfaced header tap | both hosts should gate reveal opening from the same resolved reveal payload instead of local ad hoc trigger wiring | normalize now | high |
| reveal persistence state shape differs | World 1 `_campaignHudDetailsExpanded` plus sheet open path; World 2 transient sheet open only | this is a real host-state divergence after the seam and should not be unified without broader runner-state redesign | remain local | medium |
| reveal trigger ownership differs | World 1 app-bar / compact header Details CTA; World 2 compact surfaced header tap | trigger placement is shell/chrome-specific, not a shared state seam | remain local | medium |
| extra details body content differs | World 1 sheet mixes prompt plus additional detail/debug rows; World 2 prompt sheet shows compact prompt-only content | content composition after the shared revealed text still belongs to the local host surface | remain local | low |

## R279 Selection

- selected preparatory normalization:
  - shared active reveal payload resolution
- why this one:
  - it is tiny
  - it is source/state-driven
  - it helps future reveal-intent extraction by giving both hosts one canonical resolved payload shape before shell-specific rendering begins
  - it does not require shell/chrome redesign

## R280 Selection

- selected rule-level seam:
  - reveal affordance eligibility from the shared reveal payload
- why this one:
  - it is a tiny next step after payload normalization
  - it stays source/state-driven
  - it keeps trigger placement local while making the openability rule canonical

## R281 Reveal Request/Dispatch Re-audit

### Shared Before Host-Local Shell Opening

- resolved prompt/details text from the prompt source seam
- resolved reveal payload:
  - `sourceId`
  - `revealedText`
  - `canReveal`
- reveal affordance eligibility:
  - `isAffordanceEnabled`

### Host-Local After That Boundary

- which local callback owns the reveal trigger
- whether the host opens a sheet, inline expansion, or another local shell
- local persistence state for whether details stay expanded
- extra local details rows and shell-specific chrome

### R281 Selection

- selected request/dispatch seam:
  - none
- STOP reason:
  - there is no additional rule-level shared seam between `isAffordanceEnabled` and host-local shell opening
  - after the shared payload and eligibility checks, both hosts immediately cross into local callback ownership and local shell presentation
  - centralizing a request/dispatch layer now would only wrap host-local callbacks and would not create a meaningful canonical source seam
