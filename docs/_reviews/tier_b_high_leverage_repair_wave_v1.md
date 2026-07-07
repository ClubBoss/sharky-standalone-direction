# Tier B High-Leverage Repair Wave v1

Status: `tier_b_high_leverage_repair_wave_closed_at_honest_ceiling`

Date: 2026-07-07

Branch: `codex/tier-b-high-leverage-repair-wave-v1`

Base HEAD: `e6d176aa3ba3980763386e5436ffd28091d35829`

## Scope

This wave reduced maintained Tier B failure volume through shared support
repairs only. Tier C files, tier assignments, Modern Table production code,
W1-W12 content, and historical visual contracts were not changed.

## Pre-Edit Measurement

| Gate | Result |
| --- | --- |
| Manifest validator | PASS |
| Tier A full | PASS: 10 attempted, 10 pass, 0 fail, 0 timeout |
| Tier B full | BLOCK: 117 attempted, 0 pass, 117 fail, 0 timeout |

Tier B baseline was a shared compile/setup failure set, not a plugin or
timeout problem.

## Root-Cause Table

| Family | Tier B files affected | Failure mode | Shared fix possible | Risk | Action |
| --- | ---: | --- | --- | --- | --- |
| Audit Hub support modules and screenshot fixtures | 4 directly unlocked; more Audit Hub files moved from missing-import to current-state assertions | `package:poker_analyzer/audit_hub_v1/*` imports resolved to no active package path; screenshot evidence expected under `assets/audit_hub_v1` was archived | Yes: restore maintained Audit Hub support modules and fixture assets from the accepted archived owner copy | Low: Tier B support-only, no active route/product behavior | Implemented |
| Session-drill / ModernTable legacy runner imports | ~72 files | Stale imports and symbols for `SessionDrillPlayerV1Screen`, `ModernTableScreenV1`, and `CanonicalTerminalSessionDrillSurfacedRunnerV1` | Technically possible only by restoring old import paths or rewriting many tests | High: prompt forbids Modern Table alteration and compatibility wrappers for retired APIs | Stopped |
| Progress-map / legacy UI path drift | ~10 files | Missing `UiV2ProgressMapScreenV2`, legacy session-result, and map routing APIs | No safe shared fix without reopening archived UI surfaces | High: Act0 remains canonical; map v2 is archived reference-only | Stopped |
| Audit Hub operational snapshot / readiness parser drift | 2 primary files plus dependent service assertions | Missing `assets/audit_hub_v1/operational_snapshot.json`; readiness parser expects older score-line format | Partial, but current readiness owner uses layered Core / Ship / Final model and no active snapshot fixture exists | Medium-high: would require inventing fixture truth or reinterpreting readiness SSOT | Stopped |
| Tool CLI Dart/Flutter dependency drift | 2 files | CLI tests invoke `dart run` against tools whose transitive imports require Flutter `dart:ui` | Possible only through deeper tool dependency split | Medium: first small fix did not make files green; broader split is poor EV in this wave | Stopped |
| Heterogeneous assertion/content/path drift | Remaining files | Missing current assets, expected-clean audit outputs that now report live issues, stale API constants | No single owner-safe repair | Mixed | Deferred |

## Changes Made

- Restored seven maintained Audit Hub support modules under
  `lib/audit_hub_v1/` from
  `docs/archive/archived_dormant_subsystems/audit_hub_v1_code_archived/`.
- Restored Audit Hub screenshot evidence fixtures under
  `assets/audit_hub_v1/world_screenshot_evidence_v1/` from the accepted
  archived asset bucket.

No product route code, Tier C files, Modern Table source, tier manifests, or
W1-W12 content files were changed.

## Focused Evidence

Focused Audit Hub support checks:

```text
flutter test \
  test/tools/world_route_ownership_inventory_v1_test.dart \
  test/tools/world_screenshot_evidence_audit_v1_test.dart \
  test/tools/world_visual_instrumentation_audit_v1_test.dart \
  test/tools/session_world_truth_surface_audit_v1_test.dart \
  -r compact
```

Result: PASS, 8 assertions across 4 files.

The broader Audit Hub operational builder/service tests still fail on missing
operational snapshot and readiness-parser drift. Those require owner truth and
were not repaired by inventing fixture state.

## Final Tier B Measurement

| Gate | Result |
| --- | --- |
| Tier B full | BLOCK: 117 attempted, 4 pass, 113 fail, 0 timeout |

Newly green Tier B files:

- `test/tools/session_world_truth_surface_audit_v1_test.dart`
- `test/tools/world_route_ownership_inventory_v1_test.dart`
- `test/tools/world_screenshot_evidence_audit_v1_test.dart`
- `test/tools/world_visual_instrumentation_audit_v1_test.dart`

Remaining dominant signatures are stale legacy runner imports, Modern Table
symbol drift, map-v2 legacy imports, missing operational snapshot fixture, and
heterogeneous assertion/path drift. Further repair would require restoring
retired APIs, touching Modern Table, changing tier assignments, or making
owner-truth decisions outside this prompt.

## Final Validation

| Gate | Result |
| --- | --- |
| Manifest validator | PASS |
| Tier A full | PASS: 10 attempted, 10 pass, 0 fail, 0 timeout |
| Tier B full | BLOCK: 117 attempted, 4 pass, 113 fail, 0 timeout |
| Tier C smoke | NON_BLOCKING_SIGNAL: 4 attempted, 0 pass, 3 fail, 1 timeout |
| `flutter analyze` | PASS: no issues |
| `git diff --check` | PASS |
| `git diff --cached --check` | PASS |
| `graphify hook-check` | PASS |

## Verdict

`tier_b_high_leverage_repair_wave_closed_at_honest_ceiling`

Tier A remained green pre-edit, Tier B non-green count was reduced from 117 to
113, the implemented fixes are shared and maintained-owner aligned, and the
remaining failures are not safe high-EV shared repairs in this wave.
