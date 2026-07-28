# Native iOS Visual Audit Method v1

Native iOS Simulator captures are the canonical visual-audit transport. Widget
captures remain useful only for structural regression, reachability, geometry,
and deterministic seed checks; they cannot close typography, iconography,
line-wrap, or visual-quality claims.

`tools/sharky_native_visual_audit_v1.py` builds one debug Simulator Runner with
`--dart-define=SHARKY_VISUAL_AUDIT=true`. For every state it restarts that same
installed bundle with a `SIMCTL_CHILD_*` payload, waits for the Runner's
`SHARKY_VISUAL_CAPTURE_READY:<state>` marker, then uses `xcrun simctl io ...
screenshot`. The payload is served by a narrow iOS method channel and is
unreachable when the compile-time flag is false or in release mode.

Every produced row records the state identity, semantic phase, capture source,
state classification, candidate SHA, simulator model/runtime, PNG hash, and
raw path. Raw PNGs belong in a GitHub Actions artifact or local `output/`, not
canonical main. The six-state gate must pass before a full pack is published.
