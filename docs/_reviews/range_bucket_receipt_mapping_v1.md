# Range-Bucket Receipt / Review Mapping v1

## Scope

PIEC only for the existing W6 `range_bucket_classifier_v1` same-signal
family. No UI, route, telemetry, content, glossary, Modern Table, or
generated-output changes are included.

## Evidence used

- `docs/_reviews/same_signal_drill_expansion_v1.md`
- `content/worlds/world6/v1/sessions/w6.s01/drills/`
- `content/_meta/world_drills_manifest_v1.json`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- focused Act0 repair-intent/resolver and W6 runtime contracts

## Current limitation

The six authored W6 range-bucket drills are deterministic session-drill
content. They load through the manifest -> `DrillRuntimeAdapterV1` ->
session-drill-player path.

Act0 repair intents are created only from an `Act0RunnerStateV1` feedback
proof. The current proof classifier recognizes table/board/price/position
signals and emits the corresponding receipt atom and next-rep id. It has no
range-bucket proof identity or receipt field.

The Act0 World 7 range tasks are a separate, currently locked task catalog;
their task ids do not identify the authored W6 session-drill cards. Mapping a
miss to one of those cards now would therefore either invent source evidence
or add a new runtime/route bridge.

## Mapping decision

Documented unsafe. No range-bucket Review/recheck mapping was added.

The existing first-week mappings remain isolated and unchanged. Review does
not claim that an authored W6 range-bucket drill is an open repair target.

## Smallest prerequisite

Add one explicit, deterministic receipt adapter at the session-drill boundary
that emits a stable range-bucket signal id, source drill id, and repair target
drill id for `range_bucket_classifier_v1`. Only after that adapter has a
launch contract into the existing repair queue should Act0 accept a mapped
range-bucket intent.

## Product EV

The prerequisite preserves causal proof: a visible range-bucket miss can only
be routed to a same-signal card when the actual source drill and target card
are both known. It avoids a misleading Review continuation built from
unrelated Act0 task ids.

## Intentionally not changed

- No receipt schema or telemetry payload.
- No Review, Practice, Home, or Profile UI.
- No Act0 route or locked-world access.
- No W6 content or manifest edits.
- No recovered-proof data.
- No screenshot tooling or generated artifacts.

## Checks

- `git diff --check`
- `git status --short`

## Remaining limitation and next step

W6 range-bucket misses remain local to the session-drill practice path. The
next safe wave is a narrow session-drill-to-repair-receipt contract, with a
real source/target launch seam and focused lifecycle tests before Review
mapping is opened.
