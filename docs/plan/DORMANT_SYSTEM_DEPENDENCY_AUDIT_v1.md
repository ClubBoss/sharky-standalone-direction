# DORMANT_SYSTEM_DEPENDENCY_AUDIT_v1
Status: ACTIVE
Purpose: classify large non-route repository families before any archival or
deletion wave.
Last updated: 2026-05-13

## Scope

This audit covers the main dormant/non-route families currently visible in the
repo:

1. `lib/ui_v2/persona`
2. `lib/ui_v2/ai_coach`
3. `lib/personalization`
4. `lib/ui_v3`
5. `lib/ui_v2/screens`

This is not a broad cleanup or archive operation by itself.

It exists to answer one question safely:

`what can be removed now, and what is still linked enough that removal would be dishonest or risky?`

## Classification rule

Each family must be classified as one of:

1. `safe_to_archive_now`
2. `dormant_but_linked`
3. `still_active_by_dependency`

Only `safe_to_archive_now` families are eligible for direct archive/removal in
the next wave without a deeper unlink pass.

## Findings

### 1. `lib/ui_v2/persona`

- Approx. file count: `399`
- Quick external reference count: `4`
- Reference types observed:
  - QA / stability bridges
  - regression gates
  - simulation/table-adjacent surfaces
  - dormant-system boundary docs

Verdict: `dormant_but_linked`

Reason:

- This family is not part of the current Act0 learner route.
- It is still linked through QA/release helper surfaces and a few non-Act0 UI
  references.
- Broad deletion would create avoidable breakage before value is proven.

### 2. `lib/ui_v2/ai_coach`

- Approx. file count: `3`
- Quick external reference count: `5`
- Reference types observed:
  - smoke tests
  - HUD overlay
  - service layer
  - dormant-system boundary docs

Verdict: `dormant_but_linked`

Reason:

- Tiny family, but still visibly wired into support layers.
- Safe to demote from active route; not yet safe to archive blindly.

### 3. `lib/personalization`

- Approx. file count: `21`
- Quick external reference count: `47`
- Reference types observed:
  - many tests
  - session result / intake / recommendation legacy flows
  - services and content bridges
  - planning docs

Verdict: `still_active_by_dependency`

Reason:

- Not active Act0 route truth, but still materially linked across test and
  legacy flow seams.
- This family needs a real unlink plan, not cosmetic archiving.

### 4. `lib/ui_v3`

- Approx. file count: `24`
- Quick external reference count: `45`
- Reference types observed:
  - tables/widgets
  - screens
  - services
  - persona and recommendation surfaces

Verdict: `dormant_but_linked`

Reason:

- Clearly outside the current Act0 shell route.
- Still structurally entangled with various widgets and support paths.
- Not safe for direct removal yet.

### 5. `lib/ui_v2/screens`

- Approx. file count: `52`
- Quick external reference count: `197`
- Reference types observed:
  - guards
  - legacy routing tests
  - old runtime surfaces
  - compatibility contracts

Verdict: `still_active_by_dependency`

Reason:

- This is the most confusing dormant family because parts of it are still
  referenced by canonical-adjacent files.
- Example: `lib/ui_v2/ui_v2_beta_shell.dart` still imports legacy
  `ui_v2/screens/*` surfaces while also owning `buildCanonicalPathRootV1`.
- Direct archival would be reckless until that mixed ownership is split.

## Safe cuts already landed

The following cuts were safe and already landed:

1. remove stray local screenshot artifact under `lib/ui_v2/ai_coach/`
2. remove the unused `universal_intake_plan_screen.dart` import from
   `lib/ui_v2/app_root.dart`

These reduce noise without pretending larger dormant families are safe to
delete yet.

## Recommended next unlink order

If the goal is to keep shrinking non-active app confusion safely, use this
order:

1. **Split canonical helpers out of mixed files**
   - especially `lib/ui_v2/ui_v2_beta_shell.dart`, which currently mixes active
     canonical root helpers with older tab-host behavior
2. **Demote or isolate legacy `ui_v2/screens` compatibility flows**
   - only after canonical helper extraction
3. **Audit `personalization` imports from old result/intake surfaces**
   - classify which parts are still needed by current repo contracts
4. **Trim QA/release references to persona/ai-coach where they no longer carry
   active value**

## Hard rule

Until a family is upgraded to `safe_to_archive_now`, do not:

- move it to archive
- delete it
- claim it is gone from the app

Demotion from the active route is already done.
Actual archival requires proven dependency separation.
