# Runner Shared Behavior Seam Audit v1

Purpose:

- audit shared runner/host behavior across current compatible World 1 / World 2 learning runners
- identify where behavior still lives per screen instead of one canonical shared seam
- select at most one highest-EV seam only if it is cleanly separable

## Scope Audited

- [world1_foundations_microtask_runner_screen.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart)
- [session_drill_player_v1_screen.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/screens/session_drill_player_v1_screen.dart)

## Candidate Seams

| Behavior seam | Where it currently lives | Shared intent or local | Current inconsistency / risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| top prompt vs full-condition/details source resolution | World 1: mode-local overrides in `world1_foundations_microtask_runner_screen.dart`; World 2: chain-step override in `session_drill_player_v1_screen.dart`; final precedence now shared via `runner_prompt_source_v1.dart` | shared product intent | final precedence/fallback drift is removed, but host-local mode decisions still remain separate by design | shared runner prompt-presentation resolver plus host-local override inputs | high | normalized in R276 at the precedence/fallback seam only |
| details / full-condition reveal trigger and modal shell | World 1: `_showRunnerDetailsSheetV1` plus info button in app bar; World 2: `showCompactPromptSheetV1` plus tappable compact surfaced header | partially shared | reveal affordance and sheet shell differ by screen; however those differences are entangled with each host's layout and visual chrome | shared modal shell widget with local body content | medium | leave local for now |
| instruction / header override injection | World 1: `RunnerInstructionSourceV1` intro and step overrides; World 2: local intro / recap card builders and direct prompt projection | partially shared | World 1 supports injected runner instruction overrides while World 2 currently projects authored source directly; centralizing now would conflate different product surfaces | none yet; needs a broader runner instruction contract first | medium | leave local |

## Highest-EV Candidate Check

- highest-EV candidate:
  - top prompt vs full-condition/details source resolution
- R276 bounded extraction:
  - the shared seam was isolated at the final precedence/fallback layer only
  - host-local mode logic still computes overrides, but both hosts now delegate the final `shortPrompt` / `detailsPrompt` resolution to one canonical source helper

## R275 Outcome

- selected seam for normalization:
  - top prompt vs full-condition/details source resolution at the precedence/fallback layer
- result:
  - normalized in bounded form
  - modal shell, visual chrome, and runner-mode branching remain host-local by design

## R277 Re-audit

### Next Candidate Ranking After R276

| Rank | Behavior seam | Classification | Why |
| --- | --- | --- | --- |
| 1 | details / full-condition reveal invocation behavior | partially shared but still host-local at the state boundary | both hosts expose fuller prompt/details on demand, but one uses an app-bar Details CTA and the other uses a tappable compact surfaced header; the invocation path is coupled to each host's chrome, density, and reveal surface |
| 2 | instruction / header override injection | partially shared but still host-local at the state boundary | World 1 has `RunnerInstructionSourceV1` overrides tied to intro/action/outcome runner modes, while World 2 still projects authored source directly |

### R277 Selection

- selected seam for normalization:
  - none
- STOP reason:
  - the next highest-EV candidate after prompt-source normalization is reveal invocation behavior
  - it is not cleanly separable yet because the trigger, affordance, and reveal surface remain coupled to host-local header chrome and runner-state shape
  - centralizing it now would require broader runner-state or shell redesign rather than one bounded shared seam extraction

## R278 Reveal-Intent Boundary

- minimal shared seam identified:
  - reveal intent/state for opening the already-resolved fuller prompt/details text
- canonical contract:
  - `docs/plan/runner_reveal_intent_contract_v1.md`
- extraction result:
  - STOP
- why:
  - the contract is isolatable, but the implementation value is still too small because both hosts already have trivial local reveal state while the real differences remain in trigger placement, chrome, and shell behavior

## R279 Reveal-State Boundary

- smallest normalized blocker:
  - shared active reveal payload resolution
- canonical source seam:
  - `lib/ui_v2/runner/runner_reveal_payload_v1.dart`
- remaining blockers after R279:
  - reveal persistence state shape
  - reveal trigger ownership
  - local shell/content composition

## R280 Reveal Rule Re-audit

- next shared rule-level seam:
  - reveal affordance eligibility
- canonical source seam:
  - `RunnerRevealPayloadResolvedV1.isAffordanceEnabled`
- why selected:
  - both hosts should only wire a reveal trigger when the shared reveal payload is revealable
  - this centralizes the openability rule without changing local trigger placement or shell behavior

## R281 Reveal Request/Dispatch Re-audit

### Candidate Classification

| Candidate seam | Classification | Why |
| --- | --- | --- |
| reveal request/dispatch seam between eligibility and opening | still host-local by design | after the shared payload and eligibility rules, both runners immediately hand off to local callbacks that open different local surfaces; the remaining variation is shell ownership, not a reusable source rule |
| trigger placement and trigger ownership | host-local by design | World 1 uses a `Details` CTA and World 2 uses a compact header tap; this is local chrome |
| shell open path and persistence state | host-local by design | one host also has persistent expanded HUD detail state while the other is transient sheet-only |

### R281 Selection

- selected seam for normalization:
  - none
- STOP reason:
  - no additional reveal-related request/dispatch seam is cleanly separable without wrapping host-local callback ownership
  - the next real differences are shell/state differences, not another canonical source seam
