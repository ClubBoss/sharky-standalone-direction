# Content Expansion Execution Plan - SSOT (Phase 7.x)

## 1) Goal
Extend the training library safely by adding minimal, deterministic units that plug into the validated First 5 Minutes baseline without altering the core session flow, telemetry, or UX.

## 2) In-scope (allowed)
- New modules or packs that reuse the current content schemas (`CONTENT_SCHEMAS.md`) and manifest structure.
- Content that is consumed via the existing loaders (`DirectLoader`, pack templates) and therefore runs through the guarded session path (`training_session_screen.dart` → `TrainingSessionOutcomeTracker`).
- Additions that keep the telemetry names `session_start`, `session_end`, and `session_abort` unchanged.

## 3) Out-of-scope (forbidden)
- New engines, telemetry events, schemas, or DSLs beyond the current manifest + drills/quiz definitions.
- Changes to Modern Table visuals, navigation flows, or completion UX defined in Phase 6.1–6.2 SSOTs.
- Any new telemetry hooks, analytics surfaces, or UX components not already covered by the baseline.
- Infra or tooling changes that would alter how packs are run (e.g., new launchers, new session services).

## 4) Execution order
1. Draft manifest + schema-conformant drills/quiz files for a single module/pack.  
2. Run schema validation (`tools/validate_training_content.dart --ci`).  
3. Confirm the module is discoverable via `DirectLoader`/pack registry and triggers `training_session_screen.dart`.  
4. Verify telemetry invariants via the existing contract tests (session timing + outcome tracker).  
5. Only then proceed to the next module or pack.

## 5) Entry gates
- `CONTENT_SCHEMAS.md` validator passes for all new files.  
- The First 5 Minutes SSOTs (`first_5_minutes_flow.md`, `learning_philosophy.md`, `content_design_spec.md`) remain unchanged.  
- Contract tests (`test/contracts/session_start_timing_e2e_contract_flutter_test.dart`, `test/unit/training_session_outcome_tracker_test.dart`) still pass with the new addition.  
- The pack/module is wired through the canonical loaders and not through an ad-hoc screen.

## 6) Exit criteria
- Each new module has been validated, wired, and exercised through the deterministic session flow.  
- Baseline telemetry events (`session_start`, `session_end`, `session_abort`) still fire once per session.  
- Expansion is limited to the approved modules/packs; no additional items are staged.

## 7) Drift guards
- No new schemas, engines, or telemetry unless a new Phase 7+ SSOT is documented in an existing canonical/governance location (the historical Phase 7 folder path is not present in this repo snapshot; use `docs/reference/master_plan_6/legacy_materials_index.md` as the archive/governance index until a new phase index is created).  
- Any deviation (e.g., new telemetry names or feelings of uncertainty in the session flow) requires a re-freeze and revalidation by the Phase 6.x SSOT owners.  
- Expansion proceeds one module/pack at a time; rolling batches are forbidden without an explicit gate review.  
- All new content must go through the same contract tests and `tools/validate_training_content.dart --ci` before being merged.
