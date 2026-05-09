# R77 World1 Scenario Inventory v1

## Scope
- World1 pilot families only.
- Inventory for migration planning, not broad migration execution.

## Family inventory

### 1) Seat quiz / position identification
- Canonical content/source:
  - World1 Act0 packs in campaign registry (`world1_act0_table_literacy`, related Act0 modules).
- Authoritative runtime renderer:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - guidance helper: `_seatQuizGuidanceForTargetV1(...)`.
- Main dependencies:
  - runner mode resolution, seat target state, map launch order from `ProgressService`.
- Known contradiction risks:
  - low-meaning guidance drift if non-authoritative wording branches are edited.
- Current test coverage:
  - `test/guards/world1_foundations_microtask_contract_test.dart` seat-quiz guidance/loop/layout tests.
- Migration priority:
  - medium.
- Disposition:
  - included now (pilot contract shape + boundaries), implementation migration later.

### 2) Action choice / early decision
- Canonical content/source:
  - World1 spine campaign/followup steps (`allowedActions`, `expectedActionKind`, `why_v1` family).
- Authoritative runtime renderer:
  - same runner screen; `_buildCampaignActionChips(...)` and expected/correct/why helper chain.
- Main dependencies:
  - `toCall/currentBet/pot` action state, normalized expected-action resolver.
- Known contradiction risks:
  - illegal expected-family if explicit metadata bypasses normalization.
  - semantic mismatch between expected family and why family.
- Current test coverage:
  - world1 action-state truth invariants and expected/why contracts in foundations guard suite.
- Migration priority:
  - highest.
- Disposition:
  - included now.

### 3) Hand-loop mismatch / footer feedback family
- Canonical content/source:
  - campaign hand-loop mismatch path (`range_expectation_mismatch`) and footer outcome lines.
- Authoritative runtime renderer:
  - runner screen mismatch chain: `_runEngineV2FullHandLoop(...)`, `_engineOutcomeReason(...)`, `_buildOutcomeWhyLineV1(...)`, `_buildOutcomeExpectedLineV1(...)`.
- Main dependencies:
  - EngineV2 first-hero decision expected/actual label generation, mismatch normalization.
- Known contradiction risks:
  - sibling branch precedence divergence (R76 class) when mismatch branch uses explicit expected metadata directly.
- Current test coverage:
  - targeted contracts in `test/guards/world1_foundations_microtask_contract_test.dart` including R75/R76 repro classes.
- Migration priority:
  - highest.
- Disposition:
  - included now.

### 4) Result/progression handoff (pilot coherence)
- Canonical content/source:
  - session result composition and progression handoff semantics.
- Authoritative runtime renderer:
  - `lib/ui_v2/screens/session_result_screen.dart` (`_primaryCtaLabelV1`, `_resultWhyLineV1`, `_upNextFocusLineV1`).
- Main dependencies:
  - `ProgressService` next-pack/routing reason/progression state.
- Known contradiction risks:
  - duplicated finish framing regressions or CTA hierarchy drift.
- Current test coverage:
  - `test/ui_v2/session_result_screen_contract_test.dart`.
- Migration priority:
  - medium.
- Disposition:
  - included now for contract alignment, deferred for any broad finish rework.

## Included now / later / deferred summary
- Included now:
  - action choice and hand-loop mismatch families,
  - seat-quiz and result handoff ownership contracts,
  - foundation-level scenario truth shape.
- Later:
  - deeper field-level migration of every World1 step into canonical scenario records.
- Deferred:
  - Worlds2-10 scenario migration,
  - broad content rewriting.
