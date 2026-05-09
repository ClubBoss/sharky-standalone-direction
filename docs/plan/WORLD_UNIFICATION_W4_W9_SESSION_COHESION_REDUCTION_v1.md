# World Unification W4-W9 Session Cohesion Reduction v1

## Purpose

Record one bounded reduction wave inside the `World / Runner Unification
Frontier`.

This wave does not change canonical readiness or the active ops queue. It
reduces one measured world/unification residue that became visible once the
runner-unification audit path was restored.

## Reduced Residue

- measured residue before this wave:
  worlds `4-9` session-world rows were reported as `mixed`
- exact count before:
  `60`
- measured residue after this wave:
  worlds `4-9` session-world rows report as `canonical`
- exact count after:
  `0`

## Why This Reduction Is Honest

- the affected rows were already canonical in the truth map as playable
  `sessionDrillPlayer` session-world entries
- launch health was already `ok`
- the mixed classification came from missing session-world cohesion bucketing,
  not from contradictory runtime truth
- this wave formalizes that bucket in canonical truth rather than inventing new
  weights or rescores

## Exact Bounded Change

- extend `_kCanonicalSessionWorldCohesionSessionIdsV1` to include worlds
  `4-9` playable session-world entries
- leave campaign-pack and world10 track-session families unchanged

## Acceptance Condition

This wave is valid only if:

1. `dart run tools/runner_unification_readiness_audit_v1.dart` still runs
2. worlds `4-9` session-world rows now classify `canonical`
3. campaign-pack mixed residue and world10 track-session mixed residue remain
   unchanged unless separately reduced in future waves
