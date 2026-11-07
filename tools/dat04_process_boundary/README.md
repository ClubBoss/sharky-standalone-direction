# DAT-04 interrupted-write witness

Scope: original SHARKY_100 DAT-04, row 97, MACHINE + RESTART. No score or
release acceptance is asserted by this harness.

## Reproduce

Run from the repository root, with its pinned Flutter toolchain and locked
dependencies available:

```sh
flutter test test/ui_v2/act0_dat04_atomic_persistence_v1_test.dart
python3 tools/dat04_process_boundary/driver_v1.py --output output/dat04-unique-run
```

Use a new output directory for each execution. The driver refuses to replace
existing evidence. It preserves source identities/hashes, requests, individual
child logs, exact persisted bytes, killed/test-reader PIDs, cut markers and a
machine-readable verdict. An interrupted or failed run without `verdict.json`
is not PASS.

The two unit falsifiers cover the missing mechanism: the no-head compatibility
path must not expose a lone recovery/backup snapshot when writing and reloading
its twin fails. Both assertions fail on the original source. Load now fails
closed; save/reset also refuse to replace the surviving bytes. A checksum or a
duplicate storage copy never establishes independent learning evidence.

## What actually runs

`shell_fixtures_v1_test.dart` derives the fixtures through a source-backed
`actions_check_drill` choice and its actual feedback Continue control. The
initial learner state is a synthetic schema-18 fixture (including prior XP),
not native earned history. It exports three complete production-serialized
snapshots: before choice, recorded decision before completion, and completion
with the source task's XP. The pre-completion decision correctly grants no task
completion or XP. The original REP05 once-only control remains unchanged.

Each store operation runs in a fresh Flutter test VM. The file preference
adapter reopens the on-disk JSON on every read, writes a flushed temporary file,
then renames it. A boundary marker is published atomically. The Python parent
sends real SIGKILL to the exact waiting test-VM PID, before its save result is
produced. No exception handler, rollback or graceful teardown executes in that
VM. A different VM then loads the same durable files. Exact whole-payload
equality is checked, rather than only comparing XP counters.

For both the recorded-decision and completion snapshots:

| Interrupted boundary | Required restarted state |
| --- | --- |
| Before save; before head write; torn head temporary file | Entire old snapshot |
| Head landed, before recovery lands; torn recovery temporary file | HOLD, no learner state exposed |
| Recovery landed; torn backup temporary file; backup or mirror landed | Entire new snapshot, healed before exposure |

Further controls corrupt the only new recovery copy after an actual interrupted
write (stale backup must not win), interrupt reset before/after its fence, save
the same completed snapshot twice, and feed the genuinely recovered payload to
the production shell parser and visible replay path in another fresh VM. A
false/absent save acknowledgement is indeterminate; healing may commit the
entire new snapshot. It must never produce mixed completion/XP or infer another
independent decision.

## Limits and independent acceptance handoff

This is a versioned Linux MACHINE integration witness. Its preference adapter
is deliberately file backed and deterministic. It does **not** execute Apple's
NSUserDefaults, prove filesystem power-loss durability, or constitute an iPhone
app crash/restart receipt. Torn temporary files are controlled faults. The
fresh-shell consumer uses the exact recovered payload in a widget host, not a
native application container. Existing post-ack kill evidence in #367/#368
retains its original provenance and is not relabelled as in-flight proof.

The single integrator and independent finisher must still:

1. Pin the integrated HEAD/TREE and run the required checkpoint policy before
   a main merge. Confirm no overlapping persistence writer and preserve
   DAT02/03, DAT06, REP05/08, ASM07 and source-owned reward/evidence tests.
2. Build an exact integrated EN iPhone 14 Pro (393x852) candidate. Preserve its
   source/binary manifest and original application data. Use an owned test
   profile; do not borrow or reset another worker's simulator.
3. Record a genuine source decision, interrupt the actual pending preference
   operation before completion acknowledgement, then kill the app. Capture at
   least before-save, head-only and recovery-landed boundaries, including the
   completion/XP snapshot. Any temporary timing instrumentation needs its own
   exact source/binary identity and must observe existing writes without
   injecting learner progress or changing the transaction algorithm.
4. Relaunch and show whole old/new state or explicit recovery HOLD; never show
   half completion/XP, silently reset progress, resurrect a stale backup, or
   upgrade assistance/duplicate history into independent proof. Replay the
   same source task after restart and verify once-only XP. Keep raw lifecycle,
   preference, telemetry and visible-state receipts joined to source attempts.
5. Independently adjudicate the original row's complete acceptance criteria.
   MACHINE PASS alone cannot award the DAT-04 point or admit release/Human.

### Exact shared seam if #380 is taken into main

Live #380 at `29af178a5a74134713b3492ca748c49dbe69dcec` also edits the
singleton branch of `_resolve`, adding an immutable read-only `inspection`.
It remains an unmerged older Draft, not part of this candidate's base. Do not
take either branch's entire function over the other. Preserve #380's
non-destructive eligibility inspection and apply the DAT04 heal requirement
only to ordinary reads. The resolved singleton branch must be:

```dart
final only = rec ?? bak;
if (only != null) {
  if (inspection != null) {
    return (revision: only.revision, payload: only.payload);
  }
  final twin = identical(only, rec) ? backupKey : recoveryKey;
  if (!await _write(prefs, twin, only.raw) ||
      _parse(prefs, recoveryKey)?.raw != only.raw ||
      _parse(prefs, backupKey)?.raw != only.raw) {
    throw const _CheckpointHealFailure();
  }
  return (revision: only.revision, payload: only.payload);
}
```

In particular, an I/O/heal refusal must not make an otherwise readable survivor
reset-eligible. Re-run #380's readable-survivor/inspection/confirmation controls
and the two DAT04 negatives on the combined bytes. This is a proposed serial
resolution, **not an executed combined-tree test or acceptance of #380**.
