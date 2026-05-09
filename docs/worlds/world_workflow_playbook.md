# World Workflow Playbook

This playbook defines the standard demo and release gate workflow for World1 through World10.

## Scope and Parity

- Script parity is aligned across World1-World10.
- For each world `N` (1-10), use:
  - `./tools/demo_worldN.sh`
  - `./tools/release_gate_worldN.sh`
  - `CHECKPOINT=1 ./tools/release_gate_worldN.sh`

## Strict Full-Suite Policy

- Default release gate runs with full-suite OFF.
- Full-suite is allowed only in checkpoint mode with `CHECKPOINT=1`.
- Full-suite runs are intended only for checkpoint PRs.

## Command Pattern

Run the same 3-step pattern per world:

```bash
./tools/demo_worldN.sh
./tools/release_gate_worldN.sh
CHECKPOINT=1 ./tools/release_gate_worldN.sh
```

## Examples

### World2

```bash
./tools/demo_world2.sh
./tools/release_gate_world2.sh
CHECKPOINT=1 ./tools/release_gate_world2.sh
```

### World10

```bash
./tools/demo_world10.sh
./tools/release_gate_world10.sh
CHECKPOINT=1 ./tools/release_gate_world10.sh
```

## Do / Don't Checklist

Do:
- Run demo first to validate targeted confidence tests.
- Run release gate without checkpoint for default PR validation.
- Run checkpoint mode only when intentionally doing checkpoint PR validation.
- Keep world command usage consistent with the `worldN` naming pattern.
- Use `flutter test` for `test/guards/*` and Flutter-bound service tests.
- Use `dart test` only for pure Dart suites (for example `test/engine_v2/*`).

Don't:
- Do not run full-suite in normal PR loops.
- Do not replace checkpoint mode with ad-hoc full test commands for gate parity checks.
- Do not skip the default (full-suite OFF) release gate before checkpoint mode.
- Do not run Flutter-only tests with `dart test`.
