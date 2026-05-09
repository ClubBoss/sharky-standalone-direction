# R23 Formatter Gate Hardening v1

## Scope
Bounded operational reliability hardening for formatter-driven release-gate blocks only.

## Recurrence Evidence
- `tools/release_gate_world1.sh` enforces `dart format --set-exit-if-changed .` as gate step 1.
- Prior unblock commits show repeated recurrence:
  - `adac5f546` (`chore: dart format (release gate unblock) v1`)
  - `b53840561` (`chore: dart format (r21 gate unblock) v1`)

## Deterministic Handling Rule
1) Always run formatter preflight before invoking the release gate.
2) If preflight fails, allow only a format-only unblock commit.
3) Rerun preflight, then rerun release gate.
4) Do not mix logic changes with formatter unblock.

## Commands
Pre-gate:
```bash
./tools/release_preflight_world1.sh
```

Release gate:
```bash
./tools/release_gate_world1.sh
```

If preflight fails:
```bash
dart format .
git add -A
git commit -m "chore: dart format (release gate unblock) v1"
./tools/release_preflight_world1.sh
./tools/release_gate_world1.sh
```

## R23 P0.2 Verdict
Included bounded slice closed by adding a deterministic preflight surface + explicit handling rule for formatter gate failures.
